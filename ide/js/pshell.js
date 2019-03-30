/**
 * PShell is a Promise wrapper for the powershell library
 *  The main benefit is we can do `await exec`
 *  This also allows us to swap out the library later
 */
let pshell = (function() {

    const PowerShell = (typeof require === "function")?require("powershell"):mock;  
    
    return {
        exec: async function(command, options) {
            return new Promise(function(resolve, reject) {
                let ps = new PowerShell(command, options, (err, stdout, stderr)=>{
                    if (err === null) {
                        // We trim because of extra trailing newline
                        resolve({stdout: stdout.trim(), stderr: stderr.trim()});
                    } else {
                        reject(err);
                    }
                });
                ps.on("error", (err)=>{
                    reject(err);
                });
                //ps.on("error-output", (err)=>{reject(err)});
            })
        }
    }

    function mock(command, options, cb) {
        // Just return the command text as stdout
        cb(null, command, "");
    }

})();
if (typeof module !== "undefined") module.exports = pshell;
