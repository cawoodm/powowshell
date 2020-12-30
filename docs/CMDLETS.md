#CmdLets

Ideally, we support any installed command, alias or function in the powershell environment.

## Fundamental Blocks
Blocks that do basic operations on *any* data stream:
* ForEach-Object: A FOR Loop
* Compare-Object: Like a SQL JOIN or a DIFF command
* Select-Object -Property: Like SQL SELECT <top N> <fields>
* Where-Object: A Filter like SQL WHERE
* Measure-Object: Like SQL COUNT, SUM, AVERAGE...
** Need to bracket input `(some stream) | Measure` to get correct results
* Sort-Object: Like SQL ORDER BY
* Group-Object: Like SQL's GROUP BY
* Other:
** We need a Transform-Object (maybe using ForEach-Object)
** Split data/text into discreet objects (-split or Get-Content -Delimiter)
** AWK Component

## Cache
It makes sense to create a cache of these cmdlets in JSON format which we can use just like components.json
$CmdLets = Get-Command |
  Sort-Object -Property Name |
  ForEach-Object {pow inspect $_}
$CmdLets = Get-Content .\examples\cmdlets.json | ConvertFrom-Json
$Components = Get-Content .\examples\components\components.json | ConvertFrom-Json
($Components + $CmdLets) | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 .\examples\components.json

Get-Command | Select Name, Type, Source, Module, Version | Sort Name | ogv

## Useful Commands
### List 10 Most Common Cmdlet Input Types
```
pow cmdlets list | group input | sort count -Descending | select -first 10
```
### List Most Common Object Outputs
```
pow cmdlets list | ? {$_.output -like '*object*'} | group output | sort count -Descending
```
### List the 10 Modules with the most Cmdlets
```
pow cmdlets list | group module | sort count -Descending | select -first 10
```
