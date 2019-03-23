app.root = new Vue({
    el: '#root',
    data: {
        panels: [true]
    },
    methods: {
        showDialog: function(step) {
            //this.$refs.stepForm.show = true; //showDialog();
            let component = app.getComponent(step.reference);
            formBuilder.showForm(app.root.$root, step, component);
        }
    },
    mounted: function() {
        // Make .drag elements draggable
        app.dragula = dragula([].slice.call(document.querySelectorAll('.drag')),{
            revertOnSpill: true, // true=Go back if not dropped
            copy: true, // true=Copy the element
            accepts: function (el, target, source, sibling) {
                return target.className.indexOf('drop')>=0;
            } 
        }).on('drop', function (el, space) {
            let id = el.getAttribute("d-id");
            let ref = el.getAttribute("d-ref");
            if (ref) {
                // This is a component
                let component = app.getComponent(ref);
                app.root.$refs.stepsGrid.addComponent(space.id, component)
            }
            app.dragula.cancel(true)
        });
        // Listen for save events
        this.$root.$on('stepSave', (newStep) => {
            let oldStep = pipelineManager.getStep(newStep.id)
            pipelineManager.setStep(newStep);
            // Must synch entire grid OR Vue.set(exactObject, newObject)
            app.stepsGrid.doUpdate();
        });
    }
});
app.stepsGrid = app.root.$refs.stepsGrid;
app.stepForm = app.root.$refs.stepForm;
console.clear(); // Vue junk