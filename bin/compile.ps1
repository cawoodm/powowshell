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
    If ("DEBUG" -eq "DEBUG") {
        $Pipeline="pipeline1"
        $VerbosePreference = "Continue"
    }
    Push-Location $PSScriptRoot
    CompilingPipeline($Pipeline)
    Pop-Location
}

function CompilingPipeline($PipelineId) {

    try {

    # TODO: Check pipeline exists
    Push-Location $PipelineId/

    # Read pipeline.json definition
    $pipelineDef = ReadingPipelineDefinition("pipeline.json")
    #$pipeline = Get-Content -Raw "$Pipeline/pipeline.json" | ConvertFrom-Json

    # Validate definition
    CheckingComponents($pipelineDef.components)

    # Transform definition of components into Steps
    CreatingComponentSteps($pipelineDef)

    # Transform definition of pipeline into run.ps1

    # Cleanup
    <# This method hides who caused the error as we only see#>
    } catch {
        If ($_.Exception.Message -ne "") {
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
    If (-not $components -or -not $components.Count -or $components.Count -eq 0) {
        Write-Error "No components found!"
        Return
    }
    Write-Verbose "$($components.Count) components found"

    # Check each component
    $components | ForEach-Object {
        # TODO: Support Cmdlets and maybe use Get-Command?
        If (-not (Test-Path $_.reference)) {
            Write-Error "Component Id $($_.id) reference $($_.reference) not found!"
        }
        # TODO: Check mandatory fields (e.g. id)
        # TODO: Check parameters against component definition?
     }

     Write-Verbose "Components checked out OK"

}

function CreatingComponentSteps($pipelineDef) {

    $stepTemplate = ". .\globals.ps1`n`$params = @{{`n{0}`n}}`n{1}"
    $Count = 0
    $validOutputs = @{"System.String"=$true;"System.Array"=$true;"System.Object"=$true}

    $pipelineDef.components | ForEach-Object {
        $id = $_.id
        $ref = $_.reference
        
        # Inspect definition from component script
        $cmd = Get-Command $_.reference
        If (-not $cmd.Parameters) {
            If ($_.parameters.PSObject.Properties.Count -gt 0) {
                Write-Error "No parameters found for component '$ref'!"
                Throw [Exception] ""
            } Else {
                Write-Warning "No parameters found for component '$ref'!"
            }
        }
        $params0 = ""
        $_.parameters.PSObject.Properties | ForEach-Object {
            # TODO: We need the parameter types from the component definition...
            $params0 += "`t$($_.Name) = `"$($_.Value)`"`n"
        }
        # Validate OUTPUT of Component
        $outputType = $cmd.OutputType.Name
        If (-not $outputType) {
            Write-Warning "No OutputType found for component '$ref'!"
        } ElseIf ($outputType -and -not $validOutputs.ContainsKey($outputType)) {
            Write-Error "Invalid OutputType '$outputType' found for component '$ref'!"
            Throw [Exception] ""
        }
        $cmd1 = "$ref @params >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt"
        $stepTemplate -f $params0, $cmd1 > "step_$id.ps1"
        $Count++
    }
    Write-Verbose "$Count steps created"

}
Main