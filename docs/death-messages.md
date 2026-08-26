# AFTERGLOW — Death Message Library v1.0

> Companion content library for §15.3 (Meme Death Screens) of the game design document.
> **50 causes**, categorized by trigger. Tone law: *dry, punchy, screenshot-worthy* — roast the situation, never the player.

---

## Writing rules

1. **Length:** ≤ 90 characters — must fit the recap-card headline slot without shrinking the font.
2. **Placeholders:** `{kills}` · `{seconds}` · `{n}` (death count) · `{levels}` (account levels to unlock dodge) · `{elite}` (elite modifier name). Numbers stay outside quotes where possible for easy localization.
3. **Rotation:** never repeat a message within a player's last 15 deaths. Near-miss lines are **reserved triggers** — they only fire under their stated condition so they stay rare and land hard.
4. **Rating:** Teen/PEGI-12 safe. No slurs, no real-world tragedy references, no punching down — the *dark* is the butt of most jokes; the player gets affectionate teasing at worst.
5. **Localization:** avoid idioms tied to English wordplay where possible; every message must survive a translation pass without becoming nonsense.

---

## A. Boss — THE DEVOURER (7)

| # | Trigger | Message |
|---|---|---|
| A1 | Boss kill-shot | "Devoured by THE DEVOURER… 2 seconds before your chest opened." |
| A2 | Any boss death | "The whale always wins. This time it was official." |
| A3 | Swallow attack | "Swallowed whole. You were delicious, apparently." |
| A4 | Any boss death | "Cause of death: one (1) extremely large fish." |
| A5 | Slam attack | "You fed the whale. It's still hungry." |
| A6 | Sweep attack | "Swept, slammed, snacked on." |
| A7 | Victory denied | "THE DEVOURER left a review: 'Tasted like victory. Almost.'" |

## B. Boss — THE CHOIR (3)

| # | Trigger | Message |
|---|---|---|
| B1 | Any Choir death | "The Choir harmonized. You were the rest between the notes." |
| B2 | Core enrage | "Three cores sang. You became the applause." |
| B3 | Any Choir death | "Defeated by opera. At least the acoustics were great." |

## C. Boss — NULL PRIME (3)

| # | Trigger | Message |
|---|---|---|
| C1 | Any Null Prime death | "Your reflection won the argument." |
| C2 | Mirror-phase kill | "Null Prime ran your build with better aim. Rude." |
| C3 | Final phase | "Mirror match: lost. To you. Because of you." |

## D. Swarm overwhelm (7)

| # | Trigger | Message |
|---|---|---|
| D1 | >2,000 kills this run | "4,112 shades attended. None sent flowers." *(use actual run kill count)* |
| D2 | Overwhelmed | "The swarm didn't hate you. That's worse." |
| D3 | Overwhelmed | "Trampled by things with no feet." |
| D4 | Early death (<60s) | "You glowed brilliantly. Briefly." |
| D5 | Overwhelmed | "Cause of death: everyone." |
| D6 | Overwhelmed | "The dark filed a group complaint. In person." |
| D7 | Spawn-ring death | "Surrounded politely, then impolitely." |

## E. Elite kills (4)

| # | Trigger | Message |
|---|---|---|
| E1 | Shielded elite | "{elite} read the patch notes. You didn't." |
| E2 | Any elite | "That elite had a name tag. So does your tombstone now." |
| E3 | Frenzied elite | "Frenzied, shielded, and frankly showing off." |
| E4 | Any elite | "Elites are just enemies with ambition." |

## F. Hazards & dark zones (4)

| # | Trigger | Message |
|---|---|---|
| F1 | Undercity hazard | "The Undercity claims another tourist." |
| F2 | Hazard pool | "Dissolved in a puddle. A magical puddle, but still." |
| F3 | Hazard pool | "The floor was legally distinct lava." |
| F4 | Dark-zone slow death | "Warning label unread. Lesson learned posthumously." |

## G. Ranged deaths (3)

| # | Trigger | Message |
|---|---|---|
| G1 | Spitter projectile | "Spit on. Fatally. Somehow." |
| G2 | Any ranged | "Dodged everything except the thing that hit you." |
| G3 | Repeated ranged hits | "The universe suggests standing somewhere else." |

## H. AFK / idle deaths (4)

| # | Trigger | Message |
|---|---|---|
| H1 | No input >4s | "You stood still. The dark noticed." |
| H2 | No input >8s | "AFK for {seconds} seconds. The swarm kept its calendar open." |
| H3 | No input >12s | "Statue mode is not a viable build." |
| H4 | Idle at spawn | "The shadows took your silence as consent." |

## I. Near-miss (reserved triggers) (6)

| # | Trigger | Message |
|---|---|---|
| I1 | Boss dies with player at same moment | "SO close the Devourer felt your breath. Again?" |
| I2 | Death within 10s of victory timer | "{seconds} seconds short. The city almost remembered you." |
| I3 | Death within 5s of victory timer | "One hit from legend. This screen instead." |
| I4 | Chest uncollected on death | "Your chest was RIGHT THERE." |
| I5 | Death within 1% of boss HP | "The victory screen rendered a frame after you didn't." |
| I6 | First-ever loss at 90%+ progress | "The credits were warming up. They'll wait." |

## J. Special contexts (16 → shown top 16, pick per trigger)

| # | Trigger | Message |
|---|---|---|
| J1 | Died chasing XP/chest | "Greed: 1. Survival instinct: 0." |
| J2 | Died returning for gems | "You went back for the gem. The gem stayed. You didn't." |
| J3 | Repeat death (n≥3 same biome) | "Death #{n}. The dark is starting to feel seen." |
| J4 | Any death (rare weight) | "Died as you lived: surrounded and glowing." |
| J5 | Very late-game death | "The city kept the receipt for that last spark." |
| J6 | Death right after chest open | "Chest opened. Celebration scheduled. Attendance interrupted." |
| J7 | Death pre-dodge unlock | "Your dodge unlocks in {levels} levels. Condolences." |
| J8 | Death while paused-menuing | "Pause menu explored mid-swarm. Brave." |
| J9 | Device battery <5% death | "Battery: 1%. Hope: 0%." |
| J10 | Died to own Singularity pull | "Gravity: undefeated since forever." |
| J11 | Revive used, died again <30s | "The second chance lasted 30 seconds. Memorable." |
| J12 | Daily challenge death | "Same seed as everyone. Same fate as most." |
| J13 | Win streak broken | "Streak status: mythology." |
| J14 | Died during Evolution window | "Evolution was 1 gem away. Evolution is patient." |
| J15 | Full-build death (all slots maxed) | "Perfect build. Imperfect piloting." |
| J16 | Tier-N difficulty death (N≥3) | "Tier {n} doesn't do participation Shards. Oh wait — it does." |

*(Library total: 50 — A7 + B3 + C3 + D7 + E4 + F4 + G3 + H4 + I6 + J16 = 50.)*

---

## Weighting & tuning notes

- **Rare-weight lines** (J4, J13, I-pool): max once per session so they stay special.
- **Data hook:** every displayed message logs `death_message{id}` alongside `death_cause` — if a line's share-rate outperforms, write more in that voice.
- **Seasonal packs:** reserve 5–6 slots per season for themed additions (e.g., anniversary: "One year old. Still afraid of whales.") — keeps the library fresh with tiny effort.
- **Never show:** anything referencing monetization failures, real money, or ad errors — death screens stay playful, never bitter.

---

*AFTERGLOW death copy v1.0 — 50/50 written. Extend via seasonal packs; retire any line whose share rate dips below library median.*
