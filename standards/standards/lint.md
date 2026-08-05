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
  "debugprofilestop",   -- ms CPU clock behind the perf brackets (performance-§2); omit under the performance-§12 exemption, which has no brackets
  -- per-addon globals are added per-repo
}
globals = {
  "<Addon>DB",        -- per-repo SavedVariables write target
  "<Addon>PerfDB",    -- the diagnostics capture ring (savedvariables-§4, performance-§5); omit under the performance-§12 exemption, which declares no ring
}
```

- **MUST** run `luacheck .` with **0 errors** before every commit (testing). `tests/` is excluded from lint (the harness is exercised by running it, not by linting it).
- **MUST NOT** add `globals` (write access) without a comment justifying it.
- **`libs/` is excluded**, so a vendored Ka0s-owned lib is **not** linted in the consumer — it is linted in its own repo, against its own config (library-stack-§7). The bracket **call sites** are addon code and **are** linted, which is why `debugprofilestop` belongs in `read_globals` here even though the harness itself lives under `libs/`.
- **Both perf entries are conditional on the wiring.** An addon holding a recorded **no-combat-path exemption** (performance-§12) brackets nothing and declares no capture ring, so it **MUST NOT** carry `debugprofilestop` in `read_globals` or `<Addon>PerfDB` in `globals`. Config lines for symbols the addon never touches are unfalsifiable — `luacheck` cannot warn about a permission nobody uses — so they are the ones that outlive the code that needed them. Re-arming the harness adds them back with the brackets.
