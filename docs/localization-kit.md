# AFTERGLOW — Localization Starter Kit v1.0

> Companion to §12.4 (Platform Targets) and every doc that says *"longest locale: German"* — this is why that sentence keeps appearing.
> **Budget law:** $0 translation services. Phased rollout driven by player data; drafts come from MT, *quality* comes from native-speaking volunteers in our own Discord (credited in-game — the Bug Hunter economy extends to words).

---

## 1. Language phases

| Phase | Languages | When | Quality level |
|---|---|---|---|
| **L0 — Launch** | English (source) | Global M0 | Native |
| **L1 — Early** | German · Portuguese-BR · Spanish-LATAM | M+1–3 | MT draft + volunteer pass |
| **L2 — Soft-launch debt** | Indonesian · Filipino | M+2–4 (matches PH/ID soft launch, §17) | Volunteer-first |
| **L3 — Demand-driven** | French · Polish · Turkish | Only when players > threshold | Standard |
| **Store-only** | Japanese · Korean · Simplified Chinese · Russian | Listing pages localized, game UI stays EN | Marketing copy only |

**Rationale:** DE stresses layouts hardest (the canonical long-string locale), PT-BR/ES-419 are massive Android markets with strong survivors-like appetite, ID/FIL honor soft-launch communities who beta-tested us. JA/KO/ZH get real UI versions only when retention data justifies the font + quality investment (see §5 font problem).

## 2. Technical setup ($0, engine-native)

- **Format:** Godot's official **CSV → `.translation`** pipeline. One master `strings.csv`: `key,en,de,pt_BR,es_419,…` — imported at build; missing languages auto-fallback to English per-string (partial languages ship safely).
- **Key naming:** `context.element` — `death.swarm_overwhelm`, `card.nova.name`, `menu.settings_title`. Context lives in the key so translators never guess.
- **Pseudo-loc mode** (free truncation insurance): debug toggle replaces every string with `[Àççöûñţ]`-style padded variants (+40% length, bracketed). Every screenshot/QA sweep runs pseudo-loc first — catches clipped buttons before any human translator exists.
- **Extraction rule:** no literal strings in code. Ever. The linter greps for quoted user-facing literals in scripts; CI fails the build on matches.

## 3. String-length budgets (base → localized ceiling)

Expansion factors: **DE +35% · FI none used · PT-BR +20% · ES-419 +25% · ID −10% · FIL +15%.**

| Context | Base (EN) | Ceiling (any locale) | Mechanism when over |
|---|---|---|---|
| Buttons / chips | ≤14 chars | 22 chars | Two-line wrap allowed once |
| Upgrade card names ("5-word rule") | ≤24 chars | 32 chars | Autoshrink 100→85% |
| Upgrade card descriptions | ≤60 chars | 80 chars | Second line |
| Death message headlines | ≤90 chars | 120 chars | Recap-card autoshrink (§15.1) |
| Settings labels | ≤28 chars | 38 chars | Wraps, never ellipsizes |
| Recap-card stat labels | ≤16 chars | 22 chars | Caps-lock tracking reduced before shrink |
| Hero timer / scores | numerals only | locale digit grouping | Never translated |

**Hard veto:** any string that must truncate mid-word in any L1 language gets rewritten shorter in English first. Source text is the cheapest place to fix length.

## 4. Glossary — terms that don't translate literally

### Keep in English everywhere
| Term | Why |
|---|---|
| **AFTERGLOW**, **#AFTERGLOW** | Brand |
| **Spark · Ember · Volt · Wick · Moth · Lumen** | Names transliterate; they're also all light-puns that die in translation — the *bios* around them carry the flavor instead |
| **survivors-like** | Genre term; localized scenes keep it untranslated (like "roguelike") |
| **Balance Friday** | Community ritual name; explained, never translated |
| **Shards** currency icon does the work | Icon + number reads universally; word translates freely though |

### Transcreate, don't translate (meaning over words)
| Term | Guidance |
|---|---|
| **"Outshine the dark."** | The one line worth spending real effort on. Target: imperative, ≤4 words, light-vs-dark contrast preserved. DE draft: *"Überstrahle die Dunkelheit."* — reviewers may rewrite entirely |
| **THE DEVOURER / THE CHOIR / NULL PRIME** | Epithets translate (*Der Verschlinger*, *O Coro*…); keep definite-article drama |
| **Promenade · Undercity · Spire** | Translate meaningfully (place-feel over literalness); consistency across lore fragments mandatory |
| **Death-message humor** | Dry understatement doesn't cross borders. Rule: translators may **rewrite the joke entirely** keeping trigger + length; a localized joke that lands beats an accurate one that doesn't. Each pack line tagged `{locale-rewritten}` for analytics comparison |
| **"Respect the player"** policy lines | Legal-adjacent tone; translate precisely, not cleverly |

## 5. The font problem (honest engineering note)

Bundled fonts **Chakra Petch + Rajdhani cover Latin + Latin-ext + Vietnamese** — fine through L2. They do **not** cover Cyrillic or CJK:

- **RU/UA** would need adding a Cyrillic-capable display face (e.g., subsetted Noto Sans pairing) → deferred until L3 demand exists.
- **JA/KO/ZH** are store-only (§1) partly for this reason: shipping CJK without proper glyph coverage and a native-quality pass would violate the respect-the-player law. Revisit post-year-one with real revenue.

## 6. Community translation workflow

```
MT draft (DeepL/Google, free tiers) → pseudo-loc QA gate
→ Discord call for native volunteers (@Translator role, credited in About panel
   next to Bug Hunters — same economy)
→ volunteer review in shared sheet (per-string comments, thread-style)
→ dev merges weekly with Balance Friday cadence
→ live behind Remote Config per-language flag → flip when reviewer signs off
```

Rules: volunteers translate *into* their native language only; death-message rewrite proposals go through #death-poetry for community vote; every shipped language's lead reviewer gets a special recap-card frame (**Polyglot**) — status rewards stay cosmetic, always.

## 7. Store listing localization

Priority order follows §1 phases: listing pages (title suffix, short/full description from `store-listing.md`) localize **before** game UI for that language — listings cost nothing and convert installs even while UI falls back to English. Localized screenshots reuse frames 1–4 with translated caption overlays; frame 5 stays EN until UI ships.

## 8. Acceptance checklist

- [ ] Zero hardcoded strings in GDScript (CI grep green)
- [ ] Pseudo-loc sweep: all tabs, full run, results screen, recap card — zero clipped labels at 130% UI scale
- [ ] German build: settings menu, level-up cards, one full boss fight reviewed end-to-end
- [ ] Fallback audit: delete de.translation → app runs fully EN, no key-names visible ever (`menu.settings_title` must never render as itself)
- [ ] Death-line lengths verified in longest L1 locale against recap-card autoshrink floor
- [ ] Translator credits present in About panel before first non-EN flag flips

---

*Loc kit v1.0 — English is a dialect; make everyone else feel like the default too.*
