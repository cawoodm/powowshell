<#
 .Synopsis
 Selects only certain fields from the input

 .Inputs
 psobject/any

 .Outputs
 psobject/any

 .Example
 ConvertFrom-Json '{"a": "foo", "b": 2, "c": 3}' | .\SelectFields.ps1 -Fields "a", "b"
 Take an object '{a: "foo", b: 2, c: 3}' and return properties/fields "a" and "b" => '{a: "foo", b: 2}'
#>
[OutputType([Object])]
param(
  [Parameter(ValueFromPipeline)][Object]$InputObject,
  [String[]]$Fields
)

$input | Select-Object -Property $Fields