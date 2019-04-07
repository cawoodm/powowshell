/* global Vue dragula formBuilder console pipelineManager */
let app = {};
if (typeof process !== "undefined") {
    var pow = require("./js/pow").pow;
    pipelineManager = require("./js/pipeline-manager") //  eslint-disable-line
    var {dialog} = require("electron").remote
    console.log(dialog)
}
pipelineManager.reset();
app.components = {}

app.getComponent = (reference) => {
    if (!app.components) return alert("Components not loaded!")
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
                this.loading[what]=true;
                // Check everything is loaded
                if (!this.loading.pipeline || !this.loading.components) return;
                this.$refs.componentList.setComponents(app.components);
            },
            componentsUpdated: function() {
                let root = this;
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
            showLoading: function(show, msg) {
                this.$refs.loading.showLoading(show, msg);
            },
            run: function() {
                // TODO: We should to save the pipeline first!
                pow.build("!"+this.pipeline.id)
                    .then(()=>{
                        return pow.verify("!"+this.pipeline.id);
                    })
                    .then(()=>{
                        return pow.run("!"+this.pipeline.id)
                    })
                    .then((obj)=>{
                        alert(JSON.stringify(obj.object, null, 2))
                    }).catch(this.handlePOWError);
            },
            handlePOWError: function(err) {
                let message = err.message;
                err.messages.forEach((msg)=>{
                    message += "\n" + msg.type + ": " + msg.message;
                });
                alert(message);
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
            pipelineLoad: function(id, opts) {
                // Load pipeline definition
                opts = opts || {};
                opts.skipConfirm=opts.skipConfirm||false;
                if (!opts.skipConfirm && !confirm("Are you sure you want to clear the grid and load a new pipeline?")) return;
                this.showLoading(true, `Loading pipeline (${id})...`);
                pow.pipeline(`${id}`)
                    .then((res)=>{
                        pipelineManager.import(res.object);
                        if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                        this.pipeline = res.object;
                        this.loaded("pipeline");
                        this.showLoading(false);
                    }).catch(this.handlePOWError);
            },
            pipelineNew: function() {
                if (!confirm("Are you sure you want to clear the grid and start a new pipeline?")) return;
                pipelineManager.reset();
                this.redraw();
            },
            pipelineOpen: function() {
                if (typeof dialog === "undefined") return alert("Not implemented in the demo!\nTry download the app and run it with electron for all the features.")
                let file = dialog.showOpenDialog({
                    properties: ["openFile"],
                    filters: { name: "Pipelines", extensions: ["json"] }
                });
                if (!file) return;
                pow.load(file[0]).then((res)=>{
                    pipelineManager.import(res.object);
                    if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                    this.pipeline = res.object;
                }).catch(this.handlePOWError);
            },
            pipelineSave: function() {
                let pipeline = pipelineManager.export();
                pow.save(pipeline)
                    .then(()=>alert("Saved"))
                    .catch(this.handlePOWError);
            },
            redraw: function() {
                // Must synch entire grid OR Vue.set(exactObject, newObject)
                this.$refs.stepGrid.doUpdate();
            }
        },
        mounted: function() {
            let root = this;
            this.loading = {components: false, pipeline: false};
            // Listen for events
            this.$root.$on("stepSave", (newStep) => {
                pipelineManager.setStep(newStep);
                this.redraw();
            });
            this.$root.$on("stepPreview", (step) => {
                let component = app.getComponent(step.reference);
                pow.preview(step, component).then((obj)=>{
                    if (obj.object)
                        alert(JSON.stringify(obj.object, null, 2))
                    else
                        alert(obj.output)
                }).catch(this.handlePOWError);
            });
            if (app.DEVMODE) {
                console.clear(); // Vue/electron junk warnings
                pow.init("!examples")
                    .then(()=>root.pipelineLoad("pipeline1", {skipConfirm: true}))
                    .catch(this.handlePOWError);
            }
        }
    });
}