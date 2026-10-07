# Final summary: WowAddonStandards review remediation (2026-10-07)

*Written as though `03_SMOKE_TESTS.md` has passed. It is a template for the PR and record, not a claim that the work has been done.*

## Headline

The standard now follows its own line-endings rule. Its `.gitattributes` is the `line-endings-§5` body, and every place that restates the shebang carve-out names both `*.sh` and `*.py`. Several small inaccuracies are fixed:
- a scaffold comment that taught the opposite of `testing-§9`
- a wrong `documentation-§` citation
- a stale footer date
- a "today" that had aged
- a malformed reference

The audit's working-tree command no longer runs file names as shell code. A one-second `scripts/check-standard.sh` now catches this class of drift mechanically. If the owner approves M3, the 418 KB index that every consumer must read loses its 384 KB changelog to a sibling file.

## Counts

Critical fixed: 0, High fixed: 0, Medium fixed: 5 (F-001 to F-005), Low fixed: 7 (F-006 to F-012).

Partly deferred:
- F-010: the summary is renamed, and the editorial trim is deferred.
- F-003: depends on the owner's M3 decision.

## Changes by theme

### A. Line-endings self-compliance (C-01)

- **What changed:** `.gitattributes` replaced with the §5 non-client body. Seven restatements now name both carve-outs.
- **Why it mattered:** This was the only one of 14 repos still drifting, and it is the repo that publishes the rule.
- **IDs:** F-001, F-002.
- **Files:** `.gitattributes`, `standards/standards/documentation.md`, `standards/standards/library-stack.md`, `standards/standards/automated-tests.md`, `NEW_ADDON.md`, `standards/NEW_ADDON_CONTEXT.md`, `standards/EXECUTIVE_SUMMARY.md`, `CLAUDE.md`.

### B. Index slimming (C-02, H-01)

- **What changed:** The changelog moved to `standards/CHANGELOG.md`. The index keeps the current entry and a link.
- **Why it mattered:** Every audit, review and scaffold run was told to read 384 KB of history before any rule.
- **IDs:** F-003.
- **Files:** `standards/STANDARDS.md`, `standards/CHANGELOG.md`, `CLAUDE.md`, `README.md`, `standards/README.md`, `docs/ARCHITECTURE.md`, `DEPENDENCIES.md`, plus two dev-copilot files.

### C. Mechanical integrity check (C-03)

- **What changed:** A new on-demand script checks CR bytes, the §5 body, cross-reference range, the Sections map, anti-pattern numbering and version stamps.
- **Why it mattered:** The repo had no check of any kind, and drift was found only by accident.
- **IDs:** F-004.
- **Files:** `scripts/check-standard.sh`, `DEPENDENCIES.md`, `docs/ARCHITECTURE.md`, `CLAUDE.md`, `README.md`.

### D. Doc-truth fixes (C-04)

- **IDs:** F-005, F-006, F-007, F-009, F-010, F-012.
- **Files:** `standards/NEW_ADDON_CONTEXT.md`, `standards/standards/library-stack.md`, `AUDIT.md`, `standards/STANDARDS.md`, `standards/standards/testing.md`, `standards/EXECUTIVE_SUMMARY.md`.

### E. Playbook command hardening (C-05)

- **IDs:** F-008.
- **Files:** `AUDIT.md`, `standards/standards/line-endings.md`.

## API and behavior changes

- **The standard moves v2.76.1 → v2.76.2 → v2.76.3**, and to v2.77.0 if M3 lands.
- **Changelog location** (M3 only): `standards/STANDARDS.md#changelog` → `standards/CHANGELOG.md`. Consumers that write changelog entries must use the new file (H-01).
- **New file:** `scripts/check-standard.sh`.
- **No rule's meaning changes.** C-01 and C-04 correct copies of existing rules so they match their source.

## Migration notes

None. No addon has to change. Every consumer's `.gitattributes` already carries `*.py`.

## Dependency changes

| Dependency | Old | New | Why |
|---|---|---|---|
| bash, coreutils, grep, awk | not listed | required (on-demand check) | C-03 |

## Test movement

None. This repo has no test count, coverage figure or badge. `DEPENDENCIES.md`'s tracked-file count goes from 67 to 68, or 69 with M3, in the commit that adds each file.

## Known follow-ups

- **F-010:** Trim `EXECUTIVE_SUMMARY.md` back toward a summary. This is editorial and needs the owner's view of what belongs in it.
- **Changelog house style:** Consider capping new entries at a summary plus a commit link (alternative 1 under Theme B in 02).
- **Repo self-audit:** This repo has no `docs/audits/` bundle of its own. That is the `wow-standards-audit` agent's business, not this review's.

## Verification evidence

- `03_SMOKE_TESTS.md` sign-off table, once completed.
- The commit range on `feat/2026-10-07-review-audit-remediation` (WAS-01 to WAS-10), plus the dev-copilot H-01 commit.

## Suggested PR description

```
WowAddonStandards: review remediation 2026-10-07 (v2.76.2 / v2.76.3 [/ v2.77.0])

- F-001/F-002: .gitattributes is line-endings-§5's non-client body; every
  restatement names both §3 carve-outs (*.sh, *.py)
- F-005..F-007, F-009, F-010, F-012: scaffold suite comment matches testing-§9;
  documentation-§6 cited for the citation scheme; footer date removed;
  aged "today" and partial kit tree corrected; malformed ref fixed
- F-008: AUDIT.md / line-endings-§7 check (e) passes the path as an argument
- F-004: scripts/check-standard.sh — on-demand mechanical invariants
- F-003 (owner-approved): changelog moved to standards/CHANGELOG.md (needs dev-copilot H-01)

Review bundle: docs/reviews/2026-10-07/
```
