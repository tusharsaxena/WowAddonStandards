> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## SavedVariables / AceDB

### 1. Structure

```lua
NS.defaults = {
  profile = { display = {...}, behavior = {...} },
  global  = { schemaVersion = 0, ignored = {} },   -- 0, never the current version (below)
  char    = {},   -- only if genuinely per-character
}
local AceDB = LibStub("AceDB-3.0")
NS.db = AceDB:New("<Addon>DB", NS.defaults, true)   -- true = use current profile
```

- **MUST** keep one global namespace `<Addon>DB`.
- **MUST** declare `schemaVersion = 0` in the global namespace's defaults and ship a migration runner in `core/Database.lua`:

```lua
NS.SCHEMA_VERSION = 2   -- the runner's target: the highest step's `to`

local STEPS = {
  { to = 1, run = function() end },                   -- 0 -> 1: pre-versioning, a no-op
  { to = 2, run = function(sv, profile) ... end, perProfile = true },
}

function NS:RunMigrations()
  local g, sv = NS.db.global, _G["<Addon>DB"]
  for _, step in ipairs(STEPS) do
    if g.schemaVersion < step.to then
      if step.perProfile then
        for _, profile in pairs(sv.profiles or {}) do step.run(sv, profile) end
      else
        step.run(sv)
      end
      g.schemaVersion = step.to   -- reached only when the step returned
    end
  end
end
```

**Why the default is 0 and never the current version.** AceDB's `removeDefaults` strips every stored
value equal to its default at logout. A `schemaVersion` default equal to the current version therefore
never persists: the stamp is deleted on every logout, the next login reads the default back, and when
the version is next raised the default rises with it, so the first real migration never runs for any
existing user. AceDB's defaults merge also backfills a declared default onto a legacy account that
stored no stamp at all, so a current-version default makes an account from before the runner existed
read as already migrated. A default of **0** has neither problem: a stamp the runner advanced past 0
differs from the default and persists, and an account with no stamp reads 0 and runs every step. The
collection's worked cases are the three that hit it: a default of `NS.SCHEMA_VERSION` that the logout
strip would have erased, a floor of 1 held against a runner that walks to 8 with the reason only in a
comment, and a declared default that masked legacy accounts until the addon stopped seeding the stamp.

**Who owns the stamp** (ruled at v2.65.0; open-evolutions records the history):

- **MUST** hold the runner's target in `NS.SCHEMA_VERSION`, equal to the highest step's `to`. The
  defaults value **MUST** stay `0`; it is the pre-migration floor, not the current version, and it never
  moves.
- **MUST** let the **runner** own the stamp. A step does not write `schemaVersion`; the runner advances
  it to a step's `to` only **after that step returned without raising**. A step that raises leaves the
  stamp at the last completed step, so the next load retries it rather than skipping it.
- **MUST** run a **profile-scoped** step for **every stored profile**, either by walking the raw
  SavedVariables `profiles` table as above, or idempotently from AceDB's `OnProfileChanged` (and
  `OnProfileCopied` / `OnProfileReset`) callbacks against a **per-profile** stamp. A profile-scoped step
  **MUST NOT** be gated by the account-wide stamp alone: that runs it for the profile active at the
  first login after the upgrade and never for the others, which then carry the old shape forever. A step
  walking the raw table sees only what AceDB stored, never the defaults merged over it, so it reads an
  absent key as the default and leaves it absent.
- **MUST** write every step **idempotent against a fresh default profile**: a profile created after the
  stamp advanced, or one that already has the new shape, passes through the step unchanged.
- The executable form of these rules is each addon's own red-first migration test: a stamp that survives
  AceDB's logout strip, a raising step that leaves the stamp at the last completed step, and a
  non-active stored profile that a profile-scoped step still reaches.

- The runner, and any profile-preparation step called with it at initialization and from AceDB's profile callbacks, is the **load pass**: it writes stored data directly, before any reader has seen it, and its entry points are reachable from nothing else (a seed routine it shares with a registry writer's reset verb belongs to that writer — architecture-§5). Where it seeds or repairs a **structural registry**, architecture-§5 makes it part of that registry's writer surface and requires it named in `docs/ARCHITECTURE.md` beside the writer. It **MAY** also migrate, backfill or seed architecture-§5's **named non-setting state** — a pre-migration position lifted onto its new key, an empty learned cache — which does not make it a runtime writer that state's naming has to list.
- **SHOULD** allow the user to opt out via a soft-fallback path (an AceDB-missing shim, as the absorb-shield tracker ships). Not mandatory.

### 2. Defaults

- **MUST** declare in `defaults/Profile.lua`.
- **MUST** be the **only** place a default value is hardcoded. Schema rows `default =` reference these constants if reused.

### 3. Per-zone profile trees (optional)

For party/group/raid/PvP context-aware addons, **SHOULD** consider a per-zone profile model: `profile.party.arena`, `profile.party.party`, `profile.party.raid`, each carrying full settings (the model used by party-cooldown trackers).

### 4. The diagnostics global — the one sanctioned non-AceDB SV

savedvariables-§1's "one global namespace `<Addon>DB`" has exactly **one** carve-out: the performance capture ring `<Addon>PerfDB` (performance-§5). It is a **second top-level SavedVariables global**, declared in the TOC alongside `<Addon>DB` (toc-file-§2) and written directly rather than through AceDB.

The carve-out is **permission, not an obligation of its own**. It exists because performance-§5 requires the ring; an addon holding a recorded **no-combat-path exemption** (performance-§12) does not create the ring and therefore **MUST NOT** declare the global — an SV global nothing ever writes is a persisted empty table and a lie in the TOC. Such an addon is back to savedvariables-§1's single `<Addon>DB`, with no deviation to record beyond the register row the exemption already carries.

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
