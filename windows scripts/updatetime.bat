@echo off
setlocal enabledelayedexpansion

echo --------------------------------------------------
echo Press 'N' to set the system time.
echo Press any other key to skip and continue.
echo --------------------------------------------------

:: Prompt the user for input
:: 'set /p' takes the user input and stores it in the variable 'choice'
set /p choice="Enter choice: "

:: Check if the input is 'n' (case-insensitive)
if /i "%choice%"=="n" (
    echo.
    echo Opening time command...
    time
) else (
    echo.
    echo Skipping time command...
)

echo.
echo --------------------------------------------------
echo Continuing with the rest of the batch file...
echo --------------------------------------------------

:: Put the rest of your commands below this line
dir
echo.
echo Script finished.
pause
