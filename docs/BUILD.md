BUILD

A pipeline definition (source) is compiled into a single PowerShell "scriptlet".
A pipeline is organized by arranging steps onto a 10x10 grid layout.

Build Process:
* Left to Right, Top to Bottom
* Each row is processed as a single line of code with each step piped into the next
* By default a step receives the piped input of the previous step UNLESS
** The step does not accept piped input
** The designer specifies a different step input
** The designer specifies NO (null) input
* Pipe flow can be broken up by
** Placing steps on a new row
** Separating steps by a space (empty grid placeholder)
** Specifying a different/null input