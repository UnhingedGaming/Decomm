@echo off
rem ===================================================================
rem  T480S Step 7 - AppData and account report (READ-ONLY)
rem  Lists what is in AppData, every OneDrive folder on the PC and its
rem  real size, and which Microsoft accounts this user signed in with.
rem  Output: Desktop\T480S-AppData-Report.txt
rem  Run it normally (double-click) - it does not need administrator.
rem ===================================================================
title T480S AppData report
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0appdata-report.ps1"
echo.
pause
