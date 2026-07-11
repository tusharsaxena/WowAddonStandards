# WoW Addon Standards — Ka0s Collection

A house standard for the Ka0s World of Warcraft addon collection, plus the periodic audits that
measure the collection against it. The goal: codify what already works across the collection, close
the gaps, and make every future addon **born compliant**.

This repository is a **research and analysis deliverable** — it contains documents only (a standard,
audit reports, and per-addon remediation plans). No addon source code lives here or is modified by
this work.

## Two parts

| Part | What it is |
|---|---|
| [**`standards/`**](standards/) | **The standard** — the canonical, living house rules for all Ka0s addons, plus a drop-in context pack for scaffolding new ones. Evolves in place; versioned via its changelog. |
| [**`audit/`**](audit/) | **The audits** — periodic, point-in-time compliance runs against the standard. Each run is a frozen snapshot under `audit/YYYY-MM-DD/`, with per-addon deviations and remediation plans. |

The standard is the source of truth; the audits are the evidence and the remediation roadmap.

## Start here

New to this? Read the executive summaries:

- [`audit/2026-05-03/00_EXECUTIVE_SUMMARY.md`](audit/2026-05-03/00_EXECUTIVE_SUMMARY.md) — a one-page
  TL;DR of the latest audit: findings, top wins, top risks, and remediation sequencing.
- [`standards/00_EXECUTIVE_SUMMARY.md`](standards/00_EXECUTIVE_SUMMARY.md) — a one-page TL;DR of the
  standard itself.

The canonical output is [`standards/01_STANDARD.md`](standards/01_STANDARD.md) — **the standard**.

## Scope

- **Audited (5):** AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup
- **Researched (10 reference addons):** DBM, BigWigs, Auctionator, Plater, Plumber, Details!,
  WeakAuras, ElvUI, Bagnon, OmniCD

## Layout

```
WowAddonStandards/
  standards/                              -- THE STANDARD (living, canonical)
    00_EXECUTIVE_SUMMARY.md               -- one-page TL;DR of the standard
    01_STANDARD.md                        -- the Ka0s WoW Addon Standard (canonical)
    02_NEW_ADDON_CONTEXT.md               -- drop-in CLAUDE.md context pack for new addons
  audit/                                  -- periodic compliance runs (see audit/README.md)
    2026-05-03/                           -- one dated folder per run (frozen snapshot)
      00_EXECUTIVE_SUMMARY.md             -- one-page TL;DR of this run
      01_PLAN.md                          -- milestone plan
      02_CURRENT_STATE.md                 -- per-addon snapshot + matrix
      03_INDUSTRY_RESEARCH.md             -- 10 reference addons synthesized
      04_DEVIATIONS.md                    -- per-addon gap report + sprints
      _raw/                               -- per-addon evidence (_industry/ = reference research)
      remediation/                        -- per-addon design + execution plans
```

## Using this work

1. Read [`standards/01_STANDARD.md`](standards/01_STANDARD.md) and approve or request edits.
2. Drop [`standards/02_NEW_ADDON_CONTEXT.md`](standards/02_NEW_ADDON_CONTEXT.md) into any new addon's
   `CLAUDE.md` so it starts compliant.
3. Schedule the remediation sprints against
   [`audit/2026-05-03/04_DEVIATIONS.md`](audit/2026-05-03/04_DEVIATIONS.md), executing the per-addon
   plans in [`audit/2026-05-03/remediation/`](audit/2026-05-03/remediation/).
4. Run future audits as new `audit/YYYY-MM-DD/` folders — see [`audit/README.md`](audit/README.md).

## Status

Analysis **complete**. Remediation (actually modifying the addons) is a separate follow-up
engagement, planned but not yet executed.

## License

See [`LICENSE`](LICENSE).
