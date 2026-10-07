# Smoke tests: WowAddonStandards (2026-10-07)

This repo ships nothing to the WoW client. So no change here has an in-client test, and none is invented. This file holds three things:

1. The pre-flight and per-change checks a human runs in a shell after the changes land. This repo has no headless suite of its own until C-03 adds one.
2. The live-environment checks that need a plugin run in a **consumer** repo.
3. The in-client half of the cross-addon pass, which the review overlay makes non-optional.

## Pre-flight

From the repo root, on the feature branch, after the changes:

```sh
git grep -Il $'\r' -- . ; echo "exit $? (1 = clean)"
git check-attr text eol -- README.md scripts/check-standard.sh     # expect auto/lf, set/lf
bash scripts/check-standard.sh; echo "exit $?"                      # once C-03 has landed; expect 0
```

## Per-change checks

### C-01: Self-compliance and the carve-out set

- **Setup:** C-01 applied.
- **Steps:**
  1. `diff <(awk '/^```gitattributes/{n++;f=(n==2);next} /^```/{f=0} f' standards/standards/line-endings.md) .gitattributes`
  2. `git add --renormalize . && git status --short`
  3. `git grep -n 'text eol=lf' -- ':!harvests' ':!standards/STANDARDS.md' ':!standards/CHANGELOG.md' | grep -v 'py'`
- **Expected:**
  1. No output.
  2. Nothing staged beyond the intended edits.
  3. The only hits are `.gitattributes:36`, the two §5 body lines, `NEW_ADDON_CONTEXT.md`'s snippet line, the §3 example line, and the `automated-tests` runner block. Each of these sits next to a `*.py` line or sentence. No prose restatement lists `*.sh` alone.
- **Pass / Fail:** Pass if step 1 prints nothing and step 3 shows no prose row naming `*.sh` without `*.py`.

### C-02: Changelog out of the index (only if the owner approves)

- **Setup:** C-02 applied, and H-01 landed in dev-copilot.
- **Steps:**
  1. `wc -c standards/STANDARDS.md standards/CHANGELOG.md`
  2. `grep -c '^- \*\*v' standards/CHANGELOG.md`
  3. `git -C ../dev-copilot grep -n 'top of `STANDARDS.md`'`
- **Expected:**
  1. The index is well under 60,000 bytes (it was 418,659 on 2026-10-07).
  2. ≥ 99, the entries moved plus any new ones.
  3. No output.
- **Pass / Fail:** Pass if all three hold, and `git diff --stat` shows the old changelog lines moved, not rewritten (`git diff -M --color-moved`).

### C-03: `scripts/check-standard.sh`

- **Setup:** C-03 applied.
- **Steps:**
  1. Run it on a clean tree. Expect exit 0.
  2. In a scratch clone, append `*.zz text` to `.gitattributes` and run it. Expect non-zero, naming `line-endings-§5`.
  3. In the scratch clone, write `layout-§9` into any section file and run it. Expect non-zero, naming the citation.
  4. In the scratch clone, change `README.md`'s Status version and run it. Expect non-zero, naming the stamp.
  5. Delete the scratch clone.
- **Expected:** Each injected defect turns the run red, and the clean tree is green. This shows the checks can fail.
- **Pass / Fail:** Pass if all four results match.

### C-04: Doc-truth fixes

- **Steps:**
  ```sh
  grep -n 'SKIPPED, not failed' standards/NEW_ADDON_CONTEXT.md
  sed -n 223,224p standards/standards/library-stack.md
  grep -n 'Authoritative as of 20' standards/STANDARDS.md
  grep -n 'ships today' standards/standards/testing.md
  git grep -nE '[a-z]-§([^0-9]|$)' -- standards
  ```
- **Expected:** The first, third and fourth commands print nothing. The library-stack rows read §5 = keeping docs in sync and §6 = citation scheme. The last grep prints only the meta mentions of the literal `filename-§N` form.
- **Pass / Fail:** Pass if every grep matches its expectation.

### C-05: Positional-argument check (e)

- **Setup:** A scratch git repo holding a tracked file named `a";touch PWNED;"b.md` and a CRLF file under an LF pin.
- **Steps:** Run the new block from `AUDIT.md` in the scratch repo. Then run it in `../AbsorbTracker`, read-only.
- **Expected:**
  - No `PWNED` file appears.
  - The CRLF file is reported.
  - AbsorbTracker's count is the same as the old block's (0 on 2026-10-07).
- **Pass / Fail:** Pass if all three hold. Also confirm that `diff` between the two copies (`AUDIT.md`, `line-endings.md`) shows the same block.

### C-06: ADDONS.md Folder column (optional)

- **Steps:** Open `standards/ADDONS.md` on GitHub after the push.
- **Expected:** The Folder cells render as code, not as links. The Repository links work.

## Live-environment checks (a consumer repo, run by the owner)

- **L-1 (after C-01, C-04, C-05):** In one addon, for example AbsorbTracker, run `/dev-copilot:wow-standards-audit`. Confirm the line-endings step uses the new (e) block and the bundle reports the same straggler count as before. This is a scratch run; discard the bundle if it is not wanted.
- **L-2 (after C-02 + H-01):** Run `/dev-copilot:wow-standards-audit` and `/dev-copilot:review` in one addon. Confirm that neither tries to read `standards/CHANGELOG.md` as a section and that both resolve the standard version. Then run `/dev-copilot:wow-harvest-standards` as a dry run, or read its step 4, and confirm it targets `standards/CHANGELOG.md`.

## In-client: the cross-addon dispatch (overlay requirement)

The source-level pass was clean today (22 roots, no duplicates, LibKa0s v1.70.0). The client's dispatch table is a separate claim from that:

1. Load all eleven addons from `standards/ADDONS.md`, then `/reload`.
2. Type each root (`/at`, `/am`, `/bl`, `/cm`, `/kcd`, `/lh`, `/mm`, `/pm`, `/pfe`, `/pc`, `/wg`) and confirm each reaches its own addon's help.
3. Open Settings → AddOns. Confirm each addon appears once, and each multi-page addon's pages appear once each.
4. Expected: no Lua error popup with `/console scriptErrors 1`.

## Regression

- `git grep -Il $'\r' -- .` is clean.
- `bash scripts/check-standard.sh` exits 0.
- `git ls-files | wc -l` is 67 plus the files added (C-02: +1, C-03: +1). Update `DEPENDENCIES.md`'s "67 tracked files" sentence and its list of members **in the same change**.
- The Sections map still matches `standards/standards/*.md` (27).

## Sign-off

| ID | Tested? | Pass/Fail | Notes |
|---|---|---|---|
| C-01 | | | |
| C-02 | | | |
| C-03 | | | |
| C-04 | | | |
| C-05 | | | |
| C-06 | | | |
| L-1 | | | |
| L-2 | | | |
| Cross-addon in-client | | | |
