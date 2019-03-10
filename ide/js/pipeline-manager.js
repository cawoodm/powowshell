/*
 PipelineManager
 Manage the pipeline interfacing between the UI/user (dragging stuff around) and the pipeline.json output
 The pipeline is represented in meory as a list of columns with steps
 
 Functionality:
    reset(): Like an init() which can be called repeatedly to clear the pipeline
    import(): Read/de-serialize a pipeline JSON document into memory
    export(): Save/serialize a pipeline JSON document to JSON
    verifyPipeline(): Check in-memory pipeline for consistency
    addComponent(): Add a new step from a componet definition
    removeStep(): Remove a step from a pipeline
    moveStep(): Move a step from one position to another
 HelperS:
    getColumn(c): Get a column (array of steps)
    getStep(c, r): Get a step from within column c at row r

 Data Model:
  columns: Array of columns representing [A-I]
   column: Array of steps representing [1-9]
    step: {
        id: "B1",                       // The id of the step 
        reference: "file-csv-ps1",            // The path to the component
        label: "Read Voters File",      // short readable name of the step
        parameters: {
            "p1": "value",              // Parameter p1 and it's value
            "p2": "value",              // Parameter p2 and it's value
        },
        input: "A1"                     // Which step's output is my input
    }

*/
// @ts-check
const pipeCols = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
let pipelineManager = (function() {
    const COLS = pipeCols.length;
    const ROWS = 9;
    let columns = [];
    let pipelineDef = {};

    /**
     * Takes "A22" and returns 22
     * @param {string} col 
     * @return {number} 
     */
    function parseRow(col) {
        return parseInt(col.substring(1))
    }
    /**
     * Takes "A22" and returns 1
     * @param {string} col 
     * @return {any} 
     */
    function parseCol(col) {
        return typeof col === "number"?col:pipeCols.indexOf(col.substring(0,1))+1;
    }
    function getColumn(col) {
        // We may be called as a number or a letter (e.g. "A")
        if (typeof col !== "number") {col = pipeCols.indexOf(col)+1}
        if (col>=1 && col<=pipeCols.length+1) {
            return columns[col-1];
        } else throw("Invalid column number " + col + " in getColumn!");
    }
    function getStep(col, row) {
        // @ts-ignore We may be called as (1,1) or ("A", 1) or ("A1") 
        if (!row) {row = parseRow(col); col = parseCol(col)}
        let column = getColumn(col);
        if (row>=1 && row<=ROWS) {
            return column[row-1];
        } else throw("Invalid row number " + row + " in getStep!");
    }
    /**
     * Import a step from the definition in pipeline.json
     * @param {Object} step
     */
    function importStep(step) {
        let col = parseCol(step.id);
        let row = parseRow(step.id);
        if (getStep(col, row).reference != null) throw "Step " + col + row + " is not empty!"
        // @ts-ignore
        columns[col-1][row-1] = step;
    }
    function pipelineStepToStep(id, stepI) {
        // MAPPING: Step definition in pipeline JSON to Step in UI
        return {
            id: id,
            reference: stepI.reference,
            label: stepI.name,
            parameters: stepI.parameters,
            input: stepI.input
        }
    }
    function component2Step(id, component) {
        // MAPPING: Component Definition to Step in UI
        return {
            id: id,
            reference: component.reference,
            parameters: component.parameters||{},
            input: component.input||null,
            output: component.output||null
        };
    }
    function stepToPipelineStep(id, step) {
        // MAPPING: Step in UI to step definition in pipeline JSON
        return {
            id: id,
            reference: step.reference,
            name: step.label,
            parameters: step.parameters,
            input: step.input,
            output: step.output
        }
    }

    // Public members
    return {
    /**
     * Initialize a new, empty pipeline
      */ 
    reset: function() {
        columns = [];
        pipelineDef = {};
        for (let c=0; c<pipeCols.length; c++) {
            let column = [];
            for (let r=0; r<ROWS; r++) {
                let step = {id: pipeCols[c]+(r+1).toString(), reference: null, label: null}
                column.push(step);
            } 
            columns.push(column);
        } 
    },
    /**
     * Return a column indexed from 1 to 10 (A-K)
     * @param {number|string} col The ID of the column to return (1-9 or A-Z)
     */
    getColumn: getColumn,
    /**
     * Return a step indexed from A1 to Z9
     * @param {string} col The ID (A-Z or 1 to 10) of the column to return
     * @param {number} row The ID (1 to 9) of the step to return
     */
    getStep: getStep,
    /**
     * Add a step to the grid
     * @param {string} col The ID (1 to 10) of the column
     * @param {number} row The ID (1 to 9) of the step
     * @param {Object} component The component definition to add
     */
    addComponent: function(col, row, component) {
        if (!row) {row = parseRow(col); col = parseCol(col)}
        let step = this.getStep(col, row);
        if (step.reference != null) throw "Step " + col + row + " is not empty!"
        step = component2Step(step.id, component);
        columns[parseInt(col)-1][row-1] = step;
        return step;
    },
    /**
     * Import pipeline definition from JSON
     * @param {Object|string} def The JSON object defining the pipeline from pipeline.json
     * @returns {boolean} True is success
     */
    import: function(def) {
        this.reset();
        if (typeof def === "string") def = JSON.parse(def);
        for(let s=0; s<def.steps.length; s++) {
            let stepI = def.steps[s];
            let col = parseCol(stepI.id);
            let row = parseRow(stepI.id);
            let step = pipelineStepToStep(stepI.id, stepI)
            importStep(step);
        }
        this.pipelineDef = def;
        return true;
    },
    /**
     * Return the definition for unit testing
     */
    getDefinition: function() {
        return this.pipelineDef;
    },
    /**
     * Export pipeline definition as an object
     * @return {Object}
     */ 
    export: function() {
        let res = {};
        // Export all properties in pipelineDef
        Object.assign(res, this.pipelineDef)
        // Overwriting all non-empty steps
        res.steps = [];
        for (let r=1; r<=ROWS; r++) {
            for (let c=1; c<=COLS; c++) {
                let step = this.getStep(c, r);
                if (step.reference !== null) {
                    let stepO = stepToPipelineStep(step.id, step);
                    res.steps.push(stepO);
                }
            }
        }
        return res;
    },
    columnCount: function() {
        return columns.length;
    },
    rowCount: function() {
        return columns[0].length;
    }
};
})();

/**
 * Tester
 */
(function pipelineManagerTest(verbose) {
    let tests = 0;
    let fails = 0;
    function assert(cond, msg) {
        if (verbose) console.log("\x1b[36m", "... " + msg);
        try {
            tests++;
            let res = typeof cond === "function"?cond():eval(cond);
            if (res) {
                if (verbose) console.log("\x1b[36m", "*** OK: "+msg);
            } else {
                fails++;
                console.log("\x1b[31m", "*** FAIL: "+msg);
            }
        } catch(e) {
            fails++;
            console.log("\x1b[31m", "****EXCEPTION: "+msg);
            console.log(e);
            throw "ENDE"; // Halt test
        }
    }
    function columnsToString() {
        for (let r=1; r<=pipelineManager.rowCount(); r++) {
            let s = "";
            for (let c=1; c<=pipelineManager.columnCount(); c++) {
                let step = pipelineManager.getStep(c, r);
                s += step.id + " (" + step.label + ") ";
            }
            console.log(s);
        }
    }
    const fs = require('fs');
    let testPipeline = fs.readFileSync('../../examples/pipeline1/pipeline.json', "utf8").trim();
    //let testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A", "name":"Read Voters File", "reference":"../components/ReadFile.ps1", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B", "name":"Convert2JSON", "reference":"../components/CSV2JSON.ps1", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C", "name":"Select Name and Email", "reference":"../components/SelectFields.ps1", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
    let testComponent = JSON.parse(fs.readFileSync('../../examples/components/CSV2JSON.json', "utf8").trim());
    //let testComponent = { "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": { "FieldSeparator": { "type": "string", "default": ",", "description": "Specifies the field separator. Default is a comma." } }, "input":"text/csv", "output":"json/array"};

    try{
        console.clear();
        pipelineManager.reset();
        assert(pipelineManager.columnCount()===pipeCols.length, "We have the right number of columns ("+pipeCols.length+")")
        assert(pipelineManager.rowCount()===9, "We have the right number of rows (9)")
        
        // Getting and Adding Steps
        assert('pipelineManager.getStep(1, 1).reference === null', "Step A1 is initialized")
        assert('pipelineManager.addComponent(1, 2, {reference: "foo"}).reference === "foo"', "Step A2 is set to foo")
        assert('pipelineManager.addComponent("C3", null, testComponent).reference=="CSV2JSON"', "Add basic component")
        assert('pipelineManager.getStep("C", 3).reference !== null', "Step C3 is set")

        // Import
        assert(()=>pipelineManager.import(testPipeline), "Pipeline import");
        assert(()=>pipelineManager.getStep("A1").reference.match(/File/), "Test pipeline step B1 is File")
        assert(()=>pipelineManager.getStep("B1").reference.match(/CSV2JSON/), "Test pipeline step B1 is CSV2JSON")
        assert(()=>pipelineManager.getStep("C1").reference.match(/SelectFields/), "Test pipeline step C1 is SelectFields")
        assert(()=>typeof pipelineManager.getStep("A1").parameters.Path === "string", "Step A1 of imported pipeline has a 'Path' parameter")
        
        // Export
        let myPipeline = pipelineManager.export();
        assert(()=>myPipeline.steps.length===3, "Pipeline export has 3 steps")
        let pipelineDef = pipelineManager.getDefinition();
        assert(()=>myPipeline.id===pipelineDef.id, "Export has same id")
        let pipelineStr = JSON.stringify(myPipeline);
        fs.writeFileSync("C:\\temp\\pipeline.json", pipelineStr, "utf-8");

        //console.log(pipelineManager.getStep("C1"))
        //columnsToString();

    } catch(e) {
        console.log("TEST cancelled:")
        console.log(e)
    }

    if (fails) {
        columnsToString();
        console.error("\x1b[31m", fails + " of " + tests + " failed")
    } else
        console.log("\x1b[36m", "All test passed successfully")
})(1);