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

## Anatomy of a run

```
audit/<YYYY-MM-DD>/
  00_EXECUTIVE_SUMMARY.md    -- one-page TL;DR of this run (start here)
  01_PLAN.md                 -- the milestone plan for this audit
  02_CURRENT_STATE.md        -- per-addon snapshot + comparison matrix
  03_DEVIATIONS.md           -- per-addon gap report against the standard
  _raw/                      -- full per-addon compliance evidence
  remediation/               -- per-addon TECHNICAL_DESIGN + EXECUTION_PLAN (+ README index)
```

> An audit does **not** include industry research — that is part of the **standards process** and lives
> in [`../standards/`](../standards/) (`03_INDUSTRY_RESEARCH.md`). An audit only checks addons against the
> standard; it does not survey the ecosystem.

## Running a new audit

1. Create `audit/<today>/` and produce the documents above, auditing each addon against the
   then-current [`../standards/01_STANDARD.md`](../standards/01_STANDARD.md).
2. Keep **deviation IDs** per-addon and stable (AT-\*, CM-\*, KCD-\*, PC-\*, WG-\*) — they are the
   shared key between `03_DEVIATIONS.md` and the remediation plans.
3. Add a row to the **Audit runs** table above.
