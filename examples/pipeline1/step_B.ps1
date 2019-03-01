[CmdletBinding(SupportsShouldProcess)]
param([Parameter(ValueFromPipeline=$true)][String]$InputObject,$PipelineParams=@{})
function main() {
$params = @{
	Delimiter = "|"
	Header = "name", "age", "email", "source"
};
$InputObject | & ../components/CSV2JSON.ps1 @params
}
Set-StrictMode -Version Latest
main
