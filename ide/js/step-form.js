formBuilder = (function() {
    let dialog;
    return {
        showForm: function($root, step, component) {
            let frm = document.createElement('div');
            frm.setAttribute('id', 'myForm');
            document.body.appendChild(frm);
            let str = JSON.stringify(step) + "\n" + JSON.stringify(component);
            for(let p = 0; p<component.parameters.length; p++) {
                let compParam = component.parameters[p];
                compParam.stepValue = step.parameters[compParam.name]||null;
                compParam.rules=compParam.required?[value => !!value || 'Required parameter!']:[];
            }
            // Have to clone step or we can't cancel out of the form
            let stepClone = Object.assign({}, step);
            let inputs = pipelineManager.getAvailableInputs(step.id);
            dialog = new StepForm({
                parent: $root,
                propsData: {
                  id: step.id,
                  text: `<code>${str}</code>`,
                  oldStep: step,
                  step: stepClone,
                  component: component,
                  inputs: inputs
                }
            }).$mount('#myForm');
        }
    }
})();
const StepForm = Vue.extend({
    props: ['id', 'step', 'oldStep', 'component', 'text', 'inputs'],
    data: function() {
        return {
            show: true
        }
    },
    methods: {
        save(e) {
            dp("save", e)
            this.$root.$emit('stepSave', this.step);
            this.close();
        },
        help() {
            alert((this.component.synopsis||"") + `\n` + (this.component.description||""))
        },
        cancel() {
            this.close();
        },
        close() {
            this.$destroy();
            this.$el.remove();
        }
    },
    computed: {
        title: function() {
            return `${this.id}: ${this.component.reference}`;
        }
    },
    template: `
    <v-dialog v-model="show" scrollable max-width="75%">
        <v-card @keyup.esc="cancel" @keyup.ctrl.83="save" tabindex="0">
            <v-toolbar card dark color="primary">
                <span class="headline">{{title}}</span>
                <v-spacer></v-spacer>
                <v-icon @click="help()" color="white">help</v-icon>
            </v-toolbar>
            <v-card-text>
                <v-container grid-list-xs>
                    <v-layout row wrap>
                        <v-flex xs12>
                            <div>{{step.description}}</div>
                        </v-flex>
                        <v-flex xs12>
                            <v-text-field label="Name" placeholder="A label for this step" v-model="step.name"></v-text-field>
                        </v-flex>
                        <v-flex xs6>
                            <v-select :items="inputs" :label="'Input (' + component.input + ')'" v-model="step.input" v-if="step.input"></v-select>
                            <v-text-field label="Input" placeholder="No Input" disabled v-if="!step.input"></v-text-field>
                        </v-flex>
                        <v-flex xs6>
                            <v-text-field :label="'Output (' + component.output + ')'" v-model="step.output" readonly>
                                <!--<v-icon slot="append" color="blue lighten-2">keyboard_arrow_right</v-icon>-->
                            </v-text-field>
                        </v-flex>
                        <v-flex xs12 v-for="p in component.parameters" :key="p.name">
                        <v-text-field :label="p.name + (p.required?'*':'')" :placeholder="p.default+''" :rules="p.rules" v-model="p.stepValue" clearable>
                            <v-tooltip slot="append" bottom v-if="p.description">
                                <v-icon slot="activator" color="gray lighten-2">help</v-icon>
                                <span>{{p.description}}</span>
                                <span v-if="p.required"><br>* Required parameter!</span>
                            </v-tooltip>
                            </v-text-field>
                        </v-flex>
                    </v-layout>
                </v-container>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue darken-1" flat @click="cancel()">Close</v-btn>
                <v-btn color="blue darken-1" flat @click="save()">Save</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
`
});