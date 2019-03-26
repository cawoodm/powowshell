<# 
 .Synopsis
  Returns a list of files.

 .Description
  Lists files with a specific filter (e.g. *.txt) or
  within a specified date range.

 .Parameter Path
  Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.).

 .Parameter Filter
  The wildcard for matching files (e.g. *.csv)
	
 .Parameter Recurse
  If $true, will search all sub-folders
	
 .Example
 .\FileList.ps1 -Path C:\windows -Filter *.exe
	
 .Inputs
 none
 
 .Outputs
 text/json[name,fullName,size(int)]

#>
[CmdletBinding(DefaultParameterSetName="Std")]
[OutputType([string])]
param(

	[Parameter(ParameterSetName="PWTest")]
		[Switch]$PWTest,

	[Parameter(ParameterSetName="PWOutput")]
		[Switch]$PWOutput,
		
	[Parameter(ParameterSetName="Std",Mandatory,HelpMessage="The path to the files",Position=0)]
		[string]$Path,
		[string]$Filter,
		[switch]$Recurse
		
)
Set-StrictMode -Version 3.0
function main() {
	$files = @()
	Get-ChildItem -Path $Path -File -Filter $Filter -Recurse:$Recurse|
	  ForEach-Object {
		$f = $null
		$len = 0
		if ($_.PSobject.Properties.Name -match "Length") {$len = $_.Length}
		$f = @{
			name=$_.Name
			fullName=$_.FullName
			size=$len
		}
		if ($f) {$files += New-Object -TypeName PSObject -Property $f}
	}
	$files | ConvertTo-Json
}
function PWTest() {
	Push-Location $PSScriptRoot
	if ((.\FileList.ps1 -Path "C:\Windows" | ConvertFrom-Json).length -gt 0) {"FileList: OK"} else {Write-Error "FileList: FAIL"}
	Pop-Location
}
function PWOutput() {
	'[{"name":"one.txt","fullName":"C:\\temp\\one.txt","size":1},{"name":"two.txt","fullName":"C:\\temp\\two.txt","size":2}]'
}
switch ($PsCmdlet.ParameterSetName) {
	PWTest {PWTest}
	PWOutput {PWOutput}
	default {main}
}
