app.root = new Vue({
    el: '#root',
    data: {
        panels: [true],
        items: [
            { title: 'Click Me' },
            { title: 'Click Me' },
            { title: 'Click Me' },
            { title: 'Click Me 2' }
          ]
    },
    methods: {
        showDialog: function(step) {
            //this.$refs.stepForm.show = true; //showDialog();
            let component = app.getComponent(step.reference);
            formBuilder.showForm(app.root.$root, step, component);
        },
        pipelineLoad: function(id) {
            // Load pipeline definition
            fetch(`../examples/${id}/pipeline.json`)
            .then((res)=>res.json())
            .then((obj)=>{
                pipelineManager.import(obj);
                app.stepGrid.doUpdate();
            })
        },
        pipelineOpen: function() {
        },
        pipelineSave: function() {
            dp("pipelineSave")   
        },
    },
    mounted: function() {
        // Make .drag elements draggable
        const dragOpts = {
            revertOnSpill: true, // true=Go back if not dropped
            //copy: true, // true=Copy the element
            accepts: function (el, target, source, sibling) {
                return target.className.indexOf('drop')>=0;
            } 
        };
        app.dragula = dragula([].slice.call(document.querySelectorAll('.drag')),dragOpts).on('drop', function (el, space) {
            let id = el.getAttribute("d-id");
            console.log(id)
            let ref = el.getAttribute("d-ref");
            if (ref) {
                // This is a component
                let component = app.getComponent(ref);
                app.root.$refs.stepGrid.addComponent(space.id, component)
            } else if (id) {
                // This is a step
                app.root.$refs.stepGrid.moveStep(id, space.id);
            }
            app.dragula.cancel(true)
        });
        // Listen for save events
        this.$root.$on('stepSave', (newStep) => {
            let oldStep = pipelineManager.getStep(newStep.id)
            pipelineManager.setStep(newStep);
            // Must synch entire grid OR Vue.set(exactObject, newObject)
            app.stepGrid.doUpdate();
        });
        if (app.DEVMODE) {
            console.clear(); // Vue junk
            this.pipelineLoad('pipeline1')
        }
    }
});
app.stepGrid = app.root.$refs.stepGrid;
app.stepForm = app.root.$refs.stepForm;