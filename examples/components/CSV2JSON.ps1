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

 .Example
 "name;age`na;1`nb;2" | .\CSV2JSON.ps1 -Delimiter ";"
 Return a JSON array with objects => [{name:"a", age: 1},{name:"b", age: 2}]
 This example shows the usage of the Delimiter parameter

#>
[CmdLetBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory,ValueFromPipeline)][string]$InputObject,
        [string]$Delimiter=",",
        [string[]]$Header
)
if ($Header) {
    $InputObject | ConvertFrom-Csv -Header $Header -Delimiter $Delimiter | ConvertTo-JSON
} else {
    Write-Verbose ($InputObject | ConvertFrom-Csv -Delimiter $Delimiter).GetType()
    $InputObject | ConvertFrom-Csv -Delimiter $Delimiter | ConvertTo-JSON
}