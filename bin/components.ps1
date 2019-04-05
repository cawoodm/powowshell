<#
 .Synopsis
 Run through all components in a directory and:
 * Validate OUTPUT
 * TODO: Generate a JSON definition from the components/ directory

 .Description
 Will list each .ps1 file inside the components/ folder and
 generate a list with each component's definition

 .Parameter Path
 Path to the components directory

 .Parameter Export
 Export component definitions as JSON for IDE

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Path,
    [string]$Action=$null

)
function main() {
    $Path = $Path.replace('.ps1', '')
    Write-Verbose "Path=$Path"
	$FullPath = (Resolve-Path -Path $Path).Path
    Push-Location $FullPath
    try {
        $Components = ListComponents
        if ($Action -like "export") {
            # Provide a serialized JSON export
            $Components | ConvertTo-JSON -Depth 4
        } else {
            return $Components
        }
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Pop-Location
    }
}

function ListComponents() {

    # Get list of subfolders (1 level)
    $folders = Get-ChildItem -Path .\ -Directory

    # Process each folder
    ForEach($folder in $folders) {
        LoadComponents($folder)
    }
    
    # Process current folder
    LoadComponents(".\")
}

function LoadComponents($Path) {

    # Get list of .ps1 scripts components (1 level)
    $scripts = Get-ChildItem -Path $Path -File -Filter *.ps1

    # Process each folder
    ForEach($script in $scripts) {
        Write-Verbose "INSPECT $($script.Name)"
        try {
            & "$PSScriptRoot\inspect.ps1" $script.Fullname
        } catch {
            # Error message on each component but continue
            $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        }
    }

}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main