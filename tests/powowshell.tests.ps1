<#
 .Synopsis
 Basic tests of all commands
#>
[CmdletBinding()]
param()
function main() {
    try {
        Push-Location $PSScriptRoot

        & ..\bin\workspace.ps1 ../examples | Out-Null
        Write-Host "OK: pow workspace" -ForegroundColor Green

        & ..\bin\clean.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK: pow clean" -ForegroundColor Green

        & ..\bin\build.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK: pow build" -ForegroundColor Green

        & ..\bin\verify.ps1 ../examples/pipeline1 "@{DataSource='.\data\names.txt'}" | Out-Null
        & ..\bin\verify.ps1 ../examples/pipeline1 "DataSource=.\data\names.txt" | Out-Null
        Write-Host "OK: pow verify" -ForegroundColor Green

        & ..\bin\run.ps1 ../examples/pipeline1 -WhatIf @{DataSource='.\data\names.txt'} | Out-Null
        Write-Host "OK: pow run" -ForegroundColor Green

        & ..\bin\help.ps1 verify | Out-Null
        Write-Host "OK: pow help" -ForegroundColor Green

        & ..\bin\inspect.ps1 ..\examples\components\CSV2JSON.ps1 | Out-Null
        Write-Host "OK: pow inspect" -ForegroundColor Green

    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Pop-Location
    }
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main