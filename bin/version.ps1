function main() {
    $info = invoke-expression (get-content "$PSScriptRoot\powowshell.psd1" -raw)
    "PowowShell v$($info.ModuleVersion)"
    "PowerShell v" + $PSVersionTable.PSVersion.toString()
}
main