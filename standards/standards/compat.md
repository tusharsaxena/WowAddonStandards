> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Compat / deprecated APIs

An addon that calls any deprecated or version-variant client API outside `LibKa0s`'s majors **MUST** own those calls in its **compat family** (below), and **no** other file may make them; the family exposes shimmed versions to the rest of the addon. Retail-only, so it shims across **Retail patch** differences — not across game flavors. A read a `LibKa0s` major makes for the addon with no host seam of its own — `LibKa0s-Env-1.0`'s TOC-metadata read is the case — is the library's call, and does not count toward the condition. A `LibKa0s-Compat-1.0` member the addon consumes **does** count: library-stack-§7 routes it from `core/Compat.lua`, the family's root, which also carries its library-absent stub.

**The compat family.** The family is `core/Compat.lua` plus zero or more `core/Compat<Topic>.lua` files, where `<Topic>` is a PascalCase name for **one** concern (`CompatItem.lua`, `CompatWorld.lua`). A file outside that pattern — a shim in `modules/`, a `core/ItemCompat.lua`, a `core/Compat/` folder — is not in the family and **MUST NOT** make a deprecated or version-variant client call. A family of one file is the normal case.

- **One seam (MUST).** Every family file publishes into the same `NS.Compat` table (`NS.Compat = NS.Compat or {}`) and into no table of its own. Callers reach `NS.Compat.X` and **MUST NOT** know, name or depend on which family file defines `X`; moving a member between family files changes no caller.
- **The root (MUST).** `core/Compat.lua` is present whenever any family file is. It is listed **first of the family** in the TOC, and every other family file follows it immediately and contiguously (toc-file-§5). It carries the `LibKa0s-Compat-1.0` resolution, every member routed through that major and that member's library-absent stub; a split file holds hand-written shims only. Its file header names every other family file (each `core/Compat<Topic>.lua`) by path, so the header alone tells a reader where the rest of the seam lives; it need not list the individual `NS.Compat` members. Here and throughout this section a *member* is one `NS.Compat.X` shim and a *family file* is one `core/Compat*.lua`.
- **When to split.** A split file **MAY** be opened only when the family's combined length would otherwise put `core/Compat.lua` past layout-§1's **1000-line** on-notice line (`cat core/Compat*.lua | wc -l` above 1000), and **SHOULD** be opened then, rather than letting the root grow toward layout-§1's 1500-line cap. Each split file **MUST** hold the one cohesive topic its name states; a split by size alone (`CompatMore.lua`, `Compat2.lua`) is a violation.
- **Family-wide rules.** The applicability condition, the dead-fallback-rung rule and documentation-§3's `compat-layer.md` trigger apply to the family as a whole: a shim count is counted across every family file, and a rule below that says *`core/Compat.lua`* or *`Compat`* as the home of such calls means the family.
- **Fencing (MAY).** An addon's lint or test fence that confines client globals to `core/Compat.lua` — a `.luacheckrc` `files[...]` block, a seam-only test — **MAY** name each family file, or the `core/Compat*.lua` pattern, and **MUST NOT** reach any file outside the family.

Through v2.78.3 this section named `core/Compat.lua` the **only** file allowed to make such calls. v2.79.0 widens that to the family on the owner's decision of 2026-10-11, when Ka0s Drop Watcher's `core/Compat.lua` stood at 999 lines with its item and world shims still to place (`core/CompatItem.lua`, `core/CompatWorld.lua`): the one-file rule and the 1500-line cap would otherwise have met inside a single file.

**The applicability condition.** An addon with **no** such call carries **no** compat family — no `core/Compat.lua` and no `core/Compat<Topic>.lua`; an empty scaffold or a file of pass-through aliases is not required and not wanted — and records `compat-layer` as *Not applicable* in `docs/ARCHITECTURE.md`'s `## Documentation map`, citing this condition (*no deprecated or version-variant client call outside `LibKa0s`'s majors*). The first such call the addon adds brings `core/Compat.lua` with it, in the same change. Through v2.64.0 this section said every addon **MUST** ship the file, while library-stack-§7 counted two addons (AbsorbTracker, PrettyChat) that carry none and documentation-§3's `compat-layer.md` trigger counted shims in a file that might not exist; the condition is the ruling between them.

An addon that ships an in-game simulator (preview-mode, *The in-game simulator*) routes through its compat family every client read the simulation answers, deprecated or not, because that table is what `LibKa0s-Sim-1.0`'s seam wraps. Such a read is a family member like any other, and the applicability condition never exempts it: the first such read brings `core/Compat.lua` with it.

**A dead fallback rung is deleted, not shimmed.** A fallback rung that calls a global **no** client the addon's `## Interface` line admits provides is dead code: it can never reach a working call. Such a rung **MUST** be deleted rather than kept or moved into the compat family as a shim, wherever it sits — in a library-absent stub or inside a family file's own ladder — and deleting it does not bring a `Compat.lua` into being. Two worked cases: `GetAddOnMetadata` behind `C_AddOns.GetAddOnMetadata` in a library-absent stub (the global survives only as the newer namespace's member), and a pre-11.0 `GetMouseFocus` rung behind `GetMouseFoci` in a `Compat.lua` ladder (the global was removed in 11.0 and replaced by a differently named one). The live rung, and the caller-supplied fallback after it, stay. A rung is dead only when **every** admitted client lacks the global; a rung some admitted client still reaches is a shim and stays.

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

The example is **illustrative**: it routes two members through `LibKa0s-Compat-1.0`, which ships from `LibKa0s v1.55.0` (library-stack-§7), and shows the library's `GetSpellInfo` contract — `name, iconID, castTime, minRange, maxRange, spellID` — rather than the legacy positional shape with a `nil` rank slot. Adopting the major is on each addon's own schedule and this section does not require it; what it requires is below. A shim no major carries is written by hand, in `core/Compat.lua` or in the split file its topic belongs to.

- **MUST** route every deprecated-API call through `Compat` (an addon the applicability condition above exempts has none to route). Direct calls to deprecated spec/spell APIs scattered through feature modules are a violation — a current addon still calls `GetSpecialization`/`GetSpecializationInfo` directly in two modules and must be migrated.
- **MUST NOT** branch on `WOW_PROJECT_ID` for game flavor (Retail only). Any Retail-patch version check that is genuinely needed lives in the compat family behind a named flag.
