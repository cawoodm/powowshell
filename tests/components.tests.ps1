[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$filter="*"
)
function main() {
    $StartPath = (Get-Location).Path
    Push-Location $PSScriptRoot
    try {
        # 1. Inspect and test each powershell component
        $i=0
        $components = ..\bin\components.ps1 ..\examples\components
        foreach($component in $components) {
            if ($component.reference -notlike $filter) {continue}
            $i++
            try{$component.reference+=""}catch{$Host.UI.WriteErrorLine("ERROR: $i. Something about $component is not right")}
            $reference = $component.reference
            Write-Verbose "Component $reference"
            $component.POWMessages | ForEach-Object {
                $msg = $_
                if ($msg.type -eq "WARNING") {Write-Warning $msg.message}
                elseif ($msg.type -eq "ERROR") {$Host.UI.WriteErrorLine($msg.message)}
                else {Write-Host $msg.message -ForegroundColor Cyan}
            }
            $SelfTest = $component.path.replace(".ps1", ".tests.ps1");
            Write-Verbose "Self-test $SelfTest :"
            if (Test-Path $SelfTest) {
                # Self-testing
                Write-Verbose "Self-testing $SelfTest :"
                & $SelfTest
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