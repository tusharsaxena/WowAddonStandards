# 04 — Technical design: WowAddonStandards remediation (2026-10-07)

This repo is documents only, so every fix is a text edit. Two things decide the design:

- **What gets re-read downstream.** `AUDIT.md` and the section files are fetched on every run in
  thirteen sibling repos, so a sentence there is reproduced, not just read.
- **The repo's own ripple rule.** Under `CLAUDE.md:132-135`, a change to the standard ripples into
  `EXECUTIVE_SUMMARY.md` and `NEW_ADDON_CONTEXT.md`, and sometimes into the root `README.md` and the
  playbooks, and the version and changelog are bumped.

The fixes below are a **patch release of the standard (v2.76.2)**. None changes what an addon must
do, with one exception: WAS-09 changes which directories a notation sweep may touch, and its
direction is protective (it sweeps fewer files). If the owner prefers, WAS-09 can carry a minor
bump instead.

## Design by deviation

### WAS-01 (+01a, +01b): this repo keeps its own lane stores

**The decision to write down.** Addons audit themselves in their own repos. That stays true. This
repo is also audited, against documentation-§8, and keeps its own frozen `docs/audits/<date>/` and
`docs/reviews/<date>/` stores. documentation-§8 already applies `audit-review-history` unchanged,
so this records what the standard says rather than introducing anything new.

**Edits.**

- **`CLAUDE.md`.**
  - `:11-12`: change "does **not** run audits" to "does not audit **addons**".
  - `:61-62`: "Audit and review runs of addons live in each addon's repo. This repo's own documentation-lane runs live under `docs/audits/` and `docs/reviews/` here (documentation-§8, `audit-review-history`)."
  - `:107-110`: same qualifier.
- **`docs/ARCHITECTURE.md`.**
  - `:23-24`: limit the sentence to *addon* output.
  - **WAS-01a:** add two rows to the map, `docs/audits/<date>/` and `docs/reviews/<date>/`, each described as a "frozen documentation-lane bundle, named once here", matching `harvests/<date>/` at `:83`.
- **`README.md:17-18`, `:154-156`, `:160-161`, `standards/README.md:5-6` and `standards/ADDONS.md:5-7`, `:80-82`:** the same qualifier. ADDONS.md's own `:55-56` ("are audited") is already correct and is the anchor.
- **`AUDIT.md:3-6`:** "auditing **one repo** — usually an addon; the kind table in step 1 says which rule set binds". Keep "never an addon's audit results".
- **WAS-01b, `DEPENDENCIES.md:14`:** replace the file count with the composition, which does not go stale on every audit: "Markdown only, plus `LICENSE`, `.gitattributes` and the collection logo".

**Risk.** Low. Getting the wording wrong would read as permission to run *addon* audits here, so
keep "addons audit themselves" verbatim beside the new clause.

### WAS-02 (+02a, +02b, +02c): finish the v2.61.0 `*.py` ripple

- **The repo's own file.** Replace `.gitattributes` with the non-client fence from line-endings-§5, byte-for-byte, extracted mechanically rather than retyped (the awk extraction in E2). Check: the `diff` against the canonical file is empty, the tail is empty, and `git add --renormalize .` stages nothing. (e) is already 0. A docs-only repo has no shebang files, so nothing on disk changes behavior.
- **WAS-02a.** Change documentation-§8's row (`documentation.md:675`) to "the `*.sh text eol=lf` and `*.py text eol=lf` carve-outs, mandatory in both kinds (`line-endings-§3`)".
- **WAS-02b.** Add `*.py text eol=lf` to the `CLAUDE.md:123-124` enumeration. Once the file is canonical, the "non-client canonical body" labels at `CLAUDE.md:47`, `README.md:140` and `DEPENDENCIES.md:64` become true and need no edit.
- **WAS-02c.** `EXECUTIVE_SUMMARY.md:52`: name both carve-outs, and fix "the eight addons" to "the eleven addons" (WAS-06).
- **Optional, same sweep.** `AUTOMATED_TESTS.md:28`, `NEW_ADDON.md:20`, `NEW_ADDON_CONTEXT.md:1514/:1622`, `anti-patterns.md:67`, `automated-tests.md:64` and `library-stack.md:221` mention only `*.sh`. None says "only", so none is wrong, but naming both carve-outs keeps the next reader from re-deriving the rule from a partial quote. `NEW_ADDON_CONTEXT.md:1198`, the snippet a scaffold copies, already carries `*.py`.

### WAS-03: stop priming audits for failures that adoption has closed

- **`AUDIT.md:541-543`.** Delete "every addon in the collection is expected to be non-compliant until it adopts". Keep "record the gap once, as one finding per addon".
- **`AUDIT.md:652-657`.** Recast as history: "The 2026-09-16 sweep found eleven of eleven failing, with 107 survivors. Every addon has since adopted `LibKa0s-Lifecycle-1.0` (all on ≥ v1.42.0). Measure the latch and the registration set; do not assume the draw gate, and do not assume its absence." Keep the v1.40.0 and v1.42.0 floor sentence.
- **`launcher.md:92`.** "Every roster addon has since adopted (measured 2026-10-07: `core/LauncherSetup.lua`, LibDBIcon and the 128 `.tga` in all eleven); this subsection now records *how*, for a new addon." Keep the blocked-versus-overdue logic, since it still governs a new addon.
- **`slash-commands.md:200`.** Change to the past tense with a date: "at the 2026-09-16 sweep, eleven of eleven implemented disable as a draw gate…". The argument for the rule survives intact.

**Ordering.** Independent of the rest. Highest value, because it changes the next eleven runs.

**Cross-repo.** WAS-15 is the same text in the `dev-copilot` documentation-lane prompt. Fix it in
that repo's run, in the same remediation milestone, so the prompt and the playbook stop disagreeing.

### WAS-04 / WAS-05: make file:line examples rot-proof

**The rule to adopt.** Write it into documentation-§6's *Citing the standard*, or §5, as a SHOULD.
A worked example citing another repo **SHOULD** do one of two things:

- (a) pin the commit it was measured at, as `` `Repo@<sha7>:path:line` ``;
- (b) cite a **symbol or heading**, as `` `BankLedger modules/Browser.lua` `B:MakeCloseButton` ``.

Bare `path:line` is reserved for a frozen bundle's own evidence. Without this, every release rots
the examples. The 43 ROT and 6 GONE in E5 are the measurement.

**Edits.**

- **WAS-05 first.** In `AUDIT.md:523`, replace `` `modules/Browser.lua:98` `` with `` `modules/Browser.lua` `B:MakeCloseButton` ``.
- **Then the E5 list, one site at a time.**
  - **Historical narrative** ("the case this was written for"): pin each citation to the SHA at which the sentence was authored. `git log -S '<cited text>'` on the standard gives the authoring commit and its date. The sibling repo's SHA on that date comes from `git -C <repo> rev-list -1 --before=<date> master`.
  - **Present-tense examples** (`options-ui.md:410` "The live case", `standalone-windows.md:31-37`, `toc-file.md:171`): re-point to the current line and add the symbol name.
  - **GONE citations** (`library-stack.md:382-388` LSMPatch, `layout.md:87` `test_layout_cap.lua`): change the tense to "shipped" and pin the SHA.

**Risk.** Pinning by SHA needs the sibling history to be available, and it is. Do not "fix" the line
numbers inside `harvests/` or `standards/_raw/`, which are frozen.

### WAS-06: re-derive or date every present-tense inventory

| Site | Change |
|---|---|
| `audit-review-history.md:9`, `:11`, `:51` and `AUDIT.md:343`, `:346-348` | Either restate as "at the 2026-09-22 count, 68 bundles (40 tagged, 28 bare) in 10 stores", or re-measure (today: 225, 197, 28, 11 stores). The argument rests on the 28 bare-dated bundles, which is unchanged, so dating is the smaller edit. `:25`: "Ten addons ship" becomes "Eleven", or dated. |
| `documentation.md:150` | Re-measure: "all eleven addons nest it under `## Documented deviations`". The convergence argument is now settled, not open. |
| `documentation.md:359` | "Ten addons" becomes "Eleven", or dated. |
| `AUDIT.md:145-146` | "split five to four" becomes "split six to five", or "split". |
| `EXECUTIVE_SUMMARY.md:36` | "all eleven" becomes "nine of nine", per documentation-§3. |
| `EXECUTIVE_SUMMARY.md:52` | "the eight addons" becomes "the eleven addons". |
| `library-stack.md:95`, `open-evolutions.md:71`, `options-ui.md:376`, `:408` | "nine addons" becomes "every addon", which states the point without a count that rots. |
| `library-stack.md:382` | "Five addons ship" becomes "Five addons shipped (as of <sha/date>)". |
| `documentation.md:297-305` | Date the Compat sizes ("measured 2026-09-…"). The argument is historical. |
| `layout.md:93`, `AUDIT.md:270` | PrettyChat moved its splitter to `tools/split_globalstrings.py`. Record it as resolved, and delete the AUDIT.md "Known instance" sentence, which can no longer fire. |

### WAS-07: one ordinal scheme for the hub sections

Use documentation-§3's list order, the one at `:148` and in `EXECUTIVE_SUMMARY.md:36`: Documentation
map is the ninth section and Documented deviations the tenth. Make `:170` say "the tenth mandated
section" and `:347`'s heading say "the ninth". Consistent alternative: drop both ordinals.

### WAS-08: two malformed references and one item pointer

- **`STANDARDS.md:120`.** `` `preview-mode-§` `` becomes `` `preview-mode` ``.
- **`STANDARDS.md:168`.** `` `automated-tests-§?` `` becomes `` `automated-tests-§3` ``, the release gate, *The release gate*. Confirm against the section heading `### 3. What gates, and what only records (MUST)` before writing it.
- **`documentation.md:259`.** "(documentation-§1 item 8)" becomes "(documentation-§1 item 6)".

These are changelog entries, but documentation-§6 exempts only frozen bundles, and the changelog is
live text. The `tiered-layout-§N` carve-out at `:236` is a declared historical exception. Leave it alone.

### WAS-09: one list of frozen stores, used by both rules

Rewrite `documentation.md:625-637` so the sweep exemption **refers to** documentation-§3's
out-of-scope store list rather than restating a shorter one. That is the same centralization
documentation-§3's `:373-376` argues for. Then:

- Make the command exclude `docs/perf-analysis/`, `docs/superpowers/` and `docs/investigations/`, and the run directories under `docs/automated-tests/` (`--exclude-dir` matches a basename, so keep `automated-tests`, accept the live `README.md`/`RESULTS.md` blind spot, and state it). Simpler: replace the `grep -r` with a `git ls-files` pipeline that filters the documentation-§3 paths. That also matches the census rule (`git ls-files`, stated scope).
- Add a sentence that a repo's *own* frozen stores (this repo's `harvests/` and `standards/_raw/`) are exempt on the same footing.

**Risk.** A sweep command is an executed artifact. Test the new pipeline in LootHistory: the 117
`docs/superpowers/` hits must vanish and the live-doc count must be unchanged.

### WAS-10: make documentation-§8 truly exhaustive

- Add `localization-§1`–`§4` (`NS.L`, keys, coverage, matching on IDs) to *Does not apply*: there is no Lua.
- Add `documentation-§9` to *Applies, unchanged* with "no instance until the repo authors Lua", mirroring §9's own sentence.
- In the `:698` row, write "Five of the ten describe a runtime this repo kind does not have (Settings Schema, Message Bus, Slash Commands, Event Subscriptions, Taint Notes); Module Map stays, read as a file-and-path map", so the arithmetic sums.

### WAS-11: name the seventh Tier 2 doc everywhere

Add `perf-analysis/README.md` (trigger: the harness is wired, performance-§12) to the Tier 2 lists
at `CLAUDE.md:155-156` and `EXECUTIVE_SUMMARY.md:38`.

### WAS-12 (Info): roster copies

Optional. Change `README.md:47-49` to "the eleven addons in `standards/ADDONS.md`", dropping the
names. `line-endings.md:72-74` is normative text that benefits from naming the repos, so keep it,
and note in `CLAUDE.md:76-78` that the standard's own pin list is the one sanctioned copy.

### WAS-13: changelog order

Move the `v2.19.0` entry (`STANDARDS.md:218`) above `v2.18.0` (`:215`). A changelog is history, but
its order is presentation, not content, so this changes no wording. Make `standards/README.md:13`
say "after the Sections map".

### WAS-14, WAS-15 (Info)

No change here. WAS-15 is carried to `dev-copilot`.

## Ordering constraints

- **Version bump.** The v2.76.2 changelog entry goes **first** in `## Changelog`, and it lands in the same change as the text edits (CLAUDE.md editing rules).
- **WAS-02 before WAS-02b.** WAS-02b's labels become true only once WAS-02's file is canonical.
- **WAS-01a with this bundle.** WAS-01a has to land in the same commit that adds this bundle, or right after it, so the map is never caught with orphans.
- **WAS-09.** Ships with a changelog line that tells re-vendor-standards runs about the narrowed scope, because it changes an executed command.
