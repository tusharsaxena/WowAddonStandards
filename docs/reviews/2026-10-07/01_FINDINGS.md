# Review findings: WowAddonStandards (2026-10-07)

**Verdict: minor issues.** Nothing here is wrong at runtime, because this repo ships nothing to the client. The biggest finding is that the standard does not follow its own line-endings rule. Its root `.gitattributes` is the only one of the 14 rotation repos that drifts from the `line-endings-§5` canonical body. The cause is in the documents: seven restatements of the shebang carve-out still name only `*.sh`.

**Resolved scope:** `all`. The whole repository at `f472389` (branch `feat/2026-10-07-review-audit-remediation`, equal to `origin/master`, clean tree): 67 tracked files, 63 of them Markdown. Profile `wow`, kind `standards`. Frozen material (`harvests/`, `standards/_raw/_industry/`) was read but is never proposed for edits.

## Measurement run

All commands were run from the repo root unless marked *(GIT/)*, which means the parent directory that holds the siblings. Output went to scratch only. Nothing in the repo was written apart from this bundle.

| Suite | Result | Command / scope |
|---|---|---|
| luacheck | **not applicable**: no `.luacheckrc`, 0 tracked `.lua` | `git ls-files '*.lua' \| wc -l` → `0` |
| Headless test suite | **not applicable**: no `tests/run.lua` | n/a |
| `--list` inventory / `docs/test-cases.md` | **not applicable** | n/a |
| `tests/perf.lua` | **not applicable** | n/a |
| Complexity (sighted runner) | **not applicable**: no Lua and no `tests/_kit/` | n/a |
| `make test` | **not applicable**: no `Makefile` | n/a |
| Vendor sync | **not applicable**: this repo vendors nothing | n/a |
| Line endings (DEPENDENCIES.md's own check) | **pass**: no tracked file carries a CR | `git grep -Il $'\r' -- .` → exit 1; `git check-attr text eol -- README.md` → `auto` / `lf` |
| `.gitattributes` vs `line-endings-§5` LF body | **fail**: the shell-scripts comment and the `*.py` line differ (F-001) | `diff <(sed -n 255,339p standards/standards/line-endings.md) .gitattributes` |
| Same check in the other repos (context for F-001) | AbsorbTracker matches the CRLF body after CR is stripped; dev-copilot matches the LF body | *(GIT/)* `diff <(sed -n 166,249p …/line-endings.md) <(tr -d '\r' < AbsorbTracker/.gitattributes)`; same with lines 255–339 against `dev-copilot/.gitattributes` |
| Cross-reference range (`filename-§N`) | **pass in living docs**. 4 out-of-range refs, all in frozen `harvests/2026-09-22/` (`compat-§1` ×2, `packaging-§28`, `packaging-§29`). Frozen bundles are never edited, so these are recorded, not findings | scratch `xref.py` over `git ls-files '*.md'`, subsection set = `^### N.` per file |
| Relative links | 28 hits (27 unique) over `git ls-files '*.md'` minus `_raw/`. 14 in `standards/ADDONS.md` (13 sibling folders, F-011, plus the `../` self row, which resolves). 12 are `…` placeholders in prose examples. 1 is in a frozen harvest. 1 is a template anchor in an addon-README example. None is a broken link inside the repo | scratch `links.py` |
| Sections map vs files | **pass**: 27 = 27 | Sections list in `standards/STANDARDS.md` vs `git ls-files 'standards/standards/*.md'` |
| Anti-pattern numbering | **pass**: 1..92 contiguous, matching the index's `(#1–#92)` | `grep -oE '^[0-9]+\.' standards/standards/anti-patterns.md` |
| Context-pack `LIB_FILES` vs `LibKa0s.xml` | **pass**: 34 = 34, same order | `NEW_ADDON_CONTEXT.md:1049-1074` vs `../LibKa0s/LibKa0s/LibKa0s.xml` at v1.70.0 |
| library-stack-§7 recount | **pass**: 15 majors, 34 `.lua` files | *(../LibKa0s)* `git ls-files 'LibKa0s/*.lua' \| wc -l` → 34; MAJOR/MINOR grep → 15 |
| Kit/library paths named in docs | **pass**: all 8 `tests/_kit/*` paths exist in `../LibKa0s/testkit/` | `git grep -ohE 'tests/_kit/[A-Za-z0-9_.-]+\.(lua\|sh\|py)'` |
| US English | **pass**: every British-spelling hit is a quoted example or a word list | `git grep -niwE 'colour\|grey\|behaviour\|…' -- ':!standards/_raw' ':!harvests'` |
| Cross-addon pass (4 classes) | **pass, 4/4 clean** at LibKa0s `v1.70.0`. (1) 22 roots across 11 addons, 0 duplicates, 0 raw `SLASH_*` in TOC-loaded source. (2) one minors line: `Bus:2 Compat:1 Core:10 DebugLog:19 Env:1 Item:2 Launcher:5 Lifecycle:3 Media:4 Options:28 Perf:14 Pool:3 Schema:2 Slash:19 Widgets:12`. (3) 0 `diff -rq` lines against AbsorbTracker's copy (159 files). (4) `## Interface: 120100`, uniform. The brief's recorded baseline (v1.56.0) is a stale brief, not drift | *(GIT/)* the four loops from the review overlay, scoped to each TOC's load list. Seven sibling working trees had 2 uncommitted files each and were measured as found |
| Standard fetch for the guardrail | **degraded**: `curl` of `raw.githubusercontent.com` hung. The local checkout was used instead. It is the published one: `HEAD` = `origin/master` = `f472389`, v2.76.1 | `git rev-parse HEAD origin/master` |

**Committed artifacts that disagree with today's run:**

- `standards/STANDARDS.md:255`: "Authoritative as of 2026-10-01". The header says `v2.76.1, 2026-10-07` (F-007).
- `.gitattributes:6`: "Everything after it is byte-identical across the collection". It isn't (F-001).
- `DEPENDENCIES.md`: "67 tracked files: 63 Markdown plus …" matches `git ls-files | wc -l` → 67 and `git ls-files '*.md' | wc -l` → 63.

---

## Medium

### F-001: The standard's own `.gitattributes` breaks `line-endings-§3` and `§5` `[line-endings]`

- **Where:**
  - `.gitattributes:30-36`, which carries the old six-line comment `# Shell scripts are LF, ALWAYS — …` followed by `*.sh text eol=lf`, and no `*.py text eol=lf`.
  - `.gitattributes:6`, which claims "Everything after it is byte-identical across the collection".
- **Problem:** The file is not byte-identical to `line-endings-§5`'s non-client body (`line-endings.md:255-339`). That body has the eight-line "A file with a shebang is LF, ALWAYS" comment and `*.py text eol=lf` at line 293. `line-endings-§3` (`line-endings.md:100-107`) MUSTs `*.py` "including the LF-pinned repos". The rule was added in v2.61.0 (`16aa3de`, 2026-09-20). This file was last touched on 2026-08-07 (`6934abf`).
- **Impact:**
  - There is no runtime effect, because the LF pin already makes any future `.py` LF.
  - It is the one repo of the 14 that still carries the drift `line-endings` describes ("thirteen of the fourteen diverged … on the same six lines"). Every addon, LibKa0s and dev-copilot now match their body. CLAUDE.md:122-127 calls this case "the one thing that discredits the rule".
  - The documentation-and-tooling one-liner (`line-endings.md:483`) cannot catch it, because it prints any matching line and does not check that *both* carve-outs are present.
- **Reachability:** Any `/dev-copilot:wow-standards-audit` of this repo, and any reader who diffs the bodies. No player, and no client-side or checkout effect today.
- **Measured:** `diff <(sed -n 255,339p standards/standards/line-endings.md) .gitattributes` → hunks `30,37c30,35` and `39d36 < *.py text eol=lf`.

### F-002: Seven restatements of the shebang carve-out still name only `*.sh` `[design]` `[docs-drift]`

- **Where:**
  - `standards/standards/documentation.md:675`: "the `*.sh text eol=lf` carve-out mandatory in both kinds"
  - `standards/standards/library-stack.md:221`: "plus the `*.sh text eol=lf` carve-out for its own `testkit/run-automated-tests.sh`"
  - `standards/standards/automated-tests.md:60-64`: "**MUST** carry the `*.sh` carve-out that `line-endings-§3` already requires", with a one-line `*.sh` block
  - `NEW_ADDON.md:20`: "the `*.sh text eol=lf` carve-out, and the `binary` markings"
  - `standards/NEW_ADDON_CONTEXT.md:1622`: the checklist item "`* text=auto eol=crlf`, `*.sh text eol=lf`, binaries marked `binary`"
  - `standards/EXECUTIVE_SUMMARY.md:52`: "`*.sh text eol=lf` is mandatory in **both** kinds"
  - The repo's own `CLAUDE.md:123`: "`* text=auto eol=lf`, `*.sh text\n  eol=lf`, binaries marked `binary`"
- **Problem:** v2.61.0 widened `line-endings-§3` to the pair `*.sh` + `*.py`. These copies were never updated, so each one now describes a rule that is one line short.
- **Impact:** These copies are what a maintainer actually reads. F-001 is what happens when a repo follows its own `CLAUDE.md` instead of §5. The `NEW_ADDON.md` and context-pack checklist wording tells a scaffolder that a `*.sh`-only body is complete. The copied snippet (`NEW_ADDON_CONTEXT.md:1198-1199`) does carry both lines, so new addons come out right only if the author copies rather than reads.
- **Reachability:** Every maintainer or agent who reads a restatement instead of §3/§5. That includes the `/dev-copilot:wow-new-addon` checklist and any library- or doc-repo audit that reads its applicability row. There is no runtime effect.

### F-003: The index every consumer must fetch is 92% changelog and grows with every release `[perf]` `[design]`

- **Where:** `standards/STANDARDS.md:97-253` (`## Changelog`).
- **Problem:**
  - The changelog takes 384,409 of the file's 418,659 bytes, across 99 entries.
  - Single entries are one physical line of up to 25,133 characters (`STANDARDS.md:113`, v2.63.0).
  - The file was 11,177 bytes on 2026-07-13, 145,206 on 2026-08-07 and 418,659 today.
  - The index plus the 27 section files total 1,276,409 bytes.
- **Impact:**
  - The index tells tools to hard-code this one file and to read "this index **and then every file linked under Sections**" (`STANDARDS.md:15-24`).
  - Every audit, review and scaffold run therefore pays for about 0.38 MB of history before reaching a rule, roughly 100k tokens at a rough 4 bytes per token (not measured).
  - The whole standard is several times a typical agent context. In practice consumers read selectively, so a rule they skip is a rule they never check.
  - The cost rises with every release, at no benefit to the reader, because git already keeps the history.
- **Reachability:** Every `/dev-copilot:wow-standards-audit`, `/dev-copilot:review` (WoW overlay guardrail), `/dev-copilot:wow-new-addon` and harvest run in all 14 rotation repos, on every invocation.
- **Measured:** `wc -c standards/STANDARDS.md` → 418659; `sed -n 97,255p standards/STANDARDS.md | wc -c` → 384409; `grep -c '^- \*\*v' standards/STANDARDS.md` → 99; `git show <sha>:standards/STANDARDS.md | wc -c` sampled every 15th commit (table in 02).

### F-004: The repo's "No mechanical gate" limitation keeps letting cheap, checkable drift through `[tests]` `[design]`

- **Where:** `docs/ARCHITECTURE.md:54-60`, quoted: "**No mechanical gate.** There is no suite that can catch a contradiction between two section files, a broken internal link, …" and "**Cross-references are unenforced.**"
- **Problem:** The limitation is written down and accepted, but today's evidence shows its cost. F-001 went 17 days with no detection, and F-002, F-005, F-006, F-007 and F-012 all slipped through. Each one is found by a git + grep/awk check that runs in under a second. `DEPENDENCIES.md`'s "Verifying your setup" only checks for CR bytes, not the §5 body.
- **Impact:** Doc drift in this repo spreads to every consumer on its next run (ARCHITECTURE.md: "A playbook edit takes effect immediately … with no staging"). Each such defect costs a human or agent read to find, and is usually found by accident.
- **Reachability:** Every maintainer editing the standard, and every one of the 14 repos that consumes it. This is a process gap, with no direct runtime effect.

### F-005: The scaffold runner's comment states the opposite of `testing-§9` and the kit `[docs-drift]`

- **Where:** `standards/NEW_ADDON_CONTEXT.md:1072`: "-- from what the client loads. A suite named here but missing from disk is SKIPPED, not failed."
- **Problem:** `testing-§9` (`testing.md:284-293`) states that a missing suite **raises**, and that a deliberately absent suite is declared `pending`. The kit enforces this: `../LibKa0s/testkit/framework.lua:360-400`, `loadSuites`. The comment dates from `8dbffb1` (2026-07-31), before the rule changed in v2.63.0 (`957b3c5`).
- **Impact:** Every addon scaffolded from the pack gets a `tests/run.lua` whose header teaches the old, silent behavior. A maintainer who trusts it will read a raised error as a kit bug.
- **Reachability:** Every new addon scaffolded via `/dev-copilot:wow-new-addon`. The text is a comment in generated code with no runtime effect, so it is capped at Medium.

---

## Low

### F-006: `documentation-§5` is cited as the citation scheme, which is `§6` `[citation]`

- **Where:**
  - `standards/standards/library-stack.md:223`: "| documentation-§5 | The `filename-§N` citation scheme and documentation-§6's citation rules. |"
  - `AUDIT.md:994`: "written as `filename-§N` (documentation-§5/§6 — …"
- **Problem:** `documentation-§5` is "Keeping docs in sync" (`documentation.md:525`). The citation scheme is `documentation-§6` (`documentation.md:529`, and §8's row at `:679`). The library-stack row has said this since `5446657` (2026-08-05).
- **Impact:** The library repo's applicability list gives §5 the wrong meaning and never names §6 as its own row. An auditor applying the list literally checks the wrong subsection.
- **Reachability:** Only an audit of LibKa0s that reads the applicability table, plus AUDIT.md's parenthetical. No runtime effect.

### F-007: The index footer's authority date is stale by three releases `[docs-drift]`

- **Where:** `standards/STANDARDS.md:255`: "Authoritative as of 2026-10-01; bump on amendment."
- **Problem:** The header reads `v2.76.1, 2026-10-07` (`STANDARDS.md:1`). The footer missed v2.75.0 (10-02), v2.76.0 (10-04) and v2.76.1 (10-07). A release currently has to bump the version stamp in six places: the header, this footer, `README.md:160`, `EXECUTIVE_SUMMARY.md:11`, `NEW_ADDON_CONTEXT.md:1` and `CLAUDE.md:143`. This footer is the one that drifts. It has been corrected before (`harvests/2026-09-22/06_OUTCOME.md:138`).
- **Reachability:** A reader of the index footer. No runtime effect.

### F-008: Line-ending check (e) splices file names into shell code `[security]`

- **Where:**
  - `AUDIT.md:184-189`: `git ls-files -z | xargs -0 -I{} sh -c ' … "{}" … '`
  - `standards/standards/line-endings.md:486-491`: the same block
- **Problem:** `{}` is substituted into the `sh -c` script text. A tracked file name containing `"` runs whatever comes after it, and the file is not counted correctly.
- **Impact:** Arbitrary command execution in the auditor's shell, plus a wrong straggler count.
- **Reachability:** An audit of a repo that tracks a file name containing `"`, `$` or a backtick. None of the 14 rotation repos does today (`git ls-files | grep -c '["$`'"'"']'` → 0 in each), so this is latent.
- **Measured:** In a scratch repo, a tracked file named `a";touch PWNED;"b.md` created `PWNED` when the block ran.

### F-009: Temporal claims and partial lists that read as complete `[docs-drift]`

- **Where:**
  - `standards/standards/testing.md:292`: "This is what LibKa0s test-kit revision 24 ships today". The kit is at revision 37 (`Kit.VERSION = 37` in `../LibKa0s/testkit/framework.lua`).
  - `standards/standards/testing.md:20` and `standards/NEW_ADDON_CONTEXT.md:1019`: "_kit/ -- vendored, never edited: framework.lua, loader.lua, mock_base.lua, README.md". That is 4 of the 22 files in `../LibKa0s/testkit/`.
- **Problem:** "Today" in a living normative file gets older every day. The kit tree in both places reads as a complete inventory but is not one, which brushes against this repo's own rule against stating a set without its real members (CLAUDE.md:141-142).
- **Reachability:** Readers of `testing` and of the scaffold pack. No runtime effect.

### F-010: The "one-page TL;DR" is about ten pages `[naming]`

- **Where:** `standards/EXECUTIVE_SUMMARY.md:3`: "**One-page TL;DR of the standard.**"
- **Problem:** The file is 58 lines but 4,733 words (31,851 bytes). Four of its lines are 2,836 to 4,586 characters (`:22`, `:23`, `:26`, `:56`), measured with `wc -lwc`.
- **Impact:** The name promises a quick read the document cannot give. The summary has grown into a second copy of the standard that every amendment must keep in sync (CLAUDE.md:132-135).
- **Reachability:** A newcomer following the README's "Start here". No runtime effect.

### F-011: The roster's Folder links resolve outside the repository `[docs]` (GitHub behavior unverified)

- **Where:** `standards/ADDONS.md:19-29`, `:49`, `:61`, for example "[`../../AbsorbTracker/`](../../AbsorbTracker/)".
- **Problem:** These are local-disk links ("Paths below are relative to this file", `:15`). On GitHub, `blob/master/standards/` + `../../X/` resolves to `blob/X/`, which is a branch that does not exist.
- **Impact:** The links are dead on the published page. The Repository column next to them carries working URLs.
- **Reachability:** Readers of the roster on GitHub. Not verified today, because outbound HTTP to GitHub hung.

### F-012: Malformed cross-reference in the changelog `[citation]`

- **Where:** `standards/STANDARDS.md:120`: "**`preview-mode-§`'s two MUSTs read in tension …**"
- **Problem:** The `-§` has no number. `preview-mode` has no numbered subsections, so the correct form is the bare filename (`documentation-§6`, CLAUDE.md:93-96).
- **Reachability:** A reader of the v2.59.1 changelog entry. No runtime effect.

---

## Recorded non-findings

These were looked at and need no action:

- The harvest refs that are out of range are frozen (`harvests/` is "never edited after the fact").
- `AUDIT.md`'s package check (b) printing `UNACCOUNTED — .git` in every addon is documented (`AUDIT.md:252`).
- The revendor-bundle check (`AUDIT.md:310-333`) was run in AbsorbTracker, MultiMeters and PrettyChat and works. It reported v1.69.0 and v1.70.0 as unrecorded, which is a sibling in-flight state on today's branch, not a playbook defect.
