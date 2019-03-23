<#
 .Synopsis
 Run a pipeline

 .Description
 Runs the pipeline in production (or trace) mode

 .Parameter Path
 The path to the pipeline folder

 .Parameter Parameters
 A hashmap of the parameters to pass to the pipeline (splatting)

 .Parameter Trace
 If set, will trace each step's input and output to the trace\ folder of the pipeline
 This can be useful for debugging

 .Example
 pow run ./examples/pipeline1 @{DataSource="./data/names.txt"}

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)][String]$Path,
		$Parameters=@{},
		[switch]$Trace=$false
)
function main() {
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
		if ($Trace) {
			& .\run_trace.ps1 @Parameters
		} else {
			& .\run_prod.ps1 @Parameters
		}
	} catch {
		Write-Host "!!! PIPELINE RUN FAILED !!!" -ForegroundColor Red
		Write-Error ("ERROR in pipeline on Line " + $_.InvocationInfo.ScriptLineNumber + ":`n" + $_.Exception.Message)
	} finally {
		Pop-Location
	}
}
Set-StrictMode -Version Latest
main