/**
 * The wrapper for all our pow commands in PowerShell
 * In general, methods return a POWResult e.g.
 *  {
 *      success: true,
 *      output: "42",
 *      messages: [
 *          {type: "INFO", message: "42"},
 *          {type: "WARNING", message: "You asked the wrong question!"}
 *      ]
 *  }
 */
// @ts-check
const pow = (function(){

    let pshell = require("./pshell");
    let workspace = ".";
    let execOptions = {};

    /**
     * Initialize a workspace
     * @param {string} workspacePath: The path to the workspace root
     * @returns {Promise} Promise with true if successful
     */
    async function init(workspacePath) {
        return new Promise(function(resolve, reject) {
            _POWPromise(`pow workspace ${workspacePath}`, true).then((result)=>{
                if (result.success) {
                    workspace = workspacePath
                    resolve(result);
                } else reject("Could not set workspace "+workspacePath)
            }).catch(reject);
        });
    }

    /**
     * Return version information
     * @returns {Promise} Promise with the POW Version info
     */
    async function version() {
        return new Promise(function(resolve, reject) {
            _POWPromise("pow version").then((result)=>{
                if (result.success)
                    resolve(result.output)
                else
                    reject(result)
            }).catch(reject);
        });
    }

    /**
     * Return version information
     * @param {String} command: The powershell command to execute
     * @returns {Promise} Promise with a POWResult
     */
    async function exec(command) {
        return _POWPromise(command, false);
    }
    async function execStrict(command) {
        return _POWPromise(command, true);
    }


    /**
     * Builds a pipeline from it's definition
     * @param {string} pipelineId The ID of the pipeline
     */
    function build(pipelineId) {
        if (!pipelineId) throw(new POWError("No pipeline Id provided to pow builder!"));
        if (pipelineId==="error") throw(new POWError("Booo!", [new POWMessage("ERROR", "Fail bru!")]));
        //return new POWResult(true, null);
    }

    /**
     * Intercept a promise and parse the result as a POWResult
     * @param {String} command: The powershell command to execute
     * @param {boolean} strict: Throw exception if we have errors
     * @returns {Promise} Promise with a POWResult
     */
    function _POWPromise(command, strict=false) {
        return new Promise(function(resolve, reject) {
            if (execOptions.debug) console.debug("EXEC", command);
            pshell.exec(command, execOptions)
                .then((out)=>{
                    let result = _processResult(out);
                    if (strict && !result.success)
                        reject(result)
                    else
                        resolve(result);
                }).catch((err)=>{
                    reject(err);
                });
        });
    }

    /**
     * Process powershell result
     * @param {Object} out: stdout and stderr components
     * @returns {POWResult} The success, output and messages
     */
    function _processResult(out) {
        let success = true;
        let messages = [];
        if (out.stderr) {
            success = false;
            messages.push(new POWMessage("ERROR", out.stderr))
        }
        let outlines = out.stdout.split("\r\n");
        for (let o=0; o < outlines.length; o++)
            messages.push(new POWMessage("INFO", outlines[o]))
        return new POWResult(success, out.stdout, messages)
    }

    return {
        init: init,
        execOptions: execOptions,
        version: version,
        build: build,
        exec: exec,
        execStrict: execStrict,
        getWorkspace: function(){return workspace}
    }

})();

/**
 * Result and message class
 * @param {boolean} success 
 * @param {string} output
 * @param {POWMessage[]} messages 
 */
const POWResult = function(success, output, messages) {
    this.success  = success;
    this.output   = output;
    this.messages = messages || [];
}
/**
 * 
 * @param {string} type The type of message ERROR|WARN|INFO|DEBUG
 * @param {string} message The message text
 */
const POWMessage = function(type, message) {
    this.type =  type || "INFO";
    this.message = message;
}

/**
 * A POWError consists of
 *  - A summary message
 *  - An array of POWMessages
 */
class POWError extends Error {
    constructor(message, messages) {
        super(message);
        this.messages = messages || [];
        this.name = "POWError";
    }
}

if (typeof module !== "undefined") {
    module.exports.pow = pow;
    module.exports.POWResult = POWResult;
    module.exports.POWError = POWError;
}