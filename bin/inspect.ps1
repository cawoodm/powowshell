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
		$cmd = Get-Help -Full -Name $Path -ErrorAction SilentlyContinue
		# We WARN and exit instead of throwing so that 1 broken component doesn't halt everything
		#  if ($null -eq $cmd ) {throw"Invalid CmdLet in component '$Filename'!"}
		if (-not $cmd.PSObject.Properties.item("details")) {Write-Warning "Invalid CmdLet in component '$Filename'!"; return $null}
		$boolMap = @{"true"=$true;"false"=$false}
		$parameters = Get-Help -Name $Path -Parameter * -EA 0
		if ($null -eq $parameters) {Write-Warning "No parameters found in component '$Filename'!"}
		$inputType = ""; $inputDesc = "";
		$paramsOut = @()
		$pipelineInputParam = $false;
		foreach ($parameter in $parameters) {
			if ($parameter.pipelineInput -like "true*") {
				$pipelineInputParam = $true;
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
		if ($pipelineInputParam) {
			$inputType = Get-IPType($cmd)
			$inputDesc = Get-IPDesc($cmd)
		}
		if ($pipelineInputParam -and -not $inputType) {Write-Warning "Pipeline input not described properly in annotated comments (.Inputs) of $Filename!"}
		if (-not $pipelineInputParam -and $inputType) {Write-Warning "Pipeline input not declared properly in parameters (ValueFromPipeline=`$true) of $Filename!"}
		$synopsis = Get-Synopsis($cmd)
		$description = Get-Description($cmd)
		$outputType = Get-OPType($cmd)
		$outputDesc = Get-OPDesc($cmd)
		$reference = $Filename -replace ".ps1", ""
		return [PSCustomObject]@{
			"reference" = $reference;
			"synopsis" = $synopsis;
			"description" = $description;
			"parameters" = $paramsOut;
			"input" = $inputType;
			"inputDescription" = $inputDesc;
			"output" = $outputType;
			"outputDescription" = $outputDesc;
		} #| ConvertTo-Json
	} catch {
		#throw ("ERROR in ./bin/inspect.ps1 on Line " + $_.InvocationInfo.ScriptLineNumber + ":`n" + $_.Exception.Message)
		Write-Error ("ERROR in ./bin/build.ps1 on Line " + $_.InvocationInfo.ScriptLineNumber + ":`n" + $_.Exception.Message)
		#$PSCmdlet.ThrowTerminatingError($PSItem)
		#throw $_
	}
}
function Get-Synopsis($cmd) {try{$cmd.details.description[0].Text}catch{}}
function Get-Description($cmd) {try {return $cmd.description[0].Text}catch{}}
function Get-IPType($cmd) {try{([string](Get-IP($cmd))[0]).ToLower()}catch{}}
function Get-IPDesc($cmd) {try{[string](@(Get-IP($cmd)))[1]}catch{}}
function Get-IP($cmd) {try{@($cmd.inputTypes[0].inputType[0].type.name+"`n" -split "`n")}catch{}}
function Get-OPType($cmd) {try{([string](Get-OP($cmd))[0]).ToLower()}catch{}}
function Get-OPDesc($cmd) {try{[string](@(Get-OP($cmd)))[1]}catch{}}
function Get-OP($cmd) {try{@($cmd.returnValues[0].returnValue[0].type.name+"`n" -split "`n")}catch{}}
Set-StrictMode -Version Latest
main