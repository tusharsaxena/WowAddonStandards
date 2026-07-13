# The Standard

The **living, canonical** core of this repo: the house rules for the Ka0s WoW addon collection,
the research they are built on, the [roster](ADDONS.md) of in-scope addons, and a drop-in context
pack for scaffolding new addons. Compliance auditing is **not** run from here — each addon audits
**itself**, in its own repo, via `/wow-addon:standards-audit` (playbook: [`../AUDIT.md`](../AUDIT.md)).

## What's in here

| File | Role |
|---|---|
| [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) | One-page TL;DR of the standard. |
| [`STANDARDS.md`](STANDARDS.md) | **The standard** — canonical. Everything else supports this. Versioned via the changelog at its top. |
| [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md) | Drop-in `CLAUDE.md` context pack — paste into a new addon so it is born compliant. |
| [`INDUSTRY_RESEARCH.md`](INDUSTRY_RESEARCH.md) | The research foundation: synthesized patterns from 10 reference addons that justify the rules. |
| [`ADDONS.md`](ADDONS.md) | **The roster** — the editable list of in-scope Ka0s addons; a standards-process input. |
| [`_raw/_industry/`](_raw/_industry/) | Per-addon raw research reports — the evidence base behind `INDUSTRY_RESEARCH.md`. |

The two **process playbooks** live at the repo root (predictable paths for the `wow-addon` plugin to
fetch): [`../AUDIT.md`](../AUDIT.md) (`/wow-addon:standards-audit`) and
[`../NEW_ADDON.md`](../NEW_ADDON.md) (`/wow-addon:new-addon`). Each is a thin orchestrator that draws
its substance from the docs above.

`STANDARDS.md` is the source of truth. When any document here disagrees with it, it wins.

## Living, not frozen

The standard **evolves in place**. Every substantive change bumps the version + date and adds a
changelog entry at the top of `STANDARDS.md`; git history carries the rest. This is the opposite of
an audit run, which is a frozen dated snapshot under an addon's own `docs/audits/YYYY-MM-DD/` and is never
edited after the fact. Industry research lives here, with the standard, precisely because it is a
*living input* to the rules — not a point-in-time compliance measurement.

## How to (re)build `STANDARDS.md`

The standard is a **synthesis** of two inputs:

1. **Industry research** — what the wider ecosystem converged on (and what to avoid).
   Captured in [`INDUSTRY_RESEARCH.md`](INDUSTRY_RESEARCH.md), backed by
   [`_raw/_industry/`](_raw/_industry/).
2. **The collection's current state** — what the Ka0s addons actually do today, and which of those
   habits are worth codifying. *Which* addons make up "the collection" is defined by the roster,
   [`ADDONS.md`](ADDONS.md). Their current state is captured by each addon's own most-recent audit run
   (`/wow-addon:standards-audit` in that addon's repo) — mine its `docs/audits/<date>/01_CURRENT_STATE.md`.

### Rebuild steps

1. **Refresh the research.** Re-survey the reference addons (or add/remove some) and update
   `INDUSTRY_RESEARCH.md` and its `_raw/_industry/` reports. Note convergent patterns (adopt) vs
   anti-patterns (reject), with evidence links.
2. **Read the collection's current state.** The in-scope addons are those in
   [`ADDONS.md`](ADDONS.md); in each addon's repo, pull its latest
   `docs/audits/<date>/01_CURRENT_STATE.md` (and `02_DEVIATIONS.md`) for what it does now and which
   decisions are still open. Run `/wow-addon:standards-audit` first if an addon has no recent run.
3. **Synthesize / revise.** Fold both inputs into `STANDARDS.md` as prescriptive rules
   (MUST / SHOULD / MAY), each with a rationale and, where possible, a **reference implementation**
   from the collection or a cited industry source. Preserve each section's local numbering and the
   `filename-§N` cross-reference scheme — other documents reference it.
4. **Bump the changelog.** Update the version + date and add a changelog entry at the top of
   `STANDARDS.md` describing what changed and why.
5. **Ripple the change.** A rule change usually touches
   [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) and
   [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md); keep them in sync. Existing audit runs (in the
   addons' own repos) stay frozen — each addon's *next* audit re-measures it against the revised standard.

### Where audits fit

An audit does **not** build the standard. Run per addon in its own repo, it takes the then-current
`STANDARDS.md` as fixed and checks that addon against it, producing deviations and a remediation
plan under `docs/audits/<date>/`. The one thing an audit feeds back is observation: an addon's current-state
doc is an input to step 2 above, and a deviation that turns out to be *industry-aligned* is a signal
to revise the standard rather than the addon. See the [`../AUDIT.md`](../AUDIT.md) playbook.
