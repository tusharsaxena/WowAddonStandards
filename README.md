# WoW Addon Standards — Ka0s Collection

A house standard for the Ka0s World of Warcraft addon collection, derived from an audit of the
existing addons and research into how the leading addons in the ecosystem are built. The goal:
codify what already works across the collection, close the gaps, and make every future addon
**born compliant**.

This repository is a **research and analysis deliverable** — it contains reports, a standard, and
per-addon remediation plans. No addon source code lives here or is modified by this work.

## Scope

- **Audited (5):** AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup
- **Researched (10 reference addons):** DBM, BigWigs, Auctionator, Plater, Plumber, Details!,
  WeakAuras, ElvUI, Bagnon, OmniCD

## Start here

New to this? Read [`06_EXECUTIVE_SUMMARY.md`](06_EXECUTIVE_SUMMARY.md) — a one-page TL;DR of the
findings, top wins, top risks, and the recommended remediation sequencing.

The canonical output is [`03_STANDARDS.md`](03_STANDARDS.md) — **the standard** itself.

## Documents

| File | What it is |
|---|---|
| [`00_PLAN.md`](00_PLAN.md) | The approved milestone plan for the analysis project |
| [`01_CURRENT_STATE.md`](01_CURRENT_STATE.md) | Per-addon current-state snapshot and comparison matrix |
| [`02_INDUSTRY_RESEARCH.md`](02_INDUSTRY_RESEARCH.md) | Patterns synthesized from the 10 reference addons |
| [`03_STANDARDS.md`](03_STANDARDS.md) | **The Ka0s WoW Addon Standard** (canonical, v1.0) |
| [`04_DEVIATIONS.md`](04_DEVIATIONS.md) | Per-addon gap report against the standard, with remediation sprints |
| [`05_NEW_ADDON_CONTEXT.md`](05_NEW_ADDON_CONTEXT.md) | Drop-in `CLAUDE.md` context pack for scaffolding new addons |
| [`06_EXECUTIVE_SUMMARY.md`](06_EXECUTIVE_SUMMARY.md) | One-page executive summary |

### Supporting material

- **[`_raw/`](_raw/)** — full per-addon evidence behind `01_CURRENT_STATE.md`, plus
  **[`_raw/_industry/`](_raw/_industry/)** — the raw research report for each of the 10 reference addons.
- **[`remediation/`](remediation/)** — per-addon technical designs (HLD+LLD) and subagent-ready,
  checkbox-tracked execution plans for bringing each addon to full compliance. See
  [`remediation/README.md`](remediation/README.md) for the index and cross-cutting sequencing.

## Layout

```
WowAddonStandards/
  00_PLAN.md … 06_EXECUTIVE_SUMMARY.md   -- the report set (read in order)
  _raw/                                   -- per-addon evidence
    _industry/                            -- 10 reference-addon raw reports
  remediation/                            -- per-addon design + execution plans
    <Addon>/TECHNICAL_DESIGN_<Addon>.md
    <Addon>/EXECUTION_PLAN_<Addon>.md
```

## Using this work

1. Read [`03_STANDARDS.md`](03_STANDARDS.md) and approve or request edits.
2. Drop [`05_NEW_ADDON_CONTEXT.md`](05_NEW_ADDON_CONTEXT.md) into any new addon's `CLAUDE.md` so it
   starts compliant.
3. Schedule the remediation sprints against [`04_DEVIATIONS.md`](04_DEVIATIONS.md), executing the
   per-addon plans in [`remediation/`](remediation/).

## Status

Analysis **complete**. Remediation (actually modifying the addons) is a separate follow-up
engagement, planned but not yet executed.

## License

See [`LICENSE`](LICENSE).
