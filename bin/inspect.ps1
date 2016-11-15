<#
	.Synopsis
	Inspect a powershell script or cmdlet to view it's input and outputs
	
	.Description
	PowowShell expects components (scripts) to clearly define their interface.
	This script returns basic information about a script
	
	.Parameter Name
	The name of the cmdlet or the path to the .ps1 script
	
#>
param(
	[Parameter(Mandatory=$true)][string]$Name,
	[switch]$Full
)
function main() {
	if ($Full) {return Get-Help $Name -Full | ConvertTo-Json}
	$cmd = Get-Help -Full -Name $Name
	$obj = @{
		name = Split-Path -Path $Name -Leaf
		input = IPType($cmd)
	  output = OPType($cmd)
	}
	New-Object -TypeName PSObject -Property $obj
}
function IPType($cmd) {return $cmd.inputTypes[0].inputType.type.name.ToLower();trap {return "none"}}
function OPType($cmd) {return $cmd.returnValues[0].returnValue[0].type.name.ToLower();trap {return "none"}}
function IPMode($cmd) {
	#$cmd.parameters.parameter.name.Contains("InputObject");
}
Set-StrictMode -Version 3.0
main