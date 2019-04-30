(function powTest(console, args) {

    let verbose = args.indexOf("verbose")>=0?true:false;
    let debug = args.indexOf("debug")>=0?true:false;

    let FUNC = require("./functions")(verbose);
    let assert = FUNC.assert;

    let pow = require("../ide/js/pow").pow;
    let path = require("path");

    let workspacePath = path.resolve(__dirname, "../examples/");

    (async() => {
        let out;
        try {

            // Basic checks of powershell execution, error and output handling
            pow.execOptions.debug = !!debug;
            out = await pow.exec("Get-Date1"); assert(out.success===false, "Should have no success calling unknown CmdLet")
            try{out = await pow.execStrict("Get-Date1"); assert(false, "Should have an exception - we should not be here!!!")} catch(e){assert(e.messages.length>0, "Should have exceptions in execStrict")}
            out = await pow.exec("Get-Date -f 'yyyy-MM-dd'"); assert(out.output.match(/\d{4}-\d{2}-\d{2}/), `Should have a date: ${out.output}`)

            // Basic POW Tests
            out = await pow.version(); assert(out.match(/0\.\d\.\d/), `Should have a pow version number: ${out.match(/v\d+\.\d+\.\d+/)}`)
            out = await pow.init(workspacePath); assert(out.success, "Should find our ./examples/ workspace: " + out.success)
            out = pow.getWorkspace(); assert(out.match(/examples/),`Workspace should be set to 'examples': (${out})`)

            // Test loading pipeline
            out = await pow.pipeline("!pipeline1"); assert(out.success, `Load of pipeline1 should succeed: '${out.object.id}'`)
            assert(out.object.id=="pipeline1", `ID of pipeline1 should be set: '${out.object.id}'`)
            let pipeline1 = out.object;

            // Test POW building a pipeline
            try{out = await pow.build(); assert(false, "NO!!!")} catch(e){assert(e.messages.length>0, "Build without ID should throw")}
            out = await pow.build("!pipeline1"); assert(out.success, `Build of pipeline1 should succeed: '${out.messages[0].message}'`)

            // Test verifying a pipeline
            out = await pow.verify("!pipeline1"); assert(out.success, `Verification of pipeline1 should succeed: '${out.messages[0].message}'`)

            // Test running a pipeline
            out = await pow.run("!pipeline1"); assert(out.success, `Running a pipeline1 should succeed: '${out.object.length} items'`)
            assert(out.object[0].name === "John Doe", `Should have 'John Doe' in our pipeline output: '${out.object[0].name}'`)
            //out.messages.forEach((msg)=>{console.log(msg.type, msg.message)})

            // Test inspecting a single component
            out = await pow.inspect("!CSV2JSON"); assert(out.success, `Should inspect a component and see the reference: '${out.object.reference}'`)
            assert(out.object.inputFormat.match(/text\/.sv/), `Should have 'text/*sv' as our component input: '${out.object.inputFormat}'`)

            // Test pow components
            out = await pow.components("!"); assert(out.success && out.object.length > 5, `Should list components find some: '${out.object.length}'`)

            // Test pow cmdlets
            out = await pow.cmdlets("a*"); assert(out.success && out.object.length > 5, `Should list a* cmdlets find some: '${out.object.length}'`)

            // Test pow save
            out = await pow.save(pipeline1); assert(out.success, `Should save the pipeline: ${out.success}`)

        } catch(e) {
            let stk = e.stack.split(/\n/)
            console.error("\x1b[31m", "TEST cancelled:\n", e.message)
            console.error(stk[1]);
            if (e.messages)
                for (let i=0; i < e.messages.length && i < 10; i++) {
                    let msg = e.messages[i];
                    if (["ERROR", "WARNING"].indexOf(msg.type)>=0 || verbose)
                        console.log("\t", `${msg.type}: ${msg.message}`)
                }
            FUNC.addFails;
        }

        if (FUNC.fails()>0) {
            console.log("\x1b[31m", `FAIL: pow.js failed ${FUNC.fails()} of ${FUNC.tests()} tests`)
            console.log("\x1b[0m")
            process.exit(1)
        } else {
            console.log("\x1b[32m", `SUCCESS: pow.js passed ${FUNC.tests()} tests successfully`)
            console.log("\x1b[0m")
            process.exit(0)
        }

    })();

})(console, process.argv.slice(2));