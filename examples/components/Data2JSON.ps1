﻿<#
 .Synopsis
  Convert input data to JSON format

 .DESCRIPTION
  Accepts custom tabular data about people and return contents as a JSON Array
	The data must be in the format:
	NAME|AGE|GENDER
	However, the separator can be different and specified by the -Delimiter parameter

 .PARAMETER Delimiter
  Specifies the field separator. Default is a comma ",")

 .EXAMPLE
  Data2JSON.ps1 -Delimiter ";"
 
 .INPUTS
  text/xsv
  Any separated data (e.g. CSV) with newlines between records
	
 .OUTPUTS
  text/json
  An array of JSON objects corresponding to the rows of the input data

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Std")]
    [String]$InputObject,
  [Parameter(Mandatory,ParameterSetName="Std")]
    [String]$Delimiter=",",
  [Parameter(ParameterSetName="Std")]
  [String]$RecordSeparator,

	[Parameter(ParameterSetName="POW")]
		[string]$POWAction
)
if ($POWAction -like "test") {
  if (("a|1|M`nb|2|F" | " $PSScriptRoot\Data2JSON.ps1" -Delimiter "|" | ConvertFrom-Json)[1].gender -eq "F") {"OK: Data2JSON"} else {Write-Error "FAIL: Data2Json"}; return
}
,
# The Magic Happens Here...
$result = ""
$r = 0
$str = [string]$InputObject

if ($RecordSeparator) {
	$sep = $RecordSeparator
} else {
	if ($str.IndexOf("`r`n") -ge 0) {$sep = "`r`n"}
	elseif ($str.IndexOf("`r") -ge 0) {$sep = "`r"}
	else {$sep = "`n"}
}

$rows = $str -split $sep
$rows | ForEach-Object {
    $row = $_ -split $Delimiter, 0, "SimpleMatch"
    if ($row.Length -gt 1) {
        $result += '{"name":"' + $row[0] + '", "age":' + $row[1] + ', "gender":"' + $row[2] + '"}'
        $r++
    }
}

# Format as a JSON Array
$result = $result.Replace("}{", "},{")
$result = "[$result]"

# Return JSON serialized
$result

# Should we return JSON Object?
#  -> No, we want serialized data we can redirect into a text file!
# $result | ConvertFrom-Json