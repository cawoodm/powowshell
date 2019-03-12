<#
	.Synopsis
	Inspect a component (powershell script) to view it's input and outputs
	
	.Description
	PowowShell expects components (scripts) to clearly define their interface.
	This script returns basic information about a script
	
	.Parameter Path
	The path to the .ps1 script
	
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][string]$Path,
	[switch]$Full
)
function main() {
	$FullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
	if ($FullPath -eq $null) {throw "Path $Path not found!"}
	$Path = ($FullPath).Path
	Write-Verbose "Inspecting $Path ..."
	#if ($Full) {return Get-Help $Path -Full | ConvertTo-Json}
	$cmd = Get-Help -Full -Name $Path
	$boolMap = @{"true"=$true;"false"=$false}
	$parameters = Get-Help -Name $Path -Parameter *
	$inputType = ""
	$paramsOut = @()
	$parameters | % {
		if ($_.pipelineInput -eq $true) {
			write-host $_.name
			$inputType = IPType($cmd)
		} else {
			$paramsOut += [PSCustomObject]@{
				"name" = $_.name;
				"type" = $_.type.name; #"string"
				"required" =  $boolMap[$_.required];
				"default" = $_.defaultValue;
				"description" = (&{if ($_.PSObject.Properties.Item("description") -and $_.description.length) {$_.description[0].text} else {""}})
			};
		}
	}
	return [PSCustomObject]@{
		"reference" = Split-Path -Path $Path -Leaf;
		"synopsis" = $cmd.details.description[0].Text;
		"description" = $cmd.description[0].Text;
		"parameters" = $paramsOut;
		"input" = $inputType;
		"output" = OPType($cmd)
	} #| ConvertTo-Json
}
function IPType($cmd) {return $cmd.inputTypes[0].inputType.type.name.ToLower();trap {return "none"}}
function OPType($cmd) {return $cmd.returnValues[0].returnValue[0].type.name.ToLower();trap {return "none"}}
function IPMode($cmd) {
	#$cmd.parameters.parameter.name.Contains("InputObject");
}
Set-StrictMode -Version Latest
main