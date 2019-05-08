/**
 * A loading/progress bar/spinner...
 */
let modLoading = function (Vue) {
    Vue.component("loading", {
        data: function() {
            return {
                show: this.show,
                title: this.title,
                message: this.message
            };
        },
        methods: {
            showLoading: function(show, message, title) {
                if (show===false) {
                    this.messages--;
                    if (this.messages <= 0) {
                        this.show = false;
                        this.title = "";
                        this.message = "";
                    }
                } else {
                    this.show = true;
                    this.title = title||"Loading";
                    this.messages++;
                    this.message += (message||"Loading...")+"<br>";
                }
            },
            close: function() {
                this.messages=0;
                this.show = false;
                this.title = "";
                this.message = "";
            }
        },
        mounted: function() {
            this.title="";
            this.message="";
            this.messages=0;
        },
        template: `
    <div class="text-xs-center">
        <v-dialog v-model="show" persistent width="300">
        <v-card>
            <v-card-title>{{title}}...<v-spacer/><v-icon dark @click="close">close</v-icon></v-card-title>
            <v-card-text>
            <span v-html="message"></span>
            <v-progress-linear indeterminate color="secondary" class="mb-0"></v-progress-linear>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
            </v-card-actions>
        </v-card>
        </v-dialog>
    </div>
    `
    });
}
// @ts-ignore
if (typeof module !== "undefined") module.exports = modLoading;