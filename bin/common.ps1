<#
 .Synopsis
 Common stuff required by all POW's commands

 .Description
 The following application constants should not be changed unless you really know what you're doing
 All content you change will be overwritten each time you update PowowShell!

#>

$_POW = @{

  # PowerShell Runtime (e.g. PS5 or PS6)
  RUNTIME         = "PS" + $PSVersionTable.PSVersion.ToString().Substring(0, 1)
  RUNTIME_VERSION = [int]$PSVersionTable.PSVersion.ToString().Substring(0, 1)

  # PowowShell's Home Directory in the Users Home
  HOME            = "$HOME/.powowshell"

  # PowowShell's temporary directory
  TEMP            = "$([IO.Path]::GetTempPath())/powowshell"

  # Encoding of all files we read/write and output we generate
  ENCODING        = "utf8"

};

# Calculated values
$_POW.WORKSPACE = "$($_POW.HOME)/workspace.txt"

# Encoding of all files we read/write and output we generate
$_POW.CACHE = "$($_POW.HOME)/cache"

# Cache per runtime version (PS5, PS6 etc)
$_POW.CACHER = "$($_POW.CACHE)/$($_POW.RUNTIME)"

# Configure powershell output encoding
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING

# Common functions
function Show-Message($msg, $Color = "White") {Write-Host $Msg -ForegroundColor $Color}
function Show-Error($errmsg) {$host.UI.WriteErrorLine($errmsg)}
#function Show-Error($errmsg) {[Console]::Error.WriteLine($errmsg)}
function ResolveWorkspace($Command, $Path) {
  Write-Verbose "WKSPC: cmd=$Command path=$Path"
  # Resolve ! paths with the workspace
  #  Doing this: (Resolve-Path ./examples).path > ./workspace.txt
  #  Lets you do this: pow inspect mycomponent
  #  instead of: pow inspect ./examples/components/mycomponent.ps1
  if (Test-Path $_POW.WORKSPACE) {
    $Workspace = Get-Content "$($_POW.HOME)/workspace.txt"; Write-Verbose "WORKSPACE: $Workspace"
  } else {
    $Workspace = (Resolve-Path "../").Path
  }
  if ($Command -in "inspect", "components", "examples") {
    $Path1 = $Path.replace("!", "$Workspace/components/");
    if ($Command -ne "components" -and $Path1 -notlike '*.ps1') {$Path1 += ".ps1"}
  } elseif ($Command -eq "adaptors") {
    # Adaptors are in /core/adaptors
    $Path1 = $Path.replace("!", "../core/adaptors");
  } elseif ($Command -eq "workspace") {
    # e.g. "!examples" should be relative to the root of the app
    $Path1 = $Path.replace("!", "../");
  } else {
    # !pipeline1 => $Workspace/pipeline1/
    $Path1 = $Path.replace("!", "$Workspace/");
  }
  Write-Verbose "To: $Path1"
  if (-not (Test-Path $Path1)) {throw "Reference '$Path' not found at path '$Path1'!"}
  return (Resolve-Path $Path1).Path
}
function Out-Json($obj, [switch]$AsArray) {
  Write-Verbose "POW:LIB:OP: JSONARRAYOUT:$AsArray"
  # Handle nulls
  if ($null -eq $obj) {
    if ($AsArray) {return '[]'} else {return 'null'}
  }
  # Don't double wrap an array
  if ($AsArray -and $obj -is [array]) {$AsArray = $false}
  Write-Verbose "POW:LIB:OP: JSONARRAYOUT:$AsArray"
  if ($_POW.RUNTIME_VERSION -ge 6) {
    $JSON = $obj | ConvertTo-Json -Compress -AsArray:$AsArray -Depth 10 # -EscapeHandling -EnumsAsStrings
  } else {
    # Older PowerShell Versions
    $JSON = $obj | ConvertTo-Json -Compress -Depth 10
    if ($AsArray) {$JSON = "[$JSON]"}
  }
  Write-Verbose "JSON=$JSON"

  # Flatten JSON for 1 error per line
  $JSON = $JSON -replace "\r?\n", " "
  return $JSON
}
