!PowowShell

Ever dreamed of drawing a visual data flow and pressing "Play" to see it run.
I have, and that's why I dreamed up PowowShell: a graphical designer powered
by PowerShell.

!!The Vision
Imagine dragging a CSV File component into your pipeline, connecting it to a 
Database component and pressing "Play" to load data into your database. What
about getting an email out if some records don't load? Drag in an Email component
and connect it to the Errors output of your Database component. Call a web service?
Sure, just use a Transform component to map your data to the format required.

!!PowerShell
PowerShell is a cross platform, open source shell designed by Microsoft which
runs on Windows, Mac and Linux. It's powerful and fun to use and becoming much
more than a utility merely for IT departments. It's designed around discreet
functionality called "CmdLets" which generally accept and provide input and 
output on the pipeline.

!!What does PowowShell do?
PowowShell aims to let you design and run workflows (called Pipelines) which
consist of individual powershell components. These components are joined together
in a sequence of steps with data from one step feeding into another.

What each step does is up to you. You can use existing powershell Cmdlets, write
your own advanced functions and scripts, or even call any command line utility
you like curl, awk, batch files, what every you have. Because components are written
in powershell (yes you do have to write code to make components) you can also tap into
the full power of the .NET framework very easily to do just about anything.

* A Scriptlet is a compatible powershell script
** It is a Powershell script *.ps1
** It declares it's parameters with types and if mandatory
** It gets it's input from the pipeline (stdin) with $input
** It writes it's output to the pipeline (stdout) with Write-Output
** It writes it's errors to the pipeline (stderr) with Write-Error
** It has annotated help describing it's function and parameters
*** Check it with help .\mycomponent.ps1 -full

!TODO
* We need to create the pipeline.ps1 file from the pipeline definition in pipeline.json
* We need to create the step files from components
** from a metadata JSON description of component.ps1?
** by parsing component.ps1? -> will exclude standard CmdLets we don't have the source for
** by inspecting component.ps1 with Get-Command?
* We need to deal with not passing on empty parameters
* Pipeline parameters
* Change Write-Debug to Write-Verbose?