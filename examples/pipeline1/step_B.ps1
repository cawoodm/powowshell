[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,$PipelineParams=@{})
$params = @{
	Delimiter = "|"
	Header = "name", "age", "email", "source"
};
Write-Verbose "STEP B: PipelineGlobals=$($PipelineGlobals.foo)"
$input | ../components/CSV2JSON.ps1 @params
