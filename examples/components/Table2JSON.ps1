<#
 .Synopsis
  Convert tabular input data to JSON format

 .Description
  Accepts custom tabular data about people and return contents as a JSON Array
	The data must be in the format:
	NAME|AGE|GENDER
	However, the record and field separator can be anything.

 .Parameter Delimiter
  Specifies the field separator. Default is a comma ",")

 .Parameter RecordSeparator
  Specifies the record separator. Default is a newline.

 .Inputs
  text/xsv
  Any separated data (e.g. CSV) with newlines between records

 .Outputs
  text/json
  An array of JSON objects corresponding to the rows of the input data

  .Example
  Table2JSON.ps1 -Delimiter ";"

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [Parameter(Mandatory,ValueFromPipeline)]
  [String]$InputObject,
  [String]$Delimiter=",",
  [String]$RecordSeparator
)

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