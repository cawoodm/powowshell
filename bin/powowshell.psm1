<#
.Synopsis
A module which exposes the POW Cmdlet (CLI)

.Description
Place in your powershell modules directory so you can run "POW" from anywhere in powershell

.Example
Clean, build and verify a pipeline
POW "clean", "build", "verify" .\examples\pipeline1

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
		else {& "$PSScriptRoot\$_.ps1" $p1}
	}
}
Set-StrictMode -Version Latest
Export-ModuleMember main