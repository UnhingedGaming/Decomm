@echo off
rem ===================================================================
rem  X51 RESCUE - copy the files that exist ONLY on this PC to a USB drive
rem  For a failing hard drive: copies each file once, gives up quickly on
rem  unreadable spots instead of hammering the drive, and never writes to C:
rem  except its own log. Skips OneDrive (those files are in the cloud),
rem  AppData, and program folders.
rem ===================================================================
setlocal EnableDelayedExpansion
title X51 RESCUE

net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo.
echo  Plug in a USB stick or drive with at least 2 GB free.
echo  Drives on this PC:
wmic logicaldisk get deviceid,volumename,size,freespace,drivetype | more
echo  (DriveType 2 = USB stick, 3 = hard drive)
echo.
set /p "USB=Type the USB drive letter only, e.g. E, then press Enter: "
set "USB=%USB::=%"
if "%USB%"=="" goto :bad
if /i "%USB%"=="C" goto :bad
if not exist "%USB%:\" goto :bad

set "DEST=%USB%:\X51-Rescue"
mkdir "%DEST%" 2>nul
set "RC=/E /COPY:DAT /DCOPY:T /R:1 /W:1 /XJ /NP /NDL /LOG+:%DEST%\rescue-log.txt /TEE"
set "SKIPDIRS=/XD AppData OneDrive* SkyDrive* IntelGraphicsProfiles X51-Rescue"

echo.
echo [1/4] Inventory reports and file list
robocopy "%USERPROFILE%\Desktop\X51-Inventory" "%DEST%\X51-Inventory" %RC%

echo [2/4] Each user's personal folders
for /d %%U in ("%SystemDrive%\Users\*") do (
  set "N=%%~nxU"
  if /i not "!N!"=="Public" if /i not "!N!"=="Default" if /i not "!N!"=="Default User" if /i not "!N!"=="All Users" (
    echo   -- !N!
    robocopy "%%U" "%DEST%\Users\!N!" %RC% %SKIPDIRS% /XF ntuser* NTUSER* *.tmp
  )
)

echo [3/4] Browser bookmarks
for /d %%U in ("%SystemDrive%\Users\*") do (
  mkdir "%DEST%\Bookmarks\%%~nxU" 2>nul
  copy /y "%%U\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "%DEST%\Bookmarks\%%~nxU\Chrome-Bookmarks" >nul 2>&1
  copy /y "%%U\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks" "%DEST%\Bookmarks\%%~nxU\Edge-Bookmarks" >nul 2>&1
  for /d %%P in ("%%U\AppData\Roaming\Mozilla\Firefox\Profiles\*") do (
    mkdir "%DEST%\Bookmarks\%%~nxU\Firefox" 2>nul
    copy /y "%%P\places.sqlite" "%DEST%\Bookmarks\%%~nxU\Firefox\" >nul 2>&1
  )
)

echo [4/4] Public folders
robocopy "%SystemDrive%\Users\Public" "%DEST%\Users\Public" %RC% /XD AppData

echo.
echo  Done. Copied to %DEST%
echo  Files that could NOT be read are listed in rescue-log.txt as ERROR.
findstr /c:"ERROR" "%DEST%\rescue-log.txt" > "%DEST%\unreadable-files.txt" 2>nul
for /f %%C in ('type "%DEST%\unreadable-files.txt" ^| find /c /v ""') do echo  Unreadable entries: %%C
echo.
pause
exit /b

:bad
echo  That isn't a USB drive letter I can use. Run this again.
pause
exit /b
