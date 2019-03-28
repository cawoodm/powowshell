let pipelineManager = require('../ide/js/pipeline-manager.js');
console.log(pipelineManager.reset);
(function pipelineManagerTest(verbose) {
    let tests = 0;
    let fails = 0;

    let PM = pipelineManager;
    let COLS = pipelineManager.pipeCols;

    function assert(cond, msg, exception) {
        if (verbose) console.log("\x1b[36m", "... " + msg);
        try {
            tests++;
            let res = typeof cond === "function"?cond():eval(cond);
            if (res) {
                if (verbose && !exception) console.log("\x1b[36m", "*** OK: "+msg);
            } else {
                fails++;
                console.log("\x1b[31m", "*** FAIL: "+msg);
            }
        } catch(e) {
            if (!exception) {
                fails++;
                console.log("\x1b[31m", "*** FAIL: "+msg);
                console.log("\x1b[31m", "****EXCEPTION: "+e.message);
                console.log(e);
                throw new Error("HALT TEST: Unexpected exception");
            } else {
                if (verbose) console.log("\x1b[36m", "*** OK: "+msg);
            }
        }
    }
    function columnsToString() {
        for (let r=1; r<=pipelineManager.rowCount(); r++) {
            let s = "";
            for (let c=1; c<=pipelineManager.columnCount(); c++) {
                let step = pipelineManager.getStep(c, r);
                s += step.id + " (" + step.name  + ") ";
            }
            console.log(s);
        }
    }
    // @ts-ignore
    const fs = require('fs');
    // @ts-ignore
    const path = require('path');
    // @ts-ignore
    let testPipeline = fs.readFileSync(path.resolve(__dirname, '../examples/pipeline1/pipeline.json'), "utf8").trim();
    //testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"../components/ReadFile.ps1", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"../components/CSV2JSON.ps1", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"../components/SelectFields.ps1", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
    // @ts-ignore
    let testComponent = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../examples/components/CSV2JSON.json'), "utf8").trim());
    //testComponent = { "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": { "FieldSeparator": { "type": "string", "default": ",", "description": "Specifies the field separator. Default is a comma." } }, "input":"text/csv", "output":"json/array"};

    try{

        console.clear();

        // Check a new pipeline
        PM.reset();
        assert(PM.columnCount()===COLS.length, "We have the right number of columns ("+COLS.length+")")
        assert(PM.rowCount()===9, "We have the right number of rows (9)")
        assert(PM.nextRow("A")===1, "Next empty row in column A is 1")
        
        // Getting and Adding Steps
        assert(()=>PM.getStep(1, 1).reference === null, "Step A1 is initialized")
        assert(()=>PM.addComponent("1", 1, {reference: "foo"}).reference === "foo", "Step A1 is set to foo")
        assert(PM.nextRow("A")===2, "Next empty row in column A is 2")
        assert(()=>PM.addComponent("B", null, {reference: "bar"}).reference === "bar", "Step B1 is set to bar")
        assert(()=>PM.addComponent("C3", null, testComponent).reference=="CSV2JSON.ps1", "Add component to wrong row", true)
        assert(()=>PM.addComponent("C1", null, testComponent).reference=="CSV2JSON.ps1", "Add C1 component")
        assert(()=>PM.addComponent("C", null, testComponent).reference=="CSV2JSON.ps1", "Add C component")
        assert(()=>PM.addComponent("C", null, testComponent).reference=="CSV2JSON.ps1", "Add another C component")
        assert(()=>PM.getStep("C", 3).reference !== null, "Step C3 is set")
        let step = PM.getStep("C3");
        assert(()=>PM.setStep(step), "Set step works");
        assert(()=>step.parameters.length===3, "CSV2JSON should have 3 parameters");

        // Available inputs
        assert(()=>PM.getAvailableInputs("C3").length==4, "Step 3 has 2 available inputs");

        // Moving steps
        assert(()=>PM.moveStep("C3", "A1"), "Step can't be moved over existing step", true);
        assert(()=>PM.getStep("D4").reference===null, "Step D4 should be empty");
        assert(()=>PM.getStep("A1").reference!==null, "Step A1 should not be empty");
        assert(()=>PM.getStep("C3").reference!==null, "Step C3 should not be empty"); 
        PM.moveStep("C3", "D4")
        let c3 = PM.getStep("C3");
        let d4 = PM.getStep("D4");
        assert(()=>d4.reference=="CSV2JSON.ps1" && c3.reference === null, "Step C3 moved to D4");

        // Removing steps
        PM.removeStep("D4");
        assert(()=>PM.getStep("D4").reference === null, "Step D4 is removed")

        // Import
        assert(()=>PM.import(testPipeline), "Pipeline import");
        assert(()=>PM.getStep("A1").reference.match(/File/), "Test pipeline step B1 is File")
        assert(()=>PM.getStep("B1").reference.match(/CSV2JSON/), "Test pipeline step B1 is CSV2JSON")
        assert(()=>PM.getStep("C1").reference.match(/SelectFields/), "Test pipeline step C1 is SelectFields")
        assert(()=>typeof PM.getStep("A1").parameters.Path === "string", "Step A1 of imported pipeline has a 'Path' parameter")
        
        // Export
        let myPipeline = PM.export();
        assert(()=>myPipeline.steps.length===3, "Pipeline export has 3 steps")
        let pipelineDef = PM.getDefinition();
        assert(()=>myPipeline.id===pipelineDef.id, "Export has same id")
        let pipelineStr = JSON.stringify(myPipeline);
        //fs.writeFileSync("C:\\temp\\pipeline.json", pipelineStr, "utf-8");

        //console.log(PM.getStep("C1"))
        //columnsToString();

    } catch(e) {
        fails++;
        console.log("TEST cancelled:")
        console.log(e);
    }

    if (fails) {
        columnsToString();
        console.error("\x1b[31m", fails + " of " + tests + " failed")
    } else {
        console.log("\x1b[36m", "All test passed successfully")
    }
})(1);