/* global Vue */
Vue.component("cmdlet-list", {
    props: [],
    data: function() {
        return {
            filter: "",
            cmdlets: this.cmdlets
        };
    },
    computed: {
        filteredCmdlets() {
            if (this.cmdlets && this.filter) {
                return this.cmdlets.filter((comp)=>comp.reference.indexOf(this.filter)>=0);
            } else if (this.cmdlets) {
                return this.cmdlets;
            } else {
                return [];
            }
        }
    },
    methods: {
        //showDialog: function(id) {},
        setCmdlets: function(cmdlets) {
            this.cmdlets = cmdlets;
        }
    },
    updated: function() {},
    template: `
    <v-expansion-panel-content @hook:updated="$root.componentsUpdated">
        <div slot="header">CmdLets</div>
        <v-list dense>
            <v-list-tile class="search-tile">
                <v-text-field v-model="filter" prepend-inner-icon="search"></v-text-field>
            </v-list-tile>
            <v-list-tile v-for="cmdlet in filteredCmdlets" class="drag cmdlet" :d-ref="cmdlet.reference" :key="cmdlet.reference">
            <v-icon>file_copy</v-icon>{{cmdlet.name}}
            </v-list-tile>
        </v-list>
    </v-expansion-panel-content>    
`
});