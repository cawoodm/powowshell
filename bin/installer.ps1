param(
	$path=$PSScriptRoot
)
function main() {
	if ($PSVersionTable -eq $null -or $PSVersionTable.PSVersion.Major -lt 3.0) {
		$host.ui.RawUI.ForegroundColor = "red"
			Write-Output "Sorry, you need PowerShell version 3.0 or higher to run PowowShell!"
		return
	}
	@"
@ECHO OFF
IF "%POWERSHELL%" == "" SET POWERSHELL=POWERSHELL
%POWERSHELL% -File "$path\%1.ps1" %2 %3 %4
"@ |
	  Out-File -FilePath .\pow.cmd -Encoding ASCII
	$path = $env:path -split ';'
	@"
-------------------------------------
    PowowShell is now installed!
-------------------------------------

Type 'pow version' to verify this...
NOTE: It's a good idea to now copy pow.cmd to a location on your system PATH e.g.:
	COPY .\pow.cmd `"$($path[1])`"
"@
	}
main