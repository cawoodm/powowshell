<#
    .Synopsis
    Run a powowshell command

    .Description
    Calls compile.ps1 to build the pipeline
		If successful, runs the pipeline
   
    .Parameter Commands

#>
[CmdletBinding()]
param(
		[Parameter(Mandatory=$true)][String[]]$Commands,
		$p1
)
function Main() {
	$Commands | % {
		& "$PSScriptRoot\$_.ps1" $p1
	}
}
Main