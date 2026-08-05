> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Audit & review history

Audit and code-review runs are **frozen, dated snapshots** kept in the addon's **own** repo, under `docs/`. Each is a five-artifact bundle written to a new dated folder; a re-run is a **new** folder — **never** edit a prior run. The two skills write to **separate** locations:

- **`/wow-addon:standards-audit`** → **`docs/audits/<YYYY-MM-DD>/`** — compliance against this standard: `01_CURRENT_STATE.md`, `02_DEVIATIONS.md` (stable per-addon deviation IDs), `03_EVIDENCE.md`, `04_TECHNICAL_DESIGN.md`, `05_EXECUTION_PLAN.md`. The step-by-step playbook is `AUDIT.md` at the root of the standards repo. This audit is **read-only** — it produces a remediation plan, it does not change code.
- **`wow-addon:review`** → **`docs/reviews/<YYYY-MM-DD>/`** — principal-engineer code review: `01_FINDINGS.md`, `02_PROPOSED_CHANGES.md`, `03_SMOKE_TESTS.md`, `04_EXECUTION_PLAN.md`, `05_FINAL_SUMMARY.md`.

- **MUST** write each run to a new dated folder under the correct parent (`docs/audits/` for audits, `docs/reviews/` for reviews); never edit a prior run.
- **SHOULD** retain every prior `docs/audits/` and `docs/reviews/` folder; they are the addon's institutional memory. (Runs are **kept**, not deleted after commit.)
- Both histories are dev-only and **MUST NOT** ship in the package — `docs/` is ignored by `.pkgmeta` (packaging).
- A review's `03_SMOKE_TESTS.md` catalogs **in-game** checks; they complement the headless unit suites (testing), which cover testable logic.

### The deviation register is an input to an audit, not a finding of one

*(This section carries no numbered subsections; cite it as `audit-review-history`.)*

`documentation-§3` gives a ratified deviation exactly one home: `## Documented deviations` in
`docs/ARCHITECTURE.md`. An audit that does not read it re-derives decisions already made and files them
as open failures — which is how one ratified decline becomes the same High row in every bundle forever.
Two MUSTs, pointing in opposite directions on purpose: the first stops the register being re-litigated,
the second stops it becoming a place to hide.

- **MUST read the register first**, before filing anything, and record a matching entry as **accepted,
  with its id** — never as an open MUST failure. The audit still *names* the deviation, because a
  reader of the bundle needs to know it exists; what it **MUST NOT** do is count it toward the MUST
  tally or ask for it to be fixed. A decision recorded exactly where this standard asks for it is
  **compliance**, and an audit reporting it as a defect is reporting on its own reading. Conversely, a
  decision reasoned only in `docs/pending/LEDGER.md`, a root `CLAUDE.md` note or `docs/scope.md`, with
  **no** register row, is **not** ratified — that missing row is itself the finding, and the audit
  files it.
- **MUST report as a finding any register entry whose cited rule the standard has since changed** — so
  the behavior the row records as a deviation is now mandated, permitted outright, or governed by a
  different rule. The Rule column is a `filename-§N` reference precisely so this check is mechanical:
  resolve every row's citation against the current standard and report the rows that no longer say
  what the row claims. Without it the register accumulates compliant behavior, and a reader who trusts
  it is misled by the one document whose whole purpose is to be trusted. Retiring such a row is a doc
  change, not a re-decision.
