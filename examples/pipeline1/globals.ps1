#  This will be included in all steps and thus executed multiple times
$globals = @{
	PPRoot = $PSScriptRoot
    PPDebug = $true
    PPNow = (Get-Date).toString("yyyy-MM-dd hh:mm:ss")
	Foo = "Bar"
}