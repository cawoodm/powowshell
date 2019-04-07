<#
    .Synopsis
    Add some days to today's date and return the date
    
    .Description
    foo bar

    .Parameter days
    The number of days (integer) to add (or subtract) to todays date
    
    .Outputs
    date

#>
[OutputType([DateTime])]
param(
    [int]$days=0
)
Write-Output (Get-Date).AddDays($days).toString('yyyy-MM-dd')