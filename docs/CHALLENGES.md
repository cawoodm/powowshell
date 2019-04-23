CHALLENGES

BUILD:
 Should we really wrap CmdLets as step.ps1??
 We have to really take care of:
 * Correct main, begin, process, end blocks
 * Not passing null parameters
 ** CmdLets that take optional parameters may not accept them @splatted as $null so we need a way to omit them
 ** e.g. ConvertFrom-Csv @{Header=$null}

VERIFY:
* Components may say they output text/json and then (due to a bug/malfunction) produce something else
** Would be good if we could diagnose this earlier
** Task for the IDE?

Consistent output: we currently have a mish-mash of write-host, write-warning

Matching I/O
Where-Object has psobject as it's input type but it actually accepts anything
 object|psobject are like wildcards and need no adaptors