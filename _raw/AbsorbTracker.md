# AbsorbTracker — Current-State Analysis (2026-05-03)

Read-only audit. All claims cite `relative/path:LINE`.

## 1. TOC metadata

`AbsorbTracker.toc:1-23`. Verbatim:

```
## Interface: 120000,120001,120005
## Title: Ka0s Absorb Tracker
## Notes: Display your total absorb shield value in a clean, customizable bar interface.
## Author: add1kted2ka0s
## Version: 1.8.0
## iconTexture: 512902
## SavedVariables: AbsorbTrackerDB
## OptionalDeps: LibStub, CallbackHandler-1.0, Ace3, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: Combat
## X-License: MIT
```

- Multi-Interface line covering 120000/120001/120005 (Midnight 12.0.x).
- `SavedVariables: AbsorbTrackerDB` (single global SV).
- `SavedVariablesPerCharacter`: **absent**.
- `Dependencies`: **absent** (only `OptionalDeps`).
- `LoadOnDemand`: **absent**.
- `X-Curse-Project-ID` / `X-Wago-ID` / `X-WoWI-ID`: **absent**. Only `X-License: MIT` and the non-`X-` `iconTexture` and `Category-enUS` fields.

## 2. Folder/file layout

```
AbsorbTracker/
  AbsorbTracker.toc           (46 lines)
  Core.lua                    35
  Utils.lua                   21
  LSMPatch.lua                61
  Settings.lua               171
  Schema.lua                 272
  UI.lua                      60
  Display.lua                112
  Timer.lua                   39
  Events.lua                  84
  SlashCommands.lua          355
  OptionsPanel.lua           167
  Panel/
    Helpers.lua              355
    ScrollPatch.lua          127
    Widgets.lua              292
    About.lua                108
  Options/
    General.lua              137
    Bar.lua                  145
    Border.lua                91
    Font.lua                  96
    Profiles.lua              70
  libs/
    LibStub-1.0/
    CallbackHandler-1.0/      (.lua + .xml)
    LibSharedMedia-3.0/       (.lua + lib.xml)
    Ace3/
      AceAddon-3.0/           (.xml embed)
      AceDB-3.0/              (.xml embed)
      AceGUI-3.0/             (.xml embed)
      AceConfig-3.0/          (.xml embed)
      AceDBOptions-3.0/       (.xml embed)
      AceGUI-3.0-SharedMediaWidgets/  (widget.xml)
  media/screenshots/          (logos + shots)
  reviews/2026-05-02/         (5 review docs)
  docs/                       (10 .md companion docs)
  ARCHITECTURE.md, CLAUDE.md, README.md, LICENSE, .gitattributes, .gitignore
```

Game lua line count: 2798 (`wc -l` over `*.lua`, `Options/*.lua`, `Panel/*.lua`).

Largest files: `SlashCommands.lua` 355, `Panel/Helpers.lua` 355, `Panel/Widgets.lua` 292, `Schema.lua` 272.

XML embeds: TOC loads `CallbackHandler-1.0.xml`, the five Ace3 `*-3.0.xml`, `LibSharedMedia-3.0/lib.xml`, and `AceGUI-3.0-SharedMediaWidgets/widget.xml`. The addon itself does **not** ship any XML — every frame is built in Lua (`UI.lua:22`, panel `CreateFrame` in `Panel/Helpers.lua:173`).

## 3. Module-loading order

Driven entirely by `AbsorbTracker.toc:14-45`. No embeds.xml at addon level. No dynamic require.

Load order (post-libs): `Core` → `Utils` → `LSMPatch` → `Settings` → `Schema` → `UI` → `Display` → `Timer` → `Events` → `SlashCommands` → `OptionsPanel` → `Panel/Helpers` → `Panel/ScrollPatch` → `Panel/Widgets` → `Panel/About` → `Options/General` → `Bar` → `Border` → `Font` → `Profiles`.

Load-order assumptions:
- `OptionsPanel.lua:33` publishes `AddonTable.Helpers = AddonTable.Helpers or {}` *before* the four `Panel/*.lua` files decorate it.
- `Options/Bar.lua:52` reads `AddonTable.Helpers.LSMValues` at file-load — relies on `Panel/Helpers.lua` already having loaded (which it has, per TOC order).
- `UI.lua:22-26` builds the bar at file-load time, so `bar` exists before `Display`/`Timer`/`Events` reference it.
- Late-callable functions (`UpdateBarAppearance`, `RestartUpdateTicker`, `CreateOptionsPanel`) are looked up via `AddonTable.X` at call time inside event/AceDB callbacks — the soft forward-reference pattern (`Events.lua:74`, `Schema.lua:90`, `SlashCommands.lua:172`).

## 4. Library stack

All under `libs/`, embedded via `#@no-lib-strip@` block in `AbsorbTracker.toc:13-23`.

| Lib | Version (from source) | Embed |
|---|---|---|
| LibStub | major 2 (`libs/LibStub-1.0/LibStub.lua` `LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2`) | direct `.lua` |
| CallbackHandler-1.0 | minor 8 | `.xml` |
| LibSharedMedia-3.0 | 12000001 (12.0.0 v1) | `.xml` |
| AceAddon-3.0 | minor 13 (`@release` rev 1284, 2022-09-25) | `.xml` |
| AceDB-3.0 | minor 33 (rev 1364, 2025-07-05) | `.xml` |
| AceGUI-3.0 | minor 41 (rev 1288, 2022-09-25) | `.xml` |
| AceConfig-3.0 | rev 1335, 2024-05-05 (AceConfigDialog-3.0 minor 92) | `.xml` |
| AceDBOptions-3.0 | minor 15 (rev 1304, 2023-05-19) | `.xml` |
| AceGUI-3.0-SharedMediaWidgets | r65 per `ARCHITECTURE.md:67` (canonical multi-file lib loaded via `widget.xml`) | `widget.xml` |

Usage:
- LibStub: read every time AceDB/AceGUI/etc. is needed (`Events.lua:38`, `OptionsPanel.lua:107`, `Panel/Helpers.lua:101`).
- CallbackHandler-1.0: dependency of AceDB/LSM, not used directly.
- LSM: fetched/cached in `Settings.lua:18-29`; values pulled via `Panel/Helpers.lua:348-355` `LSMValues`.
- AceAddon-3.0: bundled but **not used as a registry** — `CLAUDE.md` and `ARCHITECTURE.md:46` describe the addon as plain `AddonTable` modules with AceAddon "as the carrier for AceDB." No `:NewAddon`/`:NewModule` call exists in the addon's own code.
- AceDB-3.0: explicit `LibStub("AceDB-3.0", true):New(...)` at `Events.lua:38-43` with profile callbacks for change/copy/reset.
- AceGUI-3.0: every panel widget (`Panel/Widgets.lua:40-217`).
- AceConfig + AceConfigDialog: only used by the Profiles sub-page (`Options/Profiles.lua:23-39`).
- AceDBOptions-3.0: same — supplies the AceConfig options table for profiles.
- LSM30_* widgets: used as `dialogControl` strings on schema rows (`Options/Bar.lua:51`, `Border.lua:23`, `Font.lua:37`).

No unused libs in functional sense; AceAddon's runtime registry features are unexercised.

## 5. Core architecture pattern

Pattern: **`AddonTable` bus**, plain Lua modules, no AceAddon registry, no manual `_G[ADDON]` table.

Entry-point pattern (`Core.lua:2`):
```lua
local AddonName, AddonTable = ...
```
Every other file does the same. `AddonTable` is the WoW-supplied per-addon table from `...`. Functions are attached as fields (`AddonTable.UpdateAbsorbBar = function(...)` etc.). Cross-module calls go through `AddonTable.X` so name resolution happens at call time (`Events.lua:74`).

Bootstrap is event-driven, not module-init: `Events.lua:29-33` creates one event frame for `PLAYER_LOGIN` / `PLAYER_ENTERING_WORLD` / `UNIT_ABSORB_AMOUNT_CHANGED`. `PLAYER_LOGIN` (`Events.lua:35-76`) initializes the AceDB, primes LSM, paints the bar, starts the ticker, then calls `AddonTable.CreateOptionsPanel` (set by `OptionsPanel.lua:105`).

WoW-required globals: only `AbsorbTrackerDB` (SV), `SLASH_ABSORBTRACKER1`/`SLASH_ABSORBTRACKER2` (`SlashCommands.lua:334-335`), and the named frame `AbsorbTrackerFrame` (`UI.lua:22`).

## 6. Settings / saved variables

- SV name: `AbsorbTrackerDB` (`AbsorbTracker.toc:7`).
- Defaults defined as an AceDB-shape table at `Core.lua:10-32` (only a `profile` scope; no `char`/`global`/`realm`).
- Per-profile keys: 18 settings (texture/border/font names, sizes, colors, three class-color toggles, locked/hidden, updateInterval, position).
- AceDB construction: `Events.lua:40` `AceDB:New("AbsorbTrackerDB", defaults, true)` — third arg `true` means use the user's default-profile shared profile.
- Profile callbacks registered for `OnProfileChanged`, `OnProfileCopied`, `OnProfileReset` (`Events.lua:41-43`), all routed to a single handler `OnProfileChanged` (`Events.lua:16-26`) that re-paints + restarts ticker + refreshes panel.
- Fallback when AceDB missing: `Events.lua:47-65` builds a `{ profile = AbsorbTrackerDB }` shim and seeds defaults, deep-copying table-typed defaults so mutation can't reach back into `flatDefaults` (the F-002 hardening cited in `reviews/2026-05-02/05_FINAL_SUMMARY.md`; verified at `Events.lua:54-64`).
- Schema-shape validation runs once at panel creation (`Schema.lua:182-207`, called from `OptionsPanel.lua:113`). Validates `path`, `page`, `type`; only prints, never refuses to register.
- No SV migration logic — version field never read; defaults are merged by AceDB on load.
- SV key naming: camelCase (`barWidth`, `useClassColorBar`).

## 7. Options UI

- Built on **Blizzard Settings** (the modern `Settings.RegisterCanvasLayoutCategory` / `Settings.RegisterCanvasLayoutSubcategory` API) — `OptionsPanel.lua:79-103`, with each Options sub-page calling `Settings.RegisterCanvasLayoutSubcategory` (`Options/General.lua:131`, `Bar.lua:139`, `Border.lua:85`, `Font.lua:90`, `Profiles.lua:64`).
- Inside each canvas frame the body is rendered via **AceGUI** widgets through a custom toolkit (`Panel/Helpers.lua` + `Panel/Widgets.lua`). Widgets are AceGUI `CheckBox` / `Slider` / `Dropdown` (or `LSM30_*`) / `ColorPicker` / `Heading` / `SimpleGroup` / `ScrollFrame` / `Button` / `Label` (`Panel/Widgets.lua:40-217`).
- AceConfig is **only used for the Profiles page** — `Options/Profiles.lua:38-39` registers `"AbsorbTracker-Profiles"` and `Options/Profiles.lua:61` calls `AceConfigDialog:Open` against an embedded `SimpleGroup` container.
- Top-level "Ka0s Absorb Tracker" parent is itself a canvas-layout panel with an about page (logo + Notes + slash list), built by `Panel/About.lua:40-108`, registered in `OptionsPanel.lua:100`.
- No legacy `InterfaceOptions_AddCategory` calls — uses only the Settings API.
- Combat lockdown gate: `OptionsPanel.lua:151-154` early-returns from `OpenOptionsPanel` while `InCombatLockdown()` is true.

## 8. Slash commands

- **Hand-rolled** raw `SLASH_ABSORBTRACKER1`/`2` + `SlashCmdList["ABSORBTRACKER"]` at `SlashCommands.lua:334-355`. **No** AceConsole `:RegisterChatCommand`.
- Two slash tokens: `/absorbtracker` and `/at` (`SlashCommands.lua:334-335`).
- Argument parsing: lowercase command name, preserve case in tail (`SlashCommands.lua:343-345`) so schema paths like `barTexture` survive `/at set`. Sub-args parsed via `:gmatch("%S+")` per command (`Schema.lua:264-265`, `SlashCommands.lua:236`).
- Help: `printHelp` walks `AddonTable.SlashCommands` and prints "/at <verb> — <desc>" (`SlashCommands.lua:97-103`).
- Backward-compat alias: `options` → `config` (`SlashCommands.lua:348`).
- All 15 verbs (`SlashCommands.lua:29-75`):

  `help`, `config`, `list`, `get`, `set`, `reset`, `resetall`, `resetposition`, `lock`, `unlock`, `toggle`, `debug`, `update`, `test`, `profile`.

  `profile` subcommands (`SlashCommands.lua:266-327`): `list`, `current`, `use <name>`, `new <name>`, `copy <name>`, `delete <name>`, `reset`. Undocumented aliases `set`/`create`/`remove` were removed per F-017 (`reviews/2026-05-02/05_FINAL_SUMMARY.md`); confirmed gone — only the seven listed are accepted at `SlashCommands.lua:286-323`.

- All chat prefixed `[AT]` via `AddonTable.Print` (`Utils.lua:8-11`); files shadow global `print` with `local print = AddonTable.Print` (`SlashCommands.lua:16`, `Utils.lua:14`, etc.).

## 9. Localization

- **AceLocale: absent.** No `AceLocale-3.0` lib in `libs/Ace3/`; no `Locale/` or locales folder.
- Strings hardcoded throughout: chat messages (`SlashCommands.lua:46,51,209,217,231,287` etc.), tooltips and labels (`Options/Bar.lua:25,37,48,...`), panel headers (`OptionsPanel.lua:39` "Ka0s Absorb Tracker"), schema validator messages (`Schema.lua:191,195,200`), StaticPopup `text` (`Options/General.lua:69`).
- TOC declares English-only intent (`AbsorbTracker.toc:10` `## Category-enUS: Combat`); README "English only" per `CLAUDE.md`.
- Coverage: 0% — no externalized locale module exists.

## 10. Events

- **Raw frame `:RegisterEvent`** — `Events.lua:29-34` creates one `CreateFrame("Frame")` and registers three events. `LSMPatch.lua:25-27` creates a second event frame for `PLAYER_LOGIN` only (one-shot, then `UnregisterAllEvents`). No AceEvent.
- Events handled (file:line):
  - `PLAYER_LOGIN` — `Events.lua:31` → `Events.lua:35` (bootstrap).
  - `PLAYER_ENTERING_WORLD` — `Events.lua:31` → `Events.lua:77` (`UpdateAbsorbBar`).
  - `UNIT_ABSORB_AMOUNT_CHANGED` — `Events.lua:30` → `Events.lua:79`. Notably **does not** drive the paint; only used as a `DebugPrint` trigger. The ticker (`Timer.lua:29`) is the actual paint source.
  - `PLAYER_LOGIN` (second frame) — `LSMPatch.lua:26` → `LSMPatch.lua:27` (one-shot LSM30_Border patch).
- Combat-lockdown discipline: `InCombatLockdown()` checked at `OptionsPanel.lua:151` for the Settings.OpenToCategory call. No other lockdown gates — but no other secure operations occur, so this is the only place one is needed.

## 11. Frames

- **All Lua, no XML.** Bar built imperatively at `UI.lua:22-49`. Panels via `CreateFrame("Frame", name)` in `Panel/Helpers.lua:173`.
- No frame pooling.
- No `SecureActionButtonTemplate` / `SecureUnitButtonTemplate` — the addon is purely cosmetic and never binds spells.
- BackdropTemplate inheritance at `UI.lua:22`.
- Taint-prone patterns:
  - `OpenOptionsPanel` is gated by `InCombatLockdown()` (`OptionsPanel.lua:151`).
  - `OnDragStop` saves position via `SetSetting` (`UI.lua:33-38`) — fine, no secure attributes touched.
  - `expandMainCategory` at `OptionsPanel.lua:135-147` reaches into `SettingsPanel` private API, but wrapped in `pcall`.
  - `Panel/ScrollPatch.lua:68-127` rebinds AceGUI ScrollFrame methods — no taint, but tight coupling to AceGUI internals (`scrollbar`, `scrollframe`, `content`, `status`/`localstatus`).

## 12. Debug/logging

- Debug flag: `AddonTable.DEBUG = false` at `Utils.lua:5`, toggled by `/at debug` (`SlashCommands.lua:225-227`).
- Toggle is in-memory only — **not** persisted in SV. A relog resets to false.
- Log levels: none — single boolean, single `DebugPrint` helper (`Utils.lua:17-21`).
- Performance discipline:
  - `Display.lua:98-100` gates the per-tick `DebugPrint` in `if AddonTable.DEBUG then ... end` so `AbbreviateNumbers` + `format` don't allocate when off (F-007 hardening).
  - `Timer.lua:13` `RestartUpdateTicker` `DebugPrint` is uncondtional but only fires on ticker restart, not per-tick — minimal cost.
- No `print(...)` calls outside `Utils.lua:8-11` (verified: shadowed via `local print = AddonTable.Print` in every file that emits chat).

## 13. Error handling

- `pcall` use:
  - `OptionsPanel.lua:137-146` wraps the `SettingsPanel` private-API expansion.
  - `Panel/Helpers.lua:290-294` wraps button onClick handlers (so a bad callback doesn't kill the panel).
  - `Panel/Helpers.lua:316,338` wraps refresher functions in `RestoreDefaults` / `RefreshAllPanels`.
- Defensive nil checks at API boundaries: `if AddonTable.X then ... end` forward-reference guards (`Events.lua:23,74`, `SlashCommands.lua:63,172,196,207,208`). Also `LibStub` and `Settings`/`Settings.OpenToCategory` (`OptionsPanel.lua:79,106,155`).
- API version: `getVersion` at `SlashCommands.lua:87-95` and `getMetadata` at `Panel/About.lua:21-28` both prefer the modern `C_AddOns.GetAddOnMetadata` and fall back to bare `GetAddOnMetadata` (F-001 hardening, confirmed).
- No `GetSpellInfo` / `UnitAura` calls in addon code — irrelevant since the addon only reads `UnitGetTotalAbsorbs` (`Display.lua:93`) and `UnitHealthMax` (`Display.lua:94`), both still current.
- `UnitGetTotalAbsorbs` "secret value" handled by passing through `AbbreviateNumbers` directly without `tonumber` (`Display.lua:110`, per `CLAUDE.md` hard rule). Verified.
- StaticPopup at `Options/General.lua:68` follows current shape (no deprecated `OnAccept` patterns).

## 14. Packaging

- **`.pkgmeta`: absent.** No file at addon root or anywhere in tree (verified by find).
- README Version History row at `README.md:114` notes "1.2.0 — Removed pkgmeta and embedded libs directly," confirming intentional removal.
- All libs vendored in-tree under `libs/` and committed to git.
- No `externals` declared, no `ignore`, no auto-changelog. CHANGELOG is the README's "Version History" table (`README.md:104-116`), maintained manually.
- `.gitattributes` (`AbsorbTracker/.gitattributes:1-29`) enforces CRLF on disk for `*.lua/*.toc/*.xml/*.md/*.json`, binary for `*.png/*.jpg/*.tga/...`.
- `.gitignore`: present (144 B, contents not inspected — small).

## 15. Documentation

- `README.md` (117 lines), `ARCHITECTURE.md` (89 lines), `CLAUDE.md` (60+ lines), 10 `docs/*.md` companion files, 5 `reviews/2026-05-02/*.md`.

Drift verification — five claims per top-level doc spot-checked:

**README.md**
1. "1.8.0" badge / version row (`README.md:108`) — matches `AbsorbTracker.toc:5`. ✅
2. "Five subcategories under Ka0s Absorb Tracker" (`README.md:48`) — verified: `Options/General.lua`, `Bar.lua`, `Border.lua`, `Font.lua`, `Profiles.lua` each register a sub-page (`RegisterOptionsPage` at the bottom of each). ✅
3. "/at test [value] [hold-secs]" (`README.md:42`) — matches `SlashCommands.lua:71` and the `runTest` parser at `SlashCommands.lua:236-238`. ✅
4. "Bar Width 50–500, Bar Height 10–100, Border thickness 1–32, Font size 6–32" (`README.md:50-53`) — matches `Options/Bar.lua:28,39`, `Options/Border.lua:35`, `Options/Font.lua:49`. ✅
5. "Profile subcommands: list, current, use <name>, new <name>, copy <name>, delete <name>, reset" (`README.md:44`) — exact match to `SlashCommands.lua:286-323`. ✅

No drift detected in README spot-check.

**ARCHITECTURE.md**
1. "Interface line is 120000, 120001, 120005" (`ARCHITECTURE.md:69`) — matches `AbsorbTracker.toc:1`. ✅
2. "AceGUI-3.0-SharedMediaWidgets r65" (`ARCHITECTURE.md:67`) — not directly verifiable from source (no version constant in `widget.xml`); claim accepted as authoritative.
3. "Five sub-pages (General, Bar, Border, Font, Profiles)" (`ARCHITECTURE.md:53`) — matches Options/ folder.
4. Load-order list (`ARCHITECTURE.md:73-86`) matches `AbsorbTracker.toc:26-45` exactly. ✅
5. "OptionsPanel.lua is the registration shell" (`ARCHITECTURE.md:53`) — matches the 167-line shell verified at `OptionsPanel.lua`. ✅

No drift detected.

**CLAUDE.md**
1. "Schema is the single source of truth" — verified: `Schema.lua` + `RegisterSchemaRows` callers in `Options/*.lua`; `/at set/get/list/reset` and panel widgets both walk it. ✅
2. "Color getters resolve at call time" — verified at `Settings.lua:146-171`; each `GetXColor` re-reads `useClassColor*` per call. ✅
3. "SetBackdrop(nil) before SetBackdrop(info)" — verified at `Display.lua:54-55`. ✅
4. "Combat-lockdown gate on /at config" — verified at `OptionsPanel.lua:151`. ✅
5. "No raw print(...) calls" — verified by inspection: every chat-emitting file does `local print = AddonTable.Print`.

No drift detected. The doc set is unusually well-aligned with code, likely because the 2026-05-02 review (`reviews/2026-05-02/05_FINAL_SUMMARY.md`) explicitly synced docs as part of M2.6 / M3 polish.

## 16. Tests / lint

- `.luacheckrc`: **absent**.
- Test harness: **absent** — no `tests/`, `spec/`, or LuaUnit files (the `libs/LibStub-1.0/tests/` directory exists but is the upstream LibStub project's own test, not loaded by the TOC).
- Smoke-test docs: `docs/smoke-tests.md` exists (referenced by `README.md:103` and `ARCHITECTURE.md:42` — manual in-game QA recipe).

## 17. Notable strengths

- **Schema-as-single-source.** `Schema.lua` + `RegisterSchemaRows` means a new option = one row, and the panel widget AND `/at get/set/list/reset` surface are wired automatically. Validator (`Schema.lua:182-207`) catches typos at load.
- **`SetByPath` write seam.** Panel widgets and slash commands both write through `AddonTable.SetByPath` (`Schema.lua:101-105`) which dispatches the correct `onChange`. Single seam = no drift between UI and CLI behaviour.
- **Soft fallbacks for optional libs.** AceDB-missing → flat-table shim with deep-copied defaults (`Events.lua:47-65`); LSM-missing → Blizzard built-in fallback constants (`Settings.lua:13-15,57-91`); AceDBOptions-missing → Profiles page silently skipped (`Options/Profiles.lua:26-28`).
- **Lazy panel rendering.** Each sub-page defers AceGUI render to first `OnShow` (`Options/General.lua:104`, `Bar.lua:133`, `Border.lua:79`, `Font.lua:84`, `OptionsPanel.lua:91-98`) so panels never built unless opened, and so AceGUI lays out against real width.
- **Per-tick allocation discipline.** `Display.lua:98-100` gates `DebugPrint` formatting; ColorPicker uses single re-armed `C_Timer.NewTimer` + reused `pendingArgs` table (`Panel/Widgets.lua:199-211`) — O(1) garbage per drag.
- **Reusable backdrop table.** `UI.lua:13-19` defines one `backdropInfo`; `Display.lua:44-55` reuses it with explicit `SetBackdrop(nil)` flush.
- **Panel registry + refresher closures.** `Panel/Helpers.lua:59` collects ctx; `RefreshAllPanels` walks per-widget refresher closures rather than per-page namespaces.
- **`reviews/` folder is real and thorough** — five-document review with completed milestones (`reviews/2026-05-02/05_FINAL_SUMMARY.md`). Cross-doc traceability.

## 18. Notable weaknesses / risks

- **No `.luacheckrc` and no tests.** Mid-size codebase (~1100 game-lua lines + 882 panel lines) with zero static lint or programmatic verification. Manual smoke-tests are the only safety net.
- **No `.pkgmeta`.** Self-contained packaging is by-design (`README.md:114` v1.2.0), but it means CurseForge/Wago/WoWI can't fetch lib externals — release artifacts ship the vendored libs intact, slowing lib refresh cadence. No `X-Curse-Project-ID`/`X-Wago-ID`/`X-WoWI-ID` despite the CurseForge badge on `README.md:4`.
- **AceAddon-3.0 vendored but unused as a registry.** Adds ~200kb of lib weight for AceDB carriage only. Could in principle drop AceAddon-3.0 from `libs/` and the TOC.
- **`Panel/ScrollPatch.lua` couples to AceGUI ScrollFrame internals** (`scrollbar`, `scrollframe`, `content.original_width`, `status.offset`, `localstatus`, `MoveScroll`, `FixScroll`). An AceGUI minor-bump that touches ScrollFrame internals will silently break the always-visible-scrollbar override. Not gated by an AceGUI version check.
- **`/at debug` not persisted.** Toggle is in-memory only (`Utils.lua:5` reset to false at file-load every login). Inconvenient for repro of intermittent issues across relogs.
- **Schema validator only prints; never refuses to register.** A typo in `path` would silently miss its widget but still appear in `/at list`. By design (`Schema.lua:156-159` comment), but means typos can ship.
- **No localization shell.** Adding non-English support means string-grep across 20 files plus `StaticPopupDialogs` text.
- **Bar `OnDragStop` writes position synchronously** (`UI.lua:33-38`) — fine, but no debouncing means a rapid drag generates many SV writes (cheap, but worth noting).
- **`Panel/About.lua:19` hard-codes `Interface\AddOns\AbsorbTracker\media\screenshots\absorbracker.logo.v2.tga`** — if the addon folder is ever renamed (e.g. shipped under a different folder name), the logo silently fails to load. No fallback.
- **`expandMainCategory`** (`OptionsPanel.lua:135-147`) reaches into `SettingsPanel.CategoryList` private API. Pcall-guarded so it degrades gracefully, but a Blizzard rename would silently lose the auto-expand behaviour (acknowledged in the inline comment).
- **No throttle on `RefreshAllPanels`.** Every `/at set` and every panel widget write triggers a full traversal of every `ctx.refreshers` on every panel (`Panel/Helpers.lua:336-340`). Cost is O(panels × widgets) per write — small in practice but unbounded as the schema grows.
- **`Display.lua:103` `bar:SetAlpha(1)` fires on every paint** — harmless but redundant; the alpha never changes outside this call site.
