<#
 .Synopsis
 Search documents in ElasticSearch

 .Description
 List of documents according to a flexible lucene search pattern

 .Parameter Url
 The ElasticSearch Server Urls (e.g. http://localhost:9200)

 .Parameter Username
 Optional Username for Basic Authentication

 .Parameter Password
 Optional Password for Basic Authentication

 .Parameter Query
 LucenesSearch string like 'moby AND dick AND type: book'

 .Parameter PageSize
 Page size for paging results (e.g. 10)

 .Parameter Page
 Page number for paging results (e.g. 1)

 .Parameter Fields
 Array of field names to return, else entire _source object is returned

 .Inputs
 none

 .Outputs
 PSObj
 {_id,_source(object)}

 .Example
 .\ESDocSearch.ps1 -Query "foo: bar"
 Get all documents with field foo = 'bar'

#>
[OutputType([object])]
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$Url = "http://localhost:9200",
  [string]$Username,
  [string]$Password,
  [string]$Index,
  [string]$Query,
  [int]$PageSize = 25,
  [int]$Page = 1,
  [string[]]$Fields
)
function main() {

  if (-not $Url) {throw "Parameter -Url not supplied!"}
  if (-not $Index) {throw "Parameter -Index not supplied!"}

  if (-not $Page){$Page = 1}
  if (-not $PageSize){$PageSize = 25}

  try {

    $Headers = @{}
    if ($Username -and $Password) {
      $Creds = "$($Username):$Password"
      $Creds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Creds))
      $Headers.add("Authorization", "Basic " + $Creds)
    }

    $Query = [System.Web.HTTPUtility]::UrlEncode($Query)

    $From = "&from=$(($Page-1)*$PageSize)"
    $Size = "&size=$PageSize"

    $Uri = $Url + "/$Index/_search?q=$Query$From&$Size"
    $res = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method Get

    $res.hits.hits | ForEach-Object {
      if ($Fields) {
        $_._source | Select-Object $Fields
      } else {
        $_._source
      }
    }

  } catch {
    #$Host.UI.WriteErrorLine("ERROR in $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)")
    throw $_
  }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ErrorActionPreference = "Stop"
main