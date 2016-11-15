#$DebugPreference_ = $DebugPreference;$DebugPreference = "Continue";
Push-Location $PSScriptRoot;

DIR .\components\*.ps1 | ForEach-Object {..\bin\inspect.ps1 $_}

If (("a|1|M`nb|2|F" | .\components\Data2JSON.ps1 -Delimiter "|" | ConvertFrom-Json)[1].gender -eq "F") {"Data2JSON: OK"} Else {Write-Error "Data2Json: FAIL"}
If (("[{`"a`":`"a`"}]" | .\components\SelectFields.ps1 -Fields a | ConvertFrom-Json).a -eq "a") {"SelectFields: OK"} Else {Write-Error "SelectFields: FAIL"}
"" | .\components\CSV2JSON.ps1
"" | .\components\JSONMapping.ps1

If ((.\pipeline1\run.ps1 | ConvertFrom-Json)[1].age -eq "100") {"Pipeline: OK"} Else {Write-Error "Pipeline: FAIL"}

Pop-Location
#$DebugPreference = $DebugPreference_