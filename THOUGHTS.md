#Thoughts

# Globals
* How do we let steps/components write globals
** In theoriy, components don't know about the pipeline they are running in and hence don't know specific globals
** However, it might be nice to have a general purpose "context" to write to which persists among steps...
** $PipelineParams is readonly for steps and the pipeline maps these to the component parameters
** $PipelineGlobals is writeable for steps (and components!) because it's a global in the pipeline context

##IDE Technology
* Vue/Vuetify: Modern, good look and works with NWJS
* HTML5: no OS; good look and JS; could add node.js server (or NW.js)
* HTA: poor JS/HTML; good option for a quick prototype
* jQuery UI: no have .HTA support (IE8)
* NW.js / AppJS: Not maintained
* **Electron: We have a winner!**
* Node.js: Not a simple tool (client/server)
* Chrome Apps: issues with native messaging, chrome only
* C#: No HTML5, XAML? Difficult?
* Java: sucky suck