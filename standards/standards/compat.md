> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Compat / deprecated APIs

Every addon **MUST** ship a `Compat.lua` (Tier 1) or `core/Compat.lua` (Tier 2). It is the **only** file that calls deprecated APIs and exposes shimmed versions. Retail-only, so it shims across **Retail patch** differences — not across game flavors.

```lua
local addonName, NS = ...
NS.Compat = NS.Compat or {}
local Compat = NS.Compat

-- Spell info: post-11.x consolidation
function Compat.GetSpellInfo(id)
  if C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(id)
    if info then return info.name, nil, info.iconID end
  end
  return GetSpellInfo and GetSpellInfo(id)
end

-- Specialization: post-11.x deprecation
function Compat.GetSpecialization()
  return (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()) or GetSpecialization()
end
```

- **MUST** route every deprecated-API call through `Compat`. Direct calls to deprecated spec/spell APIs scattered through feature modules are a violation — a current Tier-2 addon still calls `GetSpecialization`/`GetSpecializationInfo` directly in two modules and must be migrated.
- **MUST NOT** branch on `WOW_PROJECT_ID` for game flavor (Retail only). Any Retail-patch version check that is genuinely needed lives here behind a named flag.
