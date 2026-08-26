# AFTERGLOW — Press Kit & itch.io Page Copy v1.0

> Companion to §19 (Launch & Marketing Checklist). Everything here is written to be pasted directly into an itch.io page, a GitHub Pages press site (free hosting), or an email to a journalist/creator.
> **Voice reminder:** dry, punchy, confident. We never beg, never hype-shout, never use exclamation marks in body copy.

---

## 1. Fact sheet

| Field | Value |
|---|---|
| Title | **AFTERGLOW** |
| Subtitle | Outshine the dark. |
| Genre | Arena survival roguelite ("survivors-like") |
| Platform | Android 8.0+ (phones & tablets) |
| Players | Single-player, offline-capable |
| Price | Free. No pay-to-win. No energy timers. Ever. |
| Monetization | Optional rewarded ads + frequency-capped interstitials · "Remove Ads" one-time purchase post-launch |
| Release | Soft launch [MONTH YEAR] · Global [MONTH YEAR] *(fill from roadmap §17)* |
| Engine | Godot 4 (MIT) |
| Developer | [STUDIO / DEV NAME] — solo developer |
| Contact | [email] · Press kit: [github-pages URL] · Discord: [invite] |

## 2. Tagline options (pick per placement)

1. **Outshine the dark.** ← canonical (matches GDD high concept)
2. The last spark versus everything.
3. One thumb. Ten thousand shadows.
4. Survive the swarm. Become the light.
5. Eight minutes to outshine a city of dark.
6. Death is content. Glory is optional. *(community/itch flavor)*
7. Beautifully doomed. *(store A/B test candidate)*

## 3. Pitches

**One-liner (store "summary" field, ≤80 chars):**
> Survive neon swarms of shadows in a one-thumb roguelite that respects your time.

**Short pitch (~50 words, press emails):**
> AFTERGLOW is a free Android roguelite where you're the last spark of light in an abandoned neon city. Weapons fire themselves; you move, dodge, and choose the build. Runs take eight minutes, every death pays out progress, and nothing interrupts your game — or your group chat silence — uninvited.

**Medium pitch (~100 words, itch.io top):**
> The city went dark. You didn't. AFTERGLOW drops you into abandoned neon districts as the final spark of light, surrounded by shades that want you snuffed. Combat fires itself — your job is positioning, greed management, and picking one of three upgrades every forty-five seconds until the screen turns into fireworks. Runs last five to ten minutes. Every run earns permanent upgrades. Every death generates a shareable neon stat card, because failures this pretty deserve an audience. No energy timers, no paywalls, no ads mid-combat. Just you, one thumb, and ten thousand shadows.

## 4. Feature bullets (player-facing)

- **One thumb, total control** — floating joystick anywhere your thumb lands; weapons aim themselves
- **A new build every run** — 6 weapons × evolutions, passives, and 3 characters; the meta-game is the game
- **5–10 minute runs** — designed for commutes and breaks, tuned to never throttle your phone
- **Neon graphics on any device** — glow, particles, and dynamic lighting with automatic quality presets down to budget phones
- **Every death is content** — auto-generated share cards, meme death messages, instant replay clips
- **Daily challenge** — the whole world plays the same seeded run each day; streaks and global ranks
- **Respectful by design** — no forced interruptions mid-combat, rewarded ads always opt-in, offline-friendly
- **Zero servers, zero accounts** — your progress lives on your device; leaderboards ride Google Play

*(itch.io variant adds:)*
- **Free on Google Play at launch; beta builds live here first**

## 5. itch.io page body template

```
[COVER IMAGE — see asset checklist]

Outshine the dark.

The city went dark. You didn't. [medium pitch]

== FEATURES ==
[feature bullets]

== CURRENT STATUS ==
[Beta / Demo — vX.Y]. Core loop complete: 3 biomes, 3 bosses,
6 weapon families, daily challenge, share cards. Beta feedback
shapes balance before the Play Store launch.

== FEEDBACK ==
Discord: [invite] · In-game feedback button sends a report file
you can attach anywhere. Bug reports with death clips get fixed first.

== CREDITS ==
Design/code/art/noise: [name]
Engine: Godot 4 · Fonts: Chakra Petch, Rajdhani (OFL) · SFX: CC0/libraries
```

**itch.io metadata:** Genre: Action → Survival · Tags: `roguelite`, `survivors-like`, `arcade`, `neon`, `android`, `bullet-heaven`, `singleplayer` · Kind: Downloadable (APK) + later "In development" devlog posts.

## 6. FAQ

**Players / store Q&A**
- **Is it really free?** Yes. Optional rewarded ads accelerate *choices* (revive, double rewards). Nothing gameplay-gating is ever sold.
- **Are ads forced on me?** Interstitials appear only between runs — capped, skippable after a few seconds, never during combat, never after a boss victory. Rewarded ads are always opt-in. One purchase removes interstitials/banners forever.
- **Does it work offline?** Fully playable offline. Ads, leaderboards, and cloud saves simply go quiet.
- **What data do you collect?** Crash reports and anonymous gameplay analytics only. No accounts, no contacts, no location. Privacy policy: [link].
- **Will it run on my phone?** If it has Android 8+ it runs; quality presets auto-adjust down to budget hardware.

**Press / creators**
- **Review keys / early access?** Android F2P — just grab the beta via [itch/Play link]; happy to add anyone to the internal testing track: [email].
- **Can I monetize videos?** Yes, blanket permission for let's-plays, streams, and reaction content. Clips of our game are marketing we can't buy.
- **Embargo?** None. Ship content whenever.
- **Why another survivors-like?** Because the genre's power fantasy deserves better than spreadsheet art. We compete on feel, readability, and respecting the player — not novelty for its own sake.
- **Solo dev? How long?** ~9 months part-time, Godot 4, zero outside funding. The budget section of our design doc is honestly our favorite feature.

## 7. Developer boilerplate

> **[STUDIO NAME]** is [one person / a small team] making small, polished games with big-feeling presentation. We believe mobile players deserve games that respect their time, their battery, and their intelligence. AFTERGLOW is our first release. [Portfolio link]

Pull-quote bank (for others to quote us):
- "We designed the death screen before the tutorial."
- "If an ad interrupts a boss fight, we've failed. Full stop."
- "Good graphics is a lighting budget, not a polygon count."

## 8. Asset checklist

**Core kit (zip on GitHub Pages, versioned folders `/v1/`):**
- [ ] Logo pack: wordmark SVG + PNG @ 1x/2x/4x, dark-bg and light-bg variants, clear-space guide
- [ ] App icon 512×512 PNG (+ adaptive icon layers) — geometry, glow recipe & 48 px gauntlet in **`docs/app-icon-spec.md`**
- [ ] Screenshots: 5× phone (9:16, 1080×2340) + 2× tablet — matching Play Store set
- [ ] GIF set (≤5 s each, <8 MB): evolution moment, boss entrance, level-up card flow, recap card generation
- [ ] Trailer: 30 s cut (1080p MP4 + vertical 9:16 crop), captions burned-in-free version included — full beat sheet: **`docs/trailer-script.md`**
- [ ] Fact sheet PDF (this doc §1–4, branded)
- [ ] Cover art: itch capsule **630×500**, project banner 960×320, made in Krita/Inkscape ($0)
- [ ] Team/dev photo + logo (press love faces)
- [ ] LICENSES.txt — font/engine/asset attributions

**Rules:** GIFs exported at 30 fps max, palette-optimized (glow survives); trailer opens on the *worst* moment then explodes — pattern-interrupt for muted autoplay feeds.

## 9. Launch-week email template (subject + 80 words)

> **Subject:** New Android roguelite: AFTERGLOW — neon, brutal, respectful of ad-haters
>
> Hi [name] — quick one: I solo-developed AFTERGLOW, a neon survivors-like for Android where weapons fire themselves and every death makes a shareable card. It's free, offline-first, and its entire business model is refusing to interrupt people. Beta link + full press kit (assets, fact sheet, GIFs): [URL]. Happy to answer anything — even skeptical questions. Especially those.
>
> [Name], [studio], [contact]

---

*Press kit v1.0 — fill bracketed fields before publishing. Host the kit on GitHub Pages (§14.6 stack) so links survive.*
