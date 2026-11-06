# Harvest 2026-11-06 — 02 Findings

Every finding of this run, by category, with its repo count and its filter outcome:

- **live** — survives all three filters and goes to `04_PROPOSALS.md`;
- **vote** — a duplicate of an `open-evolutions` entry, recorded as new evidence for it;
- **settled** — today's standard (v2.101.0) already changed the rule; the version that settled it is named;
- **below bar** — fewer than two repos and no stated cost; goes to the watch list at the end;
- **audit debt** — a single addon failing a clear rule. Not a harvest finding; named so the next audit of that
  repo picks it up.

Full citations and verbatim excerpts are in `03_EVIDENCE.md`, Parts A–E. "Part A, Q11" means that heading.

---

## Category 1 — Convergent patterns

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F1-01 | A keyed combat-end queue (`Run(key, fn)`, latest wins, replayed on `PLAYER_REGEN_ENABLED`), written four times with different error isolation, ordering and stand-down clearing (Part C, C1) | 4 (OR, PFE, QC, WG) | **vote** — *Further `LibKa0s` modules* |
| F1-02 | A coalesced refresh ("one run per burst") on four different timer APIs; LootHistory `core/Util.lua` records a shipped freeze when the stand-down canceled the timer (Part C, C2) | ~6 | **vote** — *Further `LibKa0s` modules* |
| F1-03 | Secret-safe `PlainString` / `PlainNumber`, copied between addons (Part C, C3) | 4 (DR, QC, DW, OR) | **vote** — *Further `LibKa0s` modules* (Compat) |
| F1-04 | Frame position save and restore: 14 copies, two stored field names (`relPoint` ×6, `relativePoint` ×4, AuraMaster both) (Part C, C4) | 13 | **vote** — *Whether an unlock anchor has to be the library's handle* |
| F1-05 | Testkit gaps: chat capture copied into 14 repos; `tests/mock_menu.lua` in 12 (~1,300 lines, 11 distinct); deep-equal and deep-copy re-implemented while the kit's `__deepcopy` is private (Part C, C5–C7) | 12–14 | **vote** — *Further `LibKa0s` modules* (testkit) |
| F1-06 | Generator `--check` modes; only Outfitter Reborn's generators run inside the green gate (Part C, C8) | 3 | below bar as a rule (no stated cost); watch list |

## Category 2 — Divergent patterns

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F2-01 | `core/SkinSetup.lua` host glue: 17 files, 11,779 lines, ~20 identically named functions in 15–16 of them (Part C, D1) | 17 | **vote** — *A per-addon adoption command*; library extraction candidate (host factory on `LibKa0s-Skin-1.0`) |
| F2-02 | The Schema library-absent stub: five host-object names, 17 copies of `SplitPath` and a deep copy (Part C, D2) | 17 | **vote** — *Whether an adopted major needs a full library-absent stub* |
| F2-03 | "Name-Realm" key built five ways; BankLedger and LootHistory keep the hyphen and write `Unknown`, DropWatcher strips it — a correctness split when two addons join on the key (Part C, D3) | 5 | **vote** — *Further `LibKa0s` modules* (Compat) |
| F2-04 | Class color by `classFile` re-implemented; DropWatcher reads `C_ClassColor` first against the library's ruling (Part C, D4) | 7 | **vote** — *Further `LibKa0s` modules* (`Core.ClassColor` taking a classFile) |
| F2-05 | The slash `format` hook bypasses `colorDecode`, so AuraMaster and ConsumableMaster copy the library's color branch (Part C, D6) | 2 | library fix; **vote** — *Further `LibKa0s` modules* |
| F2-06 | Tooltip line readers: four addons; only LootHistory guards `RETRIEVING_ITEM_INFO`, only Outfitter Reborn guards secrets (Part C, D7) | 4 | **vote** — LibKa0s#49's promotion list (declined; the decline holds, semantics still disagree) |
| F2-07 | Test fixture homes: the degraded-environment builder in three places, the skin-facts fixture under four names (Part C, D8–D9) | 3–4 | below bar (no stated cost) |

## Category 3 — Midnight quirks

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F3-01 | **The private catalogues keep growing.** 11 repos keep `docs/midnight-quirks.md` (6 on 2026-08-25, 9 on 2026-09-22): 2,073 lines, ~133 entries, of which ~81 (~60%) belong to 21 behaviors written up independently in two or more files. 9 of the 11 open with their own restatement of the 12.0 secret rules. The standard drives some of it: `events-frames-taint.md` §1 tells each addon to write the unknown-event trade-off "in the addon's quirks doc", and that quirk now has 8 copies (Part A, §0) | 11 | **live** → P-05 (re-proposal of the deferred 2026-08-25 P-07, with the new numbers) |
| F3-02 | **The standard contradicts four repos on the lockdown edge.** `events-frames-taint.md` §2 says `InCombatLockdown()` is "true from `PLAYER_REGEN_DISABLED`" and that the regen events "fire exactly at the lockdown boundary". AbsorbTracker measured it false inside the handler (`docs/midnight-quirks.md`, "`InCombatLockdown()` lags `PLAYER_REGEN_DISABLED`"); PanelMaster passes `true` explicitly because "PLAYER_REGEN_DISABLED fires before lockdown begins" (`core/PanelMaster.lua`, `core/Compat.lua`); AuraMaster and Outfitter Reborn rely on the gap (Part A, Q11) | 4 (+2 in code) | **live** → P-02 |
| F3-03 | A secret boolean cannot be tested at all (Part A, Q6) | 7 | not covered; folds into P-05 |
| F3-04 | A secret cannot be a table key; covered only in `library-stack.md` (Part A, Q7) | 7 | partial; folds into P-05 |
| F3-05 | Item data is nil until cached and the load event has holes; covered only by `LibKa0s-Item` (Part A, Q15) | 7 | partial; folds into P-05 |
| F3-06 | `ADDON_RESTRICTION_STATE_CHANGED`: `Activating` fires before enforcement; the payload's second argument is recorded as a boolean by AuraMaster (measured), DropWatcher and QuickComms, and as a state enum by MultiMeters — against C3-F06's 2026-09-22 ruling that the shape was settled (Part A, Q10) | 6 | **contested**; folds into P-05 as *needs a probe* |
| F3-07 | Client state lags its own event, so a settle pass or retry is needed (Part A, Q19); a valid event that never fires (Q20) | 6 / 4 | not covered; folds into P-05 |
| F3-08 | `string.format` on a secret: `events-frames-taint.md` §8, KickCD and AbsorbTracker say it raises; MultiMeters and DpsRace say it works, DpsRace measured (Part A, Q5) | 5 vs 2 | **contested** — needs a per-specifier probe before §8 is edited; recorded in P-05 as an open probe, not a rule change |
| F3-09 | Blizzard renumbers enums, resolve by member name (Part A, Q18); spec readers moved to `C_SpecializationInfo` (Q29); `134400` is the dynamic-icon sentinel (Q28) | 5 / 2 / 2 | partial; folds into P-05 |
| F3-10 | Outfitter Reborn's quirks doc and `core/Secrets.lua` say `..` on a secret raises, against §8 and four repos (Part A, §2) | 1 | **audit debt** — Outfitter Reborn |
| F3-11 | Secure-button anchoring: WhatGroup says `SetAllPoints(parent)` fails at load; Outfitter Reborn anchors its secure rows that way; its smoke check O11 is still owed (Part A, §2) | 2 | contested; watch list until O11 is run |

## Category 4 — The audit and review corpus

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F4-01 | **documentation-§5 drift in 17 of 18 newest audits, every repo at every date.** In 12 repos the drifted items are hand-written counts of the repo's own tree or in-repo `file:line` citations (AT-80, LH-73, KICKCD-C-08, DRW-07, OR-01a, QC-08, CM-97, LK-29 …). documentation-§6's "rule or dated count" and "no bare line" forms cover only claims about the collection or another repo. Raised in 2026-09-22 as C4-F04 and not promoted (Part B, 4-A) | 17 | **live, ambiguous** → P-04 (both readings) |
| F4-02 | **toc-file-§5 load-bearing annotations** fail in 14 repos since 2026-09-07, recur at 3–4 audit dates in AT, CM and LH, and still fail after the v2.77.0 and v2.81.0 rewrites (QC-26). No gate exists outside `AUDIT.md`. Raised in 2026-09-22 as C4-F02 (Part B, 4-B) | 14 | **live, tooling** → recorded in P-07 (a kit check is a `LibKa0s` change first) |
| F4-03 | **The `ARCHITECTURE.md` hub.** 14 of 17 hubs exceed documentation-§3's ~400-line SHOULD; 14 carry a `## Skins` section of 70–197 lines added by the 2026-10-29 skinning rollout. It is not a mandated section, so the spill MUST cannot reach it and it has no spill target (Part B, 4-C) | 14 | **live, ambiguous** → P-06 |
| F4-04 | slash-commands-§1: the library-absent Slash stub copies `FormatRow`'s em-dash row in DropWatcher `settings/Slash.lua` and PGFE `settings/Slash.lua`, unfiled by either newest audit; AM, PM and QC had it and fixed it. No kit gate (Part B, 4-D; Part D, C2) | 2 live, 5 total | **audit debt** (DW, PGFE) + tooling, recorded in P-07 |
| F4-05 | The kit's `Kit.assertLatchHoldOrder` is used by 3 repos and named nowhere in the standard (Part B, 4-G) | 3 | below bar (no stated cost); watch list |
| F4-06 | architecture-§5 named-state rows missing (9 repos); events-frames-taint-§8 pre-formatting SHOULD (7); hand-rolled debug memos (4) (Part B, 4-G) | 4–9 | measured at v2.76.1; **settled-by-date unknown** — re-measure in the next audits before harvesting |
| F4-07 | Re-vendor bundle missing (10/11 at 2026-10-07), held today (Part B, 4-F) | — | **settled** by practice |
| F4-08 | slash-commands-§7 conformance suite gaps (Part B, 4-E) | — | **settled** v2.81.0, one inventory gap live → F5-02 |

## Category 5 — Standard-internal tensions and silences

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F5-01 | Gating a swatch on its feature's own switch: QuickComms QC-18 and AuraMaster AM-03 hold ratified rows against options-ui-§17; WowAddonStandards#13 open (Part B, §3) | 2 | **vote** — *Gating a swatch on its feature's own switch* |
| F5-02 | slash-commands-§7's survivor list names only `hooksecurefunc` (PGE-29, PGFE issue #10 open) (Part B, §3) | 1 + open issue | below bar; watch list |
| F5-03 | No rule for chat an addon sends on the player's behalf (DropWatcher's "(no rule yet)" row, issue #11 open; QuickComms exposed) (Part B, §3) | 2 | **live, new direction** → recorded in P-07 (no rule can be written from two rows yet) |
| F5-04 | frame-layering-§4 is silent on a click-catcher behind a secure HUD popup (QC-30) | 1 | below bar; watch list |
| F5-05 | events-frames-taint-§1's unit-filter wording, "events" against "not a budget for a second event" (AuraMaster) | 1 | below bar; watch list |
| F5-06 | options-ui-§15 names no place for a one-shot test action in a frameless addon (PrettyChat) | 1 | below bar; watch list |
| F5-07 | No rule for an extension addon that attaches to another addon's frames (PGFE, 4 register rows) | 1 | below bar; watch list |
| F5-08 | **Screenshots are packaged by default.** packaging's template has no `media/screenshots/` line; every addon that tracks the folder ignores it by hand — 15 of 15 measured 2026-11-06 — and AuraMaster's audit (AM-40) punted it as "the owner's call". LootHistory tracks 27 screenshots (39 MB) that a missing line would ship (Part B, §3; measured by the lead) | 15 | **live** → P-03 |
| F5-09 | Whether an adopted major needs a full library-absent stub: PrettyChat review F-008 (758 lines of stubs for an install the packager cannot produce) and F2-02 | 2+ | **vote** — *Whether an adopted major needs a full library-absent stub* |

## Category 6 — `state:will-not-do` and `state:triaged`

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F6-01 | **"Withdraw the ratified performance-§12 exemption: declined — the citations rotted, the argument did not"** — BankLedger#15, LootHistory#29, PrettyChat#14, WhatGroup#18, all `severity:low`. The same refusal in four repos: drift in a `file:line` citation is not drift in the argument (Part E) | 4 | **live** — joins F4-01 as evidence for P-04 (in-repo citations by symbol) |
| F6-02 | **`RenderTabbedSchema` has no pre-clear hook on a tab switch.** ConsumableMaster#41 (Macro Bar) and MultiMeters#53 (Columns) independently decline adoption for the same missing hook: a live reorder handle goes back into AceGUI's process-wide pool when `O.ClearScroll` runs before the host can cancel it. KickCD#23 declines for a neighboring gap (a disabled notice that replaces rather than heads the rows; an inert strip only through a private field). Not shipped as of v1.89.0 (grep for `beforeClear` / `onTabSwitch` empty) | 3 | **live, library-first** → recorded in P-07 |
| F6-03 | `X-Wago-ID` declined: ConsumableMaster#17, PrettyChat#7, WhatGroup#5 | 3 | **settled** — toc-file-§1 makes the field optional, "only if listed on Wago" |
| F6-04 | Core's window chrome declined: BankLedger#5, LootHistory#19, PanelMaster#27 | 3 | **settled** — superseded by the skinning series (the Ka0s window edge is now the skin's) |
| F6-05 | `RestoreAllDefaults` / `InlineButtonPair` / `ConsoleCheckbox` / `LIST_GROUP_ORDER` adoption declines (BankLedger, PanelMaster, WhatGroup) | 2–3 | adoption declines with reasons, not rule refusals; no proposal |
| F6-06 | `LibKa0s-Item/Widgets/Pool/Compat/Bus` per-major declines ("no domain for it") across 6 repos | 6 | adoption declines; no proposal. They are the evidence *A per-addon adoption command* already cites |
| F6-07 | LibKa0sSkinTester and Outfitter carry no `state:` labels — never swept by `issue-audit` | 2 | rollout debt (`06_OUTCOME.md`) |

## Category 7 — Rules nobody satisfies

| ID | Finding | Outcome |
|---|---|---|
| F7-01 | documentation-§5 (17/18) — the collection is non-compliant, or §6's citation and count forms should reach an addon's own docs | **live, ambiguous** → P-04 |
| F7-02 | documentation-§3 ~400-line SHOULD (14/17) — the `## Skins` section shows the rule's shape is the problem, or the hubs are bloated | **live, ambiguous** → P-06 |
| F7-03 | toc-file-§5 — the rule is clear and the missing gate is the problem | → P-07 (tooling) |

No rule was found that every repo satisfies trivially and no audit has cited; no retirement is proposed.

## Category 8 — LibKa0s against the standard

| ID | Finding | Outcome |
|---|---|---|
| F8-01 | **A whole major is undescribed.** `LibKa0s-IconBrowser-1.0` shipped in v1.86.0 (`IconBrowserSources`, `IconBrowserWindow`, `IconBrowser`); QuickComms and Outfitter Reborn consume it; no file under `standards/` names it (Part D, A1) | **live** → P-01 |
| F8-02 | **Stale counts in six places.** "twenty majors across sixty-four files" (library-stack-§7, `STANDARDS.md`'s blurb, `EXECUTIVE_SUMMARY.md`), "Nineteen of the twenty" (library-stack-§7), open-evolutions (two places). The library ships **21 majors in 67 files** (`tests/majors.lua`; `LibKa0s.xml`'s 67 entries; the library's own `docs/releasing.md` already says twenty-one and sixty-seven). This is the fourth recount drift of this paragraph (Part D, A2) | **live** → P-01 |
| F8-03 | Shipped, undescribed members: the opt-in Toast stack (v1.88.0: `stack`, `stackGrow`, `stackGap`, `STACK_GAP`, `SetStack`, `Visible`, `FrameFor`) against library-stack's "one payload at a time"; `W.ContextMenu` (Widgets minor 21, cascading submenus v1.87.0) still listed in open-evolutions as "recorded, not ruled" (Part D, A3) | **live** → P-01 |
| F8-04 | Members the standard tells addons to call and the library no longer has: **none** (Part D, A4) | — |
| F8-05 | Consumer drift: **none** — every vendored copy matches its claimed tag byte for byte (Part D, B) | — |
| F8-06 | **Tags are re-cut.** v1.85.0 was re-cut (`550ef68`), so 14 repos re-vendored on 2026-11-04 under an unchanged "v1.85.0" string, and only KickCD and PartyFrameEnhanced wrote a `-recut` bundle; DropWatcher once vendored a branch tip labeled v1.87.0 (`b2726c7`). The provenance line names no commit, so a moved tag is invisible (Part D, B) | **live, owner call** → recorded in P-07 (re-cuts were owner-directed; a rule needs a ruling first) |

## Category 9 — Emergent conventions

| ID | Finding | Repos | Outcome |
|---|---|---|---|
| F9-01 | `docs/superpowers/specs/<YYYY-MM-DD>-<topic>-design.md` and `docs/superpowers/plans/<YYYY-MM-DD>-<topic>.md`: 16 of 17 repos; 110 of 121 specs and 141 of 167 plans conform; AM and DW add `research/`. documentation-§3 names the directory and not its shape (Part C, §3) | 16 | **live** → P-08 |
| F9-02 | `media/screenshots/<addon>.screenshot.NN.<ext>` in 11 repos, 4 outliers | 11 | below bar (no stated cost); watch list |
| F9-03 | `docs/brainstorm/` (2 repos, registered two ways); `.gitignore` of dev-tool dirs; `core/Util.lua` grab-bags; split enUS locale files | 2–n | below bar; watch list |
| F9-04 | open-evolutions' *#55 picker-credit helper* rejection ("`all` is reserved to one addon. Re-check when a second addon ships a player-facing icon chooser") — its trigger has fired: Outfitter Reborn and QuickComms both declare `LibKa0s icons: all`, both ship an icon chooser on `LibKa0s-IconBrowser-1.0`, and each hand-writes the credit block (Part C, §4) | 2 | **vote** — trigger met |

## Category 10 — Tooling gaps

| ID | Finding | Outcome |
|---|---|---|
| F10-01 | `scripts/check-standard.sh` passes (exit 0, 7 checks) but reads only this repo, so it cannot see F8-01/F8-02. A `libka0s-counts` check against `../LibKa0s/tests/majors.lua` would have caught the fourth recount drift (Part D, C1–C2) | **live** → P-01 (the check ships with the recount) |
| F10-02 | The kit's `vendor_sync.lua` could enforce "a re-vendor implies a bundle" and record the tag's commit | library-first → P-07 |
| F10-03 | A kit case asserting `.pkgmeta` ignores everything under `media/logos/` except the shipped logo (QC-20, AM-35/40) | library-first → P-07 |
| F10-04 | A kit case for the library-absent Slash stub (F4-04) | library-first → P-07 |
| F10-05 | A toc-file-§5 load-bearing check (F4-02) | library-first → P-07 |

---

## Watch list

Carried for the next run. A second repo's evidence, or a stated cost, promotes any of these.

- F1-06 generator `--check` modes inside the gate (AM, PM, OR; no cost stated).
- F2-07 test fixture homes and names.
- F3-11 secure-button `SetAllPoints(parent)` at load (WG vs OR; OR's smoke O11 owed).
- F4-05 `Kit.assertLatchHoldOrder` unnamed in the standard.
- F5-02, F5-04, F5-05, F5-06, F5-07 (single-repo silences).
- F9-02 screenshot file naming; F9-03 brainstorm, dev-tool ignores, Util grab-bags, split locales.
- Part A §4: 24 single-repo quirks that state their cost (e.g. Outfitter Reborn's raise mid-`BeginEquipmentUpdate`
  silently stopping equipment updates for the session) — these are the first entries a quirks section would take.
- Part C D5: the secret-safe number-abbreviation ladder.
