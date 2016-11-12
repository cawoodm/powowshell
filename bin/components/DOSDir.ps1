<#
    .Synopsis
    List files with DOS CMD

    .Parameter Path
    The path to the directory to be listed
#>
param(
    [String]$Path
)
CMD /C "DIR /B $Path"