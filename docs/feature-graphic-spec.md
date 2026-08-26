# AFTERGLOW — Feature Graphic Spec v1.0 (1024×500)

> Companion to `store-listing.md` §1 and `app-icon-spec.md`. The feature graphic is the **billboard above the storefront** — first full-width brand impression, shown before any screenshot.
> **Banner laws:** one idea · silhouette first · wordmark never moves · glow is *baked*, never assumed · survives every crop Google throws at it.

---

## 1. Hard constraints (what Play does to it)

| Constraint | Consequence for design |
|---|---|
| Canvas 1024×500 PNG/JPEG (≤15 MB; we target ≤1 MB) | Design at exact size, author vectors at 1:1 px |
| Some surfaces center-crop to ~16:9 | **Critical-safe band = x 68–956** (888 px wide centered). Outer 68 px each side is bleed only |
| Promo video attached → translucent ▶ button renders at dead center (512, 250) | Keep the center corridor low-detail — see composition |
| Sits on Play's **white** listing page | Dark edges are an advantage; verify no glow bleeds past canvas edge |
| Search-result thumbnails (~156×76 effective) | Squint test governs element count |
| Google recompresses aggressively | Baked-glow recipe (§5), gradient dithering, JPEG-q70 roundtrip gate |

## 2. Concept options

### A — "The Spark and the Tide" ★ recommended
The icon's spark, grown up: left side holds the four-point cyan spark over a lit streetlamp horizon; right side a rising tide of shade silhouettes with magenta eye-glows recedes into depth. Between them, empty dark — the confrontation gap. Wordmark bottom-left. One glance reads the entire pitch: *one bright thing vs everything.*

### B — "Wordmark Is the Hero"
AFTERGLOW set huge across the canvas with a light-sweep through the letters and a tiny gameplay silhouette below. Safe, but generic — could banner any neon game. Fails uniqueness law.

### C — Key-art collage
Devourer looming + character + particles + logo lockup. Max drama, but 6+ elements turns to mud at thumbnail size and fights the play-button chrome.

**Decision:** A ships. B/C archived.

## 3. Composition grid

| Element | Position / geometry |
|---|---|
| Background | Diagonal gradient `#131832` (upper-right) → `#0B0E1A` (lower-left); faint parallax city silhouette along bottom at 8% alpha (reuses recap-card ambient layer); hairline grid strokes `#151B33` at 12% alpha |
| **Spark** | Icon geometry reused verbatim (same SVG symbol, 1.45:1 spikes). Center (295, 195), height 200 px (40% of canvas). White core, crisp `#00F0FF` body, baked glow stack |
| Light pool | Soft ellipse under spark: `#00F0FF` @ 10% alpha additive, 360×90 px at y≈330 |
| Lamp horizon | Row of 9 tiny amber points (`#FFB800`, Ø4–6 px, varying alpha 40–100%) along y=392 from x≈180→620 — the lamps that stayed; fades out toward the tide |
| **Shade tide** | Indigo silhouette mass (`#1E2440` bodies) entering from right edge, spanning x 620→1024, crest peaking at y≈120. Three visible eye-glows (`#FF2E88`): Ø56 px at (760, 185), Ø30 px at (878, 262), Ø16 px at (700, 318) — size = depth |
| Tide rim | 2 px `#FF2E88` @ 35% alpha along the crest edge only — threat accent without a wall of pink |
| **Confrontation corridor** | x 430–620 kept deliberately near-empty (gradient only). The promo-video ▶ chrome lands here and floats in narrative negative space instead of covering content |
| Wordmark block | Anchored x=72, baseline y≈420 (inside critical-safe band) |

Element count at thumbnail distance: spark, tide mass, wordmark. Three. That's the whole read.

## 4. Palette use (locked §10.1, budgeted)

| Color | Share | Where |
|---|---|---|
| `#0B0E1A` / `#131832` / `#151B33` | ~70% | Background gradient, grid, city silhouette |
| Desaturated indigo `#1E2440` | ~12% | Shade-tide bodies |
| `#00F0FF` cyan | ~8% | Spark body+glow, tagline |
| `#FF2E88` magenta | ~6% | Eye-glows, crest rim |
| `#FFB800` amber | <2% | Lamp horizon row |
| `#FFFFFF` | accents only | Spark core, wordmark fill |

Brightness law intact: brightest elements (spark, white core) are safe/valuable; darkest mass is the threat. Amber stays rare so the victory color keeps its value.

## 5. Text treatment

| Element | Spec |
|---|---|
| Wordmark `AFTERGLOW` | Chakra Petch Bold, 128 px caps, tracking +10%, white fill, baked cyan under-glow. **The "O" in GLOW is drawn as the four-point spark glyph** (icon continuity). If it fails the squint test → fallback plain O, decided by §8 |
| Tagline `OUTSHINE THE DARK.` | Rajdhani SemiBold, 34 px caps, tracking +14%, `#00F0FF`, baseline y≈462 |
| Forbidden | Drop shadows, outlines, gradients inside letterforms, more than two text elements, exclamation marks (voice law) |

Contrast floor: both text/bg pairs ≥ 4.5:1 against `#0B0E1A`. Kerning pass on "AF" pair; tabular spacing not needed (static string).

## 6. Glow & production recipe ($0 toolchain)

Same baked approach as recap card + icon — no assumed bloom survives Google:

1. Master SVG in Inkscape (spark imported as the *same symbol file* as the icon — rebrand once, everywhere updates)
2. Shade mass painted in Krita, imported as raster; eyes + crest rim as vectors
3. Baked glow per glowing element: duplicate → gaussian σ=14 px @ 40% alpha additive under crisp pass (σ=28 @ 20% for the spark's outer halo)
4. Gradient dithering: 1% monochrome noise over background gradient to prevent compression banding
5. Scripted export like the icon: PNG-24 target ≤1 MB; if over, JPEG q88 (never below q85 — glow smears)

**Textless master export:** same composition minus wordmark/tagline, kept in the repo for localized banners when store-listing localization phases land (`localization-kit.md`) — baked EN text must never be the thing that blocks DE/PT-BR listings.

## 7. Seasonal variants

Layout grid, wordmark, tagline, and spark are **locked forever**. Variants swap designated layers only — a variant is a ~2-hour job, not a redesign.

| Variant | Slot (LiveOps calendar) | Layer swaps |
|---|---|---|
| **First Light** (base) | Launch | As specced above |
| **Wick** | M3 character drop | Second small flame-spark joins at (390, 260); lamp row brightens; +warm cast on light pool |
| **Moth** | M6 character drop | Small moth silhouette drifts in corridor top (y≈80 — clear of ▶ zone); one eye-glow shifts violet `#B44DFF` |
| **Anniversary Gold** | M9 Blackout 🎂 | Victory treatment: background floods toward white-gold bloom, wordmark gradient white→`#FFE29A` (recap-card victory rules), lamp row at full brightness |
| **Longest Night / Lumen** | M11–M12 | Composition mirrored — light right, dark left; mirror-silver `#DDE6FF` accent on spark halo |

Cadence law: max **3 variant swaps per year** post-launch. The banner is a conversion baseline — churn it more often and store experiments lose their control. Each swap gets its own listing-experiment window before going default.

## 8. Acceptance gauntlet

- [ ] **Squint test:** rendered at 156×76 — spark, dark mass, wordmark all resolve
- [ ] **16:9 crop check:** nothing critical outside x 68–956; cropped render still balanced
- [ ] **▶-chrome mock:** Ø120 translucent triangle at (512, 250) overlaid — covers only corridor emptiness
- [ ] **White-page contrast:** graphic edges clean against Play's white listing bg, zero glow spill past canvas
- [ ] **JPEG q70 roundtrip:** no banding in gradient, eyes still crisp (dither passes if not)
- [ ] **50% zoom:** tagline legible at 512×250 render
- [ ] **Icon continuity:** spark is byte-identical geometry to `app-icon-spec.md` master symbol
- [ ] **Textless master exported** and stored beside the branded one

---

*Feature graphic v1.0 — the whale approved the framing: "I'm the big one on the right. Correct."*
