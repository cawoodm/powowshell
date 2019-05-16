<#
 .Synopsis
 Build a powershell script from a .json definition into a runnable .ps1 script

 .Description
 Unlike build, only cmdlets can be used and a single .ps1 script is the result
 The idea is a quick script builder which generates simple PowerShell code without
 dependencies on PowowShell Components or other proprietary code.

 .Parameter Path
 The path to the .json describing the script

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][String]$Path
)
function main() {

    # Include common settings/functions
    . "$PSScriptRoot\common.ps1"

	# Save path we are started from
    $StartPath = (Get-Location).Path

    # Map folder to pipeline.json
    if ($Path -notlike "*.ps1") {$Path += "\pipeline.json"}

    $FullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
	if ($null -eq $FullPath) {throw "Path to script definition $Path not found!"}
    try {
        $def = Get-Content $Path | ConvertFrom-Json

        # Script header, input params etc.

        # Get a hashmap of the steps where $steps.A1 => Step with id='A1'
        $steps = @{}
        foreach ($step in $def.steps) {
            $steps.add($step.id, $step)
        }

        # Convert list of steps to 9x9 grid of steps
        $grid = @(1..9)
        foreach($r in 1..9) {
            $cols = @()
            foreach($c in 1..9) {
                # Get step ID as e.g. "C3"
                $id = [char](64+$c)+[string]$r
                # Get step definition for this position if available
                if ($steps.ContainsKey($id)) {$step = $steps[$id]} else {$step=$null}
                $cols += $step
            }
            $grid[$r-1] = $cols
        }

        # Parse and compile each step into piped lines
        $lines = @()
        $r=0
        foreach($row in $grid) {
            $r++
            $cols = $row
            $cmdlets = @()
            foreach($step in $cols) {
                if ($null -eq $step) {continue}
                $cmdlets += (ScriptStep $step)
            }
            if ($cmdlets) {
                $lines += "# Row $r"
                $line = "`$ROW$r = " + ($cmdlets -join " |`n`t")
                $lines += $line
            }
        }
        $lines -join "`n"

    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        Set-Location $StartPath
    }
}
function ScriptStep($step) {
    if ($step.reference -like "*.ps1") {throw "Only Cmdlets are supported in the script builder!"}
    $result = $step.reference
    return $result
}

. "$PSScriptRoot\common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main