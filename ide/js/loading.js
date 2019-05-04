/**
 * A loading/progress spinner
 */
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
            this.show = show;
            this.title = title||"Loading";
            this.message = message||"Loading...";
        },
        cancel: function() {
            this.show = false;
        }
    },
    template: `
<div class="text-xs-center">
    <v-dialog v-model="show" persistent width="300">
      <v-card>
        <v-card-title>{{title}}...</v-card-title>
        <v-card-text>
          {{message}}
          <v-progress-linear indeterminate color="secondary" class="mb-0"></v-progress-linear>
        </v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="primary" dark color="red" @click="cancel">Cancel</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
</div>
`
});
