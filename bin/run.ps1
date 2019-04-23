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

 .Example
 pow run ./examples/pipeline1 @{DataSource="./data/names.txt"}

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][String]$Path,
		$Parameters=@{},
		[string]$Option
)
function main() {

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
		if ($option -like "trace") {
			& .\run_trace.ps1 @Parameters
		} else {
			& .\run_prod.ps1 @Parameters
		}
	} catch {
		Write-Host "ERROR: !!! PIPELINE RUN FAILED !!!" -ForegroundColor Red
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
	} finally {
		Set-Location $StartPath
	}
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main