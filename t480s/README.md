# T480s scripts

Same toolkit as `x51/`, relabeled so its reports never mix with the Alienware's.
Run these on the **Lenovo T480s** only.

| Script | What it does | Changes anything? |
|---|---|---|
| `1-inventory.bat` | Hardware, Windows, drive health, programs, startup items, OneDrive settings, folder sizes, duplicate report. Output: `Desktop\T480S-Inventory`. | **No.** Read-only. |
| `4-list-onedrive.bat` | Lists every file in the OneDrive folder, cloud-only or on disk, without downloading anything. | **No.** Read-only. |
| `5-gather.bat` | Finds every non-system file on C: and **moves** it into `Desktop\T480S-Gathered`, keeping original folders. Files in a OneDrive folder are copied instead of moved. Undo list included. | Moves/copies files off C:, nothing deleted. |
| `6-copy-to-usb.bat` | Copies `T480S-Gathered` onto one or more USB sticks. | Copies only. |
| `7-appdata-report.bat` | AppData contents + which Microsoft accounts have signed in. | **No.** Read-only. |
| `8-full-pc-report.bat` | Every folder on C: with real vs. cloud-only size. | **No.** Read-only. |
| `9-browser-and-shortcuts.bat` | Chrome/Edge bookmarks, Quick links, desktop shortcuts, Quick Access/taskbar pins → USB. | Copies only. |
| `2-clean.bat` / `3-optimize.bat` | Junk cleanup / drive optimize. Only run **after** files are confirmed safe. | Writes to the drive. |

**Order:** run `8-full-pc-report.bat` first to see everything on the machine before moving anything (this laptop already has folders like `OneDrive - T480S`, `IRP Backup`, `Bin recovery from Drive` from earlier syncing — check what's really local before gathering).
