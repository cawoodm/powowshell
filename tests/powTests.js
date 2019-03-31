(function powTest(console, args) {

    let verbose = args.indexOf("verbose")>=0?true:false;
    let debug = args.indexOf("debug")>=0?true:false;

    let FUNC = require("./functions").FUNC(verbose);
    let assert = FUNC.assert;

    let POW = require("../ide/js/pow");
    let path = require("path");
    let pow = POW.pow;

    let workspacePath = path.resolve(__dirname, "../examples/");

    (async() => {
        let out;
        try {

            // Basic checks of powershell execution, error and output handling
            pow.execOptions.debug = !!debug;
            out = await pow.exec("Get-Date1"); assert(out.success===false, "Should have no success")
            try{out = await pow.execStrict("Get-Date1"); assert(false, "Should have an exception - we should not be here!!!")} catch(e){assert(e.messages.length>0, "Should have exceptions in execStrict")}
            out = await pow.exec("Get-Date -f 'yyyy-MM-dd'"); assert(out.output.match(/\d{4}-\d{2}-\d{2}/), `Should have a date: ${out.output}`)

            // Basic POW Tests
            out = await pow.version(); assert(out.match(/0\.\d\.\d/), `Should have a pow version number: ${out.match(/v\d+\.\d+\.\d+/)}`)
            out = await pow.init(workspacePath); assert(out.success, "Should find our ./examples/ workspace: " + out.success)
            out = pow.getWorkspace(); assert(out.match(/examples/),`Workspace should be set to 'examples': (${out})`)
            
            // // Test POW building a pipeline
            // try{out = await pow.build(); assert(false, "NO!!!")} catch(e){assert(e.messages.length>0, "Build without ID should throw")}
            // out = await pow.build("!pipeline1"); assert(out.success, `Build of pipeline1 should succeed: '${out.messages[0].message}'`)
            
            // // Test verifying a pipeline
            // out = await pow.verify("!pipeline1"); assert(out.success, `Verification of pipeline1 should succeed: '${out.messages[0].message}'`)
            
            // // Test running a pipeline
            // out = await pow.run("!pipeline1"); assert(out.success, `Running a pipeline1 should succeed: '${out.messages[0].message}'`)
            // assert(out.object[0].name === "John Doe", `Should have 'John Doe' in our pipeline output: '${out.object[0].name}'`)
            // //out.messages.forEach((msg)=>{console.log(msg.type, msg.message)})
            
            // // Test inspecting a single component
            // out = await pow.inspect("!CSV2JSON"); assert(out.success, `Should inspect a component and see the reference: '${out.object.reference}'`)
            // assert(out.object.input.match(/text\/.sv/), `Should have 'text/*sv' as our component input: '${out.object.input}'`)

            // TODO: Test pow components
            out = await pow.components("!"); assert(out.success && out.object.length > 5, `Should list components find some: '${out.object.length}'`)

            
        } catch(e) {
            console.error("\x1b[31m", "TEST cancelled:\n", e.message, "\x1b[31m")
            if (e.messages)
                for (let i=0; i < e.messages.length && i < 10; i++) {
                    let msg = e.messages[i];
                    if (["ERROR", "WARNING"].indexOf(msg.type)>=0 || verbose)
                        console.log("\t", `${msg.type}: ${msg.message}`)
                }
            FUNC.addFails;
        }

        if (FUNC.fails) {
            console.log("\x1b[31m", `FAIL: pow.js failed ${FUNC.fails} of ${FUNC.tests} tests`)
            console.log("\x1b[0m")
            process.exit(1)
        } else {
            console.log("\x1b[32m", `SUCCESS: pow.js passed ${FUNC.tests} tests successfully`)
            console.log("\x1b[0m")
            process.exit(0)
        }

    })();

})(console, process.argv.slice(2));