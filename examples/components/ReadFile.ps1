<#
 .Synopsis
  Read text from a file

 .Description
  Read a single text file and return contents as a string.

 .Parameter Path
  Specifies full literal (no wildcards) path to the file to be read.
  
 .inputs
 none
 
 .outputs
 text

#>
[OutputType([String])]
param(
    [Parameter(Mandatory)][String]$Path
)

# The Magic Happens Here...
Write-Verbose "ReadFile.ps1 $Path"
Get-Content -Raw -LiteralPath $Path