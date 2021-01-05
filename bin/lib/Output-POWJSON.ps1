<#
 .Synopsis
 Capture all output streams and serialize to POWJSON Format

 .Description
 For each object on the stream output one JSON object per line
 The special streams (Error, Warning, Verbose, Info) will be wrapped as POWMessages
 The standard output stream will be serialized as is

 .Parameter internal
 Set this switch when calling from inside powershell to display error output in red
 Otherwise errors

 .Parameter AsArray
 Will force array output by wrapping single objects in '[...]'
#>
[CmdletBinding()]
[OutputType([string])]
param (
  [Parameter(ValueFromPipeline)] $InputObject,
  [switch]$internal,
  [switch]$AsArray
)
begin {

  Push-Location $PSScriptRoot
  . ../common.ps1
  Pop-Location

  function Out-JsonError($obj) {
    Out-Json $obj -AsArray:$AsArray
    # We can't write to stderr until node-powershell supports it
    return
    $JSON = Out-Json $obj -AsArray:$AsArray
    if ($internal) {
      # WriteErrorLine is red but not on stream 2 inside powershell
      $Host.UI.WriteErrorLine($JSON)
      # WriteLine is not on stream 2 inside powershell (equivalent to Write-Host)
      #[Console]::Error.WriteLine($JSON)
    } else {
      # Write to stderr of the pwsh process
      [Console]::Error.WriteLine($JSON)
    }
  }
}
process {
  if ($null -eq $InputObject) {return}
  Write-Verbose "POW:LIB:OP:InputObject is [$($InputObject.GetType())]"
  $scriptName = if ($InputObject.InvocationInfo.ScriptName){Split-Path -Path $InputObject.InvocationInfo.ScriptName -Leaf}
  if ($InputObject -is [System.Management.Automation.VerboseRecord]) {
    Write-Verbose "POW:LIB:OP:Verbose"
    Out-Json ([PSCustomObject]@{
      powType          = "V" # Verbose
      scriptName       = $ScriptName
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.InformationRecord]) {
    Write-Verbose "POW:LIB:OP:Information"
    Out-Json ([PSCustomObject]@{
      powType          = "I" # Information
      scriptName       = $ScriptName
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.WarningRecord]) {
    Write-Verbose "POW:LIB:OP:Warning"
    Out-Json ([PSCustomObject]@{
      powType          = "W" # Warning
      scriptName       = $ScriptName
      scriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
      positionMessage  = $InputObject.InvocationInfo.PositionMessage
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.ErrorRecord]) {
    Write-Verbose "POW:LIB:OP:Error"
    Out-Json ([PSCustomObject]@{
      powType          = "E" # Error
      scriptName       = $ScriptName
      scriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
      positionMessage  = $InputObject.InvocationInfo.PositionMessage
      message          = $InputObject.Exception.Message
    })
  } else {
    Write-Verbose "POW:LIB:OP:Output"
    Out-Json $InputObject -AsArray:$AsArray
  }
}
