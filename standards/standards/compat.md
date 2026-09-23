> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Compat / deprecated APIs

Every addon **MUST** ship a `core/Compat.lua`. It is the **only** file that calls deprecated APIs and exposes shimmed versions. Retail-only, so it shims across **Retail patch** differences — not across game flavors.

```lua
local addonName, NS = ...
NS.Compat = NS.Compat or {}
local Compat = NS.Compat
local CompatLib = LibStub and LibStub("LibKa0s-Compat-1.0", true)

-- Spell info: post-11.x consolidation. The ladder (C_Spell, then the legacy global with its
-- rank dropped) is the library's; the contract is
--   name, iconID, castTime, minRange, maxRange, spellID   -- or a single nil
-- Library absent: the major's documented absent answer.
Compat.GetSpellInfo = CompatLib and CompatLib.GetSpellInfo or function() return nil end

-- Specialization: post-11.x deprecation
Compat.GetSpecialization = CompatLib and CompatLib.GetSpecialization or function() return nil end
```

The example is **illustrative**: it routes two members through `LibKa0s-Compat-1.0`, which ships from `LibKa0s v1.55.0` (library-stack-§7), and shows the library's `GetSpellInfo` contract — `name, iconID, castTime, minRange, maxRange, spellID` — rather than the legacy positional shape with a `nil` rank slot. Adopting the major is on each addon's own schedule and this section does not require it; what it requires is below. A shim no major carries is written in this same file, by hand, as before.

- **MUST** route every deprecated-API call through `Compat`. Direct calls to deprecated spec/spell APIs scattered through feature modules are a violation — a current addon still calls `GetSpecialization`/`GetSpecializationInfo` directly in two modules and must be migrated.
- **MUST NOT** branch on `WOW_PROJECT_ID` for game flavor (Retail only). Any Retail-patch version check that is genuinely needed lives here behind a named flag.
