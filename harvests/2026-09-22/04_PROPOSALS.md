# Harvest 2026-09-22 — 04 Proposals

Seventeen survivors: findings that cleared the date filter, the `open-evolutions.md` dedup and the
two-repo evidence bar, and then survived a hostile verification of their own citations and counts.
Forty-six live findings did not survive that verification and are recorded in `02_FINDINGS.md` with their
refutations rather than here.

**Two are clear wins** — factual corrections or unanimous existing practice, applicable without a ruling.
**Three are owner calls** and are in their own section at the top, each stating both readings with their
counts, because that section is what the owner is about to be asked. The remaining twelve are live
proposals that need a decision but not a ruling between two readings.

| | Proposal | Target | Bump | Kind |
|---|---|---|---|---|
| **O1** | C7-F02 — private event frames | events-frames-taint.md §1 | minor | **owner call** |
| **O2** | C5-F02 — packaging's ignore template vs its strong form | packaging.md | patch | **owner call** |
| **O3** | C10-F04 — the `.gitattributes` body is gated by nothing | line-endings.md §7 + kit | tooling | **owner call** |
| 1 | C8-F02 — the LibKa0s inventory, wrong in nine places | library-stack.md + ripple | patch | **clear win** |
| 2 | C10-F03 — a local suite silently shadows the kit's | LibKa0s testkit + testing.md | tooling | apply |
| 3 | C10-F02 — the documentation-shape gate, five names | LibKa0s testkit + testing.md | tooling | apply |
| 4 | C9-F01 — `docs/revendor/` is the fifth frozen store | documentation.md + audit-review-history.md | minor | apply |
| 5 | C10-F01 — the 1500-line cap gate, five copies | LibKa0s testkit + layout.md | tooling | apply |
| 6 | C3-F05 — retail raises on an unknown event name | events-frames-taint.md §1 + kit | minor | apply |
| 7 | C9-F02 — the re-vendor bundle convention has lapsed | audit-review-history.md + AUDIT.md | tooling | apply |
| 8 | C4-F03 — nothing pins the test record to its tree | automated-tests.md §4 | minor | apply |
| 9 | C1-F06 — bus message names published once as constants | architecture.md §4 | minor | apply |
| 10 | C1-F03 — name the rule-subject conformance suites | testing.md §8 + naming-cheatsheet.md | patch | **clear win** |
| 11 | C3-F07 — `Settings.OpenToCategory` and the collapsed tree | options-ui.md | patch | apply |
| 12 | C8-F03 — `Widgets.DragHandle` earns a rule, or not | library-stack.md (+ options-ui.md) | minor | apply |
| 13 | C1-F07 — the casing of `<Event>` | naming-cheatsheet.md | minor | apply |
| 14 | C1-F08 — the self-naming file header | documentation.md | minor | apply |

---

# Owner calls

Three findings the evidence cannot decide. Each is a MUST that a substantial fraction of the collection
escapes, or a place where the standard says two things. The playbook forbids picking, and the reason is
that the decision is not recoverable from the evidence: guessing here is how a real rule gets softened
away, or how N repos get told to do busywork.

## O1 — events-frames-taint-§1 forbids private event frames, and the standard legislates around them twice

**Target section:** `standards/standards/events-frames-taint.md` §1 · **Evidence:** 4 repos touched,
3 violating, 1 complying at a cost · **Bump:** minor

`§1` reads "**MUST** use AceEvent-3.0 … **MUST NOT** create per-module frames just for events
(boss-mod-scale hand-rolling is overkill below 1000 events/min)". The vendored AceEvent-3.0 exposes no
`RegisterUnitEvent` (zero hits in `libs/AceEvent-3.0`) and therefore structurally cannot filter a `UNIT_*`
event to a unit, so an addon that wants the client-level filter drops to a raw frame.

**READING A — the collection is non-compliant, and the rule stands.**
KickCD (`core/Util.lua:438`, a general-purpose private-frame factory called from `modules/IconGrid.lua:821`
and `modules/Castbar.lua:1030`) and LootHistory (`modules/Attribution.lua:367`) each owe a register row;
AbsorbTracker already has one (`docs/ARCHITECTURE.md:601`). **Counts: 3 repos violating, 1 with a ratified
row, 2 unfiled.** Cost: two more rows saying what AbsorbTracker's row already says, and the next addon that
needs a unit filter writes a fourth copy of the same argument.

**READING B — §1 is out of step with two other sections, and this is a contradiction rather than a missing
exception.** The standard has **already legislated around** the frames §1 forbids:
`slash-commands.md:186` requires the disabled-state teardown to unregister "every `RegisterEvent`,
`RegisterUnitEvent` … **including the per-unit frames** — gone, not gated", and `testing.md:32` makes
recording `RegisterUnitEvent` a mock-fidelity MUST because "a no-op `RegisterUnitEvent` lets a widened or
dropped per-unit event filter pass the entire suite" (implemented at `LibKa0s/testkit/mock_base.lua:226`).
**Counts: 3 sections in play, 2 of which presuppose the frames exist and are legitimate; 1 repo (AuraMaster)
complies with §1 and recorded the bill at `modules/TimedSpells.lua:13` — a raid-wide `UNIT_AURA` firehose it
then gates on combat lockdown and aura secrecy to keep bounded.** Under this reading the fix is a carve-out
by name — a private `CreateFrame` whose only job is `RegisterUnitEvent` for a named unit — with the three
conditions three repos independently arrived at: the frame is held where teardown can reach it and not in a
closure; it is unregistered in the module's disable path, because AceAddon's `UnregisterAllEvents` does not
reach it; and it is re-used across a disable/enable cycle rather than rebuilt. Cost: a carve-out phrased
loosely ("a frame just for events is fine when you need filtering") re-admits the boss-mod hand-rolling the
MUST NOT was actually aimed at.

**What the verification changed.** PartyFrameEnhanced is **not** a violator — its registrations sit on the
cast bars, pet buttons and target buttons themselves, and its own ratified row says "The frames are the
elements themselves, not frames made for events." So reading A's precedent rests on **one** ratified row,
not two, and reading B is stronger than the finding argued: the statement's "the rule as written makes the
client-level filter unreachable" is false — it is already reached, twice, by the standard's own text.

**Rollout debt.** Under A: KickCD and LootHistory each file a `## Documented deviations` row with a
re-check trigger; nothing else moves. Under B: `events-frames-taint-§1` gains the carve-out and the three
conditions, `slash-commands-§7` and `testing-§1` are re-read for consistency with it, and the three existing
rows (AbsorbTracker, PartyFrameEnhanced, and whichever of the two new ones is filed first) are retired
rather than added to. Note for either: the same three conditions in three repos is category-2 evidence that
the wrapper itself is a LibKa0s extraction candidate, which changes what B costs.

## O2 — packaging's ignore template is unconditional while its own strong form binds only what is present

**Target section:** `standards/standards/packaging.md` · **Evidence:** 7 repos carry a hand-written
`.pkgmeta` paragraph on this; 2 audits filed it from opposite directions · **Bump:** patch

The minimum template lists `.claude` and `.superpowers` unconditionally (`packaging.md:19-20`) and the MUST
at `:33` attaches no condition to them — while conditioning `tools/` explicitly ("**if the repo has one** …
an addon with no generator has no such folder and owes no such line"). The strong form at `:34` then scopes
the real check to "Every root dotfile and dot-directory **present in the repo**". `AUDIT.md:210-212` bakes
the split into the runner: `tools` gated on `[ -d tools ]`, `.claude .superpowers` enumerated unconditionally.

**READING A — the strong form governs; the template is a template.**
Comment both lines out of the template the way `tools/` is, rewrite the MUST as "the agent-tooling
directories `.claude/` and `.superpowers/` **where the repo has them**", and add the sentence LootHistory's
audit asks for in as many words: the list is a template whose entries bind only when the entry exists,
because a list padded with absent entries goes stale in the direction nobody notices.
**Counts: 5 of 11 addons behave this way and argue it in a committed comment** — PanelMaster (neither
directory, neither listed), BankLedger and LootHistory (no `.claude`, deliberately no line), PrettyChat and
WhatGroup (no `.superpowers`, deliberately no line). Under this reading **2 repos are wrong**:
PartyFrameEnhanced lists both while neither exists, AuraMaster lists `.claude` while it does not.

**READING B — the template is normative; the two dot-directories are a forward declaration.**
Delete "present in the repo" from `:34` and say the two lines are carried unconditionally so a tool that
creates one later cannot ship it. **Counts: 6 of 11 addons list both** (AbsorbTracker, AuraMaster,
ConsumableMaster, KickCD, MultiMeters, PartyFrameEnhanced). Under this reading **5 repos are non-compliant**
— PanelMaster, BankLedger, LootHistory (missing `.claude`), PrettyChat, WhatGroup (missing `.superpowers`) —
and every one of them would be told to add a line whose own committed comment explains why it would assert
something false.

**5 against 6 is why no per-addon process will ever close this.** The two audits prove it: MultiMeters
`MM-A-04` filed it Medium for omitting present directories; LootHistory `LH-61` filed it Info for refusing
to name an absent one, and routed it upstream explicitly.

**What the verification changed.** The two bullets are jointly *satisfiable* — listing both always breaks
neither — so this is **under-specification and inconsistent treatment**, not a strict contradiction. The
"asserts something untrue" objection is the collection's own invented norm, not a rule the standard states.
Four repos are compliant under either reading, so the readings diverge in seven, not eight. And one fact
tempers the severity: `git ls-files .claude` and `.superpowers` return **zero** in all eleven addons, so
neither directory is tracked anywhere and no package ships either today — the player-facing harm MM-A-04
describes is historical.

**Rollout debt.** Under A: PartyFrameEnhanced and AuraMaster remove a line each; `AUDIT.md:210-212` moves
`.claude .superpowers` behind the same `[ -d ]` gate `tools` already has. Under B: five repos add a line,
each over a committed comment arguing the opposite, and `AUDIT.md` is unchanged. Either way the rule should
then be stated **once** rather than in a template and two bullets — the present split is what let seven
repos each write their own paragraph.

## O3 — nothing gates the `.gitattributes` body, and reversing §7's exclusion is the owner's call

**Target section:** `standards/standards/line-endings.md` §7 + `LibKa0s/testkit/test_eol.lua` ·
**Evidence:** 12 of 14 repos fail a published MUST · **Bump:** tooling, with a section reversal beside it

`line-endings-§5` fixes one canonical `.gitattributes` body per repo kind and requires `*.sh text eol=lf`
and `*.py text eol=lf` in both (`:198-199`, `:289-290`). Only AuraMaster and LibKa0s carry the `*.py` line;
nine addons plus both tooling repos do not. It is invisible because `line-endings-§7:466` consigns
properties (a)–(d) to the audit: "A green suite **MUST NOT** be read as covering (a) through (d) … Those
stay the audit's work, every cycle."

**The part that is no longer a question.** The verification refuted the "narrow the rule to repos that track
a `.py`" reading. Five repos track Python — AuraMaster, LibKa0s, PanelMaster (four files), PrettyChat,
wow-addon — and **three of those five lack the line** while shipping `#!/usr/bin/env python3` scripts, so the
claimed perfect correlation does not hold and the breakage §5 describes is live in three repos. The failure
is also **body drift**, not twelve independent omissions: the twelve carry the superseded six-line shell-only
comment block while the two carry §5's current eight-line block that added the `python3\r` rationale and the
`*.py` pin. So the twelve are one un-propagated revision, not twelve judgments.

**What is left for the owner is the section reversal.** `§7` states, as a deliberate position, that the
green suite does not cover (a)–(d) and that they stay the audit's work every cycle. Adding the case reverses
that position, and §7 makes the *opposite* argument about property (e) three paragraphs earlier — "A rule
with an auditor and no seam is a rule that gets re-swept every cycle … it comes back because between one
audit and the next nothing in the repo ever mentions it again."

**Reading A — reverse it.** The argument for (e) transfers word for word, the bodies are published and
copyable whole (the `test_prose.lua`/BRITISH-list precedent), and twelve repos failing one published line
for want of a seam is the exact failure (e)'s argument names. **Count: 12 of 14 failing, 2 passing, and the
2 that pass are the 2 someone happened to touch.**

**Reading B — keep §7 as written and fix the twelve by hand.** The bullet is a stated position with a stated
reason, and a byte-identity assertion is a new class of gate that reddens on any legitimate §5 appendix
until every diff is triaged. **Count: 5 repos' bodies differ in length from the eleven-repo common body
(PanelMaster 87, AuraMaster 84, LibKa0s 82, the two tooling repos 82, against 81) — PanelMaster's six extra
lines are a legitimate §5 appendix (the realesrgan binary mark), and each other diff needs the same triage
before byte-identity can be turned on.**

**Rollout debt.** LibKa0s leads (kit revision bump), then a re-vendor. Twelve repos owe a one-line
`.gitattributes` edit — or, better, the whole current §5 block, since the omission is drift of that block.
WowAddonStandards and wow-addon track no `.lua` and run no suite at all, so for those two it stays
`AUDIT.md`'s check under either reading.

---

# Clear wins

## 1 — C8-F02: the LibKa0s inventory is wrong in nine places, and one of them is anti-pattern #48

**Target section:** `standards/standards/library-stack.md`, plus the full ripple ·
**Evidence:** the tree versus nine copies of the prose · **Bump:** patch · **Clear win — auto-apply**

The library ships **eighteen** `.lua` files, the Options major spans **five** (`Options`, `OptionsWidgets`,
`OptionsTabs`, `OptionsCompose`, `OptionsScroll`) and Widgets **two**, and `LibKa0s/tests/majors.lua` — the
repo's own gate-backed manifest — says so. The standard says otherwise in nine places, and `OptionsTabs.lua`,
which owns the tab strip options-ui-§13 makes mandatory, the page banner and (since its minor 2) the combat
lock's page cover, is named **nowhere** in the standard at all.

**The proposed change, as one commit:**

- `library-stack.md:82` — "seventeen files" → **eighteen**; "`Options` spans four files" → **five**.
- `library-stack.md:94` — the Options row's file list → all five.
- `library-stack.md:91` — the Widgets row's file list → `Widgets.lua`, `WidgetsDragHandle.lua`.
- `library-stack.md:103` — "ten of the eleven majors" → **eleven of the twelve**.
- `library-stack.md:113` — "three of the ten gate on it without calling a single member" → **eight of the
  eleven**, which is the measured figure and makes the argument stronger rather than weaker: the floor's
  purpose is to make a partial payload fail whole rather than mixed, and that is the majority behaviour, not
  an edge case. Keep `Lifecycle` as the named example.
- `options-ui.md:13` — "spans **three** files" → a pointer at library-stack-§7 with **no count of its own**,
  since a count restated in a second section is a count that will drift again.
- `anti-patterns.md:54` (#48) — "Four of LibKa0s's five majors" → **eleven of the twelve**, matching
  `library-stack.md:113` word for word so the two cannot drift apart; and the attach-file enumeration →
  `OptionsWidgets.lua`, `OptionsTabs.lua`, `OptionsCompose.lua`, `OptionsScroll.lua`, `PerfPanel.lua`,
  `WidgetsDragHandle.lua`.
- `STANDARDS.md:57` (the Sections blurb) and `EXECUTIVE_SUMMARY.md:56` — eighteen.
- `NEW_ADDON_CONTEXT.md:489` and `:817` — the five-file list; `:1037` — eleven of the twelve. Bump the
  pack's own version in the same commit.
- `open-evolutions.md:13` — the third copy of the file count, which neither sweep found.
- Point options-ui-§13's tab-strip rules at the file that implements them.

**Why it is a clear win.** Every figure is a fact about the tree, verified twice, and no rule moves. The cost
of leaving it is the one #48 itself describes: a shell that arrives without an attach file `:New`s
successfully and fails at call time, and an auditor working #48's own list would not think to look for the
missing tab strip.

**Rollout debt: none for any addon.** `OptionsTabs.lua` is byte-identical (md5
`deef16f2e6a8abc072dedafdf53c53d4`) in LibKa0s and in all eleven `libs/LibKa0s/` copies; every consumer
already vendors the whole folder, which is what the rule actually requires. The debt is entirely inside the
standard, and it is the reason this must land as one commit: a fix applied to one copy and missed in another
leaves an agent completing the list from whichever copy it read.

**The durable half, carried from C5-F03 and worth taking with it.** Stop restating the library's file list in
prose that nothing checks. Make §7 the only place the inventory is written and derive it from
`LibKa0s/LibKa0s/LibKa0s.xml` — either generated the way `LibKa0s/tools/gen-api-members.lua` already
generates the API documents, or asserted by an `AUDIT.md` check that diffs §7's list against the sibling
checkout's XML. This is the **second** time this table has fallen behind, and the first correction bought
four weeks.

## 10 — C1-F03: name the conformance suites whose subject is a rule rather than a module

**Target section:** `standards/standards/testing.md` §8, with a `naming-cheatsheet.md` row ·
**Evidence:** 11 of 11 addons (12 of 12 counting LibKa0s) · **Bump:** patch · **Clear win — auto-apply**

`testing-§8` specifies the stub-surface parity case in four bullets of detail — the grep-derived member list,
the grep named in the comment, the degraded arm from a partial file list, nil-valued members counted as
divergence — and never says what file it lives in. All eleven addons put it in
`tests/test_surface_parity.lua`, and all eleven open that file with a header naming it at line 1. The
cheatsheet's only test-suite row is `test_<module>.lua`, and there is no module called SurfaceParity.

**Proposed change:** the stub-surface parity cases **MUST** live in `tests/test_surface_parity.lua`, listed
in `tests/run.lua` like any other suite. Add the cheatsheet row for the general case —
`test_<rule-subject>.lua` for a conformance suite whose subject is a standard rule rather than a source
module — citing the two instances the standard already names by filename (`test_disabled.lua` at
`slash-commands.md:271`, `test_kitsync.lua` at `testing.md:316`) plus this one.

**Why it is a clear win.** Unanimous existing practice, zero rollout debt, and the gap is specific rather
than general: the standard's house style *is* to name such a file at the point it mandates the suite, and §8
is the outlier. The reason to fix the name rather than leave it to habit is that an auditor checking §8
compliance across eleven repos currently has to find the suite before grading it, and a repo that renames it
fails nothing.

**Rollout debt: none.** All eleven already comply. `NEW_ADDON.md` and the `new-addon` scaffold need the
filename added so a new repo is born with it.

**Carried from C1-F04, and worth one sentence in the same edit:** `tests/test_vendor_sync.lua` is likewise
eleven-for-eleven, likewise unnamed, and every copy is a 31–39-line delegation to `tests/_kit/vendor_sync.lua`.
The MUST worth keeping is that the consumer half **delegates** rather than reimplements, for the reason
library-stack-§7 already gives about the provenance line: two implementations of one gate means the kit can
be fixed and eleven repos keep failing the old way.

---

# The rest, ranked

## 2 — C10-F03: a consumer suite whose basename collides with a kit suite silently shadows it

**Target:** `LibKa0s/testkit/framework.lua`, with one sentence in `testing.md` ·
**Evidence:** 6 of 12 repos shadowing; mechanism confirmed in source · **Bump:** tooling

`suiteDeclarations` keys `declared` by bare name (`framework.lua:654`) and the kit-directory pass hands that
same name-keyed set to `collectUndeclared` (`:744`), so a bare `"test_prose"` declared from `tests/`
satisfies `tests/_kit/test_prose.lua` and the kit copy is never loaded. Six repos are in that state —
BankLedger, ConsumableMaster, LootHistory, PrettyChat, WhatGroup and LibKa0s itself — each running a
262–443-line local copy while believing it is gated. The kit's README states the rule ("wires one or the
other, never both", `:145`) and claims the scan covers `tests/_kit/` (`:109`); nothing enforces either.

**Proposed change.** (1) Key the declaration set by the pair `(name, dir)`: a suite present in `tests/_kit/`
must be declared with an entry whose `dir` names the kit, and a consumer suite of the same basename declared
without a `dir` is **reported as a collision**, naming both paths and saying which one is running — not
silently accepted. (2) The same pass reports any `tests/_kit/*.lua` suite on disk and unreferenced, which is
the general form and covers the next kit suite. Both fail rather than skip, for the reason the kit's own
headers already give. `testing.md` gains one sentence recording the one-gate rule so it has a normative home
and not only a comment.

**Why it ranks second.** Six repos believe they are gated and are not; the divergence is already real (the
kit copy reads `tests/prose_waivers.lua`, WhatGroup and LootHistory hardcode `WAIVED`); and all seven
BRITISH lists are byte-equal **today**, which is exactly why this is worth fixing before the next amendment
rather than after — localization-§5 requires the published list be copied whole and amended upstream only,
so an amendment arriving with a re-vendor would reach six repos' dark copy and none of their live ones.
It is also the **ordering constraint** for proposals 3 and 5: extract, then delete the local copy in the
same commit that wires the kit's, or the extraction re-creates this trap in five more repos.

**Rollout debt.** LibKa0s leads. On re-vendor the new check goes red immediately in BankLedger,
ConsumableMaster, LootHistory, PrettyChat, WhatGroup and LibKa0s; each clears it by deleting its local
`tests/test_prose.lua`, wiring `{ name = "test_prose", dir = "tests/_kit/" }`, and adding
`tests/prose_waivers.lua` where it had a hardcoded `WAIVED` table. The other six need only the re-vendor.
Each of the six also owes a `docs/test-cases.md` count refresh, since the case names move.

## 3 — C10-F02: the documentation-shape gate exists under five names with five coverage sets

**Target:** `LibKa0s/testkit/test_docs.lua` (new), cited from `testing.md`; `AUDIT.md` keeps the prose ·
**Evidence:** documentation-§3 cited in 11 of 11 addons, recurring 4–5 times per repo · **Bump:** tooling

documentation-§1/§3/§5 is the collection's most-cited rule family and its enforcement is five hand-written
basenames with materially different coverage (`test_docs.lua`, `test_docmap.lua`, `test_doc_structure.lua`,
`test_deviation_register.lua`, `test_register.lua`), with PartyFrameEnhanced carrying none among 30 suites.
Only the evidence-id case is near-universal. `AUDIT.md:106-144` already expresses the six checks as prose, so
this moves an existing specification into the kit rather than designing one.

**Proposed change.** The kit gains `test_docs.lua` asserting AUDIT.md's six checks: (a) the six Tier 1 files
under exactly their canonical names; (b) `## Documentation map` with exactly four tables in order and every
`.md` under `docs/` in exactly one of them, minus the enumerated out-of-scope directories, with no row
naming a file that does not exist; (c) the six Verification-and-record rows; (d) no retired or
non-canonical filename; (e) every anchor into `docs/ARCHITECTURE.md` resolving to a heading; (f) every
evidence id a `## Documented deviations` row cites resolving to a bundle under `docs/audits/`.
Tier-2 trigger counts come in through a consumer-supplied opts table, since only the consumer knows where to
count them. **Two things it must not do:** assert the soft ~60/~400-line hub guidelines (a soft threshold
that reddens a commit gate is how a gate acquires a switch), and carry a private list of retired names — the
list is published in the standard and copied whole, like localization-§5's BRITISH list.

**Rollout debt.** LibKa0s leads, then a re-vendor in all eleven addons. PartyFrameEnhanced gains doc-shape
enforcement for the first time. Five repos swap and delete a local `test_docs.lua`/`test_docmap.lua`; five
swap and delete `test_doc_structure.lua` (MultiMeters and WhatGroup hold two each); BankLedger,
ConsumableMaster, PanelMaster, PrettyChat and WhatGroup also delete a separate `test_register.lua`.
Predictable first-run reds: PrettyChat's two orphaned `docs/revendor/` files (`PC-71`) and its stale second
inventory (`PC-74`). **Correction to the finding:** reds are *not* expected in AuraMaster or
PartyFrameEnhanced — their registers hold 2 and 1 rows and neither uses an ID column, so check (f) has
nothing to resolve there.

## 4 — C9-F01: `docs/revendor/<date>/` is the collection's fifth frozen store

**Target:** `documentation.md` §3's scope sentence + `audit-review-history.md` · **Evidence:** 10 of 11
addons, 68 bundles · **Bump:** minor

Ten addons ship the store and each hand-amended a normative sentence it otherwise quotes verbatim, because
every `.md` under `docs/` MUST sit in exactly one table and the rule does not mention the directory. The
amendments have already diverged four ways: MultiMeters gives it a table row *and* names it in scope
(breaking the "exactly one table" MUST against its own amendment), AuraMaster adds `docs/spell-research/`,
AbsorbTracker alone still carries `docs/investigations/`, and PartyFrameEnhanced has no scope sentence at
all. A rule that leaves ten repos editing its text is a rule that has not been written.

**Proposed change.** Name `docs/revendor/<date>/` in documentation-§3's frozen-and-generated scope sentence
alongside the six already there, and in `audit-review-history` as the third frozen dated bundle kind beside
`docs/audits/` and `docs/reviews/`. Settle the directory name on `<date>-v<tag>` — the majority form and the
only one that says which library release the bundle is about, which matters because a single day can carry
two re-vendors. State that the store carries no `README.md`, since no repo has written one against six that
ship `docs/perf-analysis/README.md`.

**Two corrections from the verification, both load-bearing.** State the contents as a **numbered-prefix
convention whose stable members are `01_DELTA.md` and `05_SUMMARY.md`**, not a five-file MUST: the full set
appears in only 40 of 68 bundles, 19 lack `04_EXECUTION_PLAN.md` (nothing was adopted) and 9 carry two. And
**do not** write a general "an addon adds nothing to the scope list" rule — confine the upstream-change rule
to a frozen store written by a shared command across repos, or it contradicts Tier 3
(`documentation.md:296-301`: an addon-specific subject "MAY ship under any name, and the standard MUST NOT
name it … a home that does not require an upstream change to create") and wrongly turns AuraMaster's
`docs/spell-research/` into upstream debt.

**Rollout debt.** PartyFrameEnhanced: no store, no `docs/reviews/`, and no frozen-directory scope sentence in
its map — it needs the sentence written and the store created at its next re-vendor. MultiMeters: move
`docs/revendor/` out of the table row or out of the scope sentence, not both. AbsorbTracker: keeps its
`docs/investigations/` line, and its one bare-dated folder (`2026-09-14`) is a rename of a frozen bundle,
which must be decided explicitly rather than done silently. The other nine: their hand-written sentence
becomes a quote of the rule, no content change.

## 5 — C10-F01: the 1500-line cap gate is hand-written five times and absent from seven repos

**Target:** `LibKa0s/testkit/test_layout_cap.lua` (new) + a prose half in `layout.md` or `documentation.md` ·
**Evidence:** 5 divergent copies, 7 repos ungated, 12 in scope · **Bump:** tooling

layout-§1's cap is a MUST whose only mechanical enforcement is five hand-written suites (232/221/209/380/206
lines, all md5-distinct) that already disagree about what they read. The extraction is unusually cheap — the
whole input is `git ls-files`, a line count and one heading in a hub document — and layout-§1's three
terminal states give the gate an exact thing to assert.

**Proposed change.** The kit gains the gate, vendored and wired as
`{ name = "test_layout_cap", dir = "tests/_kit/" }`, asserting over the `git ls-files` set with `libs/` and
`tests/_kit/` dropped: (a) no authored `.lua` over 1500 lines is absent from the hub's census; (b) every
census row names a path that still exists and is still over the cap, so a disposition cannot outlive its
breach; (c) each over-cap row carries one of the three terminal states. It fails rather than skips when it
cannot look — no `io.popen`, no git, no hub — the same bargain `test_eol.lua` and `test_prose.lua` strike.
Consumer facts (the hub's path, any genuine carve-out) go in an opts table the way `vendor_sync.register`
already takes one.

**Two things the verification changed, and both need deciding in the extraction.** The heading disagreement
is a different heading **name**, not a level: PanelMaster looks for ``### Files by the `layout-§1` band``
because it is the copy that also asserts the 1000–1500 band, against `### Files over the 1500-line cap` in
three addons and `## …` in LibKa0s. And **parts (b) and (c) need a prose half first** — no section mandates a
census heading in the hub at all, so without it the gate asserts a document structure the standard does not
require. PanelMaster's band assertion additionally collides with `automated-tests.md:268` ("the band is a
column, not a heading"), which already places the band record in the automated-test bundle's watch list; that
ruling should be made against that rule rather than in isolation.

**Rollout debt.** LibKa0s leads, then a re-vendor. Gains the check outright: AbsorbTracker, AuraMaster,
BankLedger, KickCD, LootHistory, PartyFrameEnhanced, WhatGroup — seven repos where the cap may already be
breached unnoticed (AuraMaster has four over-cap files with no terminal state today). Swap and delete the
local copy in the same commit: ConsumableMaster, MultiMeters, PanelMaster, PrettyChat, LibKa0s.

## 6 — C3-F05: retail raises on an unknown event name, and one retired name deafens the block

**Target:** `events-frames-taint.md` §1, with the better half in the kit · **Evidence:** 5 repos ·
**Bump:** minor

Modern retail raises rather than ignoring, so a bare registration loop turns one retired event name into a
silently deaf addon — every registration after the throw goes unbound, with no visible error unless the
player has script errors switched on. §1 mandates AceEvent registration and says nothing about it.

**Proposed change.** State the client behaviour in §1 and require that a registration block survive one bad
name. **Promote BankLedger's version — it is the deepest**, and it is the only one that names the *silent*
half, which is the whole reason this is dangerous rather than annoying, and the only one with a complete
mechanism rather than a mitigation: per-event isolation (`modules/Ledger.lua:849`), rejected names recorded
in `Ledger.unavailableEvents`, and a player-reachable report through `/bl debug scan` — so a deaf event is
*discoverable*, not merely survivable. Carry MultiMeters' cheaper front gate as the complementary half with
its own stated reason for not relying on it alone (`C_EventUtils.IsEventValid` is the cheap ask, "where even
that is missing" the fallback still has to hold) and its worked judgment call on
`PLAYER_IS_GLIDING_CHANGED`: "losing that one edge is survivable where losing the block is not."

**Prefer the check to the paragraph.** `LibKa0s/testkit/mock_base.lua:715-727` already models the raise and
`PanelMaster/tests/test_harness.lua:115-123` already asserts against it, so the kit can carry the assertion
for everyone, and `RegisterEventSafely` is a five-line helper five repos would otherwise keep re-deriving.

**Rollout debt.** BankLedger and MultiMeters comply. ConsumableMaster fixed its instance
(`LEARNED_SPELL_IN_TAB` → `LEARNED_SPELL_IN_SKILL_LINE`) but carries no isolation and owes the guard.
**AbsorbTracker owes a documentation correction rather than a guard**: `docs/midnight-quirks.md:118-120`
records the *opposite* model ("the registration succeeds but the event never fires"), which is wrong and
would mislead the next author. Seven repos are unmeasured and need `/wow-addon:standards-audit`. If the
helper is extracted, LibKa0s leads and must be tagged and pushed before consumers cite it.

## 7 — C9-F02: the re-vendor bundle convention has lapsed collection-wide

**Target:** `audit-review-history.md` (name the store) then `AUDIT.md` (the check) · **Evidence:** 11 of 11
addons behind · **Bump:** tooling, with a prose half

The store proposal 4 finds ten repos converging on has stopped being written everywhere at once. The newest
bundle in nine stores is `2026-09-13-v1.34.0` and AbsorbTracker's is `2026-09-14`, against a library now at
**v1.54.2** — roughly 15 to 20 re-vendor commits per repo, for tags past each repo's newest bundle, with no
bundle written for any of them. Nothing went red, because no audit check reads the store and no MUST names it.

**Proposed change, and it is two-part rather than one.** The finding proposes only an `AUDIT.md` check, but
an audit check measures conformance to the standard and `docs/revendor/` is named in no section — so the
store needs a home first (proposal 4's `audit-review-history` half), and the check second: for every
`Re-vendor LibKa0s v<tag>` commit in the repo's history, a `docs/revendor/` bundle naming that tag must exist
or the absence is justified in the deviation register. `versioning-git.md:9` already requires the re-vendor
commit and requires it to stand alone, so the commit subject is a reliable trigger and the check is a
git-log-to-directory-listing comparison.

**One correction to the causal story, because it changes the remedy.** The convention is not purely
emergent: `wow-addon/commands/revendor-libka0s.md:171` and `:307` mandate the bundle and freeze it, and
`wow-addon/CLAUDE.md:61` names it as one of three frozen artifact stores. It lapsed because twenty library
releases were carried by bulk suite sweeps that never invoked `/wow-addon:revendor-libka0s`, not because
nobody wrote the rule down. Prose alone will not hold it — which is the argument for the check, but the check
has to have a rule behind it.

**Rollout debt.** All eleven addons are behind. Back-filling twenty bundles per repo is not the answer; the
realistic debt is **one consolidated bundle per repo** covering v1.34.0/v1.35.0 → v1.54.2, written by
`/wow-addon:revendor-libka0s` on its next run. PartyFrameEnhanced additionally needs the store created.

## 8 — C4-F03: nothing pins the automated-test record to the tree it describes

**Target:** `automated-tests.md` §4 + the runner and a kit case · **Evidence:** 10 of 10 reviewed repos ·
**Bump:** minor

§4 is thorough about what a `RESULTS.md` row must contain and who may write which cell, and silent on when
the record stops describing the tree. The 2026-09-07 sweep found the newest bundle behind the working tree in
**ten of ten** reviewed repos (the finding said six), by margins that moved the very numbers the record
exists to carry — AbsorbTracker's was two source-moving commits stale and its figures moved by 39 tests and
906 NLOC.

**Two distinct defects sit under that, and only the second is a gap.** Going stale is expected and §4 knows
it: the file is regenerated at release, and several reviews call it "stale, not non-compliant". Being
**unknowable** is the gap — LibKa0s' v1.25.0 release bundle records a dirty tree, so the run cannot be
reproduced from its own SHA, and ConsumableMaster's newest bundle is dirty too. A reader cannot tell a row
that is two commits old from one that describes no commit anyone can check out.

**Proposed change.** In prose: §4 gains a MUST that every row carries the **commit SHA** the run measured and
whether the tree was **clean** at that SHA, and a MUST NOT on recording a run from a dirty tree without
marking it. In tooling: the runner emits both into the row and the manifest — it already knows them — and a
kit case **reports** when the newest bundle's SHA is not HEAD. Report, never fail: §4 is explicit that perf
and complexity do not gate a commit, and a staleness check that blocks work is one people learn to bypass.

**Rollout debt.** No repo becomes non-compliant on the day the rule lands — existing rows are historical.
Every repo's next run emits the two new cells. LibKa0s leads if the kit case is taken.

## 9 — C1-F06: bus message names are published once as constants, or a typo is silent

**Target:** `architecture.md` §4, with a `naming-cheatsheet.md` row · **Evidence:** 5 repos + 1 equivalent ·
**Bump:** minor

architecture-§4 mandates the closed bus, the `Ka0s_<Addon>_` prefix, one sender and per-receiver targets —
and types the literal at both call sites in its own example. Five addons publish the names once as a
constants table so the literal appears exactly once in the repo; a sixth reaches the same end with
module-scoped constants. The cost of the alternative is specific to pub/sub: a misspelled name in a
publisher or a subscriber is silently a message nobody sends or nobody hears, and no lint, no test and no
client error sees it.

**Proposed change.** An addon's bus message names **MUST** be declared once as constants, and every
`SendMessage` and `RegisterMessage` call site uses the constant rather than the literal. Name a
namespace-level table (`core/Bus.lua`, or `core/Constants.lua` where the addon has no bus file) as the
preferred home and permit module-scoped exported constants as PanelMaster uses them, rather than forcing one
shape. **Write the rule against the addon's namespace seam, not the token `NS`** — two of the five use
`KCM.MSG` and `Constants.MSG`.

**Two corrections from the verification.** PanelMaster **already conforms** (`modules/Registry.lua:19-21`,
`settings/Schema.lua:31-35`, consumed at `modules/Canvas.lua:878-880`), so it is not rollout debt. And the
proposed SHOULD's justification is false as written — three of the five name the sender in-file, not one, and
`architecture.md:91` already MUSTs the sender be documented in `docs/ARCHITECTURE.md`; so the SHOULD should
read "the constant MAY carry its sender in a comment beside it, satisfying §4's sender documentation there".

**Rollout debt.** BankLedger, KickCD and LootHistory type literals at publisher and subscriber and each need
a constants table plus a call-site sweep. PrettyChat and WhatGroup ship one module each and publish no
`Ka0s_` message at all, so the rule is vacuous for them and the honest state is a *Not applicable* note, not
work. Sequencing note: KickCD must adopt the table **before** proposal 13's rename, which is what makes that
rename behaviour-preserving.

## 11 — C3-F07: `Settings.OpenToCategory` takes a numeric ID and leaves the sibling tree collapsed

**Target:** `options-ui.md`, beside the combat-refusal rule that already governs this call ·
**Evidence:** 4 repos · **Bump:** patch

Four addons independently documented the same pair of facts: the call accepts the numeric category ID and
range-errors on the object (or on the frame `AceConfigDialog:AddToBlizOptions` returns), so the ID must be
captured with `:GetID()` at registration; and opening a *parent* leaves its subcategory tree collapsed,
hiding the sibling tabs the player is navigating to, fixed only by
`SettingsPanel:GetCategoryList():GetCategoryEntry(cat):SetExpanded(true)` — private API, so the walk sits
under `pcall` and degrades to "parent opened, tree collapsed". options-ui-§2 legislates the *combat* half of
this call thoroughly and is silent on both.

**Proposed change.** Record both as a catalogue entry. **Promote ConsumableMaster's write-up — it is the
deepest**: the only one that explains *why* the walk reaches the list entry rather than the category
("`SettingsCategoryMixin` does NOT expose a `SetExpanded` method — that lives on the visual list-entry
element"), and the only one stating the ordering constraint that makes the fix work ("Call it AFTER
`Settings.OpenToCategory` so `SettingsPanel` is realized and the entry element exists") and the reason to
re-run it every open. Take WhatGroup's sharper failure modes, including the silent one: "**Do not overwrite
`category.ID` with a string.** Doing so silently breaks the lookup and `OpenToCategory` becomes a no-op."
KickCD adds the AceConfig variant. Because `LibKa0s-Options-1.0` already implements all of it once for
everyone (`Options.lua:598`, `:1388-1399`), the right shape is an entry recording *why the library does it
this way* plus a MUST NOT on hand-rolling — not a rule every addon satisfies afresh.

**Two corrections that must be applied before this is written.** WhatGroup's "a parent with subcategories
renders no panel widgets" element is **already legislated** at `options-ui.md:84-91`, which MUSTs the
landing-page/subcategory split and mandates a parent *body* every addon in fact renders — so it must not be
promoted as new, and the finding's claim that "nothing currently checks it" is wrong. And a MUST NOT on
hand-rolling the open has to carve out the **page-jump helper** — a call against a recorded *subcategory* id,
combat-gated — which at least two repos ship (`AuraMaster/settings/OptionsSetup.lua:366-375`, and KickCD's
`Helpers.OpenPageTab`), or it makes two repos non-compliant on sight.

**Rollout debt.** Nobody, as a catalogue entry — hence patch. With the MUST NOT and its carve-out, the two
page-jump helpers need a measurement to confirm they sit inside it.

## 12 — C8-F03: `Widgets.DragHandle` was extracted for two hand-built copies and is named nowhere

**Target:** `library-stack.md` (the table fix rides with proposal 1) + an open question for
`standalone-windows.md` or `options-ui.md` · **Evidence:** 3 consumers, 8 non-consumers · **Bump:** minor

`WidgetsDragHandle.lua` ships as the second file of `LibKa0s-Widgets-1.0`, version-paired
(`__dragMinor`), publishing `DragHandle` and `DRAG_HANDLE`. Its extraction commit states the bar it met —
"the unlock anchor both addons hand-built", which is `library-stack-§7`'s two-consumers-same-semantics test.
`grep -rn "DragHandle\|DRAG_HANDLE" WowAddonStandards` returns **zero hits, repo-wide**.

**The inventory half rides with proposal 1** and is folded into that ripple. **What stays live here** is the
separable question the finding poses and does not answer: does the drag anchor earn a rule of `ReorderList`'s
kind? The comparison is the argument — both are members of the same major; options-ui-§18 makes one
mandatory and four addons consume it; nothing mandates the other and three consume it. The difference
between them is a rule, not a quality gap. options-ui-§18 is scoped to "where the **order** of a list is the
setting" and does not reach a frame-move handle, so nothing currently covers it.

**Rollout debt.** The table fix costs nobody anything. If a SHOULD is added, the eight addons not on
`DragHandle` each need a look at whatever they draw an unlock anchor with; those that draw none are
unaffected. No LibKa0s change is needed first — the surface ships at v1.54.2, which every addon vendors.

## 13 — C1-F07: the casing of `<Event>` in `Ka0s_<Addon>_<Event>`

**Target:** `naming-cheatsheet.md`'s Bus messages row · **Evidence:** 9 publishers, 7 against 2 ·
**Bump:** minor

The cheatsheet fixes the format and leaves the casing unstated, in a column where every neighbouring row
states one. Seven addons write PascalCase and two SCREAMING_SNAKE, each uniformly; both are defensible
against the text as written, which is the tell that the omission is the defect. It matters more than casing
usually does because the bus is the one namespace shared across the whole collection: a reader debugging two
Ka0s addons at once reads both addons' messages in the same chat log, and the format exists so they scan as
one family.

**Proposed change.** `<Event>` is **PascalCase** (MUST) and **SHOULD** name what happened, preferably as a
past participle — `Ka0s_ExampleBar_RosterChanged`, not `ROSTER_CHANGED` and not `UpdateRoster`. Note in the
same row that the SCREAMING_SNAKE **constant** proposal 9 asks for is a different thing from the wire string
it holds: `NS.MSG.CONFIG_CHANGED = "Ka0s_MultiMeters_ConfigChanged"` satisfies both rules.

**Two corrections.** Only **MultiMeters** let a constant's casing leak into the wire name; KickCD has no
constant table at all and simply chose the casing WoW's own event names use. And the rename is not uniformly
mechanical: three of KickCD's five names are state nouns (`COMBAT_STATE`, `SPELL_STATE`, `GRID_LAYOUT`), so
the past-participle half is a semantic rename there — which is why it is a SHOULD beside a PascalCase MUST.

**Rollout debt.** KickCD and MultiMeters rename every message. A bus rename is behaviour-preserving only if
publisher and subscriber move together, which is exactly what proposal 9's constant table makes safe — and
the two repos are unequally ready (MultiMeters has the table, KickCD does not). **Sequence it:** KickCD
adopts the table first, then both rename. PrettyChat and WhatGroup publish nothing and are unaffected.

## 14 — C1-F08: the self-naming file header

**Target:** `documentation.md` (a comment-convention bullet) or `naming-cheatsheet.md` ·
**Evidence:** 6 repos, 247 files · **Bump:** minor

Six addons open the large majority of their authored files with a comment naming the file's own path and
saying in one line what it is for. The standard mandates the documentation tiers, `## Documentation map` and
`module-map.md`, all of which answer *what files exist*; none answers *what is this file for* at the point
where a reader has the file open.

**Proposed change — a SHOULD, not a MUST, stating the reason rather than the form.** Every authored `.lua`
under `core/`, `modules/`, `settings/`, `defaults/` and `locales/` should open with a comment naming its own
path and saying in one line what the file is for — because `module-map.md` answers that in a file the reader
is not currently in, and a file whose purpose is recorded only elsewhere is one a later author merges away.
The path has a second job the collection has already leaned on: it is what survives a file being pasted into
a review, an issue or an agent transcript. **Settle the placement in the same edit** (carried from C9-F09,
which C1-F08 does not address): immediately after the `local _, NS = ...` bootstrap, which is what
documentation-§5's comment-citation check reads and what the six repos that place it consistently do.

**Why a SHOULD.** The convention holds at 87–100% wherever it was adopted, so it does not need enforcement
once chosen; a MUST would make 99 existing files across five repos retroactively non-compliant for a rule
whose value is in new code. **The opposite decision — stating that no header is required — is equally
available and equally ends the split**; what should not continue is 249 files with no answer.

**Correction to the finding's framing.** The claim that "repos are at 100% or at 5%" is false: re-measured,
the split is 63/63, 18/18, 56/58, 36/38, 41/47, 33/38 against 9/19, 13/28, 8/30, 5/30, 1/28. In the low
repos the headers sit almost exclusively on the LibKa0s seam files, where they arrived with the wiring
template rather than by choice. The rule stands on the convergence itself, not on a binary split.

**Rollout debt.** Under the SHOULD nothing is retroactively non-compliant; AbsorbTracker, BankLedger,
LootHistory, PanelMaster and PrettyChat adopt it going forward. Under a MUST it would be 99 files across
those five, which is the reason not to write it as one. Either way, the `new-addon` scaffold needs the
header seeded — even the strongest repos leave the same scaffolded files bare (`core/CoreSetup.lua`,
`settings/Slash.lua`, `core/Constants.lua`, `core/Namespace.lua`, `core/State.lua`).

---

## One discrepancy the owner should resolve before the interview

**C10-F07 — the no-blanket-suppression gate, hand-written ten times — was upheld by verification and is not
in the survivor set** handed to this bundle. It is recorded in `02_FINDINGS.md` as live-and-upheld. Its
substance: ten addons carry `tests/test_lintconfig.lua` at 256–278 lines, no two byte-identical, gating
lint's no-blanket-suppression rule, which `lint.md` states and provides no check for; PartyFrameEnhanced and
LibKa0s have none. The verification confirmed the counts and the coverage gap and trimmed one overreach —
"the same four assertions" is false for two of the ten (PanelMaster asserts the stricter "every inline
luacheck ignore names the code it answers"; AuraMaster carries a fifth, unrelated case), so the rollout is
eight clean swaps plus two that need a decision first.

If it was dropped deliberately, `06_OUTCOME.md` should say why so the next run does not re-file it. If it
was dropped by accident, it belongs at roughly rank 10 in the list above, beside the other kit extractions,
and it carries its own dedup note: `open-evolutions.md:8`'s *Shared luacheckrc base* entry is the **adjacent**
half, not this one — sharing the config would make every repo's `read_globals` the union of eleven addons'
client surfaces, which lint deliberately forbids, while sharing the gate over the config is purely additive
and needs no repo to give anything up.
