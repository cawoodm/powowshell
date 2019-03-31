Vue.component("component-list", {
    props: ["store"],
    data: function() {
        return {
            components: this.components
        };
    },
    methods: {
        //showDialog: function(id) {},
        setComponents: function(components) {
            this.components = components;
        }
    },
    template: `
    <v-expansion-panel-content>
        <div slot="header">Components</div>
        <v-list dense>
            <v-list-tile v-for="component in components" class="drag component" :d-ref="component.reference" :key="component.reference">
            <v-icon>file_copy</v-icon>{{component.reference}}
            </v-list-tile>
        </v-list>
    </v-expansion-panel-content>    
`
});