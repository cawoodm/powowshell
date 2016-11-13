<#
 .Synopsis
  Convert CSV data to JSON format

 .Description
  Accepts tabular CSV data and return contents as a JSON Array

 .Parameter FieldSeparator
  Specifies the field separator. Default is a comma ",")

 .Outputs
 String

#>
[OutputType([String])]
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,
    [String]$Delimiter=",",
    [String[]]$Header
)

$params = @{}
$MyInvocation.BoundParameters.Keys | Where {$_ -and $_ -ne "InputObject"} | % {$params.Add($_, (Get-Variable $_).Value )}
Write-Debug $params

$InputObject | ConvertFrom-Csv @params | ConvertTo-JSON