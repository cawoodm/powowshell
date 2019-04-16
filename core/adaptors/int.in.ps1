<#
 .Synopsis
 Convert an integer from the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([int])]
param(
    [Parameter(ValueFromPipeline)][string]$InputObject
)
process {
    # {value:12} => 12
    return [int]($InputObject | ConvertFrom-Json).value
}