# BigWigs — Principal-Engineer Research Notes

Target: https://github.com/BigWigsMods/BigWigs (master branch as of 2026-05-03)
Sibling: https://github.com/BigWigsMods/packager (the de-facto WoW addon packager — same authors)

This is a read-only research dump. Every claim cites a URL.

---

## 1. TOC structure

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/BigWigs.toc

Salient fields (paraphrased — file uses `@project-version@` substitution token consumed by the packager):

- `## Interface: 120001, 120005, 120007` — multi-interface line, supporting current Retail PTR/live/beta simultaneously.
- `## Title: BigWigs`
- `## Notes: ` modular, lightweight, non-intrusive boss encounter warnings.
- `## Author: Funkeh, Nebula, Justwait, Delk`
- `## Version: @project-version@` — replaced by the packager from the git tag.
- `## X-License: All Rights Reserved (with GitHub fork/modification permission)`
- `## X-Category: Raid`
- `## X-Website: https://github.com/BigWigsMods`
- `## OptionalDeps: Ace3, LibSharedMedia-3.0, LibCandyBar-3.0, ...`
- `## SavedVariables:` BigWigs3DB and friends.
- `## X-BigWigs-LoadOn-CoreEnabled`, `## X-BigWigs-LoadOn-InstanceId`, `## X-BigWigs-LoadOn-WorldBoss`, `## X-BigWigs-LoadOn-Slash` — **custom X- fields used as a declarative module-loading manifest**, parsed by `Loader.lua` (see §3).

There are five sibling TOC files for Classic eras: `BigWigs_Cata.toc`, `BigWigs_Mists.toc`, `BigWigs_TBC.toc`, `BigWigs_Vanilla.toc`, `BigWigs_Wrath.toc`. The packager `enable-toc-creation: yes` directive is **not** used here; they author them by hand because each expansion has a different file list.

## 2. Folder/file layout (top level)

Source: https://github.com/BigWigsMods/BigWigs

```
.github/                — CI workflows
Core/                   — Core.lua, BossPrototype.lua, PluginPrototype.lua, Constants.lua, modules.xml, libs.xml, BigWigs_Core.toc + per-expansion TOCs
Libs/                   — embedded libs (AceDB, LibSpecialization, LibLatency, LibDurability, LibKeystone, LibDualSpec, LibSharedMedia, LibDBIcon)
Locales/                — enUS.lua + enUS_common.lua and 11 other locale pairs; Encounters_Classic/ subdir
Media/                  — Sounds/, Icons/ (with Source/ subdirs ignored by packager)
Options/                — Options.lua + Libs/ (AceGUI-3.0, AceConfig*, AceDBOptions, LibDDI)
Plugins/                — 22 plugin .lua files (Bars, Messages, Sound, Countdown, Proximity, etc.) + Libs/ (LibSink, LibCandyBar, LibCustomGlow)
MarchOnQuelDanas/, MidnightWorld/, TheDreamrift/, TheVoidspire/  — current-tier raid content folders, each shipped as a separate add-on
Tools/                  — non-encounter helper modules
API.lua                 — public API surface
BigWigs.toc + 5 per-expansion TOCs
Init.lua + per-expansion variants
Loader.lua              — bootstrap / on-demand loader
GuildVersion.lua
bosses.xml, embeds.xml, modules.xml
.pkgmeta
.luacheckrc
gen_option_values.lua, ldoc.ltp  — dev tools, ignored by packager
```

Key insight: `Core/`, `Options/`, `Plugins/`, and each raid folder are **packaged as separate addons** via `move-folders:` (see §13). Inside the repo they look like one project; on a user's disk they are seven independent addons that share the `BigWigs_` namespace prefix.

## 3. Module loading — TOC vs XML, plugins/bossmods registration

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/Loader.lua

- The main TOC loads only **bootstrap files + XML registries**: `embeds.xml` (libs), `modules.xml` (plugins), `bosses.xml` (encounter modules), `Locales/*.lua`, `Init.lua`, `Loader.lua`.
- **All boss/plugin/option code is loaded on demand**. Each raid pack is its own addon listed in optional-deps; the loader scans installed addons for `X-BigWigs-LoadOn-*` metadata and calls `LoadAddOn(name)` when the trigger fires.

```lua
meta = GetAddOnMetadata(i, "X-BigWigs-LoadOn-Slash")
if meta then
    local slashCommandsTable = {strsplit(",", meta)}
    -- registers each as a SLASH_FOO command that lazy-loads the addon
end
```

Three load triggers are supported: `CoreEnabled` (load when fight engine activates), `InstanceId` (zone in), `WorldBoss` (mob ID seen). This is the **most important architectural lesson**: BigWigs has hundreds of thousands of lines of encounter scripts but only loads a few KB until you actually zone into a raid.

## 4. Library stack

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/.pkgmeta + embeds.xml

Embedded via `externals:` in `.pkgmeta` (so they pull fresh from upstream at build time, **never vendored in git**):

| Library | Purpose | Source |
|---|---|---|
| AceDB-3.0 | profile DB | `https://repos.wowace.com/wow/ace3/trunk/AceDB-3.0` |
| AceGUI-3.0 | options UI widgets | wowace |
| AceConfigDialog/Registry-3.0 | options framework | wowace |
| AceDBOptions-3.0 | profile UI | wowace |
| LibSharedMedia-3.0 | fonts/textures/sounds registry | wowace |
| LibDBIcon-1.0 | minimap button | wowace |
| LibCandyBar-3.0 | timer bars | wowace |
| LibSink-2.0 | configurable message routing | wowace |
| LibCustomGlow-1.0 | spell glow | github Stanzilla |
| LibSpecialization | spec broadcast | github BigWigsMods |
| LibLatency, LibDurability, LibKeystone | group telemetry | wowace + BigWigsMods |
| LibDualSpec-1.0 | per-spec profiles | wowace |
| LibDDI-1.0 | dropdown widget | wowace |
| LibChatAnims | chat animation hook | wowace |

Notably **absent**: AceAddon, AceEvent, AceTimer, AceConsole, AceLocale. BigWigs reimplemented all of these in `Core/Core.lua` and `Core/BossPrototype.lua` for performance/control. They use Ace3's data-and-config libs but not its lifecycle/event libs.

## 5. Core architecture pattern

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/Core/Core.lua + BossPrototype.lua + PluginPrototype.lua

Two factory methods on the core table:

```lua
function core:NewBoss(moduleName, zoneId, journalId)
  -- returns: module, CL  (CL = common locale shared across all bosses)
end
function core:NewPlugin(moduleName, globalFuncs)
  -- returns: module, L
end
```

Each call returns a metatable-chained instance:

```lua
local bossMeta = { __index = bossPrototype, __metatable = false }
local m = setmetatable({
    moduleName       = moduleName,
    RegisterMessage  = loader.RegisterMessage,
    UnregisterMessage= loader.UnregisterMessage,
    RegisterEvent    = core.RegisterEvent,
    UnregisterEvent  = core.UnregisterEvent,
}, bossMeta)
```

Pattern: **mixin by direct field assignment, prototype by `__index`**. Methods that are hot (RegisterEvent, RegisterMessage) are copied as locals onto the instance to skip the metatable lookup; less-hot methods are reached via `__index` to `bossPrototype`.

A representative boss module (https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/TheVoidspire/Crown.lua):

```lua
local mod, CL = BigWigs:NewBoss("Crown of the Cosmos", 2912, 2738)
if not mod then return end
mod:RegisterEnableMob(240430, 243805, 243810, 243811)
mod:SetEncounterID(3181)
mod:SetRespawnTime(30)

function mod:GetOptions()
    return { "stages", 1233602, {1233865, "HEALER"}, ... }, {
        { tabName = CL.stage:format(1), { ... } },
    }
end
function mod:OnBossEnable()  ... end
function mod:OnBossDisable() ... end
```

The core dispatcher routes all `COMBAT_LOG_EVENT_UNFILTERED` through a single hidden frame and **dispatches by event name + spell ID** to module callbacks registered via `mod:Log(event, func, spellId1, spellId2, ...)` (or `"*"` wildcard). This is the canonical hot-path pattern across all WoW boss-mod addons.

Plugin pattern (https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/Plugins/Bars.lua):

```lua
local plugin, L = BigWigs:NewPlugin("Bars", { "db", "SendCustomBarToGroup" })
if not plugin then return end
plugin.defaultDB = { fontName = ..., fontSize = 10, ... }
plugin.pluginOptions = { type = "group", get=..., set=..., args = { ... } }
function plugin:OnPluginEnable()
    self:RegisterMessage("BigWigs_StartBar")
    self:RegisterMessage("BigWigs_PauseBar", "PauseBar")
end
```

## 6. Settings storage

Source: Loader.lua + Core.lua

Single AceDB-3.0 instance per addon: `LibStub("AceDB-3.0"):New("BigWigs3DB", defaults, true)`. Plugins store under `db.profile.plugins[pluginName]`; encounter toggles under `db.profile.encounters[bossName]`. LibDualSpec-1.0 enables per-spec profile switching automatically.

## 7. Options UI

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/Options/Options.lua

**Hybrid**, not pure custom. They use AceConfigDialog + AceConfigRegistry **inside** an AceGUI Frame they construct themselves, so the look/feel is custom but the option-tree introspection is Ace3:

```lua
local acr = LibStub("AceConfigRegistry-3.0")
local acd = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function OpenConfig(specificPanel)
    local bw = AceGUI:Create("Frame")
    bw:SetTitle("BigWigs"); bw:SetWidth(858); bw:SetHeight(660); bw:SetLayout("Flow")
    -- TabGroup with: options, tools, bigwigs (raids by expansion), littlewigs (dungeons)
end
```

The `Options` addon is loaded **lazily on first `/bw` invocation**, not at login.

## 8. Slash commands

Source: Loader.lua

```lua
SLASH_BigWigs1 = "/bw"
SLASH_BigWigs2 = "/bigwigs"
SlashCmdList.BigWigs = function() loadCoreAndOpenOptions() end

SLASH_BigWigsVersion1 = "/bwv"
SlashCmdList.BigWigsVersion = function() ... end
```

Plus the dynamic `X-BigWigs-LoadOn-Slash` registration described in §3 — any sibling addon can declare slash commands in its TOC and the loader wires them up. **Raw `SLASH_*`/`SlashCmdList`, no AceConsole.**

## 9. Localization

Source: https://github.com/BigWigsMods/BigWigs/tree/master/Locales + Init.lua

```lua
-- enUS.lua
local _, addonTbl = ...
local L = addonTbl.API:NewLocale("BigWigs", "enUS")
L.berserk      = "Berserk"
L.berserk_desc = "Show a bar and timed warnings..."
```

Custom locale system on `addonTbl.API`, **not AceLocale-3.0**. Each locale file is paired with a `_common.lua` for shared encounter strings. Convention: `key` + `key_desc` for option descriptions; `%s`/`%d` interpolation; embedded color escapes `|cFF...|r`. enUS is the implicit fallback (it's loaded first; non-enUS files only override).

## 10. Event handling

Source: Core.lua + BossPrototype.lua + Loader.lua

Three layers:

1. **Blizzard events** — single hidden `bwUtilityFrame` registers each event once; an `eventMap[event][module] = func` table dispatches to all listeners. `mod:RegisterEvent(event, func)` joins the map.
2. **Unit events** — `mod:RegisterUnitEvent(event, func, "boss1", "boss2", ...)` calls Blizzard's `:RegisterUnitEvent` per unit token. The handler filters by `UnitPosition()` to drop remote players sharing your raid.
3. **Combat log** — `mod:Log(subevent, func, spellId, ...)` keys by `(subevent, spellId)`, with `"*"` wildcard. The dispatcher unpacks `CombatLogGetCurrentEventInfo()` once and reuses across listeners.

Cross-module messaging is a **CallbackHandler-style pubsub**: `self:RegisterMessage("BigWigs_StartBar")` / `self:SendMessage("BigWigs_StartBar", ...)`. This is the entire integration surface between encounter modules and plugins — encounters never call `Bars.lua` directly; they fire `BigWigs_StartBar` and Bars listens.

## 11. Frames / UI

- Bars: LibCandyBar-3.0 — handed off via `BigWigs_StartBar` message.
- Anchor frames: created in `Plugins/Bars.lua` (`normalAnchor`, `emphasizeAnchor`); draggable, persisted to AceDB.
- No SecureActionTemplate — BigWigs deliberately does **no** combat-restricted UI (no buttons that cast spells); everything is informational so it can update freely in combat.
- Nameplate decoration uses Blizzard's `C_NamePlate` API via `Plugins/Nameplates.lua`.

## 12. Debug / logging

Source: Core.lua

```lua
function core:Error(msg, noPrint)
    if not noPrint then core:Print(msg) end
    geterrorhandler()("BigWigs: " .. msg)
end
```

Plus `:Debug(msg)` on the plugin prototype gated by a `db.debug` flag, and `Tools/` contains a logger module that records timeline events for replay analysis.

## 13. Packaging — the .pkgmeta reference implementation

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/.pkgmeta
Tool: https://github.com/BigWigsMods/packager (the de-facto standard; almost every WoW addon uses it via GitHub Action `BigWigsMods/packager@v2`)

Full file reproduced verbatim in §full-pkgmeta below. Key directives demonstrated:

- `package-as: BigWigs` — output zip name.
- `wowi-archive-previous: no` — don't archive old WoWInterface uploads.
- `externals:` — fetched from upstream at build time (libs are **never committed**). Mix of wowace SVN trunks and GitHub repos, including subdir extraction (e.g. `https://github.com/BigWigsMods/LibSpecialization.git/LibSpecialization`).
- `move-folders:` — splits the monorepo into seven addon zips. This is the trick that lets one repo ship Core, Options, Plugins, and four current-tier raid packs as independent installable addons.
- `ignore:` — dev files (`gen_option_values.lua`, `ldoc.ltp`), source PSDs under `Media/Icons/Source`, and the `.xml` shims that some libs ship for stand-alone use but aren't needed when embedded.

GitHub Actions usage (https://github.com/BigWigsMods/packager README):

```yaml
- uses: BigWigsMods/packager@v2
  with:
    args: -p 1234 -w 5678 -a he54k6bL   # -p Curse, -w WoWI, -a Wago project IDs
```

Local: `./release.sh` from `.release/` dir, with credentials in `.env`.

## 14. Notable patterns to steal

1. **Lazy-load by TOC metadata.** `X-BigWigs-LoadOn-InstanceId` style declarative manifests parsed by a tiny `Loader.lua`. Pay-for-what-you-use even within a single addon family.
2. **`move-folders:` monorepo → multi-addon.** One git repo, one `.pkgmeta`, N installable addons. Massive repo-management win for an addon collection like Ka0s'.
3. **External libraries via `.pkgmeta`, never vendored.** Libs in `Libs/` are fetched fresh at build, kept out of git. Eliminates the Ace3-version-drift problem we audit for.
4. **Pubsub between core and plugins.** Encounters fire `BigWigs_StartBar`; the Bars plugin listens. No direct cross-module function calls. Replaceable plugins, testable encounters.
5. **Spell-ID-keyed CLEU dispatch via `:Log(event, fn, spellId, ...)`.** One frame, one event registration, O(1) dispatch by `(subevent, spellId)`. Standard for any addon that watches combat log.
6. **Hot-path mixin: copy methods onto the instance, fall through to prototype for cold methods.** Skips one metatable lookup on every `RegisterEvent` call. Worth it for addons hammered every frame.

## 15. Anti-patterns / things to avoid

1. **Custom AceLocale replacement.** They reimplemented locale lookup on `addonTbl.API:NewLocale`. For an addon family our size, AceLocale-3.0 is fine and well-understood; rolling our own is unjustified.
2. **Custom event dispatcher instead of AceEvent-3.0.** Justified for BigWigs (hundreds of modules, each registering dozens of events) — **not** justified for a normal addon. Don't copy this part.
3. **Hand-maintained per-expansion TOCs.** Five sibling TOCs (`BigWigs_Cata.toc`, `_Wrath.toc`, ...) drift over time. The packager's `enable-toc-creation: yes` would let one TOC + a build flag generate per-flavor TOCs; BigWigs declines because each flavor has a genuinely different file list, but for a typical addon this manual approach is overkill.
4. **`X-License: All Rights Reserved`** with a carve-out only for GitHub forks. Hostile to packagers and historians; Ka0s standard is MIT, keep it that way.

---

## Appendix — full `.pkgmeta` (verbatim)

Source: https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/.pkgmeta

```yaml
package-as: BigWigs
wowi-archive-previous: no

externals:
    Libs/LibDBIcon-1.0: https://repos.wowace.com/wow/libdbicon-1-0/trunk/LibDBIcon-1.0
    Libs/LibSharedMedia-3.0: https://repos.wowace.com/wow/libsharedmedia-3-0/trunk/LibSharedMedia-3.0
    Libs/LibSpecialization: https://github.com/BigWigsMods/LibSpecialization.git/LibSpecialization
    Libs/LibLatency: https://repos.wowace.com/wow/liblatency/trunk/LibLatency
    Libs/LibDurability: https://repos.wowace.com/wow/libdurability/trunk/LibDurability
    Libs/LibKeystone: https://github.com/BigWigsMods/LibKeystone.git/LibKeystone
    Libs/AceDB-3.0: https://repos.wowace.com/wow/ace3/trunk/AceDB-3.0
    Libs/LibDualSpec-1.0: https://repos.wowace.com/wow/libdualspec-1-0
    Core/Libs/LibChatAnims: https://repos.wowace.com/wow/libchatanims/trunk/LibChatAnims
    Plugins/Libs/LibSink-2.0: https://repos.wowace.com/wow/libsink-2-0/trunk/LibSink-2.0
    Plugins/Libs/LibCandyBar-3.0: https://repos.wowace.com/wow/libcandybar-3-0/trunk/LibCandyBar-3.0
    Plugins/Libs/LibCustomGlow-1.0: https://github.com/Stanzilla/LibCustomGlow.git
    Options/Libs/AceGUI-3.0: https://repos.wowace.com/wow/ace3/trunk/AceGUI-3.0
    Options/Libs/AceConfigDialog-3.0: https://repos.wowace.com/wow/ace3/trunk/AceConfig-3.0/AceConfigDialog-3.0
    Options/Libs/AceConfigRegistry-3.0: https://repos.wowace.com/wow/ace3/trunk/AceConfig-3.0/AceConfigRegistry-3.0
    Options/Libs/AceDBOptions-3.0: https://repos.wowace.com/wow/ace3/trunk/AceDBOptions-3.0
    Options/Libs/LibDDI-1.0: https://repos.wowace.com/wow/libddi-1-0/trunk

move-folders:
    BigWigs/Core: BigWigs_Core
    BigWigs/Options: BigWigs_Options
    BigWigs/Plugins: BigWigs_Plugins
    BigWigs/TheVoidspire: BigWigs_TheVoidspire
    BigWigs/TheDreamrift: BigWigs_TheDreamrift
    BigWigs/MarchOnQuelDanas: BigWigs_MarchOnQuelDanas
    BigWigs/MidnightWorld: BigWigs_MidnightWorld

ignore:
  - gen_option_values.lua
  - ldoc.ltp
  - Core/Libs/LibChatAnims/LibChatAnims.xml
  - Libs/AceDB-3.0/AceDB-3.0.xml
  - Libs/LibDBIcon-1.0/lib.xml
  - Libs/LibDualSpec-1.0/LibDualSpec-1.0.toc
  - Libs/LibDualSpec-1.0/LibStub.lua
  - Libs/LibDurability/LibDurability.xml
  - Libs/LibLatency/LibLatency.xml
  - Libs/LibSharedMedia-3.0/lib.xml
  - Media/Sounds/spell_on_you.flac
  - Media/Sounds/spell_under_you.flac
  - Media/Sounds/Long.wav
  - Media/Sounds/Alarm.wav
  - Media/Sounds/Alert.wav
  - Media/Sounds/VictoryClassic.wav
  - Media/Sounds/Victory.wav
  - Media/Sounds/VictoryLong.wav
  - Media/Sounds/Info.mp3
  - Media/Sounds/Amy/countdown.wav
  - Media/Sounds/David/countdown.wav
  - Media/Sounds/Jim/countdown.wav
  - Media/Icons/Source
  - Media/Icons/Menus/Source
  - Options/Libs/AceConfigRegistry-3.0/AceConfigRegistry-3.0.xml
  - Options/Libs/AceConfigDialog-3.0/AceConfigDialog-3.0.xml
  - Options/Libs/AceDBOptions-3.0/AceDBOptions-3.0.xml
  - Options/Libs/LibDDI-1.0/lib.xml
  - Options/Libs/LibDDI-1.0/LibDDI-1.0.toc
  - Plugins/Libs/LibCandyBar-3.0/lib.xml
  - Plugins/Libs/LibCustomGlow-1.0/LibCustomGlow-1.0.toc
  - Plugins/Libs/LibCustomGlow-1.0/LibCustomGlow-1.0.xml
  - Plugins/Libs/LibCustomGlow-1.0/cspell.json
  - Plugins/Libs/LibCustomGlow-1.0/LICENSE
  - Plugins/Libs/LibCustomGlow-1.0/README.md
  - Plugins/Libs/LibSink-2.0/lib.xml
```
