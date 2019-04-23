# Adaptors
Adaptors are the glue or the translators which make it possible for components to communicate.

Adaptors are charged with converting the I/O of the component or cmdlet to a common language (JSON)
Each adaptor must provide INPUT adaption: converting JSON to the component's input type as well as OUTPUT adaption: converting the component's output type to JSON.

The benefit of adaptors is that you always have a common language between components.
The disadvantage is performance since you are constantly converting between formats.
A later optimization will be to drop adaptors between components which are compatible. There is no need (except in trace mode) to adapt/deserialize between say Get-ChildItem and Where-Object since the latter accepts any object

Adaptors need to work in 2 modes:
* Parameter mode: where they are passed a value/object as a parameter
* Pipeline mode: where they are piped zero, one, or more values/objects

## Primitives
Basic types such as `string` and `int` are converted to simple objects with a single value property:
* `2 | ./int.out.ps1` produces `{"value":2}`
* `"foo" | ./string.out.ps1` produces `{"value":"foo"}`
or, in "parameter" mode:
* `./int.out.ps1 2` produces `{"value":2}`

## Collections
Since powershell pipelines are collections and not technically arrays and, in order to support streamed data we do not convert a stream of objects to the `[{object1}, {object2},...]` equivalent but simply a collection of individual JSON objects.
* `1,2,3 | ./int.out.ps1` produces `{"value":1} {"value":2} {"value":3}`
However, in order to be as flexible as possible, adaptors should also accept arrays as parameters:
* `./int.out.ps1 1,2,3` produces `[1, 2, 3]`

# Disclaimer
PowerShell's ConvertTo-JSON takes the view that primitives should be output not as objects but as primitives.
We take the view that everything must be an object (or stream of objects) and that this is the only way to provide a consistent common object language.
We thus depart from ConvertTo-JSON here as well as with streamed arrays.
Streamed data (collections) produce something similar to newline delimited JSON (NDJSON) and not a single JSON array [...] of objects.