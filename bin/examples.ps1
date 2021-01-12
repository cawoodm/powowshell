<#
  .Synopsis
  Inspect a component and return examples of usage

  .Description
  Equivalent to PowerShell's 'Get-Help -Examples' command

  .Parameter Path
  The path to the .ps1 script or name of the CmdLet

  .Example
  pow examples !JSONMapping
  Show examples of how to use the JSONMapping component

#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Path
)
function main() {

  try {
    $RealPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    if ($RealPath) {
      $RealPath = $RealPath.Path
      Write-Verbose "Inspecting custom POW Component from $RealPath ..."
      $Name = (Split-Path -Path $RealPath -Leaf)
      $cmd = Get-Help -Examples -Name $RealPath -ErrorAction SilentlyContinue
      if ($null -eq $cmd) { throw "Invalid POW Component '$RealPath'!" }
    } else {
      $RealPath = $Path
      Write-Verbose "Inspecting installed CmdLet $Path ..."
      $Name = $Path
      $cmd = Get-Help -Examples -Name $Name -ErrorAction SilentlyContinue
      if ($null -eq $cmd) { throw "Invalid CmdLet '$RealPath'!" }
    }
    $result = @()
    if ($cmd.PSObject.Properties["examples"] -and $cmd.examples) {
      foreach ($example in $cmd.examples.example) {
        $res = [PSCustomObject]@{
          title       = ($example.title -replace '-', '').Trim();
          code        = $example.code;
          description = "";
        }
        foreach ($line in $example.remarks) {
          $sep = ""; if ($res.description) { $sep = "`n" }
          if ($line.Text) { $res.description += $line.Text + $sep; }
        }
        $result += $res
      }
    }
    return $result
  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main