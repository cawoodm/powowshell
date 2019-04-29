[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param()
function main() {
    $info = Invoke-Expression (get-content "$PSScriptRoot\powowshell.psd1" -raw)
    "PowowShell v$($info.ModuleVersion)"
    "PowerShell v" + $PSVersionTable.PSVersion.toString()
}

main