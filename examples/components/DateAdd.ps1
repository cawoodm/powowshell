<#
    .Synopsis
    Add a field to each object in an array

    .Parameter Name
    Name of the field to add
		
		.Parameter Value
		Value of the field to add

#>
[OutputType([Object])]
param(
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,
	[Parameter(Mandatory=$true)][string]$Name,
	[Parameter(Mandatory=$true)][string]$Value
)
$obj = $InputObject | ConvertFrom-JSON
$obj | % {
	Add-Member -InputObject $_ -NotePropertyName $Name -NotePropertyValue $Value
}
$obj | ConvertTo-Json