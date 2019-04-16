<#
 .Synopsis
 Convert an Integer to the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(ValueFromPipeline)][object]$InputObject
)
process {
    # We -Compress to facilitate unit tests
    if ($InputObject -isnot [array]) {
        ConvertTo-Json -Compress ([PSCustomObject]@{value=$InputObject})
    }
}
end {
    if ($InputObject -is [array]) {
        ConvertTo-Json -Compress $InputObject
    }
}