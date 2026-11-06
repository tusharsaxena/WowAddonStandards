# Harvest 2026-11-06 — 06 Outcome

Eight proposals went to the owner on 2026-11-06. **Seven were accepted and one was declined.** The standard went
from **v2.101.0** to **v2.102.0 (2026-11-06)**, a **minor**: P-04 and P-05 can make a previously compliant
addon SHOULD-deviant, and P-03 and P-08 are new rules no addon fails today.

## The owner's decisions

| Proposal | Decision | Reading chosen |
|---|---|---|
| P-01 — library-stack-§7 recount, IconBrowser, Toast stack, `W.ContextMenu`, `libka0s-counts` check | **Accepted** | with the check |
| P-02 — events-frames-taint-§2, the combat-start edge | **Accepted** | — |
| P-03 — packaging, `media/screenshots/` | **Accepted** | — |
| P-04 — documentation-§5/§6, an addon's own citations and counts | **Accepted** | **Reading B**: the rule's shape produces the drift; extend §6's forms |
| P-05 — client-quirks catalogue | **Accepted** | — (third time proposed; deferred 2026-08-25 and noted 2026-09-22) |
| P-06 — the `## Skins` hub section | **Declined** | **Reading B**: the section is core reference material and stays in the hub; the ~400-line SHOULD is unchanged. The next harvest **MUST NOT** re-propose a spill target on the same evidence; new evidence (a hub nobody can navigate, an audit that cannot grade it) reopens it |
| P-07 — open-evolutions votes and new entries | **Accepted** | — |
| P-08 — the shape of `docs/superpowers/` | **Accepted** | — |

## The ripple, discharged item by item

Common to the release: `standards/STANDARDS.md` front matter → v2.102.0 (2026-11-06) **applied**; the v2.102.0
changelog entry written under `## Changelog` **applied**; the displaced v2.101.0 entry moved verbatim to the top of
`standards/CHANGELOG.md` **applied**; `EXECUTIVE_SUMMARY.md` current pointer **applied**; `NEW_ADDON_CONTEXT.md`
line 1 **applied**; `README.md` Status **applied**; `CLAUDE.md` "As of" line **applied**;
`bash scripts/check-standard.sh` → exit 0, eight checks, `libka0s-counts` ok against `LibKa0s v1.89.0`
**applied**.

**P-01.** library-stack-§7 *The modules* (21 / 67, `IconBrowser` in the list, the v1.86.0 recount and the
fourth-drift note) **applied**; module table: new IconBrowser row, Toast row (opt-in stack), Widgets row
(`W.ContextMenu`) **applied**; *Inter-module dependencies* (twenty of twenty-one; eleven of twenty; IconBrowser in
the reach-a-Core-member list) **applied**; `STANDARDS.md` blurb **applied**; `EXECUTIVE_SUMMARY.md` count and list
**applied**; open-evolutions counts (two) and the closed context-menu entry **applied**;
`scripts/check-standard.sh` check 8 **applied**, verified in a throwaway clone: `skip` with no sibling, `ok` clean,
`FAIL` naming both injected defects; `DEPENDENCIES.md` check list and verification step **applied**; the script's
description in `CLAUDE.md`, `README.md`, `standards/README.md` and `docs/ARCHITECTURE.md` **applied**.
`NEW_ADDON_CONTEXT.md` states no count — **not applicable**.

**P-02.** events-frames-taint-§2 **applied**. The index blurb does not state the timing — **not applicable**.
`NEW_ADDON_CONTEXT.md` does not state it (grep) — **not applicable**.

**P-03.** packaging template and MUST bullet **applied**; `STANDARDS.md` blurb **applied**;
`NEW_ADDON_CONTEXT.md` `.pkgmeta` template **applied**; `AUDIT.md` check (a) gains the conditional entry
**applied**.

**P-04.** documentation-§5 SHOULD bullet and §6 paragraph **applied**; `STANDARDS.md` blurb **applied**;
`NEW_ADDON_CONTEXT.md` item 20f **applied**; `EXECUTIVE_SUMMARY.md` bullet **applied**; `AUDIT.md` Tier 2 pass
(the count of in-repo bare-line citations and undated hand counts) **applied**.

**P-05.** `standards/standards/client-quirks.md` (new, numbered §1–§6, so it does **not** join `CLAUDE.md`'s
list of unnumbered section files) **applied**; `STANDARDS.md` Sections entry after `compat` **applied**;
documentation-§3 Tier 2 `midnight-quirks.md` row **applied**; events-frames-taint-§1 pointer **applied**;
`NEW_ADDON_CONTEXT.md` item 20g **applied**; `EXECUTIVE_SUMMARY.md` bullet **applied**; `AUDIT.md` Tier 2 pass
(restated or contradicting quirks entries) **applied**; `docs/ARCHITECTURE.md`'s section-file count (29 → 30,
dated) **applied**.

**P-06.** Declined — no touch.

**P-07.** open-evolutions: votes on *Further `LibKa0s` modules*, *A per-addon adoption command*, *Whether an
unlock anchor has to be the library's handle*, *Whether an adopted major needs a full library-absent stub*,
*Gating a swatch on its feature's own switch*, *#55 picker-credit helper* (trigger met) **applied**; new entries
— `RenderTabbedSchema` pre-clear hook, chat on the player's behalf, a moved `LibKa0s` tag, kit gates — **applied**.

**P-08.** documentation-§3 *The shape of `docs/superpowers/`* **applied**. `NEW_ADDON_CONTEXT.md` does not
describe the store — **not applicable**.

## Rollout debt

No accepted proposal needs a `LibKa0s` change first. Every addon needs
`/dev-copilot:wow-revendor-standards` to carry the v2.102.0 reference.

| Proposal | Repos it makes non-compliant (2026-11-06) | What each needs |
|---|---|---|
| P-04 | Every addon with a present-tense in-repo `path:line` citation or an undated hand count in a live doc — documentation-§5 drift of this shape was reported in AbsorbTracker, LootHistory, KickCD, DropWatcher, OutfitterReborn, QuickComms, ConsumableMaster and five more (`03_EVIDENCE.md`, Part B, 4-A); treat all seventeen as owing a sweep | `/dev-copilot:sync-docs` to convert; the next `/dev-copilot:wow-standards-audit` measures it |
| P-05 | The eleven addons with `docs/midnight-quirks.md` — AbsorbTracker, AuraMaster, BankLedger, ConsumableMaster, DropWatcher, KickCD, LootHistory, MultiMeters, OutfitterReborn, PartyFrameEnhanced, WhatGroup — wherever an entry restates a catalogued behavior | `/dev-copilot:sync-docs` to replace restated entries with citations |
| P-03 | none | — |
| P-08 | none (new files only) | — |
| P-01, P-02, P-07 | none | — |

**Per-repo audit debt found by this harvest** (not standard changes; for each repo's next audit):

- OutfitterReborn: `docs/midnight-quirks.md` and `core/Secrets.lua` say `..` on a secret raises, against
  events-frames-taint-§8 and four repos (F3-10); its smoke check O11 (`SetAllPoints` on secure rows) is owed
  (F3-11).
- DropWatcher and PremadeGroupsFilterExtension: the library-absent Slash stub copies the em-dash help row
  slash-commands-§1 forbids, `settings/Slash.lua` (F4-04).
- LibKa0sSkinTester and Outfitter: no `state:` labels — never swept by `/dev-copilot:issue-audit` (F6-07).
- DpsRace and LibKa0sSkinTester: never audited, never reviewed.
- Fourteen addons are on kit revision 50 and miss revision 51's flake fix until their next
  `/dev-copilot:wow-revendor-libka0s`.
- Thirteen repos were last audited against v2.76.1; twenty-six releases are unmeasured there.

## Correction made during the run, before the release left the branch

P-05 as proposed and first applied told an addon to **cite** a catalogued behavior rather than restate it.
Reading `/dev-copilot:wow-revendor-standards` (installed plugin 2.7.0, its Step 3d) before the first re-vendor
showed that the collection's own tooling already defines the other shape: when the standard has a quirks
catalogue, the command **vendors it whole** into `docs/midnight-quirks.md` between stamped markers, replaces it
wholesale, prunes the addon's own duplicates, and creates the file where it is missing. A standard that said
"cite" beside a command that copies would have contradicted itself on the first run. The release was corrected
on the branch, before any addon read it: client-quirks-§1 now states the vendored-block contract,
documentation-§3's Tier 2 row for `docs/midnight-quirks.md` is **required in every addon** (six addons owe the
file: DpsRace, LibKa0sSkinTester, PanelMaster, PremadeGroupsFilterExtension, PrettyChat, QuickComms), and the
`AUDIT.md`, `NEW_ADDON_CONTEXT.md`, `EXECUTIVE_SUMMARY.md`, `STANDARDS.md` blurb, changelog entry and
`CLAUDE.md` doc-set paragraph say the same. The fix in every addon is the re-vendor itself. P-05's rollout row
above reads accordingly: `/dev-copilot:wow-revendor-standards` writes the block and prunes duplicates; sync-docs
is not needed for it.
