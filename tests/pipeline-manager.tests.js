let pipelineManager = require("../ide/js/pipeline-manager.js");
(function pipelineManagerTest(console, args) {
    
    let verbose = args.indexOf("verbose")>=0?true:false;
    let FUNC = require("./functions")(verbose);
    let assert = FUNC.assert;
    //let debug = args.indexOf("debug")>=0?true:false;

    let PM = pipelineManager;
    let COLS = pipelineManager.pipeCols;

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
    const fs = require("fs");
    // @ts-ignore
    const path = require("path");
    // @ts-ignore
    let testPipeline = fs.readFileSync(path.resolve(__dirname, "../examples/pipeline1/pipeline.json"), "utf8").trim();
    //testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"../components/ReadFile", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"../components/CSV2JSON", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"../components/SelectFields", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
    // @ts-ignore
    let testComponent = JSON.parse(fs.readFileSync(path.resolve(__dirname, "./CSV2JSON.json"), "utf8").trim());
    let testComponent2 = JSON.parse(fs.readFileSync(path.resolve(__dirname, "./FileList.json"), "utf8").trim());
    //console.log(testComponent);process.exit();
    //testComponent = { "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": { "FieldSeparator": { "type": "string", "default": ",", "description": "Specifies the field separator. Default is a comma." } }, "input":"text/csv", "output":"json/array"};

    try{

        // Check a new pipeline
        PM.reset();
        assert(PM.columnCount()===COLS.length, "We have the right number of columns ("+COLS.length+")")
        assert(PM.rowCount()===9, "We have the right number of rows (9)")
        assert(PM.nextRow("A")===1, "Next empty row in column A is 1")
        
        // Getting and Adding Steps
        assert(()=>PM.getStep(1, 1).reference === null, "Step A1 is initialized")
        assert(()=>PM.addComponent("1", 1, testComponent).reference === "csv2json", "Step A1 is set to CSV2JSON")
        assert(PM.nextRow("A")===2, "Next empty row in column A is 2")
        assert(()=>PM.addComponent("B", null, testComponent2).reference === "filelist", "Step B1 is set to FileList")
        assert(()=>PM.addComponent("B", null, testComponent).reference=="csv2json", "Add component a cell with a step should fail", true)
        assert(()=>PM.addComponent("C1", null, testComponent).reference=="csv2json", "Add C1 component")
        assert(()=>PM.addComponent("C", null, testComponent).reference=="csv2json", "Add C component")
        assert(()=>PM.addComponent("C", null, testComponent).reference=="csv2json", "Add another C component")
        assert(()=>PM.getStep("C", 3).reference !== null, "Step C3 is set")
        let step = PM.getStep("C3");
        assert(()=>PM.setStep(step), "Set step works");

        // Available inputs
        assert(()=>PM.getAvailableInputs("C1").length==3, "Step 3 has 3 available inputs (A1 B1 and B2)");

        // Moving steps
        assert(()=>PM.moveStep("C3", "A1"), "Step can't be moved over existing step", true);
        assert(()=>PM.getStep("D4").reference===null, "Step D4 should be empty");
        assert(()=>PM.getStep("A1").reference!==null, "Step A1 should not be empty");
        assert(()=>PM.getStep("C3").reference!==null, "Step C3 should not be empty"); 
        PM.moveStep("C3", "D4")
        let c3 = PM.getStep("C3");
        let d4 = PM.getStep("D4");
        assert(()=>d4.reference=="csv2json" && c3.reference === null, "Step C3 moved to D4");

        // Removing steps
        PM.removeStep("D4");
        assert(()=>PM.getStep("D4").reference === null, "Step D4 is removed")

        // Import
        assert(()=>PM.import(testPipeline), "Pipeline import");
        assert(()=>PM.getStep("A1").reference.match(/readfile/), "Test pipeline step A1 is ReadFile")
        assert(()=>PM.getStep("B1").reference.match(/csv2json/), "Test pipeline step B1 is CSV2JSON")
        assert(()=>PM.getStep("C1").reference.match(/selectfields/), "Test pipeline step C1 is SelectFields")
        assert(()=>typeof PM.getStep("A1").parameters.Path === "string", "Step A1 of imported pipeline has a 'Path' parameter")
        
        // Export
        let myPipeline = PM.export();
        assert(()=>myPipeline.steps.length===3, "Pipeline export has 3 steps")
        let pipelineDef = PM.getDefinition();
        assert(()=>myPipeline.id===pipelineDef.id, "Export has same id")
        //let pipelineStr = JSON.stringify(myPipeline);
        //fs.writeFileSync("C:\\temp\\pipeline.json", pipelineStr, "utf-8");

        //console.log(PM.getStep("C1"))
        //columnsToString();

    } catch(e) {
        FUNC.addFails();
        console.log("TEST cancelled:")
        console.log(e);
    }
    
    if (FUNC.fails() > 0) {
        columnsToString();
        console.log("\x1b[31m", `FAIL: pipeline-manager.js failed ${FUNC.fails()} of ${FUNC.tests()} tests`, "\x1b[0m")
        process.exit(1)
    } else {
        console.log("\x1b[32m", `SUCCESS: pipeline-manager.js passed ${FUNC.tests()} tests successfully`, "\x1b[0m");
        process.exit(0)
    }
})(console, process.argv.slice(2));