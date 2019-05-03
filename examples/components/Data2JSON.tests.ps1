[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

$obj = [PSCustomObject]@{foo = "bar"; age=1}
$json = '{"foo":"bar","age":1}';
if (($obj | & $Me -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSON: Basic object test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Basic object test failed" -ForegroundColor Red}

$json = '{"foo":"bar","age":1}';
if (($obj | & $Me -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSON: Forced array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Forced array test failed" -ForegroundColor Red}

$arr = @(); $arr+=$obj; $arr+=$obj;
$json = '{"foo":"bar","age":1}', '{"foo":"bar","age":1}';
if ($null -eq (Compare-Object ($arr | & $Me -Compress) $json)) {Write-Host "SUCCESS: Data2JSON: Piped array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Normal array test failed" -ForegroundColor Red}

$json = '[{"foo":"bar","age":1},{"foo":"bar","age":1}]';
if ((& $Me $arr -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSON: Passed array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Passed array test failed" -ForegroundColor Red}