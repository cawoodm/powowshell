. .\globals.ps1
$params = @{
	Fields = "name", "age", "email"

}
$input | ../components/SelectFields.ps1 @params
