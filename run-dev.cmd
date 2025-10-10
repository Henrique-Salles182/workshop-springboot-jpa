@echo off
REM Fallback batch wrapper for Windows cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-dev.ps1" %*
