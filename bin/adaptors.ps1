<#
 .Synopsis
 Run through all core adaptors and list them

 .Description
 Will list each .ps1 file inside the /core/adaptors/ folder and
 generate a list with each adaptor"s definition

 .Parameter Path
 Path to the adaptors directory

 .Parameter Action
 Action export: Generate component definitions as JSON for IDE
 Action list: List cached component definitions as JSON for IDE

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Path,
    [ValidateSet("export", "list")][string]$Action=$null
)
function main() {
    Write-Verbose "Path=$Path"
	$FullPath = (Resolve-Path -Path $Path).Path
    Push-Location $FullPath
    try {
        # The cached option
        if ($Action -like "list" -and (Test-Path .\adaptors.json)) {
            return Get-Content .\adaptors.json
        }
        #TODO: Check cache freshness
        # Process all .in files (ASSUME: .out.ps1 exists also)
        $files = Get-ChildItem -Path .\ -File -Filter *.in.ps1
        $Adaptors = @()
        foreach ($file in $files) {
            $Adaptors += [PSObject]@{
                type = (Split-Path -Path $file.Fullname -Leaf).Replace(".in.ps1", "")
            }
        }
        Write-Verbose "$($Adaptors.length) adaptors found"
        # Cache JSON
        $JSON = $Adaptors | ConvertTo-JSON -Depth 4
        $JSON > .\adaptors.json
        if ($Action -like "export") {
            # Provide a serialized JSON export
            $JSON
        } else {
            return $Adaptors
        }
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Pop-Location
    }
}

function LoadComponents() {

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
        try {
            & "$PSScriptRoot\inspect.ps1" $script.Fullname
        } catch {
            # Error message on each component but continue
            $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        }
    }

}

$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main