# AFTERGLOW — Discord Server Plan v1.0

> Companion to §19 (Launch & Marketing Checklist). Discord is **free**, needs **no hosting** (§14.6 stack), and does the heavy lifting no store page can: turning 50 engaged testers into your balance department, bug QA, and content engine.
> **Server law:** mirrors the game's design pillars — fast, readable, respectful of time, zero pay-to-win status games.

---

## 1. Goals (in order)

1. **Beta feedback pipeline** (P4) — structured reports a solo dev can triage in 30 min/day
2. **Retention surface** — daily-challenge bragging, recap-card flexing, streak accountability
3. **Content flywheel** — deaths/builds/clips posted here feed the TikTok calendar (`devlog-content-calendar.md`)
4. **Launch megaphone** — one ping reaches everyone who opted in

Success metric at global launch: ≥500 members, ≥20% weekly active, median bug report turnaround <48 h.

## 2. Channel layout

```
◤ WELCOME
├── #rules            6 rules max, pinned, no walls of text
├── #announcements    dev posts only · @everyone used ≤1×/week
└── #get-roles        self-assign pings (see §3)

◤ THE CITY (community)
├── #general          chat; off-topic allowed but threads encouraged
├── #recap-cards      share run cards (forum channel — image-first)
├── #clips            gameplay GIFs/clips; best-of-week gets reposted by dev
├── #death-poetry     suggested death messages (feeds docs/death-messages.md packs!)
└── #build-lab        build codes (AG-VOLT-7F3K2) + strategy talk

◤ FEEDBACK (beta+)
├── #bug-reports      FORUM channel, mandatory template (§4)
├── #balance-talk     feels-overall-power discussions; "Balance Friday" thread weekly
├── #feature-votes    forum + reactions = lightweight polling
└── #known-issues     live table: reported → confirmed → fixed-in-build X

◤ BETA HQ (role-gated: @Tester)
├── #beta-downloads   current APK/testing-track link + changelog
├── #beta-chat        tester coordination
└── #test-scripts     this week's focus ("please hammer Undercity hazards")

◤ DEV LOGS
├── #devblog          auto-crossposted TikTok/Shorts + itch.io devlogs
└── #roadmap          living roadmap summary; done/moving/next columns
```

**Anti-sprawl rule:** start with exactly these channels. A new channel must replace an old one or wait until >50 messages/day demand it.

## 3. Roles

| Role | How granted | Perks |
|---|---|---|
| **@Spark** | default | Everything above |
| **@Tester** | request form (Google Form, free) → manual grant at P4 | #beta-downloads, direct line to dev |
| **@Bug Hunter** | 3 confirmed non-duplicate reports | Name in patch credits + exclusive Discord badge color |
| **@Prism Council** | top 10 of each weekly season (synced manually, 5 min task) | Private channel #council, early patch notes |
| **@Ping Patch / @Ping Daily** | self-assign in #get-roles | opt-in notifications only — mirrors in-game notification respect policy |

Moderation starts as @Moderator = the dev + 1 trusted tester from beta cohort. Rules digest: (1) be decent, (2) no cheats/mods/APK sharing, (3) spoilers tagged until global+2 weeks, (4) self-promo only in #clips if it's actual gameplay, (5) dev has final say, (6) don't feed the whale (arguments die in threads).

## 4. Beta feedback workflow

### 4.1 Intake — two doors, one funnel

1. **In-game report button** (per QA plan §18): packages save-file slice, recent log, optional last-death clip → player attaches it in #bug-reports. 🔧 Full spec (capture list, `.zip` format, 3-screen flow, paste-ready template): **`docs/report-tool-spec.md`**.
2. **Direct forum post** using the pinned template:

```
Title: [biome] – short symptom        e.g. [Undercity] Spitter projectiles invisible on Low preset
Build: vX.Y (shown on results screen)
Device: model + Android version
Quality preset: Low/Med/High
Repro: 1) … 2) … 3) …
Expected vs got: …
Attachment: clip/save file if possible
Frequency: always / sometimes / once
```

Forum-channel tags: `crash` `visual` `balance` `ui` `audio` `performance`. Posts missing the template get the bouncy reply macro, not silence.

### 4.2 Triage (30 min/day, same time daily)

| Priority | Definition | Action |
|---|---|---|
| **P0** | Crash, save loss, progression hard-block, ad SDK failure loop | Hotfix path within 72 h; #known-issues immediately |
| **P1** | Feature broken, common visual/gameplay wrong | Next weekly build |
| **P2** | Annoyance, edge case | Backlog, batched |
| **P3** | Polish/nice-to-have | Tagged, revisited monthly |

Rules: every report gets a reaction within 24 h (👀 = seen, ✅ = reproduced, ❌ = can't reproduce + asked for more); duplicates are *linked*, never deleted (reporters keep their credit count); balance ≠ bugs — feelings go to #balance-talk.

### 4.3 Closing the loop (the retention trick)

Weekly **"Balance Friday"** post: what was fixed, what was nerfed and *why* (data screenshot), what's next. Every fixed bug names its reporter. This single ritual converts testers into evangelists — being credited beats being thanked. ✍️ Template + sample notes: **`docs/patch-notes.md`**.

## 5. Launch-event plan

| When | Event | Mechanics |
|---|---|---|
| L−7 days | **Countdown channel opens** (#launch-week): daily teaser + theory-crafting prompts | Hype without spam; each day unlocks one asset (icon, GIF, trailer still) |
| L−3 | Trailer premiere watch-party: voice channel + live commentary | Trailer drops on TikTok simultaneously |
| L−1 | **Last Supper Run**: dev attempts a Tier-3 no-upgrade run live; failure = launch-day bonus code for everyone | Stakes content; fails gracefully either way |
| **L-Day** | Hourly recap-card reposts in #announcements-adjacent thread; "first 100 global players" role @Dawnbringer | Scarcity role, zero cost |
| L+1 weekend | **Double-Shards Weekend** (matches GDD launch event) + in-Discord screenshot contest: best recap card caption | Winner's card becomes next video thumbnail |
| L+7 | **Season 1 kickoff** (§15.6): @Prism Council resets, rules explained in #build-lab | Converts launch spike into weekly habit |
| L+14 | First **Community Goal Event** progress post (§15.8 milestone framing) | Sets LiveOps rhythm |

Post-launch steady state: Balance Friday weekly · recap-card spotlight weekly · patch party in voice chat per release (~30 min, casual).

## 6. Free setup checklist ($0, one evening)

- [ ] Create server; apply channel layout above; upload icon (app icon spec) + banner
- [ ] Configure #get-roles self-assign (native roles, no bot needed at start)
- [ ] Set forum channels (#bug-reports, #feature-votes, #recap-cards) with template in guidelines field
- [ ] Webhook: GitHub Actions release → posts changelog to #beta-downloads automatically (GitHub free tier)
- [ ] Onboarding: community setup wizard, verification level medium, raid protection on during launch week
- [ ] Invite link in: game results screen ("Found a bug?" → report flow), itch.io page, press kit §1, TikTok bios
- [ ] Welcome message ends with one question ("What's your go-to genre?") — replies train the algorithm and start conversations

---

*Discord plan v1.0 — pairs with `devlog-content-calendar.md` (content flywheel) and GDD §15 (viral features feeding #recap-cards, #build-lab, seasons).*
