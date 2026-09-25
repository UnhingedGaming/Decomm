# LapTots (Surface Laptop 5)

Same toolkit as `../x51`, relabeled so its reports and rescued files stay separate
from the other devices. Named "LapTots" to match this machine's name in the
Microsoft account device list (it also shows as "Surface" on the front page of
account.microsoft.com — same physical laptop, i7/32GB/1TB).

This is the **primary/main machine** — it already holds a real local copy of the
consolidated library, not just cloud-only shortcuts. See `../PROJECT-STATUS.md`
for full current status before starting anything here.

Run order:
1. `1-inventory.bat` - read-only hardware/drive/duplicate report
2. `4-list-onedrive.bat` - read-only OneDrive folder listing (keep OneDrive closed)
3. `5-gather.bat` - moves every non-system file into `Desktop\LAPTOTS-Gathered`
4. `6-copy-to-usb.bat` - copies that folder onto USB stick(s)
5. `7-appdata-report.bat` / `8-full-pc-report.bat` - read-only deeper scans if needed
6. `9-browser-and-shortcuts.bat` - Chrome/Edge bookmarks, Quick links, shortcuts to USB

## In progress / picking back up

- Local library already found at `C:\Users\Melys\OneDrive\!Laptots` — **492 GB,
  74,954 real files** (Documents 215GB incl. Gmail Takeout + Samsung phone backup
  + Outlook PST, Videos 144GB, Music 70GB, Pictures 63GB), plus
  `C:\!LOCAL - No One Drive` (12GB, local-only)
- Was mid-way through renaming `C:\Users\Melys\OneDrive` →
  `!Laptots Library - LOCAL COPY` (to free the name up so OneDrive can be signed
  back in against an empty folder without merging/creating duplicates) - blocked
  by a file lock, suspected OneDrive setup / Outlook / a music-or-photo app
  holding a handle open
- Next: Task Manager → Startup apps → disable OneDrive (and Outlook/MusicBee/
  digiKam if present) → restart → retry the rename → sign OneDrive in fresh,
  skip "Back up your folders" → run `4-list-onedrive.bat` → compare against
  the Alienware's old file list and the cloud's current contents
