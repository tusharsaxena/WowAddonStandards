# Harvest 2026-09-22 — 01 Collection state

**Harvesting into:** Ka0s WoW Addon Standard **v2.62.1 (2026-09-22)** — `WowAddonStandards/standards/STANDARDS.md:1`.
**Previous harvest:** `WowAddonStandards/harvests/2026-08-25/`, which harvested into **v2.33.0 (2026-08-25)** (`harvests/2026-08-25/01_COLLECTION_STATE.md:3`). **Twenty-nine minor versions** of the standard have landed between the two runs, so the date filter does real work again this run.

All repos were read from the working tree at `/mnt/d/Profile/Users/Tushar/Documents/GIT/`. Every repo in the collection is on branch `suite/2026-09-22-standards-sweep` and was left untouched.

---

## Repos read

| Repo | Kind | Version | Last audit | Standard that audit measured against | Last review | Newest automated-test stamp | Green? |
|---|---|---|---|---|---|---|---|
| AbsorbTracker | addon | 1.10.0 (`AbsorbTracker/AbsorbTracker.toc:5`) | 2026-09-08 | v2.39.0 (2026-09-07) (`AbsorbTracker/docs/audits/2026-09-08/01_CURRENT_STATE.md:4`) | 2026-09-07 | `20260916-184524` | green (`…/ANALYSIS.md:4`) |
| AuraMaster | addon | 0.1.0 (`AuraMaster/AuraMaster.toc:5`) | 2026-09-11 | v2.42.0 (2026-09-10) (`AuraMaster/docs/audits/2026-09-11/01_CURRENT_STATE.md:7`) | 2026-09-11 | `20260916-184324` | green (`…/ANALYSIS.md:4`) |
| BankLedger | addon | 1.1.0 (`BankLedger/BankLedger.toc:5`) | 2026-09-08 | v2.39.0 (`BankLedger/docs/audits/2026-09-08/01_CURRENT_STATE.md:3`) | 2026-09-07 | `20260916-184426` | green |
| ConsumableMaster | addon | 1.6.2 (`ConsumableMaster/ConsumableMaster.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:5`) | 2026-09-07 | `20260916-184427` | green |
| KickCD | addon | 1.3.0 (`KickCD/KickCD.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:4`) | 2026-09-07 | `20260916-184417` | green |
| LootHistory | addon | 1.3.0 (`LootHistory/LootHistory.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:5`) | 2026-09-07 | `20260916-184506` | green |
| MultiMeters | addon | 1.0.0 (`MultiMeters/MultiMeters.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:3`) | 2026-09-07 | `20260916-184449` | green |
| PanelMaster | addon | 1.1.1 (`PanelMaster/PanelMaster.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:3`) | 2026-09-07 | `20260916-184500` | green |
| PartyFrameEnhanced | addon | 1.0.1 (`PartyFrameEnhanced/PartyFrameEnhanced.toc:5`) | 2026-09-15 | v2.44.0 (2026-09-12) (`PartyFrameEnhanced/docs/audits/2026-09-15/01_CURRENT_STATE.md:6`) | **never** | `20260918-121606` | green |
| PrettyChat | addon | 1.5.0 (`PrettyChat/PrettyChat.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:4`) | 2026-09-07 | `20260916-184747` | green |
| WhatGroup | addon | 1.4.0 (`WhatGroup/WhatGroup.toc:5`) | 2026-09-08 | v2.39.0 (`…/audits/2026-09-08/01_CURRENT_STATE.md:3`) | 2026-09-07 | `20260916-184548` | green |
| LibKa0s | library | **v1.54.2** (newest tag) | 2026-09-08 | v2.39.0 (`LibKa0s/docs/audits/2026-09-08/01_CURRENT_STATE.md:3`) | 2026-09-07 | `20260922-202214` | green (`…/ANALYSIS.md:4`) |
| WowAddonStandards | docs/tooling (self) | v2.62.1 (2026-09-22) (`standards/STANDARDS.md:1`) | **never** | — | **never** | *(no `docs/automated-tests/`)* | — |
| wow-addon | docs/tooling | 2.3.0 (`wow-addon/.claude-plugin/plugin.json`, `"version": "2.3.0"`) | **never** | — | **never** | *(none)* | — |

Every addon's vendored library provenance line reads **LibKa0s v1.54.2** in root `CLAUDE.md` (all eleven), matching LibKa0s' newest tag. The collection is fully re-vendored as of this run's start, so no "N repos are behind" caveat applies to library-derived counts.

**Age of the audit corpus.** Nine of the twelve audited repos were last measured against **v2.39.0 (2026-09-07)**; AuraMaster against **v2.42.0**, PartyFrameEnhanced against **v2.44.0**. Nothing in the corpus has been measured against anything newer than v2.44.0, and the standard is now at **v2.62.1** — an eighteen-minor gap at best and twenty-three at worst. Any deviation cluster drawn from these bundles must be re-checked against the current section text before it is proposed, because a rule that changed after the bundle was frozen will show as a false cluster.

**No addon stamps a standard version.** Every `## X-Standard` line is the bare repository URL (e.g. `AuraMaster/AuraMaster.toc:12`, `KickCD/KickCD.toc:12`, `PartyFrameEnhanced/PartyFrameEnhanced.toc:12`), so the only machine-readable record of *which* standard a repo was measured against is the audit bundle's own prose — which is why the column above is read, not inferred.

---

## Roster drift

**Rostered (`WowAddonStandards/standards/ADDONS.md`):** 11 addons, 1 library (LibKa0s), 2 documentation-and-tooling repos (WowAddonStandards, wow-addon). Total 14.

**On disk** (a sibling directory with a root `.toc` is an addon; LibKa0s identifies itself): AbsorbTracker, AuraMaster, BankLedger, ConsumableMaster, KickCD, LootHistory, MultiMeters, PanelMaster, PartyFrameEnhanced, PrettyChat, WhatGroup — plus `Outfitter/Outfitter.toc`.

**Reconciliation:**

- **Rostered but absent from this machine: none.** All 11 rostered addons, LibKa0s and both tooling repos were read from the working tree. Every "N repos do X" count in this run is therefore measured against the full collection the standard believes it has — there is no shrinkage caveat this run, unlike the risk the playbook warns of.
- **On disk but unrostered: one, and it is correctly unrostered.** `Outfitter/Outfitter.toc` is a third-party fork, explicitly out of scope for this run. It is not a Ka0s addon and its learnings are not the collection's to harvest.
- **The previous run's drift has closed.** `harvests/2026-08-25/01_COLLECTION_STATE.md:33-46` reported two Tushar-authored addons on disk and unrostered — `BuffTextNotifications` and `WhoGotLoots` — whose learnings "have never been harvested by anything." Neither directory exists on disk today. That is the one drift item this run inherits and can mark resolved: the collection is now 11 rostered addons and 11 addons on disk, where the previous run was 9 rostered against 11 on disk.
- Also present on disk and correctly out of scope: `Ka0sAddonsCommonTasks` (deliberately outside the rotation per `ADDONS.md`, "Not in the rotation"), `dev-copilot`, `#Worktrees`, and seven non-WoW repos (`cultchampionssportsclub`, `ed-blackbox`, `steamdb`, `weakaura_sounds`, `wow_screenshot_organizer`, `wow_wtf_cleaner`, plus loose files). None carries a root `.toc`.

**What the closed drift means for this run:** AuraMaster and PartyFrameEnhanced are on the roster now but were **not** in the 2026-08-25 sweep (that bundle's table lists nine addons; neither appears). Their entire history is therefore **unharvested** — every quirk, deviation and `state:will-not-do` refusal in those two repos is being read for the first time by this run, and a finding that appears in one of them plus one previously-harvested repo is a *new* two-repo vote, not a re-count.

---

## Never audited, never reviewed

| Repo | Never audited | Never reviewed |
|---|---|---|
| PartyFrameEnhanced | — (audited 2026-09-15) | **yes** — `PartyFrameEnhanced/docs/reviews/` does not exist |
| WowAddonStandards | **yes** | **yes** |
| wow-addon | **yes** | **yes** |

Every other repo has both. Note the shape of the gap: **both documentation-and-tooling repos have never been audited or reviewed**, despite `ADDONS.md` placing them in scope against `documentation-§8`'s applicability lists. The standard's own repo is the one repo in the rotation that has never been measured against the standard. For this harvest that means the tooling half of the collection contributes **working-tree evidence only** — there is no deviation corpus for it, so a defect in the standard that only shows up when a tooling repo is audited cannot surface here.

PartyFrameEnhanced contributes one audit bundle (v2.44.0) and no review bundle, so any count of the form "N of 12 review bundles show X" rests on **eleven** review bundles (ten addons + LibKa0s), while audit-derived counts rest on **twelve** bundles.

---

## Prior watch list — verbatim, and why it matters here

The previous harvest left a watch list at `harvests/2026-08-25/02_FINDINGS.md:264-283`, under "Below the bar — watch list for the next run", prefaced "Each needs one more repo, or a stated cost, to be promotable." Its items, verbatim:

1. **`.pkgmeta` should ignore itself.** "ConsumableMaster is the only repo listing `.pkgmeta` in its own ignore block (`ConsumableMaster/.pkgmeta`); the standard's template does not. One repo, no stated cost."
2. **`media/screenshots` ignored.** "Same file, same single repo."
3. **KickCD's `DurationObject` probe** (`KickCD/docs/midnight-quirks.md:53-93`) — "the finding that *every* `DurationObject` getter is secret in combat. Deepest client research in the corpus and currently paid for by one repo."
4. **A parent Settings category with subcategories hides its own panel widgets** (`WhatGroup/docs/midnight-quirks.md:18-32`). "One repo. `options-ui-§...` already mandates the thin landing page, so the *behavior* is enforced; only the *reason* is undocumented."
5. **The collapsed-group key `mode .. "\001" .. rawValue`** — "already in `open-evolutions.md` as its own entry, still at two addons. **Vote unchanged**, no third addon found this run."
6. **A shared `.luacheckrc` base** — "`open-evolutions.md`'s *Shared luacheckrc base* entry. This run adds evidence: all **ten** repos (nine addons + LibKa0s) carry a `.luacheckrc` and **all ten** differ (ten distinct md5s). **Recorded as a strengthened vote**, not a new item… the entry's own blocker (it wants a symlink, and the repos are not a monorepo) is untouched by this evidence."

**These six are the run's promotion shortlist, not rediscovery targets.** Each already has one repo's evidence banked and an argued cost; a second repo evidencing any of them promotes it this run rather than re-opening it from scratch. Items 5 and 6 additionally live in `open-evolutions.md` and are therefore dedup keys — evidence found for them is recorded as a strengthened vote on the existing entry, never filed as a new proposal.

Items 1, 2, 3 and 4 each sat at **one repo out of nine** in August. The collection is now **eleven addons**, and two of those eleven (AuraMaster, PartyFrameEnhanced) have never been swept for any of them — so the denominator moved and two genuinely unread repos are exactly where a second vote could come from.

---

## What was NOT read — coverage notes, per category sweep

This section exists because a silent gap reads as a clean sweep. Each of the ten category sweeps stated,
in its own words, what it did not open; those statements are reproduced here unedited. Where a count
below rests on a sweep that did not read the issue store, or did not read the frozen bundles, the count
is bounded by that gap and not by the collection.

Two gaps are collection-wide and worth naming once before the per-sweep notes: **nine of the ten
category sweeps did not call `gh`** (category 6 owns the issue store, and category 7 read two stores
only), so any finding outside category 6 is unaware of whether the rule it names has already been
refused in a `state:will-not-do` issue; and **no sweep read the two documentation-and-tooling repos'
audit corpus, because neither repo has one** — so a defect in the standard that only an audit of the
standards repo would find could not surface in this run at all.

### 1 — Convergent patterns

> Read-only throughout; nothing written outside /tmp/claude-1000/ka0s-harvest/cat1-convergent/ (and in the end no scratch file was needed). Sweep covered every addon's core/, modules/, settings/, defaults/, locales/, tests/, docs/ trees plus .luacheckrc, and the standard's full Sections list including open-evolutions.md for dedup.
>
> Gaps, stated honestly:
> - I did NOT read LibKa0s' own payload for this category (category 8 owns library↔standard drift) beyond confirming that vendored libs/ and tests/_kit/ are carve-outs from every count below. Every "N repos" count here is over addon-authored files only.
> - I did NOT run gh — this category's evidence is entirely file-level, so no issue-store read was required. Category 6's agent owns that channel. If gh is unauthenticated in this environment, none of my findings depend on it.
> - I did NOT read the frozen docs/audits/ or docs/reviews/ bundles in depth (category 4 owns them); the one exception is that layout.md quotes MultiMeters' and ConsumableMaster's 2026-09-07 bundles, which I read only as quoted inside the standard.
> - Counts of the "self-naming file header" convention (C3-F08) were produced by a mechanical head -6 grep for the file's own basename; it will slightly undercount a header that spells the path differently and slightly overcount a file whose first lines happen to mention a sibling of the same name. I report the mechanical number and name the near-100%/near-0% split rather than a single threshold.
> - PartyFrameEnhanced is the youngest repo and is the sole absentee on three separate conventions (docs/revendor/, tests/test_lintconfig.lua). That is one repo, not three independent counter-examples, and I have said so in each rollout-debt cell rather than letting it read as broad dissent.

### 2 — Divergent patterns

> All 11 addons + LibKa0s read on disk; the standard read from the WowAddonStandards working tree (v2.62.1, 2026-09-22), every section discovered from the Sections list, and open-evolutions.md read as the dedup key. Read-only throughout; nothing written outside /tmp/claude-1000/ka0s-harvest/cat2-divergent/.
>
> Gaps, stated honestly:
> - I did NOT sweep GitHub issues. `gh auth status` reports logged in as tusharsaxena, so it was available, but issue harvesting is category 6's slice and I stayed in mine. Any finding here that a repo has already argued against in a `state:will-not-do` issue is therefore unknown to me.
> - I did NOT read docs/audits/<date>/ or docs/reviews/<date>/ bundles (category 4's slice). Evidence here is source-tree only, so a divergence a bundle has already explained as a ratified deviation may be re-reported by me. C2-F05 and C2-F08 are the two most likely to have such a row.
> - Outfitter and Ka0sAddonsCommonTasks excluded per scope. wow-addon was read only for the playbook.
> - I did not run the test harness or luacheck; nothing here needed a run.
> - Line counts and copy counts are from grep/wc over the working tree on branch suite/2026-09-22-standards-sweep as of 2026-09-22; they are not measured against a tag.
> - Depth of the Compat union (C2-F01) is measured by function inventory and by reading the overlapping shims, not by reading all 2820 lines; the addon-specific shims (C_DamageMeter, guild bank, aura container) I inventoried but did not diff, because nothing duplicates them.

### 3 — Midnight quirks

> Read all nine `docs/midnight-quirks.md` files in full (AbsorbTracker 120L, AuraMaster 433L, BankLedger 128L, ConsumableMaster 114L, KickCD 128L, LootHistory 68L, MultiMeters 114L, PartyFrameEnhanced 123L, WhatGroup 192L), every non-vendored `core/Compat.lua` (ten repos have one; AbsorbTracker and PrettyChat do not), and grepped all eleven addons + LibKa0s for the quirk seams (`issecretvalue`, `IsSafeKey`, `SetAlphaFromBoolean`, `EvaluateColorValueFromBoolean`, `GetSpellCooldownDuration`, `IsEventValid`, `ADDON_RESTRICTION_STATE_CHANGED`, `OpenToCategory`, `SetExpanded`). Resolved the standard from the working tree at v2.62.1 and walked every section file from the Sections list.
>
> Gaps, stated honestly: (1) **PanelMaster and PrettyChat ship no `docs/midnight-quirks.md`**, so two of eleven addons contributed only code comments and tests to this sweep — PanelMaster in particular carries `core/Compat.lua` and a test that asserts the unknown-event raise (`PanelMaster/tests/test_harness.lua:115-123`), which is a documented client behaviour with no write-up; whether that fires `documentation-§3`'s Tier 2 trigger is category 4/9's call, not mine, but it means my repo counts below understate by up to two. (2) **I did not read the GitHub issue stores.** `gh` is authenticated (account `tusharsaxena`), but category 6 owns the issue sweep and the playbook told me to stay inside my category; a quirk recorded only as an issue and never as prose would be missed here. (3) I did not read `docs/audits/` or `docs/reviews/` bundles — category 4's slice. (4) Read-only throughout: nothing written to any repo, no commits, no branches.
>
> **One cross-repo disagreement I could not resolve from the trees and did not average away** (see C3-F06): MultiMeters reads `ADDON_RESTRICTION_STATE_CHANGED` as `(type, state)` with a three-valued state enum whose `Activating` arm still permits access (`MultiMeters/core/Secrets.lua:43-44,94`), while AuraMaster's in-game probe records it as `(type, active)` with a boolean second argument (`AuraMaster/docs/midnight-quirks.md:44-48`). These are probably the same signature described at different resolutions, but I have no in-game capture of my own to decide, so both readings go upstream with their citations rather than one.

### 4 — The audit and review corpus

> WHAT I READ. Every `docs/audits/<date>/02_DEVIATIONS.md` (52 bundles) and every `docs/reviews/<date>/01_FINDINGS.md` (38 bundles, excluding Outfitter's 2026-09-16 which is out of scope) across the collection. Extraction scratch is under /tmp/claude-1000/ka0s-harvest/cat4-audit-corpus/ (entries.txt, latest_entries.txt, latest_reviews.txt, recur.txt) — my own directory, nothing written to any repo.
>
> THE DATE FILTER IS DOING HEAVY LIFTING THIS RUN. Ten of twelve measured repos were last audited against v2.39.0; the working tree is v2.62.1. That is 23 minor versions of drift, including v2.45.0 (README logo forbidden), v2.46.0–v2.49.0 (test mode), v2.50.0/§56–58 (slash surface, enable/disable), v2.51.0 (documentation-§8, the third repo kind), v2.52.0/§54 (launcher), v2.55.0, v2.59.0 (testing-§15 bounded runs), v2.60.0 (combat-locked settings page), v2.61.0 and v2.62.0/.1 (localization-§5). Every "N repos fail X" count below is therefore a count against a standard nobody has re-measured; I have resolved each finding against today's text and marked the settled ones rather than re-proposing them.
>
> WHAT I COULD NOT READ / DELIBERATELY DID NOT. (1) I did not call `gh` at all — category 6 (the `state:will-not-do` issue store) is a sibling agent's slice, and this category is the on-disk bundles. The audit bundles do quote issue URLs and I carried those quotes, not fresh queries. (2) WowAddonStandards and wow-addon have no `docs/audits/` or `docs/reviews/` directories at all — that is the absence reported as C4-F07, not a read failure. (3) Bundle formats differ enough that my mechanical extractor missed the deviation rows in PanelMaster/docs/audits/2026-07-30/ (prose-only "Open items" shape); I read that bundle by hand and it contributes nothing this run beyond its date. (4) I did not run the test harness or luacheck anywhere; no bounded-runner invocation was needed. (5) Read-only was maintained: no byte written outside my scratch directory.

### 5 — Standard-internal contradictions

> Read the standard from the working tree at v2.62.1 (2026-09-22) and followed the Sections list to all 27 section files plus open-evolutions.md. Swept every `docs/audits/<date>/` and `docs/reviews/<date>/` bundle in all 11 addons plus LibKa0s with a tension/contradiction/punt-to-user grep; read the hits in place. WowAddonStandards and wow-addon carry no docs/audits/ or docs/reviews/ directories at all, so the two documentation-and-tooling repos contributed only their own text, not audit evidence — documentation-§8 exists precisely because that repo kind was never audited, and this run could not change that.
>
> I did NOT run `gh` for this category: category 5's evidence is the standard's text plus the frozen bundles, and no finding here rests on an issue. So the issue store is unswept by me — sibling agents on categories 6 and 7 own it. Treat any claim about `state:will-not-do` refusals as outside my coverage.
>
> Mechanical checks run and PASSED (recorded so the next harvest does not redo them): every `filename-§N` cross-reference in STANDARDS.md and all section files resolves to an existing file and an in-range subsection number (zero unresolvable); anti-patterns.md holds exactly 88 entries numbered 1..88 with no gaps or duplicates, and the Sections-list blurb's `#1–#88` agrees; library-stack-§7's and documentation-§8's three applicability lists each do classify all 27 sections.
>
> Date-filter casualties — real contradictions in the corpus that TODAY's standard has already closed, listed so they are not re-proposed: the `toc-file-§5` ↔ `layout-§1` load-order conflict (LootHistory LH-13, ConsumableMaster CM-49) is settled — both now state `Libraries → Locales → Core → Defaults → Modules → Settings` and toc-file-§5 explicitly demotes the within-`core/` sequence to non-normative; `library-stack-§1`'s mandatory table vs §3's prune rule (PrettyChat PC-52) is settled by §1's "mandatory when used" preamble; `standalone-windows`' MAY/MUST close-button collision (BankLedger BL-28) is settled by the four-condition reasoned-decline bullet; `options-ui-§16`'s composer grep vs the broadcast meta row (MultiMeters MM-A-12) is settled by the named exemption at options-ui.md:384; `options-ui-§1`'s load-completing-stub vs no-host-copy collision (KickCD KICKCD-A-10) is settled by the hollow-composer ruling at options-ui.md:53; `launcher-§5`'s self-declared contradiction (compose minor 6 had no minimap seam) is settled — `LibKa0s/LibKa0s/OptionsCompose.lua:510-517` ships `minimapPath`.
>
> Deduped against open-evolutions.md and NOT re-filed: the `performance-§12` re-check-trigger asymmetry (combat qualifies only the event-handler arm) is already recorded there as an unresolved ruling, and WhatGroup's 2026-08-06 case is already cited in it.
>
> One candidate left below the bar and put on the watch list rather than filed: documentation-§8 lists `lint`, `testing`, `automated-tests` and `documentation-§3` in BOTH its *Does not apply* and its *Applies, read here* lists, while the same section claims the three lists "classify every section" and "an audit may check that mechanically". The prose reconciles it explicitly ("because there is no Lua today… a statement about the tree rather than a permanent grant"), so it is a mechanical-checkability defect rather than a rule collision, and it has exactly one instance (WowAddonStandards itself, unaudited). A second repo of that kind — wow-addon — growing a `.lua` would promote it.

### 6 — `state:will-not-do` issues

> gh CLI authenticated as tusharsaxena (repo scope); `gh issue list --label` used throughout, no GraphQL. Totals read: 81 `state:will-not-do` (closed) and 99 `state:triaged` (open) issues across the collection.
>
> Per-repo store census (state:done / will-not-do / triaged / untriaged, total): AbsorbTracker 12/7/11/0 (30); AuraMaster 4/2/5/4 (15); BankLedger 8/8/3/0 (19); ConsumableMaster 14/13/11/0 (38); KickCD 9/3/9/0 (21); LootHistory 21/6/4/0 (31); MultiMeters 36/5/9/1 (51); PanelMaster 20/9/21/0 (50); PartyFrameEnhanced 0/1/11/1 (13); PrettyChat 2/7/6/0 (15); WhatGroup 8/9/3/0 (20); LibKa0s 12/7/9/6 (34); WowAddonStandards 2/4/0/1 (7).
>
> **Gap 1 — wow-addon has NO issue store at all.** `gh issue list --repo tusharsaxena/wow-addon --state all --limit 200` returns zero issues and therefore zero `state:` labels. Per the playbook this repo has never been swept; it must not be read as "a repo with no refusals". It is the repo that holds the playbooks every other repo's sweep is driven by.
>
> **Gap 2 — no repo in the collection still carries `docs/pending/LEDGER.md`.** Checked all 14 working trees; none present. Ledger migration is complete, so no un-migrated rows went unharvested this run.
>
> **Gap 3 — severity is nearly flat.** 76 of 81 `will-not-do` issues are `severity:low`; the only exceptions are ConsumableMaster#26, PanelMaster#51 and WowAddonStandards#2 (medium) and MultiMeters#25/#16 (high, and those two are product defects rather than rule refusals). Under the playbook's own reading, that means every collective decline recorded below is "a rule/surface nobody thinks is worth its cost" rather than "a rule the collection thinks is actively wrong" — which matters for the fix direction: these want the surface made cheaper or the rule narrowed, not reversed.
>
> **Gap 4 — I read issue bodies, not the cited source.** Per the read-only rule I did not open addon source to re-verify each `repo:file:line` the issues quote; citations below are the issue URL plus the file:line the issue itself states. Where a claim needed checking against today's standard I read only the WowAddonStandards working tree.
>
> I did not stray into categories 1–5 or 7–10 except where a Category-6 refusal is itself the evidence (noted per finding).

### 7 — Rules nobody satisfies, and rules nobody needs

> Compliance counts here are derived from DIRECT mechanical checks of the working trees plus each repo's live `## Documented deviations` register, NOT primarily from the audit bundles — deliberately. Every audit bundle in the collection is stale against today's standard: the newest bundles are AbsorbTracker/BankLedger/ConsumableMaster/KickCD/LootHistory/MultiMeters/PanelMaster/PrettyChat/WhatGroup/LibKa0s at 2026-09-08 (measured against v2.39.0), AuraMaster at 2026-09-11 (v2.42.0) and PartyFrameEnhanced at 2026-09-15 (v2.44.0). The standard is now v2.62.1, so the corpus is 18–23 versions behind and its deviation lists cannot be read as current compliance. I used the bundles only for the "has this rule ever been cited" half (7b), where staleness does not matter.
>
> What I could NOT read:
> - WowAddonStandards and wow-addon have no `docs/audits/` or `docs/reviews/` at all, so neither contributes deviation evidence. They are in the collection and are counted as "not measurable" rather than as compliant.
> - PartyFrameEnhanced has never been reviewed (`docs/reviews/` does not exist) and has exactly one audit, so its register is thin by age rather than by compliance; treat its counts as under-reported.
> - `gh` IS authenticated (account `tusharsaxena`). I read the AuraMaster and LibKa0s issue stores because layout-§1's second terminal state is "an open issue". I did NOT sweep all 12 issue stores for `state:will-not-do` — that is category 6's slice, and a sibling agent has it. So where I say "no terminal state", I have verified no register row and (for AuraMaster and LibKa0s) no issue; for the other repos I verified the register row only.
> - CRLF/line-endings: every working tree shows CRLF because this is a Windows checkout under WSL with `.gitattributes` normalizing on commit; I spot-checked `git show HEAD:core/AbsorbTracker.lua` in AbsorbTracker and the committed blob is LF (0 CR). I did not verify the committed blobs across all 12 repos, so I filed nothing on line-endings.
> - I did not run the Lua harness or luacheck anywhere; nothing in this category needed them.
> - Read-only respected: zero bytes written outside /tmp/claude-1000/ka0s-harvest/cat7/.

### 8 — LibKa0s ↔ standard drift

> SECOND HALF OF THE CATEGORY IS CLEAN, AND THAT IS A RESULT, NOT A GAP. `diff -r` of LibKa0s/LibKa0s -> <addon>/libs/LibKa0s and LibKa0s/testkit -> <addon>/tests/_kit returned zero differences in all eleven addons, and the library's own self-vendor (testkit -> tests/_kit) is byte-identical too. All eleven root CLAUDE.md provenance lines read "Bundles LibKa0s v1.54.2 (MIT)". So there is no vendored drift anywhere in the collection today, no anti-pattern #45 instance, and therefore no "missing feature wearing a violation's clothes" to harvest from the drift direction. Every finding below is therefore from the first half: what the library ships versus what the prose claims.
>
> WHAT I COULD NOT READ. gh was not exercised at all for this category: category 8 is a code-and-prose comparison and the issue store belongs to categories 6 and 7, which sibling agents hold. I make no claim about what LibKa0s or any addon has filed as issues about these drifts — if one of these findings is already an open issue somewhere, I did not see it and did not dedup against it. I did dedup against standards/standards/open-evolutions.md: none of the findings below is recorded there, and that file's "A per-addon adoption command" entry independently says "adoption spans twelve majors", which corroborates that the "five majors" and "the ten" numbers in the section files are pure staleness rather than a different counting convention.
>
> MEASUREMENT METHOD, so the counts can be re-run. Majors and their files come from LibKa0s/tests/majors.lua (the repo's own single source, read by both tests/run.lua and tools/gen-api-members.lua) and LibKa0s/LibKa0s/LibKa0s.xml. Public member sets come from the newest docs/api/<Major>/members-<key>.json per major, which tests/test_versioning.lua regenerates and compares on every run, so they are gate-backed rather than read by eye. Core-dependency counts come from grep of `LibStub("LibKa0s-Core-1.0"` and of `core.<Member>` per file. I did not run the Lua harness or luacheck in any repo, so nothing here rests on a run I performed.
>
> ONE THING I DELIBERATELY DID NOT CHASE. LibKa0s-Options-1.0's public major surface is four members (LAYOUT, New, PatchAlwaysShowScrollbar, STRINGS) while options-ui's prose talks in terms of five widget makers and the flow engine, which are instance members rather than major members. Every addon's stub-parity case nonetheless asserts its host `Helpers` namespace against the string "LibKa0s-Options-1.0". That may be exactly right or may be a case asserting almost nothing, but deciding which needs the options-ui agent's reading of §1's load-completing stub rule, so I left it alone rather than half-claim it.

### 9 — Undocumented emergent conventions

> Read the standard from the working tree (v2.62.1, 2026-09-22): STANDARDS.md's Sections list, then documentation.md, testing.md, packaging.md, versioning-git.md, layout.md (index blurb) and open-evolutions.md in full or by targeted grep. Swept all 14 repos on disk for: docs/ file sets, docs/ frozen-store shapes, ARCHITECTURE.md Documentation-map tables (all four), root entries, .luacheckrc / .gitattributes shape, tools/ shape, tests/ file organisation and run.lua suite wiring, file-header comment convention across 249 authored core/ and modules/ files, and 200 commit subjects per repo.
>
> Gaps, stated honestly: (1) gh is authenticated (account tusharsaxena) but I made no issue calls — category 9 is a tree-shape sweep and the will-not-do / triaged store is category 6's slice, so if any of these conventions was already refused in an issue I would not have seen it; the sibling on category 6 should cross-check F01, F04 and F05 against the stores. (2) I did not read docs/audits/ or docs/reviews/ bundles; a convention already filed as a deviation there may be double-reported (category 4's slice). (3) .editorconfig exists in no repo in the collection, so there was nothing to compare. (4) WowAddonStandards and wow-addon were read for root shape and docs/ shape only — documentation-§8 gives them their own applicability lists and I did not re-audit them against the addon doc set. (5) I ran no Lua/luacheck; every claim is from file contents and git history. (6) Wrote nothing outside this report; no scratch files created.

### 10 — Tooling gaps

> All 14 in-scope repos read on disk (11 addons + LibKa0s + the two doc-and-tooling repos). Read-only throughout; nothing written outside /tmp/claude-1000/ka0s-harvest/cat10-tooling/ (which in the end held nothing — every measurement was a one-liner).
>
> What I read: every repo's tests/ inventory and tests/run.lua suite list; every .luacheckrc and .gitattributes; LibKa0s/testkit/ in full (README.md, framework.lua's assertSuiteInventory and skip machinery, test_eol.lua, test_prose.lua, vendor_sync.lua) so I would not propose a check the kit already carries; WowAddonStandards/standards/STANDARDS.md and the section files reached through its Sections list that bear on tooling (testing, lint, line-endings, layout, documentation, localization, automated-tests, open-evolutions); WowAddonStandards/AUDIT.md's mechanical-check blocks; and the audit corpus — 54 docs/audits/<date>/02_DEVIATIONS.md bundles across 12 repos, swept mechanically for rule citations by distinct repo.
>
> gh is authenticated and works: `gh issue list --repo tusharsaxena/WhatGroup --state closed --label state:will-not-do --json ...` returned five issues. I did NOT sweep the issue store repo by repo — category 10's evidence is the kit, the gate inventories and the audit corpus, and nine sibling agents hold the issue-store categories. So nothing here rests on an issue URL, and my citations are all repo:file:line.
>
> Gaps I could not close:
> - docs/reviews/<date>/01_FINDINGS.md bundles were not swept (the audit corpus alone already gave 10–11-repo counts for every finding here; a review sweep would only raise counts, not change directions).
> - Bundle heading formats differ (some tables, some `### ID —` headings), so my per-rule counts come from grepping `filename-§N` citations rather than from parsing deviation IDs. That counts a rule cited in a closed or retired row the same as a live one, so the recurrence figures are an upper bound on live failures — but the direction (which rules recur in nearly every repo, across dates) is robust.
> - I did not run the test harness or luacheck anywhere, so no finding here claims a suite is currently red. C10-F04's 12-repo `*.py` gap is a byte fact about .gitattributes, not a run result.
> - Outfitter is out of scope by instruction; it appears once in my notes only as proof that a TOC-header gate is writable (Outfitter/tests/test_toc.lua), and no finding counts it.
