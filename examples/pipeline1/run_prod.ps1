[CmdletBinding(SupportsShouldProcess)]
param(
	$DataSource = ".\data\voters.txt",
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

	# Run Step A: Read Voters File
	Write-Verbose "Running step A: Read Voters File"
	$OP_A = .\step_A.ps1 -PipelineParams $PipelineParams

	# Run Step B: Convert2JSON
	Write-Verbose "Running step B: Convert2JSON"
	$OP_B = $OP_A | .\step_B.ps1 -PipelineParams $PipelineParams

	# Run Step C: Select Name and Email
	Write-Verbose "Running step C: Select Name and Email"
	$OP_C = $OP_B | .\step_C.ps1 -PipelineParams $PipelineParams

	$OP_C

} catch {
   throw $_
} finally {
   Pop-Location
}

