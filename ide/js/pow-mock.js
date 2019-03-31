/* pow.js Mock for browser where we have now PowerShell */
if (typeof process === "undefined") {
window.pow = (function(){
    let fakePromise = function(msg) {
        return new Promise(function(resolve) {
            resolve(new POWResult(true, `Would now execute '${msg}' in PowerShell if I could in a browser!\nThe IDE must be run in electron!`, [], {}))
        });
    }
    return {
        init: async ()=>fakePromise("init"),
        execOptions: async ()=>fakePromise(""),
        version: async ()=>fakePromise(""),
        build: async ()=>fakePromise(""),
        verify: async ()=>fakePromise(""),
        run: async ()=>fakePromise(""),
        inspect: async ()=>fakePromise(""),
        components: async ()=>fakePromise(""),
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