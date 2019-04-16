<#
 .Synopsis
 Convert an object to the common object model (JSON)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(ValueFromPipeline)][object]$InputObject
)
process {
    # We -Compress to facilitate unit tests
    Write-Verbose "`t`t`tAdaptor system.object.out.ps1 process: InputObject=$InputObject"
    $InputObject | ConvertTo-Json -Depth 10 -Compress
}
end {
    # For empty arrays, process{} is not called
    if ($null -eq $InputObject) {"[]"}
}