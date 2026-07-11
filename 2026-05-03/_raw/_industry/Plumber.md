# Plumber — Industry Reference Notes

Research date: 2026-05-03
Author of addon: Peterodox
License: GPL-3.0
Distribution: CurseForge (`www.curseforge.com/wow/addons/plumber`)
Version observed: 1.9.1 (TWW, Interface 120001 / 120005)

Sources:
- Repo root: https://github.com/Peterodox/Plumber
- TOC: https://raw.githubusercontent.com/Peterodox/Plumber/master/Plumber.toc
- Initialization: https://raw.githubusercontent.com/Peterodox/Plumber/master/Initialization.lua
- API: https://raw.githubusercontent.com/Peterodox/Plumber/master/API.lua
- Locales tree: https://github.com/Peterodox/Plumber/tree/master/Locales
- Locales XML: https://raw.githubusercontent.com/Peterodox/Plumber/master/Locales/Localization.xml
- enUS: https://raw.githubusercontent.com/Peterodox/Plumber/master/Locales/enUS.lua
- PostLoad: https://raw.githubusercontent.com/Peterodox/Plumber/master/Locales/PostLoad.lua
- Modules tree: https://github.com/Peterodox/Plumber/tree/master/Modules
- ControlCenter: https://github.com/Peterodox/Plumber/tree/master/Modules/ControlCenter
- SettingsPanelRegistry: https://raw.githubusercontent.com/Peterodox/Plumber/master/Modules/ControlCenter/SettingsPanelRegistry.lua
- ControlCenter PreLoad: https://raw.githubusercontent.com/Peterodox/Plumber/master/Modules/ControlCenter/PreLoad.lua

---

## 1. TOC

- Single canonical `Plumber.toc` plus expansion-specific TOCs: `Plumber_Vanilla.toc`, `Plumber_TBC.toc`, `Plumber_Wrath.toc`, `Plumber_Cata.toc`, `Plumber_Mists.toc`. No multi-flavor merged TOC; one TOC per flavor (Blizzard's modern way, no `#@retail@` shenanigans needed at runtime).
- Header: `## Title`, `## Author`, `## Version`, `## IconTexture`, `## Notes`, `## SavedVariables: PlumberDB, PlumberDevData, PlumberStorage`, `## SavedVariablesPerCharacter: PlumberDB_PC`.
- `## Interface: 120001, 120005` — multi-version interface line (single TOC supports multiple build numbers).
- Lots of modules listed; experimental/disabled modules are commented-out with `#` rather than deleted, so toggling a feature in/out of a build is a one-character TOC edit.

## 2. Folder layout

```
Plumber/
  Plumber.toc + Plumber_<flavor>.toc
  Initialization.lua
  API.lua
  Bindings.xml
  Locales/
    Localization.xml
    enUS.lua, deDE.lua, ... zhTW.lua
    PostLoad.lua
  Modules/
    ControlCenter/         <- options UI + module registry
    ExpansionLandingPage/
    Housing/
    MerchantUI/
    RaidCheck/
    Shared/                <- common widgets/util used by modules
    Timerunning/
    <100+ flat *.lua files for individual features>
  Art/
  Fonts/
  _Dev/                    <- dev-only utilities, never shipped
  .luacheckrc              <- static analysis config
```

Heavy folders are namespaced; smaller features sit as flat files in `Modules/`. `Shared/` keeps cross-module widgets (scrollbars, buttons) DRY.

## 3. Module loading

- `local addonName, addon = ...` everywhere — single shared namespace table.
- Feature modules call a registration API (`AddModule`) with a metadata table containing `name`, `dbKey`, `categoryID`, `uiOrder`, `validityCheck`, `toggleFunc`, `requiredDBValues`, `minimumTocVersion`, `newFeatureExpiry`.
- Boot path: `ADDON_LOADED` -> `LoadDatabase()` (apply defaults, version-stamp, optional changelog). `PLAYER_ENTERING_WORLD` -> `InitializeModules()`. `LOADING_SCREEN_DISABLED` -> deferred queued work via `QueueEvent` (~2s debounce after the loading screen).
- `InitializeModules()` runs each module's `validityCheck` first (e.g. Timerunning auto-disables outside its season), then for valid + enabled modules calls `toggleFunc(true)` inside `pcall` so one bad module can't cascade-fail boot.
- Toggling a module at runtime calls the same `toggleFunc(enabled)` — modules must be idempotently enable/disable-able. No reload required.

## 4. Libraries

**No Ace3.** No LibStub. No Ace-* dependencies in TOC. The addon hand-rolls:
- Its own `CallbackRegistry` (supports both function callbacks and `obj:method` style; events for addon-loaded, setting changes, async data ready).
- Its own settings panel UI (`Modules/ControlCenter/SettingsPanel*.lua`, `ScrollBar.lua`).
- Its own slash-command helper (`API.CreateSlashCommand`).
- Its own DB-defaults / per-character DB plumbing on top of raw saved variables.
- Its own locale loader (see below).

Result: zero external lib dependencies, all behaviour grep-able inside the repo.

## 5. Architecture

- Two-table namespace: `addonName, addon = ...`. `addon.API`, `addon.L`, `addon.CallbackRegistry`, etc. are sub-tables.
- Module pattern: each module file does `local _, addon = ...` at top, accesses `addon.API` / `addon.L`, registers via `AddModule({...})`. No globals leaked except a single `_G.Plumber_ToggleSettings` and `BINDING_*` strings.
- Event flow: a single master event frame in Initialization handles ADDON_LOADED / PLAYER_ENTERING_WORLD / PLAYER_LOGOUT / LOADING_SCREEN_DISABLED. Modules subscribe to higher-level addon-internal callbacks (`OnDBLoaded`, `OnSettingChanged`) instead of each owning a WoW event frame.
- Deferred work via `QueueEvent` to avoid loading-screen jank.
- Build-version gating: helpers detect WoW build (Midnight, Classics, MoP-Classic) so the same source supports the multi-flavor TOCs.

## 6. Settings / database

- Account DB: `PlumberDB`. Per-character DB: `PlumberDB_PC`. Telemetry/dev cache: `PlumberDevData`. Asset cache: `PlumberStorage`.
- Defaults applied in `LoadDatabase()`; missing keys get filled, version timestamp recorded for changelog popup detection.
- Module on/off lives at `PlumberDB[dbKey]`. `requiredDBValues` lets a module declare hard prerequisites — if the user disables prereq A, dependent module B is skipped automatically.
- "Force-enable for new features" with a 7-day "NEW" badge that auto-expires — drives discoverability without spam.

## 7. Options UI

- Custom panel in `Modules/ControlCenter/SettingsPanel*.lua`. Both an in-house canvas AND registered into Blizzard's modern Settings:
  ```
  Settings.RegisterCanvasLayoutCategory(BlizzardPanel, "Plumber");
  Settings.RegisterAddOnCategory(category);
  ```
- A `SettingsPanelRegistry` decouples module-registration from the renderer — modules register *what* they expose; the panel discovers them.
- Module-toggle UI is the headline UX: every feature has an independent on/off in a flat searchable list with category filters, alphabetical / by-date sort, and search box. This is the single biggest UX differentiator vs. typical Ace addon option trees.
- Addon Compartment button registered via `API.AddButtonToAddonCompartment(...)` with click + tooltip handlers — modern (Dragonflight+) micro-button entry point instead of a minimap LDB icon.

## 8. Slash command

- One slash: `/plumber` -> `Plumber_ToggleSettings()`.
- No sub-commands inside the slash; everything funnels into the GUI. Keybindings (`Bindings.xml`) cover power-user toggles (`TOGGLE_PLUMBER_LANDINGPAGE`, `PLUMBER_QUESTWATCH_NEXT/PREVIOUS`).

## 9. Locale strategy (non-Ace)

- `Locales/Localization.xml` declares load order: `enUS.lua` first (fallback / source of truth), then every other locale, then `PostLoad.lua` last.
- Each locale file does:
  ```lua
  local _, addon = ...
  local L = addon.L;
  L["Module Control"] = "Module Control";
  ```
  i.e. direct table writes. Subsequent locale files overwrite English keys when WoW's client locale matches — but Plumber actually loads ALL locale files; the locale table that "wins" depends on... actually it loads everything, which means the LAST file in XML order wins. (Pattern: enUS first as defaults, then locales in an order such that the final assignment matches the player. Some addons gate this with `if GetLocale() == "deDE" then`; Plumber's enUS file plain-assigns, and other-locale files appear to assign unconditionally too — relying on missing keys to fall back to enUS, with `PostLoad.lua` tying up cross-references.)
- `PostLoad.lua` does *reference assignment* — e.g. mapping new currency IDs to existing localized strings (`L[2806] = L[2706]`). Avoids duplicating translations; localizers only translate the canonical key.
- Globals like `BINDING_HEADER_PLUMBER` and `BINDING_NAME_*` are set directly in the locale file (Blizzard reads these globals when displaying keybindings).
- Dev capture: `API.SaveLocalizedText` writes untranslated strings into `PlumberDevData` so the author can collect missing-key reports from real users.
- Net: 12 locales supported with zero library; ~600+ keys.

## 10. Events / frames

- Centralized event frame in Initialization (4 master events). Modules typically subscribe to internal callbacks; only modules that *must* see a high-frequency WoW event create their own frame.
- `Bindings.xml` for keybindings (separate from XML scripting).
- `Modules/<area>/<area>.xml` is used by some sub-modules (e.g. ControlCenter) for `<Frame>` / `<Texture>` templates — XML for layout, Lua for behaviour.

## 11. Debug

- `PlumberDevData` saved variable acts as a dev-only telemetry sink (`SaveDataUnderKey`, `SaveLocalizedText`).
- `_Dev/` folder excluded from packaged build.
- `.luacheckrc` for static analysis.
- Disabled-module commenting pattern in TOC = trivial bisect.
- "Secret value" guards (`Secret_CanAccess`, `Secret_CanAccessValues`) protect against tainting Blizzard's secure environment when reading restricted API.

## 12. Packaging

- CurseForge as primary distribution (likely BigWigs packager via the standard `.pkgmeta`).
- 154 releases / 960 commits — fast cadence, semver-ish (`1.9.1`).
- One TOC per flavor lets the packager produce per-flavor zips cleanly.

---

## What "lean modern WoW addon" looks like in 2026 (per Plumber)

- Zero LibStub / zero Ace.
- Single shared namespace from `...`, no globals.
- Hand-rolled CallbackRegistry instead of AceEvent.
- Native Blizzard Settings API + custom canvas — no AceConfig/AceGUI tree.
- Addon Compartment (not minimap LDB) as primary entry point.
- One slash command, GUI-first.
- Per-flavor TOCs (multi-flavor `## Interface:` line for retail builds).
- Locales as plain Lua tables under `addon.L`, with a `PostLoad.lua` for derived keys.
- Module registry with metadata-driven enable/disable, validity checks, dependency declarations, "NEW" badges.
- `pcall`-wrapped module toggles so failures are isolated.

## Module-toggle UI pattern

Every feature is an entry in a flat, searchable, sortable list. Each entry has: name, description, category tag, "NEW" badge (auto-expires), and an on/off switch backed by `PlumberDB[dbKey]`. Toggling calls `module.toggleFunc(enabled)` immediately (no reload). Dependencies (`requiredDBValues`) auto-disable dependent modules when prereqs are off. Categories are soft tags, not folders — the user sees one list, not a tree.

---

## Patterns to steal (5)

1. **Metadata-driven module registry**: a single `AddModule({name, dbKey, categoryID, validityCheck, toggleFunc, requiredDBValues, minimumTocVersion, newFeatureExpiry})` API. Replaces ad-hoc per-file enable code with one declarative list.
2. **`toggleFunc(enabled)` contract under `pcall`**: every module is idempotent enable/disable, runtime, no reload, isolated failure. Massive UX win vs. the AceAddon "needs a /reload" tradition.
3. **Flat searchable module list as the options UI** — categories as filters, NEW-badge with auto-expiry, by-date sort. Discoverability for 100+ features without an AceConfig tree.
4. **`PostLoad.lua` for derived locale keys** (`L[2806] = L[2706]`). Translators translate canonical keys only; aliases and currency-ID-to-name maps live in one post-load pass.
5. **Dev-only saved variable (`PlumberDevData`) for telemetry/missing-locale capture**, plus `_Dev/` folder excluded from packaging. Lets the author harvest real-world data without shipping debug code.

Bonus: Addon Compartment as primary entry point + multi-build `## Interface: 120001, 120005` line + per-flavor TOCs is the modern packaging trifecta.

## Anti-patterns (3)

1. **100+ flat `*.lua` files in `Modules/`** alongside namespaced subfolders. The flat pile makes navigation, code-ownership, and diff review harder. Threshold for promoting a file into its own folder seems undefined; results in inconsistency.
2. **Locale loading without a `GetLocale()` gate**: every locale file is loaded for every player, and "last write wins". Wastes memory (12x string tables in RAM) and makes locale precedence implicit/order-dependent. AceLocale's `if not L then return end` short-circuit is the cheap fix.
3. **Commenting modules out in the TOC with `#` to "disable" them**: useful for the author's bisect workflow, but it bleeds into shipped TOCs (disabled modules visible to users) and means dead code keeps shipping. Should live in a branch or be removed.
