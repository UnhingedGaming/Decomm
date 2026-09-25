@echo off
rem ===================================================================
rem  T480S Step 9 - Copy browser bookmarks, quick links and shortcuts to USB
rem  Copies Chrome and Edge profiles (bookmarks, favorites bar, new-tab
rem  Quick links, settings) WITHOUT their caches, plus desktop shortcuts,
rem  File Explorer Quick Access pins and taskbar pins.
rem  Close Chrome and Edge first. Reads only - nothing on C: is changed.
rem ===================================================================
setlocal
title T480S Browser and shortcuts backup
echo.
echo  Close Chrome and Edge before continuing.
echo.
wmic logicaldisk get deviceid,volumename,freespace,filesystem | more
set /p "USB=Type the USB drive letter (e.g. E) and press Enter: "
set "USB=%USB::=%"
if "%USB%"=="" goto :bad
if /i "%USB%"=="C" goto :bad
if not exist "%USB%:\" goto :bad

taskkill /im chrome.exe /f >nul 2>&1
taskkill /im msedge.exe /f >nul 2>&1

set "DEST=%USB%:\T480S Rescue\Browsers and Shortcuts"
mkdir "%DEST%" 2>nul
set "RC=/E /R:1 /W:1 /XJ /NP /NFL /NDL /NJH"
set "NOCACHE=/XD Cache "Code Cache" GPUCache "Service Worker" ShaderCache GrShaderCache "Media Cache" "Application Cache" Crashpad "Safe Browsing" component_crx_cache"

echo [1/5] Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data" (
  robocopy "%LOCALAPPDATA%\Google\Chrome\User Data" "%DEST%\Chrome User Data" %RC% %NOCACHE% /XF *.tmp *.log LOCK
)
echo [2/5] Edge (favorites, Quick links, settings)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data" (
  robocopy "%LOCALAPPDATA%\Microsoft\Edge\User Data" "%DEST%\Edge User Data" %RC% %NOCACHE% /XF *.tmp *.log LOCK
)
if exist "%USERPROFILE%\MicrosoftEdgeBackups" robocopy "%USERPROFILE%\MicrosoftEdgeBackups" "%DEST%\MicrosoftEdgeBackups" %RC%
if exist "%USERPROFILE%\Favorites" robocopy "%USERPROFILE%\Favorites" "%DEST%\Favorites" %RC%

echo [3/5] Desktop shortcuts
robocopy "%USERPROFILE%\Desktop" "%DEST%\Desktop shortcuts" *.lnk *.url /R:1 /W:1 /NP /NFL /NDL /NJH
robocopy "%PUBLIC%\Desktop" "%DEST%\Desktop shortcuts (all users)" *.lnk *.url /R:1 /W:1 /NP /NFL /NDL /NJH
if exist "%USERPROFILE%\OneDrive\Desktop" robocopy "%USERPROFILE%\OneDrive\Desktop" "%DEST%\Desktop shortcuts (OneDrive desktop)" *.lnk *.url /R:1 /W:1 /NP /NFL /NDL /NJH

echo [4/5] File Explorer Quick Access pins and recent list
robocopy "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations" "%DEST%\Quick Access" %RC%
robocopy "%USERPROFILE%\Links" "%DEST%\Links" %RC%

echo [5/5] Taskbar and Start menu pins
robocopy "%APPDATA%\Microsoft\Internet Explorer\Quick Launch" "%DEST%\Taskbar pins" %RC%
robocopy "%APPDATA%\Microsoft\Windows\Start Menu" "%DEST%\Start Menu" %RC%

echo.
echo  Done. Saved to %DEST%
echo.
pause
exit /b

:bad
echo  That isn't a USB drive letter I can use. Run this again.
pause
