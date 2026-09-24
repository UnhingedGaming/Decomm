@echo off
rem ===================================================================
rem  X51 Step 1 - Inventory (READ-ONLY: changes and deletes nothing)
rem  Works on Windows 7, 8, 8.1 and 10.
rem  Output: Desktop\X51-Inventory\
rem ===================================================================
setlocal EnableDelayedExpansion
title X51 Inventory

net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator rights...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "HERE=%~dp0"
set "OUT=%USERPROFILE%\Desktop\X51-Inventory"
if not exist "%OUT%" mkdir "%OUT%"

echo.
echo  Collecting inventory into:
echo    %OUT%
echo  Nothing on this PC is changed or deleted. This takes 5-20 minutes.
echo.

echo [1/10] System summary
systeminfo > "%OUT%\01-system.txt" 2>&1
(
  echo.
  echo === Windows ===
  wmic os get caption,version,osarchitecture,installdate,lastbootuptime | more
  echo === License status ===
  cscript //nologo "%windir%\system32\slmgr.vbs" /dli
  echo === Product key stored in BIOS - Windows 8 and later only, blank on Windows 7 ===
  wmic path softwarelicensingservice get OA3xOriginalProductKey | more
  echo === User accounts ===
  net user
  dir /b "%SystemDrive%\Users"
) >> "%OUT%\01-system.txt" 2>&1

echo [2/10] Hardware
(
  echo === Model and Service Tag ===
  wmic csproduct get vendor,name,identifyingnumber | more
  echo === BIOS ===
  wmic bios get manufacturer,smbiosbiosversion,releasedate,serialnumber | more
  echo === Motherboard ===
  wmic baseboard get manufacturer,product,version | more
  echo === CPU ===
  wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed | more
  echo === Memory sticks installed ===
  wmic memorychip get devicelocator,capacity,speed,manufacturer,partnumber | more
  echo === Memory slots and max supported, in KB ===
  wmic memphysical get maxcapacity,memorydevices | more
  echo === Graphics ===
  wmic path win32_videocontroller get name,driverversion,adapterram | more
  echo === Network adapters ===
  wmic nic where "physicaladapter=true" get name,macaddress,speed | more
) > "%OUT%\02-hardware.txt" 2>&1
start /wait dxdiag /t "%OUT%\02b-dxdiag.txt"

echo [3/10] Drives and drive health
(
  echo === Physical drives ===
  wmic diskdrive get model,size,status,interfacetype,serialnumber | more
  echo === SMART failure prediction - PredictFailure TRUE means replace the drive ===
  wmic /namespace:\\root\wmi path MSStorageDriver_FailurePredictStatus get InstanceName,PredictFailure,Reason | more
  echo === Volumes - sizes in bytes ===
  wmic logicaldisk where drivetype=3 get deviceid,volumename,filesystem,size,freespace | more
) > "%OUT%\03-drives.txt" 2>&1

echo [4/10] Installed programs
(
  for %%K in (
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
  ) do (
    reg query %%K /s /v DisplayName 2>nul | findstr /c:"DisplayName"
  )
) > "%OUT%\04-programs-raw.txt" 2>&1
sort "%OUT%\04-programs-raw.txt" > "%OUT%\04-programs.txt"
del "%OUT%\04-programs-raw.txt"

echo [5/10] Startup programs
wmic startup get caption,command,location | more > "%OUT%\05-startup.txt" 2>&1

echo [6/10] Drivers and problem devices
(
  echo === Devices with problems - empty is good ===
  wmic path win32_pnpentity where "ConfigManagerErrorCode<>0" get name,configmanagererrorcode | more
  echo === All drivers ===
  driverquery
) > "%OUT%\06-drivers.txt" 2>&1

echo [7/10] Recent system errors
wevtutil qe System /q:"*[System[(Level=1 or Level=2)]]" /c:60 /rd:true /f:text > "%OUT%\07-system-errors.txt" 2>&1

echo [8/10] OneDrive / SkyDrive settings
(
  echo === OneDrive and SkyDrive folders registered for this user ===
  reg query "HKCU\Software\Microsoft\OneDrive" /s 2>nul | findstr /i "UserFolder UserEmail"
  reg query "HKCU\Software\Microsoft\SkyDrive" /s 2>nul | findstr /i "UserFolder"
  echo === OneDrive running right now? ===
  tasklist | findstr /i "onedrive skydrive"
  echo === OneDrive / SkyDrive folders on this drive ===
  dir /b /ad "%SystemDrive%\Users\*" > "%TEMP%\x51users.txt"
  for /f "usebackq delims=" %%U in ("%TEMP%\x51users.txt") do (
    for /d %%D in ("%SystemDrive%\Users\%%U\OneDrive*" "%SystemDrive%\Users\%%U\SkyDrive*") do echo %%D
  )
) > "%OUT%\08-onedrive.txt" 2>&1

echo [9/10] How big each user's folders are
(
  echo Totals per folder - files count, bytes
  for /f "usebackq delims=" %%U in ("%TEMP%\x51users.txt") do (
    echo.
    echo === %%U ===
    for /d %%F in ("%SystemDrive%\Users\%%U\*") do (
      set "LAST="
      for /f "tokens=*" %%L in ('dir "%%F" /s /a-d 2^>nul ^| findstr /c:"File(s)"') do set "LAST=%%L"
      if defined LAST echo   %%~nxF: !LAST!
    )
  )
) > "%OUT%\09-folder-sizes.txt" 2>&1
del "%TEMP%\x51users.txt"

echo [10/10] Duplicate files, including OneDrive copies - the slow part
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%find-duplicates.ps1" -OutDir "%OUT%"

echo.
echo  Done. Reports are in:
echo    %OUT%
echo  Nothing was changed or deleted.
echo.
start "" explorer "%OUT%"
pause
