!TODO
* Dynamically compile the pipeline.ps1 file from the pipeline definition in pipeline.json
** Compile each of the step files
* Inspect/reflect the definition of component
** from a separate MyComponent.json file?
** by parsing MyComponent.ps1? -> will exclude standard CmdLets we don't have the source for
** by inspecting/reflecting MyComponent.ps1 with Get-Command?
* We need to deal with not passing on empty parameters
* Handling parameters for the pipeline as a whole
* Using Write-Debug or Write-Verbose?
* Progress Bar?
** Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I;