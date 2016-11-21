#PowowShell

Ever dreamed of drawing a visual data flow and pressing "Play" to see it run?
I have, and that's why I dreamed up PowowShell: a graphical designer powered
by PowerShell.

##The Vision
Imagine dragging a CSV File component into your pipeline, connecting it to a 
Database component and pressing "Play" to load data into your database. What
about getting an email out if some records don't load? Drag in an Email component
and connect it to the Errors output of your Database component. Call a web service?
Sure, just use a Transform component to map your data to the format required.

### Pipelines

Pipelines are where the magic happens. Here you connect your components together in a sequence. The pipeline is run in columns: Column A is run, then B etc. In each column the components are executed from top to bottom so you'd have: A1 -> B1 -> B2 -> C1 -> C2 -> C3 -> D1

 ![pipeline](docs/pipeline.png)

### Components

The diagram shows the 4 types of components (source, transform, destination and script) and how data can flow between them. It also shows how script components just run, needing no input and producing no output. Indeed you can use a pipeline to just run some commands in sequence.

##Installation

There is no GUI yet. Download the repository and compile and run the sample pipeline as follows:
```
git clone git@github.com:cawoodm/powowshell.git
cd powowshell/bin
install
```
This will create `pow.cmd` which you should copy to your PATH so you can run it from anywhere.
Let's check if we're up and running by displaying the version:
```
pow version
```
Now we'll compile and run the example pipeline:
```
pow compile examples\pipeline1
pow run examples\pipeline1
```

This builds and runs a pipeline based on it's definition in `pipeline.json`.
The result of the build `compile.ps1` is a powershell script `runner.ps1`. Running this runs the pipeline.
The pipeline does the following:
* Step A: Read a list of voters from the file in `data\voters.txt` as text
* Step B: Convert the text to JSON
* Step C: Select only the name. age and email fields

The result is a JSON string representing a list of voters.

We'll be developing this pipeline by adding new steps like:

* Filtering only young voters (age < 30)
* Sending each voter an email

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

##Component Definition
A component is just a script with some basic requirements
* It must declare its PARAMETERS with types
* If it accepts INPUT, it gets the data as a String from the pipeline (stdin) with parameter $InputObject
* If it provides OUTPUT, it writes it's output as a String to the pipeline (stdout) with Write-Output
* It writes any errors to the pipeline (stderr) with Write-Error
* It has annotated help describing it's function and parameters

As you can see, PowowShell expects components to behave in a certain way. This may be a pain but it makes things easier later. One of the weaknesses of PowerShell is that very few CmdLets can interact because most have their own special object types. You can't pass the output of one object type to another easily. PowowShell ensures each component can only write a String. This may sound limiting but since you can put JSON (or whatever) into that string, you retain all of the flexibility of objects. Of course if one component outputs JSON, the next component downstream needs to accept JSON or you need to put a Transform component in between.

Let's look at some [component examples](docs/Component-Examples.md).

