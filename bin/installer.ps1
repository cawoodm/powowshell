function main() {
  $cd = $pwd.Path
	"@ECHO OFF`nPOWERSHELL -File `"$cd\`%1.ps1`" `%2 `%3 `%4" | Out-File -FilePath .\pow.cmd -Encoding ASCII
	$path = $env:path -split ';'
  "PowowShell is now installed!"
  "Type 'pow version' to verify this..."
	""
	"NOTE: It's a good idea to now copy pow.cmd to a location on your system PATH e.g.:"
	"  COPY .\pow.cmd " + $path[0]
	}
main