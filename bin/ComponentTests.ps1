#$DebugPreference_ = $DebugPreference;$DebugPreference = "Continue";
Push-Location $PSScriptRoot;

If (("a|1|M`nb|2|F" | .\components\Data2JSON.ps1 -Delimiter "|" | ConvertFrom-Json)[1].gender -eq "F") {"Data2JSON: OK"} Else {Write-Error "Data2Json: FAIL"}
If (("[{`"a`":`"a`"}]" | .\components\SelectFields.ps1 -Fields a | ConvertFrom-Json).a -eq "a") {"SelectFields: OK"} Else {Write-Error "SelectFields: FAIL"}
If (("a;1`nb;2" | .\components\CSV2JSON.ps1 -Delimiter ";" -Header "name","age" | ConvertFrom-Json)[1].age -eq 2) {"CSV2JSON: OK"} Else {Write-Error "CSV2Json: FAIL"}
If ((.\pipeline1\run.ps1 | ConvertFrom-Json)[1].gender -eq "F") {"Pipeline: OK"} Else {Write-Error "Pipeline: FAIL"}

Pop-Location
#$DebugPreference = $DebugPreference_