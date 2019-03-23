<#
 .Synopsis
 Selects only certain fields from the input

 .Inputs
 text/json

 .Outputs
 text/json
#>
[OutputType([String])]
param(
    [String[]]$Fields
)

$data = $input | ConvertFrom-JSON

$data |
    Select-Object -Property $Fields |
    ConvertTo-JSON