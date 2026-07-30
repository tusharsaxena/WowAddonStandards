> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- **Ka0s-Core sibling addon.** Long-term: extract Schema runtime, AceGUI panel scaffold, slash dispatcher, Compat templates, and the debug-console + test-harness scaffolding into a single `Ka0s-Core` addon (the shared-engine model bag-replacement addons use). Out of scope for now.
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- **Shared test scaffolding.** A copyable `tests/` skeleton (runner + WoW mocks) so new addons inherit the harness.
- **Multi-zone profile model adoption** for group-context addons.
- **Object pool standard** packaged as a copyable micro-lib.
- **Vendor-sync rule for Ka0s-owned libs.** Slated for v2.12.0 with the `LibKa0s` work. `library-stack-§3` says vendor and commit, which is the whole story for a third-party lib — upstream releases, you copy. A Ka0s-owned lib breaks the assumption: the same person edits the library and its consumers the same afternoon, so a consumer's `libs/<Lib>/` can fall behind between two commits with nothing in the green gate noticing. It already happened once during the `LibKa0s-Perf` extraction — a library fix landed, the consumer was not re-vendored, and an after-the-fact `diff -r` was the only thing that caught it. The rule wants: the vendored payload MUST be byte-identical to the source repo's ship folder, a library change MUST be followed by a re-vendor commit in every consumer, and `diff -r <LibRepo>/<Lib> <Addon>/libs/<Lib>` belongs in `AUDIT.md` (arguably each consumer's gate too) so the check is mechanical rather than remembered. Lands in `library-stack`, cross-referenced from `testing` if it becomes a gate step.
