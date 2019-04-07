<#
 .Synopsis
 Basic tests of all commands
#>
[CmdletBinding()]
param()
function main() {
    try {
        Push-Location $PSScriptRoot

        & pow version | Out-Null
        Write-Host "OK: pow is installed" -ForegroundColor Green

        & ..\bin\help.ps1 verify | Out-Null
        Write-Host "OK: pow help" -ForegroundColor Green

        & pow workspace ../examples | Out-Null
        Write-Host "OK: pow workspace" -ForegroundColor Green

        & pow clean !pipeline1 | Out-Null
        Write-Host "OK: pow clean" -ForegroundColor Green

        & pow build !pipeline1 | Out-Null
        Write-Host "OK: pow build" -ForegroundColor Green

        & pow verify ../examples/pipeline1 "@{DataSource='.\data\names.txt'}" | Out-Null
        & pow verify !pipeline1 "DataSource=.\data\names.txt" | Out-Null
        Write-Host "OK: pow verify" -ForegroundColor Green

        & pow run !pipeline1 -WhatIf @{DataSource='.\data\names.txt'} | Out-Null
        Write-Host "OK: pow run" -ForegroundColor Green

        & pow components ! export | Out-Null
        Write-Host "OK: pow components" -ForegroundColor Green

        & pow preview !DateAdder 2 | Out-Null
        Write-Host "OK: pow preview" -ForegroundColor Green

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