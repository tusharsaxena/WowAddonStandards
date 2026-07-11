# Current-State Analysis — Five Ka0s Addons (2026-05-03)

**Source of truth:** Read-only audit of source code, not docs. Per-addon deep dives live under `_raw/<Addon>.md` and are the evidence base for everything below. This document is the synthesized cross-cutting view.

**Inputs:**

| Addon | Raw report | LOC (largest file) | File count |
|---|---|---|---|
| AbsorbTracker | [_raw/AbsorbTracker.md](_raw/AbsorbTracker.md) | `SlashCommands.lua` 355 | ~16 |
| ConsumableMaster | [_raw/ConsumableMaster.md](_raw/ConsumableMaster.md) | `SlashCommands.lua` 1257 | ~25 |
| KickCD | [_raw/KickCD.md](_raw/KickCD.md) | `modules/IconGrid.lua` 1753 | ~30 (modular) |
| prettychat | [_raw/prettychat.md](_raw/prettychat.md) | `Config.lua` ~600 | ~10 |
| WhatGroup | [_raw/WhatGroup.md](_raw/WhatGroup.md) | `WhatGroup_Settings.lua` 1056 | 3 flat |

---

## 1. Comparison matrix

Legend: ✅ present and idiomatic · ◐ present but partial / non-idiomatic · ❌ absent · ⚠️ present but problematic

| Dimension | AbsorbTracker | ConsumableMaster | KickCD | prettychat | WhatGroup |
|---|---|---|---|---|---|
| TOC `Interface` (multi-line) | ✅ 120000,120001,120005 | ✅ multi | ✅ multi | ✅ | ✅ |
| `SavedVariables` (per-char vs global) | global | global | global | global | global |
| `X-Curse-Project-ID` / `X-Wago-ID` | ❌ | ❌ | ❌ | ❌ | ❌ |
| `.pkgmeta` | ❌ | ❌ | ❌ | ❌ | ❌ |
| `.luacheckrc` | ❌ | ❌ | ❌ | ❌ | ❌ |
| Folder layout | flat + `Panel/` | flat + `defaults/` `settings/` | **modular** (`core/`/`modules/`/`defaults/`/`settings/`/`locales/`) | flat | flat (3 files) |
| `embeds.xml` | ❌ (TOC-only) | ✅ | ❌ (TOC-only) | ❌ | ❌ |
| Lib-loader pattern | TOC | embeds.xml | TOC | TOC | TOC |
| **Architecture pattern** | AceAddon as carrier only | AceDB-direct + `KCM.*` | AceAddon + named modules + bootstrap-ns promotion | `_G[ADDON]` override | `_G[ADDON]` flat |
| AceDB-3.0 | ✅ (with shim fallback) | ✅ | ✅ | ◐ raw SV | ✅ |
| AceDBOptions / Profiles page | ◐ optional | ❌ | ❌ | ❌ | ❌ |
| AceConfig | ⚠️ vendored, used only for Profiles | ⚠️ **vendored, unused** | ⚠️ **vendored, unused** | ⚠️ **vendored, unused** | ❌ |
| Options UI approach | Blizzard `Settings.RegisterCanvasLayout` + raw AceGUI | same | same | same | same |
| **Schema-as-single-source** | ✅ `Schema.lua` | ✅ `KCM.Schema` | ✅ `KickCD.Settings.Schema` | ✅ `Schema.lua` | ✅ inline in `WhatGroup_Settings` |
| Slash dispatcher | table-driven | `COMMANDS` table | ordered dispatch table | table-driven via `COMMANDS` | helper-driven |
| AceConsole `:RegisterChatCommand` | ◐ raw `SLASH_*` | ◐ raw | ◐ raw | ◐ raw | ◐ raw |
| Localization (AceLocale) | ❌ | ❌ | ⚠️ hand-rolled metatable, AceLocale vendored unused | ❌ (English-only) | ❌ (relies on `_G` Blizzard strings) |
| AceEvent | ✅ | ✅ | ✅ + `Util.RegisterTargetEvent` | ◐ partial | ✅ |
| Combat-lockdown discipline | ✅ | ✅ | ✅ | ✅ (combat gate on `OpenConfig`) | ✅ (3-layer cascade) |
| Taint discipline | good | **excellent** (macro firewall) | good | **excellent** (no chat hooks at all) | **excellent** (deferred SettingsPanel/UISpecialFrames) |
| Debug module / on-off SV | ◐ in-mem only | ✅ `Debug.lua` | ◐ partial | ❌ | ❌ |
| Defensive nil / `pcall` at API edges | ✅ | ✅ | ✅ | ✅ | ✅ |
| Deprecated APIs | none flagged | none flagged | ⚠️ `GetSpecialization*` raw | ❌ none | ❌ none |
| Tests / smoke tests / harness | docs only | docs only | docs only | docs only | docs only |
| README / CLAUDE.md / ARCHITECTURE.md | ✅ no drift | ✅ minor | ◐ drift on counts | ✅ minor | ✅ no drift |
| Prior `reviews/` folder | ✅ 2026-05-02 | ✅ 2026-05-02 | ✅ 2026-05-02 | ✅ ≥3 reviews | ✅ recent |

---

## 2. Convergent strengths (already de-facto Ka0s standards)

These are patterns present in **3+ addons** and worth canonicalizing in `03_STANDARDS.md`:

1. **Schema-as-single-source.** Every addon has a `Schema` (or equivalent) table where each row defines: SV path, default, validator, label, widget, scope. The same table feeds the AceGUI panel AND the `/cmd get|set|list|reset` slash dispatcher. Found verbatim in AbsorbTracker (`Schema.lua`), ConsumableMaster (`KCM.Schema`), KickCD (`KickCD.Settings.Schema`), prettychat (`Schema.lua`), and inline in WhatGroup (`Settings.Schema`). KickCD's implementation is the most complete; AbsorbTracker's is the cleanest in 200 lines.

2. **Single write seam.** All settings mutations route through one helper (`SetByPath` / `Schema.Set` / `Helpers.Set`) so panel, slash, and reset paths cannot drift in `onChange` semantics.

3. **Blizzard `Settings.RegisterCanvasLayoutCategory` + raw AceGUI hybrid.** Five out of five addons use the same options-UI strategy: register a canvas-layout category with the Blizzard panel, then render content with raw AceGUI inside it. **No addon uses AceConfig dialogs**, even when AceConfig is vendored.

4. **Deferred / lazy first-`OnShow` rendering** in panel sub-pages. AbsorbTracker, KickCD, ConsumableMaster, WhatGroup all do this. Result: zero AceGUI work for panels the user never opens, plus correct width-based layout.

5. **Combat-lockdown gating** at the panel-open and panel-build seams (`InCombatLockdown()` returning the user back, with deferred replay on `PLAYER_REGEN_ENABLED`). Universal.

6. **Three-or-more-layer fallback discipline.** AbsorbTracker has AceDB→flat-table→deepcopy-defaults; prettychat has `nil → true → SV` cascade; WhatGroup has 3-layer combat safety. Defensive resilience is a Ka0s house style.

7. **Coalescing / debounced refresh.** ConsumableMaster's `Pipeline.Recompute` with `scoreCache`, KickCD's message bus, AbsorbTracker's reused `pendingArgs`. Consistent perf discipline.

8. **`reviews/<DATE>/` audit folders** with five-artifact bundles (findings, proposed changes, smoke tests, execution plan, final summary) feeding documented remediation. This is itself a standard worth keeping and codifying.

## 3. Convergent weaknesses (5-of-5 deviations)

These are gaps present in **all five** addons and are the highest-priority items for the standard:

1. **No `.pkgmeta`.** All addons rely on manual zip-and-upload. CurseForge/Wago packager would handle externals, ignore lists, and changelog. (CI is out of scope per your call, but `.pkgmeta` itself is independently valuable.)

2. **No `.luacheckrc`.** No static analysis at all. Catching `_G` leaks, undefined globals, and unused locals would be near-free with the BigWigsMods/luacheckrc-wow snippet.

3. **No `X-Curse-Project-ID` / `X-Wago-ID`** in TOCs even though the addons appear to be published. Required for proper packager publishing flow.

4. **AceConsole unused.** Every addon hand-rolls `SLASH_*` registration. AceConsole's `:RegisterChatCommand` would unify and shorten this — and we already vendor AceConsole-3.0 in three addons.

5. **AceConfig vendored but unused.** Four out of five addons embed AceConfig-3.0 and never load it. Either commit to using it for at least the Profiles page, or remove from `libs/`.

6. **Localization is essentially absent.** No addon uses AceLocale despite vendoring it (KickCD); prettychat ships English-only; WhatGroup leans on Blizzard `_G` strings. For published addons, this is the biggest external-quality gap.

## 4. Per-addon defining traits

### AbsorbTracker
- Cleanest schema implementation in the collection (272 LOC for full panel+slash wiring).
- Documentation drift is **zero** — May 2 review fixed it; reverify in M5.
- Dead `AceAddon-3.0` weight: lib loaded but not used as a registry, just as an AceDB carrier.
- `Panel/ScrollPatch.lua` reaches into AceGUI ScrollFrame private fields with no version guard — fragile across AceGUI bumps.
- `/at debug` toggle is in-memory only; resets every login.

### ConsumableMaster
- **Hardest taint firewall:** `MacroManager` is the sole caller of `CreateMacro/EditMacro`; `DeleteMacro` is never called. Every other module is provably pure.
- **Most monolithic file:** `SlashCommands.lua` at 1257 LOC is unusual — slash should be a thin dispatcher.
- `embeds.xml` is the only addon using XML loading. Unique.
- `schemaVersion = 1` declared with no migration code — latent v2 trap.
- AceConfig-3.0 fully embedded but unreferenced — pure dead weight.

### KickCD
- **Closest to the target standard.** Modular `core/`/`modules/`/`defaults/`/`settings/`/`locales/` layout. Bootstrap-namespace promoted in place to AceAddon. Closed message bus with five named messages and one-sender-each contract. **The folder layout itself is the strongest internal candidate to lift into `03_STANDARDS.md`.**
- Two files too monolithic: `modules/IconGrid.lua` 1753 LOC, `settings/Panel.lua` 1258 LOC.
- Hand-rolled fallback-metatable locale despite AceLocale vendored — pick one.
- Uses deprecated `GetSpecialization`/`GetSpecializationInfo` directly — needs Compat shim.
- Most vendored-but-unloaded libs (AceLocale, AceBucket, AceComm, AceHook, AceSerializer, AceTab, AceTimer).

### prettychat
- **Architecturally taint-free chat formatter** by overriding `_G[GLOBALNAME]` instead of hooking chat events. Genuinely rare and valuable.
- `LOOT_ITEM_CREATED_SELF[_MULTIPLE]` cross-registration race — `pairs()` ordering is non-deterministic.
- 22,879-entry `GlobalStrings/` dictionary loaded eagerly for ~80 actually-referenced globals — material RAM waste. The LoD intent in the sub-TOC is defeated by the parent TOC.
- Lowercase folder name vs siblings; `Libs/` vs `libs/`. Naming drift.

### WhatGroup
- **Exemplary taint discipline.** Every Logout-taint hazard is reproduced and patched: hooks at file-load, Settings/StaticPopup/UISpecialFrames deferred, panel-body builds wrapped in `C_Timer.After(0, ...)`.
- 3 files; right-sized as flat.
- `WhatGroup_Settings.lua` at 1056 LOC mixes 5 concerns and is the only file warranting a within-folder peel.
- Uses `IsInGroup()` only; no deprecated `GetRaidRosterInfo`/`GetNumGroupMembers`. Cleaner than typical 2026 codebases.
- **Recommendation: stay flat.** Forcing the modular standard here would scatter the capture state machine for no gain. Instead, the standard should formally allow a "flat" tier for ≤3-file addons and a "modular" tier for everything else.

## 5. Cross-cutting decisions to lock in M4

The standards doc must take a position on each of these, since the addons disagree:

1. **AceConsole** — adopt across all addons, retire raw `SLASH_*` registration, OR formalize raw `SLASH_*` and remove AceConsole from libs.
2. **AceConfig** — adopt for at least the Profiles sub-page across all addons, OR remove from all `libs/`.
3. **AceLocale** — adopt as the single localization mechanism, OR formalize the hand-rolled fallback-metatable pattern (KickCD's). Mixed state today is the worst outcome.
4. **embeds.xml vs TOC-only** — pick one. ConsumableMaster is the outlier with `embeds.xml`.
5. **Folder casing** — `libs/` vs `Libs/`. Pick lowercase (4 of 5 addons agree).
6. **Folder name casing** — `prettychat` is the outlier (lowercase). Decide if addon folder names should be the canonical `PascalCase`.
7. **Two-tier layout standard** — codify both `flat (≤3 files)` and `modular (KickCD layout)` as legal, with explicit rules for when each applies. WhatGroup's analyst made the strongest case for not over-modularizing.
8. **Slash naming convention** — `/at`, `/cm`, `/kcd`, `/pc`, `/wg`. All 2-3 chars, lowercase. Already converged — codify.
9. **SavedVariables naming** — `<Addon>DB`. Already converged — codify.
10. **Deprecated-API policy** — every addon should have a `Compat.lua` (KickCD has one) that shims `GetSpecialization`, `GetSpellInfo` post-11.x, etc., and is the only legitimate caller of pre-deprecation APIs.

---

## 6. Open data points to chase in M3 / M4

Items where the in-house evidence is insufficient and we need industry research to answer:

- Is `Settings.RegisterCanvasLayoutCategory` + raw AceGUI an industry pattern, or are the popular addons using AceConfig dialogs / their own panel framework? (Affects decision #2.)
- Locale fallback strategy: hand-rolled metatable (KickCD) vs AceLocale silent-mode vs hardcoded enUS — what do BigWigs / Plumber / OmniCD do?
- Macro-management taint patterns: how does Auctionator / WeakAuras handle protected-API access from non-secure code? Validate ConsumableMaster's firewall against industry practice.
- `embeds.xml` vs TOC-only file inclusion: what's the modern preference in 2026?
- Module-self-registration patterns: does AceAddon `:NewModule` win, or do popular addons use bootstrap-namespace promotion (KickCD's pattern)?

---

**Status:** M2 complete. Proceeding to M3 (industry research) per auto-mode and locked scope.
