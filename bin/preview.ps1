<#
 .Synopsis
 Preview a step

 .Description
 Runs a step with inputs and returns the result

 .Parameter Reference
 The path to the component or cmdlet name

 .Parameter Parameters
 Optional, a hashmap of the parameters to pass to the step (splatting)

 .Parameter InputObject
 Optional, the object to be piped to the component

 .Example
 pow preview ./examples/components/DateAdd.ps1 7
 Should return the date a week from now

 .Example
 pow preview ./examples/components/DateAdd.ps1 @{Days=7}
 Should return the date a week from now

 .Example
 pow preview ./examples/components/DateAdd.ps1 "@{Days=7}"
 Should return the date a week from now

 .Outputs
 text

#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][String]$Path,
	$Parameters,
	$InputObject
)
function main() {

	# Save path we are started from
	$StartPath = (Get-Location).Path

    try {
        Write-Verbose "JSON: $Parameters"
        if ($Parameters -is [hashtable]) {
            $ParamHash = $Parameters
            $Parameters = "@ParamHash"
        } elseif ($Parameters -like "{*") {
            # Decode JSON and convert JSON Object to HashTable for Splatting
            Write-Verbose "JSON: $Parameters"
            $Parameters = ConvertFrom-Json $Parameters
            $ParamHash = @{}
            $Parameters.psobject.properties | ForEach-Object {$ParamHash[$_.Name] = $_.Value }
            $Parameters = "@ParamHash"
        } elseif ($Parameters -like "@*") {
            # Unsplat parameters if they are a '@{}' string
            $ParamHash = Invoke-Expression $Parameters
            $Parameters = "@ParamHash"
        }

        # Read component/cmdlet definition
        Write-Verbose "PREVIEWING $Path ..."
        $component = & pow "inspect" $Path
        
        # Build executable
        $exec = "& "
        if ($component.type -eq "component") {
            $exec += "`"$Path`""
        } else {
            # CmdLet
            $exec += $component.reference
        }
        $exec += " " + $Parameters
        
        # Run executable
        Write-Verbose "PREVIEW EXEC: $exec"
        Invoke-Expression $exec

	} catch {
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