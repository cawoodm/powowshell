[OutputType([Array])]
param(
    [String[]]$Fields
)

$data = $input | ConvertFrom-JSON

$data |
    Select-Object -Property $Fields |
    ConvertTo-JSON