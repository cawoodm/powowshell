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
        #$PowowShell = Get-Module "PowowShell" # Unreliable: may exist but not be installed
        #$PowowShell = (Get-Module "PowowShell" -EA 0) -or (Get-Alias "pow" -EA 0)
        $PowowShell = Get-Command "Invoke-PowowShell" -ErrorAction SilentlyContinue
        $PowExists = -not ($null -eq $PowowShell)

        # We install if forced or if we are not just Verifying
        if ($Force -or -not $Verify) {
            $Paths = $env:PSModulePath -split ";"
            $File = Get-Item .\powowshell.psm1
            $File2 = Get-Item .\powowshell.psd1
            $PathFinal = $null
            # We install if forced or if pow does not exist
            if ($Force -or -not $PowExists) {
                ForEach ($Path in $Paths) {
                    Write-Host "Installing PowowShell module to $Path ..."
                    $DestPath = $Path + "\PowowShell"
                    try {
                        if (Test-Path $DestPath) {} else {New-Item -ItemType directory $DestPath 2>$null | Out-Null}
                        #if (Test-Path "$DestPath\powowshell.psm1") {
                        if ((Get-Module "PowowShell" -EA 0) -or (Get-Alias "pow" -EA 0)) {
                            Write-Warning "PowowShell Module exists: You may need to restart PowerShell to see the changes!"
                            Remove-Module -Name PowowShell
                        }
                        Write-Verbose "Copying $File to $DestPath\powowshell.psm1 ..."
                        $result = $File.CopyTo($DestPath + "\powowshell.psm1", $true) 2> $null
                        $PathFinal = $DestPath + "\powowshell.psm1"
                        if (Test-Path $PathFinal) {
                            # Success
                            $result = $File2.CopyTo($DestPath + "\powowshell.psd1", $true) 2> $null
                            Write-Verbose "Import-Module -Name PowowShell -Global -Alias pow"
                            Import-Module -Name PowowShell -Global -Alias pow
                            break
                        }
                    } catch {
                        Write-Host "Could not install module to $Path : $_"
                    }
                }
                # Point the powowshell module back to this bin\ directory
                $PSScriptRoot > "$DestPath\path.txt";
                if ($PathFinal -eq $null) {
                    Write-Host "Could not find an existing powershell modules directory to install to!" -ForegroundColor Red
                }
            } else {
                Write-Warning "The pow command already exists in PowerShell!"
                Write-Host " Tip: Type install -force to re-install" -ForegroundColor Yellow
            }
            #if (Get-Command "pow" -errorAction SilentlyContinue) {$PowowShell=$true}
            write-verbose 'Get-Alias "pow"'
            $PowowShell = Get-Alias "pow"
            write-verbose "`$PowowShell=$PowowShell"
            $PowExists = -Not ($PowowShell -eq $null)
        }

        if ($PowExists) {
            Write-Host "Yep, the 'Invoke-PowowShell' cmdLet is installed" -ForegroundColor Green
            Write-Host "NOTE: You may need to run 'Import-Module -name PowowShell -Global' in PowerShell to use the 'pow' alias" -ForegroundColor Cyan
            Write-Host " Type 'pow help' for a list of commands"
            Write-Host " Type 'pow cmdlets generate' to generate a list of cmdlets for the IDE (may take several minutes)"
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
$ErrorActionPreference = "Stop"
main