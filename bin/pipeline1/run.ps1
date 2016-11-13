param(
    [bool]$something
)

# Clear Screen
# => Not good for tests
#Clear-Host

# Clear trace folder
New-Item -Path .\trace -Type directory -Force | Out-Null
Remove-Item -Path .\trace\tmp_*.txt

# We must start in the folder of the pipeline
#  or relative paths to steps won't work
# Alternatively we have to save $ROOT
$ENV=@{}
$ENV.PathStarted = (Get-Location).Path
CD $PSScriptRoot

# Get our context by including all globals
. .\globals.ps1

# Run component A (Source)
.\step_A.ps1

# Run component B (Transformation)
Get-Content -Raw .\trace\tmp_A_output.txt | .\step_B.ps1

# Run component C (Destination)
Get-Content -Raw .\trace\tmp_B_output.txt | .\step_C.ps1

# Return Output
Get-Content -Raw .\trace\tmp_C_output.txt

# Restore path
CD $ENV.PathStarted