$params = @{
	Fields = "name", "age", "email"
};
$globals = @{
	Foo = "Bar"
};

$input | ../components/SelectFields.ps1 @params
