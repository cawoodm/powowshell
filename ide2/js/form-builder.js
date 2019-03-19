formBuilder = (function() {
    let dialog;
    return {
        showForm: function(step) {
            //app.stepForm.showDialog()
            let frm = document.createElement('div');
            frm.setAttribute('id', 'myForm');
            app.root.$el.appendChild(frm);
            let str = JSON.stringify(step);
            dialog = new StepForm({
                propsData: {
                  text: str
                }
            }).$mount('#myForm');
        }
    }
})();
const StepForm = Vue.extend({
    props: ['text'],
    data: function() {
        return {
            show: true
        }
    },
    methods: {
        close() {
            this.$destroy();
        },
        showDialog() {
            this.show=!this.show;
        }
    },
    template: `
    <v-dialog v-model="show" max-width="75%">
        <v-card>
            <v-card-title dark color="primary">
                <span class="headline">Properties</span>
                <v-btn @click="close()">X</v-btn>
            </v-card-title>
            <v-card-text>
                Lorem ipsum {{text}}
            </v-card-text>
        </v-card>
    </v-dialog>
`
});
//Vue.component('step-form', 