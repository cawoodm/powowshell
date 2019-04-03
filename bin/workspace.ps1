<#
 .Synopsis
 Set the current workspace

 .Description
 Dry run a pipeline, suppressing real output to check for errors
 Run with -Verbose to see detailed steps

 .Parameter Path
 The path to the folder containing components and pipelines

 .Example
 pow workspace ./examples
 Set workspace to the standard examples which come with powowshell

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Path
)
function main() {
	try {
        $WPath = (Resolve-Path -Path $Path).Path
        if (-not (Test-Path "$Wpath\components")) {Write-Warning "$WPath does not appear to be a workspace. No components\ subfolder!"; return;}
        # Workspace is always in root of this app otherwise pow commands will become relative to their execution location
        Push-Location $PSScriptRoot
        $WPath > ..\workspace.txt
        Pop-Location
        Write-Host "Workspace set to '$WPath'" -ForegroundColor Cyan
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)")
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main