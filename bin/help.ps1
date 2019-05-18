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
            Show-Message "WARNING:`tUnknown command '$Command'!" Red
            Show-Message "INFO:`t * try 'pow help' for a list of commands" Cyan
            Show-Message "INFO:`t * try 'pow help <command>' for help on a command" Cyan
            Show-Message "INFO:`t * try 'pow examples <component|cmdlet>' for examples using a component or cmdlet" Cyan
        }
        Pop-Location
    } else {
	Show-Message "POW! PowowShell Packs a Punch!" Cyan
@"
Usage: pow <command>
Commands: "install", "version", "help", "workspace", "clean", "build", "verify", "run", "inspect", "components", "cmdlets", "pipeline", "preview", "examples", "adaptors"
Command examples:
 * pow version: Print version information
 * pow help <command> : Help using a command
 * pow workspace ./examples : Set the current workspace (containing pipelines) to ./examples
 * pow build <pipeline> : Build a pipeline (creates .ps1 file)
 * pow verify !pipeline1 : Verify a pipeline1 (in workspace) by running it in PowerShell's 'dry run' (-WhatIf) mode
 * pow run <pipeline> : Run a pipeline
 * pow run !pipeline1 -Trace -Verbose : Run a pipeline with verbose output and each step's output logged to trace directory
 * pow run <pipeline> @params: Run a pipeline passing in parameters (using splatting)
 * pow pipeline <pipeline> : Return a pipeline definition
 * pow pipeline <pipeline> export: Return a pipeline definition as JSON
 * pow clean, build, verify <pipeline> : Delete a built pipeline, re-build it and verify it
 * pow inspect <component.ps1> : Inspects a component
 * pow inspect !component.ps1 : Inspects a component in the workspace
 * pow components <components directory> : List components in a folder
 * pow components ! list : List cached components in workspace
 * pow cmdlets generate: Generate cache of installed cmdlets
 * pow cmdlets list: List cache of installed cmdlets
 * pow adaptors : List data I/O adaptors available
 * pow preview <component.ps1> : Preview a component output (if supported)
 * pow examples <component.ps1> : Show examples of component usage (if supported)
"@
    }
}
. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main