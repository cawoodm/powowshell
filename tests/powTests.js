(function powTest(console, verbose) {

    let POW = require("../ide/js/pow");
    let path = require("path");
    let pow = POW.pow;

    let tests = 0;
    let fails = 0;

    let workspacePath = path.resolve(__dirname, "../examples/");

    (async() => {
        let out;
        try {
            // Basic PowerShell checks
            pow.execOptions.debug = false;
            try{out = await pow.execStrict("Get-Date1"); assert(false, "Should have an exception - we should not be here!!!")} catch(e){ assert(e.messages.length>0, "Should have exceptions in execStrict")}
            out = await pow.exec("Get-Date1"); assert(out.success===false, "Should have no success")
            out = await pow.exec("Get-Date -f 'yyyy-MM-dd'"); assert(out.output.match(/\d{4}-\d{2}-\d{2}/), `Should have a date: ${out.output}`)

            // Basic POW Tests
            out = await pow.version(); assert(out.match(/0\.\d\.\d/), `Should have a pow version number: ${out.match(/v\d+\.\d+\.\d+/)}`)
            out = await pow.init(workspacePath); assert(out.success, "Should find our ./examples/ workspace: " + out.success)
            out = pow.getWorkspace(); assert(out.match(/examples/),`Workspace should be set to 'examples': (${out})`)
            
            // Build tests
            //assert(()=>pow.build(), "Build without ID should throw", true)
            //assert(()=>pow.build("pipeline1").success, "Build with ID should work", true)
        } catch(e) {
            console.error("\x1b[31m", "TEST cancelled:\n", e.message, "\x1b[31m")
            fails++;
        }

        if (fails) {
            console.error("\x1b[31m", fails + " of " + tests + " failed")
        } else {
            console.log("\x1b[32m", "SUCCESS: All test passed successfully")
        }
        console.log("\x1b[0m", "fin") // Reset colors

    })();


    function assert(cond, msg, exception) {
        // 32m=green, 31m=red, 33m=yellow
        if (verbose) console.log("\x1b[34m", "Asserting: " + msg);
        try {
            tests++;
            let res = typeof cond === "function"?cond():eval(cond);
            if (res) {
                if (!exception) console.log("\x1b[32m", "*** OK: "+msg);
            } else {
                fails++;
                console.log("\x1b[31m", "*** FAIL: "+msg);
            }
        } catch(e) {
            if (!exception) {
                fails++;
                console.log("\x1b[31m", "*** FAIL: "+msg);
                console.log("\x1b[33m", "****EXCEPTION: "+e.message);
                console.log(e);
                throw new Error("HALT TEST: Unexpected exception");
            } else {
                if (verbose) console.log("\x1b[32m", "*** OK: "+msg);
            }
        }
    }
    //const path = require('path');

})(console, 0);