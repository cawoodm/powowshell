[CmdletBinding(SupportsShouldProcess)]
param($PipelineParams=@{})
function main() {
$params = @{
	Path = $PipelineParams.DataSource
};
& ../components/ReadFile.ps1 @params
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main
