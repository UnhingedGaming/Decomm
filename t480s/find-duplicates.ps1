# T480S duplicate finder - READ-ONLY. Reports duplicates, never deletes or moves anything.
# Compatible with PowerShell 2.0 (Windows 7) and later.
# Called by 1-inventory.bat, or run on its own:
#   powershell -ExecutionPolicy Bypass -File find-duplicates.ps1 -OutDir C:\somewhere

param(
    [string]$OutDir = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'T480S-Inventory')
)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Folders never scanned: Windows itself, programs, and app caches.
$skipPattern = '\\(AppData|Application Data|Local Settings|\$Recycle\.Bin|System Volume Information|Windows|Program Files|Program Files \(x86\)|ProgramData|MSOCache)(\\|$)'

# File attributes that mean "only in the cloud" - reading these would download them, so skip.
$cloudOnly = 0x1000 -bor 0x400000 -bor 0x40000

# What to scan: every user profile on the system drive, plus every other fixed drive.
$roots = @()
$sysDrive = $env:SystemDrive + '\'
Get-ChildItem (Join-Path $sysDrive 'Users') -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.PSIsContainer -and $_.Name -notmatch '^(Public|Default|Default User|All Users)$' } |
    ForEach-Object { $roots += $_.FullName }
Get-WmiObject Win32_LogicalDisk -Filter 'DriveType=3' |
    Where-Object { ($_.DeviceID + '\') -ne $sysDrive } |
    ForEach-Object { $roots += ($_.DeviceID + '\') }

Write-Host "  Scanning:"
$roots | ForEach-Object { Write-Host "    $_" }

$files = New-Object System.Collections.ArrayList
$skippedCloud = 0
foreach ($root in $roots) {
    Get-ChildItem -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.PSIsContainer) { return }
        if ($_.FullName -match $skipPattern) { return }
        if ($_.Length -eq 0) { return }
        if (([int]$_.Attributes -band $cloudOnly) -ne 0) { $script:skippedCloud++; return }
        [void]$files.Add($_)
        if (($files.Count % 5000) -eq 0) { Write-Host "    ...$($files.Count) files listed" }
    }
}
Write-Host "  $($files.Count) files listed. Comparing contents of same-size files..."

function Get-Md5([string]$path, [long]$maxBytes) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $stream = $null
    try {
        $stream = [System.IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
        if ($maxBytes -gt 0) {
            $buf = New-Object byte[] $maxBytes
            $n = $stream.Read($buf, 0, $maxBytes)
            $hash = $md5.ComputeHash($buf, 0, $n)
        } else {
            $hash = $md5.ComputeHash($stream)
        }
        return [BitConverter]::ToString($hash).Replace('-', '')
    } catch {
        return $null
    } finally {
        if ($stream) { $stream.Close() }
    }
}

$rows = New-Object System.Collections.ArrayList
$groupId = 0
$wasted = [long]0
$sizeGroups = $files | Group-Object Length | Where-Object { $_.Count -gt 1 }
$done = 0
foreach ($sg in $sizeGroups) {
    $done++
    if (($done % 500) -eq 0) { Write-Host "    ...$done of $(@($sizeGroups).Count) size groups checked" }
    # Quick pass on the first 64 KB, then a full hash only for files that still match.
    $quick = $sg.Group | ForEach-Object {
        New-Object PSObject -Property @{ File = $_; Key = (Get-Md5 $_.FullName 65536) }
    } | Where-Object { $_.Key } | Group-Object Key | Where-Object { $_.Count -gt 1 }
    foreach ($qg in $quick) {
        $full = $qg.Group | ForEach-Object {
            $f = $_.File
            $h = $_.Key
            if ($f.Length -gt 65536) { $h = Get-Md5 $f.FullName 0 }
            New-Object PSObject -Property @{ File = $f; Key = $h }
        } | Where-Object { $_.Key } | Group-Object Key | Where-Object { $_.Count -gt 1 }
        foreach ($g in $full) {
            $groupId++
            $wasted += [long]$g.Group[0].File.Length * ($g.Count - 1)
            foreach ($item in ($g.Group | Sort-Object { $_.File.LastWriteTime })) {
                $f = $item.File
                [void]$rows.Add((New-Object PSObject -Property @{
                    Group     = $groupId
                    SizeMB    = [math]::Round($f.Length / 1MB, 2)
                    Modified  = $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
                    InOneDrive = ($f.FullName -match '\\(OneDrive|SkyDrive)')
                    Path      = $f.FullName
                }))
            }
        }
    }
}

$rows | Select-Object Group, SizeMB, Modified, InOneDrive, Path |
    Export-Csv (Join-Path $OutDir '10-duplicates.csv') -NoTypeInformation

# Files whose NAME looks like an OneDrive/sync conflict copy, whether or not the contents match.
$pc = [Regex]::Escape($env:COMPUTERNAME)
$conflictPattern = "(-$pc(-\d+)?|\s\(\d+\)|\s-\sCopy(\s\(\d+\))?|-Copy\d*)$"
$conflicts = $files | Where-Object {
    [IO.Path]::GetFileNameWithoutExtension($_.Name) -match $conflictPattern
} | ForEach-Object {
    New-Object PSObject -Property @{
        SizeMB   = [math]::Round($_.Length / 1MB, 2)
        Modified = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        Path     = $_.FullName
    }
}
$conflicts | Select-Object SizeMB, Modified, Path |
    Export-Csv (Join-Path $OutDir '11-conflict-copy-names.csv') -NoTypeInformation

# Which folders hold the most duplicate copies.
$byFolder = $rows | Group-Object { Split-Path $_.Path -Parent } |
    Sort-Object Count -Descending | Select-Object -First 40

$summary = @()
$summary += "Duplicate file report - read-only, nothing was deleted"
$summary += "Generated: $(Get-Date)"
$summary += ""
$summary += "Files scanned:                 $($files.Count)"
$summary += "Cloud-only files skipped:      $skippedCloud (not downloaded)"
$summary += "Sets of identical files:       $groupId"
$summary += "Space used by extra copies:    $([math]::Round($wasted / 1GB, 2)) GB"
$summary += "Files named like sync copies:  $(@($conflicts).Count)"
$summary += ""
$summary += "Folders with the most duplicate files:"
$byFolder | ForEach-Object { $summary += ("  {0,6}  {1}" -f $_.Count, $_.Name) }
$summary += ""
$summary += "Open 10-duplicates.csv in Excel: rows with the same Group number are identical files."
$summary += "Within each group the oldest copy is listed first."
$summary | Out-File (Join-Path $OutDir '10-duplicates-summary.txt') -Encoding ASCII

Write-Host ""
$summary[0..8] | ForEach-Object { Write-Host "  $_" }
