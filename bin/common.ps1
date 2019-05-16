<#
 .Synopsis
 Common stuff required by all POW's commands

 .Description
 The following application constants should not be changed unless you really know what you're doing
 All content you change will be overwritten each time you update PowowShell!

#>

$_POW = @{

    # PowowShell's Home Directory in the Users Home
    HOME = "$HOME\.powowshell"

    # PowowShell's temporary directory
    TEMP = "$([IO.Path]::GetTempPath())\powowshell"

    # Encoding of all files we read/write and output we generate
    ENCODING = "utf8"

};

# Calculated values
$_POW.WORKSPACE = "$($_POW.HOME)\workspace.txt"

# Common functions
function Show-Message($msg, $Color="White") {Write-Host $Msg -ForegroundColor $Color}