# Component Examples

### Hello World Component

The most simple component could accept no input and just return a string like this:

```powershell
Write-Output "hello, world"
```

I like to call such components, which take no input "Source Components". Examples would be file or database readers.

### DOS Wrapper Component

Although your components must be PowerShell scripts, you can call OS commands easily from PowerShell. This means you can easily wrap your favorite shell commands (like AWK or curl) or your favorite Perl, Python or WhatHaveYou Scripts. You can also pass parameters:

```powershell
param(
    [String]$Path
)
CMD /C "DIR /B $Path"
```

### Date Adder Component

Let's look at a more interesting component. Suppose you want something which returns today's date plus a certain number of days. Your `DateAdder.ps1` component could look
like this (with full annotations):

```powershell
<#
    .Synopsis
    Add some days to today's date and return the date

    .Parameter days
    The number of days (integer) to add (or subtract) to todays date
    
    .Outputs
    date

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

It will output the date in 2 weeks as: `2016-11-26`. The output type for all components is always technically a string. The question of what the string signifies (or serializes) is answered by the `.Outputs` annotation in the comments.

This component is better than the above examples (because it declares it's interface and has a description) but it can be improved some more. In the next example we'll see how to accept INPUT via the powershell pipe from a preceding component.

### Data2JSON Component

The following component takes a text string (passed in from some previous component which read from a text file) and parses it into a JSON object. The input string would look something like this:

````
John|28|M
Sarah|29|F
Joe|45|M
````

Here's the code for `DATA2JSON.ps1`:

```powershell
<#
 .SYNOPSIS
  Convert input data to JSON format

 .DESCRIPTION
  Accepts custom tabular data about people and return contents as a JSON Array
	The data must be in the format:
	NAME|AGE|GENDER
	However, the separator can be different and specified by the -Delimiter parameter

 .PARAMETER Delimiter
  Specifies the field separator. Default is a comma ",")
	
 .EXAMPLE
  Data2JSON.ps1 -Delimiter ";"
 
 .INPUTS
  text
	
 .OUTPUTS
  json[]

#>
[CmdLetBinding()]
[OutputType([String])]
param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$InputObject,
	[Parameter(Mandatory=$false)][String]$RecordSeparator,
  [Parameter(Mandatory=$true)][String]$Delimiter=","
)

# The Magic Happens Here...
$result = ""
$r = 0
$str = [string]$InputObject

If ($RecordSeparator) {
	$sep = $RecordSeparator
} Else {
	If ($str.IndexOf("`r`n") -ge 0) {$sep = "`r`n"}
	ElseIf ($str.IndexOf("`r") -ge 0) {$sep = "`r"}
	Else {$sep = "`n"}
}

$rows = $str -split $sep
$rows | ForEach-Object {
    $row = $_ -split $Delimiter, 0, "SimpleMatch"
    If ($row.Length -gt 1) {
        $result += '{"name":"'+$row[0]+'", "age":'+$row[1]+', "gender":"'+$row[2] + '"}'
        $r++
    }
}

# Format as a JSON Array
$result = $result.Replace("}{", "},{")
$result = "[$result]"

# Return JSON serialized
$result
```



