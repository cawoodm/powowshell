<#
 .Synopsis
 Convert a string to the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(ValueFromPipeline)][String]$InputObject
)
process {
    # Support piped ($_) and parameter input ($InputObject) as well as $null passed
    if ($InputObject.length -eq 0) {$IN=$null}else{if ($_) {$IN=$_}else{$IN=$InputObject}}
    # We -Compress to facilitate unit tests
    ([PSCustomObject]@{value=$_}) | ConvertTo-Json -Compress
}