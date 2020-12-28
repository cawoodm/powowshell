<#
 .Synopsis
 Return the list of all cmdlets installed on the system

 .Description
 The output is cached and will be used unless the action is "generate"

 .Parameter Action
 Action generate: Generate cmdlet definitions as collection
 Action list: List (cached) cmdlet definitions
 Action export: Return (cached) cmdlet definitions as JSON
 Action check: Ensure we have a cache, generate if necessary don't return anything

#>
[CmdletBinding()]
param(
    [ValidateSet("generate", "export", "list", "check")][string]$Action=$null,
    [string]$Filter
)
function main() {

    # Save path we are started from
    $StartPath = (Get-Location).Path

    try {

        # Check Cache
        Set-Location $PSScriptRoot
        $CacheDir = $_POW.CACHER
		if (-not (Test-Path "$CacheDir/cmdlets")) {$null = New-Item -Path "$CacheDir/cmdlets" -ItemType Directory}
        $CachePath = "$CacheDir/cmdlets.json"
        $CacheFile=$null;$JSON=$null
        if ($Action -notlike "generate" -and (Test-Path $CachePath)) {
            $CacheFile = Get-Item $CachePath;
            $JSON = Get-Content $CachePath -Raw
            if ($JSON -match "^\["){} else {$JSON=$null; $CacheFile=$null} # Cache is gone
        }

        if ($Action -notlike "generate" -and $CacheFile) {
            # We can return cached results
            try {
                $NoFilter = ($null -eq $Filter -or $Filter -eq "");
                if ($Action -like "export" -and $NoFilter) {
                    $CmdLets = $JSON
                } elseif ($NoFilter) {
                    $Cmdlets = ($JSON | ConvertFrom-Json)
                } else {
                    $Cmdlets = ($JSON | ConvertFrom-Json) | Where-Object {$_.reference -like $Filter}
                }
                Write-Verbose "Cmdlet cache is fresh"
                if ($Action -like "export") {
                    if ($NoFilter) {return $JSON}
                    return $CmdLets | ConvertTo-Json -Depth 10
                }
                if ($Action -notlike "generate" -and $Action -notlike "check") {
                    return $Cmdlets
                } else {
                   return "OK"
                }
            } catch {throw "Cmdlet cache is corrupted: $_"}
        }
        # Get all installed Cmdlets and Functions
        #  - include only *-*: gives good results
        $WhereFilter = {$_.Name -like "*-*"}
        if ($Filter) {
            $CmdletsAll = (Get-Command -Type CmdLet,Function -Name $Filter).Where($WhereFilter)
        } else {
            $CmdletsAll = (Get-Command -Type CmdLet,Function).Where($WhereFilter)
        }
        Write-Verbose "$($CmdletsAll.count) Cmdlets found"
        # Sort and deduplicate (yes!) by name
        $CmdletsAll = $CmdletsAll | Sort-Object Name -Unique # | Select -First 10
        # Parse each CmdLet using `pow inspect`
        $Cmdlets = [System.Collections.ArrayList]@()
        $done=0;$tot=$CmdletsAll.count
        foreach($cmdlet in $CmdletsAll) {
            $done++
            Write-Progress -PercentComplete ([int]([Math]::Round(100*$done/$tot))) -CurrentOperation "Reading $($cmdlet.name)..." -Activity "Inspecting installed cmdlets"
            if ($cmdlet.name -notlike "*-*") {Write-Verbose "Excluding $($cmdlet.name) as a possible alias function.";continue;}
            $cm = & "$PSScriptRoot/inspect.ps1" -Path $cmdlet.name
            if ($null -eq $cm) {continue}
            $null = $Cmdlets.add($cm)
            # Cache each cmdlet (for development/diagnosis)
            #  For BOM-less with PWSH6 we could use -Encoding UTF8NoBOM
            ConvertTo-Json -InputObject $cm -Depth 7 | Set-Content -Encoding UTF8 -Path "$CacheDir/cmdlets/$($cmdlet.name).json"
        }
        if (-not $Filter) {
            # Update the cache of all cmdlets
            $JSON = ConvertTo-Json -Depth 10 -InputObject $Cmdlets
            $JSON | Set-Content $CachePath
        } elseif ($Action -like "export") {
            $JSON = ConvertTo-Json -Depth 10 -InputObject $Cmdlets
        }
        if ($Action -like "export") {
            return $JSON
        } elseif ($Action -notlike "generate" -and $Action -notlike "check") {
            return $Cmdlets
        }
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Set-Location $StartPath
    }
}

. "$PSScriptRoot/common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
$ErrorActionPreference = "Stop"
main