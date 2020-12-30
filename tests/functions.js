function FUNC(verbose) {
    let tests = 0;
    let fails = 0;
    return {
        tests: ()=>tests,
        fails: ()=>fails,
        addFails: ()=>fails++,
        assert: function(cond, msg, exception) {
            if (verbose) console.log("\x1b[36m", "... " + msg);
            try {
                tests++;
                let res = typeof cond === "function"?cond():eval(cond);
                if (res) {
                    if (verbose && !exception) {
                        console.log("\x1b[32m", "\tSUCCESS: "+msg);
                        return true;
                    }
                } else {
                    fails++;
                    console.log("\x1b[31m", "\tFAIL: "+msg);
                    return false;
                }
            } catch(e) {
                if (!exception) {
                    fails++;
                    console.log("\x1b[31m", "\tFAIL: "+msg);
                    console.log("\x1b[33m", "\t\tEXCEPTION: "+e.message);
                    console.log(e);
                    throw new Error("HALT TEST: Unexpected exception");
                } else {
                    if (verbose) console.log("\x1b[32m", "\tSUCCESS: "+msg);
                    return true;
                }
            }
        }
    };
}
module.exports = FUNC