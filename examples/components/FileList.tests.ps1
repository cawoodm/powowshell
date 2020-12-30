[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

if ((& $Me -Path "C:\Windows").length -gt 0) {Write-Host "SUCCESS: FileList: Basic list works!" -ForegroundColor Green} else {Write-Host "FAIL: FileList: Basic list failed" -ForegroundColor Red}