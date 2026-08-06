# CLAUDE.md

Guidance for AI agents working in this repository.

## What this repo is

The **house standard** for the Ka0s World of Warcraft addon collection, plus the three **process
playbooks** the `wow-addon` plugin consumes — `AUDIT.md`, `AUTOMATED_TESTS.md` and `NEW_ADDON.md`. It
contains **documents only** — no addon source code lives here.

This repo does **not** run audits. Compliance auditing and new-addon scaffolding happen **in each
addon's own repo**, driven by a plugin skill that reads the playbook from here:

- **`AUDIT.md`** (root) — the step-by-step spec for `/wow-addon:standards-audit`. An addon audits
  **itself**, writing a dated `docs/audits/<YYYY-MM-DD>/` bundle inside **its own** repo.
- **`AUTOMATED_TESTS.md`** (root) — the step-by-step spec for `/wow-addon:automated-tests`. An addon
  records **itself**, writing a frozen `docs/automated-tests/<YYYYMMDD-HHMMSS>/` bundle inside
  **its own** repo.
- **`NEW_ADDON.md`** (root) — the step-by-step spec for `/wow-addon:new-addon`. Scaffolds a new addon
  that is born compliant.

All three are **thin orchestrators**: they say *how* the process runs and defer all substance to the
canonical docs under `standards/`. The plugin lives in a separate repo
(<https://github.com/tusharsaxena/wow-addon>) and is updated there to consume these files.

The in-scope repos are listed in **`standards/ADDONS.md`** (the roster) and live in their own sibling
repositories under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`: the addon table, and a second table of
**Ka0s-owned library repos**, which are audited against library-stack-§7's applicability list rather
than the addon rule set. **Do not modify those repos from here.**

## Layout

```
AUDIT.md                          -- PLAYBOOK: /wow-addon:standards-audit (per-addon self-audit)
AUTOMATED_TESTS.md                -- PLAYBOOK: /wow-addon:automated-tests (per-addon test record)
NEW_ADDON.md                      -- PLAYBOOK: /wow-addon:new-addon (scaffold, born compliant)
README.md                         -- repo overview + the three things you can do here
CLAUDE.md                         -- this file
LICENSE
.gitattributes                    -- line-ending policy: the non-client canonical body, LF (line-endings-§2/§5)
standards/                        -- THE STANDARD (living, canonical). Everything supports STANDARDS.md.
  README.md                       -- what's in standards/ + how to rebuild the standard
  EXECUTIVE_SUMMARY.md            -- one-page TL;DR of the standard
  STANDARDS.md                    -- THE STANDARD: index/entry point + the Sections map (canonical)
  standards/                      -- the standard's sections, one unnumbered file each (layout.md, ...)
  NEW_ADDON_CONTEXT.md            -- new-addon scaffolding pack (NEW_ADDON.md's detail); fetched, never stored
  INDUSTRY_RESEARCH.md            -- research foundation: patterns from 10 reference addons
  ADDONS.md                       -- THE ROSTER: editable list of in-scope addons (standards-process input)
  _raw/_industry/                 -- per-addon raw research reports (evidence for INDUSTRY_RESEARCH.md)
```

Audit and review runs are **not** in this repo — they live under each audited addon's own
`docs/audits/<date>/` and `docs/reviews/<date>/` (see `AUDIT.md`, and audit-review-history of the standard).

Read order for a newcomer: `README.md` → `standards/STANDARDS.md` → the playbooks (`AUDIT.md`,
`NEW_ADDON.md`, `AUTOMATED_TESTS.md`) → the rest as needed.

## Conventions

- **`standards/ADDONS.md` is the roster.** It is a **standards-process input** (which addons the
  standard codifies for, and whose current state feeds the next refresh). To change collection scope,
  edit that one file. Don't hard-code the addon list elsewhere; point at `standards/ADDONS.md`.
- **`standards/STANDARDS.md` is canonical.** When docs conflict, it wins. It is the **index/entry
  point**: the normative rules are split into one file per section under `standards/standards/`
  (unnumbered topic names — `layout.md`, `architecture.md`, …), and `STANDARDS.md` carries the
  front matter, the reading guide, the **Sections** map, and the changelog. It is **living**: every
  substantive change bumps the version + date and adds a changelog entry at its top (git history
  carries the rest). When you add, split, or reorder a section, update the Sections list in
  `STANDARDS.md`.
- **Reference sections by `filename-§N` — always.** A whole section is its **bare filename**
  (`architecture`, `audit-review-history`); a subsection is **`filename-§N`** (`architecture-§5`,
  `options-ui-§10`), where `N` is that section's **local** number. The old global `§N.M` numbering is
  retired — do **not** reintroduce it. Preserve these refs when editing, in every doc and in the
  `wow-addon` plugin.
- **Eleven section files have no numbered subsections and take the bare filename only
  (documentation-§6).** Measured by `grep -c '^### [0-9]' standards/standards/<file>` returning 0, they
  are: `anti-patterns`, `audit-review-history`, `compat`, `lint`, `naming-cheatsheet`,
  `open-evolutions`, `packaging`, `preview-mode`, `public-api`, `standalone-windows`,
  `versioning-git`. **Any** `filename-§N` against one of them is out-of-range by construction and a
  **MUST** fix, whatever the number — an unnumbered `###` heading is not a section number. Where a
  specific passage matters, name its heading in words (*standalone-windows, "The Ka0s window edge"*).
  This repo's own prose is held to the rule it publishes; if one of the eleven ever gains numbered
  subsections, it leaves the list in the same change.
- **The playbooks are thin orchestrators.** `AUDIT.md`, `NEW_ADDON.md` and `AUTOMATED_TESTS.md` describe process and point
  into `standards/` (`STANDARDS.md` as the audit checklist; `NEW_ADDON_CONTEXT.md` as the scaffold
  pack). Keep the *substance* in `standards/`; don't duplicate rules into the playbooks — they drift.
- **Industry research is a standards-process input, not an audit step.** The reference-addon research
  (`standards/INDUSTRY_RESEARCH.md` + `standards/_raw/_industry/`) is a living foundation for
  `STANDARDS.md`; see `standards/README.md` for the rebuild process.
- **Audits are per-repo and frozen.** A `/wow-addon:standards-audit` run writes a frozen dated
  `docs/audits/<YYYY-MM-DD>/` bundle (`01_CURRENT_STATE` … `05_EXECUTION_PLAN`, with stable per-addon
  deviation-ID prefixes) into the **audited addon's** repo — never here, and never edited after the
  fact. See `AUDIT.md` for the structure.
- **Cross-references** use plain relative paths. From `standards/` to a root playbook: `../AUDIT.md`.
  From root to a standard doc: `standards/STANDARDS.md`. Within `standards/`, docs reference each
  other and `ADDONS.md` by bare name.

## Git workflow

- **Trunk-based.** Work directly on the current branch (usually `master`) by default; branch when a
  changeset genuinely warrants isolation.

## Editing rules

- **This repo ships nothing to the WoW client, so it pins LF (`line-endings-§2`).** Its root
  `.gitattributes` carries the **non-client** canonical body — `* text=auto eol=lf`, `*.sh text
  eol=lf`, binaries marked `binary`. Write LF here. Do not reach for the `wow-addon` plugin's CRLF
  behavior: the hook reads `git check-attr eol` and follows whatever the repo declares, and what this
  repo declares is LF. The standard it publishes binds it — a standards repo that does not follow its
  own rule is the one thing that discredits the rule. If a file arrives CRLF anyway, that is a
  straggler, not a local convention: `rm <path> && git checkout -- <path>`, then `file <path>`.
- Keep documents internally consistent. A change to the standard usually ripples into
  `standards/EXECUTIVE_SUMMARY.md` and `standards/NEW_ADDON_CONTEXT.md`, and sometimes the root
  `README.md` / the playbooks. Update all affected docs together, and bump the standard's version +
  changelog.
- **Write in US English.** The standard mandates it for addons (`localization-§5`), and these documents
  follow their own rule: `color`, `gray`, `behavior`, `center`, `canceled`, `-ize`/`-ization` — never
  `colour`, `grey`, `behaviour`, `centre`, `cancelled`, `-ise`/`-isation`. Two exemptions: Blizzard /
  third-party symbols are reproduced verbatim, and `standards/_raw/_industry/` is frozen research
  evidence quoting external addons — leave its wording alone.
- **Never state a doc-set count without naming its members.** A bare count ("root ships three docs")
  is the shape that goes stale silently and gets mis-propagated. Always write the count *and* the
  list. As of v2.22.0 the sets are: **repo root** — exactly three docs plus `LICENSE`: a full
  `README.md`, a stub `CLAUDE.md`, and `DEPENDENCIES.md` (documentation-§1/§2/§7), and **never a
  `CHANGELOG.md`**, which is forbidden at an addon root and required at a Ka0s-owned **library**
  root (documentation-§1/§3, library-stack-§7); the **`docs/` canonical trio** — `ARCHITECTURE.md`,
  `testing.md`, `smoke-tests.md`, where `ARCHITECTURE.md` carries ten mandated sections ending in
  `## Documentation map` (the per-addon doc register) and `## Documented deviations` (the single home
  of a ratified deviation); the **verification-and-record docs** — `test-cases.md`, `performance.md`,
  `perf-runs/README.md`, `automated-tests/README.md`, `automated-tests/RESULTS.md`, of which the
  first, second, fourth and fifth are unconditional and `perf-runs/README.md` is required only while
  the performance harness is wired, so an addon holding a recorded performance-§12 exemption ships
  four; and **Tier 1** — `scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`,
  `data-flow.md`, `common-tasks.md`, all six unconditional and under exactly those names, with Tier 2
  (`slash-dispatch.md`, `midnight-quirks.md`, `compat-layer.md`, `message-bus.md`, `profiles.md`,
  `debug.md`) required per stated trigger and recorded as *Not applicable* in the map when the
  trigger has not fired, and Tier 3 free-form (documentation-§3).
  `docs/automated-tests/RESULTS.md` is generated, one file overwritten in place — its single-path
  git history is the trend line — and a full run bundle is produced at **release**, never as a
  commit gate (automated-tests-§4/§6). **`docs/complexity.md` was retired in v2.19.0**; if you see
  one in an addon, it is pre-adoption, not a doc to sync.
- **The two checkpoints gate differently, on purpose (v2.21.0).** A **commit** is gated on `lint` +
  the harness and nothing else (testing-§4, unchanged) — a threshold on every commit is routed
  around with `--no-verify`, after which it protects nothing. The **tag** is gated on all four
  suites plus `suites.complexity.warnings == 0`, i.e. zero functions above CCN 15
  (automated-tests-§3, *The release gate*). The runner's exit code is unchanged, because the same
  vendored script is the commit gate; the release gate is evaluated by `/wow-addon:bump-version`
  from the run's `manifest.json`, and a `skip` blocks as NOT EVALUATED rather than reading as a
  pass. Don't restate this as "perf and complexity never gate" without saying which checkpoint.
- Don't invent compliance claims. Findings are evidence-backed (`file:line` citations); keep new
  claims sourced the same way.
