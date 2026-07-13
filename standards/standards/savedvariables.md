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

- **MUST** declare in `defaults/Profile.lua` (Tier 2) or in `Settings.lua` (Tier 1).
- **MUST** be the **only** place a default value is hardcoded. Schema rows `default =` reference these constants if reused.

### 3. Per-zone profile trees (optional)

For party/group/raid/PvP context-aware addons, **SHOULD** consider a per-zone profile model: `profile.party.arena`, `profile.party.party`, `profile.party.raid`, each carrying full settings (the model used by party-cooldown trackers).
