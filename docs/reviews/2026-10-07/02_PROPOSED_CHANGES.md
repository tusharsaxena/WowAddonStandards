# Proposed changes: WowAddonStandards (2026-10-07)

**Standard resolved:** v2.76.1 (2026-10-07). It was read from the local checkout at `f472389`, which equals `origin/master`. A `curl` of `raw.githubusercontent.com` hung, so the guardrail was checked against the identical published text on disk, not against a fresh fetch.

Every change below is a documentation edit inside this repo, except C-03, which adds one shell script. None targets `harvests/` or `standards/_raw/`, which are frozen. This repo vendors nothing, so there is no `[upstream]` change-set. Two changes need a matching edit in the **dev-copilot** repo, which is a separate repo the owner controls and not vendored code. That handoff is listed separately below.

---

## HLD: themes

### Theme A: The standard follows its own line-endings rule, and every copy of the rule says the same thing (F-001, F-002)

**Rationale.** `line-endings` exists because one edit to a rule failed to reach every copy. That is now happening inside the document that publishes the rule. Two parts:
1. Make this repo's `.gitattributes` the §5 LF body byte for byte.
2. Change the seven restatements so they **cite** the carve-out set, rather than listing it on their own:
   - five that list only `*.sh` (`documentation-§8`, `library-stack-§7`, `NEW_ADDON.md`, `NEW_ADDON_CONTEXT.md`'s checklist, `CLAUDE.md`)
   - two that describe it (`EXECUTIVE_SUMMARY.md`, `automated-tests`)

**Alternatives rejected:**
- **Fix only `.gitattributes`.** This leaves the cause in place. The next widening of §3 (a third interpreter) would repeat F-002.
- **Delete the restatements.** `documentation-§8` and `library-stack-§7` are applicability tables that need a row for `line-endings`. Their job is to say *that* it binds and *which pin*, not to restate the body.

**Trade-off:** A row that names "both shebang carve-outs (`*.sh`, `*.py`) of line-endings-§3" is still a list. But it is a list next to its source, and the C-03 check holds it to §3.

### Theme B: Slim the index that every consumer must read (F-003)

**Rationale.** `STANDARDS.md` is the one file tools hard-code. 92% of its bytes are history the tools never need, and it grows with every release. Moving the history out means every audit, review and scaffold run reads only what binds.

**Proposal:**
- Move `## Changelog` into a sibling `standards/CHANGELOG.md`.
- Keep in the index only a one-line pointer and the **current** version's entry.
- Link the history file under *Related documents*, not under *Sections*, so tools following the Sections list never fetch it.

**Alternatives considered:**
1. **Keep the changelog in the index but cap entries at a summary plus a commit link.** This is smaller, but the index still grows by one entry every release. Rejected as the main fix. It is still worth doing as a house style for new entries.
2. **Drop the changelog and rely on git log.** Rejected. CLAUDE.md and `wow-harvest-standards` treat the changelog as the argued, evidence-carrying record of each amendment, which commit subjects are not.
3. **Name it `standards/changelog.md`** to keep clear of the addon-root `CHANGELOG.md` ban (`documentation-§1/§3`). That ban binds an **addon root** only, and `standards/` is not a root. Either name complies. Owner's call.

**Trade-offs and risk:** This is a **process change**, so it is a minor bump. It needs a dev-copilot ripple:
- `commands/wow-harvest-standards.md:152` writes "The changelog entry at the top of `STANDARDS.md`".
- `agents/wow-standards-audit.md:108` describes the index as carrying the changelog.

It must not land until those two lines move with it.

### Theme C: A mechanical integrity check for a documents-only repo (F-004; would have caught F-001, F-002, F-005 to F-007 and F-012)

**Rationale.** `docs/ARCHITECTURE.md` lists *No mechanical gate* and *Cross-references are unenforced* as accepted limitations. Today's run shows each check those limitations name runs in about a second with git, grep and awk. The drift they let through is real and repeats.

**Proposal:** Add `scripts/check-standard.sh`, run on demand and **not** wired as a hook (see below). It does six things, each printing failures and exiting non-zero:
1. No CR in any tracked file.
2. `.gitattributes` equals the §5 LF body extracted from `line-endings.md`.
3. Every `filename-§N` outside `harvests/` and `standards/_raw/` names an existing file and an existing `### N.`.
4. The Sections list in `STANDARDS.md` equals `git ls-files 'standards/standards/*.md'`.
5. Anti-patterns are numbered 1..N contiguously, and N equals the index's `(#1–#N)`.
6. The version stamp in `STANDARDS.md:1` appears in `README.md`'s Status line, `EXECUTIVE_SUMMARY.md`, `NEW_ADDON_CONTEXT.md:1` and `CLAUDE.md`'s "As of" line.

**Alternatives rejected:**
- **A pre-commit hook.** CLAUDE.md's *two checkpoints* rule says a commit is gated on lint and the harness only, and that a threshold on every commit gets routed around with `--no-verify`. The script is a tool a maintainer and `sync-docs` run, not a gate.
- **Putting the checks in dev-copilot's `sync-docs` profile.** These are invariants of *this* repo's own files. Their home is this repo, the way an addon's tests live in the addon. A dev-copilot hook may call the script later.
- **Python.** It would add an interpreter row to `DEPENDENCIES.md` for no gain over awk.

**Trade-off:** `DEPENDENCIES.md`'s required list gains `bash` and coreutils/grep/awk, which is evidence-based per `documentation-§7`. "There is no … test runner" becomes untrue and is rewritten. `documentation-§8`'s re-check trigger is "the first `.lua`", so a `.sh` does not trigger `lint`/`testing`.

### Theme D: Small doc corrections (F-005 to F-007, F-009, F-010, F-012)

These are one-line truth fixes, plus one structural choice. Instead of bumping the index footer's date a seventh time, F-007 removes the footer's own date, so a release has five stamps to bump instead of six.

### Theme E: Harden the playbook's working-tree command (F-008)

Pass each path to `sh -c` as a positional argument instead of splicing it into the script text.

---

## Upstream change-set

**None.** This repo vendors nothing. The dev-copilot edits that Theme B needs are a **cross-repo handoff** (H-01), not an `[upstream]` re-vendor.

| ID | Repo | File | Change | Exit |
|---|---|---|---|---|
| H-01 | dev-copilot | `commands/wow-harvest-standards.md:152`, `agents/wow-standards-audit.md:108` | Point the changelog step at `standards/CHANGELOG.md` and stop describing the index as carrying the changelog | dev-copilot commit landed before or with C-02 |

---

## LLD: change-set

### C-01: Self-compliance and the carve-out set (F-001, F-002)

- **`.gitattributes`:** Replace the whole file with `line-endings.md:255-339`, verbatim. Before: lines 30-36 hold the six-line "Shell scripts are LF, ALWAYS" comment, then `*.sh text eol=lf`. After: the eight-line "A file with a shebang is LF, ALWAYS" comment, then `*.sh text eol=lf` and `*.py text eol=lf`. Run `git add --renormalize .` afterwards. It must stage nothing, since there are no CRs today.
- **`standards/standards/documentation.md:675`** (`line-endings` row of §8):
  - Before: "the `*.sh text eol=lf` carve-out mandatory in both kinds"
  - After: "both of `line-endings-§3`'s shebang carve-outs (`*.sh`, `*.py`), mandatory in both kinds"
- **`standards/standards/library-stack.md:221`:**
  - Before: "plus the `*.sh text eol=lf` carve-out for its own `testkit/run-automated-tests.sh`"
  - After: "plus `line-endings-§3`'s shebang carve-outs (`*.sh`, `*.py`), the first protecting its own `testkit/run-automated-tests.sh`"
- **`standards/standards/automated-tests.md:60-64`:** Keep the MUST about `*.sh` (it is this section's runner). Add one sentence: "§3 requires `*.py` alongside it, and the body in `line-endings-§5` carries both."
- **`NEW_ADDON.md:20`, `standards/NEW_ADDON_CONTEXT.md:1622`, `standards/EXECUTIVE_SUMMARY.md:52`:** Name both carve-outs, in the same wording as the documentation-§8 row.
- **`CLAUDE.md:122-124`:** "`* text=auto eol=lf`, the `*.sh` and `*.py` shebang carve-outs (`line-endings-§3`), binaries marked `binary` — byte-identical to `line-endings-§5`'s non-client body".
- **Version:** Patch bump to **v2.76.2**, since this corrects copies of an existing MUST. Changelog entry, plus header, README Status, EXECUTIVE_SUMMARY, NEW_ADDON_CONTEXT and CLAUDE.md "As of" stamps.
- **Risk:** Low. No consumer reads these rows mechanically. Audits of LibKa0s and dev-copilot are unaffected, because both already carry `*.py`.

### C-02: Move the changelog out of the index (F-003), *owner decision required*

- **New `standards/CHANGELOG.md`:** A header line, then `STANDARDS.md:99-253` moved verbatim. Keep entry text unchanged. This is a move, not a rewrite.
- **`standards/STANDARDS.md`:** Replace `## Changelog` with a short section holding the current version's entry and the line "Full history: [`CHANGELOG.md`](CHANGELOG.md)". Add the file to *Related documents*. Do **not** add it to Sections (Sections are normative, and tools follow them).
- **`CLAUDE.md`** *Conventions* ("adds a changelog entry first in its `## Changelog` section"), **`standards/README.md`**, **`README.md`** section A step 4, and **`docs/ARCHITECTURE.md`**'s Module Map and Documentation map: point at the new file.
- **Version:** Minor bump to **v2.77.0**, because it changes the amendment process.
- **Expected movement:** The index should drop from 418,659 bytes to about 36 KB. Measure with `wc -c standards/STANDARDS.md` before and after.
- **Risk:** Medium. An old plugin build that still writes the entry into `STANDARDS.md` would recreate the section. That is why H-01 must land first.

### C-03: `scripts/check-standard.sh` (F-004)

```sh
#!/usr/bin/env bash
# check-standard.sh — the mechanical invariants of WowAddonStandards. On demand; not a hook.
set -u; fail=0; say(){ printf '%s\n' "$*"; fail=1; }
cd "$(git rev-parse --show-toplevel)"
# 1. no CR in any tracked file
git grep -Il $'\r' -- . && say "CR found (line-endings-§2)"
# 2. .gitattributes == line-endings-§5 non-client body (the 2nd column-0 gitattributes fence)
body=$(awk '/^```gitattributes/{n++;f=(n==2);next} /^```/{f=0} f' standards/standards/line-endings.md)
[ "$body" = "$(cat .gitattributes)" ] || say ".gitattributes differs from line-endings-§5 (non-client)"
# 3..6: xref range, Sections map, anti-pattern contiguity, version stamps (awk; see 03)
exit $fail
```

The fence index was checked today. §3's example is indented, so `^```gitattributes` matches only §5's two bodies (`line-endings.md:165` CRLF, `:254` LF). `n==2` reproduces dev-copilot's `.gitattributes` exactly.

- **`DEPENDENCIES.md`:** Required gains bash ≥ 4 and coreutils/grep/awk, with a Verify column. Replace "no test runner" with "one on-demand check script". Add `bash scripts/check-standard.sh` to *Verifying your setup*.
- **`docs/ARCHITECTURE.md:54-60`:** Rewrite both limitations to say what the script now catches and what it still cannot catch (semantic contradictions, wrong-but-in-range citations like F-006). Add the script to the Module Map.
- **`CLAUDE.md`:** Under *Editing rules*: "run `bash scripts/check-standard.sh` before committing a change to the standard".
- **Standards conformance:**
  - The file is `*.sh`, which is LF via the carve-out (`line-endings-§3`).
  - It is not a commit gate (CLAUDE.md *two checkpoints*).
  - It is not `.lua`, so `documentation-§8`'s re-check trigger does not fire.
- **Version:** Patch to v2.76.x. It is repo tooling, not a rule change. Changelog entry.

### C-04: Doc-truth fixes (F-005, F-006, F-007, F-009, F-010, F-012)

| Finding | File:line | Before | After |
|---|---|---|---|
| F-005 | `standards/NEW_ADDON_CONTEXT.md:1072` | "A suite named here but missing from disk is SKIPPED, not failed." | Move the sentence to the `Kit.run{ … suites = … }` line and correct it: "A suite named in `suites` but missing from disk RAISES (testing-§9); declare one still being written as `{ name = …, pending = "why" }`." |
| F-006 | `standards/standards/library-stack.md:223` | "\| documentation-§5 \| The `filename-§N` citation scheme and documentation-§6's citation rules. \|" | Two rows: "\| documentation-§5 \| Keeping docs in sync. \|" and "\| documentation-§6 \| The `filename-§N` citation scheme and its citation rules. \|" |
| F-006 | `AUDIT.md:994` | "(documentation-§5/§6 — …" | "(documentation-§6 — …" |
| F-007 | `standards/STANDARDS.md:255` | "Authoritative as of 2026-10-01; bump on amendment." | "Authoritative as of the version and date in this file's title." Then remove "this file's trailing *Authoritative as of* line" from the stamp checklists wherever it is listed. |
| F-009 | `standards/standards/testing.md:292` | "This is what LibKa0s test-kit revision 24 ships today" | "LibKa0s test-kit revision 24 and later ship this" |
| F-009 | `standards/standards/testing.md:20`, `standards/NEW_ADDON_CONTEXT.md:1019` | "_kit/ -- vendored, never edited: framework.lua, loader.lua, mock_base.lua, README.md" | "_kit/ -- vendored whole from LibKa0s testkit/, never edited (framework.lua, loader.lua, mock_base.lua, … — the folder, not a list)" |
| F-010 | `standards/EXECUTIVE_SUMMARY.md:3` | "**One-page TL;DR of the standard.**" | "**The short version of the standard.**" Trimming the summary is a separate, optional editorial pass and is deferred. |
| F-012 | `standards/STANDARDS.md:120` (moves to `CHANGELOG.md` if C-02 lands first) | "`preview-mode-§`'s" | "`preview-mode`'s" |

- **Version:** These fold into C-01's v2.76.2 entry.
- **Risk:** Very low.

### C-05: Positional-argument form of check (e) (F-008)

In `AUDIT.md:184-189` **and** `standards/standards/line-endings.md:486-491`, both copies in the same change:

```sh
git ls-files -z | xargs -0 -n1 sh -c '
  f=$1
  set -- $(git check-attr text eol -- "$f" | sed "s/.*: //")
  [ "$1" = unset ] && exit                      # binary: git converts nothing here
  cr=$(tr -dc "\r" < "$f" | wc -c); lf=$(tr -dc "\n" < "$f" | wc -c)
  case "$2" in crlf) [ "$lf" -gt 0 ] && [ "$cr" -ne "$lf" ] && printf "%s\n" "$f";;
               lf)   [ "$cr" -gt 0 ] && printf "%s\n" "$f";; esac' _ 2>/dev/null | wc -l
```

This was verified in scratch:
- A file named `a";touch PWNED;"b.md` no longer runs anything.
- A CRLF file `it's.md` is now detected.
- AbsorbTracker still reports `0`, the same as the old form.

The kit's `tests/_kit/test_eol.lua` is not touched. That gate belongs to the library.

### C-06: ADDONS.md Folder links (F-011), *optional*

Change the Folder column from markdown links to plain code spans (`` `../../AbsorbTracker/` ``). That keeps the local-path information without publishing 13 dead links. The adjacent Repository column already links GitHub.

---

## Standards conformance

| Change | Conformance |
|---|---|
| C-01 | Brings the repo **into** `line-endings-§3/§5`. The edited rows still cite their source per `documentation-§6`. US English per `localization-§5`. |
| C-02 | No addon rule binds a `standards/` subfile name. `documentation-§1/§3`'s CHANGELOG ban is an addon-root rule. The index keeps its name and its Sections list, as `STANDARDS.md:15-24` requires for tools. |
| C-03 | Not a commit gate, per CLAUDE.md *two checkpoints*. LF shebang file, per `line-endings-§3`. `DEPENDENCIES.md` rows are evidence-based, per `documentation-§7/§8`. |
| C-04 | Each edit restores agreement with the section it describes. No rule changes. |
| C-05 | Same command semantics. `line-endings-§7` (count bytes, ask git for `text` and `eol`) is unchanged. |
| C-06 | Cosmetic. The roster stays the single source of truth (`standards/ADDONS.md`). |

No change moves a test count, coverage figure or badge. This repo has none.
