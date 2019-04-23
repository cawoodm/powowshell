<#
 .Synopsis
 Tests of all functionality via *.tests.* files

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
        
        $verbose = if ($VerbosePreference -like "Continue") {"verbose"} else {""}

        $scripts = Get-ChildItem |
         Where-Object name -like $Filter |
         Where-Object name -like "*.tests.*"
         foreach($script in $scripts) {
            $script = $script.Name
            if ($script -notlike "*.ps1" -and $script -notlike "*.js") {continue}
            $script1 = $script.replace(".tests.", ".")
            Write-Host "Testing $script :"
            if ($script -like "*.js") {
                & node "$script" $verbose
                if ($LASTEXITCODE) {throw "FAIL: $script"}
            } else {
                if ($verbose) {
                    & "./$script"
                } else {
                    & "./$script" | Out-Null
                }
            }
            [Console]::ResetColor()
        }
        
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    } finally {
        Set-Location $StartPath
    }
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main