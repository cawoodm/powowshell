# TODO

## POW.js
* How to capture -Verbose output

## POW CLI
* Need to agree on `""` or `null/$null` for empty values in JSON

## IDE
* BUG: Drag & drop is broken
* TODO: When dragging a step the inputs need to be changed/cleared
* Verify pipeline
* Build pipeline
* Run pipeline
* Load pipeline/components via fs instead of XHR?

* Pipeline from Scratch
  * Drag dummy components around the matrix -> DONE
  * Load components list and configuration
    * Read list of components from components
      * list by folder
    * Read list of installed modules from profile?
      - list by module
  * Configure components in IDE (forms)

## Components
* We need to deal with not passing on empty parameters
* Running pipeline as a step/component
* Progress Bar?
  * `Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I;`
* Package Manager
  * `Invoke-WebRequest http://PoshCode.org/i -OutF PC.ps1; .\PC; rm .\PC.ps1`
  * Dealing with PS vs Component compatability/versions