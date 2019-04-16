<#
 .Synopsis
 Map one form of JSON to another

 .Description
 Used for transforming JSON between two types.
 Limitation: Resulting object is only 1-level deep

 .Parameter InputObject

 .Inputs
 text/json
 The JSON object to be transformed.

 .Outputs
 text/json
 The transformed output JSON object.

 .Example
 '{"Name":"John","Surname":"Doe"}}' | .\JSONMapping.ps1 -Mapping '{"Fullname":".Name +' ' + .Surname"}'
 Convert an object with name+surname to a full name


#>
[CmdLetBinding()]
[OutputType([String])]
param(
    [Parameter(Mandatory,ValueFromPipeline,ParameterSetName = 'Standard')]
    $InputObject,
    [Parameter(Mandatory,ParameterSetName = 'Standard')]
    [string]$Mapping,

    [Parameter(Mandatory,ParameterSetName = 'POW')]
    [string]$POWAction
)
if ($POWAction -eq "test") {
    Push-Location $PSScriptRoot
    if (('{"a":"1","b":{"b1":100}}' | .\JSONMapping.ps1 -Mapping '{"x":".a", "y":".b.b1 + 1"}' | ConvertFrom-Json).y -eq 101) {"JSONMapping: OK"} else {Write-Error "JSONMapping: FAIL"}
    Pop-Location
    return
}
if ($InputObject -is [string]) {$InputObject = $InputObject | ConvertFROM-Json}
$Output = New-Object -TypeName PSObject
$Map = $Mapping | ConvertFrom-JSON
$Map.PSObject.Properties | ForEach-Object {
    $Value = Invoke-Expression "`$InputObject$($_.Value)"
    $Output | Add-Member -MemberType NoteProperty -Name $_.Name $Value
}
$Output | ConvertTo-JSON