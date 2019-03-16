# Ground Rules

## COMPONENTS
A component is the building block of a pipeline: pipelines wire together components as steps.
* Technically components are reusable powershell scriptlets which obey certain rules and recommendations.
* For example they accept and produce piped text input (not powershell objects or other primitives).
* If they have parameters then these are typed and described properly.

In detail these are the rules:
* 1.1 All components MUST be powershell scripts
	* Don't worry, powerShell is cool and can call anything (DOS, Node, Python etc...)
* 1.2 Component Input is defined as fixed PARAMETERS and/or piped INPUT:
	* It must declare its PARAMETERS with types, which can be mandatory or optional with or without defaults.
	* If it accepts piped INPUT, it gets the data as a String from the pipeline (stdin) with parameter $InputObject
	* If it provides piped OUTPUT, it writes it's output as a String to the pipeline (stdout) with Write-Output
		* Annotate scriptlet with `[OutputType([String])]` and document INPUT/OUTPUT properly in powershell header (See documentation below)
* 1.3 Component is movable
	* should run and work regardless of where it is located (no $PSScriptRoot)
	* should not include any scriptlets from a relative path
	* if it uses modules/includes these are not (cannot be) managed or garanteed by the powowshell framework
* 1.4 Handles errors correctly:
	* Write error messages to the pipeline (stderr) with Write-Error
	* throw helpful errors with correct line numbers
* 1.5 Documentation
	* Has powershell help/comments describing (for humans) the function and interface (.Parameter, .Inputs, .Outputs)
	* .Inputs and .Outputs will always be `text` or `text/*` (e.g. `text/json`)
	* .Inputs and/or .Outputs can also be `none`
* 1.6 Should support dry runs with -WhatIf (SupportsShouldProcess)
	* This means a pipeline can be verified (using `pow verify`) by running it without any side-effects

## Pipelines
Pipelines are ultimately powershell scripts which wire various components together
As such, they are similar to components in that they
* Have PARAMETERS which can be supplied at runtime and which can have defaults set at design time
* * These can be passed to components in the step via `$PipelineParams` by wrapping it in `${}` (e.g. `stepParameter: "{$PipelineParams.DataSource}"`)
* * These PipelineParams are readonly to the steps and won't be changed
* Have GLOBALS defined which all components can read and write!
* Can produce text output on stdout
* Pipelines should accept piped input as well
* Pipelines run and end - no continuous operation (streaming) mode supported

Because pipelines generate and accept piped input and support parameters they will effectively be able to be used as components in other pipelines.

## Isolation
COMPONENTS are called from within STEPS which are like an instance of a component. The Step runs in the same context/program as the pipeline and thus can see PARAMETERS and change GLOBALS. The actual component is isolated from the context (using PowerShell's `&` operator) and can only see what it gets from the step.

Currently, the Step is 100% built by PowowShell and you can't change how it works much except to pass parameters (global or step) to it. Step parameters are passed automatically to the component. To pass in a pipeline parameter just pass in `{$PipelineParams.DataSource}`.

Indeed, anything inside `${...}` is an evaluated PowerShell expression so you can pass in a timestamp with `${Get-Date}`.