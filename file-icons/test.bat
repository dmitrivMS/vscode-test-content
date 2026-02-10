@echo off
setlocal enabledelayedexpansion

:: Build and deploy script for .NET application
set PROJECT_DIR=%~dp0src\WebApp
set OUTPUT_DIR=%~dp0publish
set CONFIG=Release

echo ============================================
echo   Building project in %CONFIG% mode...
echo ============================================

if exist "%OUTPUT_DIR%" (
    rmdir /s /q "%OUTPUT_DIR%"
)

dotnet publish "%PROJECT_DIR%\WebApp.csproj" -c %CONFIG% -o "%OUTPUT_DIR%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed with error code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

echo Build succeeded. Output: %OUTPUT_DIR%
endlocal
