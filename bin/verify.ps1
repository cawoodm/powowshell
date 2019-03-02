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
        if (-not (Test-Path .\run_prod.ps1)) {throw "Pipeline is not built!"}
        if (Test-Path .\errors.log) {DEL .\errors.log}
        if (Test-Path .\warnings.log) {DEL .\warnings.log}
        $output = & .\run_prod.ps1 -WhatIf 2> .\errors.log 3> .\warnings.log
        $outputErr = Get-Content .\errors.log -Raw
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
        # Show params
        $cmd = Get-Command .\run_prod.ps1
        "`nParameters:"
        $cmd.Parameters.Keys | Where {$_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters} | % {
            $cmd.Parameters[$_].Attributes[0].Mandatory
        }
    } catch {
        Write-Host "!!! VERIFICATION FAILED !!!" -ForegroundColor Red
        throw $_
    } finally {
        DEL .\errors.log -ErrorAction SilentlyContinue
        DEL .\warnings.log -ErrorAction SilentlyContinue
        Pop-Location
    }
}
Set-StrictMode -Version Latest
main