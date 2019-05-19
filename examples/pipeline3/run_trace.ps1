[CmdletBinding(SupportsShouldProcess)]
param(
)
$PipelineParams = @{
};
$PipelineGlobals = @{
};
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
#Create folder for trace files
New-Item -Path ./trace -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Run Step A1: Read Log Files
Write-Verbose "Running step A1: Read Log Files"
./step_A1.ps1 -PipelineParams $PipelineParams > ./trace/tmp_A1_output.txt 2> ./trace/tmp_A1_errors.txt 5>>./trace/tmp_debug.txt

# Run Step B1: Parse Names File
Write-Verbose "Running step B1: Parse Names File"
Get-Content -Raw ./trace/tmp_A1_output.txt | ./step_B1.ps1 -PipelineParams $PipelineParams > ./trace/tmp_B1_output.txt 2> ./trace/tmp_B1_errors.txt 5>>./trace/tmp_debug.txt

# Run Step C1: Select Name and Email
Write-Verbose "Running step C1: Select Name and Email"
Get-Content -Raw ./trace/tmp_B1_output.txt | ./step_C1.ps1 -PipelineParams $PipelineParams > ./trace/tmp_C1_output.txt 2> ./trace/tmp_C1_errors.txt 5>>./trace/tmp_debug.txt

# Return Output
Write-Host "Trace output is in the trace/ folder of your pipeline"
Pop-Location
