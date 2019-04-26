/* global Vue */
Vue.component("component-list", {
    props: ["store"],
    data: function() {
        return {
            filter: "",
            components: this.components
        };
    },
    computed: {
        filteredComponents() {
            if (this.components && this.filter) {
                return this.components.filter((comp)=>comp.reference.indexOf(this.filter)>=0);
            } else if (this.components) {
                return this.components;
            } else {
                return [];
            }
        }
    },
    methods: {
        //showDialog: function(id) {},
        setComponents: function(components) {
            this.components = components;
        }
    },
    updated: function() {},
    template: `
    <v-expansion-panel-content @hook:updated="$root.componentsUpdated">
        <div slot="header">Components</div>
        <v-list dense>
            <v-list-tile class="search-tile">
                <v-text-field v-model="filter" prepend-inner-icon="search"></v-text-field>
            </v-list-tile>
            <v-list-tile v-for="component in filteredComponents" class="drag component" :d-ref="component.reference" :key="component.reference">
            <v-icon>file_copy</v-icon>{{component.name}}
            </v-list-tile>
        </v-list>
    </v-expansion-panel-content>    
`
});