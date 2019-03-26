<#
 .Synopsis
  Execute any PowerShell Cmdlet

 .Description
  Generic component which allows you to map up to 10 parameters to any cmdlet you like

 .Parameter ExecuteTemplate
  The command to be executed

 .Parameter Depth
  The depth of the JSON output to be returned
	
 .Parameter p0
 The first parameter passed in. Can be used in ExecuteTemplate as {0}
	
 .Parameter p1
 The second parameter passed in. Can be used in ExecuteTemplate as {1}
	
 .Inputs
 text

 .Outputs
 text/json
 
 .Example
 .\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\temp" -p1 "*.txt"

#>
[CmdletBinding(DefaultParameterSetName="Std")] 
[OutputType([String])]
param(

	[Parameter(ParameterSetName="Std",Mandatory)]
		[String]$ExecuteTemplate,
	[Parameter(ParameterSetName="Std")]
		[Int32]$Depth=2,
	[Parameter(ParameterSetName="Std")]
		[String]$p0,
	[Parameter(ParameterSetName="Std")]
		[String]$p1,
	[Parameter(ParameterSetName="Std")]
		[String]$p2,

	[Parameter(ParameterSetName="POW")]
		[string]$POWAction
	
)
Set-StrictMode -Version Latest
if ($POWAction -like "test") {
	# Test Case
	Push-Location $PSScriptRoot
	if ((.\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\" | ConvertFrom-Json).length -gt 0) {"ExecuteCmdlet: OK"} else {Write-Error "ExecuteCmdlet: FAIL"}
	Pop-Location
	return
}
Write-Verbose ("ExecuteTemplate=" + $ExecuteTemplate)
$command = $ExecuteTemplate -f $p0, $p1, $p2
Invoke-Expression -Command $command | ConvertTo-Json -Depth $Depth