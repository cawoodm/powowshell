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

 .Parameter Action
 Action export: Generate component definitions as JSON for IDE
 Action list: List cached component definitions as JSON for IDE

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Path,
    [ValidateSet("generate", "export", "list")][string]$Action=$null
)
function main() {

    $Path = $Path.replace('.ps1', '')
  $FullPath = (Resolve-Path -Path $Path).Path
    Write-Verbose "Components Path=$Path; FullPath=$FullPath"
    Push-Location $FullPath
    try {
        # Check Cache
        $CachePath = "$($_POW.CACHER)/components.json"
        $CacheFile=$null;$JSON=$null
        if ($Action -notlike "generate" -and (Test-Path $CachePath)) {
            $CacheFile = Get-Item $CachePath;
            $JSON = Get-Content $CachePath -Raw
            if ($JSON -match "^\["){} else {$JSON=$null; $CacheFile=$null} # Cache is gone
        }
        # Action = export : Return cached JSON
        if ($Action -like "export" -and $CacheFile) {return $JSON}
        # When did a component last change
        $LastWriteTime = (Get-ChildItem ./ -File -Filter *.ps1 | Where-Object name -notlike *.tests.ps1* | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
        if ($Action -like "generate" -or $null -eq $CacheFile -or $LastWriteTime -gt $CacheFile.LastWriteTime) {
            if ($Action -notlike "generate") {Write-Verbose "Component cache is stale"}
            $JSON=$null
            $Components = ListComponents
            # Update the cache
            $JSON = $Components | ConvertTo-Json -Depth 10
            $JSON | Set-Content $CachePath
        } else {
            # Cache is fresh
            try {$Components = $JSON | ConvertFrom-Json} catch {throw "Component cache is corrupted (invalid JSON)!"}
            Write-Verbose "Component cache is fresh"
        }
        # Update the cache
        if ($Action -like "export") {return $JSON}
        return $Components
    } catch {
        #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        throw $_
    } finally {
        Pop-Location
    }
}

function ListComponents() {

    # Get list of subfolders (1 level)
    $folders = Get-ChildItem -Path ./ -Directory

    # Process each folder
    ForEach($folder in $folders) {
        LoadComponents($folder)
    }

    # Process current folder
    LoadComponents("./")
}

function LoadComponents($Path) {

    # Get list of .ps1 scripts components (1 level)
    #  - Don't include components tests (*.tests.ps1)
    $scripts = Get-ChildItem -Path $Path -File -Filter *.ps1 | Where-Object name -notlike *.tests.ps1

    # Process each folder
    foreach($script in $scripts) {
        try {
            & "$PSScriptRoot/inspect.ps1" $script.Fullname
        } catch {
            # Error message on each component but continue
            #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        }
    }

}

. "$PSScriptRoot/common.ps1"
main