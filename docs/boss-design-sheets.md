# AFTERGLOW — Boss Design Sheets v1.0

> Companion to §7.2 (Bosses) and `death-messages.md` pools A/B/C. All numbers live in `.tres` tuning files — values below are starting points expressed in both absolutes *and* player-DPS-seconds (the real balancing unit).
> **Shared combat contract:** every attack telegraphs ≥0.6 s with a shape-coded cue (accessibility pass §1); max **2 concurrent threats**; 2 s grace after entrance; boss contact damage never instakills at full HP.

---

## Shared tuning constants (`boss_base.tres`)

| Field | Value | Note |
|---|---|---|
| entrance_grace_s | 2.0 | No attacks until name-card finishes |
| contact_damage_pct | 12% max HP/s | Body overlap, not instant death |
| cc_immune | true | No knockback/stun except scripted windows |
| target_fight_length_s | 75 ± 20 | Median across skill levels |
| tier_hp_mult | ×1.35^n | Per difficulty Tier n (§8.2) |

Target: median kill time 60–90 s; fail state analysis flags any pattern causing >20% of deaths with zero successful dodges (unfair signal).

---

# SHEET 1 — THE DEVOURER ★★☆
*"The city's hunger grew a stomach."* · Biome 1: The Promenade

### Concept
A shadow-whale circling the plaza that ate the district's light. First boss: teaches **watch-the-floor** literacy. Big, readable, dramatic — every attack is geometry, no hidden rules.

### Stats
| Field | Value |
|---|---|
| HP | 9,000 (= 70 dps-seconds at on-curve build) |
| Size | 3.2 × 1.8 screens-length hitbox core (body edges forgiving — only the core segment damages on overlap) |
| Weak points | 3 dorsal nodes, exposed post-Slam (below) |

### Phases
| Phase | HP band | Behavior |
|---|---|---|
| P1 Cruising | 100–66% | Sweeps + Orb Spit, unhurried cadence (cycle ~7 s) |
| P2 Hunting | 66–33% | Adds Breach Slam; cycle tightens to ~5 s; orbs +2 |
| P3 Feeding Frenzy | <33% | Double lane sweeps, permanent weak-point exposure, arena edge vignette pulses ("the hunger closes in") |

### Attacks

| Attack | Telegraph (shape-coded) | Pattern | Counterplay |
|---|---|---|---|
| **Lane Sweep** | Chevron arrows fill the target lane, 0.8 s, cyan→magenta flash | Whale dashes the lane's full length | Step out of marked lane; sweeps alternate adjacent lanes in P2+ |
| **Orb Spit** | Mouth glow swell 0.6 s | 3–5 homing orbs (turn-rate capped — they cannot reverse sharply); 25 HP each, shootable | Bait a curve then sidestep, or pop them for bonus XP motes |
| **Breach Slam** *(P2+)* | Expanding landing ring at player's position, 1.0 s | Whale breaches, slams point; shockwave ring 1.5× ring radius | Leave the ring; **reward:** 3 dorsal nodes glow amber 4 s → 2× damage taken — the DPS window the whole fight teaches |
| **Frenzy Sweeps** *(P3)* | Two lanes marked simultaneously, 0.7 s | Consecutive sweeps, center lane always safe | Hold center discipline under pressure |

### Failure/death hooks
Death-message pool **A** (7 lines). "2 seconds before your chest opened" line triggers when a chest spawned <5 s before death.

### Acceptance criteria
- [ ] Median clear 60–90 s at Tier 0; <10% of runs end at P1 (onboarding-boss mercy)
- [ ] Slam → weak-point window produces visible DPS spike in telemetry (players learned the lesson)
- [ ] No death replays where telegraph was <0.6 s

---

# SHEET 2 — THE CHOIR ★★★
*"Three voices. One appetite."* · Biome 2: The Undercity

### Concept
Three linked cores suspended in a triangle, joined by humming energy filaments. Destroy in **any order** — but survivors absorb their fallen sister's voice and *enrage*. Every attempt writes its own difficulty curve: burst one fast and fight two angry ones, or whittle all three evenly?

### Cores (each ~2,600 HP = 22 dps-seconds)

| Core | Color code | Signature behavior |
|---|---|---|
| **CANTOR** | Magenta | Radial bullet-rings with rotating gap (walk the gap) |
| **DRONE BASS** | Indigo | Spawns Swarmlet packs (alive-cap 6, P2: 8) — add management pressure |
| **SOPRANAUT** | Amber | Rotating beam sweep: arc telegraph 0.9 s, then 140° sweep over 1.6 s |

### Phases (by total remaining HP)
| Phase | Band | Escalation |
|---|---|---|
| P1 Harmony | 100–60% | One signature pattern per core, slow cycle (~8 s global) |
| P2 Dissonance | 60–30% | Rings become spirals · add cap 8 · beams reverse mid-sweep · cycle ~6 s |
| P3 The Chord | <30% (or any 2 cores dead) | Surviving cores link filaments → converging **cross-beam lattice** (4 telegraphed lines, 1.2 s, then fire); enrage aura visuals |

### Mechanics

| Mechanic | Rule | Purpose |
|---|---|---|
| **Harmony Link** | If all 3 cores take no damage for 5 s, each heals 0.5%/s | Anti-kite timer — forces engagement |
| **Enrage Stacks** | Each dead core: survivors +18% cast speed, +1 pattern layer | Any-order choice = self-set difficulty |
| **Filament Hazard** | Connecting filaments damage on touch (thin, always visible) | Makes positioning spatially interesting, not just orbiting |

Counterplay identity: hug the beam-gap rotations, save AoE for Drone Bass windows, and choose your kill order deliberately — Ember builds melt one core (then survive chaos), tanky Spark builds even them out.

### Failure/death hooks
Pool **B** (opera jokes). Enrage-death line reserved: *"Defeated by opera. At least the acoustics were great."*

### Acceptance criteria
- [ ] Kill-order distribution across beta testers spans all 3 orders (no dominant strategy >60%)
- [ ] Median clear 80–110 s (harder than Devourer by design)
- [ ] Chord lattice deaths ≤10% of total boss deaths after week 1 of beta (learnable, not random)

---

# SHEET 3 — NULL PRIME ★★★★
*"Fight your reflection."* · Biome 3: The Spire — campaign finale

### Concept
The mirror at the top of the Spire kept a copy of everyone who failed. NULL PRIME is *your* build turned around — it spawns casting simplified versions of your exact four weapons. You lose to yourself, knowledgeably. Deliberate palette exception: its core is white-gold (the "victory color") because it believes it's the winner — telegraphs stay shape-coded per the accessibility law, but this is the one enemy allowed to look like the safest thing in the room.

### Stats
| Field | Value |
|---|---|
| HP | 11,000 (= 85 dps-seconds) |
| Mimic source | Snapshot of player's 4 weapons + evolutions at encounter start |
| Mimic power | 60% of player's damage values (P1), 80% (P2), anti-versions (P3) |
| **Reflection Tax** | Takes −15% damage from the player's highest-invested weapon category | Anti-stat-check: diversified builds shine; capped so it never hard-walls |

### Phases
| Phase | Band | Behavior |
|---|---|---|
| P1 Mimicry | 100–66% | Casts your arsenal back at you, slower cadence; mirrors your movement with 0.4 s delay (unsettling, learnable) |
| P2 Distortion | 66–33% | Mimic upgrades include evolutions at reduced power; **teleport-step** repositioning every ~5 s (glitch-shimmer telegraph 0.5 s) |
| P3 Null Overload | <33% | Drops imitation for **anti-versions**: anti-Nova *pulls*, anti-Rail sweeps toward you, anti-drone hunts; desperation: **Null Pulse** — screen-wide ring, 2.0 s telegraph, survivable only behind one of the arena's 4 light-pillars (pillars shatter after blocking once — resource management finale) |

### Counterplay identity
You know these attacks — you've been upgrading them all run. The fight is applied self-knowledge: dodge your own Chain Arc gaps, punish your own Nova cooldowns. Pillars turn P3 into a cold, calm inventory of safety.

### Failure/death hooks
Pool **C** (mirror jokes): *"Your reflection won the argument."* · *"Null Prime ran your build with better aim. Rude."*

### Acceptance criteria
- [ ] Players verbally recognize their own weapons in beta comments (the fantasy landed) — tracked qualitatively
- [ ] Reflection Tax keeps highest-category DPS within ±10% of others (tax works, doesn't wall)
- [ ] ≥1 pillar remains unbroken in ≥50% of clears (resource mechanic reads)
- [ ] Victory triggers white-gold bloom flood → credits without cutscene skip complaints

---

## Reward tables (all bosses, Tier n)

| Outcome | Shards | Cores | Notes |
|---|---|---|---|
| Boss killed | 250 × tier mult | +1 (first weekly kill only) | Interstitial suppressed after victory — protected moment (§14.1) |
| Died during boss | Standard run payout + 15% "courage bonus" | — | Dying to bosses must never feel worthless (pillar 5) |

## Global boss QA gates (per §18 suite)

- [ ] All telegraphs verified shape-legible in 3 colorblind palettes
- [ ] Thermal soak: boss fights cause no device throttling spike vs regular waves (particle budget respected in P3s)
- [ ] Rewarded-revive during boss resumes cleanly (no pattern restart mid-animation)
- [ ] Each boss solo-tested with all 3 characters × 2 archetype builds minimum

---

*Boss sheets v1.0 — three fights, one escalation grammar: floor-literacy → prioritization → self-knowledge.*
