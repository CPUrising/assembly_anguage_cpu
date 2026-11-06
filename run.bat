@echo off
chcp 65001 >nul
setlocal

echo ============================================
echo    Assembly Homework - DOSBox Quick Launch
echo ============================================
echo.

if "%1"=="" (
    set /p HW=Enter homework number 1-5, Enter to exit: 
) else (
    set HW=%1
)

if "%HW%"=="" goto :eof

if "%HW%"=="1" (
    set DIR=homework1_helloworld
) else (
    set DIR=homework%HW%
)

set FULL=D:\documents\assembly_anguage_cpu\%DIR%

if not exist "%FULL%" (
    echo.
    echo [ERROR] Directory not found: %FULL%
    echo.
    pause
    exit /b 1
)

echo.
echo Mounting: %DIR%
echo DOSBox will open and stop at C:\ prompt.
echo You can type masm / link / run commands directly.
echo.

"C:\Users\Lenovo\Desktop\DOSBox-0.74\DOSBox.exe" -c "mount c %FULL%" -c "mount d D:\Masm50" -c "path d:\;d:\bin" -c "c:" -c "dir"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to launch DOSBox
    pause
)

goto :eof