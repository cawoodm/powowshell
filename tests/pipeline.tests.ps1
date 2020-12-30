[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$filter = "csv*"
)
function main() {
  $StartPath = (Get-Location).Path
  Push-Location $PSScriptRoot
  try {
    Get-ChildItem -Directory -Path ..\examples\ | 
      Where-Object {$_.Name -notlike 'components'} |
      ForEach-Object {
      $Pipeline = $_.Name
      try {
        Invoke-PowowShell build $_.FullName
        $result = Invoke-PowowShell verify $_.FullName
        #$result = Invoke-PowowShell verify $_.FullName
        #if (($PipelineExec)[1].age -eq "100") { "Pipeline: OK" } else { ErrMsg "Pipeline: FAIL" }
        #else {Write-Warning "Not testing missing pipeline build: $PipelineExec"}
      } catch {
        Write-Warning "ERROR: Pipeline '$Pipeline': " + $_.Exception.Message
      }
    }
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  } finally {
    Set-Location $StartPath
  }
}
$ErrorActionPreference = "Stop"
main
