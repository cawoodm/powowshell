<#
 .Synopsis
 Verify a pipeline can run (by running it)

 .Description
 Dry run a pipeline, suppressing real output to check for errors
 Run with -Verbose to see detailed steps
 INPUT:
  - A path to a valid, built pipeline
 PROCESS:
  - Runs the pipeline with -WhatIf enabled
 OUTPUT:
  - Messages in color on the terminal about success/fail (BOO)

 .Parameter Path
 The path to the pipeline folder

 .Parameter Parameters
 An optional hashmap of parameters to pass
 Can also be a string in the form "param1=x;param2=y"

 .Example
 pow verify ./pipeline1
 Verify a pipeline runs

 .Example
 pow verify ./pipeline1 "Param1=foo"
 Verify a pipeline runs with parameter -Param1 foo

 .Example
 pow verify ./pipeline1 "@{Param1=foo}"
 Verify a pipeline runs with parameter -Param1 foo

 .Example
 pow verify ./pipeline1 -Verbose
 Show detailed (verbose) information

#>
[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param(
  [Parameter(Mandatory)][String]$Path,
  $Parameters = @{}
)
function main() {

  # Save path we are started from
  $StartPath = (Get-Location).Path

  if ($Parameters -is [string]) {
    if ($Parameters -like '@*') {
      $Parameters = Invoke-Expression $Parameters
    } else {
      # Parameters in the form of "p1=x"
      Write-Verbose $Parameters
      $Parameters = ($Parameters -replace ";", "`n") # Newlines separate parameters
      # If the user doesn't escape backspaces
      if ($Parameters -notlike "*\\*") {
        # Escape them
        $Parameters = $Parameters.replace("\", "\\")
      }
      $Parameters = ConvertFrom-StringData $Parameters
    }
    #$p = $ExecutionContext.InvokeCommand.ExpandString($Parameters)
  }
  Write-Verbose $Parameters
  $Path = (Resolve-Path -Path $Path).Path
  Write-Verbose $Path
  Push-Location $Path
  try {
    if (-not (Test-Path ./build/run_prod.ps1)) { throw "Pipeline is not built!" }
    if (Test-Path .\errors.log) { Remove-Item .\errors.log }
    if (Test-Path .\warnings.log) { Remove-Item .\warnings.log }
    & ./build/run_prod.ps1 @Parameters -WhatIf 2> .\errors.log 3> .\warnings.log
    return
    $null = & ./build/run_prod.ps1 @Parameters -WhatIf 2> .\errors.log 3> .\warnings.log
    $outputErr = Get-Content .\errors.log -Raw
    $outputWar = Get-Content .\warnings.log -Raw
    if ($outputErr) {
      Show-Message "VERIFICATION ERRORS" Red
      Show-Message "Your pipeline was verified but generated error output:"
      Show-Message $outputErr Red
      if ($outputWar) { Show-Message $outputWar Yellow }
    } elseif ($outputWar) {
      Show-Message "VERIFICATION ERRORS" Yellow
      Show-Message "Your pipeline was verified but generated warning output:"
      Show-Message $outputWar Yellow
    } else {
      Show-Message "VERIFICATION OK" Green
      Show-Message "Your pipeline was verified with no errors"
    }
    # Show params
    #$cmd = Get-Command ./build/run_prod.ps1
    #"`nParameters:"
    #$cmd.Parameters.Keys | Where-Object {$_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters} | Where-Object {
    #    #if ($cmd.Parameters[$_].Attributes[0].Mandatory) {"$_ (mandatory)"} else {$_}
    #}
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  } finally {
    Remove-Item .\errors.log -ErrorAction SilentlyContinue
    Remove-Item .\warnings.log -ErrorAction SilentlyContinue
    Set-Location $StartPath
  }
}
function  Show-Message($msg, $Color = "White") { Write-Host $Msg -ForegroundColor $Color }

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
#$ErrorActionPreference = "Stop"
main