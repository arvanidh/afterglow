# AFTERGLOW — Onboarding A/B Testing Plan v1.0

> Companion to §13 (Onboarding & Retention Design). Goal: turn the #1 retention lever (median D1 ≈ 22%; our target ≥35%) into a measured pipeline instead of opinions.
> **Stack reality:** free tiers only — **Firebase A/B Testing + Remote Config** drive experiments; GameAnalytics carries design events. $0.
> **Ethics law:** we test *clarity*, never manipulation. No forced-ad variants, no fake urgency, no loss-framed FOMO — anything violating §14's respect-the-player law is not a variant, it's a bug.

---

## 1. Operating principles

1. **One experiment at a time** — solo-dev bandwidth and small samples both demand it.
2. **One primary metric per test**, declared before launch. Moving goalposts = invalid result.
3. **Fixed horizon:** decide sample size up front; no peeking-stopping (small-sample sin #1).
4. Every test ships as a Remote Config parameter — instant rollback, default = current behavior.
5. Results get written into `docs/experiment-log.md` regardless of outcome. Dead tests still teach.

## 2. Instrumentation prerequisites (built by end of P3 / Month 6)

| Event | Fires when | Feeds |
|---|---|---|
| `first_open` | Cold install first launch | Funnel start |
| `ftue_step{n}` | Each micro-run beat passed | Step-level leak map |
| `first_input` | First joystick movement (timestamp vs first_open) | Time-to-fun |
| `tutorial_complete` | Micro-run victory screen dismissed | Primary funnel exit |
| `run{1..3}_complete`, `run{1..3}_abandon` | Real runs | Post-tutorial falloff |
| `levelup_first_choice` (+ time-since-start) | First card picked | Choice-timing tests |
| `rewarded_offer_view/accept{placement}` | Ad offers | Monetization tests |
| `d1_return`, `d3_return`, `d7_return` | Next-day app open | Guardrails + primaries |

**Leak-map hypothesis (to verify before any test):** biggest drops expected at ① cold-start→first-input (store-intent noise, low fixability), ② mid-micro-run abandonment (fixable pacing), ③ run-1→run-2 gap (fixable payout clarity).

## 3. Test backlog (prioritized)

| # | Test | Hypothesis | Variants | Primary metric | When |
|---|---|---|---|---|---|
| T1 | **Splash cost** | Every logo second costs completions | A: current 2-beat splash · B: instant-to-game, splash moves behind pause menu | `tutorial_complete` rate | Closed beta M7 |
| T2 | **Micro-run length** | 90 s exceeds first-session attention budget | A: 90 s · B: 60 s (same beats compressed) | tutorial_complete + `d1_return` (both must hold) | Beta M7 |
| T3 | **First choice timing** | Agency felt earlier sticks longer | A: first level-up ~45 s · B: guaranteed first card <25 s (scripted fast XP) | `levelup_first_choice` time + run1_complete | Soft launch M8 |
| T4 | **First rewarded offer** | Framing changes acceptance without hurting trust | A: "Double your Shards?" (results screen) · B: "+50% Shards — watch a short video" explicit-cost copy | accept rate **and** D3 retention (trust guardrail) | Soft launch M8 |
| T5 | **Death payout clarity** | "You lost but earned" needs saying out loud | A: standard results · B: results header "+38 Shards banked — progress never resets" | run2_start within session | Global M9+ |
| T6 | **Character tease copy** | Specific beats vague for unlock motivation | A: "Volt unlocks in 4 runs" · B: same + portrait + one-line kit hint | `d1_return` | Global |
| T7 | **Day-1 mission gift** | Pre-completing mission #1 removes next-day friction | A: earn it · B: auto-complete on D1 open | d1_return | Global |

Backlog rule: new test ideas queue here with hypothesis + metric before implementation; anything that can't state its primary metric goes back to the drawing board.

## 4. Small-sample statistics (honest math)

- **Beta (M7):** traffic is tiny (~200–400 installs). Run T1/T2 as **directional only**: require consistent sign across 7 consecutive days + qualitative Discord corroboration. Never declare victory at n<150/arm.
- **Soft launch (M8):** real numbers arrive. Minimum **500 users/arm**, fixed 14-day window, Firebase-reported significance.
- **Minimum detectable effect:** plan for **≥10% relative lift** on the primary. If the idea can't plausibly move a metric 10%, it's polish, not an experiment — just ship it either way.
- **Segment sanity check:** winners must hold for both phone-class halves and top-2 geos before full rollout.

## 5. Rollout rules

```
Ship default (A) → run test fixed window → evaluate
├─ WIN:    primary lifts ≥ threshold, p<0.05, no guardrail regression
│          → staged rollout 50% arm → 100% over 72 h → log decision
├─ FLAT:   no reliable difference → keep cheaper/simpler variant → log
└─ LOSS:   primary drops OR any guardrail regresses >2%
           → revert instantly via RC flag → log + post-mortem paragraph
```

**Guardrail metrics (any test, always watching):** `d1_return`, crash-free sessions ≥99.5%, FTUE completion, rewarded-offer complaint signals (settings visits after ad), median session length. A test that wins its primary by hurting a guardrail loses.

Special rule for **T4** (ad framing): acceptance-rate wins mean nothing alone — D3 retention is a co-primary. An ad variant that converts better but retains worse is a confirmed loss, permanently documented so future-us doesn't re-litigate greed.

## 6. Cadence & ownership

- Max one live test at any moment; minimum 3-day cool-down between tests (event pollution).
- Test calendar slots: beta = T1, T2 · soft launch = T3, T4 · global quarter = T5–T7, then backlog refresh from telemetry.
- Friday ritual extension: Balance Friday gains a "experiment status" line (running / won / lost / learned-nothing).

---

*A/B plan v1.0 — measure the promise, not the player's patience.*
