#Thoughts

# Components
* Components can now self test with the `-POWAction test` parameter

# Globals
* How do we let steps/components write globals
** In theory, components don't know about the pipeline they are running in and hence don't know specific globals
** It's also dangerous for components to depend on variables which they don't control
** It's better for them to be agnostic and only use their own parameters
** However, it might be nice to have a general purpose "context" to write to which persists among steps...
** $PipelineParams is readonly for steps and the pipeline designer can map these to the component parameters
** $PipelineGlobals is writeable for steps (and components!) because it's a global in the pipeline context
** It's bad practice for a component to read $PipelineGlobals without setting it but we can't prevent it

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