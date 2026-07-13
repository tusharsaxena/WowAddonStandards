> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- **Ka0s-Core sibling addon.** Long-term: extract Schema runtime, AceGUI panel scaffold, slash dispatcher, Compat templates, and the debug-console + test-harness scaffolding into a single `Ka0s-Core` addon (the shared-engine model bag-replacement addons use). Out of scope for now.
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- **Shared test scaffolding.** A copyable `tests/` skeleton (runner + WoW mocks) so new addons inherit the harness.
- **Multi-zone profile model adoption** for group-context addons.
- **Object pool standard** packaged as a copyable micro-lib.
