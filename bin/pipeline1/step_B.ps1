. .\globals.ps1

$params = @{
    Delimiter = "|"
    Header = "name", "age", "gender"
}

$input | ..\components\CSV2JSON.ps1 @params >.\trace\tmp_B_output.txt 2>.\trace\tmp_B_errors.txt 5>>.\trace\tmp_debug.txt