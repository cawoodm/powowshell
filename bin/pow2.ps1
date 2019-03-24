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
#########################################
[CmdletBinding()]
	param(
			[Parameter(Mandatory=$true)][String[]]
			$Command,
			$p1,$p2,$p3
    )
#########################################
function Invoke-PowowShell {
	[CmdletBinding()]
	param(
			[Parameter(Mandatory=$true)][String[]]
			[ValidateSet("version", "help", "clean", "build", "verify", "run", "inspect", "components", "install", "workspace")]
			$Command,
			$p1,$p2,$p3
    )
    
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    
    # Change to bin\ path
    $BinPath = $PSScriptRoot
    # If we are installed as a module, our bin\ path is stored in path.txt
    if (Test-Path "$BinPath\path.txt") {$BinPath = Get-Content "$BinPath\path.txt"}
    Push-Location $BinPath

    # Resolve ! paths with the workspace
    #  Doing this: (Resolve-Path .\examples).path > .\workspace.txt
    #  Lets you do this: pow inspect mycomponent
    #  instead of: pow inspect .\examples\components\mycomponent.ps1
    $Workspace=$null
    if (Test-Path "..\workspace.txt") {$Workspace = Get-Content "..\workspace.txt"}
    if ($p1 -is [string] -and $p1 -like "!*") {
        if ($Command -in "inspect", "components") {
            $p1 = $p1.replace("!", "$Workspace\components\"); $p1+=".ps1"
        } else {
            # !pipeline1 => $Workspace\pipeline1\
            $p1 = $p1.replace("!", "$Workspace\");
        }
    }
    # Get back to the location of the caller
    Pop-Location
	ForEach ($Cmd in $Command) {
		try {
			Write-Verbose "`"$BinPath\$Cmd.ps1`" $p1 $p2 $p3"
			if ($p3) {& "$BinPath\$Cmd.ps1" $p1 $p2 $p3}
			elseif ($p2) {& "$BinPath\$Cmd.ps1" $p1 $p2}
			elseif ($p1) {& "$BinPath\$Cmd.ps1" $p1}
			else {& "$BinPath\$Cmd.ps1"}
		} catch {
			#Write-Error "Error in '$cmd' command:" + $_
			throw $_
		} finally {
            
        }
	}
}
Set-StrictMode -Version Latest
Set-Alias pow Invoke-PowowShell
#########################################
Invoke-PowowShell $Command $p1 $p2 $p3
#########################################