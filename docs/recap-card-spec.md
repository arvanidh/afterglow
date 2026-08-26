# AFTERGLOW — Run Recap Card Visual Spec v1.0

> Companion spec for §15.1 (Run Recap Cards ★) of the game design document.
> Goal: a shareable image so striking that posting it feels like showing off loot — and it still looks premium after WhatsApp/TikTok crush it.

---

## 1. Design principles

1. **Compression-proof:** thick strokes (≥4 px minimum anywhere), high contrast, glow *baked into pixels* (no reliance on viewer-side rendering). Test target: legible after 70% JPEG quality + 480p re-encode.
2. **One glance, one story:** within 0.5 s a stranger reads *result → how long → how big*. Everything else is garnish.
3. **Brand carrier:** every card carries the wordmark + `#AFTERGLOW` — the card IS the ad.
4. **Deterministic export:** what the player sees on the results screen is pixel-identical to the shared PNG (same renderer, fixed resolution).

## 2. Canvas & export

| Property | Value |
|---|---|
| Canvas | **1080 × 1350 px** (4:5 portrait — optimal feed real estate on IG/Facebook; crops safely to 16:9 and 9:16) |
| Safe margin | 60 px all sides; nothing meaningful outside it |
| Export format | PNG-24 (crisp text edges); optional JPEG q90 fallback if size > 1.5 MB |
| Color profile | sRGB |

## 3. Layout grid (top → bottom)

Six-column grid (column width 160 px, gutter 20 px, starting x=60). Zones:

```
┌──────────────────────────────────────────────┐ y=0
│ A  RESULT BANNER            y 60 – 280       │  headline (≤2 lines, autoshrink)
│                                                │
│ B  HERO STAT                y 320 – 600       │  TIME SURVIVED (the flex)
│      label                                    │
│      07 : 42                                  │
│                                                │
│ C  STATS BAND               y 640 – 840       │  3-up: purified · score · peak lvl
│                                                │
│ D  BUILD STRIP              y 880 – 1060      │  4 weapon slots + evolution rings
│                                                │
│ E  IDENTITY ROW             y 1100 – 1190     │  portrait medallion + rank/name
│ ── biome accent rule ──                       │
│ F  FOOTER CTA               y 1230 – 1290     │  wordmark + #AFTERGLOW
└──────────────────────────────────────────────┘ y=1350
```

### Zone details

| Zone | Content | Spec |
|---|---|---|
| **A** | Result headline: victory line or meme death message | Max 2 lines, center-aligned, width 900 px. Autoshrink 100%→85%, never below. Victory state gets amber underline flourish (240×6 px, radius 3) |
| **B** | Hero stat: **TIME SURVIVED** | Label (28 px caps, letterspacing +8%) over digits at **220 px**, tabular numerals, `MM : SS` with thin colon. This is the largest element by law |
| **C** | 3-up band: SHADES PURIFIED / SCORE / PEAK LEVEL | Values 76 px semibold, labels 26 px caps below, columns at x-centers 240/540/840. Hairline dividers (2 px, `#2A3157`) between columns |
| **D** | Build strip: up to 4 weapon slots | Icons 150×150 px, 24 px gaps, centered as a row. Evolution weapons get an 8 px ring in their rarity color + soft radial underglow sprite. Empty slot shows dashed placeholder circle |
| **E** | Identity: 96 px character-portrait medallion (left, x=60) + player rank badge & biome chip (right-aligned) | Medallion: circular crop, 6 px cyan ring. Rank badge = shield shape w/ tier color. Biome chip = rounded rect, biome accent fill @ 20% alpha, biome name 24 px caps |
| **F** | Wordmark "AFTERGLOW" (48 px display, letterspaced) + "#AFTERGLOW" hashtag (36 px, cyan) | Centered stack, 12 px apart. Hashtag uses cyan `#00F0FF`; wordmark white-gold gradient |

**Biome accent:** a full-width 6 px rule sits directly under zone E, tinted per biome (Promenade cyan, Undercity magenta, Spire gold) — subtle wayfinding for players who compare cards.

## 4. Typography (all SIL-OFL, bundled — $0)

| Role | Font | Usage |
|---|---|---|
| Display / digits | **Chakra Petch Bold** | Headlines, hero timer, stat values, wordmark |
| Labels / chips | **Rajdhani Medium/SemiBold** | Caps labels, badges, hashtags, chips |

| Element | Size | Weight | Tracking | Color |
|---|---|---|---|---|
| Hero digits | 220 px | Bold | −1% | White `#FFFFFF` + baked glow |
| Hero label | 28 px | SemiBold | +8% caps | Cyan `#00F0FF` |
| Stat values | 76 px | SemiBold | 0 | White |
| Stat labels | 26 px | Medium | +8% caps | `#8A93C4` muted indigo |
| Headline | 64–54 px (autoshrink) | Bold | 0 | Death: `#FF2E88` · Victory: `#FFB800` |
| Wordmark | 48 px | Bold | +12% caps | Gradient white→`#FFE29A` |
| Hashtag | 36 px | SemiBold | +4% | Cyan |

Contrast floor: every text/bg pair ≥ 4.5:1 (verified against `#0B0E1A` base).

## 5. Color system (extends locked palette §10.1)

| Role | Value |
|---|---|
| Card background | Vertical gradient `#0B0E1A` → `#131832`, plus corner radial vignette (black @ 35% alpha, corners only) |
| Ambient backdrop art | Faint arena silhouette (parallax city layer @ 8% alpha) behind zones B–C — depth without noise |
| Player/friendly accents | `#00F0FF` |
| Danger/death headline | `#FF2E88` |
| Reward/victory headline | `#FFB800` |
| Muted text/dividers | `#8A93C4` / `#2A3157` |
| Rarity colors (evolution rings) | Uncommon `#00F0FF` · Rare `#B44DFF` · Epic `#FF2E88` · Legendary `#FFB800` |

**Baked-glow recipe (no live bloom):** every glowing element renders twice — a pre-blurred additive copy underneath (gaussian σ≈12 px, element color @ 40% alpha) under the crisp pass. Deterministic, cheap, survives any downstream compression because it's already in the pixels.

## 6. Stat hierarchy (decision law)

1. **TIME SURVIVED** — universal flex, works even for someone who's never played.
2. Shades purified — spectacle number (goes up, feels big).
3. Score — competitive players' hook; feeds leaderboard comparisons.
4. Peak level — builder cred.
5. Build strip — visual "ooh, what's that" bait.
6. Rank/biome/chips — context garnish.

If a future feature fights for space, it loses to something above it on this list. No exceptions.

## 7. State variants

| Variant | Differences |
|---|---|
| **Victory** | Zone A: "OUTSHONE THE DARK" + gold underline; gold ambient rim-light added along card edge (8 px inner stroke, 30% alpha) |
| **Death (default)** | Zone A: meme message (pink); no rim light |
| **Daily challenge** | Chip next to biome chip: "DAILY #<n>" with seed date; adds seed code line under zone E (mono 24 px, `AG-VOLT-7F3K2`) |
| **Rank achieved** | Rank badge glows; small "+1 TIER" ribbon on badge corner |
| **Revive used** | Tiny phoenix glyph beside timer label — quiet bragging rights |

## 8. Godot rendering implementation

### 8.1 Scene structure

```
recap_card.tscn (Control, custom_minimum_size 1080×1350)
├── BGGradient (TextureRect, generated GradientTexture2D)
├── ArenaSilhouette (TextureRect, biome-dependent)
├── Zones (Control)
│   ├── ZoneA_Headline (Label + UnderlineRule)
│   ├── ZoneB_HeroTimer (VBoxContainer)
│   ├── ZoneC_StatsBand (HBoxContainer ×3 StatCell)
│   ├── ZoneD_BuildStrip (HBoxContainer ×4 SlotIcon)
│   ├── ZoneE_Identity (HBoxContainer: PortraitMedallion, RankBadge, BiomeChip)
│   └── ZoneF_Footer (VBoxContainer: Wordmark, Hashtag)
└── GlowLayer (CanvasGroup, additive material)   ← blurred duplicates live here
```

Every glowable node registers itself; `RecapCardBuilder` duplicates sprites/labels into `GlowLayer` with the blur shader (`shader_type canvas_item; uniform float sigma;` — 2-pass gaussian on a downscaled copy, upscaled additively).

### 8.2 Off-screen capture (deterministic PNG)

```gdscript
# RecapCapture.gd (autoload helper)
const CARD_SIZE := Vector2i(1080, 1350)

func export_card(card: Control, path: String) -> String:
    var vp := SubViewport.new()
    vp.size = CARD_SIZE
    vp.render_target_update_mode = SubViewport.UPDATE_ONCE
    vp.transparent_bg = false
    card.scale = Vector2.ONE                 # author at 1:1 px — no stretch scaling
    vp.add_child(card)
    add_child(vp)
    await RenderingServer.frame_post_draw    # ensure one clean draw
    var img: Image = vp.get_texture().get_image()
    img.save_png(path)
    vp.queue_free()
    return path
```

Key gotchas encoded in the spec:
- **Author at final resolution** (card designed at 1080×1350, scale 1.0) so font rasterization is exact — no supersampling surprises across devices.
- `UPDATE_ONCE` guarantees one deterministic draw; capture happens on the results screen while the interstitial-safe moment plays.
- Fonts: `.ttf` imported with *antialiasing on, hinting light, subpixel off* (subpixel positioning breaks at odd offsets in `SubViewport`).
- Numerals use Chakra Petch tabular figures so the timer never reflows mid-capture.

### 8.3 Data binding

`RunState.end_run()` emits `run_summary` (dict: time, kills, score, level, biome, build_ids, death_message_id, rank_delta, flags). `RecapCardBuilder.bind(summary)` maps fields → nodes; unknown/missing fields fall back to defaults, never blank.

### 8.4 Share hand-off

```gdscript
var path := await RecapCapture.export_card(build_card(summary), CACHE_PATH)
ShareManager.share_image(path, caption_for(summary))   # Android intent via open-source Godot Share plugin
```

`ShareManager` is an autoload abstraction (same pattern as `AdsManager`) wrapping the community share plugin; fallback = save to gallery + toast ("Card saved — post it!") if no share activity resolves. Caption template pool lives in data files, e.g. *"Outshone the dark for {time}. {kills} shades didn't. #AFTERGLOW"*.

### 8.5 Performance rules

- Build/capture cost budget: ≤ 50 ms frame impact on results screen — heavy work (blur passes) split across 2 frames via `await get_tree().process_frame`.
- Pre-build the card during the results-screen entrance animation; the Share button is instant.
- Low-quality preset devices: identical pipeline (it's one static frame — no runtime bloom involved).
- Never capture mid-gameplay; the buffer exists only on results screens.

## 9. Acceptance checklist (ship gate)

- [ ] Legible at 33% zoom and after 480p H.264 re-encode
- [ ] All text pairs ≥ 4.5:1 contrast on gradient bg
- [ ] Timer uses tabular figures; no reflow across all 10 test locales (longest string German)
- [ ] Death/victory/daily/rank variants pixel-reviewed side-by-side
- [ ] Export ≤ 1.5 MB PNG, ≤ 400 KB JPEG fallback
- [ ] Full share flow verified offline (gallery-save fallback fires)
- [ ] Card generation invisible to frame profiler on Snapdragon 4xx device

---

*Recap card spec v1.0 — implements §15.1. Pair with `docs/death-messages.md` for Zone A content.*
