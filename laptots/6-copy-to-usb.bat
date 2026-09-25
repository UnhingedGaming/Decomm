@echo off
rem ===================================================================
rem  LAPTOTS Step 6 - Copy Desktop\LAPTOTS-Gathered onto USB sticks
rem  Plug in all your USB sticks, then run this. It fills them in order
rem  and can be run again with new sticks to continue where it stopped.
rem ===================================================================
title LAPTOTS Copy to USB
echo.
echo  Drives on this PC:
wmic logicaldisk get deviceid,volumename,size,freespace,filesystem | more
echo.
echo  Type the USB drive letters to fill, in order, with no spaces.
set /p "USB=For example EFG, then press Enter: "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rescue.ps1" -Mode Usb -Usb "%USB%"
echo.
pause
