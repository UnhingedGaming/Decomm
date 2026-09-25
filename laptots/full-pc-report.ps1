# LAPTOTS FULL PC REPORT - READ-ONLY. Reads only file names and sizes on the whole C: drive.
# Opens no files, changes nothing, downloads nothing.
# Output on the Desktop (C:\Users\<you>\Desktop):
#   LAPTOTS-Full-Report.txt   - summary: where every GB is, where personal files are hiding
#   LAPTOTS-All-Folders.csv   - every folder on C: with real size, cloud-only size, file count
param([string]$Drive = 'C:\')

$desk = Join-Path $env:USERPROFILE 'Desktop'
$report = Join-Path $desk 'LAPTOTS-Full-Report.txt'
$csv = Join-Path $desk 'LAPTOTS-All-Folders.csv'
$cloudOnly = 0x1000 -bor 0x400000 -bor 0x40000
$personal = @{}
foreach ($e in 'jpg jpeg png gif bmp heic tif tiff raw cr2 nef psd mp4 mov avi mkv wmv m4v 3gp mts mp3 m4a wav flac wma aac doc docx xls xlsx xlsm csv ppt pptx pdf txt rtf odt ods one pst ost mbox eml msg qbw qbb qdf zip rar 7z gz tar'.Split(' ')) { $personal['.' + $e] = $true }

# Per-folder totals: path -> [realBytes, cloudBytes, realFiles, cloudFiles, personalRealBytes, personalRealFiles]
$dirs = @{}
$stack = New-Object System.Collections.Stack
$stack.Push($Drive.TrimEnd('\'))
$scanned = 0
$sw = [Diagnostics.Stopwatch]::StartNew()
Write-Host '  Reading the whole drive (names and sizes only). This can take 10-30 minutes...'
while ($stack.Count -gt 0) {
    $path = $stack.Pop()
    $t = New-Object 'long[]' 6
    $dirs[$path] = $t
    try { $items = (New-Object System.IO.DirectoryInfo ('\\?\' + $path + '\')).GetFileSystemInfos() } catch { continue }
    foreach ($i in $items) {
        if ($i -is [System.IO.DirectoryInfo]) {
            # Skip linked folders (they point somewhere already counted) except OneDrive's own folders.
            if (($i.Attributes -band [IO.FileAttributes]::ReparsePoint) -and ($path + '\' + $i.Name) -notmatch '(?i)\\(OneDrive|SkyDrive)') { continue }
            $stack.Push($path + '\' + $i.Name)
        } else {
            $scanned++
            if (([int]$i.Attributes -band $cloudOnly) -ne 0) { $t[1] += $i.Length; $t[3]++ }
            else {
                $t[0] += $i.Length; $t[2]++
                if ($personal.ContainsKey($i.Extension.ToLower())) { $t[4] += $i.Length; $t[5]++ }
            }
        }
    }
    if ($scanned -gt 0 -and ($dirs.Count % 2000) -eq 0) {
        Write-Host ('    ...{0:N0} files, {1:N0} folders, {2:N0} min' -f $scanned, $dirs.Count, $sw.Elapsed.TotalMinutes)
    }
}

Write-Host '  Adding up folder totals...'
# Roll totals up to parent folders, deepest first.
$totals = @{}
foreach ($k in $dirs.Keys) { $totals[$k] = [long[]]$dirs[$k].Clone() }
$ordered = $dirs.Keys | Sort-Object { ($_.Split('\')).Count } -Descending
foreach ($k in $ordered) {
    # Plain text split - Split-Path chokes on names containing [ ] or other odd characters.
    $cut = $k.LastIndexOf('\')
    if ($cut -le 0) { continue }
    $parent = $k.Substring(0, $cut)
    if ($totals.ContainsKey($parent)) {
        $p = $totals[$parent]; $c = $totals[$k]
        for ($x = 0; $x -lt 6; $x++) { $p[$x] += $c[$x] }
    }
}

$rows = foreach ($k in $totals.Keys) {
    $v = $totals[$k]
    New-Object PSObject -Property @{
        Folder = $k; Depth = ($k.Split('\')).Count - 1
        RealGB = [math]::Round($v[0] / 1GB, 3); CloudOnlyGB = [math]::Round($v[1] / 1GB, 3)
        RealFiles = $v[2]; CloudOnlyFiles = $v[3]
        PersonalGB = [math]::Round($v[4] / 1GB, 3); PersonalFiles = $v[5]
    }
}
$rows | Sort-Object Folder | Select-Object Folder, Depth, RealGB, RealFiles, CloudOnlyGB, CloudOnlyFiles, PersonalGB, PersonalFiles |
    Export-Csv $csv -NoTypeInformation -Encoding UTF8

$L = New-Object System.Collections.ArrayList
function Add($s) { [void]$L.Add($s) }
$root = $totals[$Drive.TrimEnd('\')]
$vol = Get-WmiObject Win32_LogicalDisk -Filter ("DeviceID='" + $Drive.Substring(0, 2) + "'")
Add "LAPTOTS FULL PC REPORT - $(Get-Date) - read-only"
Add ('Drive {0}  size {1:N1} GB, used {2:N1} GB, free {3:N1} GB' -f $Drive, ($vol.Size / 1GB), (($vol.Size - $vol.FreeSpace) / 1GB), ($vol.FreeSpace / 1GB))
Add ('Real data found: {0:N1} GB in {1:N0} files.  Cloud-only shortcuts: {2:N0} files ({3:N1} GB, NOT on this drive)' -f ($root[0] / 1GB), $root[2], $root[3], ($root[1] / 1GB))
Add '(Used space above the real data found = Windows files this account cannot read, e.g. System Volume Information / restore points.)'
Add ''
$fmt = '{0,9:N2} {1,9:N0} {2,9:N2} {3,9:N0}  {4}'
$hdr = '{0,9} {1,9} {2,9} {3,9}  {4}' -f 'Real GB', 'Files', 'Pers. GB', 'Pers.#', 'Folder'
Add '=== Top level of C: ==='
Add $hdr
$rows | Where-Object { $_.Depth -eq 1 } | Sort-Object RealGB -Descending | ForEach-Object { Add ($fmt -f $_.RealGB, $_.RealFiles, $_.PersonalGB, $_.PersonalFiles, $_.Folder) }
Add ''
Add '=== Biggest folders anywhere (real data, 3 levels down) ==='
Add $hdr
$rows | Where-Object { $_.Depth -le 3 -and $_.RealGB -ge 0.25 } | Sort-Object RealGB -Descending | Select-Object -First 60 |
    ForEach-Object { Add ($fmt -f $_.RealGB, $_.RealFiles, $_.PersonalGB, $_.PersonalFiles, $_.Folder) }
Add ''
Add '=== Where PERSONAL-type files are (photos, videos, music, documents, PDFs, email, zips) ==='
Add '    Deepest folders holding 25 MB+ of them, outside Windows and Program Files:'
Add $hdr
$rows | Where-Object { $_.PersonalGB -ge 0.025 -and $_.Folder -notmatch '^C:\\(Windows|Program Files|Program Files \(x86\))(\\|$)' } |
    Sort-Object Depth -Descending | ForEach-Object {
        $f = $_.Folder
        # keep only folders whose personal data is not mostly explained by one subfolder already listed
        $_
    } | Sort-Object PersonalGB -Descending | Select-Object -First 120 |
    ForEach-Object { Add ($fmt -f $_.RealGB, $_.RealFiles, $_.PersonalGB, $_.PersonalFiles, $_.Folder) }
Add ''
Add '=== Every folder named like OneDrive / SkyDrive ==='
Add ('{0,9} {1,9} {2,11} {3,11}  {4}' -f 'Real GB', 'Files', 'Cloud GB', 'Cloud #', 'Folder')
$rows | Where-Object { $_.Folder.Substring($_.Folder.LastIndexOf('\') + 1) -match '(?i)onedrive|skydrive' } | Sort-Object Folder |
    ForEach-Object { Add ('{0,9:N2} {1,9:N0} {2,11:N1} {3,11:N0}  {4}' -f $_.RealGB, $_.RealFiles, $_.CloudOnlyGB, $_.CloudOnlyFiles, $_.Folder) }

$L | Out-File $report -Encoding UTF8
Write-Host ''
$L | Select-Object -First 25 | ForEach-Object { Write-Host $_ }
Write-Host ''
Write-Host "  Saved: $report"
Write-Host "         $csv"
Write-Host '  Nothing was changed.'
