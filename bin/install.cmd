@ECHO OFF
POWERSHELL -Command "' PowerShell version: ' + $PSVersionTable.PSVersion.toString()"
IF %ERRORLEVEL% GTR 0 GOTO ERR_PSC

:: Check if pow is already installed
DEL /Q pow.cmd 2>nul
WHERE /Q pow.cmd
IF %ERRORLEVEL% EQU 0 GOTO ERR_POWI

POWERSHELL -File "%~dp0\installer.ps1"
IF %ERRORLEVEL% GTR 0 GOTO ERR_PSF

GOTO:eof

:ERR_PSC
ECHO ERROR: Please ensure PowerShell v3 or greater is installed!
GOTO:eof

:ERR_PSF
ECHO ERROR: Your system does not allow unsigned PowerShell scripts to run!
ECHO PowowShell is unsigned so you may need to run the following command as an administrator in order to proceed:
ECHO   POWERSHELL -Command "Set-ExecutionPolicy Unrestricted"
ECHO
ECHO Alternatively, just right-click on security.cmd in this folder and say "Run as Administrator"
ECHO WARNING: This could put you at risk. Use carefully and google "powershell executionpolicy".
ECHO
ECHO Another option ist to copy powershella.cmd to your path and then set the following environment variable:
ECHO   SET %POWERSHELL%=POWERSHELLA
ECHO This works around PowerShell security by encoding scripts for execution.
ECHO PowowShell will now use powershella.cmd for executing powershell
GOTO:eof

:ERR_POWI
ECHO  WARNING: pow.cmd is already installed on your system. You should be able to run pow already!
ECHO   Otherwise, delete the following file in order to re-install:
WHERE pow.cmd
GOTO:eof