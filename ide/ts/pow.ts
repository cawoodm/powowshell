/**
 * The wrapper for all our pow commands in PowerShell
 * In general, methods return a POWResult e.g.
 *  {
 *      success: true,
 *      output: "42",
 *      messages: [
 *          {type: "INFO", message: "42"},
 *          {type: "WARNING", message: "You asked the wrong question!"}
 *      ],
 *      object: {"could": "be", "any": "thing"}
 *  }
 */
import * as POWType from "./pow-types";
import fs from "fs";
import path from "path";
import {PShell} from "./pshell";

const pow = (function(){

    let workspace = ".";
    let execOptions : {debug: boolean; PSCore: string, userProfile: boolean} = {debug: false, PSCore: "pwsh", userProfile: true};

    /**
     * Initialize a workspace
     * @param {string} workspacePath: The path to the workspace root
     * @returns {Promise} Promise with true if successful
     */
    async function init(workspacePath) {
        return new Promise(function(resolve, reject) {
            _POWPromise(`pow workspace ${workspacePath} | ConvertTo-Json`, true, true).then((result: POWType.POWResult)=>{
                if (result.success) {
                    workspace = result.object
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
            _POWPromise("pow version").then((result: POWType.POWResult)=>{
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
     * Return a built pipeline definition
     * @param {string} path Path to the pipeline ("!pipeline1" for default workspace)
     * @returns {Promise} Promise with a POWResult
     */
    async function pipeline(path) {
        // If we don't have a !* or a */* path, add the ! prefix
        if (!path.match(/^!/) && !path.match(/[\\/]/)) path = "!"+path;
        return execStrictJSON(`pow pipeline "${path}" -Export`);
    }

    /**
     * Save a pipeline definition to pipeline.json
     * @param {POWPipelineDef} pipeline Path to the pipeline (e.g. "!pipeline1" for default workspace)
     * @param {string} pipelineId Pipeline ID
     * @returns {Promise} Promise with a POWResult
     */
    async function save(pipeline: POWType.PipelineDef, pipelineId) {
        pipelineId = pipelineId || pipeline.id;
        pipeline.id = pipelineId;
        let data = JSON.stringify(pipeline, null, 2);
        return new Promise(function(resolve, reject) {
            if (!pipelineId) return reject(new POWError("No pipeline id specified!", []));
            let directory = path.resolve(workspace, pipelineId);
            if (!fs.existsSync(directory)) fs.mkdirSync(directory);
            fs.writeFile(path.resolve(directory, "pipeline.json"), data, (err)=>{
                if (!err) resolve(new POWResult(true, "Pipeline saved!", [], {}));
                else reject(new POWError(err.message, []));
            })
        });
    }

    /**
     * Load a pipeline definition from a pipeline.json
     * @param {string} path Path to the pipeline (e.g. "!pipeline1" for default workspace)
     * @returns {Promise} Promise with a POWPipelineDef
     */
    async function load(pipeline: string) {
        return new Promise(function(resolve, reject) {
            fs.readFile(pipeline, "utf8", (err, data)=>{
                data = data.replace(/^\uFEFF/, ''); // Strip BOM
                if (!err) resolve(new POWResult(true, "Pipeline loaded!", [], JSON.parse(data)));
                else reject(new POWError(err.message, []));
            })
        });
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
        return execStrictJSON(`pow verify "${pipelineId}" $null -export`);
    }

    /**
     * Run a built pipeline
     * @param {string} path Path to pipeline (or "!pipelineId" for default workspace)
     * @returns {Promise} Promise with a POWResult containing an object (pipeline result)
     */
    async function run(path) {
        return execStrictJSON(`pow run "${path}" $null -export`);
    }

    /**
     * Preview a step
     * @param {string} pipelineId Pipeline ID
     * @param {StepDef} step Step definition
     * @param {Object} component Component definition
     * @returns {Promise} Promise with a POWResult containing an object (step result)
     */
    async function preview(pipelineId, step, component) {
        let path = component.executable;
        //if (component.type=="component") path = "!"+path;
        let params = JSON.stringify(step.parameters).replace(/"/g, '`"');
        //console.log(`pow preview "${path}" "${params}"`)
        if (component.output.match(/text\/json/))
            // JSON Component returns an object
            return execStrictJSON(`pow preview "${pipelineId}" "${path}" "${params}"`);
        else
            // Normal component returns a string
            return execStrict(`pow preview "${pipelineId}" "${path}" "${params}"`);
    }

    /**
     * Inspect a component
     * @param {string} path Path to component (or "!componentReference" for default workspace)
     * @returns {Promise} Promise with a POWResult (.object=component definition)
     */
    async function inspect(path) {
        return execStrictJSON(`pow inspect "${path}" | ConvertTo-JSON -Depth 4`);
    }

    /**
     * Return array of components
     * @param {string} path Path to the components ("!" for default workspace)
     * @returns {Promise} Promise with a POWResult (.object=Array of component definitions)
     */
    async function components(path = "!") {
        return execStrictJSON(`pow components "${path}" -Export`);
    }

    /**
     * Return array of cmdlets
     * @returns {Promise} Promise with a POWResult (.object=Array of cmdlet definitions)
     */
    async function cmdlets(filter="") {
        return execStrictJSON(`pow cmdlets export "${filter}"`);
    }

    /**
     * Return an example of a component's usage
     * @param {string} path Path to the component ("!" for default workspace)
     * @returns {Promise} Promise with a POWResult(.object=Array of examples)
     */
    async function examples(path:string) {
        return execStrictJSON(`pow examples "${path}" -Export -AsArray`);
    }

    /**
     * Intercept a promise and parse the result as a POWResult
     * @param {String} command: The powershell command to execute
     * @param {boolean} strict: Throw exception if we have errors
     * @returns {Promise} Promise with a POWResult
     */
    function _POWPromise(command, strict=false, json=false) {
        return new Promise(function(resolve, reject) {
            const pshell = PShell();
            let pid = pshell.init({
                pwsh: execOptions.PSCore==="pwsh"?true:false,
                verbose: execOptions.debug,
                noProfile: !execOptions.userProfile
            });
            if (execOptions.debug) console.log("EXEC", pid, command);
            pshell.exec(command, [])
                .then((out: any)=>{
                    try {
                        if (execOptions.debug) console.log("STDOUT", pid, out.stdout.substring(0,200));
                        let result = _processResult(out, json);
                        if (strict && !result.success)
                            reject(new POWError(`Failure of '${command}'!`, result.messages))
                        else
                            resolve(result);
                    } catch (e) {
                        reject(e);
                    }
                }).catch((err)=>{
                    try {
                      // TODO: If strict=true we should probably not resolve here
                      const errorObject = JSON.parse(err.message.trim().replace(/^\uFEFF/, '')); // Strip BOM
                      resolve(_processResult({stderr: errorObject}));
                    } catch(e) {
                      if (strict) reject(_processResult({stderr: err.message}));
                      else resolve(_processResult({stderr: err.message}));
                    }
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
            let msg = typeof out.stderr === 'object' ? out.stderr.message : out.stderr;
            let obj = typeof out.stderr === 'object' ? out.stderr : null;
            messages.push(new POWMessage("ERROR", msg, obj))
        }

        let obj = null;
        if (out.stdout) {
          if (json) {
          // Process JSON output
            try{
                obj = JSON.parse(out.stdout)
            } catch(e) {
                messages.unshift(new POWMessage("ERROR", e.message, null))
                throw new POWError(`POW102:Invalid JSON Object: ${e.message}`, messages)
            }
          } else {
              // Get stdout as a series of INFO messages
              let outlines = out.stdout.split(/\r?\n/); // TODO: INTEROP
              for (let o=0; o < outlines.length && o < 25; o++) {
                  messages.push(new POWMessage("INFO", outlines[o], null))
              }
          }
        }

        return new POWResult(success, out.stdout, messages, obj)
    }

    return {
        init,
        execOptions,
        version,
        build,
        verify,
        run,
        preview,
        inspect,
        components,
        cmdlets,
        examples,
        pipeline,
        save,
        load,
        exec,
        execStrict,
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
const POWMessage = function(type: string, message: string, obj: any) {
    this.type =  type || "INFO";
    this.message = message;
    this.obj = obj || null;
}

/**
 * A POWError consists of
 *  - A summary message
 *  - An array of POWMessages
 */
class POWError extends Error implements POWType.POWError{
    messages: string[];
    constructor(message: string, messages: string[]) {
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