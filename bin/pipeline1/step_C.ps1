. .\globals.ps1
$params = @{
	Fields = "name", "email"

}
$input | ../components/SelectFields.ps1 @params
