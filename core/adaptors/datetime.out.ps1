<#
 .Synopsis
 Convert a DateTime to the common object model (JSON)
 E.g. {"Date": "2019-04-15T00:00:00+02:00"}
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory,ValueFromPipeline)][datetime]$InputObject
)
process {
    # Support piped ($_) and parameter input ($InputObject)
    if ($_) {$IN=$_}else{$IN=$InputObject}
    $Val = Get-Date $IN -Format O
    # We -Compress to facilitate unit tests
    ConvertTo-Json -Compress ([PSCustomObject]@{Date=$Val})
    #PS6: $Source | Select-Object -Property Date | ConvertTo-Json -Compress
}