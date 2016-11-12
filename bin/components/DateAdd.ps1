<#
    .Synopsis
    Add some days to today's date and return the date

    .Parameter days
    The number of days (integer) to add (or subtract) to todays date

    .Outputs
    System.DateTime
#>
param(
    [int]$days=0
)
Write-Output (Get-Date).AddDays($days).toString('yyyy-MM-dd')
#Write-Output (Get-Date).AddDays($days) | ConvertTo-JSON