# Standards Audit — Playbook

**Invoked by `/wow-addon:standards-audit`.** This is the step-by-step spec for auditing **one addon
repo** against the Ka0s WoW Addon Standard. It runs **inside the addon's own repository** and writes
its output there — this `WowAddonStandards` repo holds only the rules and this playbook, never an
addon's audit results.

The rules being audited against are canonical in
[`standards/STANDARDS.md`](standards/STANDARDS.md) (its section files and the `anti-patterns`
list). This playbook says *how to run the audit and where to put the results*; the standard says
*what to check*.

## What an audit is

A **read-only** compliance measurement: it snapshots the addon, measures it against the then-current
standard, catalogues every deviation with evidence, and produces a remediation **plan**. An audit
**never modifies addon code** — remediation is a separate, follow-up engagement that executes the
plan this audit writes.

Each run is a **frozen, point-in-time snapshot**. A new audit never edits an old one — it drops a new
dated folder beside it.

## Output structure

Everything lands under the audited addon's own repo, in a single dated folder under `docs/`:

```
<REPO_ROOT>/docs/audits/<YYYY-MM-DD>/
  01_CURRENT_STATE.md      -- snapshot of the addon against the standard (what it does today)
  02_DEVIATIONS.md         -- gap report: every deviation, each with a stable ID (see below)
  03_EVIDENCE.md           -- compliance evidence, file:line citations backing each finding
  04_TECHNICAL_DESIGN.md   -- remediation design (how to close the gaps)
  05_EXECUTION_PLAN.md     -- ordered remediation steps (what to change, in what order)
```

The folder is **flat** — one addon per repo, so there are no per-addon subfolders. `<YYYY-MM-DD>` is
the run date; if a folder for today already exists, either append to that run or start tomorrow's —
never overwrite a prior run.

### Deviation IDs

Each deviation in `02_DEVIATIONS.md` gets a **stable ID** with a short per-addon prefix (2–3 letters
from the addon name, e.g. `AT-*` for Absorb Tracker, `CM-*` for Consumable Master). IDs are the
shared key between `02_DEVIATIONS.md` and the remediation plans (`04_TECHNICAL_DESIGN.md` /
`05_EXECUTION_PLAN.md`) — **keep them stable across runs**: a deviation that persists keeps its ID.
Assign the addon a prefix on its first audit and reuse it thereafter.

## Steps

1. **Resolve the standard.** Read the canonical rules from `standards/STANDARDS.md` in the
   `WowAddonStandards` repo (the addon's TOC `## X-Standard:` URL points here). Use the current
   version — note it (e.g. "audited against v1.0.0") in `01_CURRENT_STATE.md` so the run is reproducible.
2. **Create the run folder.** `<REPO_ROOT>/docs/audits/<today>/`. Never edit an existing run's folder.
3. **Snapshot current state** → `01_CURRENT_STATE.md`. Walk the addon section by section (layout,
   TOC, libraries, patterns, settings, slash, debug, tests, packaging, docs) and record what it does
   now, citing files.
4. **Measure against every section + anti-pattern.** Go through each section of the standard and the
   `anti-patterns` list. For each MUST/SHOULD it fails or partially meets, record a deviation.
5. **Catalogue deviations** → `02_DEVIATIONS.md`. One row/entry per gap: the ID, the section violated,
   MUST/SHOULD severity, a one-line description, and the fix direction.
6. **Back every finding with evidence** → `03_EVIDENCE.md`. `file:line` citations that prove each
   deviation (and each compliance claim). Don't assert without a citation.
7. **Design the remediation** → `04_TECHNICAL_DESIGN.md`. How to close the gaps: the modules/files to
   touch, the shape of the change, risks, and any ordering constraints. Reference deviation IDs.
8. **Plan the execution** → `05_EXECUTION_PLAN.md`. Ordered, checkable remediation steps grouped into
   sensible sprints, each step tied to its deviation ID(s). This is the hand-off to the separate
   remediation engagement.

## Hard rules

- **Read-only.** The audit produces documents only; it does not change addon code, TOC, or config.
- **Frozen runs.** Never edit a prior `docs/audits/<date>/`; a re-audit is a new dated folder.
- **Sourced findings.** Every deviation cites `file:line` evidence — no unsourced compliance claims.
- **Stable IDs.** A deviation that recurs across runs keeps its ID and prefix.
- **The standard wins.** When this playbook and `standards/STANDARDS.md` disagree on *what* to
  check, the standard is canonical; this playbook governs only *how* the run is structured.
