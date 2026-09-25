@echo off
rem ===================================================================
rem  T480S Step 4 - List everything in the OneDrive folder (READ-ONLY)
rem  Records every file name, size and date, including cloud-only files,
rem  without downloading anything. Keep OneDrive CLOSED while running.
rem  Output: Desktop\T480S-Inventory\12-onedrive-summary.txt and
rem          Desktop\T480S-Inventory\12-onedrive-file-list.csv
rem ===================================================================
title T480S OneDrive list
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
start "" explorer "%USERPROFILE%\Desktop\T480S-Inventory"
pause
