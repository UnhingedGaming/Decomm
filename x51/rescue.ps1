# X51 rescue - two modes:
#   -Mode Gather : finds every real file on C: that isn't Windows or a program (wherever
#                  OneDrive buried it) and MOVES it into Desktop\X51-Gathered, keeping its
#                  original folders. A move on the same drive only renames - no data is
#                  rewritten, so it is gentle on a failing drive. Files inside a OneDrive
#                  folder are COPIED instead, so OneDrive can never treat them as deleted.
#                  Every move is recorded in X51-Gathered\_undo-list.csv.
#   -Mode Usb    : copies Desktop\X51-Gathered onto one or more USB sticks, filling them in order.
# Cloud-only OneDrive shortcuts are always skipped (those files live in the cloud).
# Safe to re-run after a freeze: finished files are skipped.
param([ValidateSet('Gather', 'Usb')][string]$Mode = 'Gather', [string]$Usb)

$ErrorActionPreference = 'Continue'
$gathered = Join-Path $env:USERPROFILE 'Desktop\X51-Gathered'
$src = if ($Mode -eq 'Usb') { $gathered + '\' } else { 'C:\' }

# Folders never touched (system, programs, caches). Matched against the path below C:\
$skipRoots = @('Windows', 'Program Files', 'Program Files (x86)', 'ProgramData', '$Recycle.Bin',
    'System Volume Information', 'Recovery', 'PerfLogs', '$WINDOWS.~BT', '$Windows.~WS',
    '$SysReset', '$GetCurrent', 'Config.Msi', 'MSOCache', 'Windows.old\Windows',
    'Windows.old\Program Files', 'Windows.old\Program Files (x86)', 'Windows.old\ProgramData')
# The folder these scripts were run from is left alone.
$toolDir = Split-Path $PSScriptRoot -Parent
if ($toolDir -like 'C:\*') { $skipRoots += $toolDir.Substring(3) }
$skipNames = @('AppData', 'Application Data', 'Local Settings', 'IntelGraphicsProfiles', 'X51-Rescue')
if ($Mode -eq 'Gather') { $skipNames += 'X51-Gathered' }
$skipFiles = @('pagefile.sys', 'hiberfil.sys', 'swapfile.sys', 'DumpStack.log.tmp', 'desktop.ini')
$cloudOnly = 0x1000 -bor 0x400000 -bor 0x40000   # Offline, RecallOnDataAccess, RecallOnOpen

function Get-LocalFiles {
    $stack = New-Object System.Collections.Stack
    $stack.Push('')
    while ($stack.Count -gt 0) {
        $rel = $stack.Pop()
        $dir = New-Object System.IO.DirectoryInfo ('\\?\' + $src + $rel)
        try { $items = $dir.GetFileSystemInfos() } catch { continue }
        foreach ($i in $items) {
            $r = if ($rel) { $rel + '\' + $i.Name } else { $i.Name }
            if ($i -is [System.IO.DirectoryInfo]) {
                if ($i.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                    # Skip Windows shortcut-folders (junctions/links) but keep OneDrive folders.
                    $lt = (Get-Item -LiteralPath ($src + $r) -Force -ErrorAction SilentlyContinue).LinkType
                    if ($lt) { continue }
                }
                if ($skipRoots -contains $r) { continue }
                if ($skipNames -contains $i.Name) { continue }
                $stack.Push($r)
            } else {
                if (([int]$i.Attributes -band $cloudOnly) -ne 0) { continue }
                if ($i.Length -eq 0) { continue }
                if ($skipFiles -contains $i.Name) { continue }
                if ($i.Name -like 'ntuser*' -or $i.Name -like 'UsrClass*') { continue }
                New-Object PSObject -Property @{ Rel = $r; Length = $i.Length; Time = $i.LastWriteTimeUtc }
            }
        }
    }
}

Write-Host ''
Write-Host ('  Finding every real file in {0} ...' -f $src)
$files = @(Get-LocalFiles)
# Users first, so the most personal files are handled before anything else.
$files = @($files | Sort-Object @{ Expression = { if ($_.Rel -like 'Users\*') { 0 } else { 1 } } }, Rel)
$total = ($files | Measure-Object Length -Sum).Sum

$byFolder = $files | Group-Object { $p = $_.Rel.Split('\'); if ($p.Count -gt 3) { ($p[0..2]) -join '\' } else { ($p[0..($p.Count - 2)]) -join '\' } } |
    ForEach-Object { New-Object PSObject -Property @{ Folder = $_.Name; Files = $_.Count; GB = ($_.Group | Measure-Object Length -Sum).Sum / 1GB } } |
    Sort-Object GB -Descending

Write-Host ''
Write-Host ('  Found {0:N0} files, {1:N1} GB. Biggest places:' -f $files.Count, ($total / 1GB))
$byFolder | Select-Object -First 25 | ForEach-Object { Write-Host ('   {0,8:N1} GB  {1,7:N0} files  {2}' -f $_.GB, $_.Files, $_.Folder) }
$big = @($files | Where-Object { $_.Length -ge 4GB })

if ($Mode -eq 'Gather') {
    Write-Host ''
    Write-Host '  These will be MOVED (OneDrive ones copied) into:'
    Write-Host "    $gathered"
    Write-Host '  keeping their original folders. Windows and programs are not touched.'
    $answer = Read-Host '  Start? Type Y and press Enter'
    if ($answer -notmatch '^[Yy]') { return }
    New-Item -ItemType Directory -Force -Path $gathered | Out-Null
    $byFolder | ForEach-Object { '{0,8:N2} GB  {1,7}  C:\{2}' -f $_.GB, $_.Files, $_.Folder } |
        Out-File (Join-Path $gathered '_what-was-found.txt') -Encoding UTF8
    $undo = Join-Path $gathered '_undo-list.csv'
    $problems = Join-Path $gathered '_problems.txt'
    if (-not (Test-Path $undo)) { '"Original","NowAt","Action"' | Out-File $undo -Encoding UTF8 }
    $buffer = New-Object System.Collections.ArrayList
    $moved = 0; $copied = 0; $already = 0; $failed = 0; $n = 0
    foreach ($f in $files) {
        $n++
        if ($n % 200 -eq 0) {
            Write-Progress -Activity 'Gathering' -Status ('{0:N0} of {1:N0} files' -f $n, $files.Count) -PercentComplete (100 * $n / $files.Count)
            if ($buffer.Count) { $buffer | Out-File $undo -Append -Encoding UTF8; $buffer.Clear() }
        }
        $from = '\\?\C:\' + $f.Rel
        $to = '\\?\' + $gathered + '\' + $f.Rel
        $inOneDrive = $f.Rel -match '^Users\\[^\\]+\\(OneDrive|SkyDrive)'
        try {
            if ([System.IO.File]::Exists($to)) { $already++; continue }
            [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($to)) | Out-Null
            if ($inOneDrive) {
                [System.IO.File]::Copy($from, $to, $false); $copied++; $act = 'copied'
            } else {
                [System.IO.File]::Move($from, $to); $moved++; $act = 'moved'
            }
            [void]$buffer.Add(('"C:\{0}","{1}\{0}","{2}"' -f $f.Rel, $gathered, $act))
        } catch {
            "COULD NOT MOVE  C:\$($f.Rel)  --  $($_.Exception.Message)" | Out-File $problems -Append
            $failed++
        }
    }
    if ($buffer.Count) { $buffer | Out-File $undo -Append -Encoding UTF8 }
    Write-Progress -Activity 'Gathering' -Completed
    Write-Host ''
    Write-Host ('  Moved {0:N0}, copied {1:N0} (OneDrive), already there {2:N0}, could not move {3:N0}.' -f $moved, $copied, $already, $failed)
    if ($failed) { Write-Host "  The ones left in place are listed in $problems (usually files in use)." }
    Start-Process explorer $gathered
    return
}

if (-not $Usb) { return }
# One or more USB drive letters, e.g. "E" or "EFG". Fills them in order.
$targets = @()
foreach ($L in $Usb.ToUpper().ToCharArray()) {
    if ($L -notmatch '[A-Z]' -or $L -eq 'C') { continue }
    $d = Get-WmiObject Win32_LogicalDisk -Filter ("DeviceID='" + $L + ":'")
    if ($d) { $targets += New-Object PSObject -Property @{ Letter = [string]$L; Fs = $d.FileSystem; Free = [long]$d.FreeSpace } }
}
if ($targets.Count -eq 0) { Write-Host '  No usable USB drive letters given.'; return }
$room = ($targets | Measure-Object Free -Sum).Sum
Write-Host ''
$targets | ForEach-Object { Write-Host ('  USB {0}: {1:N1} GB free ({2})' -f $_.Letter, ($_.Free / 1GB), $_.Fs) }
Write-Host ('  Total room {0:N1} GB for {1:N1} GB of files.' -f ($room / 1GB), ($total / 1GB))
if ($room -lt $total) {
    Write-Host '  !! Not enough room for everything. Your user folders go first; the rest'
    Write-Host '     is copied until the drives are full. Run again later with a bigger drive.'
}
if (@($targets | Where-Object { $_.Fs -eq 'FAT32' }).Count -gt 0 -and $big.Count -gt 0) {
    Write-Host ('  !! {0} file(s) are 4 GB or larger and cannot go on a FAT32 stick; they will be listed.' -f $big.Count)
}
Write-Host ''
$answer = Read-Host '  Start copying now? Type Y and press Enter'
if ($answer -notmatch '^[Yy]') { return }

$first = $targets[0].Letter + ':\X51-Rescue'
New-Item -ItemType Directory -Force -Path $first | Out-Null
$log = $first + '\rescue-problems.txt'
$byFolder | ForEach-Object { '{0,8:N2} GB  {1,7}  {2}' -f $_.GB, $_.Files, $_.Folder } |
    Out-File ($first + '\what-was-found.txt') -Encoding UTF8

# Files already on any of the sticks (from an earlier run) are skipped.
function Test-Copied($rel, $len) {
    foreach ($t in $targets) {
        $e = New-Object System.IO.FileInfo ('\\?\' + $t.Letter + ':\X51-Rescue\' + $rel)
        if ($e.Exists -and $e.Length -eq $len) { return $true }
    }
    return $false
}

Write-Host ''
Write-Host '  Copying. If the PC freezes, let it cool and run this again - it resumes.'
$done = [long]0; $n = 0; $copied = 0; $skipped = 0; $failed = 0; $ti = 0
foreach ($f in $files) {
    $n++
    $done += $f.Length
    if ($n % 200 -eq 0) {
        Write-Progress -Activity 'Copying to USB' -Status ('{0:N1} of {1:N1} GB' -f ($done / 1GB), ($total / 1GB)) -PercentComplete ([math]::Min(100, 100 * $done / [math]::Max(1, $total)))
    }
    if (Test-Copied $f.Rel $f.Length) { $skipped++; continue }
    $from = '\\?\' + $src + $f.Rel
    $placed = $false
    for ($k = $ti; $k -lt $targets.Count -and -not $placed; $k++) {
        $t = $targets[$k]
        if ($t.Fs -eq 'FAT32' -and $f.Length -ge 4GB) { continue }
        $free = (Get-WmiObject Win32_LogicalDisk -Filter ("DeviceID='" + $t.Letter + ":'")).FreeSpace
        if ($free -lt ($f.Length + 50MB)) { if ($k -eq $ti) { $ti++ }; continue }
        $to = '\\?\' + $t.Letter + ':\X51-Rescue\' + $f.Rel
        try {
            [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($to)) | Out-Null
            [System.IO.File]::Copy($from, $to, $true)
            (New-Object System.IO.FileInfo $to).LastWriteTimeUtc = $f.Time
            $copied++; $placed = $true
        } catch {
            $msg = $_.Exception.Message
            if ($msg -match 'not enough space|disk is full') { if ($k -eq $ti) { $ti++ }; continue }
            "COULD NOT READ  $($f.Rel)  --  $msg" | Out-File $log -Append
            $failed++; $placed = $true
        }
    }
    if (-not $placed) { "NO ROOM LEFT  $($f.Rel)" | Out-File $log -Append; $failed++ }
}
Write-Progress -Activity 'Copying to USB' -Completed
Write-Host ''
Write-Host ('  Copied {0:N0} files, {1:N0} were already on the USB, {2:N0} could not be copied.' -f $copied, $skipped, $failed)
if ($failed -gt 0) { Write-Host "  The ones not copied are listed in $log" }
