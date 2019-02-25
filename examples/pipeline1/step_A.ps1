[CmdletBinding(SupportsShouldProcess)]
param($PipelineParams=@{})
$params = @{
	Path = $PipelineParams.DataSource
};
Write-Verbose "STEP A: PipelineGlobals=$($PipelineGlobals.foo)"
$PipelineGlobals.foo="bar2"
../components/ReadFile.ps1 @params
