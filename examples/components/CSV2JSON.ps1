<#
 .Synopsis
  Convert CSV data to JSON format

 .Description
  Accepts tabular CSV data and return contents as a JSON Array

 .Parameter FieldSeparator
  Specifies the field separator. Default is a comma ",")
	
 .Inputs
 text/csv

 .Outputs
 json/array

#>
[CmdLetBinding()]
[OutputType([String])]
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$InputObject,
    [String]$Delimiter=",",
    [String[]]$Header
)
Set-StrictMode -Version 3.0
If ($InputObject -eq "") {
    Push-Location $PSScriptRoot
    If (("a;1`nb;2" | .\CSV2JSON.ps1 -Delimiter ";" -Header "name","age" | ConvertFrom-Json)[1].age -eq 2) {"CSV2JSON: OK"} Else {Write-Error "CSV2Json: FAIL"}
    Pop-Location
    return
}
$params = @{}
$MyInvocation.BoundParameters.Keys | Where {$_ -and $_ -ne "InputObject"} | % {$params.Add($_, (Get-Variable $_).Value )}
$InputObject | ConvertFrom-Csv @params | ConvertTo-JSON