# LAPTOTS AppData + account report - READ-ONLY. Changes nothing, downloads nothing.
# Lists what is in AppData\Local and AppData\Roaming (sizes), every OneDrive-related
# folder, OneDrive account settings, and the Microsoft accounts this user has signed in with.
$out = Join-Path $env:USERPROFILE 'Desktop\LAPTOTS-AppData-Report.txt'
$cloudOnly = 0x1000 -bor 0x400000 -bor 0x40000
$lines = New-Object System.Collections.ArrayList
function Add($s) { [void]$lines.Add($s); Write-Host $s }

function Measure-Folder($path) {
    $n = 0; $bytes = [long]0
    Get-ChildItem -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if (-not $_.PSIsContainer -and (([int]$_.Attributes -band $cloudOnly) -eq 0)) { $n++; $bytes += $_.Length }
    }
    New-Object PSObject -Property @{ Files = $n; GB = $bytes / 1GB }
}

Add "LAPTOTS AppData report - $(Get-Date)"
Add "User: $env:USERNAME   Profile: $env:USERPROFILE"
Add ''

Add '=== Microsoft accounts this user has signed in with ==='
foreach ($k in @('HKCU:\Software\Microsoft\IdentityCRL\UserExtendedProperties',
                 'HKCU:\Software\Microsoft\IdentityCRL\StoredIdentities')) {
    Get-ChildItem $k -ErrorAction SilentlyContinue | ForEach-Object { Add ('  Microsoft account: ' + $_.PSChildName) }
}
Get-ChildItem 'HKCU:\Software\Microsoft\Office' -ErrorAction SilentlyContinue | ForEach-Object {
    Get-ChildItem (Join-Path $_.PSPath 'Common\Identity\Identities') -ErrorAction SilentlyContinue | ForEach-Object {
        $p = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
        if ($p.EmailAddress) { Add ('  Office sign-in: ' + $p.EmailAddress + '  (' + $p.ProviderId + ')') }
    }
}
Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts' -ErrorAction SilentlyContinue | ForEach-Object {
    $p = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
    Add ('  OneDrive account slot ' + $_.PSChildName + ': ' + $p.UserEmail + '  folder=' + $p.UserFolder)
}
Add ''

Add '=== OneDrive settings folders (Personal = home account, Business1 = work/school) ==='
$od = Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive'
if (Test-Path $od) {
    Get-ChildItem (Join-Path $od 'settings') -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | ForEach-Object {
        Add ('  settings\' + $_.Name)
        Get-ChildItem $_.FullName -Filter *.ini -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Get-Content $_.FullName -ErrorAction SilentlyContinue |
                Where-Object { $_ -match '(?i)(email|userfolder|library|cid|tenant|displayname)\s*=' } |
                Select-Object -First 15 | ForEach-Object { Add ('      ' + $_) }
        }
    }
} else { Add '  (no AppData\Local\Microsoft\OneDrive folder)' }
Add ''

Add '=== Every folder with OneDrive or SkyDrive in its name, under this profile and C:\ ==='
$roots = @($env:USERPROFILE, 'C:\')
foreach ($r in $roots) {
    Get-ChildItem -LiteralPath $r -Recurse -Force -Directory -Depth 5 -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '(?i)onedrive|skydrive' -and $_.FullName -notmatch '\\Windows\\WinSxS' } |
        ForEach-Object {
            $m = Measure-Folder $_.FullName
            Add ('  {0,8:N2} GB {1,8:N0} files on PC   {2}' -f $m.GB, $m.Files, $_.FullName)
        }
    if ($r -eq $env:USERPROFILE) { Add '  -- (the rest of C:) --' }
}
Add ''

foreach ($base in @($env:LOCALAPPDATA, $env:APPDATA)) {
    Add "=== Contents of $base (real files on this PC, biggest first) ==="
    Get-ChildItem -LiteralPath $base -Force -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $m = Measure-Folder $_.FullName
        New-Object PSObject -Property @{ Name = $_.Name; GB = $m.GB; Files = $m.Files }
    } | Sort-Object GB -Descending | ForEach-Object {
        Add ('  {0,8:N2} GB {1,8:N0} files   {2}' -f $_.GB, $_.Files, $_.Name)
    }
    Add ''
}

$lines | Out-File $out -Encoding UTF8
Write-Host ''
Write-Host "  Saved to $out - nothing was changed."
