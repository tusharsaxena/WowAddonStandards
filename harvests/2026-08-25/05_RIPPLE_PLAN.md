# Harvest 2026-08-25 — 05 Ripple plan

Every file each proposal must touch, resolved to real paths against the working tree. Discharge
item by item; record the outcome of each in `06_OUTCOME.md`, including the ones that turn out not to
apply.

The nine ripple slots (Step 6): **1** section file · **2** `STANDARDS.md` Sections blurb ·
**3** anti-pattern range · **4** changelog entry · **5** version bump · **6** `NEW_ADDON_CONTEXT.md`
(+ its own version) · **7** `EXECUTIVE_SUMMARY.md` (+ its current-version pointer) · **8** the
playbooks · **9** `ADDONS.md`.

Slots **4** and **5** apply to every accepted proposal and are listed once, at the end.

---

## P-01 — the ordering contradiction

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/layout.md:51` | the load-order MUST — the change itself |
| 1 | `standards/standards/toc-file.md:106` | make the "matching the load order (layout-§1)" clause true, or delete it (reading C) |
| 2 | `standards/STANDARDS.md` — `layout` blurb | says "the single modular … layout + load order"; the order it names changes |
| 3 | anti-patterns | **n/a** — no anti-pattern added, and **#28 is safe**: `anti-patterns.md:34` defers to `toc-file-§1`/`toc-file-§5` by reference rather than restating an order, so it follows whichever way P-01 goes |
| 6 | `standards/NEW_ADDON_CONTEXT.md:106-108` | the starter tree's `Compat.lua -- LOAD FIRST` prefix |
| 6 | `standards/NEW_ADDON_CONTEXT.md:186-196` | the TOC template — already the winning order under reading A; **must** be rewritten under reading B |
| 7 | `standards/EXECUTIVE_SUMMARY.md:18` | item 2 names the modular layout; check whether it states an order |
| 8 | `NEW_ADDON.md:49` | "Lay out files. Use the single modular layout" |
| 8 | `AUDIT.md` | the layout / TOC checks, if they name an order |
| 9 | `ADDONS.md` | **n/a** — roster unchanged |

**Under reading B only:** every one of the nine addons needs a TOC reordering. That is rollout debt,
not a ripple — it belongs in `06_OUTCOME.md` and in Step 7, and this repo writes none of it.

## P-02 — the `core/` prefix

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/layout.md:51` | same line as P-01 — **land P-01 and P-02 as one edit** |
| 2 | `standards/STANDARDS.md` — `layout` blurb | as P-01 |
| 3 | anti-patterns | **n/a** unless the replacement constraint is expressed as one |
| 6 | `standards/NEW_ADDON_CONTEXT.md:106-118` | the starter tree — six setup files now sit inside the `core/` block |
| 6 | `standards/NEW_ADDON_CONTEXT.md:186-196` | the TOC template's `core/` order |
| 7 | `standards/EXECUTIVE_SUMMARY.md:18` | as P-01 |
| 8 | `NEW_ADDON.md:70-85` | "In TOC load order:" — the normative setup-file ordering, which is the replacement constraint stated in prose |
| 8 | `AUDIT.md` | whichever check produces CM-49; it must stop producing it |

## P-03 — ten majors across thirteen files

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/library-stack.md:70` | the count **and** its members |
| 1 | `standards/standards/library-stack.md` module table | four new rows: Env, Item, Pool, Widgets |
| 1 | `standards/standards/library-stack.md:95` | "Five of the six majors need `LibKa0s-Core-1.0`" — recount against the library |
| 1 | `standards/standards/open-evolutions.md` — *Further `LibKa0s` modules* | the shipped list and the candidate list; **remove the object pool from the candidates** |
| 2 | `standards/STANDARDS.md` — `library-stack` blurb | names the umbrella; check it states no count |
| 3 | anti-patterns | **n/a** |
| 6 | `standards/NEW_ADDON_CONTEXT.md:955-960` and the `libs/LibKa0s/` prose | the whole-folder payload description, if it states a file count |
| 7 | `standards/EXECUTIVE_SUMMARY.md:51` | **"six LibStub majors across nine files (Core, Media, DebugLog, Slash, Options, Perf)"** — the count and the parenthesized member list |
| 8 | `NEW_ADDON.md:70-85` | the setup-file list — `EnvSetup`/`ItemSetup`/`PoolSetup` are absent from it and are consumed by 9 / 3 / 4 addons |
| 8 | `AUDIT.md` | any vendored-file inventory that pins nine files |

**This is the ripple most likely to be left half-done**, because the count appears in four documents
and three of them state it with a different member list. `grep -rn "six LibStub majors\|six majors\|nine files"` before declaring it discharged.

## P-04 — the load-bearing annotation

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/toc-file.md` (§5) | the new MUST/SHOULD and the one definition of both terms |
| 2 | `standards/STANDARDS.md` — `toc-file` blurb | "`#`-sectioned file listing" → add the annotation |
| 3 | anti-patterns | **candidate**: moving a load-bearing line without reading its comment. If added, `#1–#65` becomes `#1–#66` in **both** the `anti-patterns` blurb in `STANDARDS.md` and the file's last entry (today `anti-patterns.md` ends at **#65**, and the blurb agrees) |
| 6 | `standards/NEW_ADDON_CONTEXT.md:186-196` | the TOC template already annotates `MediaSetup`; make the annotation explicit as the required form |
| 7 | `standards/EXECUTIVE_SUMMARY.md` | only if the summary gains a line for it |
| 8 | `AUDIT.md` | a check: every seam line in the `# Core` block carries a position comment |

## P-05 — packaging the agent-tooling directories

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/packaging.md` | the ignore-list MUST **and** the minimum template (both list the entries; they must not disagree) |
| 2 | `standards/STANDARDS.md` — `packaging` blurb | "`.pkgmeta`: vendored libs, ignore lists, no `externals:`" — likely unchanged |
| 3 | anti-patterns | **n/a** |
| 6 | `standards/NEW_ADDON_CONTEXT.md:949-962` | the `.pkgmeta` block — a new addon is born with the entries |
| 6 | `standards/NEW_ADDON_CONTEXT.md:926-927` | the prose that walks through adding `.gitattributes` to the ignore block |
| 7 | `standards/EXECUTIVE_SUMMARY.md` | no packaging line today; leave alone |
| 8 | `AUDIT.md` | **the mechanical check** — this is half the proposal, not an optional extra |

## P-06 — the unpublished addon and `X-Curse-Project-ID`

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/toc-file.md:30` | the MUST NOT + SHOULD |
| 2 | `standards/STANDARDS.md` — `toc-file` blurb | "required TOC fields" — check it does not enumerate |
| 3 | anti-patterns | **candidate**: a placeholder distribution id in a shipped TOC. Same `#1–#N` arithmetic as P-04 if taken |
| 6 | `standards/NEW_ADDON_CONTEXT.md:176` | `## X-Curse-Project-ID: <id>` in the TOC template — a new addon is by definition unpublished, so this line is exactly the case the proposal governs |
| 6 | `standards/NEW_ADDON_CONTEXT.md:1130` | "`X-Curse-Project-ID` (mandatory once published on CurseForge)" in the hard-rules cheat sheet |
| 8 | `AUDIT.md` | whatever produced PanelMaster's D-001/D-002 must stop producing them once the comment is present |

## P-07 — a quirks catalogue section

| # | File | Touch |
|---|---|---|
| 1 | `standards/standards/<new>.md` | the new section file, in the house form (the `> Part of the …` banner first) |
| 2 | `standards/STANDARDS.md` — **Sections list** | a new entry, in reading order — the single item that makes the section exist for every tool, since the plugin discovers sections by following this list |
| 3 | anti-patterns | **n/a** |
| 6 | `standards/NEW_ADDON_CONTEXT.md` | only if a new addon is born with a quirks obligation beyond `documentation-§3`'s Tier 2 `midnight-quirks.md` |
| 7 | `standards/EXECUTIVE_SUMMARY.md` | the summary lists the standard's shape; a new section is the kind of thing it names |
| 8 | `AUDIT.md:89-92` | the Tier 2 accounting for `midnight-quirks.md` — the relationship between the per-addon file and the collection catalogue must be stated, or the two will drift into two sources of truth |
| 8 | `AUDIT.md` category-3 sweep | where a promoted quirk now lands |

---

## Slots 4 and 5 — every accepted proposal

| # | File | Touch |
|---|---|---|
| 4 | `standards/STANDARDS.md` — Changelog | **one entry at the top**, in the house register: what changed, why, the evidence with citations, the bump classification in the standard's own words, and the pass it came from (*harvest 2026-08-25*) |
| 5 | `standards/STANDARDS.md` — front matter line 1 | `# Ka0s WoW Addon Standard (vX.Y.Z, 2026-08-25)` |
| 5 | `standards/NEW_ADDON_CONTEXT.md:1` | the pack's **own** version — `(v2.32.0, 2026-08-23)` today, and it is already a version behind v2.33.0 |
| 5 | `standards/EXECUTIVE_SUMMARY.md` | **n/a for a version stamp** — it carries no version of its own, only a link to `STANDARDS.md` (`EXECUTIVE_SUMMARY.md:3`). It still ripples on **content** wherever a proposal changes a fact it states |

**The pack is already stale at v2.32.0 against a v2.33.0 standard.** Whatever lands here, that
pointer is either brought current or deliberately left — and if left, `06_OUTCOME.md` says so, so
the next run does not read it as this run's omission.
