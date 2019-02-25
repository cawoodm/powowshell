﻿[CmdletBinding(SupportsShouldProcess)]
param(
	$p1 = "",
	$p2 = (Get-Date)
)
Push-Location $PSScriptRoot

try {

	# Run Step A: Read Voters File
	$OP_A = .\step_A.ps1

	# Run Step B: Convert2JSON
	$OP_B = $OP_A | .\step_B.ps1

	# Run Step C: Select Name and Email
	$OP_C = $OP_B | .\step_C.ps1

	$OP_C

} catch {
   throw $_
} finally {
   Pop-Location
}

