<#
	.Synopsis
	Inspect a component and return examples of usage
	
	.Description
	Equivalent to PowerShell's 'Get-Help -Examples' command
	
	.Parameter Path
	The path to the .ps1 script or name of the CmdLet

	.Parameter Action
    Action = "export": Export description as JSON
    
    .Example
    pow examples !JSONMapping export
    Export examples of how to use the JSONMapping component

#>
[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$Path,
	[string][ValidateSet("export")]$Action
)
function main() {
	
	try {
		$RealPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
		if ($RealPath) {
			$CompType = "component"
			$RealPath = $RealPath.Path
			Write-Verbose "Inspecting custom POW Component from $RealPath ..."
			$Name = (Split-Path -Path $RealPath -Leaf)
			$cmd = Get-Help -Examples -Name $RealPath -ErrorAction SilentlyContinue
			if ($null -eq $cmd) {throw "Invalid POW Component '$RealPath'!"}
		} else {
			$CompType = "cmdlet"
			$RealPath = $Path
			Write-Verbose "Inspecting installed CmdLet $Path ..."
			$Name = $Path
			$cmd = Get-Help -Examples -Name $Name -ErrorAction SilentlyContinue
			if ($null -eq $cmd) {throw "Invalid CmdLet '$RealPath'!"}
        }
		$result=@()
		if ($cmd.PSObject.Properties["examples"] -and $cmd.examples) {
			foreach($example in $cmd.examples.example) {
				$res = [PSCustomObject]@{
					title = $example.title -replace '-', '';
					code = $example.code;
					description = "";
				}
				foreach($line in $example.remarks) {
					$sep = ""; if ($res.description) {$sep="`n"}
					if ($line.Text) {$res.description += $line.Text + $sep;}
				}
				$result += $res
			}
		}
		if ($Action -like "export") {
			return (ConvertTo-Json $result -Depth 3)
		} else {
			return $result
		}
	} catch {
		$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
		#throw $_
	}
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
#[Console]::OuputEncoding = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main