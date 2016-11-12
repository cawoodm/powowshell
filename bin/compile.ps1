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
    [String]$Pipeline="pipeline1" # DEBUG
)
function Main() {
    #$VerbosePreference = "Continue"
    Push-Location $PSScriptRoot
    CompilingPipeline($Pipeline)
    Pop-Location
}

function CompilingPipeline($PipelineId) {

    #try {

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
    <# This method hides who caused the error as we only see
    } catch [System.ArgumentException] {
        Write-Error ("!!!Error Parsing Pipeline Definition!!!`n" + $_)
    } catch {
        Write-Error ("Some other error: " + $_)

    } finally {
        Pop-Location
    }#>
}

function ReadingPipelineDefinition($Path) {

    trap [System.ArgumentException] {
        Write-Error "Error Parsing Pipeline Definition: $Path"
        #$_ | gm
        Break
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

     Write-Verbose "Components checked out OK."

}

function CreatingComponentSteps($pipelineDef) {

    $stepTemplate = @'
. .\globals.ps1

$params = @{{
{0}
}}

{1}
'@;

    $pipelineDef.components | ForEach-Object {
        $id = $_.id
        $ref = $_.reference
        $params0 = ""
        $_.parameters.PSObject.Properties | ForEach-Object {
            # TODO: We need the parameter types from the component definition...
            $params0 += "`t$($_.Name) = `"$($_.Value)`""
        }
        $cmd1 = "$ref @params >.\trace\tmp_$id_output.txt 2>.\trace\tmp_$id_errors.txt 5>>.\trace\tmp_debug.txt"
        $step = $stepTemplate -f $params0, $cmd1
        $step
    }

}

Main