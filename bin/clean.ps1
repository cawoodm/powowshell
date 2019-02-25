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
function main() {
  $Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	DEL step_*.ps1
	DEL run_*.ps1
	DEL *.log
	DEL .\trace\*.txt
	Pop-Location
}
Main