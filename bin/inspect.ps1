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
		$Path = (Resolve-Path -Path $Path).Path
		if ($ExportPath) {$ExportPath = (Resolve-Path -Path $ExportPath).Path}
		$Filename = (Split-Path -Path $Path -Leaf)
		Write-Verbose "Inspecting $Path ..."
		$POWMessages=@()
		$cmd = Get-Help -Full -Name $Path -ErrorAction SilentlyContinue
		$paramsOut = @(); $inputType = ""; $inputDesc = "";
		if ($cmd.PSObject.Properties.item("details")) {
			$boolMap = @{"true"=$true;"false"=$false}
			$parameters = Get-Help -Name $Path -Parameter * -EA 0
			if ($null -eq $parameters) {$POWMessages+=[PSCustomObject]@{type="INFO";message="No parameters found in component '$Filename'!"}}
			$pipelineInputParam = $false;
			foreach ($parameter in $parameters) {
				if ($parameter.pipelineInput -like "true*") {
					$pipelineInputParam = $true;
				} else {
					$paramsOut += [PSCustomObject]@{
						"name" = $parameter.name;
						"type" = $parameter.type.name;
						"required" =  $boolMap[$parameter.required];
						"default" = $parameter.defaultValue;
						"description" = (&{if ($parameter.PSObject.Properties.Item("description") -and $parameter.description.length) {$parameter.description[0].text} else {""}})
					};
				}
			}
			if ($pipelineInputParam) {
				$inputType = Get-IPType($cmd)
				$inputDesc = Get-IPDesc($cmd)
			}
			if ($pipelineInputParam -and -not $inputType) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not described properly in annotated comments (.Inputs) of $Filename!"}}
			if (-not $pipelineInputParam -and $inputType) {$POWMessages+=[PSCustomObject]@{type="WARNING";message="Pipeline input not declared properly in parameters (ValueFromPipeline=`$true) of $Filename!"}}
		} else {
			$POWMessages+=[PSCustomObject]@{type="ERROR";message="Invalid CmdLet in component '$Filename'!"}
		}
		$synopsis = Get-Synopsis($cmd)
		$description = Get-Description($cmd)
		$outputType = Get-OPType($cmd)
		$outputDesc = Get-OPDesc($cmd)
		$reference = $Filename -replace ".ps1", ""
		$result = [PSCustomObject]@{
			"reference" = $reference;
			"synopsis" = $synopsis;
			"description" = $description;
			"parameters" = $paramsOut;
			"input" = $inputType;
			"inputDescription" = $inputDesc;
			"output" = $outputType;
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
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)")
		#throw $_
	}
}
function Get-Synopsis($cmd) {try{$cmd.details.description[0].Text}catch{$null}}
function Get-Description($cmd) {try {return $cmd.description[0].Text}catch{$null}}
function Get-IPType($cmd) {try{([string](Get-IP($cmd))[0]).ToLower()}catch{$null}}
function Get-IPDesc($cmd) {try{[string](@(Get-IP($cmd)))[1]}catch{$null}}
function Get-IP($cmd) {try{@($cmd.inputTypes[0].inputType[0].type.name+"`n" -split "`n")}catch{$null}}
function Get-OPType($cmd) {try{([string](Get-OP($cmd))[0]).ToLower()}catch{$null}}
function Get-OPDesc($cmd) {try{[string](@(Get-OP($cmd)))[1]}catch{$null}}
function Get-OP($cmd) {try{@($cmd.returnValues[0].returnValue[0].type.name+"`n" -split "`n")}catch{$null}}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
#[Console]::OuputEncoding = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main