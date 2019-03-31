/* global Vue dragula formBuilder console pow pipelineManager */
let dp = console.log
let app = {};
pipelineManager.reset();
if (typeof process !== "undefined") {
    var POW = require("./js/pow")
    var pow = POW.pow;
}
app.components = {}

// TODO: List components dynamically

app.getComponent = (reference) => {
    let res = app.components.filter((item)=>item.reference===reference);
    return res.length>0?res[0]:null;
}
app.DEVMODE = true;
Vue.config.devtools = true;
Vue.config.productionTip = false;

window.onload = function() {
    fetch("../examples/components/components.json")
        .then((res)=>res.json())
        .then((obj)=>{
            app.components = obj;
            app.root.$refs.componentList.setComponents(app.components);
            app.root.loaded("components");
        })
    app.root = new Vue({
        el: "#root",
        data: {
            panels: [false, true],
        },
        methods: {
            loaded: function(what) {
                let root = this;
                this.loading[what]=true;
                // Check everything is loaded
                if (!this.loading.pipeline || !this.loading.components) return;
                // Make .drag elements draggable
                const dragOpts = {
                    revertOnSpill: true, // true=Go back if not dropped
                    accepts: function(el, target) {
                        return target.className.indexOf("drop")>=0;
                    } 
                };
                app.dragula = dragula([].slice.call(document.querySelectorAll(".drag")),dragOpts).on("drop", function (el, space) {
                    let id = el.getAttribute("d-id");
                    let ref = el.getAttribute("d-ref");
                    if (ref) {
                        // This is a component
                        let component = app.getComponent(ref);
                        root.$refs.stepGrid.addComponent(space.id, component)
                        root.showDialog(space.id);
                    } else if (id) {
                        // This is a step
                        root.$refs.stepGrid.moveStep(id, space.id);
                    }
                    app.dragula.cancel(true)
                });
            },
            run: function() {
                pow.execStrict("Get-Date").then((res)=>alert(res.output))
            },
            showDialog: function(id) {
                try {
                    let step = pipelineManager.getStep(id);
                    if (!step.reference) return;
                    let component = app.getComponent(step.reference);
                    formBuilder.showForm(this.$root, step, component);
                } catch(e) {
                    alert(e.message)
                }
            },
            pipelineLoad: function(id) {
                let root = this;
                // Load pipeline definition
                fetch(`../examples/${id}/pipeline.json`)
                    .then((res)=>res.json())
                    .then((obj)=>{
                        pipelineManager.import(obj);
                        if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                        root.loaded("pipeline");
                    });
            },
            pipelineOpen: function() {
            },
            pipelineSave: function() {
                dp("pipelineSave")   // TODO: IDE: Pipeline Save
            }
        },
        mounted: function() {
            let root = this;
            this.loading = {components: false, pipeline: false};
            // Listen for save events
            this.$root.$on("stepSave", (newStep) => {
                //let oldStep = pipelineManager.getStep(newStep.id)
                pipelineManager.setStep(newStep);
                // Must synch entire grid OR Vue.set(exactObject, newObject)
                root.$refs.stepGrid.doUpdate();
            });
            if (app.DEVMODE) {
                //console.clear(); // Vue junk
                this.pipelineLoad("pipeline1")
            }
        }
    });
}