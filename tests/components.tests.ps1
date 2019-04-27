[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$filter="*"
)
$global:cmd=$null
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
            try{$component.reference+=""}catch{err "ERROR: $i. Something about $component is not right"}
            $reference = $component.reference
            Write-Verbose "Component $reference"
            $component.POWMessages | ForEach-Object {
                $msg = $_
                if ($msg.type -eq "WARNING") {Write-Warning $msg.message}
                elseif ($msg.type -eq "ERROR") {ErrMsg $msg.message}
                else {Write-Host $msg.message -ForegroundColor Cyan}
            }
            $SelfTest = $component.executable.replace(".ps1", ".tests.ps1");
            Write-Verbose "Self-test $SelfTest :"
            if (Test-Path $SelfTest) {
                # Self-testing
                Write-Verbose "Self-testing $SelfTest :"
                & $SelfTest
            }
        }

        # Detailed test of a component
        $tests=0; $success=0
        $global:cmd = ..\bin\inspect.ps1 ..\examples\components\CSV2JSON.ps1
        $success += Assert {$global:cmd.reference -eq "csv2json.ps1"} "Inspect component reference"; $tests++
        $success += Assert {$global:cmd.name -eq "CSV2JSON"} "Inspect component name"; $tests++
        $success += Assert {$global:cmd.type -eq "component"} "Inspect component type" $global:cmd.type; $tests++
        $success += Assert {$global:cmd.executable -like "*csv2json.ps1"} "Inspect component executable"; $tests++
        $success += Assert {$global:cmd.synopsis -like "*csv*"} "Inspect component synopsis"; $tests++
        $success += Assert {$global:cmd.description -like "*json*"} "Inspect component description"; $tests++
        $success += Assert {$global:cmd.input -eq "string"} "Inspect component input"; $tests++
        $success += Assert {$global:cmd.inputFormat -eq "text/csv"} "Inspect component input format"; $tests++
        $success += Assert {$global:cmd.output -eq "string"} "Inspect component output"; $tests++
        $success += Assert {$global:cmd.outputFormat -eq "text/json"} "Inspect component output format"; $tests++
        $success += Assert {$global:cmd.parameters.length -eq 3} "Inspect component parameters"; $tests++
        $success += Assert {$global:cmd.parameters[0].type -eq "string" -and $global:cmd.parameters[0].required -eq $true} "Inspect component parameter InputObject basics"; $tests++
        $success += Assert {$global:cmd.parameters[0].piped -eq $true -and $global:cmd.parameters[0].pipedMode -eq "value"} "Inspect component parameter InputObject piping"; $tests++
        $global:cmd = ..\bin\inspect.ps1 ..\examples\components\CURL.ps1
        $success += Assert {$global:cmd.parameters[1].values.length -gt 1} "Inspect CURL component parameter Method has values"; $tests++
        if ($success -eq $tests) {SuccessMsg "SUCCESS: Inspect CSV2JSON works"} else {ErrMsg "FAIL: Inspect failed $($tests-$success) of $tests tests!"}

        # Test Pipeline1
        if ((..\examples\pipeline1\run_prod.ps1 | ConvertFrom-Json)[1].age -eq "100") {"Pipeline: OK"} else {ErrMsg "Pipeline: FAIL"}

    } catch {
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
    } finally {
        Set-Location $StartPath
    }
}
function Assert($expr, $msg, $val) {
    try {
    if ($expr.Invoke() -eq $true) {
        Write-Verbose "OK: $msg"
        return 1
    } else {
        $Host.UI.WriteErrorLine("FAIL: $msg ($val)")
        return 0
    }
    } catch {
        if ($VerbosePreference -eq "Continue") {Write-Warning "ERROR in {$($expr.ToString())} : $($_.Exception.Message)"}
        $Host.UI.WriteErrorLine("FAIL: $msg ($val)")
    }
}
function ErrMsg($msg){$Host.UI.WriteErrorLine($msg)}
function SuccessMsg($msg){Write-Host $msg  -ForegroundColor Green}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main
#$DebugPreference = $DebugPreference_