# AFTERGLOW — App Icon Spec v1.0

> Companion to `press-kit.md` asset checklist and §10 art direction. The icon is the smallest billboard we own — it works at **48 px** (home screen) and **108 px** (store) or it doesn't work.
> **Icon laws:** silhouette first · one idea only · zero text · survives every wallpaper · glow is *baked*, never assumed.

---

## 1. Concept options

### A — "The Last Spark" ★ recommended
A single four-point spark of cyan light on deep navy. It *is* the game: one bright thing against everything. Maximum simplicity, maximum palette fidelity, instantly legible at any size.

### B — "The Lamp That Stayed"
Streetlamp silhouette, one glowing pane, long light-pool beneath. Narrative-rich (Spark's origin) but carries ~6 visual elements — at 48 px the lamp reads as… a lamp. Any lamp. From any game. Fails uniqueness law.

### C — "What Ate the Light"
Dark mass with a magenta slit-eye curving around a tiny cyan dot. Dramatic, memorable — but leads with *threat*, and our brand is cozy-doom, not horror. Wrong emotional contract for a home screen tap.

**Decision:** A ships. B and C archived for feature-graphic/story art where size allows nuance.

## 2. Geometry (Concept A, precise)

Canvas: **512×512 master** (Inkscape, vector). Adaptive-icon export derives from the same file.

| Element | Spec |
|---|---|
| Background | Radial gradient: `#182042` @ 62% radius → `#0B0E1A` edges. Slightly lighter center gives depth without a visible "vignette ring" |
| Spark body | Four-point concave star (classic sparkle pinch). Vertical spike : horizontal spike = **1.45 : 1** — taller than wide reads "alive," perfectly symmetric reads "corporate logo" |
| Spark size | Height 58% of adaptive safe-zone diameter; never larger — glow needs room to breathe |
| Pinch construction | Each concave edge = quadratic bézier with control point pulled to 18% of the way toward center; this creates the inward-curling sparkle curve rather than a flat diamond |
| Core | Inner copy at 32% scale, pure white `#FFFFFF`, sharp edges |
| Body color | `#00F0FF` cyan — flat fill, no gradient on the crisp layer |
| Rotation | 0° — bolted upright. Tilted sparks read as "error icon" at small sizes |

### Adaptive icon layers (API 26+ — our floor, so no legacy square needed)

| Layer | Content | Safe zone discipline |
|---|---|---|
| Background | The radial gradient, full-bleed 108×108 dp | Extends past all masks by design |
| Foreground | Spark only (no glow in vector layer — see §3) | Entire mark inside **Ø66 dp safe circle**; spikes touch 64% of zone max |
| Monochrome (Android 13 themed) | Spark as single-path silhouette | Pure white path, system tints it |

Mask survival: verified in circle, squircle, and rounded-square — the gradient bg makes all three identical-looking; the spark never nears a masked edge.

## 3. Glow treatment (baked, per recap-card recipe)

The crisp vector stays clean in source; glow exists only in raster exports:

1. Duplicate spark → gaussian blur σ=8 px @ 55% alpha, additive, cyan
2. Second duplicate → σ=20 px @ 28% alpha, additive
3. Stack order: big soft halo → tight halo → crisp spark → white core

Why baked: launchers, folders, and share sheets recompress icons ruthlessly. Assumed bloom dies; baked pixels survive. Test target below.

Optional flourish (store-size renders only, ≥192 px): a single faint amber arc along the bottom curve — the last city horizon. Removed below 192 px because a 3 px arc at 48 px is noise.

## 4. The 48 px gauntlet (acceptance tests)

- [ ] **Squint test:** icon at 48 px, eyes blurred — still obviously "a bright spark on dark"
- [ ] **Wallpaper matrix:** light / dark / photo-busy backgrounds — contrast holds ≥3:1 against all three
- [ ] **Folder grid:** placed among 8 deliberately similar neon-styled competitor fakes — identified correctly by 5/5 non-dev friends
- [ ] **Notification size** (~24 dp effective): spark still resolves, doesn't become a blob-dot
- [ ] **Compression:** save-as-JPEG q70 + 50% downscale-upscale roundtrip → glow intact, no banding rings in gradient
- [ ] **Themed mode:** monochrome silhouette recognizable without color
- [ ] **One-glance story check:** stranger asked "what do you think this app is?" answers within the light/dark/action space — never "calculator?"

## 5. Export set (from the one master SVG)

| Asset | Size | Destination |
|---|---|---|
| Adaptive foreground/background | 432×432 px each (108 dp @4x) | Play Console |
| Monochrome layer | 432×432 | Play Console (themed) |
| Play listing icon | 512×512 PNG | Store |
| Full-glow beauty render | 1024×1024 | Press kit, recap-card footer, Discord server icon |
| Notification-scale | 96×96 + 48×48 PNG | In-engine status uses |

All exports scripted once (`inkscape --export-type=png …` loop) so re-branding never involves hand-exporting seven files.

---

*Icon v1.0 — one spark, four points, zero letters. If they can't tell what it is at 48 px, we start over.*
