> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- **Ka0s-Core sibling addon.** Long-term: extract Schema runtime, AceGUI panel scaffold, slash dispatcher, Compat templates, and the debug-console + test-harness scaffolding into a single `Ka0s-Core` addon (the shared-engine model bag-replacement addons use). Out of scope for now.
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- **Shared test scaffolding.** A copyable `tests/` skeleton (runner + WoW mocks) so new addons inherit the harness.
- **Multi-zone profile model adoption** for group-context addons.
- **Object pool standard** packaged as a copyable micro-lib.
- **Further `LibKa0s` modules.** `LibKa0s` is now the sanctioned path for shared Ka0s-owned code (library-stack-§7), and its per-module-major layout makes each addition independent and purely additive. Candidates the collection duplicates today: the `Compat` shim, the debug console, the message bus, the headless test harness, and the object pool. Each is its own decision, adopted on its own schedule — deliberately **not** a lockstep migration, and deliberately not a `Ka0s-Core` addon (library-stack-§6 forbids requiring another addon).
- **A per-addon adoption command.** Rolling the performance harness (performance) into the remaining addons is mechanical enough to script — vendor the lib, write the descriptor, wire the reserved verb, declare the SV global, add the integration suite — and repetitive enough that hand-rolling it five times will produce five subtly different wirings. A `wow-addon` plugin command for it would keep them identical.
