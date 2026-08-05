# WoW Addon Standards — Ka0s Collection

This repo holds the house standard for the Ka0s World of Warcraft addon collection, plus the three
**process playbooks** the `wow-addon` plugin consumes — `AUDIT.md`, `AUTOMATED_TESTS.md` and
`NEW_ADDON.md`:

1. **Define the standard.** A detailed house standard — built from industry research and the
   collection's own best patterns — covering not just technical design but **UX and user-behavior
   patterns**: slash-command handling, settings-panel look and feel, debug-mode conventions,
   standalone windows, packaging, localization, and more. → [`standards/`](standards/)
2. **Ship the process playbooks.** Three thin orchestrator specs the plugin fetches and runs **inside
   each addon's own repo**: → [`AUDIT.md`](AUDIT.md) (`/wow-addon:standards-audit`),
   [`NEW_ADDON.md`](NEW_ADDON.md) (`/wow-addon:new-addon`) and
   [`AUTOMATED_TESTS.md`](AUTOMATED_TESTS.md) (`/wow-addon:automated-tests`).

The standard is the source of truth and evolves in place. **Auditing no longer happens here** — each
addon audits *itself*, in its own repo, writing a dated `docs/audits/<YYYY-MM-DD>/` bundle there. Which
addons make up the collection is defined in one editable place: [`standards/ADDONS.md`](standards/ADDONS.md).

This repository is a **research and analysis deliverable** — it contains documents only. No addon
source code lives here, and this work never modifies the addons themselves.

> The plugin that invokes these playbooks lives in a **separate repo**,
> <https://github.com/tusharsaxena/wow-addon>, and is updated there to consume `AUDIT.md` /
> `AUTOMATED_TESTS.md` / `NEW_ADDON.md` and the `standards/` docs from here.

## The three things you can do here

| I want to… | Go to | Playbook |
|---|---|---|
| Refresh or revise the standard | [`standards/`](standards/) | [A, below](#a-refresh-the-standard) |
| Audit an addon for compliance | [`AUDIT.md`](AUDIT.md) | [B, below](#b-audit-an-addon) |
| Start a new addon, born compliant | [`NEW_ADDON.md`](NEW_ADDON.md) | [C, below](#c-start-a-new-addon) |
| Add/remove an addon from the roster | [`standards/ADDONS.md`](standards/ADDONS.md) | edit one table row |

## Scope

The addons the standard codifies rules for are listed in
**[`standards/ADDONS.md`](standards/ADDONS.md)** — the single, editable roster. Edit that one file to
change collection scope.

- **In scope:** see [`standards/ADDONS.md`](standards/ADDONS.md) — currently 8 Ka0s addons: Absorb
  Tracker, Bank Ledger, Consumable Master, KickCD, Loot History, Panel Master, Pretty Chat, WhatGroup.
- **Reference addons studied for the standard (10):** DBM, BigWigs, Auctionator, Plater, Plumber,
  Details!, WeakAuras, ElvUI, Bagnon, OmniCD — see
  [`standards/INDUSTRY_RESEARCH.md`](standards/INDUSTRY_RESEARCH.md).

## Start here

New to this? Read [`standards/EXECUTIVE_SUMMARY.md`](standards/EXECUTIVE_SUMMARY.md) — the
one-page TL;DR of the standard. The canonical output is
[`standards/STANDARDS.md`](standards/STANDARDS.md) — **the standard**.

---

## A. Refresh the standard

Revise the living house rules. Full, authoritative steps: [`standards/README.md`](standards/README.md).
At a glance:

1. **Refresh the research.** Re-survey the reference addons (add/remove as needed) and update
   [`standards/INDUSTRY_RESEARCH.md`](standards/INDUSTRY_RESEARCH.md) + its
   `standards/_raw/_industry/` reports.
2. **Read the collection's current state.** For the in-scope addons in
   [`standards/ADDONS.md`](standards/ADDONS.md), pull each addon's own most-recent
   `docs/audits/<date>/01_CURRENT_STATE.md` (in its repo) for what it does today.
3. **Synthesize into the rules.** Fold both inputs into
   [`standards/STANDARDS.md`](standards/STANDARDS.md) as MUST/SHOULD/MAY rules, each with a
   rationale and a reference implementation. Preserve each section's local numbering and the
   `filename-§N` cross-reference scheme.
4. **Bump the changelog.** Update the version + date at the top of `STANDARDS.md`.
5. **Ripple the change.** Sync [`standards/EXECUTIVE_SUMMARY.md`](standards/EXECUTIVE_SUMMARY.md)
   and [`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md).

## B. Audit an addon

Measure one addon against the current standard — run **in that addon's own repo**. Full,
authoritative steps: [`AUDIT.md`](AUDIT.md). At a glance:

1. Run `/wow-addon:standards-audit` in the addon's repo.
2. It resolves the current [`standards/STANDARDS.md`](standards/STANDARDS.md), snapshots the
   addon, and writes a **frozen** dated bundle to that repo's `docs/audits/<today>/`:
   `01_CURRENT_STATE`, `02_DEVIATIONS` (stable deviation IDs), `03_EVIDENCE`, `04_TECHNICAL_DESIGN`,
   `05_EXECUTION_PLAN`.
3. The audit is **read-only** — it produces a remediation plan; executing it is a separate engagement.

## C. Start a new addon

Scaffold a new Ka0s addon that is compliant from day one. Full walkthrough: [`NEW_ADDON.md`](NEW_ADDON.md).
In short: run `/wow-addon:new-addon` to scaffold the Ace3 skeleton, build against the standard
working from the [`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md) pack — which is
fetched to a temp directory and **never** written into the addon (documentation-§3), and add the addon's row to [`standards/ADDONS.md`](standards/ADDONS.md). A born-compliant addon ships three root docs plus `LICENSE` — a full `README.md`, a stub `CLAUDE.md`, and `DEPENDENCIES.md` (documentation-§7) — over the canonical `docs/` trio (`ARCHITECTURE.md`, `testing.md`, `smoke-tests.md`).

---

## Layout

```
WowAddonStandards/
  AUDIT.md                                -- PLAYBOOK: /wow-addon:standards-audit (per-addon self-audit)
  AUTOMATED_TESTS.md                      -- PLAYBOOK: /wow-addon:automated-tests (per-addon test record)
  NEW_ADDON.md                            -- PLAYBOOK: /wow-addon:new-addon (scaffold, born compliant)
  README.md                               -- this file
  CLAUDE.md                               -- guidance for AI agents
  LICENSE
  standards/                              -- THE STANDARD (living, canonical)
    README.md                             -- what's here + how to refresh the standard
    EXECUTIVE_SUMMARY.md               -- one-page TL;DR of the standard
    STANDARDS.md                        -- the Ka0s WoW Addon Standard: index/entry point + Sections map (canonical)
    standards/                          -- the standard's sections, one unnumbered file each (layout.md, ...)
    NEW_ADDON_CONTEXT.md               -- new-addon kickstart pack; fetched at runtime, never stored in an addon
    INDUSTRY_RESEARCH.md               -- research foundation: 10 reference addons synthesized
    ADDONS.md                             -- THE ROSTER: editable list of in-scope addons
    _raw/_industry/                       -- per-addon raw research reports (evidence)
```

Audit and review runs are **not** stored here — each lives under its own addon's `docs/audits/<YYYY-MM-DD>/` and `docs/reviews/<YYYY-MM-DD>/` (audit-review-history).

## Status

Standard is at **v2.22.0** and living. Compliance auditing has moved out of this repo into each addon's
own repository, driven by the `AUDIT.md` / `AUTOMATED_TESTS.md` / `NEW_ADDON.md` playbooks that the
`wow-addon` plugin consumes.

## License

See [`LICENSE`](LICENSE).
