/* global Vue */
Vue.component("cmdlet-list", {
    props: [],
    data: function() {
        return {
            filter: this.filter,
            selectedCmdlet: null,
            loading: this.loading,
            cmdlets: this.cmdlets
        };
    },
    computed: {
        filteredCmdlets() {
            if (this.cmdlets && this.filter) {
                let filt = this.filter.toLowerCase();
                return this.cmdlets.filter((comp)=>comp.reference.indexOf(filt)>=0);
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
            this.loading = false;
            this.cmdlets = cmdlets;
        },
        addCmdlet: function() {
            alert(this.selectedCmdlet)
        }
    },
    mounted: function() {
        console.log("mounted cmdlet-list")
        this.filter = "";
        this.loading = true;
    },
    template: `
    <v-expansion-panel-content @hook:updated="$root.componentsUpdated">
        <div slot="header" class="body-2">CmdLets</div>
        <v-list dense style="height:80px; overflow: hidden">
            <v-list-tile class="search-tile">
                <v-autocomplete v-model="filter" :items="filteredCmdlets" item-text="name" label="CmdLets" clearable chips :loading="loading"></v-autocomplete>
            </v-list-tile>
            <v-list-tile v-if="filter" v-for="cmdlet in filteredCmdlets" class="drag cmdlet nowrap1" :d-ref="cmdlet.reference" :key="cmdlet.reference">
            <v-icon>file_copy</v-icon>{{cmdlet.name}}
            </v-list-tile>
        </v-list>
    </v-expansion-panel-content>    
`
});