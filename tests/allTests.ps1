<#
 .Synopsis
 Tests of all functions

 .Parameter Filter
 A wildcard match for test files

 .Example
 .\allTests.ps1 "*.js"
 Test all JavaScript Files

#>
[CmdletBinding()]
param(
    [string]$Filter="*"
)
function main() {
    # Save path we are started from
    $StartPath = (Get-Location).Path
    Push-Location $PSScriptRoot
    try {
        
        $verbose = if ($VerbosePreference -eq "Continue") {"verbose"} else {""}

        $scripts = DIR | Where name -like $Filter
        foreach($script in $scripts) {
            $script = $script.Name
            if ("functions.js", "allTests.ps1", "workspace.txt" -contains $script) {continue}
            if ($script -notlike "*.ps1" -and $script -notlike "*.js") {continue}
            Write-Host "Testing $script :"
            #$script = $script.replace(".", "Tests.")
            if ($script -like "*.js") {
                & node "$script" $verbose
                if ($LASTEXITCODE) {throw "FAIL: $script"}
            } else {
                & "./$script" | Out-Null
            }
        }
        
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)")
    } finally {
        Set-Location $StartPath
    }
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main