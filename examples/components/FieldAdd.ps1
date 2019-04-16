<#
    .Synopsis
    Add a field to each object in an array

    .Parameter Name
    Name of the field to add
		
		.Parameter Value
		Value of the field to add

#>
[OutputType([string])]
param(
	[Parameter(Mandatory,ValueFromPipeline)][String]$InputObject,
	[Parameter(Mandatory)][string]$Name,
	[Parameter(Mandatory)][string]$Value
)
$obj = $InputObject | ConvertFrom-JSON
$obj | % {
	Add-Member -InputObject $_ -NotePropertyName $Name -NotePropertyValue $Value
}
$obj | ConvertTo-Json