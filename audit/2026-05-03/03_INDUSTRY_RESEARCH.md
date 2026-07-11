# Industry Research — Reference Addon Patterns (2026-05-03)

Deep-dive analysis of 10 widely respected community addons to extract patterns the Ka0s standard should consider adopting (or explicitly reject). Per-addon raw reports under `_raw/_industry/<Addon>.md` are the evidence base; this file is the synthesized cross-cutting view.

| Addon | Stack | Repo | Raw report |
|---|---|---|---|
| DBM | Custom + LibStub | DeadlyBossMods/DeadlyBossMods | [DBM.md](_raw/_industry/DBM.md) |
| Big Wigs | Ace3 | BigWigsMods/BigWigs | [BigWigs.md](_raw/_industry/BigWigs.md) |
| Auctionator | Native Blizzard `Settings` + LibStub | Auctionator/Auctionator | [Auctionator.md](_raw/_industry/Auctionator.md) |
| Plater | DetailsFramework + LibStub | Tercioo/Plater-Nameplates | [Plater.md](_raw/_industry/Plater.md) |
| Plumber | Zero-lib (vanilla) | Peterodox/Plumber | [Plumber.md](_raw/_industry/Plumber.md) |
| Details! | DetailsFramework + LibStub | Tercioo/Details-Damage-Meter | [Details.md](_raw/_industry/Details.md) |
| WeakAuras | Ace3 + LibSerialize/LibDeflate | WeakAuras/WeakAuras2 | [WeakAuras.md](_raw/_industry/WeakAuras.md) |
| ElvUI | Private Ace3 fork | tukui-org/ElvUI | [ElvUI.md](_raw/_industry/ElvUI.md) |
| Bagnon | Custom (Sushi/Poncho/WildAddon) | Jaliborc/Bagnon | [Bagnon.md](_raw/_industry/Bagnon.md) |
| OmniCD | Hand-rolled mini-framework + LibStub | muleyo/OmniCD | [OmniCD.md](_raw/_industry/OmniCD.md) |

---

## 1. Stack distribution across the reference set

| Stack | Count | Addons |
|---|---|---|
| Ace3 (canonical) | 2 | BigWigs, WeakAuras |
| Ace3 (private fork) | 1 | ElvUI |
| Ace3 partial (LibStub + libs but no AceAddon) | 1 | OmniCD |
| Custom + LibStub only | 4 | DBM, Plater, Details!, Bagnon |
| Native Blizzard `Settings` API | 1 | Auctionator |
| Vanilla / zero lib | 1 | Plumber |

**Conclusion (relative to Ka0s scope):** Ace3 is correct for our standard but **not industry-default for top-tier addons**. The pattern is: small/medium addons use Ace3; megaprojects either fork Ace3 (ElvUI) or build their own mini-framework (DBM, Plater, Details!, Bagnon, OmniCD) for performance and version control. Auctionator and Plumber represent the "modern non-Ace" path used when the addon is UI-focused and lives inside Blizzard frames. Auctionator's analyst explicitly recommended **keep Ace3 for our collection** because we're a multi-addon collection that needs AceDB profiles, AceLocale namespacing, and LibStub-deduplicated embeds — costs Auctionator pays in `_G` pollution, no profiles, and forked source trees.

---

## 2. Convergent patterns — found in 4+ reference addons

These should be **codified into the Ka0s standard** in M4.

### 2.1 `local addonName, NS = ...` namespace bootstrap (8 of 10)
Every modern addon uses the loader's two varargs to share private state across files without globals. WeakAuras (`local addonName, Private = ...`), OmniCD (`local E, L, C, G = select(2, ...):unpack()`), ElvUI (tuple `unpack(ElvUI)`), Plater (`local addonId, platerInternal = ...`), Plumber, Bagnon, Auctionator, Details! all do this. **DBM and BigWigs** are the holdouts (they pre-date the pattern).

**Action:** mandate this in the standard. Optionally bias toward ElvUI/OmniCD's `unpack()` tuple since it gives every file 3-4 short upvalues for free.

### 2.2 `.pkgmeta` with externals + `move-folders` for monorepo→multi-addon (5 of 10)
BigWigs, DBM, Details!, Plumber, Bagnon all use the BigWigsMods packager to ship N installable addons from one git repo. **Externals — never vendored libs.** This is the de-facto 2026 standard for Ace3 lib management.

**Action (superseded by Standard v1.1):** this originally recommended `.pkgmeta` `externals:` for AceX libs; Ka0s now **vendors all libs** in `libs/` instead. Still mandate `.pkgmeta` for ignore lists and `move-folders:` for any future monorepo — just without an `externals:` block.

### 2.3 Multi-flavor TOC (one Interface line, many builds) (8 of 10)
`## Interface: 120005, 120007, 50504, 20505, 11508` style. Plater, Plumber, OmniCD (with per-flavor TOCs), Bagnon (3-TOC + runtime flag), and the rest support multiple WoW versions from a single source tree. Per-flavor *code branching* uses runtime flags (`E.isRetail`, `Addon.IsClassic`) or per-flavor *data files* swapped via TOC includes — never `if WOW_PROJECT_ID` ladders inline.

**Action:** mandate single-source multi-flavor; allow per-flavor `Spells_Mainline.xml`/`Defaults_Classic.lua` inclusion when data must differ.

### 2.4 Closed message bus (4 of 10)
BigWigs (`SendMessage`/`RegisterMessage`), Bagnon (`WildAddon` `SendSignal` after `MutexDelay` debounce), Plumber (CallbackRegistry), KickCD (already!) — modules don't call each other directly, they publish typed messages. Consumers re-derive state from messages. Decouples options UI from runtime, makes modules swappable, and is a free first-class testing seam.

**Action:** make this a hard rule: **modules never reach into each other's tables**; every cross-module signal is a named message with one publisher and zero-to-many subscribers.

### 2.5 Lazy/deferred load of options UI (4 of 10)
ElvUI (Options as a sibling addon loaded via OptionalDeps), WeakAuras (`WeakAurasOptions` is a separate addon), DBM (DBM-GUI separate), BigWigs (Options module loads on first open). Options code is inert until the panel opens.

**Action:** mandate "options is loaded on first `OpenConfig`" — either as a sibling addon (LoD) or as a deferred module.

### 2.6 Spell-ID-keyed CLEU dispatch (4 of 10)
BigWigs `mod:Log(subevent, fn, spellId, ...)`, DBM two-stage filter, Details! token-dispatched handlers with module upvalues, OmniCD per-spec spell tables. One frame, one event, O(1) hash dispatch. No combat-log handler should be a per-handler `RegisterEvent`.

**Action:** for any addon touching CLEU, mandate one shared frame + spellID hash table.

### 2.7 Locale fallback metatable (`__index = function(_,k) return k end`) (5 of 10)
WeakAuras, OmniCD, KickCD (already), Plumber, ElvUI all use the trick where missing locale keys return their key as English. Eliminates AceLocale's hard-error mode and lets translators ship at any % coverage. KickCD's hand-rolled locale (currently flagged as a deviation) is **actually industry-aligned**; we should make this the standard, not AceLocale's strict mode.

**Action:** locale module returns a metatable-wrapped table; AceLocale optional but not required.

### 2.8 Versioned wire prefix on serialized strings (3 of 10)
WeakAuras `!WA:2!`, Plater (Revision gate + UID + index validation), DBM-Test reports. Every export string starts with `<addon>:<version>!`, so v1 importers reject v2 cleanly. LibSerialize + LibDeflate, two encodings (`EncodeForPrint` for chat, `EncodeForWoWAddonChannel` for AceComm).

**Action:** if any Ka0s addon ships an export/import feature, mandate this template.

### 2.9 Object pooling for high-churn UI (3 of 10)
OmniCD `ObjectPoolMixin` (~80 lines), Plater UpdateAllPlates, Details! weak tables on segments. Roster churn / nameplate churn / segment GC become free.

**Action:** for any addon with N>10 dynamic frames, mandate Acquire/Release/HideAll pooling. Reference: OmniCD's 80-line pool.

### 2.10 Hot-path upvalue cache + explicit refresh (3 of 10)
Plater's `RefreshDBUpvalues()` flushes profile values into module locals (`DB_AURA_ENABLED`, etc.) and is called after every settings setter. Details! uses module-level upvalues for `UnitGUID`/`GetTime`. Eliminates per-frame table indirection.

**Action:** in any per-frame loop, locals shadow `db.foo`; settings writes call a `RefreshUpvalues()` after the write.

---

## 3. Notable single-addon patterns worth borrowing

### 3.1 BigWigs `.pkgmeta` template (BigWigs)
Already cited above. The literal file is the canonical template; copy it, change names, ship.

### 3.2 Plumber metadata-driven module registry
```
AddModule({
  name, dbKey, categoryID,
  validityCheck, toggleFunc,
  requiredDBValues, minimumTocVersion, newFeatureExpiry,
})
```
One declarative table replaces ad-hoc enable code. Each `toggleFunc(enabled)` is `pcall`-wrapped and runtime-toggleable — no `/reload` needed. **Adopt for any "feature toggle"-shaped addon** (e.g., prettychat).

### 3.3 Plumber `Locales/PostLoad.lua` for derived keys
Locale files contain canonical translations only; `PostLoad.lua` assigns aliases (`L[2806] = L[2706]`) so translators never duplicate work. **Adopt for any addon with multi-key strings.**

### 3.4 ElvUI two-phase module init (`RegisterInitialModule` vs `RegisterModule`)
Solves OnInitialize ordering without hand-rolled deps. **Adopt for any addon north of ~6 modules.** Below that, single-phase is enough.

### 3.5 Auctionator per-module `Manifest.xml` cascade
TOC `<Include>`s each module's manifest; modules own their file order. Near-zero merge conflict surface compared to flat TOC file lists. **Adopt only at the modular tier (≥10 files).**

### 3.6 Auctionator versioned public API namespace (`Addon.API.v1`)
Pin third-party-facing surface under `vN`. Future-proof for free. **Adopt for any addon exposing a public `_G[ADDON]` API.**

### 3.7 DBM Prototype Registry for load-order independence
~15 lines: a lazy table cache that lets a consumer file load before the producer with no error. **Adopt for any addon where TOC ordering has been fragile** (KickCD's bootstrap-namespace pattern is similar but doesn't go all the way to lazy resolution — DBM's is the cleaner version).

### 3.8 OmniCD per-zone profile trees
`C.Party.arena/pvp/party/raid` each carries full position/icons/visibility settings. `/oc m <zone>` toggles `detached`. KickCD treats all contexts equally; this is the right model for any group-context addon.

### 3.9 OmniCD declarative unit-frame-addon registry
`OmniCD.AddUnitFrameData({ELvUI = ..., VuhDo = ..., Grid2 = ..., Plexus = ..., Cell = ...})` — anchors to third-party UF addons via a registry, zero `if` ladders. **Critical for any party/raid-anchoring addon.**

### 3.10 Bagnon engine+presentation split
The "engine" (frame primitives, classes, settings, slash, locale, taint shims) lives in a sibling `BagBrother` addon; flavor addons ship ~9 files in `src/` that subclass and compose. **Aspirational for the Ka0s collection at large** — long-term, common helpers (Schema, slash dispatcher, Settings panel scaffold) could move into a `Ka0s-Core` sibling addon. Out of scope for this standard, but worth recording as a future direction.

### 3.11 Bagnon taint-safe bag-UI replacement recipe
- `hooksecurefunc` on `Toggle*` (don't replace).
- Guard with `debugstack():find('Manager')` to ignore Blizzard recursion.
- **Reparent** Blizzard frames to a hidden parent rather than `:Hide()` them.
- Never instantiate `MoneyFrame`; rebuild via `TooltipDataProcessor.AddLinePreCall` + `GetMoneyString()`.
- Ship `TaintLess.xml` as the first XML include.

This is the canonical recipe for taint-replacing any Blizzard UI. **Codify in the standard's "taint" section.**

---

## 4. Anti-patterns — what NOT to copy

Aggregated across all 10 reports:

1. **Hand-rolled options GUI replacing AceConfig** (DBM-GUI, ElvUI, Plater, OmniCD's LibOmniCDC fork). Maintenance debt is enormous; only justified when scale forces it. **For Ka0s addons: use AceConfig or `Settings.RegisterCanvasLayoutCategory` + raw AceGUI.**
2. **`SlashCmdList` if/elseif substring dispatcher** (DBM). Use AceConsole or the Ka0s schema-driven `COMMANDS` table pattern.
3. **`X-License: All Rights Reserved`** (BigWigs, Bagnon). Hostile to forks/packagers. **Stay on MIT.**
4. **Hand-maintained per-flavor TOCs that drift** (DBM 6 TOCs, Auctionator 8 `Source_*` folders). Use the packager's `enable-toc-creation: yes` instead.
5. **Co-locating options UI with runtime** (WeakAuras did this until they split it). Above ~5 panels of options, split options into a sibling addon.
6. **Executing user-supplied Lua without a sandbox** (Plater explicitly does NOT sandbox; WeakAuras does). If you ever ship import strings that contain code, you must `setfenv` + whitelist or you've shipped a vulnerability. **For Ka0s: ban executable user content.**
7. **Mixed pt_BR/English identifiers fossilized in public API** (Details! `_detalhes`, `SairDoCombate`). Once shipped in SVs, untouchable forever. **Lock public identifiers to a single language at v1.**
8. **`X-Curse-Project-ID`/`X-Wago-ID` absence** (every addon publishing without these). Required for packager-driven publishing.
9. **Forking Ace libraries privately** (ElvUI's `Ace3-ElvUI`, OmniCD's `LibOmniCDC`). Blocks every Ace3 update. **Use `AceGUI:RegisterWidgetType` for widget extensions; never fork the lib.**
10. **`ElvUI = {...}` global-by-design** (ElvUI). Only viable when your addon *is* the UI. Stay namespaced.
11. **30+ flat `Plater_*.lua` files at root** (Plater). Folder-group by feature once you're past ~10 files.
12. **`Plater.lua` at 13.8k lines / 555KB** (Plater). Diff-hostile, IDE-hostile. **Hard cap: ~1500 LOC per file; split when you exceed it.**
13. **Cross-addon relative-path XML includes** (`..\..\BagBrother\core\core.xml`) (Bagnon). Bypasses `Dependencies`; fragile.
14. **`#`-commented modules in shipped TOC** (Plumber). Author bisect tool leaks into release.
15. **No `GetLocale()` gate on locale files** (Plumber). All locales load for every player; "last write wins" is implicit.

---

## 5. Validation against Ka0s in-house decisions

Cross-checking the 10 "decisions to lock in M4" from `02_CURRENT_STATE.md` against industry practice:

| Decision | Industry signal | Recommendation for M4 |
|---|---|---|
| AceConsole vs raw `SLASH_*` | DBM hand-rolls; everyone else either uses AceConsole or routes through their bus | **Adopt AceConsole** for slash registration; keep our schema-driven `COMMANDS` table as the dispatcher tier |
| AceConfig (vendored unused) | BigWigs, WeakAuras use AceConfig; ElvUI, Plater, DBM hand-roll; trend is `Settings.RegisterCanvasLayoutCategory` for entry + raw AceGUI for content | **Keep current Ka0s pattern** (Blizzard Settings + raw AceGUI). Remove AceConfig from libs since none of the 5 actually use it. Only re-add for Profiles sub-page if AceDBOptions is wanted |
| AceLocale | OmniCD, KickCD, WeakAuras all use metatable fallback (not AceLocale strict). Plumber is non-Ace entirely | **Adopt the metatable-fallback pattern**, not AceLocale strict. Codify as "locale module exports a table with `__index` returning the key on miss" |
| `embeds.xml` vs TOC-only | Bagnon, Auctionator (Manifest), DBM use XML; modern non-Ace (Plumber, Auctionator core) and BigWigs use TOC-only | **TOC-only at the flat tier (≤8 files); `embeds.xml` only at the modular tier where file groups need to be authored as modules** |
| `libs/` casing | All 10 reference addons lowercase | **Mandate `libs/`** (prettychat is the outlier) |
| Folder name casing | All 10 PascalCase | **Mandate PascalCase** (prettychat → PrettyChat) |
| Two-tier (flat ≤3 files vs modular) | WhatGroup analyst's recommendation; supported by industry — Plumber/Auctionator/Bagnon range from ~9 files (flat-ish) to massive (modular) | **Codify two tiers explicitly.** Tier 1 ≤8 files flat, Tier 2 modular (KickCD layout) |
| Slash naming | All 2-3 char lowercase across Ka0s; industry varies but converges on short prefix | **Codify** `/<2-3 lowercase>` |
| `<Addon>DB` SV naming | Ka0s already converged | **Codify** |
| Deprecated-API policy | OmniCD has Compat module; KickCD has one but doesn't use it consistently; Plater has explicit per-flavor includes | **Mandate `Compat.lua`** as the only legitimate caller of pre-deprecation APIs |

---

## 6. New decisions surfaced by industry research (not in the in-house list)

These weren't in the Ka0s-only analysis but are worth taking a position on in M4:

1. **Vendoring over externals** *(revised in Standard v1.1, 2026-07-11 — originally the reverse).* Vendor and commit all AceX libs in `libs/`; do **not** use `.pkgmeta` `externals:`. Ka0s prioritizes self-contained, offline-installable addons over the repo-size savings of externals. Still prune vendored-*unused* libs (the real "vendored AceConfig unused" issue) — vendor only what you `LibStub()`.
2. **`Compat.lua` per addon** for deprecated-API shims (`GetSpecialization*`, `GetSpellInfo` post-11.x, `UnitAura`).
3. **Hot-path upvalue cache** — any addon with a per-frame loop must cache db values into module locals and refresh on settings change.
4. **Object pool standard** — for any addon with N>10 dynamic frames, use OmniCD-style pool.
5. **Closed message bus** — modules never reach into each other's tables.
6. **Locale `__index → key` fallback** — replaces AceLocale strict mode.
7. **Versioned export-string prefix** — for any addon with import/export.
8. **Hard-cap file LOC at ~1500.** ConsumableMaster's `SlashCommands.lua` (1257) is at the edge; KickCD's `IconGrid.lua` (1753) is over.
9. **Lazy options loading** — options code inert until first panel open.
10. **`X-Curse-Project-ID` / `X-Wago-ID` mandatory** for any published TOC.

---

**Status:** M3 complete. Proceeding to M4 (synthesize `01_STANDARD.md`).
