@ECHO OFF

:: Do a PowerShell Install
ECHO 1. Installing the "pow" CmdLet in PowerShell...
POWERSHELL -File ".\bin\install.ps1" %*
POWERSHELL -Command "pow version"
