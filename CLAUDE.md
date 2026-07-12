# CLAUDE.md

Guidance for AI agents working in this repository.

## What this repo is

A **research and analysis deliverable** — the house standard for the Ka0s World of Warcraft addon
collection, plus the periodic audits (evidence and remediation plans) that measure the collection
against it. It contains **documents only**. No addon source code lives here.

The in-scope addons are listed in **`ADDONS.md`** (the single, editable roster) and live in their own
sibling repositories under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`. **Do not modify those addons
from here** — remediation is a separate, follow-up engagement. This repo only describes what should
change, it does not change it.

## Two-part layout

The repo is split into the **standard** (canonical, living) and the **audits** (periodic, frozen).

```
ADDONS.md                           -- THE ROSTER: single editable scope list, read by both halves
standards/                          -- THE STANDARD (living, canonical). Everything supports 01_STANDARD.md.
  README.md                         -- what's in standards/ + how to rebuild the standard
  00_EXECUTIVE_SUMMARY.md           -- one-page TL;DR of the standard
  01_STANDARD.md                    -- THE STANDARD (canonical)
  02_NEW_ADDON_CONTEXT.md           -- drop-in CLAUDE.md context pack for new addons
  03_INDUSTRY_RESEARCH.md           -- research foundation: patterns from 10 reference addons
  _raw/_industry/                   -- per-addon raw research reports (evidence for 03_)
audit/                              -- periodic compliance runs; see audit/README.md
  <YYYY-MM-DD>/                     -- one dated folder per run (frozen snapshot)
    00_EXECUTIVE_SUMMARY.md         -- cross-addon TL;DR: comparison matrix + sprints (start here)
    01_PLAN.md                      -- how this run is conducted (run-wide milestone plan)
    <Addon>/                        -- SELF-CONTAINED per-addon folder; one agent owns it end-to-end
      01_CURRENT_STATE.md           -- this addon's snapshot
      02_DEVIATIONS.md              -- this addon's gap report + deviation IDs
      03_EVIDENCE.md                -- this addon's compliance evidence
      04_TECHNICAL_DESIGN.md        -- this addon's remediation design
      05_EXECUTION_PLAN.md          -- this addon's remediation steps
```

Per-addon folders are self-contained by design, so runs can be worked in parallel (one agent per
addon); only genuinely cross-addon material lives at the run root.

The only audit run so far is `audit/2026-05-03/`, which predates the per-addon layout and uses the
legacy flat layout (combined `02_CURRENT_STATE.md`/`03_DEVIATIONS.md`, flat `_raw/`,
`remediation/<Addon>/`). It is frozen and left as-is; the per-addon layout applies from the next run.

Read order for a newcomer: `audit/2026-05-03/00_EXECUTIVE_SUMMARY.md` → `standards/01_STANDARD.md` →
the rest as needed.

## Conventions

- **`ADDONS.md` is the single scope source.** Both the standards process and every audit run take the
  list of in-scope addons from this one roster. To add/remove an addon from scope, edit that file —
  nothing else. Don't hard-code the addon list elsewhere; point at `ADDONS.md`.
- **`standards/01_STANDARD.md` is canonical.** When docs conflict, it wins. It uses section refs like
  `§4.5`, `§9.2` — preserve those when editing.
- **The standard is living; audits are frozen.** `standards/` evolves in place (versioned via the
  changelog at the top of `01_STANDARD.md` and git history). Each audit is a point-in-time snapshot
  under `audit/YYYY-MM-DD/` — never edit an old run to reflect new findings; add a new dated folder
  instead (see `audit/README.md`).
- **Industry research is a standards-process input, not an audit step.** The reference-addon research
  (`standards/03_INDUSTRY_RESEARCH.md` + `standards/_raw/_industry/`) is a living foundation for
  `01_STANDARD.md`; see `standards/README.md` for the rebuild process. An **audit** only checks each
  addon against the then-current standard — it does not survey the ecosystem. (This work used to live
  under `audit/2026-05-03/`; it was promoted to `standards/`.)
- **The date `2026-05-03`** is an audit-run identifier: it **is** the folder name for that run, and it
  also appears in that run's document titles/headers. (Note: this repo previously flattened everything
  to the root with no dated folder — that is no longer true; audits are dated folders again.)
- **Cross-references** use plain relative paths; depth depends on where the doc sits. A **per-addon**
  doc (`audit/<date>/<Addon>/…`) reaches the standard at `../../../standards/01_STANDARD.md`, its run's
  summary at `../00_EXECUTIVE_SUMMARY.md`, and its sibling per-addon docs by bare name
  (`02_DEVIATIONS.md`). A **run-root** doc reaches the standard at `../../standards/01_STANDARD.md`.
  From `standards/` to an audit: `../audit/<date>/…`. The standard itself should reference audit
  concepts generically (e.g. "the deviation report") rather than hard-linking one dated run. (The
  frozen `2026-05-03/` run uses the older flat depth — `../../standards/…` from its run-root docs.)
- **Deviation IDs** are per-addon (AT-*, CM-*, KCD-*, LH-*, PC-*, WG-*) and referenced across the
  reports. Keep them stable; they are the shared key between each addon's `02_DEVIATIONS.md` and its
  remediation plans (`04_TECHNICAL_DESIGN.md` / `05_EXECUTION_PLAN.md`) in the same `<Addon>/` folder.
  A newly-rostered addon gets its prefix assigned on its first audit run.

## Git workflow

- **Never create a branch in this repo automatically.** Work directly on the current branch (usually
  `main`) — trunk-based. Only create a branch when the user **explicitly asks** for one.
- **Never push, and never commit unless the user asks.** Approval to commit or branch once does not
  carry over to the next change.

## Known corrections (read before trusting a finding)

`audit/2026-05-03/remediation/README.md` records corrections the design agents surfaced against that
run's `03_DEVIATIONS.md` and `00_EXECUTIVE_SUMMARY.md`. Most important: the "5/5 addons hand-roll
`SLASH_*`" finding is **wrong** — only AbsorbTracker does; the other four already use AceConsole
`:RegisterChatCommand`. Prefer `remediation/README.md` over the original reports where they disagree.

## Editing rules

- Keep documents internally consistent — a change to the standard may ripple into an audit run's
  per-addon deviation/remediation docs (`<Addon>/02_DEVIATIONS.md`, `04_TECHNICAL_DESIGN.md`,
  `05_EXECUTION_PLAN.md`) and both `00_EXECUTIVE_SUMMARY.md` files. Update all affected docs together.
  (In the legacy `2026-05-03/` run these are the flat `03_DEVIATIONS.md` + `remediation/` subtree.)
- Don't invent compliance claims. Findings here are evidence-backed (citations in a run's `_raw/`);
  keep new claims sourced the same way.
