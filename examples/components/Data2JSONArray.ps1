<#
 .Synopsis
  Convert stream of objects to JSON array format

 .Description
  Accepts any object or stream of objects and return a JSON string [{object1}, {object2}, ...]

 .Parameter Compress
  Compress JSON output

 .Inputs
  object
  Any PowerShell object or stream of objects

 .Outputs
  text/json
  An JSON array of objects corresponding to the rows of the input data

  .Example
  [PSCustomObject]@{foo="bar1"}, [PSCustomObject]@{foo="bar2"} | Data2JSONArray.ps1 -Compress
  Pass 2 objects in and get JSON out: [{"foo":"bar1"},"foo":"bar2"]

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [Parameter(Mandatory,ValueFromPipeline)]
  [object]$InputObject,
  [switch]$Compress
)
end {
  if ($Input -is [array] -and $Input.length -gt 1) {
    # We have an array, pass to convertto-json as is
    return $Input | ConvertTo-Json -Compress:$Compress
  } else {
    return ConvertTo-Json -InputObject @($Input) -Compress:$Compress
  }
}