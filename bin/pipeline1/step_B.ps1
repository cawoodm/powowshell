. .\globals.ps1
$params = @{
	Delimiter = "|"
	Header = "name", "age", "email"

}
$input | ../components/CSV2JSON.ps1 @params
