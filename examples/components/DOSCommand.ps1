<#
 .Synopsis
 Run any command with DOS CMD

 .Parameter Command
 The command string to be executed
    
 .Inputs
 none

 .Outputs
 text
    
#>
[CmdletBinding()]
[OutputType([String])]
param(
    [String]$Command
)
CMD /C $Command