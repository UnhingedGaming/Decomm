# Decomm

Tools for inventorying, cleaning up and reusing an old Alienware X51 R2 (Windows 10 1909).

## Failing drive? Rescue first

1. `5-gather.bat` - finds every personal file on C: (wherever OneDrive scattered it) and moves it
   into `Desktop\X51-Gathered`, keeping its original folders. Moving on the same drive only renames,
   so it's gentle on a failing disk. OneDrive-folder files are copied instead. Every move is logged
   in `_undo-list.csv`.
2. `6-copy-to-usb.bat` - copies `X51-Gathered` onto one or more USB sticks, filling them in order.

See **[PROJECT-STATUS.md](PROJECT-STATUS.md)** for current status per device and the OneDrive account - update it whenever something changes so any conversation can read state without re-deriving it from chat history.

## Devices

Each device being decommissioned/inventoried gets its own folder with a copy of
the same scripts, so reports never overwrite each other:
- `x51/` - Alienware X51 R2 (Basestar-PC)
- `t480s/` - Lenovo T480s
- `laptots/` - Surface Laptop 5 ("LapTots"/"Surface" in Microsoft account) - the primary machine

More folders (Surface, HP Z2 Mini, PowerSpec G731) get added the same way as we
get to each one.

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
