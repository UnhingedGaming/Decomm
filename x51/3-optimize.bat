@echo off
rem ===================================================================
rem  X51 Step 3 - Health check and optimize
rem  Repairs Windows system files, checks the drive (read-only scan),
rem  optimizes drives (defrag for hard disks, TRIM for SSDs), and sets
rem  the High performance power plan. Does not touch personal files.
rem  Creates a System Restore point first.
rem  Log: Desktop\X51-Logs\3-optimize.log
rem ===================================================================
setlocal
title X51 Optimize

net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "LOGDIR=%USERPROFILE%\Desktop\X51-Logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "LOG=%LOGDIR%\3-optimize.log"
echo X51 optimize started %DATE% %TIME% > "%LOG%"

for /f "tokens=4-5 delims=. " %%i in ('ver') do set "WINVER=%%i.%%j"

echo.
echo  STOP: only run this AFTER the inventory confirms your files are safe
echo  and backed up. If files may be missing, close this window now -
echo  writing to the drive can destroy deleted files you want back.
echo.
echo  This can take 30-90 minutes. Keep the PC plugged in and awake.
echo.
pause

echo [1/5] Creating a System Restore point
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Before X51 optimize", 100, 7 >> "%LOG%" 2>&1

echo [2/5] Repairing the Windows image - needs internet
if not "%WINVER%"=="6.1" (
  Dism /Online /Cleanup-Image /RestoreHealth
  echo DISM exit code %ERRORLEVEL% >> "%LOG%"
)

echo [3/5] Checking Windows system files
sfc /scannow
echo SFC exit code %ERRORLEVEL% >> "%LOG%"
findstr /c:"[SR]" "%windir%\Logs\CBS\CBS.log" > "%LOGDIR%\3-sfc-details.txt" 2>nul

echo [4/5] Scanning the drive for errors - read-only, nothing is fixed automatically
if "%WINVER%"=="6.1" (
  chkdsk %SystemDrive% >> "%LOG%" 2>&1
) else (
  chkdsk %SystemDrive% /scan >> "%LOG%" 2>&1
)
echo chkdsk exit code %ERRORLEVEL% >> "%LOG%"
if errorlevel 1 (
  echo   !! chkdsk found problems. See the log, and tell Claude before fixing.
) else (
  echo   Drive looks healthy.
)

echo [5/5] Optimizing drives and power plan
if "%WINVER%"=="6.1" (
  defrag %SystemDrive% /A /V >> "%LOG%" 2>&1
  echo   Windows 7: drive analysed only - see log.
) else (
  rem /O picks the right method per drive: defrag for hard disks, TRIM for SSDs.
  defrag /C /O /U /V >> "%LOG%" 2>&1
)
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >> "%LOG%" 2>&1
powercfg -getactivescheme >> "%LOG%" 2>&1

echo.
echo  Done. Log: %LOG%
echo  Please restart the PC when convenient.
echo.
pause
