<#
 .Synopsis
 List of Indices in an ElasticSearch Server

 .Description
 Provides a filtered list of indices in an ElasticSearch instance

 .Parameter Url
 The ElasticSearch Server Urls (e.g. http://localhost:9200)

 .Parameter Username
 Optional Username for Basic Authentication

 .Parameter Password
 Optional Password for Basic Authentication

 .Parameter Filter
 Optional wildcard filter for limiting index names (e.g. myindex-*)

 .Inputs
 none

 .Outputs
 PSObj
 {name,fullName,size(int)}

 .Example
 .\ESIndexList.ps1 -Filter .kibana*
 Get Kibana Indices on Localhost without authentication

#>
[OutputType([object])]
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$Url = "http://localhost:9200",
  [string]$Username,
  [string]$Password,
  [string]$Filter
)
function main() {
  
  if (-not $Url) {throw "Parameter $Url not supplied!"}
    
  try {

    $Headers = @{}
    if ($Username -and $Password) {
      $Creds = "$($Username):$Password"
      $Creds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Creds))
      $Headers.add("Authorization", "Basic " + $Creds)
    }

    $Uri = $Url + '/_cat/indices?format=json'
    $res = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get

    if ($Filter) {
      Write-Verbose "Filtering indices by name '$Filter'..."
      $res = $res | Where-Object {$_.index -like $Filter}
    }

    return $res

  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"
main