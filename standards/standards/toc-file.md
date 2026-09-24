> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## TOC file

### 1. Required fields

The metadata block **MUST** use this **exact field order** (omit a line only when the field genuinely doesn't apply); no blank lines inside the block:

```
## Interface: <latest Retail>            -- SINGLE number; latest Retail patch (toc-file-§3)
## Title: Ka0s <Human Name>              -- prefix every Ka0s addon
## Notes: <one-line user-facing description>
## Author: add1kted2ka0s
## Version: <semver>                     -- managed by bump-version skill
## IconTexture: Interface\AddOns\<Folder>\media\logos\<addon>.logo.128.tga   -- the addon's OWN logo (toc-file-§1, layout-§4)
## SavedVariables: <Addon>DB, <Addon>PerfDB   -- settings global + diagnostics ring (toc-file-§2)
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: <a category string the client accepts>   -- see the note below the block
## X-License: MIT
## X-Standard: https://github.com/tusharsaxena/WowAddonStandards
## X-Curse-Project-ID: <id>              -- mandatory once published on CurseForge; omitted (with a comment) before that
## X-Wago-ID: <id>                       -- optional; only if listed on Wago
## X-WoWI-ID: <id>                       -- optional; only if listed on WoW Interface
```

- **MUST** follow the field order above so every Ka0s TOC reads identically. The file listing that follows the metadata block has its own required structure (toc-file-§5). Reference implementation (in the collection): the modular tracker's TOC.
- **MUST** have `X-License: MIT`. **MUST NOT** ship "All Rights Reserved".
- **MUST** have `X-Standard:` pointing at the standards repo, declaring the addon is built to this standard.
- **MUST** have `X-Curse-Project-ID` once the addon is published on CurseForge (the collection's distribution platform). **Before** it is published the field is **omitted**, and the omission is **compliant**: an unpublished addon **MUST NOT** carry a placeholder, invented, or borrowed id — the packager uploads to whatever project the id names, so a placeholder does not fail loudly, it publishes this addon into somebody else's project. An unpublished addon **SHOULD** carry a one-line comment where the field would go (`# X-Curse-Project-ID: not published on CurseForge yet`), in the field's own position, so the next reader sees a decision rather than an oversight. With that comment present the absence needs **no deviation-register row** — the same shape toc-file-§5 uses for a forced within-section order. Filing the absence as a deviation files a row no act of the addon can close. `X-Wago-ID` and `X-WoWI-ID` are **optional** (**MAY**) — include each only when the addon is actually listed on that platform (Wago / WoW Interface respectively); an addon that doesn't publish there simply omits the line. Keep the field **order** above regardless (Curse → Wago → WoWI).
- **MUST** set `## IconTexture:` to the addon's **own logo**, at the absolute in-game path `Interface\AddOns\<Folder>\media\logos\<addon>.logo.128.tga`. The field was *optional but encouraged*; it is now required, because that same file is also the minimap button's icon and the broker object's icon (launcher-§4), so the AddOns list, the minimap and a broker display show one identity rather than three. **MUST NOT** use a **Blizzard icon path** (`Interface\Icons\…`) or a **numeric file id**: a borrowed icon makes the addon look like something else in the one list where the player is deciding what to turn off, and a bare number says nothing to the next person reading the TOC. The file's exact format and the recipe that generates it are **layout-§4** (128×128, uncompressed 32-bit TGA), which owns shipped media; do not restate them here (**anti-pattern #82**).
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
- **MUST** declare `schemaVersion = 0` in defaults — the pre-migration floor, never the current version, which lives in `NS.SCHEMA_VERSION` (savedvariables-§1 says why and who advances the stamp). **MUST** ship a `Database.lua` migration runner even if the body is empty — schema migration is a from-day-one concern.

### 3. Retail only — single Interface line

The collection targets **Retail (Mainline) only**. Classic/other flavors are out of scope for the standard.

- **MUST** ship a single TOC with a **single** `## Interface:` value = the **latest Retail patch** interface number. The standard deliberately carries no literal for it, because a number written here goes stale the next patch: the collection's current value is the one its addons ship (the roster, `ADDONS.md`, lists them), and `/wow-addon:bump-interface` determines the Live value and bumps it each patch.
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
core\Compat.lua                          -- conventional: reached through closures at call time
core\MediaSetup.lua                      -- LOAD-BEARING: publishes NS.MediaFont, which Constants
                                         -- resolves FONT_MONO from at file load
core\Constants.lua
core\State.lua
core\Util.lua
core\PerfSetup.lua                       -- LOAD-BEARING: before any module taking NS.Perf as an
                                         -- upvalue (performance-§1)
core\Database.lua                        -- conventional, as are the lines above it without a note
core\<Addon>.lua

# Defaults
defaults\Profile.lua

# Modules
modules\<Feature>.lua

# Settings (last — depend on everything else being initialized)
settings\Panel.lua
settings\...
```

- **MUST** use `#` section headers, in the order **Libraries → Locales → Core → Defaults → Modules → Settings** — the same folder load order `layout-§1` states, expressed as the headers an author is actually looking at while writing a TOC. Libraries always load **first**; settings **last**, because a settings panel depends on every module it configures already being initialized.
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

**Every position in the listing is one of two things, and the TOC says which.** A position is
**load-bearing** when something resolves *at file scope* as the file loads — a library major taken
as an upvalue, a constant computed from a seam that loaded earlier — so moving the line changes
behavior. A position is **conventional** when everything the file needs is reached through a closure
at call time, so the line is free to move and only reads oddly out of place.

The distinction is worth a rule rather than a habit because of how the load-bearing kind fails:
silently, and only in the client. A media seam that publishes `NS.MediaFont` sits above
`core\Constants.lua` because `Constants` resolves its monospace font from it **at file load**; move
the seam below and nothing errors, no test goes red, and every consumer quietly gets the client
default font instead. The comment is the only guard there is.

- A line whose position is **load-bearing MUST** carry a comment saying so, at the line, naming
  **what resolves at load** — not merely that the order matters. `core\PerfSetup.lua` in the block
  above is the form: the constraint and its reason on one line.
- A position that is merely **conventional SHOULD** say that too, once per group rather than per
  line, so the next author knows which lines are safe to move without re-deriving the whole
  dependency graph. A TOC that annotates only its load-bearing lines leaves every other line
  ambiguous between "free" and "not yet understood".
- Moving an annotated line **MUST** be preceded by reading its comment. This is the one rule here
  that is about the reader rather than the writer, and it is the one the annotation exists for.

**The denominator this MUST is measured against.** The MUST above binds **load-bearing positions**,
and its denominator is the set of positions that actually are load-bearing — established by reading
the seam files (`*Setup.lua`) and `core\Constants.lua`, not by counting lines in the TOC. An 81-line
listing with two load-bearing positions has a denominator of **two**: annotate both and the file
passes the MUST outright, and the seventy-nine other lines are not seventy-nine unmet MUSTs. An
unannotated **conventional** line is never a MUST failure. At most it is the SHOULD above, which is
graded separately, once per group, and files a SHOULD row.

**This is stated because an audit got it wrong.** The 2026-09-07 collection audit read the MUST
against every line of nine TOC files — 23 to 81 lines each — and on that arithmetic concluded the
rule was unsatisfiable and had to be rewritten. Measured against its own denominator the same nine
files were **eight** unannotated load-bearing positions in three of them: `KickCD.toc:55` and `:73`,
`PrettyChat.toc:40` and `:57`, and four in `WhatGroup.toc` at `:44`, `:47` and `:53-56`. No per-repo
audit filed a per-line MUST row against the remaining six. The rule did not change; the denominator
did, and a rule counted against the wrong denominator looks unworkable long before it is.

**Worked example — both kinds, one file.** `AbsorbTracker.toc:35-42` carries one of each and is the
form to copy:

```
# Core (the LibKa0s-Env seam loads first)
# The LibKa0s-Env seam: this addon reads its own TOC manifest through it. Nothing here is resolved
# at load, so this position is conventional rather than load-bearing.
core\EnvSetup.lua
# Before Constants, deliberately: Constants.FONT_MONO is resolved from the NS.MediaFont seam
# this file publishes, so a Constants that loaded first would resolve it to the fallback.
core\MediaSetup.lua
core\Constants.lua
```

`core\MediaSetup.lua` satisfies the **MUST**: the comment names the symbol that resolves
(`Constants.FONT_MONO`), the seam it resolves from (`NS.MediaFont`) and what moving the line would
silently do. `core\EnvSetup.lua` satisfies the **SHOULD**: it says the position is free, and why it
is free despite being a seam. `core\Constants.lua` carries nothing and is **compliant** — its
position is already pinned by the annotated line above it, and a rule that made every line restate
its neighbor's comment would be noise the next reader learns to skip.

**Grading, so two auditors reach the same row.**

- A load-bearing position with no comment, or with a comment saying only *"order matters"* without
  naming what resolves: one **MUST** row, one row per position.
- A file whose load-bearing positions are all annotated and whose conventional groups are not: one
  **SHOULD** row for the file — never one per line, and never a MUST row.
- A file whose within-section sequence is unusual but dependency-correct and annotated: **no row**,
  per the ordering rules above.
