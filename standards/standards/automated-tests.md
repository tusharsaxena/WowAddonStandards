> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Automated test records

Four out-of-game suites answer four different questions about an addon — does it lint, does it pass,
what does it cost, where is it getting hard to change — and before this section each one recorded its
answer somewhere else, in a different shape, on a different schedule. `luacheck` and the harness left
no record at all beyond a transient console; the offline perf runner wrote into a store shared with
in-game captures; `lizard` wrote a single hand-curated markdown file. Nothing could answer *"what did
this addon look like on the day we shipped 1.4.2"* without three archaeology passes, and nothing could
answer *"which of these moved between two releases"* at all.

This section makes the **record** normative, not the tools. What runs is unchanged. Where the results
land, in what shape, and what may fail a run — that is what is specified here.

### 1. The bundle (MUST)

- **MUST** record every run under **`docs/automated-tests/<YYYYMMDD-HHMMSS>/`** — one directory per
  run, **frozen once written**, never edited afterwards (audit-review-history applies the same rule to
  audits and reviews, for the same reason: an amended record is no longer evidence).
- **MUST** stamp the directory in **local time**, not UTC. A record is read by the person who ran it,
  usually minutes later, and a folder name that disagrees with their clock costs a mental conversion
  on every glance. The manifest's `startedAt` carries an explicit UTC **offset** (`2026-08-04T17:03:11+05:30`),
  so the instant stays unambiguous once the record outlives the machine that produced it — local for
  reading, offset for arithmetic. Note that "local" is the *machine's* timezone: a host left on
  `Etc/UTC` stamps UTC and is behaving correctly, so a developer expecting their own wall clock sets
  the system timezone rather than the runner.
- **MUST** carry, per run, one file per suite that produced output, plus a machine-readable manifest:

  ```
  docs/automated-tests/
    README.md                     -- what this is and how to run it
    RESULTS.md                    -- the trend line; overwritten in place (§4)
    <YYYYMMDD-HHMMSS>/
      manifest.json               -- every suite's status and counts (§3)
      ANALYSIS.md                 -- the write-up (§5)
      lint.txt                    -- luacheck output
      tests.txt                   -- harness output
      test-cases.md               -- the generated inventory as it stood for this run
      perf.txt / perf.json        -- offline scenario output + its record
      complexity.txt              -- raw lizard output
  ```

- **MUST** name suite files for the suite, not the tool, so a future tool swap does not rename the
  artifact and break every reader.
- **MUST NOT** prune. Bundles are cumulative; the collection keeps them all, because the question a
  record answers is asked long after the run and usually about a version nobody expected to revisit.
- The directory sits under `docs/`, which every `.pkgmeta` already ignores — adopting this needs **no**
  packaging change.

### 2. The runner is vendored, not per-addon (MUST)

- **MUST** run the suites through **`tests/_kit/run-automated-tests.sh`**, vendored whole-folder from
  `LibKa0s`'s `testkit/` exactly as the rest of the kit is (testing-§1, library-stack-§7). It is
  byte-identical in every addon and the existing vendoring gate enforces that; an addon-side copy is a
  fork nobody knows about, and the next re-vendor reverts it silently.
- **MUST NOT** edit the vendored copy, and **MUST NOT** re-implement the runner locally "just for this
  addon". A runner that differs per addon produces bundles that cannot be compared across the
  collection, which is most of what the bundle is for.
- **MUST** carry the `*.sh` carve-out that `line-endings-§3` already requires of this repo's
  `.gitattributes`:

  ```gitattributes
  *.sh text eol=lf
  ```

  The requirement is **unconditional** and belongs to `line-endings`, not to this section: it binds
  **both** repo kinds — the CRLF-pinned client-bound repos and the LF-pinned ones, where the line is
  redundant and mandatory anyway. Through v2.23.0 this bullet read *"carve shell scripts out of a
  CRLF-pinned repo"*, which presumed a pin no section stated and which a repo could satisfy by not
  pinning at all — one repo did exactly that, arriving at the carve-out with no rule above it.
  `line-endings-§1/§2` now state the rule, and this bullet restates the exception only as it bears on
  the vendored runner. The rationale is written once, at `line-endings-§3`, and is not repeated in
  normative voice here; the consequence for **this** section is that without the line the vendored
  runner is broken on **every** checkout rather than in one contributor's, failing identically for
  everyone — which reads as *"the script is wrong"* and sends the reader to the wrong repo.
- **MUST** satisfy the rest of `line-endings` too, since a `.gitattributes` holding this carve-out and
  no pin is explicitly **not** compliance (`line-endings-§1`).
- **MUST** end re-vendoring by setting the executable bit **in the git index**, not in the working
  tree:

  ```sh
  git update-index --chmod=+x tests/_kit/run-automated-tests.sh
  ```

  `cp` does not reliably carry the executable bit, and the mode that survives a **clone** is the one
  git recorded — `git ls-files -s` must report **`100755`**, not `100644`. **`chmod +x` is not
  sufficient and, in this collection, does nothing at all**, which is the trap: every repo here sits on
  a **WSL DrvFs** mount that reports *every* file as `rwxrwxrwx`, so `ls -l` shows the bit already set
  and a `chmod` appears to succeed; and every repo has **`core.fileMode=false`**, so git ignores the
  working tree's mode even when it does change. Both signals a reader would trust are therefore silent
  about the real state, and the instruction that used to close this bullet — `chmod +x …` — failed
  identically in **9 of 9 repos**, every one of them recording `100644` while every working tree
  claimed the file was executable.
- **MUST** assert the recorded mode mechanically rather than remembering it: the repo's
  **vendored-payload gate** — the consumer-side gate of testing-§11, or `tests/test_kitsync.lua` in the
  library repo — **MUST** assert that `run-automated-tests.sh` is recorded as `100755`. Nine identical
  failures against an explicit MUST is what a rule with no test looks like, and this is the one
  property of the payload that no amount of reading the working tree can confirm.

### 3. What gates, and what only records (MUST)

This is the section's load-bearing rule, and it is a deliberate refusal to do the obvious thing.

- **`lint`** (`luacheck .`) and **`tests`** (`lua tests/run.lua`) are **gating**. They answer
  *is it correct*, they are deterministic, and testing-§4 already makes them the green commit gate.
- **`perf`** (`lua tests/perf.lua`) and **`complexity`** (`lizard`) are **recorded — they never fail a
  run and never gate a commit**. They answer *what does it cost* and *where is it getting hard to
  change* — questions whose answers are read, compared and argued with, not thresholded. At the
  **release** they do gate, and that is a separate checkpoint evaluated by a separate actor: see *The
  release gate* below.

**MUST NOT** fail a **run**, or block a **commit**, on a perf or complexity result. `performance-§9` and `performance-§10` already
say this for each tool separately, and the reason survives consolidation intact: a threshold that
fails a run teaches everyone to reach for `--no-verify`, after which the gate protects nothing and the
habit remains. Folding these two into a red/green battery because they now live beside two suites that
*are* gates would reverse both rules by accident, which is precisely the drift a consolidated record
makes easy. They contribute `amber` — a signal — never `red`.

**MUST** record a missing tool as a **skip**, with its reason, and **MUST NOT** record it as a pass or
a failure. An absent `luacheck`, `lizard` or Lua 5.1 means the suite did not run; it does not mean the
addon is clean and it does not mean the addon is broken. A green run that silently measured nothing is
worse than a red one, because it is believed.

**Exactly two `skipReason` values are sanctioned for `perf`**, and both describe *nothing to run* rather
than *nothing measured*: **(1)** the addon ships no `tests/perf.lua`; **(2)** the addon holds a recorded
**no-combat-path exemption** (performance-§12), which is why it ships no `tests/perf.lua`. The second is
the more informative of the two and **MUST** be recorded when it applies, naming `performance-§12`, so a
reader of the bundle can tell a ratified exemption from a suite somebody forgot to write. Neither
sanctions a silent skip: both are still written into the run's `skipReason` and both still surface in
the release notes.

Verdicts: **`red`** — a gating suite failed. **`amber`** — a gating suite was skipped, or `perf` failed
its own deterministic assertions. **`green`** — gating suites passed and nothing went unmeasured
without saying so.

#### The release gate: all four, and it is not the commit gate (MUST)

Everything above is about **the run**, and about **commits**. A **release** is a different checkpoint
with a different failure mode, and there all four suites gate.

- **MUST NOT** cut a release — bump the version, roll `## What's new`, tag — unless the release run's
  `manifest.json` shows **all four** suites at `pass`, and `suites.complexity.warnings` at **0**.
  Concretely: `lint` pass (which already means **zero warnings and zero errors**, since `luacheck`
  exits non-zero on either), `tests` pass with zero failures, `perf` pass, and `complexity` pass with
  **no function above CCN 15**.
- **MUST** treat a **skip** as a gate that did **not pass**. A release claiming zero CCN > 15 on a run
  where `lizard` never executed is an unmeasured claim, and automated-tests-§3's own rule — a skip is
  never a pass — is what makes it one. The remedy is to install the tool and re-run, not to read the
  skip as clean. The one narrow exception is `perf` skipped because the addon **ships no
  `tests/perf.lua`**: nothing was there to run, which is a different fact from a scenario that failed
  or a tool that was missing, and it **MUST** be stated as such in the release notes. That exception
  covers both of §3's sanctioned `perf` skip reasons, including the **performance-§12 exemption** — an
  exempt addon's release notes name the exemption rather than the bare absence, because *"this addon
  brackets nothing and here is the ratified reason"* is the sentence a reader needs; the skip still
  **MUST** be said out loud either way.
- **MUST NOT** move this gate to commit time, and **MUST NOT** change the runner's exit code to
  implement it. `performance-§9`/`§10` and automated-tests-§3's `never gating` are retained **verbatim
  and deliberately**, and the runner stays exactly as specified — the same script is the commit gate
  (testing-§4), so a threshold added inside it would land on every commit. The release gate is
  evaluated by the **release command**, reading the manifest the run already writes.

**Why this is consistent with the rule it appears to reverse.** The argument against thresholding perf
and complexity is an argument about **commit** gates specifically: a gate on every commit is routed
around with `--no-verify`, after which it protects nothing and the habit remains. A release has no
such escape hatch — it is infrequent, deliberate, already the moment the addon is looked at whole
(performance-§10), and the one point where an unmeasured claim becomes a claim made **to users**.
Between commits the numbers stay advisory and argued with, which is what keeps them honest; at the tag
they have to be true. Shipping a release with a known failing test or an unmeasured complexity number
is not a judgment call the release notes can absorb.

- **MUST** report **every** failed gate, not the first one. A release blocked for a lint error that
  turns out to also have four failing tests and a CCN 62 function has been stopped once and should be
  understood once — a gate that stops at the first failure produces three more rounds of the same
  interruption.
- **MUST NOT** bump, tag or push anything when a gate fails. A partial bump — the TOC moved, the tag
  not cut — is worse than a clean refusal, because the next run starts from a state nobody chose.

### 4. `RESULTS.md` — the trend line (MUST)

- **MUST** maintain **`docs/automated-tests/RESULTS.md`**: **one** file, **overwritten in place**,
  never dated and never a directory, carrying one row per run across **all four** suites.
- The **git history of that single path is the trend line**. This is the same rule `performance-§10`
  applied to the complexity report and the same reason: a dated pile scatters across files the one
  comparison the record exists to make. Consolidating the *evidence* into per-run bundles is only safe
  because this file keeps the *comparison* on one path.
- **MUST** carry, per row: the run stamp (linking its bundle), the addon version, the verdict, and
  each suite's headline figures — lint warnings/errors and files checked, tests
  **passed/skipped/total**, perf status, and for complexity **both totals and averages**: NLOC,
  functions, avg NLOC/function, avg CCN, max CCN and the warning count. An average without its total,
  or a total without its average, cannot be read across a change in size.
- The `tests` column **MUST** carry the **skipped** figure alongside passed and total, and **MUST NOT**
  fold a skip into either. A case that could not run — the sibling checkout a vendored-payload gate
  needs is absent, say (testing-§11) — is neither a pass nor a failure, and a trend line that reports
  `41/41` on a run where two cases never looked is claiming coverage that was not exercised. Same rule
  as this section's suite-level one, one level down: a skip is recorded as a skip, never as a pass.
- **MUST** distinguish a suite that was **not selected** from one that was **skipped**. A subset run
  whose row reads `0/0` for tests is indistinguishable from a full run that found no tests, and the
  trend line carries that forever. Not-selected and tool-absent are different facts about why a
  number is missing, and both are different from zero.
- **The generated lead-in MUST name the checkpoint for each suite, not merely the verdict.** The
  prose the runner writes above the table is not decoration — it is the sentence eight repos quote
  back — and *"perf and complexity never fail a run"* is true and, standing alone, misleading, because
  it reads as *"these two never gate anything"* while §3's release gate says otherwise. The emitted
  text **MUST** state, per suite:
  - **`lint`** and **`tests`** — gate the **run** and gate the **commit** (testing-§4);
  - **`perf`** and **`complexity`** — never fail a run and never block a commit; they are recorded;
  - the **tag** — gated on **all four** suites at `pass` plus **zero** functions above **CCN 15**
    (§3, *The release gate*), evaluated by the release command from the run's `manifest.json`, where a
    **`skip` is NOT EVALUATED rather than a pass**.
  A verdict without its checkpoint is the half-truth this bullet exists to end, and because the lead-in
  is **runner-generated**, one addon cannot fix its own copy — testing-§1 forbids editing the vendored
  kit. The fix lands in the kit and reaches every repo on its next re-vendor.
- The manifest **MUST** carry the same fact in machine-readable form: a **`gates`** object naming both
  checkpoints per suite rather than a bare `gating` boolean, which cannot express *"not at commit, yes
  at the tag"* and is what let the generated prose drift. The legacy boolean **MAY** be retained for
  one revision for readers that still key on it, and **MUST NOT** be the field a new reader consults.
- **MUST NOT** silently recreate the file when its column set has changed. Rewriting the header
  drops every previous row — the one thing a trend line must never do. A runner that cannot append
  says so and leaves the file alone.
- **MUST** carry the current complexity **watch list** below the table, as **two tables with header
  rows**: warned functions (Function / CCN / Location / Disposition), and files by `layout-§1` band
  (**Band** / File / LOC / Disposition). Each carries a one-line disposition — *accepted and why*,
  *peel next*, or *already tracked as `<deviation-id>`* — and anything that **newly** crossed since
  the previous run says so. A regeneration that yields no disposition for what newly crossed has
  performed the ritual and skipped the point.
- **MUST NOT** carry an entry as *accepted* indefinitely. A disposition is a decision with a shelf
  life (performance-§10): an entry accepted across **three consecutive release runs** is either fixed
  or converted into a tracked deviation with an ID and an owner, and the watch list then points at the
  tracker. Left alone, "accepted" is the disposition every entry drifts into, and a list where
  everything is accepted costs maintenance and carries no signal (anti-patterns #53).
- The band is a **column, not a heading**. Two bands exist today (1000–1500 on notice, over the 1500
  cap) and the standard may add or move one; a column absorbs that, whereas a heading per band makes
  every addon's record need restructuring when it changes. It also keeps a file that moved between
  bands on one line in the diff rather than two.
- **MUST** carry a short standing section for each of the **other three** suites as well — test
  suite, lint, perf. The complexity watch list existed first and it is easy to leave it the only
  prose, but a record whose only narrative is about complexity teaches the reader that the other
  three suites are just pass/fail lights. They are not: a suite count that has not moved in six
  releases, a lint config with a broad exclusion, and an addon with no perf scenarios at all are
  each worth a sentence that the table cannot carry.

### 5. `ANALYSIS.md` — the write-up (MUST at release, SHOULD otherwise)

- **MUST** write **`<bundle>/ANALYSIS.md`** for every **release** run, and **SHOULD** write one for any
  run whose verdict is not `green` or whose numbers moved.
- **MUST** follow the uniform prompt in the root **`AUTOMATED_TESTS.md`** playbook, so every addon's
  write-up has the same shape and two addons' analyses can be read against each other.
- **MUST** link each suite's artifact from the row that reports it, so a reader gets from a figure to
  the evidence in one click, and **MUST** report `complexity` with **totals and averages both** —
  every field of `lizard`'s footer, which `manifest.json` records. A total that rose because the addon
  grew is a different fact from an average that rose because it got denser, and only the second is a
  complexity signal; totals alone make a growing addon look like a degrading one every release, until
  nobody reads the row.
- **MUST** be evidence-backed against the bundle it sits in — a claim about a number cites the file in
  the same directory that carries it. The analysis is frozen with its evidence; if the reading was
  wrong, the *next* run's analysis says so, and this one stands as what was believed at the time.

### 6. The checkpoint: release, plus whenever it helps

- **MUST** produce a full four-suite bundle as part of **every release**, in the same change that
  bumps the version and rolls the README forward (versioning-git, documentation-§1), **before** the
  tag. The manifest records the version, so a release bundle identifies itself.
- **MUST NOT** gate commits on the full bundle. The green gate stays what testing-§4 defines — lint and
  the harness — and the fast path for that is `--suite lint --suite tests --no-bundle`, which writes
  nothing.
- **The release itself IS gated on all four**, on the bundle this checkpoint produces
  (automated-tests-§3, *The release gate*). The two checkpoints are deliberately different: commits are
  gated on the two deterministic suites, the tag is gated on all four plus zero CCN > 15.
- **MAY** run any subset at any time (`--suite complexity`, say, while deciding where to refactor).
  Subset runs are ordinary and expected; the record is cheap and the alternative is measuring without
  keeping the answer.

### 7. What this replaces

- **`docs/complexity.md` is retired.** Its content is the `complexity.txt` in each bundle; its
  trend-line role and its watch list are `RESULTS.md`'s (§4). An addon adopting this section deletes
  the file rather than leaving a second, staler copy of the same numbers — two reports of one
  measurement diverge, and the reader cannot tell which is current.
- **`docs/perf-analysis/` narrows to in-game captures only.** Offline scenario runs are produced by the
  runner and belong in the bundle with the rest of the run. In-game captures **cannot** be produced by
  a script — a human runs `/<slash> perf` in a live client and exports the record — so they keep the
  standing cumulative store `performance-§8` defines, and its `README.md` says plainly that it is the
  in-game half. A directory written only by hand and a directory written only by a script are
  different things and are not merged.
