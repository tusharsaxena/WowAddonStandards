# Execution plan: WowAddonStandards (2026-10-07)

Covers F-001 to F-012 through C-01 to C-06 and handoff H-01. There is no `[upstream]` milestone, because this repo vendors nothing. H-01 is a cross-repo handoff to dev-copilot, which the owner controls.

Branch: `feat/2026-10-07-review-audit-remediation`. This is the collection-wide branch, and the repo is already on it. Commit only when the owner authorizes it. Never merge into `master` without the owner's go-ahead (`Ka0sAddonsCommonTasks/CLAUDE.md`).

## Milestones

### M1: Truth fixes and self-compliance (patch, v2.76.2)

**Done when:**
- C-01, C-04 and C-05 have landed.
- The C-01, C-04 and C-05 checks in `03_SMOKE_TESTS.md` pass.
- The standard header, README Status, EXECUTIVE_SUMMARY, NEW_ADDON_CONTEXT and CLAUDE.md "As of" all read v2.76.2.

| Task | Role | Implements | Files |
|---|---|---|---|
| M1-T1 | standards-editor | C-01 (F-001) | `.gitattributes` |
| M1-T2 | standards-editor | C-01 (F-002) | `standards/standards/documentation.md`, `standards/standards/library-stack.md`, `standards/standards/automated-tests.md`, `NEW_ADDON.md`, `standards/NEW_ADDON_CONTEXT.md`, `standards/EXECUTIVE_SUMMARY.md`, `CLAUDE.md` |
| M1-T3 | standards-editor | C-04 (F-005, F-006, F-007, F-009, F-010, F-012) | `standards/NEW_ADDON_CONTEXT.md`, `standards/standards/library-stack.md`, `AUDIT.md`, `standards/STANDARDS.md`, `standards/standards/testing.md`, `standards/EXECUTIVE_SUMMARY.md` |
| M1-T4 | playbook-editor | C-05 (F-008) | `AUDIT.md`, `standards/standards/line-endings.md` |
| M1-T5 | standards-editor | version stamps + changelog entry | `standards/STANDARDS.md`, `README.md`, `standards/EXECUTIVE_SUMMARY.md`, `standards/NEW_ADDON_CONTEXT.md`, `CLAUDE.md` |

**Checkpoint CP-1:** The owner reviews the v2.76.2 diff, since it changes the published standard text. Then push, if authorized.

### M2: Integrity check script (patch, v2.76.3)

**Done when:**
- `scripts/check-standard.sh` exits 0 on the tree.
- Each of the four injected defects in 03/C-03 turns it red.
- `DEPENDENCIES.md` and `docs/ARCHITECTURE.md` describe it.

| Task | Role | Implements | Files |
|---|---|---|---|
| M2-T1 | tooling-author | C-03 (F-004) | `scripts/check-standard.sh` (new) |
| M2-T2 | standards-editor | C-03 docs | `DEPENDENCIES.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md`, `README.md` (layout block) |
| M2-T3 | standards-editor | stamps + changelog | `standards/STANDARDS.md`, `README.md`, `standards/EXECUTIVE_SUMMARY.md`, `standards/NEW_ADDON_CONTEXT.md`, `CLAUDE.md` |

**Checkpoint CP-2:** Run the script. Its first run is retroactive evidence that M1 closed everything it can see.

### M3: Changelog out of the index (minor, v2.77.0). **Owner decision required (F-003)**

**Done when:**
- H-01 has landed in dev-copilot.
- C-02 has landed.
- 03/C-02 and L-2 pass.

| Task | Role | Implements | Files |
|---|---|---|---|
| M3-T0 | plugin-editor (**dev-copilot repo**) | H-01 | `../dev-copilot/commands/wow-harvest-standards.md`, `../dev-copilot/agents/wow-standards-audit.md` |
| M3-T1 | standards-editor | C-02 | `standards/STANDARDS.md`, `standards/CHANGELOG.md` (new), `CLAUDE.md`, `README.md`, `standards/README.md`, `docs/ARCHITECTURE.md`, `DEPENDENCIES.md` (file count) |

**Checkpoint CP-3:** The owner runs L-2 in one addon before M3 is pushed.

### M4: Optional cosmetic

| Task | Role | Implements | Files |
|---|---|---|---|
| M4-T1 | standards-editor | C-06 (F-011) | `standards/ADDONS.md` |

## Critical path and concurrency

- **Must serialize:**
  - `standards/STANDARDS.md` is touched by M1-T3, M1-T5, M2-T3 and M3-T1.
  - `CLAUDE.md` is touched by M1-T2, M1-T5, M2-T2, M2-T3 and M3-T1.
  - `standards/EXECUTIVE_SUMMARY.md` and `standards/NEW_ADDON_CONTEXT.md` are touched by M1-T2, M1-T3 and every stamp task.
  - `standards/standards/library-stack.md` is touched by M1-T2 and M1-T3.
  - `AUDIT.md` is touched by M1-T3 and M1-T4.
- **Parallelizable:**
  - M1-T1 (`.gitattributes` only).
  - M1-T4's `line-endings.md` edit, which is disjoint from M1-T2.
  - M2-T1 (a new file).
  - M3-T0, which is in another repo and can start any time. M3-T1 waits for it.
  - M4-T1.
- **Ordering:**
  - M1 comes before M2, because the script's first green run must be over a fixed tree.
  - M3 comes after M2, so the script's stamp check learns where the changelog lives once.
  - H-01 comes before C-02.

## Commits

One commit per task. Subjects are prefixed `<ID>: ` so `resume-state.sh`-style tooling can find them.

- `WAS-01: .gitattributes is line-endings-§5's non-client body (adds *.py)` (M1-T1)
- `WAS-02: restatements name both line-endings-§3 carve-outs` (M1-T2)
- `WAS-03: doc-truth fixes — scaffold suite comment, documentation-§5/§6 cite, footer date, kit tree, TL;DR, malformed ref` (M1-T3)
- `WAS-04: check (e) passes the path as an argument, not script text` (M1-T4)
- `WAS-05: v2.76.2` (M1-T5)
- `WAS-06: scripts/check-standard.sh` + `WAS-07: document it` + `WAS-08: v2.76.3`
- `DC-xx: harvest and audit point at standards/CHANGELOG.md` (dev-copilot, M3-T0)
- `WAS-09: the changelog leaves the index (v2.77.0)` (M3-T1)
- `WAS-10: roster Folder column is plain text` (M4-T1)

Every message ends with the session's attribution trailers.
