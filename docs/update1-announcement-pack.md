# AFTERGLOW — Update 1 Announcement Pack v1.0

> Worked example for every future update: one patch, four channel-native announcements, zero copy-paste between them. Content = LiveOps M1 "FIRST LIGHT" (`liveops-calendar.md`). Formats follow `patch-notes.md`, `discord-server-plan.md`, `devlog-content-calendar.md`, `reddit-posts.md`.
> **Pack law:** same facts everywhere — version, feature names, goal numbers, credits — different native voice per channel. If two posts disagree on a number, players will find it before you do.

---

## 0. Release facts (single source of truth)

| Fact | Value |
|---|---|
| Version | **v1.1.0 — "First Light"** |
| Ships | Instant Replays · Build Codes · Referrals (Twin Flames) · live Community Goal counter · Founders' death-message pack |
| Remix | Nova Burst gains pull-fragment upgrade path |
| Replay buffer change | 12 s → 15 s (see patch notes) |
| Community Goal | "**1,000,000 runs finished**" → everyone earns the **Streak Shield** (+1 forgiveness/week) |
| Rollout | Staged 20% → 50% → 100% over 72 h (Remote Config flags, kill-switch ready) |

## 1. Timing table

| When (UTC) | Channel | Asset |
|---|---|---|
| D−1, 19:00 | Discord #announcements | Teaser line only, **no @everyone** ("tomorrow, the light comes back") |
| **D-Day 10:00** | Staged rollout begins | GitHub tag → webhook auto-posts changelog to #beta-downloads |
| D-Day 10:15 | Discord #announcements | **Full post below — this week's single @everyone slot** |
| D-Day 10:20 | itch.io devlog | Patch notes verbatim |
| D-Day 19:00 | TikTok/Shorts/Reels | 20 s "what changed" video (Wednesday slot) |
| D+1, 13:00–16:00 | Reddit | T5 post, **one subreddit**, author in comments ≥3 h |

---

## 2. Patch notes draft (itch.io devlog + repo CHANGELOG)

```markdown
## AFTERGLOW v1.1.0 — "First Light"

Launch gave you the dark. Update 1 gives you the receipts: your best moments
are now saveable, shareable, and dareable.

### New
- **Instant Replays** — the game quietly records your last seconds; save or
  share any Evolution moment or boss kill straight from the results screen.
- **Build Codes** — export your loadout + run seed as `AG-VOLT-7F3K` and paste
  it at a friend. Same run, same spawns, no excuses left.
- **Referrals** — invite a friend from the menu; when they install, you both
  earn the **Twin Flames** trail. Two sparks, one rope of light.
- **Live Community Goal board** (main menu): "**1,000,000 runs finished**"
  worldwide → every participant earns the **Streak Shield** (+1 forgiveness
  per week). The number goes up when you play. That's the whole trick.
- Six new **Founders'** death messages, historically. Sample: "Founded 1892.
  Abandoned 2026. You, briefly: both."

### Changed
- **Nova Burst — pull-fragment upgrade path added.** Fragments now drag
  neighbors inward before detonating. Crowd-clear becomes crowd-tidy.

### Buffed *(numbers, as promised)*
- **Replay buffer: 12 s → 15 s.** Why: beta telemetry showed 61% of saved
  clip highlights landed between second 12 and second 15 — the good part
  kept happening after the camera stopped caring. Camera cares now.

### Fixed
- Build Codes pasted from WhatsApp carried an invisible trailing space and
  failed to parse. Codes are now trimmed of everything except ambition.
  *(found by @moss_engine)*
- Referral link opened the Play Store twice on Samsung Internet. Once is
  plenty. *(found by @dawnrunner)*
- Replay audio drifted ~80 ms out of sync on 90 Hz devices. Lips re-synced
  to explosions. *(found by @kestrel_writes)*

### Known Issues *(we know, they're listed, that's the point)*
- Still no way to pet the whale.
- Replays occasionally make your deaths look cooler than they felt. We've
  decided that's a feature wearing a bug costume.

### Next Up
The Undercity at night is getting darker. That's not a threat, it's a patch
note.

— solo dev, $25 spent so far. The Play Console fee was inevitable. The whale
accepts cash.
```

*Note the budget-gag continuity: beta samples ran "$0 spent so far"; the $25 console fee lands with launch, so Update 1 is the first notes to carry the real number.*

## 3. Discord post (#announcements)

```markdown
@everyone

**UPDATE 1 — "FIRST LIGHT" IS LIVE** 🌅

Everything you voted loudest for, in the game today:

▸ **Instant Replays** — your last 15 seconds, saveable. Your deaths are now
  downloadable evidence.
▸ **Build Codes** — export any run as `AG-VOLT-7F3K` and dare someone to
  survive it. <#build-lab> is open for business.
▸ **Referrals** — invite a friend, you both get the **Twin Flames** trail.
▸ **Goal board is live:** **1,000,000 runs finished** → everyone earns the
  **Streak Shield**. Progress bar's on the main menu. It likes watching.

Plus the Nova Burst pull-fragment path and six new Founders' death messages:
*"Founded 1892. Abandoned 2026. You, briefly: both."*

Full notes: <itch devlog link>

🔊 **Patch party tonight, 20:00 UTC** — voice chat, ~30 min, bring your worst
replay. I'll bring the balance data.

— the lamp that stayed on
```

*Ops notes:* this is the week's one lawful @everyone (§2 server law). Pin it, auto-thread replies ("Show me your first saved replay"), cross-post the changelog snippet to <#known-issues>, and swap the Founders' sample line into <#death-poetry> as a standalone prompt 3 hours later — the pack should harvest submissions, not just announce.

## 4. TikTok script (20 s, works muted)

**Hook (0–1.5 s):** mid-explosion freeze-frame → VHS rewind effect pulls back *into* the living fight. Text overlay: **"Your death. Now downloadable."**

| Beats | Time | Visual | Overlay/caption |
|---|---|---|---|
| Rewind cold open | 0–1.5 | explosion → rewind → chaos resumes | "Your death. Now downloadable." |
| Instant Replays | 1.5–6 | results screen → Save Clip tap → gallery | "15 seconds ago, forever" |
| Build Codes | 6–10 | code appears → paste into chat bubble → friend's identical run | "Dare someone. Same seeds." |
| Referrals | 10–13 | two sparks joined by the Twin Flames trail | "Bring a friend. Get matching light." |
| Death Message Theatre crossover | 13–17 | deadpan read of Founders' line over gameplay | caption text verbatim |
| End slate | 17–20 | wordmark + "LIVE NOW" stamp | "$25 total spent. Ever." |

- **Voiceover:** optional single deadpan line at 13 s (Death Message Theatre format); otherwise silent-safe.
- **Caption:** "You asked for replays. You got receipts. AFTERGLOW Update 1 is live. #AFTERGLOW #roguelite #survivorslike #androidgames #gamedev"
- **Pinned comment:** my own best-run build code, posted the hour the video goes up — comments become #build-lab traffic.
- This pays off the calendar's L+7 tease slot ("Update 1 tease") — first line of the description: *"Teased it. Shipped it."*

## 5. Reddit T5 post (r/AndroidGaming)

**Title:** *Patch notes for my neon survivors-like: Update 1 adds replays and shareable run codes — here's the data behind a 15-second change*

```
I'm the dev — solo, Godot, and as of this patch exactly $25 spent (the Play
Console fee finally came due; there's a running joke and it just got a bill).

Update 1 shipped today. The honest summary, numbers included:

• Instant Replays — rolling capture, save/share from results screen.
  Buffer went 12s → 15s because beta telemetry showed 61% of saved-clip
  highlights occurred between second 12 and 15. The funniest data point
  I've ever shipped a feature around.
• Build Codes — loadout + seed exported as a short code (AG-VOLT-7F3K).
  Friends get the exact same run. Fully offline; no server involved.
• Referrals — Play Install Referrer API, both sides earn a cosmetic trail.
  Honest weakness: attribution can fail on some OEM browsers. Fallback is a
  manual claim field shipping in v1.1.1 if failure rates look bad — I'll
  report the number either way.
• Live community goal: 1,000,000 runs finished globally → every participant
  earns a streak-forgiveness perk. Cosmetic-or-QoL only; no limited-time
  power, ever.

Full patch notes with every fix credited to its finder:
<itch devlog link>

Currently ~[N] players and the goal bar moved [N]% overnight, which is the
most motivating spreadsheet cell I own.
```

*Protocol reminders (§5 reddit-posts):* disclose first line ✓ · one subreddit only · reply window ≥3 h · preload comment scripts — expect "how much are the ads?" (policy verbatim) and "another VS clone" (specificity + genuine question back) · EDIT tags on any substantive change · judge effect by the 48 h curve, not day-of installs.

---

## 6. Pre-flight consistency checklist

- [ ] Version string `v1.1.0` identical in all four assets + store What's-new
- [ ] Goal figure reads **1,000,000 runs** everywhere; Streak Shield named identically
- [ ] Feature names verbatim: Instant Replays · Build Codes · Twin Flames
- [ ] Every credited finder (@moss_engine, @dawnrunner, @kestrel_writes) actually received their @Bug Hunter increment before posting
- [ ] Budget gag shows **$25** in both patch notes and Reddit; Discord omits it (channel voice)
- [ ] Replay buffer stated as 15 s in all copies (not 12 — that was yesterday's truth)
- [ ] Kill-switch verified: Remote Config flags default off; rollback = flag flip, not hotfix
- [ ] Tone check: read aloud once — anything sounding like a press release gets rewritten until it sounds like a person who owes the whale money

*Pack v1.0 — clone this file for Update 2 and change the facts, not the laws.*
