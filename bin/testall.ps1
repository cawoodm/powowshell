<#
 .Synopsis
 Basic tests of all commands
#>
[CmdletBinding()]
param()
function main() {
    $ErrorActionPreference = "Stop"
    try {
        Push-Location $PSScriptRoot

        Write-Host "------------------------CLEAN-----------------------------------------------------"
        & .\clean.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------BUILD-----------------------------------------------------"
        & .\build.ps1 ../examples/pipeline1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------VERIFY----------------------------------------------------"
        & .\verify.ps1 ../examples/pipeline1 "@{DataSource='.\data\names.txt'}" | Out-Null
        Write-Host "OK" -ForegroundColor Green
        & .\verify.ps1 ../examples/pipeline1 "DataSource=.\data\names.txt" | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------RUN-------------------------------------------------------"
        & .\run.ps1 ../examples/pipeline1 -WhatIf @{DataSource='.\data\names.txt'} | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------HELP------------------------------------------------------"
        & .\help.ps1 verify | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "------------------------INSPECT---------------------------------------------------"
        & .\inspect.ps1 ../examples/components/CSV2JSON.ps1 | Out-Null
        Write-Host "OK" -ForegroundColor Green

        Write-Host "----------------------------------------------------------------------------------"
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)")
        #throw $_
    } finally {
        Pop-Location
    }
}
Set-StrictMode -Version Latest
main