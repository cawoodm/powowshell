<#
 .Synopsis
 Delete built pipeline

 .Description
 Delete all built elements of a pipeline folder (including logs and traces)
   
 .Parameter Path
 The path to the pipeline folder
		
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Path
)
function main() {
  $Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	Remove-Item -Force step_*.ps1
	Remove-Item -Force run_*.ps1
	Remove-Item -Force *.log
	Remove-Item -Force .\trace\*.txt
	Write-Host "SUCCESS: CLEAN completed" -ForegroundColor Green
	Pop-Location
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main