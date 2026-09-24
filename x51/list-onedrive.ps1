# X51 OneDrive file list - READ-ONLY. Lists every file OneDrive shows in the folder,
# including cloud-only ones, WITHOUT downloading or opening anything.
param(
    [string]$Folder = (Join-Path $env:USERPROFILE 'OneDrive'),
    [string]$OutDir = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'X51-Inventory')
)
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$cloudOnly = 0x1000 -bor 0x400000 -bor 0x40000

Write-Host "  Listing $Folder (nothing is downloaded)..."
$rows = New-Object System.Collections.ArrayList
Get-ChildItem -LiteralPath $Folder -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer } | ForEach-Object {
        $rel = $_.FullName.Substring($Folder.Length).TrimStart('\')
        $top = $rel.Split('\')[0]
        if ($top -eq $_.Name) { $top = '(top level)' }
        [void]$rows.Add((New-Object PSObject -Property @{
            TopFolder = $top
            Path      = $rel
            SizeMB    = [math]::Round($_.Length / 1MB, 2)
            Modified  = $_.LastWriteTime.ToString('yyyy-MM-dd')
            Where     = $(if (([int]$_.Attributes -band $cloudOnly) -ne 0) { 'Cloud only' } else { 'On this PC' })
        }))
        if (($rows.Count % 10000) -eq 0) { Write-Host "    ...$($rows.Count) files" }
    }

$rows | Select-Object TopFolder, Path, SizeMB, Modified, Where |
    Export-Csv (Join-Path $OutDir '12-onedrive-file-list.csv') -NoTypeInformation

$summary = @()
$summary += "OneDrive folder contents - read-only, nothing downloaded"
$summary += "Folder: $Folder"
$summary += "Generated: $(Get-Date)"
$summary += ""
$summary += ("{0,8}  {1,9}  {2,8}  {3,-10}  {4,-10}  {5}" -f 'Files', 'GB', 'On PC', 'Oldest', 'Newest', 'Folder')
$rows | Group-Object TopFolder | Sort-Object Name | ForEach-Object {
    $gb = ($_.Group | Measure-Object SizeMB -Sum).Sum / 1024
    $local = @($_.Group | Where-Object { $_.Where -eq 'On this PC' }).Count
    $dates = $_.Group | Sort-Object Modified
    $summary += ("{0,8}  {1,9:N1}  {2,8}  {3,-10}  {4,-10}  {5}" -f $_.Count, $gb, $local,
        $dates[0].Modified, $dates[-1].Modified, $_.Name)
}
$totalGb = ($rows | Measure-Object SizeMB -Sum).Sum / 1024
$summary += ""
$summary += ("Total: {0} files, {1:N1} GB" -f $rows.Count, $totalGb)
$summary | Out-File (Join-Path $OutDir '12-onedrive-summary.txt') -Encoding ASCII
$summary | ForEach-Object { Write-Host $_ }
