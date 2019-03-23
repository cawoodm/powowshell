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

	# Run Step A1: Read Voters File
	Write-Verbose "Running step A1: Read Voters File"
	$OP_A1 = .\step_A1.ps1 -PipelineParams $PipelineParams

	# Run Step B1: Convert2JSON
	Write-Verbose "Running step B1: Convert2JSON"
	$OP_B1 = $OP_A1 | .\step_B1.ps1 -PipelineParams $PipelineParams

	# Run Step C1: Select Name and Email
	Write-Verbose "Running step C1: Select Name and Email"
	$OP_C1 = $OP_B1 | .\step_C1.ps1 -PipelineParams $PipelineParams

	$OP_C1

} catch {
   throw $_
} finally {
   Pop-Location
}

