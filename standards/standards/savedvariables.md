> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## SavedVariables / AceDB

### 1. Structure

```lua
NS.defaults = {
  profile = { display = {...}, behavior = {...} },
  global  = { schemaVersion = 1, ignored = {} },
  char    = {},   -- only if genuinely per-character
}
local AceDB = LibStub("AceDB-3.0")
NS.db = AceDB:New("<Addon>DB", NS.defaults, true)   -- true = use current profile
```

- **MUST** keep one global namespace `<Addon>DB`.
- **MUST** declare `schemaVersion` in the global namespace and ship a migration function in `core/Database.lua`:

```lua
function NS:RunMigrations()
  local g = NS.db.global
  g.schemaVersion = g.schemaVersion or 1
  if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
end
```

- **SHOULD** allow the user to opt out via a soft-fallback path (an AceDB-missing shim, as the absorb-shield tracker ships). Not mandatory.

### 2. Defaults

- **MUST** declare in `defaults/Profile.lua`.
- **MUST** be the **only** place a default value is hardcoded. Schema rows `default =` reference these constants if reused.

### 3. Per-zone profile trees (optional)

For party/group/raid/PvP context-aware addons, **SHOULD** consider a per-zone profile model: `profile.party.arena`, `profile.party.party`, `profile.party.raid`, each carrying full settings (the model used by party-cooldown trackers).

### 4. The diagnostics global — the one sanctioned non-AceDB SV

savedvariables-§1's "one global namespace `<Addon>DB`" has exactly **one** carve-out: the performance capture ring `<Addon>PerfDB` (performance-§5). It is a **second top-level SavedVariables global**, declared in the TOC alongside `<Addon>DB` (toc-file-§2) and written directly rather than through AceDB.

- **MUST** stay **outside the AceDB tree**. Inside a profile it would be copied by "copy profile", wiped by "reset profile", and swapped out mid-capture by a profile switch. Diagnostics are not user settings and **MUST NOT** ride the settings lifecycle.
- **MUST** be a bounded ring of most-recent captures — a hand-read snapshot store, not telemetry.
- **MUST** carry its own schema stamp, owned by the library that writes it (performance-§8) and independent of the addon's `schemaVersion`.
- **MUST NOT** be joined by further top-level globals. The carve-out is **narrow by construction**: one diagnostics global per addon, named after that addon. A second one needs a change to this standard, not a local decision.

### 5. Defaulting a stored value: `== nil`, not `or` (MUST)

`stored.k or D.k` is the shortest way to write "use the default when unset", and it is wrong for every
field whose stored value can legitimately be **falsy or empty**. Lua's `or` cannot distinguish *unset*
from *set to `false`*, and the same one-liner spelled over a table of fields silently launders three
different user choices into the default:

- a stored **`false`** — the user turned the thing off, and `or` turns it back on;
- an **empty string** — a cleared custom path or label, restored to the shipped one on next read;
- an **empty table/set** — "I deselected every option", restored to the full default selection.

`0` is truthy in Lua and so survives `or`, which is exactly what makes this bug hard to spot: the
numeric fields a reader spot-checks all behave, and the boolean and empty-collection fields do not.

- **MUST** test absence with **`== nil`** when defaulting any field where a falsy or empty stored value
  is a meaningful user choice. `if stored.k == nil then t.k = D.k else t.k = stored.k end`, or a
  `pick(v, d)` helper applied over a defaults table.
- **MUST** carve out and comment the fields where empty is deliberate, at the point of defaulting. An
  addon that means "an empty accent-edge set is a choice, not an unset field" **MUST** say so where the
  defaulting happens, because the next mechanical sweep over that table is what would otherwise undo it.
- **MUST NOT** introduce `or`-defaulting while refactoring for complexity. `or` is one decision to
  `lizard` and `if ... == nil` is one as well, so the metric does not favor either — but a refactor
  that rewrites a careful `== nil` ladder into a compact `or` table has changed behavior for every
  falsy field in it (performance-§11, anti-patterns #54).
- `AceDB`'s own defaults merge follows `nil`-ness, not truthiness, so a hand-written `or` layer on top
  of AceDB disagrees with the library underneath it about what "unset" means — in the one direction
  the user notices, since AceDB restores their `false` and the addon's own read overrides it.
