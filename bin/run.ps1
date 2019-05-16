<#
 .Synopsis
 Run a pipeline

 .Description
 Runs the pipeline in production (or trace) mode

 .Parameter Path
 The path to the pipeline folder

 .Parameter Parameters
 A hashmap of the parameters to pass to the pipeline (splatting)

 .Parameter Option
 trace: will trace each step's input and output to the trace\ folder of the pipeline for debugging
 export: will export the output as JSON

 .Example
 pow run ./examples/pipeline1 @{DataSource="./data/names.txt"}

#>
[CmdletBinding(SupportsShouldProcess)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param(
    [Parameter(Mandatory)][String]$Path,
		$Parameters=@{},
		[ValidateSet("trace", "export")]
		[string[]]$Options
)
function main() {

	# Include common settings/functions
	. "$PSScriptRoot\common.ps1"

	# Save path we are started from
	$StartPath = (Get-Location).Path

	if ($Parameters -is [string]) {
			if ($Parameters -like '@*') {
					$Parameters = Invoke-Expression $Parameters
			} else {
					# Parameters in the form of "p1=x"
					Write-Verbose $Parameters
					$Parameters = ($Parameters -replace ";", "`n") # Newlines separate parameters
					# If the user doesn't escape backspaces
					if ($Parameters -notlike "*\\*") {
							# Escape them
							$Parameters = $Parameters.replace("\", "\\")
					}
					$Parameters = ConvertFrom-StringData $Parameters
			}
			#$p = $ExecutionContext.InvokeCommand.ExpandString($Parameters)
	}
	$Path = (Resolve-Path -Path $Path).Path
	Push-Location $Path
	try {
		$exec = ".\run_prod.ps1"
		if ($Options -contains "trace") {$exec=".\run_trace.ps1"}
		if ($Parameters) {
			$result = & $exec @parameters
		} else {
			$result = & $exec
		}
		if ($Options -contains "export" -and $result -isnot [string]) {
			return ConvertTo-Json $result -Compress
		}
		return $result
	} catch {
		Show-Message "ERROR: !!! PIPELINE RUN FAILED !!!" Red
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
	} finally {
		Set-Location $StartPath
	}
}

. "$PSScriptRoot\common.ps1"
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main