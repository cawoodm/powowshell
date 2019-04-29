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
	Show-Message "SUCCESS: CLEAN completed" Green
	Pop-Location
}
function Show-Message($msg, $Color) {Write-Host $Msg -ForegroundColor $Color}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main