<#
 .Synopsis
 Most basicest component
#>
[CmdletBinding()]param()
$a = [PSCustomObject]@{
  foo = "bär"
}
echo "bär"