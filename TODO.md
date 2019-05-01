# TODO

* Parameter[] - use "Pills" so Name, Age => {"Name", "Age"}
* IDE produces new pipeline with parameters as an empty array: should be an object
* Can we do away with pipeline.id - it's redundant!
* * Let's switch to pipelineId.pipe so we can have a .exe run the file
* We maybe need a convertto-json component for outputs of pipelines
* We need to save a pipeline before running it in the IDE
* We need a concept of "dirty" in the IDE so we know if a pipeline has been changed

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
* We need more realistic, complex pipelines
* We need more components (API, HTTP, NodeJs, AWK, Python...)
 * Components should declare their dependencies

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