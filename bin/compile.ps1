<#
 .Synopsis
 Compile a pipeline definition into runnable run.ps1 script

 .Description
 Will read and parse the pipeline.json file inside the pipeline folder.
 Next, each component listed is verified.
   
 .Parameter Path
 The path to a pipeline directory to compile
   
 .Parameter Output
 The path to output the resulting powershell program (runnable pipeline)

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][String]$Path,
    [String]$Output
)
$OutputPath=".\"
function main() {
    
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

    $FullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
	if ($FullPath -eq $null) {throw "Path to pipeline $Path not found!"}
    if ($Output) {$OutputPath = Resolve-Path $Output -ErrorAction SilentlyContinue}
    if ($OutputPath -eq $null) {throw "Output path $Output not found!"}
    Push-Location $FullPath.Path
    try {
        CompilingPipeline
    } catch {
        Write-Error ("ERROR in Compiler in Line " + $_.InvocationInfo.ScriptLineNumber + ": " + $_.Exception.Message)
        #throw $_
    }
    Pop-Location
}

function CompilingPipeline() {

    try {

            # Read pipeline.json definition
			$pipelineDef = ReadingPipelineDefinition("pipeline.json")

			# Validate definition
			CheckingComponents($pipelineDef.components)

			# Transform definition of components into Steps
			CreatingComponentSteps($pipelineDef)

			# Transform definition of pipeline into run_trace.ps1
			CreatingPipeline_trace($pipelineDef)

			# Transform definition of pipeline into run_prod.ps1
			CreatingPipeline_prod($pipelineDef)
			
			"Pipeline compiles successfully!"
            $p=$Path; if ($Output) {$p=$Output}
            "Usage:`n  POW run $p"
            "OR`n  POW run $p -Trace"
                

    } catch {
        if ($_.Exception.Message -ne "") {
            Write-Error ("Unhandled Excption`n" + $_)
        }
    } finally {
        
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
        # TODO: Check parameters against component definition? - Done in CreatingComponentSteps()
     }

     Write-Verbose "Components checked out OK"

}

function CreatingComponentSteps($pipelineDef) {
		
    # Pass GLOBALS to the Component
    $globals = "`$globals = " + (ReSerializeObject $pipelineDef.globals) + "`n";
    $stepTemplate += "[CmdletBinding(SupportsShouldProcess)]`n`{0}`n{1}`n{2}";

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
        $params0 = "`$params = " + (ReSerializeObject $step.parameters);

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

        # Actual core component call
        $cmd1 = "$inputSrc$ref @params" # >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt"
        
        # Build Step code
        $stepTemplate -f $params0, $globals, $cmd1 > "$OutputPath\step_$id.ps1"

        $Count++

    }

    Write-Verbose "$Count steps created"

}

<#
	CreatingPipeline_prod
	Create pipeline for production
	 * No trace files are used
	 * Performance is better
#>
function CreatingPipeline_prod($pipelineDef) {
    Write-Verbose "COMPILER CreatingPipeline_prod"
    #Write-Error ("ERROR in Compiler in Line " + $_.InvocationInfo.ScriptLineNumber + ": " + $_.Exception.Message)

    # Can be run from anywhere, change to pipeline path
    $cmd = ReSerializeParams $pipelineDef.parameters;
    $cmd += "Push-Location `$PSScriptRoot`n"
    $cmd += "`n"
    $cmd += "try {`n`n"
    
    $pipelineDef.components | ForEach-Object {$step = $_;
    
        $id = $step.id
        
        $cmd += "`t# Run Step $($id): $($step.name)`n"
        
        # Capture step OUTPUT
        $cmd += "`t`$OP_$id = "
        
        # Pass INPUT to step
        if ($step.input) {$cmd += "`$OP_$($step.input) | "}
        
        # Run step LOGIC
        $cmd += ".\step_$($id).ps1`n`n"
        
    }
    
    # Return OUTPUT
    $cmd += "`t`$OP_$($id)`n"
    
    # Clean up
    $cmd += "`n"
    $cmd += "} catch {`n"
    $cmd += "   throw `$_`n"
    $cmd += "} finally {`n"
    $cmd += "   Pop-Location`n"
    $cmd += "}`n"
    
    $cmd > "$OutputPath\run_prod.ps1"
		
}

<#
	CreatingPipeline_trace
	Create pipeline for tracing
	 * Trace files are generated
	 * Better for debugging
#>
function CreatingPipeline_trace($pipelineDef) {

    Write-Verbose "COMPILER CreatingPipeline_prod"

    # Can be run from anywhere, change to pipeline path
    $cmd = "[CmdletBinding(SupportsShouldProcess)]"
    $cmd = "Push-Location `$PSScriptRoot`n"
    $cmd += "`$VerbosePreference='Continue'`n"
    $cmd += "New-Item -Path .\trace -ItemType Directory -ErrorAction SilentlyContinue | Out-Null`n"
    $cmd += "`n"
    
    $pipelineDef.components | ForEach-Object {$step = $_;
    
        $id = $step.id
        
        $cmd += "# Run Step $($id): $($step.name)`n"
        $cmd += "Write-Verbose `"Running step $($id): $($step.name)`"`n"
        
        if ($step.input) {
            # Pass INPUT to step
            $cmd += "Get-Content -Raw .\trace\tmp_$($step.input)_output.txt | "
        }
        
        # Run step LOGIC and capture OUTPUT
        $cmd += ".\step_$($id).ps1 >.\trace\tmp_$($id)_output.txt 2>.\trace\tmp_$($id)_errors.txt 5>>.\trace\tmp_debug.txt`n`n"
        
    }
    
    # Return OUTPUT
    $cmd += "# Return Output`n"
    $cmd += "Get-Content -Raw .\trace\tmp_$($id)_output.txt`n"
    
    # Clean up
    $cmd += "`n"
    $cmd += "Pop-Location"
    
    $cmd > "$OutputPath\run_trace.ps1"
		
}
function ReSerializeObject($obj) {
    Write-Verbose "COMPILER ReSerialieObject"
    $res = "@{`n"
    $obj.PSObject.Properties | ForEach-Object {
        $pVal = $_.Value; $pName = $_.Name
        if ($pVal.Contains("`{") -and $pVal.EndsWith("}")) {
            # Parameter is code (a PowerShell Expression)
            # TODO: Escape code for PS
            $res += "`t$($pName) = " + $pVal.SubString(1, $pVal.Length-2) + "`n"
        } else {
            # Parameter is a String
            # TODO: Escape String for PS
            $res += "`t$($pName) = `"$($pVal)`"`n"
        }
    }
    $res += "};"
    return $res
}
function ReSerializeParams($obj) {
    Write-Verbose "COMPILER ReSerializeParams"
    if ($obj -is [array]) {throw "Parameters object is not an array!"}
    $res = "[CmdletBinding(SupportsShouldProcess)]`n"
    $res += "param(`n"
    $obj.PSObject.Properties | ForEach-Object {
        Write-Verbose $_.Name
        $pVal = $_.Value; $pName = $_.Name
        if ($pVal.Contains("`{") -and $pVal.EndsWith("}")) {
            # Parameter is code (a PowerShell Expression)
            # TODO: Escape code for PS
            $res += "`t`$$($pName) = (" + $pVal.SubString(1, $pVal.Length-2) + "),`n"
        } else {
            # Parameter is a String
            # TODO: Escape String for PS
            $res += "`t`$$($pName) = `"$($pVal)`",`n"
        }
    }
    $res = $res -replace ',\n$', "`n"
    $res += ")`n"
    return $res
}
Set-StrictMode -Version 5.0
main