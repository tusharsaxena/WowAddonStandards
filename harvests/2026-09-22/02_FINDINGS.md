# Harvest 2026-09-22 — 02 Findings

Ninety-one findings, by category. Each carries its citations, its repo count, its filter outcome and
the reason for that outcome, and — where the verification pass ran — whether the finding survived a
hostile read of its own evidence.

**Outcome vocabulary.** `live` = cleared all three filters. `settled-by-date` = the rule it argues
against has already changed. `duplicate-of-open-evolution` = already on the standard's own ledger, so
it is a vote rather than an item. `merged-away` = the same defect found from another angle, carried by
a named sibling. `below-bar` = one repo, or no stated cost. A live finding was then **verified** —
citations re-resolved, counts re-measured, and the standard re-read for coverage the sweep missed.
**REFUTED** means the verification found the finding's load-bearing claim false, miscounted, or
already answered by a section the sweeper did not open.

**Refuted findings stay here, with their refutation.** A refuted finding that vanishes from the record
is rediscovered next run at full price, and the next run pays the verification cost again. The
refutation reason is the thing worth keeping.

| Outcome | Count |
|---|---|
| live (cleared the filters) | 64 |
| — of which **upheld** by verification | 18 |
| — of which **refuted** by verification | 46 |
| settled-by-date | 4 |
| duplicate-of-open-evolution | 3 |
| merged-away | 17 |
| below-bar | 3 |
| **total** | **91** |

Seventeen of the eighteen upheld findings were carried into `04_PROPOSALS.md`. The eighteenth,
**C10-F07**, is upheld and is **not** in the survivor set handed to this bundle — that discrepancy is
recorded at its entry below and at the end of `04_PROPOSALS.md` rather than silently resolved either way.

---

## Category 1 — Convergent patterns (three or more repos, one answer, standard silent)

### C1-F01 — The re-vendor bundle: ten repos ship a frozen `docs/revendor/<date>/` the standard has never heard of
**Outcome:** merged-away → **C9-F01** · **Repos:** 10 · **Target:** audit-review-history.md + documentation.md
Ten addons ship frozen dated re-vendor bundles in a five-document shape and each names `docs/revendor/`
in its own `## Documentation map`; `documentation-§3`'s exhaustive frozen-directory list omits it and no
section file mentions the directory anywhere.
**Citations:** `AbsorbTracker/docs/ARCHITECTURE.md:541`, `MultiMeters/docs/ARCHITECTURE.md:415`, `:477`, `WhatGroup/docs/ARCHITECTURE.md:437`, `BankLedger/docs/ARCHITECTURE.md:404`, `PanelMaster/docs/ARCHITECTURE.md:279`, `PrettyChat/docs/ARCHITECTURE.md:192`, `ConsumableMaster/docs/ARCHITECTURE.md:436`, `KickCD/docs/ARCHITECTURE.md:324`, `LootHistory/docs/ARCHITECTURE.md:412`, `AuraMaster/docs/ARCHITECTURE.md:771`, `WowAddonStandards/standards/standards/documentation.md:331`
**Reason:** Same store, same silence. C9-F01 carries it because it adds the evidence that decides the
question: the ten repos did not merely invent a directory, each hand-edited a normative sentence it
otherwise quotes verbatim, and those edits have already diverged four ways. Everything unique here
carries over — the five filenames, the argument that `<date>-v<tag>` is the form that stays unique
because a day can carry two re-vendors, and the carve-out that makes `04_EXECUTION_PLAN.md` optional
where nothing was adopted (BankLedger and KickCD omit it correctly).

### C1-F02 — `docs/superpowers/{specs,plans}/` is universal, dated and entirely unspecified
**Outcome:** live → **REFUTED** · **Repos:** 11 · **Target:** documentation.md
All eleven addons partition `docs/superpowers/` into `specs/` and `plans/` with `<YYYY-MM-DD>-<slug>.md`
filenames; `documentation-§3` names the directory once, in the frozen-directory list, and says nothing else.
**Citations:** `AbsorbTracker/docs/superpowers/specs/2026-07-13-event-driven-repaint-design.md`, `MultiMeters/docs/superpowers/plans/2026-08-09-multi-meters-v0.1.0-plan.md`, `PrettyChat/docs/superpowers/specs/2026-07-14-tier2-debug-console-slash-conformance-design.md`, `MultiMeters/docs/ARCHITECTURE.md:476`, `PartyFrameEnhanced/docs/ARCHITECTURE.md:4`, `:323`, `documentation.md:331`
**REFUTED:** The descriptive half holds (12 of 12 repos, zero non-dated filenames), but the normative
half is false. "Frozen and never revised after the fact" is contradicted in every repo including the one
cited as writing the contract down — `MultiMeters/docs/superpowers/specs/2026-08-22-death-recap-design.md`
has five commits, one titled "Write down what the build learned that the design had not". The proposal
would also collide with `wow-addon/commands/revendor-standards.md:91,98`, which deliberately does *not*
exclude `docs/superpowers/` from the retired-notation sweep, and it contradicts its own citations on tier
placement (both cited repos file the directory under Tier 3, while the proposal asks the standard to say
it is not Tier 3). A purely descriptive patch is still available; the freeze clause is not.

### C1-F03 — `tests/test_surface_parity.lua`: eleven repos, one filename, and testing-§8 names none
**Outcome:** live → **UPHELD** · **Repos:** 11 (12 counting LibKa0s) · **Target:** testing.md §8 + naming-cheatsheet.md
**Citations:** `tests/test_surface_parity.lua:1` in all eleven addons; `LibKa0s/tests/test_surface_parity.lua:1`; `testing.md:164-186`; `naming-cheatsheet.md:11`; `slash-commands.md:271`
**Verification:** All eleven headers resolve and name the file at line 1. `surface_parity` appears nowhere
in any section file as a filename. One overreach trimmed: the standard *does* name a rule-subject suite
elsewhere — `slash-commands.md:271` mandates `tests/test_disabled.lua` by name, `testing.md:316` names
`tests/test_kitsync.lua` — so §8 is the outlier rather than the discovery of a missing general rule. That
makes the finding narrower and stronger. **Clear win:** unanimous existing practice, zero rollout debt.
**Absorbed:** C1-F04 (same shape for `tests/test_vendor_sync.lua`).

### C1-F04 — `tests/test_vendor_sync.lua`: eleven repos, one filename, delegating to one kit implementation
**Outcome:** merged-away → **C1-F03** · **Repos:** 11 · **Target:** testing.md
**Citations:** `tests/test_vendor_sync.lua:1` in all eleven addons; `library-stack.md:131`
**Reason:** Merged at the finding's own suggestion — C1-F03 proposes exactly the general rule this is an
instance of. What carries over: every copy is a 31–39-line delegation to `tests/_kit/vendor_sync.lua`, and
the MUST worth keeping is that the consumer half delegates rather than reimplements, for the reason
library-stack-§7 already gives about the provenance line — two implementations of one gate means the kit
can be fixed and eleven repos keep failing the old way.

### C1-F05 — `tests/test_lintconfig.lua`: ten repos gate lint's no-blanket-suppression rule with a test the standard never asked for
**Outcome:** merged-away → **C10-F07** · **Repos:** 10 · **Target:** TOOLING (the vendored kit) + lint.md
**Citations:** `tests/test_lintconfig.lua:1` in ten addons; `lint.md:5`, `lint.md:40`
**Reason:** Identical proposal from the convergent-patterns angle. C10-F07 carries it because it did the
diff work — the four assertions and the sandboxed-chunk loader are common, and what differs is the
harness global plus a per-repo header. C1-F05's best argument carries over and should be quoted in the
interview: lint.md states the rule and ten repos still had to write the enforcement themselves, so the
finding whose fix is prose has already been tried here. So does its observation that the identical
AbsorbTracker and ConsumableMaster headers are the tell that the copies were propagated rather than
rediscovered — and a propagated copy is the one that rots in the repo that forgets to re-propagate.

### C1-F06 — `NS.MSG`: five repos route every bus message through a constant table so no call site types the literal
**Outcome:** live → **UPHELD (narrowed)** · **Repos:** 5 (+1 equivalent) · **Target:** architecture.md §4 + naming-cheatsheet.md
**Citations:** `AbsorbTracker/core/Bus.lua:88`, `:16`, `AuraMaster/core/Bus.lua:30`, `ConsumableMaster/core/Bus.lua:78`, `PartyFrameEnhanced/core/Bus.lua:135`, `MultiMeters/core/Constants.lua:507`, `:515`
**Verification:** All seven citations resolve. A `.MSG = {` table exists in exactly those five repos and
nowhere else; the `Ka0s_` literals appear only at that seam. Two corrections: **PanelMaster already
conforms** by a different shape (module-scoped constants re-exported — `modules/Registry.lua:19-21`,
`settings/Schema.lua:31-35`, consumed at `modules/Canvas.lua:878-880`), so the honest rollout debt is
BankLedger, KickCD and LootHistory only; and the claim that AbsorbTracker's sender header is unique is
false — `AuraMaster/core/Bus.lua:31` and `MultiMeters/core/Constants.lua:513` do the same, and
`architecture.md:91` already MUSTs the sender be documented in `docs/ARCHITECTURE.md`. The rule must be
written against the addon's namespace seam, not the literal token `NS`.

### C1-F07 — The `<Event>` half of `Ka0s_<Addon>_<Event>` is PascalCase in seven repos and SCREAMING_SNAKE in two
**Outcome:** live → **UPHELD (narrowed)** · **Repos:** 9 publishers · **Target:** naming-cheatsheet.md (Bus messages row)
**Citations:** `AbsorbTracker/core/Bus.lua:89`, `AuraMaster/core/Bus.lua:34`, `ConsumableMaster/core/Bus.lua:80`, `PartyFrameEnhanced/core/Bus.lua:136`, `BankLedger/core/Database.lua:106`, `LootHistory/core/Database.lua:292`, `PanelMaster/modules/Registry.lua:19`, `KickCD/core/Database.lua:44`, `KickCD/core/State.lua:171`, `MultiMeters/core/Constants.lua:542`, `naming-cheatsheet.md:20`
**Verification:** Independent grep reproduces the split exactly — seven repos uniformly PascalCase, two
uniformly SCREAMING_SNAKE, no repo mixing. `naming-cheatsheet.md:20` states the format and, unlike its
neighbouring rows, no casing. Three cited lines were wrong-location (BankLedger and LootHistory senders
are in `core/Database.lua`, not the module; MultiMeters' constant is at `:542`, not `:507`) — wrong
anchors, not wrong facts. Two narrowings: only MultiMeters leaked a constant's casing into the wire name
(KickCD has no MSG table at all), and three of KickCD's five names are state nouns (`COMBAT_STATE`), so
"past participle" is a semantic rename and belongs as a SHOULD beside a PascalCase MUST.

### C1-F08 — The self-naming file header: six repos open every source file with its own path and a one-line why
**Outcome:** live → **UPHELD (reframed)** · **Repos:** 6 of 11 · **Target:** documentation.md or naming-cheatsheet.md
**Citations:** `AuraMaster/modules/Anchors.lua:3`, `ConsumableMaster/core/BagScanner.lua:1`, `KickCD/modules/Castbar_Debug.lua:1`, `MultiMeters/modules/Row_NameCell.lua:1`, `PartyFrameEnhanced/modules/Anchor.lua:3`, `WhatGroup/modules/Frame.lua:1`; negative: `PanelMaster/core/Util.lua:1-3`, `LootHistory/modules/Collector.lua:1-3`
**Verification:** Nine of nine citations resolve; no section governs a top-of-file purpose comment. The
headline framing is false, though: "repos are at 100% or at 5%" does not hold — re-measured, the six are
63/63, 18/18, 56/58, 36/38, 41/47, 33/38 and the others are 9/19, 13/28, 8/30, 5/30, 1/28, so only two are
near zero. In the low repos the headers sit almost exclusively on the LibKa0s seam files, where they
arrived with the wiring template rather than by choice. The SHOULD survives on the convergence itself
(247 files), not on a binary split. Rollout under the SHOULD is 99 files, not 129. Note that even the
strongest repos leave the same scaffolded files bare (`core/CoreSetup.lua`, `settings/Slash.lua`,
`core/Constants.lua`), so the `new-addon` scaffold is where the rule has to be seeded.
**Absorbed:** C9-F09.

### C1-F09 — The peel file: four repos split an over-cap file as `Parent_Suffix.lua`, loaded after the parent
**Outcome:** live → **REFUTED** · **Repos claimed 4, true 2** · **Target:** layout.md §1
**Citations:** `KickCD/modules/Castbar.lua:1`, `Castbar_Debug.lua:1`, `Castbar_Handle.lua:1`, `IconGrid_Layout.lua`, `settings/Panel_Render.lua`, `AuraMaster/modules/Style_{Bars,Icons,Text}.lua`, `MultiMeters/modules/Row_NameCell.lua:1`, `Tooltip_Builders.lua`, `core/Diagnostics_DeathRecap.lua`, `settings/Schema_Paths.lua`, `ConsumableMaster/defaults/Defaults_*.lua`, `layout.md:69`
**REFUTED, four ways.** (1) Only KickCD and MultiMeters have cap-driven peels; AuraMaster's `Style_*` trio
are per-mode partition files off a 943-line parent that was never over cap, and ConsumableMaster has no
`Defaults.lua` parent at all. (2) A live counterexample falsifies the central MUST: `MultiMeters/MultiMeters.toc:126-127`
lists `Schema_Compose.lua` **before** `Schema.lua` deliberately, with the reason in the TOC comment — so
"a peel MUST be listed after its parent" would make a correct, annotated TOC non-compliant. (3) The naming
and placement half is already in the section the finding targets: `layout.md:58`'s MAY shows
`settings/Schema.lua → settings/Schema_Core.lua` in the same folder. (4) The load-bearing-comment half is
already `toc-file.md:145`. The attach-rather-than-register claim holds in one repo only.

### C1-F10 — `defaults/Global.lua`: three repos put account-wide defaults in a file savedvariables-§1 does not name
**Outcome:** live → **REFUTED** · **Repos claimed 3, true 2** · **Target:** savedvariables.md
**Citations:** `BankLedger/defaults/Global.lua:3`, `:8`, `LootHistory/defaults/Global.lua:3`, `:6`, `PanelMaster/defaults/Global.lua:3`, `:8`, `savedvariables.md:33`, `:18`
**REFUTED:** The premise — that §1 and §2 cannot both be satisfied in one file — is false. `savedvariables.md:8-12`
shows both namespaces in one defaults table, and five repos do exactly that in `defaults/Profile.lua`
(AbsorbTracker:103, AuraMaster:84, ConsumableMaster:25, MultiMeters:817, PartyFrameEnhanced:130). The
"same second convention" claim also fails: LootHistory *does* seed `schemaVersion = 1` as a deliberate
floor (`defaults/Global.lua:13`), the opposite of the other two. BankLedger and LootHistory shipping no
`defaults/Profile.lua` at all is a per-repo §2 deviation, not a standards gap. The migration-stamp half is
already `open-evolutions.md`'s *Migration-stamp ownership* entry and belongs there as strengthened evidence.

### C1-F11 — `NS.SetByPath` / `NS.ApplyDefault`: the standard's own example names the write seam the cheatsheet omits
**Outcome:** live → **REFUTED as filed; a stronger finding survives** · **Repos:** 4 vs 4 · **Target:** architecture.md ↔ slash-commands.md
**Citations:** `slash-commands.md:83`, `:85`, `AbsorbTracker/settings/Schema.lua:187`, `:289`, `AuraMaster/settings/Schema.lua:711`, `:782`, `MultiMeters/settings/Schema_Paths.lua:730`, `:809`, `PartyFrameEnhanced/settings/Schema.lua:198`, `:286`, `naming-cheatsheet.md:4`
**REFUTED on premise:** the statement says architecture-§ "names no helper". It names one, in the same MUST
sentence — `architecture.md:126`: "MUST route every write to a schema-row path through one helper:
`NS.Schema:Set(path, value)`". So this is **not** a category-1 silence; it is a **standard-internal
contradiction**, two names for one mandated seam in two sections, which is a stronger finding than the one
filed and belongs in category 5. Adopting `NS.SetByPath` as normative would put the cheatsheet in conflict
with a MUST and convert four currently-conforming repos into breaches. Re-file, do not promote as written.

---

## Category 2 — Divergent patterns (same problem, N different ways)

### C2-F01 — The Compat shim: nine copies, and the six that overlap have drifted into three incompatible return contracts
**Outcome:** duplicate-of-open-evolution · **Repos:** 9 · **Target:** LIBKA0S
**Citations:** `AuraMaster/core/Compat.lua:315`, `KickCD/core/Compat.lua:162`, `MultiMeters/core/Compat.lua:44`, `ConsumableMaster/core/Compat.lua:68`, `LootHistory/core/Compat.lua:82`, `WhatGroup/core/Compat.lua:27`, `BankLedger/core/Compat.lua:153`, `PanelMaster/core/Compat.lua:27`, `PartyFrameEnhanced/core/Compat.lua:13`
**Reason:** `open-evolutions.md:13` already names "the Compat shim" among the candidates the collection
still duplicates. This is a **vote with new measurement attached**, and the measurement is what the entry
was missing: 2820 lines across nine copies of which only ~400 is genuinely duplicated surface, plus the
explicitly non-portable set (MultiMeters' C_DamageMeter block ~410 lines, AuraMaster's aura-container
block, BankLedger's guild bank, LootHistory's bind-state scanner) that stops an extraction shipping the
common denominator. Carry the design constraint too: the extracted major must state, per shim, the return
arity and what it answers when every rung is absent, because the headless harness is a client with no
rungs and exercises that answer on every run.

### C2-F02 — The message bus: one AceEvent pattern, five homes, four mutually incompatible stand-down designs
**Outcome:** duplicate-of-open-evolution · **Repos:** 11 · **Target:** LIBKA0S
**Citations:** `AbsorbTracker/core/Bus.lua:70`, `:77`, `ConsumableMaster/core/Bus.lua:56`, `:68`, `PartyFrameEnhanced/core/Bus.lua:46`, `:118`, `AuraMaster/core/Bus.lua:21`, `BankLedger/core/BankLedger.lua:6`, `LootHistory/core/LootHistory.lua:6`, `PanelMaster/core/PanelMaster.lua:6`, `MultiMeters/core/Namespace.lua:210`, `MultiMeters/core/Constants.lua:515`, `KickCD/core/KickCD.lua:46`
**Reason:** `open-evolutions.md:13` names "the message bus" as a duplicated candidate. Vote, not item. The
entry gains the design finding it lacked: an extracted `LibKa0s-Bus-1.0` must cover the **union**, which is
PartyFrameEnhanced's design and only its — a per-receiver AceEvent target whose Register/Unregister members
are wrapped so the library holds a live record covering events *and* messages, with StandDown/StandUp
replaying from the record as it is now rather than from a snapshot. AbsorbTracker's triple register and
ConsumableMaster's closure register are strictly weaker: neither takes game events down.
**Kept distinct from C1-F06**, which proposes a rule that binds whether or not the library is built.

### C2-F03 — The Schema runtime: nine repos, five calling conventions, and the write seam is named differently in every one
**Outcome:** duplicate-of-open-evolution · **Repos:** 9 · **Target:** LIBKA0S
**Citations:** `AbsorbTracker/settings/Schema.lua:187`, `:208`, `PartyFrameEnhanced/settings/Schema.lua:198`, `AuraMaster/settings/Schema.lua:711`, `:90`, `MultiMeters/settings/Schema_Paths.lua:97`, `:622`, `BankLedger/settings/Schema.lua:530`, `:475`, `LootHistory/settings/Schema.lua:515`, `PanelMaster/settings/Schema.lua:452`, `PrettyChat/settings/Schema.lua:636`, `WhatGroup/settings/Schema.lua:451`, `:505`
**Reason:** Named twice on the ledger (`open-evolutions.md:6` and `:13`). Vote with substantial new design
work: the runtime splits into a portable half (path split, read/write at path, same-value comparison,
default lookup, apply-default, changed-row counting, bulk open/close/run, row registry, row-shape
validation, value formatting) and a host half that is why a naive extraction fails — what the path is
rooted at differs per addon (`AuraMaster/settings/Schema.lua:147` the active container,
`MultiMeters/settings/Schema_Paths.lua:179` the active window, `PrettyChat/settings/Schema.lua:796` a
category) — so the major takes a `resolveRoot` and an `announce` callback and owns everything between.
One technical argument decides the convention: a colon-called seam cannot be passed as a value to the
Options descriptor. The cheaper half — naming the seam so the MUST becomes greppable — is now C1-F11's
contradiction and must be settled there first.

### C2-F04 — The secret-value seam: five homes, four names, one addon with no seam at all
**Outcome:** merged-away → **C3-F08** · **Repos:** 5 · **Target:** LIBKA0S
**Citations:** `MultiMeters/core/Secrets.lua:113`, `:182`, `:290`, `AuraMaster/core/Secrets.lua:36`, `:66`, `ConsumableMaster/core/Compat.lua:60`, `PartyFrameEnhanced/core/Compat.lua:13`, `KickCD/modules/Cooldowns.lua:122`, `:251`, `KickCD/modules/IconGrid.lua:334`, `KickCD/modules/Castbar.lua:303`, `LibKa0s/LibKa0s/Core.lua:57`, `:67`
**Reason:** Same extraction, same five repos. C3-F08 is the fuller proposal. What carries over is the
sizing: MultiMeters' 325-line eleven-member surface is the deepest and the right promotion base and the
only one exposing restriction *state* rather than a boolean; AuraMaster's `NumberOr` is the guard in front
of every geometry read and MultiMeters lacks it; ConsumableMaster and PartyFrameEnhanced consult
`issecretvalue` only and never `canaccessvalue`, which answers the wrong question since a value can be
non-secret yet inaccessible; and KickCD has **no seam at all** — twelve inline `_G.issecretvalue` call
sites across four feature modules, a live compat-§1 breach in the addon whose data is most often secret.

### C2-F05 — Four incompatible stored shapes for a window's saved position
**Outcome:** live → **REFUTED** · **Repos:** 10 · **Target:** LIBKA0S
**Citations:** `KickCD/core/Util.lua:41`, `:60`, `MultiMeters/modules/Window_Placement.lua:48`, `WhatGroup/core/Util.lua:57`, `:65`, `:76`, `BankLedger/modules/Browser.lua:144`, `:159`, `BankLedger/modules/SessionWindow.lua:252`, `LootHistory/modules/Browser.lua:106`, `PartyFrameEnhanced/modules/Anchor.lua:332`, `AuraMaster/modules/Anchors.lua:291`, `AbsorbTracker/modules/Display.lua:140`, `PanelMaster/modules/Registry.lua:924`
**REFUTED:** The gap is real — nothing specifies the stored shape — but the account of it is not. The
degradation comparison is wrong in all three instances (all three "readers" cited are writers:
`Util.SaveAnchor`, `B:SaveGeometry`, `PointOf`), and the proposed reader contract is attributed to a repo
that does the opposite — `BankLedger/modules/Browser.lua:169-171` falls through to `SetPoint("CENTER")`,
the very behaviour the proposal condemns in KickCD, and CENTER is in fact the majority reader behaviour.
"No two agree" is false: the shapes cluster into three families, several byte-identical, and the proposal
misses a real fourth shape (flat fields on the record, ConsumableMaster and PanelMaster). Decisively,
`LibKa0s/docs/api/Widgets/version-9.2-docs.md:499,653-657` already places the position save on the **host**
side of the drag-handle seam by design and names two hosts' savers as intended retentions; reversing a
published library boundary needs an argument the finding does not make. A naming-cheatsheet line plus an
open-evolutions entry for the migration is what the evidence supports.

### C2-F06 — LibSharedMedia is reached twenty times in nine addons, six ways
**Outcome:** live → **REFUTED** · **Repos claimed 9, true 7** · **Target:** library-stack.md §8
**Citations:** `AbsorbTracker/core/Data.lua:22`, `AuraMaster/modules/Style.lua:33`, `KickCD/modules/UnitLabel.lua:22`, `KickCD/modules/Castbar.lua:140`, `KickCD/modules/IconGrid_Render.lua:60`, `:870`, `ConsumableMaster/modules/MacroBarButton.lua:48`, `:63`, `MultiMeters/modules/Row.lua:327`, `Tooltip.lua:336`, `Window.lua:89`, `PartyFrameEnhanced/core/Util.lua:14`, `PanelMaster/core/Compat.lua:104`, `:126`, `:150`, `LibKa0s/LibKa0s/Media.lua:233`, `:264`
**REFUTED on four grounds.** The standard already speaks here and says the **opposite**: `library-stack.md:56`
SHOULDs `LibStub` be called once at load and stashed on the namespace, and SHOULD NOTs per-frame `LibStub`
calls — so the proposal inverts a live rule without naming it. `compat.md:5` scopes `core/Compat.lua` to
*deprecated APIs*, not optional vendored libraries, so "compat-§1 makes Compat the only file" is not a rule
that exists. "Nothing left to build" is false and load-bearing: LibKa0s-Media publishes only `Icon`,
`Texture`, `Font` and `RegisterLSM`, each resolving out of the library's **own** catalogs, while the twenty
call sites do `LSM:Fetch(type, <player-stored key>)` and `LSM:List(type)` — surfaces the library does not
have. The stated TOC-ordering harm is also unsound: LSM is vendored under `libs/` and has already run
(`library-stack.md:319-321`). The defensible residue is an addon-internal DRY rule about the fetcher.

### C2-F07 — Deep copy is written fifteen times across ten repos under five names
**Outcome:** live → **REFUTED** · **Repos claimed 10, true 9** · **Target:** LIBKA0S
**Citations:** `MultiMeters/core/Database.lua:68`, `defaults/Profile.lua:38`, `modules/WindowManager.lua:82`, `settings/Schema_Paths.lua:132`, `KickCD/core/Util.lua:90`, `core/Database.lua:51`, `defaults/Profile.lua:22`, `LootHistory/core/Util.lua:18`, `settings/Schema.lua:423`, `BankLedger/settings/Schema.lua:427`, `WhatGroup/settings/Schema.lua:59`, `PanelMaster/core/Util.lua:248`, `PartyFrameEnhanced/core/Util.lua:35`, `AbsorbTracker/core/Units.lua:42`, `AuraMaster/settings/Schema.lua:122`
**REFUTED:** The central technical premise is false. All sixteen copies (the count is 16, not 15) are the
same five-line body; **not one** carries a metatable and **not one** detects a cycle, so "the copies differ"
— the whole value of the proposed contract — is not true. `library-stack.md:143-168` already answers this
shape: "MUST NOT promote on frequency alone. High frequency plus low semantic content is the signature of a
shape that should stay inline." Four of the cited sites additionally carry committed comments explaining
that the copy is deliberately file-local for load-order reasons, so "nothing to adopt beyond deleting a
local" is wrong. A watch-list line in `open-evolutions.md` recording the deliberate non-promotion, with a
re-check trigger the day two copies actually diverge, is the honest outcome.

### C2-F08 — Eleven repos register the AceDB profile callback in three files, and eight react to a switch but not a copy or reset
**Outcome:** live → **REFUTED** · **Repos exhibiting the defect: 0** · **Target:** savedvariables.md
**Citations:** `KickCD/core/Database.lua:904-906`, `ConsumableMaster/core/ConsumableMaster.lua:511`, `AbsorbTracker/core/Database.lua:14`, `AuraMaster/core/Database.lua:249`, `BankLedger/core/Database.lua:20`, `PanelMaster/core/Database.lua:102`, `PartyFrameEnhanced/core/Database.lua:14`, `LootHistory/core/LifecycleSetup.lua:199`, `PrettyChat/core/PrettyChat.lua:63`, `WhatGroup/core/WhatGroup.lua:269`, `MultiMeters/core/Database.lua:1107`
**REFUTED flatly.** All **eleven** repos register all three callbacks; the sweeper cited only the first line
of each three-line block and read the absence of further citations as absence of registration. Several of
those blocks carry comments saying the opposite of the finding (BankLedger: "the cost is three lines and the
failure they prevent is silent"). The requirement is also already normative in two sections the sweeper did
not open — `slash-commands.md:199` names all three callbacks, and `options-ui.md:248` requires
`db:ResetProfile()` precisely so `OnProfileReset` reaches the host handler. What is left is the cosmetic
observation that registration lives in three different files, which the finding itself concedes costs nothing.

### C2-F09 — `return X and X()` in a Compat shim answers false, not nil
**Outcome:** live → **REFUTED** · **Repos exhibiting the defect: 0** · **Target:** TOOLING
**Citations:** `KickCD/core/Compat.lua:259`, `MultiMeters/core/Compat.lua:101`, `KickCD/core/Util.lua:202`, `ConsumableMaster/core/Compat.lua:17`
**REFUTED on Lua semantics.** `and` yields its **left** operand when that operand is falsy, so `nil and nil()`
is `nil`; `false` can only arise if the global is literally the boolean false, which no client does. Verified
by execution. The repos' own tests already prove it — `MultiMeters/tests/test_compat.lua:113` asserts
`assertNil(...GetSpecialization())` against a harness with the global absent, inside the green gate. The
"demonstrated consequence" also does not exist: `KickCD/core/Util.lua:204` is `if not idx then return nil end`,
which stops any falsy value. The proposed grep would fire on seventeen correct lines across the collection
**and on the standard's own worked example** at `compat.md:18`.

### C2-F10 — compat's own worked example is followed by no addon, and one of its two shims raises on the client it protects
**Outcome:** live → **REFUTED as framed; one real erratum survives** · **Repos claimed 9, true 6** · **Target:** compat.md
**Citations:** `compat.md:11`, `:21`, `:27`, `MultiMeters/modules/Roster.lua:187`, `AuraMaster/core/Compat.lua:315`, `KickCD/core/Compat.lua:162`, `ConsumableMaster/core/Compat.lua:68`
**REFUTED on counts:** only six repos hold a spell-or-spec shim at all, so five abstentions were counted as
votes; and "only ConsumableMaster got the degradation right" is false — all three repos with a
`GetSpecialization` shim degrade safely. The proposed correction to the section's stale sentence is itself
wrong and *less* accurate than the text it corrects: a full sweep finds **three** direct reaches across two
repos and three modules (`MultiMeters/modules/Roster.lua:187-188`, `KickCD/core/Util.lua:264,274`,
`KickCD/settings/Spells.lua:917,926`), not one. **What survives:** the example at `compat.md:22-24` does call
the bare global unconditionally and raises when both surfaces are absent — a one-line erratum in a code
block, worth fixing, not worth an owner interview.

### C2-F11 — BankLedger and LootHistory ship the same seven-function data-browser utility pack
**Outcome:** below-bar (watch list) · **Repos:** 2 · **Target:** LIBKA0S
**Citations:** `BankLedger/core/Util.lua:6,15,24,29,36,51,155`; `LootHistory/core/Util.lua:6,25,34,40,47,63,91`
**Reason:** Below bar at the finding's own recommendation, and the reasoning is worth recording so it is not
re-litigated. Two repos is the bar exactly and both are the same kind of addon. `library-stack-§7`'s third
bar is unmet: `FormatMoney` and `FormatClock` are presentation, and presentation is where a third consumer
arrives wanting a format argument — the escape hatch the bar exists to refuse. `SplitPath` and `PlayerKey`
do clear all three bars, and `SplitPath` is better carried as evidence on the Schema-runtime ledger entry
(C2-F03) than as a standalone item.

### C2-F12 — Nothing in the green gate detects double-encoded UTF-8
**Outcome:** merged-away → **C4-F04** · **Repos:** 1 · **Target:** TOOLING
**Citations:** `PartyFrameEnhanced/core/Bus.lua:25`, `:34`, `LibKa0s/testkit/test_prose.lua:1`
**Reason:** Merged rather than filed below-bar, which is the honest handling: one repo, but its proposed fix
is literally a subset of C4-F04's citation gate — check (c) resolves every `filename-§N` reference, which is
this finding's second assertion, and the double-encoding scan (`Â§`, `â€”`, `â€“`, `â€™`, `Ã©`) is one more
fixed-byte assertion over the same files. Merging lifts it over a bar it could not clear alone. What must
carry over: nothing in the collection would ever report this (`test_prose.lua` has no such check, luacheck
does not read comments, and revendor-standards looks for *retired* notation rather than *corrupted*
notation), and the finding's own refusal to spend a rule on it is right — "do not corrupt your encoding" is
unactionable.

---

## Category 3 — Midnight quirks

### C3-F01 — Nine repos keep nine private quirk catalogues; the standard has no quirks section
**Outcome:** live → **REFUTED (catalogue half); ledger half survives)** · **Repos:** 9 · **Target:** NEW section
**Citations:** all nine `docs/midnight-quirks.md` files; `STANDARDS.md:176`; `documentation.md:250`
**REFUTED on premise:** "the standard itself catalogues no quirk" is false, and the two behaviours actually
demonstrated as duplicated are both already catalogued upstream, in more depth than most local files —
secret values at `events-frames-taint.md:73-97` (the `..`-propagates/`table.concat`-raises asymmetry, plus
the vendored `IsConcatSafe`/`SafeToString` seam "so that no addon has to get it right twice"), and
`Settings.OpenToCategory`'s numeric ID at `options-ui.md:65,67` and anti-pattern #88. Also,
`documentation.md:250` does **not** mandate the file per addon: it is a Tier-2 trigger scoped to "at least
one client-version workaround **of its own**". The v2.34.0 deferral's stated objection — that a catalogue
rots without a stated expiry discipline — is not answered by a build stamp with no owner or gate.
**What survives, and should be carried:** that deferral was recorded only in the `STANDARDS.md` changelog and
never in `open-evolutions.md`, this command's declared dedup key, so a later harvest had to rediscover it by
grepping the changelog. One paragraph in the ledger, patch-class, no rollout.

### C3-F02 — A secret BOOLEAN is unusable, not merely unprintable
**Outcome:** live → **REFUTED on count** · **Repos claimed 5, true 2 (+2 adjacent)** · **Target:** events-frames-taint.md §8
**Citations:** `KickCD/docs/midnight-quirks.md:53-78`, `KickCD/core/State.lua:65`, `:110-126`, `PartyFrameEnhanced/docs/midnight-quirks.md:26-43`, `core/Compat.lua:121-141`, `ConsumableMaster/docs/midnight-quirks.md:58-62`, `modules/MacroBarButton.lua:170-195`, `AuraMaster/docs/midnight-quirks.md:7-20`, `MultiMeters/docs/midnight-quirks.md:13-26`, `events-frames-taint.md:73-168`
**REFUTED as a five-repo convergence.** Only KickCD and PartyFrameEnhanced decide a possibly-secret boolean
C-side. ConsumableMaster's single `SetAlphaFromBoolean` call passes a **plain** boolean with a secret alpha
and its write-up frames the rule prospectively ("For a future field where neither…"); MultiMeters and
AuraMaster ship the opposite answer — restructure so the boolean never meets an `if` — and neither calls
either C method. Three of ten citations point at passages that say something else. The underlying gap is
real and uncovered (§8 is a printing rule end to end), and the narrower true shape is a four-repo
*prohibition* plus a two-repo C-side pattern plus a permitted third road. Re-file at that width.

### C3-F03 — A secret used as a table key raises its own distinct error
**Outcome:** live → **REFUTED on count** · **Repos claimed 3, true 2** · **Target:** events-frames-taint.md §8
**Citations:** `MultiMeters/docs/midnight-quirks.md:13-26`, `core/Secrets.lua:224`, `AuraMaster/core/Secrets.lua:76`, `modules/TimedSpells.lua:71`, `:112`, `PartyFrameEnhanced/docs/midnight-quirks.md:8-10`, `core/Compat.lua:163-165`, `events-frames-taint.md:73-90`
**REFUTED:** `IsSafeKey` exists in exactly two repos. PartyFrameEnhanced — the claimed third — built no gate
at all; its contribution is one clause of prose in a bulleted list, which is the "third does something
adjacent" case. The verbatim client error the proposal wants made greppable appears in exactly one place in
the collection (MultiMeters' own write-up), unreplicated, and the widening to indexed *reads* of Blizzard
constant tables rests entirely on a citation that does not say it. The gap is genuine and undeduped (§8
names comparison, arithmetic and string-building and not keying), so re-run when a third repo hits it. The
stronger signal is that two repos wrote byte-identical `IsSafeKey` helpers, which points at library-stack
rather than at a prose arm.

### C3-F04 — Restricted cooldowns are paintable only through a duration object
**Outcome:** live → **REFUTED on count and on the gap claim** · **Repos claimed 4, true 2** · **Target:** events-frames-taint.md §8
**Citations:** `KickCD/docs/midnight-quirks.md:5-35`, `core/Compat.lua:97-141`, `ConsumableMaster/docs/midnight-quirks.md:43-57`, `core/MacroDisplay.lua:92-131`, `modules/MacroBarButton.lua:185-195`, `PartyFrameEnhanced/docs/midnight-quirks.md:8-10`, `AuraMaster/docs/midnight-quirks.md:239-250`, `events-frames-taint.md:120-135`
**REFUTED:** Only KickCD and ConsumableMaster describe the duration-object path. PartyFrameEnhanced's quirks
file contains the word "cooldown" zero times and the repo has no reference to any of the three APIs;
AuraMaster's two hits are in a research note, and the cited lines are about aura filter tokens. The
trigger-set claim is also overstated: §8's list ends with a catch-all — "any other API a client build
protects in combat, and anything derived from a protected value" — so `C_Spell.GetSpellCooldown` is already
in scope of the MUST and naming it explicitly is a specificity improvement, not a gap closure. **Worth
keeping:** a third repo, WhatGroup, calls the API with no secret handling at all
(`WhatGroup/core/Compat.lua:96-107` compares and does arithmetic on `info.startTime`/`info.duration`) —
the strongest argument for naming the API explicitly, and a per-repo defect to file.

### C3-F05 — Retail raises on an unknown event name, so one retired event silently deafens the rest of the block
**Outcome:** live → **UPHELD (membership corrected)** · **Repos:** 5 · **Target:** events-frames-taint.md §1 + TOOLING
**Citations:** `BankLedger/docs/midnight-quirks.md:53-60`, `BankLedger/modules/Ledger.lua:849`, `:864-881`, `MultiMeters/docs/midnight-quirks.md:84-95`, `MultiMeters/core/MultiMeters.lua:119-131`, `ConsumableMaster/docs/midnight-quirks.md:110-114`, `PanelMaster/tests/test_harness.lua:115-123`, `LibKa0s/testkit/mock_base.lua:715-727`, `events-frames-taint.md:5-9`
**Verification:** Nine of ten citations resolve exactly. No section states the raise or requires a
registration block to survive one bad name; the nearest analogue (`options-ui.md:233`, "Each refresher MUST
be pcall'd") is the same shape in a different domain. `open-evolutions.md` has no entry. **One membership
correction:** LibKa0s belongs in the five (its kit models and tests the raise) and AbsorbTracker does not —
`AbsorbTracker/docs/midnight-quirks.md:118-120` records the **opposite** model ("the registration succeeds
but the event never fires"), a documentation defect to correct during rollout rather than a variant guard.

### C3-F06 — `ADDON_RESTRICTION_STATE_CHANGED` is the restriction edge, and the two repos that read it disagree about its signature
**Outcome:** live → **REFUTED** · **Repos:** 2 · **Target:** events-frames-taint.md
**Citations:** `AuraMaster/docs/midnight-quirks.md:44-48`, `core/AuraMaster.lua:66`, `:73`, `modules/TimedSpells.lua:142`, `modules/ContainerManager.lua:168`, `MultiMeters/docs/midnight-quirks.md:74-83`, `core/Secrets.lua:43-44`, `:94`, `:126`, `:132`
**REFUTED:** The headline — an unresolvable signature disagreement — is false and resolvable in two greps.
AuraMaster does not read the payload at all (`core/AuraMaster.lua:126` is `function addon:OnRestrictionChanged()`,
no parameters), so there is no second implementation; the only `(type, active)` in the repo is one line of
doc prose. MultiMeters' reading is anchored to the live client enum — `core/Secrets.lua:91-96` resolves
`Enum.AddOnRestrictionState` with `Inactive/Activating/Active` — which settles the second argument. Writing
"both readings, unresolved" into a standard eleven repos copy would manufacture doubt the evidence closes.
The underlying facts are worth a catalogue entry (the `Activating` window; type 4 never clearing in a
dungeon while auras stay readable), stated as facts, and AuraMaster's doc line corrected in that repo.

### C3-F07 — `Settings.OpenToCategory` takes a numeric ID and leaves the sibling tree collapsed
**Outcome:** live → **UPHELD (narrowed)** · **Repos claimed 5, true 4** · **Target:** options-ui.md
**Citations:** `AbsorbTracker/docs/midnight-quirks.md:73-78`, `ConsumableMaster/docs/midnight-quirks.md:74-109`, `WhatGroup/docs/midnight-quirks.md:19-46`, `KickCD/docs/midnight-quirks.md:124-128`, `AuraMaster/settings/OptionsSetup.lua:372-373`, `LibKa0s/LibKa0s/Options.lua:598`, `:1388-1399`, `options-ui.md:64-67`
**Verification:** All eight citations resolve. No section file mentions `GetID()`, `SetExpanded`,
`GetCategoryEntry` or `CategoryList`; `open-evolutions.md` has no entry. Three narrowings: the fifth repo is
not an instance (AuraMaster jumps to a named *subcategory* and never meets the collapsed-parent problem);
WhatGroup's "a parent with subcategories renders no widgets" element is **already legislated** at
`options-ui.md:84-91`, which MUSTs the landing-page/subcategory split and mandates a parent body every addon
in fact renders — so it must not be promoted as new; and a MUST NOT on hand-rolling the open would have to
carve out the page-jump helper, which at least two repos ship (AuraMaster and KickCD's `Helpers.OpenPageTab`).

### C3-F08 — Five repos hand-rolled a secret-value reader while LibKa0s ships only the concat probe
**Outcome:** live → **REFUTED on the promotable surface** · **Repos:** 5 · **Target:** LIBKA0S
**Citations:** `LibKa0s/LibKa0s/Core.lua:52`, `AuraMaster/core/Secrets.lua:76`, `MultiMeters/core/Secrets.lua:151`, `:166`, `:182-198`, `:224-290`, `PartyFrameEnhanced/core/Compat.lua:13`, `:121-141`, `KickCD/core/State.lua:110-126`, `ConsumableMaster/docs/midnight-quirks.md:37-41`, `events-frames-taint.md:90-100`
**REFUTED as proposed, though the repo count holds.** Of the union the proposal asks LibKa0s to take, only
`IsSecret` and `CanAccess` clear `library-stack-§7`'s first bar; every other named member has exactly one
consumer (`CanCompare`, `IsSecretTable`, `SafeIterate` and the restriction-state pair are MultiMeters'
alone; `IsReadableNumber`/`NumberOr` AuraMaster's; the C-side boolean seams PartyFrameEnhanced's).
`IsSafeKey` has two. Worse, the C-side boolean pair is a **correctness disagreement**, which §7 forbids
promoting: PartyFrameEnhanced gates first, KickCD calls `SetAlphaFromBoolean` ungated on purpose and
`KickCD/docs/castbar.md:133` argues gating there is wrong. Three of thirteen citations carry the proposal's
specific claims and all three point elsewhere. Narrow to `IsSecret` + `CanAccess` (+`IsSafeKey`) and
reconcile against `open-evolutions.md:13`'s existing Compat candidate.

---

## Category 4 — The audit and review corpus

### C4-F01 — options-ui-§13's wrapped-strip Testing MUST is open in five repos and has never been satisfied anywhere
**Outcome:** live → **REFUTED** · **Repos:** 5 open rows · **Target:** options-ui.md
**Citations:** `AbsorbTracker/docs/audits/2026-09-08/02_DEVIATIONS.md:44`, `:21`, `AuraMaster/docs/audits/2026-09-11/02_DEVIATIONS.md:118`, `PanelMaster/…:38`, `PrettyChat/…:51`, `MultiMeters/…:155`, `:250`, `LibKa0s/testkit/mock_base.lua:168`, `:178`, `:187`
**REFUTED:** "Never satisfied anywhere" is false — ConsumableMaster satisfies it in full and has since
2026-09-08 (`tests/test_settingsui_optionsui.lua:514-600`, two genuinely wrapping strips, the band asserted
across two selections, with a local per-atlas harness extender). The standard also already says what the
finding asks it to say: `options-ui.md:300` reads "A harness that answers one height for every atlas cannot
fail this — the harness MUST answer a different height for the selected-state art, or the case is green
against nothing." Two of the five bundles additionally contradict the "blocked upstream" story in their own
text. Five open rows against a rule a sibling has demonstrably closed is a rollout item, not a standards change.

### C4-F02 — toc-file-§5's load-bearing annotation MUST is failed by eight repos and checked by nothing
**Outcome:** merged-away → **C10-F05** · **Repos:** 8 · **Target:** TOOLING
**Citations:** `AbsorbTracker/docs/audits/2026-09-08/02_DEVIATIONS.md:46`, `BankLedger/…:49`, `ConsumableMaster/…:49`, `LootHistory/…:54`, `PartyFrameEnhanced/docs/audits/2026-09-15/02_DEVIATIONS.md:27`, `PrettyChat/…:50`, `:92`, `KickCD/…:30`, `AuraMaster/docs/audits/2026-09-11/02_DEVIATIONS.md:24`
**Reason:** Same gate, same section, from the audit-corpus angle. C10-F05 sequences the two halves correctly
(mechanical field/order half first, the annotation inference second). C4-F02's contribution carries over and
is the better-worded specification: parse the root `.toc`'s file listing, detect a file-scope resolution of an
`NS.*` seam published by a file listed earlier, and require that TOC line to carry a comment — the denominator
toc-file-§5 spent a paragraph establishing, computed instead of counted by hand. Its framing is also right
for the interview: the section's text is already the best-argued in the standard and a ninth paragraph will
not help.

### C4-F03 — Nothing pins the automated-test record to the tree it describes
**Outcome:** live → **UPHELD (count raised)** · **Repos claimed 6, true 10** · **Target:** automated-tests.md §4
**Citations:** `AbsorbTracker/docs/reviews/2026-09-07/01_FINDINGS.md:283`, `:48`, `BankLedger/…:37`, `LootHistory/…:224`, `PanelMaster/…:233`, `MultiMeters/docs/audits/2026-09-08/02_DEVIATIONS.md:222`, `LibKa0s/docs/reviews/2026-09-07/01_FINDINGS.md:355`, `KickCD/…:82`
**Verification:** All eight citations resolve and say what is claimed; the 39-test/906-NLOC arithmetic checks.
`automated-tests.md` §1/§3/§4/§5 were read end to end and no section names a commit SHA or tree cleanliness —
a grep for `sha|dirty|clean tree|uncommitted` across every section file returns nothing on point. The SHA and
dirty flag exist in the runner's manifest as runner behaviour, not as a requirement, which is why the fix is
cheap. The count **undercounts**: the 2026-09-07 sweep found the record behind the tree in **ten of ten**
reviewed repos. Two distinct defects sit under it — going stale (expected, §4 regenerates at release) and
being *unknowable* (LibKa0s' v1.25.0 bundle records a dirty tree and cannot be reproduced from its own SHA,
and ConsumableMaster's newest is dirty too). The second is the real gap.

### C4-F04 — Citation drift is the collection's most common deviation class, and the one gate written for it is green against the drift
**Outcome:** live → **REFUTED on count and coverage; a narrower proposal survives** · **Repos claimed 8+8, true 6** · **Target:** TOOLING
**Citations:** `ConsumableMaster/docs/reviews/2026-09-07/01_FINDINGS.md:176`, `WhatGroup/docs/audits/2026-09-08/02_DEVIATIONS.md:154`, `:183`, `:205`, `PrettyChat/…:53`, `PartyFrameEnhanced/…:26`, `AuraMaster/…:130`, `AuraMaster/docs/reviews/2026-09-11/01_FINDINGS.md:172`, `LibKa0s/…:38`, `LootHistory/…:155`, `:291`, `PanelMaster/…:212`, `ConsumableMaster/docs/audits/2026-09-08/02_DEVIATIONS.md:46`, `AbsorbTracker/…:21`
**REFUTED as filed:** six of fourteen citations point at findings that are not citation drift under the
proposal's own definition (stale counts, stale prose, a summary bullet). Measured directly, four newest
audits and four newest reviews carry a genuine one — six distinct repos, not "eight and eight", and two of
the four audit findings are graded SHOULD. Three of the four proposed sub-checks are **already normative**:
`documentation.md:531-600` grades an unresolvable `filename-§N` MUST and publishes the range-check command,
and `audit-review-history.md:37-52` already MUSTs that a register row's cited ids resolve.
**What survives:** the executable gate. The rules exist; nothing runs them, and the one repo that tried
shipped a gate green against its own defect (`WhatGroup` WG-63). The gate belongs in the LibKa0s testkit and
lands in `testing.md`, not in a nonexistent TOOLING section.
**Absorbed:** C2-F12 (mojibake scan as one more assertion in the same gate).

### C4-F05 — A deviation whose cause is a class gets closed at the one cited site, and the class comes back
**Outcome:** live → **REFUTED** · **Repos claimed 4, true 2** · **Target:** audit-review-history.md
**Citations:** `KickCD/docs/audits/2026-09-08/02_DEVIATIONS.md:37`, `AbsorbTracker/docs/audits/2026-08-05/02_DEVIATIONS.md:29`, `LootHistory/…:22`, `ConsumableMaster/docs/audits/2026-09-08/02_DEVIATIONS.md:44`, `AbsorbTracker/…/2026-09-08/…:44`
**REFUTED:** Two of the four repos do not exhibit the mechanism, and AbsorbTracker is the **counter-example** —
`AT-35` already states the class and the denominator ("17 sites, concentrated in…") and the next audit
re-counted the whole class and ratified it. ConsumableMaster is compliance, not defect: `CM-80` is filed as
`derived from CM-79` and closed as one item, which is exactly what `AUDIT.md:703-717` already mandates
("One root, derived dependents listed under it"). So the proposal's second half restates an existing rule and
cites its correct application as evidence of failure. KickCD's self-reported `KICKCD-A-08` is the one genuine
instance, and a SHOULD on stating the class, the enumerating command and the count is defensible on it alone.

### C4-F06 — User-facing sentences assembled from separately routed locale fragments
**Outcome:** live → **REFUTED** · **Repos:** 2 · **Target:** localization.md
**Citations:** `PrettyChat/docs/reviews/2026-08-03/01_FINDINGS.md:144`, `/2026-08-05/…:180`, `/2026-09-07/…:271`, `AuraMaster/docs/reviews/2026-09-11/01_FINDINGS.md:163`, `ConsumableMaster/…:176`
**REFUTED on two independent grounds.** The rule already exists, in the exact section, in almost the exact
words: `localization.md:34` ends "so route the whole sentence with a format placeholder instead" — and both
reviewers who filed the class cited it (`AuraMaster` F-013 quotes "localization-§1: route the whole sentence
with a format placeholder"). And the cost evidence does not hold: the three PrettyChat findings are not one
class — 08-03 and 08-05 are strings **not routed at all**, ordinary routing-SHOULD violations, and only the
09-07 finding is the routed-fragment shape. So it was filed once in that repo, not three times. At most an
example addition to an existing note; the paired kit case flagging `..` beside `L[...]` needs no rule change.

### C4-F07 — WowAddonStandards and wow-addon are rostered, governed by documentation-§8, and never audited
**Outcome:** live → **REFUTED as a standards change; real as a compliance finding** · **Repos:** 2 · **Target:** audit-review-history.md
**Citations:** `standards/ADDONS.md:55`, `:57`, `:58`, `STANDARDS.md:116`, `AbsorbTracker/docs/audits/2026-09-08/02_DEVIATIONS.md:1`, `LibKa0s/…:1`
**REFUTED:** the exemption the finding says is unstated is stated — `documentation.md:634`, inside §8's
*Applies, unchanged* table: "`audit-review-history` | The frozen dated bundles, all three MUSTs on the
deviation register, and the GitHub-issue decision store." So bundles bind these repos already, and the
rotation's third kind is named normatively in three places (`AUDIT.md:62`, `ADDONS.md:52-53`,
`documentation.md:619`). The contrast is also overstated: the range is 1–11 bundles, not 6–11 (AuraMaster 2,
PartyFrameEnhanced 1). What is left is two repos out of compliance with a rule that already exists — an
issue on each repo, not text in a section. The ordering observation is worth carrying into that issue: an
audit of the standards repo lands its findings in the document every other audit measures against.

### C4-F08 — Three collection-wide deviations stopped recurring the moment a vendored gate took ownership
**Outcome:** live → **REFUTED** · **Repos:** 10 · **Target:** TOOLING (evidence, no rule change)
**Citations:** `ConsumableMaster/docs/audits/2026-09-08/02_DEVIATIONS.md:36`, `MultiMeters/…:240`, `PanelMaster/…:35`, `BankLedger/…:30`, `KickCD/…:33`, `:32`, `LibKa0s/…:48`, `automated-tests.md:244`, `AbsorbTracker/docs/reviews/2026-09-07/01_FINDINGS.md:48`, `LootHistory/…:34`
**REFUTED, and the refutation is the useful part.** Five of ten citations are mis-anchored and one is
**counter-evidence presented as evidence** — `LibKa0s` LK-28d is an *open* deviation recording that the
vendored prose gate's scope is too narrow (`SHIPPED = { "LibKa0s", "testkit" }`, no recursion, "216 live hits
are invisible to a green suite"). The quoted six-repo sentence appears three times, not six. The sub-counts
are wrong in both directions (line endings failed **ten** repos, not eight; British spellings were cited in
**four** 2026-09-07 bundles, not eight). Fatally, "all three closed within one cycle" is false for the prose
gate on the very date nominated: PrettyChat PC-75 (49 spellings, 19 files), AbsorbTracker AT-66 (private list
where the standard publishes a canonical one), LibKa0s LK-28d, and KickCD closed only "for the 12 files it
named". **The corrected lesson is narrower and better:** a gate closes a class when it reads the whole
tracked set, and leaves it open when its scope is narrower than the rule's. That qualifier, not the bare
gate-over-prose claim, is what belongs in the argument for the tooling proposals.

### C4-F09 — testing-§9's suite-list pinning MUST is failed in three repos, including the repo that ships the kit
**Outcome:** settled-by-date · **Repos:** 3 → 1 residual · **Target:** LIBKA0S
**Citations:** `LibKa0s/docs/reviews/2026-09-07/01_FINDINGS.md:339`, `:345`, `WhatGroup/…:174`, `:181`, `LootHistory/…:186`, `:198`
**Reason:** The extraction the finding proposes has already shipped. The pin exists in the kit as
`Kit.assertSuiteInventory` (`LibKa0s/testkit/framework.lua:730`, exposed at `:459`, run first whenever
`opts.dir` is given explicitly, `:1191`), and LibKa0s', LootHistory's and AbsorbTracker's runners all pass
`dir = "tests/"`, so it runs in all three — including LibKa0s, the repo the review cited as failing it. The
reviews predate the kit gaining the check. **One residual goes to the watch list:** `WhatGroup/tests/run.lua`
does not pass `dir`, so the pin never runs there. Note that it overlaps C10-F03's territory — the kit now has
the pin, and the live defect in it is the name-keyed shadowing bug, not its absence.

---

## Category 5 — Standard-internal contradictions

### C5-F01 — library-stack-§7 both binds `automated-tests` and exempts the two documents that section mandates
**Outcome:** live → **REFUTED** · **Repos:** 1 · **Target:** library-stack.md
**Citations:** `library-stack.md:212`, `:219`, `:224`, `:226`, `:198`, `automated-tests.md:32`, `:33`, `:179`, `:97`, `LibKa0s/docs/automated-tests/RESULTS.md:1`, `LibKa0s/CLAUDE.md:200`, `:201`, `LibKa0s/docs/audits/2026-09-07/04_TECHNICAL_DESIGN.md:246`, `/2026-09-08/02_DEVIATIONS.md:78`, `documentation.md:648`
**REFUTED:** `documentation.md:178-180` and `:338-340` both disclaim authorship of the five
verification-and-record documents — "required by `testing` and `automated-tests` rather than by this
section's tier model … filing them under a tier anyway would misstate where their requirement comes from."
So §7's *Does not apply* bullet exempts documentation-§3's **tier claim** over those filenames, not the
underlying MUSTs, which bind through `automated-tests` sitting in *Applies, unchanged*. The tie-break the
finding says is missing is that same sentence, and `documentation.md:648` demonstrates the drafter applying
it deliberately in the mirror case. LibKa0s shipping both documents is compliance, not a hand-resolution.
The most that is left is an editorial clause repeating the cross-reference inline.

### C5-F02 — `packaging`'s ignore template is a flat MUST while its own strong form binds only entries present in the repo
**Outcome:** live → **UPHELD (reframed, count corrected)** · **Repos claimed 8, true 7** · **Target:** packaging.md
**Citations:** `packaging.md:19`, `:20`, `:33`, `:34`, `:23`, `LootHistory/docs/audits/2026-09-08/04_TECHNICAL_DESIGN.md:164`, `/02_DEVIATIONS.md:57`, `MultiMeters/docs/audits/2026-09-07/02_DEVIATIONS.md:84` (MM-A-04), `PanelMaster/.pkgmeta:11`, `BankLedger/.pkgmeta:19`, `PrettyChat/.pkgmeta:24`, `WhatGroup/.pkgmeta:15`, `LootHistory/.pkgmeta:16`, `PartyFrameEnhanced/.pkgmeta:12`, `AuraMaster/.pkgmeta:12`
**Verification:** All citations resolve; LootHistory's audit does ask verbatim for "one sentence… saying the
list is a template whose entries bind only when the entry exists", and two audits filed it from opposite
directions. `AUDIT.md:210-212` bakes the split into the runner — `tools` gated on `[ -d tools ]`,
`.claude .superpowers` enumerated unconditionally. Two reframings: the two bullets are jointly *satisfiable*
(listing both always breaks neither), so this is **under-specification and inconsistent treatment** rather
than a strict contradiction; and four repos are compliant under either reading, so the readings actually
diverge in seven. One fact that tempers severity: `git ls-files .claude` and `.superpowers` return zero in
all eleven addons, so no package ships either today.
**Owner call — both readings and their counts are in `04_PROPOSALS.md`.**

### C5-F03 — The standard's inventory of LibKa0s disagrees with itself in four places and with the shipped library in all of them
**Outcome:** merged-away → **C8-F02** · **Repos:** 5 · **Target:** library-stack.md
**Citations:** `library-stack.md:82`, `:91`, `:94`, `:113`, `options-ui.md:13`, `anti-patterns.md:54`, `testing.md:279`, `LibKa0s/LibKa0s/LibKa0s.xml:1`, `OptionsTabs.lua:1`, `WidgetsDragHandle.lua:1`, `LibKa0s/docs/audits/2026-09-07/04_TECHNICAL_DESIGN.md:242`, plus four consumers' vendored copies
**Reason:** The same drift from the contradictions angle; its four claimed disagreements are the union of
C8-F01/F02/F04/F05. C8-F02 carries it because it is unambiguous where this is marked ambiguous on a reading
the tree does not support (§7's own additive-contract MUST permits a major to gain files, and all eleven
addons vendor both today). **The durable half carries over and is the more valuable one:** stop restating the
library's file list in prose nothing checks — make §7 the only place the inventory is written and derive it
from `LibKa0s.xml`, either generated the way `tools/gen-api-members.lua` generates the API documents or
asserted by an `AUDIT.md` check that diffs the two. Its closing observation is the argument for that half:
this is the second time the same table has fallen behind, and the first correction bought four weeks.

---

## Category 6 — `state:will-not-do` issues

### C6-F01 — Five repos decline LibKa0s-Perf-1.0 for one structural reason
**Outcome:** merged-away → **C7-F01** · **Repos:** 6 · **Target:** performance.md + LIBKA0S
**Citations:** BankLedger#9, LootHistory#22, PanelMaster#31, PrettyChat#10, WhatGroup#7, LibKa0s#5; `LibKa0s/LibKa0s/Perf.lua:634-665`; `BankLedger/modules/Ledger.lua:620`; `PanelMaster/modules/Canvas.lua:459-486`
**Reason:** Same rule, same five repos, same ambiguity — one interview, not two. C7-F01 carries because it
measures against the live registers and catches the two repos leaving by a door §1 says does not exist. What
carries over and must not be lost: the single structural cause — `Perf.lua:634-665` arms its window only
while `UnitAffectingCombat("player")`, so an out-of-combat addon's buckets read 0.000 by construction and
`suspend` would destroy the data the addon exists to capture — and the library half, which C7-F01 entirely
lacks: LibKa0s#5 already names the out-of-combat capture variant and names BankLedger and LootHistory as the
reason, with one open design question (what bounds the window with no regen edge).

### C6-F02 — performance-§12 exemption pages cannot re-run their own evidence
**Outcome:** live → **REFUTED** · **Repos claimed 4, true 3** · **Target:** TOOLING
**Citations:** BankLedger#15, LootHistory#29, PrettyChat#14, WhatGroup#18; `BankLedger/docs/performance.md:39`; `LootHistory/docs/performance.md:40-60`; `PrettyChat/docs/performance.md:33-50`; `WhatGroup/modules/Frame.lua:275,664-665,315-330,351`
**REFUTED on all three grounds.** Only three repos hold a ratified §12 exemption — WhatGroup's was
**retired on 2026-09-08** and replaced by an ordinary deviation, which its own register says. Every code
citation is dead against today's tree (BankLedger's timer is `core/ItemSetup.lua:67` and the page names it;
LootHistory's page states thirteen registrations and five timers and both re-measure correctly; PrettyChat's
page prints its greps and says explicitly what does not survive; WhatGroup's ticker is armed *behind* the
visibility gate at `modules/Frame.lua:482,486`). The declines the finding reads as "repair, not re-check" say
the opposite in their own bodies — the repair shipped under M4-24. And the fallback shape is already
`audit-review-history.md:41`'s third MUST, which evaluates every row's re-check trigger against the tree —
demonstrably working, since that is how WhatGroup's row was retired.

### C6-F03 — `RenderGrid` is declined or blocked in four repos, and the two named blockers are the same both times
**Outcome:** live → **REFUTED** · **Repos claimed 4, true 3** · **Target:** LIBKA0S
**Citations:** AbsorbTracker#23, KickCD#11, KickCD#10, LootHistory#20; `LibKa0s/LibKa0s/OptionsWidgets.lua:534-585`; `AbsorbTracker/settings/About.lua:93`; `KickCD/settings/Spells.lua:888-904`
**REFUTED:** the load-bearing claim — "exactly one consumer, so the contract has been tested against exactly
one shape" — was true when the issues were written on 2026-08-01 and is false now. `RenderGrid` has at least
four live consumers across four repos (AuraMaster ×10 call sites, AbsorbTracker, MultiMeters ×2, KickCD),
and KickCD, listed as a repo that "put it down", calls it in `settings/General.lua:267`. Both blockers are
stale in their own cited hosts: KickCD deleted the hand-built scroll frame (`settings/Spells.lua:103`,
`:1114-1119`), and AbsorbTracker's dense-text list moved to `O.BuildLandingPage` (`settings/About.lua:24-36`,
36 lines of data). Line numbers in the library citation are also 1000 lines stale. A `parent` parameter may
still be a symmetry nicety; no host is blocked on it today.

### C6-F04 — `O.RestoreAllDefaults` declined in three repos: a global reset must reach state the schema does not hold
**Outcome:** live → **REFUTED** · **Repos claimed 3, true 6 declining** · **Target:** LIBKA0S
**Citations:** BankLedger#10, PanelMaster#30, WhatGroup#10; `LibKa0s/LibKa0s/Options.lua` (RestoreAllDefaults); PanelMaster `Sl:CliResetAll`
**REFUTED:** both requested features already exist. The host-supplied extra-reset callback is
`afterRestoreAll()`, documented at `Options.lua:515-519` and invoked at `:1109`; and the library never writes
storage — it calls the host's `applyDefault(row)` (`:488`) — while `sessionOnly` is the pivot of the whole
algorithm (`:1090`, reasoned at `:1055-1058`), alongside `skipRestoreAll` and `resetProfile`. The trailing
standard change also already exists verbatim: `options-ui.md:240-242` is "Global reset — one act, one
wording", naming the footer control, the header Defaults button and `/<slash> resetall` as one implementation.
WhatGroup#10's body is an empty migration stub stating no reason at all, and its real reason
(`settings/Schema.lua:630-700`) is a third, unrelated one. Six repos decline, not three.

### C6-F05 — `O.InlineButtonPair` declined in three repos: it owns the row
**Outcome:** live → **REFUTED** · **Repos claimed 3, true 1** · **Target:** LIBKA0S
**Citations:** BankLedger#10, PanelMaster#30, WhatGroup#9; `LibKa0s/LibKa0s/Options.lua` (`O.BUTTON_PAIR_REL`)
**REFUTED:** only PanelMaster matches the statement. BankLedger deleted its host maker and now routes through
`O.InlineButtonPair` (`settings/Panel.lua:65-68,154`); WhatGroup's `Helpers.InlineButton` creates its **own**
Flow row exactly like the library maker and does not read `BUTTON_PAIR_REL` at all — its stated reason is a
fixed 160px left-aligned width. The library already expresses the requested shape: the `pairWith` hook
(`OptionsWidgets.lua:1578`, dispatched at `:254-267`) takes a maker receiving the parent row, and AuraMaster
uses it that way (`settings/Layout.lua:235-245`). And the anti-pattern framing inverts the rule —
`options-ui.md:135` explicitly sanctions reading the constant off the instance.

### C6-F06 — Three repos decline LibKa0s-Core's window chrome, and the library's SKIN is the outlier
**Outcome:** live → **REFUTED** · **Repos claimed 3, true 1 live decline** · **Target:** standalone-windows.md
**Citations:** BankLedger#5, LootHistory#19, PanelMaster#27; `BankLedger/modules/Browser.lua:67-86`; `LootHistory/modules/Browser.lua`
**REFUTED:** both code citations point at code that says the opposite — `BankLedger/modules/Browser.lua:61-72`
records every value as `Core.SKIN`, "byte for byte… Delegated rather than restated", and LootHistory's
`B:ApplySkin` delegates to `Core.ApplySkin` (`core/CoreSetup.lua:152`). The standard has already done both
things the proposal asks it to choose between: `standalone-windows.md`'s "The Ka0s window edge" subsection
makes the flat 1px WHITE8x8 identity normative from Core minor 3, and its four-condition reasoned-decline
bullet settles the close button — and the section states in advance that LootHistory's decline **expired with
v1.10** and that "any document still naming the two together is a release stale." One live decline, already
ratified with a re-check trigger.

### C6-F07 — `D:ConsoleCheckbox()` declined in two repos: the library cannot know the row is session-only
**Outcome:** live → **REFUTED** · **Repos:** 2 · **Target:** LIBKA0S
**Citations:** BankLedger#6, PanelMaster#28; `BankLedger/settings/Schema.lua`; `PanelMaster/settings/Schema.lua`
**REFUTED:** the central claim — the surface is left "with no consumer" — is false: AuraMaster
(`settings/General.lua:86`) and AbsorbTracker (`settings/General.lua:87-89`) both consume it in shipping
settings code and publish it from their library-absent stubs. The better of the two requested changes already
exists in the shape asked for: the `MasterControls` composer emits a `debugConsole` row with its own label,
tooltip and `sessionOnly = true` (`OptionsCompose.lua:493-499`), and `Options.lua:1090`'s reset walk keeps
exactly the sessionOnly rows — the Defaults reach BankLedger#6 worried about. Both "declining" repos are on
that composer now, so the declines describe a superseded arrangement. `debug-logging.md:22,73,86` and
`options-ui.md:346` already fix the rest.

### C6-F08 — Three LibKa0s majors are declined near-universally, and the library has written down why
**Outcome:** live → **REFUTED on the actionable half** · **Repos claimed 8, true 7** · **Target:** library-stack.md
**Citations:** LibKa0s#10; AbsorbTracker#26/#27/#28, ConsumableMaster#28, KickCD#12, PanelMaster#43/#46, PrettyChat#11/#13, WhatGroup#12; `AbsorbTracker/settings/UnitPanel.lua:190-192`; `PanelMaster/settings/PanelEditor.lua:525-536`
**REFUTED in part.** Counts: Item is declined in **seven** repos (MultiMeters#20 missed), and seven addons
exhibit declines, not eight. The fatal defect is in proposal (2): "a record shape the collection invented and
uses consistently" is false — **20 of 81** `state:will-not-do` issues across the collection carry a "What
would reopen this" section, and **zero of the twelve** Item and Pool declines do, including four of the
proposal's own citations. So that MUST would retroactively breach 61 existing issues rather than codify a
practice. Proposal (1) is largely covered already: `library-stack.md:46` carves LibKa0s out of the prune
rule, and the "a decline owes no register row" idiom is verbatim at `slash-commands.md:36,300,303`. The two
stale source line numbers are cosmetic; the content is in the named files.

### C6-F09 — layout-§1's 1500-line cap: declined wholesale in one repo, triaged-but-never-done in three others
**Outcome:** merged-away → **C7-F03** · **Repos:** 4 · **Target:** layout.md
**Citations:** MultiMeters#46, LibKa0s#32/#33/#7, PanelMaster#47; `MultiMeters/settings/Schema.lua:3080` et al; `LibKa0s/LibKa0s/OptionsWidgets.lua:2812`; `PanelMaster/docs/automated-tests/RESULTS.md:157`
**Reason:** Same rule, same ambiguity, and C7-F03's measurements are current where these are a week stale
(OptionsWidgets 2812 → 3922, test_options_widgets 3219 → 4086). What carries over: MultiMeters#46's wholesale
decline of fifteen files on the grounds that ~21,000 lines would move for no player-visible payoff — the only
wholesale refusal of a rule in the collection; LibKa0s#7's argument that a library file costs more to split
(LibKa0s.xml load order, major boundaries, every consumer vendoring `libs/` whole per anti-pattern #48) and
that breadth without knots (worst CCN 11, average 3.4) is not what the cap protects against, which is the
candidate narrowing worth putting to the owner; and PanelMaster#47's proof that a split trigger recorded only
in a generated per-run document never fires (1091 → 1350 → 1488 after a watch-list row said to execute it).

### C6-F10 — LibKa0s has no localization layer, and a host's locale overrides for library strings silently do nothing
**Outcome:** live → **REFUTED as a standards item** · **Repos claimed 4, true 2** · **Target:** LIBKA0S
**Citations:** ConsumableMaster#16, LibKa0s#6, PanelMaster#26, PartyFrameEnhanced#9; `ConsumableMaster/libs/LibKa0s/Slash.lua` (parseBool/allowedText/parseColor); `PanelMaster/locales/enUS.lua:8-11`
**REFUTED:** the proposed standards line already exists and the finding cites its own anti-pattern number —
`library-stack.md:120-123` MUST NOTs editing anything under `libs/`, "including a one-line fix that is
plainly correct and plainly urgent", and anti-patterns #45/#47 say it again. "Cannot take effect" is also
false: WhatGroup declares the same `ERR_BOOL` override and it **does** work, through the descriptor's
documented `parse` hook (`WhatGroup/settings/Slash.lua:199-207,248`, asserted at
`tests/test_libka0s.lua:456-458`). And the count composites one Slash defect with two unrelated localization
issues. What remains is a genuine LibKa0s ergonomics defect, already filed as ConsumableMaster#16 and
LibKa0s#6 — library work on the library's schedule, not a rule eleven repos are audited against.

### C6-F11 — Three issues in two repos carry `state:triaged` while closed
**Outcome:** live → **REFUTED as a standards change** · **Repos claimed 2, true 3** · **Target:** TOOLING
**Citations:** MultiMeters#21, MultiMeters#4, AuraMaster#10; `audit-review-history.md:88`
**REFUTED:** the mechanical ask already exists. `wow-addon/commands/issue-summary.md:74` already reports
exactly these three shapes — "a `state:triaged` issue that is closed, a `state:done` issue that is open, an
issue carrying two `state:` labels" — as an Inconsistencies list, and it deliberately **escalates rather than
repairs**, with the reason stated: "The label and the open/closed state encode the same decision twice, so a
disagreement means one of them is wrong and a human has to say which." The evidence supports that reasoning
rather than defeating it. The invariant itself is already normative in the status table's *Issue state*
column, so a closed `state:triaged` issue is already a violation. Scope note: the violation exists in **three**
repos and five issues (adding MultiMeters#24 and KickCD#15), which widens the cleanup and does not rescue the
proposal — maintainer triage, not a rule.

### C6-F12 — Two collective refusals the standard has already absorbed
**Outcome:** settled-by-date · **Repos:** 4 · **Target:** (none — record only)
**Citations:** ConsumableMaster#17, PrettyChat#7, WhatGroup#5, WowAddonStandards#2; `toc-file.md:23,30`; `layout.md:57`; `toc-file.md:110`
**Reason:** Confirmed settled against v2.62.1, and the finding correctly predicted its own outcome. `X-Wago-ID`
and `X-WoWI-ID` are now MAY, "include each only when the addon is actually listed on that platform" — three
refusals answered by one rule change. And `layout.md:57` states the single folder order plus the defect clause
verbatim: "if the two ever disagree that is a defect in this document rather than a choice an addon gets to
make", with `toc-file.md:110` agreeing. Recorded here so the next run's date filter finds them resolved
rather than re-deriving three repos of strong-looking evidence against a rule that no longer says what the
evidence refuses. **Residual for the repo, not this harvest:** PanelMaster#22 and #23 are still open against a
CurseForge id that does not exist until first upload, which toc-file now explicitly calls compliant.

### C6-F13 — A GCD-suppression curve is duplicated line-for-line between two addons
**Outcome:** live → **REFUTED** · **Repos:** 2 · **Target:** LIBKA0S
**Citations:** ConsumableMaster#26; `ConsumableMaster/modules/MacroBarButton.lua`, `core/Constants.lua`; `KickCD/modules/IconGrid_Render.lua`, `core/Constants.lua`
**REFUTED:** "line-for-line" holds only for the ~12-line curve builder. The apply sides have **already
diverged, deliberately**: KickCD evaluates against the cooldown's **total** duration
(`modules/IconGrid_Render.lua:609-613,624`) because reading remaining "brightens the icon ~1.5s early" on an
interrupt, while ConsumableMaster reads **remaining** (`modules/MacroBarButton.lua:196-197`) and records the
result as an "Accepted limitation (do not try to fix)". That is a correctness disagreement, which
`library-stack.md:170-179` forbids promoting outright — and `:182-186` already mandates the exact mitigation
both repos applied, a deliberate duplication commented as one at both copies. The decline is structural after
all, not scheduling. The useful follow-up is addon-side: ConsumableMaster considering KickCD's evaluate-by-total fix.

### C6-F14 — `wow-addon` has no issue store at all
**Outcome:** live → **REFUTED as a standards change** · **Repos claimed 2, true 1** · **Target:** TOOLING
**Citations:** wow-addon (zero issues, zero `state:` labels); WowAddonStandards#5; `wow-addon/commands/harvest-standards.md`
**REFUTED:** the obligation already exists — `documentation.md:637`, inside §8's *Applies, unchanged* table,
names the GitHub-issue decision store in as many words, and `ADDONS.md:58` rosters wow-addon under
documentation-and-tooling repos. So this is a compliance deviation **in wow-addon**, to be filed there, not
text for a section; the proposed change is itself an operational chore ("run `/wow-addon:issue-audit` once"),
not a rule. The count is also wrong: WowAddonStandards carries seven issues of which four are
`state:will-not-do`, so it is compliant and only one repo exhibits the pattern. The third citation
misattributes the scope claim to the playbook, which never uses the phrase.
**The underlying fact is confirmed and worth carrying:** every cross-repo count in this harvest is measured
against thirteen issue stores, and the missing one is the repo whose contents decide how the other thirteen
are read.

### C6-F15 — Vendored standards text gets locally respelled, and nobody has decided whether the change belongs upstream
**Outcome:** below-bar (watch list) · **Repos:** 2 · **Target:** documentation.md
**Citations:** PanelMaster#19; `PanelMaster/docs/agent-context.md`; `AuraMaster` commit 329e1a3
**Reason:** One open issue plus one commit resolving the mirror case, and the date filter weakens it further:
the single instance is moot, because anti-pattern #49 forbids `docs/agent-context.md` existing in a repo at
all ("under that name or any other") and documentation-§3 requires the pack be fetched at runtime. So
PanelMaster#19's question is settled by a different rule. Promotes the moment a second repo runs a spelling
sweep over genuinely vendored text (`libs/` or `tests/_kit/`). The mechanical half is independently cheap and
can be taken any time — `revendor-standards` already excludes `libs/`, `tests/_kit/` and the frozen bundles.

---

## Category 7 — Rules nobody satisfies, and rules nobody needs

### C7-F01 — performance-§1's wiring MUST is declined by 5 of 11 addons, and 2 leave by a door §1 says does not exist
**Outcome:** live → **REFUTED** · **Repos:** 5 · **Target:** performance.md
**Citations:** `BankLedger/docs/ARCHITECTURE.md:461`, `LootHistory/…:470`, `PrettyChat/…:268`, `PanelMaster/…:349`, `WhatGroup/…:496`, `performance.md:7`, `:13`, `AbsorbTracker/core/PerfSetup.lua:1`, `MultiMeters/docs/ARCHITECTURE.md:452`
**REFUTED:** the "off-book third exit" does not exist as an off-book thing. `documentation.md:137-153`
mandates `## Documented deviations` as the single home for a ratified deviation against **any**
`filename-§N` rule, and other sections rely on it that way (layout-§1 names a ratified row as one of three
terminal states). PanelMaster's row citing `performance-§1` is therefore the sanctioned exit, taken
correctly, with a re-check trigger — and performance-§12 itself routes through the same register. The
WhatGroup half is the standard's own queued question: `open-evolutions.md:25-49` already holds "What
`performance-§12`'s re-check trigger should do with a window-bounded ticker", including the exact asymmetry
and the candidate shape, and WhatGroup's row says an amendment is proposed upstream. Also factually: WhatGroup
**does** ship `tests/perf.lua` (built 2026-09-16), contra the statement.
**Absorbed:** C6-F01.

### C7-F02 — events-frames-taint-§1 forbids private event frames; addons create them, and the one addon that obeys documented what obedience costs it
**Outcome:** live → **UPHELD (count corrected, and reframed)** · **Repos claimed 5, true 4 touched / 3 violating** · **Target:** events-frames-taint.md §1
**Citations:** `events-frames-taint.md:7`, `AbsorbTracker/core/AbsorbTracker.lua:152` + `docs/ARCHITECTURE.md:601`, `KickCD/core/Util.lua:438` (called at `modules/IconGrid.lua:821`, `modules/Castbar.lua:1030`), `LootHistory/modules/Attribution.lua:367`, `AuraMaster/modules/TimedSpells.lua:13`, `PartyFrameEnhanced/docs/ARCHITECTURE.md:332`, `slash-commands.md:186`, `testing.md:32`
**Verification:** Three repos create a frame *just for events* — AbsorbTracker (ratified row), KickCD and
LootHistory (both registers read end to end; neither carries an events-frames-taint row). PartyFrameEnhanced
is **not** a violator and its own row says so: "The frames are the elements themselves, not frames made for
events." AuraMaster obeys and its module header records the bill. The reframing matters: the standard has
**already legislated around** the frames §1 forbids, in two sections the sweep did not open —
`slash-commands.md:186` requires the teardown to unregister "every … `RegisterUnitEvent` … **including the
per-unit frames**", and `testing.md:32` makes recording `RegisterUnitEvent` a mock-fidelity MUST because "a
no-op `RegisterUnitEvent` lets a widened or dropped per-unit event filter pass the entire suite". So this is a
live contradiction across three sections, not a missing exception — which is a cheaper and better-supported
change than the proposal argues for.
**Owner call — both readings and their counts are in `04_PROPOSALS.md`.**

### C7-F03 — layout-§1's cap: AuraMaster is over it in four files with no terminal state, and the issue branch has absorbed 2× growth
**Outcome:** live → **REFUTED as a standards change; a narrow gap survives** · **Repos:** 3 · **Target:** layout.md
**Citations:** `layout.md:57`, `:67`, `AuraMaster/settings/GeneralSpells.lua:1528`, `tests/test_pages_general.lua:1761`, `test_database.lua:1702`, `test_filtercompiler.lua:1567`, `LibKa0s/LibKa0s/OptionsWidgets.lua:3922`, `tests/test_options_widgets.lua:4086`, LibKa0s#16/#32/#8/#33, `PrettyChat/docs/ARCHITECTURE.md:78`, `MultiMeters/tests/test_provider.lua:1500`
**REFUTED in both directions.** Direction A is not a standards proposal — `layout.md:67` and anti-pattern #22
already say that an over-cap file nothing remarks on is what an audit files against, so AuraMaster's four are
an audit finding for its next bundle. Direction B is false on its face: the 1000–1500 band already carries
two MUSTs (`performance.md:236` requires the release watch list to name every file in the band with a
one-line disposition, `:278` covers newly-entered files) and a generated column (`automated-tests.md:268`),
in sections the sweep did not open — so "no obligation and no check" would delete or duplicate a live rule.
The band also holds 69 files across eleven repos, not "60+ across 9". **The narrow gap that does survive:**
the three-release expiry on a watch-list disposition reaches "accepted" but not "already tracked as <id>", so
a long-lived issue sidesteps the clock — which is exactly LibKa0s' two files, 1989/2398 → 3922/4086 across two
executed peels. That belongs in `automated-tests`, not `layout`.
**Absorbed:** C6-F09.

### C7-F04 — RETIREMENT QUESTION: `public-api` has never been engaged and has never been cited
**Outcome:** live → **REFUTED** · **Repos claimed 12, true 11** · **Target:** public-api.md
**Citations:** `public-api.md:6`, `:10`, `LootHistory/docs/audits/2026-08-04/02_DEVIATIONS.md:109`, `/2026-08-05/…:134`, `WhatGroup/…/2026-08-04/…:231`, `/2026-09-07/…:284`, `/2026-09-08/…:340`
**REFUTED:** LibKa0s **does** engage it, and the standard says so in terms — `library-stack.md:248`:
"`public-api` | Binds, and is closer to load-bearing here than in any addon: a library major **is** a public
API… which is the library's form of the `NS.API.v1` contract." That surface exists (`LibKa0s/docs/api/`), so
a `NS.API` grep cannot see it. The corpus count is also wrong and wrong in kind: ten citations, not seven,
and one of them is a graded finding rather than an N/A line (LibKa0s LK-27). The preferred option is already
in the standard too — `AUDIT.md:699-701` says a section outside a rule's scope "is not an entry at all".
Retiring the section would silently break `library-stack-§7`'s row.

### C7-F05 — RETIREMENT QUESTION: `launcher` has never been cited in a single deviation bundle
**Outcome:** live → **REFUTED** · **Repos:** 11 · **Target:** launcher.md
**Citations:** `launcher.md:1`, `AbsorbTracker/core/LauncherSetup.lua:1`, `WhatGroup/…:1`, `PrettyChat/…:1`, `AbsorbTracker/AbsorbTracker.toc:6`, `WhatGroup/WhatGroup.toc:6`, `performance.md:13`
**REFUTED by the calendar.** `launcher.md` was added on **2026-09-16** (WowAddonStandards 59c5757, v2.52.0);
the newest audit bundle anywhere in the collection is dated **2026-09-15**. No audit has ever run against a
standard containing the section, so zero citations carries no information about adoption or enforcement, and
the inference that the section is uncited *because the library discharges it* is indistinguishable from
"nobody has read it yet". The proposal then generalises from that inference to restructuring N sections. The
compliance facts are confirmed (11/11 ship `core/LauncherSetup.lua`, 11/11 point `## IconTexture` at their own
logo). The design question — whether a section discharged by a vendored major should be re-expressed as a
library contract plus a one-line adoption MUST, as `performance.md:11` already does — is legitimate and must
be argued on its merits after the next audit rotation.

### C7-F06 — localization-§3's state 2 requires a register row, and two English-only addons never got one
**Outcome:** live → **REFUTED** · **Repos exhibiting the defect: 0** · **Target:** TOOLING
**Citations:** `localization.md:56`, six repos' register rows, `ConsumableMaster/docs/ARCHITECTURE.md:490`, `PartyFrameEnhanced/docs/ARCHITECTURE.md:328`
**REFUTED:** both "English-only" repos are in terminal state 1 (routed) and owe nothing. ConsumableMaster
routes through `KCM.L` — `locales/enUS.lua:13-16` does `local KCM = NS; KCM.L = L`, eleven source files alias
it and there are 314 `L[` call sites; the sweeper grepped the literal token `NS.L`. PartyFrameEnhanced has 14
`NS.L` references and 267 `L[` call sites, and `settings/Slash.lua:10` states "Every word a player reads goes
through NS.L". So every one of the eleven addons sits in one of §3's two terminal states and there is nothing
to gate. The verification is also a live demonstration of why the proposed check is dangerous: its first half
scores ConsumableMaster zero and would redden a fully routed addon on every green run.

### C7-F07 — architecture-§5 says every player preference routes through the schema helper; three repos ratified rows saying it cannot
**Outcome:** settled-by-date · **Repos:** 3 · **Target:** architecture.md
**Citations:** `architecture.md:1`, `KickCD/docs/ARCHITECTURE.md:394`, `PanelMaster/…:352`, `LootHistory/…:469`, `LootHistory/modules/AuctionPrice.lua:116`
**Reason:** The clearest catch of the run — it would have been re-proposed confidently without opening the
section. Today's §5 names the missing fourth case explicitly and rules on it: "A preference the player sets on
a member — a color, a size, a toggle, a position, an art choice — is not a registry either, whatever
collection it lives in: it is a setting, and a setting with no row is a missing row… A missing row fails the
drive-all-of MUST and the schema-row helper MUST both, unless it carries a Documented deviations row." It also
rules on LootHistory's exact shape (a priority cascade over known providers). All three cited repos hold
exactly the ratified rows the amended rule requires, so all three are compliant and the missing case is no
longer missing. The reachability complaint survives as a per-repo quality question, already on their rows.

### C7-F08 — events-frames-taint-§8's pre-formatting SHOULD is failed at scale by 4 addons
**Outcome:** settled-by-date · **Repos:** 4 · **Target:** events-frames-taint.md
**Citations:** `AbsorbTracker/docs/ARCHITECTURE.md:603`, `PanelMaster/…:350`, `WhatGroup/…:498`, `KickCD/…:392`
**Reason:** Today's §8 carries an explicit scoping paragraph that had this argument and resolved it:
pre-formatting is "a MUST NOT at a call site whose arguments can reach a value read from one of the
combat-protected APIs named below, and a SHOULD NOT everywhere else", followed by the reasoning that is almost
word for word the finding's own reading B — "Outside the trigger set it is a SHOULD, and the reason is drift,
not secrets… a recurring finding across roughly fifty such sites collection-wide costs triage and changes no
behavior." The section names the same ~50-site population the four rows describe and states why it keeps the
SHOULD anyway. Reading A's rewrite is already declined upstream. The one live residual is carried by C3-F04:
whether `C_Spell.GetSpellCooldown` joins the trigger set, which would move some sites from SHOULD to MUST.

---

## Category 8 — LibKa0s ↔ standard drift

### C8-F01 — The library ships eighteen files; the standard says seventeen, in two places
**Outcome:** merged-away → **C8-F02** · **Repos:** 2 · **Target:** library-stack.md
**Citations:** `library-stack.md:82`, `EXECUTIVE_SUMMARY.md:56`, `LibKa0s/LibKa0s/LibKa0s.xml:2`, `LibKa0s/tests/majors.lua:16`
**Reason:** One line of the same ripple, and it must not be applied separately for the reason C8-F06 gives:
the count lives in several copies and all of them move together or the next agent completes the list from
whichever copy it read. Verified — eighteen `.lua` under `LibKa0s/LibKa0s/` and the XML loads all eighteen.
The finding missed a third copy of the same sentence, now folded into the carrier: `open-evolutions.md:13`
also reads "twelve majors across seventeen files". Its closing suggestion is the durable one: state the count
as a pointer to the gate-backed `tests/majors.lua` rather than as a literal.

### C8-F02 — `OptionsTabs.lua` is shipped, load-bearing and named nowhere, and normative file lists are wrong because of it
**Outcome:** live → **UPHELD** · **Repos:** 2 (the drift is standard-vs-library) · **Target:** library-stack.md + the ripple
**Citations:** `options-ui.md:13`, `library-stack.md:94`, `anti-patterns.md:54`, `NEW_ADDON_CONTEXT.md:489`, `:817`, `:1037`, `LibKa0s/LibKa0s/OptionsTabs.lua:1`, `:40`, `LibKa0s/tests/majors.lua:70`, `:74`, `STANDARDS.md:57`, `library-stack.md:82`, `:103`, `:113`, `EXECUTIVE_SUMMARY.md:56`, `open-evolutions.md:13`
**Verification:** Confirmed against the tree. Eighteen `.lua` files ship, the XML loads all eighteen, the
Options major spans five files and Widgets two. Every cited count is wrong in the live text, and the
verification found **two more the sweeps missed** — `library-stack.md:103` also says "ten of the eleven majors
refuse to register without Core", and `open-evolutions.md:13` carries a third copy of the file count. The
tab-strip rule is options-ui-**§13** (`options-ui.md:279`), not §12; the page banner is §14. **Clear win:**
pure factual correction against the tree, applicable without a ruling, zero addon rollout (`OptionsTabs.lua`
is byte-identical in LibKa0s and all eleven addons — md5 `deef16f2e6a8abc072dedafdf53c53d4`).
**Absorbed:** C5-F03, C8-F01, C8-F04, C8-F05, C8-F06.

### C8-F03 — `Widgets.DragHandle` was extracted because two addons hand-built it, and the standard still does not mention it
**Outcome:** live → **UPHELD (count corrected, scope widened)** · **Repos:** 3 consumers · **Target:** library-stack.md
**Citations:** `LibKa0s/LibKa0s/WidgetsDragHandle.lua:1`, `LibKa0s/docs/api/Widgets/members-9.2.json`, `LibKa0s/tests/majors.lua:48-51`, `library-stack.md:91`, `AuraMaster/modules/Anchors.lua:324`, `:416`, `ConsumableMaster/modules/MacroBar.lua:176`, `KickCD/modules/Castbar_Handle.lua:88-89`
**Verification:** The file ships, is version-paired (`__dragMinor`), and publishes `DragHandle` and
`DRAG_HANDLE`; `grep -rn "DragHandle" WowAddonStandards` returns **zero** hits. The extraction commit is
"Widgets minor 10: lib.DragHandle, the unlock anchor both addons hand-built" — the two-consumers-same-semantics
shape `library-stack.md:148-152` sets as bar 1. Three addons consume it and eight do not, and nothing in the
standard would tell the next one to. Four of seven cited lines were wrong-location (three pointed at
`test_prose` entries in runner lists) but the content is in the named files. The inventory half **rides with
C8-F02's ripple**; what stays live here is the separable question of whether the drag anchor earns a rule of
`ReorderList`'s kind — options-ui-§18 is scoped to list ordering and does not reach a frame-move handle, so
nothing currently covers it.

### C8-F04 — Anti-pattern #48 still counts the library at five majors
**Outcome:** merged-away → **C8-F02** · **Repos:** 2 · **Target:** anti-patterns.md
**Citations:** `anti-patterns.md:54`, `library-stack.md:113`, `LibKa0s/tests/majors.lua:16`, `LibKa0s/LibKa0s/Lifecycle.lua:49`, `Pool.lua:45`
**Reason:** One line of the same ripple. Verified: #48 reads "Four of LibKa0s's five majors return before
`LibStub:NewLibrary`", the five-major era, against twelve majors of which eleven gate on Core — and
`library-stack.md:113` states the correct figure one file away, so the standard contradicts itself on the same
fact. Not decorative: #48 is one of the most-cited entries and that sentence is what an agent uses to decide
whether an absent module is expected behaviour or a bug. Its instruction to re-check every cardinal in #47 and
#48 against `tests/majors.lua` is sound and has already been extended once by the verification.

### C8-F05 — "Three of the ten gate on Core without calling a member" — both numbers are wrong
**Outcome:** merged-away → **C8-F02** · **Repos:** 2 · **Target:** library-stack.md
**Citations:** `library-stack.md:113`, `LibKa0s/LibKa0s/Env.lua:31`, `Launcher.lua:43`, `Pool.lua:42`, `Lifecycle.lua:49`, `Slash.lua:17`, `DebugLog.lua:23`, `Perf.lua:22`
**Reason:** One line of the same ripple, and the most self-evidently wrong: the denominator contradicts the
first half of its own sentence ("Eleven of the twelve majors need Core … and three of the ten gate on it").
The numerator is wrong too, in the direction that weakens the argument — **eight** of the eleven dependents
read nothing but Core's `MINOR` floor probe. The sentence is arguing that the floor makes a partial payload
fail whole rather than mixed, and understating it as three of ten makes the majority behaviour look like an
edge case. Keep `Lifecycle` as the named example, since its own header gives the reason.

### C8-F06 — The scaffolding pack tells a new addon the library has eleven majors
**Outcome:** merged-away → **C8-F02** · **Repos:** 2 · **Target:** NEW_ADDON_CONTEXT.md
**Citations:** `NEW_ADDON_CONTEXT.md:1037`, `library-stack.md:113`, `LibKa0s/tests/majors.lua:16`
**Reason:** One line of the same ripple, in the copy that matters most — the pack an agent loads as working
context when an addon is born, which is precisely the reader least able to notice the number is stale, and
anti-pattern #49 already records what happens when a stale scaffolding pack is read as working context. Its
instruction is what makes the whole ripple one unit of work: bump the pack's version alongside the section
fixes so every copy of the fact moves in one commit.

### C8-F07 — testing-§8 mandates a grep-derived member list; the kit ships a by-name lookup and eleven repos use it
**Outcome:** live → **REFUTED** · **Repos claimed 11/11, true 10/11** · **Target:** testing.md
**Citations:** `testing.md:164`, `:169`, `LibKa0s/testkit/framework.lua:394`, `:298`, `:350`, `LibKa0s/docs/api/README.md:33`, `AuraMaster/tests/test_surface_parity.lua:46`, `test_launcher.lua:413`, `test_poolsetup.lua:32`, runner lines in three repos
**REFUTED:** the two counts the ambiguity rests on are both wrong. ConsumableMaster uses the **declared-list**
form throughout for its LibKa0s seams (`tests/test_surface_parity.lua:121,163,214,258`) and one of those cases
carries exactly the derivation the MUST asks for — `-- Member list produced by: grep -n '^function DL\.…'`.
And the claim that the grep comment survives only on host-namespace cases is refuted by the proposal's own
citation: `AuraMaster/tests/test_poolsetup.lua:28-33` asserts a **LibKa0s major** with a declared list and a
named grep. So neither reading survives, and the manufactured ambiguity dissolves. What does survive is small
and additive: the standard names none of `Kit.assertSurfaceParity`, `Kit.setSurfaceSource` or the gate-backed
`members-<key>.json` manifests, although it already MUSTs what they do.

### C8-F08 — The kit's inventory gate cannot see an unadopted kit suite when a same-named local suite exists
**Outcome:** merged-away → **C10-F03** · **Repos:** 7 · **Target:** LIBKA0S
**Citations:** `LibKa0s/testkit/framework.lua:654`, `:742`, `:744`, `:693`, `LibKa0s/docs/api/testkit/version-24-docs.md:24`, `localization.md:295`, five repos' `tests/run.lua`
**Reason:** Same defect, same mechanism, same fix. C10-F03 carries it because it names the framework functions
precisely, catches a sixth repo (LibKa0s itself) and generalises the fix to the next kit suite. What carries
over from here: the documented bargain at `version-24-docs.md:24` — adoption is not automatic and a repo that
does not declare the file is *supposed* to go red, because "a gate that arrives silently and runs nothing is
the failure this kit refuses everywhere else" — which is the strongest statement that the current behaviour is
a bug rather than a design choice; and the correct sequencing note that raising localization-§5's SHOULD
toward a MUST must wait until the gate can see the state.

---

## Category 9 — Undocumented emergent conventions

### C9-F01 — `docs/revendor/<date>/` is the collection's fifth frozen store, and ten repos patch the standard's own exemption list by hand
**Outcome:** live → **UPHELD (two elements corrected)** · **Repos:** 10 · **Target:** documentation.md + audit-review-history.md
**Citations:** `documentation.md:330`, `:331`, and the `## Documentation map` scope sentence in all ten addons (`AbsorbTracker:541`, `AuraMaster:771`, `BankLedger:404`, `ConsumableMaster:436`, `KickCD:324`, `LootHistory:412`, `MultiMeters:415` + `:477`, `PanelMaster:279`, `PrettyChat:192`, `WhatGroup:437`)
**Verification:** All thirteen citations resolve; `grep -rn "docs/revendor" WowAddonStandards/standards/`
returns nothing, and no section owns the store. Sixty-eight bundles across ten repos; PartyFrameEnhanced has
none and has no scope sentence at all. The divergence is confirmed four ways (MultiMeters gives it a table row
instead, AuraMaster adds `docs/spell-research/`, AbsorbTracker alone still carries `docs/investigations/`).
Two corrections: the five-file shape appears in only **40 of 68** bundles (19 lack `04_EXECUTION_PLAN.md`, 9
carry two), so state a numbered-prefix convention with `01_DELTA.md` and `05_SUMMARY.md` as the stable members;
and the proposed "an addon adds nothing to the scope list" rule must be confined to a store written by a
shared command, or it contradicts Tier 3 (`documentation.md:296-301`: an addon-specific subject "MAY ship
under any name, and the standard MUST NOT name it").
**Absorbed:** C1-F01.

### C9-F02 — The re-vendor bundle convention has lapsed collection-wide
**Outcome:** live → **UPHELD (arithmetic corrected)** · **Repos:** 11 · **Target:** TOOLING + audit-review-history.md
**Citations:** the newest `05_SUMMARY.md:1` in all ten stores (nine at `2026-09-13-v1.34.0`, AbsorbTracker at `2026-09-14`); `versioning-git.md:9`
**Verification:** Confirmed on disk — the newest bundle in nine stores is `2026-09-13-v1.34.0` and
AbsorbTracker's is `2026-09-14`, against a library now at v1.54.2. Three corrections: the headline "158" does
not match the finding's own per-repo list (163) or the measurement (161); measured by *tag past the newest
bundle* — the reading the finding actually argues — the span is 15 to 20 commits per repo; and AbsorbTracker
did produce a bundle on 2026-09-14, so the claim holds from 2026-09-15. The causal claim also overreaches: the
convention is mandated in the tooling repo (`wow-addon/commands/revendor-libka0s.md:171`, `:307`), so it
lapsed because bulk sweeps bypassed the command, not because nobody wrote it down. That makes the fix
two-part: name the store in a section first, then add the `AUDIT.md` check.

### C9-F03 — A kit-shipped suite can arrive vendored and never run
**Outcome:** merged-away → **C10-F03** · **Repos:** 11 · **Target:** TOOLING
**Citations:** `testing.md:21`, `:218`, `:220`, `BankLedger/tests/test_prose.lua:1`, `BankLedger/tests/run.lua:26`, `ConsumableMaster/tests/run.lua:469`, `LootHistory/…:86`, `PrettyChat/…:65`, `WhatGroup/…:124`, plus six kit-wired runners
**Reason:** Same defect from the emergent-conventions angle. What carries over and is unique: the forensic
detail that the commit which put the kit file in each of the five repos is titled "Adopt the kit's US-English
gate, and delete the copy this repo was keeping" and deleted nothing — BankLedger's 6b12edf touches four
files, none of them `tests/run.lua` or `tests/test_prose.lua`; the explanation of why testing's existing MUST
cannot catch it (completeness is written over `tests/test_*.lua` on disk and paths in the declared list, so a
present-but-undeclared kit file satisfies both halves); and the second, smaller convention defect worth fixing
in the same edit — two spellings of the kit path inside a single `run.lua` in KickCD and MultiMeters.

### C9-F04 — Tier 2's counted triggers are being overridden by judgment in both directions
**Outcome:** live → **REFUTED** · **Repos claimed 3, true 1** · **Target:** documentation.md
**Citations:** `documentation.md:249`, `:252`, `MultiMeters/docs/ARCHITECTURE.md:456`, `:457`, `LootHistory/…:433`, `KickCD/…:351`, `AbsorbTracker/…:328`, `PanelMaster/…:281`
**REFUTED:** Tier 2 is a floor, not a ceiling — "MUST ship under exactly these names **when** the stated
trigger holds" — so LootHistory and KickCD shipping `message-bus.md` below the trigger is compliance, and the
"opposite directions" framing, the finding's whole rhetorical engine, dissolves. Only MultiMeters overrides a
fired trigger, on two rows. And the standard's answer already exists in the same section: a MUST is argued
with in `## Documented deviations` (`documentation.md:137`, `:166`), not in a Documentation-map row
(`:291` draws that line explicitly) — MultiMeters already maintains such a register and simply did not file
there. Two of eight citations point at unrelated text. One narrow clarification would be defensible: whether
`slash-dispatch.md`'s count is over `NS.COMMANDS` whole (10 of 11 repos) or the addon's own verbs (MultiMeters alone).

### C9-F05 — The collection changed its commit-subject register in eleven repos and the standard has never mentioned commit subjects
**Outcome:** live → **REFUTED** · **Repos claimed 12, cited 13, prefix-era 8** · **Target:** versioning-git.md
**Citations:** `versioning-git.md:9`, `:13`, `:15`; eleven `<repo>/.git:1`
**REFUTED:** eleven of fourteen citations cite nothing — `.git` is a directory and cannot be opened at a line,
so a verifier is given no command, window or regex to re-run. The counts are also wrong: eight repos ran
conventional-commit prefixes at 42–69 of their last 200, not ten — AuraMaster (1), MultiMeters (12) and
PartyFrameEnhanced (0) never carried the habit, which also falsifies "PartyFrameEnhanced is the only repo that
never carried it". Two of the three proposed MUSTs rest on a universality that does not exist: LibKa0s has 9
bare `Release vX.Y.Z` subjects against 77 tags alongside three other forms, and WowAddonStandards mixes
`vX.Y.Z:` with an older em-dash form — so writing them down would invent a convention, not record one. **The
silence is real** (no section mentions commit subjects; `documentation.md:84` mentions them only to exempt
them), and a SHOULD plus the `Re-vendor LibKa0s v<tag>` subject as a SHOULD attached to the existing bullet is
what the evidence supports.

### C9-F06 — `tests/prose_waivers.lua` is the kit gate's canonical waiver file in five repos and is named nowhere
**Outcome:** live → **REFUTED** · **Repos:** 5 · **Target:** testing.md
**Citations:** `testing.md:21`, `:22`, `:23`, five repos' `tests/prose_waivers.lua:1`, `AbsorbTracker/tests/test_helpers.lua:1`
**REFUTED:** "named nowhere" is false — `localization.md:291-293` names the file verbatim, gives its return
shape and rules on the malformed case, and `:283-295` covers the per-file/per-word shape and makes the kit gate
the SHOULD. The sweeper checked `testing.md` and not the section that owns the gate. The PartyFrameEnhanced
"latent finding" is the **compliant** case: the file is optional and the vendored kit says so in its own doc
comment ("ABSENT IS THE NORMAL CASE… A repo with nothing to waive ships no file"). And the one concrete cost is
a misread: `AbsorbTracker/tests/test_helpers.lua` is a genuine 66-case suite for `NS.Helpers`, declared at
`tests/run.lua:94`, i.e. exactly the `test_<module>.lua` shape. With that gone the proposal has zero
demonstrated cost, and `testing.md:214-221` already covers the mechanism the MUST NOT was invented to protect.

### C9-F07 — One job, three filenames, ten repos, one repo with no copy: the Documentation-map check
**Outcome:** merged-away → **C10-F02** · **Repos:** 11 · **Target:** LIBKA0S
**Citations:** `documentation.md:324`, `AbsorbTracker/tests/test_docs.lua:1`, `AuraMaster/…`, `BankLedger/…`, `PanelMaster/…`, `KickCD/tests/test_doc_structure.lua:1`, `LootHistory/…`, `MultiMeters/…` + `tests/test_docmap.lua:1`, `PrettyChat/…`, `WhatGroup/…` + `test_docmap.lua:1`, `ConsumableMaster/tests/test_docmap.lua:1`, `PartyFrameEnhanced/docs/ARCHITECTURE.md:282`
**Reason:** Same extraction from the naming angle. C10-F02 carries it because it specifies what the extracted
suite must assert and — crucially — what it must not. What carries over: the three-names-one-job census; the
observation that PartyFrameEnhanced has none of them and its Documentation map is correspondingly the thinnest
in the collection, which ties it to C9-F01; and the framing that the extraction *removes* the naming question
rather than answering it. Its fallback is worth keeping if extraction is declined: `test_docmap.lua` is the
most precise of the three names, since `test_docs.lua` reads as a test of the docs' content.

### C9-F08 — `tools/` has two shapes and the root has three unruled entries
**Outcome:** below-bar (watch list) · **Repos:** 5 · **Target:** layout.md
**Citations:** `AuraMaster/tools/spell-research/README.md:1`, `PanelMaster/tools/artwork`, `tools/sunn`, `LibKa0s/tools/gen-api-members.lua:1`, `tools/artwork`, `PrettyChat/GlobalStrings`, `AuraMaster/_dev`, `LootHistory/.pytest_cache`
**Reason:** The date filter removed most of it. `layout-§1` has gained a "Where an authored generator lives"
paragraph that rules on two of the three instances — it names `PrettyChat/GlobalStrings` explicitly with the
move specified, and cites LibKa0s' **flat** `tools/gen-api-members.lua` approvingly, which directly
contradicts the proposal's first rule. `AuraMaster/_dev` is granted by packaging's own minimum template, and
`LootHistory/.pytest_cache` is already a finding under `AUDIT.md`'s existing root-dot-entry check. What
survives is the second proposal — state that layout-§1's root list is closed — at one stray each and no stated
cost. Promotes on a second flat-`tools/` collision or a second unexplained root directory.

### C9-F09 — Half the collection opens every authored file with a header naming its own path, and half does not
**Outcome:** merged-away → **C1-F08** · **Repos:** 11 · **Target:** NEW
**Citations:** `core/Database.lua` line 1 or 3 in all eleven addons
**Reason:** The same two-camp split with the same conclusion and a narrower denominator. C1-F08 carries it.
What carries over from here: the **placement** question, which C1-F08 does not address and which is a real
second divergence — some repos put the header above the `local _, NS = ...` bootstrap and some below, and this
finding proposes immediately after, which is also what documentation-§5's comment-citation check reads; the
explicit offer of the opposite decision (no header required), which equally ends the split; and its own
instruction that this should not consume interview time ahead of the higher-ranked category-9 items, honoured
in the ranking.

---

## Category 10 — Tooling gaps

### C10-F01 — The 1500-line cap gate is hand-written five times and absent from seven repos
**Outcome:** live → **UPHELD (two narrowings)** · **Repos:** 12 · **Target:** TOOLING → testing.md
**Citations:** `ConsumableMaster/tests/test_layout_cap.lua:34`, `:36`, `MultiMeters/…:36`, `PanelMaster/…:41`, `PrettyChat/…:45`, `LibKa0s/…:39`, `:41`, three runner lines, `BankLedger/docs/audits/2026-09-08/02_DEVIATIONS.md:64`, `KickCD/docs/audits/2026-07-18/02_DEVIATIONS.md:13`, `LibKa0s/testkit/test_prose.lua:9`
**Verification:** All fifteen citations resolve. Exactly five copies exist (232/221/209/380/206 lines), all five
md5-distinct, and seven addons carry none. All twelve repos already vendor `tests/_kit/`. `layout-§1` mandates
no gate; `automated-tests.md:254,268`'s band watch list is a dated record rather than a commit gate.
**Two narrowings:** the heading disagreement is a different heading *name*, not a level — PanelMaster looks for
`### Files by the \`layout-§1\` band` — and parts (b) and (c) of the proposed assertion need a prose half
first, because **no section mandates a census heading in the hub at all**. PanelMaster's band assertion also
collides with `automated-tests.md:268` ("the band is a column, not a heading").

### C10-F02 — The documentation-shape gate exists under five names with five different coverage sets
**Outcome:** live → **UPHELD (four corrections)** · **Repos:** 12 · **Target:** TOOLING → testing.md
**Citations:** `AbsorbTracker/tests/test_docs.lua:86`, `:159`, `ConsumableMaster/tests/test_docmap.lua:45`, `KickCD/tests/test_doc_structure.lua:121`, `:136`, `MultiMeters/…:162`, `:248`, `WhatGroup/tests/test_docmap.lua:46`, `LootHistory/tests/run.lua:82`, `PrettyChat/tests/run.lua:97`, `PrettyChat/docs/audits/2026-09-08/02_DEVIATIONS.md:55`, `:52`, `BankLedger/…:51`, `PartyFrameEnhanced/tests/run.lua:77`, `AUDIT.md:106`, `:113`, `:129`
**Verification:** All seventeen citations resolve; five basenames confirmed; PartyFrameEnhanced has none of
them among 30 suites; the per-bundle recurrence numbers reproduce exactly. Four corrections: "no two repos
gate the same rule" is false (the evidence-id case is byte-identically titled in ten repos); ConsumableMaster
does gate evidence ids, in a separate `test_register.lua`; documentation-§5 is cited in ten addons, not eleven
(MultiMeters has none); and the predicted first-run reds for AuraMaster and PartyFrameEnhanced are unsupported
— their registers hold 2 and 1 rows and neither uses an ID column. The load-bearing argument is untouched.
**Absorbed:** C9-F07.

### C10-F03 — A consumer suite whose basename collides with a kit suite silently shadows it
**Outcome:** live → **UPHELD** · **Repos:** 6 shadowing of 12 · **Target:** TOOLING → LibKa0s testkit + testing.md
**Citations:** `LibKa0s/testkit/framework.lua:730` (mechanism at `:654`, `:742-745`, invoked at `:1191`), `LibKa0s/testkit/README.md:145`, `:109`, `LibKa0s/testkit/test_prose.lua:20`, `:27`, `:125`, `:157`, and the runner lines in all twelve repos
**Verification:** Mechanism confirmed in source — `suiteDeclarations` keys `declared` by bare name (`:654`) and
the kit-directory pass hands that same name-keyed set to `collectUndeclared` (`:744`), so a bare `"test_prose"`
satisfies `tests/_kit/test_prose.lua` and the kit copy is never loaded. Six repos are in that state
(BankLedger, ConsumableMaster, LootHistory, PrettyChat, WhatGroup, LibKa0s), running 262–443-line local copies.
The divergence is already real: the kit copy reads `tests/prose_waivers.lua` and the local copies hardcode
`WAIVED` (WhatGroup `:123`, LootHistory `:121`). All seven BRITISH lists are byte-equal **today**, which is
precisely why this is worth fixing before the next amendment rather than after. One citation was mis-anchored
(the "one or the other, never both" rule is at README `:145`, not `:8`).
**Absorbed:** C8-F08, C9-F03.

### C10-F04 — Nothing gates the `.gitattributes` body, and twelve of fourteen repos are missing a MUST line it publishes
**Outcome:** live → **UPHELD; one reading refuted** · **Repos:** 14 · **Target:** TOOLING → LibKa0s testkit + line-endings.md §7
**Citations:** `line-endings.md:147`, `:198`, `:199`, `:289`, `:290`, `:434`, `:466`, `AuraMaster/.gitattributes:37`, `LibKa0s/.gitattributes:35`, and `<repo>/.gitattributes:6` in twelve repos
**Verification:** All twenty-one citations resolve. Re-measured: `*.py text eol=lf` is present in AuraMaster
and LibKa0s only; absent in the other nine addons plus both tooling repos. `*.sh text eol=lf` is in all
fourteen. The failure is **body drift**, not twelve independent omissions — the twelve carry the superseded
six-line shell-only comment block while the two carry §5's current eight-line block that added the `python3\r`
rationale and the `*.py` pin. **Reading two is refuted:** five repos track Python (AuraMaster, LibKa0s,
PanelMaster ×4, PrettyChat, wow-addon) and three of those five lack the line while shipping
`#!/usr/bin/env python3` scripts, so the claimed perfect correlation does not hold and the kernel-level
breakage §5 describes is live in three repos.
**Owner call — the residual decision (reversing §7's "(a)–(d) stay the audit's work") is in `04_PROPOSALS.md`.**

### C10-F05 — The TOC header is the most machine-readable file in an addon and is gated in no repo
**Outcome:** live → **REFUTED on premise** · **Repos:** 11 · **Target:** TOOLING
**Citations:** `AbsorbTracker/docs/audits/2026-07-18/02_DEVIATIONS.md:32`, `/2026-09-08/…:46`, `:47`, `BankLedger/…:49`, `AuraMaster/docs/audits/2026-09-11/02_DEVIATIONS.md:205`, `PrettyChat/…:54`, `AbsorbTracker/tests/test_loadorder.lua:30`, `:89`, three more `test_loadorder.lua`, `PrettyChat/tests/loader.lua:1`, `WhatGroup/tests/loader.lua:1`
**REFUTED:** "not one repo checks it" and "none of them asks the header a single question" are false. **All
eleven** addons already open their own `.toc`, read `## IconTexture` and assert on it — six of them assert both
negatives (no `Interface\Icons\` path, no bare numeric id), which are two of the six assertions the proposal
enumerates. The annotation half is not unchecked either: `PartyFrameEnhanced/tests/test_loadorder.lua:40-45`
already asserts that a TOC line carries the note saying its position is load-bearing. Two supporting numbers
are also wrong (both §1 and §5 are cited in 11 of 11 repos, and the TOC parser is one shared
`tests/_kit/loader.lua`, not eleven). **Four assertions do survive** and should be re-proposed at that width:
required fields present, exact field order, single `## Interface`, the `#` section-block order, plus the
`## X-Standard` three-way agreement no test anywhere asserts.

### C10-F06 — testing-§12's falsification marker is adopted at ratios from 10% to 180%, and nothing counts it
**Outcome:** live → **REFUTED** · **Repos:** 12 · **Target:** TOOLING
**Citations:** `testing.md:390`, `:400`, `:402`, `PanelMaster/docs/audits/2026-09-08/02_DEVIATIONS.md:38`, `:169`, `AuraMaster/…:118`, `LibKa0s/testkit/framework.lua:730`, five suite files
**REFUTED:** the headline statistic is not reproducible — every quoted figure disagrees with an independent
count by 20–30%, and the claimed range is not the range (ConsumableMaster is 158/3). The proposal concedes the
denominator is a grep artifact and then argues from the spread anyway, and concedes the counter "has to be
calibrated… or it will record a lie of its own" while proposing to put it in eleven repos' trend line. The
metric also cannot measure the SHOULD it names: `testing.md:412` scopes the marker to cases "whenever the
falsification is not obvious from reading it", which is not mechanically derivable, so a repo at 10% may be
fully compliant. And the two findings it is offered as the fix for are **missing-case** findings, which a
marker-density counter is structurally blind to. One citation is misattributed. A raw marker count per suite
file, reported and not gated, is all the evidence supports.

### C10-F07 — The no-blanket-suppression gate is hand-written ten times, ~270 lines each
**Outcome:** live → **UPHELD (one overreach corrected)** · **Repos:** 10 copies of 12 · **Target:** TOOLING → LibKa0s testkit + lint.md
**Citations:** `AbsorbTracker/tests/test_lintconfig.lua:1`, `:5`, `:31`, `WhatGroup/…:1`, `ConsumableMaster/…:1`, `KickCD/…:1`, `MultiMeters/…:1`, `PanelMaster/…:1`, `PrettyChat/…:1`, `AuraMaster/…:1`, `BankLedger/tests/run.lua:26`, `LootHistory/tests/run.lua:83`, `PartyFrameEnhanced/tests/run.lua:77`, `LibKa0s/testkit/test_prose.lua:9`, `open-evolutions.md:8`
**Verification:** Ten copies, 256–278 lines, all ten md5-distinct; PartyFrameEnhanced and LibKa0s have none.
Nothing in lint.md, testing.md or library-stack.md mandates a suite enforcing the rule or names the file, and
the `test_prose.lua` precedent is verbatim in the kit. **One overreach:** "the same four assertions" is false
for two of the ten — PanelMaster asserts the stricter "every inline luacheck ignore names the code it answers"
(`:241`) and AuraMaster carries a fifth, unrelated lizard-adjacency case (`:254`) — so the rollout is eight
clean swaps plus two that need a decision first. Nine of the ten headers also cite a section id, `lint.md
M4-11`, that no longer resolves.
**DISCREPANCY:** this finding was **upheld** by verification and is **absent from the survivor set** handed to
this bundle. It is recorded here as live-and-upheld so the owner can decide whether that omission was intended;
see the closing note in `04_PROPOSALS.md`.
**Absorbed:** C1-F05.

### C10-F08 — The mandated disabled-state conformance suite is hand-written eleven times, 297 to 580 lines
**Outcome:** live → **REFUTED** · **Repos:** 11 · **Target:** TOOLING
**Citations:** `slash-commands.md:1` (the mandate is at `:271`), eleven `tests/test_disabled.lua:1`, `LibKa0s/testkit/vendor_sync.lua:66`
**REFUTED by its own recommended measurement.** The finding asks that the eleven suites be diffed against §7's
checklist before anyone commits to an extraction; run, that diff comes back against it. PartyFrameEnhanced —
the shortest by 148 lines and the nominated first adopter — asserts **all ten** §7 steps in ten cases.
PanelMaster's 580 lines are cases *past* the checklist and specific to that addon ("a reserved verb this addon
never registered", "the hold keys are the library's exported constants, not local literals"). So the spread is
addon difference, not coverage difference, and by the finding's own stated test this is a watch-list item. It
also concedes no audit shows any repo's suite missing an arm, and the adoption shape is the hardest of any kit
change (it deletes a suite the addon owns). Note `slash-commands.md:271-290` already fixes the checklist in ten
numbered steps with testing-§12 falsification comments required on three of them.

---

## Watch list — below the bar, and what promotes each

Each needs one more repo, or a stated cost, to be promotable. The next run should find these rather than
rediscover them.

1. **C2-F11 — the shared data-browser utility pack.** BankLedger and LootHistory ship the same seven functions
   under the same names in the same order (`BankLedger/core/Util.lua:6,15,24,29,36,51,155`;
   `LootHistory/core/Util.lua:6,25,34,40,47,63,91`), neither citing the other. Two repos of one addon kind;
   `library-stack-§7`'s stability bar is unmet because `FormatMoney` and `FormatClock` are presentation, and
   presentation is where a third consumer arrives wanting a format argument. **Promotes** when a third data-browser
   addon appears. Note separately that `SplitPath` alone clears all three bars today and is duplicated five more
   times inside the Schema runtimes — carry it on open-evolutions' Schema-runtime entry rather than here.

2. **C6-F15 — who owns the spelling of vendored text.** PanelMaster#19 (open, triaged since July) asks whether the
   US-English respelling of `docs/agent-context.md` belongs upstream; AuraMaster resolved the mirror case the
   opposite way in commit 329e1a3. Below bar because the one instance is moot: anti-pattern #49 forbids
   `docs/agent-context.md` existing in a repo at all, so that file settles by a different rule. **Promotes** the
   moment a second repo runs a spelling, wording or formatting sweep over genuinely vendored text (`libs/` or
   `tests/_kit/`). The mechanical half is independently cheap — `revendor-standards` already excludes `libs/`,
   `tests/_kit/` and the frozen bundles, and could exclude the context pack on the same list.

3. **C9-F08 — layout-§1's root list is not stated as closed.** Three repos each carry one unruled root entry:
   `PrettyChat/GlobalStrings` (now ruled on by layout-§1's new generator paragraph, which names the move),
   `AuraMaster/_dev` (granted by packaging's own template ignore block), `LootHistory/.pytest_cache` (already a
   finding under `AUDIT.md`'s existing root-dot-entry check). The finding's other proposal — a generator lives in
   `tools/<generator>/` — is contradicted by layout-§1's own fresh example, which cites LibKa0s' flat
   `tools/gen-api-members.lua` approvingly. **Promotes** if a second repo grows a flat `tools/` collision, or a
   second unexplained root directory with no deviation row.

4. **WhatGroup's runner does not arm the kit's suite-list pin.** `WhatGroup/tests/run.lua` does not pass
   `dir = "tests/"` to `Kit.run`, so `Kit.assertSuiteInventory` (`LibKa0s/testkit/framework.lua:730`, called at
   `:1191` only when `opts.dir` is given explicitly) never runs there and testing-§9's both-directions pin is
   unenforced in that repo alone. This is the one live residual of C4-F09 after the date filter showed the
   extraction had already shipped. One repo, so below bar as a standards proposal; it is a repo fix, and it would
   also be caught for free by C10-F03's proposed second check.

5. **AuraMaster's `docs/spell-research/<date>/`** is a frozen dated store that documentation-§3's scope sentence
   does not cover and that C9-F01's proposed amendment still would not cover, since that amendment adds
   `docs/revendor/` alone. One repo. **Promotes** if a second repo grows a research or investigation store of its
   own; until then AuraMaster needs either an upstream decision or a Documented-deviations row.

6. **The naming cheatsheet's own coverage is the gap.** `naming-cheatsheet.md` is 30 lines and carries rows for the
   Perf instance, the bus message format, the settings key and the chat printer, and no row for the schema write
   seam, the bus event casing, the MSG constant table, or the rule-subject test suites. If C1-F03, C1-F06, C1-F07
   and C1-F11 are each declined individually, the residual worth recording is that the cheatsheet's coverage is
   itself the defect rather than any one missing row.

7. **documentation-§8's applicability lists are not mechanically checkable as claimed.** The section lists `lint`,
   `testing`, `automated-tests` and `documentation-§3` in both its *Does not apply* and its *Applies, read here*
   lists while claiming the three lists "classify every section" and that "an audit may check that mechanically".
   The prose reconciles it explicitly ("because there is no Lua today… a statement about the tree rather than a
   permanent grant"), so it is a mechanical-checkability defect rather than a rule collision, and it has exactly
   one instance (WowAddonStandards itself, unaudited). **Promotes** the day wow-addon tracks its first `.lua`.
