. .\globals.ps1
Write-Verbose $globals.PPRoot
$obj = $input | ConvertFrom-JSON
$obj | % {
	Add-Member -InputObject $_ -NotePropertyName "test" -NotePropertyValue $globals.Foo
}
$obj | ConvertTo-Json
"nix=$nix"