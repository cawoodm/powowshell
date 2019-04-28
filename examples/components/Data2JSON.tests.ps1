[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

if (("a|1|M`nb|2|F" | & $Me -Delimiter "|" | ConvertFrom-Json)[1].gender -eq "F") {Write-Host "SUCCESS: Data2JSON: Basic test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Basic test failed" -ForegroundColor Red}