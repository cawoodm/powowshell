. .\globals.ps1
$params = @{
	Delimiter = "|"
	Header = "name", "age", "email", "source"

}
$input | ../components/CSV2JSON.ps1 @params
