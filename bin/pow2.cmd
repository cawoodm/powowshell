@ECHO OFF
::ECHO ALL %*
::ECHO 1 %1
::POWERSHELL -Command "& 'D:\Google Drive\Work\PowerShell\powowshell\bin\run.ps1' ./examples/pipeline1 @{DataSource='D:\Google Drive\Work\PowerShell\powowshell\examples\pipeline1\data\names.txt'}"
::ECHO POWERSHELL -Command "& 'D:\Google Drive\Work\PowerShell\powowshell\bin\run.ps1' %2 %3 %4 %5"
:: C:\Marc\prg\cmd\pow.cmd
POWERSHELL -Command "& 'D:\Google Drive\Work\PowerShell\powowshell\bin\pow.ps1' %1 %2 %3 %4 %5"