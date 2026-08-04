> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- ~~**Ka0s-Core sibling addon.**~~ **Settled, and settled the other way.** The AceGUI panel scaffold, the slash dispatcher, the debug console and the test-harness scaffolding are all extracted — as `LibKa0s-Options-1.0`, `LibKa0s-Slash-1.0`, `LibKa0s-DebugLog-1.0` and the shared `testkit/`, on top of `LibKa0s-Core-1.0`. They are a **vendored library**, not a sibling addon, because library-stack-§6 forbids requiring another addon to be installed. What remains open is the Schema runtime and the Compat templates.
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- ~~**Shared test scaffolding.**~~ **Shipped** as `testkit/` in the LibKa0s repo, vendored to each addon's `tests/_kit/` — the framework, the sandboxed loader and the universal WoW/Ace mock base (testing-§1).
- **Multi-zone profile model adoption** for group-context addons.
- **Object pool standard** packaged as a copyable micro-lib.
- **Further `LibKa0s` modules.** `LibKa0s` is now the sanctioned path for shared Ka0s-owned code (library-stack-§7), and its per-module-major layout makes each addition independent and purely additive. Shipped so far: the secret-safe/printer seams (Core), the debug console, the slash dispatcher, the options toolkit and the perf harness — five majors across eight files. Candidates the collection still duplicates: the `Compat` shim, the message bus, the Schema runtime, and the object pool. Each is its own decision, adopted on its own schedule — deliberately **not** a lockstep migration, and deliberately not a `Ka0s-Core` addon (library-stack-§6 forbids requiring another addon).
- **A per-addon adoption command.** Still open, and now broader than when it was written: adoption spans five majors rather than one, and the four newer ones **delete files the addon owns** rather than only adding a descriptor — which is harder to script safely and more valuable to keep identical across addons. `LibKa0s/docs/adoption-prompt.md` carries the per-addon survey and hazards in the meantime.
- **Migration-stamp ownership.** The collection holds **five incompatible schema-migration variants**
  across eight repos, disagreeing on who writes `schemaVersion` (the runner, or each step), whether it
  is stamped per step or once at the end, whether a failed step still stamps, and what a missing step
  does. `savedvariables-§1` shows one shape and mandates none of this. The divergence is why a shared
  runner was rejected (library-stack-§7, anti-patterns #55) — but the right resolution is a **ruling
  here**, then convergence, rather than a library that hatches around the disagreement. It needs a
  decision on one genuinely hard case first: AceDB's defaults merge backfills `schemaVersion` to
  current the moment `db.global` is first read, so a version stamp cannot by itself distinguish a fresh
  install from a legacy account, and at least one addon runs its fold shape-driven and unconditionally
  for exactly that reason.
- **A collapsed-group key convention.** Two addons independently key a table's collapsed-group state as
  `mode .. "\001" .. rawValue`. It is load-bearing — changing the format silently resets every user's
  collapsed groups — and is currently written down nowhere. Too small to be a library (it is one
  concatenation); the right home is a naming/convention line, if a third addon grows grouped tables.
