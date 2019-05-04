Vue.component('step-grid', {
    props: ['store'],
    data: function() {
        return {
            rows: pipelineManager.getRows()
        };
    },
    methods: {
        addComponent: function(id, component) {
            try {
                pipelineManager.addComponent(id, null, component)
                this.doUpdate()
            } catch(e) {
                alert(e.message)
            }
        },
        moveStep: function(fromId, toId) {
            try {
                pipelineManager.moveStep(fromId, toId)
                this.doUpdate()
            } catch(e) {
                alert(e.message)
            }
        },
        showDialog: function(id) {
            this.$root.showDialog(id)
        },
        preview(id) {
            this.$root.$emit("stepPreview", id);
        },
        remove(id) {
            this.$root.$emit("stepRemove", id);
        },
        doUpdate: function() {
            this.rows = pipelineManager.getRows();
        }
    },
    template: `
    <v-container id="container">
            <!--<button v-on:click="doUpdate()">Reload</button>
                {{message}}
            -->
        <div id="scroll">
        <table id="maintable">
            <tr>
                <th v-for="step in rows[0]">{{step.id.substring(0,1)}}
                </th>
            </tr>
            <tr v-for="row in rows">
                <td v-for="step in row" :key="step.id" class="step">
                    <div :id="step.id" :class="step.reference===null?'step drop':'step drag drop'">
                    <div :d-id="step.id" :class="'stepContainer'+(step.reference?' stepFilled':' stepEmpty')" @click="showDialog(step.id)">
                        <v-flex>
                        <v-card height="200px" v-if="step.reference" class="flexcard">
                            <v-card-title class="blue white--text stepName" :title="step.reference">
                                {{ step.reference }}
                            </v-card-title>
                            <v-card-text class="grow">
                                <div class="stepReference">{{step.name}}</div>
                            </v-card-text>
                            <v-card-actions dark>
                                <v-spacer></v-spacer>
                                <v-btn icon @click.stop="remove(step.id)"><v-icon title="Remove" small>delete</v-icon></v-btn>
                            </v-card-actions>
                        </v-card>
                        </v-flex>
                    </div>
                    </div>
                </td>
            </tr>
        </table>
        </div>
    </v-container>
`
});