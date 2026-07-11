# prettychat — Current State Analysis (2026-05-03)

Read-only analysis of `/mnt/d/Profile/Users/Tushar/Documents/GIT/prettychat`. All citations refer to source files; documentation is verified against code, not the reverse.

## 1. TOC metadata

Full quote of `PrettyChat.toc:1-10`:

```
## Interface: 120000,120001,120005
## Title: Ka0s |cffff0000P|cffff9900r|cffffff00e|cff00ff00t|cff00fffft|cff4a86e8y |cff0000ffC|cff9900ffh|cffff00ffa|cffefefeft|r
## Version: 1.3.0
## Author: aDd1kTeD2Ka0s
## Notes: Prettier chat messages
## iconTexture: 2056011
## SavedVariables: PrettyChatDB
## DefaultState: enabled
## Category-enUS: Chat & Communication
## X-License: MIT
```

Sub-TOC `GlobalStrings/GlobalStrings.toc:1-6` is a separate `LoadOnDemand: 1` packaging of the strings dictionary, version 1.1.0; same Interface line.

## 2. Folder / file layout

```
prettychat/
  PrettyChat.toc            (PrettyChat.toc, 35 lines)
  PrettyChat.lua            (614 LOC)
  Config.lua                (652 LOC) — largest source file
  Defaults.lua              (366 LOC)
  Schema.lua                (237 LOC)
  Constants.lua             (54 LOC)
  README.md, ARCHITECTURE.md, CLAUDE.md, TODO.md, LICENSE
  .gitattributes, .gitignore
  Libs/
    LibStub/, CallbackHandler-1.0/, AceAddon-3.0/, AceDB-3.0/,
    AceConsole-3.0/, AceGUI-3.0/, AceConfig-3.0/  (vendored, NOT loaded)
  GlobalStrings/
    GlobalStrings.lua             (23,842 LOC — source-only, not in any TOC)
    GlobalStrings_001.lua…_010.lua (22,879 entries total across chunks)
    GlobalStrings.toc             (LoD sub-addon)
    split_globalstrings.py        (regen helper)
    README.md
  docs/                     (10 topic docs)
  media/screenshots/        (logo + before/after)
  reviews/2026-05-02/       (5-doc prior-review bundle)
```

Largest *single* file by LOC is `GlobalStrings/GlobalStrings.lua` at 23,842 lines (source dump, not TOC-loaded). Largest *runtime* file is `Config.lua` at 652 lines (`Config.lua:1-652`). Largest TOC-loaded data file is `GlobalStrings_009.lua` at 3,284 lines.

`GlobalStrings/` contents (`GlobalStrings/README.md:1-15`): 10 alphabetical chunk files written as `PrettyChatGlobalStrings["KEY"] = "value"` assignments (e.g. `GlobalStrings_001.lua:1-2`), plus a master `GlobalStrings.lua` that is *not* loaded by any TOC (used only as input to `split_globalstrings.py`), plus a Python splitter script that rebalances the chunks and rewrites `GlobalStrings.toc`. The chunked files dual-load: eagerly under the parent TOC so the panel can resolve "Original Format String" without a load step, and as an LoD sub-addon `PrettyChat - GlobalStrings` for any future on-demand consumer.

## 3. Module-loading order (TOC)

`PrettyChat.toc:12-34`, in order:

1. `Libs/LibStub/LibStub.lua`
2. `Libs/CallbackHandler-1.0/CallbackHandler-1.0.xml`
3. `Libs/AceAddon-3.0/AceAddon-3.0.xml`
4. `Libs/AceDB-3.0/AceDB-3.0.xml`
5. `Libs/AceConsole-3.0/AceConsole-3.0.xml`
6. `Libs/AceGUI-3.0/AceGUI-3.0.xml`
7. `GlobalStrings/GlobalStrings_001.lua` … `_010.lua` (10 files)
8. `Constants.lua`
9. `Defaults.lua`
10. `PrettyChat.lua`
11. `Schema.lua`
12. `Config.lua`

Note `Libs/AceConfig-3.0/` is on disk under `Libs/` but **not** referenced by the TOC; it is dead-vendored.

## 4. Library stack

Under `Libs/`:

- `LibStub` — `Libs/LibStub/LibStub.lua:3` declares `LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2`.
- `CallbackHandler-1.0` — `Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua:2` declares MINOR=8.
- `AceAddon-3.0` — embedded.
- `AceDB-3.0` — embedded.
- `AceConsole-3.0` — embedded (mixed into the addon object via `:NewAddon("PrettyChat", "AceConsole-3.0")` at `PrettyChat.lua:3`).
- `AceGUI-3.0` — embedded for canvas widgets in `Config.lua`.
- `AceConfig-3.0` — vendored on disk but **not loaded** by the TOC; no live consumer (confirmed by `reviews/2026-05-02/05_FINAL_SUMMARY.md:84-91`, M5).

Embedding: standard Ace3 vendoring via `.xml` aggregator files. Lib MAJOR/MINOR not surfaced in the TOC (no `## OptionalDeps` / `## X-Embeds`).

## 5. Core architecture pattern

Five-file Lua module split with a virtual single-namespace publish surface (`local addonName, ns = ...` idiom in every file; CLAUDE.md table at lines 31-39).

- **Entry point** — `PrettyChat.lua:3` creates the AceAddon: `LibStub("AceAddon-3.0"):NewAddon("PrettyChat", "AceConsole-3.0")`. Lifecycle is `OnInitialize` (`PrettyChat.lua:30`) registering AceDB and slash commands; `OnEnable` (`PrettyChat.lua:37`) snapshots Blizzard originals, calls `ApplyStrings`, and triggers panel registration via `ns.Config.RegisterPanels()`.
- `Constants.lua` — pure data: panel layout integers + `Const.Color` palette (`Constants.lua:45-54`).
- `Defaults.lua` — populates the global `PrettyChatDefaults` table with 8 categories of format strings + per-category `enabled` flag and per-string `label`/`default` (`Defaults.lua:1-4`).
- `PrettyChat.lua` — addon object, snapshot/apply/restore pipeline (`ApplyStrings` at `PrettyChat.lua:138-153`), `Test`, `RenderSample`, and the `COMMANDS`-table-driven slash dispatcher (`PrettyChat.lua:362-379`).
- `Schema.lua` — builds two parallel structures (`rows[]` ordered list, `byPath{}` map) from `PrettyChatDefaults`, exposing `Schema.Get/Set/FindByPath/RowsByCategory/ResolveCategory` plus a refresher dispatch system (`Schema.lua:180-193`). Single write path is `Schema.Set` (`Schema.lua:200-207`).
- `Config.lua` — AceGUI canvas-layout panels: parent landing page + 9 sub-pages (General + 8 categories) registered via `Settings.RegisterCanvasLayoutCategory`/`Subcategory` (`Config.lua:609-647`).

The architecture is **string-replacement-only**: PrettyChat *never* hooks chat events or `AddMessage`. It mutates `_G[GLOBALNAME]` once on enable; WoW's chat code reads those globals lazily on each line (documented invariant `CLAUDE.md` Hard Rules and `ARCHITECTURE.md:43-53`).

## 6. Settings / saved variables

- AceDB-3.0 used at `PrettyChat.lua:31`: `LibStub("AceDB-3.0"):New("PrettyChatDB", defaults, true)`. Third arg `true` requests the shared **Default** profile rather than per-character.
- `defaults` table is local at `PrettyChat.lua:17-28` — only `profile.categories = {}`. The comment explicitly notes the empty table is documentation-only because AceDB does not merge `{}` into user-keyed sub-tables, and that `enabled` flags are intentionally absent so `nil` reads as default-true via `IsAddonEnabled`/`IsCategoryEnabled` (`PrettyChat.lua:109-121`).
- **Defaults.lua / Schema.lua interplay.** `Defaults.lua` is data-only — it populates `PrettyChatDefaults` (`Defaults.lua:1`) keyed by category → `{enabled, strings = {GLOBALNAME = {label, default}}}`. `Schema.lua:117-134` walks `CATEGORY_ORDER` (`Schema.lua:13-18`) and for each category inserts a `category_enabled` row and one `string_enabled` + one `string_format` row per global (`Schema.lua:46-112`). The General virtual category contributes one `addon_enabled` row at `Schema.lua:46-59`. Every row carries closure-bound `get`/`set` so the row table survives even though `PrettyChatDefaults` is the data source.
- **Migration.** Absent. There is no version-stamping in saved vars and no `OnDatabaseShutdown`/upgrade hook. Existing users who saved an `enabled = true` value before the M7 cleanup are unaffected because `IsAddonEnabled` accepts both `true` and `nil` (`PrettyChat.lua:109-113`).
- **Auto-clear on default.** `string_format` row's `set` closure at `Schema.lua:104-110` writes `nil` if the new value equals the PrettyChat default — `db.profile.categories[Cat].strings` never accumulates redundant entries.

## 7. Options UI

Modern **canvas-layout** registration (`Config.lua:593-648`):

- Guarded existence check for `Settings.RegisterCanvasLayoutCategory` / `…Subcategory` / `RegisterAddOnCategory` at `Config.lua:594-598` — graceful no-op on older clients.
- Parent page registered via `Settings.RegisterCanvasLayoutCategory(parentCtx.panel, PARENT_TITLE)` at `Config.lua:609`, followed by `Settings.RegisterAddOnCategory(mainCategory)` (line 610) so the panel sits in the addon list.
- 9 sub-pages registered via `Settings.RegisterCanvasLayoutSubcategory(mainCategory, catCtx.panel, category)` at `Config.lua:646-647` — General, then `Loot, Currency, Money, Reputation, Experience, Honor, Tradeskill, Misc`.
- Each sub-page defers AceGUI body rendering until first `OnShow` (`Config.lua:603-606`, `624-643`) so AceGUI's `List` layout sees a non-zero container width.
- Custom always-show scrollbar patch reaching into AceGUI internals at `Config.lua:68-166` — the documented field-list comment at lines 60-66 is the diff guide if AceGUI changes.
- `OpenConfig` (`PrettyChat.lua:78-99`) gates the call with `InCombatLockdown` and prints a grey notice via `ns.Print` if `Settings.OpenToCategory` returns `false`. Auto-expands the parent category in the left tree via private `SettingsPanel:GetCategoryList` (`PrettyChat.lua:62-76`), wrapped in `pcall` because the API is private.
- AceConfig is **not** used; everything is hand-rolled AceGUI inside Blizzard canvas frames.

## 8. Slash commands

Two registrations at `PrettyChat.lua:33-34`: `pc` and `prettychat` (alias). Single dispatcher `OnSlashCommand` (`PrettyChat.lua:598-614`) walks the `COMMANDS` ordered table at `PrettyChat.lua:362-379`. Verbs:

| Verb | Handler | Cite |
|------|---------|------|
| `help` | `printHelp` | `PrettyChat.lua:386-393` |
| `config` | `OpenConfig` | `PrettyChat.lua:78-99` |
| `list` | `listSettings` | `PrettyChat.lua:401-464` (sub-keywords `category`, `formatstring`, plus category-name) |
| `get` | `getSetting` | `PrettyChat.lua:466-479` |
| `set` | `setSetting` | `PrettyChat.lua:481-516` (bool: true/false/on/off/yes/no/1/0) |
| `reset` | `runReset` | `PrettyChat.lua:518-533` |
| `resetall` | `runResetAll` | `PrettyChat.lua:535-538` |
| `test` | `runTest` | `PrettyChat.lua:549-596` (sub-keywords `all`, `category <name>`, `formatstring <NAME>`) |

`COMMANDS` is published on `ns.COMMANDS` (`PrettyChat.lua:384`) so `Config.lua:579-586` can render the same list on the parent page — no drift between help text and panel landing page.

## 9. Localization

**Absent.** AceLocale is not loaded, embedded, or referenced anywhere. All UI strings are hard-coded English literals in `Config.lua`, `PrettyChat.lua`, and the `label` fields in `Defaults.lua`. The TOC line `## Category-enUS: Chat & Communication` (`PrettyChat.toc:9`) is the only locale acknowledgement.

`GlobalStrings/` is **not a localization system** — it is a static reference dictionary of Blizzard's enUS GlobalStrings.lua (~22,879 entries, `PrettyChatGlobalStrings[KEY] = value`) used purely for the panel's read-only "Original" display (`Config.lua:416-418`). It does not vary by client locale — running a non-enUS client would show enUS originals while overriding the locale-specific `_G[GLOBALNAME]`. (Risk: format-specifier signatures may differ between locales when Blizzard rearranges `%n$type` positionals; addressed in `RenderSample` at `PrettyChat.lua:204-230` but not in the panel's "Original" display.)

Coverage: zero non-enUS coverage; English-only addon.

## 10. Events / chat-frame hooks

- `RegisterEvent` calls in addon code: **none.** `grep -rn RegisterEvent PrettyChat.lua Config.lua Schema.lua Constants.lua Defaults.lua` returns only library-internal usages.
- `ChatFrame_AddMessageEventFilter`: **absent.** Not used anywhere.
- `hooksecurefunc`: **absent** in addon code.
- Raw `AddMessage` replacement: **absent.** `DEFAULT_CHAT_FRAME:AddMessage` is *called* at `PrettyChat.lua:14, 261, 263, 292, 293, 296, 300, 304, 306, 320, 329` for output, but never replaced.
- Lifecycle is entirely Ace3-driven: `OnInitialize` (`PrettyChat.lua:30`) and `OnEnable` (`PrettyChat.lua:37`).
- One Blizzard `OnShow` script registered per panel (`Config.lua:603, 625, 638`).
- One `HookScript` in `attachTooltip` (`Config.lua:46-48`) for non-AceGUI frames — but the live call sites all pass AceGUI widgets, so this branch is currently dead.

The addon **does not hook chat at all**. Its entire reformatting strategy is `_G[GLOBALNAME]` mutation. This is the design's deliberate strength — taint-free, replication-safe, ChatFrame-implementation-agnostic.

## 11. Frames

No `CreateFrame("ChatFrame", …)`, no manipulation of `ChatFrame1..N`, no `ChatTypeInfo` mutation. The only `CreateFrame` calls are panel scaffolding in `Config.lua:222, 231` (the parent panel and its body container). All chat output goes through `DEFAULT_CHAT_FRAME:AddMessage` via `ns.Print` (`PrettyChat.lua:13-15`).

## 12. Debug / logging

**Absent as a system.** No `debug` flag in saved variables, no `/pc debug` verb, no log-level hierarchy. Diagnostic output is ad-hoc:

- `ns.Print` (`PrettyChat.lua:13-15`) — the chat chokepoint with cyan `[PC]` prefix.
- One-time `_expandWarned` flag at `PrettyChat.lua:96` so the SettingsPanel-private-API failure surfaces once per session as a grey notice rather than repeatedly.
- `Test` (`PrettyChat.lua:260-330`) — manual diagnostic that prints every active format string with sample args, gated by either a category or formatstring filter.

## 13. Error handling

- `pcall` wrapping for risky private-API calls: `PrettyChat.lua:63-74` (`expandMainCategory` wraps `SettingsPanel:GetCategoryList` / `:GetCategoryEntry`); `PrettyChat.lua:240` (`pcall(string.format, …)` in `RenderSample`); `Schema.lua:188, 192` (refresher dispatch wraps each closure).
- `Config.lua:527` wraps each per-string refresher.
- No `pcall` around hooked Blizzard callbacks because there are none.
- Chat-frame hook hazards: **N/A** — no hooks. The chosen architecture sidesteps the entire taint surface.
- Settings panel auto-expand failure is the only Blizzard-private-API exposure, and it's defended (`PrettyChat.lua:62-76, 95-98`).

## 14. Packaging

`.pkgmeta`: **absent.** `.gitattributes` exists at the repo root and forces CRLF on disk for all text files (`CLAUDE.md` Working Environment section). `.gitignore` covers OS/editor cruft, `TODO.md`, and `.claude/`. There is no CurseForge BigWigs/WowAce packager config; releases (per the README CurseForge badge) appear to be uploaded manually. No CI, no GitHub Actions config.

## 15. Documentation drift

### README.md (`README.md:1-99`)

5 verifiable claims:
1. "Eight format-bearing categories" — README:47-54 names 8 sub-pages (Loot/Currency/Money/Reputation/Experience/Honor/Tradeskill/Misc). `Schema.lua:13-17` confirms 8 + General. ✓
2. "Loot — 19 strings" — `Defaults.lua` Loot section starts at line 2 and contains 19 entries through the section close. ✓ (sample: 19 globals visible in initial scan; matches `reviews/2026-05-02/05_FINAL_SUMMARY.md:30` "81 rows over 79 unique globals"). ✓
3. `/pc list` accepts unambiguous prefixes — `Schema.lua:223-237` `ResolveCategory` implements exact-then-prefix matching. ✓
4. "settings stored in `PrettyChatDB` via AceDB on a single shared **Default** profile" — `PrettyChat.lua:31` confirms `defaultProfile=true`. ✓
5. Version 1.3.0 — `PrettyChat.toc:3` matches; README badge says `WoW-Midnight_12.0.5` matching `Interface: 120005`. ✓

No drift detected in README.

### CLAUDE.md

5 verifiable claims:
1. Single write path through `Schema.Set` — confirmed by `Schema.lua:200-207`. ✓
2. "Master toggle wins" 3-layer order — confirmed at `PrettyChat.lua:138-153`. ✓
3. Cyan `[PC]` prefix; `Test` writes directly via `AddMessage` but every line still carries `PREFIX` — confirmed at `PrettyChat.lua:6, 261-329`. ✓
4. `ns.Config.RegisterPanels()` called from `OnEnable` — confirmed at `PrettyChat.lua:50-52`. ✓
5. `PrettyChat` not on `ns`; reached via `LibStub("AceAddon-3.0"):GetAddon("PrettyChat")` — confirmed at `Schema.lua:3`, `Config.lua:3`. ✓

No drift detected in CLAUDE.md.

### ARCHITECTURE.md

5 verifiable claims:
1. "81 strings total" (`ARCHITECTURE.md:7`) — `reviews/2026-05-02/05_FINAL_SUMMARY.md:30` clarifies "81 rows over 79 unique globals" because of the Loot/Tradeskill cross-registrations. The bare "81 strings total" in ARCHITECTURE.md:7 is therefore mildly misleading — drift candidate. (Not corrected at line 7 even though it was corrected in `docs/file-index.md` and README.) ⚠
2. "Eight format-bearing categories with 81 strings total" — count detail: as above. The category count of 8 is correct.
3. "AceConfig-3.0 is vendored on disk but not loaded by the TOC" (`ARCHITECTURE.md:65-67`) — confirmed by TOC inspection and `reviews/2026-05-02/05_FINAL_SUMMARY.md:84-91`. ✓
4. Load order section (`ARCHITECTURE.md:71-82`) — matches TOC exactly. ✓
5. Dependency list (`ARCHITECTURE.md:57-64`) — 6 libs listed (LibStub/CallbackHandler/AceAddon/AceDB/AceConsole/AceGUI). Matches TOC. ✓

One minor drift: ARCHITECTURE.md:7 still says "81 strings" without the row-vs-global qualifier.

### TODO.md (`TODO.md:1-5`)

```
## Done
- Add reference to GlobalConstants, figure out sub variables and show them in the settings ui

## Backlog
- Update defaults
- Add ability to add custom replacements in a "Custom" section in the Settings Panel
```

Relevance check:
- "Done" item is delivered (the `PrettyChatGlobalStrings`-driven Original column in `Config.lua:412-422` is exactly that).
- "Update defaults" — vague; no acceptance criteria. Still relevant in spirit (defaults change with WoW patches).
- "Add a Custom section" — still relevant; no implementation found. The schema has 4 row kinds and `Defaults.lua` is a closed table.

`TODO.md` is listed in `.gitignore` per `CLAUDE.md` Working Environment but the file is present in the working tree (and confirmed untracked per `reviews/2026-05-02/05_FINAL_SUMMARY.md:174-177`).

### `docs/`

Ten topic docs exist (scope, file-index, module-map, override-pipeline, schema, settings-panel, slash-commands, smoke-tests, common-tasks, global-strings). Did not deep-audit each, but `reviews/2026-05-02/05_FINAL_SUMMARY.md:122-134` records doc-sync edits across the 2026-05-02 commit so docs are likely closer to truth than typical.

## 16. Tests / lint

- **`.luacheckrc`: absent.** No lint config at the repo root.
- **No automated tests.** `CLAUDE.md` Working Environment explicitly states "No automated tests. Validation is manual, in-game" and points to `docs/smoke-tests.md`. The smoke-test doc exists and breaks tests into Boot / Override / Panel / Slash / Sync / Persistence groups.
- No CI / no GitHub Actions config in repo.

## 17. Notable strengths

1. **Architecturally taint-free.** The decision to override `_G[GLOBALNAME]` rather than hook chat events sidesteps the entire chat-frame hook hazard surface — no `ChatFrame_AddMessageEventFilter`, no `AddMessage` replacement, no taint propagation. It's the cleanest possible chat-formatting model. (`PrettyChat.lua:38-44, 138-153`)
2. **Single write path strictly enforced.** Every settings mutation funnels through `Schema.Set` (`Schema.lua:200-207`) which centralizes both `PrettyChat:ApplyStrings()` and `Schema.NotifyPanelChange(category)`. Panel widgets and `/pc set` cannot drift apart.
3. **Schema-driven slash + panel parity.** `COMMANDS` table at `PrettyChat.lua:362-379` is the source for both the dispatcher and the panel's slash-command listing (`Config.lua:579-586`). Adding a verb only takes one row.
4. **Three-layer enable cascade with correct semantics.** Master → category → per-string, with `nil → true` as the read-side contract (`PrettyChat.lua:109-129`) so SavedVariables stays small until users actively disable. Auto-clear on default match (`Schema.lua:104-110`) keeps the DB lean.
5. **Defensive `OpenConfig`.** Combat-lockdown gate, `Settings.OpenToCategory` return-value check, and a one-time-warned auto-expand around private SettingsPanel API (`PrettyChat.lua:62-99`) — no silent failures.
6. **`RenderSample` handles positional `%n$type`.** `PrettyChat.lua:204-230` correctly fills positional gaps so non-enUS Blizzard format strings preview without `string.format` errors.
7. **Excellent inline comment quality.** Every non-obvious choice is documented with the *why* (e.g. `PrettyChat.lua:17-28` defaults table comment, `Schema.lua:37-41` row-set contract, `Config.lua:60-66` AceGUI internals diff list). Drift cost on future Blizzard / AceGUI changes is minimized.
8. **Prior-review discipline.** `reviews/2026-05-02/` is a complete 5-doc cycle (findings/proposed/smoke/execution/summary) that closed 18 findings in one commit; TODO/CLAUDE/ARCHITECTURE coherence is unusually high.

## 18. Notable weaknesses

1. **No localization.** No AceLocale, no `Locales/` folder; every UI string is hard-coded English in `Config.lua` and `Defaults.lua`. Non-enUS users get an English settings panel sitting alongside their localized chat. The "Original" column in the panel always shows enUS values from `PrettyChatGlobalStrings` — confusing on a deDE/frFR client where actual `_G[GLOBALNAME]` differs.
2. **Loot/Tradeskill cross-registration race.** `LOOT_ITEM_CREATED_SELF` and `_MULTIPLE` are registered under both Loot and Tradeskill (`Schema.lua:140-159` builds `crossRegisteredGlobals`). The last category to iterate wins on `/reload` because `pairs(PrettyChatDefaults)` order is non-deterministic — `ApplyStrings` (`PrettyChat.lua:138-153`) uses `pairs`. The tooltip warns the user but the code does not deterministically resolve which category wins.
3. **Vendored-but-unused AceConfig-3.0.** `Libs/AceConfig-3.0/` exists on disk, not in TOC. Adds 100s of KB of dead code in the repo. Either re-wire or remove.
4. **No `.pkgmeta`.** Releases must be assembled manually; CurseForge auto-packaging unavailable. No way to externalize Libs.
5. **No `.luacheckrc` and no CI.** Lint regressions are caught only by manual review. The codebase is ~1900 LOC of source — small enough to review but easy to backslide.
6. **No SavedVariables migration story.** No version stamp in `PrettyChatDB`; if the schema's path scheme ever changes, existing DBs become hostile. Today's reads tolerate `nil`/`true`/`false` for `enabled`, but a future rename of a GlobalString key would silently abandon a user's edits.
7. **`GlobalStrings` chunked dictionary is heavy.** ~22,879 entries loaded eagerly into `PrettyChatGlobalStrings` — only ~80 globals are actually referenced (the ones in `PrettyChatDefaults`). The remaining ~22,799 entries are pure RAM cost paid by every player. The LoD sub-addon route is configured (`GlobalStrings/GlobalStrings.toc:6`) but the parent TOC loads chunks eagerly anyway (`PrettyChat.toc:19-28`).
8. **Reaches into AceGUI ScrollFrame internals.** `Config.lua:68-166` patches `FixScroll`, `MoveScroll`, `OnRelease`, mutates `scrollframe`, `scrollbar`, `content.original_width`, `localstatus`, `scrollBarShown`, `updateLock`. Documented as a known fragility but still a maintenance liability tied to a specific bundled AceGUI revision.
9. **Reaches into private SettingsPanel API.** `expandMainCategory` (`PrettyChat.lua:61-76`) calls `SettingsPanel:GetCategoryList`/`GetCategoryEntry`/`SetExpanded`. Defended by `pcall` and a one-time grey notice but still patch-fragile.
10. **`attachTooltip` HookScript branch is dead.** `Config.lua:46-48` handles non-AceGUI widgets via `HookScript`, but every call site passes AceGUI widgets — so the branch never executes. Dead code.
11. **No deprecated chat APIs in use** — but the ARCHITECTURE.md:7 "81 strings total" claim is mildly out of sync with `reviews/2026-05-02/05_FINAL_SUMMARY.md:30`'s "81 rows over 79 unique globals" qualifier; doc drift is fixable but present.

## Sibling-naming inconsistencies

- Folder `Libs/` is capitalized, vs lowercase `libs/` reportedly used elsewhere in the GIT/ collection.
- Folder `GlobalStrings/` exists (no sibling parallel).
- `TODO.md` is checked-in (untracked but present in the tree); other addons in the collection may not carry one.
- Addon folder is lowercase `prettychat` while the TOC name is `PrettyChat` — case mismatch between filesystem path and `addonName` ABI requires care if any code uses raw paths (logo path at `Config.lua:16-17` uses `addonName` so it's fine).
