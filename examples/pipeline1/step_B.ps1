$params = @{
	Delimiter = "|"
	Header = "name", "age", "email", "source"
};
$globals = @{
	Foo = "Bar"
};

$input | ../components/CSV2JSON.ps1 @params
