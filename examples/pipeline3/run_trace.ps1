Push-Location $PSScriptRoot
#Create folder for trace files
New-Item -Path .\trace -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Run Step A: Read Voters File
Write-Verbose "Running step A: Read Voters File"
.\step_A.ps1 >.\trace\tmp_A_output.txt 2>.\trace\tmp_A_errors.txt 5>>.\trace\tmp_debug.txt

# Run Step B: Convert2JSON
Write-Verbose "Running step B: Convert2JSON"
Get-Content -Raw .\trace\tmp_A_output.txt | .\step_B.ps1 >.\trace\tmp_B_output.txt 2>.\trace\tmp_B_errors.txt 5>>.\trace\tmp_debug.txt

# Run Step C: Select Name and Email
Write-Verbose "Running step C: Select Name and Email"
Get-Content -Raw .\trace\tmp_B_output.txt | .\step_C.ps1 >.\trace\tmp_C_output.txt 2>.\trace\tmp_C_errors.txt 5>>.\trace\tmp_debug.txt

# Return Output
Write-Host "Trace output is in the trace\ folder of your pipeline"
Pop-Location
