# AFTERGLOW — Accessibility Pass v1.0

> Companion to §6 (Mobile Controls & UX). Principle: **accessibility is a design pillar, not a patch** — every item here ships in the launch build, not "post-launch if time permits."
> Budget note: everything below is engine features + data tables. $0.

---

## 1. Vision & perception

| Need | Solution | Default |
|---|---|---|
| Colorblind (protan/deutan/tritan) | Enemy telegraphs are **shape-coded first** (§6 rule): Spitter = landing-zone decal, Wraith = crouch-flash, elites = aura + name tag, hazards = animated outline patterns | Shape coding always on |
| Colorblind palettes | 4 modes in settings: **Standard / Protanopia / Deuteranopia / Tritanopia** — implemented as palette-swap `.tres` variants of §10.1 colors (danger magenta → blue-shifted variant etc.) | Standard |
| Brightness/glow tolerance | **Glow intensity slider** (0–100%, default 80%) — scales bloom strength; Low quality preset already disables glow entirely | 80% |
| Contrast | **High-contrast mode**: background gradient darkens to near-black `#070912`, enemy bodies gain +1 px outline, HUD text switches to pure white | Off |
| Screen-size legibility | UI scale independent of world zoom: **100 / 115 / 130%** (§6) with safe-area reflow audit per step | 100% |

**Design law:** color never carries exclusive meaning anywhere in AFTERGLOW — shape, motion, or position always co-signals. This is enforced in the palette template (§10.1), so new content can't violate it.

## 2. Control alternatives

| Need | Options |
|---|---|
| Left vs right handed | Floating joystick anchors to whichever half of the screen is touched first (**left-handed mode** = fixed-stick mirrored right) |
| Motor fatigue / small hands | Three joystick styles: **Floating** (default) · **Fixed** (static position) · **Edge-swipe** (drag anywhere, no visible stick) |
| Stick feel | Dead-zone size (Small/Med/Large), sensitivity slider, optional stick opacity 25–100% |
| One-hand reachability | Already a design pillar (§6); verified at all three UI scales and in landscape + portrait-ish aspect ratios |
| Accidental input protection | Pause button requires 150 ms hold on High UI scale (mis-taps during panic dodges); level-up cards ignore touches for first 200 ms so thumb momentum doesn't auto-pick |
| External controllers | Bluetooth controller mapping (left stick move, A = dodge when unlocked) — free via Godot input map |

**Haptics:** global toggle + intensity (Off / Subtle / Full). Damage feedback never relies on haptics alone — visual vignette always fires too (§7.3).

## 3. Motion reduction

| Setting | Effect |
|---|---|
| **Reduce Motion** (master toggle) | Disables screen shake entirely, halves hit-stop duration, removes zoom pulses and chromatic-aberration damage flash |
| Shake intensity | Granular slider 0–100% if players want partial shake (Reduce Motion overrides to 0) |
| Background parallax | Static option — layers stop drifting for vestibular comfort |
| Death/level-up transitions | Instant-cut option replaces slide/scale animations |
| Particle density | Tied to quality presets (Low = −50%) plus an extra **Particles: Minimal** toggle that keeps only kill bursts (gameplay-critical info) |

Defaults respect the player immediately: first-boot detection offers Reduce Motion if OS-level reduce-motion is enabled.

## 4. Audio accessibility

- All gameplay-critical signals have visual counterparts already (boss entrances, Spitter decals) — audio is enhancement, never sole channel.
- **Boss health audible cue** gets an optional visual pulse ring on the boss instead.
- Separate music/SFX sliders (§11 mix rules) double as cognitive-load tools.
- Subtitles/captions: any future story/vocal content ships with caption toggle; today's game has none by design (note kept here so it stays true).

## 5. Cognitive load

- Level-up pause is unlimited-time by default; optional **"Relaxed decisions"** toggle removes the slow-fade urgency styling entirely.
- Build summary readable mid-run via pause (§6) — no memorization required.
- Tutorial micro-run replayable anytime from settings ("How to play").
- Icon + word pairing everywhere: no icon-only menus (localization bonus).

## 6. Settings menu integration

Accessibility gets its own top-level tab (not buried under "Advanced"): `Vision · Controls · Motion · Audio`. Every setting applies **instantly with a live preview behind the menu** (a looping arena scene plays dimmed behind panels). All settings persist to save file v1 schema and survive reinstall via cloud-save opt-in.

## 7. Testing checklist (ship gate)

- [ ] Simulate protanopia/deuteranopia/tritanopia (Godot color-filter debug shader): every death cause identifiable by shape/motion alone
- [ ] Full run completed at Glow 0% + High Contrast — readability verdict from one non-dev tester
- [ ] Full run with Reduce Motion on — zero nausea report from motion-sensitive tester (30+ min session)
- [ ] Left-handed mode: full run, zero UI occlusion moments
- [ ] Edge-swipe joystick: 3 runs, no accidental pause triggers
- [ ] UI 130% + tablet layout + foldable inner screen — no clipped labels (longest locale: German)
- [ ] Controller-only run start-to-boss
- [ ] Settings persistence: force-close app mid-session → relaunch → all toggles intact
- [ ] First-boot flow honors OS reduce-motion/bold-text flags where exposed
- [ ] Battery sanity: Reduce Motion build shows no FPS regression on Snapdragon 4xx device

## 8. Scope guardrails (honest v1 boundaries)

Not in launch scope, documented for post-launch votes in #feature-votes: full screen-reader navigation (menu structure is simple enough to add later without rework — flat hierarchy, labeled controls from day one), one-switch play mode, remappable multi-touch gestures beyond the three joystick styles.

---

*Accessibility pass v1.0 — ships at launch, costs $0, tested like a feature because it is one.*
