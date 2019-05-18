#Linux Issues

## User Profile:
* $env:USERPROFILE doesn't exist
* Should be created by install.ps1 (executed in sudo)

## Path Sepaators
* Test-Path "$BinPath/path.txt"

## Install Failure
* ":" is the $env:path separator
* Copy of files failed miserably

``` 
PS /home/marc/work/powowshell> sudo pwsh -f ./bin/install.ps1 -verbose
Installing PowowShell module to /home/marc/.local/share/powershell/Modules ...
VERBOSE: Copying /home/marc/work/powowshell/bin/powowshell.psm1 to /home/marc/.local/share/powershell/Modules\PowowShell\powowshell.psm1 ...
Installing PowowShell module to /usr/local/share/powershell/Modules ...
VERBOSE: Copying /home/marc/work/powowshell/bin/powowshell.psm1 to /usr/local/share/powershell/Modules\PowowShell\powowshell.psm1 ...
Installing PowowShell module to /snap/powershell/21/opt/powershell/Modules ...
Could not install module to /snap/powershell/21/opt/powershell/Modules : Read-only file system
out-file : Could not find a part of the path '/snap/powershell/21/opt/powershell/Modules/PowowShell/path.txt'.
At /home/marc/work/powowshell/bin/install.ps1:56 char:13
+             $PSScriptRoot > "$DestPath\path.txt";
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : OpenError: (:) [Out-File], DirectoryNotFoundException
+ FullyQualifiedErrorId : FileOpenFailure,Microsoft.PowerShell.Commands.OutFileCommand
 
PS /home/marc/work/powowshell> ^C
PS /home/marc/work/powowshell> exit       
marc@lounge:~/work/powowshell$ sudo cp ./bin/powowshell.psd1 /home/marc/.local/share/powershell/Modules/PowowShell/
marc@lounge:~/work/powowshell$ 
```
