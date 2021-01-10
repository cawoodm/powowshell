const modCmdletList = function (Vue) {
  Vue.component("cmdlet-list", {
  props: [],
  data: function() {
    return {
      filter: this.filter,
      cmdlets: this.cmdlets,
      loading: this.loading
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
    setCmdlets: function(cmdlets) {
      this.cmdlets = cmdlets;
      this.loading = false;
    },
    refresh: function() {
      this.$root.$emit("cmdletsLoad", true);
    }
  },
  mounted: function() {
    this.filter = "";
    this.loading = false;
  },
  template: `
  <v-expansion-panel-content @hook:updated="$root.componentsUpdated">
    <div slot="header" class="body-2">Cmdlets <v-icon small @click="refresh">refresh</v-icon>
      <v-progress-linear v-if="loading" indeterminate color="secondary"></v-progress-linear>
    </div>
    <v-list dense v-if="!loading" style="max-height: 400px; overflow-x: hidden; overflow-y: scroll;">
      <v-list-tile class="search-tile">
        <v-text-field v-model="filter" prepend-inner-icon="search" class="pa-0"></v-text-field>
      </v-list-tile>
      <v-list-tile v-for="cmdlet in filteredCmdlets" class="drag cmdlet nowrap1" :d-ref="cmdlet.reference" :key="cmdlet.reference">
        <v-icon>file_copy</v-icon>{{cmdlet.name}}
      </v-list-tile>
    </v-list>
  </v-expansion-panel-content>
`
});
}
// @ts-ignore
if (typeof module !== "undefined") module.exports = modCmdletList;