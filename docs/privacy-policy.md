# AFTERGLOW — Privacy Policy & Data Safety Answers v1.0

> Companion to §14.3 (Consent & Compliance). Two artifacts: **(A)** the public privacy policy (host free on GitHub Pages; link required by Play before publishing), **(B)** the Play Console **Data safety** form answers, pre-mapped.
> Fill every `[BRACKET]` before publishing. Revisit both whenever §14's stack changes — the form is a legal statement, not marketing.

---

# PART A — Privacy Policy (public text)

## AFTERGLOW Privacy Policy

*Effective date: [DATE]* · *Developer: [STUDIO/DEV NAME] ("we")*

**Short version:** AFTERGLOW works fully offline. If you're online, limited technical data helps us fix crashes, understand gameplay balance, and show ads. We never sell your personal data, we don't want your name, and there are no accounts.

### 1. What we collect

| Data | When | Why |
|---|---|---|
| Crash logs & diagnostics (Firebase Crashlytics) | Only when online, after a crash/error | Fixing bugs |
| Anonymous usage events (GameAnalytics / Firebase Analytics): e.g., run length, upgrade choices, settings toggles — no identifiers tied to you personally | Only when online | Balancing the game, improving features |
| Advertising data processed by Google AdMob: device identifier, approximate location derived from IP, ad interaction data | Only when online and ads load | Serving and measuring ads |

**Never collected:** your name, email, contacts, photos, microphone/camera access, precise location, or anything you type outside feedback you voluntarily send. The game requests exactly one permission: INTERNET.

### 2. Ads & your choices

AFTERGLOW shows ads through **Google AdMob** (Google's policies: policies.google.com/technologies/ads). Before ads load for EEA/UK users, Google's consent form lets you choose personalized or non-personalized ads; elsewhere, non-personalized ads may apply until you opt in via device settings. You can reset or disable advertising identifiers any time in Android Settings → Privacy → Ads. Purchasing **Remove Ads** eliminates interstitial and banner ads permanently (optional rewarded videos stay, because they only appear when *you* ask for them).

### 3. Offline mode

No internet = no collection. Gameplay, saves, and progression work entirely on-device; nothing queues up to transmit later except standard crash/analytics delivery once you're back online.

### 4. Storage & security

Your progress saves locally on your device. Optional cloud saves use Google Play Games Services under Google's privacy policy. Data in transit uses TLS encryption.

### 5. Children

AFTERGLOW is rated Teen / PEGI 12 and is **not directed at children under 13**, does not participate in Google's Families program, and does not knowingly collect data from children. If you believe a child provided personal information, contact us and we will delete it.

### 6. Your rights & data deletion

EEA/UK (GDPR), California (CCPA), and elsewhere: you may request access to, correction of, or deletion of data associated with your installs. Because we hold no identity-linked records, deleting the game removes local data immediately; for cloud saves or analytics/ad-data requests, email **[PRIVACY EMAIL]** — we respond within 30 days. California residents may additionally exercise "Do Not Sell/Share" rights — note that we do not sell personal information as defined by CCPA.

### 7. Third-party services

Google AdMob (ads) · Firebase (Crashlytics, Analytics, Remote Config) · GameAnalytics · Google Play Games Services (optional leaderboards/saves). Each processes data under its own policy; links listed at [POLICY URL]/third-parties.

### 8. Changes & contact

We'll update this page with a new effective date when practices change; material changes also get an in-game notice. Questions/deletion requests: **[PRIVACY EMAIL]**.

---

# PART B — Play Console Data safety form answers

> Answer flow: *Does your app collect or share any of the required data types?* → **Yes**

## B1. Collected & shared matrix

| Data type | Collected? | Shared? | Purpose | Type (Ephemeral/Required/Optional) |
|---|---|---|---|---|
| **Device or other IDs** (advertising ID) | Yes | Yes — AdMob/ad partners | Advertising or marketing; Analytics | Optional |
| **Approximate location** (IP-derived, via AdMob) | Yes | Yes — AdMob/ad partners | Advertising or marketing | Optional |
| **App interactions** (gameplay events, session length) | Yes | No | Analytics | Optional |
| **Crash logs** | Yes | No | App functionality, Analytics | Optional |
| **Diagnostics** (other performance data) | Yes | No | Analytics | Optional |

*Nothing else applies: no name/email/address, no financial data (Play handles purchases — we never see payment details), no health, no messages, no photos/media, no files, no calendar, no precise location, no contacts.*

## B2. Form questions

| Question | Answer |
|---|---|
| Is all of the data collected encrypted in transit? | **Yes** (all listed services use TLS) |
| Do you provide a way for users to request data deletion? | **Yes** ([PRIVACY EMAIL]; local data removed by uninstalling) |
| Committed to Families Policy? | **No** (Teen rating; not child-directed) |
| Is this data ephemeral (processed without retention)? | No — standard retention windows of the listed providers |
| Personal-data sharing based on user consent? | Yes — EEA/UK ad personalization gated behind UMP consent; non-personalized fallback otherwise |

## B3. Pre-submission checklist

- [ ] Privacy policy live at public URL; linked in: Play listing, in-game settings, first-boot consent flow
- [ ] UMP SDK integrated and tested in EEA sim (consent appears *before* first ad request — §14.3)
- [ ] AdMob account: no personalized-ads-for-unknown-consent misconfiguration; test units swapped for production IDs only after this passes
- [ ] Data safety answers re-verified against final SDK list at release candidate (adding any SDK = re-audit)
- [ ] Deletion-request inbox monitored ([PRIVACY EMAIL]); 30-day SLA calendared
- [ ] Remote Config defaults documented (no data-hungry surprises shipped via flags)

---

*Privacy pack v1.0 — boring on purpose. Honest data practice is a feature; this document is its spec.*
