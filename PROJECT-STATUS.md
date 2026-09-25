# Device Cleanup — Project Status

One place tracking what's done, per device and for the OneDrive account, across
every "Claude - ... Cleanup" conversation in the Device Cleanup group. Update this
file (and commit/push) whenever a device's status changes, so any conversation can
read it cold instead of re-deriving state from chat history.

## IRP / Huk situation — legal status

**SECURITY WARNING - standing rule for ALL IRP-related material, every device:**
Paul Lewis is known for planting backdoors via executables, "syncing" tools, and Excel files with malicious
external data-source/update links. Rules for any IRP/Huk-related file, on any drive, any device, any
conversation, from here forward:
- NEVER execute or open any .exe file from IRP-related material
- NEVER open .xlsx/.xls files in actual Excel - read them as raw zip/XML structure instead (xlsx is a zip
  archive internally); opening in Excel risks triggering malicious external data links or legacy DDE links
- NEVER run any installer, updater, or sync tool found in this material
- If anything unexpected launches, or any unexpected network activity occurs, stop immediately and disconnect
  the affected drive

New context (2026-09-25): two external drives discovered - D:\ (1TB, 169GB free) and E:\ (2TB, 321GB free) -
contain IRP/ARK/ARKoncepts business material organized (loosely) by person: Paul, Brandon, Kris, Nick,
sales@IRP, plus Ihor's own material. Combined ~2.5TB used. Goal: consolidate onto one clean drive to hand to
Huk directly - keep originals on D:/E: untouched (copy, don't move), preserve original names/structure (no
dedup in this pass), oldest + most-organized version preferred when duplicates exist across drives.

User reports an AI agent was previously used to "organize and zip" files on these drives and this is believed
to be the source of file-naming corruption there (separate from, but possibly related to, the numeric-prefix
issue found on the LapTots personal library - both may trace back to the same
C:\Users\Melys\AppData\Roaming\Claude\local-agent-mode-sessions history, currently under investigation).


Attorney involved. NJ DA opened an investigation in June 2023 when the IRP
situation was discovered; case is currently **on hold** - DA told the user
(~June 2026) that if she builds a case herself and hands it to them, they'll
act on it. Until then it's deprioritized on their end.

**Working rule (updated 2026-09-25):** proceed normally with cleanup/
consolidation. Don't block on legal sign-off for ordinary personal files.
The one standing rule: anything clearly IRP/Huk/Paul/Roof Experts/Nations
Renovations related does not get deleted - it's potential case-building
material for the user's own effort, not something to destroy, but it's also
not a reason to freeze all other work. Quarantine it (copy into its own
clearly labeled folder) when encountered, flag it, keep moving on everything
else.

Confirmed live connection: OneDrive setup on the LapTots (Surface) kept
defaulting to a work account, **Lyss@irperformance.com** - a live connected
account on at least one machine. User has locked down her own and related
parties' accounts (Gmail personal/work, Microsoft, Xbox) but reports
continued suspicious activity ("weird shit keeps happening") after lockdown -
pointed toward persistent-access vectors that survive password resets
(Workspace/365 admin-level access, mail forwarding/delegate rules, OAuth app
grants) - user advised to check these specifically and document ongoing
incidents for the attorney.

Also flagged: HP Z2 Mini reported by user as "involved" in the situation -
not yet detailed.

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
