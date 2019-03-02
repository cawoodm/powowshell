<#
 .Synopsis
 Run a powowshell command

 .Description
 Calls one or more <command>.ps1 to

 .Example
 Clea, build and verify a pipeline
 .\pow.ps1 "clean", "build", "verify" .\examples\pipeline1

 .Parameter Command
 One or more (array) of commands to execute

 .Parameter p1
 An optional first pass-thru parameter

#>
[CmdletBinding()]
param(
		[Parameter(Mandatory=$true)][String[]]$Command,
		$p1,$p2,$p3
)
function main() {
	$Command | % {
		Write-Verbose "`"$PSScriptRoot\$_.ps1`" $p1 $p2 $p3"
		if ($p3) {& "$PSScriptRoot\$_.ps1" $p1 $p2 $p3}
		elseif ($p2) {& "$PSScriptRoot\$_.ps1" $p1 $p2}
		elseif($p1) {& "$PSScriptRoot\$_.ps1" $p1}
		else {& "$PSScriptRoot\$_.ps1"}
	}
}
Set-StrictMode -Version Latest
main