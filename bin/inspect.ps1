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
		if ($ExportPath) {$ExportPath = (Resolve-Path -Path $ExportPath).Path}
		$RealPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
		if ($RealPath) {
			$CompType = "component"
			$RealPath = $RealPath.Path
			Write-Verbose "Inspecting custom POW Component from $RealPath ..."
			$Name = (Split-Path -Path $RealPath -Leaf)
			$cmd = Get-Help -Full -Name $RealPath -ErrorAction SilentlyContinue
			$cmd2 = Get-Command -Name $RealPath -ErrorAction SilentlyContinue
			if ($null -eq $cmd) {throw "Invalid POW Component '$RealPath'!"}
			$outputType = Get-OPType($cmd2)
			$outputFormat = Get-OPReturn($cmd)
		} else {
			$CompType = "cmdlet"
			$RealPath = $Path
			Write-Verbose "Inspecting installed CmdLet $Path ..."
			$Name = $Path
			$cmd = Get-Help -Full -Name $Name -ErrorAction SilentlyContinue
			$cmd2 = Get-Command -Name $Name -ErrorAction SilentlyContinue
			if ($null -eq $cmd) {throw "Invalid CmdLet '$RealPath'!"}
			$outputType = Get-OPReturn($cmd)
			$outputFormat = Get-OPType($cmd2)
		}
		$reference = ($Name -replace ".ps1", "").ToLower()
		$POWMessages=@()
		$paramsOut = @(); $inputFormat = ""; $inputDesc = ""; $inputType=$null
		if ($cmd.PSObject.Properties.item("details")) {
			$boolMap = @{"true"=$true;"false"=$false}
			$parameters = Get-Help -Name $RealPath -Parameter * -EA 0
			if ($null -eq $parameters) {$POWMessages+=[PSCustomObject]@{type="INFO";message="No parameters found in component '$Name'!"}}
			$pipelineInputParam = $false;
			foreach ($parameter in $parameters) {
				if ($parameter.pipelineInput -like "true*") {
					$pipelineInputParam = $true;
					$inputType = $parameter.type.name.ToLower();
				} else {
					$paramsOut += [PSCustomObject]@{
						"name" = $parameter.name;
						"type" = $parameter.type.name;
						"required" =  $boolMap[$parameter.required];
						"default" = (&{try{$parameter.defaultValue}catch{$null}})
						"description" = (&{try{$parameter.description[0].text}catch{$null}})
					};
				}
			}
			if ($pipelineInputParam) {
				$inputFormat = Get-IPType($cmd); if ($inputFormat -like "none") {$inputFormat=$null}
				$inputDesc = Get-IPDesc($cmd)
			}
			if ($pipelineInputParam -and -not $inputFormat) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not described properly in annotated comments (.Inputs) of $Name!"}}
			if (-not $pipelineInputParam -and $inputFormat) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not declared properly in parameters (ValueFromPipeline=`$true) of $Name!"}}
		} else {
			$POWMessages+=[PSCustomObject]@{type="ERROR";message="Invalid CmdLet in component '$Name'!"}
		}
		$synopsis = Get-Synopsis($cmd)
		$description = Get-Description($cmd)
		# Use 'string' instead of 'system.string'
		$outputType = $outputType -replace '^system\.', ''
		$inputType = $inputType -replace '^system\.', ''
		# Store actual type in format for CmdLets
		#$CompType
		# PSObjects are Objects
		#$MapTypes=@{psobject="object"}
		#if ($MapTypes.Contains($inputType)) {$inputType=$MapTypes[$inputType]}
		$outputDesc = Get-OPDesc($cmd)
		$result = [PSCustomObject]@{
			"reference" = $reference;
			"type" = $CompType;
			"path" = $RealPath;
			"synopsis" = $synopsis;
			"description" = $description;
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
				return $result | ConvertTo-Json > $ExportPath
			} else {
				return $result | ConvertTo-Json
			}
		} else {
			return $result
		}
	} catch {
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
	}
}
function Get-Synopsis($cmd) {try{$cmd.details.description[0].Text}catch{$null}}
function Get-Description($cmd) {try {return $cmd.description[0].Text}catch{$null}}
function Get-IPType($cmd) {try{([string](Get-IP($cmd))[0]).ToLower() -replace "[\r\n]", ""}catch{$null}}
function Get-IPDesc($cmd) {try{[string](@(Get-IP($cmd)))[1]}catch{$null}}
function Get-IP($cmd) {try{@($cmd.inputTypes[0].inputType[0].type.name+"`n" -split "[\r\n]")}catch{$null}}
function Get-OPReturn($cmd) {try{([string](Get-OP($cmd))[0]).ToLower() -replace "[\r\n]", ""}catch{$null}}
function Get-OPType($cmd) {try{([string]($cmd.OutputType[0].Name)).ToLower()}catch{$null}}
function Get-OPDesc($cmd) {try{[string](@(Get-OP($cmd)))[1]}catch{$null}}
function Get-OP($cmd) {try{@($cmd.returnValues[0].returnValue[0].type.name+"`n" -split "`n")}catch{$null}}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
#[Console]::OuputEncoding = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main