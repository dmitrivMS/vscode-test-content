@echo off
rem Service management script for Windows

set SERVICE_NAME=AppWorker
set INSTALL_DIR=%ProgramFiles%\AppWorker

if "%1"=="start" goto :start
if "%1"=="stop" goto :stop
if "%1"=="status" goto :status
echo Usage: %~nx0 [start^|stop^|status]
exit /b 1

:start
echo Starting %SERVICE_NAME%...
net start %SERVICE_NAME%
if %ERRORLEVEL% equ 0 (
    echo %SERVICE_NAME% started successfully.
) else (
    echo Failed to start %SERVICE_NAME%.
)
exit /b %ERRORLEVEL%

:stop
echo Stopping %SERVICE_NAME%...
net stop %SERVICE_NAME%
exit /b %ERRORLEVEL%

:status
sc query %SERVICE_NAME% | findstr /i "STATE"
exit /b 0
