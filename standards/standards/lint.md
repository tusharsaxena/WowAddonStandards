> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Lint (`.luacheckrc`)

Every addon **MUST** ship `.luacheckrc` at the root. Base it on the common WoW-addon `luacheck` config:

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "docs/audits/", "docs/reviews/", "_dev/", "tests/_kit/" }
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
-- The test tree is linted. The harness publishes its shared table under a per-repo global,
-- written by `tests/run.lua` and read by every suite file (testing-§2). It is declared HERE and
-- not in the top-level `read_globals` above: a name declared at the top level is a name the
-- addon's own source may then reach for unchallenged, and no shipped file may ever touch the
-- harness. `globals` rather than `read_globals` because `tests/run.lua` is the writer.
files["tests/"] = {
  globals = { "<ADDON>_TEST" },
}
```

- **MUST** run `luacheck .` with **0 errors** before every commit (testing). **The test tree is in scope.** A suite file is Lua the repo authors and maintains, and the argument that it is *exercised by running it* proves only that the paths a run reaches are executed — a typo in an unreached branch, a shadowed local, an unused upvalue in a helper no case calls, none of them raise, and the run stays green over them. Across the ten repositories that is **308 test files against 329 source files** (`git ls-files '*.lua'`, `libs/` and `tests/_kit/` excluded), so a `.luacheckrc` that excludes bare `tests/` buys a clean-lint claim covering a little under half the Lua the collection owns.
- **Only `tests/_kit/` is excluded, and for a reason that does not generalise.** It is a byte copy of the vendored kit, whose original is linted in `LibKa0s` as source (library-stack-§7). Linting both reports every finding twice and — worse — lets the copy drift green while the original goes red, which is the one state a `diff -r` re-vendor gate is supposed to make impossible.
- **The harness global goes in the `files["tests/"]` stanza, never in top-level `read_globals`.** The two look interchangeable and are not: a name at the top level is a permission granted to `Core.lua` as much as to `tests/test_core.lua`, and a shipped file reaching for the test harness is exactly the kind of thing lint is here to refuse. `globals` and not `read_globals` because `tests/run.lua` writes it.
- **MUST NOT** turn the tree on behind a blanket `ignore`. Whatever the newly-linted files report is the point of linting them; an ignore wide enough to silence the wall reads as coverage in every table that quotes the `0/0` and provides none, which is strictly worse than the exclusion it replaced. Fix them, or carry a narrow per-code ignore in the stanza with a comment saying which files and why.
- **MUST NOT** add `globals` (write access) without a comment justifying it.
- **`libs/` is excluded**, so a vendored Ka0s-owned lib is **not** linted in the consumer — it is linted in its own repo, against its own config (library-stack-§7). The bracket **call sites** are addon code and **are** linted, which is why `debugprofilestop` belongs in `read_globals` here even though the harness itself lives under `libs/`.
- **Both perf entries are conditional on the wiring.** An addon holding a recorded **no-combat-path exemption** (performance-§12) brackets nothing and declares no capture ring, so it **MUST NOT** carry `debugprofilestop` in `read_globals` or `<Addon>PerfDB` in `globals`. Config lines for symbols the addon never touches are unfalsifiable — `luacheck` cannot warn about a permission nobody uses — so they are the ones that outlive the code that needed them. Re-arming the harness adds them back with the brackets.
