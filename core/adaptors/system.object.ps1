<#
 .Synopsis
 Convert an object to the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory)][Object]$Source
)
function Convert-ObjectToJson {
    # We don't pipe to produce predictable results with arrays
    # We -Compress to facilitate unit tests
    ConvertTo-Json -Depth 10 -Compress -InputObject $Source
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Convert-ObjectToJson