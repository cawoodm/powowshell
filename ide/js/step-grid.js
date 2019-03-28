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
                <td v-for="step in row" :key="step.id" :id="step.id" :class="step.reference?'step drag':'step drag drop'">
                    <div :d-id="step.id" :class="'stepContainer'+(step.reference?' stepFilled':' stepEmpty')" @click="showDialog(step.id)">
                        <v-card height="200px" v-if="step.reference">
                            <v-card-title class="blue white--text stepName" :title="step.name">
                                {{ step.name }}
                            </v-card-title>
                            <v-card-text>
                                <div class="stepReference">{{step.reference}}</div>
                            </v-card-text>
                        </v-card>
                    </div>
                </td>
            </tr>
        </table>
        </div>
    </v-container>
`
});