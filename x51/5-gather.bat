@echo off
rem ===================================================================
rem  X51 Step 5 - Gather every personal file into Desktop\X51-Gathered
rem  Finds every real file on C: that isn't Windows or a program, wherever
rem  it is, and MOVES it into Desktop\X51-Gathered keeping its folders.
rem  Files in OneDrive are copied, not moved. Undo list: _undo-list.csv
rem  Cloud-only OneDrive shortcuts are skipped (they live in the cloud).
rem  Keep OneDrive CLOSED. Safe to run again if the PC freezes.
rem ===================================================================
title X51 Gather
net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
tasklist | findstr /i "onedrive.exe" >nul
if not errorlevel 1 (
  echo  OneDrive is running. Quit it first: right-click the cloud icon, Quit OneDrive.
  pause
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rescue.ps1" -Mode Gather
echo.
pause
