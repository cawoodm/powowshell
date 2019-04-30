<#
 .Synopsis
  Convert input object to JSON format

 .Description
  Accepts any object data about and return contents as JSON

 .Parameter Compress
  Compress JSON output

 .Parameter AsArray
  Always return a JSON array

 .Inputs
  object
  Any PowerShell object

 .Outputs
  text/json
  A JSON object corresponding to the input data
  OR
  An array of JSON objects corresponding to the rows of the input data

  .Example
  [PSCustomObject]@{foo="bar"} | Data2JSON.ps1

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [Parameter(Mandatory,ValueFromPipeline)]
  [object]$InputObject,
  [switch]$Compress,
  [switch]$AsArray
)
if ($AsArray -And -not ($InputObject -is [array])) {
    return ConvertTo-Json -Compress:$Compress -InputObject @($InputObject)
} else {
    return ConvertTo-Json -Compress:$Compress -InputObject $InputObject
}