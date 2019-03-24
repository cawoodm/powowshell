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
	try {
        $WPath = ResolvePath $Path
        $WPath > .\workspace.txt
        Write-Host "Workspace set to '$WPath'" -ForegroundColor Cyan
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)")
    }
}
function ResolvePath($Path) {
    $error.clear();
    $Path = Resolve-Path $Path -EA SilentlyContinue;
    if ($error) {throw $error}
    return $Path.path
}
Set-StrictMode -Version Latest
main