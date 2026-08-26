# AFTERGLOW — Services Setup Guide v1.0

> Step-by-step companion for configuring every free service the game needs, **one service at a time**: configure → share non-secret details → verify → next. This file is the durable record — chat sessions die, this doc doesn't.
> **Budget law:** everything here is free-tier unless marked 💰 (exactly one: Play Console $25 lifetime).

---

## Security rules (read once, obey always)

1. **Never share in chat:** passwords, 2FA codes, API keys/secrets, recovery codes, service-account JSON files.
2. **Safe to share:** account usernames, repo URLs, project IDs, package name, App IDs — these are identifiers, not credentials.
3. When we reach SDK integration, keys go directly into Godot project config files on your machine — never pasted into chat.
4. Every account: recovery email + phone set on day one; password manager recommended.

**Golden rule:** use ONE Gmail/Google account for all Google services (Firebase, AdMob, Play Console, Play Games Services) — linking between them becomes one click and recovery stays sane.

---

## Locked decisions

| Decision | Value | Locked |
|---|---|---|
| GitHub identity | `arvanidh` | 2026-08-25 |
| **Android package name** | **`com.arvanidh.afterglow`** | 2026-08-25 — PERMANENT once published. Type identically in Firebase, AdMob, GameAnalytics, Play Console. Never hyphenate, never uppercase. |

---

## Master order & status

| # | Service | Purpose | Depends on | Status |
|---|---|---|---|---|
| 1 | **GitHub** | Code + docs home, free CI later | nothing | ✅ DONE (`arvanidh`, repo public) |
| 2 | **Firebase** (Spark free) | Analytics, Remote Config, Crashlytics | package name decided | ✅ DONE (`afterglow-32efb`, Spark, pkg registered) |
| 3 | **Google AdMob** | Rewarded/interstitial/banner revenue | package name (+ Firebase link optional) | ✅ DONE (App ID issued; pkg name to add in App settings; Firebase link deferred) |
| 4 | **GameAnalytics** | Gameplay KPIs: D1 retention, funnels | package name | ✅ DONE (Org `Arvanidh Games`, Studio `main`, GameKey recorded) |
| 5 | **itch.io** | Beta distribution + devlog home | nothing | ✅ DONE (profile live w/ bio; project draft hidden ✓) |
| 6 | **Discord server** | Community HQ (plan ready in `discord-server-plan.md`) | nothing | ✅ DONE (`discord.gg/tXgRjAS3y` verified live) |
| — | *Local toolchain* *(guided session)* | Godot 4 LTS + Android export templates + JDK 17 + Android SDK + signing keystore | after #1 ideally | ✅ DONE (auto-installed 2026-08-26 — see toolchain section for real paths) |
| 7 💰 | **Google Play Console → Play Games Services** | Store listing; leaderboards + cloud saves | signup submitted 2026-08-26 | 🟡 IN PROGRESS — identity verification pending (user completing in coming days). ⛔ Does **NOT** gate development |

*Order logic: identity first (GitHub), then package-name-tied consoles while nothing depends on store approval, distribution/community whenever convenient, Play last because it costs money and gates nothing above it.*

---

## Service #1 — GitHub

**Goal:** one private-or-public repo holding docs now, game code during P0. Free Actions CI builds APKs from month ~6.

### Steps

1. Go to **github.com → Sign up**.
   - **Username matters:** it appears in URLs, commit credits, and likely becomes part of your Android package name (`com.<username>.afterglow`). Pick something you'd print on a store listing. Lowercase, no spaces.
2. Verify email address (Settings → Emails).
3. Enable **2FA** immediately (Settings → Password and authentication): authenticator app method; download recovery codes and store them offline.
4. Free plan is enough — select it if asked.
5. Create repository: **New repository**
   - Name: `afterglow`
   - Description: `One thumb vs ten thousand shadows. Neon roguelite built in Godot 4.`
   - Visibility: **Public recommended** (open-dev marketing synergy: devlogs link to it, r/godot credibility, zero-cost portfolio). Private is fine if cautious — I just can't verify it remotely; you'd confirm with a screenshot instead.
   - Do **NOT** initialize with README / .gitignore / license — our local `docs/` folder becomes the first push during bootstrap, and license choice gets made deliberately then (MIT typical).
6. Bookmark the repo URL.

### Report back (safe to share)

- [ ] GitHub username
- [ ] Repo URL
- [ ] Public or Private?

### Verification (I do)

- Public repo: fetch URL, confirm existence, naming, description.
- Private: you paste a screenshot description; we proceed on trust.

### Done when

Repo exists, 2FA on, username doubles as future package-name segment.

---

## Services #2–#7 (steps delivered in-session as we reach each)

### #2 Firebase — FULL WALKTHROUGH 🟡

Use the **golden Google account** (one Gmail for Firebase + AdMob + Play Console).

1. Go to **console.firebase.google.com** → signed in with the golden account → **Create a project**
2. Project name: `afterglow`
3. Google Analytics prompt: **Enable** (free; powers all §16 KPIs) → Create → wait for provisioning
4. Gear icon → **Usage and billing** → confirm plan reads **Spark (free)**. Never upgrade to Blaze.
5. Project Overview → click the **Android robot icon** → register app:
   - Package name: `com.arvanidh.afterglow` *(exact)*
   - App nickname: `AFTERGLOW`
   - Debug signing SHA-1: **skip** (added later, once the keystore exists)
6. Download **`google-services.json`** → store locally, e.g. `afterglow/config/android/`. Not secret (ships inside APKs) but keep it OUT of the public git repo — `.gitignore` it; we'll set API-key restrictions during bootstrap.
7. Enable products (left menu):
   - **Analytics** — already live; open its tab once to confirm the app appears
   - **Crashlytics** — click Get started (activation only; SDK wires up in-engine later)
   - **Remote Config** — just open it once. Create NO flags yet (kill-switch defaults come with real features per LiveOps law)
8. Touch nothing else: no Firestore, no Functions, no Auth — zero-server law.

**Report back (safe):** Project ID (Settings → General, looks like `afterglow-xxxxx`) · plan shows Spark · package name registered exactly · json file downloaded.

### #3 Google AdMob — FULL WALKTHROUGH 🟡

Same golden Google account.

1. Go to **apps.admob.com** → sign in → first-time setup: country (this becomes your payment address region — choose where you actually live/bank) + billing currency (choose carefully; hard to change after first payment)
2. **Apps → Add app** → Platform **Android** → "**No**" / *not listed on a store yet* → Name `AFTERGLOW`
3. Confirm/enter package name `com.arvanidh.afterglow` if prompted
4. Copy the generated **App ID** (`ca-app-pub-XXXXXXXX~YYYYYYY`) — public by design, ships inside every APK
5. **Link Firebase:** Apps → AFTERGLOW → App settings → Link to Firebase → pick project `afterglow-32efb` (one click since same account)
6. **Create ZERO ad units today.** Units get made when we wire the SDK (P3) so each placement gets purposeful IDs. Dev builds always use Google's public TEST IDs anyway — clicking your own live ads = policy ban.
7. Payment/identity verification: skip until prompted (required only before first payout).

**Report back (safe):** the App ID string · Firebase link status shown as connected.

### #4 GameAnalytics — FULL WALKTHROUGH 🟡

1. Go to **gameanalytics.com** → Sign up (Google sign-in with the golden account is fine)
2. Dashboard → **New game** → Name `AFTERGLOW` · Platform **Android** · Package name `com.arvanidh.afterglow`
3. Open the game's settings/info panel → locate **Game Key** + **Secret Key**
4. 🔴 The **Secret Key is a real credential** — save it locally beside google-services.json (`C:\Users\acer\afterglow\config\`), NEVER pasted into chat or committed to git
5. The **Game Key is an identifier** — that one comes back to me for verification
6. Touch nothing else: event schema (progression/design events per GDD §16) gets configured during engine integration, free tier covers everything

**Report back:** Game Key string only + confirmation the secret is saved safely.

*New-game form mapping (UI as of setup): Title `AFTERGLOW` · Platform Android · SDK integration Godot · Store Google Play · Bundle ID `com.arvanidh.afterglow` · **Google Play licensing key: leave EMPTY** (comes later from Play Console; optional forever). Hierarchy requires creating **Organization** (`Arvanidh Games`) + **Studio** (`main`) first — both instant, no verification.*

### #5 itch.io — FULL WALKTHROUGH 🟡

Purely creative/public — nothing sensitive.

1. Sign up at **itch.io** → username `arvanidh` (URL consistency: `arvanidh.itch.io`)
2. Verify email → enable 2FA (Account settings → security)
3. Profile setup: display name `arvanidh` · one-line bio: *"Solo dev building AFTERGLOW — one thumb vs ten thousand shadows."* · avatar placeholder fine until app-icon beauty render exists
4. **Creator Dashboard → Create a new project** (itch calls pages "projects"):
   - Kind of project: **Downloadable**
   - Title: `AFTERGLOW` → URL auto-derives to `arvanidh.itch.io/afterglow` ✓
5. Keep the page **unpublished/draft** until devlog #1 ships (P0 week 1 per `itch-devlog-series.md`) — cadence law: max 1 devlog/month
6. Fill metadata closer to page launch, all pre-written in `press-kit.md`: cover 630×500, tags (`roguelite`, `bullet-heaven`, `neon`…), pricing Free, "beta builds live here first"

**Report back:** profile URL + confirmation the project page exists in draft.

### #6 Discord server — FULL WALKTHROUGH 🟡

Built per `discord-server-plan.md`. One evening; build in this order:

1. **Account:** discord.com → username `arvanidh` → verify email → enable 2FA
2. **Create server:** Add a Server → Create My Own → name `AFTERGLOW` (icon placeholder until beauty render)
3. **Categories + channels, exact layout from plan §2:**
   - ◤ WELCOME: `#rules` · `#announcements` · `#get-roles`
   - ◤ THE CITY: `#general` · `#recap-cards` *(forum)* · `#clips` · `#death-poetry` · `#build-lab`
   - ◤ FEEDBACK: `#bug-reports` *(forum)* · `#balance-talk` · `#feature-votes` *(forum)* · `#known-issues`
   - ◤ BETA HQ *(role-gated @Tester)*: `#beta-downloads` · `#beta-chat` · `#test-scripts`
   - ◤ DEV LOGS: `#devblog` · `#roadmap`
   - Anti-sprawl law: no other channels
4. **Forum channels:** on #bug-reports set tags `crash` `visual` `balance` `ui` `audio` `performance`; paste the §4.1 report template into its guidelines
5. **Roles:** create @Tester · @Bug Hunter · @Prism Council · opt-in @Ping Patch / @Ping Daily; post role-request instructions in #get-roles (manual grants fine at this size — no bots needed)
6. **Rules:** paste the six-rule digest from plan §3 into #rules
7. Server settings → Verification Level: Medium; enable raid protection later during launch week only
8. GitHub webhook → #beta-downloads comes with CI during bootstrap, not now

**Report back:** an instant-invite link (Server → invite → edit link → never expire) + confirmation channels match.


### Local toolchain session — ✅ DONE 2026-08-26 (machine-installed)

All free. ~10 GB disk for the Android SDK route.

**A. Godot 4.x LTS**
1. godotengine.org → Download → **Godot 4.x LTS**, Windows 64-bit standard build (portable exe — no installer)
2. Keep it somewhere permanent, e.g. `C:\Godot\Godot_v4.exe`; pin to taskbar

**B. JDK 17**
1. adoptium.net → Temurin **17 (LTS)** → Windows x64 MSI → install with "Set JAVA_HOME" option checked
2. Verify: open Command Prompt → `java -version` → must print 17.x

**C. Android SDK (via Android Studio — simplest GUI path)**
1. developer.android.com/studio → install Android Studio (free)
2. Open it → More Actions → **SDK Manager**: check *Android SDK Platform* (latest), *SDK Platform-Tools*, *Build-Tools*, and the **Command-line Tools** under SDK Tools tab → Apply
3. Note your SDK path (shown at top of SDK Manager; typically `C:\Users\acer\AppData\Local\Android\Sdk`)

**D. Wire Godot to Android**
1. In Godot: Editor Settings → Export → Android: set **Java SDK Path** + **Android SDK Path**
2. Editor menu → Manage Export Templates → **Download and Install** (~1 GB)

**E. Signing keystore — the one-way door 🔐**
Run once, in Command Prompt:
```
keytool -genkeypair -v -keystore C:\Users\acer\afterglow\config\afterglow-release.keystore -alias afterglow -keyalg RSA -keysize 2048 -validity 10000
```
It asks for two passwords + name/org — record BOTH passwords in a password manager immediately. Then copy the keystore file to TWO offline places (USB drive + cloud drive).
⚠️ Lose this file after launch = Play Store can never accept an update to your app again. New listing, zero reviews, zero installs. This is the single most important backup in the whole project.

**F. Register the SHA-1 fingerprint with Firebase** *(completes the field we skipped in #2)*
Extract the keystore's public fingerprint:
```
keytool -list -v -keystore C:\Users\acer\afterglow\config\afterglow-release.keystore -alias afterglow
```
If `keytool` isn't found, use the JDK's full path, e.g. `"C:\Program Files\Eclipse Adoptium\jdk-17..\bin\keytool.exe"`. Copy the **SHA1:** line (it's public by design — printed inside every signed APK), then Firebase console → ⚙ Project settings → Your apps → AFTERGLOW (Android) → **Add fingerprint** → paste → Save.

**Completion record — what was actually done (deviations from the walkthrough above):**

| Component | Plan | Reality |
|---|---|---|
| Godot | manual download | ✅ **4.7.2-stable** → `C:\Users\acer\afterglow\tools\godot\Godot_v4.7.2-stable_win64.exe` (verified `--version`) |
| JDK | Temurin 17 MSI, system-wide | ✅ **Portable 17.0.20.1 zip** instead — system Java 21 untouched → `tools\jdk17\jdk-17.0.20.1+1\bin\` |
| Android SDK | fresh install | ✅ **Already present**: `%LOCALAPPDATA%\Android\Sdk` — platforms 33→36.1, build-tools 34→37, platform-tools w/ adb, licenses accepted |
| Export templates | in-editor downloader | ✅ Placed manually → `%APPDATA%\Godot\export_templates\4.7.2.stable\` (android_debug.apk + android_release.apk confirmed) |
| Keystore | user-typed passwords | ✅ Machine-generated random password, never displayed in chat → `C:\Users\acer\afterglow\config\afterglow-release.keystore` · alias `afterglow` · RSA-2048 · valid 10,000 days · password stored ONLY in local `KEYSTORE-PASSWORD.txt` |
| SHA-1 | — | ✅ Extracted `F2:71:6A:9A:0E:A7:EB:0E:E2:71:38:40:C3:13:5B:EF:27:98:99:AA` (public) and handed over for Firebase registration |

**Security actions — ALL COMPLETE 2026-08-26:** ① keystore password moved to user's password manager; `KEYSTORE-PASSWORD.txt` deleted (verified — config dir was empty) ② user reports backups made ③ SHA-1 registered in Firebase per user. **Location incident:** the .keystore had been *moved* to `C:\arjun\game\` — verified intact (2,622 bytes, generation timestamp, SHA-256 `479C370B…89D9`) and a byte-identical copy restored to canonical `C:\Users\acer\afterglow\config\`. Rule going forward: the `config\` file is what build tooling references; every other copy must be a copy of THAT file, never a second keystore. ⚠️ Open item: user to re-confirm the off-machine (USB/cloud) backup holds this exact file.

~~④ Godot editor paths~~ → **✅ CONFIGURED & USER-CONFIRMED 2026-08-26:** `%APPDATA%\Godot\editor_settings-4.tres` holds `export/android/java_sdk_path` = portable JDK 17 + `android_sdk_path` = local Sdk; validated via headless-editor load test AND confirmed by user in the GUI (initially showed system JDK 21 — corrected to portable 17 in Editor Settings, re-verified on disk). User opens the project via Project Manager → Import.

### #7 Play Console 💰 → Play Games Services — FULL WALKTHROUGH 🟡

Issued 2026-08-26. Phased: only A (and B if approved quickly) happen today.

**Phase A — Purchase & identity (~15 min):**
1. **play.google.com/console** → sign in with the **golden Google account**
2. Account type: **Personal** (solo dev; Organization requires a D-U-N-S number)
3. **Developer name** — this becomes your public store brand: recommended `Arvanidh Games` (matches GameAnalytics org). Decide before typing.
4. Pay **$25 once, lifetime** (card/UPI per region)
5. **Identity verification:** government ID, sometimes address + video check; approval takes minutes to days

**Phase B — Create the app entry (after account approval):**
6. All apps → **Create app**: Name `AFTERGLOW` · Default language English (US) · **Game** · **Free** · accept both declarations
7. ⚠️ The package name is NOT typed at creation — it locks automatically from the **first uploaded APK/AAB** (ours will carry `com.arvanidh.afterglow`)

**Phase C — The 12-tester production gate (2026 policy, shapes the beta plan):**
8. Personal accounts created after Nov 2023 must run a **closed test with ≥12 opted-in testers, continuously for the last 14 days**, then apply for production access via Google's questionnaire
9. AFTERGLOW's answer already exists: Discord @Tester role + itch.io page + communities like r/AndroidClosedTesting for recruitment. This slots into the P3/beta phase — **not today**
10. Internal testing track has no tester minimum — use it for yourself as soon as the first APK exists

**Phase D — later guided sessions (all content pre-written):** store listing ← `store-listing.md` · Data safety ← `privacy-policy.md` Part B · content-rating questionnaire · Play Games Services (leaderboards/achievements)

**Report back (safe):** developer name chosen · payment confirmed · ID verification submitted/approved · app entry created?

---

## Progress log

| Date | Milestone | Verified? |
|---|---|---|
| 2026-08-25 | Guide created; Service #1 (GitHub) instructions issued | — |
| 2026-08-25 | **GitHub verified:** `github.com/arvanidh/afterglow`, public, description matches, intentionally empty. Username `arvanidh` becomes package-name segment. 2FA assumed done per instructions. | ✅ fetched URL, HTTP 200, all fields match |
| 2026-08-25 | **Package name locked:** `com.arvanidh.afterglow` — user chose via options. Firebase walkthrough issued. | ✅ user-selected |
| 2026-08-25 | **Firebase verified:** project `afterglow-32efb`, Spark plan, Android app registered w/ exact package name, google-services.json downloaded (advise moving Downloads → `C:\Users\acer\afterglow\config\`; gitignore later). | ✅ identifiers checked |
| 2026-08-25 | **AdMob verified:** App ID `ca-app-pub-7504785764801971~6083580629` (format-valid). UI drift noted: pkg-name prompt skipped for unpublished apps → user adds manually via App settings → App information. Firebase↔AdMob link pending/optional — non-blocking, retry anytime pre-launch. | ✅ App ID checked; link deferred |
| 2026-08-25 | **GameAnalytics verified:** Org `Arvanidh Games` / Studio `main`; Game Key `e20ce14f6d54b7584b0d36751bcf2a6f` format-valid. ⚠️ SECRET KEY accidentally pasted in chat — flagged; rotation advised if UI offers; risk assessed negligible pre-launch (zero traffic). Going forward: credentials local-only. itch.io walkthrough issued. | ✅ game key checked; secret incident logged |
| 2026-08-25 | **itch.io verified:** profile `itch.io/profile/arvanidh` live with bio; project `afterglow` saved as draft — public URL correctly 404s until devlog #1 publishes it. Discord walkthrough issued. | ✅ fetched both URLs |
| 2026-08-25 | **Discord verified:** invite `discord.gg/tXgRjAS3y` resolves to live server "AFTERGLOW". Roles/rules/verification-level steps delivered and confirmed applied. Toolchain walkthrough issued. | ✅ fetched invite, HTTP 200 |

---

| 2026-08-26 | **Toolchain COMPLETE (self-installed):** Godot 4.7.2-stable verified via `--version`; portable JDK 17.0.20.1 verified; existing SDK reused (no download); export templates 4.7.2.stable installed to %APPDATA%; release keystore generated with chat-hidden password; SHA-1 issued for Firebase. User actions pending: password→manager, keystore dual backup, Firebase fingerprint. (Godot path fields eliminated same day — editor settings auto-injected + headless load-test passed.) Only **#7 Play Console ($25)** remains on the roadmap. | ✅ CLI-verified (java -version, template listing, keytool -list, godot --version) |
| 2026-08-26 | **Security steps closed:** password→manager (txt deletion verified), keystore found at `C:\arjun\game\` after being moved — hash-verified and restored to canonical `config\`; SHA-1 pasted into Firebase per user. Play Console walkthrough issued, incl. researched production gate: personal accounts need **≥12 opted-in testers continuously over the last 14 days** before applying for production access. | ✅ SHA-256 hash match + user confirmations |
| 2026-08-26 | **Play Console: application SUBMITTED** — identity verification pending (user finishing in coming days). Ruling recorded: Play Console gates only store distribution (closed testing track, listing, production); development/building/local testing/itch+Discord beta all run without it. **Development authorized to start immediately.** ⚠️ Same-day housekeeping flags: `KEYSTORE-PASSWORD.txt` reappeared in `config\` and `settings.txt` holds plaintext credentials — both must move to password manager & be deleted BEFORE git repo bootstrap. | 🟡 awaiting Google verification; flags issued |
| 2026-08-26 | **Day One — repo BOOTSTRAPPED & PUSHED:** working home moved by user to `C:\arjun\game`; credential txt files confirmed deleted ✓. Git repo initialized there; commit `966a58d` = 28 files / 3,759 lines (.gitignore + README.md + all 26 docs). Pre-commit secret audit **CLEAN** — keystore + google-services.json sit at root but are gitignored and were never staged. First push blocked 403: machine held stale GitHub credentials for account `mmodit` → solved WITHOUT touching them via dedicated SSH keypair (`~/.ssh/afterglow-github`, public half added to arvanidh's GitHub, repo-local `core.sshCommand` pins it). Remote = `git@github.com:arvanidh/afterglow.git`. | ✅ ssh -T greets "Hi arvanidh" · push landed · fetched repo page, README renders, HTTP 200 |
| 2026-08-26 | **Godot project SCAFFOLDED + FIRST APK (commit `0dfdb0d`, pushed):** GDD §12.2 structure implemented — autoloads GameState/RunState/SaveSystem/Analytics/AdsManager/Audio, first-light boot scene (touch sparks + FPS + analytics seam), portrait mobile renderer, ETC2/ASTC enabled. Export = non-Gradle prebuilt template (Gradle build deferred until ad-plugin milestone needs it), arm64-only, signed with system debug keystore. **APK: `builds/afterglow-first.apk` (28.4 MB)** — gitignored as designed; export_presets.cfg stays local-only forever (future signing-secret home). **Installed via adb onto user's moto g73 5G (ZD22299C4L) — launched successfully** (com.arvanidh.afterglow window live). Dev loop now: edit → headless export → adb install, one command away. | ✅ headless import clean · export exit 0 · push landed · install Success |
| 2026-08-26 | **P0 CORE LOOP BUILT (commit `faa2846`, pushed):** menu→run→death→menu playable per GDD §5–§7 — floating joystick, Spark i-frames/knockback/trail, Pulse Bolt auto-targeting, Shade/Swarmlet chasers with tracking glow-eyes, vacuuming light motes, seeded spawn director with swarmlet pack events, juice set (kill bursts, damage vignette, screen shake, haptic tick), results panel persisting best time + shard payouts. **Headless arena smoke test caught 2 real bugs pre-export** (untyped-loop-var type inference; missing STATS key) — fixed, re-smoked clean. APK `builds/afterglow-p0.apk` (28.4 MB) exported; installed via adb after USB re-plug — launched clean, no script errors in logcat. **First playable build in user's hands.** | ✅ smoke clean · push landed · install Success · runtime log clean |
| 2026-08-26 | **v0.0.3 — PLAYTEST UPDATE (commit `82442b9`, pushed):** user feedback (no sound / want levels / want graphical kills / want guns+powerups) → ① nine procedural WAVs baked by `tools/make_sfx.gd` + pooled Audio autoload ② discrete LEVELS with fixed enemy counts, clear banners, +1 HP reward, seeded shuffle ③ kill juice: shockwave rings (FxRing pool), 22-particle two-tone bursts ④ weapon crates → Orbit Blades / Nova Burst join Pulse Bolt; Overdrive/Shield/Magnet Storm orbs; guaranteed clear-drop alternating crate/orb. Smoke test caught unregistered-class + const-array-of-scripts issues pre-export; fixed; clean 40s sim; installed to device, 0 runtime errors. | ✅ push landed · install Success · log clean |

---

*Setup guide v1.0 — seven accounts, one $25 bill, zero recurring hosting. Configure slowly, verify each, never rush recovery codes.*
