function main() {
    $cd = $pwd.Path
    $cmd = @'
@ECHO OFF
IF "%POWERSHELL%" == "" SET POWERSHELL=POWERSHELL
%POWERSHELL% -File "%~dp0%1.ps1" %2 %3 %4
'@ |
	  Out-File -FilePath .\pow.cmd -Encoding ASCII
	$path = $env:path -split ';'
  "PowowShell is now installed!"
  "Type 'pow version' to verify this..."
	""
	"NOTE: It's a good idea to now copy pow.cmd to a location on your system PATH e.g.:"
	"  COPY .\pow.cmd `"$($path[1])`""
	}
main