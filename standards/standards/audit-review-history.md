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
  decision reasoned only in a issue-audit issue, a root `CLAUDE.md` note or `docs/scope.md`, with
  **no** register row, is **not** ratified — that missing row is itself the finding, and the audit
  files it.
- **MUST report as a finding any register entry whose cited rule the standard has since changed** — so
  the behavior the row records as a deviation is now mandated, permitted outright, or governed by a
  different rule. The Rule column is a `filename-§N` reference precisely so this check is mechanical:
  resolve every row's citation against the current standard and report the rows that no longer say
  what the row claims. Without it the register accumulates compliant behavior, and a reader who trusts
  it is misled by the one document whose whole purpose is to be trusted. Retiring such a row is a doc
  change, not a re-decision.

### Pending-audit decisions live in GitHub issues, not a file in the repo

*(This section carries no numbered subsections; cite it as `audit-review-history`.)*

Pending work is swept up, decided, and recorded as **GitHub issues on the addon's own repo**. That
record used to be `docs/pending/LEDGER.md`, a tracked markdown table; it is **retired** and **MUST**
be deleted where it still exists.

**Discovery and triage are two commands, deliberately.** `/wow-addon:issue-audit` sweeps the addon —
four discovery passes, stable item IDs, evidence hashes, severity — and files anything not already in
the store as an open `[untriaged]` issue. It never interviews and never changes code.
`/wow-addon:issue-triage` takes those `[untriaged]` issues, puts each to the maintainer one at a time
with its evidence, and records the decision on the issue. It changes the store only.

The split exists because the two halves have different costs. A sweep is mechanical, safe, and worth
running often, including across every repo at once; a triage costs a human decision per item and can
only be done attentively. Fused, the cheap half was gated behind the expensive one — you could not
find out what was hanging without committing to an interview about all of it, which is a good way to
train people not to look. Split, an addon can be swept in a minute and triaged when there is time to
think, and the `[untriaged]` backlog between the two is itself a visible, countable quantity rather
than an unrecorded intention.

A consequence worth stating, because it changes what a decision means: **triage records, it does not
implement.** Accepting that something should be done produces a `[deferred]` issue carrying the
chosen approach, not a code change. The work happens in an ordinary session against that issue.

- **MUST** carry the item's status as a **title prefix**, shaped exactly `[<Status>] <Title>`, drawn
  from a closed vocabulary of four:

  | Status prefix | Issue state | Means |
  |---|---|---|
  | `[done]` | closed | Decided and implemented |
  | `[will-not-do]` | closed | Declined; terminal |
  | `[deferred]` | open | Accepted as real, deliberately not now |
  | `[untriaged]` | open | Swept up, not yet interviewed |

  The prefix is the status — **not** a label, and **not** a milestone. One field, visible in every
  listing, in the one place `gh issue list` returns without a second call.
- **MUST** drive issue work through the **`gh` CLI subcommands** — `gh issue list`, `gh issue create`,
  `gh issue edit`, `gh issue close`, `gh issue comment`, `gh issue view` — taking structured data with
  `--json` on those same subcommands. Listing by status is therefore a **title filter** over
  `gh issue list --json number,title,state`.
- **MUST NOT** use `gh api graphql`, or hand-rolled GraphQL against `api.github.com/graphql`, for
  issue work. Reaching for GraphQL first is a real, observed failure: it spends a round trip on a
  deprecated path before falling back to the subcommand that would have worked. Where a REST call is
  genuinely unavoidable, use `gh api repos/{owner}/{repo}/issues` — never the GraphQL endpoint.
- **Migration is deferrals only.** `[deferred]` rows migrate out of a surviving ledger as **open**
  `[deferred]` issues. `done` and `wont-do` rows are terminal and are **not** migrated; they survive
  in git history via the commit that deletes the file, which is the whole reason deleting it is safe.
