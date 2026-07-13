> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Audit & review history

Audit and code-review runs are **frozen, dated snapshots** kept in the addon's **own** repo, under `docs/`. Each is a five-artifact bundle written to a new dated folder; a re-run is a **new** folder — **never** edit a prior run. The two skills write to **separate** locations:

- **`/wow-addon:standards-audit`** → **`docs/audits/<YYYY-MM-DD>/`** — compliance against this standard: `01_CURRENT_STATE.md`, `02_DEVIATIONS.md` (stable per-addon deviation IDs), `03_EVIDENCE.md`, `04_TECHNICAL_DESIGN.md`, `05_EXECUTION_PLAN.md`. The step-by-step playbook is `AUDIT.md` at the root of the standards repo. This audit is **read-only** — it produces a remediation plan, it does not change code.
- **`wow-addon:review`** → **`docs/reviews/<YYYY-MM-DD>/`** — principal-engineer code review: `01_FINDINGS.md`, `02_PROPOSED_CHANGES.md`, `03_SMOKE_TESTS.md`, `04_EXECUTION_PLAN.md`, `05_FINAL_SUMMARY.md`.

- **MUST** write each run to a new dated folder under the correct parent (`docs/audits/` for audits, `docs/reviews/` for reviews); never edit a prior run.
- **SHOULD** retain every prior `docs/audits/` and `docs/reviews/` folder; they are the addon's institutional memory. (Runs are **kept**, not deleted after commit.)
- Both histories are dev-only and **MUST NOT** ship in the package — `docs/` is ignored by `.pkgmeta` (packaging).
- A review's `03_SMOKE_TESTS.md` catalogues **in-game** checks; they complement the headless unit suites (testing), which cover testable logic.
