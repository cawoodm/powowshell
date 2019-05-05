/* global Vue */
Vue.component("pipeline-form", {
    props: [],
    data: function() {
        return {
            show: false,
            def: this.def
        };
    },
    methods: {
        showForm: function(def) {
            let clone = Object.assign({}, def);
            this.show = true;
            this.def  = clone;
        },
        cancel() {
            this.show = false;
        },
        ok() {
            this.$root.$emit("pipelineFormOK", this.def);
            this.show = false;
        }
    },
    mounted: function() {
        window.setTimeout(this.$refs.focusMe.focus,200);
    },
    computed: {
        title: function() {
            return this.def.name?`${this.def.name} (${this.def.id})`:this.def.id;
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
                        <v-text-field label="Id" placeholder="Technical Id of the pipeline" v-model="def.id" :rules="[value => !!value || 'Required parameter!']"></v-text-field>
                    </v-flex>
                    <v-flex xs12>
                        <v-text-field label="Name" placeholder="Brief title for this pipeline" v-model="def.name" :rules="[value => !!value || 'Required parameter!']" ref="focusMe" autofocus></v-text-field>
                    </v-flex>
                        <v-flex xs12>
                            <v-textarea label="Description" hint="Description of what this pipeline does and how" v-model="def.description"></v-textarea>
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