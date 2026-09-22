# Harvest 2026-09-22 — 05 Ripple plan

Every file each accepted proposal must touch, resolved to actual paths in the working tree, as a checklist
to be discharged item by item. **The ripple is the dangerous part, not the rule change.** A rule edited in
its section and missed in the index, the pack or a playbook leaves the standard contradicting itself, and
the contradiction is worse than the old rule: an agent reading the stale copy follows it, and nothing goes
red. This bundle exists in part because that has already happened twice to the same table.

All paths are relative to `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards/`.

---

## The touches that apply to every accepted proposal

Discharge these once per release, not once per proposal:

- [ ] **`standards/STANDARDS.md` front matter, line 1** — version and date:
      `# Ka0s WoW Addon Standard (v2.62.1, 2026-09-22)`. Bump to the highest class among the accepted
      proposals (patch if none changes a rule; **minor** if any accepted proposal can make an addon
      non-compliant — and say so in those words in the entry).
- [ ] **`standards/STANDARDS.md` changelog, at `## Changelog` (line 97)** — one entry at the top, above
      `- **v2.62.1 (2026-09-22):**` on line 99, in the house register: what changed, why, the evidence with
      its citations, the bump classification, **and the pass it came from** (`harvests/2026-09-22/`). Entries
      below it are released and are never rewritten (localization-§5's own exclusion list says so).
- [ ] **`standards/EXECUTIVE_SUMMARY.md:11`** — the current-version pointer. **It is already wrong today:**
      it reads `(current: **v2.62.1**, 2026-09-20)` while `STANDARDS.md:1` reads `2026-09-22`. Fix the date
      in the same commit whatever else lands — it is a live instance of exactly the ripple defect this plan
      is written to prevent.
- [ ] **`standards/NEW_ADDON_CONTEXT.md:1`** — the pack's own version line,
      `# New Ka0s Addon — Context Pack (v2.62.1, 2026-09-22)`, bumped in the same commit as any change that
      alters how a new addon is born.
- [ ] **Anti-patterns range invariant** — `standards/STANDARDS.md:80` reads
      `- **[anti-patterns](standards/anti-patterns.md)** — the forbidden do-not list (#1–#88).` and
      `standards/standards/anti-patterns.md`'s last entry is `88.`. **They agree today.** Any proposal that
      adds an entry moves both; verify with
      `grep -c '^[0-9]\+\.' standards/standards/anti-patterns.md` against the blurb before committing.
- [ ] **`standards/ADDONS.md`** — *not applicable to any proposal in this bundle.* The roster did not change
      (11 addons, 1 library, 2 documentation-and-tooling repos), and the previous run's drift closed on its
      own. Recorded here so `06_OUTCOME.md` can mark it genuinely not applicable rather than skipped.

---

## O1 — private event frames (events-frames-taint-§1)

Under **reading A** nothing in the standard moves; the ripple is two GitHub issues, not files.

Under **reading B** (carve out the unit-filter frame):

- [ ] `standards/standards/events-frames-taint.md` §1, **line 7** — the `MUST NOT` bullet gains the carve-out
      by name and the three conditions (held where teardown reaches it; unregistered in the module's disable
      path, because AceAddon's `UnregisterAllEvents` does not reach it; re-used across a disable/enable cycle).
- [ ] `standards/STANDARDS.md:66` — the Sections-list blurb for `events-frames-taint` currently reads
      "AceEvent; combat lockdown; taint-safe Blizzard replacement; frame pooling; combat 'secret' values"
      and does not mention the prohibition at all. If the carve-out lands, the blurb must say the section now
      names one permitted private frame, or the index understates what the section covers.
- [ ] **Consistency read, mandatory, because these two sections already presuppose the carved-out frame:**
      `standards/standards/slash-commands.md:186` ("…including the per-unit frames — gone, not gated") and
      `standards/standards/testing.md:32` (the `RegisterUnitEvent` mock-fidelity clause). Neither needs
      editing if the carve-out is worded to match them; both need editing if it is not.
- [ ] `standards/standards/anti-patterns.md` — check whether any existing entry forbids the carved-out shape
      in passing; if one does, it moves with the section.
- [ ] `AUDIT.md` — if §1 gains a condition set, the audit needs to know how to grade a private frame that
      meets it (held, unregistered, re-used) versus one that does not.
- [ ] Rollout, not a file: AbsorbTracker's and PartyFrameEnhanced's existing rows are **retired** rather than
      joined by two more.

## O2 — packaging's ignore template (packaging)

- [ ] `standards/standards/packaging.md:19-20` — the two template lines, commented out the way `tools`
      already is at `:23-27` (reading A), or left as they are (reading B).
- [ ] `standards/standards/packaging.md:33` — the MUST: `.claude/` and `.superpowers/` gain
      "**where the repo has them**" (A), matching the `tools/` clause in the same sentence.
- [ ] `standards/standards/packaging.md:34` — the strong form: the words "present in the repo" stay (A) or
      are deleted (B). **Exactly one of `:33` and `:34` moves — moving both, or neither, is how this
      ambiguity was created.**
- [ ] `standards/standards/packaging.md` — state the rule **once** rather than in a template and two bullets,
      whichever reading wins. The present split is what let seven repos each write their own paragraph.
- [ ] `standards/STANDARDS.md:70` — the packaging blurb reads "ignore lists that account for every root
      dot-entry including `.pkgmeta` itself and for the dev-only folders". Under A it must say the entries
      bind only when present; under B it is already right.
- [ ] `AUDIT.md:208-212` — the enumeration check. Under A, `.claude .superpowers` move behind the same
      `[ -d ]` gate `tools` already has:
      `entries=".luacheckrc .pkgmeta .gitignore .gitattributes docs tests _dev"` plus per-directory
      `[ -d .claude ] && entries="$entries .claude"`. Under B it is unchanged.
- [ ] `standards/NEW_ADDON_CONTEXT.md` — grep for the `.pkgmeta` template; a new addon is born with whichever
      shape wins, and a pack that still carries the other one is the drift this plan exists to catch.

## O3 — the `.gitattributes` body gate (line-endings-§7 + the kit)

**LibKa0s leads.** The kit change must be tagged and pushed before any consumer cites it.

- [ ] `LibKa0s/testkit/test_eol.lua` — a **second case**, not a new file (the gate exists and already reads
      `.gitattributes`-adjacent facts; a repo should not gain two suites over one section), asserting §5's
      properties (a)–(d): the file exists at the repo root; exactly one `* text=auto eol=crlf` **or**
      `* text=auto eol=lf` pin; `*.sh text eol=lf` and `*.py text eol=lf` both present; everything below the
      pin byte-identical to the canonical body for that kind, with the §5 appendix the one permitted addition.
      Fails rather than skips when it cannot read the file.
- [ ] The canonical bodies are copied **whole** from `standards/standards/line-endings.md:196-199` (CRLF) and
      `:287-290` (LF) into the kit, never a locally-authored subset — the same rule localization-§5 applies to
      the BRITISH list, and the same rule `LK-28d` shows a private subset breaking.
- [ ] `standards/standards/line-endings.md:466-468` — the bullet consigning properties (a)–(d) to the audit
      is **reversed**, and the reversal is recorded in the section the way v2.57.0's reversal of the
      enable/help narrowing is recorded in `slash-commands`.
- [ ] `standards/standards/line-endings.md` §7 — name the new case, so the MUST says how it is measured.
- [ ] `standards/STANDARDS.md:71` — the line-endings blurb already names "the vendored EOL gate `§7` now
      names rather than only supplying a command for"; it must now say the gate also checks the body.
- [ ] `AUDIT.md` — keep the one-liner for repos that have not re-vendored, and for
      **WowAddonStandards and wow-addon**, which track no `.lua`, run no suite, and therefore have no green
      gate to hang this on under either reading.
- [ ] Rollout, not a file: twelve repos owe the current §5 block (not just the one line — the omission is
      drift of the whole eight-line comment block). Triage each length diff first: PanelMaster's six extra
      lines are a legitimate §5 appendix (the realesrgan binary mark), AuraMaster's and LibKa0s's and the two
      tooling repos' differences need the same check before byte-identity is turned on.

---

## 1 — C8-F02: the LibKa0s inventory (clear win)

**One commit, all of it, or the next agent completes the list from whichever copy it read.**

- [ ] `standards/standards/library-stack.md:82` — "seventeen files" → eighteen; "`Options` spans four files"
      → five.
- [ ] `standards/standards/library-stack.md:91` — the `LibKa0s-Widgets-1.0` row's Files cell →
      `Widgets.lua`, `WidgetsDragHandle.lua` (and describe `DragHandle`/`DRAG_HANDLE` there — proposal 12's
      inventory half).
- [ ] `standards/standards/library-stack.md:94` — the `LibKa0s-Options-1.0` row's Files cell → all five,
      adding `OptionsTabs.lua`, with what it owns (tab strip, page banner, page header block, sub-tab strip,
      the combat-lock page cover).
- [ ] `standards/standards/library-stack.md:103` — "ten of the eleven majors refuse to register without
      `Core.lua`" → eleven of the twelve.
- [ ] `standards/standards/library-stack.md:113` — "three of the ten gate on it without calling a single
      member" → **eight of the eleven**; keep `Lifecycle` as the named example.
- [ ] `standards/standards/options-ui.md:13` — "The major spans **three** files (…)" → a pointer at
      library-stack-§7 **with no count of its own**. A count restated in a second section is a count that
      will drift again, which is what happened here.
- [ ] `standards/standards/anti-patterns.md:54` (#48) — "Four of LibKa0s's five majors" → "Eleven of the
      twelve majors", worded to match `library-stack.md:113` exactly; and the attach-file enumeration →
      `OptionsWidgets.lua`, `OptionsTabs.lua`, `OptionsCompose.lua`, `OptionsScroll.lua`, `PerfPanel.lua`,
      `WidgetsDragHandle.lua`.
- [ ] `standards/standards/anti-patterns.md` — re-check **every other cardinal in #47 and #48** against
      `LibKa0s/tests/majors.lua` in the same pass.
- [ ] `standards/standards/testing.md:279` — the stale major/attach pair named there moves with #48.
- [ ] `standards/standards/open-evolutions.md:13` — the third copy of "twelve majors across seventeen files",
      **which neither sweep found**, plus the Widgets description that omits both `ReorderList` and
      `DragHandle`.
- [ ] `standards/STANDARDS.md:57` — the Sections-list blurb: "twelve majors across seventeen files" →
      eighteen.
- [ ] `standards/EXECUTIVE_SUMMARY.md:56` — "twelve LibStub majors across seventeen files" → eighteen.
- [ ] `standards/NEW_ADDON_CONTEXT.md:489` — the three-file Options list → five.
- [ ] `standards/NEW_ADDON_CONTEXT.md:817` — the `LIB_FILES` runner list → add
      `libs/LibKa0s/OptionsTabs.lua` and `libs/LibKa0s/OptionsCompose.lua`.
- [ ] `standards/NEW_ADDON_CONTEXT.md:1037` — "ten of the eleven majors" → eleven of the twelve.
- [ ] `standards/NEW_ADDON_CONTEXT.md:1` — bump the pack version.
- [ ] `standards/standards/options-ui.md` §13 — point the tab-strip rules at the file that implements them.
- [ ] **Anti-patterns range:** #48's text changes but no entry is added, so `STANDARDS.md:80`'s `#1–#88` is
      unchanged. Verify anyway.
- [ ] **The durable half (from C5-F03), decide and record:** derive `library-stack-§7`'s table from
      `LibKa0s/LibKa0s/LibKa0s.xml` — generated the way `LibKa0s/tools/gen-api-members.lua` generates the API
      documents — **or** add an `AUDIT.md` check that diffs §7's file list against the sibling checkout's
      `LibKa0s.xml` and fails on a mismatch. Without one of these, this table falls behind a third time.
- [ ] Rollout: **none.** No addon file changes. Record that in `06_OUTCOME.md` explicitly.

## 2 — C10-F03: the shadowed kit suite

**LibKa0s leads.**

- [ ] `LibKa0s/testkit/framework.lua:649-663` — `suiteDeclarations` keys the declaration set by the pair
      `(name, dir)` rather than by bare name.
- [ ] `LibKa0s/testkit/framework.lua:740-745` — the kit-directory pass consumes the pair-keyed set, and a
      consumer suite of the same basename declared without a `dir` is reported as a **collision**, naming both
      paths and saying which one is running.
- [ ] `LibKa0s/testkit/framework.lua` — the same pass reports any `tests/_kit/*.lua` suite on disk and
      unreferenced (the general form, which covers the next kit suite). Both are failures, not skips.
- [ ] `LibKa0s/testkit/README.md:145` — the "wires one or the other, never both" rule now has an enforcer;
      say so. `:109-111`'s claim that the scan covers `tests/_kit/` becomes true.
- [ ] `LibKa0s/docs/api/testkit/version-<N>-docs.md` — a new kit-revision document, and the kit revision bump.
- [ ] `standards/standards/testing.md` — one sentence recording the rule the kit README already states: a
      repo wires the kit's copy or its own, never both. This gives the rule a normative home rather than
      only a comment.
- [ ] `standards/STANDARDS.md:73` — the testing blurb names "the three pinned load lists (TOC files, vendored
      library files, the suite list)"; the suite-list pin now also covers the kit directory by path.
- [ ] `standards/standards/localization.md:295` — the SHOULD naming the kit's prose gate can now be measured;
      do **not** raise it toward a MUST in the same edit (the gate has to be able to see the state first).
- [ ] **Ordering constraint for proposals 3 and 5:** extract, then delete the local copy in the same commit
      that wires the kit's, or the extraction recreates this trap in five more repos.

## 3 — C10-F02: the documentation-shape gate

**LibKa0s leads.**

- [ ] `LibKa0s/testkit/test_docs.lua` — new, carrying `AUDIT.md:106-144`'s six checks (a)–(f) as assertions,
      with the Tier-2 trigger counts supplied through an opts table. Fails rather than skips.
- [ ] `LibKa0s/testkit/README.md` — the new suite, its opts and its wiring entry
      `{ name = "test_docs", dir = "tests/_kit/" }`.
- [ ] `LibKa0s/docs/api/testkit/version-<N>-docs.md` + kit revision bump.
- [ ] `standards/standards/testing.md` — name the gate, so `documentation-§3`'s MUSTs have a stated
      measurement. **Do not** put the assertion list in `documentation.md`; the rule lives there and the gate
      lives in testing, the way the EOL and prose gates already split.
- [ ] `standards/standards/documentation.md` — §3 cites the gate as how it is measured.
- [ ] `standards/STANDARDS.md:76` — the documentation blurb, if the change alters what the section covers.
- [ ] `AUDIT.md:106-144` — keep the six checks as prose for repos that have not re-vendored, with one line
      saying the suite is the primary enforcement.
- [ ] **Two things the gate must NOT do, recorded here so they are not added later by someone who forgets
      why:** it must not assert the soft ~60/~400-line hub guidelines (a soft threshold on a commit gate is
      how a gate acquires a switch), and it must not carry a private list of retired filenames — that list is
      published in the standard and copied whole, like localization-§5's BRITISH list.

## 4 — C9-F01: `docs/revendor/` named in the standard

- [ ] `standards/standards/documentation.md:329-331` — add `docs/revendor/<date>/` to the frozen-and-generated
      scope sentence, beside the six already there.
- [ ] `standards/standards/audit-review-history.md` — the store as the third frozen dated bundle kind beside
      `docs/audits/` and `docs/reviews/`: the `<date>-v<tag>` folder form, the numbered-prefix document
      convention with `01_DELTA.md` and `05_SUMMARY.md` as its stable members, and the statement that it
      carries no `README.md`.
- [ ] `standards/STANDARDS.md:76` — the documentation blurb enumerates the map's four tables; if the scope
      sentence's directory list is part of what the blurb describes, it moves.
- [ ] `standards/STANDARDS.md:77` — the audit-review-history blurb currently names "frozen dated `docs/audits/`
      + `docs/reviews/` bundles"; it must name the third.
- [ ] `standards/NEW_ADDON_CONTEXT.md` — the `docs/` tree a new addon is born with, and its Documentation-map
      template, if either enumerates the frozen directories.
- [ ] **Do NOT write** a general "an addon adds nothing to the scope list" rule. Confine the upstream-change
      rule to a store written by a shared command across repos, or it contradicts Tier 3 at
      `standards/standards/documentation.md:296-301` and turns `AuraMaster/docs/spell-research/` into upstream
      debt it is not.
- [ ] `AUDIT.md` — the Documentation-map check's out-of-scope directory list gains `docs/revendor/`, or it
      will file every bundle as an unregistered `.md`.

## 5 — C10-F01: the 1500-line cap gate

**LibKa0s leads, and a prose half lands first.**

- [ ] **Prose half, first:** `standards/standards/layout.md` §1 (or `standards/standards/documentation.md`
      §3, if the hub's shape is the better home) mandates the over-cap **census heading** and its row shape.
      Without it, parts (b) and (c) of the gate assert a document structure the standard does not require.
      Settle the heading **name**, not only its level: `### Files over the 1500-line cap` (three addons)
      versus ``### Files by the `layout-§1` band`` (PanelMaster) versus `## Files over the 1500-line cap`
      (LibKa0s, whose hub is `CLAUDE.md`).
- [ ] **Decide the band question against the rule that already owns it:** `standards/standards/automated-tests.md:268`
      says the 1000–1500 band "is a column, not a heading", and `standards/standards/performance.md:236,278`
      already MUST the band onto the release watch list. PanelMaster's gate asserts the band in the hub, which
      collides with that. Rule on it there, not in isolation.
- [ ] `LibKa0s/testkit/test_layout_cap.lua` — new: (a) no authored `.lua` over 1500 lines absent from the
      census; (b) every census row names a path that exists and is still over the cap; (c) each over-cap row
      carries one of layout-§1's three terminal states. Over the `git ls-files` set with `libs/` and
      `tests/_kit/` dropped. Fails rather than skips when it cannot look.
- [ ] `LibKa0s/testkit/README.md` + `LibKa0s/docs/api/testkit/version-<N>-docs.md` + kit revision bump.
- [ ] `standards/standards/layout.md:57`/`:67` — cite the gate as how the cap is measured; the three terminal
      states stay as they are.
- [ ] `standards/standards/testing.md` — the suite named in the kit inventory.
- [ ] `standards/STANDARDS.md:55` — the layout blurb already names "the three terminal states an over-cap file
      may sit in"; it must now name the census and the gate.

## 6 — C3-F05: retail raises on an unknown event name

- [ ] `standards/standards/events-frames-taint.md:5-9` — §1 states the client behaviour and requires a
      registration block to survive one bad name. Promote BankLedger's write-up, name the repo it came from,
      and carry MultiMeters' front gate as the complementary half with its stated reason.
- [ ] `standards/STANDARDS.md:66` — the events-frames-taint blurb (currently five words) must name the new
      rule, or the index understates the section.
- [ ] `LibKa0s/testkit/` — the kit already models the raise at `mock_base.lua:715-727`; add the **assertion**
      so every repo inherits it rather than each writing PanelMaster's case again
      (`PanelMaster/tests/test_harness.lua:115-123` is the reference).
- [ ] `LibKa0s/LibKa0s/` — if the five-line `RegisterEventSafely` helper is extracted, it is a library change
      and **LibKa0s leads**: tagged and pushed before any consumer cites it.
- [ ] `standards/standards/anti-patterns.md` — a bare registration loop over a name list is a candidate entry.
      **If one is added, `STANDARDS.md:80`'s `#1–#88` becomes `#1–#89` and the file's last entry must agree.**
- [ ] `standards/NEW_ADDON_CONTEXT.md` — a new addon's event-registration example, if it shows a bare loop.
- [ ] Rollout, not a file: AbsorbTracker owes a **documentation correction** rather than a guard —
      `AbsorbTracker/docs/midnight-quirks.md:118-120` records the opposite model and would mislead the next
      author. That is a per-repo task for `/wow-addon:standards-audit`, not a file in this repo.

## 7 — C9-F02: the lapsed re-vendor bundles

- [ ] **Prose half, first — it is proposal 4's `audit-review-history` touch.** A check that measures
      conformance needs a rule to measure against, and `docs/revendor/` is named in no section today.
- [ ] `AUDIT.md` — the mechanical check: for every `Re-vendor LibKa0s v<tag>` commit in the repo's history, a
      `docs/revendor/` bundle naming that tag exists, or the absence is justified in the deviation register.
      `standards/standards/versioning-git.md:9` already requires the commit and requires it to stand alone, so
      the subject is a reliable trigger and the check is a git-log-to-directory-listing comparison.
- [ ] `standards/standards/versioning-git.md:9` — if the commit subject becomes machine-read, the SHOULD that
      the re-vendor commit stands alone gains the subject form `Re-vendor LibKa0s v<tag>` beside it. A subject
      a tool parses is not a style preference.
- [ ] `wow-addon/commands/revendor-libka0s.md` — **out of scope for this repo's ripple**, but record in
      `06_OUTCOME.md` that the command at `:171` and `:307` already mandates the bundle, so the fix is the
      check plus the rule rather than new command text.
- [ ] Rollout, not a file: one consolidated bundle per repo covering v1.34.0/v1.35.0 → v1.54.2, written by
      `/wow-addon:revendor-libka0s` on its next run; PartyFrameEnhanced additionally needs the store created.

## 8 — C4-F03: SHA and clean flag in the test record

- [ ] `standards/standards/automated-tests.md:179-183` (§4) — the MUST that every `RESULTS.md` row carries the
      commit SHA the run measured and whether the tree was clean at it, and the MUST NOT on recording a run
      from a dirty tree without marking it.
- [ ] `standards/standards/automated-tests.md` §3 — the manifest already carries `git { sha, branch, dirty }`
      as runner behaviour; §3 makes it required rather than incidental.
- [ ] `standards/standards/automated-tests.md` — the generated/authored boundary: the two new cells are the
      **runner's**, like every other cell but the complexity watch list's `Disposition`.
- [ ] `LibKa0s/testkit/run-automated-tests.sh` — emit both into the row and the manifest (it already knows
      them). Kit revision bump; **LibKa0s leads**.
- [ ] `LibKa0s/testkit/` — the kit case that **reports** (never fails) when the newest bundle's SHA is not
      HEAD. §4 is explicit that perf and complexity do not gate a commit, and a staleness check that blocks
      work is one people learn to bypass.
- [ ] `standards/STANDARDS.md:75` — the automated-tests blurb names "`RESULTS.md` as the single-path trend
      line" and "the **one boundary** between what is generated and what is authored"; both move.
- [ ] `AUTOMATED_TESTS.md` (repo root playbook) — the run's recorded fields.

## 9 — C1-F06: bus message names as constants

- [ ] `standards/standards/architecture.md:83-95` — §4's worked example stops typing the literal at both call
      sites and shows the constant; the MUST is added beside the existing four, with the reason (a misspelled
      literal is a message nobody sends or nobody hears, and no lint, test or client error sees it).
- [ ] `standards/standards/architecture.md:91` — the existing "MUST document each message in
      `docs/ARCHITECTURE.md` with: name, sender (one), payload schema, all consumers" gains the note that the
      constant MAY carry its sender in a comment beside it, satisfying that MUST there. **Do not** write it as
      a new obligation: three of the five repos already do it and the MUST already exists.
- [ ] `standards/standards/naming-cheatsheet.md` — a row for the message-name catalog, beside the existing
      `| Bus messages |` row at `:20`.
- [ ] `standards/STANDARDS.md:58` — the architecture blurb names "the closed message bus and the shape of
      addon it binds"; it must now name the catalog.
- [ ] `standards/NEW_ADDON_CONTEXT.md` — the bus example a new addon is born with.
- [ ] `standards/standards/anti-patterns.md` — a raw message literal at a call site is a candidate entry;
      **if added, move the `#1–#N` range in `STANDARDS.md:80` with it.**
- [ ] **Sequencing, recorded for the rollout:** KickCD must adopt the table **before** proposal 13's rename,
      which is what makes that rename behaviour-preserving. PanelMaster already conforms by a different shape
      and is not debt.

## 10 — C1-F03: naming the rule-subject conformance suites (clear win)

- [ ] `standards/standards/testing.md:164-186` (§8) — the parity cases **MUST** live in
      `tests/test_surface_parity.lua`, listed in `tests/run.lua` like any other suite.
- [ ] `standards/standards/testing.md` — one sentence on the general case, citing the two instances the
      standard already names by filename (`tests/test_disabled.lua` at
      `standards/standards/slash-commands.md:271`, `tests/test_kitsync.lua` at `standards/standards/testing.md:316`).
      Add `tests/test_vendor_sync.lua` and its delegation MUST in the same sentence.
- [ ] `standards/standards/naming-cheatsheet.md:11` — beside `| Test suites | test_<module>.lua |`, a row for
      `test_<rule-subject>.lua`.
- [ ] `standards/STANDARDS.md:73` — the testing blurb names "the stub-surface parity case"; it can now name
      the file.
- [ ] `NEW_ADDON.md` (repo root playbook) — the scaffold's `tests/` file set, so a new repo is born with the
      filenames.
- [ ] `standards/NEW_ADDON_CONTEXT.md` — the same list in the pack, plus its version bump.
- [ ] Rollout: **none.** All eleven addons already comply. Record it as genuinely not applicable.

## 11 — C3-F07: `Settings.OpenToCategory`

- [ ] `standards/standards/options-ui.md`, beside §2's combat-refusal bullets at `:64-67` — the two facts as a
      catalogue entry: the numeric ID captured with `:GetID()` at registration, and the `pcall`'d
      `GetCategoryList():GetCategoryEntry(cat):SetExpanded(true)` walk called **after** `OpenToCategory` and
      re-run on every open. Promote ConsumableMaster's write-up and name the repo it came from; take
      WhatGroup's enumerated wrong forms including the silent string case, and KickCD's AceConfig variant.
- [ ] `standards/standards/options-ui.md` — the MUST NOT on hand-rolling the open, **with the page-jump
      carve-out**: a call against a recorded *subcategory* id, combat-gated, which at least two repos ship
      (`AuraMaster/settings/OptionsSetup.lua:366-375` and KickCD's `Helpers.OpenPageTab`).
- [ ] **Do NOT add** WhatGroup's "a parent with subcategories renders no panel widgets" element:
      `standards/standards/options-ui.md:84-91` already MUSTs the landing-page/subcategory split **and** a
      parent body every addon renders, so promoting it would contradict §5.
- [ ] `standards/STANDARDS.md:60` — the options-ui blurb, if the section's coverage changes.
- [ ] `standards/standards/anti-patterns.md` — #88 already covers the combat-close case; check whether
      hand-rolling the open belongs beside it. **If an entry is added, move the range.**
- [ ] Rollout: none as a catalogue entry. With the MUST NOT, AuraMaster and KickCD need a measurement
      confirming their page-jump helpers sit inside the carve-out.

## 12 — C8-F03: `Widgets.DragHandle`

- [ ] **Inventory half rides with proposal 1** — `standards/standards/library-stack.md:91`. Do not apply it
      twice.
- [ ] `standards/standards/standalone-windows.md` **or** `standards/standards/options-ui.md` — the open
      question: does an unlock/move anchor have to be the library's handle, the way options-ui-§18 requires
      `ReorderList` for an ordered list? §18 is scoped to "where the **order** of a list is the setting" and
      does not reach a frame-move handle, so nothing covers it today.
- [ ] `standards/STANDARDS.md:61` (standalone-windows) or `:60` (options-ui) — whichever section takes it.
- [ ] `standards/standards/preview-mode.md` — cross-check: the unlock anchor is the affordance preview mode's
      lock/unlock state is expressed through, and the two rules must not disagree.
- [ ] Rollout: the table fix costs nobody anything. A SHOULD sends eight addons to look at whatever they draw
      an unlock anchor with. **No LibKa0s change needed first** — the surface ships at v1.54.2, which every
      addon already vendors.

## 13 — C1-F07: the casing of `<Event>`

- [ ] `standards/standards/naming-cheatsheet.md:20` — the Bus messages row's Convention cell gains
      **PascalCase**, with the past-participle preference as a SHOULD and the note that the SCREAMING_SNAKE
      constant proposal 9 asks for is a different thing from the wire string it holds.
- [ ] `standards/standards/architecture.md:83-95` — the example must agree with the cheatsheet; it already
      uses `Ka0s_<Addon>_RosterChanged`.
- [ ] `standards/STANDARDS.md:79` — the naming-cheatsheet blurb is one line ("the naming conventions table")
      and does not move.
- [ ] Rollout, not a file: KickCD and MultiMeters rename every message. **Sequence it** — KickCD adopts
      proposal 9's constant table first, then both rename, because a bus rename is behaviour-preserving only
      if publisher and subscriber move together. Three of KickCD's five names are state nouns and need a
      semantic rename, not a case change.

## 14 — C1-F08: the self-naming file header

- [ ] `standards/standards/documentation.md` — the SHOULD, with its reason (`module-map.md` answers the
      question in a file the reader is not in; the path survives a paste into a review, an issue or an agent
      transcript) **and the placement**: immediately after the `local _, NS = ...` bootstrap, which is what
      documentation-§5's comment-citation check reads.
- [ ] `standards/standards/naming-cheatsheet.md` — a row, if the convention is expressed there instead.
      **One home, not two.**
- [ ] `standards/STANDARDS.md:76` — the documentation blurb, if §-coverage changes.
- [ ] `standards/NEW_ADDON_CONTEXT.md` — the scaffold's file templates. **This is the load-bearing touch:**
      even the repos at ~100% leave the same scaffolded files bare (`core/CoreSetup.lua`, `settings/Slash.lua`,
      `core/Constants.lua`, `core/Namespace.lua`, `core/State.lua`), which is where the convention has to be
      seeded to hold.
- [ ] `NEW_ADDON.md` — the playbook, if it enumerates what a new file opens with.
- [ ] Rollout: under the SHOULD nothing is retroactively non-compliant. Under a MUST it is 99 files across
      five repos, which is the reason not to write it as one.

---

## Discharge record

`06_OUTCOME.md` records, per accepted proposal, **which touches applied and which were genuinely not
applicable** — not which were skipped. The two are different, and only the first is safe.

Three standing checks before the release commit, each of which has failed in this collection before:

1. `grep -rn "seventeen files\|five majors\|ten of the eleven\|three of the ten" standards/` returns nothing.
2. `standards/STANDARDS.md:80`'s anti-pattern range matches the last entry in
   `standards/standards/anti-patterns.md`.
3. `standards/EXECUTIVE_SUMMARY.md:11`'s version **and date** match `standards/STANDARDS.md:1`. They do not
   match today.
