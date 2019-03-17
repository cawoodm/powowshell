<#
 .Synopsis
 Run through all components in a directory and:
 * Validate OUTPUT
 * TODO: Generate a JSON definition from the components/ directory

 .Description
 Will list each .ps1 file inside the components/ folder and
 generate a list with each component's definition

 .Parameter Path
 Path to the components directory

 .Parameter Export
 Export component definitions as JSON for IDE

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][String]$Path,
    [string]$Action=$null

)
function main() {
    $Path = $Path.replace('.ps1', '')
	$FullPath = (Resolve-Path -Path $Path).Path
    Push-Location $FullPath
    try {
        $Components = ListComponents
        if ($Action -like "export") {
            # Provide a serialized JSON export
            return $Components | ConvertTo-JSON
        } else {
            return $Components
        }
    } catch {
        Write-Error ("ERROR in ./bin/components.ps1 in Line " + $_.InvocationInfo.ScriptLineNumber + ":`n" + $_.Exception.Message)
        #throw $_
    } finally {
        Pop-Location
    }
}

function ListComponents() {

    # Get list of subfolders (1 level)
    $folders = Get-ChildItem -Path .\ -Directory

    # Process each folder
    ForEach($folder in $folders) {
        LoadComponents($folder)
    }
    
    # Process current folder
    LoadComponents(".\")
}

function LoadComponents($Path) {

    # Get list of .ps1 scripts components (1 level)
    $scripts = Get-ChildItem -Path $Path -File -Filter *.ps1

    # Process each folder
    ForEach($script in $scripts) {
        Push-Location $PSScriptRoot
        Write-Verbose "INSPECT $($script.Name)"
        try {
            & .\inspect.ps1 $script.Fullname
            #Write-Error ("ERROR in pow/components/LoadComponents in Line " + $_.InvocationInfo.ScriptLineNumber + ": " + $_.Exception.Message)
        } finally {
            Pop-Location
        }
    }

}

function LoadComponent($File) {
    $cmd = Get-Command $File.Fullname

    # Get all parameters in the "Standard" Parameter Set
    $params = $cmd.Parameters.Values | Where {$_.ParameterSets.ContainsKey("Standard")}
  	if ($params -eq $null) {
			# Fallback on all non-system parameters
  		$params = $cmd.Parameters.Values| Where {-not $_.ParameterSets.ContainsKey("__AllParameterSets")}
  	}
  	
  	# Get INPUT Type (must be a InputObject parameter)
  	#$inputType = $cmd.InputType.Name
  	$inputType = $cmd.Parameters.InputObject
  	
    # Validate OUTPUT of Component
    $validOutputs = @("System.String")
    $outputType = $cmd.OutputType.Name
    if (-not $outputType) {
        Write-Warning "No OutputType found for component '$ref'!"
    } ElseIf ($outputType -and -not $validOutputs -contains $outputType) {
        Write-Error "Invalid OutputType '$outputType' found for component '$ref'!"
        Throw [Exception] ""
    }

    # Build Step code
    #$cmd1 = "$inputSrc$ref @params" # >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt"
    #$stepTemplate -f $params0, $cmd1 > "step_$id.ps1"

    #$Count++

}
Set-StrictMode -Version Latest
main