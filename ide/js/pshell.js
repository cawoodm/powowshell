"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function PShell() {
    // ../ide/node_modules/node-powershell/lib/index.js
    const shell = require("node-powershell");
    let PowerShell;
    return {
        init: function (options) {
            PowerShell = new shell({
                executionPolicy: options.executionPolicy || 'Bypass',
                noProfile: options.noProfile || true,
                verbose: options.verbose || false,
                inputEncoding: options.inputEncoding || 'utf8',
                outputEncoding: options.outputEncoding || 'utf8',
                pwsh: options.pwsh || false
            });
            return PowerShell.pid;
        },
        exec: async function (command, args) {
            return new Promise(function (resolve, reject) {
                PowerShell.addCommand(command);
                PowerShell.invoke()
                    .then((output) => {
                    resolve({ stdout: output, stderr: null });
                })
                    .catch((err) => {
                    reject(err);
                });
                //ps.on("error", reject);
            });
        }
    };
}
exports.PShell = PShell;
//# sourceMappingURL=pshell.js.map