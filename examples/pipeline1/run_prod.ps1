[CmdletBinding(SupportsShouldProcess)]
param(
	[string]$DataSource = ".\data\voters.txt",
	$p2 = (Get-Date)
)
$PipelineParams = @{
	DataSource = $DataSource;
	p2 = $p2;
};
$PipelineGlobals = @{
	foo = "bar"
};
Push-Location $PSScriptRoot

try {

	# Run Step A1 readfile: Open Names File
	Write-Verbose "Running step A1 : Open Names File"
	$OP_A1 = .\step_A1.ps1 -PipelineParams $PipelineParams

	# Run Step B1 csv2json: Parse Names File
	Write-Verbose "Running step B1 : Parse Names File"
	# FROM [string] => TO [string]
	$OP_B1 = $OP_A1 | .\step_B1.ps1 -PipelineParams $PipelineParams

	# Run Step C1 selectfields: Select Name and Email
	Write-Verbose "Running step C1 : Select Name and Email"
	# FROM [string] => TO []
	$OP_C1 = $OP_B1 | .\step_C1.ps1 -PipelineParams $PipelineParams

	$OP_C1

} catch {
   throw $_
} finally {
   Pop-Location
}

