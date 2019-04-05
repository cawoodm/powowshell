[CmdletBinding(SupportsShouldProcess)]
param()
function main() {
    $StartPath = (Get-Location).Path
    Push-Location $PSScriptRoot
    try {
        # 1. Inspect and test each powershell component
        $i=0
        ..\bin\components.ps1 ..\examples\components | ForEach-Object {
            $i++
            $component = $_
            try{$component.reference}catch{Write-Error "ERROR: $i. Something about $component"}
            $reference = $component.reference
            $_.POWMessages | ForEach-Object {
                $msg = $_
                if ($msg.type -eq "WARNING") {Write-Warning $msg.message}
                elseif ($msg.type -eq "ERROR") {$Host.UI.WriteErrorLine($msg.message)}
                else {Write-Host $msg.message -ForegroundColor Cyan}
                if ($component.parameters | Where name -like "POWAction") {
                    # Self-testing
                    & "..\examples\components\$reference.ps1" -POWAction test
                }
            }
        }

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