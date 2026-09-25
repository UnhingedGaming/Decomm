@echo off
rem ===================================================================
rem  LAPTOTS Step 7 - AppData and account report (READ-ONLY)
rem  Lists what is in AppData, every OneDrive folder on the PC and its
rem  real size, and which Microsoft accounts this user signed in with.
rem  Output: Desktop\LAPTOTS-AppData-Report.txt
rem  Run it normally (double-click) - it does not need administrator.
rem ===================================================================
title LAPTOTS AppData report
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0appdata-report.ps1"
echo.
pause
