param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,$PipelineParams=@{})
$params = @{
	Delimiter = "|"
	Header = "name", "age", "email", "source"
};
$globals = @{
	foo = "bar"
};

$input | ../components/CSV2JSON.ps1 @params
