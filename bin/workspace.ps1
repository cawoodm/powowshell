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
    [Parameter(Mandatory=$true)][String]$Path
)
function main() {
    Push-Location $PSScriptRoot
    CD..
	try {
        $WPath = (Resolve-Path $Path).Path
        if (-not (Test-Path $WPath)) {throw "Workspace does not exist at $WPath"}
        $WPath > .\workspace.txt
        Write-Host "Workspace set to '$WPath'" -ForegroundColor Cyan
    } catch {
        throw $_
    } finally {
        Pop-Location
    }
}
Set-StrictMode -Version Latest
main