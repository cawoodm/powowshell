param(
    [int]$runMode=3
)
Set-PSDebug -Strict

Push-Location $PSScriptRoot

# Clear trace folder
If (-not (Test-Path './trace')) {New-Item -Path .\trace -Type directory | Out-Null}
Remove-Item -Path .\trace\tmp_*.txt

# Get our context by including all globals
. .\globals.ps1

If ($runMode -eq 3) {

# Run component A (Source)
.\step_A.ps1 >.\trace\tmp_A_output.txt 2>.\trace\tmp_A_errors.txt 5>>.\trace\tmp_debug.txt

# Run component B (Transformation)
Get-Content -Raw .\trace\tmp_A_output.txt | .\step_B.ps1 >.\trace\tmp_B_output.txt 2>.\trace\tmp_B_errors.txt 5>>.\trace\tmp_debug.txt

# Run component C (Destination)
Get-Content -Raw .\trace\tmp_B_output.txt | .\step_C.ps1 >.\trace\tmp_C_output.txt 2>.\trace\tmp_C_errors.txt 5>>.\trace\tmp_debug.txt

# Return Output
Get-Content -Raw .\trace\tmp_C_output.txt
} ElseIf ($runMode -eq 1) {

} Else {
    # This mode shows the errors in the console if we don't redirect them
    #$OP=@{}
    $OP_A = .\step_A.ps1 #2>.\trace\tmp_A_errors.txt
    $OP_B = $OP_A | .\step_B.ps1 #2>.\trace\tmp_B_errors.txt
    #$OP_B2 = $OPA | .\step_B2.ps1
    $OP_C = $OP_B | .\step_C.ps1 #2>.\trace\tmp_C_errors.txt
    $OP_C
}

# Restore path
#CD $ENV.PathStarted
Pop-Location