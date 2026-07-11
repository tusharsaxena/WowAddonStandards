# CLAUDE.md

Guidance for AI agents working in this repository.

## What this repo is

A **research and analysis deliverable** — the house standard for the Ka0s World of Warcraft addon
collection, plus the periodic audits (evidence and remediation plans) that measure the collection
against it. It contains **documents only**. No addon source code lives here.

The audited addons (AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup) live in their
own sibling repositories under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`. **Do not modify those
addons from here** — remediation is a separate, follow-up engagement. This repo only describes what
should change, it does not change it.

## Two-part layout

The repo is split into the **standard** (canonical, living) and the **audits** (periodic, frozen).

```
standards/                          -- THE STANDARD (living, canonical). Everything supports 01_STANDARD.md.
  00_EXECUTIVE_SUMMARY.md           -- one-page TL;DR of the standard
  01_STANDARD.md                    -- THE STANDARD (canonical)
  02_NEW_ADDON_CONTEXT.md           -- drop-in CLAUDE.md context pack for new addons
audit/                              -- periodic compliance runs; see audit/README.md
  <YYYY-MM-DD>/                     -- one dated folder per run (frozen snapshot)
    00_EXECUTIVE_SUMMARY.md         -- one-page TL;DR of this run (start here to orient)
    01_PLAN.md                      -- this run's milestone plan
    02_CURRENT_STATE.md             -- per-addon snapshot + comparison matrix
    03_INDUSTRY_RESEARCH.md         -- patterns from 10 reference addons
    04_DEVIATIONS.md                -- per-addon gap report against the standard
    _raw/                           -- full per-addon evidence; _raw/_industry/ = reference research
    remediation/                    -- per-addon TECHNICAL_DESIGN + EXECUTION_PLAN; see remediation/README.md
```

The only audit run so far is `audit/2026-05-03/`.

Read order for a newcomer: `audit/2026-05-03/00_EXECUTIVE_SUMMARY.md` → `standards/01_STANDARD.md` →
the rest as needed.

## Conventions

- **`standards/01_STANDARD.md` is canonical.** When docs conflict, it wins. It uses section refs like
  `§4.5`, `§9.2` — preserve those when editing.
- **The standard is living; audits are frozen.** `standards/` evolves in place (versioned via the
  changelog at the top of `01_STANDARD.md` and git history). Each audit is a point-in-time snapshot
  under `audit/YYYY-MM-DD/` — never edit an old run to reflect new findings; add a new dated folder
  instead (see `audit/README.md`).
- **The date `2026-05-03`** is an audit-run identifier: it **is** the folder name for that run, and it
  also appears in that run's document titles/headers. (Note: this repo previously flattened everything
  to the root with no dated folder — that is no longer true; audits are dated folders again.)
- **Cross-references** use plain relative paths. From an audit doc to the standard:
  `../../standards/01_STANDARD.md`. Within an audit run: `04_DEVIATIONS.md`, `remediation/README.md`.
  From `standards/` to an audit: `../audit/<date>/…`. The standard itself should reference audit
  concepts generically (e.g. "the deviation report") rather than hard-linking one dated run.
- **Deviation IDs** are per-addon (AT-*, CM-*, KCD-*, PC-*, WG-*) and referenced across the reports.
  Keep them stable; they are the shared key between a run's `04_DEVIATIONS.md` and its remediation plans.

## Known corrections (read before trusting a finding)

`audit/2026-05-03/remediation/README.md` records corrections the design agents surfaced against that
run's `04_DEVIATIONS.md` and `00_EXECUTIVE_SUMMARY.md`. Most important: the "5/5 addons hand-roll
`SLASH_*`" finding is **wrong** — only AbsorbTracker does; the other four already use AceConsole
`:RegisterChatCommand`. Prefer `remediation/README.md` over the original reports where they disagree.

## Editing rules

- Keep documents internally consistent — a change to the standard may ripple into an audit run's
  `04_DEVIATIONS.md`, its remediation plans, and both `00_EXECUTIVE_SUMMARY.md` files. Update all
  affected docs together.
- Don't invent compliance claims. Findings here are evidence-backed (citations in a run's `_raw/`);
  keep new claims sourced the same way.
