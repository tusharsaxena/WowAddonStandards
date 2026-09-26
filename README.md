# WoW Addon Standards — Ka0s Collection

This repo holds the house standard for the Ka0s World of Warcraft addon collection. It also holds the
four process playbooks that the `wow-addon` plugin consumes: `AUDIT.md`, `AUTOMATED_TESTS.md`,
`NEW_ADDON.md` and `PERF_ANALYSIS.md`. So it has two jobs.

1. Define the standard. The house standard draws on industry research and on the best patterns
   already in the collection. It covers technical design, and it also covers UX and user-behavior
   patterns: slash-command handling, how the settings panel looks and feels, debug-mode conventions,
   standalone windows, packaging, localization and more. → [`standards/`](standards/)
2. Ship the process playbooks. There are four, each a thin orchestrator spec that the plugin fetches
   and runs **inside each addon's own repo**: → [`AUDIT.md`](AUDIT.md) (`/wow-addon:standards-audit`),
   [`NEW_ADDON.md`](NEW_ADDON.md) (`/wow-addon:new-addon`),
   [`AUTOMATED_TESTS.md`](AUTOMATED_TESTS.md) (`/wow-addon:automated-tests`) and
   [`PERF_ANALYSIS.md`](PERF_ANALYSIS.md) (`/wow-addon:perf-analysis`).

The standard is the source of truth, and it evolves in place. Auditing doesn't happen here any more.
Each addon audits itself, in its own repo, and writes a dated `docs/audits/<YYYY-MM-DD>/` bundle
there. The list of addons that make up the collection lives in one editable place:
[`standards/ADDONS.md`](standards/ADDONS.md).

This repository is a research and analysis deliverable, and it contains only documents. No addon
source code lives here. Nothing done here modifies the addons themselves.

> The plugin that invokes these playbooks lives in a separate repo,
> <https://github.com/tusharsaxena/wow-addon>. That repo, not this one, is where the plugin gets
> updated to consume `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`, `PERF_ANALYSIS.md` and the
> `standards/` docs from here.

## What you can do here

| I want to… | Go to | Playbook |
|---|---|---|
| Refresh or revise the standard | [`standards/`](standards/) | [A, below](#a-refresh-the-standard) |
| Audit an addon for compliance | [`AUDIT.md`](AUDIT.md) | [B, below](#b-audit-an-addon) |
| Start a new addon, born compliant | [`NEW_ADDON.md`](NEW_ADDON.md) | [C, below](#c-start-a-new-addon) |
| Turn an in-game perf capture into evidence | [`PERF_ANALYSIS.md`](PERF_ANALYSIS.md) | [D, below](#d-analyze-an-in-game-perf-capture) |
| Add/remove an addon from the roster | [`standards/ADDONS.md`](standards/ADDONS.md) | edit one table row |
| Harvest learnings from the collection into the standard | [`harvests/`](harvests/) | run `/wow-addon:harvest-standards` |

## Scope

[`standards/ADDONS.md`](standards/ADDONS.md) lists the repos the standard codifies rules for. It is
the single editable roster, split into three tables by repo kind: addons, Ka0s-owned library repos,
and documentation-and-tooling repos. To change the collection's scope, edit that one file.

- In scope are the addons in [`standards/ADDONS.md`](standards/ADDONS.md), currently 11 Ka0s
  addons: Absorb Tracker, Aura Master, Bank Ledger, Consumable Master, KickCD, Loot History,
  Multi Meters, Panel Master, Party Frame Enhanced, Pretty Chat, WhatGroup.
- The Ka0s-owned library repos those addons vendor are in scope too. There is currently 1, LibKa0s.
  A library repo is in scope for the standards process and gets audited, but against library-stack-§7's
  applicability list rather than the addon rule set. It has no TOC, no player-facing README, no
  settings panel and no install, so the addon-shaped sections don't bind it.
- The standard draws on a study of 10 reference addons: DBM, BigWigs, Auctionator, Plater, Plumber,
  Details!, WeakAuras, ElvUI, Bagnon, OmniCD. The research is in
  [`standards/INDUSTRY_RESEARCH.md`](standards/INDUSTRY_RESEARCH.md).

## Start here

New to this? Read [`standards/EXECUTIVE_SUMMARY.md`](standards/EXECUTIVE_SUMMARY.md) first. It is a
one-page TL;DR of the standard. The canonical output is
[`standards/STANDARDS.md`](standards/STANDARDS.md), which is the standard itself.

---

## A. Refresh the standard

This is how the living house rules get revised. The full, authoritative steps are in
[`standards/README.md`](standards/README.md). In outline:

1. Refresh the research. Re-survey the reference addons, adding or dropping some as needed, then
   update [`standards/INDUSTRY_RESEARCH.md`](standards/INDUSTRY_RESEARCH.md) and its
   `standards/_raw/_industry/` reports.
2. Read the collection's current state. For each in-scope addon in
   [`standards/ADDONS.md`](standards/ADDONS.md), pull that addon's most recent
   `docs/audits/<date>/01_CURRENT_STATE.md` from its own repo. It tells you what the addon does today.
3. Fold both inputs into [`standards/STANDARDS.md`](standards/STANDARDS.md) as MUST/SHOULD/MAY
   rules. Each rule gets a rationale and a reference implementation. Keep each section's local
   numbering and the `filename-§N` cross-reference scheme intact.
4. Bump the changelog: update the version and date at the top of `STANDARDS.md`.
5. Ripple the change into [`standards/EXECUTIVE_SUMMARY.md`](standards/EXECUTIVE_SUMMARY.md) and
   [`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md) so they stay in sync.

## B. Audit an addon

An audit measures one addon against the current standard. You run it **in that addon's own repo**,
and [`AUDIT.md`](AUDIT.md) has the full, authoritative steps. Roughly:

1. Run `/wow-addon:standards-audit` in the addon's repo.
2. The command resolves the current [`standards/STANDARDS.md`](standards/STANDARDS.md), snapshots the
   addon, and writes a frozen, dated bundle to that repo's `docs/audits/<today>/`. The bundle holds
   `01_CURRENT_STATE`, `02_DEVIATIONS` (with stable deviation IDs), `03_EVIDENCE`,
   `04_TECHNICAL_DESIGN` and `05_EXECUTION_PLAN`.
3. The audit is read-only. It produces a remediation plan, and carrying that plan out is a separate
   engagement.

## C. Start a new addon

Use this to scaffold a new Ka0s addon that is compliant from day one. The full walkthrough is
[`NEW_ADDON.md`](NEW_ADDON.md). In short, you run `/wow-addon:new-addon` to scaffold the Ace3
skeleton, then build against the standard, working from the
[`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md) pack. That pack is fetched to a
temp directory and **never** written into the addon (documentation-§3). You also add the addon's row
to [`standards/ADDONS.md`](standards/ADDONS.md).

A born-compliant addon ships three root docs plus `LICENSE`: a full `README.md`, a stub `CLAUDE.md`
and `DEPENDENCIES.md` (documentation-§7). Beneath them sits the canonical `docs/` trio:
`ARCHITECTURE.md`, `testing.md` and `smoke-tests.md`.

## D. Analyze an in-game perf capture

A player takes a capture in a live client, and this playbook turns it into committed evidence. It
also runs **in that addon's own repo**, and [`PERF_ANALYSIS.md`](PERF_ANALYSIS.md) is where the
full, authoritative steps live.

In short, run `/wow-addon:perf-analysis` with the paste of `/<slash> perf report` **and**
`/<slash> perf dump`. The command splits, validates and stamps them into a frozen
`docs/perf-analysis/<YYYYMMDD-HHMMSS>/` bundle. That bundle holds `report.md`, a verbatim one-line
`dump.json`, and an `ANALYSIS.md` written to the playbook's uniform prompt. The command also
refreshes the store's `README.md` and its capture index. Nothing is ever recorded in this repo, and
a capture is never invented. No paste means no bundle.

---

## Layout

```
WowAddonStandards/
  AUDIT.md                                -- PLAYBOOK: /wow-addon:standards-audit (per-addon self-audit)
  AUTOMATED_TESTS.md                      -- PLAYBOOK: /wow-addon:automated-tests (per-addon test record)
  NEW_ADDON.md                            -- PLAYBOOK: /wow-addon:new-addon (scaffold, born compliant)
  PERF_ANALYSIS.md                        -- PLAYBOOK: /wow-addon:perf-analysis (per-addon in-game capture bundle)
  README.md                               -- this file
  CLAUDE.md                               -- guidance for AI agents
  DEPENDENCIES.md                         -- toolchain contract (documentation-§7): git only, and why the rest is absent
  docs/ARCHITECTURE.md                    -- how this repo is put together + the deviation register (documentation-§3, reduced by §8)
  LICENSE
  .gitattributes                          -- line-ending policy: the non-client canonical body, LF (line-endings-§2/§5)
  standards/                              -- THE STANDARD (living, canonical)
    README.md                             -- what's here + how to refresh the standard
    EXECUTIVE_SUMMARY.md                  -- one-page TL;DR of the standard
    STANDARDS.md                          -- the Ka0s WoW Addon Standard: index/entry point + Sections map (canonical)
    standards/                            -- the standard's sections, one unnumbered file each (layout.md, ...)
    NEW_ADDON_CONTEXT.md                  -- new-addon kickstart pack; fetched at runtime, never stored in an addon
    INDUSTRY_RESEARCH.md                  -- research foundation: 10 reference addons synthesized
    ADDONS.md                             -- THE ROSTER: editable list of in-scope addons
    _raw/_industry/                       -- per-addon raw research reports (evidence)
  harvests/                               -- frozen collection-harvest bundles, one <YYYY-MM-DD>/ per pass
  media/logos/                            -- the Ka0s collection logo art (an addon README displays no logo: documentation-§1)
```

Audit and review runs are not stored here. Audits live under each addon's own
`docs/audits/<YYYY-MM-DD>/`, and reviews under its `docs/reviews/<YYYY-MM-DD>/`
(audit-review-history).

## Status

The standard is at **v2.69.0** and is a living document. Compliance auditing has moved out of
this repo and into each addon's own repository. The `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`
and `PERF_ANALYSIS.md` playbooks drive it, and the `wow-addon` plugin is what consumes them.

## License

See [`LICENSE`](LICENSE).
