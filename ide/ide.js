/* global Vue dragula formBuilder dataTableBuilder console pipelineManager */
let app = {};
if (typeof process !== "undefined") {
    var pow = require("./js/pow").pow;
    pipelineManager = require("./js/pipeline-manager") //  eslint-disable-line
    var {dialog} = require("electron").remote
}
pipelineManager.reset();
app.components = {};
app.cmdlets = {};

app.getComponent = (reference) => {
    if (!app.components) return alert("Components not loaded!")
    let ref = reference.toLowerCase();
    let res = app.components.filter((item)=>item.reference===ref);
    if (res.length===0) {
        if (!app.cmdlets) return alert("Cmdlets not loaded!")
        res = app.cmdlets.filter((item)=>item.reference===ref);
    }
    return res.length>0?res[0]:null;
}
app.DEVMODE = false;
Vue.config.devtools = app.DEVMODE;
Vue.config.productionTip = false;

window.onload = function() {
    app.root = new Vue({
        el: "#root",
        data: {
            panels: [false, false, false],
            message: {
                show: false,
                message: ""
            },
            pipeline: {}
        },
        methods: {
            componentsUpdated: function() {
                let root = this;
                // Make .drag elements draggable
                const dragOpts = {
                    revertOnSpill: true, // true=Go back if not dropped
                    accepts: function(el, target) {
                        return target.className.indexOf("drop")>=0;
                    }
                };
                app.dragula = dragula([].slice.call(document.querySelectorAll(".drag,.drop")),dragOpts).on("drop", function (el, space) {
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
            showLoading: function(show, msg, title) {
                this.$refs.loading.showLoading(show, msg, title);
            },
            run: function() {
                let root = this;
                if (pipelineManager.isDirty() && confirm("Do you want to save before running?")) {
                    return root.pipelineSave().then(root.run);
                }
                this.showLoading(true, "Building "+this.pipeline.id, "Build and Run")
                return pow.build("!"+this.pipeline.id)
                    .then(()=>{
                        this.showLoading(true, "Verifying "+this.pipeline.id, "Build and Run")
                        return pow.verify("!"+this.pipeline.id);
                    })
                    .then(()=>{
                        this.showLoading(true, "Running "+this.pipeline.id, "Build and Run")
                        return pow.run("!"+this.pipeline.id)
                    })
                    .then((obj)=>{
                        if (Array.isArray(obj.object))
                            dataTableBuilder.showTable(this.$root, {title: "Result", items: obj.object});
                        else {
                            let data = JSON.stringify(obj.object, null, 2);
                            alert(data)
                        }
                        this.showLoading(false);
                    }).catch((err)=>{
                        this.showLoading(false);
                        this.handlePOWError(err)
                    });
            },
            handlePOWError: function(err) {
                let message = "";
                if (err.constructor.name === "POWError") message += "POWError:\n";
                if (err.message) message += err.message+"\n";
                if (err.messages && Array.isArray(err.messages))
                    err.messages.forEach((msg)=>message += "\n" + msg.type + ": " + msg.message);
                console.log(err);
                this.showMessage(message, "error");
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
            componentsLoad: function() {
                return pow.components()
                    .then((obj)=>{
                        app.components = obj.object;
                        this.$refs.componentList.setComponents(app.components);
                    }).catch(this.handlePOWError);
            },
            cmdletsLoad: function() {
                return pow.cmdlets()
                    .then((obj)=>{
                        app.cmdlets = obj.object;
                        this.$refs.cmdletList.setCmdlets(app.cmdlets);
                    }).catch(this.handlePOWError);
            },
            pipelineLoad: function(id, opts) {
                // Load pipeline definition
                opts = opts || {};
                if (pipelineManager.isDirty() && !confirm("Are you sure you want to clear the grid and load a new pipeline?")) return;
                this.showLoading(true, `Loading pipeline (${id})...`);
                return pow.pipeline(`${id}`)
                    .then((res)=>{
                        pipelineManager.import(res.object);
                        if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
                        this.pipeline = res.object;
                        this.showMessage(`Pipeline (${id}) loaded`);
                        this.showLoading(false);
                    }).catch(this.handlePOWError);
            },
            pipelineNew: function() {
                if (pipelineManager.isDirty() && !confirm("Are you sure you want to clear the grid and start a new pipeline?")) return;
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
                let root = this;
                let pipeline = pipelineManager.export();
                // TODO: Use existing pipeline id or generate a new one
                let pipelineId = pipeline.id || ("pipeline"+Math.random().toString(36).substring(7));
                return pow.save(pipeline, pipelineId)
                    .then(()=>{
                        pipelineManager.setClean();
                        root.showMessage(`Saved ${pipelineId}`);
                    })
                    .catch(this.handlePOWError);
            },
            redraw: function() {
                // Must synch entire grid OR Vue.set(exactObject, newObject)
                this.$refs.stepGrid.doUpdate();
            },
            showMessage: function(text, color) {
                color = color || "info";
                if (this.message.show) {
                    // Already visible, add to the message
                    this.message.show = false;
                    this.showMessage(this.message.text + " " + text, color);
                    return;
                }
                this.message.text = text;
                this.message.color = color;
                this.message.show = true;
            }
        },
        mounted: function() {
            let root = this;
            // Listen for events
            this.$root.$on("stepSave", (newStep) => {
                pipelineManager.setStep(newStep);
                this.redraw();
            });
            this.$root.$on("componentExamples", (reference, type) => {
                let ref = type==="cmdlet"?reference:"!"+reference;
                pow.examples(ref)
                    .then((res)=>{
                        if (!res.object || res.object.length===0) return alert("No examples found!")
                        res.object.forEach((o)=>{
                            let msg = o.code+"\n"+o.description;
                            msg = msg.replace("`n", "\n");
                            alert(msg)
                        });
                    }).catch(this.handlePOWError);
            });
            this.$root.$on("stepPreview", (step) => {
                if (typeof step === "string") {step = pipelineManager.getStep(step);}
                let component = app.getComponent(step.reference);
                pow.preview(step, component).then((obj)=>{
                    if (obj.object)
                        alert(JSON.stringify(obj.object, null, 2))
                    else
                        alert(obj.output)
                }).catch(this.handlePOWError);
            });
            this.$root.$on("stepRemove", (step) => {
                if (typeof step === "string") {step = pipelineManager.getStep(step);}
                if (confirm("Are you sure you want to remove this step?")) {
                    pipelineManager.removeStep(step.id);
                    this.redraw();
                }
            });
            if (app.DEVMODE) {
                console.clear(); // Vue/electron junk warnings
                //pow.execOptions.debug=true;
                pow.init("!examples")
                    .then(()=>{
                        root.componentsLoad()
                        root.cmdletsLoad()
                    })
                    .then(()=>root.pipelineLoad("pipeline2"))
                    .then(()=>root.run())
                    .catch(this.handlePOWError);
            } else {
                root.componentsLoad();
                root.cmdletsLoad();
            }
        }
    });
}