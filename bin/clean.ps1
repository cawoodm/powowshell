<#
 .Synopsis
 Delete compiled pipeline

 .Description
 Delete all compiled elements of a pipeline folder
   
 .Parameter Path
 The path to the pipeline folder
		
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][String]$Path
)
function Main() {
  $Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	DEL step_*.ps1
	DEL run_*.ps1
	DEL .\trace\*.txt
	Pop-Location
}
Main