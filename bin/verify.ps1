<#
 .Synopsis
 Verify a pipeline can run (by running it)

 .Description
 Dry run a pipeline, suppressing real output to check for errors
 Run with -Verbose to see detailed steps

 .Parameter Path
 The path to the pipeline folder

 .Example
 pow verify ./pipeline1
 Verify a pipeline runs

 .Example
 pow verify ./pipeline1 "Param1=foo"
 Verify a pipeline runs with parameter -Param1 foo

 .Example
 pow verify ./pipeline1 "@{Param1=foo}"
 Verify a pipeline runs with parameter -Param1 foo

 .Example
 pow verify ./pipeline1 -Verbose
 Show detailed (verbose) information

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][String]$Path,
    $Parameters=@{}
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
    Write-Verbose $Parameters
    $Path = (Resolve-Path -Path $Path).Path
    Write-Verbose $Path
	Push-Location $Path
	try {
        if (-not (Test-Path .\run_prod.ps1)) {throw "Pipeline is not built!"}
        if (Test-Path .\errors.log) {DEL .\errors.log}
        if (Test-Path .\warnings.log) {DEL .\warnings.log}
        $output = & .\run_prod.ps1 @Parameters -WhatIf 2> .\errors.log 3> .\warnings.log
        $outputErr = Get-Content .\errors.log -Raw
        $outputWar = Get-Content .\warnings.log -Raw
        if ($outputErr) {
            Write-Host "VERIFICATION ERRORS" -ForegroundColor Red
            Write-Host "Your pipeline ran to completion but generated error output:"
            Write-Host  $outputErr -ForegroundColor Red
        } elseif ($outputWar) {
            Write-Host "VERIFICATION ERRORS" -ForegroundColor Yellow
            Write-Host "Your pipeline ran to completion but generated warning output:"
            Write-Host  $outputWar -ForegroundColor Yellow
        } else {
            Write-Host "VERIFICATION OK" -ForegroundColor Green
            Write-Host "Your pipeline ran to completion with no errors"
        }
        # Show params
        $cmd = Get-Command .\run_prod.ps1
        #"`nParameters:"
        $cmd.Parameters.Keys | Where {$_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters} | % {
            #if ($cmd.Parameters[$_].Attributes[0].Mandatory) {"$_ (mandatory)"} else {$_}
        }
    } catch {
        Write-Host "!!! PIPELINE VERIFICATION FAILED !!!" -ForegroundColor Red
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    } finally {
        DEL .\errors.log -ErrorAction SilentlyContinue
        DEL .\warnings.log -ErrorAction SilentlyContinue
		Set-Location $StartPath
	}
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main