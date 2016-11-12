. .\globals.ps1

$params = @{
    Path = ".\data\names.txt"
}

..\components\ReadFile.ps1 @params >.\trace\tmp_A_output.txt 2>.\trace\tmp_A_errors.txt 5>>.\trace\tmp_debug.txt