[CmdletBinding(SupportsShouldProcess)]
param($Filter="*")
function main() {
    $StartPath = (Get-Location).Path
    Push-Location $PSScriptRoot
    try {
        $tests = 0; $success = 0
        if ("string" -like $Filter) {$success += CheckAdaptorString; $tests++}
        if ("int" -like $Filter) {$success += CheckAdaptorInt; $tests++}
        if ("datetime" -like $Filter) {$success += CheckAdaptorDateTime; $tests++}
        if ("object" -like $Filter) {$success += CheckAdaptorObject; $tests++}
        if ($success -eq $tests) {Write-Host "SUCCESS: Adaptors passed all $tests tests" -ForegroundColor Green} else {$Host.UI.WriteErrorLine("FAIL: Adaptors passed $success of $tests - $($tests-$success) failed")}
    } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
     throw $_
    } finally {
        Set-Location $StartPath
    }
}
function CheckAdaptorString {
    $tests = 0; $success = 0
    $success += CheckAdaptorOut "string" $null '{"value":null}'; $tests++
    $success += CheckAdaptorOut "string" "foo" '{"value":"foo"}'; $tests++
    $success += CheckAdaptorOut "int" "foo","bar" '["foo","bar"]' -param; $tests++
    $success += CheckAdaptorIn "string" "foo" '{"value":"foo"}'; $tests++
    if ($success -eq $tests) {Write-Verbose "`tSUCCESS: String Adaptor passed all tests";return 1} else {$Host.UI.WriteErrorLine("`tFAIL: String Adaptor - $success of $tests passed!"); return 0}
}
function CheckAdaptorInt {
    $tests = 0; $success = 0
    $success += CheckAdaptorOut "int" $null '{"value":null}'; $tests++
    $success += CheckAdaptorOut "int" 42 '{"value":42}'; $tests++
    $success += CheckAdaptorOut "int" 42,24 '{"value":42}', '{"value":24}'; $tests++
    $success += CheckAdaptorOut "int" 42,24 '[42,24]' -param; $tests++
    $success += CheckAdaptorIn "int" 42 '{"value":42}'; $tests++
    if ($success -eq $tests) {Write-Verbose "`tSUCCESS: Integer Adaptor passed all tests";return 1} else {$Host.UI.WriteErrorLine("`tFAIL: Integer Adaptor - $success of $tests passed!"); return 0}
}
function CheckAdaptorDateTime {
    $tests = 0;$success = 0
    $success += CheckAdaptorOut "datetime" (Get-Date "2000-01-01 00:00:00") '{"Date":"2000-01-01T00:00:00.0000000"}'; $tests++
    $success += CheckAdaptorIn "datetime" (Get-Date "2000-01-01 00:00:00") '{"Date":"2000-01-01T00:00:00.0000000"}'; $tests++
    if ($success -eq $tests) {Write-Verbose "`tSUCCESS: DateTime Adaptor passed all tests";return 1} else {$Host.UI.WriteErrorLine("`tFAIL: DateTime Adaptor - $success of $tests passed!"); return 0}
}
function CheckAdaptorObject {
    
    $tests = 0; $success = 0

    # Empty Array
    $aa=@()
    $success += CheckAdaptorOut "object" $aa "[]"; $tests++
    
    # Simple Object
    $a = [PSCustomObject]@{foo="bar";age=20}
    $success += CheckAdaptorOut "object" $a '{"foo":"bar","age":20}'; $tests++
    
    # Array with single item
    $aa+=$a;
    $success += CheckAdaptorOut "object" $aa '{"foo":"bar","age":20}'; $tests++

    # Array with 2 items
    $aa+=$a;
    $success += CheckAdaptorOut "object" $aa '{"foo":"bar","age":20}','{"foo":"bar","age":20}'; $tests++

    # Array with 2 items as a parameter
    $success += CheckAdaptorOut "object" $aa '[{"foo":"bar","age":20},{"foo":"bar","age":20}]' -param; $tests++

    if ($success -eq $tests) {Write-Verbose "`tSUCCESS: Object Adaptor passed all tests"; return 1} else {$Host.UI.WriteErrorLine("`tFAIL: Object Adaptor - $success of $tests passed!"); return 0}
}
function CheckAdaptorIn($type, $should, $str) {
    try {
        $t = $str | & "..\core\adaptors\$type.in.ps1"
        if ($null -eq (Compare-Object $t $should)) {Write-Verbose "`t`tSUCCESS: IN: $str";return 1} else {Write-Warning "`t`tFAIL: IN: $t should be $should"; return 0} 
    } catch {
        throw "Error in adaptor $type.in.ps1: $_"
    }
}
function CheckAdaptorOut($type, $o, $should, [switch]$param) {
    try {
        if ($param) {
            $t = & "..\core\adaptors\$type.out.ps1" $o
        } else {
            $t = $o | & "..\core\adaptors\$type.out.ps1"
        }
        if ($null -eq (Compare-Object $t $should)) {Write-Verbose "`t`tSUCCESS: OUT: $should";return 1} else {Write-Warning "`t`tFAIL: OUT: $t should be $should"; return 0} 
    } catch {
        throw "Error in adaptor $type.out.ps1: $_"
    }
}

$ErrorActionPreference = "Stop"
main
#$DebugPreference = $DebugPreference_