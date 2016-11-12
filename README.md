#PowowShell

Ever dreamed of drawing a visual data flow and pressing "Play" to see it run.
I have, and that's why I dreamed up PowowShell: a graphical designer powered
by PowerShell.

##The Vision
Imagine dragging a CSV File component into your pipeline, connecting it to a 
Database component and pressing "Play" to load data into your database. What
about getting an email out if some records don't load? Drag in an Email component
and connect it to the Errors output of your Database component. Call a web service?
Sure, just use a Transform component to map your data to the format required.

##PowerShell
PowerShell is a cross platform, open source shell designed by Microsoft which
runs on Windows, Mac and Linux. It's powerful and fun to use and becoming much
more than a utility merely for IT departments. It's designed around discreet
functionality called "CmdLets" which generally accept and provide input and 
output on the pipeline.

##What does PowowShell do?
PowowShell aims to let you design and run workflows (called Pipelines) which
consist of individual powershell components. These components are joined together
in a sequence of steps with data from one step feeding into another.

What each step does is up to you. You can use existing powershell Cmdlets, write
your own advanced functions and scripts, or even call any command line utility
you like curl, awk, batch files, what every you have. Because components are written
in powershell (yes you do have to write code to make components) you can also tap into
the full power of the .NET framework very easily to do just about anything.

##Components
A component is just a script with some basic requirements
* It must declares it's PARAMETERS with types
* If it accepts INPUT, it gets the data as a String from the pipeline (stdin) with parameter $InputObject
* If it provides OUTPUT, it writes it's output as a String to the pipeline (stdout) with Write-Output
* It writes any errors to the pipeline (stderr) with Write-Error
* It has annotated help describing it's function and parameters

As you can see, PowowShell expects components to behave in a certain way. This may be a pain but it makes 
things easier later. One of the weaknesses of PowerShell is that very few CmdLets can interact because most have their own
special object types. You can't pass the output of one object type to another easily. PowowShell ensures each 
component can only write a String. This may sound limiting but since you can put JSON (or whatever) into
that string, you retain all of the flexibility of objects. Of course if one component outputs JSON, the
next component downstream needs to accept JSON or you need to put a Transform component in between.

Let's look at some components:

###Hello World Component
The most simple component could accept no input and just return a string like this:
```powershell
Write-Output "hello, world"
```

###DOS Wrapper Component
You don't have to run powershell, you can call OS commands. You can also pass parameters:
```powershell
param(
    [String]$Path
)
CMD /C "DIR /B $Path"
```

###Example Component
Suppose you want a component which returns today's date plus N days. Your DateAdder.ps1 component could look
like this (with full annotation):
```powershell
<#
    .Synopsis
    Add some days to today's date and return the date

    .Parameter days
    The number of days (integer) to add (or subtract) to todays date
		
		.Output
		
#>
param(
    [int]$days=0
)
Write-Output (Get-Date).AddDays($days).toString('yyyy-MM-dd')
```

This component is a fully-fledged powershell script and can be run from the powershell console like this:
```powershell
./DateAdder.ps1 -days 14
```
It will output the date in 2 weeks as: `2016-11-26`.