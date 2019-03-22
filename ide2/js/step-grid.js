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
        showDialog: function(id) {
            let step = pipelineManager.getStep(id);
            if (!step.reference) return;
            app.root.showDialog(step)
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
                    <div :id="step.id" :class="'stepContainer'+(step.reference?' stepFilled':' stepEmpty')" @click="showDialog(step.id)">
                        <div v-if="step.reference">
                            <div class="stepName">{{ step.name }}</div>
                            <div class="stepReference">{{step.reference}}</div>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
        </div>
    </v-container>
`
});