# Harvest 2026-08-25 — 04 Proposals

Seven proposals cleared the three filters. Two of them (**P-01**, **P-02**) are ambiguous signals
and are presented with **both readings and the counts**; this run does not pick, and the
recommendation attached to each is a recommendation, not a resolution.

---

## P-01 — Resolve the `layout-§1` ↔ `toc-file-§5` ordering contradiction

**Target:** `layout` (`layout.md:51`) and `toc-file` (`toc-file.md:106`).
**Evidence:** F-01 · 9 of 9 addons · two independently filed issues (`WowAddonStandards#1`, `#2`).
**Filter:** live at v2.33.0 — both lines unchanged.

Two MUSTs, no TOC can satisfy both, and `toc-file-§5` falsely claims to be "matching the load order
(layout-§1)". The contradiction has already been paid for twice: LootHistory's 2026-07-12 pass
conformed to `layout-§1` and its 2026-07-18 pass conformed to `toc-file-§5`, **trading one MUST
violation for the other** (`LootHistory/docs/audits/2026-07-18/02_DEVIATIONS.md:17-22`); PrettyChat
resolved it toward `toc-file-§5` and recorded a local deviation, which its own issue calls
"arbitrary".

### Reading A — the rule is wrong, and `layout-§1` is the wrong half

`toc-file-§5`'s order is what **9 of 9** addons ship, and eight of them independently give the same
reason for the disputed half ("Settings (last — depend on everything else being initialized)").
`layout-§1` would put `settings/*` before `modules/*`, which no addon does and none argues for.

**Change:** `layout-§1`'s load order becomes
`libs/*` → `locales/*` → `core/*` → `defaults/*` → `modules/*` → `settings/*`, and it cites
`toc-file-§5` as the section-header expression of the same order. `toc-file-§5`'s
"matching the load order (layout-§1)" clause becomes true rather than being deleted.

**Bump:** **minor** — a MUST changes. But it makes **zero addons non-compliant**: every one already
ships the winning order. This is the "satisfied by doing nothing" shape.

### Reading B — the collection is wrong

`layout-§1` is the older and more architectural statement, and nine TOCs converged on `toc-file-§5`
because that is the section that names the `#` headers an author is looking at while writing a TOC —
convergence by proximity, not by argument.

**Change:** `toc-file-§5` defers to `layout-§1`; Locales moves after Defaults, Settings before
Modules.

**Bump:** **minor**, and it makes **all nine addons non-compliant** in one stroke. Each needs a TOC
reordering, and moving `settings/*` above `modules/*` invalidates the load-bearing seam comments
that eight of the nine TOCs carry.

### Reading C — they are orthogonal

Section-header order and load order are different things; `toc-file-§5` drops the
"matching the load order" clause and says so.

**Bump:** **patch**. Cheapest, and it leaves two orders standing — which is the state that produced
two audits of one addon trading one violation for another.

**Recommendation: A.** The evidence is 9–0, the cost is zero, and B's cost is nine TOC rewrites
against the collection's own reasoning.

---

## P-02 — `layout-§1`'s `core/` prefix: failed by 9 of 9

**Target:** `layout` (`layout.md:51`, the same line as P-01).
**Evidence:** F-02 · 9 of 9 addons fail · CM-49 recurring across two audit dates · escalated upstream
by ConsumableMaster's own execution plan.
**Filter:** live.

The rule opens `core/Compat.lua` → `core/Constants.lua` → `core/Namespace.lua`. Not one addon does
this, and the TOCs say why in their own comments: `core/Namespace.lua` publishes `NS`, so files that
read it at file scope must follow it; and `core/Constants.lua` resolves `FONT_MONO` from
`NS.MediaFont` **at file load**, so the media seam must precede `Constants` in all nine.

### Reading A — the rule is wrong

A fixed three-file prefix cannot survive the seam files that `library-stack-§7` itself introduced
(`MediaSetup`, `EnvSetup`, `ItemSetup`, `PoolSetup`, `CoreSetup`, `PerfSetup` — none of which
existed when the prefix was written). The real constraint is **dependency-correct order with the
load-bearing positions declared**, which is what nine TOCs already implement (P-04).

**Change:** `layout-§1` replaces the literal prefix with the constraint — `core/` **MUST** load in
dependency-correct order; a file whose position is load-bearing **MUST** say so at its line
(P-04's rule) — and keeps `Compat → Constants → Namespace` as the *illustrative* shape for an addon
with no seam files.

**Bump:** **minor**; makes **zero** addons non-compliant, and closes CM-49 and every future
re-filing of it.

### Reading B — the collection is wrong

Nine addons drifted, and the prefix is a real architectural intent worth restoring: `Compat` first
so nothing calls a deprecated API before the shim exists, `Constants` before anything reads one.

**Change:** none to the rule; nine addons reorder `core/`.

**Bump:** **patch** (no rule change), and it makes **all nine addons non-compliant today** —
they already are, silently, which is the argument for reading B and also the argument against it: a
MUST that nine of nine repos have quietly failed for months is not enforcing anything.

**Recommendation: A**, taken together with P-04, which supplies the replacement constraint.

---

## P-03 — `library-stack-§7`: six majors is now ten

**Target:** `library-stack` (`library-stack.md:70`, the module table, and `:95`), plus
`open-evolutions`'s *Further LibKa0s modules* entry.
**Evidence:** F-03 · `LibKa0s/LibKa0s/LibKa0s.xml` (13 script files) · ten `local MAJOR` declarations
· consumer counts from all 9 addons.
**Filter:** live.

The standard says **"six LibStub majors across nine files"** and tables six. The library ships
**ten majors across thirteen files**. `LibKa0s-Env-1.0` — consumed by **every addon in the
collection** — is described nowhere in the standard. Three claims are stale together: the count, the
"**five of the six** majors need `LibKa0s-Core-1.0`" line, and `open-evolutions`'s list, which still
names *the object pool* as a candidate the collection duplicates months after
`LibKa0s-Pool-1.0` shipped and four addons adopted it.

**Change:** the count becomes **ten majors across thirteen files**, stated with its members as
`CLAUDE.md` requires; four rows are added to the module table (Env, Item, Pool, Widgets) with the
same one-line description shape as the existing six; the inter-module dependency count is recounted
against the library rather than asserted; the `open-evolutions` entry is corrected to say what has
shipped and drops the pool from the candidate list.

**Bump:** **patch** — descriptive catch-up, no rule changes. An addon compliant before is compliant
after. (Whole-folder vendoring already carries all thirteen files to every consumer, so nothing in
any repo changes.)

**Requires a `LibKa0s` change first?** No. The library leads and has already shipped; this is the
prose catching up, which is the direction `library-stack-§7` expects.

---

## P-04 — The load-bearing / conventional annotation, codified

**Target:** `toc-file` (a new subsection under §5, or an addition to it).
**Evidence:** F-05 · 9 of 9 addons · 19 annotated positions · the same case annotated in all nine.
**Filter:** live — neither word appears anywhere in `toc-file` or `layout`.

Every addon in the collection already annotates its TOC seam lines with whether the position is
**load-bearing** (something resolves at file scope, so moving the line breaks the addon silently) or
merely **conventional** (everything is reached through a closure at call time, so the line is free
to move). The vocabulary is identical across nine independently written files. The standard has
never mentioned it.

The reason it is worth a rule rather than a habit is the failure mode the comments themselves
describe: `LootHistory.toc:41-42` — *"publishes `NS.MediaFont`, which `core\Constants.lua` reads at
file load to resolve `FONT_MONO`. Below `Constants` and every consumer silently gets the client
font."* Nothing goes red. No test catches it. The comment is the only guard.

**Change:** `toc-file-§5` gains: a TOC line whose position is **load-bearing MUST** carry a comment
saying so and naming what resolves at load; a position that is merely **conventional SHOULD** say
that too, so the next author knows which lines are safe to move. Both terms are defined once, in
the section.

**Bump:** **minor** — a new MUST. In practice it makes **zero to two** addons non-compliant: all
nine already annotate, but KickCD, MultiMeters and PrettyChat use only "load-bearing" and never mark
a conventional position, which the SHOULD covers rather than the MUST. An audit would confirm.

---

## P-05 — `packaging`: name the agent-tooling directories, and give the check teeth

**Target:** `packaging` (the ignore-list MUST and the minimum template), plus a mechanical check in
`AUDIT.md`.
**Evidence:** F-07 · 5 addons would ship `.superpowers/` (54 files) to players · KickCD's `A-3`
filed identically on two consecutive audit dates · ConsumableMaster is the one repo that fixed it.
**Filter:** live.

`packaging`'s MUST enumerates `docs/`, `_dev/`, `tests/`, `.luacheckrc`, `.gitignore`,
`.gitattributes` — written before agent tooling existed in these repos. Six addons now carry
`.superpowers/`; one ignores it. The consequence is concrete and player-facing: a 54-file
development directory inside the packaged AddOn.

This is a **category-10** finding, and the tooling half matters more than the prose half. The rule
has existed in spirit since the section did — "dev-only; not shipped to players" — and it was still
missed five times, then re-filed unchanged, because nothing checks it. Prose alone would produce a
sixth filing.

**Change:** (a) `packaging`'s MUST and template name `.claude/` and `.superpowers/` explicitly,
with the reason stated once (agent tooling; dev-only; never loaded by the client); (b) `AUDIT.md`
gains a mechanical check — every root dotfile and dot-directory present in the repo must appear in
`.pkgmeta`'s ignore list or be justified — so the finding is produced by the run rather than by an
auditor happening to look.

**Bump:** **minor** — a MUST that names new entries. It makes **five addons non-compliant**
(AbsorbTracker, BankLedger, KickCD, LootHistory, MultiMeters), and each is fixed by adding two lines
to `.pkgmeta`. This is the "satisfied by deleting something" shape in reverse: nothing is deleted
from the repo, only from the package.

---

## P-06 — `toc-file`: what an unpublished addon does about `X-Curse-Project-ID`

**Target:** `toc-file-§2` (`toc-file.md:30`).
**Evidence:** F-06 · PanelMaster D-001/D-002, permanently blocked (`issues/22`, `/23`) · MultiMeters'
TOC comment with the stated cost.
**Filter:** live. Clears the bar as two repos **plus** a stated consequence.

The MUST is conditional — "once the addon is published on CurseForge" — but says nothing about the
state before that, so audits file the absence as a deviation and the deviation cannot be closed by
any act of the addon. PanelMaster carries two such rows. MultiMeters answered it in the TOC and
named the cost: *"a placeholder ID here would make the packager upload to somebody else's project."*

**Change:** `toc-file-§2` states the pre-publication position explicitly — an unpublished addon
**MUST NOT** carry a placeholder id (naming the reason), and **SHOULD** carry a one-line TOC comment
where the field would go, saying the addon is not published yet. With the comment present the
absence is **compliant** and needs no deviation-register row. This is the same shape `toc-file-§5`
already uses for a forced within-section order ("with that comment present the ordering is
compliant and needs no deviation-register row").

**Bump:** **minor** — a new MUST NOT and a new SHOULD. Makes **zero** addons non-compliant (no addon
carries a placeholder); it **closes two blocked deviation rows** in PanelMaster and prevents the
next one.

---

## P-07 — A quirks catalogue section

**Target:** a **new section file** and a new row in `STANDARDS.md`'s Sections list.
**Evidence:** F-08 · the same client behavior written up independently in 3 addons, at three
different depths.
**Filter:** live. The standard has no quirks catalogue; `AUDIT.md`'s category-3 sweep has nowhere to
land a promoted quirk.

Six addons keep a `docs/midnight-quirks.md`, and the collection has now demonstrably paid three
times for one behavior: `Settings.OpenToCategory` takes the integer category ID, and forcing the
parent category to render expanded needs a private `SettingsPanel:GetCategoryList():
GetCategoryEntry(cat):SetExpanded(true)` walk in a `pcall`. Three write-ups, three depths, and each
one holds a piece the others do not (`03_EVIDENCE.md` §C).

**Change:** a new section — the collection's catalogue of client behaviors discovered the hard way,
each entry naming the behavior, the failure it produces, the repo the deepest write-up came from,
and the workaround. Seeded with the two entries above, merged **deepest-first** rather than to their
common denominator: WhatGroup's enumeration of the wrong ID forms and the silent no-op,
ConsumableMaster's explanation of why the private walk exists and when to call it.

**Bump:** **minor** — a new section is a structural addition, but not a restructuring of the
standard (that would be major, and this is not one). It makes zero addons non-compliant on its own.

**The honest cost.** A quirks catalogue is a document that rots the way `docs/agent-context.md`
rotted: entries describing a client that has moved on, which agents then follow. Whatever is
decided, the section needs a stated expiry discipline — an entry names the client build it was
observed on, and an entry nobody can reproduce is deleted rather than hedged. **This proposal is the
one most reasonably deferred**, and deferring it costs one duplicated write-up per new addon rather
than anything shipping wrong.
