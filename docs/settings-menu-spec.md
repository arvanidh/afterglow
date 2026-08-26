# AFTERGLOW — Settings Menu Spec v1.0

> Companion to §6 (Mobile Controls & UX), `accessibility-pass.md`, and §12.2 save system. One source of truth for every toggle, its key, default, and where it lives.
> **Menu laws:** every change applies instantly with a looping arena scene visible behind panels (live preview); nothing requires restart; nothing hides under "Advanced."

---

## 1. Layout

Six top-level tabs, thumb-reachable bottom navigation:

```
[ Gameplay ] [ Controls ] [ Graphics ] [ Sound ] [ Accessibility ] [ About ]
```

- Opens over a dimmed, slowly looping Promenade scene (world renders behind panels — changes visibly land).
- Reached from main menu AND pause screen (identical panel; pause variant adds "Resume" footer button).
- Safe-area insets respected at all three UI scales; German locale verified (longest strings).

## 2. Gameplay tab

| Key | Type | Options | Default | Notes |
|---|---|---|---|---|
| `notif_streak` | toggle | on/off | **off** | Daily-challenge streak reminder; max 1/day policy (§13) — never default-on |
| `relaxed_decisions` | toggle | on/off | **off** | Removes slow-fade urgency styling from level-up cards (a11y cognitive) |
| `show_damage_numbers` | toggle | on/off | **on** | Off = cleaner screen for screenshot purists |
| `how_to_play` | button | — | — | Replays tutorial micro-run anytime |
| `daily_challenge_info` | info row | — | — | Today's seed constraint + countdown; not a toggle |

## 3. Controls tab

| Key | Type | Options | Default | Notes |
|---|---|---|---|---|
| `joystick_style` | choice | Floating / Fixed / Edge-swipe | **Floating** | §6 + a11y alternatives |
| `handedness` | choice | Right / Left | **System-agnostic: Right** | Fixed style mirrors to left side when Left |
| `dead_zone` | choice | Small / Medium / Large | **Medium** | |
| `stick_sensitivity` | slider | 50–150% | **100%** | |
| `stick_opacity` | slider | 25–100% | **70%** | Edge-swipe ignores (no visible stick) |
| `haptics_intensity` | choice | Off / Subtle / Full | **Full** | Visual feedback always fires regardless (a11y law) |

## 4. Graphics tab

| Key | Type | Options | Default | Notes |
|---|---|---|---|---|
| `quality_preset` | choice | Auto / Low / Medium / High | **Auto** | Auto-detected at first boot (§10.3); shows detected device class underneath |
| `fps_cap` | choice | 30 / 60 | **60** (30 on Low auto) | Thermal escape hatch |
| `glow_intensity` | slider | 0–100% | **80%** | Scales bloom strength; Low preset floors it regardless |

*(Deliberately absent: resolution scaling, shaders-by-category — scope discipline; presets carry complexity.)*

## 5. Sound tab

| Key | Type | Options | Default | Notes |
|---|---|---|---|---|
| `vol_master` | slider | 0–100% | **100%** | Limiter always on (§11) |
| `vol_music` | slider | 0–100% | **80%** | |
| `vol_sfx` | slider | 0–100% | **100%** | Sliders play sample blip while dragging |

## 6. Accessibility tab *(four grouped sections)*

**Vision**
| Key | Type | Options | Default |
|---|---|---|---|
| `colorblind_mode` | choice | Standard / Protanopia / Deuteranopia / Tritanopia | Standard |
| `high_contrast` | toggle | on/off | off |
| `ui_scale` | choice | 100% / 115% / 130% | 100% |

**Motion**
| Key | Type | Options | Default |
|---|---|---|---|
| `reduce_motion` | toggle | on/off | **OS reduce-motion flag if exposed, else off** |
| `shake_intensity` | slider | 0–100% | 100% (overridden to 0 by reduce_motion) |
| `static_parallax` | toggle | on/off | off |
| `instant_transitions` | toggle | on/off | off |
| `particles_minimal` | toggle | on/off | off (keeps kill bursts only — gameplay-critical info stays) |

**Cognitive** — mirrors `relaxed_decisions` (Gameplay) + link-line to How to Play.
**First-boot:** OS reduce-motion / bold-text flags applied silently on cold install; banner explains "adjusted for your system — change anything below."

## 7. About tab

| Key | Type | Notes |
|---|---|---|
| `privacy_policy` | link | URL from `privacy-policy.md`; required placement |
| `report_a_bug` | button | Opens in-game report flow (captures save slice/log/clip → Discord template hand-off, `discord-server-plan.md` §4.1) |
| `restore_purchases` | button | Hidden until IAP ships (§14.5); then lives here, not in a store overlay |
| `credits` | panel | Roles + font/OFL attributions + tester wall of fame (@Bug Hunters, season Councils) |
| `version` | info row | `vX.Y.Z (build)` — tappable 3× enables verbose logging for support sessions |

**Danger zone** (bottom, red-bordered group):
| Key | Type | Notes |
|---|---|---|
| `reset_progress` | double-confirm button | Typed confirmation ("outshine") — no accidental wipes; exports backup file first |

## 8. System rules

- **Persistence:** all keys in save schema v1 (`user://settings.json`, atomic writes, §12.3); synced via optional Play Games cloud save alongside progress.
- **Instant apply:** every control mutates live values through the same autoloads gameplay reads (`Audio`, `QualityManager`) — preview *is* reality.
- **Telemetry:** `settings_changed{key, value}` only on final commit (slider release), never per-tick.
- **Mid-run access:** pause menu exposes quick row only — music, haptics, quit. Everything else waits; full settings during a run is a death wish we don't sell.
- **No dark patterns:** nothing defaults to ON that benefits us (notifications off, personalized ads handled by UMP consent — not here).

---

*Settings spec v1.0 — every switch honest, every default defensible.*
