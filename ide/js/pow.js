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

    const pshell = require("./pshell");
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
     * Execute any powershell command
     *  Will not throw an error if errors are written to stderr
     * @param {String} command: The powershell command to execute
     * @returns {Promise} Promise with a POWResult
     */
    async function exec(command) {
        return _POWPromise(command, false);
    }
    /**
     * Execute any powershell command
     *  Will throw an error if errors are written to stderr
     * @param {String} command: The powershell command to execute
     * @returns {Promise} Promise with a POWResult
     */
    async function execStrict(command) {
        return _POWPromise(command, true);
    }
    /**
     * Execute any powershell command and return an object from the JSON output
     *  Will throw an error if errors are written to stderr
     * @param {String} command: The powershell command to execute
     * @returns {Promise} Promise with a POWResult
     */
    async function execStrictJSON(command) {
        return _POWPromise(command, true, true);
    }

    /**
     * Return a built pipeline definition (pipeline.json)
     * @param {string} path Path to the pipeline ("!pipeline1" for default workspace)
     * @returns {Promise} Promise with a POWResult
     */
    async function pipeline(path) {
        if (!path.match(/^!/) && !path.match(/[\\/]/)) path = "!"+path;
        return execStrictJSON(`pow pipeline "${path}" export`);
    }

    /**
     * Savea pipeline definition to pipeline.json)
     * @param {string} path Path to the pipeline (e.g. "!pipeline1" for default workspace)
     * @param {POWPipelineDef} pipeline Path to the pipeline (e.g. "!pipeline1" for default workspace)
     * @returns {Promise} Promise with a POWResult
     */
    async function save(path) {
        if (!path.match(/^!/) && !path.match(/[\\/]/)) path = "!"+path;
        return execStrictJSON(`pow pipeline "${path}" export`);
    }

    /**
     * Builds a pipeline from it's definition
     * @param {string} pipelineId The ID of the pipeline
     * @returns {Promise} Promise with a POWResult
     */
    async function build(pipelineId) {
        return execStrict(`pow build "${pipelineId}"`);
    }

    /**
     * Verify a built pipeline
     * @param {string} pipelineId The ID of the pipeline
     * @returns {Promise} Promise with a POWResult
     */
    async function verify(pipelineId) {
        return execStrict(`pow verify "${pipelineId}"`);
    }

    /**
     * Run a built pipeline
     * @param {string} path Path to pipeline (or "!pipelineId" for default workspace)
     * @returns {Promise} Promise with a POWResult containing an object (pipeline result)
     */
    async function run(path) {
        return execStrictJSON(`pow run "${path}"`);
    }

    /**
     * Inspect a component
     * @param {string} path Path to component (or "!componentReference" for default workspace)
     * @returns {Promise} Promise with a POWResult containing an object (component definition)
     */
    async function inspect(path) {
        return execStrictJSON(`pow inspect "${path}" | ConvertTo-JSON -Depth 4`);
    }

    /**
     * Run a built pipeline
     * @param {string} path Path to the components ("!" for default workspace)
     * @returns {Promise} Promise with a POWResult
     */
    async function components(path="!") {
        return execStrictJSON(`pow components "${path}" export`);
    }

    /**
     * Intercept a promise and parse the result as a POWResult
     * @param {String} command: The powershell command to execute
     * @param {boolean} strict: Throw exception if we have errors
     * @returns {Promise} Promise with a POWResult
     */
    function _POWPromise(command, strict=false, json=false) {
        return new Promise(function(resolve, reject) {
            if (execOptions.debug) console.debug("EXEC", command);
            pshell.exec(command, execOptions)
                .then((out)=>{
                    try {
                        let result = _processResult(out, json);
                        if (strict && !result.success)
                            reject(new POWError(`Failure of '${command}'!`, result.messages))
                        else
                            resolve(result);
                    } catch (e) {
                        reject(e);
                    }
                }).catch((err)=>{
                    reject(err);
                });
        });
    }

    /**
     * Process powershell result returning a POWResul
     * @param {Object} out: stdout and stderr components
     * @param {boolean} json: Parse stdout as JSON
     * @returns {POWResult} The success, output and messages
     */
    function _processResult(out, json=false) {
        // TODO: Handle -Verbose output as type=DEBUG
        let success = true;
        let messages = [];

        // TODO: Get warnings as a series of WARNING messages

        // Get stderr as a series of ERROR messages
        if (out.stderr) {
            success = false;
            messages.push(new POWMessage("ERROR", out.stderr))
        }

        // Get stdout as a series of INFO messages
        let outlines = out.stdout.split(/\r?\n/);
        for (let o=0; o < outlines.length; o++)
            messages.push(new POWMessage("INFO", outlines[o]))

        let obj = null;
        // Process JSON output
        if (json) try{obj = JSON.parse(out.stdout)}catch(e){
            messages.unshift(new POWMessage("ERROR", e.message))
            throw new POWError(`Invalid JSON Object: ${e.message}`, messages)
        }
            
        return new POWResult(success, out.stdout, messages, obj)
    }

    return {
        init: init,
        execOptions: execOptions,
        version: version,
        build: build,
        verify: verify,
        run: run,
        inspect: inspect,
        components: components,
        pipeline: pipeline,
        exec: exec,
        execStrict: execStrict,
        getWorkspace: ()=>workspace
    }

})();

/**
 * Result and message class
 * @param {boolean} success: True if no errors
 * @param {string} output: The raw stdout string
 * @param {POWMessage[]} messages: List of all messages
 * @param {Object} object: The resulting JSON parsed as an obhecrt
 */
const POWResult = function(success, output, messages, object) {
    this.success  = success;
    this.output   = output;
    this.object   = object;
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