<#
    .Synopsis
    Compile and run a pipeline

    .Description
    Calls compile.ps1 to build the pipeline
		If successful, runs the pipeline
   
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
  $FullPath = (Resolve-Path -Path $Path).Path
	#Push-Location $PSScriptRoot
	. "$PSScriptRoot\compile.ps1" -Path $Path
	if ($error.count -gt 0) {Pop-Location;return;}
	Pop-Location
	. "$PSScriptRoot\run.ps1" -Path $Path -Trace:$Trace
}
Main