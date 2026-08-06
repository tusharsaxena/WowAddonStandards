# Automated test records — the playbook

**The step-by-step spec for `/wow-addon:automated-tests`.** An addon records **itself**: the run and
its bundle are written into the **addon's own** repo under `docs/automated-tests/`, never here.

This file is a **thin orchestrator**. The normative rules — what a bundle contains, what gates, what
`RESULTS.md` is — are `standards/standards/automated-tests.md`'s, and this playbook defers to it. What
lives here is the *process*: how a run is driven, and the **uniform analysis prompt** that makes two
addons' write-ups readable against each other.

Read `standards/STANDARDS.md` and follow its Sections list to the `automated-tests` section before
running this. Do not re-derive the rules from this file.

---

## Step 1 — Run

From the addon repo root:

```sh
tests/_kit/run-automated-tests.sh                              # all four suites, writes a bundle
tests/_kit/run-automated-tests.sh --release X.Y.Z              # a release run (see Step 4)
tests/_kit/run-automated-tests.sh --suite complexity           # a subset
tests/_kit/run-automated-tests.sh --suite lint --suite tests --no-bundle   # the green gate, writes nothing
```

If the runner fails with `bad interpreter` or a `\r`-shaped syntax error, it arrived CRLF: the repo's
`.gitattributes` is missing `*.sh text eol=lf`, or has it and was never renormalized. The rule and the
fix are one hop away at `line-endings-§3`/`§6` — do not edit the vendored script.

The runner is **vendored** (`automated-tests-§2`). If it is missing, the addon has not adopted the
section yet — say so and stop; do not hand-roll a substitute, and do not run the four tools
individually and assemble a bundle by hand. A bundle whose provenance is "an agent ran some
commands" is not the artifact the standard defines.

The runner writes the bundle and updates `RESULTS.md`'s table row. It does **not** write `ANALYSIS.md`
or the `RESULTS.md` watch list — those are Steps 2 and 3, and they are the parts that need a reader.

## Step 2 — Write `<bundle>/ANALYSIS.md`

Use the template below **verbatim in structure**. Every claim cites a file in the same bundle.

Two standing rules:

- **Do not fabricate a number.** Every figure comes from `manifest.json` or a suite artifact in this
  bundle. If a suite was skipped, the analysis says what was not measured and why — a write-up that
  reads as complete over a run that measured three of four suites is the failure mode this whole
  section exists to prevent.
- **Do not soften a skip into a pass.** "luacheck unavailable" is not "lint clean". The same rule
  applies one level down, at the **case**: a test case that could not run reports a **skip** carrying
  its reason (`Kit.skip`, testing-§11), and it is folded into neither the passed figure nor the
  failed one (testing-§5, automated-tests-§4).

```markdown
# Analysis — <YYYYMMDD-HHMMSS>

- **Addon:** <name> <version>
- **Verdict:** <green|amber|red>
- **Commit:** <sha> (<branch>)<, dirty> 
- **Previous run:** <stamp of the row above this one in RESULTS.md, or "none — this is the first">

## Headline

<Two or three sentences. What a reader needs if they read nothing else: did it pass, did anything
move since the previous run, and is there anything to act on.>

## Suites

Every row links its artifact, so a reader can get from a figure to the evidence in one click. A
skipped suite links nothing — there is no artifact — and says what was not measured.

| Suite | Status | Result | Artifact | Moved since <previous run> |
|---|---|---|---|---|
| lint | | <warnings> warnings / <errors> errors in <files> files | [`lint.txt`](lint.txt) | |
| tests | | <passed> passed, <skipped> skipped, <failed> failed, <total> total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | |
| perf | | <scenarios> scenarios | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | |
| complexity | | see below | [`complexity.txt`](complexity.txt) | |

**Complexity is reported in full**, because a single figure cannot be compared across a change in
size. Give every field of `lizard`'s footer — totals *and* averages — plus the two derived counts:

| Metric | Value |
|---|---|
| Total NLOC | |
| Functions | |
| Avg NLOC / function | |
| Avg CCN | |
| Max CCN | |
| Avg tokens / function | |
| Warnings (CCN > 15) | |
| Warning rate (`Fun Rt` / `nloc Rt`) | |
| Files in the 1000–1500 band | |
| Files over the 1500 cap | |

The averages are the point. A **total** that rose because the addon grew is a different fact from an
**average** that rose because it got denser, and only the second is a complexity signal — reporting
totals alone makes a growing addon look like a degrading one, every release, until nobody reads the
row. Every value comes from `manifest.json`'s `suites.complexity`, which records all eight footer
fields.

For each suite that is not a clean pass, one short paragraph: what the output says, and whether it is
a regression, a pre-existing condition, or a skip.

## What moved

<Per-suite deltas against the previous run, or "First run — nothing to diff against; every figure
below is a baseline reading" if there is none. A number that did not move is worth one line saying
so; silence reads as "not checked".>

## Complexity watch list

<Two tables, both WITH HEADER ROWS — see Step 3 for the exact shape. Functions: Function / CCN /
Location / Disposition. Files: Band / File / LOC / Disposition, band as a column so more bands than
today's two render uniformly. "None." rather than dropping a heading.>

## Actions

<Numbered, or "None." Each action names the file and what would change. An action with no owner in
the addon's own tracking — a deviation ID or a review finding — says that it is new here.>
```

## Step 3 — Refresh the `RESULTS.md` standing sections

The runner prepends the table row. Everything **below** the table is written by the reader
(`automated-tests-§4`) and describes the **current** state, not this run's diff.

Four sections, one per suite. The complexity watch list came first and it is easy to leave it the
only prose — but a record whose only narrative is about complexity teaches the reader that the other
three suites are pass/fail lights, and they are not.

### `## Test suite`

Case count and what it covers. Worth a sentence when: the count has **not moved** across several
runs (a suite that stopped growing while the addon did is a coverage gap, and the table cannot show
it); a whole area is covered only by in-game smoke tests; or the count jumped and it is worth saying
why. Name the generated inventory (`test-cases.md`) as the authority.

### `## Lint`

Clean or not, over how many files, and **what the config excludes**. A `0/0` row means nothing
without knowing what was in scope — a `.luacheckrc` with a broad `exclude_files` can make an addon
permanently green over half its source, and that is invisible in the table.

### `## Perf`

The scenarios and what they pin. A permanent `skip` is a standing fact about the addon, not a
transient tooling gap, and it should read as one. Two reasons are sanctioned (automated-tests-§3),
and the write-up says **which**, because they mean different things:

- the addon ships **no** `tests/perf.lua` — the run is silent about runtime cost, and
  `performance-§9`'s zero-overhead evidence does not exist for this addon;
- the addon holds a recorded **performance-§12 no-combat-path exemption** — it brackets nothing by
  design, the reason is ratified in its `## Documented deviations` register, and the skip is cited
  to that row rather than left to read as an unmeasured addon.

### `## Complexity watch list`

Two tables, both with headers — a bare row of pipes with no header line does not render as a
table at all, it renders as literal pipes.

**Functions `lizard` warned on:**

```markdown
| Function | CCN | Location | Disposition |
|---|---|---|---|
| `name` | 21 | `path/File.lua` | **Peel next / Accepted — why / Already tracked as `<id>`** |
```

**At a release, the functions table reads "None." by construction** — the release gate is all four
suites plus **zero functions above CCN 15** (`automated-tests-§3`), so a bundle produced for a tag
that passed cannot have a warned function in it. A non-empty functions table in a release bundle means
the gate was not run or not honored, and that is the finding. Between releases the table is ordinary
and its dispositions are read normally.

A disposition is a decision with a shelf life, not a label that renews itself. An entry carried as
**Accepted** across **three consecutive release runs** is either fixed or converted into a tracked
deviation with an ID and an owner — after which the disposition reads *Already tracked as `<id>`*
and the argument is not re-had every release. A watch list where everything is accepted costs
maintenance and carries no signal, and one too long to read in a single pass is itself the finding:
that is a backlog, and a backlog needs scheduling (automated-tests-§4, performance-§10,
anti-pattern #53).

When reading these numbers, remember `lizard` counts every `and`/`or` short-circuit as a decision.
In Lua that means a run of `t.k = rec.k or D.k` defaulting lines scores high with no visible
branching at all, so a large CCN usually means *this function defaults or guards a lot of fields*
rather than *this function has tangled control flow* — and the two want different fixes
(performance-§10). What a refactor triggered by this list may and may not do is performance-§11.

**Files by `layout-§1` band** — the band is a **column**, not a heading, so any number of bands
renders uniformly and sorts together. Today's bands are `1000–1500 (on notice)` and `> 1500 (over
cap)`, but the standard may add or move one, and a column absorbs that without restructuring every
addon's record:

```markdown
| Band | File | LOC | Disposition |
|---|---|---|---|
| 1000–1500 (on notice) | `tests/test_x.lua` | 1256 | accepted — case count, not tangle |
| > 1500 (over cap) | `data/Generated.lua` | 2893 | already tracked as `<id>` |
```

Anything that **newly** crossed since the previous run is marked as such in its disposition. `None.`
where a table would be empty — an empty watch list is a **result**, not a reason to drop the heading.

Carry forward a disposition that is still true rather than re-arguing it; a watch list that reads
differently every release teaches the reader that none of it is settled.

## Step 4 — Release runs

A release run is `--release X.Y.Z`, which stamps the manifest. It is produced as part of the version
bump, **before** the tag (`automated-tests-§6`), and:

- **MUST** carry an `ANALYSIS.md` (`automated-tests-§5`).
- **MUST** have its verdict reported to the user while they are deciding whether to tag — a `red` or
  `amber` release run is a decision point, not a footnote.

## Step 5 — Report

Print, in chat:

- One line per suite: name — status — headline figure — **and the checkpoint, not the verdict alone**
  (automated-tests-§4). `lint` and `tests` gate **the run and the commit**; `perf` and `complexity`
  gate **neither**; the **tag** is gated on all four at pass plus zero functions above CCN 15,
  evaluated by `/wow-addon:bump-version` from this run's `manifest.json`, where a `skip` is **NOT
  EVALUATED** rather than a pass. A bare `(recorded, non-gating)` is the half-truth this replaces —
  it is true of the commit and false of the tag, and it is what teaches a reader that a complexity
  number never matters.
- The verdict, and the bundle path.
- Anything that newly crossed a threshold, with its disposition.
- Any suite that was **skipped**, with what is missing and its install hint. Never let a skip pass
  silently: the whole point of recording skips is that they are visible.

## Hard rules

- **Never edit a frozen bundle.** A bundle is evidence (`automated-tests-§1`). If a reading was wrong,
  the *next* run's analysis says so; this one stands as what was believed at the time.
- **Never edit the vendored runner** (`tests/_kit/`). A kit problem is fixed in `LibKa0s` and
  re-vendored; a local patch is reverted silently by the next re-vendor.
- **Never make this run itself gate on perf or complexity**, and never report a run as failed because
  of them. They are measured and recorded (`automated-tests-§3`); a complexity warning count does not
  fail a run and must not be presented as one. The **release** is gated on all four plus zero CCN > 15,
  but that gate belongs to `/wow-addon:bump-version`, which reads this run's `manifest.json` — never to
  the runner, whose exit code stays unchanged because the same script is the commit gate.
- **Never hand-write a number into a bundle.** Everything in it came from a tool. A hand-edited record
  is worse than an absent one, because it reads as measured.
