<#
 .Synopsis
  Execute any PowerShell Cmdlet

 .Description
  Generic component which allows you to map up to 10 parameters to any cmdlet you like

 .Parameter ExecuteTemplate
  The command to be executed

 .Parameter Depth
  The depth of the JSON output to be returned
  
 .Parameter p0
 The first parameter passed in. Can be used in ExecuteTemplate as {0}
  
 .Parameter p1
 The second parameter passed in. Can be used in ExecuteTemplate as {1}
  
 .Inputs
 text

 .Outputs
 any
 
 .Example
 .\ExecuteCmdlet.ps1 -ExecuteTemplate "Get-ChildItem {0} {1}" -p0 "C:\temp" -p1 "*.txt"

#>
[CmdletBinding(DefaultParameterSetName="Std")] 
[OutputType([String])]
param(
  [Parameter(Mandatory)]
    [String]$ExecuteTemplate,
    [Int32]$Depth=2,
    [String]$p0,
    [String]$p1,
    [String]$p2
)
Write-Verbose ("ExecuteTemplate=" + $ExecuteTemplate)
$command = $ExecuteTemplate -f $p0, $p1, $p2
Invoke-Expression -Command $command #| ConvertTo-Json -Depth $Depth