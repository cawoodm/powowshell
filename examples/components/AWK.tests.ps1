[CmdletBinding()]param()

$Me = "$PSScriptRoot\AWK.ps1"

if (("hello`nworld" | & $Me -process "/e/" ) -eq "hello") {Write-Host "SUCCESS: AWK: Basic hello test works!" -ForegroundColor Green} else {Write-Host "FAIL: AWK: Basic hello test failed" -ForegroundColor Red}