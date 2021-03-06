# TODO

https://github.com/rannn505/node-powershell/blob/master/docs/api/Shell/dispose.md

* pow.exec vs pow.execStrict error handling
* Decide whether adaptors work on data type (cmdlet.output) or format (cmdlet.outputFormat)
  * `pow components ! | select name, output, outputFormat`

## Build
* Build Modes:
* Pipeline Mode
** As today - basically a folder
* Script Mode
** As a teaching aid/kickstart for real powershell programming
** A single .ps1 file: basis for further hacking
** Don't wrap Cmdlets in a separate step file

* Move components to core
* Build should copy components to pipeline folder and reference them

* Trace should be serializing step output to JSON as required

* components.json should not have absolute paths
** Need to decide how to cache this per workspace OR
** Rethink where components need to reside: probably in core/ globally
* How to switch between POWERSHELL (v5) and PWSH (v6)
* What to do about parameter sets with multiple ByValue pipeline parameters? (e.g. Unprotect-CmsMessage)
* Convert System.DateTime.MinValue to {[System.DateTime]::MinValue} in Parameter defaults
** Or just //Microsoft.ActiveDirectory.Management.AuthType.Negotiate since not all values can be resolved
* New component "ScriptBlock" for arbitrary PS Code?
* Parameter[] - use "Pills" so Name, Age => {"Name", "Age"}
* Can we do away with pipeline.id - it's redundant!
 * * But do we want the id to change when we move folders?
* Let's switch to pipelineId.pipe so we can have a .exe run the file

# Adaptors
We want to support any Cmdlet's output so...
We provide adaptors which convert any data type to the canon: JSON string
We need to know how a component expects I/O
* Input: STDIN or PARAMS
* Output: STDOUT or RETURN

Types of components regarding PIPED I/O:
* TYPE:         STDIN       PARAMS      STDOUT      RETURN
* Source:       -           ?           Y           ?
* Filter:       Y           ?           Y           ?
* End-Point:    Y           ?           -           ?
* Function:     -           ?           -           ?

At some point we need to know if the JSON is an object or an array

## POW.js
* How to capture -Verbose output

## Examples
* We need more components (API, HTTP, NodeJs, AWK, Python...)
* * Components should declare their dependencies
* * Maybe the -WhatIf parameter should check dependencies (on steps and pipelines)

## IDE
* We need some arrows showing pipeline flow of data
* We need some basic shapes showing the type of text/xxx input (e.g. csv, json) a component inputs/outputs
* TODO: When dragging a step the inputs may need to be changed/cleared

## POW CLI
* Cleanup uses of Write-Host: fine if called by a human
* When data is piped in, how do we differentiate between lines of text and bulk text (-raw)
* We need some basic components for core operations
 * Filter: Remove docs/lines not matching
 * Map: Transform data
 * Reduce: Summarize data
 * Sequence: Generate a sequence of ...numbers, things
 * Loop/Split: Split incoming data and output discreet values
* If a component doesn't accept piped input we might still want to map an output to a parameter
* Pipeline designer may need to preview a components outputs
* Need to agree on `""` or `null/$null` for empty values in JSON


## Components
* Read list of installed modules from profile?
* Running pipeline as a step/component
* Progress Bar?
  * `Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I;`
* Package Manager
  * `Invoke-WebRequest http://PoshCode.org/i -OutF PC.ps1; .\PC; rm .\PC.ps1`
  * Dealing with PS vs Component compatability/versions