<# 
 .Synopsis
  Returns a list of files.

 .Description
  Lists files with a specific filter (e.g. *.txt) or
  within a specified date range.

 .Parameter Path
  Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.).

 .Parameter Filter
  The wildcard for matching files (e.g. *.csv)
	
 .Inputs
 none
 
 .Outputs
 json[]

#>
[OutputType([String])]
param(
		[Parameter(Mandatory=$true,HelpMessage="The path to the files")][string]$Path,
		[string]$Filter
)
function main() { 
	$files = @()
	Get-ChildItem -Path $Path -Filter $Filter -Recurse:$Recurse |
	  ForEach-Object {
		$f = @{
			name=$_.Name
			fullName=$_.FullName
			size=$_.Length
		}
		$files += New-Object -TypeName PSObject -Property $f
	}
	$files | ConvertTo-JSON
}
main