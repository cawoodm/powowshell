[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,$PipelineParams=@{})
$params = @{
	Fields = "name", "age", "email"
};
$input | ../components/SelectFields.ps1 @params
