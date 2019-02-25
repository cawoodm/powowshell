param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,$PipelineParams=@{})
$params = @{
	Fields = "name", "age", "email"
};
$globals = @{
	foo = "bar"
};

$input | ../components/SelectFields.ps1 @params
