param(
    [String[]]$Fields
)

$data = $input | ConvertFrom-JSON
Write-Debug ($data | ConvertTo-JSON)
$data |
    Select-Object -Property $Fields |
    ConvertTo-JSON