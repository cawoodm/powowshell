/* global Vue dragula formBuilder console pipelineManager */
let dp = console.log
let app = {};
if (typeof process !== "undefined") {
    var pow = require("./js/pow").pow;
    pipelineManager = require("./js/pipeline-manager") //  eslint-disable-line
}
pipelineManager.reset();
app.components = {}

app.getComponent = (reference) => {
    let res = app.components.filter((item)=>item.reference===reference);
    return res.length>0?res[0]:null;
}
app.DEVMODE = true;
Vue.config.devtools = true;
Vue.config.productionTip = false;

window.onload = function() {
    pow.components()
        .then((obj)=>{
            app.components = obj.object;
            app.root.loaded("components");
        });
    app.root = new Vue({
        el: "#root",
        data: {
            panels: [false, true],
            pipeline: {}
        },
        methods: {
            loaded: function(what) {
                let root = this;
                this.loading[what]=true;
                // Check everything is loaded
                if (!this.loading.pipeline || !this.loading.components) return;
                app.root.$refs.componentList.setComponents(app.components);
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
                pow.run("!"+this.pipeline.id)
                    .then((obj)=>{
                        alert(JSON.stringify(obj.object))
                    })
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
                // Load pipeline definition
                pow.pipeline(`${id}`)
                    .then((obj)=>{
                        pipelineManager.import(obj.object);
                        if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                        this.pipeline = obj.object;
                        this.loaded("pipeline");
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
                console.clear(); // Vue/electron junk warnings
                this.pipelineLoad("pipeline1")
            }
        }
    });
}