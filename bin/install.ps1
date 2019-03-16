<#
	.Synopsis
	Install PowowShell as a Global CmdLet (Module)
	
	.Description
	Once installed you can run "pow <command>" directly from PowerShell
	
	.Parameter Verify
	Only check if PowowShell is installed
	
	.Parameter Force
	Overwrite PowowShell if is installed already
	
#>
[CmdletBinding()]
param(
	[switch]$Verify=$false,
	[switch]$Force=$false
)
function main() {
    try {
        Push-Location $PSScriptRoot
        
        # Check if already installed
        #$PowowShell = Get-Module "PowowShell" # Unreliable
        $PowowShell = Get-Command "pow"
        $PowExists = -not ($PowowShell -eq $null)

        # We install if forced or if we are not just Verifying
        if ($Force -or -not $Verify) {
            $Paths = $env:PSModulePath -split ";"
            $File = Get-Item .\powowshell.psm1
            $PathFinal = $null
            # We install if forced or if pow does not exist
            if ($Force -or -not $PowExists) {
                ForEach ($Path in $Paths) {
                    Write-Host "Installing PowowShell module to $Path ..."
                    $DestPath = $Path + "\PowowShell"
                    try {
                        if (Test-Path $DestPath) {} else {New-Item -ItemType directory $DestPath 2>$null | Out-Null}
                        if (Test-Path "$DestPath\powowshell.psm1") {Write-Warning "PowowShell Module exists: You need to restart PowerShell to see the changes!"}
                        $result = $File.CopyTo($DestPath + "\powowshell.psm1", $true) 2> $null
                        $PathFinal = $DestPath + "\powowshell.psm1"
                        if (Test-Path $PathFinal) {break}
                    } catch {
                        Write-Host "Could not install module to $Path !"
                    }
                }
                # Point the powowshell module back to this bin\ directory
                $PSScriptRoot > "$DestPath\path.txt";
                if ($PathFinal -eq $null) {
                    Write-Host "Could not find an existing powershell modules directory to install to!" -ForegroundColor Red
                }
            } else {
                Write-Host "The pow command already exists in PowerShell!" -ForegroundColor Cyan
                Write-Host " Tip: Type install -force to re-install" -ForegroundColor Cyan
            }
            #if (Get-Command "pow" -errorAction SilentlyContinue) {$PowowShell=$true}
            $PowowShell = Get-Command "pow"
            $PowExists = -Not ($PowowShell -eq $null)
        }

        if ($PowExists) {
            Write-Host "Yep, the 'pow' is CmdLet installed" -ForegroundColor Green
            Write-Host " Type 'pow help' for a list of commands"
        } else {
            Write-Host "Nope, the 'pow' CmdLet is not installed!" -ForegroundColor Red
        }
        return $null
    } catch {
        throw $_
    } finally {
        Pop-Location
    }
}
Set-StrictMode -Version Latest
main