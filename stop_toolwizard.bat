@echo off
title Stop Tool Wizard Server
echo ========================================================
echo               STOPPING TOOL WIZARD SERVER
echo ========================================================
echo.
set FOUND=0
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5000 " ^| findstr "LISTENING"') do (
    if not "%%a"=="0" (
        echo Terminating process PID %%a on port 5000...
        taskkill /F /PID %%a >nul 2>&1
        set FOUND=1
    )
)

if "%FOUND%"=="1" (
    echo.
    echo [SUCCESS] Tool Wizard server has been stopped.
) else (
    echo.
    echo [INFO] Tool Wizard server is not currently running.
)
