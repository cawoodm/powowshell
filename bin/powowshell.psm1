<#
.Synopsis
The POW Cmdlet (CLI) runs various POW CmdLets to work with PowowShell

.Description
Place in your powershell modules directory so you can run "POW" from anywhere in powershell
OR run the following in PowerShell to install globally
Import-Module -Global .\bin\powowshell.psm1 -Force
Type "pow help" for a list of commands

.Example
pow help
Get general help with a list of commands

.Example
pow help build
Get help with a specific command (e.g. build)

.Example
pow "clean", "build", "verify" .\examples\pipeline1
Clean, build and verify a pipeline

#>
function Invoke-PowowShell {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory=$true)][String[]][ValidateSet("version", "help", "clean", "build", "verify", "run", "inspect", "components", "install")]$Command,
			$p1,$p2,$p3
	)
	ForEach ($Cmd in $Command) {
		try {
			Write-Verbose "`"$PSScriptRoot\$Cmd.ps1`" $p1 $p2 $p3"
			if ($p3) {& "$PSScriptRoot\$Cmd.ps1" $p1 $p2 $p3}
			elseif ($p2) {& "$PSScriptRoot\$Cmd.ps1" $p1 $p2}
			else {& "$PSScriptRoot\$Cmd.ps1" $p1}
		} catch {
			Write-Error "Error in '$cmd' command:"
			throw $_
		}
	}
}
Set-StrictMode -Version Latest
Set-Alias pow Invoke-PowowShell
Export-ModuleMember -Function Invoke-PowowShell -Alias pow