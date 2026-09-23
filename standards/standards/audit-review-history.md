> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Audit, review & re-vendor history

Audit, code-review and re-vendor runs are **frozen, dated snapshots** kept in the addon's **own** repo, under `docs/`. Each is a numbered-prefix bundle written to a new dated folder; a re-run is a **new** folder — **never** edit a prior run. The three commands write to **separate** locations:

- **`/wow-addon:standards-audit`** → **`docs/audits/<YYYY-MM-DD>/`** — compliance against this standard: `01_CURRENT_STATE.md`, `02_DEVIATIONS.md` (stable per-addon deviation IDs), `03_EVIDENCE.md`, `04_TECHNICAL_DESIGN.md`, `05_EXECUTION_PLAN.md`. The step-by-step playbook is `AUDIT.md` at the root of the standards repo. This audit is **read-only** — it produces a remediation plan, it does not change code.
- **`wow-addon:review`** → **`docs/reviews/<YYYY-MM-DD>/`** — principal-engineer code review: `01_FINDINGS.md`, `02_PROPOSED_CHANGES.md`, `03_SMOKE_TESTS.md`, `04_EXECUTION_PLAN.md`, `05_FINAL_SUMMARY.md`.
- **`/wow-addon:revendor-libka0s`** → **`docs/revendor/<YYYY-MM-DD>-v<tag>/`** — what arrived with a LibKa0s re-vendor and what was done about it: `01_DELTA.md` (the payload delta), `02_CANDIDATES.md`, `03_DECISIONS.md`, `04_EXECUTION_PLAN.md`, `05_SUMMARY.md`. **`01_DELTA.md` and `05_SUMMARY.md` are the stable members** and are always written; the middle three are written when there is something to write. Of the sixty-eight bundles the collection has on disk, forty carry all five, nineteen have no `04_EXECUTION_PLAN.md` because nothing was adopted, and nine carry the two stable members alone — so an absent middle document records a decision rather than an unfinished bundle, and a MUST over all five would have declared twenty-eight compliant bundles broken.

**The re-vendor folder carries the tag, not the date alone (MUST).** Forty of the sixty-eight bundles on disk are `<date>-v<tag>` and twenty-eight are bare `<date>`. The tagged form is both the majority and the only one that answers the question a reader opens the store with — *which library release is this bundle about?* — which a date cannot, because a single day has carried two re-vendors more than once in this collection. Existing bare-dated folders are **not** renamed on sight: a frozen bundle's name is part of what it froze, so a rename is a decision taken deliberately and recorded, not a tidy-up.

**These three stores carry no `README.md`; `docs/automated-tests/` MUST carry one, and `docs/perf-analysis/` MUST carry one wherever that store exists (documentation-§3).** The second obligation is **conditional**, and documentation-§3 says so in as many words: `perf-analysis/README.md` is *“the one conditional member of the five”*, required while the performance harness is wired and **not shipped** by an addon holding a recorded performance-§12 exemption, which takes no in-game captures and therefore has no store to document. The obligation is on the **store**, not on every repo — a repo with no capture store owes no README over it, and an audit that files one has read the MUST without its condition. The line between the two groups is whether the store has a reading **across** bundles. The automated-test record and the in-game capture store are cumulative series measured the same way every time, so a trend exists and a `README.md` that indexes the series and says how to read a row does work no single bundle can. An audit, a review and a re-vendor are each about one moment and one question; the only fact that spans their bundles is the list of dates, which is the directory listing. A README over them would be a hand-maintained second copy of `ls`, stale on the first run nobody remembered it. The collection already drew this line before the standard stated it: no repo has written a `docs/revendor/README.md` in sixty-eight bundles, against six that ship `docs/perf-analysis/README.md` — which is **every** repo in the collection that has a `docs/perf-analysis/` store at all, so the conditional MUST is met wherever its condition holds and the repos without the store are not the exception to it.

- **MUST** write each run to a new dated folder under the correct parent (`docs/audits/` for audits, `docs/reviews/` for reviews, `docs/revendor/` for re-vendors); never edit a prior run.
- **SHOULD** retain every prior `docs/audits/`, `docs/reviews/` and `docs/revendor/` folder; they are the addon's institutional memory. (Runs are **kept**, not deleted after commit.)
- All three histories are dev-only and **MUST NOT** ship in the package — `docs/` is ignored by `.pkgmeta` (packaging).
- All three are **out of scope** for `## Documentation map`, named there as directories and never enumerated bundle by bundle (documentation-§3).
- A review's `03_SMOKE_TESTS.md` catalogs **in-game** checks; they complement the headless unit suites (testing), which cover testable logic.

### A re-vendor commit implies a bundle

*(This section carries no numbered subsections; cite it as `audit-review-history`.)*

This convention was consensual, and it lapsed in every repo that held it inside a day. Ten addons ship
the store, the command that writes it freezes it, and no repo argued with either. Then the newest
bundle in nine stores stopped at LibKa0s v1.34.0 and the tenth at v1.35.0, against a library that has
since reached **v1.54.2** — fifteen to twenty-four re-vendor commits per repo, carrying fifteen to
nineteen distinct tags past that repo's own newest bundle, none of them recorded. Nothing went red,
because the bundle was required by the command that writes it and by no rule anything checks, and
every one of those releases was carried by a bulk sweep that never invoked the command. **Another
paragraph would not have held it**, which is why this one is written to be read by a check.

- **MUST** — every **re-vendor commit** in the repo's history has a `docs/revendor/` bundle naming the
  tag that commit vendored, **or** the absence is a row in `## Documented deviations`
  (`documentation-§3`) saying why. **The trigger is the commit that touches `libs/LibKa0s/` or
  `tests/_kit/` — the library's two payloads, so a kit-only re-vendor counts — never the commit
  subject.** `versioning-git` mandates the commit and only prefers its shape — *"a lib change
  **MUST** produce a **re-vendor commit** in every consuming addon, and that commit **SHOULD** stand
  alone so the sync is legible in history"* — so what is guaranteed to exist is the payload change,
  not a stand-alone commit announcing it. That distinction is the whole reason the rule is needed: the
  releases that went unrecorded were carried by sweeps, folded into the commits that consumed them,
  and a check keyed to the subject line is blind to exactly those. `git log -- libs/LibKa0s` sees a
  folded commit and a stand-alone one alike.
- **The tag is read from the payload on both sides, never from a name.** At a vendoring commit it is
  the root `CLAUDE.md` provenance line — `Bundles [LibKa0s](…) vX.Y.Z (MIT).` (documentation-§2 item
  6, library-stack-§7) — which rolls in the same commit as the copy and is already what the
  vendored-payload gate resolves (testing-§11); a subject naming no tag stays legible, and one naming
  a tag it did not vendor cannot mislead. On the recorded side a `<date>-v<tag>` folder names its tag,
  and a bare-dated folder — grandfathered above, so they are not going away — has its tag read from
  the bundle's `01_DELTA.md` opening line instead. Twenty-eight of the sixty-eight bundles are
  bare-dated and all twenty-eight name their tag there, so a check comparing folder names alone would
  report every one of them as an unrecorded tag, in the same ten stores the no-rename rule above
  promised not to disturb. The check lives in `AUDIT.md`, the playbook named above.
- **The horizon is the store's first bundle.** Re-vendor commits older than a repo's oldest bundle
  predate the convention and are out of scope; a check that files them reports a number nobody can act
  on. A repo with no store yet is measured from its next re-vendor.
- **A consolidated bundle is a compliant answer to a backlog.** A repo twenty tags behind does not owe
  twenty bundles. One bundle naming the span it covers discharges them, because what the store records
  is what arrived and what was done about it, and for nineteen of those tags the answer is *nothing,
  carried by a sweep*. Back-filling a folder per tag would manufacture a record of deliberation that
  never happened, which is worse than the gap it fills.
- **The consolidated span bundle is the sanctioned record for a lapsed span, and its shape is fixed
  because a check reads it.** It is one folder, `docs/revendor/<YYYY-MM-DD>-v<A>-v<B>/`, named for the
  span's first and last tags, holding the two stable members **only** — `01_DELTA.md` and
  `05_SUMMARY.md`; the middle three record deliberation, and a span that was carried by sweeps had
  none. **Line 1 of `01_DELTA.md` is exactly**
  `Delta: LibKa0s v<A> -> v<B> (span: v<A> v<...> v<B>)`, the `span:` list naming **every** tag the
  bundle covers, in order, first and last included — the `AUDIT.md` check reads every
  `vX.Y.Z` on that line as recorded, so a tag left off it is a tag reported unrecorded.
  `05_SUMMARY.md` carries **one line per tag**, saying either *carried by sweep, nothing adopted* or
  the sha of the commit that adopted something from it. The bundle is frozen like every other: it is
  **never** edited after the fact, and a base it misstated (a `v<A>` that was not the tag actually
  vendored before the span) is corrected in the **next** bundle, which says so, never by rewriting
  this one.

### The deviation register is an input to an audit, not a finding of one

*(This section carries no numbered subsections; cite it as `audit-review-history`.)*

`documentation-§3` gives a ratified deviation exactly one home: `## Documented deviations` in
`docs/ARCHITECTURE.md`. An audit that does not read it re-derives decisions already made and files them
as open failures — which is how one ratified decline becomes the same High row in every bundle forever.
Three MUSTs. The first two point in opposite directions on purpose — the first stops the register
being re-litigated, the second stops it becoming a place to hide — and the third stops it going
stale while both of the others pass.

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
- **MUST evaluate every row's re-check trigger, and resolve every evidence id the row cites.**
  `documentation-§3` defines the Re-check trigger as *the condition that ends the deviation, stated so
  a reader can tell whether it has already fired* — written to be evaluated, and until now by nobody in
  particular. An audit **MUST** evaluate each trigger against the tree in front of it and report any row
  whose trigger has **already fired**: that deviation ended on the day the condition came true, and
  every day the row stays in the register the document asserts a live deviation that is not one.
  Likewise the ids a row cites in **Why** — an audit deviation id, a review finding id, a bundle date,
  an issue number — **MUST** resolve, the deviation id to a bundle under `docs/audits/`, the finding id
  to one under `docs/reviews/`, the issue to the addon's own repo. An id that resolves to nothing is
  worse than no citation at all, because it reads as evidence and leads to none, and it survives every
  re-read by a maintainer who knows the shape of an id and never goes looking for what it names. Both
  are as mechanical as the rule citation above, and they catch the case it cannot: a row whose rule
  still exists, still says what the row claims, and stopped being true months ago.

### Pending-audit decisions live in GitHub issues, not a file in the repo

*(This section carries no numbered subsections; cite it as `audit-review-history`.)*

Pending work is swept up, decided, and recorded as **GitHub issues on the addon's own repo**. That
record used to be `docs/pending/LEDGER.md`, a tracked markdown table; it is **retired** and **MUST**
be deleted where it still exists.

**Discovery and triage are two commands, deliberately.** `/wow-addon:issue-audit` sweeps the addon —
four discovery passes, stable item IDs, evidence hashes, severity — and files anything not already in
the store as an open issue labeled `state:untriaged`. It never interviews and never changes code.
`/wow-addon:issue-triage` takes those `state:untriaged` issues, **most severe first**, puts each to the
maintainer one at a time with its evidence, and records the decision by swapping the status label. It
changes the store only.

The split exists because the two halves have different costs. A sweep is mechanical, safe, and worth
running often, including across every repo at once; a triage costs a human decision per item and can
only be done attentively. Fused, the cheap half was gated behind the expensive one — you could not
find out what was hanging without committing to an interview about all of it, which is a good way to
train people not to look. Split, an addon can be swept in a minute and triaged when there is time to
think, and the `state:untriaged` backlog between the two is itself a visible, countable quantity rather
than an unrecorded intention.

A consequence worth stating, because it changes what a decision means: **triage records, it does not
implement.** Accepting that something should be done produces a `state:triaged` issue carrying the
chosen approach, not a code change. The work happens in an ordinary session against that issue.

- **MUST** carry the item's status as a **GitHub label**, drawn from a closed vocabulary of four,
  with the colors below so a status is legible at a glance in the web UI:

  | Status label | Color | Issue state | Means |
  |---|---|---|---|
  | `state:done` | green `00ff00` | closed | Decided and implemented |
  | `state:will-not-do` | blue `0000ff` | closed | Declined; terminal |
  | `state:triaged` | yellow `ffff00` | open | Put to a human, accepted as real, deliberately not now |
  | `state:untriaged` | red `ff0000` | open | Swept up, not yet interviewed |

  Exactly one per issue. **The label is the status — not a title prefix, and not a milestone.**

  **The two families are deliberately opposed in brightness, and that is load-bearing.** Status
  colors sit at full saturation (`ff` on the accent channel); severity colors sit near black (`11`
  on the accent channel). Both families use the same *hue* ladder — green, yellow, orange, red — so a
  hue alone cannot tell you which family a chip belongs to, and an issue always wears one of each.
  When both were mid-tone, a row of chips read as an undifferentiated smear and the eye had to parse
  the label text to find the status. Keep the two brightness bands apart when adding or recoloring;
  matching them is what the split exists to prevent.
- **MUST** carry the item's **severity** as a second GitHub label, one per issue, from a closed
  vocabulary of four:

  | Severity label | Color | Means |
  |---|---|---|
  | `severity:critical` | red `110000` | Taint, combat-lockdown breakage, SavedVariables corruption or data loss, an error on a common path |
  | `severity:high` | orange `110800` | A user-visible defect, or a standard deviation carried out of an audit or review bundle |
  | `severity:medium` | yellow `111100` | Maintainability: a stub callers depend on, code/doc drift, a dead path |
  | `severity:low` | green `001100` | Polish, naming, cosmetic, speculative-future notes |

  Severity is **not decoration**: it is the order `/wow-addon:issue-triage` interviews in, so a wrong
  severity does not merely mislabel an item, it puts it in front of or behind the wrong things when a
  human sits down to decide. `issue-audit` assigns one when it files, and the maintainer **MAY**
  overrule it during triage, which re-orders the remaining queue. The **level** lives in the label
  and nowhere else; the issue body carries the *rationale* for it, so the two cannot drift.
- **MUST NOT** put either value in the **title**. A title is the plain statement of the work: no
  `[<Status>] ` prefix, no emoji status marker, no severity word. Two conventions preceded the labels
  and both are retired — the `marker + word` ledger-table affordance (`🟢 done`), and the
  `[<Status>] <Title>` title prefix. Where a leftover prefix survives on an old issue, **the label is
  the truth and the prefix is stale text**, stripped on sight by the commands that write the store.
- **MUST** label the whole store, so there is no unlabeled state. An issue that arrives without a
  `state:` label — filed from the GitHub web UI, or by someone not using these commands — is
  **repaired on sight** to `state:untriaged` if open, or to the matching terminal label if closed,
  and the repair is **announced**, including by the read-only commands: a listing command that
  mutates silently is worse than one that does not repair at all. A missing `severity:` label is
  repaired only by the commands that read issue bodies; a command that has not read the body
  **MUST NOT** guess a severity from the title, because a fabricated grade lands in a report people
  then reason from.
- **MUST** drive issue work through the **`gh` CLI subcommands** — `gh issue list`, `gh issue create`,
  `gh issue edit`, `gh issue close`, `gh issue comment`, `gh issue view`, `gh label list`,
  `gh label create` — taking structured data with `--json` on those same subcommands. Listing by
  status or severity is therefore a plain **`--label` query** over
  `gh issue list --json number,title,state,labels`, not a title filter and not a search. The eight
  labels are created idempotently with `gh label create --force`, which also repairs a drifted
  color.
- **MUST NOT** use `gh api graphql`, or hand-rolled GraphQL against `api.github.com/graphql`, for
  issue work. Reaching for GraphQL first is a real, observed failure: it spends a round trip on a
  deprecated path before falling back to the subcommand that would have worked. Where a REST call is
  genuinely unavoidable, use `gh api repos/{owner}/{repo}/issues` — never the GraphQL endpoint.
- **Migration is deferrals only.** A surviving ledger's `deferred` rows migrate out as **open**
  issues labeled `state:triaged`. `done` and `wont-do` rows are terminal and are **not** migrated; they survive
  in git history via the commit that deletes the file, which is the whole reason deleting it is safe.
