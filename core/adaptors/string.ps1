<#
 .Synopsis
 Convert a string to the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory, ValueFromPipeline)][String]$InputObject
)
function Convert-StringToJson {
    [PSCustomObject]@{
        value=$InputObject
    } | ConvertTo-Json
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Convert-StringToJson