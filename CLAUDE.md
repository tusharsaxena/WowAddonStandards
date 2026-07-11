# CLAUDE.md

Guidance for AI agents working in this repository.

## What this repo is

A **research and analysis deliverable** — the house standard for the Ka0s World of Warcraft addon
collection, plus the evidence and remediation plans behind it. It contains **documents only**. No
addon source code lives here.

The audited addons (AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup) live in their
own sibling repositories under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`. **Do not modify those
addons from here** — remediation is a separate, follow-up engagement. This repo only describes what
should change, it does not change it.

## Layout

```
03_STANDARDS.md          -- THE STANDARD (canonical). Everything else supports this.
00_PLAN.md               -- the analysis project's milestone plan
01_CURRENT_STATE.md      -- per-addon snapshot + comparison matrix
02_INDUSTRY_RESEARCH.md  -- patterns from 10 reference addons
04_DEVIATIONS.md         -- per-addon gap report against the standard
05_NEW_ADDON_CONTEXT.md  -- drop-in CLAUDE.md context pack for new addons
06_EXECUTIVE_SUMMARY.md  -- one-page TL;DR (start here to orient)
_raw/                    -- full per-addon evidence; _raw/_industry/ = reference-addon research
remediation/             -- per-addon TECHNICAL_DESIGN + EXECUTION_PLAN; see remediation/README.md
```

Read order for a newcomer: `06_EXECUTIVE_SUMMARY.md` → `03_STANDARDS.md` → the rest as needed.

## Conventions

- **`03_STANDARDS.md` is canonical.** When docs conflict, it wins. It uses section refs like `§4.5`,
  `§9.2` — preserve those when editing.
- **The date `2026-05-03`** in titles and headers is the analysis date, not a path. It is *not* a
  folder anymore — this bundle was flattened to the repo root. When adding cross-references between
  these docs, use plain relative paths (e.g. `03_STANDARDS.md`, `../04_DEVIATIONS.md`), never a
  `2026-05-03/` or `_standards/` prefix.
- **Deviation IDs** are per-addon (AT-*, CM-*, KCD-*, PC-*, WG-*) and referenced across the reports.
  Keep them stable; they are the shared key between `04_DEVIATIONS.md` and the remediation plans.

## Known corrections (read before trusting a finding)

`remediation/README.md` records corrections the design agents surfaced against `04_DEVIATIONS.md`
and `06_EXECUTIVE_SUMMARY.md`. Most important: the "5/5 addons hand-roll `SLASH_*`" finding is
**wrong** — only AbsorbTracker does; the other four already use AceConsole `:RegisterChatCommand`.
Prefer `remediation/README.md` over the original reports where they disagree.

## Editing rules

- Keep documents internally consistent — a change to the standard may ripple into `04_DEVIATIONS.md`,
  the remediation plans, and `06_EXECUTIVE_SUMMARY.md`. Update all affected docs together.
- Don't invent compliance claims. Findings here are evidence-backed (citations in `_raw/`); keep new
  claims sourced the same way.
