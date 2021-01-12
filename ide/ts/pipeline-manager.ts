/**
 * PipelineManager
 * Manage the pipeline interfacing between the UI/user (dragging stuff around) and the pipeline.json output
 * The pipeline is represented in meory as a list of columns with steps
 *
 * Functionality:
 *    reset(): Like an init() which can be called repeatedly to clear the pipeline
 *    import(): Read/de-serialize a pipeline JSON document into memory
 *    export(): Save/serialize a pipeline JSON document to JSON
 *    verifyPipeline(): Check in-memory pipeline for consistency
 *    addComponent(): Add a new step from a componet definition
 *    removeStep(): Remove a step from a pipeline
 *    moveStep(): Move a step from one position to another
 * HelperS:
 *    getColumn(c): Get a column (array of steps)
 *    getStep(c, r): Get a step from within column c at row r
 *
 * Data Model:
 *  columns: Array of columns representing [A-I]
 *   column: Array of steps representing [1-9]
 *    step: {
 *        id: "B1",                       // The id of the step (*)
 *        reference: "file-csv-ps1",            // The path to the component (*)
 *        name : "Read Voters File",      // short readable name of the step (*)
 *        parameters: {
 *            "p1": "value",              // Parameter p1 and it's value
 *            "p2": "value",              // Parameter p2 and it's value
 *        },
 *        input: "A1"                     // Which step's output is my input
 *    }
 *
 */
import * as POWType from "./pow-types";
// @ts-check
let pipelineManager = (function() {
    const pipeCols = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
    const COLS = pipeCols.length;
    const ROWS = 9;
    let columns = [];
    let dirty = false;
    const pipelineDefNull = function() {return {id: null, name: null, description: null, parameters: {}, globals: {}, steps: [], input: {}, output: {}}};
    let pipelineDef: POWType.PipelineDef = pipelineDefNull();

    // Public members
    return {
        /**
         * Initialize a new, empty pipeline
         */
        reset: function() {
            dirty = false;
            columns = [];
            pipelineDef = pipelineDefNull();
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
                //if (row>this.nextRow(col)) throw new Error("Cannot add component to that row position " + col);
                col = parseCol(col)
            }
            let step = this.getStep(col, row);
            if (step.reference != null) throw new Error("Step " + col + row + " is not empty!");
            step = component2Step(step.id, component);
            dirty = true;
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
            pipelineDef = def;
            return true;
        },
        /**
         * Export pipeline definition as an object
         * @returns {Object}
         */
        export: function() {
            let res = pipelineDefNull();
            // Export all properties in pipelineDef
            Object.assign(res, pipelineDef)
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
        getRows: function() {
            let res = [];
            for (let r=1; r<=ROWS; r++) {
                let row = [];
                for (let c=1; c<=COLS; c++) {
                    row.push(this.getStep(c, r));
                }
                res.push(row);
            }
            return res;
        },
        /**
         * Return array of columns
         * @returns {Array}
         */
        getColumns: function() {
            return columns;
        },
        /**
         * Set a step directly
         * @param {Object} newStep
         */
        setStep: function(newStep) {
            dirty = true;
            let row = parseRow(newStep.id);
            let col = parseCol(newStep.id);
            columns[parseInt(col)-1][row-1] = newStep;
            // TODO: Validation
            return true;
        },
        /**
         * Move a step from one position to another
         * @param {string} fromId
         * @param {string} toId
         */
        moveStep: function(fromId, toId) {
            dirty = true;
            if (getStep(toId).reference !== null) throw new Error("Step " + toId + " is not empty!");
            let step = getStep(fromId);
            this.removeStep(fromId);
            step.id = toId;
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
            dirty = true;
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
         * Return all inputs available to a step
         *  i.e. the outputs of all steps previous to it
         * @param {string} id
         * @returns {string[]} Step IDs of available outputs
         */
        getAvailableInputs: function(id) {
            let res = [];
            let col = parseCol(id);
            let row = parseRow(id);
            for (let r=1; r<=ROWS; r++)
              for (let c=1; c<=COLS; c++)
                if (r < row || r==row && c<col) {
                    let step = this.getStep(c, r);
                    // TODO: Check step as outputs!
                    if (step.reference) res.push(step.id);
                }
            return res;
        },
        /**
         * Return the definition for editing form/unit testing
         * @returns {Object} The in-memory pipeline which was loaded
         */
        getDefinition: function() {
            return pipelineDef;
        },
        /**
         * Set the definition from editing form
         * @def {POWType.PipelineDef} The in-memory pipeline to be set
         */
        setDefinition: function(def: POWType.PipelineDef) {
            pipelineDef = def;
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
         * @returns {boolean} True if pipeline was modified
         */
        isDirty: function() {
            return dirty;
        },
        /**
         * Clears the dirty flag (after e.g. a save)
         */
        setClean: function() {
            dirty = false;
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
        pipeCols: pipeCols
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
     * @returns {number}
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
    function getStep(col, row?) {
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
            description: stepI.description,
            stream : stepI.stream,
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
        let stepParams = {};
        // We should not initialize cmdlet steps to their default because
        //  their default may be a .NET type/enum which we can't use
        component.parameters.forEach((p)=>stepParams[p.name]=null);
        return {
            id: id,
            reference: component.reference,
            name: component.name,
            description: null,
            stream: null,
            parameters: stepParams,
            input: null,
            output: null
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
            name: step.name,
            description: step.description,
            stream: step.stream,
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
// @ts-ignore
if (typeof module !== "undefined") module.exports = pipelineManager;