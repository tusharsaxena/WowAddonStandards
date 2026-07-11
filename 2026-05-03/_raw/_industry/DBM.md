# Deadly Boss Mods (DBM) — Architecture Research

Research date: 2026-05-03
Repo (canonical): https://github.com/DeadlyBossMods/DeadlyBossMods
Method: Read-only WebFetch of repo root, `.pkgmeta`, `DBM-Core_Mainline.toc`, `DBM-Core.lua`, `DBM-GUI.lua`, and selected `modules/objects/*.lua`.

## 1. TOC Structure

Source: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/DBM-Core_Mainline.toc

Per-flavor TOC files (one per expansion): `DBM-Core_Vanilla.toc`, `_TBC.toc`, `_Wrath.toc`, `_Cata.toc`, `_Mists.toc`, `_Mainline.toc`. Same pattern in `DBM-GUI/`, `DBM-Test/`, etc. — flavor-specific TOCs rather than relying on the WoW client's auto-resolution of `_Mainline`/`_Vanilla` suffixes (they use both: the file *is* `_Mainline.toc` and is loaded by the modern client).

Verbatim directives from `DBM-Core_Mainline.toc`:

```
## Interface: 120005
## X-Min-Interface: 110200
## Category: DBM
## Group: DBM-Core
## Title: |cffffe00a<|r|cffff7d0aDBM Core|r|cffffe00a>|r |cff69ccf0Main Core|r
## Notes: Deadly Boss Mods
## Author: MysticalOS, QartemisT
## Version: @project-version@
## Dependencies: DBM-StatusBarTimers
## OptionalDependencies: LibStub, CallbackHandler-1.0, LibSharedMedia-3.0, LibChatAnims, LibDBIcon-1.0, LibDeflate, LibSerialize, LibSpecialization, LibKeystone, CustomNames, Masque, ChatThrottleLib
## SavedVariables: DBM_AllSavedOptions, DBM_MinimapIcon, DBM_AnnoyingPopupDisables, DBM_ModsToLoadWithFullTestSupport, DBM_Keystones
## SavedVariablesPerCharacter: DBM_UsedProfile, DBM_UseDualProfile, DBM_CharSavedRevision
## IconTexture: Interface\AddOns\DBM-Core\textures\dbm_airhorn
## LoadOnDemand: 0
## DefaultState: enabled
## X-Curse-Project-ID: 3358
## X-Wago-ID: qv633o6b
## X-Website: https://deadlybossmods.com
```

### Notable / unusual TOC fields

- `## Category` and `## Group` — group sibling addons in the in-game AddOn list.
- `## IconTexture` — addon-list icon (modern client feature).
- `## X-Min-Interface: 110200` — explicit minimum, distinct from `## Interface`.
- `## X-Curse-Project-ID` and `## X-Wago-ID` — both packaging IDs side-by-side.
- `@project-version@` substitution token, resolved by BigWigs/CurseForge packager.
- `## DefaultState: enabled` is set explicitly.

## 2. Folder / File Layout

Top-level (https://github.com/DeadlyBossMods/DeadlyBossMods):

```
DBM-Core/              # core logic, libs, prototype objects
DBM-GUI/               # custom options panel
DBM-StatusBarTimers/   # timer bar widget (declared as Dependency)
DBM-Test/              # replay-driven characterization tests
DBM-Brawlers/          # content module
DBM-Midnight/          # content module (current expansion shorthand)
DBM-Raids-Midnight/    # content module
.github/  .vscode/
.editorconfig  .gitignore  .luacheckrc  .luarc.json  .pkgmeta
LICENSE  README.md
```

`DBM-Core/` contents (https://github.com/DeadlyBossMods/DeadlyBossMods/tree/master/DBM-Core):

```
modules/objects/   # prototype-based "classes" (BossMod, Timer, Announce, …)
modules/gui/       # GUI feature widgets (Latency, Durability, Keystones, …)
modules/           # cross-cutting modules (Commands, Sounds, Hyperlinks, …)
sounds/  textures/ tools/
DBM-Core.lua  DBM-Arrow.lua  DBM-Flash.lua  DBM-HudMap.lua
DBM-InfoFrame.lua  DBM-Nameplate.lua  DBM-RangeCheck.lua
ValidUIDs.lua  VoicePackSounds.lua  !SortList.txt
localization.<locale>.lua    # 10 files
commonlocal.<locale>.lua     # 10 files
```

Key insight: code is split into three layers — `modules/objects/` (prototypes / OOP base classes), `modules/` (cross-cutting features), root `DBM-*.lua` (top-level systems). Encounter mods live in entirely separate sibling addons (`DBM-Raids-Midnight`, `DBM-Brawlers`, …) declared by metadata, not by the core TOC.

## 3. Module Loading

Source: ordered file list in `DBM-Core_Mainline.toc` and `modules/Modules.lua`.

- **TOC-driven, not XML-embeds.** No `embeds.xml`. Every lua file is listed explicitly in the TOC; load order is the TOC order.
- The TOC sequence is intentional: libs → localizations → prototype objects → core lua → GUI features → modules → object modules. Prototypes are loaded *before* `DBM-Core.lua` so that `private:GetPrototype("DBM")` can return the live table.
- **Encounter modules are discovered, not statically registered.** From `DBM-Core.lua`: the `ADDON_LOADED` handler scans every loaded addon's TOC metadata for tags such as `X-DBM-Mod`, `X-DBM-Voice`, etc., and registers them dynamically. This lets third parties ship boss-mod packs without forking core.
- **Internal sub-systems** are registered via `private:NewModule(name)` / `private:GetModule(name)` (in `DBM-Core/modules/Modules.lua`). Each module exposes optional lifecycle hooks `OnModuleLoad()` and `OnModuleEnd()`, plus `RegisterEvents` / `RegisterShortTermEvents` for combat-scoped subscriptions.

## 4. Library Stack

Source: `.pkgmeta` (https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/.pkgmeta) and TOC file list.

Embedded libs (under `DBM-Core/Libs/`, fetched at packaging time):

| Lib | Source | Purpose |
|-----|--------|---------|
| LibStub | wowace | lib registration |
| CallbackHandler-1.0 | wowace | event/callback dispatch |
| ChatThrottleLib | wowace | chat throttling |
| LibChatAnims | wowace | chat frame animations |
| LibSharedMedia-3.0 | wowace | sounds/fonts/textures |
| LibLatency | wowace | latency reporting |
| LibDurability | wowace | durability reporting |
| LibKeystone | BigWigsMods | M+ keystone sync |
| LibSpecialization | BigWigsMods | spec detection |
| LibDataBroker-1.1 | tekkub | minimap/databroker |
| LibDBIcon-1.0 | wowace | minimap icon |
| LibDeflate | SafeteeWoW | compression for addon comms |
| LibSerialize | rossnichols | binary serialization |
| LibDropDownMenu | HizurosWoWAddOns | replacement for retired Blizzard dropdown API |
| LibCustomGlow-1.0 | Stanzilla | spell glow effects |

**Notably absent: Ace3.** No AceAddon, AceEvent, AceConfig, AceDB, AceLocale, AceConsole, AceTimer. DBM uses LibStub + CallbackHandler only; everything else is bespoke. Their lib choices align with BigWigs (LibKeystone, LibSpecialization, LibDeflate, LibSerialize), not the Ace3 ecosystem.

## 5. Core Architecture Pattern

Source: `DBM-Core.lua` and `modules/objects/PrototypeRegistry.lua`.

- File-private namespace via `local private = select(2, ...)` (the standard `...` second-arg trick for an addon-private table shared between files in the same TOC).
- Central `PrototypeRegistry` exposes `private:GetPrototype(name)` — a lazy table cache. Both producer (a prototype's defining file) and consumer (`DBM-Core.lua`) call `GetPrototype("DBM")` / `GetPrototype("DBMMod")` and end up with the *same* table. This decouples definition order from use, making the TOC ordering more forgiving.
- `DBM-Core.lua` then does `_G.DBM = DBM` to expose the global API, while `bossModPrototype = private:GetPrototype("DBMMod")` becomes the parent class of every encounter.
- Encounters use prototypal inheritance (metatable `__index = bossModPrototype`); each `DBM:NewMod(...)` call returns a new mod object that inherits Timer/Announce/SpecialWarning helpers.
- Compare to Ace3's `AceAddon:NewAddon` + `:NewModule` pattern: DBM achieves the same shape with ~50 lines of custom code and zero external dependency.

## 6. Settings Storage

Source: `DBM-Core_Mainline.toc` SavedVariables, and `loadOptions` references in `DBM-Core.lua`.

- Manual SavedVariables. No AceDB.
- Account-wide table `DBM_AllSavedOptions` keyed by profile name — DBM implements its own profile system rather than using AceDB profiles.
- Per-character split via `DBM_UsedProfile`, `DBM_UseDualProfile`, `DBM_CharSavedRevision` — supports a "dual profile" toggle (e.g., main vs alt spec).
- Distinct top-level SVs for orthogonal concerns: `DBM_MinimapIcon`, `DBM_AnnoyingPopupDisables`, `DBM_Keystones`, `DBM_ModsToLoadWithFullTestSupport`. Avoids the "one giant nested table" anti-pattern.
- `AddDefaultOptions()` walks a `DefaultOptions` table to backfill missing keys after a version upgrade.

## 7. Options UI

Source: `DBM-GUI/DBM-GUI.lua`.

- **Fully custom panel system, not AceConfig and not Blizzard `Settings.*` API.** Builds frames directly with `CreateFrame` and a hierarchy of `CreateNewPanel`, `CreateBossModPanel`, `CreateBossModTab`, `CreateArea`, plus widget factories `CreateCheckButton`, `CreateDropdown`, `CreateButton`, `CreateText`, `CreateLine`.
- Hierarchy: Addons -> Panels (raid/dungeon/world boss) -> SubPanels (seasonal variants) -> Mods (per-encounter).
- `Polyfills.xml` exists in `DBM-GUI/` — they ship compatibility shims rather than rely on Blizzard.
- Legacy: no `Settings.RegisterCanvasLayoutCategory` integration. The settings panel is its own standalone window.

## 8. Slash Commands

Source: `DBM-Core/modules/Commands.lua`.

- Raw WoW: `SLASH_DEADLYBOSSMODS1 = "/dbm"` and `SlashCmdList["DEADLYBOSSMODS"] = function(msg) ... end`.
- Dispatcher uses substring/pattern matching (`cmd:sub`, `string.match`) — no command-object table, no AceConsole.
- Branches dispatch to module methods like `DBM:ShowVersions()`, `DBM:CreatePizzaTimer()`, `DBM.Arrow:ShowRunTo()`.

## 9. Localization

Source: `DBM-Core/modules/objects/Localization.lua` plus 10 `localization.<locale>.lua` and 10 `commonlocal.<locale>.lua` files.

- Custom system, not AceLocale. 10 locales: en, br, cn, de, es, fr, it, kr, ru, tw.
- Tables use `__index` metatables with fallback chains — missing key returns the key itself (graceful degradation).
- Two-tier: per-mod localization objects created via `DBM:CreateModLocalization(name)`, plus shared `commonlocal.*` files for cross-mod strings.
- API per-mod: `:SetGeneralLocalization`, `:SetWarningLocalization`, `:SetTimerLocalization`, `:SetOptionLocalization`, `:SetOptionCatLocalization`, `:SetMiscLocalization`.
- `RegisterGeneratedLocales` / `GetGeneratedLocales` suggest tooling-driven locale generation (likely from spell IDs — `DBM-Core/tools/`).

## 10. Event Handling

Source: `DBM-Core.lua` and `modules/objects/BossModEventDispatcher.lua`.

- Custom dispatcher: a single `mainFrame = CreateFrame("Frame", "DBMMainFrame")` with a `handleEvent(self, event, ...)` script. No AceEvent.
- `registeredEvents` is a flat event -> {handlers} map.
- Combat log: dedicated CLEU branch with **spell-ID filtering at the dispatcher level** — handlers register with `eventArg = spellId`, and `handleEvent` only invokes matching handlers. Massive perf win versus calling every CLEU handler per combat event.
- Unit events: dedicated per-unit frames using `RegisterUnitEvent` (`registerUnitEvent` / `unregisterUnitEvent`) so e.g. a `UNIT_HEALTH` listener for `boss1` is not woken up by every party member's tick.
- Per-mod `BossModEventDispatcher` adds a second filter layer: `RegisterEvent` with optional spell-ID list, `RegisterRawEvent` for unfiltered. Handlers fire only when `handler.unfiltered or handler[spellId]`.
- `RegisterShortTermEvents` / `UnregisterShortTermEvents` for events that should only be live during a fight.

## 11. Frames / UI

- Mostly Lua-built `CreateFrame` calls. Minimal XML — only Polyfills.xml and the lib-side XMLs (`CallbackHandler-1.0.xml`, `LibChatAnims.xml`, `LibSharedMedia-3.0/lib.xml`, etc.) — DBM's own XML footprint is essentially zero.
- No evidence of frame pooling for warnings/timers in the files inspected (likely lives in `DBM-StatusBarTimers`).
- No secure templates — DBM does not need protected actions.

## 12. Debug / Logging

- `DBM:Debug(msg, level, ...)` is the canonical helper, used throughout `DBM-Core.lua`.
- `DBM:AddMsg(message)` for chat output.
- `test:Trace(mod, ...)` integrates with the `DBM-Test` framework — events are traced into the test recorder when the test runner is active.
- Levels are numeric and gated by a saved-variable threshold.

## 13. Packaging

Source: `.pkgmeta`.

- Standard BigWigs-style `.pkgmeta` (compatible with the CurseForge packager and the BigWigs packager fork).
- `externals:` block pulls all 15 libs at package time — they are not committed to the repo.
- `ignore:` strips lib `.toc`/`.xml`/README/docs/tests so libs do not register themselves as separate addons.
- `enable-nolib-creation: no` — only one zip variant is produced (libs always embedded).
- `move-folders:` — the build splits the monorepo into separate published addons (`DBM-Core`, `DBM-GUI`, `DBM-StatusBarTimers`, `DBM-Test`, `DBM-Midnight`, …) so users can disable content modules independently. Authoring is monorepo, distribution is multi-addon.
- Voicepack is a git external too: `DBM-VPVEM: https://github.com/DeadlyBossMods/DBM-Voicepack-VEM`.

## 14. Testing

Source: `DBM-Test/` (https://github.com/DeadlyBossMods/DeadlyBossMods/tree/master/DBM-Test).

- A *characterization / replay* test framework, not unit tests.
- Files: `Mocks.lua`, `Options.lua`, `Perf.lua`, `Registry.lua`, `Report.lua`, `ReportFrame.lua`, `Runner.lua`, `TimeWarper.lua`, plus `Public/` and `Tools/`.
- Workflow: capture a real fight via Transcriptor → store as a test case → `Runner.lua` replays the events into DBM with `Mocks.lua` standing in for game APIs and `TimeWarper.lua` advancing fake time → `Report.lua` diffs DBM's outputs (timers, warnings) against a golden snapshot.
- Ships in production as a real addon (`DBM-Test_Mainline.toc`); only loaded when the user opts in via `DBM_ModsToLoadWithFullTestSupport`.

## 15. Notable patterns to steal (named)

1. **Prototype Registry for loose load-order coupling.** `private:GetPrototype(name)` lazy-creates a shared table; producer and consumer files can be loaded in either order. Removes the "library must be defined before it is used" coupling pain.
2. **Two-stage event filtering (dispatcher + per-handler).** Central `mainFrame` filters by event name *and* by spell ID for CLEU at the dispatcher; per-mod `BossModEventDispatcher` filters again per-handler. Handlers only ever wake for events they care about.
3. **Discoverable sibling-addon modules via TOC metadata tags.** `X-DBM-Mod` lets third parties drop in encounter packs without core changes.
4. **`.pkgmeta` `move-folders:` for monorepo authoring + multi-addon distribution.** One git repo, many published addons. Users disable content packs without uninstalling the engine.
5. **Replay-based test harness shipped as an opt-in addon.** `DBM-Test` with `TimeWarper`, `Mocks`, golden reports; runs inside the live client without a separate Lua VM.
6. **Multi-flavor TOCs (`_Mainline`, `_Cata`, `_Vanilla`, `_TBC`, `_Wrath`, `_Mists`).** Lets the same source serve every WoW client without runtime version-sniffing.
7. **Split SavedVariables by concern.** Separate top-level SVs (`DBM_MinimapIcon`, `DBM_AnnoyingPopupDisables`, `DBM_Keystones`) instead of a single nested blob — cheaper merges, cleaner upgrades.
8. **Localization `__index` chain returning the key on miss.** Bugs become visible (English key in chat) instead of `nil`-crashing.

## 16. Anti-patterns / things to avoid

1. **Custom GUI framework instead of AceConfig or `Settings.RegisterCanvasLayoutCategory`.** ~1500 lines of bespoke options code (`DBM-GUI.lua` plus modules). For a Ka0s-scale addon this is enormous overkill and re-implements solved problems; AceConfig + a generated options table beats this for maintainability.
2. **`SlashCmdList` substring/pattern dispatcher with no command table.** Adding a subcommand requires editing a long if/elseif chain in `Commands.lua`. AceConsole or a `commands = { name = { handler, help } }` table is dramatically cleaner.
3. **Re-implementing AceDB-style profile management by hand.** Dual-profile, profile copy, profile reset, and per-character tracking are all custom — lots of surface area for bugs that AceDB has already shaken out over a decade.
4. **No `embeds.xml` and no `## OptionalDependencies` indirection for libs — every lib path hard-coded in 6 TOC files.** A lib version bump means editing every flavor TOC. An `Embeds.xml` (or one shared `Libs.xml`) reduces this to a single file.
5. **Locale strings as 20 separate top-level lua files in the TOC instead of conditional load by `GetLocale()`.** All 10 locales' tables are built at load time even though the user uses one.

## URLs cited

- Repo: https://github.com/DeadlyBossMods/DeadlyBossMods
- `.pkgmeta`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/.pkgmeta
- Mainline TOC: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/DBM-Core_Mainline.toc
- DBM-Core tree: https://github.com/DeadlyBossMods/DeadlyBossMods/tree/master/DBM-Core
- DBM-GUI tree: https://github.com/DeadlyBossMods/DeadlyBossMods/tree/master/DBM-GUI
- DBM-Test tree: https://github.com/DeadlyBossMods/DeadlyBossMods/tree/master/DBM-Test
- `DBM-Core.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/DBM-Core.lua
- `DBM-GUI.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-GUI/DBM-GUI.lua
- `modules/Modules.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/modules/Modules.lua
- `modules/Commands.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/modules/Commands.lua
- `objects/PrototypeRegistry.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/modules/objects/PrototypeRegistry.lua
- `objects/Localization.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/modules/objects/Localization.lua
- `objects/BossModEventDispatcher.lua`: https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/DBM-Core/modules/objects/BossModEventDispatcher.lua
