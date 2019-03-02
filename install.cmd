@ECHO OFF

:: Do a PowerShell Install
ECHO 1. Installing the "pow" CmdLet in PowerShell...
POWERSHELL -Command "Import-Module -Global .\bin\powowshell.psm1 -Force"
ECHO[

:: Do a "DOS" install
ECHO 2. Creating the "pow.cmd" for Command Line (DOS) use...
bin\install.cmd
