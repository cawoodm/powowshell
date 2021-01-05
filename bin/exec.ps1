<#
 .Synopsis
 Execute any PowerShell Code

 .Description
 Runs the PowerShell Code or Command

 .Parameter Command
 The PowerShell Command/Script to Run (string)

 .Example
 pow exec "Get-Date"

#>
[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param(
    [Parameter(Mandatory)][String]$Command
)
function main() {
  . "$PSScriptRoot/common.ps1"
  Invoke-Expression -Command $Command
}

$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
main