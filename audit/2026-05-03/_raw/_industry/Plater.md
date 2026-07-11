# Plater Nameplates — Principal-Engineer Research

Date: 2026-05-03
Repo: https://github.com/Tercioo/Plater-Nameplates
Method: Read-only WebFetch of repo root, TOC, core lua, scripting modules, options, locale, slash, logs, default settings.

---

## 1. TOC and Multi-Version Strategy

Source: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater.toc

- **Interface lines (multi-toc, single file):** `## Interface: 120005, 120007` (Retail), plus MoP 50503/50504, TBC 20505, Vanilla 11508. Plater ships ONE TOC supporting all flavors via comma-separated and per-flavor lines. (Modern WoW supports comma-separated Interface; older flavors use `Plater_Mainline.toc`/etc. via `## Interface-Cata`/`-Vanilla` build tags.)
- **SavedVariables:** `PlaterDB`, `PlaterLanguage`, `PlaterLogs`, `PlaterBackup`.
- **SavedVariablesPerCharacter:** `PlaterDBChr`.
- **OptionalDeps:** `Masque`. **No RequiredDeps** — DetailsFramework is **embedded** in `libs/DF/`, not a hard external dependency at the TOC level.
- ~45 lua/xml files loaded in a documented order.

## 2. File Layout / Load Order

Source: TOC (above)

```
libs/libs.xml                       -- one xml drives every embedded library
locales/<11 client locales>.lua     -- enUS first (default fallback)
Plater.xml                          -- frame XML templates
Definitions.lua                     -- shared constants
Plater_DefaultSettings.lua          -- PLATER_DEFAULT_SETTINGS table
Plater_Data.lua                     -- static data (NPC ids, encounter ids)
Plater_Logs.lua                     -- diagnostic log ringbuffer
Plater_Util.lua                     -- shared helpers
Plater.lua                          -- main, ~13.8k lines, 555 KB
Plater_ScriptHelpers.lua            -- helpers for user mods
Plater_PerformanceUnits.lua
Plater_ColorFrame.lua
Plater_SlashCMD.lua                 -- slash dispatcher
Plater_ImportExport.lua             -- profile/script import/export pipeline
Plater_Comms.lua                    -- AceComm channel
Plater_Auras.lua / GhostAuras*.lua  -- aura system
Plater_Resources*.lua               -- combo points / power
Plater_OptionsPanel.lua             -- main options
Plater_ScriptingOptions.lua         -- mod/script editor
Plater_ScriptingPanels.lua          -- mod/script list UI
Plater_ScriptLibrary.lua            -- script storage + revision
Plater_AnimationEditor.lua
Plater_Designer*.lua                -- visual profile designer
Plater_BossModsSupport.lua
Plater_Animations.lua
Plater_NpcColorPanels.lua
Plater_CastColorPanels.lua
Plater_SpellList.lua
Plater_Audio.lua
Plater_Profiling.lua                -- /plater profstart core/advance/mods
Plater_Plugins.lua                  -- third-party plugin registry
Plater_DebugFrames.lua
Plater_API.lua                      -- public API surface
options/Plater_O_*.lua              -- per-section option panels
Plater_LoadFinished.lua             -- last; signals init complete
```

Pattern: **flat lua files prefixed `Plater_`** rather than module folders, with `options/` as the only subfolder for option panels.

## 3. Library Stack (libs/)

Source: https://github.com/Tercioo/Plater-Nameplates/tree/master/libs

- **DetailsFramework (DF)** — embedded sibling framework from the Details! Damage Meter ecosystem. This is the **load-bearing** dependency.
- **Ace3 partial:** AceAddon, AceComm, AceConfig, AceConsole, AceDB, AceDBOptions, AceEvent, AceGUI, AceLocale, AceSerializer, AceTimer.
- **Support:** LibStub, CallbackHandler-1.0, LibSharedMedia-3.0, LibDataBroker-1.1, LibDBIcon-1.0, LibRangeCheck-3.0, LibCustomGlow-1.0, LibDeflate, LibCompress, LibClassicCasterino, LibTranslit-1.0.

Plater **uses Ace libs as primitives** (Serializer, Comm) but does **not** use AceAddon/AceEvent/AceLocale's idiomatic patterns — DF supplies those.

## 4. Architecture: DetailsFramework as Sibling Framework

Source: Plater.lua (head)

```lua
local DF = _G ["DetailsFramework"]
local addonId, platerInternal = ...
if (not DF) then
    print ("|cFFFFAA00Plater: framework not found, ...|r")
    return
end
local Plater = DF:CreateAddOn ("Plater", "PlaterDB", PLATER_DEFAULT_SETTINGS, ...)
```

- `DF:CreateAddOn` replaces `AceAddon:NewAddon`. DF wraps AceDB internally and returns the addon namespace.
- The `...` vararg gives `(addonId, platerInternal)`. **`platerInternal` is the cross-file private table** passed through every file's vararg — modules write to it (e.g. `platerInternal.VarSharing.HOOK_NAMEPLATE_ADDED`) instead of polluting `_G` or attaching to `Plater`.
- DF supplies: tab containers, BuildMenu (declarative options), language/localization (`DetailsFramework.Language.RegisterLanguage`), table utilities, color parsing, status bar widgets, and the `unitFrame:ScriptRunHook` mod-trigger plumbing.

Lesson: when an author already maintains a UI framework, **embedding it as a private library and using its addon-bootstrap saves duplicating 5–10k lines** of widget/menu/locale code.

## 5. Nameplate Frame Manipulation Without Taint

Sources: Plater.lua

Plater's hardest engineering problem is decorating Blizzard's secure nameplate frames without breaking combat protection. Strategy:

1. **Augment, do not replace.** Blizzard creates `nameplateN`. Plater attaches a child `unitFrame` table:
   ```lua
   local namePlate = C_NamePlate.GetNamePlateForUnit (unitID)
   local unitFrame = namePlate.unitFrame   -- Plater-created child
   local healthBar = unitFrame.healthBar
   local castBar   = unitFrame.castBar
   ```
   The Blizzard `UnitFrame` child remains in place; Plater's healthBar/castBar are siblings.
2. **Secure API for lookups.**
   ```lua
   local plateFrame = C_NamePlate.GetNamePlateForUnit (unitId, issecure())
   ```
   Passing `issecure()` opts into the secure path when called from a secure context.
3. **Deferred init via timers, not OnUpdate hammering:**
   ```lua
   plateFrame.HasUpdateScheduled = C_Timer.NewTimer (scheduleTime or 0,
       Plater.RunScheduledUpdate)
   ```
   Avoids running mutation logic before unit data is server-confirmed.
4. **Optional UIParent reparenting** for advanced layering, gated behind explicit profile flags (`ui_parent_base_strata`, `ui_parent_cast_strata`) and per-frame strata/level tracking in `Plater.UpdateUIParentLevels`.
5. **No `hooksecurefunc` on combat-restricted methods.** Plater hooks lifecycle events (`NAME_PLATE_UNIT_ADDED`, `NAME_PLATE_CREATED`, `NAME_PLATE_UNIT_REMOVED`) and acts on the secondary `unitFrame`.

Net effect: heavy visual customization with near-zero taint surface because the original Blizzard frame is untouched.

## 6. Mod / Script Sandbox API

Sources: Plater_ScriptLibrary.lua, Plater_ScriptingPanels.lua, Plater.lua

- Scripts/Mods are stored in `PlaterScriptLibrary["Name"]` as table objects:
  ```lua
  PlaterScriptLibrary["Script Name"] = {
      Revision = number,
      ScriptType = "script" | "hook",
      String = "<encoded>",      -- compressed source
      Enabled = boolean,
      OverrideTriggers = "merge" | true | false,
  }
  ```
- **Compile pipeline:** `Plater.CompileHook` and `Plater.WipeAndRecompileAllScripts`. Source is compiled with `loadstring(script, "Q")` (the chunkname is `"Q"` for short stack traces). The editor preview uses `loadstring("return " .. expr, "Q")` to validate expressions.
- **Environment exposure:** Plater publishes two env tables shared via `platerInternal.VarSharing`:
  - `PLATER_GLOBAL_MOD_ENV` (mod-scope persistent state)
  - `PLATER_GLOBAL_SCRIPT_ENV` (script-scope persistent state)

  These are not strict sandboxes (Plater does not block `_G`); they provide **per-mod and per-script persistent tables** scripts can write to without leaking. The `setfenv` call near the top of `Plater.lua` is even commented out (`--local setfenv = setfenv --200 locals limit`) — Plater stays under Lua's 200-upvalue limit and trusts mod authors. Security is by **revision tracking, UID, and explicit user import**, not by sandboxing.
- **Hook dispatch:** `unitFrame:ScriptRunHook(scriptInfo, ...)`. Each lifecycle event (Nameplate Added/Removed/Created/Updated, Cast Start/Stop, Combat Enter/Leave, Aura On/Off, etc.) iterates only enabled hooks via cached `HOOK_NAMEPLATE_ADDED.ScriptAmount` counters — early-out when zero.
- **API surface for scripts:** `Plater.APIList` (e.g. `Plater.SetNameplateColor`, `Plater.FlashNameplateBorder`) and `Plater.FrameworkList` (DF widgets: `CreateFlash`, `CreateLabel`, `CreateBar`).

Trade-off: Plater chose **trust + revisions over hard sandbox**. Acceptable because users explicitly import each mod string; aligns with WeakAuras' approach.

## 7. Profile / Script Import-Export

Source: Plater_ImportExport.lua

Pipeline:
1. **Indexed conversion** — `Plater.PrepareTableToExport` converts the named-key script object into a numeric-indexed array (`tableToExport["addon"]="Plater"`, `tableToExport["tocversion"]=...`). Smaller serialized footprint, version-tagged.
2. **Serialize** — `LibAceSerializer:Serialize(indexedTable)`.
3. **Compress + encode** — `Plater.CompressData(t, "comm")` (binary, AceComm-safe) or `Plater.CompressData(t, "print")` (printable, paste-safe — LibDeflate `EncodeForPrint`).
4. **Validate on import** — required indices checked: `if not indexTable["1"] or not indexTable["9"] then return nil end`.
5. **Revision gate** — `if scriptObject.Revision >= newScript.Revision then ...` prevents downgrades.
6. **UID + PlaterCore version** — every import is tagged for compatibility checks.

This is the WeakAuras-style "string starts with `!Plater:1!...`" payload, but Plater explicitly distinguishes the comm format from the print format — important because AceComm has byte restrictions LibDeflate's `EncodeForPrint` does not.

## 8. Settings (PLATER_DEFAULT_SETTINGS)

Source: Plater_DefaultSettings.lua

- Single top-level key `profile = {...}`.
- ~15-20 domains: core CVars, class/NPC colors, audio/cast, positioning, plate type configs (friendlyplayer/enemyplayer/friendlynpc/enemynpc/player), resources, auras, health/cast bars, threat, range/transparency, animations, BossMod, designer, UIParent.
- `Plater.RefreshDBUpvalues()` flushes hot profile values into local upvalues (`DB_AURA_ENABLED`, `DB_AURA_ALPHA`, `DB_USE_RANGE_CHECK`...) so per-frame OnUpdate loops avoid table indirection. Required after every settings change.

## 9. Options UI

Source: Plater_OptionsPanel.lua

Built with DF, **not** AceConfig:
```lua
local mainFrame = DF:CreateTabContainer (f, "Plater Options",
    "PlaterOptionsPanelContainer", {...}, frame_options, hookList, languageInfo)
```
Option entries are still **declarative tables**, AceConfig-shaped but processed by DF's `BuildMenu`:
```lua
{ type = "toggle", boxfirst = true,
  get = function() return Plater.db.profile.aura_enabled end,
  set = function (self, fixedparam, value)
      Plater.db.profile.aura_enabled = value
      Plater.RefreshDBUpvalues()
      Plater.UpdateAllPlates()
  end,
  name = "OPTIONS_ENABLED", desc = "OPTIONS_ENABLED" }
```
Note `name`/`desc` are localization **keys**, resolved by DF Language at render time — late binding, locale-aware.

## 10. Slash Commands

Source: Plater_SlashCMD.lua

Direct `SlashCmdList` (no AceConsole):
```
SLASH_PLATER1 = "/plater"
SLASH_PLATER2 = "/nameplate"
SLASH_PLATER3 = "/nameplates"
SlashCmdList.PLATER = function(msg, editbox) ... end
```
Subcommands: `version`, `showlogs`, `diag`/`debug`, `color`, `add <id>`, `rare`, `profstart`/`profstartcore`/`profstartadvance`/`profstartmods`, `profstop`, `profprint`, `minimap`, `compartment`, `cvar <name>`, `resetcvar <name>`, `uninstall`. Bare `/plater <number>` jumps to options tab N.

Profiling subcommands surface a real performance harness — rare in addons.

## 11. Localization

Source: locales/enUS.lua

```lua
do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "enUS")
    local L = languageTable
    L["DISABLE_TESTING_AURAS"] = "Disable Testing Auras"
    ...
end
```
Custom DF locale system (not AceLocale-3.0). DF picks the active client locale, falls back to enUS, and exposes `L` to all consumers via `addonId`. Strings stored in SavedVariable `PlaterLanguage` allow runtime swap and even community-overridden translations.

## 12. Events

Source: Plater.lua

Single dispatcher frame:
```lua
Plater.EventHandlerFrame = CreateFrame ("frame")
-- eventFunctions[event] = function(...) end
-- centralized OnEvent: dispatch via eventFunctions[event](...)
Plater.RunFunctionForEvent ("NAME_PLATE_UNIT_ADDED", unitId)
```
Manual dispatcher — no AceEvent. One `RegisterEvent`, one OnEvent, table lookup. Cheaper than AceEvent's CallbackHandler for high-frequency events like `NAME_PLATE_UNIT_ADDED`.

## 13. Frames & Templates

- `Plater.xml` declares reusable frame templates (status bars, glow regions, aura icons).
- Animations and visual effects are factored into `Plater_Animations.lua` and `Plater_AnimationEditor.lua` (drag-drop animation timeline).
- Resources, ghost auras, and combo points each live in dedicated `_Frames`/`_Options` pairs — **frame definition and its options panel are colocated by feature**, not split into a global "frames" folder.

## 14. Debug / Diagnostics

- `Plater_Logs.lua` keeps two ring buffers in `PlaterLogs` SV: `_general_logs` (cap 19) and `_error_logs` (cap 9), each row prefixed by `platerInternal.Date.GetDateForLogs()`.
- `/plater showlogs` dumps both.
- `/plater diag` prints CVars, alpha/size/positioning state.
- `Plater_Profiling.lua` + `/plater profstart{core,advance,mods}` → `profprint`: per-script and core-fn timing.
- `Plater_DebugFrames.lua` provides on-screen frame inspection.

This is **first-class observability** — most addons ship `print` debug at best.

## 15. Packaging

- `.github/` (CI / package script).
- `luaserver.lua` exists at root — likely a stub for Lua-language-server / EmmyLua type hints during dev.
- `Plater_LoadFinished.lua` is the **last** TOC entry — anything that must run after every other module registers its tables (final defaults sweep, version bump migration) lives there. Equivalent to a "post-init" file.

---

## Notable Patterns To Steal

1. **Sibling private framework via `...` vararg.** `local addonId, platerInternal = ...` and DF: cross-file shared state without globals, plus a re-usable widget/menu library you control. Massive code reuse across an addon family.
2. **Hot-path upvalue cache + explicit refresh.** `RefreshDBUpvalues()` after any settings change converts O(table-lookup) per-frame work into O(local). Pair with a single "settings changed" callback so authors cannot forget.
3. **Multi-flavor single TOC + `## Interface: 120005, 120007, 50504, 20505, 11508`.** One repo, every client. SavedVariables stay compatible.
4. **Declarative option entries with localization keys, not strings.** `name = "OPTIONS_ENABLED"` resolved at render time. Adding a translation never requires touching options code.
5. **Import/export as indexed-array → AceSerializer → LibDeflate (print *vs* comm encoding) with revision + UID.** Smaller payloads, downgrade protection, two transport formats, hard validation on import.
6. **Centralized event dispatcher table.** One frame, one OnEvent, `eventFunctions[ev](...)`. Simpler and faster than AceEvent for hot events.
7. **Augment, never replace, secure frames.** Attach a sibling `unitFrame` to `C_NamePlate.GetNamePlateForUnit()` — keep the Blizzard frame in tree.

## Anti-Patterns To Avoid

1. **No real script sandbox.** Plater commented out `setfenv` to stay within Lua's 200-local limit and trusts mod authors entirely. A malicious imported mod has full `_G`. Acceptable only because the user explicitly pastes each string — but for addons accepting unattended payloads (sync over AceComm), this is dangerous. Use `setfenv` + whitelist.
2. **One 13.8k-line `Plater.lua` (555 KB).** Even with feature files split out, the core remains a single file too large to load into most editors comfortably and impossible to diff cleanly. Should have been further decomposed by lifecycle (init / event handlers / frame mutators / api).
3. **Flat `Plater_*.lua` naming with no folder hierarchy** (only `options/` and `libs/`). 30+ top-level lua files; the relationship between, say, `Plater_GhostAuras.lua` and `Plater_GhostAurasFrames.lua` is implicit. A `modules/auras/`, `modules/resources/`, `modules/scripting/` layout would document architecture in the directory tree.

---

## Key URLs Cited

- Repo root: https://github.com/Tercioo/Plater-Nameplates
- TOC: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater.toc
- Main: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater.lua
- API: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_API.lua
- ScriptLibrary: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_ScriptLibrary.lua
- ImportExport: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_ImportExport.lua
- ScriptHelpers: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_ScriptHelpers.lua
- ScriptingPanels: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_ScriptingPanels.lua
- ScriptingOptions: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_ScriptingOptions.lua
- OptionsPanel: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_OptionsPanel.lua
- DefaultSettings: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_DefaultSettings.lua
- SlashCMD: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_SlashCMD.lua
- Logs: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/Plater_Logs.lua
- enUS locale: https://raw.githubusercontent.com/Tercioo/Plater-Nameplates/master/locales/enUS.lua
- libs/: https://github.com/Tercioo/Plater-Nameplates/tree/master/libs
