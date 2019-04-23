[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$filter="csv*"
)
function main() {
    $StartPath = (Get-Location).Path
    Push-Location $PSScriptRoot
    try {
        
        # Test Pipeline1
        if ((..\examples\pipeline1\run_prod.ps1 | ConvertFrom-Json)[1].age -eq "100") {"Pipeline: OK"} else {Write-Error "Pipeline: FAIL"}

    } catch {
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
    } finally {
        Set-Location $StartPath
    }
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main
#$DebugPreference = $DebugPreference_