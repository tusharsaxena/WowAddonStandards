# OmniCD — Principal-Engineer Research Notes

**Target:** OmniCD — Party Cooldown Tracker (the closest functional analogue to KickCD).
**Author:** Treebonker. **Version inspected:** v2.8.28 (Mainline).
**Primary repo (active mirror with full source):** https://github.com/muleyo/OmniCD (default branch: `master`)
**Note:** `https://github.com/dnawre/OmniCD` returns 404 — does not exist.
**curseforge-mirror/omnicd** is a Python release-mirroring script, not source.
**CurseForge:** https://www.curseforge.com/wow/addons/omnicd (33M+ downloads).

---

## 1. TOC and Multi-Flavor Packaging

Six TOC files at root, one per game flavor:
- `OmniCD_Mainline.toc`, `OmniCD_Cata.toc`, `OmniCD_Mists.toc`, `OmniCD_Wrath.toc`, `OmniCD_TBC.toc`, `OmniCD_Vanilla.toc`

Source: https://github.com/muleyo/OmniCD/blob/master/OmniCD_Mainline.toc

```
## Interface: 110200
## Title: OmniCD
## Notes: Party cooldown tracker. /oc
## Author: Treebonker
## Version: v2.8.28
## DefaultState: Enabled
## SavedVariables: OmniCDDB
## OptionalDeps: Ace3, LibOmniCDC, LibDeflate, LibSharedMedia-3.0, UTF8, LibDualSpec-1.0
## IconTexture: Interface\AddOns\OmniCD\Media\omnicd-logo64-c
## X-License: All Rights Reserved
## X-Localizations: enUS, deDE, esMX, frFR, itIT, koKR, ruRU, zhCN, zhTW
## X-Curse-Project-ID: 306489
## X-Wago-ID: E6gLXAK1

Embeds.xml
Locales\Locales.xml
Core\Core.xml
Modules\Spells\Spells_Mainline.xml
Modules\Modules.xml
Config\Config.xml
```

**Pattern:** TOC delegates ALL file ordering to XML manifests (`Embeds.xml`, `Core.xml`, `Modules.xml`, `Config.xml`). The TOC stays clean and per-flavor differences collapse to swapping one line (`Spells_Mainline.xml` vs `Spells_Cata.xml`).

## 2. Folder Layout

```
Config/         options UI tree (per-zone subfolder Party/)
Core/           init, addon framework glue, slash, pools, profile sharing
Libs/           Ace3 + LibDeflate + LibDualSpec + LibSharedMedia + LibOmniCDC + UTF8
Locales/        enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW
Media/          fonts, .blp, .tga
Modules/
  Blizzard/     small Blizz-frame integration (TooltipID)
  Party/        the actual feature (Bars, Icons, Position, Highlights, Sync, Inspect, ...)
  Spells/       data tables: spell_db + cooldown modifiers (per flavor)
Embeds.xml      library load order
README.md, CHANGELOG.md, LICENSE
```

Source listing: https://api.github.com/repos/muleyo/OmniCD/git/trees/HEAD?recursive=1

## 3. Module / Load Architecture

**Not AceAddon.** OmniCD rolls its own mini-framework on top of `LibStub` for libs and bare `CreateFrame("Frame")` for modules.

Source: https://github.com/muleyo/OmniCD/blob/master/Core/Init.lua

Pattern in `Core/Init.lua`:
```lua
local AddOnName, NS = ...
local AddOn = CreateFrame("Frame")
AddOn.L = LibStub("AceLocale-3.0"):GetLocale(AddOnName)
AddOn.defaults = { global = {}, profile = { modules = { ["Party"] = true } } }
NS[1] = AddOn; NS[2] = AddOn.L; NS[3] = ...profile; NS[4] = ...global
function NS:unpack() return self[1], self[2], self[3], self[4] end
NS[1].Party = CreateFrame("Frame")
NS[1].Comm = CreateFrame("Frame")
NS[1].Cooldowns = CreateFrame("Frame")
_G.OmniCD = NS
```

Every other lua file starts with:
```lua
local E, L, C, G = select(2, ...):unpack()
```
…where `E` is the addon namespace, `L` is locale, `C` is profile defaults, `G` is global defaults. This is the **single most copied idiom** in the codebase and gives every file the same 4-letter local-upvalue surface.

Lifecycle in `Core/Load.lua` is hand-rolled:
```
ADDON_LOADED  -> OnInitialize  (DB migration)
PLAYER_LOGIN  -> OnEnable
PET_BATTLE_OPENING_START / CLOSE -> Refresh all modules
```
Modules are iterated via `for moduleName in pairs(E.moduleOptions) do ... end` and each module exposes `Refresh`, `Test`, `HideAll`. There is a `DB_VERSION = 4` constant and `FixOldProfile()` migration logic.

## 4. Libraries

From `Embeds.xml` (https://github.com/muleyo/OmniCD/blob/master/Embeds.xml):
- `LibStub`, `CallbackHandler-1.0`
- `AceHook-3.0`, `AceDB-3.0`, `AceDBOptions-3.0`, `AceLocale-3.0`, `AceComm-3.0`, `AceSerializer-3.0`
- `LibOmniCDC` — **forked private copy of AceConfigDialog/AceGUI** (`AceConfigDialog-3.0-OmniCDC`). They embed customized widgets (e.g. `InlineGroupList`, `InlineGroupListCheckBox`, `Info-OmniCDC`) without polluting the global Ace3.
- `LibDeflate` — profile + sync compression
- `LibSharedMedia-3.0`, `UTF8`, `LibDualSpec-1.0`

**Notably absent:** AceAddon-3.0, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0. Every event handler is a plain `RegisterEvent` + dispatch table (`self[event](self, ...)`), and every "timer" is an `OnUpdate`.

## 5. Spell Data Table — How They Maintain It

`Modules/Spells/Spells_Mainline.lua` (https://github.com/muleyo/OmniCD/blob/master/Modules/Spells/Spells_Mainline.lua) is a **5000+ line auto-generated keyed array** indexed by class:

```lua
E.spell_db = {
  ["DEATHKNIGHT"] = {
    { class="DEATHKNIGHT", type="cc",        buff=47481,  spec=252,  duration=90, name="Gnaw",    icon=237524, spellID=47481 },
    { class="DEATHKNIGHT", type="interrupt", buff=47482,  spec=252,  duration=30, name="Leap",    icon=237569, spellID=47482 },
    { class="DEATHKNIGHT", type="movement",  buff=48265,  duration=45, name="Death's Advance", icon=237561, spellID=48265, talent={444010,1233429} },
    ...
  },
  ["DEMONHUNTER"] = { ... }, ...
}
```

Schema fields per row: `class, type, buff, spec, duration, name, icon, spellID, charges, talent` (talent can be a single ID or a list — used to mark conditional cooldowns).

**Versioning strategy:** **per-expansion files**, not runtime branches:
- `Spells_Vanilla.lua / .xml`, `Spells_TBC.lua`, `Spells_Wrath.lua`, `Spells_Cata.lua`, `Spells_Mists.lua`, `Spells_Mainline.lua`
- Each paired XML file lets the TOC pull only one in.

Talent-driven CD modifiers live in **separate** `Modifiers_<Flavor>.lua` files (https://github.com/muleyo/OmniCD/blob/master/Modules/Spells/Modifiers_Mainline.lua):

```lua
E.spell_cdmod_talents = {
  [48707] = { 205727, 20, 410320, 10, 457574, -20 }, -- Anti-Magic Shell
  [49576] = { nil,    {[251]=-0.01,[252]=-0.01,pvp=1000} },
  ...
}
```
A flat `[spellID] = { talentID1, modifier1, talentID2, modifier2 }` shape. Modifier can be a number (seconds added/subtracted) or a table keyed by spec ID for percentage reductions. Genius: **one row per spell, all variants on that row.**

Plus a `Modules/Spells/Core.lua` with hand-curated lookup sets:
- `E.wwDamageSpells` — set of spell IDs
- `E.specTalentChangeIDs` — spec/talent invalidation triggers
- `E.spell_highlighted`, `E.spellcast_all`, `E.hash_spelldb` — **runtime reverse indexes** built once

Also Azerite/Covenant separated: `Modules/Spells/Azerite.lua`, `Modules/Spells/Covenant.lua`.

## 6. Frame / Anchor Management — Cross-Character

This is the most interesting subsystem and **directly relevant to KickCD**.

`Core/Addons.lua` (https://github.com/muleyo/OmniCD/blob/master/Core/Addons.lua) holds a **declarative table of every supported unit-frame addon**:

```lua
local unitFrameData = {
  { [1]="VuhDo",   [2]="Vd%dH",                            [3]="raidid", [4]=2, [5]=40 },
  { [1]="Grid2",   [2]="Grid2LayoutHeader%dUnitButton",    [3]="unit",   [4]=1, [5]=5  },
  { [1]="Plexus",  [2]="PlexusLayoutHeader%dUnitButton",   [3]="unit",   [4]=1, [5]=5  },
  { [1]="ElvUI",   [2]="...",                              ... },
  ...
}
-- [1]=AddOn name, [2]=Frame name format, [3]=UnitID key, [4]=delay, [5]=#frames
```

`Core/API.lua` (https://github.com/muleyo/OmniCD/blob/master/Core/API.lua) exposes a **public registration API** so 3rd-party UFs can register themselves before `PLAYER_LOGIN`:

```lua
function OmniCD.AddUnitFrameData(addon, frame, unit, delay, testFunc, index)
```

`Modules/Party/Position.lua` (https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Position.lua) hard-codes Blizzard frame names (`CompactRaidFrame1..90`, `CompactRaidGroupNMemberM` 8x5, `CompactPartyFrameMember1..5`, `PartyMemberFrame1..4`) and decides which set is active via `CompactFrameIsActive` / `useRaidStylePartyFrames`.

**Cross-character positioning** uses AceDB profiles (with `LibDualSpec-1.0` for spec-aware swap). Per-zone position state lives at `E.profile.Party[zone].position`:

```lua
position = {
  uf = "auto",                   -- which UF addon to anchor to
  preset = "TOPRIGHT", anchor = "TOPLEFT", attach = "TOPRIGHT",
  offsetX = 4, offsetY = 0,
  layout = "horizontal", columns = 6,
  paddingX = 3, paddingY = 3,
  detached = false, locked = false,
}
```
Zones are: `arena`, `pvp` (BG), `party` (dungeon), `raid`, with `scenario`/`none` aliasing to one of those. Each zone has independent positioning. `/oc m <zone>` toggles `detached` (manual mode).

## 7. Slash Commands

`Core/Commands.lua` (https://github.com/muleyo/OmniCD/blob/master/Core/Commands.lua). Two slash entries `/oc` and `/omnicd`. Hand-rolled parser (no AceConsole):

```lua
local command, value, subvalue = msg:match("^(%S*)%s*(%S*)%s*(.-)$")
```

Commands:
- `help` / `?` — banner
- `rl` / `reload` — `E:Refresh()`
- `t` / `test` — toggle test frames for current zone
- `rt` / `reset` — reset timers; `rt db` wipes saved DB; `rt pf` resets profile; `rt <zone>` resets zone settings
- `m` / `manual` <zone> — toggle detached/manual positioning
- `s` / `spell` <zone> <type|all|default|clear> — spell-set bulk ops
- `f` <zone> <type> <1-8> — frame priority assignment

`/oc` with no args opens the AceConfigDialog panel.

## 8. Options UI

`Config/Core.lua` is the entry point. Tree:
- `Home` — version/author/license info shown via custom `dialogControl = "Info-OmniCDC"`
- `Modules` — toggle Party module
- `Profiles` — `AceDBOptions-3.0` + `LibDualSpec-1.0`

`Config/Party/` decomposes one panel per concern: `Frame.lua`, `Position.lua`, `Icons.lua`, `Highlight.lua`, `Priority.lua`, `Spells.lua`, `Visibility.lua`, `ExtraBars.lua`, `General.lua`, plus `SpellEditor.lua` and `ProfileSharing.lua`. `Config/Defaults.lua` holds the entire `C.Party.<zone>` default tree.

Localization is injected dynamically: `Config/Core.lua` runs `localization:gsub("enUS", ENUS):gsub("deDE", DEDE)...` to map the TOC's `X-Localizations` field through Blizzard's `ENUS/DEDE/ESES` globals.

## 9. Locale

`Locales/locales.xml` includes 11 locale lua files. Pattern (from `Locales/enUS.lua`):
```lua
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCD", "enUS", true)
if not L then return end
L["Active"] = "Active"
L["Active Icon Opacity"] = "Active Icon Opacity"
...
```
Default locale uses `true` (silent fallback). Multi-line keys use `[=[ ... ]=]` long brackets.

## 10. Events / Frames / Debug

**Events:** Each module CreateFrame's its own frame and registers events directly:
```lua
self:RegisterEvent("UI_SCALE_CHANGED")
self:RegisterEvent("PLAYER_REGEN_ENABLED")
self:RegisterEvent("PLAYER_ENTERING_WORLD")
self:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
```
Event handlers are methods named after the event itself.

**Frames:** Mass usage of **object pools** — `Core/Pools.lua` (https://github.com/muleyo/OmniCD/blob/master/Core/Pools.lua) implements `ObjectPoolMixin` with `Acquire / Release / ReleaseAll / HideAll / EnumerateActive / EnumerateInactive`. Party/Core.lua creates 5 pools at init: BarFrame, IconFrame, ExBarFrame, UnitBarFrame, StatusBarFrame. **Every cooldown icon you see is acquired from a pool.**

**Debug:** No formal debug framework. There's `E.write(...)` (a printf wrapper). Notification staticpopups in `Core/Dialogs.lua` use `OmniCDC.StaticPopupDialogs[...]` (their forked dialog system, not Blizzard's StaticPopupDialogs).

## 11. Comms / Sync (KickCD-relevant)

`Modules/Party/Sync.lua` (https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Sync.lua) and `Modules/Party/Inspect.lua`:

- Addon prefix = `E.AddOn` ("OmniCD")
- Messages: `"REQ"`, `"UPD"`, `"DESYNC"`, `"STRIVE"`, `"CD"` (cooldown)
- Channel auto-selects: `RAID` / `PARTY` / `INSTANCE_CHAT` based on group context
- `LibDeflate` compresses payloads
- `SERIALIZATION_VERSION` constant guards cross-version peers (6 for pre-Wrath, 7 for retail)
- `INSPECT_INTERVAL = 2`, `INSPECT_TIMEOUT = 300`, plus `inspectOrderList`, `queueEntries`, `staleEntries` queue

## 12. Profile Sharing

`Core/ProfileSharing.lua` builds a homemade `OmniCD_ProfileDialog` with editable text box. Pipeline: `AceSerializer` → `LibDeflate` → base64. `PS_VERSION = "OmniCD2"` prefix prevents importing legacy strings.

---

## Closest-Analogue Comparison: OmniCD → KickCD

KickCD tracks party interrupt CDs; OmniCD tracks **all** party CDs (interrupt is one of 25+ types in `E.L_PRIORITY`). OmniCD has solved the same problems at a much larger scale.

### Patterns to Steal (Top 5)

1. **`select(2, ...):unpack()` namespace idiom.** Every file gets `local E, L, C, G = select(2, ...):unpack()` for free — no `LibStub("AceAddon-3.0"):GetAddon(...)` boilerplate per file, faster locals, and the entire surface is 4 short upvalues. Move KickCD to this pattern; 30+ files become a one-line header each.

2. **Per-flavor data files swapped at TOC level, never at runtime.** `Spells_Mainline.lua` vs `Spells_Cata.lua` instead of `if E.isRetail then ... end`. KickCD's interrupt list is small enough today to live in one file but the same XML-include trick (`Spells_<Flavor>.xml`) future-proofs it for Classic-era kicks (e.g. Earth Shock 8s, Pummel 10s).

3. **Per-zone profile config with detached-mode toggle.** `C.Party.arena / pvp / party / raid` each have their own full settings tree (position, icons, visibility). User configures arena anchor once, dungeon anchor once, never has to fiddle on zone change. KickCD currently treats all contexts the same — split it.

4. **Declarative unit-frame-addon registry + public API.** `Core/Addons.lua` table + `OmniCD.AddUnitFrameData(...)` lets ElvUI/VuhDo/Grid2/Plexus/Cell anchor cleanly with **zero hardcoded per-addon `if` ladders elsewhere.** Critical for KickCD: when users run different raid frame addons, KickCD should anchor cleanly without per-user code edits.

5. **ObjectPoolMixin for icon/bar reuse.** `Core/Pools.lua` is ~80 lines and replaces every `CreateFrame` in hot paths. For KickCD, every party member's interrupt icon row should come from a pool — group changes (ZONE_CHANGED + roster churn) become free.

**Bonus 6:** **Talent CD modifier table** (`spell_cdmod_talents`) using `[spellID] = { talentID, mod, talentID2, mod2 }`. KickCD must already cope with reductions (e.g. Counterspell 24s → 20s with talent). One row per spell, additive, easy to maintain.

### Anti-Patterns to Avoid (Top 3)

1. **Hand-rolled mini-framework instead of AceAddon-3.0.** OmniCD reimplements `OnInitialize`/`OnEnable`/event dispatch/timers. It works because Treebonker is meticulous, but it costs hundreds of lines and means new contributors have to learn a private framework. **KickCD: stay on AceAddon/AceEvent/AceTimer.** Don't follow this.

2. **Forking AceConfigDialog into `LibOmniCDC` (AceConfigDialog-3.0-OmniCDC).** OmniCD privately patches Ace3 widgets and re-registers them under suffixed names. This blocks every Ace3 update and means custom widget bugs are theirs forever. KickCD should write `dialogControl` widgets via `AceGUI:RegisterWidgetType` instead, never fork the lib.

3. **Hardcoded frame name lists 90 entries long** (`COMPACT_RAID = {"CompactRaidFrame1", ..., "CompactRaidFrame90"}`). Should be `for i=1, 90 do tinsert(t, "CompactRaidFrame"..i) end` or `format("CompactRaidFrame%d", i)` lazy. The 90-entry literal is ~150 lines of dead noise per such list and there are 4 of them in `Position.lua`.

---

## URLs (citations)

- Repo root: https://github.com/muleyo/OmniCD
- Tree (recursive): https://api.github.com/repos/muleyo/OmniCD/git/trees/HEAD?recursive=1
- TOC: https://github.com/muleyo/OmniCD/blob/master/OmniCD_Mainline.toc
- Init: https://github.com/muleyo/OmniCD/blob/master/Core/Init.lua
- Load: https://github.com/muleyo/OmniCD/blob/master/Core/Load.lua
- Commands: https://github.com/muleyo/OmniCD/blob/master/Core/Commands.lua
- Pools: https://github.com/muleyo/OmniCD/blob/master/Core/Pools.lua
- API: https://github.com/muleyo/OmniCD/blob/master/Core/API.lua
- Addons table: https://github.com/muleyo/OmniCD/blob/master/Core/Addons.lua
- Dialogs: https://github.com/muleyo/OmniCD/blob/master/Core/Dialogs.lua
- ProfileSharing: https://github.com/muleyo/OmniCD/blob/master/Core/ProfileSharing.lua
- Embeds: https://github.com/muleyo/OmniCD/blob/master/Embeds.xml
- Modules manifest: https://github.com/muleyo/OmniCD/blob/master/Modules/Modules.xml
- Party Core: https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Core.lua
- Party Position: https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Position.lua
- Party Sync: https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Sync.lua
- Party Inspect: https://github.com/muleyo/OmniCD/blob/master/Modules/Party/Inspect.lua
- Spells Core: https://github.com/muleyo/OmniCD/blob/master/Modules/Spells/Core.lua
- Spells Mainline: https://github.com/muleyo/OmniCD/blob/master/Modules/Spells/Spells_Mainline.lua
- Modifiers Mainline: https://github.com/muleyo/OmniCD/blob/master/Modules/Spells/Modifiers_Mainline.lua
- Config Core: https://github.com/muleyo/OmniCD/blob/master/Config/Core.lua
- Defaults: https://github.com/muleyo/OmniCD/blob/master/Config/Defaults.lua
- Locale enUS: https://github.com/muleyo/OmniCD/blob/master/Locales/enUS.lua
- CurseForge: https://www.curseforge.com/wow/addons/omnicd
