/**
 * PShell is a Promise wrapper for the powershell library
 *  The main benefit is we can do `await exec`
 *  This also allows us to swap out the library later
 */
type ShellOpts =  {
    executionPolicy?: string;
    noProfile?: boolean;
    verbose?: boolean;
    inputEncoding?: string;
    outputEncoding?: string;
    pwsh?: boolean
}
interface SearchFunc {
    (source: string, subString: string): boolean;
}
export function PShell() {
    // ../ide/node_modules/node-powershell/lib/index.js
    const shell = require("node-powershell");
    let PowerShell;
    return {
        init: function(options: ShellOpts) {
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
        exec: async function(command, args) {
            return new Promise(function(resolve, reject) {
                PowerShell.addCommand(command);
                //args && PowerShell.addParameters(args);
                //args && args.forEach(PowerShell.addArgument);
                PowerShell.invoke()
                    .then((output)=>{
                        resolve({stdout: output, stderr: null})
                    })
                    .catch((err)=>{
                        reject(err);
                    });
                //ps.on("error", reject);
            })
        }
    }
}