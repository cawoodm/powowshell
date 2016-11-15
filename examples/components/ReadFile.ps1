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
    [Parameter(Mandatory=$true)][String]$Path
)

# The Magic Happens Here...
Get-Content -Raw -LiteralPath $Path