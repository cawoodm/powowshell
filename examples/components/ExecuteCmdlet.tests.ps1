[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

if ((& $Me -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\").length -gt 0) {Write-Host "SUCCESS: ExecuteCmdlet: Basic DIR works!" -ForegroundColor Green} else {Write-Host "FAIL: ExecuteCmdlet: Basic DIR test failed" -ForegroundColor Red}