<#
 .Synopsis
 Wrap awk.exe

 .Inputs
 text/*

 .Outputs
 text/*

 .Example
 TYPE file.txt | .\AWK.ps1 -begin "Attention shoppers:" -process "/e/" -end "That is all!"
 Take Process file.txt and return lines containing an "e"
#>
[OutputType([String])]
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline)][string]$InputObject,
    [string[]]$process,
    [string]$begin,
    [string]$end
)
function main() {

    
    try {
        # Our temporary AWK program
        $awkfile = "$env:TEMP\tmp.awk"
        Write-Verbose "`$awkfile: $awkfile"

        # Our AWK program code
        $awkcode = @();

        if ($begin) {
            $awkcode += "BEGIN {`n" + $begin + "`n}`n";
        }
        if ($process) {
            foreach ($proc in $process) {
                $awkcode += $proc
            }
        }
        if ($end) {
            $awkcode += "END {`n" + $end + "`n}`n";
        }

        $awkcode = $awkcode -join "`n";

        Write-Verbose "`$awkcode:`n$awkcode"
        $awkcode | Set-Content -Path $awkfile -Encoding Ascii

        # Pipe STDIN to AWK
        $InputObject | AWK -f $awkfile

    } catch {
        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        #throw $_
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main