try {
    Import-Module -Global .\bin\powowshell.psm1 -Force
    Write-Host "'pow' CmdLet installed!" -ForegroundColor Green
    "Type 'pow help' for a list of commands"
} catch {
    throw $_
}