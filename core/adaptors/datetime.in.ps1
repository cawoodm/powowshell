<#
 .Synopsis
 Convert an integer from the common object model (JSON)
 {"Date": "2019-04-15T00:00:00+02:00"} => 2019-04-15T00:00:00
#>
[CmdletBinding()]
[OutputType([datetime])]
param(
    [Parameter(Mandatory,ValueFromPipeline)][string]$InputObject
)
process {
    # Support piped ($_) and parameter input ($InputObject)
    if ($_) {$IN=$_}else{$IN=$InputObject}
    $Val = $IN | ConvertFrom-Json
    Get-Date $Val.Date
}