. .\globals.ps1
$params = @{
	Fields = "name,email"

}
../components/SelectFields.ps1 @params >.\trace\tmp_C_output.txt 2>.\trace\tmp_C_errors.txt 5>>.\trace\tmp_debug.txt
