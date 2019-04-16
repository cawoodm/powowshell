<#
 .Synopsis
 Convert an object from the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([system.object])]
param(
    [Parameter(ValueFromPipeline)][string]$InputObject
)
process {
    ConvertFrom-Json $InputObject
}