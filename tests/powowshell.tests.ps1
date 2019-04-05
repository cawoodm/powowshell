<#
 .Synopsis
 Basic tests of all commands
#>
[CmdletBinding()]
param()
function main() {
    try {
        Push-Location $PSScriptRoot

        Write-Host "------------------------CLEAN-----------------------------------------------------"
        & ..\bin\clean.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------BUILD-----------------------------------------------------"
        & ..\bin\build.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------VERIFY----------------------------------------------------"
        & ..\bin\verify.ps1 ../examples/pipeline1 "@{DataSource='.\data\names.txt'}" | Out-Null
        Write-Host "OK" -ForegroundColor Green
        & ..\bin\verify.ps1 ../examples/pipeline1 "DataSource=.\data\names.txt" | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------RUN-------------------------------------------------------"
        & ..\bin\run.ps1 ../examples/pipeline1 -WhatIf @{DataSource='.\data\names.txt'} | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------HELP------------------------------------------------------"
        & ..\bin\help.ps1 verify | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------INSPECT---------------------------------------------------"
        & ..\bin\inspect.ps1 ../examples/components/CSV2JSON.ps1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "----------------------------------------------------------------------------------"
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