<#
  .Synopsis
  Install PowowShell as a Global CmdLet (Module)

  .Description
  Once installed you can run "pow <command>" directly from PowerShell

  .Parameter Verify
  Only check if PowowShell is installed

#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [switch]$Verify = $false
)
function main() {

  try {
    Push-Location $PSScriptRoot

    # Check if already installed
    $PowowShell = Get-Command "Invoke-PowowShell" -ErrorAction SilentlyContinue
    $PowExists = -not ($null -eq $PowowShell)

    # We install if we are not just Verifying
    if (-not $Verify) {
      $Paths = $env:PSModulePath -split [IO.Path]::PathSeparator
      $File = Get-Item ./powowshell.psm1
      $File2 = Get-Item ./powowshell.psd1
      $PathFinal = $null
      ForEach ($Path in $Paths) {
        Show-Message "Installing PowowShell module to $Path ..."
        $DestPath = $Path + "/powowshell"
        try {
          if (-not (Test-Path $DestPath)) { $null = New-Item -ItemType Directory $DestPath }
          #if (Test-Path "$DestPath/powowshell.psm1") {
          if ((Get-Module "PowowShell" -EA 0) -or (Get-Alias "pow" -EA 0)) {
            Write-Warning "PowowShell Module exists: You may need to restart PowerShell to see the changes!"
            Remove-Module -Name PowowShell
          }
          Write-Verbose "Copying $File to $DestPath/powowshell.psm1 ..."
          $null = $File.CopyTo($DestPath + "/powowshell.psm1", $true) 2> $null
          $PathFinal = $DestPath + "/powowshell.psm1"
          if (Test-Path $PathFinal) {
            # Success
            $null = $File2.CopyTo($DestPath + "/powowshell.psd1", $true) 2> $null
            Write-Verbose "Import-Module -Name PowowShell -Global -Alias pow"
            Import-Module -Name PowowShell -Global -Alias pow
            break
          } else {
            Write-Warning "Failed to write module to $PathFinal"
          }
        } catch {
          Show-Message "Could not install module to $Path : $_"
        }
      }

      # Ensure we have the USER and TEMP folders we need
      if (-not (Test-Path $_POW.HOME)) { $null = New-Item -Path $_POW.HOME -ItemType Directory }
      if (-not (Test-Path $_POW.Temp)) { $null = New-Item -Path $_POW.TEMP -ItemType Directory }
      if (-not (Test-Path $_POW.CACHE)) { $null = New-Item -Path $_POW.CACHE -ItemType Directory }
      if (-not (Test-Path $_POW.CACHER)) { $null = New-Item -Path $_POW.CACHER -ItemType Directory }

      # Point the powowshell module back to this bin/ directory
      $PSScriptRoot > "$DestPath/path.txt";
      if ($null -eq $PathFinal) {
        Show-Message "Could not find an existing powershell modules directory to install to!" Red
      }

      #if (Get-Command "pow" -errorAction SilentlyContinue) {$PowowShell=$true}
      write-verbose 'Get-Alias "pow"'
      $PowowShell = Get-Alias "pow"
      write-verbose "`$PowowShell=$PowowShell"
      $PowExists = -Not ($null -eq $PowowShell)
    }

    # TODO: Create cache/, cache/help and cache/cmdlets folders?

    if ($PowExists) {
      Show-Message "Yep, the 'Invoke-PowowShell' cmdLet is installed" Green
      Show-Message "NOTE: You may need to run 'Import-Module -name PowowShell -Global' in PowerShell to use the 'pow' alias" Cyan
      Show-Message "Checking cmdlets installed..."
      pow cmdlets check
      Show-Message " Type 'pow help' for a list of commands"
    } else {
      Show-Message "Nope, the 'pow' CmdLet is not installed!" Red
    }
    return $null
  } catch {
    throw $_
  } finally {
    Pop-Location
  }
}

$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"
main
