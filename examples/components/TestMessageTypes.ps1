<#
 .Synopsis
  Test component for handling different message types

 .Description
  Will output warnings and errors for testing error handling.

 .Parameter CreateErrorOutput
  Write on the error stream

 .Parameter CreateWarningOutput
  Write on the warning stream

 .Outputs
 text/plain

 .Example
 TestMessageTypes.ps1 -CreateErrorOutput -CreateWarningOutput
 Produce some standard, error and warning output messages

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [switch]$CreateErrorOutput,
  [switch]$CreateWarningOutput,
  [switch]$ThrowException
)
process {
  Write-Output "OUT1: This is standard output 1"
  if ($CreateErrorOutput) { Write-Error "ERROR1: This is error output 1" }
  if ($CreateWarningOutput) { Write-Warning "WARNING1: This is warning output 1" }
  if ($ThrowException) { throw "This is an exception!" }
  Write-Output "STDOUT2: This is standard output 2"
  if ($CreateErrorOutput) { Write-Error "ERROR2: This is error output 2" }
  if ($CreateWarningOutput) { Write-Warning "WARNING2: This is warning output 2" }
}