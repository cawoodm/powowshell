<#
 .Synopsis
 AWK processes large amounts of text with power and ease

 .Description
 AWK is a powerful text processing tool which can stream process large volumes of data
 extracting and transforming it with ease

 .Parameter Begin
 The AWK code to be executed in the BEGIN{} block

 .Parameter Process
 The AWK code to be executed in the PROCESS{} block

 .Parameter End
 The AWK code to be executed in the END{} block

 .Parameter Delimiter
 The field separator (FS) variable in AWK specifies how data fields are separated
 The default is a space but you can process CSV files with -Delimiter "," or ";"

 .Inputs
 text/*

 .Outputs
 text/*

 .Example
 TYPE file.txt | .\AWK.ps1 -begin "Attention shoppers:" -process "/e/" -end "That is all!"
 Take Process file.txt and return lines containing an "e"

 .Example
 TYPE file.txt | .\AWK.ps1 -begin "Attention shoppers:" -process "/e/" -end "That is all!"
 Take Process file.txt and return lines containing an "e"
#>
[OutputType([string])]
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(ValueFromPipeline)][string]$InputObject,
  [string]$Begin,
  [string[]]$Process,
  [string]$End,
  [string]$Delimiter
)
function main() {

  try {
    # Our temporary AWK program
    $awkfile = "$([IO.Path]::GetTempPath())/tmp.awk"
    Write-Verbose "`$awkfile: $awkfile"

    # Our AWK program code
    $awkcode = @();

    # AWK Variables
    $vars = @()
    if ($Delimiter) {$vars += "FS=`"$Delimiter`";"}
    $vars = $vars -join "`n"
    Write-Verbose "`$vars: $vars"

    if ($Begin -or $vars) {
      $Begin = $vars + "`n" + $Begin;
      $awkcode += "BEGIN {`n" + $Begin + "`n}`n";
    }
    if ($Process) {
      foreach ($proc in $Process) {
        $awkcode += $proc
      }
    }
    if ($End) {
      $awkcode += "END {`n" + $End + "`n}`n";
    }

    $awkcode = $awkcode -join "`n";

    Write-Verbose "`$awkcode:`n$awkcode"
    $awkcode | Set-Content -Path $awkfile -Encoding Ascii

    # Pipe STDIN to AWK
    if ($PSCmdlet.ShouldProcess("Should AWK be run?")) {
      $InputObject | awk -f $awkfile $args
    }

  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"
main