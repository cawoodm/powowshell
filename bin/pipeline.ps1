<#
	.Synopsis
	Return a pipeline definition
	
	.Description
	Simply loads pipeline.json from the specified path
	
	.Parameter Path
	The path to the pipeline.json definition

	.Parameter Action
	Action = "export": Export description as JSON
	
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$Path,
	[string][ValidateSet("export")]$Action
)
function main() {
	
	try {
		$Path = (Resolve-Path -Path $Path).Path
		$Filename = (Split-Path -Path $Path -Leaf)
		Write-Verbose "Loading Pipeline from $Path\pipeline.json ..."
		$result = Get-Content "$Path\pipeline.json" -Raw
		if ($Action -like "export") {
			return $result 
		} else {
            return $result | ConvertFrom-Json
		}
	} catch {
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
	}
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main