.\step_A.ps1 >.\trace\tmp_A_output.txt 2>.\trace\tmp_A_errors.txt 5>>.\trace\tmp_debug.txt

Get-Content -Raw .\trace\tmp_A_output.txt | .\step_B.ps1 >.\trace\tmp_B_output.txt 2>.\trace\tmp_B_errors.txt 5>>.\trace\tmp_debug.txt

Get-Content -Raw .\trace\tmp_B_output.txt | .\step_C.ps1 >.\trace\tmp_C_output.txt 2>.\trace\tmp_C_errors.txt 5>>.\trace\tmp_debug.txt

Get-Content -Raw .\trace\tmp_C_output.txt
