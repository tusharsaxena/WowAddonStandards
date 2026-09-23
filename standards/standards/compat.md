> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Compat / deprecated APIs

An addon that calls any deprecated or version-variant client API outside `LibKa0s`'s majors **MUST** own those calls in `core/Compat.lua`, the **only** file allowed to make them; it exposes shimmed versions to the rest of the addon. Retail-only, so it shims across **Retail patch** differences — not across game flavors. A read a `LibKa0s` major makes for the addon with no host seam of its own — `LibKa0s-Env-1.0`'s TOC-metadata read is the case — is the library's call, and does not count toward the condition. A `LibKa0s-Compat-1.0` member the addon consumes **does** count: library-stack-§7 routes it from `core/Compat.lua`, the host's single seam, which also carries its library-absent stub.

**The applicability condition.** An addon with **no** such call carries **no** `core/Compat.lua` — an empty scaffold or a file of pass-through aliases is not required and not wanted — and records `compat-layer` as *Not applicable* in `docs/ARCHITECTURE.md`'s `## Documentation map`, citing this condition (*no deprecated or version-variant client call outside `LibKa0s`'s majors*). The first such call the addon adds brings the file with it, in the same change. Through v2.64.0 this section said every addon **MUST** ship the file, while library-stack-§7 counted two addons (AbsorbTracker, PrettyChat) that carry none and documentation-§3's `compat-layer.md` trigger counted shims in a file that might not exist; the condition is the ruling between them.

**A dead fallback rung is deleted, not shimmed.** A fallback rung that calls a global **no** client the addon's `## Interface` line admits provides is dead code: it can never reach a working call. Such a rung **MUST** be deleted rather than kept or moved into `core/Compat.lua` as a shim, wherever it sits — in a library-absent stub or inside `core/Compat.lua`'s own ladder — and deleting it does not bring a `Compat.lua` into being. Two worked cases: `GetAddOnMetadata` behind `C_AddOns.GetAddOnMetadata` in a library-absent stub (the global survives only as the newer namespace's member), and a pre-11.0 `GetMouseFocus` rung behind `GetMouseFoci` in a `Compat.lua` ladder (the global was removed in 11.0 and replaced by a differently named one). The live rung, and the caller-supplied fallback after it, stay. A rung is dead only when **every** admitted client lacks the global; a rung some admitted client still reaches is a shim and stays.

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

- **MUST** route every deprecated-API call through `Compat` (an addon the applicability condition above exempts has none to route). Direct calls to deprecated spec/spell APIs scattered through feature modules are a violation — a current addon still calls `GetSpecialization`/`GetSpecializationInfo` directly in two modules and must be migrated.
- **MUST NOT** branch on `WOW_PROJECT_ID` for game flavor (Retail only). Any Retail-patch version check that is genuinely needed lives here behind a named flag.
