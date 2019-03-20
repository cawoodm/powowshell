let dp = console.log
let app = {};
pipelineManager.reset();
let testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"ReadFile", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"CSV2JSON", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"SelectFields", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
pipelineManager.import(testPipeline);
app.components = [ { "reference": "CSV2JSON", "synopsis": "Convert CSV data to JSON format", "description": "Accepts tabular CSV data and return contents as a JSON Array", "parameters": [ {"name": "Delimiter", "type": "String", "required": true, "default": ",", "description": "Specifies the field separator. Default is a comma"}, {"name": "Header", "type": "String[]", "required": false, "default": "", "description": ""} ], "input": "text/csv", "output": "json/array" }, { "reference": "Data2JSON", "synopsis": "Convert input data to JSON format", "description": "Accepts custom tabular data about people and return contents as a JSON Array\nThe data must be in the format: \nNAME|AGE|GENDER\nHowever, the separator can be different and specified by the -Delimiter parameter", "parameters": [ {"name": "RecordSeparator", "type": "String", "required": false, "default": ",", "description": ""}, {"name": "Delimiter", "type": "String", "required": true, "default": "", "description": "Specifies the field separator. Default is a comma \",\")"} ], "input": "text/xsv\nany separated data (e.g. csv) with newlines between records", "output": "text/json\nan array of json objects corresponding to the rows of the input data" }, { "reference": "DateAdder", "synopsis": "Add some days to today's date and return the date", "description": "", "parameters": [ {"name": "days", "type": "Int32", "required": false, "default": 0, "description": "The number of days (integer) to add (or subtract) to todays date"} ], "input": "", "output": "date" }, { "reference": "DOSCommand", "synopsis": "Run any command with DOS CMD", "description": "", "parameters": [ {"name": "Command", "type": "String", "required": false, "default": "", "description": "The command string to be executed"} ], "input": "", "output": "text" }, { "reference": "DOSDir", "synopsis": "List files with DOS CMD", "description": "", "parameters": [ {"name": "Path", "type": "String", "required": false, "default": "", "description": "The path to the directory to be listed"} ], "input": "", "output": "text" }, { "reference": "ExecuteCmdlet", "synopsis": "Execute any PowerShell Cmdlet", "description": "Generic component which allows you to map up to 10 parameters to any cmdlet you like", "parameters": [ {"name": "PWTest", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "PWOutput", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "ExecuteTemplate", "type": "String", "required": true, "default": "", "description": "The command to be executed"}, {"name": "Depth", "type": "Int32", "required": false, "default": 2, "description": "The depth of the JSON output to be returned"}, {"name": "p0", "type": "String", "required": false, "default": "", "description": "The first parameter passed in. Can be used in ExecuteTemplate as {0}"}, {"name": "p1", "type": "String", "required": false, "default": "", "description": "The second parameter passed in. Can be used in ExecuteTemplate as {1}"}, {"name": "p2", "type": "String", "required": false, "default": "", "description": ""} ], "input": "text", "output": "json[]" }, { "reference": "FieldAdd", "synopsis": "Add a field to each object in an array", "description": "", "parameters": [ {"name": "Name", "type": "String", "required": true, "default": "", "description": "Name of the field to add"}, {"name": "Value", "type": "String", "required": true, "default": "", "description": "Value of the field to add"} ], "input": "", "output": "system.object" }, { "reference": "FileList", "synopsis": "Returns a list of files.", "description": "Lists files with a specific filter (e.g. *.txt) or\nwithin a specified date range.", "parameters": [ {"name": "PWTest", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "PWOutput", "type": "SwitchParameter", "required": false, "default": false, "description": ""}, {"name": "Path", "type": "String", "required": true, "default": "", "description": "Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.)."}, {"name": "Filter", "type": "String", "required": false, "default": "", "description": "The wildcard for matching files (e.g. *.csv)"}, {"name": "Recurse", "type": "SwitchParameter", "required": false, "default": false, "description": "If $true, will search all sub-folders"} ], "input": "", "output": "text/json[name,fullname,size(int)]" }, { "reference": "JSONMapping", "synopsis": "Map one form of JSON to another", "description": "Used for transforming JSON between two types.\nLimitation: Resulting object is only 1-level deep", "parameters": [ {"name": "Mapping", "type": "String", "required": false, "default": "", "description": ""} ], "input": "object(*)", "output": "object(*)" }, { "reference": "ObjectAddField", "synopsis": "Add a field to each object in an array", "description": "", "parameters": [ {"name": "Name", "type": "String", "required": true, "default": "", "description": "Name of the field to add"}, {"name": "Value", "type": "String", "required": true, "default": "", "description": "Value of the field to add"} ], "input": "", "output": "system.object" }, { "reference": "ReadFile", "synopsis": "Read text from a file", "description": "Read a single text file and return contents as a string.", "parameters": [ {"name": "Path", "type": "String", "required": true, "default": "", "description": "Specifies full literal (no wildcards) path to the file to be read."} ], "input": "", "output": "text" }, { "reference": "SelectFields", "synopsis": "Selects only certain fields from the input", "description": "", "parameters": [ {"name": "Fields", "type": "String[]", "required": false, "default": "", "description": ""} ], "input": "", "output": "text/json" } ];
app.getComponent = (reference) => {
    let res = app.components.filter((item)=>item.reference===reference);
    return res.length>0?res[0]:null;
}
Vue.config.devtools = true;

Vue.component('steps-grid', {
    props: ['store'],
    data: function() {
        return {
            rows: pipelineManager.getRows()
        };
    },
    methods: {
        addComponent: function(id, component) {
            try {
                pipelineManager.addComponent(id, null, component)
                this.doUpdate()
            } catch(e) {
                alert(e.message)
            }
        },
        showDialog: function(id) {
            let step = pipelineManager.getStep(id);
            if (!step.reference) return;
            app.root.showDialog(step)
        },
        doUpdate: function() {
            this.rows = pipelineManager.getRows();
        }
    },
    template: `
    <v-container id="container">
            <!--<button v-on:click="doUpdate()">Reload</button>
                {{message}}
            -->
        <div id="scroll">
        <table id="maintable">
            <tr>
                <th v-for="step in rows[0]">{{step.id.substring(0,1)}}
                </th>
            </tr>
            <tr v-for="row in rows">
                <td v-for="step in row" :key="step.id" :id="step.id" :class="step.reference?'step drag':'step drag drop'">
                    <div :id="step.id" :class="'stepContainer'+(step.reference?' stepFilled':' stepEmpty')" @click="showDialog(step.id)">
                        <div v-if="step.reference">
                            <b>{{step.reference}}</b>
                            {{ step.name }}
                        </div>
                    </div>
                </td>
            </tr>
        </table>
        </div>
    </v-container>
`
});
app.root = new Vue({
    el: '#root',
    data: {
        panels: [true]
    },
    methods: {
        showDialog: function(step) {
            //this.$refs.stepForm.show = true; //showDialog();
            let component = app.getComponent(step.reference);
            formBuilder.showForm(step, component);
        }
    },
    mounted: function() {
        // Make .drag elements draggable
        app.dragula = dragula([].slice.call(document.querySelectorAll('.drag')),{
            revertOnSpill: true, // true=Go back if not dropped
            copy: true, // true=Copy the element
            accepts: function (el, target, source, sibling) {
                return target.className.indexOf('drop')>=0;
            } 
        }).on('drop', function (el, space) {
            let id = el.getAttribute("d-id");
            let ref = el.getAttribute("d-ref");
            if (ref) {
                // This is a component
                let component = app.getComponent(ref);
                app.root.$refs.stepsGrid.addComponent(space.id, component)
            }
            app.dragula.cancel(true)
        });
    }
});
app.stepsGrid = app.root.$refs.stepsGrid;
app.stepForm = app.root.$refs.stepForm;