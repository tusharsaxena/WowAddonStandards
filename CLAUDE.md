# CLAUDE.md

Guidance for AI agents working in this repository.

## What this repo is

The **house standard** for the Ka0s World of Warcraft addon collection, plus the two **process
playbooks** the `wow-addon` plugin consumes. It contains **documents only** — no addon source code
lives here.

This repo does **not** run audits. Compliance auditing and new-addon scaffolding happen **in each
addon's own repo**, driven by a plugin skill that reads the playbook from here:

- **`AUDIT.md`** (root) — the step-by-step spec for `/wow-addon:standards-audit`. An addon audits
  **itself**, writing a dated `docs/audits/<YYYY-MM-DD>/` bundle inside **its own** repo.
- **`NEW_ADDON.md`** (root) — the step-by-step spec for `/wow-addon:new-addon`. Scaffolds a new addon
  that is born compliant.

Both are **thin orchestrators**: they say *how* the process runs and defer all substance to the
canonical docs under `standards/`. The plugin lives in a separate repo
(<https://github.com/tusharsaxena/wow-addon>) and is updated there to consume these files.

The in-scope addons are listed in **`standards/ADDONS.md`** (the roster) and live in their own sibling
repositories under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`. **Do not modify those addons from
here.**

## Layout

```
AUDIT.md                          -- PLAYBOOK: /wow-addon:standards-audit (per-addon self-audit)
NEW_ADDON.md                      -- PLAYBOOK: /wow-addon:new-addon (scaffold, born compliant)
README.md                         -- repo overview + the three things you can do here
CLAUDE.md                         -- this file
LICENSE
standards/                        -- THE STANDARD (living, canonical). Everything supports 01_STANDARD.md.
  README.md                       -- what's in standards/ + how to rebuild the standard
  00_EXECUTIVE_SUMMARY.md         -- one-page TL;DR of the standard
  01_STANDARD.md                  -- THE STANDARD (canonical)
  02_NEW_ADDON_CONTEXT.md         -- drop-in CLAUDE.md context pack for new addons (NEW_ADDON.md's detail)
  03_INDUSTRY_RESEARCH.md         -- research foundation: patterns from 10 reference addons
  ADDONS.md                       -- THE ROSTER: editable list of in-scope addons (standards-process input)
  _raw/_industry/                 -- per-addon raw research reports (evidence for 03_)
```

Audit and review runs are **not** in this repo — they live under each audited addon's own
`docs/audits/<date>/` and `docs/reviews/<date>/` (see `AUDIT.md`, and §16 of the standard).

Read order for a newcomer: `README.md` → `standards/01_STANDARD.md` → the playbooks (`AUDIT.md`,
`NEW_ADDON.md`) → the rest as needed.

## Conventions

- **`standards/ADDONS.md` is the roster.** It is a **standards-process input** (which addons the
  standard codifies for, and whose current state feeds the next refresh). To change collection scope,
  edit that one file. Don't hard-code the addon list elsewhere; point at `standards/ADDONS.md`.
- **`standards/01_STANDARD.md` is canonical.** When docs conflict, it wins. It uses section refs like
  `§4.5`, `§9.2` — preserve those when editing. It is **living**: every substantive change bumps the
  version + date and adds a changelog entry at its top (git history carries the rest).
- **The playbooks are thin orchestrators.** `AUDIT.md` and `NEW_ADDON.md` describe process and point
  into `standards/` (`01_STANDARD.md` as the audit checklist; `02_NEW_ADDON_CONTEXT.md` as the scaffold
  pack). Keep the *substance* in `standards/`; don't duplicate rules into the playbooks — they drift.
- **Industry research is a standards-process input, not an audit step.** The reference-addon research
  (`standards/03_INDUSTRY_RESEARCH.md` + `standards/_raw/_industry/`) is a living foundation for
  `01_STANDARD.md`; see `standards/README.md` for the rebuild process.
- **Audits are per-repo and frozen.** A `/wow-addon:standards-audit` run writes a frozen dated
  `docs/audits/<YYYY-MM-DD>/` bundle (`01_CURRENT_STATE` … `05_EXECUTION_PLAN`, with stable per-addon
  deviation-ID prefixes) into the **audited addon's** repo — never here, and never edited after the
  fact. See `AUDIT.md` for the structure.
- **Cross-references** use plain relative paths. From `standards/` to a root playbook: `../AUDIT.md`.
  From root to a standard doc: `standards/01_STANDARD.md`. Within `standards/`, docs reference each
  other and `ADDONS.md` by bare name.

## Git workflow

- **Never create a branch in this repo automatically.** Work directly on the current branch (usually
  `master`) — trunk-based. Only create a branch when the user **explicitly asks** for one.
- **Never push, and never commit unless the user asks.** Approval to commit or branch once does not
  carry over to the next change.

## Editing rules

- Keep documents internally consistent. A change to the standard usually ripples into
  `standards/00_EXECUTIVE_SUMMARY.md` and `standards/02_NEW_ADDON_CONTEXT.md`, and sometimes the root
  `README.md` / the playbooks. Update all affected docs together, and bump the standard's version +
  changelog.
- Don't invent compliance claims. Findings are evidence-backed (`file:line` citations); keep new
  claims sourced the same way.
