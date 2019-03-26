CHANGELOG

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