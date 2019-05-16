<#
 .Synopsis
 Set/get the current workspace

 .Description
 Defining a workspace allows you to use ! in pow commands to save typing the full path
 This setting is saved in $HOME\powowshell\workspace.txt

 .Parameter Path
 The path to the folder containing components and pipelines

 .Example
 pow workspace ./examples
 Set workspace to the standard examples which come with powowshell

#>
[CmdletBinding()]
param(
    [String]$Path
)
function main() {

	# Save path we are started from
    $StartPath = (Get-Location).Path

    # Location of our workspace setting
    $WSPath = "$($_POW.HOME)\workspace.txt"

	try {
        $WPath=$null

        if ($Path) {
            $WPath = (Resolve-Path -Path $Path).Path
            # ASSUME: Each workspace has a components subfolder
            if (-not (Test-Path "$Wpath\components")) {Write-Warning "$WPath does not appear to be a workspace. No components\ subfolder!"; return;}
            # Workspace is always in root of this app otherwise pow commands will become relative to their execution location
            Push-Location $PSScriptRoot
            $WPath > $WSPath
            Pop-Location
        }

        # Get workspace if nothing specified to set
        Push-Location $PSScriptRoot
        if (Test-Path $WSPath) {$WPath = [string](Get-Content $WSPath)}
        Pop-Location
        # Must return a string so IDE can | convertto-json
        return [string]$WPath
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    } finally {
        Set-Location $StartPath
	}
}

. "$PSScriptRoot\common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main