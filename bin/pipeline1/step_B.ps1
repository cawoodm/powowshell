. .\globals.ps1

$params = @{
    Delimiter = "|"
    Header = "name", "age", "gender"
}
$input | ..\components\CSV2JSON.ps1 @params
