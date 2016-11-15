<#
    .Synopsis
    Run a pipeline

    .Description
		Runs the pipeline
   
    .Parameter Path
    The path to the pipeline folder
		
		.Parameter Trace
		If set, will trace each step's input and output to the trace\ folder of the pipeline
		This can be useful for debugging

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][String]$Path,
		[switch]$Trace=$false
)
function Main() {
  $Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	if ($Trace) {
		. .\run_trace.ps1
	} else {
	. .\run_prod.ps1
	}
	Pop-Location
}
Main