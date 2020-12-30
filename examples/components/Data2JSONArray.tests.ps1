[CmdletBinding()]param()

$Me = "$PSScriptRoot\" + $PSCmdlet.MyInvocation.MyCommand.Name.Replace(".tests", "")

$obj = [PSCustomObject]@{foo = "bar"; age=1}
$json = '[{"foo":"bar","age":1}]';
#($obj | & $Me -Compress)
if (($obj | & $Me -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSONArray: Basic object test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSONArray: Basic object test failed" -ForegroundColor Red}

$arr = @(); $arr+=$obj; $arr+=$obj;
$json = '[{"foo":"bar","age":1},{"foo":"bar","age":1}]';
#($arr | & $Me -Compress)
if (($arr | & $Me -Compress) -eq $json) {Write-Host "SUCCESS: Data2JSONArray: Basic array test passed" -ForegroundColor Green} else {Write-Host "FAIL: Data2JSONArray: Basic array test failed" -ForegroundColor Red}