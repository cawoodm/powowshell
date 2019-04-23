<#
 .Synopsis
 Return the list of all cmdlets installed on the system 

 .Description
 The output is cached and will be used unless the action is "generate"

 .Parameter Action
 Action generate: Generate cmdlet definitions as collection
 Action export: List (cached) cmdlet definitions as JSON

#>
[CmdletBinding()]
param(
    [ValidateSet("generate", "export")][string]$Action=$null,
    [string]$Filter
)
function main() {
    try {
        # Check Cache
        Set-Location $PSScriptRoot
        # ASSUME: Cache is in root of application
        $CachePath = "..\cmdlets.json"
        $CacheFile=$null;$JSON=$null
        if (Test-Path $CachePath) {
            $CacheFile = Get-Item $CachePath;
            $JSON = Get-Content $CachePath -Raw
            if ($JSON -match "^\["){} else {$JSON=$null; $CacheFile=$null} # Cache is gone
        }
        # Return cached results
        if ($Action -notlike "generate" -and $CacheFile) {
            try {
                $NoFilter = ($null -eq $Filter -or $Filter -eq "");
                if ($Action -like "export" -and $NoFilter) {
                    $CmdLets = $JSON
                } else {
                    $Cmdlets = ($JSON | ConvertFrom-Json) | Where-Object {$_.reference -like $Filter}
                }
                Write-Verbose "Cmdlet cache is fresh"
                if ($Action -like "export"){return $CmdLets | ConvertTo-Json -Depth 10}
                return $Cmdlets
            } catch {throw "Cmdlet cache is corrupted: $_"}
        }
        return
        # Get all installed Cmdlets
        $Cmdlets = Get-Command |
            Sort-Object -Property Name |
            ForEach-Object {pow inspect $_}
        # Update the cache
        ($Cmdlets | ConvertTo-Json -Depth 10) | Set-Content $CachePath
        return $Cmdlets
    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Pop-Location
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main