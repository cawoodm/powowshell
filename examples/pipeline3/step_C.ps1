[CmdletBinding(SupportsShouldProcess)]
param([Parameter(ValueFromPipeline)][String]$InputObject,$PipelineParams=@{})
function main() {
$params = @{
	Fields = "name", "age", "email"
};
$InputObject | & ../components/SelectFields.ps1 @params
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main
