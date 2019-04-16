<#
 .Synopsis
 Convert a string from the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(ValueFromPipeline)][String]$InputObject
)
process {
    # {value:"foo"} => "foo"
    ($_ | ConvertFrom-Json).value
}