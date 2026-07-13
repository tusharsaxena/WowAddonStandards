> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Localization

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
