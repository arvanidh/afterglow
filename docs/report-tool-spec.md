# AFTERGLOW — In-Game Report Tool Spec v1.0

> Companion to `discord-server-plan.md` §4.1 (feedback intake) and `settings-menu-spec.md` (`report_a_bug`). The bridge between a frustrated player and a fixed bug — designed to cost the player **under 60 seconds** and cost us **$0 server time**.
> **Architecture law:** no auto-upload, ever (offline-first, §12.5). The tool *generates a file*; the player chooses where it goes. Privacy policy stays true by construction.

---

## 1. Entry points

| Location | Trigger | Context bonus |
|---|---|---|
| Settings → About → **Report a bug** | Manual | None |
| Pause menu footer | Small text link | Pre-fills current biome + run state |
| Results screen (deaths only) | "Something feel wrong?" subtle link | Attaches death cause + clip offer |
| **Crash recovery dialog** *(next launch after a crash)* | One-tap: "Tell us what happened?" | Auto-attaches crash stack (see §6) |

## 2. What gets captured

### Automatic (always, no player effort)

| Item | Source | Why |
|---|---|---|
| Build version + commit hash | `version` autoload | Triage basic |
| Device model, Android version, RAM tier | `OS`/`Performance` APIs | Repro matrix |
| Quality preset + all settings values | settings save (§settings spec) | "works on High, breaks on Low" cases |
| Current context snapshot | RunState | Biome, minute-mark, character, active weapons/passives |
| Telemetry tail | Ring buffer of last 50 events (`run_start`, `levelup_choice`, `interstitial_shown`…) | Reconstructs the minute before the problem |
| FPS/perf ring summary | p50/p95/p99 over last 120 s | Performance reports self-triage |
| Last crash stack (if present) | Crashlytics-local mirror / Godot error handler | Crash reports without re-typing |
| Save meta slice | Schema version, account level, unlocks list — **not** the full save | Context without bloat or cheat-export abuse |

### Player-optional (toggles on screen 2)

| Attachment | Cap |
|---|---|
| Last-death clip (from §15.4 replay buffer) | 12 s animated WebP, ≤4 MB |
| Recap card PNG | ≤1.5 MB |
| Full save file | Only when explicitly needed for progression-loss bugs |

**Privacy fence (hard rules):** no contacts, no location, no advertising ID, no anything the privacy policy doesn't already disclose — because nothing transmits unless the player personally shares the file. The fence is architectural, not promised.

## 3. File format

Single file: `AG-report-v0.7.2-20261012-1945.zip` (`.zip` chosen over cute extensions — players' apps can actually open/share it).

```
manifest.txt          ← human-readable 20-line summary FIRST (dev skims this 90% of the time)
report.json           ← schema_version, device{}, context{}, settings{}, events[], perf{}
attachments/
  ├── clip.webp       (optional)
  └── card.png        (optional)
```

- `report.json` fields snake_case, schema-versioned (`report_schema: 1`) — old reports never break the parser.
- Whole file ≤ **6 MB** hard cap; clip auto-downgrades to GIF frames if over.
- `manifest.txt` mirrors exactly what gets pasted into Discord — one artifact, two destinations.

## 4. UI flow (three screens, thumb-only)

**Screen 1 — What happened?**
Six large category chips (matching Discord forum tags): `crash · visual · balance · ui · audio · performance`.
One required field: *"In one line…"* (symptom, 140 chars). Optional expandable: steps to reproduce.

**Screen 2 — Attach evidence**
Auto-context shown as read-only chips ("Spire · minute 7 · Volt"). Toggles: clip ✓ (if buffer exists), card, save file. Frequency picker: always / sometimes / once. Everything pre-decided — most users just tap Next.

**Screen 3 — Send it somewhere**
Generated-file preview + the **prefilled Discord template** rendered as copyable text:

```
Title: [Spire] – homing orbs visible through walls
Build: v0.7.2 (8f3c21e) · Pixel 7a · Android 16 · preset High
Repro: during Null Phase 2, orbs track through pillar shields…
Expected: blocked · Got: hit anyway · Frequency: sometimes
📎 AG-report-v0.7.2-20261012-1945.zip attached
```

Buttons: **Share via…** (native sheet — Discord, email `[SUPPORT EMAIL]`, Drive, whatever the player has) / Save locally / Copy text. Works 100% offline; sharing is the online part, and it's the player's own connection.

## 5. Discord hand-off

- Pasted text matches the #bug-reports pinned template field-for-field (§discord plan) — moderators never reformat.
- Category chip = suggested forum tag; poster picks final tag.
- Zip lands as a normal attachment; triage flow proceeds per §4.2 unchanged.
- Reporter credit loop intact: fix notes cite the report title + first name/handle they used.

## 6. Crash recovery path

If previous session ended in a caught fatal (Godot error handler wrote `last_crash.stack`):

1. Next clean launch shows a calm dialog: *"Last run ended badly. Not your fault — ours, probably. Tell us?"*
2. Yes → Screen 1 pre-seeded: category `crash`, stack auto-attached, context frozen from crash moment.
3. No → dialog dismisses forever for that crash (flag hash); we don't nag. Respect law extends to guilt trips.

## 7. Implementation sketch (Godot)

```gdscript
# ReportTool.gd (autoload)
func generate(category: String, symptom: String, opts: Dictionary) -> String:
    var payload := {
        "report_schema": 1,
        "device": collect_device(), "context": RunState.context_snapshot(),
        "settings": Settings.export_all(), "events": Telemetry.tail(50),
        "perf": PerfMonitor.summary(120), "crash": CrashStore.last_stack()
    }
    return ZipWriter.pack("user://reports/", payload, opts.attachments)
# ZipWriter: JSON → manifest.txt rendering → zip via Godot's FileAccess + store paths
```

Ring buffers (`Telemetry.tail`, `PerfMonitor.summary`) are written continuously during runs at negligible cost — the report tool only reads them.

## 8. Acceptance checklist (ship gate)

- [ ] Full flow completable offline; airplane-mode suite passes
- [ ] Generated zip ≤6 MB; opens in stock Android file manager + Discord preview
- [ ] manifest.txt alone answers: what broke, where, on what, at which minute
- [ ] Paste-text matches #bug-reports template exactly (side-by-side review)
- [ ] Crash dialog appears exactly once per crash, never twice
- [ ] Privacy spot-check: strings-scan report files for forbidden identifiers (ad id, geodata) — zero hits
- [ ] Solo-dev triage test: 10 random beta reports processed using ONLY manifest.txt, timing under 90 s each

---

*Report tool v1.0 — the player does the talking; the file does the paperwork; nobody pays for a server.*
