let dp = console.log
let app = {};
pipelineManager.reset();
let testPipeline = { "id": "pipeline1", "name": "Send mail to young voters", "description": "Read voters.txt, get all voters under 21yrs of age and send them an email", "parameters": { "DataSource": { "default": ".\\data\\voters.txt", "type": "string" }, "p2": { "default": "{Get-Date}" } }, "globals": { "foo": "bar" }, "checks": { "run": "some checks that we have all we need (e.g. ./data/voters.txt) to run?" }, "input": {}, "output": {}, "steps": [ { "id":"A1", "name":"Read Voters File", "reference":"ReadFile", "input":"", "parameters": { "Path": "{$PipelineParams.DataSource}" } }, { "id":"B1", "name":"Convert2JSON", "reference":"CSV2JSON", "input": "A", "parameters": { "Delimiter": "|", "Header": "{\"name\", \"age\", \"email\", \"source\"}" } }, { "id":"C1", "name":"Select Name and Email", "reference":"SelectFields", "input": "B", "parameters": { "Fields": "{\"name\", \"age\", \"email\"}" } } ] };
pipelineManager.import(testPipeline);
app.components = [ { "reference": "CSV2JSON", "synopsis": "Convert CSV data to JSON format" }, { "reference": "Data2JSON", "synopsis": "Convert input data to JSON format" }, { "reference": "DateAdder", "synopsis": "Add some days to today\u0027s date and return the date" }, { "reference": "DOSCommand", "synopsis": "Run any command with DOS CMD" }, { "reference": "DOSDir", "synopsis": "List files with DOS CMD" }, { "reference": "ExecuteCmdlet", "synopsis": "Execute any PowerShell Cmdlet" }, { "reference": "FieldAdd", "synopsis": "Add a field to each object in an array" }, { "reference": "FileList", "synopsis": "Returns a list of files." }, { "reference": "JSONMapping", "synopsis": "Map one form of JSON to another" }, { "reference": "ObjectAddField", "synopsis": "Add a field to each object in an array" }, { "reference": "ReadFile", "synopsis": "Read text from a file" }, { "reference": "SelectFields", "synopsis": "Selects only certain fields from the input" }]
app.getComponent = (reference) => {
    let res = app.components.filter((item)=>item.reference===reference);
    return res.length>0?res[0]:null;
}
Vue.config.devtools = true;
Vue.component('step-form', {
    data: function() {
        return {
            dialog: false
        }
    },
    methods: {
        showDialog() {
            this.dialog=!this.dialog;
        }
    },
    template: `
    <v-dialog v-model="dialog" persistent max-width="600px">
        <v-card-title>
          <span class="headline">User Profile</span>
        </v-card-title>
        <v-card-text>
            Lorem ipsum
        </v-card-text>
    </v-dialog>
`
});

Vue.component('steps-grid', {
    props: ['store'],
    data: function() {
        return {
            message: this.store.message,
            items: this.store.items,
            rows: pipelineManager.getRows() //this.store.rows
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
            showForm(step)
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
        panels: [true],
        stepform: {
            show: true
        },
        sub: {
            message: "I am the System!"
        }
    },
    methods: {
        doSummat: function() {
            dp(this.stepform.show)
            this.stepform.show=!this.stepform.show;
            dp(this.stepform.show)
        },
        addItem: function(obj) {
            this.sub.items.push(obj)
        },
        addStep: function(x, y, obj) {
            Vue.set(this.sub.rows[y], x, obj)
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
        }).on('drop', function (el, d) {
            let id = el.getAttribute("d-id");
            if (id) {
                // This is a component
                let component = app.getComponent(id);
                app.root.$refs.stepsGrid.addComponent(d.id, component)
            }
            app.dragula.cancel(true)
        });
    }
});
app.stepsGrid = app.root.$refs.stepsGrid;
app.stepForm = app.root.$refs.stepForm;