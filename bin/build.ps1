<#
 .Synopsis
 Build a pipeline from it's definition into runnable run.ps1 script

 .Description
 Will read and parse the pipeline.json file inside the pipeline folder.
 Next, each component listed is verified.

 .Parameter Path
 The path to a pipeline directory to build

 .Parameter Output
 The path to output the resulting powershell program (runnable pipeline)

#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][String]$Path,
  [String]$Output
)
$OutputPath = "./build/"
function main() {

  # Save path we are started from
  $StartPath = (Get-Location).Path
  
  $FullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
  if ($null -eq $FullPath) { throw "Path to pipeline $Path not found!" }
  if ($Output) { $OutputPath = Resolve-Path $Output -ErrorAction SilentlyContinue }
  if ($null -eq $OutputPath) { throw "Output path $Output not found!" }
  Push-Location $FullPath.Path

  if (Test-Path $OutputPath) { Remove-Item $OutputPath -Recurse -Force }
  New-Item -Path $OutputPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
  
  try {
    BuildingPipeline
  }
  catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
  finally {
    Set-Location $StartPath
  }
}

function BuildingPipeline() {

  # Get all known components as a HashTable
  $COMPONENTS = @{}
  # ASSUME: components a sibling of pipeline
  & "$PSScriptRoot/components.ps1" "../components/" | ForEach-Object {
    $COMPONENTS.add($_.reference, $_)
  }

  # Get all known adaptors as a HashTable
  $ADAPTORS = @{}
  & pow adaptors | ForEach-Object { $ADAPTORS.add($_.type, $_) }

  # Read pipeline.json definition
  $pipelineDef = ReadPipelineDefinition("pipeline.json")

  # Validate definition
  CheckSteps $pipelineDef.steps $COMPONENTS

  # Transform definition of components into Steps
  CreateSteps -pipelineDef $pipelineDef -COMPONENTS $COMPONENTS -ADAPTORS $ADAPTORS

  # Transform definition of pipeline into run_trace.ps1
  CreatePipeline_trace $pipelineDef

  # Transform definition of pipeline into run_prod.ps1
  CreatePipeline_prod $pipelineDef $COMPONENTS

  Show-Message "SUCCESS: BUILD completed" Green

  Push-Location $StartPath
  $p = Join-Path $Path $OutputPath | Resolve-Path -Relative;
  Pop-Location
  if ($Output) { $p = $Output }
  "Usage:`n  pow run $p"
  "OR`n  pow run $p -Trace"
  "OR`n  $(Join-Path $p run_prod.ps1)"

  # Show params
  $cmd = Get-Command "$OutputPath/run_prod.ps1"
  "`nParameters:"
  $cmd.Parameters.Keys |
  Where-Object { $_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters } |
  ForEach-Object { " $_" };

}
function ReadPipelineDefinition($Path) {
  try {
    Get-Content -Raw ./pipeline.json | ConvertFrom-Json
  }
  catch {
    throw ("Error Parsing Pipeline Definition: $Path" + $_)
  }
}

<#
 .Synopsis
 Basic checks of components/cmdlets referenced in the pipeline
#>
function CheckSteps($steps, $COMPONENTS) {

  # Make sure we have at least one step
  if (-not $steps -or -not $steps.length -or $steps.length -eq 0) { throw "No steps found!" }
  Write-Verbose "$($steps.length) steps found"

  # Check each step
  foreach ($step in $steps) {
    Write-Verbose "Checking $($step.id): $($step.reference)"
    $component = $COMPONENTS[$step.reference]
    # If not cached, inspect the component
    if ($null -eq $component) { $component = & "$PSScriptRoot/inspect.ps1" $step.reference }
    $COMPONENTS[$component.reference] = $component
    Write-Verbose "$($component.reference) is a $($component.type)"
    # Check same number of parameters
    if ($component.parameters.length -eq 0 -and $step.parameters.length -gt 0) { throw "Step $($step.id) has parameters but component does not!" }
    # TODO: Check mandatory fields (e.g. id)
    # TODO: Check parameters against component definition? - Done in CreateSteps()
  }

  Write-Verbose "`tSteps checked out OK"

}
function CreateSteps($pipelineDef, $COMPONENTS, $ADAPTORS) {

  # Step template
  $stepHeader = "[CmdletBinding(SupportsShouldProcess)]"
  $PipelineParamsS = "param(`$PipelineParams=@{})"
  # TODO: Should we add the [type] of piped input here?
  $PipelineParamsI = "param([Parameter(ValueFromPipeline=`$true)]`$InputObject,`$PipelineParams=@{})"
  $stepHeaderMain = "function main() {"
  $stepHeaderProcess = "process {"
  $stepHeaderEnd = "end {"
  $StepComment = $null
  $stepFooterMain = "}`nmain"
  $stepFooterStream = "}`n"

  $Count = 0

  foreach ($step in $pipelineDef.steps) {

    $id = $step.id
    $ref = $step.reference

    # Get component definition and path
    $component = $COMPONENTS[$step.reference]
    $compPath = $component.executable

    # Pass PARAMETERS to the Component
    $params0 = "`t`$params = " + (ReSerializeObject $step.parameters);
    $params0 = $params0 -replace "\n", "`n`t";

    if ($step.input) { $PipelineParams = $PipelineParamsI } else { $PipelineParams = $PipelineParamsS }

    # Pass piped INPUT to the Component
    $inputSrc = if ($step.input) { '$InputObject | & ' }else { '& ' };

    # Validate OUTPUT of Component
    $outputType = $component.output
    if (-not $outputType) {
      Write-Verbose "NOTE: No OutputType found for component '$ref'!"
    }
    elseif (-not $ADAPTORS.ContainsKey($outputType)) {
      #throw "No adaptor found for output ($outputType) of component '$ref'!"
      Write-Warning "No adaptor found for output ($outputType) of component '$ref'!"
    }

    # Add a comment
    if ($step.name) { $StepComment = "`t# $($step.name)" } else { $StepComment = $null }

    # Actual core component call
    $cmd1 = "`t$inputSrc$compPath @params"

    # Add output type
    $stepOutputType = $null; if ($component.output) { $stepOutputType = "[OutputType([$($component.output)])]" }

    if ($step.stream -eq "process") {
      $cmd1 = $cmd1.replace('$InputObject', '$_')
      $stepHeader2 = $stepHeaderProcess
      $stepFooter = $stepFooterStream
    }
    elseif ($step.stream -eq "end") {
      $cmd1 = $cmd1.replace('$InputObject', '$input')
      $stepHeader2 = $stepHeaderEnd
      $stepFooter = $stepFooterStream
    }
    else {
      $stepHeader2 = $stepHeaderMain
      $stepFooter = $stepFooterMain
    }

    # Build Step code
    $stepHeader, $stepOutputType, $PipelineParams, $stepHeader2, $params0, $StepComment, $cmd1, $stepFooter -join "`n" | Set-Content -Encoding UTF8 -Path "$OutputPath/step_$id.ps1"

    $Count++

  }

  Write-Verbose "$Count steps created"

}
function Get-Step($id) { $pipelineDef.steps | Where-Object id -eq $id }

<#
  CreatePipeline_prod
  Create pipeline for production
   * No trace files are used
   * Performance is better
#>
function CreatePipeline_prod($pipelineDef, $COMPONENTS) {
  Write-Verbose "BUILDER CreatePipeline_prod"

  # Can be run from anywhere, change to pipeline path
  $cmd = ReSerializeParams $pipelineDef.parameters;
  $cmd += ReSerializePipelineParams $pipelineDef.parameters;
  $cmd += ("`$PipelineGlobals = " + (ReSerializeObject $pipelineDef.globals) + "`n");
  $cmd += "Push-Location `$PSScriptRoot`n"
  $cmd += "`n"
  $cmd += "try {`n`n"

  foreach ($step in $pipelineDef.steps) {

    $id = $step.id
    $component = $COMPONENTS[$step.reference]

    $cmd += "`t# Run Step $($id) $($step.reference): $($step.name)`n"
    $cmd += "`tWrite-Verbose `"Running step $($id) : $($step.name)`"`n"

    # TODO: Add adaptors for mismatched pipes
    if ($step.input) {
      # TODO: Show type FROM and type TO when piping between steps
      $predecessor = Get-Step $step.input
      $precomp = $COMPONENTS[$predecessor.reference]
      $cmd += "`t# FROM [$($precomp.output)] => TO [$($component.input)]`n"
    }

    # Capture step OUTPUT
    $cmd += "`t`$OP_$id = "

    # Pass INPUT to step
    if ($step.input) { $cmd += "`$OP_$($step.input) | " }

    # Run step LOGIC (passing all PipelineParams)
    $cmd += "./step_$($id).ps1 -PipelineParams `$PipelineParams`n`n"

  }

  # Return OUTPUT
  $cmd += "`t`$OP_$($id)`n"

  # Clean up
  $cmd += "`n"
  $cmd += "} catch {`n"
  #$cmd += ('$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")' + "`n")
  $cmd += "`tthrow `$_`n"
  $cmd += "} finally {`n"
  $cmd += "`tPop-Location`n"
  $cmd += "}`n"

  $cmd | Set-Content -Encoding UTF8 -Path "$OutputPath/run_prod.ps1"

}

<#
  CreatePipeline_trace
  Create pipeline for tracing
   * Trace files are generated
   * Better for debugging
#>
function CreatePipeline_trace($pipelineDef) {

  Write-Verbose "BUILDER CreatePipeline_prod"

  # Can be run from anywhere, change to pipeline path
  $cmd = ReSerializeParams $pipelineDef.parameters;
  $cmd += ReSerializePipelineParams $pipelineDef.parameters;
  $cmd += ("`$PipelineGlobals = " + (ReSerializeObject $pipelineDef.globals) + "`n");
  $cmd += "`$ErrorActionPreference = 'Stop'`n"
  $cmd += "Push-Location `$PSScriptRoot`n"
  #$cmd += "`$VerbosePreference='Continue'`n"
  $cmd += "#Create folder for trace files`n"
  $cmd += "New-Item -Path ./trace -ItemType Directory -ErrorAction SilentlyContinue | Out-Null`n"
  $cmd += "`n"

  $pipelineDef.steps | ForEach-Object { $step = $_;

    $id = $step.id

    $cmd += "# Run Step $($id): $($step.name)`n"
    $cmd += "Write-Verbose `"Running step $($id): $($step.name)`"`n"

    if ($step.input) {
      # Pass INPUT to step
      $cmd += "Get-Content -Raw ./trace/tmp_$($step.input)_output.txt | "
    }

    # Run step LOGIC and capture OUTPUT
    $cmd += "./step_$($id).ps1 -PipelineParams `$PipelineParams > ./trace/tmp_$($id)_output.txt 2> ./trace/tmp_$($id)_errors.txt 5>>./trace/tmp_debug.txt`n`n"

  }

  # Return OUTPUT
  $cmd += "# Return Output`n"
  #$cmd += "Get-Content -Raw ./trace/tmp_$($id)_output.txt`n"
  $cmd += "Write-Host `"Trace output is in the trace/ folder of your pipeline`""

  # Clean up
  $cmd += "`n"
  $cmd += "Pop-Location"

  $cmd | Set-Content -Encoding UTF8 -Path "$OutputPath/run_trace.ps1"

}
function ReSerializeObject($obj) {
  Write-Verbose "BUILDER ReSerializeObject"
  $res = "@{`n"
  foreach ($prop in $obj.PSObject.Properties) {
    $pVal = $prop.Value; $pName = $prop.Name
    # Map booleans to powershell literals ($true/$false)
    if (([string]$pVal).Contains("`{") -and $pVal.EndsWith("}")) {
      # Parameter is code (a PowerShell Expression)
      # TODO: Escape code for PS
      $res += "`t$($pName) = " + $pVal.SubString(1, $pVal.Length - 2) + "`n"
    }
    elseif ($pVal -eq $true) {
      $res += "`t$($pName) = `$true`n"
    }
    elseif ($pVal -eq $false) {
      $res += "`t$($pName) = `$false`n"
    }
    elseif ($null -eq $pVal) {
      # Don't produce null parameters
    }
    elseif ($pVal -is [array]) {
      $arrVal = '"' + ($pVal -join '", "') + '"'
      # TODO: Escape String for PS
      $res += "`t$($pName) = $arrVal`n"
    } else {
      # Parameter is a String
      # TODO: Escape String for PS
      $res += "`t$($pName) = `"$($pVal)`"`n"
    }
  }
  $res += "};"
  return $res
}
function ReSerializeParams($parameters) {
  Write-Verbose "BUILDER ReSerializeParams"
  if ($parameters -is [array]) { throw "Parameters object should not be an array!" }
  try {
    $res = "[CmdletBinding(SupportsShouldProcess)]`n"
    $res += "param(`n"
    foreach ($param in $parameters.PSObject.Properties) {
      $pName = $param.Name
      $pObj = $param.Value
      Set-StrictMode -Off
      $pVal = $pObj.default
      $pType = $pObj.type
      if ($pType) { $pType = "[$pType]" }
      $pMust = $pObj.mandatory
      if ($pMust -eq $true) { $pMust = "[Parameter(Mandatory=`$true)]" } else { $pMust = "" }
      if ($pVal.Contains("`{") -and $pVal.EndsWith("}")) {
        # Parameter is code (a PowerShell Expression)
        # TODO: Escape code for PS
        $res += "`t$pMust$pType`$$($pName) = (" + $pVal.SubString(1, $pVal.Length - 2) + "),`n"
      }
      else {
        # Parameter is a String
        # TODO: Escape String for PS
        $res += "`t$pMust$pType`$$($pName) = `"$($pVal)`",`n"
      }
    }
    $res = $res -replace ',\n$', "`n"
    $res += ")`n"
    return $res
  }
  catch {
    # TODO: Why are we catching here??
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
  }
}
function ReSerializePipelineParams($obj) {
  Write-Verbose "BUILDER ReSerializePipelineParams"
  if ($obj -is [array]) { throw "Parameters object should not be an array!" }
  $res = "`$PipelineParams = @{`n";
  foreach ($param in $obj.PSObject.Properties) {
    Write-Verbose $param.Name
    $pName = $param.Name
    # TODO: Escape String for PS
    $res += "`t$($pName) = `$$($pName);`n"
  }
  $res = $res -replace ',\n$', "`n"
  $res += "};`n"
  return $res
}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main