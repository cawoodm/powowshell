<#
    .Synopsis
    Compile a pipeline definition into runnable run.ps1 script

    .Description
    Will read and parse the pipeline.json file inside the pipeline folder.
    Next, each component listed is verified.
   
    .Parameter Pipeline
    The ID of a pipeline to compile

#>
[CmdletBinding()]
param(
    [String]$Pipeline
)
function Main() {
    if ("DEBUG" -eq "DEBUG") {
        $Pipeline="pipeline1"
        $VerbosePreference = "Continue"
    }
    Push-Location $PSScriptRoot
    CompilingPipeline($Pipeline)
    Pop-Location
}

function CompilingPipeline($PipelineId) {

    try {

			# Ensure we run from the pipeline's directory
			Push-Location $PipelineId/

			# Read pipeline.json definition
			$pipelineDef = ReadingPipelineDefinition("pipeline.json")

			# Validate definition
			CheckingComponents($pipelineDef.components)

			# Transform definition of components into Steps
			CreatingComponentSteps($pipelineDef)

			# TODO: Transform definition of pipeline into run.ps1
			CreatingPipeline($pipelineDef)

    } catch {
        if ($_.Exception.Message -ne "") {
            Write-Error ("Unhandled Excption`n" + $_)
        }
    } finally {
        Pop-Location
    }
}

function ReadingPipelineDefinition($Path) {

    trap [System.ArgumentException] {
        Write-Error ("Error Parsing Pipeline Definition: $Path" + $_)
        throw [Exception] ""
    }

    Return Get-Content -Raw ./pipeline.json | ConvertFrom-Json
}

function CheckingComponents($components) {

    # Make sure we have at least one component
    if (-not $components -or -not $components.Count -or $components.Count -eq 0) {
        Write-Error "No components found!"
        Return
    }
    Write-Verbose "$($components.Count) components found"

    # Check each component
    $components | ForEach-Object {
        # TODO: Support Cmdlets and maybe use Get-Command?
        if (-not (Test-Path $_.reference)) {
            Write-Error "Component Id $($_.id) reference $($_.reference) not found!"
        }
        # TODO: Check mandatory fields (e.g. id)
        # TODO: Check parameters against component definition? -> Done in CreatingComponentSteps()
     }

     Write-Verbose "Components checked out OK"

}

function CreatingComponentSteps($pipelineDef) {

    $stepTemplate = ". .\globals.ps1`n`$params = @{{`n{0}`n}}`n{1}"
    $Count = 0
    $validOutputs = @{"System.String"=$true;"System.Array"=$true;"System.Object"=$true}

    $pipelineDef.components | ForEach-Object {
        
        $step = $_
        $id = $step.id
        $ref = $step.reference
        
        # Inspect definition from component script
        $cmd = Get-Command $step.reference
        if (-not $cmd.Parameters) {
            if ($step.parameters.PSObject.Properties.Count -gt 0) {
                Write-Error "No parameters found for component '$ref'!"
                Throw [Exception] ""
            } else {
                Write-Warning "No parameters found for component '$ref'!"
            }
        }

        # Pass PARAMETERS to the Component
        $params0 = ""; $step.parameters.PSObject.Properties | ForEach-Object {
            $pVal = $_.Value; $pName = $_.Name
            if ($pVal.StartsWith("{") -and $pVal.StartsWith("{")) {
                # Parameter is a PowerShell Expression
                $params0 += "`t$($pName) = " + $pVal.SubString(1, $pVal.Length-2) + "`n"
                # TODO: Escape expression for PS
            # TODO: {Pass integer, date, array?}
            } else {
                # Parameter is a String
                $params0 += "`t$($pName) = `"$($pVal)`"`n"
                # TODO: Escape String for PS
            }
        }

        # Pass INPUT to the Component
        $inputSrc = if($step.input){'$input | '}else{''}

        # Validate OUTPUT of Component
        $outputType = $cmd.OutputType.Name
        if (-not $outputType) {
            Write-Warning "No OutputType found for component '$ref'!"
        } ElseIf ($outputType -and -not $validOutputs.ContainsKey($outputType)) {
            Write-Error "Invalid OutputType '$outputType' found for component '$ref'!"
            Throw [Exception] ""
        }

        # Build Step code
        $cmd1 = "$inputSrc$ref @params" # >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt"
        $stepTemplate -f $params0, $cmd1 > "step_$id.ps1"

        $Count++

    }

    Write-Verbose "$Count steps created"

}

function CreatingPipeline($pipelineDef) {

		$cmd = ""
		
		$pipelineDef.components | ForEach-Object {$component = $_;
		
			$id = $component.id
			
			if ($component.input) {
				# Pass INPUT to step
				$cmd += "Get-Content -Raw .\trace\tmp_$($component.input)_output.txt | "
			}
			
			# Run step LOGIC and capture OUTPUT
			$cmd += ".\step_$($id).ps1 >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt`n`n"
			
		}
		
		# Return OUTPUT
		$cmd += "Get-Content -Raw .\trace\tmp_$($id)_output.txt"
		
		$cmd > ".\runner.ps1"
		
}

Main