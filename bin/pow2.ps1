[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][String[]]
  $Command,
  $p1,$p2,$p3,
  [switch]$Export
)
#########################################
function Invoke-PowowShell {
  [CmdletBinding(SupportsShouldProcess)]
  [Alias('pow')]
  param(
    [Parameter(Mandatory = $true)][String[]]
    [ValidateSet("install", "version", "help", "workspace", "clean", "build", "verify", "run", "inspect", "components", "cmdlets", "pipeline", "preview", "examples", "adaptors", "script")]
    $Command,
    $p1, $p2, $p3,
    [switch]$Export
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

    # Resolve ! paths with the workspace
    #  Doing this: (Resolve-Path ./examples).path > ./workspace.txt
    #  Lets you do this: pow inspect mycomponent
    #  instead of: pow inspect ./examples/components/mycomponent.ps1
    if (Test-Path $_POW.WORKSPACE) { $Workspace = Get-Content "$($_POW.HOME)/workspace.txt"; Write-Verbose "WORKSPACE: $Workspace" } else { $Workspace = (Resolve-Path "../").Path }
    if ($p1 -is [string] -and $p1 -like "!*") {
      if ($Command -in "inspect", "components", "preview", "examples") {
        $p1 = $p1.replace("!", "$Workspace/components/"); $p1 += ".ps1"
      }
      elseif ($command -eq "adaptors") {
        # Adaptors are in /core/adaptors
        $p1 = $p1.replace("!", "../core/adaptors");
        $p1 = Resolve-Path $p1
      }
      elseif ($command -eq "workspace") {
        # e.g. "!examples" should be relative to the root of the app
        $p1 = $p1.replace("!", "../");
        $p1 = Resolve-Path $p1
      }
      else {
        # !pipeline1 => $Workspace/pipeline1/
        $p1 = $p1.replace("!", "$Workspace/");
      }
    }
    # Get back to the location of the caller
    Pop-Location
    ForEach ($Cmd in $Command) {
      $result = try {
        Write-Verbose "`"$BinPath/$Cmd.ps1`" $p1 $p2 $p3"
        if ($p3) { & "$BinPath/$Cmd.ps1" $p1 $p2 $p3 }
        elseif ($p2) { & "$BinPath/$Cmd.ps1" $p1 $p2 }
        elseif ($p1) { & "$BinPath/$Cmd.ps1" $p1 }
        else { & "$BinPath/$Cmd.ps1" }
      } catch {
        #Write-Error "Error in '$cmd' command:" + $_
        throw $_
      }
    }
    if ($Export) {# -and $result -isnot [string]) {
      Write-Verbose "POW: JSONOUT"
      return ConvertTo-Json $result -Compress
    }
    Write-Verbose "POW: STDOUT"
    return $result
  }
  catch {
    $erresult = @{
      scriptName       = (Split-Path -Path $_.InvocationInfo.ScriptName -Leaf)
      scriptLineNumber = $_.InvocationInfo.ScriptLineNumber
      message          = $_.Exception.Message
      stack            = $PSItem.ScriptStackTrace
    }
    if ($Options -contains "export") {
      $Host.UI.WriteErrorLine(($erresult | ConvertTo-Json))
    }
    else {
      $Host.UI.WriteErrorLine("ERR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    }
  }
  finally {
    Set-Location $StartPath
  }

}
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
#$ErrorActionPreference = "Stop"
#########################################
Invoke-PowowShell -Command $Command -p1 $p1 -p2 $p2 -p3 $p3