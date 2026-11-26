@echo off
setlocal DisableDelayedExpansion
title Windows 11 Local Whisper Preflight & Model Fit Checker (v1.2)

:START
cls
echo ====================================================================
echo   WINDOWS 11 LOCAL WHISPER PREFLIGHT ^& MODEL FIT CHECKER (v1.2)
echo   (Portable Windows Toolkit ^| Read-Only Audit ^| No Python Required)
echo ====================================================================
echo.
set "outDir=%~dp0."
set "customOut="
set /p "customOut=Save report in this toolkit folder? Press Enter for default or paste a folder path: "
if not defined customOut goto RUN
set "customOut=%customOut:"=%"
if not defined customOut goto RUN
call :StripSlash
if not defined customOut goto RUN
if "%customOut%"=="" goto RUN
set "outDir=%customOut%"

:RUN
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-Whisper-Preflight.ps1" -OutputFolder "%outDir%"
echo.
pause
goto START

:StripSlash
if not defined customOut goto :eof
if "%customOut:~-1%"=="\" set "customOut=%customOut:~0,-1%"
goto :eof
