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
- **What `performance-§12`'s re-check trigger should do with a window-bounded ticker.** §12 grants the
  no-combat-path exemption on criterion **(a)** — no `OnUpdate`, no repeating ticker, no event handler
  doing more than occasional work in combat — and its re-check trigger re-arms the **full** wiring MUST
  on *"the first `OnUpdate` handler, repeating ticker, or in-combat event handler doing real work"*.
  Note the asymmetry: *in-combat* qualifies only the event-handler arm. A repeating ticker re-arms the
  wiring unconditionally, however it is gated.

  WhatGroup hit this on 2026-08-06 and it is the first real test of the trigger. A teleport-cooldown
  countdown in its popup needs a 1-second timer; the timer is a single handle, armed only while the
  popup is **both** open and showing a live cooldown, replaced rather than stacked, and cancelled from
  the frame's `OnHide`, from the top of the configure path, and by the tick that reaches zero. Per tick
  it costs one `C_Spell.GetSpellCooldown` and one `SetText`. On the letter of the trigger that ends the
  exemption, so the addon owes a `core/PerfSetup.lua`, a `perf` verb, a second SavedVariables global, a
  suspend/resume contract, a `tests/perf.lua` and a `docs/perf-runs/` store — to account for a timer
  the player starts by opening a window and stops by closing it. Criteria **(b)** and **(c)** did not
  change: the buckets would still read `0.000`, which performance-§3 calls a lie in every report, and
  `suspend` would still make a capture addon miss the capture. Only (a) broke.

  It is recorded there as a **ratified deviation in its own right** rather than resolved locally, which
  is the correct handling under documentation-§3 but is also the tell that the rule needs a ruling: an
  addon meeting the *spirit* of (a) exactly — no hot path, no unbounded work — should not have to carry
  a register row for it. The decision this needs is what the boundary actually is, and it is not
  obvious. *"Gated on a visible frame"* is the intuitive line and is too loose (an addon can keep a
  window open through a raid boss). *"Never runs in combat"* is too strict and unenforceable, since a
  player can open a popup mid-pull. Candidate shape: a ticker at 1Hz or slower, bounded by a frame the
  **player** opened, doing O(1) work per tick, stays inside (a) and is recorded as a one-line note on
  the existing exemption row rather than a new deviation — with the wiring re-armed the moment any of
  those three properties stops holding. Whatever is decided, the trigger should say which of its three
  arms are qualified by combat and which are not, because the current asymmetry reads as an oversight
  and the next reader will not know whether it was one.

- **A collapsed-group key convention.** Two addons independently key a table's collapsed-group state as
  `mode .. "\001" .. rawValue`. It is load-bearing — changing the format silently resets every user's
  collapsed groups — and is currently written down nowhere. Too small to be a library (it is one
  concatenation); the right home is a naming/convention line, if a third addon grows grouped tables.
