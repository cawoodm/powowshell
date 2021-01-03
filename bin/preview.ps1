<#
 .Synopsis
 Preview a step

 .Description
 Runs a step with inputs and returns the result

 .Parameter Reference
 The path to the component or cmdlet name

 .Parameter Parameters
 Optional, a hashmap of the parameters to pass to the step (splatting)

 .Parameter InputObject
 Optional, the object to be piped to the component

 .Example
 pow preview ./examples/components/DateAdder.ps1 7
 Should return the date a week from now

 .Example
 pow preview ./examples/components/DateAdder.ps1 @{Days=7}
 Should return the date a week from now

 .Example
 pow preview ./examples/components/DateAdder.ps1 "@{Days=7}"
 Should return the date a week from now

 .Outputs
 text

#>
[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param(
  [Parameter(Mandatory)][String]$Pipeline,
  [Parameter(Mandatory)][String]$Reference,
  $Parameters,
  $InputObject
)

function main() {

  # Save path we are started from
  $StartPath = (Get-Location).Path
  Write-Verbose "PREVIEW: Pipeline=$Pipeline, Path=$Reference"

  try {
    Write-Verbose "JSON: $Parameters"
    if ($Parameters -is [hashtable]) {
      $ParamHash = $Parameters
      $Parameters = "@ParamHash"
    } elseif ($Parameters -like "{*") {
      # Decode JSON and convert JSON Object to HashTable for Splatting
      $Parameters = ConvertFrom-Json $Parameters
      $ParamHash = @{}
      $Parameters.psobject.properties | Where-Object Value -ne $null | ForEach-Object { $ParamHash[$_.Name] = $_.Value }
      $Parameters = "@ParamHash"
    } elseif ($Parameters -like "@*") {
      # Unsplat parameters if they are a '@{}' string
      $ParamHash = Invoke-Expression $Parameters
      $Parameters = "@ParamHash"
    }
    
    # Verify pipeline exists and is built
    $PipelinePath = $Pipeline
    $PipelineRunPath = Join-Path $PipelinePath "build"
    if (-not (Test-Path $PipelineRunPath)) {throw "Pipeline is not built!"}
    
    # Change to pipeline's build directory so that relative paths work
    Push-Location $PipelineRunPath

    # Read component/cmdlet definition
    $component = & pow "inspect" $Reference

    Write-Verbose "PREVIEWING $($component.reference) ..."
    Write-Verbose ((([pscustomobject]$ParamHash) | convertto-json) -replace "[\r?\n]", "")
        
    # Build executable
    $exec = "& "
    if ($component.type -eq "component") {
      $exec += "`"$Reference`""
    } else {
      # CmdLet
      $exec += $component.reference
    }
    $exec += " " + $Parameters

    # Run executable
    Write-Verbose "PREVIEW EXEC: $exec"
    Invoke-Expression $exec

  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  } finally {
    Set-Location $StartPath
  }

}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main