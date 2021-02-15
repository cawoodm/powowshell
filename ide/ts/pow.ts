/**
 * The wrapper for all our pow commands in PowerShell
 * In general, methods return a POWResult e.g.
 *  {
 *    success: true,
 *    output: "42",
 *    messages: [
 *      {type: "INFO", message: "42"},
 *      {type: "WARNING", message: "You asked the wrong question!"}
 *    ],
 *    object: {"could": "be", "any": "thing"}
 *  }
 */
import * as POWType from "./pow-types";
import fs from "fs";
import path from "path";
import { PShell } from "./pshell";

import POWResult = POWType.POWResult;

const pow = (function () {

  let workspace = ".";
  let verbosePreference: boolean;
  let execOptions: { debug: boolean; PSCore: string, userProfile: boolean } = { debug: false, PSCore: "pwsh", userProfile: true };

  /**
   * Initialize a workspace
   * @param {string} workspacePath: The path to the workspace root
   * @returns {Promise} Promise with true if successful
   */
  async function init(workspacePath, verbose) {
    verbosePreference = verbose === true;
    return new Promise(function (resolve, reject) {
      _POWPromise(`pow workspace ${workspacePath} -Export`, true, true).then((result:  POWResult) => {
        if (result.success && Array.isArray(result.object) && result.object.length === 1) {
          workspace = result.object[0]
          resolve(result);
        } else throw new Error("Could not set workspace " + workspacePath);
          //reject("Could not set workspace " + workspacePath)
      }).catch(reject);
    });
  }

  /**
   * Return version information
   * @returns {Promise<string>} Promise with the POW Version info
   */
  async function version(): Promise<string> {
    return new Promise(function (resolve, reject) {
      _POWPromise("pow version").then((result: POWResult) => {
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
   * @returns {Promise<POWResult>} Promise with a POWResult
   */
  async function exec(command): Promise<POWResult> {
    return _POWPromise(command, false);
  }
  /**
   * Execute any powershell command
   *  Will throw an error if errors are written to stderr
   * @param {String} command: The powershell command to execute
   * @returns {Promise} Promise with a POWResult
   */
  async function execStrict(command): Promise<POWResult> {
    return _POWPromise(command, true);
  }
  /**
   * Execute any powershell command and return an object from the JSON output
   *  Will throw an error if errors are written to stderr
   * @param {String} command: The powershell command to execute
   * @returns {Promise} Promise with a POWResult
   */
  async function execStrictJSON(command): Promise<POWResult> {
    return _POWPromise(command, true, true);
  }

  /**
   * Return a built pipeline definition
   * @param {string} path Path to the pipeline ("!pipeline1" for default workspace)
   * @returns {Promise} Promise with a POWResult
   */
  async function pipeline(path) {
    // If we don't have a !* or a */* path, add the ! prefix
    if (!path.match(/^!/) && !path.match(/[\\/]/)) path = "!" + path;
    const result = await execStrictJSON(`pow pipeline '${path}' -Export`);
    result.object = result?.object && result.object[0];
    return result;
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
    return new Promise(function (resolve, reject) {
      if (!pipelineId) return reject(new POWError("No pipeline id specified!", []));
      let directory = path.resolve(workspace, pipelineId);
      if (!fs.existsSync(directory)) fs.mkdirSync(directory);
      fs.writeFile(path.resolve(directory, "pipeline.json"), data, (err) => {
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
    return new Promise(function (resolve, reject) {
      fs.readFile(pipeline, "utf8", (err, data) => {
        data = data.replace(/^\uFEFF/, ""); // Strip BOM
        if (!err) resolve(new POWResult(true, "Pipeline loaded!", [], JSON.parse(data)));
        else reject(new POWError(err.message, []));
      })
    });
  }

  /**
   * Builds a pipeline from it's definition
   * @param {string} pipelineId The ID of the pipeline
   * @returns {Promise<POWResult>} Promise with a POWResult
   */
  async function build(pipelineId): Promise<POWResult> {
    return execStrict(`pow build '${pipelineId}'`);
  }

  /**
   * Verify a built pipeline
   * @param {string} pipelineId The ID of the pipeline
   * @returns {Promise} Promise with a POWResult
   */
  async function verify(pipelineId): Promise<POWResult> {
    return execStrictJSON(`pow verify '${pipelineId}' $null -Export`);
  }

  /**
   * Run a built pipeline
   * @param {string} path Path to pipeline (or "!pipelineId" for default workspace)
   * @returns {Promise} Promise with a POWResult containing an object (pipeline result)
   */
  async function run(path): Promise<POWResult> {
    // TODO: We should only execStrict if the pipeline has $ErrorActionPreference="Stop"
    return execStrictJSON(`pow run '${path}' $null -Export`);
  }

  /**
   * Run and trace a built pipeline
   * @param {string} path Path to pipeline (or "!pipelineId" for default workspace)
   * @returns {Promise} Promise with a POWResult containing an object (pipeline result)
   */
  async function trace(path): Promise<POWResult> {
    // TODO: We should only execStrict if the pipeline has $ErrorActionPreference="Stop"
    return execStrictJSON(`pow run '${path}' '' trace -Export`);
  }

  /**
   * Preview a step
   * @param {string} pipelineId Pipeline ID
   * @param {StepDef} step Step definition
   * @param {Object} component Component definition
   * @returns {Promise} Promise with a POWResult containing an object (step result)
   */
  async function preview(pipelineId, step, component): Promise<POWResult> {
    let path = component.executable;
    //if (component.type=="component") path = "!"+path;
    let parsedParams = {};
    console.log("component", component)
    Object.keys(step.parameters).forEach(p => {
      let val = step.parameters[p];
      let paramDef = component.parameters.find(cp => cp.name === p) || {type: ''};
      if (paramDef.type.match(/\[]$/)) val = (val || '').split(/,\s*/);
      console.log(p, val, paramDef && paramDef.type);
      parsedParams[p] = val;
    })
    //let params = JSON.stringify(parsedParams).replace(/"/g, "`\"").replace(/\$/g, "`$");
    let params = JSON.stringify(parsedParams).replace(/'/g, "''");
    //console.log(`pow preview '${path}' "${params}"`)
    //if (component.output.match(/text\/json/))
      // JSON Component returns an object
      return execStrictJSON(`pow preview '${pipelineId}' '${path}' '${params}' -Export`);
    /*
    else
      // Normal component returns a string
      return execStrict(`pow preview "${pipelineId}" '${path}' "${params}"`);
      */  
  }

  /**
   * Inspect a component
   * @param {string} path Path to component (or "!componentReference" for default workspace)
   * @returns {Promise} Promise with a POWResult (.object=component definition)
   */
  async function inspect(path) {
    const result = await execStrictJSON(`pow inspect '${path}' -Export`);
    result.object = result?.object && result.object[0];
    return result;
  }

  /**
   * Return array of components
   * @param {string} path Path to the components ("!" for default workspace)
   * @param {boolean} reload Whether to reload all components, bypassing cache
   * @returns {Promise} Promise with a POWResult (.object=Array of component definitions)
   */
  async function components(path, reload = false) {
    path = path || '!';
    return execStrictJSON(`pow components '${path}' ${reload ? "generate" : ""} -Export`);
  }

  /**
   * Return array of cmdlets
   * @returns {Promise} Promise with a POWResult (.object=Array of cmdlet definitions)
   */
  async function cmdlets(filter = "") {
    const result = await execStrictJSON(`pow cmdlets export '${filter}'`);
    result.object = result?.object && result.object[0];
    return result;
  }

  /**
   * Return an example of a component's usage
   * @param {string} path Path to the component ("!" for default workspace)
   * @returns {Promise} Promise with a POWResult(.object=Array of examples)
   */
  async function examples(path: string) {
    return execStrictJSON(`pow examples '${path}' -Export`);
  }

  /**
   * Intercept a promise and parse the result as a POWResult
   * @param {String} command: The powershell command to execute
   * @param {boolean} strict: Throw exception if we have errors
   * @returns {Promise} Promise with a POWResult
   */
  function _POWPromise(command, strict = false, json = false): Promise<POWResult> {
    return new Promise(function (resolve, reject) {
      const pshell = PShell();
      let pid = pshell.init({
        pwsh: execOptions.PSCore === "pwsh" ? true : false,
        verbose: execOptions.debug,
        noProfile: !execOptions.userProfile
      });
      command = command + (verbosePreference?' -Verbose':'');
      if (execOptions.debug) console.log("EXEC", pid, command);
      pshell.exec2(command, [])
        .then((out: any) => {
          try {
            if (execOptions.debug) console.log("STDOUT", pid, out.stdout.substring(0, 200));
            let result = _processResult(out, json);
            if (strict && !result.success)
              reject(new POWError(`Failure of '${command}'!`, result.messages))
            else
              resolve(result);
          } catch (e) {
            reject(e);
          }
        }).catch((err) => {
          if (json) {
            try {
              const errorObject = JSON.parse(err.message.trim().replace(/^\uFEFF/, "")); // Strip BOM
              // TODO: If strict=true we should probably not resolve here
              resolve(_processResult({ stderr: errorObject }));
            } catch (e) {
              // JSON was expected but error could not be parsed
              reject(_processResult({ stderr: err.message }));
            }
          }
          if (strict) reject(_processResult({ stderr: err.message }));
          // We have to resolve here in non-strict mode because this is the
          //  only way we get all output in a script with errors
          //  because node-powershell throws errors as soon as Write-Error is called
          else resolve(_processResult({ stderr: err.message }));
        });
    });
  }

  /**
   * Process powershell result returning a POWResul
   * @param {Object} out: stdout and stderr components
   * @param {boolean} json: Parse stdout as JSON
   * @returns {POWResult} The success, output and messages
   */
  function _processResult(out, json = false): POWResult {
    // TODO: Handle -Verbose output as type=DEBUG
    let success = true;
    let messages = [];
    const MessageTypes = {"I":"INFO","V":"VERBOSE","W":"WARNING","E":"ERROR","X":"ABORT"};

    // Process stderr for ERROR messages
    //  Either one message per line OR
    //  One complete JSON object
    if (out.stderr) {
      success = false;
      if (out.stderr.trim().match(/^{.*}$/)) try {out.stderr = JSON.parse(out.stderr)}catch{}
      if (typeof out.stderr === "object") {
        messages.push(new POWMessage(MessageTypes[out.stderr.powType], out.stderr.message, out.stderr))
      } else {
        // Drop trailing newlines which make primitives like "foo" into "foo\n"
        out.stderr = out.stderr.trim();
        // Split output by newline, skipping empty lines
        let outlines = out.stderr.split(/\r?\n/).filter(l => !!l);
        messages.push(...outlines.map(parseErrorLine));
      }
    }

    let obj = null;
    if (out.stdout) {
      // Drop trailing newlines which make primitives like "foo" into "foo\n"
      out.stdout = out.stdout.trim();
      // Split output by newline, skipping empty lines
      let outlines = out.stdout.split(/\r?\n/).filter(l => !!l);
      if (json) {
        // Process JSON output
        //  each line should be a JSON object
        obj = [];
        outlines.filter(line => !!line).map(line => {
          try {
            let lineObj = JSON.parse(line);
            if (lineObj.powType) {
              messages.push(new POWMessage(MessageTypes[lineObj.powType], lineObj.message, lineObj))
            } else {
              obj.push(lineObj);
            }
          } catch (e) {
            // Expected JSON but got something else - probably a message from the Invoke-PowowShell Runtime wrapper
            /*
            messages.unshift(new POWMessage("ERROR", e.message, null))
            throw new POWError(`POWJS102:Invalid JSON Object: ${e.message}`, messages)
            */
            // We can ignore these in prod
            messages.push(parseErrorLine(line))
          }
        });
      } else {
        // Get stdout as a series of messages where stdout(Write-Output) has type OUTPUT
        messages.push(...outlines.map(parseLine))
      }
    }
    if (messages.find(m => m.type ==='ABORT')) success = false;

    return new POWResult(success, out.stdout, messages, obj)
  }
  function parseErrorLine(line) {
    return parseLine(line, "ERROR")
  }
  function parseLine(line, type) {
    const parsedLine = line.match(/^((ERROR)|(WARNING)|(INFO)|(VERBOSE)): (.*)/);
    let msgType: string = type || (parsedLine ? parsedLine[1] : "OUTPUT");
    return new POWMessage(msgType, parsedLine ? parsedLine[parsedLine.length - 1] : line, null)
  }

  return {
    init,
    execOptions,
    version,
    build,
    verify,
    run,
    trace,
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
    execStrictJSON,
    getWorkspace: () => workspace
  }

})();
/**
 *
 * @param {string} type The type of message ERROR|WARN|INFO|DEBUG
 * @param {string} message The message text
 */
const POWMessage = function (type: string, message: string, obj: any) {
  this.type = type || "INFO";
  this.message = message;
  this.obj = obj || null;
}

/**
 * A POWError consists of
 *  - A summary message
 *  - An array of POWMessages
 */
class POWError extends Error implements POWType.POWError {
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