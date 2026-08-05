> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## TOC file

### 1. Required fields

The metadata block **MUST** use this **exact field order** (omit a line only when the field genuinely doesn't apply); no blank lines inside the block:

```
## Interface: 120007                     -- SINGLE number; latest Retail patch (toc-file-§3)
## Title: Ka0s <Human Name>              -- prefix every Ka0s addon
## Notes: <one-line user-facing description>
## Author: add1kted2ka0s
## Version: <semver>                     -- managed by bump-version skill
## IconTexture: <path|fileID>            -- optional but encouraged
## SavedVariables: <Addon>DB, <Addon>PerfDB   -- settings global + diagnostics ring (toc-file-§2)
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: <a category string the client accepts>   -- see the note below the block
## X-License: MIT
## X-Standard: https://github.com/tusharsaxena/WowAddonStandards
## X-Curse-Project-ID: <id>              -- mandatory once published on CurseForge
## X-Wago-ID: <id>                       -- optional; only if listed on Wago
## X-WoWI-ID: <id>                       -- optional; only if listed on WoW Interface
```

- **MUST** follow the field order above so every Ka0s TOC reads identically. The file listing that follows the metadata block has its own required structure (toc-file-§5). Reference implementation (in the collection): the modular tracker's TOC.
- **MUST** have `X-License: MIT`. **MUST NOT** ship "All Rights Reserved".
- **MUST** have `X-Standard:` pointing at the standards repo, declaring the addon is built to this standard.
- **MUST** have `X-Curse-Project-ID` once the addon is published on CurseForge (the collection's distribution platform). `X-Wago-ID` and `X-WoWI-ID` are **optional** (**MAY**) — include each only when the addon is actually listed on that platform (Wago / WoW Interface respectively); an addon that doesn't publish there simply omits the line. Keep the field **order** above regardless (Curse → Wago → WoWI).
- **SHOULD NOT** declare hard `Dependencies`. Use `OptionalDeps` and shim missing libs with soft fallbacks. Reference implementation (in the collection): the absorb-shield tracker ships an AceDB-missing flat-table shim and LSM-missing Blizzard fallback constants, so it loads even with no libs present.

**`Category-enUS` — the value MUST be a string the client accepts, and any list here is illustrative.**
The category set is **Blizzard's**, not this standard's, and it changes between client builds. The
normative requirement is only that the value is a category string the current client accepts, spelled
exactly as Blizzard spells it — including the ampersand and the spaces in the multi-word ones.

Commonly used, as an **illustration and not an enumeration**: `Combat`, `Group`, `Auction`, `Chat`,
`UI`, `Misc`, `Chat & Communication`, `Roleplay`, `Quests & Leveling`, `Professions`, `Map & Minimap`,
`Class`, `Unit Frames`, `Action Bars`, `Tooltip`, `Buffs & Debuffs`, `Combat Log`, `PvP`, `Data
Broker`, `Development Tools`.

An earlier version of this section listed six values as a closed set. That was the incomplete half of
the disagreement: `Chat & Communication` is a real Blizzard category, and narrowing an addon's TOC to
`Chat` to satisfy the enumeration would list it under a category Blizzard does not use. **Do not file a
deviation against a `Category-enUS` value on the strength of a list in this document** — check it
against the client.

### 2. SavedVariables naming

- **MUST** name the settings global `<Addon>DB`. Already universal in the collection.
- **MUST** declare exactly **two** SavedVariables globals in the order above **when the performance harness is wired**: `<Addon>DB` (the AceDB tree) and `<Addon>PerfDB` (the performance capture ring, performance-§5). The second is the standard's **one sanctioned non-AceDB SV global** (savedvariables-§4) — a diagnostics store deliberately outside the profile tree so it never rides profile copy, reset, or switch. An addon holding a recorded **no-combat-path exemption** (performance-§12) declares **one**: `<Addon>DB` alone, because nothing would ever write the ring. So: **two when wired, one when exempt, never three** — a **third** top-level global is non-compliant either way, and a `<Addon>PerfDB` declared by an exempt addon is a global nothing writes.
- **SHOULD NOT** use `SavedVariablesPerCharacter` unless the data is genuinely per-character (most Ka0s addons run profile-per-character via AceDB; that's enough).
- **MUST** declare a `schemaVersion` integer in defaults. **MUST** ship a `Database.lua` migration runner even if the body is empty — schema migration is a from-day-one concern.

### 3. Retail only — single Interface line

The collection targets **Retail (Mainline) only**. Classic/other flavors are out of scope for the standard.

- **MUST** ship a single TOC with a **single** `## Interface:` value = the **latest Retail patch** interface number (currently `120007`). Bump it each patch with the `wow-addon:bump-interface` skill.
- **MUST NOT** use a comma-separated multi-flavor Interface list, per-flavor TOC files, or `enable-toc-creation` flavor fan-out.
- **MUST NOT** ship `_Mainline`/`_Classic` data splits. Data files are plain (`Spells.lua`, `Data*.lua`).
- **MUST NOT** use `if WOW_PROJECT_ID == ...` ladders inline in feature code. Any genuine cross-patch version check is a Retail-patch check and is branched in `Compat.lua` behind a named flag (compat).
- The README `[wow]` badge (canonical template `![WoW](https://img.shields.io/badge/WoW-<Expansion>_<X.Y.Z>-purple)`, documentation-§1 #1) **MUST** show this same single Interface number and stay in lockstep with the TOC: bumping `## Interface:` and updating the badge is **one change**, never deferred (documentation).

### 4. File listing

- **MUST** list `.lua` files in dependency-correct order. **MUST NOT** rely on alphabetical loading.
- **MUST** list every vendored library **directly** in the `# Libraries` section (toc-file-§5) — one entry per library (its `.lua`, or the library's own packaged `.xml` such as `AceGUI-3.0.xml`), in dependency order. **MUST NOT** delegate library loading to an addon-authored `embeds.xml` (or any other aggregate `.xml` the TOC loads as a single line): the wrapper hides the load order from the TOC that every Ka0s addon otherwise reads identically, and splits "what loads first" across two files for no benefit at Ka0s file counts. The TOC is the single, self-documenting load-order source of truth (anti-patterns #38).

### 5. File-listing structure (after the metadata block)

The metadata block (toc-file-§1) is followed by **one blank line**, then the file listing broken into **commented sections in load order**. Every Ka0s TOC uses the same section comments so the load order is self-documenting. Reference implementation (in the collection): the modular tracker's TOC.

```
# Libraries (must load first)
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
...
libs\LibKa0s\LibKa0s.xml                 -- Ka0s-owned shared modules, after Ace3 (library-stack-§7)

# Locales
locales\enUS.lua

# Core
core\Compat.lua
core\Constants.lua
core\State.lua
core\Util.lua
core\PerfSetup.lua                       -- before any module taking NS.Perf as an upvalue (performance-§1)
core\Database.lua
core\<Addon>.lua

# Defaults
defaults\Profile.lua

# Modules
modules\<Feature>.lua

# Settings (last — depend on everything else being initialized)
settings\Panel.lua
settings\...
```

- **MUST** use `#` section headers, in the order **Libraries → Locales → Core → Defaults → Modules → Settings**, matching the load order (layout-§1). Libraries always load **first**; settings **last**.
- **MUST** end the file with a single trailing newline.

**The file sequence *within* a section is illustrative, not normative.** The block above is a reference
implementation. Read it as one: the two MUSTs are the **section-header order** and the single trailing
newline, and nothing else in that block is a rule.

Specifically, the within-`core/` sequence shown — `Compat → Constants → State → Util → PerfSetup →
Database → <Addon>` — is **not** an ordered MUST, and it is **not achievable** in every addon. An addon
whose `Namespace.lua` bootstraps the `NS` table that `Compat.lua` and `Constants.lua` then attach to
**cannot** put `Compat` first; the bootstrap has to load before the files that extend it. Filing that as
a MUST failure is filing the reference implementation's incidental order as a rule.

What the within-section order **MUST** satisfy is the load-order constraints the code actually has —
the bootstrap before whatever attaches to it, `core\PerfSetup.lua` before any module taking `NS.Perf`
as a load-time upvalue (performance-§1, performance-§2) — and nothing more.

- An addon whose bootstrap forces a different within-section order **MUST** state the reason in a
  **comment in the TOC itself**, immediately above the affected lines, where the next reader and the
  next auditor both already are.
- With that comment present the ordering is **compliant** and needs no deviation-register row: a
  register row records a departure from a rule, and there is no rule here to depart from.
