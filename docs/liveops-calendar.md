# AFTERGLOW — Year-One LiveOps Calendar v1.0

> Companion to §15 (Viral & Community Features), §15.8 (Community Goal Events), §16 (Analytics) and `death-messages.md` (seasonal pack slots). Covers global launch (GDD month 9) plus 12 months after.
> **LiveOps law:** everything is cosmetic, Shards, or Cores — never power. Missed an event? Its cosmetics return within 12 months. FOMO is churn wearing a party hat.

---

## 1. Cadence stack (what runs when)

| Layer | Frequency | Content | Delivered via |
|---|---|---|---|
| Daily Challenge | Daily 00:00 local | Seeded run + rotating constraint (§15.2) | Date-hash seed, $0 |
| Ranked Season | Weekly (Mon 00:00 UTC) | Ladder reset, @Prism Council top-10 (Discord) | Play Games leaderboards |
| Balance Friday | Weekly | Patch/balance post + changelog (Discord ritual §4.3) | Manual + GitHub webhook |
| Recap Spotlight | Weekly | Best community card featured in-game menu | Manual pick |
| Monthly Drop | 2nd Tuesday | New weapon *or* biome remix (alternating) | Store update |
| Community Goal | Monthly-aligned | Global milestone → reward for everyone (§15.8) | Firebase Remote Config |
| Event Season | Quarterly | Theme + cosmetic line + death-message pack + finale event | Combined |
| Character Drop | Quarterly (with Event Season finale) | New playable spark | Store update |

**Buffer law:** one content update always finished and shelved before its slot. A solo dev who ships late ships late; a solo dev who ships nothing has cancelled the game. Buffer > schedule.

---

## 2. Monthly calendar

*Month 0 = global launch month.*

### M0 — IGNITION (Launch)
- Double-Shards Weekend (L+1) · first Ranked Season starts L+7 · Dawnbringer role window (first 100 players)
- **Goal:** "The community purifies **10,000,000 shades**" → `Gold Trail` for everyone
- Pack: none (launch set carries it)

### M1 — FIRST LIGHT (Update 1)
- Ships §15.9 wave: Instant Replays · Build Codes · Referrals · live Community Goal counters (free-tier backend if adopted)
- Drop: weapon remix — *Nova Burst* gains pull-fragment upgrade path
- **Goal:** "**1,000,000** runs finished" → everyone earns streak shield (+1 forgiveness/week)
- Pack: **Founders' Pack** begins (see §3)

### M2 — UNDERCITY NIGHTS
- Drop: *The Undercity* remix — hazard pools gain slow-pulse safe islands (map variety without new art)
- First community-build spotlight series (TikTok tie-in, calendar M2 slots)
- **Goal:** "**25,000** daily challenges completed" → `Nightshift` aura color line

### M3 — SEASON OF THE WHALE (Event Season Q2 finale)
- **Character Drop #1: WICK** ★★☆ — sustain archetype, candle-keeper lore ("a flame that chose to stay"); kit: regen-on-standstill + candle wick deployable heal zone *(numbers TBD in .tres)*
- Whale Week: Devourer community challenge (fastest kills leaderboard, non-ranked)
- **Goal:** "**500,000** Devourer weak-point hits" → `Baleen` dash-trail cosmetic

### M4 — TRANSIT AUTHORITY
- Drop: new weapon **Turnstile** — rotating barrier segments that damage pass-throughs *(new weapon #7)*
- Build Codes go mainstream: weekly featured code pinned everywhere
- **Goal:** "**100,000** build codes redeemed" → `Metro Pass` Volt trail skin

### M5 — STATIC BLOOM
- Drop: *The Spire* remix — moving pillar layouts (reuses boss pillar tech)
- Photo Mode lite: pause-frame camera + filter (feeds #clips)
- **Goal:** "**50,000** clips saved" → `Kodachrome` recap-card frame

### M6 — SEASON OF CURRENTS (Event Season Q3 finale)
- **Character Drop #2: MOTH** ★★★ — high-skill trickster drawn to light ("the dark sent a spy; she defected"); kit: dash-chains, bonus damage in darkness zones *(TBD)*
- First **Anniversary-adjacent** community vote: next weapon family (Discord #feature-votes, real consequences)
- **Goal:** "**10,000,000** total shades purified (lifetime)" → animated `Grid Ghost` portrait frame
- Pack swap: **Transit Pack** ends, **Static Pack** begins

### M7 — HARD LIGHT
- Drop: new weapon **Prison of Suns** — stationary light walls, enemies route around *(new #8)*
- Difficulty Tier expansion: Tier 5–6 unlock chase for Prism Council
- **Goal:** "**1,000** Tier-5 clears" → `Overload` victory flash variant

### M8 — DIMMING
- Quiet month by design (dev recovery + buffer rebuild): rerun M0–M2 goals as "Encore" for new players
- Retention experiment window: D30 win-back notification copy test (respectful policy still applies)
- **Goal:** Encore board — best single goal result repeats

### M9 — BLACKOUT ANNIVERSARY 🎂
- In-fiction holiday: the night the city went dark, celebrated with lights
- Anniversary login trail: 7-day streak → `First Candle` trail + anniversary recap-card frame
- **Death Message Theatre live show**: Discord voice reading of the year's most-shared deaths
- **Goal:** "**365,000** daily challenges completed (all-time)" → `Anniversary` wordmark badge
- Pack: **Blackout Anniversary Pack** (includes *"One year old. Still afraid of whales."*)

### M10 — CROSSWIRES
- Drop: weapon remix — Chain Arc chains gain arc-jump visual variants
- Co-op-flavored async event: **Relay Runs** — your finish seeds a modifier for the next player's daily (light touch, still offline-first: relay state rides the daily seed math)
- **Goal:** "**200,000** relay hand-offs" → `Signal Flame` aura

### M11 — LONGEST NIGHT
- Winter event: daily challenges run darker palettes + +10% Shards all week
- Charity-adjacent community goal framed as gift-to-players (no payment mechanics — zero-budget law intact)
- **Goal:** "**5,000,000** orbs spat by Devourers destroyed midair" → `Anti-Fang` weapon charm

### M12 — PRISM YEAR TWO (Event Season Q4 finale)
- **Character Drop #3: LUMEN** ★★☆ — mirrored twin of Spark from Null Prime's dimension (lore payoff; kit: borrowed mimicry stance swapping offense/defense *(TBD)*)
- Year-in-review infographic (real player numbers, shared publicly — transparency brand continues)
- Year Two teaser slot: biome 4 confirmation vote results
- **Goal:** lifetime community total → permanent `Year One` Discord role for all participants
- Pack: **Grid Holiday Pack**

---

## 3. Seasonal death-message packs (6 lines each, written into `death-messages.md` slots)

| Pack | Active | Tone sample |
|---|---|---|
| **Founders'** | M1–M3 | "Founded 1892. Abandoned 2026. You, briefly: both." |
| **Transit** | M4–M6 | "The trams stopped running. You didn't. The wall disagreed." |
| **Static** | M6–M9 | "Moths report: the light was worth it." *(Moth drop tie-in)* |
| **Blackout Anniversary** | M9 only | "One year old. Still afraid of whales." |
| **Grid Holiday** | M11–M12 | "Season's greetings from the dark. It enclosed a sweep attack." |

Rules per pack: ≤6 lines, retire on schedule, never reference monetization (death-library law), each line tagged `{pack}` for analytics share-rate comparison against library median.

## 4. Community goal design rules

- Thresholds sized from telemetry at proposal time (never vibes): aim for **60–70% of active players contributing ≥1 unit**
- Reward always cosmetic-or-QoL (streak shields ok), delivered via Remote Config flag flip — revertible if abused
- Every goal gets a Discord progress bar post each Balance Friday — the number going up IS the content
- One goal live at a time; overlap creates noise, not hype

## 5. Operating guardrails

- **No limited-time power.** Ever. (§14 law extension.)
- **Events configure via Remote Config flags** with kill-switch defaults off; a broken event is turned *off*, not hotfixed at 2am
- **Dev-health calendar:** M8 quiet month is load-bearing — treat as unmovable
- **Content reuse beats new scope:** remixes alternate with genuinely new items 1:1 (M4/M7/M10 pattern)
- KPI review after each Event Season: participation %, goal completion, pack-line share rates → next quarter tuned accordingly

---

*LiveOps v1.0 — twelve months planned, one human sustainable, zero pay-to-win.*
