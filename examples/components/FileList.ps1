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
  
 .Parameter Recurse
  If $true, will search all sub-folders
  
 .Example
 .\FileList.ps1 -Path C:\windows -Filter *.exe
  
 .Inputs
 none
 
 .Outputs
 PSObj
 {name,fullName,size(int)}

#>
[CmdletBinding(DefaultParameterSetName="Std")]
[OutputType([string])]
param(
  [string]$Path,
  [string]$Filter,
  [switch]$Recurse
)
function main() {
  $files = @()
  write-verbose "Get-ChildItem -Path $Path -File -Filter $Filter -Recurse:$Recurse"
  Get-ChildItem -Path $Path -File -Filter $Filter -Recurse:$Recurse|
    ForEach-Object {
    $f = $null
    $len = 0
    if ($_.PSobject.Properties.Name -match "Length") {$len = $_.Length}
    $f = @{
      name=$_.Name
      fullName=$_.FullName
      size=$len
    }
    if ($f) {$files += New-Object -TypeName PSObject -Property $f}
  }
  $files
}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
main