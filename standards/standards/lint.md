> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Lint (`.luacheckrc`)

Every addon **MUST** ship `.luacheckrc` at the root. Base it on the common WoW-addon `luacheck` config:

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "docs/audits/", "docs/reviews/", "_dev/", "tests/" }
ignore = {
  "212/self",   -- unused argument self
  "212/event",  -- unused argument event
}
read_globals = {
  "_G", "LibStub", "CreateFrame", "GetTime", "UnitName", "UnitGUID",
  "GetSpellInfo", "C_Spell", "C_SpecializationInfo", "GetSpecialization",
  "InCombatLockdown", "PlaySound", "GetLocale",
  "Settings", "InterfaceOptionsFrame_OpenToCategory",
  "C_Timer", "hooksecurefunc",
  "CreateColor",
  -- per-addon globals are added per-repo
}
globals = {
  "<Addon>DB",        -- per-repo SavedVariables write target
}
```

- **MUST** run `luacheck .` with **0 errors** before every commit (testing). `tests/` is excluded from lint (the harness is exercised by running it, not by linting it).
- **MUST NOT** add `globals` (write access) without a comment justifying it.
