/* global pipelineManager */
const formBuilder = (function() {
    let dialog;
    return {
        showForm: function($root, step, component) {
            let frm = document.createElement("div");
            frm.setAttribute("id", "myForm");
            document.body.appendChild(frm);
            //let str = JSON.stringify(step) + "\n" + JSON.stringify(component);console.log(str)
            for(let p = 0; p<component.parameters.length; p++) {
                let compParam = component.parameters[p];
                compParam.stepValue = step.parameters[compParam.name]||compParam.default||null;
                compParam.rules=compParam.required?[value => !!value || "Required parameter!"]:[];
            }
            // Have to clone step or we can't cancel out of the form
            let stepClone = Object.assign({}, step);
            let inputs = pipelineManager.getAvailableInputs(step.id);
            dialog = new StepForm({
                parent: $root,
                propsData: {
                  id: step.id,
                  oldStep: step,
                  step: stepClone,
                  component: component,
                  inputs: inputs
                }
            }).$mount("#myForm");
        }
    }
})();
const StepForm = Vue.extend({
    props: ["id", "step", "oldStep", "component", "text", "inputs"],
    data: function() {
        return {
            show: true
        }
    },
    methods: {
        save() {
            this.form2Step()
            this.$root.$emit("stepSave", this.step);
            this.close();
        },
        preview() {
            this.form2Step()
            this.$root.$emit("stepPreview", this.step);
        },
        examples() {
            this.$root.$emit("componentExamples", this.step.reference, this.component.type);
        },
        help() {
            alert((this.component.synopsis||"") + "\n" + (this.component.description||""))
        },
        cancel() {
            this.close();
        },
        close() {
            this.$destroy();
            this.$el.remove();
        },
        form2Step() {
            for (let i=0; i < this.component.parameters.length; i++) {
                let compParam = this.component.parameters[i];
                this.step.parameters[compParam.name] = compParam.stepValue;
            }
        }
    },
    computed: {
        title: function() {
            return `${this.id}: ${this.component.name}`;
        }
    },
    template: `
    <v-dialog v-model="show" scrollable max-width="75%">
        <v-card @keyup.esc="cancel" @keydown.ctrl.83.prevent.stop="save" tabindex="0">
            <v-toolbar card dark color="primary">
                <span class="headline">{{title}}</span>
                <v-spacer></v-spacer>
                <v-icon @click="help()" color="white">help</v-icon>
            </v-toolbar>
            <v-card-text>
                <v-container grid-list-xs>
                    <v-layout row wrap>
                        <v-flex xs12 v-if="component.synopsis">
                            <div class="subheading">{{component.synopsis}}</div>
                        </v-flex>
                        <v-flex xs12 v-if="step.description">
                            <div>{{step.description}}</div>
                        </v-flex>
                        <v-flex xs12>
                            <v-text-field label="Name" placeholder="A label for this step" v-model="step.name"></v-text-field>
                        </v-flex>
                        <v-flex xs12>
                            <v-text-field label="Description" placeholder="A description for this step" v-model="step.descriptions"></v-text-field>
                        </v-flex>
                        <v-flex xs4>
                            <v-select :items="inputs" :label="'Piped Input (' + component.input + ')'" v-model="step.input" v-if="component.input"></v-select>
                            <v-text-field label="Input" placeholder="No Piped Input" disabled v-if="!component.input"></v-text-field>
                        </v-flex>
                        <v-flex xs4>
                            <v-select :items="['begin', 'process','end']" label="Stream Mode" v-model="step.stream"></v-select>
                        </v-flex>
                        <v-flex xs4>
                            <v-text-field :label="'Output (' + component.output + ')'" v-model="step.output" readonly>
                                <!--<v-icon slot="append" color="blue lighten-2">keyboard_arrow_right</v-icon>-->
                            </v-text-field>
                        </v-flex>
                        <template v-for="compParam in component.parameters" :key="compParam.name">
                            <v-flex xs1>
                                <v-tooltip bottom v-if="compParam.description">
                                <v-icon slot="activator" color="gray lighten-2">help</v-icon>
                                <span>{{compParam.description}}</span>
                                <span v-if="compParam.required"><br>* Required parameter!</span>
                                </v-tooltip>
                            </v-flex>
                            <v-flex xs11>
                                <v-checkbox v-if="compParam.type==='switch'"                               v-model="compParam.stepValue" :label="compParam.name + (compParam.required?'*':'')"></v-checkbox>
                                <v-combobox v-else-if="compParam.values && compParam.type.match(/\\[/)"    v-model="compParam.stepValue" :label="compParam.name + (compParam.required?'*':'')" :items="compParam.values" multiple></v-combobox>
                                <v-combobox v-else-if="compParam.values"                                   v-model="compParam.stepValue" :label="compParam.name + (compParam.required?'*':'')" :items="compParam.values"></v-combobox>
                                <v-text-field v-else :label="compParam.name + (compParam.required?'*':'')" :placeholder="compParam.default?compParam.default:''" :rules="compParam.rules" v-model="compParam.stepValue" clearable>
                                </v-text-field>
                            </v-flex>
                        </template>
                    </v-layout>
                </v-container>
            </v-card-text>
            <v-card-actions>
                <v-btn color="yellow darken-1" flat @click="examples()">Examples</v-btn>
                <v-spacer></v-spacer>
                <v-btn color="red darken-1" flat @click="cancel()">Cancel</v-btn>
                <v-btn color="green darken-1" flat @click="preview()" :disabled="!!component.input">Preview</v-btn>
                <v-btn color="blue darken-1" flat @click="save()">Save</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
`
});