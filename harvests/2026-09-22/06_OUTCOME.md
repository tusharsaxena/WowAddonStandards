# Harvest 2026-09-22 — 06 Outcome

The record of what this pass decided and what it moved. `04_PROPOSALS.md` handed seventeen survivors to
the interview; **sixteen were accepted** and one was deferred. The standard went from **v2.62.1** to
**v2.63.0 (2026-09-22)** — a **minor**, because several accepted proposals can make a previously-compliant
addon non-compliant.

The release then went through an **adversarial audit before it was committed**, which found **thirteen
blocker reports — seven distinct blockers — and twenty-four majors** in the promotion pass's own work.
Clearing them took two further passes, and this file records all three.

- **Pass one — promotion.** The sixteen accepted proposals applied to the sections, the index, the context
  pack and the playbooks.
- **Pass two — the fix pass** (six agents, 2026-09-22/23). Killed all seven distinct blockers, verified dead
  at their sites, and cleared the majors. Recorded under *The fix pass* below. It introduced **count errors
  of its own** and left `layout-§1` contradicting itself — telling the gate to grade an exempt row against
  three conditions the same section says the gate cannot read.
- **Pass three — counts and the last rulings** (2026-09-23). Six counts re-measured against the live trees
  and corrected in the sections, three agents closing the remaining judgment-level defects, and this file
  and the index reconciled to what the sections finally say. Recorded under *The third pass* below.

Nothing in this bundle describes an intention: every claim here was measured against the working trees on
those dates.

This file exists to stop the failure the ripple plan names: an unapplied touch recorded as **nothing**.
Every item on the plan's checklist is marked below as **applied** or **not applicable with its reason**.
**The release closed with no open touch** — O3's section half, which the promotion pass left undone and
this file previously carried as open debt, landed in the fix pass.

---

## The owner's rulings

**O1 — events-frames-taint-§1, private event frames. Reading B: carve out the unit-filter case by name.**
Not a general permission and not a deviation register entry per repo. A private `CreateFrame("Frame")`
whose **only** job is `RegisterUnitEvent` is permitted, on three conditions — held on the module or `NS`
and not in a closure; unregistered in the module's disable path, because AceAddon's
`UnregisterAllEvents` does not reach it; re-used across a disable/enable cycle. The section states what the
carve-out does **not** admit, so a private-frame factory cannot re-enter wearing its clothes. The ruling
follows the evidence that the prohibition was inverted: the standard already tore down and tested the frame
it forbade (`slash-commands-§7`, `testing-§1`), and the one addon that complied paid a raid-wide `UNIT_AURA`
firehose for it. **The fix pass corrected the permission's scope**: it is written against the API's arity —
`frame:RegisterUnitEvent(event, unit1 [, unit2])` takes **one or two** tokens — because the `player`/`pet`
pair is the collection's live case, and a permission worded as *one unit* would have excluded the only shape
that motivated it.

**O2 — packaging's ignore template. Reading A: the strong form governs.** The template's `.claude` and
`.superpowers` lines are commented out with the condition inline, the way `tools` already was; the MUST now
reads "**where the repo has them**"; and the section says once that the list is a template whose entries
bind only when the entry exists. **Exactly one of the two bullets moved** — the strong form's "present in
the repo" is untouched, which is what the ruling turns on. The fix pass narrowed the strong form's **second
branch** in the same direction: a commented-out `ignore:` line is an absent entry carrying its explanation,
not a justification for shipping, so a repo that *has* the directory and leaves its line commented satisfies
neither branch. Read the other way the template would have discharged the MUST in advance for every entry it
names.

**O3 — the `.gitattributes` body. Reading 1: the collection is non-compliant, gate it.** Twelve of fourteen
repos fail a published MUST for want of a seam, and the failure is one un-propagated revision of the §5
comment block rather than twelve judgments. The gate is a **second case** in the kit's existing
`test_eol.lua`, not a new suite, and the canonical bodies are copied whole from `line-endings-§5` rather
than re-authored. **LibKa0s leads.** The section half did **not** land in the promotion pass and **did**
land in the fix pass: `line-endings-§7` now states that every property is checked mechanically and none is
eye-checked, and names test-kit revision 25 as the body case's commencement.

**O4 — the four batch groups, and C8-F03's SHOULD half.** All four groups accepted: the clear wins
(proposals 1 and 10), the kit-gate group (2, 5, plus O3), the record-and-store group (4, 7, 8) and the
rule-shape group (6, 9, 11, 13, 14). **C8-F03's SHOULD half is deferred to `open-evolutions.md`.** The
inventory half applied — `DragHandle`, `WidgetsDragHandle.lua` and `Widgets.DRAG_HANDLE` are named in
`library-stack-§7` for the first time. The rule half — whether an unlock anchor **must** be the library's
handle, the way `options-ui-§18` requires `ReorderList` — is recorded as an open evolution instead, because
the evidence cannot yet distinguish the eight non-consumers that have nothing positionable from a ninth
hand-built strip, and only the second makes this the shape `library-stack-§9` describes.

---

## Accepted (16)

| # | Finding | Where it landed | Bump |
|---|---|---|---|
| O1 | C7-F02 — private event frames | `events-frames-taint-§1`, two appended subsections | minor |
| O2 | C5-F02 — the ignore template vs the strong form | `packaging` | patch |
| O3 | C10-F04 — the `.gitattributes` body is gated by nothing | `line-endings-§7` (fix pass) + the kit | minor |
| 1 | C8-F02 — the LibKa0s inventory, wrong in nine places | `library-stack-§7`, `open-evolutions` | patch |
| 2 | C10-F03 — a local suite silently shadows the kit's | `testing-§9`, `localization-§5` | minor |
| 4 | C9-F01 — `docs/revendor/` is the fifth frozen store | `documentation-§3`, `documentation-§6`, `audit-review-history` | minor |
| 5 | C10-F01 — the 1500-line cap gate, five copies | `layout-§1` (census + gate), `automated-tests-§4` | minor |
| 6 | C3-F05 — retail raises on an unknown event name | `events-frames-taint-§1` | minor |
| 7 | C9-F02 — the re-vendor bundle convention lapsed | `audit-review-history`, `AUDIT.md` | minor |
| 8 | C4-F03 — nothing pins the test record to its tree | `automated-tests-§4` | minor |
| 9 | C1-F06 — bus message names published once as constants | `architecture-§4` (the sender comment as a **MAY**) | minor |
| 10 | C1-F03 (+ C1-F04) — name the rule-subject conformance suites | `testing-§1`/`-§8`/`-§11`, `naming-cheatsheet` | patch |
| 11 | C3-F07 — `Settings.OpenToCategory` and the collapsed tree | `options-ui-§2` | patch |
| 12 | C8-F03 — `Widgets.DragHandle` (inventory half) | `library-stack-§7`, `open-evolutions` | patch |
| 13 | C1-F07 — the casing of `<Event>` | `naming-cheatsheet` | minor |
| 14 | C1-F08 — the self-naming file header | `documentation-§9` (SHOULD) | minor (no retroactive debt) |

Two shapes in that list are worth naming, because a reader planning the rollout will otherwise budget work
for them. **One is satisfied by deleting something:** `testing-§9` is cleared by the six shadowing repos
**removing** their local `tests/test_prose.lua` and wiring `{ name = "test_prose", dir = "tests/_kit/" }` —
never by keeping both — and O2 is cleared in two repos by removing a `.pkgmeta` line. **One is satisfied by
doing nothing, because a re-vendor picks it up:** `automated-tests-§4`'s commit cells arrive when the
widened runner does and no row is ever hand-edited, and `layout-§1`'s gate arrives as a kit file plus one
suite-list entry. O1's carve-out runs the same way in the good direction: three addons become compliant
with nothing edited, and two ratified deviation rows are retired rather than joined by more.

## Deferred (1)

**Proposal 3 — C10-F02, the documentation-shape gate under five names.** Accepted in substance and not
applied here: it is a pure extraction of `AUDIT.md`'s six existing checks into `testkit/test_docs.lua`, so
it carries no rule the standard does not already state, and it lands behind the two kit changes it would
otherwise race — C10-F03's declaration fix must be in place first, or the extraction recreates the
shadowing trap in the five repos that already carry a local `test_docs.lua`/`test_docmap.lua`. It keeps its
rank for the next pass, with the two prohibitions the ripple plan records: no assertion of the soft
~60/~400-line hub guidelines, and no private list of retired filenames. The fix pass added a third input it
now has to honor: `documentation-§3` fixes `## Documented deviations` as the over-cap census's parent, which
is the stable anchor such a gate needs.

## Rejected (0), and one finding deliberately left out of the survivor set

Nothing was rejected. **C10-F07 — the no-blanket-suppression gate, hand-written ten times** — was upheld by
verification and is **not** in this bundle's survivor set. It is recorded here so the next run does not
treat the omission as a judgment: ten addons carry a 256–278-line `tests/test_lintconfig.lua`, no two
byte-identical, gating a `lint` rule the standard states and supplies no check for. It belongs at roughly
rank 10 beside the other kit extractions, and `open-evolutions.md:8`'s *Shared luacheckrc base* entry is
the **adjacent** half rather than a duplicate — sharing the config would make every repo's `read_globals`
the union of eleven addons' client surfaces, which `lint` forbids, while sharing the gate over the config
is purely additive.

---

## The ripple, item by item

### The touches that apply to every accepted proposal

| Touch | State | Note |
|---|---|---|
| `standards/STANDARDS.md:1` — version and date | **applied** | `v2.62.1` → **`v2.63.0`**, dated 2026-09-22. |
| `standards/STANDARDS.md:241` — the trailing authority date | **applied (fix pass)** | Read `Authoritative as of 2026-08-07; bump on amendment` through twenty-odd amendments. Now 2026-09-22. It is a **fifth** statement of the standard's currency and was on no ripple list. |
| `standards/STANDARDS.md` `## Changelog` — one entry at the top | **applied, then corrected** | One entry covering the sixteen in nine groups, plus a tenth group for O3's section half. The fix pass rewrote every figure in it that the sections no longer carry; see *Changelog corrections* below. Entries below it were not touched. |
| `standards/STANDARDS.md` Sections blurbs | **applied, then corrected twice** | Eight blurbs re-written by the fix pass against the fixed sections: `layout`, `line-endings`, `testing`, `automated-tests`, `documentation`, `audit-review-history`, `events-frames-taint` and `packaging`. The third pass re-read all eight against the final section text and moved **three** more: `layout` (the exempt row is graded against the opts-borne exempt set, not against the carve-out's conditions), `testing` (`loadSuites` raises on a listed-but-absent suite) and `audit-review-history` (`docs/perf-analysis/README.md` is the conditional one). A blurb describing a rule as an earlier pass wrote it is the contradiction this file exists to prevent. |
| `standards/EXECUTIVE_SUMMARY.md:11` — the current-version pointer | **applied** | It was wrong on both halves before this pass — `v2.62.1, 2026-09-20` against `STANDARDS.md:1`'s 2026-09-22. Now `v2.63.0, 2026-09-22`. |
| `standards/NEW_ADDON_CONTEXT.md:1` — the pack's own version | **applied** | Bumped in the same commit; the pack changed in eleven places. |
| **`README.md:146` — the repo Status line** | **applied (fix pass)** | Missed by the promotion pass, which tracked three version statements where `standards/README.md:66` names four. It read `v2.62.1`; now `v2.63.0`. Every addon's `revendor-standards` run reads this line, so Phase 4 would otherwise have carried the old version into eleven repos. |
| Anti-patterns range invariant | **applied — verified, nothing moved** | No accepted proposal added an entry, and the fix pass's edit to #48 changed its text and not its number. `anti-patterns.md`'s last entry is `88.` (88 entries total) and `STANDARDS.md:80` reads `#1–#88`. Checked against both files, not against a report. |
| `standards/ADDONS.md` | **not applicable** | The roster did not change: 11 addons, 1 library repo, 2 documentation-and-tooling repos. Confirmed against the file; no edit made. |

### Per proposal

**O1 — private event frames.** `events-frames-taint-§1` **applied** (two `####` subsections appended, so no
`events-frames-taint-§N` reference moved), and **corrected in the fix pass** to the call's one-or-two-unit
arity. `STANDARDS.md:66` blurb **applied**, then re-written to match. `slash-commands-§7` **applied in the
fix pass** — `slash-commands.md:186`'s "including the per-unit frames — gone, not gated" now says what
goes is the **registration**, not the frame object, since O1's condition (c) requires the frame to survive a
disable/enable cycle. `testing-§1` consistency read **done, no edit**. `anti-patterns.md` **not applicable**
— no existing entry forbids the carved-out shape, checked by grep for `CreateFrame`, `RegisterUnitEvent`,
"private frame" and "per-module frame". `AUDIT.md` **applied** — `events-frames-taint-§1` is added to the
list of sections whose applicability condition is checked **before** grading, with the three conditions and
the factory case spelled out, because without it the audit files the carve-out's compliant cases as
deviations, which is the outcome the ruling was made to stop.

**O2 — the ignore template.** `packaging` **applied**, with the strong form's second branch narrowed in the
fix pass and the evidence re-measured (seven, splitting **four / one / two**, below). `STANDARDS.md:70` blurb **applied** and
extended. `AUDIT.md:208-212` **applied** — `.claude` and `.superpowers` now sit behind `[ -d ]` gates beside
`tools`, and the comment says all three are conditional. Check (b), the present-dot-entry sweep, is
unchanged and is still what catches a directory that appears later. `NEW_ADDON_CONTEXT.md` **applied** — the
`.pkgmeta` starter carries the commented form, the prose above it says an entry binds only when the entry
exists, and the `.gitattributes` pointer sentence no longer implies both directories are unconditional.

**O3 — the `.gitattributes` body gate.** `line-endings-§7` **applied in the fix pass**: §7's opening now
mandates mechanical checking of every property and forbids eye-checking; the bullet consigning (a)–(d) to
the audit every cycle is replaced by one that holds through kit revision 24 and yields to the gate at
revision 25; and a new block at the end of §7 states the evidence, the gate and its commencement.
`STANDARDS.md:71` blurb **applied in the fix pass** — it was deliberately left alone while the section did
not carry the rule, and could be written once it did. Four census figures in the same file were false and
were corrected with it (below). `AUDIT.md` **not applicable this release** — the existing one-liner stays
correct under the ruling and is what still covers WowAddonStandards and wow-addon, which track no `.lua`
and run no suite; §7 now says so explicitly.

**1 — the LibKa0s inventory.** `library-stack-§7` and `open-evolutions` **applied**. `STANDARDS.md:57`
blurb **applied** (eighteen files, and it now names the `tests/majors.lua` manifest as what to recount
against). `EXECUTIVE_SUMMARY.md:56` **applied** (seventeen → eighteen). `NEW_ADDON_CONTEXT.md` **applied**
in three places, and the fix pass replaced its `LIB_FILES` list with all **eighteen** files in `LibKa0s.xml`
order — the promotion pass had left ten. `anti-patterns.md:54` (#48) and `options-ui.md:13`
**applied in the fix pass**: #48 now reads *eleven of LibKa0s's twelve majors* with the full six-file attach
set, and `options-ui-§1` **keeps no file list at all**, pointing at `library-stack-§7` instead, because that
count had drifted three times as a second copy of the same table.

**2 — the shadowed kit suite.** `testing-§9` **applied**, and **completed in the fix pass**: the
unreferenced-kit-file MUST now carries the one carve-out — a decline recorded as a `## Documented
deviations` row reports once as a decline rather than as a hole — without which `localization-§5`'s
permission to wire your own gate *or* the kit's, never both, could not be exercised without failing this
MUST. `localization-§5` **applied in the fix pass** with the matching half: declining the kit's copy is a
recordable deviation and the row is a **MUST**. Both reporting MUSTs commence at test-kit revision 25.
`STANDARDS.md:73` blurb **applied**, then corrected. `NEW_ADDON_CONTEXT.md` **applied**. `NEW_ADDON.md`
**applied** (step 5), with the pair-keying commencement added in the fix pass. The kit half is LibKa0s's and
is listed under *Rollout debt*.

**4 — `docs/revendor/` named in the standard.** `documentation-§3` and `-§6` and
`audit-review-history` **applied**. `STANDARDS.md:76` and `:77` blurbs **applied**, then corrected. The fix
pass rewrote §3's evidence paragraph, which had filed one repo's stricter reading as a broken MUST when it
is neither (below). `NEW_ADDON_CONTEXT.md` **applied** in four places. `NEW_ADDON.md` **applied** (step 6b),
with its five-name store enumeration replaced in the fix pass by a pointer at `documentation-§3`, which is
the one place that list lives. `AUDIT.md` **applied** — the `## Documentation map` check now excludes all
seven frozen directories before counting.

**5 — the cap census and gate.** `layout-§1` **applied**, and substantially repaired in the fix pass: the
census and the gate are both bound to *a repo that tracks an authored `.lua` file*; the gate's commencement
is named; its scope now drops **both** carve-outs, with the generated-data exemption arriving through the
gate's opts table; and the band conflict with `automated-tests-§4` is settled in one direction in both
files. `automated-tests-§4` **applied** (the SHA cells) and **extended in the fix pass** with the matching
half of that settlement. `STANDARDS.md:55` and `:75` blurbs **applied**, then corrected.
`NEW_ADDON_CONTEXT.md` **applied** in three places, with hard rule 15's unsatisfiable MUST bound to
revision 25 in the fix pass. `NEW_ADDON.md` **applied** (step 6b). `AUDIT.md` **applied**, and its over-cap
pipeline corrected in the fix pass to subtract the repo's **declared** generated-data exemptions.
`documentation-§3` **applied in the fix pass** — the census is not an eleventh mandated section; it is a
sub-heading of `## Documented deviations`, stated there because `layout-§1` fixes the heading's name and
level but not its parent.

**6 — the unknown event name.** `events-frames-taint-§1` **applied**. `STANDARDS.md:66` blurb **applied**
(same bullet as O1). `NEW_ADDON_CONTEXT.md` **not applicable** — the `OnEnable` example shows a single
commented `self:RegisterEvent(...)` and not a loop, so nothing there teaches the bare-loop shape; the note
for the pack's next author is that if that example ever becomes a name list it must be the isolated form.
`AUDIT.md` **applied** — a new check reads the registration shape and grades the `pcall` and the record as
the two MUSTs, with `C_EventUtils.IsEventValid` **alone** graded as the MUST failure it is.

**7 — the lapsed re-vendor bundles.** `audit-review-history` **applied**, with its central cross-reference
repaired in the fix pass: `versioning-git` **MUST**s the re-vendor commit and only **SHOULD**s that it stand
alone, so the trigger is the commit that touches `libs/LibKa0s/` and never the commit subject, and the tag
is read from the payload on both sides. The section's two count claims were re-measured and both were wrong
(below). `AUDIT.md` **applied**, and its check rewritten in the fix pass to resolve each commit's tag out of
`git show <sha>:CLAUDE.md` and each bundle's tag out of the folder name or `01_DELTA.md`'s first line — a
folder-name comparison would have filed **28** existing bundles across all ten stores as unrecorded.
`NEW_ADDON_CONTEXT.md` **applied**. `wow-addon/commands/revendor-libka0s.md` **not applicable to this repo,
and recorded so it is not re-opened**: `:171` and `:307` already mandate and freeze the bundle, so the
missing piece was never command text — it was a rule written to be read by a check.

**8 — the commit-pinned results row.** `automated-tests-§4` **applied**, with its commencement added in the
fix pass. The **manifest** half binds today: `run-automated-tests.sh:468` already emits the `git` object at
kit revision 24. The two **row** cells do not exist at revision 24 and arrive with revision 25, which is
what the rule now says. `STANDARDS.md:75` blurb **applied**, then corrected. `EXECUTIVE_SUMMARY.md:28`
**applied**. `NEW_ADDON_CONTEXT.md` **applied**; its "commit-pinned row" claim was left alone deliberately,
since the manifest half already ships. `AUTOMATED_TESTS.md` **not applicable** — its `ANALYSIS.md` template
at `:61` already carries `**Commit:** <sha> (<branch>)<, dirty>`. `AUDIT.md` **applied**.

**9 and 13 — bus constants and `<Event>` casing.** `architecture-§4` and `naming-cheatsheet` **applied**.
The sender-comment bullet lands as a **MAY** and not a SHOULD, which is what `04_PROPOSALS.md:509` and
`05_RIPPLE_PLAN.md:315` both direct: the MUST that the sender be documented in `docs/ARCHITECTURE.md` is
unchanged, and a comment at the declaration is a permitted second place to discharge it rather than a second
obligation. `STANDARDS.md:58` blurb **applied**; `:79` **not applicable** — "the naming conventions table"
still covers the cheatsheet whatever rows it holds. `NEW_ADDON_CONTEXT.md` **applied**. `NEW_ADDON.md`
**applied** (step 4). `AUDIT.md` **applied**.

**10 — the conformance suite names.** `testing-§1`/`-§8`/`-§11` and `naming-cheatsheet` **applied**.
`STANDARDS.md:73` blurb **applied**. `NEW_ADDON_CONTEXT.md` **applied**. `NEW_ADDON.md` **applied** (step 5).
Zero rollout debt: all eleven addons already ship both files under exactly these names.

**11 — `Settings.OpenToCategory`.** `options-ui-§2` **applied** (inside §2, so every `options-ui-§N`
reference is unmoved). `STANDARDS.md:60` blurb **applied**. `NEW_ADDON_CONTEXT.md` **applied**. `AUDIT.md`
**applied**. `EXECUTIVE_SUMMARY.md` **not applicable** — its combat-lockdown bullet is about lockdown
discipline and nothing in it goes stale.

**12 — `Widgets.DragHandle`.** `library-stack-§7` **applied**; `open-evolutions` **applied** (the deferred
rule question, with its evidence). `options-ui` **not applicable** — no rule was written, which is the
deferral.

**14 — the self-naming file header.** `documentation-§9` **applied** (new numbered section; nothing
renumbered, since it is appended). `STANDARDS.md:76` blurb **applied**. `NEW_ADDON_CONTEXT.md` **applied and
load-bearing** — all ten starter file templates now carry the header on the line beneath the namespace
bootstrap, plus hard rule 1. `NEW_ADDON.md` **applied** (step 4). `naming-cheatsheet` **deliberately not
touched** — §9 is the one home, and two homes is how this convention got eleven answers.

---

## The fix pass (pass two) — thirteen blockers and twenty-four majors

Before the release was committed, a four-lens adversarial audit read the promotion pass's output against
the live trees. It found **13 blocker reports over seven distinct blockers, and 24 majors**. Almost every one of them was a count or a citation
written from prose rather than measured — the same failure mode the release itself is about, committed by
the pass that was correcting it. Six agents cleared them on 2026-09-22/23, each owning a disjoint set of
files. Nothing was committed, branched or pushed.

**The governing principle the blockers shared.** A **MUST no repo can satisfy by any act of its own** is a
defect and not a strict rule. Several blockers were exactly that: a rule mandating a kit file that ships in
no kit, or a universal quantifier written without checking the rules it now quantifies over. Each was fixed
by **binding the rule to something that exists or will exist on a named date** — never by softening it to a
suggestion. The date the collection runs on is **LibKa0s test-kit revision 25 (LibKa0s v1.55.0)**; today's
kit is revision 24 (`LibKa0s/testkit/framework.lua:20`) and the library is at v1.54.2.

### What was cleared, by owner

| Owner | Files | What was wrong, and what it now says |
|---|---|---|
| A | `layout.md`, `automated-tests.md` | **Gate scope** — the cap gate was scoped to the tracked set minus `libs/` and `tests/_kit/`, which drops one carve-out of two; it would have reported one repo's 27 generated `GlobalStrings/*.lua` (one of them 23,842 lines) as unremarked authored breaches. The exempt set now arrives through the gate's **opts table**, because the carve-out's three conditions are facts about the repository, not properties a path betrays. **Unsatisfiable MUST** — the gate ships in no kit; bound to revision 25. **Repo-kind carve-out** — both MUSTs now bind only a repo that tracks an authored `.lua`. **The band conflict** — `layout-§1` and `automated-tests-§4` each claimed the 1000–1500 band; settled in one direction in both files, watch list generating both bands, census dispositioning the over-cap band. **Commit-SHA commencement** — revision 25, with pre-rule rows staying *unknown* and never reconstructed from git archaeology. |
| B | `testing.md`, `localization.md` | **`testing-§1`'s scope MUST** — written as *the whole `git ls-files` set*, a quantifier six of the gates this file itself mandates could not satisfy; now *the whole of its own denominator, enumerated from the tree*, with the three denominator kinds named. **The `testing-§9` / `localization-§5` contradiction** — §9 made an unreferenced kit file an unconditional failure while §5 permits a repo to wire its own gate instead; the ruling shipped is the **recorded decline**, a register row keyed to the rule, reported once as a decline. Both reporting MUSTs commence at revision 25. Also repaired a **rule-7 violation** in its own file: `testing-§9` named two addons as *existing reference implementations*; the shape is now described and the two citations kept as evidence. |
| C | `audit-review-history.md`, `AUDIT.md` | **A misquoted cross-reference** — the MUST claimed `versioning-git` "requires [the re-vendor commit] to stand alone"; it MUSTs the commit and SHOULDs the shape, so the trigger is the payload commit and never the subject. **Both halves of the `AUDIT.md` check rewritten** to read each commit's tag out of `git show <sha>:CLAUDE.md` and each bundle's out of the folder name or `01_DELTA.md`; the old folder-name comparison would have filed 28 existing bundles across ten stores as unrecorded — a High finding against ten repos for records that exist. **Two counts corrected** (below). **The over-cap pipeline** now subtracts the repo's declared exemptions. |
| D | `options-ui.md`, `anti-patterns.md`, `architecture.md`, `naming-cheatsheet.md` | **`options-ui-§1`'s stale three-file count** — deleted rather than corrected a fourth time; the section now keeps no file list and points at `library-stack-§7`. **#48's two stale figures** — *four of five majors* → **eleven of twelve**, with the full six-file attach set. **`architecture-§4`'s sender comment** demoted from SHOULD to **MAY**, as both proposal documents direct. **The cheatsheet's Bus-messages row** — *two addons let the casing leak* → **one**; the other SCREAMING_SNAKE publisher keeps no constant table, so it has nothing to leak and owes the declare-once MUST instead. |
| E | `NEW_ADDON_CONTEXT.md`, `EXECUTIVE_SUMMARY.md`, `lint.md`, `README.md`, `NEW_ADDON.md` | **`LIB_FILES` listed ten of eighteen files**, with no note that an unmet floor makes a module `return` before `LibStub:NewLibrary` and vanish silently. **`README.md`'s Status line still read v2.62.1** — the fourth version statement, on no ripple list. **Hard rule 20 said nine mandated sections** where the same file's own checklist says ten. **`EXECUTIVE_SUMMARY.md` named four frozen stores** where `documentation-§3` names seven, and had been wrong about two of them for releases. **`lint.md:11`'s `exclude_files`** did not match the derived copy in the context pack. **Hard rule 15 mandated a kit file that ships in no kit** — bound to revision 25. |
| F | `line-endings.md`, `packaging.md`, `documentation.md`, `events-frames-taint.md`, `slash-commands.md` | **O3's section half**, the release's one open touch, now landed. **Four false census figures** in `line-endings.md` and a client-bound enumeration listing eight addons where there are eleven. **`§5`'s body-intact command said 81/82 lines** where the bodies are **84/85**, which would have truncated three lines off every diff it produced — the command the new gate's property (d) formalizes. **`packaging`'s five-of-eleven figure** re-measured to seven / five / two — itself corrected by the third pass to seven, splitting **four / one / two**. **`documentation-§3`'s upstream-list evidence** restated: one repo's amendment is a coherent, stricter reading and not a broken MUST. **The census's parent** named as `## Documented deviations`. **`events-frames-taint-§1`'s carve-out** rewritten against the API's arity. **`slash-commands.md:186`** now says the registration goes, not the frame. |

The audit's blocker/major split is recorded as thirteen and twenty-four. The fix reports label nine blockers
explicitly by number, and one agent found and cleared a tenth in its own file that was on no list
(`NEW_ADDON_CONTEXT.md`'s hard rule 15). The remainder arrive in the reports as numbered defects without the
label. That is a gap in this record, not in the work: every defect the audit raised is accounted for above
or under *Defects still open*.

### Changelog corrections, and the number verified for each

Every figure in the v2.63.0 entry was re-checked against the fixed sections and the trees. Those that moved:

| Claim as written | Corrected to | Measured against |
|---|---|---|
| gate scope is "`git ls-files` minus the rule's own carve-outs" | the whole of its own rule's denominator, enumerated from the tree; three denominator kinds named | `testing.md:39-41`; six §-mandated gates have a non-`git ls-files` denominator |
| unreferenced kit file and collision "both failures rather than skips" | failures rather than *silent passes*, with the recorded-decline carve-out and revision-25 commencement | `testing.md:246-278`, `localization.md:302-314` |
| the five local cap gates read "three documents under three heading names" | **two** documents, **two** heading names — and both of those differences are sanctioned; the drift is one heading name and one band | 4 gates read `docs/ARCHITECTURE.md`, LibKa0s reads root `CLAUDE.md`; headings are `Files over the 1500-line cap` (×4, at two levels) and ``Files by the `layout-§1` band`` (×1) |
| "seven addons carrying none" | **kept — it is correct** | 11 addons carry a `.toc`; 4 carry the gate (ConsumableMaster, MultiMeters, PanelMaster, PrettyChat). LibKa0s carries a fifth copy and is not an addon |
| "Every repo now carries a `Files over the 1500-line cap` heading" | every repo **that tracks an authored `.lua` file**, nested under `## Documented deviations` | `layout.md:69`, `documentation.md:128` |
| "every repo wires the kit's `test_layout_cap.lua`, which reads the whole tracked set minus `libs/` and `tests/_kit/`" | minus **both** carve-outs, the exempt set through the opts table, from revision 25 | `layout.md:73-83`; `ls LibKa0s/testkit/` — the file is absent at revision 24 |
| one repo "gave the store a table row **and** named it in scope, breaking the exactly-one-table MUST" | ten edits produced **five** answers; nine prose sentences carry **four** directory lists; the tenth is a coherent stricter reading that breaks nothing | `MultiMeters/docs/ARCHITECTURE.md:415` (the amendment) and `:477` (one row). Lists: 5× {audits, reviews, automated-tests, revendor, superpowers}; 2× +perf-analysis; 1× +perf-analysis+investigations; 1× +perf-analysis+a private store with `<run>`/`<date>` spellings |
| "the patches diverged four ways" | five answers, four prose lists | as above |
| "15 to 20 unrecorded re-vendor commits per repo" | **fifteen to twenty-four** re-vendor commits past each store's newest bundle, carrying **fifteen to nineteen** distinct tags, and **nineteen to thirty-one** unrecorded tags apiece from each store's first bundle | per-repo `git log -- libs/LibKa0s` with each commit's tag read from `CLAUDE.md`; unrecorded AuraMaster **19**, AbsorbTracker **25**, MultiMeters **31** |
| "`versioning-git` already requires the re-vendor commit to stand alone" | MUSTs the commit, SHOULDs the shape; the trigger is the commit touching `libs/LibKa0s/` | `versioning-git.md:9` |
| the SHA cells bind on release day | manifest half binds today (revision 24); the two **row** cells commence at revision 25 | `run-automated-tests.sh:156-157`, `:468` emit the `git` object; no row cells |
| the carve-out permits a frame "for a named unit" | for the **one or two** units `RegisterUnitEvent` accepts | `events-frames-taint.md:17-19` |
| "Five addons list only what they have…; six list both" | **seven** of eleven have one directory or neither; **five** argue it in a committed comment; **two** carry an `ignore:` line for a directory they do not have — *superseded by the third pass: **four** argue, **one** is silent, **two** carry the ghost line* | on-disk `.claude`/`.superpowers` in all eleven addons against each `.pkgmeta` |
| "only MultiMeters let the key's casing leak" | **kept — one**, and it agrees with the corrected cheatsheet row | `MultiMeters/core/Constants.lua:515-561`; the other SCREAMING_SNAKE publisher has no `MSG` table |
| the sender comment described as a SHOULD | a **MAY**, and the entry now says why | `architecture.md:98` |
| "O3's reversal … has no section edit yet … the release's one open touch" | **deleted.** It landed; a new group (10) describes it, with the twelve-of-fourteen and thirteen-of-fourteen figures and the 84/85-line correction | `line-endings.md:438-444`, `:469-477`, `:523-567`; 12 of 14 repos lack `*.py text eol=lf`; §5's fenced bodies are 84 and 85 lines |
| the kit gates "need a LibKa0s change first" | kept, and extended to name revision 25 and the five rules that cite it, plus what a consumer owes today regardless | `Kit.VERSION = 24`; `git describe --tags` = v1.54.2 |

### Blurb corrections

`layout` (census now conditional, hosted under `## Documented deviations`, both bands in the watch list,
gate from revision 25 with the opts-borne exempt set); `testing` (own-denominator wording, the recorded
decline, the commencement); `line-endings` (the body case, from revision 25); `automated-tests` (the row
cells' commencement, and `Disposition` pointing at the census for an over-cap entry);
`audit-review-history` (the payload-commit trigger, and versioning-git's SHOULD);
`documentation` (the census as a sub-heading rather than an eleventh mandated section);
`events-frames-taint` (one or two units); `packaging` (the narrowed second branch). `anti-patterns`'s
`#1–#88` range was checked and **needed no edit**.

### Defects the fix pass reported and did not fix — and where each stands now

The fix pass (pass two) listed seven defects it had found and left. **Five are closed**; the two that are
open are open on purpose. Each is kept below with its outcome, because a defect deleted from the record is
a defect the next pass re-derives.

1. **`layout.md:85` said "Eight addons wrote none at all". It is seven. — CLOSED.** The section now reads
   **Seven** (`layout.md:85`). Re-measured this pass: **eleven** Ka0s addons carry a `## X-Standard` TOC
   field (the twelfth `*.toc` repo is Outfitter, whose `## Title:` is not Ka0s-prefixed); **four** of them
   carry `tests/test_layout_cap.lua` — ConsumableMaster, MultiMeters, PanelMaster, PrettyChat — and the
   fifth copy is LibKa0s's, which is a library repo and not an addon. 11 − 4 = **7**. The section and the
   changelog now agree, both at seven.
2. **`line-endings.md:20` carried the doubled-`l` British spelling of *traveled* — CLOSED.** The word was
   introduced by the fix pass in the release that promotes the mechanical prose gate; `:20` now carries the
   US form. The lesson is recorded rather than the word: the pass that writes a spelling rule is the pass
   most likely to break it, so the gate's own word list is the thing to run, not an eye.
3. **`layout-§1` did not state the census's parent — CLOSED.** `layout.md:69` now fixes it: the census sits
   **under `## Documented deviations`** in whichever of the two hosts holds it, its **level** follows that
   register's own nesting, and the paragraph cites `documentation-§3` as stating the same parent for the
   `docs/ARCHITECTURE.md` host. Both files now carry the parent, which is deliberate: `layout-§1` is where
   both hosts are named, and a parent fixed for one host and left open for the other is a heading a
   doc-shape gate still cannot find twice.
4. **`testing-§9`'s `loadSuites` MUST described kit behavior that does not exist — CLOSED, by ruling.** The
   ruling went to **describe the kit, not change the kit**. `testing.md:280-293` now states what revision 24
   already ships: `loadSuites` **MUST raise** on a listed-but-absent suite, naming the path and the
   declaration's position; the write-in-progress case is the explicit `{ name = …, pending = "why" }` entry,
   which registers as a skip carrying that reason; and a `pending` entry whose file **does** exist MUST
   raise too. The rule carries **no commencement**, because it describes the tree. **This adds no Phase 3
   deliverable** — see *Phase 3* under *Rollout debt*.
5. **Two rule-7 candidates in `options-ui.md` — STILL OPEN, deliberately.** `options-ui.md:53` cites an
   addon's `docs/ARCHITECTURE.md:241` and `:390` cites another's `settings/Schema.lua:1553-1566`, both
   inside rule prose. Both read as evidence citations rather than as naming a reference implementation,
   which rule 7 forbids; the adversarial audit flagged neither. Recorded so the judgment is made once by
   the owner rather than re-derived every pass. Both citations are still in the file at those lines.
6. **`documentation.md`'s "the fourth table" ordinal reads two ways — STILL OPEN.** `documentation.md:356`'s
   heading `###### \`### Verification and record\` — the fourth table (MUST)` means *the fourth table
   added*; it is the **third** in the map's own order. That heading is what propagated the "the fourth holds
   `testing.md`" error into two derived files, both since corrected to name the table instead of counting
   it. It should say *the fourth table added*, or the error propagates a third time. No pass has owned
   `documentation.md` since it was reported.
7. **`documentation.md`'s count of repos nesting the census under the register — CLOSED.**
   `documentation.md:129` now reads "**two** nest it exactly there; a third keeps it under `## Layout`, and
   the library repo keeps it as a sibling `##`", which is what the tree shows: MultiMeters
   (`docs/ARCHITECTURE.md:573` under `:481`) and PrettyChat (`:306` under `:249`) nest it; ConsumableMaster
   (`:28`) keeps it under `## Layout`; LibKa0s (`CLAUDE.md:80`) keeps it as a sibling of the register at
   `:64`. The earlier "three" counted the sibling as nested.

---

## The third pass — the counts pass two wrote from prose, and the last rulings

Pass two killed every blocker and then wrote six numbers the trees do not support. That is the release's
own subject committed a second time, so the third pass measured each one at the source before writing it.
**Six counts corrected in the sections** (by the orchestrator, each verified against
`/mnt/d/Profile/Users/Tushar/Documents/GIT/` and re-verified by this pass):

| File | Was | Is | Measured against |
|---|---|---|---|
| `layout.md:85` | "Eight addons wrote none at all" | **Seven** | 11 Ka0s addons carry `## X-Standard`; 4 carry `tests/test_layout_cap.lua`; the 5th copy is the library's |
| `documentation.md:129` | "three nest it exactly there" | **two**, and the sentence no longer rests on a majority that does not exist | MultiMeters `:573`, PrettyChat `:306` nested; ConsumableMaster `:28` under `## Layout`; LibKa0s `CLAUDE.md:80` a sibling `##` |
| `packaging.md:39` | "**Five** of them argue", "two states" | **four** argue, **three** states — one repo is simply silent, which the strong form permits | `.claude`/`.superpowers` on disk in all eleven addons against each `.pkgmeta`: argue = BankLedger, LootHistory, PanelMaster, PrettyChat; silent = WhatGroup; ghost line = AuraMaster, PartyFrameEnhanced |
| `library-stack.md:113` | "exactly two second edges" | **three** | `LibKa0s-Options-1.0` floors on `LibKa0s-Pool-1.0` at `OptionsWidgets.lua:33` and `OptionsTabs.lua:38`, borne by the attach files rather than by the major's shell |
| `AUDIT.md:125` | "sixty-eight unregistered `.md` files" | **twenty-five to thirty-six** | 68 is the collection-wide **bundle** count, not a per-repo file count; `find <repo>/docs/revendor -name '*.md'` runs 25 (AuraMaster) to 36 (AbsorbTracker) |
| `line-endings.md:20` | the doubled-`l` British spelling of *traveled* | `traveled` | `localization-§5`'s published word list, in the release that promotes the gate |

**Three agents then closed the last judgment-level defects**, none of which was a count:

- **`layout-§1`'s self-contradiction** (`layout.md:81`, and its upstream instance at `:69`). The gate was
  told to grade an `exempt` row "against that carve-out's three conditions" — the very facts `:75` says a
  gate cannot infer. It now grades the row against the **opts-borne exempt set**, in two directions, and the
  boundary is written down: whether an exemption is *legitimate* is the **auditor's** judgment, made against
  the three conditions, and the gate neither makes it nor pretends to. The same paragraph gained the census
  **parent** (defect 3 above).
- **`testing-§9`'s kit-side rule** — ruled *describe the kit*, not *change the kit* (defect 4 above), with the
  historical failure-mode bullet at `testing.md:298-302` and the closing paragraph at `:313` moved to the
  past tense, so neither contradicts the corrected rule above it.
- **`AUDIT.md`'s eleventh copy of the store list** (`:117-126`) deleted in favor of a pointer at
  `documentation-§3`, which is what makes `EXECUTIVE_SUMMARY.md:36`'s "enumerated in `documentation-§3` and
  nowhere else" true: one live hit for `docs/superpowers` outside the frozen bundle,
  `documentation.md:333`. **`AUDIT.md`'s packaging check gained its third branch** (`:251-260`) — a
  CONDITIONAL `ignore:` entry for a directory that is absent, which branch (a) drops on its own `[ -d ]`
  gate and branch (b) cannot reach because (b) walks what is on disk. Executed against all eleven addons:
  it fires in **two** and prints **three** lines (AuraMaster `.claude`; PartyFrameEnhanced `.claude` and
  `.superpowers`). `packaging.md:22` and `:39` gained `docs/revendor/`.
- **`audit-review-history.md:13`** stopped flattening `documentation-§3`'s conditional: `docs/perf-analysis/`
  carries a `README.md` **wherever that store exists**, the obligation being on the store and not on every
  repo. Measured: six repos have the store and all six carry the README — zero have it without.
- **`events-frames-taint.md:18`** replaced its false evidence: the permission is written against the
  **call's** arity, and **no repo in the collection registers a two-unit `RegisterUnitEvent` today**.
- **`library-stack.md:242`**'s `layout` applicability row gained the census, its parent ("the host changes;
  the parent does not") and the revision-25 gate.

**What this pass then did to the index and to this file.** The v2.63.0 changelog entry was arguing from
numbers its own sections no longer carried, which is the defect the whole release is about. Corrected in
`STANDARDS.md:99`: the `.pkgmeta` split (**seven**, and now **three** states — four argue, one is silent,
two carry a ghost line — not the two states and five arguers pass two wrote); the census **parent**, where
the entry still said the heading's level "follows its host" although the census MUST now fixes the parent as
`## Documented deviations` in **either** host and the level as that register's own nesting; the
`events-frames-taint-§1` arity evidence, where the entry claimed the `player`/`pet` pair is "the shape the
collection actually ships" and nothing ships it; `testing-§9`'s kit-side raise, added with its **no
commencement** stated, so the contrast with the two reporting MUSTs that do commence at revision 25 reads as
deliberate; and `AUDIT.md`'s third packaging branch and `documentation-§3` as the store list's sole home,
both recorded. Three Sections blurbs moved with them (*Blurb corrections* above). The **anti-patterns range
was re-checked from the files**: `anti-patterns.md`'s last entry is **88**, `STANDARDS.md:80` reads
**#1–#88**, and the fix pass's edit to #48 changed that entry's text and not its number — no edit needed.
The standard's **version and date are stated in four places plus one date-only line**, all now reading
v2.63.0 / 2026-09-22: `standards/STANDARDS.md:1`, `standards/EXECUTIVE_SUMMARY.md:11`,
`standards/NEW_ADDON_CONTEXT.md:1`, `README.md:146` (version only, no date), and `standards/STANDARDS.md:241`
(the trailing authority date). A repo-wide search found no fifth version statement.

**Defects this pass found and did not fix**, both in files it does not own:

1. **`layout.md:85` claims a difference the census MUST no longer sanctions.** It reads "Two of their
   differences are legitimate and the census MUST above already sanctions both: … and the heading's level
   follows its host." Under the parent fixed at `:69`, the level follows the **register's** nesting and is
   `###` in **both** hosts, so the library repo's sibling `##` is now a one-level move it owes rather than a
   sanctioned difference. The host difference is still sanctioned; the level difference is not. The
   changelog entry was corrected to say so and the section was not, so the two now disagree by one clause.
   Whoever owns `layout.md` should restore the agreement.
2. **`events-frames-taint.md:18` carries a call-site count that is wrong.** The governing claim is correct
   — no repo registers a two-unit filter — but the supporting clause says "the two live call sites each
   name a single unit", and there are **ten** authored call sites in **four** repos:
   `AbsorbTracker/core/AbsorbTracker.lua:164` and `:165`, `KickCD/core/Util.lua:439`,
   `LootHistory/modules/Attribution.lua:369`, `PartyFrameEnhanced/modules/CastBars.lua:336`,
   `.../PetFrames.lua:103`, `:104`, `:106`, `:107` and `.../TargetFrames.lua:214`. Every one passes a single
   unit token, so the claim the sentence exists to support survives; the number does not. Measured with
   `grep -rn RegisterUnitEvent --include='*.lua'` over all twelve repos, excluding `tests/` and the
   vendored `libs/`.

---

## Rollout debt

Consolidated from the section agents' reports, re-measured by the fix pass, and re-read against the final
section text by the third pass. **Every row whose *Blocked on v1.55.0?* cell reads **yes** cannot be
discharged until LibKa0s v1.55.0 (test-kit revision 25) is tagged and pushed** — the
library leads, and a consumer that cites an untagged kit is citing nothing. That ordering constraint is what
the next phases run on.

| Proposal | Blocked on v1.55.0? | Repos made non-compliant | What each needs |
|---|---|---|---|
| O1 carve-out | no | — | **Nothing is made non-compliant; two rows are retired.** AbsorbTracker retires its `docs/ARCHITECTURE.md:601` row once (b) and (c) are confirmed; PartyFrameEnhanced retires `:332`, which was never a violation. LootHistory is compliant by construction and owes **no** row. **KickCD** owes the one real fix: `core/Util.lua:437-444` is a general-purpose private-frame factory, live from `modules/IconGrid.lua:821` and `modules/Castbar.lua:1030` — narrow it, or file a row with a re-check trigger. AuraMaster **may** now take the unit filter instead of the raid-wide `UNIT_AURA` firehose; not an obligation, and its `modules/TimedSpells.lua` comment block should stop citing §1 as forbidding what §1 now permits. |
| O2 template | no | **PartyFrameEnhanced**, **AuraMaster** | Two lines and one line removed respectively — `.pkgmeta` entries for directories the repo does not have. No repo owes an addition. Under the narrowed second branch, a repo that **has** a directory and leaves its line commented out fails the MUST; none does today. |
| O3 gate | **yes** | **Thirteen of fourteen repos** on property (d), **twelve of fourteen** on (c) | The current `line-endings-§5` block **whole**, not just the `*.py` line — the omission is drift of the entire eight-line comment. Every one of the thirteen diverges on the same six lines, so this is one propagated body per repo and not thirteen judgments. **PanelMaster's six extra lines are a conforming §5 appendix and MUST NOT be flagged**; its four `#!/usr/bin/env python3` files under `tools/` are CRLF on disk today and that is what the `*.py` line fixes. WowAddonStandards and wow-addon run no suite, so `AUDIT.md`'s one-liner stays theirs. |
| 1 inventory | no | — | **None.** `OptionsTabs.lua` and `WidgetsDragHandle.lua` are already in all eleven consumers' `libs/LibKa0s/`; the whole-folder rule put them there. The debt was entirely inside the standard. |
| 2 shadowed suites | **yes** | **BankLedger, ConsumableMaster, LootHistory, PrettyChat, WhatGroup, LibKa0s** | Delete the local `tests/test_prose.lua` (262, 262, 283, 267, 292 and 443 lines) and wire `{ name = "test_prose", dir = "tests/_kit/" }` — **or** keep it and file the `localization-§5` decline as a `## Documented deviations` row with a re-check trigger, which is the carve-out the fix pass added. Not one of the six carries such a row today. Add `tests/prose_waivers.lua` where a `WAIVED` table was hardcoded (**WhatGroup** `:123`, **LootHistory** `:121`). Each also owes a `docs/test-cases.md` regeneration and a README badge refresh, since the case names move (`testing-§5`). **AbsorbTracker, AuraMaster, KickCD, MultiMeters, PanelMaster, PartyFrameEnhanced** already declare the kit path and need only the re-vendor. |
| 4 revendor store | no | **PartyFrameEnhanced** | PartyFrameEnhanced has no store, no `docs/reviews/` and no frozen-directory scope sentence at all — the sentence is written and the store created at its next re-vendor. **MultiMeters is *not* debt**: its amendment declares that a store gets one row and its bundles none, and it gives `docs/revendor/` exactly one Tier 3 row (`:477`); the earlier reading of this as a double listing was wrong. The other nine: their hand-written scope sentence becomes a quote of the rule, no content change. AbsorbTracker keeps `docs/investigations/`; AuraMaster's `docs/spell-research/` is Tier 3 and stays local. |
| 5 census | no (the heading) | **AbsorbTracker, AuraMaster, BankLedger, KickCD, LootHistory, PartyFrameEnhanced, WhatGroup** | Six of the seven have nothing over the cap and owe only the heading, under `## Documented deviations`, with "Nothing is over the cap today". **AuraMaster is the exception and owes real rows** — `settings/GeneralSpells.lua`, `tests/test_database.lua`, `tests/test_filtercompiler.lua`, `tests/test_pages_general.lua` are over 1500 and sit in no terminal state; each needs an issue naming the seam, a ratified row, or a peel. **ConsumableMaster** owes a **move**: its heading sits under `## Layout` (`docs/ARCHITECTURE.md:28`), not under the register. **PanelMaster** renames ``### Files by the `layout-§1` band`` to `Files over the 1500-line cap` and drops the band half into the release watch list. **PrettyChat** changes its `GlobalStrings.lua` row from the non-terminal disposition *Exempt* to the exempt form the section now defines. **LibKa0s** owes a one-level move of its own: `CLAUDE.md:80`'s `## Files over the 1500-line cap` becomes `### …` beneath `## Documented deviations` at `:64`. Neither ConsumableMaster's move nor LibKa0s's will be caught by the revision-25 cap gate, which looks for the heading and not for its parent — a doc-shape gate would, which is why the parent was fixed. |
| 5 gate | **yes** | All eleven addons plus LibKa0s | The kit's `test_layout_cap.lua` arrives at revision 25 and is wired by one suite-list entry. **ConsumableMaster, MultiMeters, PanelMaster, PrettyChat, LibKa0s** delete their local copy in the same commit. The kit's gate must take its exempt set **via opts**, fail rather than skip when it cannot look, and grade an *exempt* row against the **exempt set it is handed through opts** — not against the carve-out's three conditions, which it cannot read, and not against the three terminal states, which are for breaches (`layout.md:81`). |
| 6 event guard | no | **ConsumableMaster**; **AbsorbTracker** (doc only) | ConsumableMaster fixed its one instance (`LEARNED_SPELL_IN_TAB` → `LEARNED_SPELL_IN_SKILL_LINE`) and carries neither isolation nor a record — it owes the `pcall`ed helper, the rejected-name table and the `debug`-reachable report. AbsorbTracker owes a **documentation correction, not a guard**: `docs/midnight-quirks.md:118-120` records the opposite model. **BankLedger** and **MultiMeters** are already compliant. Unmeasured and needing an audit: PanelMaster, PrettyChat, WhatGroup, KickCD, LootHistory, PartyFrameEnhanced, AuraMaster. |
| 7 revendor bundles | no | **Ten addons** (PartyFrameEnhanced has no store and is measured from its next re-vendor) | **Nineteen to thirty-one unrecorded tags apiece** from each store's first bundle — AuraMaster 19, AbsorbTracker 25, PanelMaster 26, WhatGroup 26, BankLedger/KickCD/LootHistory/PrettyChat 27, ConsumableMaster 28, MultiMeters 31 — carried by fifteen to twenty-four re-vendor commits past each store's newest bundle. **One consolidated bundle per repo** at the next `/wow-addon:revendor-libka0s` run discharges it, naming the span it covers in `01_DELTA.md`'s first line, since that line is what the check reads for a bare-dated folder. Do **not** back-fill a folder per tag, and do **not** rename an existing bare-dated folder. |
| 8 commit cells | **yes** | **All eleven addons** plus LibKa0s | Re-vendor the kit revision that emits the two row cells, then one run each. No backfill: every existing row is carried forward as *unknown* and never reconstructed from git archaeology. The runner's widening must recognize the immediately previous column set and rewrite `PREV_ROWS` with `unknown` inserted, or `run-automated-tests.sh:783`'s refuse branch fires in every repo on its first run. Check once the report lands: **ConsumableMaster** (newest bundle from a dirty tree), **AbsorbTracker** (record two source-moving commits stale), **MultiMeters** (four commits behind `master`), **LibKa0s** (the v1.25.0 dirty release bundle). |
| 9 + 13 bus | no | **BankLedger, LootHistory, KickCD, MultiMeters** | BankLedger (`core/Database.lua:106`) and LootHistory (`core/Database.lua:292`) owe a constants table plus a mechanical call-site sweep. **KickCD** fails both halves — no `MSG` table (`core/Database.lua:44`, `core/State.lua:171`) and SCREAMING_SNAKE wire names; **sequence it**, constants first and rename second, which is what makes the rename behavior-preserving. MultiMeters is compliant on the constant and renames every wire string at `core/Constants.lua:542`, subscribers unaffected. **PanelMaster** is compliant by the module-scoped shape and is **not** debt. **PrettyChat** and **WhatGroup** publish no `Ka0s_` message — the honest state is a *Not applicable* note in `## Message Bus`, not work. |
| 10 suite names | no | — | **None.** All eleven already comply. |
| 11 panel open | no | **AuraMaster, KickCD** (measurement, not fix) | Each ships a page-jump helper (`AuraMaster/settings/OptionsSetup.lua:366-375`; KickCD's `Helpers.OpenPageTab`) and owes a one-line measurement at next audit confirming it opens against a **subcategory** ID it recorded itself and is combat-gated. Neither is expected to fail. |
| 12 DragHandle | no | — | **None.** Inventory only. |
| 14 file header | no | — | **None; it is a SHOULD.** AbsorbTracker, BankLedger, LootHistory, PanelMaster and PrettyChat adopt going forward — 99 files' worth, which is exactly why it is not a MUST. |

**The kit work, in order, and it is the gate on four debt rows above.** `framework.lua`'s declaration fix
(`:649-663` keys the set by the **pair**, `:740-745` consumes it and reports a collision, an unreferenced
kit suite, and a recorded **decline** as a `Kit.skip`) lands **before or with** the `test_layout_cap.lua`
extraction, or the extraction recreates the shadowing trap in the five repos that already carry a local
copy. Beside them: the `RESULTS.md` row widening and its migration; `test_eol.lua`'s second case for O3,
with both §5 bodies copied in whole; and the `RegisterEventSafely` helper and bad-event assertion that five
repos would otherwise keep re-deriving. All of it ships as **revision 25 in LibKa0s v1.55.0** — five
published rules now name that revision (`layout-§1`, `line-endings-§7`, `testing-§9`, `localization-§5`,
`automated-tests-§4`), so a gate landing at any other revision makes those five sentences false.

**A mechanism the kit phase must choose, which the standard deliberately did not.** `testing-§9` and
`localization-§5` specify the **status** of a declined gate (a skip carrying its reason) and the **record**
(a register row), not the syntax. The kit cannot safely parse a Markdown table, so the practical shape is a
declaration entry carrying the decline and citing the row — e.g.
`{ name = "test_prose", declined = "localization-§5 row 2026-09-22" }`. If the kit picks a different
mechanism, both sections need its name written in.

### Phase 3 — what the kit phase delivers, and what it does not

**The ordering constraint the next phases run on.** Four debt rows above are marked *blocked on v1.55.0*
and **cannot be discharged before LibKa0s v1.55.0 (test-kit revision 25) is tagged and pushed** — O3's
`.gitattributes` body case, proposal 2's shadowed suites, proposal 5's cap gate, and proposal 8's
`RESULTS.md` commit cells. The library leads; a consumer citing an untagged kit is citing nothing. Every
other row can be discharged today by the repo alone.

**The Phase 3 deliverable list is the kit work named above, and this pass added nothing to it.** The
`testing-§9` question the fix pass left open — whether `loadSuites` should report a listed-but-absent suite
as a skip or raise on it — was ruled in the standard's text rather than in the kit: the section now
**describes** what revision 24 already ships, so the rule is satisfied today and carries **no
commencement**. Nothing in revision 25 has to move for it. Stated plainly because the opposite ruling was
available and would have created a deliverable: if a later pass reverses this and decides the kit should
change instead, that becomes a **new Phase 3 deliverable** and `testing.md:280-293` has to be rewritten
with a revision-25 commencement to match. It is not one today.

**What is still owed to a *mechanism* rather than to a date.** The declined-gate syntax above
(`{ name = …, pending = … }` is decided; the decline marker is not) is the one shape the kit phase must
choose for itself. Both `testing-§9` and `localization-§5` specify the status and the record and neither
specifies the syntax, so whatever the kit picks has to be written back into both.

---

## The commit gate — pass four, and what it caught

Three lenses read the release whole before it was allowed to commit: every number re-measured against the
tree, every new MUST tested for satisfiability and self-consistency, and the whole added diff checked
against the standard's own register and its US-English rule. **Ten blocker reports, seven distinct
defects.** All seven were fixed by the orchestrator directly, each against a measurement rather than
against a report, and each verified present afterward.

| # | Site | What was wrong | Now |
|---|---|---|---|
| 1 | `events-frames-taint.md:17` | **The carve-out permitted only a frame that cannot work.** It blessed a private frame "whose only job is `RegisterUnitEvent`" and then forbade it a script — but a frame that registers and never dispatches receives nothing. Read literally it excluded the live instance it was written to bless. | The permission now names the handler inside it: the `RegisterUnitEvent` calls **and the single `OnEvent` that dispatches them**. The exclusions bite on a *second* job, which is what they were always for. |
| 2 | `events-frames-taint.md:18` | "the two live call sites each name a single unit" | **Ten** authored call sites across **four** addons. Measured directly; the governing claim (no repo registers a two-unit filter) was true and survives. |
| 3 | `layout.md:85` | **Self-contradiction sixteen lines wide.** `:69` settles the census's parent as `## Documented deviations` in either host; `:85` still called the varying heading level a difference the MUST "sanctions". | `:85` now says the MUST **settles** rather than sanctions that difference, and names the one-level move the library repo owes. |
| 4 | `AUDIT.md:190` | The §5 body-intact figure was corrected to 84/85 in `line-endings` and left at **81/82** here — an auditor running the playbook would diff the wrong number of lines and file a false finding in every repo. | 84 client-bound, 85 non-client, measured from the two fenced bodies. |
| 5 | `AUDIT.md:170` | **The check was blind to the MUST this release is built around.** It grepped `*.sh` only, while `line-endings-§3` has MUSTed `*.py` beside it since v2.61.0 and this release measured 12 of 14 repos failing exactly that pin. Until kit revision 25 lands, this playbook is the only check any repo has. | `grep -nE '^\*\.(sh\|py) text eol=lf$'`, matching the section's own one-liner. |
| 6 | `line-endings.md:548` | The revision-25 gate's discriminator (`a .toc or a client-bound libs/`) **misfiles a Ka0s-owned library repo**, which has neither — verified: no `.toc`, no `libs/`. The gate would have put it in the wrong line-ending group while §2's roster puts it in the other. | A third mechanical arm: the tracked payload folder `library-stack-§7` names, reached without a roster. |
| 7 | `documentation.md:722` | §9 claimed "nothing already on disk becomes non-compliant", while `:710` settles placement as *below* the bootstrap. Measured across the collection, **the majority of existing headers sit above it** — and the earliest adopters are the most lopsided, so the rule as written would have made the repos that adopted the convention first the most non-compliant of all. | An existing header is **grandfathered where it sits**; placement binds files authored from here. The reason is stated, because a carve-out without its reason is deleted by the next author. |

Also closed: `documentation.md:356`'s ordinal now reads *the fourth table **added***, which is what it
means. It had already propagated its ambiguity into two derived files, and no pass had owned the file
since it was reported.

**What the gate confirmed rather than faulted**, and it is worth recording because three passes of
correction make a release sound worse than it is: roughly forty distinct count claims across fourteen
section files, `AUDIT.md` and `NEW_ADDON_CONTEXT.md` were re-measured against the live tree, and all but
the ones above reproduce exactly — the LibKa0s inventory (12 majors, 18 files, Options 5, eleven flooring
on Core, seven of those never reaching a member), the three second edges, 68 re-vendor bundles across ten
stores splitting 40 tagged / 28 bare, the five shadow gates at 232/221/209/380/206, the 84- and 85-line
canonical bodies. `AUDIT.md`'s new re-vendor script was **run** and produces the numbers the standard
quotes. The US-English gate this release promotes passes over the release's own prose.

### The pattern, recorded once so the next harvest does not rediscover it

Every defect in all four passes traces to one habit: **a number written from prose rather than measured
against the tree.** That is what the harvest's highest-ranked finding was (an inventory wrong in nine
places); it is what pass one's blockers were; pass two reproduced it while fixing it, including writing a
British spelling into the release that promotes the spelling gate; and the commit gate found three more.

The rule this earns, and it belongs in the next harvest's evidence: **a count in an agent's report is a
claim to verify, not a fact to copy.** The corollary is already in the standard as of this release — a
gate closes a class of deviation only when it reads the whole of its own denominator — and the two are
the same lesson at two scales.
