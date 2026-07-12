# Details! Damage Meter — Principal-Engineer Research

Target: https://github.com/Tercioo/Details-Damage-Meter
Date: 2026-05-03
Method: WebFetch, read-only.

---

## 1. Repository Layout

Top-level dirs: `.github/`, `Libs/`, `assets/textures/icons/`, `classes/`, `core/`, `fonts/`, `frames/`, `functions/`, `images/`, `locales/`, `plugins/`, `sounds/`.

Key root files: `Details.toc` (+ `Details_Classic.toc`, `Details_Cata.toc`, `Details_TBC.toc`, `Details_Wrath.toc`, `Details_Mists.toc`), `.pkgmeta`, `Details.xml`, `embeds.xml`, `boot.lua`, `startup.lua`.

Source: https://github.com/Tercioo/Details-Damage-Meter

## 2. TOC

- Interface: `120005`; `Interface-Mists: 50503`; `Version: #@project-version@` (BigWigs Packager substitution).
- SavedVariables: `_detalhes_global`, `__details_backup`, `__details_debug`. Per-char: `_detalhes_database`.
- OptionalDeps: `Ace3, LibSharedMedia-3.0, LibWindow-1.1, LibDBIcon-1.0, NickTag-1.0, LibDataBroker-1.1, LibGraph-2.0`.
- Curse ID 61284, Wago ID `qv63A7Gb`. `AddonCompartmentFunc: Details_OpenDefaultOptionsWindow`.
- ~222-line manifest. Load order: libs (via `libs.xml`) → parser → 11 locales → core (Definitions, boot, indent, utilities) → ~70 function modules → ~40 frame/window files → class definitions → plugins/network/parser-control.

Source: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Details.toc

## 3. Bootstrap & Architecture

`boot.lua` builds the addon as an Ace3 addon despite the custom UI framework:

```lua
_G.Details = LibStub("AceAddon-3.0"):NewAddon(
  "_detalhes", "AceTimer-3.0", "AceComm-3.0",
  "AceSerializer-3.0", "NickTag-1.0")
```

Hierarchical namespaces (`Details222.B` data accessor, `Details222.Storage`, `Details222.ContextManager`, `Details222.Pets`, `Details222.MythicPlus`, `Details222.Cache`, `Details222.Cooldowns`, `Details222.Recap`). The "v222" suffix is a one-time refactor flag — the v1 namespace `Details` remains for backwards-compatible APIs while internal refactored code moves under `Details222`. Useful pattern for addons that need to break internals without breaking plugins.

`Details.xml` is minimal: a single `<Frame name="_detalhes_listener">` registered for `ADDON_LOADED`, routing to `_detalhes.OnEvent()`. All other frames are programmatic (Lua-built, no XML templates).

Source: https://github.com/Tercioo/Details-Damage-Meter/blob/master/boot.lua, https://github.com/Tercioo/Details-Damage-Meter/blob/master/Details.xml

## 4. Startup Sequence (`startup.lua`)

Custom event listener `Details.listener:RegisterEvent(...)` for `PLAYER_REGEN_DISABLED/ENABLED` etc. Combat log uses a dedicated frame:

```lua
Details222.parser_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
```

Conditional registration via `detailsFramework.IsWarWowOrBelow()` to flavor-gate parsing. Initialization is staged: profile load → window creation → event binding → callback registration (LibOpenRaid) → cache prefill → UI refresh. Heavy work deferred via `C_Timer.After(2, ...)` — minimap, hot-corner, aura-creation windows scheduled at 5 s.

Source: https://github.com/Tercioo/Details-Damage-Meter/blob/master/startup.lua

## 5. Combat-Log Parser — Performance

`core/parser.lua` is a single dedicated frame (`Details222.parser_frame`) bound to `COMBAT_LOG_EVENT_UNFILTERED`. It calls into typed handlers (`parser:spell_dmg(token, time, sourceSerial, sourceName, ...)`, `parser:MonkStagger_damage`, `parser:SLT_damage`, `parser:LOTM_damage`) with token discrimination inside (e.g. `if token == "SWING_DAMAGE"`). Optimizations:

- Module-level upvalues for `UnitGUID`, `GetTime`, `Details.habilidade_dano.Add`, `Details.habilidade_cura.Add` (saves a global lookup per event).
- Weak-table caches: `damage_cache`, `damage_cache_pets`, `healing_cache` use `setmetatable({}, Details.weaktable)` so cached actor refs are GC'd between segments.
- Serial-keyed npcId cache: `npcid_cache[targetSerial]` avoids re-running `tonumber(targetSerial:match(...))` on every event.
- Early-return guards (`no target name, just quit`).
- Side-channel events: `UNIT_MAXHEALTH` handled on `Details.HealthMaxFrame` rather than inside the CLEU hot path.

Sources: https://github.com/Tercioo/Details-Damage-Meter/blob/master/core/parser.lua, https://github.com/Tercioo/Details-Damage-Meter/tree/master/core

## 6. Segment / Encounter Control (`core/control.lua`)

`Details222.StartCombat(...)`, `Details:SairDoCombate(bossKilled, bIsFromEncounterEnd)` — explicit segment lifecycle distinct from CLEU. `Details:FindBoss(noJournalSearch)`, `Details:ReadBossFrames()`, `foundEncounterInfo(...)` for encounter detection. Minimum-duration validation discards trash blips. Arena helper `Details:GetPlayersInArena()` caches roster.

## 7. Plugin Architecture

Single primary registration entry point in `core/plugins.lua`:

```lua
function Details:InstallPlugin(pluginType, pluginName, pluginIcon,
  pluginObject, pluginAbsoluteName, minVersion, authorName,
  version, defaultSavedTable)
```

Returns `(install, saveddata, isEnabled)` so plugins receive their persisted SV table back. Companion factories: `Details:NewPluginObject(frameName, pluginFlag, pluginType)` and `Details:CreatePluginOptionsFrame(name, title, template, pluginIcon, pluginIconCoords)`.

Four plugin types: `SOLO`, `RAID`, `TOOLBAR`, `STATUSBAR`. Each maps to a host file (`core/plugins_solo.lua`, `core/plugins_raid.lua`, `core/plugins_toolbar.lua`, `core/plugins_statusbar.lua`).

Bundled plugins (each a separate addon folder, hoisted by `.pkgmeta` `move-folders` from `Details/plugins/X` to top-level `X`): `Details_Compare2`, `Details_DataStorage`, `Details_EncounterDetails`, `Details_RaidCheck`, `Details_Streamer`, `Details_TinyThreat`, `Details_Vanguard`. Plugins call `Details:InstallPlugin(...)` from their own `installPluginFunc()` triggered on `ADDON_LOADED` after a 1 s delay (gives Details core time to finish boot).

Sources: https://github.com/Tercioo/Details-Damage-Meter/blob/master/core/plugins.lua, https://github.com/Tercioo/Details-Damage-Meter/blob/master/.pkgmeta, https://github.com/Tercioo/Details-Damage-Meter/blob/master/plugins/Details_EncounterDetails/Details_EncounterDetails.lua

## 8. Details Framework (DF) — UI Library

`Libs/DF/fw.lua`:

```lua
local major, minor = "DetailsFramework-1.0", dversion -- 723
local DF, oldminor = LibStub:NewLibrary(major, minor)
if (not DF) then DetailsFrameworkCanLoad = false; return end
_G["DetailsFramework"] = DF
```

LibStub library + global handle + load guard flag. `dversion = 723` indicates a long-lived, heavily iterated library (compare AceGUI minor numbers).

Module surface (~50 files): widgets (`button`, `label`, `slider`, `dropdown`, `keybind`, `scrollbar`, `picture`, `pictureedit`, `icon`, `icon_midnight`, `icongeneric`); containers (`panel`, `frames`, `containers`, `scrollbox`, `tabcontainer`, `header`); advanced (`charts`, `cooltip`, `rounded_panel`, `buildmenu`, `line_indicator`); systems (`mixins`, `anchorsystem`, `auras`, `schedules`, `savedvars`, `languages`, `colors`, `math`, `editor`, `ejournal`, `elapsedtime`, `iteminfo`, `spells`, `packtable`, `help`, `scripting`, `loadconditions`).

API style — table-OOP w/ metatables and mixin composition, *not* AceGUI's "container holds children" model:

```lua
function detailsFramework:CreatePanel (parent, w, h, backdrop,
  backdropcolor, bordercolor, member, name)
function detailsFramework:NewPanel(parent, container, name, member,
  w, h, backdrop, backdropcolor, bordercolor)
detailsFramework:Mixin(PanelMetaFunctions, detailsFramework.ScriptHookMixin)
```

Each widget is a Lua object with `dframework = true`, holds the real frame as `.frame`/`.widget`, and exposes properties via `__index`/`__newindex` metamethods backed by `GetMembers["tooltip"]` / `SetMembers["color"]` tables. So `panel.width = 200` maps to a setter, and `panel:GetTooltip()` is generated.

`cooltip.lua` is a custom GameTooltip replacement supporting submenus, status bars, custom textures, wallpapers, icons, gradients, rounded corners, click handlers — i.e., a real menu/tooltip widget.

**Should it be treated as an alternative to AceGUI?** Yes, but a different shape: AceGUI is container-tree + layout-engine; DF is widget-toolkit + mixin/metatable property API closer to Blizzard frame conventions. It is more permissive (you mount widgets onto any parent frame you like) and its widget set (charts, scripting editor, anchor system, tab containers, ejournal, scrollbox) is broader than AceGUI's. Tradeoff: no published API doc surface — it's read the source / read the `.examples.lua`. For projects where AceConfig + AceGUI is enough, DF is overkill. For projects with bespoke combat-style UIs (timelines, charts, themable tooltips), DF is the strongest non-Blizzard option.

Sources: https://github.com/Tercioo/Details-Damage-Meter/tree/master/Libs/DF, https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/fw.lua, https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/panel.lua, https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/cooltip.lua

## 9. Slash Commands (`functions/slash.lua`)

```lua
SLASH_DETAILS1, SLASH_DETAILS2, SLASH_DETAILS3 = "/details", "/dt", "/de"
function SlashCmdList.DETAILS (msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = string.lower(command)
    if (command == Loc["STRING_SLASH_WIPE"] or command == "wipe") then ...
    elseif (command == "api") then Details.OpenAPI()
    elseif (command == Loc["STRING_SLASH_NEW"] or command == "new") then
        Details:CriarInstancia(nil, true)
```

Plain Blizzard `SLASH_*` + `SlashCmdList`, no AceConsole. Each branch matches both the localized command *and* the English fallback — multilingual without breaking macros.

Source: https://github.com/Tercioo/Details-Damage-Meter/blob/master/functions/slash.lua

## 10. Localization

`/locales/Details-<code>.lua`, 10–11 locales (`deDE`, `enUS`, `esES`, `esMX`, `frFR`, `itIT`, `koKR`, `ptBR`, `ruRU`, `zhCN`, `zhTW`). Plain Lua tables (not AceLocale). Locale loaded *before* core in TOC order; access through a module-level `Loc` table.

Source: https://github.com/Tercioo/Details-Damage-Meter/tree/master/locales

## 11. Packaging (`.pkgmeta`)

`package-as: Details` plus seven `move-folders` directives that promote each `Details/plugins/<Name>` into a sibling top-level addon at package time. Result: one repo, one CI pipeline, eight independently-installable addons. Curse/Wago metadata in TOC, BigWigs-Packager substitution token `#@project-version@`.

Source: https://github.com/Tercioo/Details-Damage-Meter/blob/master/.pkgmeta

## 12. Frames / Windows

`frames/` holds ~40 window definitions (options, attributes, breakdown, mythicrun, etc.). `core/windows.lua` manages the instance-window object (Details calls a meter window an "Instance"). Programmatic frames; XML used only for top-level loading and a couple of widget templates.

## 13. Debug

SV `__details_debug`. `core/inspect.lua` + `Details222.Storage` debug flags. No formal `:Print` logger — debug is mostly conditional `print(...)` gated on the SV flag.

---

## Patterns to Steal (5)

1. **Dedicated CLEU frame with token-dispatched handler functions and module-level upvalues.** Don't put `COMBAT_LOG_EVENT_UNFILTERED` on the same frame as your other events; budget every global lookup out of the hot path; use weak tables for actor caches.
2. **`InstallPlugin` registration API returning `(install, savedData, isEnabled)`.** A single typed factory beats ad-hoc plugin discovery — it forces version metadata, gives you the SV back, and lets the host return an "is the plugin allowed to load" bit.
3. **`.pkgmeta` `move-folders` to ship N separately-installable addons from one repo.** Removes the "monorepo vs marketplace" tension; users install only the plugin they want.
4. **Versioned namespace migration (`Details` → `Details222`).** Preserves the public surface of the old namespace while letting internals churn freely. Pragmatic alternative to a hard SemVer break.
5. **DF mixin + GetMembers/SetMembers table pattern.** Lets each widget declare typed property accessors in tables instead of writing `Get*`/`Set*` boilerplate, and inheritance is composition (`detailsFramework:Mixin(...)`), not class hierarchy.

## Anti-patterns (3)

1. **Mixed namespaces and Portuguese/English identifiers** — `SairDoCombate`, `CriarInstancia`, `habilidade_dano`, `_detalhes`, alongside `StartCombat`, `Storage`. The legacy of an originally-pt_BR project leaked into the public API surface forever; once `_detalhes` shipped, removing it would break every saved variable on earth. Pick one language and *enforce* it from commit one.
2. **Massive flat TOC (~222 lines), ~70 files in `functions/`, ~40 in `frames/`.** Discoverability is awful — you must grep to find anything. A meter doesn't *need* this; the file count grew because there's no enforced module boundary. Prefer fewer, larger, intent-named files (e.g. `combat/`, `ui/instance/`, `report/`) over "one concern, one file".
3. **Custom UI framework with no public docs and 700+ minor versions.** DF is technically excellent but practically un-onboardable: no API site, no `:doc()`, examples scattered as `.examples.lua` siblings. If you ship a framework, ship docs — or you've shipped a black box only its author can extend.

---

## Citations

- Repo: https://github.com/Tercioo/Details-Damage-Meter
- TOC: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Details.toc
- boot.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/boot.lua
- startup.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/startup.lua
- Details.xml: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Details.xml
- .pkgmeta: https://github.com/Tercioo/Details-Damage-Meter/blob/master/.pkgmeta
- core/: https://github.com/Tercioo/Details-Damage-Meter/tree/master/core
- core/parser.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/core/parser.lua
- core/control.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/core/control.lua
- core/plugins.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/core/plugins.lua
- functions/slash.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/functions/slash.lua
- locales/: https://github.com/Tercioo/Details-Damage-Meter/tree/master/locales
- plugins/: https://github.com/Tercioo/Details-Damage-Meter/tree/master/plugins
- Libs/DF/: https://github.com/Tercioo/Details-Damage-Meter/tree/master/Libs/DF
- Libs/DF/fw.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/fw.lua
- Libs/DF/panel.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/panel.lua
- Libs/DF/cooltip.lua: https://github.com/Tercioo/Details-Damage-Meter/blob/master/Libs/DF/cooltip.lua
- plugins/Details_EncounterDetails: https://github.com/Tercioo/Details-Damage-Meter/blob/master/plugins/Details_EncounterDetails/Details_EncounterDetails.lua
