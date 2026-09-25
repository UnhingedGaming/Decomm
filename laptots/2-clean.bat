@echo off
rem ===================================================================
rem  LAPTOTS Step 2 - Clean junk files
rem  Deletes ONLY temporary files and Windows caches.
rem  NEVER touches: Documents, Pictures, Desktop, Downloads, OneDrive,
rem  the Recycle Bin, or old Windows installations (Windows.old).
rem  Creates a System Restore point first.
rem  Log: Desktop\LAPTOTS-Logs\2-clean.log
rem ===================================================================
setlocal EnableDelayedExpansion
title LAPTOTS Clean

net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "LOGDIR=%USERPROFILE%\Desktop\LAPTOTS-Logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "LOG=%LOGDIR%\2-clean.log"
echo LAPTOTS clean started %DATE% %TIME% > "%LOG%"

for /f "tokens=4-5 delims=. " %%i in ('ver') do set "WINVER=%%i.%%j"
echo Windows version: %WINVER% >> "%LOG%"

echo.
echo  STOP: only run this AFTER the inventory confirms your files are safe
echo  and backed up. If files may be missing, close this window now -
echo  writing to the drive can destroy deleted files you want back.
echo.
echo  This removes temporary files and Windows caches only.
echo  Your personal files, OneDrive, Downloads and Recycle Bin are not touched.
echo.
pause

echo [1/5] Creating a System Restore point
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Before LAPTOTS clean", 100, 7 >> "%LOG%" 2>&1

echo [2/5] Free space before
for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='%SystemDrive%'" get FreeSpace /value ^| find "="') do set "FREE_BEFORE=%%F"
echo Free bytes before: %FREE_BEFORE% >> "%LOG%"

echo [3/5] Emptying temp folders
dir /b /ad "%SystemDrive%\Users\*" > "%TEMP%\..\x51users.txt" 2>nul
for /f "usebackq delims=" %%U in ("%TEMP%\..\x51users.txt") do (
  set "T=%SystemDrive%\Users\%%U\AppData\Local\Temp"
  if exist "!T!\" (
    echo   !T! >> "%LOG%"
    del /f /s /q "!T!\*" >nul 2>&1
    for /d %%D in ("!T!\*") do rd /s /q "%%D" >nul 2>&1
  )
)
del "%TEMP%\..\x51users.txt" >nul 2>&1
echo   %windir%\Temp >> "%LOG%"
del /f /s /q "%windir%\Temp\*" >nul 2>&1
for /d %%D in ("%windir%\Temp\*") do rd /s /q "%%D" >nul 2>&1

echo [4/5] Clearing Windows Update download cache
net stop wuauserv >> "%LOG%" 2>&1
net stop bits >> "%LOG%" 2>&1
del /f /s /q "%windir%\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%D in ("%windir%\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1
net start bits >> "%LOG%" 2>&1
net start wuauserv >> "%LOG%" 2>&1

echo [5/5] Running Windows Disk Cleanup - a window may appear, let it finish
set "VC=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
for /f "delims=" %%K in ('reg query "%VC%"') do (
  set "NAME=%%~nxK"
  set "SKIP="
  if /i "!NAME!"=="Recycle Bin" set "SKIP=1"
  if /i "!NAME!"=="DownloadsFolder" set "SKIP=1"
  if /i "!NAME!"=="Previous Installations" set "SKIP=1"
  if /i "!NAME!"=="User file versions" set "SKIP=1"
  if /i "!NAME!"=="BranchCache" set "SKIP=1"
  if defined SKIP (
    echo   skip: !NAME! >> "%LOG%"
  ) else (
    reg add "%%K" /v StateFlags0077 /t REG_DWORD /d 2 /f >nul 2>&1
    echo   clean: !NAME! >> "%LOG%"
  )
)
start /wait cleanmgr /sagerun:77

rem Windows 8 and later can also shrink the component store.
if not "%WINVER%"=="6.1" (
  echo   Shrinking Windows component store - can take 10+ minutes
  Dism /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
)

for /f "tokens=2 delims==" %%F in ('wmic logicaldisk where "DeviceID='%SystemDrive%'" get FreeSpace /value ^| find "="') do set "FREE_AFTER=%%F"
echo Free bytes after: %FREE_AFTER% >> "%LOG%"
powershell -NoProfile -Command "'Space freed: {0:N2} GB' -f ((%FREE_AFTER% - %FREE_BEFORE%) / 1GB)" > "%TEMP%\x51freed.txt" 2>nul
type "%TEMP%\x51freed.txt"
type "%TEMP%\x51freed.txt" >> "%LOG%"
del "%TEMP%\x51freed.txt" >nul 2>&1

echo.
echo  Done. Log: %LOG%
echo  Your Recycle Bin was NOT emptied - check it yourself before emptying.
echo.
pause
