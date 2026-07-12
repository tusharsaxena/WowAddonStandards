# WoW Addon Standards — Ka0s Collection

This repo does two things for the Ka0s World of Warcraft addon collection:

1. **Define the standard.** A detailed house standard — built from industry research and the
   collection's own best patterns — covering not just technical design but **UX and user-behavior
   patterns**: slash-command handling, settings-panel look and feel, debug-mode conventions,
   standalone windows, packaging, localization, and more. → [`standards/`](standards/)
2. **Audit against it.** Periodic compliance runs that measure every in-scope addon against the
   standard, catalogue the deviations, and produce a per-addon remediation plan. → [`audit/`](audit/)

The two are **independent processes** on a shared subject. The standard is the source of truth and
evolves in place; each audit is a frozen, point-in-time snapshot. Which addons both processes apply
to is defined in **one editable place**: [`ADDONS.md`](ADDONS.md).

This repository is a **research and analysis deliverable** — it contains documents only. No addon
source code lives here, and this work never modifies the addons themselves (remediation is a separate
follow-up engagement).

## The three things you can do here

| I want to… | Go to | Playbook |
|---|---|---|
| Add/remove an addon from scope | [`ADDONS.md`](ADDONS.md) | edit one table row |
| Refresh or revise the standard | [`standards/`](standards/) | [A, below](#a-refresh-the-standard) |
| Audit the addons for compliance | [`audit/`](audit/) | [B, below](#b-run-an-audit) |
| Start a new addon, born compliant | [`standards/02_NEW_ADDON_CONTEXT.md`](standards/02_NEW_ADDON_CONTEXT.md) | [C, below](#c-start-a-new-addon) |

## Scope

The addons both processes apply to are listed in **[`ADDONS.md`](ADDONS.md)** — the single, editable
roster. Edit that one file to change scope.

- **In scope:** see [`ADDONS.md`](ADDONS.md) (currently 6 Ka0s addons).
- **Reference addons studied for the standard (10):** DBM, BigWigs, Auctionator, Plater, Plumber,
  Details!, WeakAuras, ElvUI, Bagnon, OmniCD — see
  [`standards/03_INDUSTRY_RESEARCH.md`](standards/03_INDUSTRY_RESEARCH.md).

## Start here

New to this? Read the two executive summaries:

- [`standards/00_EXECUTIVE_SUMMARY.md`](standards/00_EXECUTIVE_SUMMARY.md) — one-page TL;DR of the
  standard itself.
- [`audit/2026-05-03/00_EXECUTIVE_SUMMARY.md`](audit/2026-05-03/00_EXECUTIVE_SUMMARY.md) — one-page
  TL;DR of the latest audit run: findings, top wins, top risks, remediation sequencing.

The canonical output is [`standards/01_STANDARD.md`](standards/01_STANDARD.md) — **the standard**.

---

## A. Refresh the standard

Revise the living house rules. Full, authoritative steps: [`standards/README.md`](standards/README.md).
At a glance:

1. **Refresh the research.** Re-survey the reference addons (add/remove as needed) and update
   [`standards/03_INDUSTRY_RESEARCH.md`](standards/03_INDUSTRY_RESEARCH.md) + its
   `standards/_raw/_industry/` reports.
2. **Read the collection's current state.** For the in-scope addons in [`ADDONS.md`](ADDONS.md), pull
   the most recent run's per-addon `audit/<date>/<Addon>/01_CURRENT_STATE.md` (and the comparison
   matrix in its `00_EXECUTIVE_SUMMARY.md`) for what they do today.
3. **Synthesize into the rules.** Fold both inputs into
   [`standards/01_STANDARD.md`](standards/01_STANDARD.md) as MUST/SHOULD/MAY rules, each with a
   rationale and a reference implementation. Preserve the `§`-section numbering.
4. **Bump the changelog.** Update the version + date at the top of `01_STANDARD.md`.
5. **Ripple the change.** Sync [`standards/00_EXECUTIVE_SUMMARY.md`](standards/00_EXECUTIVE_SUMMARY.md)
   and [`standards/02_NEW_ADDON_CONTEXT.md`](standards/02_NEW_ADDON_CONTEXT.md). Existing audit runs
   stay frozen; the *next* audit re-measures against the revised standard.

## B. Run an audit

Measure the addons against the current standard. Full, authoritative steps:
[`audit/README.md`](audit/README.md). At a glance:

1. **Create the run folder** `audit/<today>/` (a fresh dated snapshot; never edit an old run).
2. **Take the scope from [`ADDONS.md`](ADDONS.md)** — audit every addon listed there against the
   **then-current** [`standards/01_STANDARD.md`](standards/01_STANDARD.md).
3. **Give each addon a self-contained folder** — `audit/<today>/<Addon>/` holds that addon's
   `01_CURRENT_STATE`, `02_DEVIATIONS`, `03_EVIDENCE`, `04_TECHNICAL_DESIGN`, and `05_EXECUTION_PLAN`.
   Because the folders share no files, addons can be audited and remediated **in parallel** (one agent
   per addon). Only the cross-addon `00_EXECUTIVE_SUMMARY.md` (comparison matrix + sprint sequencing)
   and `01_PLAN.md` (how the run is conducted) live at the run root.
4. **Assign stable deviation IDs** per addon (AT-\*, CM-\*, KCD-\*, LH-\*, PC-\*, WG-\*) — the shared
   key between each addon's `02_DEVIATIONS.md` and its remediation plans.
5. **Register the run** by adding a row to the runs table in [`audit/README.md`](audit/README.md).

## C. Start a new addon

Scaffold a new Ka0s addon that is compliant from day one. Full walkthrough:
[`standards/02_NEW_ADDON_CONTEXT.md`](standards/02_NEW_ADDON_CONTEXT.md). In short: scaffold with the
`wow-addon:new-addon` skill, drop that context pack in as the addon's `CLAUDE.md`, build against the
standard, and add the addon's row to [`ADDONS.md`](ADDONS.md) so it enters scope.

---

## Layout

```
WowAddonStandards/
  ADDONS.md                               -- THE ROSTER: single editable scope list (read by both halves)
  standards/                              -- THE STANDARD (living, canonical)
    README.md                             -- what's here + how to refresh the standard
    00_EXECUTIVE_SUMMARY.md               -- one-page TL;DR of the standard
    01_STANDARD.md                        -- the Ka0s WoW Addon Standard (canonical)
    02_NEW_ADDON_CONTEXT.md               -- drop-in CLAUDE.md pack + new-addon kickstart walkthrough
    03_INDUSTRY_RESEARCH.md               -- research foundation: 10 reference addons synthesized
    _raw/_industry/                       -- per-addon raw research reports (evidence)
  audit/                                  -- periodic compliance runs (see audit/README.md)
    <YYYY-MM-DD>/                         -- one dated folder per run (frozen snapshot)
      00_EXECUTIVE_SUMMARY.md             -- cross-addon TL;DR: comparison matrix + sprints
      01_PLAN.md                          -- how the run is conducted (run-wide)
      <Addon>/                            -- SELF-CONTAINED per-addon folder (parallel-friendly)
        01_CURRENT_STATE.md               -- this addon's snapshot
        02_DEVIATIONS.md                  -- this addon's gap report + deviation IDs
        03_EVIDENCE.md                    -- this addon's compliance evidence
        04_TECHNICAL_DESIGN.md            -- this addon's remediation design
        05_EXECUTION_PLAN.md              -- this addon's remediation steps
    2026-05-03/                           -- first run (legacy flat layout; frozen)
```

## Status

Standard is at **v2.2** and living. The latest audit run (`audit/2026-05-03/`) is complete; its
remediation (actually modifying the addons) is a separate, planned follow-up engagement not yet
executed.

## License

See [`LICENSE`](LICENSE).
