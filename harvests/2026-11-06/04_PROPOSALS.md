# Harvest 2026-11-06 — 04 Proposals

Eight proposals cleared the three filters (`02_FINDINGS.md`). Each names its target, the change, the evidence
count, the bump class and the rollout debt it would create. P-04 and P-06 are **ambiguous signals**: both
readings are stated with their counts and the choice is the owner's.

---

## P-01 — library-stack-§7 describes what `LibKa0s v1.89.0` ships, and a check stops the recount drifting a fifth time

**Target.** `library-stack` (§7, the module table, *The modules*, *Inter-module dependencies*), the index blurb,
`EXECUTIVE_SUMMARY.md`, `open-evolutions` (the twenty-major counts and the `W.ContextMenu` entry),
`scripts/check-standard.sh`, `DEPENDENCIES.md`.

**Change.**
1. Recount to **twenty-one majors across sixty-seven files**, everywhere the count is stated, and "twenty of the
   twenty-one floor on Core".
2. Add a module-table row for **`LibKa0s-IconBrowser-1.0`** (v1.86.0; `IconBrowserSources.lua`,
   `IconBrowserWindow.lua`, `IconBrowser.lua`), described from the library's `docs/api/`.
3. The Toast row: one payload at a time **by default**, with the opt-in stack from v1.88.0.
4. The Widgets row names `W.ContextMenu` (minor 21, cascading submenus from v1.87.0); the open-evolutions
   *A library context menu* entry is closed as shipped.
5. A new `libka0s-counts` check in `scripts/check-standard.sh`: when `../LibKa0s` is checked out, the major
   count and file count stated in library-stack-§7 must equal `tests/majors.lua`'s and `LibKa0s.xml`'s at the
   library's newest tag; when it is not, the check reports SKIP rather than pass.

**Evidence.** F8-01, F8-02, F8-03, F10-01. IconBrowser is consumed by QuickComms and Outfitter Reborn; the
library's own `docs/releasing.md` already states twenty-one and sixty-seven. Fourth recount drift of the same
paragraph (v2.76.1, v2.94.1 and the v1.78.0 Skin recount each fixed the last).

**Bump.** **Patch** — no rule changes; the description catches up with the library. An addon compliant before is
compliant after.

**Rollout debt.** None in addons. `/dev-copilot:wow-revendor-standards` carries nothing new into an addon for this.

---

## P-02 — events-frames-taint-§2: `InCombatLockdown()` is not yet true inside `PLAYER_REGEN_DISABLED`

**Target.** `events-frames-taint` §2, the *`InCombatLockdown()` vs `UnitAffectingCombat("player")`* passage.

**Change.** Correct "true from `PLAYER_REGEN_DISABLED` to `PLAYER_REGEN_ENABLED`" and "they fire exactly at the
lockdown boundary": `PLAYER_REGEN_DISABLED` fires **before** lockdown begins, so `InCombatLockdown()` reads
**false inside its handler**, and a handler that asks lockdown to decide what to draw at combat start draws the
out-of-combat state. A combat-start handler takes its answer from the event itself (or from
`UnitAffectingCombat("player")`, already true there) and passes it on explicitly. The MUST that gates secure
writes on `InCombatLockdown()` is unchanged: a secure write made inside the handler is still permitted by the
client, which is what the gap means.

**Evidence.** F3-02. AbsorbTracker measured it (`docs/midnight-quirks.md`, "`InCombatLockdown()` lags
`PLAYER_REGEN_DISABLED`"); PanelMaster `core/PanelMaster.lua` and `core/Compat.lua` pass `true` explicitly for
that reason; AuraMaster and Outfitter Reborn rely on the gap. Four repos against one sentence of the standard,
with a stated cost (a render at combat start drew the out-of-combat state).

**Bump.** **Patch** — an erratum; no addon's compliance changes.

**Rollout debt.** None; re-vendoring the standard's reference carries the corrected text.

---

## P-03 — packaging: `media/screenshots/` is ignored wherever it exists

**Target.** `packaging` — the template's ignore list and its MUST bullets.

**Change.** Add `media/screenshots` to the template as a conditional entry, binding exactly when the repo tracks
that folder, the same shape as `tools/`: README and store images are not addon payload.

**Evidence.** F5-08. 15 of 15 addons that track `media/screenshots/` already ignore it (measured 2026-11-06);
AuraMaster's audit (AM-40) punted the question as "the owner's call"; LootHistory's 27 tracked screenshots are
39 MB a missing line would ship to every player.

**Bump.** **Minor** — a new MUST an addon could fail; **zero repos are non-compliant on 2026-11-06**, and a new
addon adds the line when it adds its first screenshot.

**Rollout debt.** None today.

---

## P-04 — documentation-§6's citation and count forms reach an addon's own docs (AMBIGUOUS)

**Target.** `documentation` §5 and §6.

**The signal.** documentation-§5 drift appears in **17 of 18** newest audits, every repo at every audit date
(F4-01). In 12 repos the drifted items are hand-written counts of the repo's **own** tree, or in-repo `file:line`
citations. Four repos decline to withdraw a performance-§12 exemption whose `file:line` citations rotted while
the argument held (F6-01). documentation-§6 already says a cross-repo citation carries a symbol, never a bare line,
and a collection count is a rule or dated — but it binds only claims about **another** repo or the collection.

**Reading A — the collection is non-compliant.** §5 is right and clear; the 17 repos should keep their docs in
step, and `/dev-copilot:sync-docs` is the fix. No change to the standard.

**Reading B — the rule's shape produces the drift.** Extend §6's two forms to an addon's own docs: a present-tense
in-repo citation names `path` plus a symbol or heading, never a bare line; a count of the repo's own tree is a
rule ("every module under `modules/` …") or dated. History files and frozen bundles stay exempt. **Bump: minor**
— existing bare-line citations in every addon's docs become SHOULD deviations; the fix is mechanical and is what
`sync-docs` would do anyway.

**Evidence.** F4-01 (17 repos), F6-01 (4 repos), F7-01.

**Rollout debt (Reading B).** Every addon: `/dev-copilot:wow-revendor-standards`, then `/dev-copilot:sync-docs`
to convert in-repo bare-line citations; the next `/dev-copilot:wow-standards-audit` measures it.

---

## P-05 — A quirks catalogue section (third time asked)

**Target.** A new section, `client-quirks`, listed in `STANDARDS.md`'s Sections; `documentation-§3`'s Tier 2
`midnight-quirks.md` trigger; `events-frames-taint-§1`'s pointer to "the addon's quirks doc".

**Change.** A section that holds client behaviors **two or more repos discovered independently**, each entry
carrying: the behavior, the deepest write-up's source (`Repo path`, heading), the client build it was measured on,
the cost of not knowing it, and the workaround. Contested behaviors (`string.format` on a secret, the restriction
payload's second argument) are listed as **open probes**, not rules. An addon's `docs/midnight-quirks.md` then
holds only its own single-repo quirks and cites the section for the rest, rather than restating it.

**Evidence.** F3-01: 11 repos keep private catalogues (6 → 9 → 11 across three harvests); ~60% of ~133 entries
are 21 behaviors written up independently; 9 of the 21 are not in the standard at all; the standard itself sends
one quirk (unknown event names) to every addon's quirks doc, and it has 8 copies; three write-ups contradict the
standard (F3-02, F3-06, F3-08).

**The honest cost (from 2026-08-25's deferral).** A catalogue rots like any inventory; the build stamp per entry
is the expiry rule (Outfitter Reborn, DropWatcher, DpsRace and AuraMaster already keep "assumptions to confirm"
lists), and a re-measure is due when the client's build moves.

**Bump.** **Minor** — a new section; addons whose quirks docs restate a catalogued entry become SHOULD-deviant
(cite, do not restate), which a revendor-and-sync pass fixes.

**Rollout debt.** The 11 repos with a quirks doc: revendor-standards, then sync-docs to replace restated entries
with citations.

---

## P-06 — The `## Skins` hub section has no spill target (AMBIGUOUS)

**Target.** `documentation` §3 (the `ARCHITECTURE.md` hub, its ~400-line SHOULD and its spill MUST; Tier 2).

**The signal.** 14 of 17 hubs exceed ~400 lines; 14 carry a `## Skins` section of 70–197 lines added by the
2026-10-29 skinning rollout. It is not one of the ten mandated sections, so the spill MUST does not reach it, and
there is no Tier 2 doc for it to spill into (F4-03, F7-02).

**Reading A — give it a home.** A Tier 2 `docs/skins.md`, triggered when the addon's skin section passes a
stated size (or always, since every addon registers a skin owner), and the hub keeps a short summary plus the
link. **Bump: minor** — 14 hubs owe a spill.

**Reading B — the hubs are fine.** The SHOULD is advisory; the skin section is load-bearing reference material and
belongs in the hub. Record that, and leave the rule alone. **Bump: none.**

**Evidence.** F4-03 (14 repos, measured on 2026-11-06).

**Rollout debt (Reading A).** 14 addons: revendor-standards, then sync-docs to move the section.

---

## P-07 — Record what is library-first, owner-first or a vote, in open-evolutions

**Target.** `open-evolutions`.

**Change.** Add the new evidence to the existing entries it votes for, and add the new entries, each with its
citations and its re-check trigger:

- **Votes.** *Further `LibKa0s` modules* — the keyed combat-end queue (4 repos), the coalesced refresh (~6, with
  LootHistory's shipped freeze), `PlainString`/`PlainNumber` (4), the Name-Realm key (5, a correctness split),
  class color by classFile (7), testkit chat capture (14), `mock_menu.lua` (12), deep-equal/deep-copy, the slash
  `format` hook's color decode (2). *Whether an unlock anchor has to be the library's handle* — 14 copies of
  position save/restore over two field names. *A per-addon adoption command* — the 17 SkinSetup files.
  *Whether an adopted major needs a full library-absent stub* — 17 Schema stubs, PrettyChat F-008. *Gating a
  swatch on its feature's own switch* — QC-18, AM-03. *#55 picker-credit helper* — **trigger met** (QuickComms
  and Outfitter Reborn both `all`).
- **New: a pre-clear hook on `RenderTabbedSchema`'s tab switch** (library-first) — ConsumableMaster#41 and
  MultiMeters#53 decline adoption for the same missing hook; KickCD#23 for a neighboring one.
- **New: chat an addon sends on the player's behalf** (no rule yet) — DropWatcher's "(no rule yet)" row and
  issue #11; QuickComms.
- **New: a moved `LibKa0s` tag** (owner-first) — the v1.85.0 re-cut re-vendored into 14 repos under one string,
  two `-recut` bundles; the provenance line names no commit.
- **New: kit gates the audits keep asking for** (library-first) — toc-file-§5 load-bearing annotations (14
  repos, recurring after two rewrites), the library-absent Slash stub's help row (5 repos over time, 2 live),
  `.pkgmeta`'s `media/logos/` ignores, and "a re-vendor implies a bundle" in `vendor_sync.lua`.

**Evidence.** As cited per line; Parts B–E.

**Bump.** **Patch** — open-evolutions is non-binding.

**Rollout debt.** None in addons. The library-first lines are `LibKa0s` work for a later run.

---

## P-08 — documentation-§3 names the shape of `docs/superpowers/`

**Target.** `documentation` §3, where `docs/superpowers/` is named as an out-of-scope store.

**Change.** A **SHOULD** for new files: a design spec is `docs/superpowers/specs/<YYYY-MM-DD>-<topic>-design.md`,
a plan is `docs/superpowers/plans/<YYYY-MM-DD>-<topic>.md`, dated the day it is written; supporting research may
sit in `docs/superpowers/research/`. Existing files are history and are not renamed.

**Evidence.** F9-01: 16 of 17 repos use the store; 110 of 121 specs and 141 of 167 plans already conform;
Ka0sAddonsCommonTasks' `CLAUDE.md` already prescribes exactly these two paths for single-repo work.

**Bump.** **Minor** in form (a new SHOULD), with no repo non-compliant: the rule binds new files only.

**Rollout debt.** None.
