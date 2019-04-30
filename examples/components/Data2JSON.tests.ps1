[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

$obj = [PSCustomObject]@{foo = "bar"; age=1}
$json = '{"foo":"bar","age":1}';
if (($obj | & $Me -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSON: Basic object test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Basic object test failed" -ForegroundColor Red}

$json = '[{"foo":"bar","age":1}]';
if (($obj | & $Me -Compress -AsArray) -eq $json) {Write-Host "SUCCESS: Data2JSON: Forced array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Forced array test failed" -ForegroundColor Red}

$arr = @(); $arr+=$obj; $arr+=$obj;
$arr
$json = '[{"foo":"bar","age":1},{"foo":"bar","age":1}]';
$json;
($arr | & $Me -Compress -AsArray)
if (($arr | & $Me -Compress -AsArray) -eq $json) {Write-Host "SUCCESS: Data2JSON: Basic array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSON: Basic array test failed" -ForegroundColor Red}