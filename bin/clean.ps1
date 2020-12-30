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

  # Include common settings/functions
  . "$PSScriptRoot/common.ps1"

  $Path = (Resolve-Path -Path $Path).Path
  Push-Location $Path
  Remove-Item -Force ./build/ -Recurse
  Show-Message "SUCCESS: CLEAN completed" Green
  Pop-Location
}
function Show-Message($msg, $Color) {Write-Host $Msg -ForegroundColor $Color}
$ErrorActionPreference = "Stop"
main