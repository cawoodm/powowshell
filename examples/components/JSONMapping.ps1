<#
 .Synopsis
 Map one form of JSON to another

 .Description
 Used for transforming JSON between two types.
 Limitation: Resulting object is only 1-level deep

 .Parameter InputObject

 .Inputs
 object(*)

 .Outputs
 object(*)

#>
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$InputObject,
    [string]$Mapping
)
If ($InputObject -eq "") {
    Push-Location $PSScriptRoot
    If (('{"a":"1","b":{"b1":100}}' | .\JSONMapping.ps1 -Mapping '{"x":".a", "y":".b.b1 + 1"}' | ConvertFrom-Json).y -eq 101) {"JSONMapping: OK"} Else {Write-Error "JSONMapping: FAIL"}
    Pop-Location
    return
}
If ($InputObject -is [string]) {$InputObject = $InputObject | ConvertFROM-Json}
$Output = New-Object -TypeName PSObject
$Map = $Mapping | ConvertFrom-JSON
$Map.PSObject.Properties | ForEach-Object {
    $Value = Invoke-Expression "`$InputObject$($_.Value)"
    $Output | Add-Member -MemberType NoteProperty -Name $_.Name $Value
}
$Output | ConvertTo-JSON