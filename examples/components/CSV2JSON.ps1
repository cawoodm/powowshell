<#
 .Synopsis
  Convert CSV data to JSON format

 .Description
  Accepts tabular CSV data and return contents as a JSON Array

 .Parameter Delimiter
  Specifies the field separator. Default is a comma ",")
	
 .Inputs
 text/csv
 A String in CSV format

 .Outputs
 text/json
 A JSON array object

 .Example
 "name,age`na,1`nb,2" | .\CSV2JSON.ps1
 Return a JSON array with objects => [{name:"a", age: 1},{name:"b", age: 2}]

#>
[CmdLetBinding()]
[OutputType([String])]
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$InputObject,
    [String]$Delimiter=",",
    [String[]]$Header
)
Set-StrictMode -Version Latest
if ($InputObject -eq "") {
    Push-Location $PSScriptRoot
    if (("a;1`nb;2" | .\CSV2JSON.ps1 -Delimiter ";" -Header "name","age" | ConvertFrom-Json)[1].age -eq 2) {"CSV2JSON: OK"} Else {Write-Error "CSV2Json: FAIL"}
    Pop-Location
    return
}
if ($Header) {
    $InputObject | ConvertFrom-Csv -Header $Header -Delimiter $Delimiter | ConvertTo-JSON
} else {
    Write-Verbose ($InputObject | ConvertFrom-Csv -Delimiter $Delimiter).GetType()
    $InputObject | ConvertFrom-Csv -Delimiter $Delimiter | ConvertTo-JSON
}