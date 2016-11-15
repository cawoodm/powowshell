Clear
Remove-Item tmp_*.txt

# Get our context by including all globals
. .\globals.ps1

# Run component A (Source)
..\components\ReadFile.ps1     -Path ".\data\names2.txt" |
..\components\Data2JSON.ps1    -FieldSeparator "|" |
..\components\SelectFields.ps1 -Fields "name", "age", "gender"