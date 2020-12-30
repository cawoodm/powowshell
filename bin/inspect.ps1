<#
  .Synopsis
  Inspect a component (powershell script) to view it's input and outputs

  .Description
  PowowShell expects components (scripts) to clearly define their interface.
  This script returns basic information about a script
  It always returns something for each .ps1 file

  .Parameter Path
  The path to the .ps1 script

  .Parameter Action
  Action = "export": Export description as JSON

  .Parameter ExportPath
  Path to export to

#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Path,
  [string][ValidateSet("export")]$Action,
  [string]$ExportPath
)
function main() {

  try {
    # A necessary evil here so we can query properties without try/catch or other shenanigans
    Set-StrictMode -Off
    $POWMessages=@();
    if ($ExportPath) {$ExportPath = (Resolve-Path -Path $ExportPath).Path}
    # Add .ps1 to components with a path so `pow inspect !componentName` works
    if ($Path.indexOf([IO.Path]::DirectorySeparatorChar) -ge 0 -and $Path -notlike "*.ps1") {$Path="$Path.ps1"}
    $Executable = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    if ($Executable) {
      $CompType = "component"
      $Executable = $Executable.Path
      $Name = (Split-Path -Path $Executable -Leaf)
      $NiceName = ($Name -replace ".ps1", "")
      Write-Verbose "Inspecting component $Name ..."
      $cmd = Get-Help -Full -Name $Executable -ErrorAction SilentlyContinue
      $cmd2 = Get-Command -Name $Executable -ErrorAction SilentlyContinue
      if ($null -eq $cmd) {throw "Invalid POW Component '$Executable'!"}
      $outputType = Get-OPType($cmd2)
      if (-not $outputType) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="No output type on '$NiceName'! Consider adding a [OutputType()] annotation."}}
      $outputFormat = Get-OPReturn($cmd)
      if (-not $outputFormat) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="No output format on '$NiceName'! Consider adding a .Outputs annotation."}}
    } else {
      $CompType = "cmdlet"
      $Executable = $Path
      Write-Verbose "Inspecting installed CmdLet $Path ..."
      $Name = $Path
      $CachePath = "$($_POW.CACHER)/help"
      if (-not (Test-Path $CachePath)) {$null = New-Item -Path $CachePath -ItemType Directory}
      if (Test-Path "$CachePath/$Name.json") {
        $cmd = Get-Content "$CachePath/$Name.json" | ConvertFrom-Json
      } else {
        $cmd = Get-Help -Full -Name $Name -ErrorAction SilentlyContinue
        # Help returns prefix match so "Get-Item" => ["Get-Item", "Get-Item2"]
        if ($cmd -is [array]) {$cmd = $cmd | Where-Object {$_.Name -like $Name}}
        if ($cmd.details.name -notlike $Name) {
          Write-Warning "'$Name' is an alias, please inspect the full name $($cmd.details.name)!"
          return
        }
        # Cache help because Get-Help can be slow
        $cmd | ConvertTo-Json -Depth 7 | Set-Content -Encoding UTF8 -Path "$CachePath/$($cmd.details.name).json"
      }
      if ($null -eq $cmd) {throw "Invalid CmdLet '$Executable'!"}
      $NiceName = $cmd.details.name
      $outputType = Get-OPReturn($cmd)
      # CmdLets don't know our output formats like "text/json"
      # TODO: Can we assume PSObj?
      $outputFormat=$null
    }
    # PS1: Should we use extension or not ???
    $reference = $Name.ToLower()

    $whatif=$false; #$confirm=$false; $passthru=$false;
    $paramsOut = @(); $inputType=$null; $inputFormat = $null; $inputDesc = $null; $outputDesc=$null; $PipedParamCount=0;
    if ($cmd.PSObject.Properties.item("details")) {
      $boolMap = @{"true"=$true;"false"=$false}
      $parameters = try{$cmd.parameters.parameter}catch{$null}
      # Only Syntax.syntaxItem has parameterValueGroup.parameterValue on each parameter
      $parameters2 = try{$cmd.Syntax.syntaxItem[0].parameter}catch{$null}
      $pipelineInputParam = $false;
      foreach ($parameter in $parameters) {
        $parameter2 = $parameters2 | Where-Object Name -eq $parameter.name
        $paramPipeMode=$null; $paramPipe=$null;
        if ($parameter.name -eq "WhatIf") {$whatif = $true; continue;}
        #if ($parameter.name -eq "Confirm") {$confirm = $true; continue;}
        #if ($parameter.name -eq "PassThru") {$passthru = $true; continue;}
        $paramType = Get-ParamType $parameter
        if ($parameter.pipelineInput -like "true*") {
          $paramPipe=$true;
          if ($parameter.pipelineInput -like "*ByValue*") {
            $paramPipeMode+="value";
            $PipedParamCount++;
            $pipelineInputParam = $true;
            $inputType = $paramType;
          }
          if ($parameter.pipelineInput -like "*ByPropertyName*") {
            $paramPipeMode+="name"
          }
        }
        if ($CompType -eq "component") {
          $paramValues = GetParamValues $cmd2.parameters[$parameter.name]
        } else {
          $paramValues = GetParamValues $parameter2 | Where-Object {$_ -ne $null}
        }
        # WEIRD: We have to convert a null object to a real null (or we get "{}" in JSON)
        if ($null -eq $paramValues) {$paramValues=$null}
        $paramDefault=$null
        if ($parameter.defaultValue -and $parameter.defaultValue -notlike "none" -and $parameter.defaultValue -notlike "false") {
          $paramDefault = $parameter.defaultValue
        }
        $paramsOut += [PSCustomObject]@{
          "name" = $parameter.name;
          "type" = $paramType
          "piped" = $paramPipe
          "pipedMode" = $paramPipeMode
          "required" =  $boolMap[$parameter.required];
          "default" = $paramDefault
          "description" = (&{try{$parameter.description[0].text}catch{$null}})
          "values" = $paramValues;
        };
      }
      if ($CompType -eq "component") {
        if ($null -eq $parameters) {$POWMessages+=[PSCustomObject]@{type="INFO";message="No parameters found in component '$Name'!"}}
        if ($pipelineInputParam) {
          $inputFormat = Get-IPType($cmd); if ($inputFormat -like "none") {$inputFormat=$null}
          $inputDesc = Get-IPDesc($cmd)
        }
        if ($pipelineInputParam -and -not $inputFormat) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not described properly in annotated comments (.Inputs) of $NiceName!"}}
        if (-not $pipelineInputParam -and $inputFormat) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not declared properly in parameters (ValueFromPipeline=`$true) of $NiceName!"}}
      }
      #if ($PipedParamCount -gt 1) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="We don't support multiple piped parameters in '$NiceName'!"}}
    } else {
      $POWMessages+=[PSCustomObject]@{type="ERROR";message="Invalid CmdLet in component '$Name'!"}
    }
    $synopsis = Get-Synopsis($cmd)
    $description = Get-Description($cmd)
    # Weird "none or" outputs
    $outputType = $outputType -replace 'None or ', ''
    $outputType = $outputType -replace 'None, ', ''
    # Use 'string' instead of 'system.string'
    $outputType = $outputType -replace '^system\.', ''
    $inputType = $inputType -replace '^system\.', ''
    $inputType = $inputType.toLower();

    # Map PSObjects to the object adaptor
    $MapTypes=@{
      "psobject"="object"
      "psobject[]"="object[]"
      "management.automation.psobject"="object"
      "management.automation.psobject[]"="object[]"
    }
    if ($MapTypes.Contains($inputType)) {$inputType=$MapTypes[$inputType]}
    if ($MapTypes.Contains($outputType)) {$outputType=$MapTypes[$outputType]}

    if ($CompType -eq "component") {$outputDesc = Get-OPDesc($cmd)}
    $result = [PSCustomObject]@{
      "reference" = $reference;
      "name" = $NiceName;
      "type" = $CompType;
      "executable" = $Executable;
      "synopsis" = $synopsis;
      "description" = $description;
      "module" = $cmd.ModuleName;
      "whatif" = $whatif;
      "parameters" = $paramsOut;
      "input" = $inputType;
      "inputFormat" = $inputFormat;
      "inputDescription" = $inputDesc;
      "output" = $outputType;
      "outputFormat" = $outputFormat;
      "outputDescription" = $outputDesc;
      "POWMessages" = $POWMessages
    }
    if ($Action -like "export") {
      if ($ExportPath) {
        return $result | ConvertTo-Json | Set-Content -Path $ExportPath -Encoding UTF8
      } else {
        return $result | ConvertTo-Json
      }
    } else {
      $POWMessages | ForEach-Object {Write-Warning ($_.type + ": " + $_.message)}
      return $result
    }
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
     throw $_
  }
}
function Get-Synopsis($cmd) {try{$cmd.details.description[0].Text}catch{$null}}
function Get-Description($cmd) {try {return $cmd.description[0].Text}catch{$null}}
function Get-IPType($cmd) {try{([string](Get-IP($cmd))[0]).ToLower() -replace "[\r\n]", ""}catch{$null}}
function Get-IPDesc($cmd) {try{[string](@(Get-IP($cmd)))[1]}catch{$null}}
function Get-IP($cmd) {try{@($cmd.inputTypes[0].inputType[0].type.name+"`n" -split "[\r\n]")}catch{$null}}
function GetParamValues($param) {
  if ($param.parameterValueGroup.parameterValue){return $param.parameterValueGroup.parameterValue} elseif ($param.Attributes.ValidValues) {return $param.Attributes.ValidValues}
  # With strictmode on we don't get the ValidValues!
}
function Get-ParamType($param) {
  $result=$null
  if ($param.parameterValue.value) {$result = [string]$param.parameterValue.value.toLower()} elseif ($param.type.name) {$result = [string]$param.type.name.toLower()}
  if ($result -like "switchparameter") {$result = "switch"}
  return $result;
}
function Get-OPReturn($cmd) {
  $result = Get-OP($cmd)
  if ($result -is [array]) {
    Write-Warning "$($cmd.name) has multiple possible output types ($($result -join ', '))!"
    # If we have multiple object types, just 'any'
    $result="any"
  } elseif ($result -like '* *') {
    Write-Warning "$($cmd.name) has multiple possible output types ($result)!"
    $result="any"
  }
  return [string]$result;
}
function Get-OPType($cmd) {try{([string]($cmd.OutputType[0].Name)).ToLower()}catch{$null}}
function Get-OPDesc($cmd) {try{[string](@(Get-OP($cmd)))[1]}catch{$null}}
function Get-OP($cmd) {try{@($cmd.returnValues.returnValue | ForEach-Object {$_.type.name})}catch{$null}}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main