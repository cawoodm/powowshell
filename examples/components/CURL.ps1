<#
 .Synopsis
 CURL is a wrapper for Invoke-WebRequest to GET data from the web via HTTP

 .Description
 CURL offers only basic GET functionality with headers

 .Parameter Url
 The Url/Uri to be fetched

 .Parameter Method
 The HTTP method to be used (e.g. GET or POST)

 .Parameter Headers
 Hashmap of headers to add

 .Parameter ContentType
 For PUT/POST methods the Content-Type request header e.g. application/json

 .Inputs
 text/*
 Text piped in will be passed as the Body of the PUT/POST request

 .Outputs
 text/*
 Text output is the HTTP Response Body

 .Example
 .\CURL.ps1 "http://www.test.com"
 Get www.test.com

#>
[OutputType([string])]
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Url,
    [ValidateSet("GET", "POST")]
    [string]$Method="GET"
)
function main() {

    
    try {
        Write-Verbose "CURL: $($MyInvocation.BoundParameters -join ' ' )"

        $res = Invoke-WebRequest -Method $Method -Uri $Url

        return $res.Content

    } catch {
        #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
        throw $_
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"
main