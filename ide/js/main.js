let dp = console.log
let app = {};
pipelineManager.reset();

// Load components via AJAX
app.components = {}
fetch("../examples/components/components.json")
    .then((res)=>res.json())
    .then((obj)=>{
        app.components = obj;
        app.root.$refs.componentList.setComponents(app.components);
        app.root.loaded('components');
    })
//[ { "reference": "CSV2JSON", "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": [ {"name": "Delimiter", "type": "String", "required": true, "default": ",", "description": "Specifies the field separator. Default is a comma"}, {"name": "Header", "type": "String[]", "required": false, "default": "", "description": ""} ], "input": "text/csv", "output": "json/array" }, { "reference": "Data2JSON", "synopsis": "Convert input data to JSON format", "description": "Accepts custom tabular data about people and return contents as a JSON Array\nThe data must be in the format: \nNAME|AGE|GENDER\nHowever, the separator can be different and specified by the -Delimiter parameter", "parameters": [ {"name": "RecordSeparator", "type": "String", "required": false, "default": ",", "description": ""}, {"name": "Delimiter", "type": "String", "required": true, "default": "", "description": "Specifies the field separator. Default is a comma \",\")"} ], "input": "text/xsv", "output": "text/json" }, { "reference": "DateAdder", "synopsis": "Add some days to today's date and return the date", "description": "", "parameters": [ {"name": "days", "type": "Int32", "required": false, "default": 0, "description": "The number of days (integer) to add (or subtract) to todays date"} ], "input": "", "output": "date" }, { "reference": "DOSCommand", "synopsis": "Run any command with DOS CMD", "description": "", "parameters": [ {"name": "Command", "type": "String", "required": false, "default": "", "description": "The command string to be executed"} ], "input": "", "output": "text" }, { "reference": "DOSDir", "synopsis": "List files with DOS CMD", "description": "", "parameters": [ {"name": "Path", "type": "String", "required": false, "default": "", "description": "The path to the directory to be listed"} ], "input": "", "output": "text" }, { "reference": "ExecuteCmdlet", "synopsis": "Execute any PowerShell Cmdlet", "description": "Generic component which allows you to map up to 10 parameters to any cmdlet you like", "parameters": [ {"name": "PWTest", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "PWOutput", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "ExecuteTemplate", "type": "String", "required": true, "default": "", "description": "The command to be executed"}, {"name": "Depth", "type": "Int32", "required": false, "default": 2, "description": "The depth of the JSON output to be returned"}, {"name": "p0", "type": "String", "required": false, "default": "", "description": "The first parameter passed in. Can be used in ExecuteTemplate as {0}"}, {"name": "p1", "type": "String", "required": false, "default": "", "description": "The second parameter passed in. Can be used in ExecuteTemplate as {1}"}, {"name": "p2", "type": "String", "required": false, "default": "", "description": ""} ], "input": "text", "output": "json[]" }, { "reference": "FieldAdd", "synopsis": "Add a field to each object in an array", "description": "", "parameters": [ {"name": "Name", "type": "String", "required": true, "default": "", "description": "Name of the field to add"}, {"name": "Value", "type": "String", "required": true, "default": "", "description": "Value of the field to add"} ], "input": "", "output": "system.object" }, { "reference": "FileList", "synopsis": "Returns a list of files.", "description": "Lists files with a specific filter (e.g. *.txt) or\nwithin a specified date range.", "parameters": [ {"name": "PWTest", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "PWOutput", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "Path", "type": "String", "required": true, "default": "", "description": "Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.)."}, {"name": "Filter", "type": "String", "required": false, "default": "", "description": "The wildcard for matching files (e.g. *.csv)"}, {"name": "Recurse", "type": "SwitchParameter", "required": false, "default": false, "description": "If $true, will search all sub-folders"} ], "input": "", "output": "text/json[name,fullname,size(int)]" }, { "reference": "JSONMapping", "synopsis": "Map one form of JSON to another", "description": "Used for transforming JSON between two types.\nLimitation: Resulting object is only 1-level deep", "parameters": [ {"name": "Mapping", "type": "String", "required": false, "default": "", "description": ""} ], "input": "object(*)", "output": "object(*)" }, { "reference": "ObjectAddField", "synopsis": "Add a field to each object in an array", "description": "", "parameters": [ {"name": "Name", "type": "String", "required": true, "default": "", "description": "Name of the field to add"}, {"name": "Value", "type": "String", "required": true, "default": "", "description": "Value of the field to add"} ], "input": "", "output": "system.object" }, { "reference": "ReadFile", "synopsis": "Read text from a file", "description": "Read a single text file and return contents as a string.", "parameters": [ {"name": "Path", "type": "String", "required": true, "default": "", "description": "Specifies full literal (no wildcards) path to the file to be read."} ], "input": "", "output": "text" }, { "reference": "SelectFields", "synopsis": "Selects only certain fields from the input", "description": "", "parameters": [ {"name": "Fields", "type": "String[]", "required": false, "default": "", "description": ""} ], "input": "", "output": "text/json" } ];

// TODO: List components dynamically

app.getComponent = (reference) => {
    let res = app.components.filter((item)=>item.reference===reference);
    return res.length>0?res[0]:null;
}
app.DEVMODE = true;
Vue.config.devtools = true;
Vue.config.productionTip = false;

window.onload = function() {
    app.root = new Vue({
        el: '#root',
        data: {
            panels: [false, true],
            items: [
                { title: 'Click Me' },
                { title: 'Click Me' },
                { title: 'Click Me' },
                { title: 'Click Me 2' }
            ]
        },
        methods: {
            loaded: function(what) {
                let root = this;
                this.loading[what]=true;
                // Check everything is loaded
                if (!this.loading.pipeline || !this.loading.components) return;
                // Make .drag elements draggable
                const dragOpts = {
                    revertOnSpill: true, // true=Go back if not dropped
                    accepts: function (el, target, source, sibling) {
                        return target.className.indexOf('drop')>=0;
                    } 
                };
                app.dragula = dragula([].slice.call(document.querySelectorAll('.drag')),dragOpts).on('drop', function (el, space) {
                    let id = el.getAttribute("d-id");
                    let ref = el.getAttribute("d-ref");
                    if (ref) {
                        // This is a component
                        let component = app.getComponent(ref);
                        root.$refs.stepGrid.addComponent(space.id, component)
                        root.showDialog(space.id);
                    } else if (id) {
                        // This is a step
                        root.$refs.stepGrid.moveStep(id, space.id);
                    }
                    app.dragula.cancel(true)
                });
            },
            run: function() {
                pshell.exec("Get-Date").then(alert)
            },
            showDialog: function(id) {
                try {
                    let step = pipelineManager.getStep(id);
                    if (!step.reference) return;
                    let component = app.getComponent(step.reference);
                    formBuilder.showForm(this.$root, step, component);
                } catch(e) {
                    alert(e.message)
                }
            },
            pipelineLoad: function(id) {
                let root = this;
                // Load pipeline definition
                fetch(`../examples/${id}/pipeline.json`)
                    .then((res)=>res.json())
                    .then((obj)=>{
                        pipelineManager.import(obj);
                        if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                        root.loaded('pipeline');
                    });
            },
            pipelineOpen: function() {
            },
            pipelineSave: function() {
                dp("pipelineSave")   // TODO
            }
        },
        mounted: function() {
            let root = this;
            this.loading = {components: false, pipeline: false};
            // Listen for save events
            this.$root.$on('stepSave', (newStep) => {
                let oldStep = pipelineManager.getStep(newStep.id)
                pipelineManager.setStep(newStep);
                // Must synch entire grid OR Vue.set(exactObject, newObject)
                root.$refs.stepGrid.doUpdate();
            });
            if (app.DEVMODE) {
                console.clear(); // Vue junk
                this.pipelineLoad('pipeline1')
            }
        }
    });
}