<#
 .Synopsis
 Selects only certain fields from the input

 .Inputs
 any/PSObj

 .Outputs
 any/PSObj

 .Example
 .\SelectFields.ps1 '{"a": "foo", "b": 2, "c": 3}' | .\examples\components\SelectFields.ps1 -Fields "a", "b"
 Take JSON string '{a: "foo", b: 2, c: 3}' and return properties/fields "a" and "b" => '{a: "foo", b: 2}'
#>
[OutputType([String])]
param(
    [Parameter(ValueFromPipeline)][Object]$InputObject,
    [String[]]$Fields
)

$input | Select-Object -Property $Fields