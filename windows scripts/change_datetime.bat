@echo off
setlocal enabledelayedexpansion

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

:START
cls
echo ======================================================
echo          WINDOWS DATE AND TIME CHANGER
echo ======================================================
echo.

:: Get current date/time using built-in %DATE% and %TIME% variables
echo Current System Date: %DATE%
echo Current System Time: %TIME%
echo.
echo [D] Change Date
echo [T] Change Time
echo [Q] Quit
echo.

set /p choice="Select an option: "

if /i "%choice%"=="D" goto CHANGE_DATE
if /i "%choice%"=="T" goto CHANGE_TIME
if /i "%choice%"=="Q" exit /b 0
goto START

:CHANGE_DATE
echo.
echo Enter new date. 
echo Note: Use the format shown above (e.g., YYYY-MM-DD or YY-MM-DD depending on your region).
set /p new_date="New Date: "

if "%new_date%"=="" goto START

date %new_date%
if %errorlevel% equ 0 (
    echo Date successfully updated to %new_date%.
) else (
    echo [ERROR] Failed to update date. Check format.
)
pause
goto START

:CHANGE_TIME
echo.
echo Enter new time in 24-hour format (HH:MM:SS).
echo Example: 14:30:00
set /p new_time="New Time: "

if "%new_time%"=="" goto START

time %new_time%
if %errorlevel% equ 0 (
    echo Time successfully updated to %new_time%.
) else (
    echo [ERROR] Failed to update time. Check format.
)
pause
goto START
