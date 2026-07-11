# TECHNICAL_DESIGN — WhatGroup

**Tier:** 1 (flat). **Stays flat.** No promotion to Tier 2.
**Source root:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/`
**Standards basis:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/_standards/2026-05-03/03_STANDARDS.md`
**Deviations:** WG-1 .. WG-11 from `04_DEVIATIONS.md`.

---

## 1. Goal

Bring WhatGroup to full standards compliance for Tier 1 layout while:

- Keeping the addon **flat** (no `core/`, `modules/`, `settings/`, `locales/` subfolders).
- Performing an **in-folder peel** of the oversized `WhatGroup_Settings.lua` (1056 LOC, 5 mixed concerns) into 2-3 sibling files in the addon root, without introducing subfolders.
- Preserving the addon's strongest properties: 3-layer combat-lockdown cascade, capture state machine (`notifiedFor` / `notifyGen`), and deferred Settings/StaticPopup/UISpecialFrames hook-installation taint discipline.

Out of explicit non-goals: do NOT modularize, do NOT touch `WhatGroup.lua` capture state machine, do NOT change LFG API integration, do NOT bump version (user's call per CLAUDE.md).

## 2. Scope

WG-1 missing `.pkgmeta`; WG-2 missing `.luacheckrc`; WG-3 missing `X-Curse-Project-ID`/`X-Wago-ID` in TOC; WG-4 in-folder peel of `WhatGroup_Settings.lua`; WG-5 missing `Compat.lua`; WG-6 missing locale module shell; WG-7 in-memory-only debug toggle (must persist in SV); WG-8 hand-rolled `SLASH_*` (migrate to AceConsole); WG-9 `appID`-as-`searchResultID` reuse undocumented; WG-10 fuzzy public surface on `_G.WhatGroup`; WG-11 cargo-cult `## DefaultState: enabled` in TOC.

The standard explicitly endorses staying flat for WhatGroup (`04_DEVIATIONS.md` "What's deliberately not on this list" → "WhatGroup staying Tier 1 flat. Standard explicitly allows it; its analyst made the case. No deviation.").

## 3. HLD — System view

### 3.1 Current layout (3 source `.lua` files)

```
WhatGroup/
├── WhatGroup.toc                          (24 lines)
├── WhatGroup.lua                          (921 LOC) — bootstrap, hooks, capture SM, slash, chat
├── WhatGroup_Settings.lua               (1056 LOC) — schema + helpers + validation + panel + scrollbar patch
├── WhatGroup_Frame.lua                    (319 LOC) — popup + teleport button
├── ARCHITECTURE.md  CLAUDE.md  README.md  LICENSE
├── libs/   media/   docs/   reviews/2026-05-02/
```

No `.pkgmeta`. No `.luacheckrc`. No `Compat.lua`. No `Locale.lua`.

### 3.2 Post-remediation layout (5-6 source `.lua` files; still ≤8 Tier-1 cap)

```
WhatGroup/
├── WhatGroup.toc                          (~28 lines: + X-IDs, + new lua entries, - DefaultState)
├── WhatGroup.lua                          (~930 LOC: AceConsole migration, persistent debug toggle wiring)
├── Compat.lua                             (NEW, ~30 LOC: empty shim scaffold)
├── Locale.lua                             (NEW, ~40 LOC: NS.L metatable + enUS table)
├── WhatGroup_Settings_Schema.lua          (NEW, ~250 LOC: Schema rows + helpers + BuildDefaults + RestoreDefaults + ValidateSchema + StaticPopup)
├── WhatGroup_Settings_Panel.lua           (NEW, ~400 LOC: header + CreatePanel + Section + widget creators + RenderField + RenderSchema + InlineButton + BuildMainContent + Settings.Register)
├── WhatGroup_Settings_Scrollbar.lua       (NEW, ~120 LOC: PatchAlwaysShowScrollbar + ensureScroll)  [optional — folds into Panel if it lands ≤500 LOC combined]
├── WhatGroup_Frame.lua                    (319 LOC, untouched)
├── ARCHITECTURE.md  CLAUDE.md  README.md  LICENSE  .pkgmeta  .luacheckrc
├── libs/   media/   docs/   reviews/<DATE>/
```

Source `.lua` count after peel: **6 maximum** (WhatGroup, Compat, Locale, Settings_Schema, Settings_Panel, Settings_Scrollbar, Frame = 7) or **6** if Scrollbar folds into Panel. Both fit under Tier 1's 8-file cap with margin.

ASCII data-flow (preserved end-to-end):

```
GROUP_ROSTER_UPDATE ─┐
                     ├─→ capture state machine (WhatGroup.lua:501-541)
LFG_LIST_*  ─────────┘     (notifiedFor / notifyGen / WipeCapture)
                                    │
                                    ▼
                       _TryFireJoinNotify ──→ chat output (NS._print prefixed [WG])
                                    │
                                    ▼
                              ShowFrame (combat-gated)
                                    │
                                    ▼
                       WhatGroupFrame popup (lazy build)
```

### 3.3 Critical patterns to preserve

1. **3-layer combat-lockdown cascade.** `runConfig` (`WhatGroup.lua:868-870`) gates → `Settings.Register` re-checks (`WhatGroup_Settings.lua:975-980` → moves to `WhatGroup_Settings_Panel.lua`) → `ShowFrame` defers (`WhatGroup_Frame.lua:282-303`). All three guards stay; the peel relocates layer 2 but keeps the body identical.
2. **Capture SM with `notifiedFor` / `notifyGen`.** Lives in `WhatGroup.lua`; not touched by this work.
3. **Taint discipline.** File-load `hooksecurefunc` (`WhatGroup.lua:39-51`); deferred Settings registration; deferred StaticPopupDialogs write (`Settings.EnsureResetPopup`); deferred `tinsert(UISpecialFrames, ...)`; panel-body builds wrapped in `C_Timer.After(0, ...)`. Every one of these stays where it is; the in-folder peel is mechanical text-relocation only.

## 4. LLD — per-deviation design

### WG-1 — Missing `.pkgmeta` (🔴, S)

**Current:** absent.
**Target:** root-level `.pkgmeta` declaring Ace3 libs as externals (per `03_STANDARDS.md` §13 template), `package-as: WhatGroup`, ignore list with `reviews/`, `_dev/`, `docs/internal/`, `*.bak`, `.luacheckrc`.
**Migration:** create file from §13 template; LibStub, CallbackHandler-1.0, AceAddon-3.0, AceEvent-3.0, AceConsole-3.0, AceDB-3.0, AceGUI-3.0 as externals. Do not delete vendored `libs/` content in the same commit (that's a separate sprint per `04_DEVIATIONS.md` cross-cutting plan).
**Risks:** None at install time — `.pkgmeta` only affects packager. Verification: `cat .pkgmeta`; future packager run produces a build with the same Ace3 versions.

### WG-2 — Missing `.luacheckrc` (🔴, S)

**Current:** absent.
**Target:** root-level `.luacheckrc` with `std = "lua51"`, `max_line_length = false`, `codes = true`, `exclude_files = { "libs/", "reviews/", "_dev/" }`, WoW globals in `read_globals`, `WhatGroupDB` and `WhatGroup` in `globals`. Add ignores for `212/self`, `212/event`.
**Migration:** drop in BigWigsMods-style snippet (§14 template) extended with the WhatGroup-specific globals enumerated below.
**Risks:** initial run will surface unused-locals / shadow warnings. Treat as an inventory task; fix only obvious ones, suppress the rest with line-level `-- luacheck: ignore` justified comments.
**Verification:** `luacheck .` exits 0 (or with documented suppressions).

WhatGroup-specific globals to enumerate:
- `read_globals`: `C_LFGList`, `C_AddOns`, `C_Spell`, `C_Timer`, `Settings`, `SettingsPanel`, `StaticPopupDialogs`, `StaticPopup_Show`, `UISpecialFrames`, `GROUP_FINDER_GENERAL_PLAYSTYLE1..4`, `YES`, `NO`, `IsInGroup`, `IsSpellKnown`, `GetSpellInfo`, `GetSpellTexture`, `GetAddOnMetadata`, `hooksecurefunc`, `SetItemRef`, `BackdropTemplateMixin`, `UIParent`, `GameTooltip`, `GameFontNormalHuge`, `GameFontNormalLarge`, `GameFontHighlight`, `NORMAL_FONT_COLOR`.
- `globals`: `WhatGroupDB`, `WhatGroup`, `WhatGroupFrame`, `WhatGroupParentPanel`, `WhatGroupGeneralPanel`.

### WG-3 — TOC missing `X-Curse-Project-ID` / `X-Wago-ID` (🔴, S)

**Current:** `WhatGroup.toc:1-19` lists License but no Curse/Wago IDs. README badge at `README.md:4` references `curseforge/v/1489907` so the listing exists.
**Target:** add `## X-Curse-Project-ID: 1489907` and `## X-Wago-ID: <id>` (user supplies Wago ID; placeholder `TBD-WAGO-ID` if not yet known).
**Migration:** edit TOC lines after `## X-License: MIT`.
**Risks:** Wago ID may not exist yet — flag for user.
**Verification:** TOC parse by packager picks up IDs.

### WG-4 — In-folder peel of `WhatGroup_Settings.lua` (🟠, M) — **the largest task**

**Current:** single file, 1056 LOC, mixes:
1. Schema rows (lines 73-184)
2. db.profile path helpers (Resolve / Get / RawSet / Set / FindSchema, lines 190-251)
3. Schema-shape validator (ValidateSchema, lines 263-298)
4. AceDB defaults builder + RestoreDefaults + RefreshAll (lines 306-354)
5. StaticPopup registration (EnsureResetPopup, lines 372-388)
6. Layout constants + tooltip helper (lines 394-436)
7. Header builder (buildHeader, lines 442-483)
8. CreatePanel (lines 491-518)
9. Always-visible scrollbar patch (PatchAlwaysShowScrollbar, lines 534-641)
10. Lazy AceGUI scroll container (ensureScroll, lines 647-678)
11. Section / widget creators / RenderField / InlineButton / RenderSchema (lines 684-862)
12. Parent-page content (BuildMainContent, lines 879-942)
13. Settings.Register (lines 963-1056)

**Target:** in-folder peel into 2-3 sibling files. **No subfolders.** The standard's Tier 1 §1.1 explicitly allows: *"MAY peel a single oversized file into 2-3 sub-files in the same folder (e.g. `Settings_Schema.lua`, `Settings_Panel.lua`) — MUST NOT introduce subfolders."*

**Region map (target = 3 files):**

| Lines (current) | Section | Target file |
|---|---|---|
| 1-51 | File-header comment, AceAddon/AceGUI lookup, NS init (`Settings = WhatGroup.Settings or {}` + tables), `pout` helper | `WhatGroup_Settings_Schema.lua` (head: small re-init shared across all three peeled files) |
| 53-184 | Schema rows (`add{}` calls) | `WhatGroup_Settings_Schema.lua` |
| 186-251 | db.profile path helpers (Resolve, Get, RawSet, Set, FindSchema) | `WhatGroup_Settings_Schema.lua` |
| 253-298 | ValidateSchema | `WhatGroup_Settings_Schema.lua` |
| 300-354 | BuildDefaults, RestoreDefaults, RefreshAll | `WhatGroup_Settings_Schema.lua` |
| 356-388 | StaticPopup (EnsureResetPopup) | `WhatGroup_Settings_Schema.lua` |
| 390-402 | Layout constants | `WhatGroup_Settings_Panel.lua` |
| 404-436 | attachTooltip | `WhatGroup_Settings_Panel.lua` |
| 438-483 | buildHeader | `WhatGroup_Settings_Panel.lua` |
| 485-518 | CreatePanel | `WhatGroup_Settings_Panel.lua` |
| 520-641 | PatchAlwaysShowScrollbar | `WhatGroup_Settings_Scrollbar.lua` |
| 643-678 | ensureScroll (calls PatchAlwaysShowScrollbar) | `WhatGroup_Settings_Scrollbar.lua` |
| 680-710 | addSpacer + Section | `WhatGroup_Settings_Panel.lua` |
| 712-799 | applyWidth, makeCheckbox, makeSlider, RenderField, InlineButton | `WhatGroup_Settings_Panel.lua` |
| 801-862 | RenderSchema | `WhatGroup_Settings_Panel.lua` |
| 864-942 | BuildMainContent + main-page constants | `WhatGroup_Settings_Panel.lua` |
| 944-1056 | Settings.Register | `WhatGroup_Settings_Panel.lua` |

**Resulting LOC envelope** (estimate, includes per-file header repeat of `local WhatGroup = LibStub("AceAddon-3.0"):GetAddon("WhatGroup")`, `local Settings = WhatGroup.Settings`, `local Helpers = Settings.Helpers`, `local Schema = Settings.Schema`):
- `WhatGroup_Settings_Schema.lua` ≈ 280 LOC
- `WhatGroup_Settings_Panel.lua` ≈ 480 LOC
- `WhatGroup_Settings_Scrollbar.lua` ≈ 120 LOC

All ≤500 LOC, well below the §1.1 1500 cap.

**TOC load order** (must follow data dependency: Schema first, then Scrollbar, then Panel which calls into both):

```
WhatGroup.lua
Compat.lua
Locale.lua
WhatGroup_Settings_Schema.lua
WhatGroup_Settings_Scrollbar.lua
WhatGroup_Settings_Panel.lua
WhatGroup_Frame.lua
```

**Decision rule for 2-vs-3:** if the Scrollbar peel ends ≤120 LOC and `WhatGroup_Settings_Panel.lua` would still be ≤700 LOC if Scrollbar folded back in (it would be ~600), keep Scrollbar separate — it has a clear single responsibility and is the most "library-shaped" part of the file. **Recommendation: 3 files** (Schema / Scrollbar / Panel).

**Risks:**
- Forgotten upvalue: every peeled file MUST repeat `local AceGUI = LibStub("AceGUI-3.0")`, `local WhatGroup = LibStub("AceAddon-3.0"):GetAddon("WhatGroup")`, `local Settings = WhatGroup.Settings`, `local Helpers = Settings.Helpers`, `local Schema = Settings.Schema`, and `local pout = ...`. Schema initializes the table; Panel/Scrollbar reuse.
- Function-table identity: `Settings.Helpers.PatchAlwaysShowScrollbar` is called by `ensureScroll` (currently inside the same file). Both move to Scrollbar — same file boundary, still works. `ensureScroll` is a `local` function used by Panel; promote to `Helpers.EnsureScroll` so Panel can call it across file boundary.
- Forward references: `Helpers.RenderSchema` references `addSpacer` (file-local). All such file-locals that cross peel boundaries must promote to `Helpers.*` or be re-declared in each consumer file. Identify at peel time:
  - `addSpacer` → promote to `Helpers.AddSpacer` (used by Section in Panel and BuildMainContent in Panel — same file, no need; but Scrollbar's ensureScroll-callers may want it. Verify; safe to leave file-local in Panel).
  - `attachTooltip` → file-local in Panel; only Panel uses it. Stays local.
  - `applyWidth`, `makeCheckbox`, `makeSlider`, `startRow`, `flushRow` → all file-local in Panel; only Panel uses them. Stay local.
  - `ensureScroll` → moves to Scrollbar; Panel needs it. Promote to `Helpers.EnsureScroll`.

**Verification:** in-game `/wg config` opens parent + General sub-page; Defaults button works; reset confirms; schema slider/checkboxes drive db.profile through Helpers.Set; scrollbar always visible.

### WG-5 — Missing `Compat.lua` (🟠, S)

**Current:** absent. No deprecated calls today (the analysis at `_raw/WhatGroup.md` §13 confirms `IsInGroup` only, `C_Spell.GetSpellName` with `GetSpellInfo` fallback, `C_AddOns.GetAddOnMetadata` with `GetAddOnMetadata` fallback — but those fallbacks are inline, not in a Compat module).
**Target:** ship a `Compat.lua` shell with `Compat.IsRetail`, `Compat.IsClassic`, and re-house the inline fallbacks into `Compat.GetSpellName(id)`, `Compat.GetSpellTexture(id)`, `Compat.GetAddOnMetadata(addon, key)`. **Body refactor is optional** — the standard requires the file's existence so a future shim has a home. Minimum: empty `Compat.lua` shell with `NS.Compat = NS.Compat or {}` + `Compat.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE`. Ship the body refactor only if M5 (the peel) finds spare time.
**Migration:** create `Compat.lua` at addon root; add to TOC after `WhatGroup.lua`. Does **not** change SVs (this is a code-only scaffold).
**Risks:** None for the empty shell. If body-refactor pulled in: must replicate the existing inline fallback semantics exactly to avoid losing spell name/icon for users on older clients.
**Verification:** addon loads; `/wg config` works; `WhatGroup.Compat.IsRetail == true` on retail.

### WG-6 — Missing locale module shell (🟠, S)

**Current:** `WhatGroup` has no AceLocale, no `Locale.lua`. CLAUDE.md hard rule says "English-only" is a deliberate non-goal. Standard §8.1 still requires the module shell so future contributors have a place to localize.
**Target:** ship `Locale.lua` at addon root with metatable-fallback pattern (per §8.1):

```lua
local addonName, NS = ...                      -- WhatGroup uses _G global, but the
                                              -- vararg pattern still works inside the
                                              -- addon. NS table is independent of the
                                              -- _G.WhatGroup AceAddon table.
WhatGroup = WhatGroup or {}
WhatGroup.L = setmetatable({}, { __index = function(_, k) return k end })
local L = WhatGroup.L
-- enUS keys (all currently English literals — these match the existing
-- hardcoded strings, so substituting L["X"] for "X" later is mechanical):
L["Reset every WhatGroup setting to its default? The active profile is the only one affected."] = ...
-- ...etc. Even without translations, the keys document every user-visible string
-- and prove the seam exists.
```

Schema labels and tooltips are NOT migrated to L["..."] in this milestone — that's an opt-in future task. Ship the shell, stub out 5-10 key strings (popup confirm, "Defaults" button, "Test" button, error prefixes) so the seam is exercised at least once.

**Migration:** create `Locale.lua`; load before Settings_Schema in TOC. `WhatGroup.L["Reset…"]` etc.
**Risks:** None. Even if every value resolves to a Blizzard `_G` string today (e.g. `YES`, `NO`), the module shell is a future seam.
**Verification:** `/dump WhatGroup.L["Defaults"]` returns "Defaults".

### WG-7 — Persistent debug toggle (🟠, S)

**Current:** `WhatGroup.lua:239` seeds `WhatGroup.debug` from `db.profile.debug`; `/wg debug` toggles via `Helpers.Set("debug", ...)`. **This is already SV-persistent** — re-read the current state. Looking at `WhatGroup_Settings.lua:108-115`: the `debug` schema row IS in `profile`, default false. So debug IS persistent across reloads.

**Re-classification:** WG-7 in `04_DEVIATIONS.md` is mis-stated — WhatGroup already has a persistent debug toggle. The standard wants `db.global.debug`; WhatGroup uses `db.profile.debug`. Both are SV-persistent. The standard says "MUST gate via persistent SV flag (`NS.db.global.debug`)" — pedantically `profile` vs `global` matters when an addon supports per-profile debug; for a single-account-shared-profile addon (WhatGroup uses `AceDB:New(..., true)` for shared Default profile), profile is functionally identical to global.

**Decision:** keep `db.profile.debug` (no migration to `db.global.debug` required). Document the analysis in `ARCHITECTURE.md` so the next reviewer doesn't re-flag.

**Migration:** documentation note only. No code change. WG-7 closes as "already compliant; analyst note added".
**Risks:** None.
**Verification:** `/wg debug` on, `/reload`, debug stays on. (Already current behaviour.)

### WG-8 — Hand-rolled `SLASH_*` → AceConsole (🟠, S)

**Current:** `WhatGroup.lua:241-242`:
```lua
self:RegisterChatCommand("wg", "OnSlash")
self:RegisterChatCommand("whatgroup", "OnSlash")
```

Wait — re-read. **This is already AceConsole.** `RegisterChatCommand` is the AceConsole-3.0 method (per `03_STANDARDS.md` §7.1 example). `WhatGroup.lua:23-25` registers `AceConsole-3.0` as a mixin.

**Re-classification:** WG-8 in `04_DEVIATIONS.md` is mis-stated — WhatGroup already uses AceConsole. There are no `SLASH_WG1 = "/wg"` lines in the source. Confirm at peel time.

**Decision:** no migration needed; close WG-8 as "already compliant; analyst error".
**Migration:** no-op.
**Risks:** None.
**Verification:** grep `SLASH_` in the WhatGroup tree returns no addon-author hits.

### WG-9 — `appID`-as-`searchResultID` reuse (🟡, S)

**Current:** `WhatGroup.lua:588` uses `appID` as `searchResultID` for `C_LFGList.GetSearchResultInfo`. Comment block at `:581-587` flags TODO F-004.
**Target:** add an explicit code comment citing the Blizzard parity invariant ("for the player's own application, `appID == searchResultID`"). Add a short note in `ARCHITECTURE.md` "Known Limitations" section.
**Migration:** edit `WhatGroup.lua` near `:581-588`; append paragraph to `ARCHITECTURE.md`. **No behavior change.**
**Risks:** None. If Blizzard ever decouples them, the failure mode is silent — but that's already the current state; this work merely documents.
**Verification:** comment present; `/grep -n "appID == searchResultID" WhatGroup.lua` matches.

### WG-10 — Public API surface (🟡, S)

**Current:** `_G.WhatGroup` is the AceAddon table. Things like `_print`, `_dbg`, `_parentSettingsCategory`, `_settingsCategory`, `_settingsRegistered`, `_frameBuildQueued`, `RunTest`, `WipeCapture`, `ShowFrame`, `Labels`, `COMMANDS`, `pendingInfo` are all on it. The leading-underscore names are intentional "private but cross-file".
**Target:** WhatGroup exposes nothing for third-party consumption. Decision: **keep everything on private NS (`_G.WhatGroup` is functionally the NS for this addon's bootstrap pattern; AceAddon owns the table).** Do NOT introduce `WhatGroup.API.v1`. Add a short cross-file contract block to `ARCHITECTURE.md` listing the leading-underscore "internal-but-cross-file" surface and the leading-uppercase methods (RunTest, WipeCapture, ShowFrame, Labels, COMMANDS) as the agreed cross-file contract.
**Migration:** documentation only. No code change.
**Risks:** None.
**Verification:** ARCHITECTURE.md "Cross-file contract" section lists the 12 leaked symbols.

### WG-11 — Cargo-cult `## DefaultState: enabled` (⚪, S)

**Current:** `WhatGroup.toc:8` has `## DefaultState: enabled`. Only meaningful for LoadOnDemand addons; harmless on regular load.
**Target:** delete the line.
**Migration:** edit TOC.
**Risks:** None.
**Verification:** addon still loads at startup.

## 5. Cross-cutting

### 5.1 SV migration

None of the deviations change SV shape. `WhatGroupDB.profile` keeps the same nested structure. WG-5 (`Compat.lua`) is code-only. WG-6 (`Locale.lua`) is code-only. WG-7 closes as already-compliant. The peel (WG-4) is text-relocation only.

We do **not** introduce a `schemaVersion` migration runner in this work — the addon doesn't use one currently and no SV shape change is on the table. (Standard §5.1 says "MUST declare schemaVersion in the global namespace and ship a migration function in `core/Database.lua`" for Tier 2; Tier 1's §1.1 is silent. WhatGroup's analyst report does not flag this. Defer to a future audit.)

### 5.2 Locale module shell

Even though every user-visible string is currently a hardcoded English literal or a Blizzard `_G` global, ship the `Locale.lua` shell. Stub 5-10 key strings end-to-end so the metatable + assignment seam is proven. Future contributors can migrate per-string at zero infrastructural cost.

### 5.3 Persistent debug toggle

Already persistent via `db.profile.debug`. Document in ARCHITECTURE.md.

## 6. Out of scope

- Capture state machine logic (`WhatGroup.lua:501-541`). Untouched.
- LFG API integration (`hooksecurefunc(C_LFGList.ApplyToGroup, ...)`). Untouched.
- WhatGroup_Frame.lua popup (319 LOC, untouched).
- Vendored libs cleanup (defer to cross-cutting Sprint 4).
- Promotion to Tier 2 (explicitly forbidden by standard).
- Version bump (CLAUDE.md hard rule: user's call).
- Schema migration runner (no SV shape change).

## 7. Acceptance criteria

1. Addon stays Tier 1 flat. **Source `.lua` count ≤ 8** in addon root (excluding `libs/`, `media/`, `docs/`, `reviews/`). Target: 6 files (WhatGroup, Compat, Locale, WhatGroup_Settings_Schema, WhatGroup_Settings_Scrollbar, WhatGroup_Settings_Panel, WhatGroup_Frame = 7 if Scrollbar peeled separately, 6 if folded).
2. `WhatGroup_Settings.lua` is **deleted**, replaced by 2-3 sibling files all ≤700 LOC each.
3. `.luacheckrc` runs clean (or with documented suppressions only).
4. `.pkgmeta` parses and lists all Ace3 libs as externals.
5. TOC has `X-Curse-Project-ID` and `X-Wago-ID`; no `## DefaultState: enabled`.
6. Combat-lockdown cascade preserved end-to-end: `runConfig` → `Settings.Register` → `ShowFrame`.
7. Existing `WhatGroupDB` SVs load unchanged; no migration prompt; no key loss.
8. `/wg config` opens both pages; `/wg test` fires the popup; `/wg debug` survives `/reload`.
9. README, CLAUDE.md, ARCHITECTURE.md re-synced (cross-file contract section in ARCHITECTURE.md; updated file map; debug-toggle analyst note).
10. Smoke tests in `docs/smoke-tests.md` re-run cleanly post-peel.
