# The Standard

The **living, canonical** half of this repo: the house rules for the Ka0s WoW addon collection,
the research they are built on, and a drop-in context pack for scaffolding new addons. The other
half, [`../audit/`](../audit/), only *measures* addons against what lives here — it does not define
the rules.

## What's in here

| File | Role |
|---|---|
| [`00_EXECUTIVE_SUMMARY.md`](00_EXECUTIVE_SUMMARY.md) | One-page TL;DR of the standard. |
| [`01_STANDARD.md`](01_STANDARD.md) | **The standard** — canonical. Everything else supports this. Versioned via the changelog at its top. |
| [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md) | Drop-in `CLAUDE.md` context pack — paste into a new addon so it is born compliant. |
| [`03_INDUSTRY_RESEARCH.md`](03_INDUSTRY_RESEARCH.md) | The research foundation: synthesized patterns from 10 reference addons that justify the rules. |
| [`_raw/_industry/`](_raw/_industry/) | Per-addon raw research reports — the evidence base behind `03_INDUSTRY_RESEARCH.md`. |

`01_STANDARD.md` is the source of truth. When any document here disagrees with it, it wins.

## Living, not frozen

The standard **evolves in place**. Every substantive change bumps the version + date and adds a
changelog entry at the top of `01_STANDARD.md`; git history carries the rest. This is the opposite of
an audit run, which is a frozen dated snapshot under `audit/YYYY-MM-DD/` and is never edited after the
fact. Industry research lives here, with the standard, precisely because it is a *living input* to the
rules — not a point-in-time compliance measurement.

## How to (re)build `01_STANDARD.md`

The standard is a **synthesis** of two inputs:

1. **Industry research** — what the wider ecosystem converged on (and what to avoid).
   Captured in [`03_INDUSTRY_RESEARCH.md`](03_INDUSTRY_RESEARCH.md), backed by
   [`_raw/_industry/`](_raw/_industry/).
2. **The collection's current state** — what the Ka0s addons actually do today, and which of those
   habits are worth codifying. *Which* addons make up "the collection" is defined by the roster,
   [`../ADDONS.md`](../ADDONS.md). Their current state is captured by an audit run — per addon in
   `audit/<date>/<Addon>/01_CURRENT_STATE.md`, with the cross-addon comparison in that run's
   `00_EXECUTIVE_SUMMARY.md`; mine the most recent run.

### Rebuild steps

1. **Refresh the research.** Re-survey the reference addons (or add/remove some) and update
   `03_INDUSTRY_RESEARCH.md` and its `_raw/_industry/` reports. Note convergent patterns (adopt) vs
   anti-patterns (reject), with evidence links.
2. **Read the collection's current state.** The in-scope addons are those in
   [`../ADDONS.md`](../ADDONS.md); pull the latest run's per-addon
   `audit/<date>/<Addon>/01_CURRENT_STATE.md` files (plus the comparison matrix in its
   `00_EXECUTIVE_SUMMARY.md`) for what they do now and which decisions are still open. (The legacy
   `2026-05-03/` run keeps this in a single `02_CURRENT_STATE.md`.)
3. **Synthesize / revise.** Fold both inputs into `01_STANDARD.md` as prescriptive rules
   (MUST / SHOULD / MAY), each with a rationale and, where possible, a **reference implementation**
   from the collection or a cited industry source. Preserve the `§`-section numbering — other
   documents reference it.
4. **Bump the changelog.** Update the version + date and add a changelog entry at the top of
   `01_STANDARD.md` describing what changed and why.
5. **Ripple the change.** A rule change usually touches
   [`00_EXECUTIVE_SUMMARY.md`](00_EXECUTIVE_SUMMARY.md) and
   [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md); keep them in sync. Existing audit runs stay
   frozen — the *next* audit is what re-measures the collection against the revised standard.

### Where audits fit

An audit does **not** build the standard. It takes the then-current `01_STANDARD.md` as fixed and
checks every addon against it, producing per-addon deviations and remediation plans. The one thing an
audit feeds back is observation: its per-addon current-state docs are an input to step 2 above, and a
deviation that turns out to be *industry-aligned* is a signal to revise the standard rather than the
addon. See [`../audit/README.md`](../audit/README.md).
