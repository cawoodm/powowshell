<#
 .Synopsis
 Run through all core adaptors and list them

 .Description
 Will list each .ps1 file inside the /core/adaptors/ folder and
 generate a list with each adaptor"s definition

 .Parameter Path
 Path to the adaptors directory

 .Parameter Action
 Action generate: Bypass adaptor cache and read adaptors
 Action export: Export as JSON

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()][String]$Path,
    [ValidateSet("generate", "export")][string[]]$Action=$null
)
function main() {

    if ($Path) {
        Write-Verbose "Path=$Path"
        $FullPath = (Resolve-Path -Path $Path).Path
    } else {
        Push-Location $PSScriptRoot
        $FullPath = (Resolve-Path -Path "..\core\adaptors").Path
    }
    Write-Verbose $FullPath
    Push-Location $FullPath
    try {
        # Check Cache
        # ASSUME: Cache is off root of application
        $CacheFile=$null;$JSON=$null
        if (Test-Path "$PSScriptRoot\..\cache\adaptors.json") {
            $CachePath = Resolve-Path "$PSScriptRoot\..\cache\adaptors.json"
            $CacheFile = Get-Item $CachePath;
            $JSON = Get-Content $CachePath -Raw
            if ($JSON -match "^\["){Write-Verbose "Adaptors cache found: $CachePath"} else {$JSON=$null; $CacheFile=$null} # Cache is gone
        }
        $Adaptors=$null
        if ($Action -notlike "generate" -and $CacheFile) {
            # Return cached JSON
            try {
                $Adaptors = $JSON | ConvertFrom-Json
                Write-Verbose "Adaptor cache is fresh"
            } catch {throw "Adaptor cache is corrupted (invalid JSON)!"}
        }
        if ($Action -like "generate" -or $null -eq $Adaptors) {
            #TODO: Check cache freshness
            # Process all .in files (ASSUME: .out.ps1 exists also)
            $files = Get-ChildItem -Path .\ -File -Filter *.in.ps1
            $Adaptors = @()
            foreach ($file in $files) {
                $Adaptors += [PSObject]@{
                    type = (Split-Path -Path $file.Fullname -Leaf).Replace(".in.ps1", "")
                }
            }
            # Cache JSON
            Write-Verbose "Writing adaptors cache"
            $JSON = ($Adaptors) | ConvertTo-JSON -Depth 4
            $JSON | Set-Content -Encoding UTF8 -Path .\adaptors.json
        }
        Write-Verbose "$($Adaptors.length) adaptors found"
        if ($Action -like "export") {
            # Provide a serialized JSON export
            return $JSON
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