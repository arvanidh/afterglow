# AFTERGLOW — Reddit Launch-Week Templates v1.0

> Companion to §19 (Launch & Marketing) and `devlog-content-calendar.md`. Subreddits can smell marketing through the screen. The only reliable anti-ad is **specificity + vulnerability**: real numbers, real mistakes, real death messages.
> **Voice law:** write like the developer who owes the whale money — because you are. If a sentence could survive being pasted into an ad, cut it.

---

## 1. Ground rules (read before posting anywhere)

1. **Read each subreddit's current self-promo rules the morning of posting** — they change; bans don't negotiate.
2. **Disclose immediately:** first line says *"I'm the dev."* Counterintuitively this *helps* — hidden shilling is the actual ad smell.
3. **Give before you take:** the account posting should have prior non-promotional activity (devlogs comments, beta feedback threads). A brand-fresh account launching a game reads as astroturf.
4. **Never:** link shorteners, fake questions, alt-account seeding, arguing with the "another survivors-like" comment.
5. **Reply window:** author stays in comments for ≥3 hours post-submit. Unattended posts die; attended posts convert skeptics.
6. One subreddit per day during launch week — same content cross-posted simultaneously reads as spam bots.

## 2. Subreddit cheat sheet

| Sub | Angle that works | Angle that dies |
|---|---|---|
| **r/AndroidGaming** | "Found/made a game that respects X" + playable link + honest ad policy talk | Hype superlatives, "revolutionary", key-art only |
| **r/roguelites** | Build depth, run structure, difficulty philosophy — mechanics-first discussion | "Casual players will love it" positioning |
| *(secondary)* r/gamedev, r/godot, r/IndieDev | Process/numbers post-mortems | Store links in body (keep to comments on request) |

## 3. Templates

### T1 — Launch announcement (r/AndroidGaming, launch day)

**Title options** *(pick concrete over shiny):*
- *I spent 9 months building a survivors-like where weapons fire themselves so you only need one thumb*
- *My game shows interstitials ONLY between runs — here's the exact policy, and the free game behind it*
- *[Play] AFTERGLOW — one-thumb neon roguelite, offline, no accounts. I'm the solo dev, AMA*

**Body skeleton:**
```
I'm the dev — solo, part-time hours, $0 spent making it (Godot + free tools).

What it is: <two sentences from press-kit medium pitch>

What I did differently on purpose:
• Weapons aim themselves — movement is the whole skill floor
• Runs are 5–10 min; thermal-tested so long sessions don't cook phones
• Rewarded ads are opt-in only; interstitials capped between runs,
  never mid-combat, never after a boss. Remove-Ads purchase exists.
• Works fully offline. No accounts. One permission: internet.

What I'm nervous about: <one honest weakness — e.g., "boss #3 might be too
hard for casual players; telemetry will tell me">

Google Play: <link>
Proof it was hard: <1 GIF of a messy early build vs now>
```

### T2 — The numbers post (r/AndroidGaming or r/gamedev, L+5)

**Title:** *Launch week numbers for my solo Android roguelike-ish game — retention, ad revenue, all of it*

Body: real D1/D7, sessions, ARPDAU, top complaint, one chart screenshot, one thing you'd redo. This format reliably outperforms announcements — developers upvote transparency and players upvote being trusted with data. Reuse quarterly (LiveOps M8/M12 tie-ins).

### T3 — Content-led humor (r/roguelites, L+2)

**Title options:**
- *Every death in my game generates a share card. Here are the 7 funniest causes so far*
- *My final boss copies YOUR build and uses it against you. Balance is going great.*

Body = pure content, game name appears once at the bottom with link. If the post survives with the link removed, it was a good post.

### T4 — Build-discussion prompt (r/roguelites, L+3)

**Title:** *What's your favorite "weak weapon that becomes broken with one evolution" design? Building mine around this idea*

Body discusses 2 of our evolutions honestly (including the one that underperforms), asks the community for genre examples. Zero links. The goal is genre credibility + comment-section relationships; curious profiles find the game themselves.

### T5 — Update post (any week with a notable patch)

**Title:** *Patch notes for my neon survivors-like: I nerfed the character everyone loved, here's the data*

Body mirrors `patch-notes.md` structure verbatim (numbers → reasons). Reddit specifically rewards nerf transparency; this doubles as Balance Friday archive.

## 4. Comment scripts (pre-drafted, personalize lightly)

**"Another vampire-survivors clone…"**
> Fair reaction — the genre tag earned it. The differences I bet on: auto-fire means movement is 100% of the skill expression, runs are built for 8-minute phone sessions instead of desk sessions, and the meta progression pays out even on deaths. Whether that's enough novelty is exactly what launch tells me. What would YOU need to see to give another one a shot?

**"How much are the ads?"**
> Interstitials: max 1 per 3 runs, between runs only — never mid-combat, never after boss wins, none before your third run. Rewarded: always opt-in (revive/double shards). One purchase removes interstitials+banners forever, rewarded stay because they're optional by definition. Policy's enforced by config flags — if I ever break it, the config flip to remove them entirely is one line.

**"Why Godot / why not Unity?"**
> Solo + 2D + Android: Godot's MIT license meant zero revenue anxiety, APKs come out tiny (~30MB base), and iteration speed carried a part-time schedule. Unity's mobile SDK depth is real but my scope never touches its advantages.

**Bug report in the wild:**
> Reproduced, logged, credited — you're in the next patch notes. (Then actually do it.)

## 5. Protocol details

- **Timing:** 13:00–16:00 UTC weekdays catches EU evening + US lunch.
- **Edits:** substantive edits get an `EDIT:` tag — silent edits erode the trust this whole doc builds.
- **Criticism rule:** every critical comment gets one genuine reply, no copy-paste. Downvote-brigading is ignored, not fought.
- **Tracking:** Play Console install spikes correlated to post timestamps; Reddit rarely gives clean attribution — judge by the 48h curve shape, not day-of.
- **After launch week:** cadence drops to update-driven posts only (T5). Presence without purpose trains subs to ignore you.

---

*Reddit kit v1.0 — the anti-ad is specificity. Bring numbers, bring receipts, bring the whale.*
