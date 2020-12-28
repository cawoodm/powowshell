[CmdletBinding()]param()
function main() {
    $Me = "$PSScriptRoot\CSV2JSON.ps1"

    if (("a;1`nb;2" | & $Me -Delimiter ";" -Header "name","age" | ConvertFrom-Json)[1].age -eq 2) {Write-Host "SUCCESS: CSV2JSON self-test successful" -ForegroundColor Green} else {Write-Host "FAIL: CSV2JSON self-test failed!" -ForegroundColor Red}
}
$ErrorActionPreference = "Stop"
main