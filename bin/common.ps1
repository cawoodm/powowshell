<#
 .Synopsis
 Common stuff required by all POW's commands

 .Description
 The following application constants should not be changed unless you really know what you're doing
 All content you change will be overwritten each time you update PowowShell!

#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$_POW = @{

    # PowerShell Runtime (e.g. PS5 or PS6)
    RUNTIME = "PS" + $PSVersionTable.PSVersion.ToString().Substring(0, 1)

    # PowowShell's Home Directory in the Users Home
    HOME = "$HOME/.powowshell"

    # PowowShell's temporary directory
    TEMP = "$([IO.Path]::GetTempPath())/powowshell"

    # Encoding of all files we read/write and output we generate
    ENCODING = "utf8"

};

# Calculated values
$_POW.WORKSPACE = "$($_POW.HOME)/workspace.txt"

# Encoding of all files we read/write and output we generate
$_POW.CACHE = (Resolve-Path "$PSScriptRoot/../cache")

# Cache per runtime version (PS5, PS6 etc)
$_POW.CACHER = "$($_POW.CACHE)/$($_POW.RUNTIME)"

# Configure powershell output encoding
$PSDefaultParameterValues['Out-File:Encoding'] = $_POW.ENCODING

# Common functions
function Show-Message($msg, $Color="White") {Write-Host $Msg -ForegroundColor $Color}