CHANGELOG

v0.1.8 05.05.2019
* Data grid vizualisation of pipeline output
* Edit pipeline details form
* pow run export can now automatically convert non-string output to JSON

v0.1.7 16.04.2019
* Streamed pipelines
* CmdLet support as components
* Adaptors made but not yet used

v0.1.6 09.04.2019
* Save, build, verify and run from IDE
* Preview step from IDE

v0.1.5 26.03.2019
* Return issues with component in POWMessages in `pow inspect`
* Universally use `$ErrorActionPreference Stop` to ensure exceptions are thrown
* Component tests and -POWAction

v0.1.4 24.03.2019
* Use vuetify cards for steps
* Load pipeline definition dynamically
* Load components definition dynamically
* Switched pow to UTF-8 output for components export
* Removed path and extension from component reference
* Esc to close step

v0.1.3 23.03.2019
* BUGFIX: Paths broken in pow build/run/verify etc
* Dynamically load available inputs selector on step
* IDE Forms
* Input/Output Descriptions of components

v0.1.1 16.03.2019
* Drop DOS support
* Generate components.json with `pow components ./examples/components export | ConvertTo-JSON`