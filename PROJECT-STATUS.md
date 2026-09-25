# Device Cleanup — Project Status

One place tracking what's done, per device and for the OneDrive account, across
every "Claude - ... Cleanup" conversation in the Device Cleanup group. Update this
file (and commit/push) whenever a device's status changes, so any conversation can
read it cold instead of re-deriving state from chat history.

## IRP / Huk situation — legal status

Attorney and DA are already involved. Incident began approximately June 2023;
IRP (Paul's entity) closed Dec 27, 2024. Given active legal involvement:

- Do NOT delete, deduplicate, or "clean up" any IRP/Huk/Paul/Roof Experts/
  Nations Renovations material found on any device (T480s and HP Z2 Mini are
  the ones with confirmed related folders so far: `IRP Backup`,
  `Ihor - TA PC Backup`, `Roof Experts - Local`)
- Before running gather/cleanup scripts on T480s or HP Z2 Mini, check with the
  attorney/DA whether they need a forensic image of those machines first -
  a plain file copy is not the same thing
- Quarantine (copy into its own untouched, clearly labeled folder), don't
  delete, anything related, once cleared to proceed
- This is a legal matter being handled by counsel - not something to
  investigate or act on unilaterally here beyond preserving data

## End goal (decided 2026-09-25)

Once every device below is inventoried and its real local files are identified,
consolidate everything onto **one large external drive** (2-4TB) as a single
clean, deduplicated master copy. Then create a **brand new Microsoft account**
and set up OneDrive fresh against that master copy - no sync history, no
inherited duplicates, no connection to the current melyssacass@gmail.com
account or anything that ever touched the irperformance.com situation.

The current melyssacass@gmail.com account (confirmed safe/not compromised) can
be archived or closed later, once the new account is confirmed working. No
rush on that step - it happens after the migration, not before.

This does not change the immediate per-device work, just the destination: we're
building toward the master drive + new account, not toward "fix the current
OneDrive account."

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
- Confirmed live connection: OneDrive setup on the LapTots (Surface) kept
  defaulting to a work account, **Lyss@irperformance.com** - this is a real,
  currently-connected account on at least one machine, not just old file names.
- Next step: run `5-gather.bat`, review the found-files list before confirming

### Surface Laptop 5 — "LapTots" / "Surface" (main OneDrive-syncing device)
- **Conversation:** Claude - LapTots Cleanup (this cloud conversation is coordinating it)
- **Folder:** `laptots/`
- **Status:** 🟢 Active work in progress
- **Local Claude Code is now set up on this machine** (C:\Users\Melys as workspace,
  browser tools off, MCP auth skipped) - it has direct file read/write access here,
  separate session from this cloud conversation. Bridge between the two is manual
  copy/paste of context and findings.
- Local library confirmed intact after rename: `!Laptots Library - LOCAL COPY`
  (492GB, 1,224 top-level items) - years of repeated OneDrive re-syncs, heavy
  duplicate folder names (e.g. `196 Lake Rockwell`/`1`/`2`, `- Copy`/`Copy1`/`Copy2`)
  - dedup needed before consolidation, not yet started
- Local Claude Code completed a read-only inventory of C:\Users\Melys and flagged:
  - **`Desktop\Briar_Ridge_Case_Summaryv1.docx`** - likely IRP/Huk case material.
    Left untouched, not opened. Instructed to keep leaving it (and anything similar)
    completely alone - existence/size only, no content read, no dedup inclusion.
  - `Desktop\Laptots-Full-Report.txt` header says "X51 FULL PC REPORT" - resolved:
    this is a real prior scan of **this same Surface**, run before the toolkit was
    split into per-device folders, not a second machine. Not a discrepancy.
  - **Unresolved:** `T480S-Full-Report.txt` / `T480S-All-Folders.csv` found on
    *this Surface's* Desktop - needs confirming whether these were accidentally
    generated by running T480s scripts on the Surface instead of on the actual
    T480s. If so, T480s does not yet have real inventory data.
  - `Documents\Other` contains financial exports (.qbo/.qfx) and an Outlook
    .pst.tmp - noted, not evaluated further, not urgent
  - `Pictures\! ARK IR` - investment-research-looking folder oddly placed under
    Pictures - noted, not evaluated
  - `Desktop\Delete me - CLAUDE` - unrelated game-mod dev scratch folder, already
    named for deletion - user's call, not blocking
- Next: resolve the T480s report-origin question, then decide dedup approach for
  the 1,224-item Library folder (many are timestamped near-duplicates)

### HP Z2 Mini
- **Conversation:** none yet
- **Folder:** none yet
- **Status:** ⚪ Untouched — currently unplugged (safe, can't sync)
- **Flagged:** user indicated this machine is "involved" in the IR Performance /
  IRP / business-material situation (see below). Not detailed yet - revisit when
  ready to get into it, alongside the T480s and LapTots findings.

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
