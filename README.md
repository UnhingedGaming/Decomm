# Decomm

Tools for inventorying, cleaning up and reusing an old Alienware X51 R2 (Windows 10 1909).

## Failing drive? Run `5-rescue.bat` first

Copies every file that exists only on this PC (user folders, inventory reports, browser bookmarks) to a USB drive, retrying unreadable spots only once. Skips OneDrive, whose files are in the cloud.

## x51 scripts

| Script | What it does | Changes anything? |
|---|---|---|
| `1-inventory.bat` | Hardware, Windows, drive health, programs, startup items, OneDrive settings, folder sizes, and a duplicate-file report (`find-duplicates.ps1`). Output goes to `Desktop\X51-Inventory`. | **No.** Read-only. |
| `2-clean.bat` | Clears temp files, the Windows Update cache and Disk Cleanup items. | Deletes junk only. Never touches personal files, OneDrive, Downloads, the Recycle Bin or Windows.old. |
| `4-list-onedrive.bat` | Lists every file in the OneDrive folder (name, size, date, cloud-only or on the PC) without downloading anything. Keep OneDrive closed. | **No.** Read-only. |
| `3-optimize.bat` | Repairs Windows (DISM + SFC), scans the drive read-only, optimizes drives, sets the High performance power plan. | System only. |

**Order:** run 1 first. Run 2 and 3 only after the inventory shows your files are safe and backed up.
Writing to a drive (and defrag in particular) can make deleted files impossible to recover.

### Running them

1. On the X51, download this branch as a ZIP (Code → Download ZIP).
2. Right-click the ZIP → **Extract All**. Don't run the scripts from inside the ZIP.
3. Double-click `1-inventory.bat` and click **Yes** when Windows asks for admin rights.
   If SmartScreen appears, click **More info → Run anyway**.
