> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Automated tests & local build toolchain

Every addon **MUST** ship an automated, **headless** test harness and be developed **test-first (TDD)**. Reference implementation (in the collection): the loot-history browser's `tests/` — a plain-Lua-5.1 harness (busted-compatible in spirit, no external framework required).

### 1. Harness shape

```
tests/
  run.lua            -- runner + micro-framework; loads sources + suites, exits non-zero on any failure
  loader.lua         -- headless source loader
  wow_mock.lua       -- WoW API mock builder
  test_<module>.lua  -- one suite per module (test_util.lua, test_database.lua, ...)
```

- **`run.lua`** defines a tiny framework — `test(name, fn)`, `assertEqual`, `assertTrue`, `assertFalse` — and exposes them (plus `NS` and the mocks) to suites via a single global table (e.g. `_G.<ADDON>_TEST`). It builds the addon environment once by loading every source in TOC order, calls `NS:InitDB()`, then `dofile`s each `test_*.lua`, runs each test under `pcall`, prints `PASS`/`FAIL`, and `os.exit(failed == 0 and 0 or 1)`.
- **`loader.lua`** loads each source with `loadfile`, then `setfenv(chunk, makeEnv(mocks))` so WoW globals resolve to the mock table first (falling back to real `_G`), and calls each chunk as `chunk(addonName, NS)` — reproducing the `local addonName, NS = ...` header.
- **`wow_mock.lua`** returns a **builder** (a fresh env per run). It stubs time/player/world APIs and a **universal self-returning no-op frame** (`setmetatable(f, { __index = function() return function() return f end end })`), plus `CreateFrame`, `UIParent`, `Settings.*`, and `LibStub` with `AceDB-3.0`/`AceAddon-3.0` fakes.
- Suites are plain: `local T = _G.<ADDON>_TEST; local NS = T.NS; local test, assertEqual = T.test, T.assertEqual` then `test("...", function() assertEqual(...) end)`.

### 2. Commands

- **Run unit tests:** `lua tests/run.lua` from the repo root (exits non-zero on failure).
- **Lint:** `luacheck .` — **0 errors** (config in `.luacheckrc`, lint).
- **Syntax-check one file:** `luac -p path/to/file.lua`.

### 3. Local toolchain

WoW runs **Lua 5.1**, so the harness targets 5.1. Install locally:

```sh
sudo apt-get update && sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck
```

### 4. TDD & the commit gate

- **MUST** be test-first: write or extend a **failing** test that pins the intended behavior, then implement until it passes.
- **MUST**, before **every** commit, run **`lua tests/run.lua`** (all suites green) **and** **`luacheck .`** (0 errors). A commit with red tests or lint errors is forbidden.
- **MUST** add/extend a suite whenever a behavior changes — no logic change lands without a covering test.
- Pure/testable logic (schema validation, data collection, attribution, migrations, formatting) **MUST** be exercised headlessly. Genuinely in-client behavior (frame rendering, taint) is covered by the in-game smoke tests (audit-review-history), which complement — not replace — the unit suites.
