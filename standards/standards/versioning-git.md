> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Versioning & git workflow

- **MUST** use semver (`MAJOR.MINOR.PATCH`). MAJOR for backwards-incompatible API or SV changes; MINOR for new features; PATCH for fixes only.
- **MUST** bump in TOC `## Version:`, and in any code constants and README badges/Version History tables. The `wow-addon:bump-version` skill automates this.
- **MUST** bump the single TOC `## Interface:` (and the matching README `[wow]` badge) each Retail patch via `wow-addon:bump-interface` (toc-file-§3).
- **MUST** increment `schemaVersion` (in defaults) whenever a SV migration is required.

**Git workflow**

- **MUST** work trunk-based: commit directly to the addon's default branch. Do **NOT** create feature/topic branches for routine work — branch **only** when the human explicitly asks (e.g. a risky spike needing isolation).
- **MUST NOT** push to a remote unless the human asks; the human pushes when ready.
- **MUST** commit only on a **green** unit of work — `lua tests/run.lua` passing and `luacheck .` clean (testing) — not at every checkpoint.
