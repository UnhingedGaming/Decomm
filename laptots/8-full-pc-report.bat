@echo off
rem ===================================================================
rem  LAPTOTS Step 8 - FULL PC REPORT (READ-ONLY)
rem  Reads the name and size of every file on C: - opens nothing,
rem  changes nothing. Shows where every GB is and where personal files
rem  (photos, videos, documents...) are hiding, including AppData.
rem  Output in C:\Users\<you>\Desktop:
rem    LAPTOTS-Full-Report.txt and LAPTOTS-All-Folders.csv
rem ===================================================================
title LAPTOTS Full PC report
net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights so every folder can be read...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0full-pc-report.ps1"
echo.
pause
