#$DebugPreference_ = $DebugPreference;$DebugPreference = "Continue";
Push-Location $PSScriptRoot;

# 1. Inspect each powershell component to view it's input and outputs
DIR .\components\*.ps1 | ForEach-Object {..\bin\inspect.ps1 $_}

# 2. Specific tests of known componets

# 2.1 Check if Data2JSON works
If (("a|1|M`nb|2|F" | .\components\Data2JSON.ps1 -Delimiter "|" | ConvertFrom-Json)[1].gender -eq "F") {"Data2JSON: OK"} Else {Write-Error "Data2Json: FAIL"}

# 2.2 Check if SelectFields works
If (("[{`"a`":`"a`"}]" | .\components\SelectFields.ps1 -Fields a | ConvertFrom-Json).a -eq "a") {"SelectFields: OK"} Else {Write-Error "SelectFields: FAIL"}

# 2.3 Self-testing components
"" | .\components\CSV2JSON.ps1
"" | .\components\JSONMapping.ps1
.\components\ExecuteCmdlet.ps1

If ((.\pipeline1\run.ps1 | ConvertFrom-Json)[1].age -eq "100") {"Pipeline: OK"} Else {Write-Error "Pipeline: FAIL"}

Pop-Location
#$DebugPreference = $DebugPreference_