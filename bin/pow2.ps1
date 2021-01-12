[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][String[]]
  $Command,
  $p1, $p2, $p3,
  [switch]$Export,
  [switch]$AsArray
)
#########################################
function Invoke-PowowShell {
  [CmdletBinding(SupportsShouldProcess)]
  [Alias('pow')]
  param(
    [Parameter(Mandatory = $true)][String[]]
    [ValidateSet("install", "version", "help", "workspace", "clean", "build", "verify", "run", "inspect", "components", "cmdlets", "pipeline", "preview", "examples", "adaptors", "script", "exec")]
    $Command,
    $p1, $p2, $p3,
    [switch]$Export,
    [switch]$AsArray
  )

  # Save path we are started from
  $StartPath = (Get-Location).Path

  $Options = $p1, $p2, $p3

  try {

    # Start in the bin/ path
    $BinPath = $PSScriptRoot

    # For ease of development we keep all our commands in our program directory's bin/ path
    #  and not in the powershell modules folder
    #  Our modules folder contains a path.txt which points back to this bin/ path
    # If we are installed as a module, our bin/ path is stored in path.txt
    if (Test-Path "$BinPath/path.txt") { $BinPath = Get-Content "$BinPath/path.txt" }
    Push-Location $BinPath

    # Include common settings/functions
    . "./common.ps1"

    if ($p1 -is [string] -and $p1 -like "!*") {
      $p1 = ResolveWorkspace $Command $p1
    }
    # Get back to the location of the caller
    Pop-Location
    ForEach ($Cmd in $Command) {
      try {
        $exec = "& `"$BinPath/$Cmd.ps1`" `$p1 `$p2 `$p3"
        Write-Verbose "POW:EXEC1: & `"$BinPath/$Cmd.ps1`" $p1 $p2 $p3"
        Write-Verbose "POW:EXEC1: & `"$BinPath/$Cmd.ps1`" $p1 $p2 $p3"
        if ($p3) {  } elseif ($p2) { $exec = $exec -replace "\`$p3", "" } elseif ($p1) { $exec = $exec -replace "\`$p2 \`$p3", "" } else { $exec = $exec -replace "\`$p1 \`$p2 \`$p3", "" }
        if ($Export) {$exec += " *>&1 | & $BinPath/lib/Output-POWJSON.ps1 -AsArray:`$AsArray"}
        $execstr = $exec
        $execstr = $execstr -replace "\`$p1", ($p1 | convertto-json -Compress)
        $execstr = $execstr -replace "\`$p2", ($p2 | convertto-json -Compress)
        $execstr = $execstr -replace "\`$p3", ($p3 | convertto-json -Compress)
        Write-Verbose "POW:EXEC: $execstr"
        Invoke-Expression -Command $exec
        return
      } catch {
        throw $_
      }
    }
  } catch {
    $scriptName = if ($_.InvocationInfo.ScriptName) {(Split-Path -Path $_.InvocationInfo.ScriptName -Leaf)} else{$null}
    $erresult = @{
      powType          = "X" # Exception
      scriptName       = $scriptName
      scriptLineNumber = $_.InvocationInfo.ScriptLineNumber
      message          = $_.Exception.Message
      stack            = $PSItem.ScriptStackTrace
    }
    if ($Export -or $Options -contains "export") {
      # We can't write to stderr until node-powershell supports it
      #$Host.UI.WriteErrorLine(($erresult | ConvertTo-Json -Compress -Depth 2))
      $erresult | ConvertTo-Json -Compress -Depth 2
    } else {
      $Host.UI.WriteErrorLine("ABORT in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    }
  } finally {
    Set-Location $StartPath
  }

  if ($PSCmdlet.ShouldProcess("Target", "Operation")){}

}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
#########################################
Invoke-PowowShell -Command $Command -p1 $p1 -p2 $p2 -p3 $p3 -Export:$Export -AsArray:$AsArray