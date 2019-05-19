let pipelineForm = function (Vue) {
    const PipelineForm = Vue.extend({
        props: ["def"],
        data: function () {
            return {
                show: true,
                def: this.def
            };
        },
        methods: {
            cancel() {
                this.show = false;
            },
            ok() {
                this.$root.$emit("pipelineFormOK", this.def);
                this.show = false;
            }
        },
        mounted: function () {
            window.setTimeout(this.$refs.focusMe.focus, 200);
        },
        computed: {
            title: function () {
                return this.def.name ? `${this.def.name} (${this.def.id})` : this.def.id;
            }
        },
        template: `
        <v-dialog v-model="show" scrollable max-width="75%">
            <v-card @keyup.esc="cancel" @keydown.ctrl.83.prevent.stop="save" tabindex="0">
                <v-toolbar card dark color="primary">
                    <span class="headline">{{title}}</span>
                    <v-spacer></v-spacer>
                </v-toolbar>
                <v-card-text>
                    <v-container grid-list-xs>
                        <v-layout row wrap>
                        <v-flex xs12>
                            <v-text-field label="Id" placeholder="Technical Id of the pipeline" box v-model="def.id" :rules="[value => !!value || 'Required parameter!']"></v-text-field>
                        </v-flex>
                        <v-flex xs12>
                            <v-text-field label="Name" placeholder="Brief title for this pipeline" box v-model="def.name" :rules="[value => !!value || 'Required parameter!']" ref="focusMe" autofocus></v-text-field>
                        </v-flex>
                        <v-flex xs12>
                            <v-textarea label="Description" hint="Description of what this pipeline does and how" v-model="def.description" box></v-textarea>
                        </v-flex>
                        <v-flex xs4>
                            <v-select :items="[{value:'ps5',text:'PowerShell v5'},{value:'ps6',text:'PowerShell v6'},{value:'ps*',text:'Any PowerShell v*'}]" label="Runtime" v-model="def.runtime"></v-select>
                        </v-flex>
                        </v-layout>
                    </v-container>
                </v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="red"            dark @click="cancel()"><v-icon dark>cancel</v-icon>Cancel</v-btn>
                    <v-btn color="blue darken-1"  dark @click="ok()"><v-icon dark>done</v-icon>OK</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    `
    });
    let dialog;
    return {
        showForm: function ($root, def) {
            let frm = document.createElement("div");
            frm.setAttribute("id", "myPipelineForm");
            document.body.appendChild(frm);
            // Have to clone pipelineDefinition or we can't cancel out of the form
            let clone = Object.assign({}, def);
            dialog = new PipelineForm({
                parent: $root,
                propsData: {
                    def: clone
                }
            }).$mount("#myPipelineForm");
        }
    };
};
// @ts-ignore
if (typeof module !== "undefined")
    module.exports = pipelineForm;
//# sourceMappingURL=pipeline-form.js.map