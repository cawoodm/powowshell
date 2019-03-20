formBuilder = (function() {
    let dialog;
    return {
        showForm: function(step, component) {
            let frm = document.createElement('div');
            frm.setAttribute('id', 'myForm');
            app.root.$el.appendChild(frm);
            let str = JSON.stringify(step) + "\n" + JSON.stringify(component);
            for(let p = 0; p<component.parameters.length; p++) {
                let compParam = component.parameters[p];
                compParam.stepValue = step.parameters[compParam.name]||null;
                compParam.rules=compParam.required?[value => !!value || 'Required parameter!']:[];
            }
            dialog = new StepForm({
                propsData: {
                  id: step.id,
                  text: `<code>${str}</code>`,
                  step: step,
                  component: component,
                }
            }).$mount('#myForm');
        }
    }
})();
const StepForm = Vue.extend({
    props: ['id', 'step', 'component', 'text'],
    data: function() {
        return {
            show: true
        }
    },
    methods: {
        save() {

        },
        help() {
            alert((this.component.synopsis||"") + `\n` + (this.component.description||""))
        },
        close() {
            this.$destroy();
            this.$el.remove();
        }
    },
    template: `
    <v-dialog v-model="show" max-width="75%">
        <v-card>
            <v-card-title dark color="primary">
                <span class="headline">{{id}}: {{component.reference}}</span>
                <v-spacer></v-spacer>
                <v-btn @click="help()">?</v-btn>
            </v-card-title>
            <v-card-text>
                <v-container grid-list-xs>
                    <v-layout row wrap>
                        <v-flex xs12>
                            <div>{{step.description}}</div>
                        </v-flex>
                        <v-flex xs6>
                            <v-text-field label="input" v-model="component.input" readonly></v-text-field>
                        </v-flex>
                        <v-flex xs6>
                            <v-text-field label="output" v-model="component.output" readonly></v-text-field>
                        </v-flex>
                        <v-flex xs12 v-for="p in component.parameters" :key="p.name">
                            <v-text-field :label="p.name" :placeholder="p.default" clearable :rules="p.rules" v-model="p.stepValue"></v-text-field>
                            <small>{{p.description}}</small>
                        </v-flex>
                    </v-layout>
                </v-container>
            Lorem ipsum {{text}}
                
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue darken-1" flat @click="close()">Close</v-btn>
                <v-btn color="blue darken-1" flat @click="save()">Save</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
`
});
//Vue.component('step-form', 