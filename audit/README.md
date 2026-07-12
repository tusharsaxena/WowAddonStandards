# Audit

Periodic compliance audits of the Ka0s addon collection against the house standard in
[`../standards/`](../standards/). This is the **evidence and remediation** half of the repo; the
canonical rules live in `standards/`.

## Run-per-date

Each audit is a **frozen, point-in-time snapshot** and lives in its own dated folder,
`audit/YYYY-MM-DD/`. Audits run periodically; a new run never edits an old one — it drops in a new
dated folder. The standard, by contrast, is a single living document that evolves in place (versioned
via its changelog and git history).

## Audit runs

| Date | Scope | Summary |
|---|---|---|
| [`2026-05-03/`](2026-05-03/) | 5 addons audited (AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup) against the standard | [`2026-05-03/00_EXECUTIVE_SUMMARY.md`](2026-05-03/00_EXECUTIVE_SUMMARY.md) |

> **Note:** `2026-05-03/` predates the per-addon-folder layout below and uses the legacy flat layout
> (combined `02_CURRENT_STATE.md` / `03_DEVIATIONS.md`, a flat `_raw/`, and a `remediation/<Addon>/`
> subtree). It is frozen and left as-is; the per-addon layout applies from the next run onward.

## Anatomy of a run

Each run is organized so that **every addon is a self-contained subfolder** — one agent can own an
addon's audit and remediation end-to-end without touching any other addon's files, so all addons can
be worked in parallel. Only genuinely cross-addon documents live at the run root.

```
audit/<YYYY-MM-DD>/
  00_EXECUTIVE_SUMMARY.md       -- cross-addon TL;DR: comparison matrix + sprint sequencing (start here)
  01_PLAN.md                    -- how this audit run is conducted (run-wide milestone plan)
  <Addon>/                      -- SELF-CONTAINED per-addon folder (one per rostered addon)
    01_CURRENT_STATE.md         -- this addon's snapshot against the standard
    02_DEVIATIONS.md            -- this addon's gap report + stable deviation IDs (e.g. AT-*)
    03_EVIDENCE.md              -- this addon's full compliance evidence (file:line citations)
    04_TECHNICAL_DESIGN.md      -- remediation design for this addon
    05_EXECUTION_PLAN.md        -- ordered remediation steps for this addon
```

The run root holds only cross-addon material: `00_EXECUTIVE_SUMMARY.md` carries the comparison matrix
and the cross-cutting sprint sequencing; `01_PLAN.md` describes how the run itself is executed.
Everything specific to one addon lives under that addon's folder.

> An audit does **not** include industry research — that is part of the **standards process** and lives
> in [`../standards/`](../standards/) (`03_INDUSTRY_RESEARCH.md`). An audit only checks addons against the
> standard; it does not survey the ecosystem.

## Running a new audit

1. **Take the scope from the roster.** Audit every addon listed in [`../ADDONS.md`](../ADDONS.md) — the
   single, editable scope source. (A run records the scope as it was on its date; adding an addon to
   the roster puts it in the *next* run, not past ones.)
2. Create `audit/<today>/` with one `<Addon>/` subfolder per rostered addon, plus the run-root
   `00_EXECUTIVE_SUMMARY.md` and `01_PLAN.md`. Audit each addon against the then-current
   [`../standards/01_STANDARD.md`](../standards/01_STANDARD.md), filling its self-contained folder
   (`01_CURRENT_STATE` → `05_EXECUTION_PLAN`). Because the folders don't share files, addons can be
   audited and remediated **in parallel** (e.g. one agent per addon); roll the cross-addon comparison
   and sprint sequencing up into `00_EXECUTIVE_SUMMARY.md`.
3. Keep **deviation IDs** per-addon and stable (AT-\*, CM-\*, KCD-\*, LH-\*, PC-\*, WG-\*) — they are
   the shared key between each addon's `02_DEVIATIONS.md` and its remediation plans in the same
   `<Addon>/` folder. Assign a short, stable prefix to any rostered addon that doesn't have one yet.
4. Add a row to the **Audit runs** table above.
