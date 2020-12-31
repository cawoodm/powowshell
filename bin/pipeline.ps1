<#
  .Synopsis
  Return a pipeline definition

  .Description
  Simply loads pipeline.json from the specified path

  .Parameter Path
  The path to the pipeline.json definition

#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Path
)
function main() {

  try {
    $Path = (Resolve-Path -Path $Path).Path
    Write-Verbose "Loading Pipeline from $Path\pipeline.json ..."
    $json = Get-Content "$Path\pipeline.json" -Raw
    #if ($_POW.RUNTIME -notlike $definition.runtime) {throw "INCOMPATIBLE: This pipeline only works in the $($definition.runtime) runtime!"}
    $definition = $json | ConvertFrom-Json
    return $definition
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main