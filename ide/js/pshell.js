let pshell = (function() {

    const PowerShell = (typeof require === "function")?require("powershell"):mock;
    
    return {
        exec: async function(command, options) {
            return new Promise(function(resolve, reject) {
                let ps = new PowerShell(command, options, (err, stdout, stderr)=>{
                    if (err === null) {
                        // We trim because of extra trailing newline
                        resolve(stdout.trim(), stderr.trim());
                    } else {
                        reject(err);
                    }
                });
            })
        }
    }

    function mock(command, options, cb) {
        // Just return the command text as stdout
        cb(null, command, "");
    }

})();
if (typeof module !== "undefined") module.exports = pshell;
