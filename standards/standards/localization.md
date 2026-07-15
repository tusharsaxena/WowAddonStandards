> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Localization

Localization is two-directional. Sections 1–3 govern the addon's **output** — its own text translated
into the player's language via `NS.L`. Section 4 governs the addon's **input** — the game's data
arrives *already* in the player's language, so any logic that branches on a localized display string
silently breaks on every client whose locale differs from the author's. Both directions are mandatory.

### 1. Module shape

```lua
-- locales/enUS.lua  (loads always)
local addonName, NS = ...
NS.L = setmetatable({}, { __index = function(_, k) return k end })
local L = NS.L
L["Scale"] = "Scale"
L["Reset all settings to defaults?"] = "Reset all settings to defaults?"
```

```lua
-- locales/deDE.lua (locale-gated)
if GetLocale() ~= "deDE" then return end
local addonName, NS = ...
local L = NS.L
L["Scale"] = "Skalierung"
```

- **MUST** export `NS.L` with a metatable that returns the key on miss. Replaces AceLocale strict mode (which hard-errors on missing keys) and is industry-aligned (the major aura framework, party-cooldown trackers, modular QoL addons, and the collection all do this).
- **MAY** use AceLocale-3.0 in non-strict mode if you prefer it. Strict mode is forbidden.
- **MUST** gate non-enUS files with `if GetLocale() ~= "<locale>" then return end` at top of file. (Loading every locale for every player — a QoL-addon anti-pattern — is wasteful.)
- **SHOULD** put derived-key aliases in `locales/PostLoad.lua`: `L["Use original"] = L["Original"]`. Translators don't duplicate work.

### 2. Source-of-truth keys

- **MUST** use the English string itself as the key. Reasons: missing-key fallback yields English; keys are self-documenting; no separate string-table maintenance.
- **SHOULD NOT** use opaque IDs like `L.STR_42`.

### 3. Coverage

- **MUST** at minimum ship `enUS.lua`. Any additional locale is opt-in.
- **MUST NOT** rely on Blizzard `_G` strings as a substitute for a locale module. (Leaning on `_G` strings is acceptable for a tiny utility addon but it should still ship a locale module shell.)

### 4. Match game data on IDs, not localized strings

The game hands you spell names, item names, class/race names, zone names, and unit names **already
translated into the player's locale**. Comparing any of them against a hardcoded English string makes
the branch true only on an enUS client and dead everywhere else — a bug that never reproduces for an
English-speaking author and silently disables the feature for every deDE/frFR/ruRU/koKR/zhCN/… player.

- **MUST** identify game entities by their stable numeric ID or non-localized token — **never** by a
  localized display string. The canonical keys:

  | Entity | Match on (stable) | Never on (localized) |
  | --- | --- | --- |
  | Spell / aura | `spellID` (number) | the `name` field of `C_Spell.GetSpellInfo` / `UnitAura` / `AuraUtil` |
  | Item | `itemID` | the item name |
  | Class | `classFile` token — 2nd return of `UnitClass`, or `UnitClassBase` — `"WARRIOR"` | the 1st return, `"Warrior"` |
  | Race | race token — 2nd return of `UnitRace` | the 1st return |
  | Faction | `"Alliance"`/`"Horde"` token — 2nd return of `UnitFactionGroup` | `UnitFactionGroup`'s 1st return |
  | Unit / NPC | `creatureID` parsed from `UnitGUID` | `UnitName` |
  | Zone / instance | `uiMapID` (`C_Map.GetBestMapForUnit`) or `instanceID` (8th return of `GetInstanceInfo`) | `GetZoneText` / `GetRealZoneText` / `GetSubZoneText` |
  | Fixed set | an `Enum.*` member | any string spelling of it |

- **MUST**, when logic genuinely has to match Blizzard-generated combat-log or error text, compare against
  the FrameXML **GlobalString constant** (`_G.ERR_*`, `SPELL_FAILED_*`, `_G.COMBATLOG_*`), which is itself
  localized — **never** hardcode that string's English value.
- **SHOULD** resolve a name for *display only* from the ID (`C_Spell.GetSpellInfo(spellID).name`), never
  the reverse. IDs flow to names; names never flow back into logic.
- **MUST NOT** call an ID-returning API with a localized **name** argument (e.g. `C_Spell.GetSpellInfo("Power
  Word: Shield")`). Pass the `spellID`.

```lua
-- WRONG — dead on every non-enUS client
if C_Spell.GetSpellInfo(spellID).name == "Power Word: Shield" then ...
local _, _, class = ...; if UnitClass("player") == "Priest" then ...
if GetRealZoneText() == "Orgrimmar" then ...

-- RIGHT — locale-independent
local PWS = 17          -- spellID
if spellID == PWS then ...
local _, classFile = UnitClass("player"); if classFile == "PRIEST" then ...
if select(8, GetInstanceInfo()) == 1637 then ...   -- Orgrimmar instanceID
```

**Uppercase tokens are the fix, not the bug.** `classFile == "PRIEST"`, `Enum.PowerType.Mana`, unit
tokens (`"player"`, `"target"`), and event names (`"UNIT_AURA"`) are non-localized Blizzard identifiers,
identical on every client — matching on them is correct and required. Only *localized display text* is
forbidden.
