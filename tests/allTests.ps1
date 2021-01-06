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
  [string]$Filter = "*",
  [switch]$DebugMode = $false
)
function main() {
  # Save path we are started from
  $StartPath = (Get-Location).Path
  Push-Location $PSScriptRoot
  try {
        
    $verbose = if ($VerbosePreference -like "Continue") { "verbose" } else { "" }
    $Debug = if ($DebugMode) { "debug" } else { "" }

    $tests = 0
    $success = 0
    $scripts = Get-ChildItem |
      Where-Object name -like $Filter |
      Where-Object name -like "*.tests.*"
    foreach ($script in $scripts) {
      $Global:LASTEXITCODE=0
      $script = $script.Name
      if ($script -notlike "*.ps1" -and $script -notlike "*.js") { continue }
      $tests++
      Write-Host "Testing $($script):"
      if ($script -like "*.js") {
        & node "$script" $verbose $Debug
        if ($LASTEXITCODE) {
          throw "FAIL: $script"
        }
      } else {
        if ($verbose) {
          & "./$script"
        } else {
          & "./$script" | Out-Null
        }
      }
      $success++
    }
    if ($success/$tests) {
      Write-Host "SUCCESS: All $success/$tests tests passed" -ForegroundColor Green
    } else {
      Write-Warning "Passed $success/$tests passed"
    }
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  } finally {
    [Console]::ResetColor() # Console]::ForegroundColor="White"
    Set-Location $StartPath
  }
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
# This causes pow verify to fail on errortest pipeline
#$ErrorActionPreference = "Stop"
main