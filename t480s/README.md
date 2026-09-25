# T480s (Lenovo)

Same toolkit as `../x51`, relabeled for this machine so its reports and rescued
files never mix with the Alienware's. See `../README.md` for what each script does;
only the output folder/file names differ here (`T480S-Inventory`, `T480S-Gathered`,
`T480S-Rescue`, etc. instead of the `X51-...` ones).

Run order is the same:
1. `1-inventory.bat` - read-only hardware/drive/duplicate report
2. `4-list-onedrive.bat` - read-only OneDrive folder listing (keep OneDrive closed)
3. `5-gather.bat` - moves every non-system file into `Desktop\T480S-Gathered`
4. `6-copy-to-usb.bat` - copies that folder onto USB stick(s)
5. `7-appdata-report.bat` / `8-full-pc-report.bat` - read-only deeper scans if needed
6. `9-browser-and-shortcuts.bat` - Chrome/Edge bookmarks, Quick links, shortcuts to USB

## Known context for this machine

This laptop's file list (`OneDrive - T480S`, `IRP Backup`, `Bin recovery from Drive`,
`Roof Experts - Local`, `Ihor - TA PC Backup`) points to business material mixed in
with personal files - IR Performance / IRP, Roof Experts, Nations Renovations, and
people: Paul Lewis, Anthony Cass, Ihor Huk. Flagged for a separate pass once the
device inventory is done - not yet sorted or actioned.
