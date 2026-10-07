> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Versioning & git workflow

- **MUST** use semver (`MAJOR.MINOR.PATCH`). MAJOR for backwards-incompatible API or SV changes; MINOR for new features; PATCH for fixes only.
- **MUST** bump in TOC `## Version:`, and in any code constants and README badges/Version History tables. The `dev-copilot:bump-version` skill automates this.
- **MUST** bump the single TOC `## Interface:` (and the matching README `[wow]` badge) each Retail patch via `dev-copilot:wow-bump-interface` (toc-file-§3).
- **MUST** add a runner step and raise `NS.SCHEMA_VERSION` whenever a SV migration is required; the defaults value stays `0` (savedvariables-§1).
- **A vendored Ka0s-owned library's file minors are a separate versioning axis** from the addon's semver and **MUST NOT** be conflated with it (library-stack-§7). The addon's `## Version:` describes the addon; a vendored lib file's LibStub **MINOR** is what LibStub compares when choosing between copies at load. Bumping the addon does not bump the lib, and a lib change does not bump the addon — but a lib change **MUST** produce a **re-vendor commit** in every consuming addon, and that commit **SHOULD** stand alone so the sync is legible in history.

**Git workflow**

- **MUST** land work on the repo's default branch by default. Two cases go on a feature branch instead: a changeset the owner directs to be isolated (e.g. a risky spike), and a changeset that spans several repos. That branch **MUST** be named `feat/<YYYY-MM-DD>-<topic>`, with the **same** name in every repo the changeset touches, **MUST** be merged into the default branch with `--no-ff` so the changeset stays legible as one unit, and is then deleted, together with any worktree or stash the run created. Do **NOT** create a feature/topic branch for routine single-repo work the owner did not direct to be isolated. Merging, tagging, pushing and releasing keep their owner go-ahead gates below.
- **MUST NOT** push to a remote unless the human asks; the human pushes when ready. The sanctioned case is pushing a feature branch at a checkpoint the owner authorized. **MUST NOT** merge a feature branch, push a tag or cut a release without the owner's go-ahead.
- **MUST** commit only on a **green** unit of work — `lua tests/run.lua` passing and `luacheck .` clean (testing) — not at every checkpoint.
