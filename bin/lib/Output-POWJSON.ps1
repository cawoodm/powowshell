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
  function Out-Json($obj) {
    Write-Verbose "POW:LIB:OP: JSONARRAYOUT"
    # Handle nulls
    if ($null -eq $obj) {
      if ($AsArray) {return '[]'} else {return 'null'}
    }
    Write-Verbose "POW:LIB:OP:111"
    # Don't double wrap an array
    if ($AsArray -and $obj -is [array]) {$AsArray=$false}
    if ($_POW.RUNTIME_VERSION -ge 6) {
      $JSON = $obj | ConvertTo-Json -Compress -AsArray:$AsArray -Depth 10 # -EscapeHandling -EnumsAsStrings
    } else {
      # Older PowerShell Versions
      $JSON = $obj | ConvertTo-Json -Compress -Depth 10
      if ($AsArray) {$JSON="[$JSON]"}
    }
    Write-Verbose "JSON=$JSON"
    
    # Flatten JSON for 1 error per line
    $JSON = $JSON -replace "\r?\n", " "
    return $JSON
  }
  function Out-JsonError($obj) {
    $JSON = Out-Json $obj
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
  Write-Verbose $InputObject.GetType()
  if ($InputObject -is [System.Management.Automation.VerboseRecord]) { 
    Write-Verbose "POW:LIB:OP:Verbose"
    $scriptName = if ($InputObject.InvocationInfo.ScriptName){Split-Path -Path $InputObject.InvocationInfo.ScriptName -Leaf}
    Out-JsonError ([PSCustomObject]@{
      powType          = "V" # Verbose
      scriptName       = $ScriptName
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.InformationRecord]) { 
    Write-Verbose "POW:LIB:OP:Information"
    $scriptName = if ($InputObject.InvocationInfo.ScriptName){Split-Path -Path $InputObject.InvocationInfo.ScriptName -Leaf}
    Out-JsonError ([PSCustomObject]@{
      powType          = "I" # Information
      scriptName       = $ScriptName
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.WarningRecord]) { 
    Write-Verbose "POW:LIB:OP:Warning"
    $scriptName = if ($InputObject.InvocationInfo.ScriptName){Split-Path -Path $InputObject.InvocationInfo.ScriptName -Leaf}
    Out-Json ([PSCustomObject]@{
      powType          = "W" # Warning
      scriptName       = $ScriptName
      scriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
      positionMessage  = $InputObject.InvocationInfo.PositionMessage
      message          = $InputObject.Message
    })
  } elseif ($InputObject -is [System.Management.Automation.ErrorRecord]) { 
    Write-Verbose "POW:LIB:OP:Error"
    $scriptName = if ($InputObject.InvocationInfo.ScriptName){Split-Path -Path $InputObject.InvocationInfo.ScriptName -Leaf}
    Out-Json ([PSCustomObject]@{
      powType          = "E" # Error
      scriptName       = $ScriptName
      scriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
      positionMessage  = $InputObject.InvocationInfo.PositionMessage
      message          = $InputObject.Exception.Message
    })
  } else {
    Write-Verbose "POW:LIB:OP:Output"
    Out-Json $InputObject
  }
}
