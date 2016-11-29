const fs = require('fs'),
			stripBom = require('strip-bom');

describe("IDE", function() {
	var path1 = '../examples/pipeline1/pipeline.json',
	    def;
  it("could find a valid pipeline file", function() {
			expect(fs.existsSync(path1)).toBe(true, 'Pipeline description not found at:' + path1);
		var str = fs.readFileSync(path1, 'utf8');
			expect(str).toBeTruthy(true, 'Pipeline description empty!');
		str = stripBom(str);
		def = JSON.parse(str);
			expect(def).toBeTruthy('Pipeline description JSON invalid!');
		//TODO: Use a JSON Schema validator? https://github.com/tdegrunt/jsonschema
  });
	
	it("could validate the pipeline file", function(){
		expect(def.id).toMatch(/^[a-z0-9\-_]+$/, "id should not contain special characters");
		expect(def.name).toBeTruthy("name should be provided");
		expect(def.parameters.length).not.toBe(null, "parameters should be an array, even if empty");
	});
});