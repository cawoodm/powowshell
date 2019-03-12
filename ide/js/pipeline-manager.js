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
        name : "Read Voters File",      // short readable name of the step
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

    // Public members
    return {
        /**
         * Initialize a new, empty pipeline
         */ 
        reset: function() {
            columns = [];
            pipelineDef = {id: null};
            for (let c=0; c<pipeCols.length; c++) {
                let column = [];
                for (let r=0; r<ROWS; r++) {
                    let step = emptyStep(pipeCols[c]+(r+1).toString());
                    column.push(step);
                } 
                columns.push(column);
            } 
        },
        /**
         * Add a component to the grid resulting in a step
         * @param {string} col The ID (1 to 10) of the column
         * @param {number} row The ID (1 to 9) of the step
         * @param {Object} component The component definition to add
         * @returns {Object} The step definition added
         */
        addComponent: function(col, row, component) {
            if (!row) {
                if (col.toString().match(/[A-Z]\d+/))
                    row = parseRow(col);
                else
                    row = this.nextRow(col)
                if (row>this.nextRow(col)) throw new Error("Cannot add component to that row position " + col);
                col = parseCol(col)
            }
            let step = this.getStep(col, row);
            if (step.reference != null) throw new Error("Step " + col + row + " is not empty!");
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
         * Export pipeline definition as an object
         * @returns {Object}
         */ 
        export: function() {
            let res = {};
            // Export all properties in pipelineDef
            Object.assign(res, this.pipelineDef)
            // Overwriting all non-empty steps
            res.steps.length = 0;
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
        /**
         * Return array of steps
         * @returns {Array}
         */ 
        getSteps: function() {
            let res = [];
            for (let r=1; r<=ROWS; r++) {
                for (let c=1; c<=COLS; c++) {
                    let step = this.getStep(c, r);
                    if (step.reference !== null) {
                        res.push(step);
                    }
                }
            }
            return res;
        },
        /**
         * Move a step from one position to another
         * @param {string} fromId 
         * @param {string} toId 
         */
        moveStep: function(fromId, toId) {
            if (getStep(toId).reference !== null) throw new Error("Step " + toId + " is not empty!");
            let step = getStep(fromId);
            this.removeStep(fromId);
            let row = parseRow(toId);
            let col = parseCol(toId);
            columns[col-1][row-1] = step;
        },
        /**
         * Remove/clear a step
         * @param {string} id
         */
        removeStep: function(id) {
            let row = parseRow(id);
            let col = parseCol(id);
            columns[col-1][row-1] = emptyStep(id);
        },
        /**
         * Return next available row in a column
         * @param {string} col
         * @returns {number}
         */
        nextRow: function(col) {
            let column = getColumn(col);
            for (let r=0; r<column.length; r++)
                if (column[r].reference === null)
                    return r+1; // First empty row
            return null;
        },
        /**
         * Return the definition for unit testing
         * @returns {Object} The in-memory pipeline which was loaded
         */
        getDefinition: function() {
            return this.pipelineDef;
        },
        /**
         * @returns {number} The number of columns
         */
        columnCount: function() {
            return columns.length;
        },
        /**
         * @returns {number} The number of rows
         */
        rowCount: function() {
            return columns[0].length;
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
        getStep: getStep
    };
    /**
     * Takes "A22" and returns 22
     * @param {string} col
     * @returns {number}
     */
    function parseRow(col) {
        if (!col.toString().match(/[A-Z]\d+/)) throw new Error("Invalid step reference '" + col + "'!")
        return parseInt(col.toString().substring(1))
    }
    /**
     * Takes "A22" and returns 1
     * @param {string} col 
     * @returns {any} 
     */
    function parseCol(col) {
        return !isNaN(parseInt(col))?col:pipeCols.indexOf(col.substring(0,1))+1;
    }
    function getColumn(col) {
        // We may be called as a number or a letter (e.g. "A")
        if (columns.length===0) throw new Error("Pipeline not initialized!");
        if (isNaN(col)) {col = parseCol(col)}
        if (col>=1 && col<=pipeCols.length+1 && col <= columns.length) {
            return columns[col-1];
        } else throw("Invalid column number " + col + " in getColumn!");
    }
    function getStep(col, row) {
        // @ts-ignore We may be called as (1,1) or ("A", 1) or ("A1") 
        if (!row) {row = parseRow(col); col = parseCol(col)}
        let column = getColumn(col);
        if (row>=1 && row<=ROWS && row <= column.length) {
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
        if (getStep(col, row).reference != null) throw new Error("Step " + col + row + " is not empty!")
        columns[parseInt(col)-1][row-1] = step;
    }
    /**
     * Map a step definition in pipeline JSON to Step in UI
     * @param {string} id 
     * @param {Object} stepI 
     * @returns {Object} The UI step
     */
    function pipelineStepToStep(id, stepI) {
        return {
            id: id,
            reference: stepI.reference,
            name : stepI.name,
            parameters: stepI.parameters,
            input: stepI.input
        }
    }
    /**
     * Map a component Definition to a new Step in the UI
     * @param {string} id 
     * @param {Object} component 
     * @returns {Object} The new UI Step based on the component
     */
    function component2Step(id, component) {
        return {
            id: id,
            reference: component.reference,
            parameters: component.parameters||[],
            input: component.input||null,
            output: component.output||null
        };
    }
    /**
     * Map a Step in the UI to step definition in pipeline JSON
     * @param {string} id 
     * @param {Object} step 
     * @returns {Object} step definition according to pipeline.json 
     */
    function stepToPipelineStep(id, step) {
        return {
            id: id,
            reference: step.reference,
            name: step.name ,
            parameters: step.parameters,
            input: step.input,
            output: step.output
        }
    }
    /**
     * Return an empty UI Step
     * @param {string} id 
     */
    function emptyStep(id) {
        return {id: id, reference: null, name : null}
    }
})();

/**
 * Tester
 */
if (typeof process !== "undefined") {
(function pipelineManagerTest(verbose) {
    let tests = 0;
    let fails = 0;
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
    let testPipeline = fs.readFileSync(path.resolve(__dirname, '../../examples/pipeline1/pipeline.json'), "utf8").trim();
    //testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"../components/ReadFile.ps1", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"../components/CSV2JSON.ps1", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"../components/SelectFields.ps1", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
    // @ts-ignore
    let testComponent = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../examples/components/CSV2JSON.json'), "utf8").trim());
    //testComponent = { "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": { "FieldSeparator": { "type": "string", "default": ",", "description": "Specifies the field separator. Default is a comma." } }, "input":"text/csv", "output":"json/array"};

    try{

        console.clear();

        // Check a new pipeline
        pipelineManager.reset();
        assert(pipelineManager.columnCount()===pipeCols.length, "We have the right number of columns ("+pipeCols.length+")")
        assert(pipelineManager.rowCount()===9, "We have the right number of rows (9)")
        assert(pipelineManager.nextRow("A")===1, "Next empty row in column A is 1")
        
        // Getting and Adding Steps
        assert('pipelineManager.getStep(1, 1).reference === null', "Step A1 is initialized")
        assert(()=>pipelineManager.addComponent(1, 1, {reference: "foo"}).reference === "foo", "Step A1 is set to foo")
        assert(pipelineManager.nextRow("A")===2, "Next empty row in column A is 2")
        assert('pipelineManager.addComponent("B", null, {reference: "bar"}).reference === "bar"', "Step B1 is set to bar")
        assert('pipelineManager.addComponent("C3", null, testComponent).reference=="CSV2JSON.ps1"', "Add component to wrong row", true)
        assert('pipelineManager.addComponent("C1", null, testComponent).reference=="CSV2JSON.ps1"', "Add C1 component")
        assert('pipelineManager.addComponent("C", null, testComponent).reference=="CSV2JSON.ps1"', "Add C component")
        assert('pipelineManager.addComponent("C", null, testComponent).reference=="CSV2JSON.ps1"', "Add another C component")
        assert('pipelineManager.getStep("C", 3).reference !== null', "Step C3 is set")
        let step = pipelineManager.getStep("C3");
        assert(()=>step.parameters.length===3, "CSV2JSON should have 3 parameters");

        // Moving steps
        assert(()=>pipelineManager.moveStep("C3", "A1"), "Step can't be moved over existing step", true);
        assert(()=>pipelineManager.getStep("D4").reference===null, "Step D4 should be empty");
        assert(()=>pipelineManager.getStep("A1").reference!==null, "Step A1 should not be empty");
        assert(()=>pipelineManager.getStep("C3").reference!==null, "Step C3 should not be empty"); 
        pipelineManager.moveStep("C3", "D4")
        let c3 = pipelineManager.getStep("C3");
        let d4 = pipelineManager.getStep("D4");
        assert(()=>d4.reference=="CSV2JSON.ps1" && c3.reference === null, "Step C3 moved to D4");

        // Removing steps
        pipelineManager.removeStep("D4");
        assert(()=>pipelineManager.getStep("D4").reference === null, "Step D4 is removed")

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
        //fs.writeFileSync("C:\\temp\\pipeline.json", pipelineStr, "utf-8");

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
}