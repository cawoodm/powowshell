<#
 .Synopsis
 When POW is called without arguments

 .Parameter Command
 The POW Command to get help for

 .Example
 pow help
 General help on commands

 .Example
 pow help build
 Help on the build command

#>
[CmdletBinding()]
param(
    $Command
)
function main() {
    if ($Command) {
        Push-Location $PSScriptRoot
        if (Test-Path ".\$Command.ps1") {
            Get-Help ".\$Command.ps1" -Detailed | more
        } else {
            Write-Host "Unknown command '$Command'!" -ForegroundColor Red
            Write-Host " * try 'pow help' for a list of commands" -ForegroundColor Cyan
            Write-Host " * try 'pow help <command>' for help on a command" -ForegroundColor Cyan
        }
        Pop-Location
    } else {
	"POW! PowowShell Packs a Punch!"
@"
Usage: pow <command>
Commands: "version", "help", "clean", "build", "verify", "run", "inspect", "components"
Command examples:
 * pow version: Print version information
 * pow help <command>: Help using a command
 * pow build <pipeline>: Build a pipeline (creates .ps1 file)
 * pow verify <pipeline>: Verify a pipeline by running it in PowerShell's 'dry run' (-WhatIf) mode
 * pow run <pipeline>: Run a pipeline
 * pow run <pipeline> -Trace -Verbose: Run a pipeline with verbose output and each step's output logged to trace directory
 * pow run <pipeline> @params: Run a pipeline passing in parameters (using splatting)
 * pow clean, build <pipeline>: Delete a built pipeline and re-build it
 * pow inspect <component.ps1>: Inspects a component
 * pow components <components directory>: List components in a folder
"@
    }
}
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main