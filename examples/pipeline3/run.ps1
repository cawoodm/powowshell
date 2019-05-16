[CmdletBinding(SupportsShouldProcess)]param([string]$Path=".\data\test.log")

function main() {
    $PowStartPath = (Get-Location).Path; Push-Location $PSScriptRoot
    try {

        # Row 1
        $input |
            Import-Csv -Path $Path -Delimiter "," -Header "char", "int", "date", "double", "string" |                   # .\step_A1.ps1 |
            ForEach-Object {[PSCustomObject]@{letter=$_.char; number=[int]$_.int; datetime=[datetime]$_.date}} |        # .\step_B1.ps1 |
            Where-Object {$_.number -lt 5} |                                                                            # .\step_C1.ps1 |
            Sort-Object -Property "datetime" -Descending                                                                # .\step_D1.ps1 |
            Set-Variable -Name OP1





        Get-Date | Out-Null # .\step_A2.ps1 with output suppressed

        Get-Date # .\step_B2.ps1 with output outputted






        Import-Csv -Path ".\data\test2.log" -Delimiter "," -Header "char", "int", "date", "double", "string" |          # .\step_A3.ps1 |
            ForEach-Object {[PSCustomObject]@{letter=$_.char; number=[int]$_.int; datetime=[datetime]$_.date}} |        # .\step_B3.ps1 |
            Split-Pipeline {$_.letter -ge "c"} |                                                                        # .\step_C3.ps1 |
            Set-Variable -Name OP3


        $OP3[0] # Letter >= c

        $OP3[1] # Letter < c

    } catch {

        $Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    } finally {
        Set-Location $PowStartPath
    }
}

<#
 .Synopsis
 Split piped input into two based on a boolean expression
#>
function Split-Pipeline {
    param(
        [object]$ScriptBlock,
        [Parameter(ValueFromPipeline)][Object]$InputObject
    )
    end {
        $ret1=@();$ret2=@();
        $Input | ForEach-Object {
            if ($ScriptBlock.Invoke()) {
                $ret1 += $_
            } else {
                $ret2 += $_
            }
        }
        @($ret1, $ret2)
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
main