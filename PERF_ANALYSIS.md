# Perf analysis — the playbook

**The step-by-step spec for `/wow-addon:perf-analysis`.** An addon records **its own** in-game
captures, in its own repo, under `docs/perf-analysis/`. Nothing is ever recorded here.

This file is a **thin orchestrator**. The normative rules — the harness, the bracket shapes, the
declared buckets, the `perf` verb, `<Addon>PerfDB`, the suspend/resume contract, the two-arm capture
protocol, the record schema, the bundle and the write-up — are all in the standard's `performance`
section. What lives here is the *process* of turning a copied client paste into a frozen bundle, and
the **uniform analysis prompt** that makes two addons' captures readable against each other.

Read `standards/STANDARDS.md` and follow its Sections list to the `performance` section before
running this. Do not re-derive the rules from this file.

---

## What makes this different from every other playbook

Every other recorded artifact in the collection is produced by running something. An audit reads the
repo; `AUTOMATED_TESTS.md` drives a vendored script over four suites. **A perf analysis cannot run
anything.** The measurement happened in a live client, in combat, on a machine no agent can reach,
and it survives only as text a human copied out of the game.

That single fact sets every rule below. The inputs are **mandatory and unobtainable** — there is no
fallback, no default, no partial mode. An agent that cannot get the paste has nothing to do, and the
correct behavior is to ask and wait, not to assemble something bundle-shaped out of a previous run,
the offline scenarios, or the addon's source.

---

## Step 1 — Establish that there is a capture, and get it

Confirm the addon has the harness wired: `core/PerfSetup.lua` and the `<Addon>PerfDB` global in the
TOC. **The descriptor is the test**, not the store: an addon can be fully instrumented and simply
never have been captured. If `docs/perf-analysis/` is absent while the descriptor is present, create
the directory and its `README.md` as part of this run and say so — a first capture is exactly when
the store comes into existence, and refusing to record one because there is nowhere to put it is the
gap defending itself.

An addon carrying a recorded `performance-§12` exemption has no combat path, ships no
`docs/perf-analysis/` at all, and is a **stop** — say it is exempt and why. Do not create the store
there; an empty directory in an addon that can never fill it is an obligation that reads as unmet
forever.

Then get **both** inputs from the player. In the client, at the end of a run:

```
/<slash> perf report      # the summary a human reads
/<slash> perf dump        # one line of JSON — the record the summary is built from
```

followed by the debug-log window's **Copy** button (`Ctrl+C`, `Esc`). One paste carries both, plus
the run's lifecycle lines. The same record is also on disk in
`_retail_/WTF/Account/<ACCOUNT>/SavedVariables/<Addon>.lua` under `<Addon>PerfDB.runs` after a
`/reload`.

- **MUST NOT** proceed on one half. A report without its dump is an interpretation with no evidence;
  a dump without its report is evidence nobody has read. `performance-§8`'s evidence rule needs both
  in the same frozen directory.
- **MUST NOT** substitute anything for a missing paste — not the offline scenarios, not a prior
  capture, not a figure inferred from the source. A fabricated capture is indistinguishable from a
  real one once it is in the store, which is precisely why the store is trustworthy without it.
- **MUST** ask, name the two verbs, and stop.

## Step 2 — Split, validate, stamp

The paste is one buffer of `HH:MM:SS | [Tag] <text>` lines. Three parts:

| Part | How to find it | Where it goes |
|---|---|---|
| The report | the `[Perf]` block from `capture: …` through the `(buckets nest: …)` footer | `report.md` |
| The dump | the single `[Perf]` line whose text is one JSON object | `dump.json` |
| The run log | lifecycle lines (`run started`, `armed`, `RECORDING`, `ENDED`, `SUSPENDED`, `RESUMED`) and any other tags | `report.md`, under its own heading |

**Keep the run log.** It is the capture's provenance: it is how a later reader confirms both arms
were combat-gated, that arm B really was suspended, and that no `/reload` landed between the arms —
the three conditions `performance-§7` puts on a comparable pair, none of which the report itself
records.

Validate and **state what was checked**: the dump's `addon` against the repo, its `version` against
the TOC, its `schema` against the vendored library's, the report's rounded figures reconciling
against the dump's four-decimal ones, and both arms having `frames > 0`. A mismatch is **reported,
never corrected**.

**Stamp the bundle from `dump.timestamp`** (epoch seconds) rendered as local-time
`YYYYMMDD-HHMMSS` — the same local-time rule and rationale `automated-tests-§1` gives for its
bundles. The directory names when the capture *happened*, not when it was pasted, so a run written up
a week later still sorts against its neighbours. A reconstructed stamp is said to be one.

## Step 3 — Write the bundle

```
docs/perf-analysis/
  README.md                     -- the standing store doc and capture index (Step 5)
  <YYYYMMDD-HHMMSS>/            -- one frozen bundle per capture
    report.md                   -- what the client printed
    dump.json                   -- the record, verbatim, one line
    ANALYSIS.md                 -- the write-up (Step 4)
```

`dump.json` is the emitted line **byte for byte**. Not pretty-printed, not re-keyed, not rounded, not
stripped of a field that looks wrong. The library emits sorted keys precisely so two records diff
cleanly, and the encoder's quirks — `%.4f` on every non-integer, an empty table encoding as `{}`
rather than `[]` — are part of the record's identity. Read it with `jq`; never write it with one.

Bundles are **frozen once written** and **MUST NOT** be pruned (`audit-review-history`). The
directory sits under `docs/`, which every `.pkgmeta` already ignores — adopting this needs **no**
packaging change.

## Step 4 — Write `<bundle>/ANALYSIS.md`

Use the template below **verbatim in structure**. Every claim cites a file in the same bundle.

Two standing rules, because they are the ones under pressure:

- **Do not fabricate a number.** Every figure comes from `report.md` or `dump.json` beside it.
- **Do not read an unresolved delta as a null result.** `fps.deltaMsPerFrame` is a difference of two
  noisy aggregates with a resolution floor near **±0.3 ms/frame** on a 60–80 s arm. Below roughly
  **0.5 ms/frame** the instrument cannot resolve the addon, and "no measurable impact" is then a
  statement about the instrument wearing the clothes of a statement about the addon. The buckets
  measure the addon's own code directly; they are the answer.

```markdown
# Analysis — <YYYYMMDD-HHMMSS>

- **Addon:** <name> <version> (record schema <n>, client interface <n>)
- **Captured:** <YYYY-MM-DD HH:MM> local, label `<label>`
- **Who / where:** <character-realm, level spec class> · <zone — subZone> · <group>
- **Delta:** <±N.NN ms/frame — resolved | unresolved below the floor | one-armed, not computed>
- **Previous capture:** <link to the bundle sorting before this one, or "none — this is the first">

## Headline

<Two or three sentences. What a reader needs if they read nothing else: what the run measured, what
the addon cost, whether the frame-time delta resolved anything, and whether there is anything to act
on.>

## The arms

Both figures come from [`dump.json`](dump.json)'s `fps` block; the rounded forms are in
[`report.md`](report.md).

| Arm | Seconds | Frames | Avg fps | ms/frame |
|---|---|---|---|---|
| active (addon running) | | | | |
| suspended (addon inert) | | | | |
| **delta** | | | | |

<One paragraph: is the delta resolved? A delta inside the floor says the frame-time instrument could
not see the addon, which is a fact about resolution, not about cost. A delta whose sign is backwards
— the suspended arm slower — says the environment moved between the arms, and is the tell for it.
Unequal arm durations are stated here, not passed over: combat gating equalizes duration, never
environment.>

## The buckets — what the addon actually cost

Every figure from [`dump.json`](dump.json)'s `buckets`; `ms/s` is `totalMs` over the **active** arm's
seconds, as [`report.md`](report.md) computes it. Buckets nest — **do not sum the column**.

| Bucket | Calls | Total ms | ms/s | Max ms | Parent |
|---|---|---|---|---|---|
| | | | | | <declared `within`, and whether it was **observed**> |

<Total accounted cost per second of combat, stated once. Then the ratios that survive a change of
combat duration — calls per pass, ms per call — because `totalMs` across two runs of different length
is not a comparison. Any declared parent that was **not observed** is named as an unverified claim
rather than presented as measured containment. Any declared bucket **absent** from the table never
fired, and that is a result about what the run exercised.>

## What the capture did not hold constant

<The environment, from the report's context block and the run log: zone, group, arm durations, the
gap between arms, anything in the log that ran between them. "Nothing — both arms back to back at the
same target, solo" is a real answer and worth stating. This section is why the run log is kept.>

## What moved

<Per-figure deltas against the previous capture, compared on `ms/s` and per-call ratios rather than
raw totals. "First capture — nothing to diff against; every figure above is a baseline reading" if
there is none. A figure that did not move is worth one line saying so; silence reads as "not
checked".>

## Actions

<Numbered, or "None." Each action names the file and what would change. An action with no owner in
the addon's own tracking — an issue, a deviation ID, a review finding — says that it is new here. An
instrumentation gap the capture exposed (an unobserved parent, a bucket that never fires, a hot path
with no bracket) is an action too.>
```

## Step 5 — Refresh `docs/perf-analysis/README.md`

The bundles are frozen; this README is the one file rewritten, and it describes what is **currently**
true:

- What the store is, and that it holds **in-game** captures only — offline runs live in the bundle
  that produced them (`automated-tests-§7`).
- The bundle naming and the three artifacts.
- A short schema summary and a pointer to the library's canonical field-by-field contract. Summarize;
  do not restate the contract, or the collection acquires a second answer that goes stale.
- How a capture is taken, in the addon's own slash verb.
- **The capture index** — one row per bundle: stamp, addon version, label, one line on what it
  measured, and a link. A reader looking for the last capture on a given version should not have to
  open every directory.
- The store is **standing and cumulative** — not tied to one investigation — so captures compare
  across addon versions.

An empty store says so plainly, and says that the gap is real rather than a tooling absence.

## Step 6 — Report

Print: the bundle path and where the stamp came from; the two arms and whether the delta resolved;
the top buckets by `ms/s` and the total accounted cost per second of combat; what moved against the
previous capture; every validation that did not pass; and a reminder that the bundle and the README
are uncommitted changes for the user to review.

## Hard rules

- **Never invent a capture.** No paste, no bundle. Not from the offline scenarios, not from a
  previous run, not from reading the source. A fabricated record is worse than an absent one, because
  it reads as measured — and unlike a fabricated test result, nothing downstream will ever contradict
  it.
- **Never edit a frozen bundle.** If a reading was wrong, the *next* capture's analysis says so.
- **Never rewrite `dump.json`.** Verbatim is what makes it evidence.
- **Never present an unresolved delta as no impact**, and never present a backwards delta as a
  speed-up.
- **Never conflate the two harnesses.** Offline `bytes/iter` and `api/iter` answer a different
  question and belong to `AUTOMATED_TESTS.md`; an in-game capture says nothing about allocation, and
  an offline run says nothing about frame time.
- **Never create the store in an addon with a recorded `performance-§12` exemption.** An empty
  directory in an addon with no combat path is an obligation that can never be discharged.
