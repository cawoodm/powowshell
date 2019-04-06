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
	[Parameter(ParameterSetName="Std",Mandatory,HelpMessage="The path to the files",Position=0)]
		[string]$Path,
		[string]$Filter,
		[switch]$Recurse,

	[Parameter(ParameterSetName="POW")][string]$POWAction
)
Set-StrictMode -Version 3.0
function main() {
	if ($POWAction -like "test") {
		Push-Location $PSScriptRoot
		if ((.\FileList.ps1 -Path "C:\Windows" | ConvertFrom-Json).length -gt 0) {"OK: FileList self-test successful"} else {$Host.UI.WriteErrorLine("FAIL: FileList self-test failed!")}
		Pop-Location
    	return
	}
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
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
main