# AFTERGLOW — Character Bios v1.0

> Companion to §8.2 (Meta Progression). Three playable sparks at launch. All numbers live in data files (`.tres`) — this doc is the *intent*; tables are the truth.
> **Lore frame:** when the city went dark, its light didn't die — it shattered. Every playable spark is a surviving fragment of the old grid, still stubbornly glowing.

---

## Shared rules

- **Baseline = Spark.** All stat deltas below are relative to Spark (HP 100 · Speed 100% · Damage 100% · Pickup radius 100%).
- **Dodge:** all characters unlock the dodge (right-thumb ability) at account level 5 — except Volt, whose entire identity is dodging (see below).
- **Cosmetics are earned only** (play + rewarded ads) — the pay-to-win ban applies triple here.
- **Difficulty ratings** guide player choice honestly: ★ = welcoming, ★★★ = mastery required.

---

## SPARK — "The Last Streetlamp"
**Role: Balanced** · Difficulty ★☆☆ · Unlock: default (playable immediately)

### Identity

| Field | Value |
|---|---|
| Origin | A promenade streetlamp that stayed lit through the whole blackout |
| Personality | Steady, quietly brave, faintly dad-joke-prone |
| Vibe | The friend who says "we've got this" and is annoyingly right |

### Playstyle

| Stat | Value |
|---|---|
| HP | 100 |
| Damage / Speed / Pickup | 100% / 100% / 100% |
| Starting weapon | **Pulse Bolt** |
| Signature trait | **Second Wind** — once per run, surviving lethal damage leaves you at 1 HP with 1s invulnerability (built-in comeback moment) |

Recommended for first-run players; every archetype (orbit-tank, laser-sniper, nova-kiter…) works cleanly on Spark. The tutorial micro-run stars Spark by design.

**Unlock quote:** *"Someone left the light on. Turns out it was me."*
**Results quips:** "Still here." · "Another night, another dawn-ish."
**Death-line affinity:** pairs with H-pool idle deaths ("You stood still. The dark noticed.") — ironic, since Spark never does.

### Cosmetic line — *Filament*
Trails: `Clean Cyan` (default) · `Helix` (double-helix ribbon) · `Twin Flames` (referral exclusive, §15.7) · `Dawnshift` (season reward).
Death effect: `Power Fade` — light dims like a dying bulb, then flickers back once. Hopeful even in defeat.

---

## EMBER — "The Furnace's Temper"
**Role: AoE glass cannon** · Difficulty ★★☆ · Unlock: ~600 Shards (≈6–8 runs)

### Identity

| Field | Value |
|---|---|
| Origin | The last spark from the Undercity foundry furnaces — where the dark first won |
| Personality | Runs hot, jokes hotter, dies gloriously; treats HP as a spending budget |
| Vibe | "DPS is a lifestyle." |

### Playstyle

| Stat | Value |
|---|---|
| HP | 75 (−25%) |
| Damage | +25% · Area size +20% |
| Speed / Pickup | 95% / 100% |
| Starting weapon | **Nova Burst** |
| Signature trait | **Wildfire** — enemies killed inside your area effects have a 12% chance to chain-explode (small radial pop, can cascade) |

Glass cannon math: clears crowds faster than anyone, forgives nothing. Pairs naturally with Singularity (pull everything in, delete everything pulled). Ember players die more often and share more recap cards — by design, they're the marketing department.

**Unlock quote:** *"The dark took my city. I'm taking the temperature."*
**Results quips:** "Controlled burn." · "Everything's flammable if you commit."
**Death-line affinity:** J-pool greed deaths ("Greed: 1. Survival instinct: 0.") were practically written about Ember players.

### Cosmetic line — *Cinder*
Trails: `Ember Fall` (drifting sparks) · `Heat Haze` (refraction shimmer) · `Backdraft` (trail flares on kills).
Aura colors: molten orange / magenta variants. Death effect: `Ashes to Ashes` — burst into rising embers that spell out a tiny "ok bye."

---

## VOLT — "The Live Wire"
**Role: Speed + dash** · Difficulty ★★★ · Unlock: ~1200 Shards (the tease from D0, §13)

### Identity

| Field | Value |
|---|---|
| Origin | A surge fragment from the Spire's old transit grid — the thing that made the trams run on time |
| Personality | Impatient, cocky, weirdly wise once per season; allergic to standing still |
| Vibe | "Standing still is a decision, and it's the wrong one." |

### Playstyle

| Stat | Value |
|---|---|
| HP | 90 |
| Speed | +15% · Pickup radius +25% (you zoom *to* the gems) |
| Damage | 95% (−5%) |
| Starting weapon | **Chain Arc** (lightning jumps while you sprint — thematic harmony) |
| Signature trait | **Live Wire dash** — dash from unlock (no level-5 gate); 6s cooldown, i-frames during dash, damages (+stuns 0.5s) enemies passed through |

Volt changes how the game *feels*: less kiting wall, more flowing current. Mastery ceiling is the highest in the game — dash-through-dash-through level-up-card timing is the community clip waiting to happen.

**Unlock quote:** *"Catch me. …You won't."*
**Results quips:** "Wire me the winnings." · "Average pace: unreasonable."
**Death-line affinity:** I-pool near-misses hit hardest here — Volt players lose by inches and post about it.

### Cosmetic line — *Current*
Trails: `Ghost Current` (afterimage echoes) · `Arc Runner` (mini-bolts) · `Overtone` (rainbow shift at top speed).
Dash effect skins: `Crackle`, `Sonic Boom`, season-exclusive `Transit Pass` (leaves a fading tram-line). Death effect: `Brownout` — lights stutter across the whole screen for one frame. Rude, memorable, very Volt.

---

## Tuning hooks (for balance passes)

All values above map to these `.tres` fields — tune weekly against beta telemetry, never touch this doc's numbers without updating both:

```
character_spark.tres : hp=100, dmg_mult=1.00, speed_mult=1.00, pickup_mult=1.00,
                       trait="second_wind", charges=1
character_ember.tres : hp=75, dmg_mult=1.25, area_mult=1.20, speed_mult=0.95,
                       trait="wildfire", proc_chance=0.12
character_volt.tres  : hp=90, dmg_mult=0.95, speed_mult=1.15, pickup_mult=1.25,
                       trait="live_wire_dash", cooldown=6.0, stun=0.5
```

Balance-law reminder: buffs land loud (patch-note drama is content), nerfs land quiet-with-reasons (§4.3 Discord ritual).

## Where bios get used

- Store listing & press kit: one-line versions ("Play a streetlamp with a hero complex")
- TikTok character-spotlight weeks (calendar, P2 weeks 13–14): bio voiceover + 15s gameplay — full shot-by-shot scripts: **`tiktok-character-spotlights.md`**
- In-game: unlock quotes on the character-select splash, quips on results screen, cosmetic names verbatim
- Recap cards: character portrait medallion + trail color pull from these definitions

---

*Character bios v1.0 — three sparks, one grid, zero pay-to-win.*
