@echo off
rem ===================================================================
rem  X51 Step 4 - List everything in the OneDrive folder (READ-ONLY)
rem  Records every file name, size and date, including cloud-only files,
rem  without downloading anything. Keep OneDrive CLOSED while running.
rem  Output: Desktop\X51-Inventory\12-onedrive-summary.txt and
rem          Desktop\X51-Inventory\12-onedrive-file-list.csv
rem ===================================================================
title X51 OneDrive list
tasklist | findstr /i "onedrive.exe" >nul
if not errorlevel 1 (
  echo  OneDrive is running. Please quit it first:
  echo  right-click the cloud icon near the clock, then Quit OneDrive.
  pause
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0list-onedrive.ps1"
echo.
echo  Done. Nothing was downloaded or changed.
start "" explorer "%USERPROFILE%\Desktop\X51-Inventory"
pause
