<#
 .Synopsis
 Verify a pipeline can run (by running it)

 .Description
 Run a pipeline, suppressing output to check for errors

 .Parameter Path
 The path to the pipeline folder

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)][String]$Path,
    $Parameters=@{},
	[switch]$Trace=$false
)
function main() {
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    $Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	try {
        if (Test-Path .\error.log) {DEL .\error.log}
        if (Test-Path .\warnings.log) {DEL .\warnings.log}
        $output = & .\run_prod.ps1 -WhatIf 2> .\error.log 3> .\warnings.log
        $outputErr = Get-Content .\error.log -Raw
        $outputWar = Get-Content .\warnings.log -Raw
        if ($outputErr) {
            Write-Host "VERIFICATION ERRORS" -ForegroundColor Red
            Write-Host "Your pipeline ran to completion but generated error output:"
            Write-Host  $outputErr -ForegroundColor Red
        } elseif ($outputWar) {
            Write-Host "VERIFICATION ERRORS" -ForegroundColor Yellow
            Write-Host "Your pipeline ran to completion but generated warning output:"
            Write-Host  $outputWar -ForegroundColor Yellow
        } else {
            Write-Host "VERIFICATION OK" -ForegroundColor Green
            Write-Host "Your pipeline ran to completion with no errors"
        }
    } catch {
        Write-Host "!!! VERIFICATION FAILED !!!" -Color Red
        throw $_
    } finally {
        Pop-Location
    }
}
Set-StrictMode -Version Latest
main