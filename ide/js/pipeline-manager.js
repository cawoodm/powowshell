/*
 PipelineManager
 Manage the pipeline interfacing between the UI/user (dragging stuff around) and the pipeline.json output
 The pipeline is represented in meory as a list of columns with steps
 
 Functionality:
    reset(): Like an init() which can be called repeatedly to clear the pipeline
    import(): Read/de-serialize a pipeline JSON document into memory
    export(): Save/serialize a pipeline JSON document to JSON
    verifyPipeline(): Check in-memory pipeline for consistency
    addStep(): Add a new step from a componet definition
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
        ref: "file-csv-ps1",            // The path to the component
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
let pipelineManager = {
    /**
     * Initialize a new, empty pipeline
      */ 
    reset: function() {
        this.columns = [];
        for (let c=0; c<pipeCols.length; c++) {
            let column = [];
            for (let r=0; r<9; r++) {
                let step = {id: pipeCols[c]+(r+1).toString(), ref: null}
                column.push(step);
            } 
            this.columns.push(column);
        } 
    },
    /**
     * Return a column indexed from 1 to 10 (A-K)
     * @param {number|string} col The ID of the column to return (1-9 or A-Z)
     */
    getColumn: function(col) {
        // We may be called as a number or a letter (e.g. "A")
        if (typeof col !== "number") col = pipeCols.indexOf(col)+1;
        if (col>=1 && col<=pipeCols.length+1) {
            return this.columns[col-1];
        } else throw("Invalid column number " + col + " in getColumn!");
    },
    /**
     * Return a step indexed from A1 to Z9
     * @param {number} col The ID (1 to 10) of the column to return
     * @param {number} row The ID (1 to 9) of the step to return
     */
    getStep: function(col, row) {
        // We may be called as (1,1) or ("A", 1) or ("A1")
        if (!row) {
            col = col.substring(0,1)
            row = col.substring(1, 2)
        }
        let column = this.getColumn(col);
        if (row>=1 && row<=9) {
            return column[row-1];
        } else throw("Invalid row number " + row + " in getStep!");
    },
    /**
     * Add a step to the grid
     * @param {number} col The ID (1 to 10) of the column
     * @param {number} row The ID (1 to 9) of the step
     * @param {Object} component The component definition to add
     */
    addStep: function(col, row, component) {
        let step = this.getStep(col, row);
        if (step.ref != null) throw "Step " + col + row + " is not empty!"
        step = {
            id: step.id,
            ref: component.ref
        };
        this.columns[col-1][row-1] = step;
    },
    /**
     * Import pipeline definition from JSON
     * @param {Object|string} def The JSON object defining the pipeline from pipeline.json
     */
    import: function(def) {

    },
    /**
     * Export pipeline definition to JSON
     * @return {Object|string}
     */ 
    export: function() {
        
    },
    columnsToString: function() {
        for (let r=0; r<9; r++) {
            let s = "";
            for (let c=0; c<pipeCols.length; c++) {
                let step = this.getStep(c+1, r+1);
                s += step.id + " (" + step.ref + ") ";
            }
            console.log(s);
        }
    }
};

/**
 * Tester
 */
(function pipelineManagerTest() {
    let tests = 0;
    let fails = 0;
    function assert(cond, msg) {
        try {
            tests++;
            if (eval(cond)) {
                //console.log("OK: "+msg);
            } else {
                fails++;
                console.log("*** FAIL: "+msg);
            }
        } catch {
            fails++;
            console.log("*** FAIL: "+msg);
        }
    }
    pipelineManager.reset();
    assert(pipelineManager.columns.length===pipeCols.length, "We have the right number of columns ("+pipeCols.length+")")
    assert(pipelineManager.columns[0].length===9, "We have the right number of rows (9)")
    
    //console.log(pipelineManager.getStep(1, 1));
    assert('pipelineManager.getStep(1, 1).ref === null', "Step A1 is initialized")
    pipelineManager.addStep(1, 2, {ref: "foo"});
    assert('pipelineManager.getStep("A", 2).ref === "foo"', "Step A2 is set to foo")

    if (fails) {
        pipelineManager.columnsToString();
        console.error("\x1b[31m", fails + " of " + tests + " failed")
    } else
        console.log("\x1b[36m", "All test passed successfully")
})();

