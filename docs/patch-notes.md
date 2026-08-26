# AFTERGLOW — Patch Notes Template & Samples v1.0

> Companion to `discord-server-plan.md` §4.3 (Balance Friday) and §18 QA. Patch notes post to #beta-downloads / #announcements and itch.io devlogs.
> **Voice law:** same as everything else — dry, specific, never corporate. Nerfs always show their numbers. Fixes always credit their finder. Every note ends with the running budget gag or a dry sign-off.

---

## 1. Template

```markdown
## AFTERGLOW vX.Y.Z — "<two-word name>"

<one sentence: what this build is for. no adjectives you can't defend.>

### New
- <feature> — <why it exists, ≤12 words>

### Changed
- <behavior> now <behavior>. (<reason, one clause>)

### Fixed
- <symptom>, not <cause we pretend is interesting>. *(found by @<tester>)*

### Nerfed / Buffed *(numbers or it didn't happen)*
- <thing>: <old> → <new>. Why: <telemetry stat in one line>.

### Known Issues *(we know, they're listed, that's the point)*
- <issue> — workaround: <if any>

### Next Up
<one teaser, one line.>

— solo dev, $[N] spent so far. The whale accepts cash.
```

### Writing rules

1. **Titles:** two words max, evocative not cute ("Whale Diet", "Tax Season").
2. **Nerfs need three parts:** old number → new number → the telemetry line that justified it. A nerf without data reads as mood.
3. **Credits are mandatory:** every player-found fix names its finder — this is the Bug Hunter economy working (Discord §4.3).
4. **Known Issues is never empty** if issues exist; hiding them costs more trust than listing them.
5. **Length cap:** players scroll past 300 words. If it needs more, it's two posts.
6. **No apologies theater.** "We messed up, here's the fix" beats three paragraphs of contrition.

---

## 2. Sample: **v0.7.0 — "First Contact"** *(first public beta — P4, Month 7)*

Nine months ago this was rectangles attacking a brighter rectangle. Today you're reading its patch notes. Welcome to the AFTERGLOW closed beta.

### In this build
- All 3 biomes: Promenade, Undercity, Spire — bring a jacket, the Spire drafts
- 3 bosses, including a whale with opinions about your chest-opening schedule
- 6 weapons × evolutions · 3 characters · permanent upgrade grid · daily seeded challenge
- Run Recap Cards — share button included, dignity not included

### How to break it (please)
Found something wrong? #bug-reports on the Discord has the template. Reports with clips get fixed first; reports without repro steps get admired and filed. Confirmed finders get the **@Bug Hunter** role and their name in these notes forever.

### Known Issues
- Recap cards occasionally render the whale slightly too majestic — cosmetic, tolerated
- On some foldables the pause menu opens like it's unsure — closing it reopens it decisively
- Volt's dash sound plays twice if you dash *while* leveling up. He's just excited.

### Next Up
Balance pass driven by your deaths. Bring data. Or just bring deaths — same thing.

— solo dev, $0 spent so far. Google wants $25 eventually. The whale accepts cash.

---

## 3. Sample: **v0.7.2 — "Whale Diet"**

Hotfix week one. You played 41,000 runs and the telemetry got opinionated.

### Fixed
- Devourer Slam could land before its ring finished drawing on 60 Hz devices. It cannot now. *(found by @moss_engine)*
- Foldable pause-menu hesitation — the menu was asking twice. Now once, firmly. *(found by @dawnrunner)*
- Recap card PNGs were 2.1 MB; WhatsApp compressed them into modern art. Now 480 KB and still gorgeous.

### Tuned *(numbers, as promised)*
- Breach Slam telegraph: **1.0 s → 1.2 s.** Why: 34% of first-boss deaths happened during the ring draw itself — that's a reading problem, not a skill problem, so we read it for you.
- Orb turn-rate: capped harder at close range. Why: point-blank orb spirals produced 11% of all deaths and 0% of anyone's fun.
- Chest spawn distance from boss arena edge: +15%. Why: the "2 seconds before your chest opened" death line was trending too literally.

### Known Issues
- Still no way to pet the whale. Listed daily. Ignored daily.

### Next Up
Full Balance Friday lands this week — Ember owners, hydrate.

— solo dev, $0 spent so far.

---

## 4. Sample: **v0.8.0 — "Tax Season"** *(first true Balance Friday patch)*

Our first nerf patch. Numbers below, feelings optional, receipts attached.

### Nerfed
- **Ember — Wildfire proc chance: 12% → 10%.** Why: Ember accounts cleared Undercity 22% faster than the next character and owned 4 of the top 5 weekly scores. She's supposed to be a glass cannon, not a glass artillery division. Chain-explosions still cascade; she's still terrifying; she's now *fair* terrifying.
- **Singularity pull radius: +20% base value → +12%.** Why: combined with Wildfire it created a room-deletion combo with no counterplay window. Combo intact, breathing room restored.

### Buffed *(quieter, but real)*
- **Volt — Live Wire dash cooldown: 6.0 s → 5.5 s.** Why: his win rate was fine; his *rematch* rate wasn't. Dying as Volt should feel like your fault, then immediately be your idea to retry.
- **Shard payout on boss-death runs: +15% → +20%.** Why: dying to THE CHOIR at 99% produced measurable controller-adjacent sadness. Courage bonus raised accordingly.

### New
- Daily challenge constraints expanded: 6 new rotating twists, including "**Undercity at night**" (yes, it's darker; yes, you'll adapt)
- Death-message pack added: *Founders'* — six new ways to be told what went wrong, historically

### Community Goal
"The community purifies 10,000,000 shades": **7.4M**. Gold Trail is sweating. Balance Friday progress bars are a tradition now.

### Known Issues
- Moth rumors persist. We neither confirm nor deny insects in the pipeline.

— solo dev, $0 spent so far. The nerfs, however, were free.

---

## 5. Distribution checklist (per release)

- [ ] Post: Discord #beta-downloads (webhook from GitHub tag auto-fires) + #announcements
- [ ] Cross-post: itch.io devlog entry (same text)
- [ ] TikTok slot: one 20 s "what changed" clip on calendar's Wednesday post when changes are visual
- [ ] Archive: append to `CHANGELOG.md` in repo — notes die, repos live
- [ ] Verify: every credited tester actually received their @Bug Hunter count increment
- [ ] Tone check: read aloud once. If any sentence sounds like a press release, rewrite it until it sounds like a person who owes the whale money.
- [ ] Full-channel pack (notes + Discord + TikTok + Reddit T5) needed? Clone the worked example: **`update1-announcement-pack.md`** — facts change, laws don't.

---

*Patch notes v1.0 — receipts attached, feelings optional.*
