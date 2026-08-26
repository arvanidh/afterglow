# AFTERGLOW — Game Design & Development Document

> **Platform:** Android (phones & tablets) · **Genre:** Arena survival roguelite ("survivors-like")
> **Version:** 1.1 · **Date:** August 25, 2026 · **Status:** Approved concept — ready for prototyping
> **Budget constraint:** 100% free development stack (see §14.6) · **Revenue model:** Advertising-first

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Market Research & Positioning](#2-market-research--positioning)
3. [Target Audience & Personas](#3-target-audience--personas)
4. [High Concept & Design Pillars](#4-high-concept--design-pillars)
5. [Core Gameplay Loop & Combat](#5-core-gameplay-loop--combat)
6. [Mobile Controls & UX](#6-mobile-controls--ux)
7. [Enemies, Bosses & Game Feel](#7-enemies-bosses--game-feel)
8. [Progression: In-Run Builds + Meta Progression](#8-progression-in-run-builds--meta-progression)
9. [World, Arenas & Level Design](#9-world-arenas--level-design)
10. [Art Direction & Graphics Technology](#10-art-direction--graphics-technology)
11. [Audio Direction](#11-audio-direction)
12. [Technical Architecture](#12-technical-architecture)
13. [Onboarding & Retention Design](#13-onboarding--retention-design)
14. [Monetization: Advertising Strategy, IAP & LiveOps](#14-monetization-advertising-strategy-iap--liveops)
15. [Viral & Community Features](#15-viral--community-features)
16. [Analytics & KPIs](#16-analytics--kpis)
17. [Production Roadmap](#17-production-roadmap)
18. [QA & Device Testing Plan](#18-qa--device-testing-plan)
19. [Launch & Marketing Checklist](#19-launch--marketing-checklist)
20. [Risks & Mitigations](#20-risks--mitigations)
21. [References](#21-references)

---

## 1. Executive Summary

**AFTERGLOW** ("Outshine the dark") is a free-to-play Android arena survival roguelite. The player is the last spark of light in an abandoned neon city, holding out against endless swarms of shadow creatures. Runs last **5–10 minutes**, controls use **one thumb**, and weapons fire automatically — the player only moves, dodges, and chooses upgrades.

**Why this game, why now:**

- The survivors-like / arcade roguelite space is one of the fastest-growing casual categories going into 2026, driven by hybrid-casual games that pair instant-play simplicity with deeper meta loops.
- Short sessions match real mobile behavior (commutes, breaks) and stay inside modern devices' ~15-minute thermal comfort zones.
- The neon-on-dark art direction produces **premium-looking graphics from cheap-to-render techniques** (bloom, additive particles, dynamic 2D lighting), so the game looks great even on mid-range hardware.
- Revenue comes from **player-friendly advertising** (rewarded video as the hero format), integrated through a completely free stack — AdMob with mediation — requiring zero upfront spend.
- Built in **Godot 4** (MIT license, free), designed **offline-first** so there is **no server hosting cost, ever**.

**Success definition at launch (+6 months):** 100k installs, D1 retention ≥ 35%, crash-free sessions ≥ 99.5%, ad ARPDAU ≥ $0.03 blended.

---

## 2. Market Research & Positioning

### 2.1 What the 2026 data says

| Signal | Finding | Implication for AFTERGLOW |
|---|---|---|
| Downloads | Puzzle and adventure lead download charts; arcade shows strong YoY download growth | Arcade action with puzzle-simple inputs fits the biggest funnel |
| Revenue | Strategy, puzzle, RPG dominate revenue; mid-core meta systems drive LTV | Add depth via meta progression, not complexity |
| Trend | Hybrid-casual = simple core + deep meta + live events is *the* dominant model | Simple one-thumb combat + layered progression |
| Hardware | ~15-minute thermal ceilings on flagship chips shape session design | 5–10 minute runs, capped particle load |
| Retention | Median D1 across 11,600+ games ≈ 22%; top quartile much higher | Onboarding is the #1 lever (see §13) |
| Monetization | Rewarded video is the highest-acceptance format; hybrid models win | Ads-first design with generous rewards |

### 2.2 Competitive set

| Game | What it proves | Our differentiation |
|---|---|---|
| Vampire Survivors | Horde-loop is addictive at near-zero control complexity | Better visual identity (neon glow), mobile-native UX |
| Brotato | Short runs + build variety = huge replayability | More atmospheric world, boss spectacle |
| Survivor.io | Massive mainstream appetite on mobile for the genre | Player-friendly ads, premium art feel at casual scale |

### 2.3 Positioning statement

> For casual players who want a visually striking action game they can pick up for five minutes, AFTERGLOW is a neon survival roguelite that delivers a power-fantasy rush every run — respectful of their time, their battery, and their attention (no forced interruptions, ever).

---

## 3. Target Audience & Personas

**Primary:** Casual players 16–34, Android-dominant markets, session lengths of 3–10 minutes, comfortable with virtual joysticks, ad-tolerant when rewards are fair.

**Secondary:** Lapsed roguelite fans who loved PC hits but want a pocket version.

### Personas

- **Priya, 24 — commuter.** Plays during 20-minute bus rides. Wants instant fun, no tutorials walls, no login. Quits any game that interrupts gameplay with ads.
- **Marcus, 31 — lapsed hardcore.** Owned every roguelite on Steam, now has 15 spare minutes a day. Chases optimal builds and leaderboard ranks. Will watch rewarded ads deliberately for progression boosts.
- **Leo, 16 — social player.** Shares flashy clips. Buys nothing, but his screenshots and TikToks are our marketing. Loves unlockable cosmetic flair he can earn by playing.

---

## 4. High Concept & Design Pillars

### High concept

> You are the last spark of light in a city swallowed by dark. Survive the swarm. Grow blindingly powerful. Outshine the dark — before it outlasts you.

### Design pillars

1. **One thumb, total control.** Every run is playable one-handed, on any screen size, standing on a bus.
2. **Visible power every 45 seconds.** Level-up choices land constantly; every choice changes how the screen looks and feels.
3. **Beautiful is cheap.** Glow, particles, and shake — not expensive geometry — carry the look. 60fps is a feature.
4. **Respect the player.** No energy timers, no mid-combat interstitials, no paywalls. Fair rewarded ads only.
5. **One more run.** Death always teaches something and always pays out progress toward the next unlock.

---

## 5. Core Gameplay Loop & Combat

### 5.1 Loop diagram (three nested loops)

```
SECONDS:   Move/dodge → auto-weapons fire → enemies pop into light motes → XP gems drop
MINUTES:   Collect XP → level up → pick 1 of 3 upgrades → build synergies → survive wave escalation
SESSIONS:  Earn Shards → permanent upgrades → new characters/weapons/biomes → harder difficulty tiers
```

### 5.2 Run structure (default ~8 minutes)

| Minute | Beat |
|---|---|
| 0–1 | Gentle spawn ramp; movement tutorial implicit |
| 1–3 | First elite; weapon evolution teaser |
| 3–5 | Spawn pressure doubles; first mini-boss (mini-boss every ~2.5 min) |
| 5–7 | Screen fills; build peaks; crowd-clearing fantasy |
| 7–8 | **Boss:** THE DEVOURER. Kill = victory payout; die = standard payout |

### 5.3 Combat rules

- **Auto-fire:** weapons target automatically (nearest / pattern-based). Player skill = positioning, spacing, and build decisions.
- **XP magnets** vacuum gems when close; pickup radius is a stat.
- **Chests & crates** drop weapon-evolution components; opening a chest plays the game's signature reward moment (light burst, rarity color, haptic thump).
- **Hit-stop** (40–70 ms) on kills above Elite tier; **screen shake** scaled by threat, never nausea-inducing.

### 5.4 Weapons (launch set — 6)

| Weapon | Behavior | Evolution |
|---|---|---|
| Pulse Bolt | Fires at nearest enemy | Prism Lance (pierces, chains) |
| Orbit Blades | Rotating melee satellites | Halo Storm (speed × count) |
| Chain Arc | Lightning jumps between enemies | Tempest Crown |
| Nova Burst | Periodic radial shockwave | Singularity (pulls enemies in) |
| Rail Line | Sweeping laser lane | Dawn Beam (persistent) |
| Wisp Drone | Companion fires independently | Choir (3 drones) |

Each weapon has 5 levels; pairing specific weapon + passive at max unlocks its **Evolution** (build-crafting payoff).

---

## 6. Mobile Controls & UX

- **Movement:** left-half floating joystick (appears wherever the thumb lands). Optional fixed-stick mode in settings.
- **Right thumb does nothing by default** — reserved for future dodge ability (unlockable at account level 5, teaches advanced play gradually).
- **Pause:** top-right, always available; pausing also opens the build summary.
- **Safe areas:** all HUD respects notch/cutout insets.
- **Haptics:** light tick on level-up, medium on chest, heavy on boss spawn. Global toggle.
- **Reachability audit:** every menu element within bottom 75% of screen; nothing critical in corners.
- **Accessibility:** colorblind-safe enemy telegraphs (shape-coded, not just hue), font scaling 100–130%, left-handed mode. ♿ Full pass plan — palettes, control alternatives, motion reduction, ship-gate checklist: **`docs/accessibility-pass.md`**.

> ⚙️ Every settings toggle specced (keys, defaults, tab layout): **`docs/settings-menu-spec.md`**.

---

## 7. Enemies, Bosses & Game Feel

### 7.1 Enemy roster (launch)

| Enemy | Role | Telegraph |
|---|---|---|
| Shade | Basic chaser | None — baseline pressure |
| Swarmlet | Fast, weak, spawns in packs | Flocking shimmer |
| Spitter | Ranged lobber | Wind-up glow + landing zone decal |
| Splitter | Splits into two Swarmlets on death | Cracked shell visual |
| Bulwark | Slow tank, blocks lanes | Hardened outline |
| Wraith | Dashes at player | Crouch-flash before dash |
| **Elite variants** | Any enemy + modifier (Shielded, Frenzied, Vampiric) | Colored aura + name tag |

All enemies are **shadow-silhouette shapes with glowing eyes** — cheap to draw, infinitely re-colorable, perfectly readable against the bright player.

### 7.2 Bosses (launch — 3)

1. **THE DEVOURER** (biome 1) — giant shadow-whale; sweeps lanes, spits homing orbs. Weak points glow after slam attacks.
2. **THE CHOIR** (biome 2) — three linked cores; destroy in any order, survivors enrage.
3. **NULL PRIME** (biome 3) — mirrors the player's own build; the thematic finale ("fight your reflection").

> 🗡️ Full boss design sheets — phases, attack tables, telegraphs, tuning files, QA gates: **`docs/boss-design-sheets.md`**.

### 7.3 Game feel spec ("the juice list")

Every kill: particle burst in victim color + XP gem pop + subtle controller/haptic pulse.
Level-up: time slows 0.3s, radial flash, card slide-in with rarity glow.
Boss entrance: screen dims, vignette closes, name card slams in, bass drop.
Damage to player: red vignette pulse + heavy haptic + brief chromatic aberration.
These effects are specified as **required acceptance criteria**, not polish wishes — juice is the product.

---

## 8. Progression: In-Run Builds + Meta Progression

### 8.1 In-run (per 8-minute run)

- XP → level-up cards (choose 1 of 3; reroll 1× free, extra rerolls via rewarded ad).
- Weapon slots: 4 max · Passive slots: 4 max → forces meaningful choices.
- Build archetypes to enable: orbit-tank, lightning-conductor, laser-sniper, drone-carrier, nova-kiter.

### 8.2 Meta (between runs)

| System | Currency | Detail |
|---|---|---|
| Permanent Upgrade Grid | **Shards** (from every run, win or lose) | ~25 nodes: HP, damage, magnet, luck, revive… |
| Characters | Shards | 3 at launch: **Spark** (balanced), **Ember** (AoE glass cannon), **Volt** (speed + dash) |
| Difficulty Tiers | Unlocked by winning | Tier N = +enemy stats, ×Shard multiplier — the "replayability engine" |
| Daily Missions | Shards + Cores | 3 rotating dailies → reason to return tomorrow |
| Cosmetics | Earned only (play + rewarded ads) | Trails, aura colors, death effects — Leo-bait, zero pay-to-win |

**Cores** (rare currency for cosmetics/rerolls) are earnable exclusively through play and rewarded ads — never sold. This keeps the game 100% fair while giving ads a desirable sink.

> 🎭 Full bios — lore, stat deltas, signature traits, unlock quotes, cosmetic lines: **`docs/character-bios.md`**.

### 8.3 Session math (design targets)

First unlock lands within **run #2**, second character within **~6 runs**, first Evolution witnessed within **~4 runs**. Payout pacing beats grind frustration — early generosity drives D1/D7.

---

## 9. World, Arenas & Level Design

Three launch biomes, each an abandoned district of the neon city:

1. **The Promenade** — cyan/teal palette, open plaza arenas, forgiving sightlines. Teaches.
2. **The Undercity** — magenta/violet, tighter corridors, hazard pools (dark zones that slow the player's light).
3. **The Spire** — white-gold palette, vertical parallax drama, fastest spawns. Prestige biome.

**Arena structure:** hand-authored 2–3 screen-wide maps with procedural spawn direction logic (never true random — spawns always telegraph off-screen 0.5s ahead with directional glow). Destructible neon signage drops pickups occasionally — environmental storytelling + reward bait.

> 📜 The blackout's full story is collectible: 20 lore fragments across the three biomes in **`docs/lore-fragments.md`**.

**Difficulty curve:** per-biome spawn budget curves defined in data tables (tunable without code), reviewed weekly during beta against heatmaps of player deaths.

---

## 10. Art Direction & Graphics Technology

### 10.1 Style guide

- **Look:** flat geometric silhouettes + emissive neon edges on deep-dark backgrounds. Think *Tron × Geometry Wars × cozy gloom*.
- **Palette (locked):**

| Role | Color |
|---|---|
| Background base | `#0B0E1A` deep navy-black |
| Grid/structure | `#151B33` |
| Player / friendly | `#00F0FF` cyan |
| Enemies | desaturated indigo bodies + colored eye-glow by type |
| Danger | `#FF2E88` magenta |
| Reward / rare | `#FFB800` amber |
| Victory | white-gold bloom flood |

- **Readability rule:** brightness encodes allegiance — brightest things are always safe or valuable; darkest things are threats. New artists can't break this rule because it's enforced in the palette template.

### 10.2 Graphics tech (how "good graphics" is achieved cheap)

| Technique | Implementation | Why it looks premium |
|---|---|---|
| Bloom/glow | Godot `WorldEnvironment` glow (HDR threshold) | Every emissive edge halos — instant production value |
| Additive particles | GPUParticles2D, additive blend, soft-dot texture | Kills feel like fireworks |
| Dynamic 2D lights | `PointLight2D` attached to projectiles/pickups | Scene breathes and reacts |
| Parallax | 3–4 scrolling city layers w/ slow drift | Depth on a 2D budget |
| Screen-space juice | Shake, hit-stop, zoom pulses, vignette | Perceived impact ↑↑ |
| Shader flourishes | Dissolve-to-motes enemy deaths; heat-haze on lasers | Signature moments |

### 10.3 Performance budget (non-negotiable)

- **Target:** 60 fps sustained on mid-range (e.g., Snapdragon 4xx/Adreno 610 class); ≥30 fps on low-end with auto quality preset.
- **Overdraw control:** particle fill ≤ 30% of screen concurrently; glow limited to 2 blur passes; no full-screen transparent stacks > 3 layers.
- **Quality presets:** Auto-detected at first boot (Low/Medium/High). Low disables glow & reduces particles 50% — game remains readable and pretty.
- **Thermals:** particle caps + optional 30 fps mode prevent throttling past ~12 min of continuous play.
- **Size:** APK ≤ 45 MB (asset compression, WebP textures, Ogg Vorbis audio).

### 10.4 Asset pipeline (free tools only)

Vector shapes authored in **Inkscape**, painted textures in **Krita/GIMP**, sprite sheets packed in Godot's built-in atlas, pixel-art needs (icons) in **Pixelorama/Libresprite**. All open-source, all $0.

---

## 11. Audio Direction

- **Music:** dark synthwave arpeggios, 90–110 BPM, sidechained pads; intensity layers add with threat level (vertical layering: calm base + percussion layer at elite + lead layer at boss). Composed in **LMMS** (free) or licensed CC0 packs (Juhani Junkala et al.).
- **SFX:** soft "pop" kills (sine blip + noise burst), satisfying chest choir stab, bass-heavy boss roars. Authored in **jsfxr/Audacity** (free).
- **Mix rules:** SFX duck music −3 dB momentarily on big moments; master limiter on; separate music/SFX volume sliders.
- **Silence as a tool:** pre-boss moment drops to near-silence for 1 beat before the drop — cheap drama.

---

## 12. Technical Architecture

### 12.1 Engine decision

| Criterion | Godot 4.x ✅ | Unity 6 (alternative) |
|---|---|---|
| License cost | **MIT — $0 forever** | Free under revenue threshold, terms have shifted historically |
| 2D renderer | Best-in-class, purpose-built | Good, 3D-first legacy |
| APK size | ~30 MB base | ~2–3× larger |
| Iteration speed | Instant scene reload, GDScript | Slower domain reloads |
| Ad SDK support | Via maintained community plugin (Poing Studios AdMob) or thin native wrapper | First-party SDKs |
| Asset Store depth | Smaller | Much larger |
| Team hiring pool | Smaller | Larger |

**Decision: Godot 4.x (GDScript)** — zero license risk, ideal 2D performance, tiny builds, and the project's scope (no console ports, no complex 3D) doesn't miss Unity's advantages. Revisit only if multiplayer/3D enters scope.

### 12.2 Project structure (Godot)

```
afterglow/
├── autoload/        # GameState, RunState, SaveSystem, AdsManager, Analytics, Audio
├── scenes/
│   ├── actors/      # player.tscn, enemy_base.tscn (+ inherited variants), boss_*
│   ├── weapons/     # weapon_base.tscn + per-weapon scenes (data-driven)
│   ├── ui/          # hud, levelup_cards, menus, settings
│   └── arenas/      # biome scenes + spawner configs
├── resources/       # .tres data: weapons, upgrades, enemies, missions, quality presets
└── assets/          # sprites (WebP), fonts (OFL), audio (ogg), shaders (.gdshader)
```

**Data-driven rule:** all balance numbers live in `.tres` resource files — designers tune without touching code. Enemy waves, spawn budgets, upgrade pools: all tables.

### 12.3 Systems

- **SaveSystem:** local JSON in `user://`, atomic writes, schema-versioned migrations; optional cloud sync via **Google Play Games Services Saved Games** (free, no backend).
- **GameState machine:** BOOT → MENU → RUN → LEVELUP(pause-tree) → RESULTS → META.
- **Object pooling:** enemies, projectiles, gems, damage numbers — zero runtime instantiation during waves.
- **AdsManager abstraction:** single interface (`show_rewarded(placement, callback)`), implementation swappable — protects us if the Godot plugin landscape shifts.
- **Determinism-lite:** seeded RNG for spawns enables future daily-seed challenge runs.

### 12.4 Platform targets & requirements

- **OS:** Android 8.0+ (API 26+) — covers ~97% of active devices.
- **Renderer:** Vulkan with GLES3 compatibility fallback (Godot's forward-mobile profile tuned for tile-based GPUs).
- **Devices:** phone + tablet layouts verified; foldables get centered-letterbox mode.
- **Permissions:** INTERNET (ads/analytics) only. Nothing else — trust is a feature.
- **Offline-first:** the full game is playable offline; ads/analytics/leaderboards degrade silently.
- **Localization:** EN at global launch; phased L1–L3 plan, string budgets & transcreation glossary in **`docs/localization-kit.md`**.

### 12.5 Zero-server architecture (why hosting costs $0/month)

No accounts, no matchmaking, no realtime anything. Social features ride free platform services:
- Leaderboards & achievements → **Google Play Games Services** (free).
- Cloud saves → **Play Games Saved Games** (free).
- Remote config / feature flags → **Firebase Remote Config** free tier (Spark plan).
If online features are ever added later, free tiers (Supabase / Cloudflare Workers) are documented as the path — but v1 ships with **$0 recurring infrastructure**.

> 🔧 Account-by-account setup walkthroughs, one service at a time (GitHub → Firebase → AdMob → …): **`docs/services-setup-guide.md`**.

---

## 13. Onboarding & Retention Design

### Onboarding (the #1 metric lever — median D1 is only ~22%)

- Cold install → firing at shadows in **under 15 seconds**: title splash → tap → run starts. No logo spam, no permission asks, no account anything.
- First run is a scripted micro-run (90 seconds, unlosevable) that secretly teaches: move → collect → level-up choice → chest moment → victory fanfare.
- Contextual teaching only: joystick hint fades on first movement; upgrade cards explain themselves in 5 words + icon.
- First rewarded ad is **offered, never forced**: "Double your Shards?" with clear value framing. Acceptance here predicts LTV — instrument it.

> 🧪 Onboarding experiments get run, not guessed — full A/B plan (test backlog, statistics rules, rollout policy): **`docs/onboarding-ab-plan.md`**.

### Retention systems mapped to days

| Day | Hook |
|---|---|
| D0 | Second-character tease at results screen ("Volt unlocks in 4 runs") |
| D1 | Daily mission #1 trivially completable → guaranteed Shard payout |
| D3 | Biome 2 unlock chase + first Evolution achievable |
| D7 | Weekly challenge seed (fixed layout, friend-beatable score) |
| D14+ | Difficulty tiers + cosmetic collection + leaderboard rank seasons |

**Notification policy:** max 1/day, only for streaks the player opted into. Respectful by design — churned players who mute us don't come back.

---

## 14. Monetization: Advertising Strategy, IAP & LiveOps

> **Design law:** monetization never touches gameplay fairness. Power comes from play; ads accelerate *choice*, never gate *access*.

### 14.1 Ad formats & placements

| Format | Placement | Frequency/rules |
|---|---|---|
| **Rewarded video** ★ hero | ① Revive on death (once/run) ② Double run Shards ③ Bonus reroll in level-up ④ Free Core gift in shop ⑤ 2× daily-mission reward | Always opt-in, always same-value, skippable reward preview |
| Interstitial | Results → menu transition only | Max 1 per 3 runs, never after a boss victory (protect the high moment), never before run 3, hard 90s minimum gap |
| Banner | Shop/settings screens only (never gameplay, never results) | Adaptive banner, dismissible region respected |
| App-open | None at launch (hostile to goodwill); revisit only with data | — |

### 14.2 Ad stack (2026 landscape, all free to integrate)

- **Foundation:** Google **AdMob** — largest Android demand, free account, eCPM floors.
- **Mediation (phase 2, week 2+ post-launch):** AdMob Mediation or **AppLovin MAX**/**Unity LevelPlay** with in-app bidding — comparison table below. Mediation lifts eCPM 15–40% via auction pressure.
- **Testing:** Google sample ad unit IDs throughout development; never click live ads in own builds.

| Mediation option | Strengths | Watch-outs |
|---|---|---|
| AdMob Mediation | One SDK, tight Google integration | Fewer bidders than MAX |
| AppLovin MAX | Strongest bidding, top gaming eCPMs | Heavier SDK, another dashboard |
| Unity LevelPlay | Good Unity ecosystem ties (less relevant for Godot) | Historically ironSource overlap quirks |

**Decision:** launch with AdMob alone (simplicity), add MAX-style mediation once DAU > ~2k makes the lift measurable.

### 14.3 Consent & compliance

- **Google UMP consent flow** (GDPR/UK) before first ad request; EEA users get ad-choice dialogue.
- Personalized ads off by default until consent; non-personalized fallback always available.
- Audience rating **Teen / PEGI 12**; no `DESIGNED_FOR_FAMILIES` program (keeps ad inventory richer and compliance simpler).
- Privacy policy + data-safety form completed honestly (AdMob + analytics disclosures). 🔐 Ready-made policy text and pre-mapped form answers: **`docs/privacy-policy.md`**.

### 14.4 Godot integration path

Maintained open-source **Poing Studios AdMob plugin for Godot 4** behind our `AdsManager` autoload; fallback plan is a 200-line custom Android plugin (documented in §12.2 abstraction). Test-unit IDs in debug builds; CI verifies ad-free paths work when SDK init fails (offline resilience).

### 14.5 Future IAP (post-launch, optional)

Only after ads prove engagement economics: **Remove Ads Forever ($3.99)** — kills interstitials/banners, keeps rewarded (players still choose to earn). Cosmetic packs strictly later, strictly optional. No consumables, no gacha-for-money.

### 14.6 💰 Zero-budget constraint — the complete free stack

> Everything in this project is free/open-source, with **one honest exception flagged below.**

| Need | Tool | Cost |
|---|---|---|
| Game engine | Godot 4.x | $0 (MIT) |
| Code editing | Godot editor / VS Code | $0 |
| Vector art | Inkscape | $0 |
| Paint art | Krita / GIMP | $0 |
| Pixel art/icons | Pixelorama / Libresprite | $0 |
| Music | LMMS + CC0 libraries | $0 |
| SFX | jsfxr + Audacity | $0 |
| Fonts | Google Fonts (OFL) | $0 |
| Source control | Git + GitHub (private repos free) | $0 |
| CI/builds | Local builds; GitHub Actions free minutes | $0 |
| Analytics | GameAnalytics (free) + Firebase Spark tier | $0 |
| Crash reporting | Firebase Crashlytics | $0 |
| Leaderboards/saves | Google Play Games Services | $0 |
| Backend servers | None — offline-first (§12.5) | **$0/month forever** |
| Ad revenue platform | AdMob (pays *us*) | $0 to join |
| Community | Discord (free) / itch.io page (free) | $0 |
| **App store publishing** | Google Play Console | ⚠️ **$25 one-time lifetime fee — the only unavoidable cost.** |
| Free-store alternatives | Direct APK sideload page, **itch.io** (free), Amazon Appstore (free registration) | $0 |

**Hosting conclusion:** because AFTERGLOW is offline-first with platform-provided free services, there is **nothing to host and nothing to pay monthly** — ever.

---

## 15. Viral & Community Features

> **Design law:** virality is engineered, not hoped for — every session ends with something worth sharing, and sharing costs the player exactly one tap. Everything below runs on the $0 offline-first stack (§12.5).

### 15.1 Run Recap Cards ★ hero feature

Every run ends by generating an auto-composed neon stat card:

| Element | Content |
|---|---|
| Headline | Result: "*OUTSHONE THE DARK*" (win) or a meme death cause (§15.3) |
| Stats band | Time survived · Biome reached · Shades purified · Peak level · Score |
| Build strip | Icons of final weapons + evolutions — instantly readable "that build looks cool" |
| Identity | Character portrait, cosmetic trail color, seasonal rank badge |
| Call-to-action | Game logo + **#AFTERGLOW** hashtag |

- **Flow:** Results screen → big **Share** button → card renders → native Android Sharesheet opens with the image attached and a pre-filled caption. One tap from death to someone's group chat.
- **Tech (no server):** card is a Godot `Control` scene rendered off-screen via `SubViewport` → `get_texture().get_image()` → PNG → OS share intent (~200 lines total).
- **Craft rule:** the card must survive WhatsApp/TikTok compression — thick strokes, high contrast, glow baked into the export.

> 🎨 Full visual & rendering spec (1080×1350 grid, typography, color system, Godot `SubViewport` capture pipeline): **`docs/recap-card-spec.md`**.

### 15.2 Daily Seeded Challenge (the Wordle loop)

- **Seed:** derived deterministically from the date (`hash("AGLOW-" + YYYY-MM-DD)`), computed locally — the whole world plays the *same* run with **zero infrastructure**, delivered by §12's determinism-lite design.
- **Daily twist:** rotating constraints keep it fresh ("Volt only", "Chain Arc start", "Undercity at night").
- **Leaderboard:** one board per day via Google Play Games Services (free), friends-first ordering.
- **Streaks:** consecutive completions pay escalating Shard bonuses; one streak-shield per week (forgiveness retains players).
- **Anti-cheat honesty:** without servers we validate heuristically (impossible-score filters, sampled replays) and keep stakes cosmetic. Perfect is the enemy of shipped.

### 15.3 Meme Death Screens

Deaths are content. Every death screen pairs its cause with the recap-card share button.

| Trigger | Death cause copy |
|---|---|
| Boss kill-shot | "Devoured by THE DEVOURER… 2 seconds before your chest opened." |
| Swarm overwhelm | "4,112 shades attended. None sent flowers." |
| Hazard pool | "The Undercity claims another tourist." |
| AFK death | "You stood still. The dark noticed." |
| 99% boss HP | "SO close the Devourer felt your breath. Again?" |

Copy tone: dry, punchy, screenshot-worthy — the Leo persona shares these unprovoked.

> 📚 Full library of **50 categorized death messages** with trigger conditions, weighting rules, and localization notes lives in **`docs/death-messages.md`**.

### 15.4 Instant Replays

- Rolling **12-second buffer**: every 3rd frame captured at 50% resolution during runs (near-nil GPU cost; disabled on Low quality preset).
- After Evolution unlocks, boss kills, and victories the game offers **"Save this moment."**
- Frames encode to animated WebP/GIF in the background on the results screen (never blocking gameplay), then follow the same Sharesheet flow as recap cards.
- Glowing crowd-clearing clips are the game's TikTok unit economics.

### 15.5 Build Codes

- Any run exports as an ~11-character code (`AG-VOLT-7F3K2`): packed bits encoding seed + character + loadout, Base32.
- Paste a code → replay the identical run layout and try to beat that score. Async racing, fully offline.
- Codes travel inside recap cards and messages — distribution is entirely player-carried.

### 15.6 Weekly Seasons & Ranks

- Weekly competitive window (Mon 00:00 UTC): rank badges earned from best daily-challenge percentile.
- Ladder flavor: **Bronze Spark → Cyan Ember → Magenta Flare → Amber Nova → Prism Legend** — cosmetic prestige only, never power.
- Soft decay (last week's best × 0.8 seeds placement) keeps the ladder climbable without grind anxiety.
- Rank badges render onto recap cards → the status chase feeds the share loop.

### 15.7 Referrals

- Invite link resolves to a **free GitHub Pages page** (deep-link explainer + store/itch links); attribution via the Play Install Referrer API.
- Reward: when an invited friend clears their first run, **both** players unlock the exclusive "Twin Flames" linked trail cosmetic.
- No accounts, no backend — attribution rides platform APIs.

### 15.8 Community Goal Events

- **v1 (honest scope):** developer-pushed milestones via Firebase Remote Config (free) — *"The community purified 10,000,000 shades: the Gold Trail unlocks for EVERYONE"* — announced on Discord/socials, redeemed in-client.
- True live global counters need aggregation → documented as a post-launch option on free tiers (e.g., Supabase edge-function counter). Explicitly **not launch scope**; §12.5's zero-server promise stands.

### 15.9 Rollout & measurement

| Feature | Phase |
|---|---|
| Recap cards · Meme deaths · Daily challenge · Seasons (basic) | Launch (built in P2–P4) |
| Instant replays · Build codes · Referrals · Community events | Update 1 (post-launch month 1) |

**New KPI targets (fold into §16):** recap share rate ≥ 8% of runs · daily-challenge participation ≥ 25% of DAU · referred installs ≥ 10% of new installs by month 3.

**Event taxonomy additions:** `recap_shared`, `clip_saved`, `code_copied`, `code_redeemed`, `referral_attributed`, `daily_challenge_complete{streak}`.

---

## 16. Analytics & KPIs

**Stack:** GameAnalytics (free, genre-benchmarked) for design metrics + Firebase Analytics/Crashlytics for funnels/crashes. Both free tiers.

| KPI | Target (top-quartile ambitions) |
|---|---|
| D1 / D7 / D30 retention | 35% / 12% / 5% |
| Median session | 8 min · 1.8 sessions/day |
| FTUE completion (first run finished) | ≥ 85% |
| Rewarded offer acceptance | ≥ 25% of eligible impressions |
| Interstitial opt-out/complaint rate | monitor < 2% |
| Ad ARPDAU (blended geo) | ≥ $0.03 |
| Crash-free sessions | ≥ 99.5% |
| FPS p95 (medium preset) | ≥ 55 |

**Event taxonomy (core 20):** run_start/end, death_cause, levelup_choice{id}, evolution_unlock, boss_outcome, chest_open{rarity}, rewarded_offer/view/complete{placement}, interstitial_shown, session_length bucket, quality_preset, biome_reached, mission_complete, settings_changed. Weekly review ritual: one metric, one experiment.

---

## 17. Production Roadmap

Solo-developer-friendly, part-time-paced; calendar months assume ~15 focused hrs/week.

| Phase | Months | Deliverables | Exit criteria |
|---|---|---|---|
| **P0 Prototype** | M1–M2 | Grey-box core loop: move, 2 weapons, 3 enemies, level-up cards, 1 boss | "Fun for 8 straight minutes with placeholder art" — the honesty gate |
| **P1 Vertical Slice** | M3 | Neon look online (bloom/light/particles), juice pass, 1 polished biome | Slice impresses strangers in 60 seconds |
| **P2 Content Complete** | M4–M5 | 3 biomes, 3 bosses, 6 weapons + evolutions, meta grid, 3 characters, missions + **viral launch set** (recap cards, meme deaths, daily challenge, basic seasons) | Full loop playable start→credits |
| **P3 Money & Measure** | M6 | AdMob live (test units), analytics wired, UMP consent, quality presets | Offline/ad-failure paths bulletproof |
| **P4 Beta** | M7 | Closed beta (itch.io page + Play internal testing), 50–200 testers, telemetry review | D1 ≥ 30% in beta; crash-free ≥ 99% |
| **P5 Soft Launch** | M8 | Public release in 2–3 soft markets (e.g., PH/ID/CA) via Play early access | ARPDAU & retention hold ≥ targets |
| **P6 Global** | M9 | Worldwide launch, LiveOps cadence begins (weekly missions, monthly event seeds) | — |

Post-launch rhythm: monthly content drop (weapon or biome remix) + quarterly character — sustainable for a solo/small team. 📅 Full year-one LiveOps calendar (themes, community goals, seasonal death-message packs): **`docs/liveops-calendar.md`**.

---

## 18. QA & Device Testing Plan

- **Device matrix (minimum):** 2 low-end (2 GB RAM, Android 8/9), 3 mid (4–6 GB), 2 high-end/foldable, 1 tablet. Borrow/community device programs; emulators only for smoke tests (touch ≠ emulator).
- **Automated:** headless scene tests in CI for balance-table integrity (every evolution recipe resolvable, no negative costs), save-schema migration tests, ad-failure simulation (airplane-mode suite).
- **Manual checklists:** notch/safe-area sweep, interruption suite (call/battery-saver/rotate mid-run), thermal soak test (25 min continuous), first-3-minutes fresh-install script recorded on video each sprint.
- **Beta instrumentation:** death heatmaps per biome; rage-click detection on menus; ad latency logging (rewarded show-time p90 < 2.5s or the button feels broken).

---

## 19. Launch & Marketing Checklist

All free channels — the game's look *is* the marketing asset:

- [ ] **Devlog clips** (TikTok/Shorts/Reels): 15-sec kill-fireworks clips — glow aesthetics are algorithm catnip. Posting starts **day one of P0** (grey-box builds included) — full phase-by-phase calendar, series formats & hooks in **`docs/devlog-content-calendar.md`**.
- [ ] **itch.io page** from P1 (free) — wishlists/comments + beta distribution. ✍️ Five-post devlog series (titles, outlines, asks) ready in **`docs/itch-devlog-series.md`**.
- [ ] **Reddit presence:** r/AndroidGaming, r/roguelites, r/godot — process posts, not ads. 📝 Launch-week templates & comment scripts: **`docs/reddit-posts.md`**.
- [ ] **Discord server** at beta — 50 engaged testers beat 500 anonymous ones. 🧭 Full blueprint (channels, roles, bug-triage workflow, launch events): **`docs/discord-server-plan.md`**.
- [ ] **Play Store listing:** 5 screenshots showing *glow + numbers-go-up moments*, 30-sec trailer (edited in free DaVinci Resolve), keyword field researched vs "survivor", "roguelite", "neon". 🏪 Final copy ready in **`docs/store-listing.md`**.
- [ ] **Pre-registration** (if using Play Console) with reward incentive (exclusive trail).
- [ ] **Press kit** one-pager: GIF set, fact sheet, designer quote — free hosting on GitHub Pages. ✍️ Full copy ready in **`docs/press-kit.md`** (taglines, pitches, FAQ, asset checklist, outreach email).
- [ ] Launch-week event: double-Shards weekend, announced in-app + Discord.

---

## 20. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Genre saturation | High | Medium | Differentiate on art identity + boss spectacle + respectful monetization; niche communities first |
| Godot ad-plugin breakage (engine updates) | Medium | Medium | `AdsManager` abstraction isolates SDK; pin engine version per release; native-wrapper fallback documented |
| Solo-dev burnout / scope creep | High | High | Data-driven content (tables, not bespoke code); P0 "fun gate" prevents polishing non-fun cores; roadmap timeboxes |
| Low-end performance misses | Medium | High | Budgets in §10.3 enforced from P1; auto-quality preset; weekly mid-device profiling |
| Rewarded fatigue / interstitial backlash | Medium | Medium | Placement laws in §14.1; complaint-rate tripwire; interstitials removable by config flip overnight |
| Ad RPM lower than modeled | Medium | Medium | Costs are ~$0 (§14.6) — breakeven is nearly free; mediation phase 2 lifts eCPM; game remains viable as portfolio piece regardless |
| $25 Play Console fee blocks publishing | Certain if unpaid | Low | Ship beta on itch.io meanwhile; treat $25 one-time as the sole capital expense when ready |

---

## 21. References

- Mobile Gaming Market Trends & Outlook (asomobile, 2026) — genre revenue splits
- Most Popular Mobile Game Genres 2026 (AppFollow) — download leaders
- Top Mobile Games H1 2026 (Singular) — strategy/puzzle/RPG revenue ranking
- Smartphone Gaming Trends 2026 (RedMagic) — thermal/session constraints
- Godot vs Unity Comparison 2026 (Rocketbrush) · Best Mobile Game Engines 2026 (AppRadar) — engine selection
- Mobile Game Retention Benchmarks 2026 (Game Growth Advisor / GameAnalytics) — median D1 ≈ 22%
- Mobile Game Monetization Playbook 2026 (AppFollow) · Monetization Models (Adapty, Unity) — hybrid/rewarded strategy
- Ad Network & Mediation Comparisons 2026 (Applixir, TheGameMarketer, AdReact) — AdMob/MAX/LevelPlay landscape
- Unity Art Optimization Tips — overdraw/particle budgets (principles applied engine-agnostically)

---

*End of document — v1.1 (adds §15 Viral & Community Features). Next artifact: P0 grey-box prototype in Godot 4.*
