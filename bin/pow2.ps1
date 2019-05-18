<#
.Synopsis
The POW Cmdlet (CLI) runs various POW commands to work with PowowShell

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
[CmdletBinding(SupportsShouldProcess)]
	param(
			[Parameter(Mandatory)][String[]]
			$Command,
			$p1,$p2,$p3
    )
#########################################
function Invoke-PowowShell {
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('pow')]
	param(
        [Parameter(Mandatory=$true)][String[]]
        [ValidateSet("install", "version", "help", "workspace", "clean", "build", "verify", "run", "inspect", "components", "cmdlets", "pipeline", "preview", "examples", "adaptors", "script")]
        $Command,
        $p1,$p2,$p3
    )

    # Save path we are started from
    $StartPath = (Get-Location).Path

    try {

        # Start in the bin\ path
        $BinPath = $PSScriptRoot

        # For ease of development we keep all our commands in our program directory's bin\ path
        #  and not in the powershell modules folder
        #  Our modules folder contains a path.txt which points back to this bin\ path
        # If we are installed as a module, our bin\ path is stored in path.txt
        if (Test-Path "$BinPath\path.txt") {$BinPath = Get-Content "$BinPath\path.txt"}
        Push-Location $BinPath

        # Include common settings/functions
        . "./common.ps1"

        # Ensure we have the USER and TEMP folders we need
        if (-not (Test-Path $_POW.HOME)) {$null = New-Item -Path $_POW.HOME -ItemType Directory}
        if (-not (Test-Path $_POW.Temp)) {$null = New-Item -Path $_POW.Temp -ItemType Directory}

        # Resolve ! paths with the workspace
        #  Doing this: (Resolve-Path .\examples).path > .\workspace.txt
        #  Lets you do this: pow inspect mycomponent
        #  instead of: pow inspect .\examples\components\mycomponent.ps1
        if (Test-Path $_POW.WORKSPACE) {$Workspace = Get-Content "$($_POW.HOME)\workspace.txt"; Write-Verbose "WORKSPACE: $Workspace"} else {$Workspace = (Resolve-Path "..\").Path}
        if ($p1 -is [string] -and $p1 -like "!*") {
            if ($Command -in "inspect", "components", "preview", "examples") {
                $p1 = $p1.replace("!", "$Workspace\components\"); $p1+=".ps1"
            } elseif ($command -eq "adaptors") {
                # Adaptors are in /core/adaptors
                $p1 = $p1.replace("!", "..\core\adaptors");
                $p1 = Resolve-Path $p1
            } elseif ($command -eq "workspace") {
                # e.g. "!examples" should be relative to the root of the app
                $p1 = $p1.replace("!", "..\");
                $p1 = Resolve-Path $p1
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
            }
        }
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    } finally {
        Set-Location $StartPath
    }

}
. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
#########################################
Invoke-PowowShell -Command $Command -p1 $p1 -p2 $p2 -p3 $p3