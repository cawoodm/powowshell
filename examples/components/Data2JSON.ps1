<#
 .SYNOPSIS
  Convert input data to JSON format

 .DESCRIPTION
  Accepts tabular data (e.g. CSV) and return contents as a JSON Array

 .PARAMETER Delimiter
  Specifies the field separator. Default is a comma ",")
	
 .EXAMPLE
  Data2JSON.ps1 -Delimiter ";"
 
 .INPUTS
  text
	
 .OUTPUTS
  json[]

#>
param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,
	[Parameter(Mandatory=$false)][String]$RecordSeparator,
  [Parameter(Mandatory=$true)][String]$Delimiter=","
)

# The Magic Happens Here...
$result = ""
$r = 0
$str = [string]$InputObject

If ($RecordSeparator) {
	$sep = $RecordSeparator
} Else {
	If ($str.IndexOf("`r`n") -ge 0) {$sep = "`r`n"}
	ElseIf ($str.IndexOf("`r") -ge 0) {$sep = "`r"}
	Else {$sep = "`n"}
}

$rows = $str -split $sep
$rows | ForEach-Object {
    $row = $_ -split $Delimiter, 0, "SimpleMatch"
    If ($row.Length -gt 1) {
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