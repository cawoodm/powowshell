#Thoughts

# PS6: PWSH
* We could use `ConvertTo-JSON -AsArray` to standardize arrays
* `Get-Date | ConvertTo-Json` is better than PSv5

# General PowerShell
* Set-PSDebug (-Off or -Trace 1|2)

# Components
* Should we use a separate MyComponent.selftest.ps1 instead of the ugly `-POWAction test` parameter?

# Globals
* How do we let steps/components write globals
** In theory, components don't know about the pipeline they are running in and hence don't know specific globals
** It's also dangerous for components to depend on variables which they don't control
** It's better for them to be agnostic and only use their own parameters
** However, it might be nice to have a general purpose "context" to write to which persists among steps...
** $PipelineParams is readonly for steps and the pipeline designer can map these to the component parameters
** $PipelineGlobals is writeable for steps (and components!) because it's a global in the pipeline context
** It's bad practice for a component to read $PipelineGlobals without setting it but we can't prevent it