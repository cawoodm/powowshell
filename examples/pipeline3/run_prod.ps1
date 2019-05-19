[CmdletBinding(SupportsShouldProcess)]
param(
)
$PipelineParams = @{
};
$PipelineGlobals = @{
};
Push-Location $PSScriptRoot

try {

	# Run Step A1 FileList.ps1: Read Log Files
	Write-Verbose "Running step A1 : Read Log Files"
	$OP_A1 = ./step_A1.ps1 -PipelineParams $PipelineParams

	# Run Step B1 CSV2JSON.ps1: Parse Names File
	Write-Verbose "Running step B1 : Parse Names File"
	# FROM [string] => TO [string]
	$OP_B1 = $OP_A1 | ./step_B1.ps1 -PipelineParams $PipelineParams

	# Run Step C1 SelectFields.ps1: Select Name and Email
	Write-Verbose "Running step C1 : Select Name and Email"
	# FROM [string] => TO [object]
	$OP_C1 = $OP_B1 | ./step_C1.ps1 -PipelineParams $PipelineParams

	$OP_C1

} catch {
$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
	throw $_
} finally {
	Pop-Location
}

