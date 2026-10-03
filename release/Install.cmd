@echo off
rem Installs the alias add-on into the Gameforge Client, or updates it.
rem Extra arguments go to the installer, for example: Install.cmd -Diagnostic
setlocal
title mt2-account-aliases - install
set "SCRIPT=%~dp0scripts\alias-addon.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0..\scripts\alias-addon.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" install %*
set "CODE=%ERRORLEVEL%"
echo.
pause
exit /b %CODE%
