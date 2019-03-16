<#
 .Synopsis
 Selects only certain fields from the input

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