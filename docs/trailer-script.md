# AFTERGLOW — 30-Second Launch Trailer Script v1.0

> Companion to `press-kit.md` (asset checklist) and `devlog-content-calendar.md` (premieres L−3). Two deliverables from one edit: **16:9 master** + **9:16 vertical** reframe.
> **Trailer laws:** muted-autoplay must carry the whole story · hook lands inside 1.5 s · opens on failure, not glory (pattern-interrupt) · no voice-over (localization-free by design).

---

## 1. Format & delivery specs

| Property | Value |
|---|---|
| Runtime | 30.0 s exactly (Play video field sweet spot; Shorts-safe) |
| Master | 1920×1080 / 30 fps / H.264 high / ≤40 MB |
| Vertical | 1080×1920 reframe — every shot composed center-safe so the cut needs no reshoots |
| Audio | −14 LUFS integrated, true peak ≤ −1 dBTP |
| Captions | None burned in (no VO exists); press kit gets identical file |

## 2. Beat sheet

| Time | Shot (16:9 framing) | Action | Overlay text (Chakra Petch Bold) | Audio / music beat |
|---|---|---|---|---|
| 0.0–1.5 | **Cold open: a death.** Red vignette pulses over a swarm overrun | Player dies at 99% boss HP; hit-stop freeze frame | *"Devoured by THE DEVOURER… 2 seconds before your chest opened."* (typewriter-in) | Single low drone note. No music. Deliberate discomfort |
| 1.5–3.0 | Hard cut to black → spark ignites center-screen (icon geometry animates on) | Spark flares to full glow | **AFTERGLOW** wordmark stamps under it | First bass pulse (kick enters, 95 BPM established) |
| 3.0–8.0 | Gameplay: Promenade early run | Floating joystick appears wherever thumb lands; auto-fire pops shades into motes; gems vacuum | *"ONE THUMB. TOTAL CONTROL."* | Arpeggio layer starts; kill-pops percussive, quantized to grid |
| 8.0–13.0 | Level-up flow ×3 rapid cuts | Card trio slides in → pick → power visibly changes the screen | *"STRONGER EVERY 45 SECONDS."* | Melody layer joins; card picks land ON beats |
| 13.0–18.0 | Escalation montage | Evolution unlock slow-mo flash → crowd turns into fireworks → kill counter spins past **4,112** | *"4,112 SHADES. NONE SENT FLOWERS."* | Percussion layer slams in (§11 vertical layering mirrored in the mix) |
| 18.0–20.0 | **The drop.** Arena dims, vignette closes | THE DEVOURER name-card slams full-screen | *(none — the name card is the text)* | Pre-drop silence, one beat — then the bass drop lands exactly on the slam (§11's cheap drama, weaponized) |
| 20.0–26.0 | Boss fight sync-cuts | Lane sweep dodge → Slam telegraph ring → amber weak points exposed → Nova detonation fills frame | *"OUTSHINE IT."* (single line, late in sequence ~24 s) | Drop section, every cut on kick; haptic-feel low end |
| 26.0–28.0 | Results screen flourish | Recap card generates live: stats snap in, share button glows | *"#AFTERGLOW"* bottom-right corner tag | Music pulls back to arpeggio+pad (breath before end card) |
| 28.0–30.0 | End card | Icon spark animates once; wordmark; store badge | **"Outshine the dark."** + *Out now on Google Play* | Final resolved chord, tail rings out clean |

## 3. Vertical (9:16) reframing rules

- All action composed in central 9:16 column during capture — HUD elements sit inside it natively (mobile footage is already vertical-friendly; the 16:9 master is the letterboxed art pass).
- Overlays move to upper-third stack; end card becomes stacked layout (spark → wordmark → badge vertically).
- The Devourer name-card slam gets its own dedicated vertical take (it's a UI animation — trivially re-rendered at 1080×1920 via the SubViewport pipeline, §recap-card-spec tech).
- Death cold-open keeps typewriter timing identical; text wraps to two lines instead of one.

## 4. Sound design spec

- **No voice-over. Ever.** Muted autoplay is the primary viewing context; VO would also force per-locale dubs we won't pay for.
- SFX set: kill-pop blips (quantized), card-slide whoosh, chest choir stab (held for the 26 s card moment), boss roar sub-drop, recap-card chime = game's actual level-up sound (audio branding consistency).
- Mix: SFX duck music −3 dB on slams/drops (§11 rule); master limiter on; final tail must fade to true silence before 30.0 — no clipped endings on loop platforms.
- Source stems from LMMS project exported per-layer so the mix can rebalance without recomposing.

## 5. Footage sourcing map (all already captured per devlog calendar)

| Beat | Source |
|---|---|
| Cold open death | Beta telemetry replay capture — pick a real 99%-death (authenticity reads) |
| 3–18 s gameplay | Best-of P1/P2 Juice Check raw captures, color-matched batch |
| Evolution slow-mo | Dedicated 120 fps capture session (one evening) |
| Boss sequence | Boss-sheet QA capture runs (§boss sheets acceptance footage reused) |
| Recap card | Live screen-record of §15.1 generation flow |
| Icon/end card | `app-icon-spec.md` beauty render animated (scale+glow keyframes only) |

## 6. Acceptance tests

- [ ] **Muted playthrough:** all five story beats readable with zero audio
- [ ] **1.5-second test:** five strangers describe the opening as "a game where you die fighting shadows" unprompted
- [ ] Every overlay ≤5 words; both crops free of safe-area violations
- [ ] Beat-sync audit: cuts land within ±1 frame of kicks (watch waveform against timeline)
- [ ] File targets met; thumbnail frame (t=19.5, name-card mid-slam) exports clean at 1280×720
- [ ] A/B thumbnails prepared: name-card slam vs crowd-fireworks frame — decide via Shorts data after 72 h

---

*Trailer v1.0 — thirty seconds: die, ignite, build, drop, outshine.*
