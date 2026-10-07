# 03 — Evidence: WowAddonStandards (2026-10-07)

Every command below was run on 2026-10-07 at `f472389`. Sibling repos were read through
`git -C <repo> show master:<path>`. Each sibling's `HEAD` equals its `master`, so files other
agents are writing in parallel this cycle do not affect these readings. Every `file:line` quoted
here was re-read before it was written.

## E0 — Kind, version, and source of the rules

```
$ dev-copilot-profile
profile=wow  kind=standards  repo=…/WowAddonStandards  name=WowAddonStandards  reason=name:WowAddonStandards
$ git ls-files '*.toc' | wc -l          → 0
$ git rev-parse HEAD origin/master master → f472389… (all three equal)
$ head -1 standards/STANDARDS.md        → # Ka0s WoW Addon Standard (v2.76.1, 2026-10-07)
```

- `standards/ADDONS.md:58-61` lists `WowAddonStandards` in the *Documentation-and-tooling repos* table.
- Fetch comparison: `curl -fsSL $RAW/<file>` followed by `cmp` against the working tree. `AUDIT.md`, `standards/STANDARDS.md`, the 27 section files and `standards/ADDONS.md` are all identical: **30 of 30 files, no diff**.

## E1 — Tree census (scope: the whole tracked set, `git ls-files`)

```
$ git ls-files | wc -l                                         → 67
$ git ls-files '*.md' | wc -l                                  → 63
$ git ls-files | grep -v '\.md$'  → .gitattributes  LICENSE  media/logos/ka0s.logo.jpg  media/logos/ka0s.logo.png
$ git ls-files '*.lua' | grep -vE '^(libs/|tests/_kit/)' | wc -l → 0   (layout-§1 denominator; empty)
$ git ls-files '*.sh' '*.py' | wc -l                            → 0
$ git ls-files 'standards/standards/*.md' | wc -l               → 27
$ git status --short                                           → ?? docs/reviews/   (parallel review run, WAS-01)
```

The Sections list in `STANDARDS.md:55-81`, diffed against `git ls-files 'standards/standards/*.md'`, matches all 27 files with no difference.

## E2 — Line endings (WAS-02, WAS-02a/b/c). Scope: the whole tracked set, no exclusions.

```
(a) test -f .gitattributes                         → present
(b) grep -n '^\* text=auto eol=\(crlf\|lf\)$'      → 28:* text=auto eol=lf
(c) grep -nE '^\*\.(sh|py) text eol=lf$'           → 36:*.sh text eol=lf        (no *.py line)
(d) grep -c ' binary$'                             → 20
(e) the playbook's git-ls-files/check-attr/tr one-liner, run verbatim → 0
```

The body diff uses the canonical text extracted from line-endings-§5's non-client fence. The canonical file has `wc -l` = 85; the client-bound canonical has 84, which matches `AUDIT.md:197`.

```
$ n=85; diff <(head -n "$n" .gitattributes) canon_lf
30,35c30,37
< # Shell scripts are LF, ALWAYS — even in a CRLF-pinned repo, where everything
…
> # A file with a shebang is LF, ALWAYS — even in a CRLF-pinned repo, where
…
36a39
> *.py text eol=lf
$ tail -n +86 .gitattributes | tr -d '\r' | grep -m1 .   → (nothing; no appendix)
```

Citations:

- `.gitattributes:30`: `# Shell scripts are LF, ALWAYS — even in a CRLF-pinned repo, where everything`
- `.gitattributes:36`: `*.sh text eol=lf`
- `standards/standards/line-endings.md:104-106`: ```` ```gitattributes ```` / `*.sh text eol=lf` / `*.py text eol=lf` (§3: "Both variants **MUST** carry")
- `AUDIT.md:177-178`: `# (c) the shebang carve-outs, both mandatory in BOTH kinds (line-endings-§3)` / `grep -nE '^\*\.(sh|py) text eol=lf$' .gitattributes`
- **WAS-02a.** `standards/standards/documentation.md:675`: `| \`line-endings\` | The **LF** pin (\`line-endings-§2\`), the \`*.sh text eol=lf\` carve-out mandatory in both kinds, the binary marks and the \`§5\` canonical body. …`
- **WAS-02b.**
  - `CLAUDE.md:47`: `.gitattributes                    -- line-ending policy: the non-client canonical body, LF (line-endings-§2/§5)`
  - `CLAUDE.md:123-124`: `` `.gitattributes` carries the **non-client** canonical body — `* text=auto eol=lf`, `*.sh text `` / `` eol=lf`, binaries marked `binary`. ``
  - `README.md:140`: `.gitattributes                          -- line-ending policy: the non-client canonical body, LF (line-endings-§2/§5)`
  - `DEPENDENCIES.md:64`: `(line-endings-§2/§5): this is the **non-client canonical body**, pinned to **LF**, unlike the addons,`
- **WAS-02c.** `standards/EXECUTIVE_SUMMARY.md:52`: `` … `*.sh text eol=lf` is mandatory in **both** kinds — a shebang followed by CRLF makes the kernel look for an interpreter literally named `bash… `` (no `*.py`)

## E3 — "No audit lands here" against "audited" (WAS-01, WAS-01a, WAS-01b)

What the repo's own docs say:

- `CLAUDE.md:11`: `This repo does **not** run audits. Compliance auditing and new-addon scaffolding happen **in each`
- `CLAUDE.md:61-62`: `Audit and review runs are **not** in this repo — they live under each audited addon's own` / `` `docs/audits/<date>/` and `docs/reviews/<date>/` … ``
- `CLAUDE.md:107-109`: `` … `docs/audits/<YYYY-MM-DD>/` bundle … into the **audited addon's** repo — never here, and never edited after the ``
- `docs/ARCHITECTURE.md:23-24`: `… Nothing here reaches into a sibling repo, and no` / `audit, test record or scaffold output is ever written here.`
- `README.md:17`: `The standard is the source of truth, and it evolves in place. Auditing doesn't happen here any more.`
- `README.md:154`: `Audit and review runs are not stored here. Audits live under each addon's own`
- `standards/README.md:5`: `… Compliance auditing is **not** run from here — each addon audits`
- `standards/ADDONS.md:5-6`: `… Compliance auditing is no longer run from` / `this repo — each addon audits **itself** …`
- `standards/ADDONS.md:80-81`: `- **Audits live with the addon.** Each addon's compliance runs are written to *its own*` / `` `docs/audits/<YYYY-MM-DD>/` folder (see …), not here. ``
- `AUDIT.md:3-6`: `This is the step-by-step spec for auditing **one addon` / `repo** … this \`WowAddonStandards\` repo holds only the rules and this playbook, never an` / `addon's audit results.`

What the standard says, against them:

- `standards/ADDONS.md:55-56`: `scope for the standards process and are audited — against **\`documentation-§8\`'s applicability` / `lists** …`
- `standards/standards/documentation.md:681`: `| \`audit-review-history\` | The frozen dated bundles, all three MUSTs on the deviation register, and the GitHub-issue decision store. |` (in *Applies, unchanged*)
- The tree: `git status --short` prints `?? docs/reviews/`, and this bundle lands at `docs/audits/2026-10-07/`.

The dependents:

- **WAS-01a.** `docs/ARCHITECTURE.md:69`: `Every \`.md\` in this repo appears in exactly one row below.` The map, `:71-83`, has no `docs/audits/` or `docs/reviews/` row. Its frozen-store row is `:83`: `| \`harvests/<date>/\` | Frozen harvest bundles, named once here rather than per file |`. documentation-§3, `documentation.md:353-356`: `` Frozen and generated material is **out of scope** … `docs/audits/`, `docs/reviews/`, … are named as `` / `directories, once each.`
- **WAS-01b.** `DEPENDENCIES.md:14`: `> The repo is 67 tracked files: 63 Markdown plus \`LICENSE\`, \`.gitattributes\` and two logo images. No`. Measured in E1: 67 and 63, which is true today.

## E4 — Adoption state (WAS-03)

The claims:

- `AUDIT.md:541-542`: `- **Check the launcher — one object, three behaviors, one row** (\`launcher\`). New in v2.52.0, and` / `**every addon in the collection is expected to be non-compliant until it adopts**; record the`
- `AUDIT.md:652-653`: `As of the 2026-09-16 sweep, **eleven of eleven addons fail this** — 107 survivors across the` / `collection. Expect findings here in every audit until the adoption pass lands. Adoption is`
- `standards/standards/launcher.md:92`: `Every addon in the collection is **non-compliant with this section until it adopts**, which is normal and expected — the section is new.`
- `standards/standards/slash-commands.md:200`: `` … **eleven of eleven implement disable as a draw gate** — a rung in a show-ladder, a boolean an early-return consults — and **not one of them genuinely stands down**. A sweep of the collection counted **107 survivors** … ``

The tree. Scope: the 11 roster addons, each on `master` (HEAD = master).

```
$ for a in <11 addons>; do grep -oE 'Bundles \[LibKa0s\]\([^)]*\) v[0-9.]+' $a/CLAUDE.md; git -C $a ls-files tests/test_disabled.lua core/LauncherSetup.lua 'libs/LibDBIcon-1.0/*' 'media/logos/*.128.tga'; grep -c test_disabled $a/tests/run.lua; done
```

| Addon | Vendored tag | `tests/test_disabled.lua` | in `tests/run.lua` | `core/LauncherSetup.lua` | LibDBIcon files | `*.logo.128.tga` | Lifecycle seam (grep `LibKa0s-Lifecycle-1.0`, own Lua) |
|---|---|---|---|---|---|---|---|
| AbsorbTracker | v1.70.0 | 1 | 4 | 1 | 2 | 1 | `core/Lifecycle.lua` |
| AuraMaster | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| BankLedger | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| ConsumableMaster | v1.70.0 | 1 | 2 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| KickCD | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| LootHistory | v1.70.0 | 1 | 5 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| MultiMeters | v1.70.0 | 1 | 2 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| PanelMaster | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| PartyFrameEnhanced | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| PrettyChat | v1.70.0 | 1 | 2 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |
| WhatGroup | v1.70.0 | 1 | 1 | 1 | 2 | 1 | `core/LifecycleSetup.lua` |

All 11 addons have adopted, on LibKa0s v1.70.0, which is above the v1.42.0 floor. This evidence shows the adoption **exists**. It does not certify each addon's stand-down. That is still each addon's own audit to measure. The finding is that the playbook tells those audits to *expect* failure.

## E5 — Worked-example citations re-read (WAS-04, WAS-05)

**Scope.** Three sets were re-read:

- **Set A:** every `<Repo>/<path>:<line>` citation in a live doc. Excluded: the `STANDARDS.md` changelog (`:97` onward), `harvests/` and `standards/_raw/`. Found with `python3 -I` regex over `git ls-files '*.md'`: 40 citations, 23 carrying a line number.
- **Set B:** documentation-§3's two lists of bare `:N` hub lines (14).
- **Set C:** the backticked `path:line` citations in `layout.md`, `toc-file.md` and `open-evolutions.md` whose repo the sentence names (24 re-read).

**Not re-read:**

- open-evolutions `:112` (`settings/Slash.lua:233`), `:116` (`Panel_Render.lua:273`), `:119` (`Panel.lua:380`), `:120` (`Panel_Render.lua:263`), `:136` (`tests/test_disabled.lua:49`) and `:139` (`OptionsShim.lua:252-261`).
- `layout.md:87`'s three citations into frozen 2026-09-07 audit bundles. Those bundles are frozen and stable by construction.

Every sibling file was read at `master`.

**Verdicts.** MATCH means the cited line or range still holds the construct the sentence describes. ROT means it holds something else. GONE means the file no longer exists.

### Set A (23)

| # | Citing line | Cited | What is there now | Verdict |
|---|---|---|---|---|
| 1 | `automated-tests.md:366` | `MultiMeters/docs/automated-tests/RESULTS.md:30`, a watch list "Current as of `20260809-195454`" | `:30` `the record holds about those runs — it is not \`clean\`…`. "Current as of" is now at `:101`, for run `20260927-030445` | ROT |
| 2 | `automated-tests.md:369` | `LibKa0s/docs/automated-tests/RESULTS.md:50`, "499 cases" | `:50` `\| [\`20260930-084657\`] … \| 1777/1/1778 \| …`. "499 cases" appears nowhere in the file | ROT |
| 3 | `library-stack.md:24` | `PrettyChat/modules/Override.lua:98-140`, the boundary watcher | `:98` is blank. `WATCH_EVENTS` is at `:132` and `CreateFrame("Frame", "PrettyChatCombatWatcher")` at `:199` | ROT |
| 4 | `library-stack.md:24` | `PrettyChat/docs/ARCHITECTURE.md:230`, a deviation row | `:230` `\| \`schema.md\` \| The persisted shape, every default, and the migration seam \|`. The retired row is at `:308` | ROT |
| 5 | `library-stack.md:49` | `BankLedger/core/BankLedger.lua:4` | `local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")` | MATCH |
| 6 | `library-stack.md:49` | `WhatGroup/core/WhatGroup.lua:31-33` | `:32` `local WhatGroup = LibStub("AceAddon-3.0"):NewAddon(` | MATCH |
| 7 | `library-stack.md:49` | `KickCD/modules/Castbar.lua:68`, `NewModule` | `:68` `--   without erroring (Blizzard's protection is on arithmetic, not on`. `NewModule` is at `:72` | ROT |
| 8–12 | `library-stack.md:385-388` | `core/LSMPatch.lua` in AbsorbTracker, ConsumableMaster, KickCD, MultiMeters and PanelMaster | absent on `master` in all five (`git cat-file -e` fails) | GONE ×5 |
| 13 | `library-stack.md:245` | `LibKa0s/docs/audits/2026-09-07/02_DEVIATIONS.md:29` | `\| **LK-18** \| A-03 \| \`layout-§1\` \| **Low** \| MUST \| **Two tracked Lua files breach the 1500-LOC hard cap** …` | MATCH (frozen bundle) |
| 14 | `options-ui.md:55` | `KickCD/docs/ARCHITECTURE.md:241`, "112 of 228" | `:241` is blank. "112 of 228" is at `:342` | ROT |
| 15 | `options-ui.md:410` | `MultiMeters/settings/Schema.lua:1553-1566`, "The live case" | the file is 1392 lines, so the range is past EOF. `label = L["Bar texture (all surfaces)"]` is at `:284` | ROT |
| 16 | `standalone-windows.md:31` | `BankLedger/core/CoreSetup.lua:117-129`, the written decline | `:117` `if type(f.innerBorder) == "table" then`. The decline is at `:202` `` -- `lib.MakeCloseButton` IS DELIBERATELY NOT REPUBLISHED… `` | ROT |
| 17 | `standalone-windows.md:34` | `BankLedger/modules/Browser.lua:98`, plus `:1047`, `SessionWindow.lua:485` and `Export.lua:362` | `:98` `--`. The factory is at `:103` `function B:MakeCloseButton(parent, onClick)`. Calls are at Browser `:1253`, SessionWindow `:511` and Export `:392` | ROT |
| 18 | `standalone-windows.md:37` | `LootHistory/core/CoreSetup.lua:19-26` | `:19` `` -- `Core.MakeCloseButton` USED TO BE DECLINED HERE, and closed issues #19 … `` | MATCH |
| 19 | `standalone-windows.md:37` | `LootHistory/core/CoreSetup.lua:167`, the adopted wrapper | `:167` `end`. The wrapper is at `:276-277` `NS.MakeCloseButton = function(parent, onClick)` / `return lib.MakeCloseButton(parent, onClick, addonName)` | ROT |
| 20 | `testing.md:203` | `ConsumableMaster/settings/Panel.lua:571-572` | a comment block (`-- The array is told apart by its first element…`) | ROT |
| 21 | `testing.md:204` | `PanelMaster/settings/Slash.lua:316`, "a stub missing a `FormatKV`" | `:316` `-- call, so the whole slash surface — table, dispatcher, generated help and the implementations —` | ROT |
| 22 | `testing.md:237` | `BankLedger/tests/test_harness.lua:22-32` | the suite-list reader (`local OWN_DIR = "tests/"` at `:31`, `entryParts` below it) | MATCH |
| 23 | `testing.md:238` | `PanelMaster/tests/test_harness.lua:19-32` | `declaredSuites()` reading `T.suites` (`:29-32`) | MATCH |

### Set B (14). All ROT.

`documentation.md:391-393` gives the line of each addon's `### Verification and record` heading. `documentation.md:416-417` gives the line of each addon's hub self-row.

| Addon | `### Verification and record`: cited → now | Hub self-row: cited → now |
|---|---|---|
| AbsorbTracker | `:332` → `:346` (`:332` is now `\| \`common-tasks.md\` \| Recipes for the changes made most often here \|`) | not cited (no self-row) |
| BankLedger | `:199` → `:415` | `:179` → `:395` |
| ConsumableMaster | `:287` → `:347` | `:267` → `:327` |
| KickCD | `:204` → `:299` | `:185` → `:279` |
| LootHistory | `:360` → `:353` | `:340` → `:333` |
| MultiMeters | `:660` → `:369` | `:656` → `:344` |
| PanelMaster | `:148` → `:303` | — |
| PrettyChat | `:190` → `:247` | — |
| WhatGroup | `:320` → `:353` | — |

### Set C (24)

| Citing line | Cited | Now | Verdict |
|---|---|---|---|
| `layout.md:87` | PrettyChat `docs/ARCHITECTURE.md:269`, "the row is live today" | `:269` is register prose. The `layout-§2` row is at `:285` | ROT |
| `layout.md:87` | PrettyChat `tests/test_layout_cap.lua:11-12` | absent; replaced by the kit's gate | GONE |
| `layout.md:93` | PrettyChat `DEPENDENCIES.md:141-150` | `:141` `## 3. Release / assets — regenerating committed data` | MATCH |
| `toc-file.md:166` | `KickCD.toc:55` | `# published. This line moves only with that one.` | ROT |
| `toc-file.md:166` | `KickCD.toc:73` | `core\Database_Migrations.lua` | ROT |
| `toc-file.md:167` | `PrettyChat.toc:40` | `# Core (the LibKa0s seams load first). …` | ROT |
| `toc-file.md:167` | `PrettyChat.toc:57` | `core\Util.lua` | ROT |
| `toc-file.md:171` | `AbsorbTracker.toc:35-42`, the worked example | the conventional `EnvSetup` annotation at `:36-38` and the load-bearing `MediaSetup` annotation at `:40-41` | MATCH |
| `open-evolutions.md:110` | PrettyChat `settings/Schema.lua:636` | `if type(node[parts[i]]) ~= "table" then node[parts[i]] = {} end` | ROT |
| `open-evolutions.md:111` | WhatGroup `settings/Schema.lua:451` | `--` | ROT |
| `open-evolutions.md:111` | WhatGroup `settings/OptionsSetup.lua:195` | `addonName = addonName,` | ROT |
| `open-evolutions.md:114` | ConsumableMaster `settings/OptionsSetup.lua:260` | `--` | ROT |
| `open-evolutions.md:114` | ConsumableMaster `settings/Slash.lua:524` | `end` | ROT |
| `open-evolutions.md:115` | KickCD `settings/OptionsSetup.lua:162` | `-- The schema seams. Store.Set through SetAndRefresh, because it is the` | MATCH |
| `open-evolutions.md:115` | KickCD `settings/Slash.lua:378` | `end` | ROT |
| `open-evolutions.md:117` | ConsumableMaster `settings/Panel.lua:1069` | `scroll:AddChild(desc)` | ROT |
| `open-evolutions.md:133` | BankLedger `core/BankLedger.lua:137` | `NS.RegisterEventSafely(self, "PLAYER_REGEN_ENABLED", "OnCombatChanged")` | ROT |
| `open-evolutions.md:134` | BankLedger `settings/Panel.lua:165` | `if ev then` (after `local ev = NS.NewBusTarget()` at `:163`) | MATCH |
| `open-evolutions.md:134` | LootHistory `settings/Panel.lua:154` | `if ev then` | MATCH |
| `open-evolutions.md:135` | AuraMaster `settings/OptionsSetup.lua:395` | `C_Timer.After(0, function()` | ROT |
| `open-evolutions.md:135` | PanelMaster `settings/PanelEditor.lua:1441-1444` | `:1441` is blank | ROT |
| `open-evolutions.md:140` | MultiMeters `settings/Profiles.lua:121` | `local bus = NS.NewBusTarget and NS.NewBusTarget()` | MATCH |
| `open-evolutions.md:141` | KickCD `settings/Spells.lua:1422-1437` | `:1422` is blank | ROT |
| `open-evolutions.md:154` | KickCD `modules/IconGrid_Render.lua:381` | `` -- `units.<unit>.` says nothing about whose class it means (options-ui-§17). `` | ROT |

**Totals:**

| Set | Citations | MATCH | ROT | GONE |
|---|---|---|---|---|
| A | 23 | 6 | 12 | 5 |
| B | 14 | 0 | 14 | 0 |
| C | 24 | 6 | 17 | 1 |
| **All** | **61** | **12** | **43** | **6** |

**WAS-05.** `AUDIT.md:522-523`: `player would watch change for nothing. The measured case is BankLedger: three host title bars` / `` behind `modules/Browser.lua:98`, and a fourth close control on a copy window the library ``. In BankLedger `master`, `modules/Browser.lua:98` reads `--` and `:103` reads `function B:MakeCloseButton(parent, onClick)`. Of the four playbooks, this is the only file:line citation (`grep -noE '[A-Za-z_/.-]+\.(lua|md|toc)`?:[0-9]+'` over AUDIT.md, AUTOMATED_TESTS.md, NEW_ADDON.md and PERF_ANALYSIS.md returns `AUDIT.md:523` alone).

## E6 — Inventories (WAS-06). Each figure was re-derived from the tree.

**Re-vendor store.** Scope: `git ls-tree -r master docs/revendor` in each of the 11 addons. A bundle is a `docs/revendor/<name>/` directory. "Tagged" means the name contains `vX.Y.Z`.

```
stores=11 bundles=225 tagged=197 bare=28 all-five=57 no-04=87 stable-two-only=65 other-shapes=16
```

Against:

- `audit-review-history.md:9`: `` … Of the sixty-eight bundles the collection has on disk, forty carry all five, nineteen have no `04_EXECUTION_PLAN.md` … nine carry the two stable members alone … ``
- `audit-review-history.md:11`: `**The re-vendor folder carries the tag, not the date alone (MUST).** Forty of the sixty-eight bundles on disk are …`
- `audit-review-history.md:25`: `This convention was consensual, and it lapsed in every repo that held it inside a day. Ten addons ship`
- `audit-review-history.md:51`: `` the bundle's `01_DELTA.md` opening line instead. Twenty-eight of the sixty-eight bundles are … ``
- `AUDIT.md:343`: `Measured across the ten stores, every in-scope commit resolves a tag this way and none is lost`
- `AUDIT.md:347-348`: `grandfathers the bare-dated folders rather than renaming them, and twenty-eight of the collection's` / `sixty-eight bundles are bare-dated, spread across all ten stores.`
- `documentation.md:359`: `` rather than per-repo. Ten addons ship the re-vendor store (`audit-review-history`), and all ten had to ``

**Cap heading.** Scope: `docs/ARCHITECTURE.md` on master in the 11 addons and LibKa0s. The result is 11 of 11 addons, every one nested at `###` under `## Documented deviations`: AT `:384`, AM `:424`, BL `:453`, CM `:383`, KC `:369`, LH `:425`, MM `:479`, PM `:372`, PFE `:430`, PC `:337`, WG `:389`. LibKa0s has no `docs/ARCHITECTURE.md` on master. This is against `documentation.md:150`: `` … Of the four repositories that carry the heading today, **two** nest it exactly there; a third keeps it under `## Layout`, and the library repo keeps it as a sibling `##` … ``

**Hub self-row.** Measured with `grep -cE '^\| \`?(docs/)?ARCHITECTURE\.md'`:

- Have it (6): BankLedger `:395`, ConsumableMaster `:327`, KickCD `:279`, LootHistory `:333`, MultiMeters `:344`, PartyFrameEnhanced (1 hit).
- Do not (5): AbsorbTracker, AuraMaster, PanelMaster, PrettyChat, WhatGroup.

This is against `AUDIT.md:145-146`: `… and the collection is split five to` / `four over a row that changes nothing.`

**Fourth table.**

- `standards/EXECUTIVE_SUMMARY.md:36`: `` … the verification-and-record table holding `testing.md`, `smoke-tests.md` and the record docs, which sit outside the tier model, and which all eleven addons wrote before the standard named it) … ``
- Against `documentation.md:391`: `**Nine of nine addons wrote the missing table before the standard named it**, independently and under`

AuraMaster and PartyFrameEnhanced joined the roster after the amendment, so "nine of nine" is the true figure.

**LSMPatch.**

- `library-stack.md:382`: `` **The case this is written against.** Five addons ship a private `core/LSMPatch.lua` that re-registers ``
- `git -C <addon> cat-file -e master:core/LSMPatch.lua` fails in all five named addons: 0 files.

**Compat sizes.** `documentation.md:297` begins `` read four ways, and the readings do not track size. `MultiMeters/core/Compat.lua` is 761 lines `` and continues `publishing 28 shims …`. Re-measured with documentation-§3's own grep, `grep -cE '^\s*function\s+[A-Za-z_][A-Za-z0-9_]*\.' core/Compat.lua`:

| Addon | Lines | Shims |
|---|---|---|
| MultiMeters | 770 | 26 |
| BankLedger | 175 | 13 |
| KickCD | 493 | 8 |
| LootHistory | 863 | 57 |
| PanelMaster | 195 | 8 |
| ConsumableMaster | 97 | 3 |
| WhatGroup | 199 | 9 |
| AuraMaster | 427 | 26 |
| PartyFrameEnhanced | 223 | 14 |
| AbsorbTracker | — | no file |
| PrettyChat | — | no file |

"Three sits deliberately below every `core/Compat.lua`" (`:307`) still holds, with ConsumableMaster at exactly 3.

**Roster size in present-tense prose.**

- `standards/EXECUTIVE_SUMMARY.md:52`: `` … a repo that ships Lua to the client — the eight addons, and `LibKa0s` vendored into their `libs/` — pins `* text=auto eol=crlf` … ``
- Against `line-endings.md:72`: `` That is the eleven addon repos — `AbsorbTracker`, `AuraMaster`, `BankLedger`, ``
- Also "nine addons" at `library-stack.md:95`, `open-evolutions.md:71`, `options-ui.md:376` and `options-ui.md:408`.

Scope of the sweep: `grep -noiE '\b(the )?(eight|nine|ten) (addons|addon repos|repos)\b'` over live docs found 29 hits. Only these five are present-tense roster claims. The rest describe a dated measurement.

**PrettyChat generator.**

- `layout.md:93`: `` … Pretty Chat answered it the other way and is **newly non-compliant**: its splitter sits at `GlobalStrings/split_globalstrings.py`, … ``
- `AUDIT.md:270`: `` … Known instance at ratification: Pretty Chat's `GlobalStrings/split_globalstrings.py`, … until the repo either moves it or registers a row. ``
- `git -C PrettyChat ls-tree -r --name-only master | grep split_globalstrings` returns `tools/split_globalstrings.py`.

**Verified correct, and not filed.** Scope: every live-doc statement of the `LibKa0s` figure.

```
$ git -C ../LibKa0s describe --tags --abbrev=0                       → v1.70.0
$ git -C ../LibKa0s ls-tree -r v1.70.0 --name-only LibKa0s | grep -c '\.lua$'  → 34
$ grep -c 'major = "LibKa0s-' ../LibKa0s/tests/majors.lua            → 15
$ grep -c '<Script' ../LibKa0s/LibKa0s/LibKa0s.xml                   → 34
Options 10, Widgets 5, Perf 4, DebugLog 3, Slash 2
```

That matches `library-stack.md:82`, `STANDARDS.md:57`, `EXECUTIVE_SUMMARY.md:56`, `open-evolutions.md:13` and `anti-patterns.md:54`.

## E7 — Internal consistency (WAS-07, WAS-09, WAS-10, WAS-11)

**WAS-07.**

- `documentation.md:148` lists `… **Known Limitations**, **\`## Documentation map\`** — … — and **\`## Documented deviations\`** …`. Documented deviations is tenth in that list.
- `documentation.md:170`: `- **MUST** carry \`## Documented deviations\` in \`docs/ARCHITECTURE.md\` — the ninth mandated section,`
- `documentation.md:347`: `##### \`## Documentation map\` — the tenth \`ARCHITECTURE.md\` section (MUST)`

**WAS-09.**

- `documentation.md:625-626`: `` **Frozen bundles are exempt and MUST NOT be swept.** Anything under `docs/audits/`, `docs/reviews/`, `` / `` `docs/automated-tests/` or `docs/revendor/` is a point-in-time record … ``
- `documentation.md:634-636`, the sweep command: `--exclude-dir=libs --exclude-dir=_kit --exclude-dir=audits --exclude-dir=reviews --exclude-dir=automated-tests --exclude-dir=revendor`
- Against `documentation.md:353-356`, which lists seven stores including `` `docs/perf-analysis/<run>/` ``, `` `docs/superpowers/` `` and `` `docs/investigations/` ``.

Measured over the tracked frozen material the §6 list omits. Scope: `git grep -nE '§[0-9]+\.[0-9]' master -- docs/perf-analysis docs/superpowers docs/investigations` in the 11 addons. Results: AuraMaster 18, LootHistory 117, MultiMeters 2, PartyFrameEnhanced 3, so **140**, every hit under `docs/superpowers/`. Every other addon has 0.

In this repo, the `filename-§N` range check found 9 malformed or out-of-range references, all inside frozen `harvests/`:

- `harvests/2026-08-25/02_FINDINGS.md:276`
- `harvests/2026-09-22/01_COLLECTION_STATE.md:75`
- `harvests/2026-09-22/02_FINDINGS.md:157`, `:214`, `:237`
- `harvests/2026-09-22/03_EVIDENCE.md:717` (two refs)
- `harvests/2026-09-22/06_OUTCOME.md:150`, `:257`

Neither §6 nor its command exempts `harvests/`.

**WAS-10.**

- `documentation.md:669`: `**The three lists are exhaustive, and the default is that a section applies.** Between them they classify **every** section in \`STANDARDS.md\`'s Sections list …`
- The section names in §8's three lists (`:671-703`) do not include `localization-§1` (`localization.md:11` `### 1. Module shape`), `§2` (`:36`), `§3` (`:41`), `§4` (`:71`), or `documentation-§9` (`documentation.md:714`).
- `documentation.md:738-739` places §9 itself: `generator. In a documentation-and-tooling repo (documentation-§8) it binds unchanged and has no` / `instance until that repo authors Lua, …`
- On the arithmetic: `documentation.md:698` reads `` … Six of the ten mandated sections — Settings Schema, Message Bus, Slash Commands, Event Subscriptions, Taint Notes, and Module Map *as a Lua module map* — … The mandated set here is **five** … ``

**WAS-11.**

- `CLAUDE.md:155-156`: `` (`slash-dispatch.md`, `midnight-quirks.md`, `compat-layer.md`, `message-bus.md`, `profiles.md`, `` / `` `debug.md`) required per stated trigger … ``
- `EXECUTIVE_SUMMARY.md:38` lists `` `slash-dispatch.md` …, `midnight-quirks.md`, `compat-layer.md` …, `message-bus.md` …, `profiles.md`, `debug.md` ``, the same six.
- Against `documentation.md:271`: `` | `docs/perf-analysis/README.md` | the performance harness is wired (performance-§12) — specified above | ``
- And `AUDIT.md:116-117`: `` (b) **Tier 2 accounted for** — for each of `slash-dispatch.md`, … `debug.md`, `perf-analysis/README.md`, evaluate ``
- `CLAUDE.md:141`: `- **Never state a doc-set count without naming its members.** …`

## E8 — Cross-references (WAS-08). Scope: `git ls-files '*.md'`, 63 files.

```
$ python3 -I xref.py .   # every `<name>-§<n>?` token; name must be a section file, n in 1..max('### N.')
TOTAL 74
  58  filename-§           (placeholder literal in the scheme's own description: not a reference)
   2  tiered-layout-§      STANDARDS.md:236 (declared historical carve-out in that changelog entry)
   9  …                    harvests/ (frozen; E7)
   1  layout-§             STANDARDS.md:236 (same entry, "layout-§N" written as a template)
   1  slash-commands-§     documentation.md:596  (the deliberate malformed EXAMPLE "slash-commands-§:")
   1  preview-mode-§       STANDARDS.md:120      ← WAS-08
   1  automated-tests-§    STANDARDS.md:168      ← WAS-08  ("automated-tests-§?")
   1  options-ui-§         STANDARDS.md:189 ("options-ui-§N" written as a template: not a reference)
                           (58 + 2 + 9 + 1 + 1 + 1 + 1 + 1 = 74; the harvests 9 = options-ui-§ ×3, compat-§1 ×2,
                            packaging-§28/§29 ×2, architecture-§ ×1, events-frames-taint-§ ×1)
```

- `standards/STANDARDS.md:120`: `` - **v2.59.1 (2026-09-19):** **`preview-mode-§`'s two MUSTs read in tension for an addon that ships a real test mode.** ``. It was introduced in `9e8466b`, when `preview-mode.md` had 0 numbered subsections (`git show 9e8466b:standards/standards/preview-mode.md | grep -c '^### [0-9]'` returns 0).
- `standards/STANDARDS.md:168`: `` … `documentation-§1`'s optional-section note, the forbidden-`CHANGELOG` rule, `automated-tests-§?`'s release gate, … ``. It was introduced in `ad9a66c` (2026-09-10).
- `standards/standards/documentation.md:259`: `` … The engineer counterpart to the README's player-facing `## How <it> works` (documentation-§1 item 8); … ``
- Against `documentation.md:77`, which is item 6 (`` 6. **`## How <it> works`** — **MUST**. ``), and `:79`, which is item 8 (`` 8. **`## Troubleshooting`** — **SHOULD** … ``).

The remaining reference checks:

- **Retired dotted notation.** documentation-§6's command run verbatim from the repo root returns 0. The `git ls-files` variant over live docs also returns 0.
- **Anti-pattern numbers.** The highest referenced is #92, and the list has 92.
- **Plugin commands.** 16 distinct `dev-copilot:<name>` references, all present as `../dev-copilot/commands/<name>.md`. Live docs carry no `wow-addon:` reference outside dated history.
- **Kit files.** Every `tests/_kit/<file>` a live doc names exists at `LibKa0s` `master:testkit/<file>`. `Kit.VERSION = 37` at `testkit/framework.lua:20`.
- **Relative links.** All 40 apparent misses are placeholders (`…`, `media/logos/…`), artifact names inside a bundle shape (`lint.txt`, `dump.json`), or sibling-repo paths that exist (`../../AbsorbTracker/` and others). One is inside frozen `harvests/2026-09-22/05_RIPPLE_PLAN.md:33`.

## E9 — Changelog order (WAS-13)

```
$ python3 -I (parse '- **vX.Y.Z (date):**' lines in STANDARDS.md) → 99 entries; one non-monotonic pair:
  (217, 2.17.1, 2026-08-03) followed by (218, 2.19.0, 2026-08-04)
```

- `STANDARDS.md:215`: `- **v2.18.0 (2026-08-04):** …`
- `STANDARDS.md:217`: `- **v2.17.1 (2026-08-03):** …`
- `STANDARDS.md:218`: `- **v2.19.0 (2026-08-04):** **The four out-of-game suites now produce one consolidated, frozen record …`
- `standards/README.md:13`: `` | [`STANDARDS.md`](STANDARDS.md) | **The standard** — canonical. Everything else supports this. Versioned via the changelog at its top. | ``
- Against `standards/README.md:32`: `` changelog entry first in the `## Changelog` section of `STANDARDS.md` (after the Sections map); ``

## E10 — Register read (WAS-14)

```
$ gh issue list --state all --limit 200 --json number,title,state,labels
7  CLOSED  enhancement,state:done,severity:low       architecture-§5: does the one-write-helper MUST cover structural registries…
6  CLOSED  bug,state:done,severity:medium            Complexity gate: lizard reads Lua's # length operator …
5  CLOSED  state:will-not-do,severity:low            Turn on linting for 308 test files in one step: declined …
4  CLOSED  state:will-not-do,severity:low            Annotate every TOC line: declined …
3  CLOSED  state:will-not-do,severity:low            Backfill ANALYSIS.md into the 35 frozen bundles: declined …
2  CLOSED  state:will-not-do,severity:medium         toc-file-§5 and layout-§1 give contradictory orderings …
1  CLOSED  state:done,severity:low                   toc-file-§5 and layout-§1 mandate contradictory load orders
```

- `docs/ARCHITECTURE.md:90-92`: `## Documented deviations` / (blank) / `**None.**`
- The bodies of #3, #4 and #5 each open `**A decision this cycle took and did not act on …**` and decline collection work.
- #2 asks for one ordering. It is resolved: `standards/standards/layout.md:55` reads `` - **MUST** load in this **folder** order: `libs/*` → `locales/*` → `core/*` → `defaults/*` → `modules/*` → `settings/*`. … ``, and `standards/standards/toc-file.md:110` reads `` - **MUST** use `#` section headers, in the order **Libraries → Locales → Core → Defaults → Modules → Settings** — the same folder load order `layout-§1` states … ``.
- No issue carries a `[status]` title prefix. There is no `docs/pending/`.
- Only the `gh issue` subcommands were used, with no GraphQL.

## E11 — Not applicable, with reasons (documentation-§8)

| Check | Reason |
|---|---|
| `luacheck .` | No `.luacheckrc` and 0 `.lua` (E1) |
| Headless runner | No `tests/` |
| Vendored-library `diff -r` and the provenance line | No `libs/`, no `tests/_kit/`, and no `Bundles [LibKa0s]` line is required |
| Sighted complexity suite / `lizard` | No functions to measure, and no `tests/_kit/run-automated-tests.sh` |
| Disabled-state registration census | No addon runtime |
| `.pkgmeta` dot-entry checks | `packaging` does not apply. No `.pkgmeta`, and no packaged artifact |
