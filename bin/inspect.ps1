<#
	.Synopsis
	Inspect a component (powershell script) to view it's input and outputs
	
	.Description
	PowowShell expects components (scripts) to clearly define their interface.
	This script returns basic information about a script
	
	.Parameter Path
	The path to the .ps1 script
	
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][string]$Path,
	[switch]$Full
)
function main() {
	$FullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
	if ($FullPath -eq $null) {throw "Path $Path not found!"}
	try {
		$Path = ($FullPath).Path
		$Filename = (Split-Path -Path $Path -Leaf)
		Write-Verbose "Inspecting $Path ..."
		#if ($Full) {return Get-Help $Path -Full | ConvertTo-Json}
		$cmd = Get-Help -Full -Name $Path -ErrorAction SilentlyContinue
		#if ($null -eq $cmd ) {throw"Invalid CmdLet in component '$Filename'!"}
		if (-not $cmd.PSObject.Properties.item("details")) {Write-Warning "Invalid CmdLet in component '$Filename'!"; return $null}
		$boolMap = @{"true"=$true;"false"=$false}
		$parameters = Get-Help -Name $Path -Parameter * -EA 0
		if ($null -eq $parameters) {Write-Warning "No parameters found in component '$Filename'!"}
		$inputType = ""
		$paramsOut = @()
		foreach ($parameter in $parameters) {
			if ($parameter.pipelineInput -eq $true -or $parameter.pipelineInput -like "true*") {
				$inputType = Get-IPType($cmd)
			} else {
				$paramsOut += [PSCustomObject]@{
					"name" = $parameter.name;
					"type" = $parameter.type.name;
					"required" =  $boolMap[$parameter.required];
					"default" = $parameter.defaultValue;
					"description" = (&{if ($parameter.PSObject.Properties.Item("description") -and $parameter.description.length) {$parameter.description[0].text} else {""}})
				};
			}
		}
		$synopsis = Get-Synopsis($cmd)
		$description = Get-Description($cmd)
		$outputType = Get-OPType($cmd)
		return [PSCustomObject]@{
			"reference" = $Filename;
			"synopsis" = $synopsis;
			"description" = $description;
			"parameters" = $paramsOut;
			"input" = $inputType;
			"output" = $outputType;
		} #| ConvertTo-Json
	} catch {
		throw ("ERROR in ./bin/inspect.ps1 in Line " + $_.InvocationInfo.ScriptLineNumber + ":`n" + $_.Exception.Message)
		#$PSCmdlet.ThrowTerminatingError($PSItem)
		#throw $_
	}
}
function Get-Synopsis($cmd) {return $synopsis=$cmd.details.description[0].Text;trap {return ""}}
function Get-Description($cmd) {return $cmd.description[0].Text;trap {return ""}}
function Get-IPType($cmd) {return $cmd.inputTypes[0].inputType.type.name.ToLower();trap {return ""}}
function Get-OPType($cmd) {return $cmd.returnValues[0].returnValue[0].type.name.ToLower();trap {return ""}}
Set-StrictMode -Version Latest
main