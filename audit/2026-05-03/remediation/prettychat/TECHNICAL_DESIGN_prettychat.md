# Technical Design — prettychat → PrettyChat (2026-05-03)

**Addon:** prettychat (current folder, lowercase) — to be renamed to **PrettyChat**.
**Tier:** Tier 1 (flat).
**Standards baseline:** `WowAddonStandards/03_STANDARDS.md`.
**Findings consumed:** `WowAddonStandards/04_DEVIATIONS.md` PC-1 .. PC-15 plus raw `_raw/prettychat.md`.
**Source root (current):** `/mnt/d/Profile/Users/Tushar/Documents/GIT/prettychat/`.

This is the principal-engineer-level HLD + LLD that the executing subagent will work from. The agent has no other context.

---

## 1. Goal

Bring prettychat to **full standards compliance** (every PC-1..PC-15 finding closed) **without disturbing the addon's defining architectural strength**: chat-formatter via `_G[GLOBALSTRING]` override, no chat-frame hooks. As part of the work, rename the addon folder from `prettychat` to `PrettyChat` (PC-4) — coordinated with a SavedVariables migration so existing user installs do not lose data.

The end-state addon is identical in behavior, smaller in footprint (PC-12 GlobalStrings diet), localizable (PC-7 scaffold), packageable (PC-1 `.pkgmeta`), lintable (PC-2 `.luacheckrc`), publishable (PC-3 X-IDs), and folder-correct (PC-4, PC-5).

---

## 2. Scope

In scope: PC-1 through PC-15 from `04_DEVIATIONS.md`.

| # | Finding (one line) | Severity |
|---|---|---|
| PC-1 | No `.pkgmeta`. | 🔴 |
| PC-2 | No `.luacheckrc`. | 🔴 |
| PC-3 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | 🔴 |
| PC-4 | Folder lowercase `prettychat` — rename to `PrettyChat`. | 🔴 |
| PC-5 | `Libs/` PascalCase — rename to `libs/`. | 🔴 |
| PC-6 | LOOT_ITEM_CREATED_SELF / _MULTIPLE cross-registration race (`pairs()` in `ApplyStrings`). | 🔴 |
| PC-7 | No localization. | 🟠 |
| PC-8 | Vendored-but-unused AceConfig-3.0. | 🟠 |
| PC-9 | No SavedVariables migration runner. | 🟠 |
| PC-10 | No `Compat.lua`. | 🟠 |
| PC-11 | Hand-rolled `SLASH_*` (already AceConsole here — see note in §4 PC-11). | 🟠 |
| PC-12 | 22,879-entry GlobalStrings dictionary loaded eagerly for ~80 referenced globals. | 🟠 |
| PC-13 | `ARCHITECTURE.md:7` "81 strings total" drift vs `reviews/2026-05-02/05_FINAL_SUMMARY.md` "81 rows over 79 unique globals". | 🟡 |
| PC-14 | `attachTooltip` `HookScript` branch dead (`Config.lua:46-48`). | 🟡 |
| PC-15 | `TODO.md` at root. | 🟡 |

Out of scope: see §6.

---

## 3. HLD — System view

### 3.1 Current layout (Tier 1, lowercase folder)

```
prettychat/                          <-- lowercase (PC-4)
  PrettyChat.toc
  PrettyChat.lua          (614 LOC; entry, AceAddon, ApplyStrings, slash)
  Schema.lua              (237 LOC; rows[], byPath{}, single write path)
  Defaults.lua            (366 LOC; PrettyChatDefaults table)
  Constants.lua           ( 54 LOC; ns.Const palette + layout)
  Config.lua              (652 LOC; AceGUI canvas-layout panel)
  TODO.md                                            <-- (PC-15)
  README.md  CLAUDE.md  ARCHITECTURE.md  LICENSE
  .gitattributes  .gitignore
  Libs/                                              <-- PascalCase (PC-5)
    LibStub/  CallbackHandler-1.0/  AceAddon-3.0/  AceDB-3.0/
    AceConsole-3.0/  AceGUI-3.0/
    AceConfig-3.0/                                   <-- on disk, unloaded (PC-8)
  GlobalStrings/
    GlobalStrings.toc            (LoadOnDemand sub-addon)
    GlobalStrings_001..010.lua   (22,879 entries; eagerly loaded by parent TOC)
    GlobalStrings.lua            (source dump; not in any TOC)
    split_globalstrings.py       (regen helper)
    README.md
  docs/                          (10 topic docs)
  media/screenshots/             (logo, before/after)
  reviews/2026-05-02/            (5-doc audit bundle)
```

### 3.2 Post-remediation layout

```
PrettyChat/                          <-- PascalCase (PC-4)
  PrettyChat.toc                     (X-Curse-Project-ID + X-Wago-ID; LoD GlobalStrings sub-addon as Dependency only if (a))
  PrettyChat.lua                     (ordered crossRegistration; SV migration call)
  Schema.lua                         (loot-race ordered table; new schemaVersion default)
  Defaults.lua                       (unchanged data)
  Constants.lua                      (unchanged)
  Config.lua                         (PC-14 dead branch removed)
  Compat.lua                         <-- NEW (PC-10)
  Locale.lua                         <-- NEW (PC-7 scaffold)
  Database.lua                       <-- NEW (PC-9 migration runner; SV-rename copy)
  README.md  CLAUDE.md  ARCHITECTURE.md  LICENSE
  .pkgmeta                           <-- NEW (PC-1)
  .luacheckrc                        <-- NEW (PC-2)
  .gitattributes  .gitignore
  libs/                              <-- lowercase (PC-5)
    (Ace3 libs — kept vendored; .pkgmeta declares them as externals for release builds)
    [AceConfig-3.0 deleted — PC-8]
  GlobalStrings/
    GlobalStrings.toc                (unchanged LoD sub-addon — option (a) future)
    GlobalStrings_referenced.lua     <-- NEW slimmed dictionary (~80 entries; PC-12 plan (b))
    [GlobalStrings_001..010.lua kept on disk for splitter regen but NOT loaded by parent TOC]
  docs/                              (PC-13 sync)
  media/
  reviews/
    2026-05-02/                      (existing)
    2026-05-03/                      <-- this remediation cycle's bundle
```

### 3.3 Critical pattern to PRESERVE

The defining architectural strength of this addon is the **chat-formatter via `_G[GLOBALSTRING]` override** approach. **Remediation MUST NOT introduce any of:**

- `ChatFrame_AddMessageEventFilter` registration.
- `hooksecurefunc(ChatFrame*, "AddMessage", ...)`.
- Direct replacement of `AddMessage` on any chat frame.
- Any `RegisterEvent("CHAT_MSG_*")` subscription used to rewrite messages.

The only chat-frame interaction permitted is the already-existing `DEFAULT_CHAT_FRAME:AddMessage` *output* sink in `ns.Print` and in `PrettyChat:Test`. These call AddMessage — they do not replace it.

The verification step at the end of each milestone (and the M10 release-prep smoke test) MUST grep the source for the four forbidden patterns and confirm zero hits.

### 3.4 Data flow (preserved end-to-end)

```
   user types /pc set Loot.LOOT_ITEM_SELF.format "..."
            │
            ▼
     ns.Schema.Set(path, value)              <-- single write path
            │
            ├─▶ row.set()       (pure DB write into PrettyChatDB.profile.categories)
            ├─▶ PrettyChat:ApplyStrings()
            │       │
            │       ▼
            │   _G["LOOT_ITEM_SELF"] = "<formatted string>"     <-- the override
            │
            └─▶ Schema.NotifyPanelChange(category)   (refreshes any open AceGUI sub-page)

   later, when WoW's chat code emits a loot line:
            │
            ▼
     CHAT_MSG_LOOT handler reads _G["LOOT_ITEM_SELF"] LAZILY
            │
            ▼
     formatted message appears in ChatFrame   (PrettyChat is uninvolved at this step)
```

The remediation does not touch any arrow in this diagram. PC-6 fixes the *order* of the override-write loop; the loop itself is untouched.

---

## 4. LLD — Per-deviation design

Each finding lists: current state file:line, target state, migration steps, risks.

### PC-1 — No `.pkgmeta`

- **Current:** absent (verified — no file at `/mnt/d/.../prettychat/.pkgmeta`).
- **Target:** `.pkgmeta` at addon root declaring Ace3 libs as `externals:`, `package-as: PrettyChat`, ignore `reviews/`, `docs/internal/`, `_dev/`, `*.bak`, `TODO.md`.
- **Migration:** new file. Use the §13 standard template. Keep the on-disk `libs/` tracked (mixed model: externals for release builds, vendored for git checkout convenience).
- **Risks:** none until the user starts using BigWigsMods packager. The vendored `libs/` tree will be replaced at release-build time by external clones — verify Ace3 versions track the curseforge SVN trunk after the first packaged release.

### PC-2 — No `.luacheckrc`

- **Current:** absent.
- **Target:** `.luacheckrc` at root. `std = "lua51"`, `exclude_files = { "libs/", "reviews/", "GlobalStrings/", "_dev/" }`, `read_globals` includes `LibStub`, `CreateFrame`, `Settings`, `SettingsPanel`, `C_AddOns`, `C_Timer`, `InCombatLockdown`, `DEFAULT_CHAT_FRAME`, `GameTooltip`, `_G`, `unpack`, `select`, `string`, `table`, `tonumber`, `tostring`, `pairs`, `ipairs`, `next`, `pcall`, `type`, `print`. `globals` contains exactly `PrettyChatDB`, `PrettyChatDefaults`, `PrettyChatGlobalStrings`. Ignore codes: `212/self`, `212/event`, `631` (line length).
- **Migration:** new file.
- **Risks:** lint sweep will surface unused locals; fix-as-found in M1 verify step.

### PC-3 — TOC missing `X-Curse-Project-ID` / `X-Wago-ID`

- **Current:** `PrettyChat.toc:1-10` — no X-Curse-Project-ID, no X-Wago-ID.
- **Target:** add both lines after `## X-License: MIT`. Project IDs are placeholders that the user fills in once published — until then, ship the lines commented-out and flag in README so the omission is intentional (per standard §2.1: "mandatory if published"; the user has CurseForge listing per WhatGroup parallel — confirm at execution time).
- **Migration:** trivial TOC edit.
- **Risks:** none.

### PC-4 — Folder rename `prettychat` → `PrettyChat` (HIGH-RISK FOR USERS)

- **Current:** addon folder is lowercase `prettychat` on disk. Standard §1.3 mandates PascalCase.
- **Target:** folder is `PrettyChat`.
- **Why this is high-risk:**
  1. **Folder name is the addon ID.** Blizzard treats `Interface/AddOns/<FOLDERNAME>` as the addon's identity. The folder rename causes every user's `addon enabled` state, list position, and load relationships to potentially reset.
  2. **SavedVariables file is named after the addon folder.** WoW writes user settings to `WTF/Account/<account>/SavedVariables/<addonfolder>.lua`. The current file is `prettychat.lua`. After rename WoW writes `PrettyChat.lua` — and reads from it. The old `prettychat.lua` file is **orphaned**, taking the user's settings with it.
  3. **Windows is case-insensitive on default NTFS.** A direct `mv prettychat PrettyChat` is a no-op or silently fails on most user filesystems. WSL's `/mnt/d/...` reflects this. The repository itself, however, may be on a case-sensitive filesystem (git tracks case).
- **Two-stage rename plan (handles Windows + git):**
  ```
  Stage 1:  mv prettychat _pc_temp_         # always changes inode
  Stage 2:  mv _pc_temp_ PrettyChat
  Then:     git add -A   (git on Windows still records the case change correctly when the intermediate name differs)
  ```
- **SavedVariables migration plan:**
  - On first OnInitialize of the new build, `Database.lua` checks for the legacy global-namespace SV key. WoW guarantees that the SV file matching the **TOC's `## SavedVariables: PrettyChatDB`** is the one populated, *not* the one matching the folder name. Since `## SavedVariables: PrettyChatDB` was already correct (`PrettyChat.toc:7`), the **in-memory `PrettyChatDB` global is unchanged across the rename** — AceDB picks it up regardless of folder casing, because Blizzard reads the SV file off the addon's TOC-declared global name.
  - **What does change:** the on-disk SV *file*. Pre-rename, WoW wrote `WTF/.../SavedVariables/prettychat.lua`. Post-rename, it writes `PrettyChat.lua`. **Test this assumption at execution time** by inspecting an actual user WTF directory: open `prettychat.lua` (lowercase), confirm the global is `PrettyChatDB = { ... }`, and verify that on first launch of the renamed addon Blizzard *does* migrate the file (recent WoW client behavior is to load by SV-global match, then write back under the new folder name; this is the historical empirical behavior, but is to be re-verified by the executor).
  - **If the empirical test shows orphaning:** ship a one-shot transitional version with **two TOCs**: `prettychat/PrettyChat.toc` (a stub that copies `_G.PrettyChatDB` if non-nil and sets `_G.PrettyChatDB_migrated = true`, then disables itself) PLUS `PrettyChat/PrettyChat.toc` (the new version). The stub TOC contains `## LoadOnDemand: 0`, lists no `.lua` files except a tiny `Migrate.lua`. After one cycle ship the final version with only `PrettyChat`.
  - **Recommended primary plan:** because `## SavedVariables` decoupling is the documented Blizzard behavior, attempt the simple rename first; only fall back to the dual-TOC path if testing shows data loss.
- **Release-notes communication (must ship in README "Version History" entry and a chat banner on first load):**
  > **v1.4.0 — Folder renamed.**
  > The addon folder has been renamed from `prettychat` to `PrettyChat` to match the addon's display name. **Existing settings are preserved** — Blizzard stores SavedVariables under the addon's declared `PrettyChatDB`, so your customizations transfer automatically.
  > If you installed manually (not via the curse client), please **delete the old `prettychat` folder** from `Interface/AddOns/` after this update. The new folder is `PrettyChat`.
- **Risks:** (1) data loss if Blizzard does not migrate by SV-global key; mitigated by the executor's WTF-test gate before merging M8. (2) Users with both folders side-by-side will have the addon listed twice; the README note covers this. (3) curse client may treat the rename as a fresh install and not auto-cleanup the old folder; the curse client typically handles this by leaving the old folder until manual cleanup — acceptable.

### PC-5 — `Libs/` → `libs/` (case-insensitive hazard)

- **Current:** `prettychat/Libs/` PascalCase.
- **Target:** `prettychat/libs/` lowercase.
- **Migration:** same two-stage `Libs → _libs_temp_ → libs` rename. TOC lines (`PrettyChat.toc:12-17`) currently use `Libs\...` — rewrite to `libs\...`.
- **Risks:** Windows case-insensitive FS the same as PC-4. The two-stage rename is mandatory.

### PC-6 — LOOT_ITEM_CREATED_SELF / _MULTIPLE race (high-value bug fix)

- **Current:** `Schema.lua:140-159` builds `Schema.crossRegisteredGlobals` from `pairs(rows)` which is order-stable per row-build. **But** `PrettyChat.lua:138-153` `ApplyStrings` iterates `pairs(PrettyChatDefaults)` and inside each category `pairs(catData.strings)`. Both `pairs()` calls have **non-deterministic order** under Lua 5.1 (hash-table iteration depends on key strings' hash). Result: when a global is registered by two categories (today: Loot + Tradeskill), the last category to be visited by `pairs(PrettyChatDefaults)` writes `_G[GLOBALNAME]` — and that loser-takes-all ordering can flip on /reload.
- **Target:** deterministic write order.
- **Design — ordered array of writes:**
  - In `Schema.lua`, after building `rows`, also build a flat **ordered `applyOrder` array** of `{category, globalName}` tuples in `CATEGORY_ORDER` order, with sortedNames within each category (already done at `Schema.lua:124-128` for row construction — extend it).
  - Expose as `Schema.applyOrder` (read-only contract).
  - In `PrettyChat:ApplyStrings`, replace the nested `pairs` loops with `for _, entry in ipairs(ns.Schema.applyOrder) do`.
  - **Cross-registered globals:** because `CATEGORY_ORDER` is `{General, Loot, Currency, Money, Reputation, Experience, Honor, Tradeskill, Misc}`, **Loot is iterated before Tradeskill** — so for the two cross-registered globals, **Tradeskill always wins** at the `_G` write, deterministically. The panel-side cross-registration tooltip already informs users; document the new "Tradeskill wins" invariant in `ARCHITECTURE.md` and `docs/override-pipeline.md`.
  - Preserve registration API: `Schema.crossRegisteredGlobals` stays exactly as today (panel tooltip data); only the write loop moves to ordered iteration.
- **Verification:**
  - Unit-style smoke test: write a tiny lua harness `_dev/test_apply_order.lua` (NOT shipped) that stubs `_G[GLOBALNAME] = ...` writes to a capture table and asserts that `LOOT_ITEM_CREATED_SELF` ends up holding the **Tradeskill** override after `ApplyStrings`. Run via standalone Lua interpreter.
  - In-game: `/pc set Loot.LOOT_ITEM_CREATED_SELF.format "<LOOT VARIANT>"` then `/pc set Tradeskill.LOOT_ITEM_CREATED_SELF.format "<TRADE VARIANT>"` then `/reload`; create a tradeskill item and confirm `<TRADE VARIANT>` shows. Run twice with different `/reload` order to confirm determinism.
- **Risks:** users who happened to be on a `pairs()` order where Loot won will see Tradeskill win after the fix. Document in v1.4.0 release notes: "Cross-registered formats now resolve deterministically — Tradeskill wins for `LOOT_ITEM_CREATED_SELF[_MULTIPLE]`. Edit either category to update."

### PC-7 — Localization scaffold

- **Current:** zero locale infrastructure. UI strings hard-coded in `Config.lua`, `PrettyChat.lua`, and `Defaults.lua` `label` fields.
- **Target:** `Locale.lua` at root, exporting `ns.L` with the metatable-fallback pattern (standard §8.1).
  ```lua
  local addonName, ns = ...
  ns.L = setmetatable({}, { __index = function(_, k) return k end })
  -- enUS values are the keys themselves; non-enUS gates with `if GetLocale() ~= "deDE" then return end` and overrides.
  ```
- **Migration — two waves:**
  - **M4 (scaffold + first wave):** add `Locale.lua` to TOC after `Constants.lua`, before `Defaults.lua`. Extract the most-visible English literals from `PrettyChat.lua` (slash usage strings, `unknown command`, `setting not found`, `cannot open settings during combat`, `[PC]` prefix is unchanged). Wrap each call site `... = "string"` → `... = ns.L["string"]` only on string-literal usages, not on dynamic format-output.
  - **M9 (second wave):** `Defaults.lua` `label` fields and `Config.lua` panel button labels, page titles, tooltips. This is the larger pass; do it last so the schema-driven paths stabilize first.
- **Risks:** keys that contain `%s` placeholders must be passed through `string.format(ns.L["fmt %s"], val)` — the metatable returns the key on miss, so behavior is identical when no translation exists. Verify `RenderSample` and `Test()` paths stay un-localized (they're chat *content*, not chat *chrome*).

### PC-8 — Drop dead AceConfig-3.0

- **Current:** `Libs/AceConfig-3.0/` exists on disk; not referenced by `PrettyChat.toc:12-17`. Confirmed no `LibStub("AceConfig-3.0"...)` callsite.
- **Target:** delete the directory entirely.
- **Migration:** `rm -rf libs/AceConfig-3.0/` (after PC-5 lowercase rename, or `rm -rf Libs/AceConfig-3.0/` before — order is independent).
- **Risks:** none. Update `ARCHITECTURE.md:65-67` to drop the "vendored on disk but not loaded" note.

### PC-9 — SavedVariables migration runner

- **Current:** absent. `PrettyChat.lua:30-31` registers AceDB but no `RunMigrations`. No `schemaVersion` in defaults.
- **Target:** `Database.lua` at root; `PrettyChat:OnInitialize` calls `ns.Database.RunMigrations(self.db)` immediately after `:New`.
- **Design:**
  ```lua
  -- Database.lua
  local addonName, ns = ...
  ns.Database = ns.Database or {}
  function ns.Database.RunMigrations(db)
      local g = db.global
      g.schemaVersion = g.schemaVersion or 1
      -- Reserved for future v2: e.g. when a globalString is renamed by Blizzard,
      -- migrate the user's stored override across to the new key.
      -- if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
  end
  ```
- **Migration:** new file. Add `global = { schemaVersion = 1 }` block to the `defaults` table at `PrettyChat.lua:17-28` (preserves the existing `profile.categories = {}` shape).
- **Risks:** existing users have no `g.schemaVersion`; the `g.schemaVersion = g.schemaVersion or 1` line stamps them at v1 silently. No migration body executes. Safe.

### PC-10 — Compat.lua scaffold

- **Current:** absent. No deprecated-API calls today (verified).
- **Target:** `Compat.lua` at root, loaded **first** in TOC (before `Constants.lua`). Houses `IsRetail` flag plus a forward-looking shim for `C_AddOns.GetAddOnMetadata` (already used at `PrettyChat.lua:7-8` and `Config.lua:13-14` with `or` fallback — move that pattern into `Compat.GetAddOnMetadata`).
- **Design:**
  ```lua
  local addonName, ns = ...
  ns.Compat = ns.Compat or {}
  local Compat = ns.Compat

  Compat.IsRetail  = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  Compat.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

  function Compat.GetAddOnMetadata(name, key)
      if C_AddOns and C_AddOns.GetAddOnMetadata then
          return C_AddOns.GetAddOnMetadata(name, key)
      end
      return GetAddOnMetadata and GetAddOnMetadata(name, key)
  end
  ```
- **Migration:** new file; replace inline `C_AddOns.GetAddOnMetadata or ...` patterns with `ns.Compat.GetAddOnMetadata(addonName, "Version")`.
- **Risks:** none.

### PC-11 — AceConsole slash registration

- **Current:** `PrettyChat.lua:33-34` already uses `self:RegisterChatCommand("pc", ...)` and `self:RegisterChatCommand("prettychat", ...)`. **AceConsole IS in use today.** Re-check the deviation against the raw report:
  - `_raw/prettychat.md` §8 "Slash commands" confirms AceConsole. The deviation in `04_DEVIATIONS.md` (PC-11) labels this as "Hand-rolled `SLASH_*`" — that is **incorrect** as written.
  - **Resolution:** PC-11 is **already conforming**; reframe the milestone as a defensive verify-only pass. Do NOT downgrade to a SLASH_* path. The "cargo-cult removal" item PC-11 in the EXECUTION_PLAN is the audit/cleanup of any leftover mentions in docs.
- **Target:** verify; remove any docs mention of "manual SLASH_PRETTYCHAT registration" if found (none expected).
- **Risks:** none.

### PC-12 — GlobalStrings RAM diet

- **Current:** `PrettyChat.toc:19-28` eagerly loads 10 chunk files (~22,879 entries totaling several hundred KB resident as Lua string-keyed table). Only ~80 entries are actually referenced (the `PrettyChatDefaults` keys, used by `Config.lua:412-422` for the panel "Original Format String" disabled input).
- **Two evaluated options:**
  - **(a) Genuine LoadOnDemand.** Parent TOC drops the 10 chunk lines; `PrettyChat.lua` calls `C_AddOns.LoadAddOn("PrettyChat - GlobalStrings")` on first panel open (`Config.lua:OnShow` of the parent page). The LoD sub-addon `GlobalStrings/GlobalStrings.toc` already exists. Pros: zero data loss; entire dictionary is still searchable via the LoD path. Cons: load-time stutter on first panel open (loading ~24k entries); panel must defer "Original" widget population until after the LoadAddOn returns.
  - **(b) Strip dictionary to ~80 actually-referenced entries.** Generate a single new file `GlobalStrings/GlobalStrings_referenced.lua` containing exactly the keys present in `PrettyChatDefaults`. Replace the 10 eager chunk lines in `PrettyChat.toc` with this one file. Pros: tiny payload, no load-time stutter, no LoadAddOn coupling. Cons: requires a regen step whenever `PrettyChatDefaults` adds a new global; full dictionary is no longer in-memory at runtime (still on disk under `GlobalStrings/` as the unloaded chunk files for reference; the splitter script keeps generating those for future reference).
- **Decision: (b) is the primary plan.** Reasoning: the "Original" panel widget is the only consumer; the user-facing surface is exactly those ~80 strings. Document (a) as a future alternative in `docs/global-strings.md` so future contributors know the LoD route is wired and reachable.
- **Implementation:**
  - Extend `GlobalStrings/split_globalstrings.py` with a `--referenced PATH_TO_DEFAULTS_LUA` flag that emits `GlobalStrings/GlobalStrings_referenced.lua` containing only the keys appearing as `PrettyChatDefaults[*].strings[KEY]`.
  - Re-run the splitter; commit the new `GlobalStrings_referenced.lua` (~80 lines).
  - Edit `PrettyChat.toc:19-28` — remove the 10 chunk lines, add `GlobalStrings\GlobalStrings_referenced.lua`.
  - Keep `GlobalStrings/GlobalStrings.toc` untouched so the LoD sub-addon still ships the full dictionary for any future on-demand consumer.
- **Verification:** count `PrettyChatGlobalStrings` size at runtime; expected `~80`. RAM target: <100 KB at addon load.
- **Risks:** if a future `PrettyChatDefaults` entry is added without rerunning the splitter, the panel "Original" widget will fall back to `_G[GLOBALNAME]` (which is the live, possibly already-overridden value — wrong for the disabled "Original" display). Mitigation: add a luacheckrc-adjacent sanity check or a CLAUDE.md note: "After editing Defaults.lua, run `python3 GlobalStrings/split_globalstrings.py --referenced ../Defaults.lua`". Document explicitly in `docs/global-strings.md`.

### PC-13 — ARCHITECTURE.md "81 strings" drift

- **Current:** `ARCHITECTURE.md:7` says "Eight format-bearing categories with 81 strings total." Should say "81 rows over 79 unique globals" (per the prior review summary).
- **Target:** edit one line.
- **Risks:** none.

### PC-14 — Dead `attachTooltip` HookScript branch

- **Current:** `Config.lua:46-48` contains the `elseif widget.HookScript then ... end` branch. Every call site passes AceGUI widgets, so this branch is dead.
- **Target:** delete the branch (lines 46-48 plus the `elseif`).
- **Risks:** if any future caller passes a plain frame, it will silently no-op. Acceptable; document via a one-line comment: `-- AceGUI-only by contract; plain frames not supported.`

### PC-15 — TODO.md disposition

- **Current:** `TODO.md` at root, untracked (gitignored), 5 lines. Done item is delivered; "Update defaults" is vague; "Add Custom section" is a real backlog item.
- **Target:** move surviving items to `reviews/2026-05-03/` deferred list (or a single GH issue). Delete `TODO.md` from working tree (it's untracked anyway, but actively remove it so no future agent treats it as canon).
- **Triage:**
  - "Add reference to GlobalConstants" — done; drop.
  - "Update defaults" — too vague; drop. Defaults track Blizzard patches on an as-needed basis.
  - "Add Custom section in Settings Panel" — keep; record in `reviews/2026-05-03/05_FINAL_SUMMARY.md` deferred list as a v2 candidate.
- **Risks:** none.

---

## 5. Cross-cutting concerns

### 5.1 SavedVariables migration across the rename (PC-4 + PC-9 interaction)

- **AceDB key is `PrettyChatDB`** — already correct, declared in TOC at `PrettyChat.toc:7`.
- **Empirical Blizzard behavior:** SV file is named after the addon folder, but the in-memory global is keyed off `## SavedVariables`. On first load post-rename:
  - WoW reads `WTF/.../SavedVariables/<oldfolder>.lua` if it exists AND the new addon's TOC `## SavedVariables` matches a global declared in that file. Recent client behavior: yes, this works.
  - WoW writes back to `<newfolder>.lua` on logout.
  - Net effect: data is preserved, with one orphaned `prettychat.lua` file in the user's WTF tree (harmless cruft, mentioned in release notes).
- **Defensive fallback (in `Database.lua`):** if `db.global.schemaVersion` is nil AND `db.profile.categories` is empty AND a one-shot transitional check shows `_G.PrettyChatDB_legacy_check` is unset, no-op (the AceDB hand-off already worked). Otherwise, log a `[PC]` notice via `ns.Print` instructing the user to consult the README "Folder rename" section. **This is informational only — no automated file copy is attempted (Lua addon code cannot read sibling SV files).**
- **Recommended approach:** trust Blizzard's SV-global-key behavior; ship clear release notes; on the *first* update post-rename, surface a one-time `[PC]` chat banner: "Pretty Chat has been renamed from prettychat to PrettyChat. Your settings are preserved. If you installed manually, delete the old prettychat folder."

### 5.2 GlobalString override mechanism unaffected by rename

The override pipeline is `_G[GLOBALNAME] = "..."` writes inside `ApplyStrings`. The names of globals being written are Blizzard's (`LOOT_ITEM_SELF`, `COMBATLOG_XPGAIN_*`, ...) — none of these depend on the addon's folder name. **The post-rename build performs identical writes.** `OnEnable` snapshot capture is also folder-agnostic — it reads `_G[globalName]`, not anything keyed off `addonName`.

### 5.3 TODO.md content disposition (PC-15 expanded)

Triage reproduced for the executor:
- `Done` block: delete (delivered).
- `Backlog: Update defaults` — drop as vague.
- `Backlog: Add Custom section in Settings Panel` — move to `reviews/2026-05-03/05_FINAL_SUMMARY.md` "Deferred to v2" section. Acceptance criteria for that v2 work would be: a 9th category "Custom" allowing user to add `(globalName, format)` pairs at runtime, persisted under `db.profile.categories.Custom.strings`. Out of scope for this remediation.

---

## 6. Out of scope

The following are explicitly **not** to be touched as part of this remediation, even if a subagent notices opportunity:

- **Content of formatter strings.** `Defaults.lua` data values are user-facing aesthetic decisions; do not retune colors, icons, or string layout.
- **Tooltip rebuilding logic** (`Config.lua` `attachTooltip` body beyond PC-14's dead-branch removal). The tooltip plumbing is correct.
- **AceGUI ScrollFrame patch** (`Config.lua:68-166`). Documented as fragile but currently working; treat as load-bearing until an AceGUI bump forces an audit.
- **Private SettingsPanel API auto-expand** (`PrettyChat.lua:61-76`). Defended with `pcall` and one-time warn; leave alone.
- **CHAT_MSG_* event handling.** There is none, by design — keep it that way (see §3.3).
- **Adding a Custom-strings category** (deferred per PC-15 triage).
- **Bumping `## Interface:` line.** Current `120000,120001,120005` stays.
- **Per-character profiles.** AceDB shared-Default-profile (`PrettyChat.lua:31` third arg `true`) is the deliberate choice.

---

## 7. Acceptance criteria (gate for v1.4.0 release)

The remediation is complete when **all** the following are true. The executor verifies each before tagging the release commit.

1. **Folder loads as `PrettyChat/`.** Place a renamed checkout into `Interface/AddOns/PrettyChat/`, launch retail client, confirm addon enables, panel opens, `/pc help` lists every command.
2. **Existing user SavedVariables preserved across rename.** Test path: in a clean WoW install, run pre-rename build, edit several formats, log out. Replace the addon folder with the renamed build. Log in, open `/pc list`, confirm every edited format is present. Confirm `WTF/.../SavedVariables/PrettyChat.lua` now exists with the expected contents.
3. **No chat-frame hooks introduced.** `grep -rEn '(ChatFrame_AddMessageEventFilter|hooksecurefunc.*AddMessage|RegisterEvent.*CHAT_MSG)' *.lua` returns zero hits across the addon source.
4. **Loot filter race fixed (deterministic order).** The `_dev/test_apply_order.lua` smoke harness asserts `LOOT_ITEM_CREATED_SELF` post-`ApplyStrings` holds the Tradeskill override across 100 runs (no flakiness). In-game spot check passes per PC-6 verification.
5. **GlobalStrings RAM <100 KB at load.** `/run print(collectgarbage("count"))` delta between fresh login (no addons) vs. with PrettyChat enabled is <100 KB attributable to PrettyChat (rough Lua-VM accounting; precise < 100 KB is the dictionary-size target).
6. **Lint clean.** `luacheck .` from the addon root returns zero errors and zero warnings (after baseline ignore list applied).
7. **`.pkgmeta` valid.** `bigwigsmods/packager` dry-run (or local equivalent) successfully resolves all externals.
8. **TOC has X-Curse-Project-ID and X-Wago-ID** (filled or commented with TODO until publish).
9. **Documentation in sync.** `README.md` Version History updated; `ARCHITECTURE.md:7` corrected; `CLAUDE.md` cross-registration ordering note added; `docs/global-strings.md` documents the slimmed-dictionary approach and the LoD fallback.
10. **No regression in chat output.** Manual smoke test (Boot / Override / Panel / Slash / Sync / Persistence groups per `docs/smoke-tests.md`) passes end-to-end.

---

**End of Technical Design.** Hand to executing subagent alongside `EXECUTION_PLAN_prettychat.md`.
