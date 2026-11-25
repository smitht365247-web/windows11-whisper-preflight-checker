@echo off
setlocal enabledelayedexpansion
title Windows 11 Local Whisper Preflight & Model Fit Checker (v1.0)

:START
cls
echo ====================================================================
echo   WINDOWS 11 LOCAL WHISPER PREFLIGHT ^& MODEL FIT CHECKER (v1.0)
echo   (Portable Windows Toolkit ^| Read-Only Audit ^| No Python Required)
echo ====================================================================
echo.
set "outDir=%~dp0"
set /p customOut="Save report in this folder? Press Enter for default or paste a folder path: "
set "customOut=%customOut:"=%"
if "%customOut:~-1%"=="\" set "customOut=%customOut:~0,-1%"
if not "%customOut%"=="" set "outDir=%customOut%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-Whisper-Preflight.ps1" -OutputFolder "%outDir%"
echo.
pause
goto START
