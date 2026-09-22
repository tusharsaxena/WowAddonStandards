> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Naming cheatsheet

| Thing | Convention | Example |
|---|---|---|
| Addon folder | PascalCase | `ExampleBar` |
| Subfolders | lowercase | `core/`, `modules/`, `libs/`, `tests/`, `docs/` |
| Media subfolders | lowercase, typed | `media/logos/`, `media/screenshots/` |
| Lua files | PascalCase.lua | `IconGrid.lua` |
| Test suites | `test_<module>.lua` | `test_database.lua` |
| Conformance suites | `test_<rule-subject>.lua` — a suite whose subject is a standard rule rather than a source module; the section that mandates it names the file (testing-§1) | `test_surface_parity.lua`, `test_vendor_sync.lua`, `test_disabled.lua` |
| Namespace upvalue | `NS` (private) | `local addonName, NS = ...` |
| Public API | `_G[addonName].API.v1` | `ExampleBar.API.v1` |
| SavedVariables | `<Addon>DB` | `ExampleBarDB` |
| Diagnostics SV | `<Addon>PerfDB` — the one sanctioned non-AceDB global (savedvariables-§4) | `ExampleBarPerfDB` |
| Perf instance | `NS.Perf`, built from a descriptor in `core/PerfSetup.lua` (performance-§1) | `Perf.Note("paintBar", ms)` |
| Perf buckets | lowerCamelCase, named for the path they time (performance-§3) | `absorbEvent`, `repaintPass`, `paintBar` |
| Ka0s shared lib | `LibKa0s`, one LibStub major per module (library-stack-§7) | `LibStub("LibKa0s-Perf-1.0")` |
| Slash verbs | 2-3 lowercase | `/eb`, `/xb` |
| Bus messages | `Ka0s_<Addon>_<Event>`, declared once as a constant and never typed as a literal at a call site (architecture-§4). `<Event>` is **PascalCase** (MUST) and **SHOULD** name what happened, preferably as a past participle: not `ROSTER_CHANGED`, not `UpdateRoster`. The constant's **key** is SCREAMING_SNAKE, and that casing belongs to the key alone — exactly one addon in the collection diverged by letting it leak into the wire string. The other SCREAMING_SNAKE publisher keeps no constant table at all, so it has nothing to leak: what it misses is the declare-once MUST (architecture-§4), not this row. | `NS.MSG.ROSTER_CHANGED = "Ka0s_ExampleBar_RosterChanged"` |
| Settings key | snake_case dotted path | `display.scale` |
| Locale keys | English source string | `L["Reset all settings"]` |
| English text (everywhere) | **US English** spelling — strings, labels, comments, identifiers, docs; never British (localization-§5) | `L["Bar color"]`, `NS.Util.colorize`, `gray`, `initialize` |
| Module table | `NS.<PascalCase>` | `NS.IconGrid` |
| Chat printer | `NS.Util.print` — never a bare `NS.Print` when AceConsole is embedded into `NS` (its `:Print` mixin clobbers it; architecture-§2, anti-pattern #36) | `NS.Util.print("…")` |
| Root agent stub | `CLAUDE.md` (stub, incl. Standards-compliance section) | documentation-§2 |
| Agent brief (in-repo) | **none** — the root `CLAUDE.md` stub is the only one; the scaffolding pack is fetched at runtime, never stored | documentation-§3, anti-pattern #49 |
| Engineer context | `docs/ARCHITECTURE.md` | documentation-§3 |
| Testing guide | `docs/testing.md` | documentation-§3, testing |
| Smoke-test suite | `docs/smoke-tests.md` | documentation-§3, audit-review-history |
