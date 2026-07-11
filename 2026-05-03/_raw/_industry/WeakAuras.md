# WeakAuras 2 — Principal-Engineer Research Notes

Date: 2026-05-03
Repo: https://github.com/WeakAuras/WeakAuras2
License: GPL-2.0

## 1. Top-Level Layout

Source: https://github.com/WeakAuras/WeakAuras2

- `WeakAuras/` — core engine
- `WeakAurasOptions/` — config UI (separately loadable, lazy)
- `WeakAurasTemplates/` — preset library
- `WeakAurasArchive/` — historical aura storage
- `WeakAurasModelPaths/` — generated model-path data
- `.pkgmeta` — BigWigs packager config
- `.luacheckrc`, `.luarc.json`, `stylua.toml` — lint/format/LSP config
- `babelfish.lua` — translation pipeline helper (excluded from packaged build)

The split into multiple addon folders (each with its own TOC) is the headline architectural choice: the heavy options UI is a separate addon that the user can keep disabled until needed.

## 2. TOC / Multi-Client Strategy

Source: https://github.com/WeakAuras/WeakAuras2/tree/main/WeakAuras

One TOC file per game flavor:
- `WeakAuras_Vanilla.toc`
- `WeakAuras_TBC.toc`
- `WeakAuras_Wrath.toc`
- `WeakAuras_Cata.toc`
- `WeakAuras_Mists.toc`
- (plus retail via packager)

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/WeakAuras_Mists.toc

- `## Interface: 50503`
- `## Version: @project-version@` (BigWigs packager substitution)
- `## SavedVariables: WeakAurasSaved`
- `## OptionalDeps: Ace3, LibCompress, LibSharedMedia-3.0, ...`
- File order grouped by phase: Init -> Core -> Triggers -> Helpers -> Region types -> Sub-regions -> Misc.

## 3. Module Loading & Namespacing

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/Init.lua

Pattern used in every file:
```lua
local AddonName = ...
local Private = select(2, ...)
```
The 2nd vararg is a shared **Private** table — the cross-file namespace. This avoids globals while still letting 100+ files cooperate. Public API hangs off the global `WeakAuras`; everything else lives on `Private`.

Library acquisition is via `LibStub("X", true)` guards (no AceAddon mixin chain for the core); `AceTimer-3.0:Embed()` is applied to a small `WeakAurasTimers` proxy table.

## 4. Libraries (from `.pkgmeta`)

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/.pkgmeta

20+ externals: Ace3 (Timer, Serializer, Comm, Config, GUI), LibStub, CallbackHandler, LibSharedMedia-3.0, LibDataBroker-1.1, LibDBIcon-1.0, LibCompress, **LibDeflate**, **LibSerialize**, LibSpellRange, LibRangeCheck, LibCustomGlow, LibGetFrame, LibSpecialization, TaintLess, LibDispel, **Archivist** (custom). `nolib` packages are disabled — every release ships with libs embedded.

## 5. User-Supplied Lua Sandbox

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/AuraEnvironment.lua

- User code runs in a custom env applied via `setfenv()` (proxy table with metatable).
- Blocked Lua: `getfenv, setfenv, loadstring, pcall, xpcall`.
- Blocked WoW APIs: `SendMail`, `RunScript`, `EditMacro`, frame manipulation.
- Blocked tables: `SlashCmdList`, `DEFAULT_CHAT_FRAME`, addon SVs.
- Helpers exposed: `WA_GetUnitAura/Buff/Debuff`, `WA_IterateGroupMembers`, `WA_ClassColorName`, `WA_Utf8Sub`, `DebugPrint`, a per-aura wrapped `C_Timer`.
- A `FakeWeakAuras` table whitelists safe getters (`GetData`, `GetDBMTimer`) while rejecting mutators (`Add`, `Delete`, `ShowOptions`).
- `aura_env` injects `id, cloneId, state, states, region, saved` per-aura.
- Compiled chunks are cached with weak refs (`CreateFunctionCache()`) so identical user code shares one closure.

This is *the* defining engineering challenge of WA: it lets strangers ship executable Lua to your client and survive.

## 6. Import / Export String Format

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/Transmission.lua

Wire format: **`!WA:2!<encoded>`** (current version 2).

Pipeline:
1. Build envelope `{m="d", d=data, v=version, s=versionString, c=children}`
2. `LibSerialize` -> binary
3. `LibDeflate:CompressDeflate(level=9)`
4. Encoding: `EncodeForPrint` (chat / clipboard) or `EncodeForWoWAddonChannel` (in-game whisper)

History: v0 LibCompress + AceSerializer, v1 `!`-prefix LibDeflate + AceSerializer, v2+ LibDeflate + LibSerialize. Versioned prefix is the migration story.

## 7. Options UI — Custom AceConfig/AceGUI Widgets

Source: https://github.com/WeakAuras/WeakAuras2/tree/main/WeakAurasOptions/AceGUI-Widgets

WA does **not** subclass AceConfig dialog widgets — it ships its own AceGUI widgets, registered via `AceGUI:RegisterWidgetType`, and renders most panels by hand-driving AceGUI rather than via AceConfigDialog. Custom widgets:

Containers:
- `AceGUIContainer-WeakAurasInlineGroup`
- `AceGUIContainer-WeakAurasTreeGroup` (the giant left-hand aura tree)

Controls:
- `WeakAurasDisplayButton` (the per-aura row, drag/drop/group)
- `WeakAurasIcon`, `WeakAurasIconButton`
- `WeakAurasInput`, `WeakAurasInputFocus`, `WeakAurasMultiLineEditBox`
- `WeakAurasSpinBox`, `WeakAurasScrollArea`
- `WeakAurasAnchorButtons`
- `WeakAurasMiniTalent_Cata` / `_Mists` / `_Wrath` / `_TWW` (per-flavor talent trees)
- `WeakAurasDropDownItemCurrency`
- `WeakAurasProgressBar`, `WeakAurasMediaSound`

Files like `ActionOptions.lua`, `AnimationOptions.lua`, `DisplayOptions.lua`, `TriggerOptions.lua`, `LoadOptions.lua` build option-trees as plain Lua tables that the custom dialog renderer consumes — AceConfig descriptor-style, but with their own dialog backend so they can mount the custom widgets.

Source: https://github.com/WeakAuras/WeakAurasOptions

## 8. Localization at Scale

Source: https://github.com/WeakAuras/WeakAuras2/tree/main/WeakAuras/Locales

- 11 locales: deDE, enUS, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW.
- **Not standard `AceLocale-3.0:NewLocale`.** The base `enUS.lua` (https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/Locales/enUS.lua) does:
  ```lua
  local L = WeakAuras.L
  -- @localization(locale="enUS", format="lua_additive_table")@
  setmetatable(L, {__index = function(_, k) return k end})
  ```
- Strings are *injected by the BigWigs packager* from the CurseForge translation system (`@localization@` directive). Source repo carries no msgid tables.
- `__index` fallback returns the key when a translation is missing — lazy & graceful.
- `babelfish.lua` (excluded from package) is the build-side helper that drives the translation pipeline.

This scales to 11 locales with zero hand-maintained `.lua` strings in git.

## 9. Events, Frames, Lifecycle

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/WeakAuras.lua

- No AceAddon `OnInitialize`. Bootstraps off `ADDON_LOADED` -> `PLAYER_LOGIN`:
  ```lua
  local loadedFrame = CreateFrame("Frame")
  Private.frames["Addon Initialization Handler"] = loadedFrame
  loadedFrame:RegisterEvent("ADDON_LOADED")
  loadedFrame:RegisterEvent("PLAYER_LOGIN")
  ```
- All managed frames go in `Private.frames[name]` — single registry, debug-friendly.
- Separate frames for load-scanning and unit events keep event fan-out narrow.

## 10. Slash Commands

Source: https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/WeakAuras/WeakAuras.lua

```lua
SLASH_WEAKAURAS1, SLASH_WEAKAURAS2 = "/weakauras", "/wa"
function SlashCmdList.WEAKAURAS(input) ... end
```
Subcommands: `pstart`, `pstop`, `minimap`, `help`, `repair`, `ff`. Native WoW slash mechanism — no AceConsole dependency in the core.

## 11. Debug / Telemetry

- `WeakAuras.prettyPrint()` for user-facing output.
- A `Private.callbacks` event hub (CallbackHandler-1.0) for cross-module pub/sub: `RegisterCallback`/`Fire`.
- Debug helpers exposed inside the sandbox via `DebugPrint`.
- `Discord.lua` ships diagnostic dump for bug reports.

## 12. Packaging

`.pkgmeta` (https://raw.githubusercontent.com/WeakAuras/WeakAuras2/main/.pkgmeta):
- `externals:` pulls each lib at a pinned ref (e.g., `LibSerialize` v1.0.0, `Archivist` v1.0.8).
- `move-folders:` reshapes the multi-addon source tree into 8 sibling addons in the zip.
- `ignore:` strips README/CONTRIBUTING/`update_translations.sh`/`generate_changelog.sh`/`babelfish.lua`/LibDeflate examples.
- `manual-changelog: CHANGELOG.md` (Markdown).
- `@project-version@` and `@localization@` substitutions resolved at package time.

---

## Patterns Worth Stealing (even for *small* addons)

1. **`local addonName, Private = ...` as the universal file header.** Every file gets the addon name and a shared private table for free — no globals, no wrapper boilerplate, scales from 2 files to 200. Cost: zero. (Source: Init.lua)
2. **Single registry of managed frames: `Private.frames["Some Purpose"] = frame`.** Trivial to enumerate frames in a `/myaddon debug` command, trivial to clean up, trivial to spot leaks. Works the same for an addon with 3 frames as one with 300. (Source: WeakAuras.lua)
3. **AceLocale-free localization with metatable fallback:**
   ```lua
   local L = setmetatable({}, {__index = function(_, k) return k end})
   ```
   Two lines. Missing keys render as English. Drop-in replacement for AceLocale when you don't need locale negotiation.
4. **Versioned wire prefix (`!WA:2!`) on any serialized string you ship to other users.** Cheap, mandatory once you regret your first format. Pair with LibSerialize+LibDeflate over AceSerializer+LibCompress (smaller, faster).
5. **Pub/sub via CallbackHandler-1.0 inside your own addon (`Private.callbacks`).** Even small addons benefit: options UI fires `OnConfigChanged` and the runtime listens — no direct cross-module function calls, easy to test.

## Anti-Patterns to Avoid

1. **Putting the options UI in the same addon as the runtime.** WA learned this years ago and split `WeakAurasOptions` out so config code (and its huge AceGUI footprint) only loads when the user opens the panel. If your addon has a settings UI bigger than ~5 panels, make it a sibling addon with `LoadOnDemand: 1`.
2. **Custom dialog rendering instead of `AceConfigDialog`.** WA had to do this — they need bespoke widgets and a tree view of thousands of auras. For small addons, hand-rolling a dialog renderer and registering custom AceGUI widgets is enormous accidental complexity. Use AceConfigDialog declaratively until you can't.
3. **Executing user-supplied Lua at all.** WA's `AuraEnvironment.lua` is hundreds of lines of careful sandbox engineering — block-lists, wrapped C_Timer, fake API tables, function caches. Unless your addon's value proposition is user scripting, don't go here. If you must, copy WA's deny-list verbatim and still expect to miss something.

---
