app.root = new Vue({
    el: '#root',
    data: {
        panels: [true]
    },
    methods: {
        showDialog: function(step) {
            //this.$refs.stepForm.show = true; //showDialog();
            let component = app.getComponent(step.reference);
            formBuilder.showForm(step, component);
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
        dp("listening on ", this.$root)
        this.$root.$on('stepSave', (newStep) => {
            let oldStep = pipelineManager.getStep(newStep.id)
            dp("got the save bru!", newStep.name, oldStep.name)
            // TODO
            // Doesn't work: oldStep = newStep;
            // Clone is not synched with Vue: pipelineManager.setStep(newStep);
        });
    }
});
app.stepsGrid = app.root.$refs.stepsGrid;
app.stepForm = app.root.$refs.stepForm;