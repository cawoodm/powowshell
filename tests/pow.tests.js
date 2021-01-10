(function powTest(console, args) {

  let verbose = args.indexOf("verbose") >= 0;
  let debug = args.indexOf("debug") >= 0;
  let halt = args.indexOf("halt") >= 0;
  let one = args.indexOf("one") >= 0;

  let FUNC = require("./functions")({ verbose, halt });
  let assert = FUNC.assert;

  let pow = require("../ide/js/pow").pow;
  let path = require("path");

  let workspacePath = path.resolve(__dirname, "../examples/");

  (async () => {
    let out;
    try {

      pow.execOptions.debug = !!debug;
      verbosePreference = verbose ? ' -Verbose' : '';

      // out = await pow.init(workspacePath, verbose); assert(out.success, "Should find our ./examples/ workspace: " + out.success)

      if (one) {
        //console.clear();
        out = await pow.cmdlets();
        assert(out.object.length > 2, `Should be 2 output lines: got ${out.object.length}`);
        console.log("OK")
        process.exit(0)
      }

      // Basic checks of powershell execution, error and output handling
      out = await pow.exec("Get-Date1"); assert(out.success === false, "Should have no success calling unknown CmdLet")
      try { out = await pow.execStrict("Get-Date1"); assert(false, "Should have an exception - we should not be here!!!") } catch (e) { assert(e.messages.length > 0, "Should have messages on exceptions in execStrict") }
      out = await pow.exec("Get-Date -f 'yyyy-MM-dd'"); assert(out.output.match(/\d{4}-\d{2}-\d{2}/), `Should have a date: ${out.output}`)

      // Basic POW Tests
      out = await pow.version(); assert(out.match(/0\.\d\.\d/), `Should have a pow version number: ${out.match(/v\d+\.\d+\.\d+/)}`)
      out = await pow.init(workspacePath, verbose); assert(out.success, "Should find our ./examples/ workspace: " + out.success)
      out = pow.getWorkspace(); assert(out.match(/examples/), `Workspace should be set to 'examples': (${out})`)

      // Test loading pipeline
      out = await pow.pipeline("!pipeline1"); assert(out.success, `Load of pipeline1 should succeed: '${out.object.id}'`)
      assert(out.object.id == "pipeline1", `ID of pipeline1 should be set: '${out.object.id}'`)
      let pipeline1 = out.object;

      // Test POW building a pipeline
      try { out = await pow.build(); assert(false, "NO!!!") } catch (e) { assert(e.messages.length > 0, "Build without ID should throw") }
      out = await pow.build("!pipeline1"); assert(out.success, `Build of pipeline1 should succeed: '${out.messages[0].message}'`)

      // Test verifying a pipeline
      out = await pow.verify("!pipeline1");
      assert(out.success, `Verification of pipeline1 should succeed: '${out.object.length}'`)

      // Test running a pipeline
      out = await pow.run("!pipeline1"); assert(out.success, `Running a pipeline1 should succeed with ${out.object.length} items`)
      assert(out.object[0].name === "John Doe", `Should have 'John Doe' in our pipeline output: '${out.object[0].name}'`)

      // Test tracing a pipeline
      out = await pow.trace("!pipeline1"); assert(out.success, `Tracing a pipeline1 should succeed with ${out.object.length} items`)

      // Test inspecting a single component
      out = await pow.inspect("!CSV2JSON"); assert(out.success, `Should inspect a component and see the reference: '${out.object.reference}'`)
      assert(out.object.inputFormat.match(/text\/.sv/), `Should have 'text/*sv' as our component input: '${out.object.inputFormat}'`)

      // Test pow components
      out = await pow.components("!"); assert(out.success && out.object.length > 5, `Should list components find some: '${out.object.length}'`)

      // Test pow cmdlets
      out = await pow.cmdlets("a*"); assert(out.success && out.object.length > 5, `Should list a* cmdlets find some: '${out.object.length}'`)

      // Test pow save
      out = await pow.save(pipeline1); assert(out.success, `Should save the pipeline: ${out.success}`)

      // Test pow examples
      out = await pow.examples("!csv2json"); assert(out.success, `Should load examples: ${out.success}`)
      assert(out.object.length > 1, `Should load more than 1 example: ${out.object.length}`)
      assert(out.object.every(e => e.title && e.code), `Examples should all have a title and some code.`)

      // Test error and message handling
      await pow.build("!errortest");
      out = await pow.run("!errortest");
      assert(out.object.length === 2, `Should be 2 output lines: got ${out?.object.length}`);
      assert(out.messages.length === 4, `Should be 4 messages: got ${out?.messages.length}`);
      assert(out.messages[0].type === 'ERROR', 'First message should be an ERROR');
      try { out = await pow.execStrictJSON("pow run !errortest 'Throw=$true' -Export"); assert(false, "Should have an exception - we should not be here!!!") } catch (e) { assert(e.messages.length > 0, "Should have exceptions with pipeline !errortest -Throw") }

    } catch (e) {
      let stk = e.stack?.split(/\n/)
      console.error("\x1b[31m", "TEST cancelled:\n", e.message || '')
      if (stk) console.error(stk[1]);
      if (e.messages)
        for (let i = 0; i < e.messages.length && i < 10; i++) {
          let msg = e.messages[i];
          if (["ERROR", "WARNING"].indexOf(msg.type) >= 0 || verbose)
            console.log("\t", `${msg.type}: ${msg.message}`)
        }
      FUNC.addFails();
    }

    if (FUNC.fails() > 0) {
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
