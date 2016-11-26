# TODO

## IDE

* Pipeline from Scratch
  * Drag dummy components around the matrix -> DONE
  * Load components list and configuration
    * Read list of components from components
      * list by folder
    * Read list of installed modules from profile?
      - list by module
  * Configure components in IDE (forms)
* Load Pipeline from pipeline.json
  * Phase 1: Copy/Paste JSON
  * Phase 2: Upload/Drag?
  * Phase 3: REST
  * Phase 4: Direct read file system
* Save Pipeline to pipeline.json
  * Phase 1: Export JSON
  * Phase 2: Direct write file system

## Components

* We need to deal with not passing on empty parameters
* Handling parameters for the pipeline as a whole
  * Calling pipeline with params
  * Running pipeline as a step
* Progress Bar?
  * `Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I;`
* Package Manager
  * Like `Invoke-WebRequest http://PoshCode.org/i -OutF PC.ps1; .\PC; rm .\PC.ps1`
  * Dealing with PS vs Component compatability/versions
