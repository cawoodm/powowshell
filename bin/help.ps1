<#
 .Synopsis
 When POW is called without arguments

 .Parameter Command
 The POW Command to get help for
#>
[CmdletBinding()]
param(
    $Command
)
function main() {
    if ($Command) {
        Push-Location $PSScriptRoot
        if (Test-Path ".\$Command.ps1") {
            Get-Help ".\$Command.ps1" -Detailed
        } else {
            Write-Host "Unknown command '$Command'!" -ForegroundColor Red
            Write-Host " * try 'pow help' for a list of commands" -ForegroundColor Cyan
            Write-Host " * try 'pow help <command>' for help on a command" -ForegroundColor Cyan
        }
        Pop-Location
    } else {
	"POW! PowowShell Packs a Punch!"
@"
Command examples:
* pow version: Print version information
* pow build <pipeline>: Build a pipeline (creates .ps1 file)
* pow verify <pipeline>: Verify a pipeline by running it in PowerShell's 'dry run' (-WhatIf) mode
* pow run <pipeline>: Run a pipeline
* pow run <pipeline> -Trace -Verbose: Run a pipeline with verbose output and each step's output logged to trace directory
* pow run <pipeline> @params: Run a pipeline passing in parameters (using splatting)
* pow clean <pipeline>: Delete a built pipeline
* pow inspect <component.ps1>: Inspects a component
* pow components <components directory>: List components in a folder
"@
    }
}
Set-StrictMode -Version Latest
main