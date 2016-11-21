!TODO
* IDE
  * Generate pipeline.json from diagram
  * Read list of components from components/ folder
  * Read list of installed modules from profile?
    * List cmdlets by module
* We need to deal with not passing on empty parameters
* Handling parameters for the pipeline as a whole
  * Calling pipeline with params
  * Running pipeline as a step
* Progress Bar?
  * `Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I;`
* Package Manager
  * `Invoke-WebRequest http://PoshCode.org/i -OutF PC.ps1; .\PC; rm .\PC.ps1`
  * Dealing with PS vs Component compatability/versions