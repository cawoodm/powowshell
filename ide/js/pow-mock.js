/* pow.js Mock for browser where we have now PowerShell */
if (typeof process === "undefined") {
window.pow = (function(){
    let fakePromise = function(msg, messages=[], obj={}) {
        return new Promise(function(resolve) {
            resolve(new POWResult(true, `Would now execute '${msg}' in PowerShell if I could in a browser!\nThe IDE must be run in electron!`, messages, obj))
        });
    }
    function componentsMock() {
        return new Promise((resolve)=>{fetch("../examples/components.json").then((res)=>res.json().then((obj)=>resolve({success:true, object:obj})));});
    }
    function cmdletsMock() {
        return new Promise((resolve)=>{fetch("../cache/cmdlets.json").then((res)=>res.json().then((obj)=>resolve({success:true, object:obj})));});
    }
    function pipelineMock(id) {
        return new Promise((resolve)=>{fetch(`../examples/${id}/pipeline.json`).then((res)=>res.json().then((obj)=>resolve({success:true, object:obj})));});
    }
    return {
        init: async ()=>fakePromise("init"),
        execOptions: async ()=>fakePromise(""),
        version: async ()=>fakePromise(""),
        build: async ()=>fakePromise(""),
        verify: async ()=>fakePromise(""),
        run: async (id)=>fakePromise(`pow run !${id}`, [], [{name:"John Doe", age:22}, {name:"Jane Doe", age:33}]),
        inspect: async ()=>fakePromise(""),
        preview: async ()=>fakePromise("", [], {"result":"This would run the step and show the output"}),
        examples: async ()=>fakePromise("", [], [{code:"somepowershell -code",description:"This is how you do this..."}]),
        pipeline: pipelineMock,
        components: componentsMock,
        cmdlets: cmdletsMock,
        exec: async (command)=>fakePromise(command),
        execStrict: async (command)=>fakePromise(command),
        getWorkspace: ()=>async ()=>fakePromise("")
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
}