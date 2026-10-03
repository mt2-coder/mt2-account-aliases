@echo off
rem Reports what is installed. Changes nothing.
rem Extra arguments go to the installer.
setlocal
title mt2-account-aliases - status
set "SCRIPT=%~dp0scripts\alias-addon.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0..\scripts\alias-addon.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" status %*
set "CODE=%ERRORLEVEL%"
echo.
pause
exit /b %CODE%
