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
 
 .Example
 .\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\temp" -p1 "*.txt"

 .Outputs
 json[]

#>
[CmdletBinding(DefaultParametersetName="PWTest")] 
[OutputType([String])]
param(

	[Parameter(ParameterSetName="PWTest",Position=0)]
		[Switch]$PWTest,

	[Parameter(ParameterSetName="PWOutput",Position=0)]
		[Switch]$PWOutput,
	
	[Parameter(ParameterSetName="Standard")]
		[Parameter(ValueFromPipeline=$true)]$InputObject,
	[Parameter(ParameterSetName="Standard",Mandatory=$true)]
		[String]$ExecuteTemplate,
	[Parameter(ParameterSetName="Standard")]
		[Int32]$Depth=2,
	[Parameter(ParameterSetName="Standard")]
		[String]$p0,
	[Parameter(ParameterSetName="Standard")]
		[String]$p1,
	[Parameter(ParameterSetName="Standard")]
		[String]$p2
	
)
Set-StrictMode -Version 3.0
If ($PsCmdlet.ParameterSetName -eq "PWTest") {
	# Test Case
	Push-Location $PSScriptRoot
	If ((.\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\" | ConvertFrom-Json).length -gt 0) {"ExecuteCmdlet: OK"} Else {Write-Error "ExecuteCmdlet: FAIL"}
	Pop-Location
	return
}
If ($PsCmdlet.ParameterSetName -eq "PWOutput") {
	# Test Case
	Push-Location $PSScriptRoot
	If ((.\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\" | ConvertFrom-Json).length -gt 0) {"ExecuteCmdlet: OK"} Else {Write-Error "ExecuteCmdlet: FAIL"}
	Pop-Location
	return
}
"ExecuteTemplate=" + $ExecuteTemplate
$command = $ExecuteTemplate -f $p0, $p1, $p2
Invoke-Expression -Command $command | ConvertTo-Json -Depth $Depth