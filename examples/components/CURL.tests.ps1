[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

if ((& $Me -Url "https://postman-echo.com/get?foo1=bar1&foo2=bar2" | ConvertFrom-Json).args.foo1 -eq "bar1") {Write-Host "SUCCESS: CURL: Basic GET works!" -ForegroundColor Green} else {Write-Host "FAIL: CURL: Basic GET test failed" -ForegroundColor Red}