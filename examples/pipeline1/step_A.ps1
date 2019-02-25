param($PipelineParams=@{})
$params = @{
	Path = $PipelineParams.DataSource
};
$globals = @{
	foo = "bar"
};

../components/ReadFile.ps1 @params
