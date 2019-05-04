/* global Vue  */
/*
 Usage:
 dataTableBuilder.showTable(this.$root, {title: "foo", headers:[{text:"Name",value:"name"},{text:"Age",value:"age"}], items: [{name:"foo1", age:1},{name:"foo2", age:2}, {name:"foo3", age:3}]});
*/
const dataTableBuilder = (function() {
    return {
        showTable: function($root, data) {
            let el = document.createElement("div");
            el.setAttribute("id", "myDataTable");
            document.body.appendChild(el);
            // Make dynamic headers if none specified
            if (!data.headers && data.items) {
                data.headers = [];
                for (let field in data.items[0]) {
                    let hdr = {text:field,value:field};
                    data.headers.push(hdr)
                }
            }
            // Check if we have weird powershell dates
            for (field in data.items[0]) {
                let val = data.items[0][field]+"";
                if (val.match(/\/Date\(/)) {
                    for (let i=0; i<data.items.length; i++) {
                        data.items[i][field] = (new Date(parseInt(val.match(/\d+/)[0]))).toISOString();
                    }
                }
            }
            let tab = new DataTable({
                parent: $root,
                propsData: {
                  title: data.title||"Data Table",
                  headers: data.headers,
                  items: data.items
                }
            }).$mount("#myDataTable");
        }
    }
})();
const DataTable = Vue.extend({
    props: ["headers", "items", "title"],
    data: function() {
        return {
            show: true
        }
    },
    methods: {
        cancel() {
            this.close();
        },
        close() {
            this.$destroy();
            this.$el.remove();
        },
    },
    template: `
    <v-dialog v-model="show" scrollable max-width="75%">
        <v-card @keyup.esc="cancel" tabindex="0">
            <v-toolbar card dark color="primary">
                <span class="headline">{{title}}</span>
                <v-spacer></v-spacer>
                <v-icon @click="close()" color="white">close</v-icon>
            </v-toolbar>
            <v-card-text>
                <v-data-table :headers="headers" :items="items" class="elevation-1" total-items="100" hide-actions>
                    <template slot="items" slot-scope="myprops">
                        <td v-for="header in headers">
                        {{ myprops.item[header.value] }}
                        </td>
                    </template>
                </v-data-table>
            </v-card-text>
            <v-card-actions></v-card-actions>
        </v-card>
    </v-dialog>
`
});
