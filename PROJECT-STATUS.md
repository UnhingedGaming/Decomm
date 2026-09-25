# Device Cleanup — Project Status

One place tracking what's done, per device and for the OneDrive account, across
every "Claude - ... Cleanup" conversation in the Device Cleanup group. Update this
file (and commit/push) whenever a device's status changes, so any conversation can
read it cold instead of re-deriving state from chat history.

Account: **melyssacass@gmail.com** — Microsoft 365 Premium (active to Oct 2027),
OneDrive 551 GB used of 1 TB. OneDrive cleanup itself is **on hold** until every
device below is inventoried/rescued — see "OneDrive cloud" at the bottom.

Each device gets its own folder in this repo (`x51/`, `t480s/`, ...), its own copy
of the toolkit, and its own labeled output files (e.g. `T480S-Inventory`,
`X51-Gathered`) so nothing from one machine overwrites or mixes with another's.

---

## Devices

### Alienware X51 R2 — "Basestar-PC"
- **Conversation:** Claude - X51 Alienware Cleanup
- **Folder:** `x51/`
- **Status:** ✅ Rescue complete
- Hardware: Windows 10 1909, failing Seagate HDD (freezing/overheating), i5/i7 + old NVIDIA GPU
- Personal files (~1 GB real data, mostly Documents\Alienware Dump) rescued to USB, confirmed present, second copy made, Defender scan clean
- OneDrive folder was 863 GB of cloud-only shortcuts (not physically on this drive) — not a data-loss risk from this machine
- Decision: repurpose as Shane's Steam PC (Bazzite + Remote Play from the G731), doubling as home OneDrive vault. Pending: confirm GPU model from `02-hardware.txt`, buy SSD/thermal paste/optional GPU upgrade
- Removed from active OneDrive sync (unlinked)

### Lenovo ThinkPad T480s
- **Conversation:** Claude - ThinkPad T480s Cleanup
- **Folder:** `t480s/`
- **Status:** 🟡 Not started — scripts ready, nothing run yet
- Known from earlier OneDrive file-list analysis: holds `OneDrive - T480S`,
  `IRP Backup`, `Bin recovery from Drive` folders
- **Flagged, not yet actioned:** business material mixed into personal files —
  IR Performance / IRP, Roof Experts, Nations Renovations, Paul Lewis, Anthony
  Cass, Ihor Huk. Needs a separate sort/decision pass.
- Next step: run `5-gather.bat`, review the found-files list before confirming

### Surface Laptop 5 — "LapTots" / "Surface" (main OneDrive-syncing device)
- **Conversation:** Claude - LapTots Cleanup (to start)
- **Folder:** `laptots/`
- **Status:** 🟡 In progress — scripts ready, mid-task from before the folder existed
- This is the **primary machine** — 32GB/i7/1TB, holds a real local copy of the
  consolidated library at `C:\Users\Melys\OneDrive\!Laptots` (492 GB, 74,954 files:
  Documents 215GB incl. Gmail Takeout + Samsung phone backup + Outlook PST,
  Videos 144GB, Music 70GB, Pictures 63GB), plus `C:\!LOCAL - No One Drive` (12GB)
- Full-PC report already run once. Was mid-way through renaming the local
  `OneDrive` folder to `!Laptots Library - LOCAL COPY` (so OneDrive can be signed
  back in fresh, without merging into 75,000 existing local files) - blocked by a
  file lock, suspected OneDrive setup / Outlook / a music-or-photo app holding a
  handle open
- Next: Task Manager → Startup apps → disable OneDrive (and Outlook/MusicBee/
  digiKam if listed) → restart → retry rename → sign OneDrive in fresh (skip
  "Back up your folders") → run `4-list-onedrive.bat` → compare against the
  Alienware's old file list and the cloud's current contents

### HP Z2 Mini
- **Conversation:** none yet
- **Folder:** none yet
- **Status:** ⚪ Untouched — currently unplugged (safe, can't sync)

### PowerSpec G731 — "GroomLake"
- **Conversation:** none yet
- **Folder:** none yet
- **Status:** ⚪ No OneDrive on this machine — the gaming PC, Shane's Steam library
  lives/will live here, streamed to the Alienware. Not part of the OneDrive
  cleanup; may still be worth a general inventory later.

### Surface Pro 4 (retired)
- **Status:** ⚪ Off, screen cracked, believed reset. Not a data-loss risk.
  Follow-up: remove from Microsoft account's device list when convenient.

### Xbox One
- **Status:** N/A — doesn't sync OneDrive folders, no action needed.

---

## OneDrive cloud (melyssacass@gmail.com)

**On hold** until all devices above are inventoried/rescued, per your note to
keep device-level files separate first and tackle the cloud side after.

What's known so far, for when we do get to it:
- 551 GB used, all OneDrive (0 GB Outlook attachments)
- The Sep 3, 2026 "big change" flagged by OneDrive's built-in Restore tool turned
  out to be **re-uploaded duplicate videos**, not deletions — restore was not
  needed and was not run
- Multiple stale/empty leftover folders exist in the cloud (`OneDrive Lost`,
  `OneDrive Sync Issues`, `old onedrive`, `2026_0120 - Onedrive Web` — this last
  one duplicated at the top level) — safe-looking cleanup candidates, not yet
  actioned
- All known devices are currently unlinked/off/no-OneDrive, so nothing should be
  actively syncing right now
- Real comparison (cloud file list vs. each device's local file list) still needs
  to happen once every device's local inventory is done

---

## How to add a new device

1. `mkdir <device>/` and copy `x51/*.bat` + `x51/*.ps1` into it
2. Relabel output names (find/replace `X51` → device tag, and the
   `X51-Rescue`/`X51-Gathered`/`X51-Inventory`/etc. folder names) — see how
   `t480s/` was done from `x51/` for the pattern
3. Add a short section to this file
4. Start (or note) its own "Claude - ... Cleanup" conversation, and paste in a
   recap pointing at this file + its folder
