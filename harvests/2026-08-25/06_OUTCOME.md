# Harvest 2026-08-25 — 06 Outcome

Applied 2026-08-26. **Six of seven proposals accepted; P-07 deferred.** The standard moved
**v2.33.0 → v2.34.0** (minor: `layout-§1`, `toc-file-§1`, `toc-file-§5` and `packaging` each gained
or changed a MUST; `library-stack-§7`'s share was descriptive).

| Proposal | Decision | Bump |
|---|---|---|
| P-01 — the ordering contradiction | **Accepted, reading A** — `layout-§1` adopts the order 9 of 9 addons ship | minor |
| P-02 — the `core/` prefix | **Accepted, reading A** — the literal prefix becomes a constraint | minor |
| P-03 — ten majors across thirteen files | **Accepted** | patch (folded into the minor) |
| P-04 — the load-bearing annotation | **Accepted** | minor |
| P-05 — the agent-tooling directories | **Accepted**, prose **and** the mechanical check | minor |
| P-06 — the unpublished `X-Curse-Project-ID` | **Accepted** | minor |
| P-07 — a quirks catalogue section | **Deferred** | — |

## What was written

**P-01 + P-02 — landed as one edit to `layout.md`, as the ripple plan required.** The single
load-order MUST became two: a **folder** order (`libs/*` → `locales/*` → `core/*` → `defaults/*` →
`modules/*` → `settings/*`, stated as the same order `toc-file-§5`'s headers express, with the note
that a disagreement between the two is a defect in the document rather than a choice), and a
**within-`core/`** rule of dependency-correct order with every load-bearing position declared. The
old three-file prefix survives as the illustration for an addon with no seam files. `toc-file-§5`'s
"matching the load order (layout-§1)" clause is now true and was kept rather than deleted. The
`core/` block of the layout tree gained a `<Module>Setup.lua` line, since the seam files are the
reason the prefix could not hold.

**P-03 — `library-stack-§7`.** Count and members restated together per `CLAUDE.md`'s rule; four rows
added (Env, Pool, Item, Widgets), placed in `LibKa0s.xml` load order rather than appended. The
inter-module claim was **recounted against the library**, not adjusted: nine of the ten majors floor
on `Core` (every module except `Core`; `Env` and `Item` gate on it without calling a member), and
there is exactly one second edge — `DebugLog` also floors on `Widgets`. Two knock-on numbers fixed
in the same pass: *"four of the five majors refuse to register without Core"* in the whole-folder
bullet (also present in `NEW_ADDON_CONTEXT.md`), and `open-evolutions`'s *adoption spans five
majors*. The **object pool candidate** was struck and the retired **Object pool standard** bullet
struck through as shipped.

**P-04 — `toc-file-§5`.** Both terms defined once; the MUST (load-bearing lines name what resolves),
the SHOULD (conventional positions marked), and the third rule the annotation exists for — a move is
preceded by reading the comment. The section's illustrative TOC block was re-annotated in the
required form, including the `MediaSetup` case, so the block demonstrates the rule instead of
merely preceding it. New **anti-pattern #66**.

**P-05 — `packaging`.** `.claude/` and `.superpowers/` named in both the ignore MUST and the
template (they must not disagree, and now do not). The enumeration is explicitly labelled the weak
form; the strong form is the new `AUDIT.md` check, which lists the repo's actual root dot-entries and
reports any not accounted for in `.pkgmeta` — the enumeration cannot go stale that way, which was the
whole reason prose alone had failed five times.

**P-06 — `toc-file-§1`.** The MUST NOT (no placeholder / invented / borrowed id, with the reason
stated: the packager uploads into whatever project the number names) and the SHOULD (a one-line
comment in the field's position), plus the explicit statement that the absence then needs no
deviation-register row. New **anti-pattern #67**. The TOC template's field comment and both context-pack
checklist lines were updated; the context pack's template now ships the field **commented out** with
the reason, since a newly scaffolded addon is unpublished by definition.

## Ripple slots discharged

| Slot | Outcome |
|---|---|
| 1 section files | `layout.md`, `toc-file.md`, `library-stack.md`, `open-evolutions.md`, `packaging.md`, `anti-patterns.md` |
| 2 Sections blurbs | `layout`, `toc-file`, `library-stack`, `anti-patterns` (range) updated in `STANDARDS.md` |
| 3 anti-pattern range | **#1–#65 → #1–#67**; blurb and file agree |
| 4 changelog | one v2.34.0 entry, in the house register, citing the harvest pass |
| 5 version bump | `STANDARDS.md` → v2.34.0 / 2026-08-26; `NEW_ADDON_CONTEXT.md` → v2.34.0 (it was two versions behind — **brought current**, not left) |
| 6 context pack | starter tree, TOC template, `.pkgmeta` block, `.gitattributes` prose, both checklists |
| 7 executive summary | the LibKa0s count + member list, and item 2's layout line, which did state an order |
| 8 playbooks | `AUDIT.md` — three new checks (packaging dot-entries, TOC annotations, unpublished id). `NEW_ADDON.md` — step 3's load order, and three setup files (`EnvSetup`, `PoolSetup`, `ItemSetup`) that were absent from a list consumed by 9 / 4 / 3 addons |
| 9 `ADDONS.md` | **n/a** — roster unchanged, as predicted |

## Not done, deliberately

- **P-07, the quirks catalogue.** Deferred on its own argument: it rots the way `docs/agent-context.md`
  rotted, and it needs a stated expiry discipline — an entry naming the client build it was observed
  on, and an unreproducible entry deleted rather than hedged — before it earns a section. Cost of
  deferring: one duplicated write-up per new addon. `AUDIT.md`'s category-3 sweep still has nowhere to
  land a promoted quirk; that remains open.
- **Rollout debt is not this repo's to write.** Five addons (AbsorbTracker, BankLedger, KickCD,
  LootHistory, MultiMeters) are non-compliant against P-05 as of this commit, each fixed by two
  `.pkgmeta` lines. Under P-04's SHOULD, KickCD, MultiMeters and PrettyChat annotate only their
  load-bearing positions. P-01, P-02, P-03 and P-06 make **zero** addons non-compliant. None of that
  is changed from here — the addon repos are read-only to this one.
- **The two blocked deviation rows in PanelMaster** (`D-001`, `D-002`) are now closable under
  `toc-file-§1`, but closing them is that repo's next audit, not this change.
