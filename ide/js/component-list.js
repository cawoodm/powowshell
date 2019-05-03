/* global Vue */
Vue.component("component-list", {
    props: ["store"],
    data: function() {
        return {
            filter: this.filter,
            loading: this.loading,
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
        setComponents: function(components) {
            this.components = components;
            this.loading = false;
        }
    },
    mounted: function() {
        this.filter = "";
        this.loading = true;
    },
    template: `
    <v-expansion-panel-content @hook:updated="$root.componentsUpdated">
        <div slot="header" class="body-2">Components</div>
        <v-progress-linear v-if="loading" indeterminate color="secondary"></v-progress-linear>
        <v-list dense v-if="!loading">
            <v-list-tile class="search-tile">
                <v-text-field v-model="filter" prepend-inner-icon="search" class="pa-0"></v-text-field>
            </v-list-tile>
            <v-list-tile v-for="component in filteredComponents" class="drag component nowrap1" :d-ref="component.reference" :key="component.reference">
            <v-icon>extension</v-icon>{{component.name}}
            </v-list-tile>
        </v-list>
    </v-expansion-panel-content>    
`
});