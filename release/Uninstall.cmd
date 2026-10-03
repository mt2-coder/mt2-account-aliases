@echo off
rem Removes the alias add-on: restores the Gameforge Client's original frontend.pak.
rem Extra arguments go to the installer.
setlocal
title mt2-account-aliases - uninstall
set "SCRIPT=%~dp0scripts\alias-addon.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0..\scripts\alias-addon.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" revert %*
set "CODE=%ERRORLEVEL%"
echo.
pause
exit /b %CODE%
