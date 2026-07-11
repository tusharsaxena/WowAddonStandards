# Execution Plan — prettychat → PrettyChat (2026-05-03)

**Read first:** `TECHNICAL_DESIGN_prettychat.md` (sibling file). It owns the *why*; this file owns the *do*.

**Source root (current):** `/mnt/d/Profile/Users/Tushar/Documents/GIT/prettychat/`. After M8 the folder becomes `PrettyChat/`. All bash commands below assume working directory `/mnt/d/Profile/Users/Tushar/Documents/GIT/`.

**Each task** is `- [ ]`, lists touched files, then **step 1 (do)**, **step 2 (verify)**, **step 3 (commit)**. Commit messages are explicit.

**Hard constraints (re-stated):**
- Do **not** introduce chat-frame hooks (no `ChatFrame_AddMessageEventFilter`, no `hooksecurefunc(...AddMessage...)`, no `CHAT_MSG_*` registrations, no AddMessage replacement).
- Do **not** bump `## Version:` until M10.
- Each milestone ends with a Checkpoint stop line — pause for review before proceeding.

---

## M1 — Tooling baseline (PC-1, PC-2, PC-3, PC-15)

### M1.1 — Move TODO.md out (PC-15)
- Files: `prettychat/TODO.md`, `prettychat/reviews/2026-05-03/05_FINAL_SUMMARY.md` (new).
- Step 1:
  ```
  mkdir -p prettychat/reviews/2026-05-03
  ```
  Create `prettychat/reviews/2026-05-03/05_FINAL_SUMMARY.md` with a `## Deferred to v2` section containing one bullet: `Add Custom-strings category — let users add (globalName, format) pairs at runtime, persisted under db.profile.categories.Custom.strings.`
  Then delete `prettychat/TODO.md`.
- Step 2: `ls prettychat/TODO.md 2>&1 | grep -q "No such"` returns success; `cat prettychat/reviews/2026-05-03/05_FINAL_SUMMARY.md` shows the deferred entry.
- Step 3: `git add prettychat/reviews/2026-05-03/ && git rm prettychat/TODO.md 2>/dev/null; git commit -m "PC-15: move TODO.md to reviews/2026-05-03 deferred list"` (TODO.md was untracked so the `git rm` may no-op; a plain `rm` is fine).

### M1.2 — Add `.luacheckrc` (PC-2)
- Files: `prettychat/.luacheckrc` (new).
- Step 1: write the file:
  ```lua
  std = "lua51"
  max_line_length = false
  codes = true
  exclude_files = { "libs/", "Libs/", "reviews/", "GlobalStrings/", "_dev/" }
  ignore = { "212/self", "212/event", "631" }
  read_globals = {
      "_G", "LibStub", "CreateFrame", "Settings", "SettingsPanel",
      "C_AddOns", "C_Timer", "InCombatLockdown",
      "DEFAULT_CHAT_FRAME", "GameTooltip",
      "GetAddOnMetadata", "GetLocale",
      "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC",
      "unpack", "select",
  }
  globals = {
      "PrettyChatDB",
      "PrettyChatDefaults",
      "PrettyChatGlobalStrings",
  }
  ```
- Step 2: `cd prettychat && luacheck .` — note any warnings; should be clean or near-clean. (If `luacheck` not installed, skip the run; the file existing is the deliverable.)
- Step 3: `git add prettychat/.luacheckrc && git commit -m "PC-2: add .luacheckrc"`.

### M1.3 — Add `.pkgmeta` (PC-1)
- Files: `prettychat/.pkgmeta` (new).
- Step 1: write the file (uses `package-as: PrettyChat` despite current lowercase folder — release builds produce the PascalCase folder):
  ```yaml
  package-as: PrettyChat

  externals:
    libs/LibStub:
      url: https://repos.curseforge.com/wow/ace3/trunk/LibStub
      tag: latest
    libs/CallbackHandler-1.0:
      url: https://repos.curseforge.com/wow/ace3/trunk/CallbackHandler-1.0
      tag: latest
    libs/AceAddon-3.0:
      url: https://repos.curseforge.com/wow/ace3/trunk/AceAddon-3.0
      tag: latest
    libs/AceDB-3.0:
      url: https://repos.curseforge.com/wow/ace3/trunk/AceDB-3.0
      tag: latest
    libs/AceConsole-3.0:
      url: https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0
      tag: latest
    libs/AceGUI-3.0:
      url: https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0
      tag: latest

  ignore:
    - .luacheckrc
    - .gitattributes
    - .gitignore
    - reviews
    - docs/internal
    - _dev
    - "*.bak"
    - TODO.md
  ```
- Step 2: `cat prettychat/.pkgmeta | head -5` shows `package-as: PrettyChat`.
- Step 3: `git add prettychat/.pkgmeta && git commit -m "PC-1: add .pkgmeta with Ace3 externals"`.

### M1.4 — TOC X-IDs (PC-3)
- Files: `prettychat/PrettyChat.toc`.
- Step 1: after the `## X-License: MIT` line, append:
  ```
  ## X-Curse-Project-ID:
  ## X-Wago-ID:
  ```
  (Empty values; user fills in at publish time. The standard requires the lines exist; values become mandatory at publish.)
- Step 2: `grep -E '^## X-(Curse|Wago)' prettychat/PrettyChat.toc | wc -l` returns `2`.
- Step 3: `git add prettychat/PrettyChat.toc && git commit -m "PC-3: add X-Curse-Project-ID and X-Wago-ID TOC stubs"`.

**Checkpoint M1.** Stop. Confirm tooling commits look right before moving on.

---

## M2 — Quick polish (PC-13, PC-14, PC-11 verify)

### M2.1 — ARCHITECTURE.md drift fix (PC-13)
- Files: `prettychat/ARCHITECTURE.md`.
- Step 1: in `prettychat/ARCHITECTURE.md` line 7, replace `Eight format-bearing categories with 81 strings total` with `Eight format-bearing categories — 81 schema rows over 79 unique globals (LOOT_ITEM_CREATED_SELF and LOOT_ITEM_CREATED_SELF_MULTIPLE are cross-registered under both Loot and Tradeskill)`.
- Step 2: `grep -n "81 rows over 79" prettychat/ARCHITECTURE.md` returns the new line.
- Step 3: `git add prettychat/ARCHITECTURE.md && git commit -m "PC-13: clarify 81-rows-vs-79-globals in ARCHITECTURE.md"`.

### M2.2 — Delete dead HookScript branch (PC-14)
- Files: `prettychat/Config.lua`.
- Step 1: in `prettychat/Config.lua` lines 43-49 — replace the `if widget.SetCallback then ... elseif widget.HookScript then ... end` block with:
  ```lua
      -- AceGUI-only by contract. attachTooltip is never called with plain frames today.
      if widget.SetCallback then
          widget:SetCallback("OnEnter", show)
          widget:SetCallback("OnLeave", hide)
      end
  ```
- Step 2: `grep -n "HookScript" prettychat/Config.lua` returns zero hits.
- Step 3: `git add prettychat/Config.lua && git commit -m "PC-14: remove dead HookScript branch in attachTooltip"`.

### M2.3 — PC-11 verify-only pass
- Files: none changed expected.
- Step 1: `grep -rEn 'SLASH_PRETTYCHAT|SLASH_PC[0-9]|SlashCmdList' prettychat/*.lua prettychat/docs/*.md` — confirm zero hits. (PC-11 was a misclassification; AceConsole is already in use at `PrettyChat.lua:33-34`. No code change.)
- Step 2: same grep — visual confirm.
- Step 3: no commit (no changes). If any doc mentions hand-rolled SLASH, edit it out and commit `docs: drop stale SLASH_* mention (PC-11)`.

**Checkpoint M2.** Stop.

---

## M3 — Loot filter race fix (PC-6)

### M3.1 — Build `Schema.applyOrder`
- Files: `prettychat/Schema.lua`.
- Step 1: after the `crossRegisteredGlobals` block (`Schema.lua:144-158`), add a new ordered-array build:
  ```lua
  -- Deterministic write order for ApplyStrings. Iterating pairs(PrettyChatDefaults)
  -- in PrettyChat:ApplyStrings was non-deterministic, which let cross-registered
  -- globals (LOOT_ITEM_CREATED_SELF[_MULTIPLE]) flip categories on /reload.
  -- This array preserves CATEGORY_ORDER, so for cross-registered globals the
  -- LATER category in CATEGORY_ORDER wins — today that means Tradeskill wins
  -- over Loot for the two shared keys.
  Schema.applyOrder = {}
  for _, category in ipairs(CATEGORY_ORDER) do
      local catData = PrettyChatDefaults[category]
      if catData and catData.strings then
          local sortedNames = {}
          for globalName in pairs(catData.strings) do
              sortedNames[#sortedNames + 1] = globalName
          end
          table.sort(sortedNames)
          for _, globalName in ipairs(sortedNames) do
              Schema.applyOrder[#Schema.applyOrder + 1] = { category = category, globalName = globalName }
          end
      end
  end
  ```
- Step 2: in a Lua REPL or stub, confirm `Schema.applyOrder` has 81 entries and `LOOT_ITEM_CREATED_SELF` appears under `Loot` BEFORE under `Tradeskill`. (Skip if no Lua available; visual review of the sort order suffices.)
- Step 3: hold for M3.2 commit.

### M3.2 — Switch ApplyStrings to ordered iteration
- Files: `prettychat/PrettyChat.lua`.
- Step 1: replace `PrettyChat.lua:138-153` with:
  ```lua
  function PrettyChat:ApplyStrings()
      -- The addon-wide toggle wins: when off, every Blizzard original is
      -- restored regardless of per-category / per-string state.
      local addonEnabled = self:IsAddonEnabled()
      for _, entry in ipairs(ns.Schema.applyOrder) do
          local category, globalName = entry.category, entry.globalName
          if addonEnabled
             and self:IsCategoryEnabled(category)
             and self:IsStringEnabled(category, globalName) then
              _G[globalName] = self:GetStringValue(category, globalName)
          elseif self.originalStrings and self.originalStrings[globalName] then
              _G[globalName] = self.originalStrings[globalName]
          end
      end
  end
  ```
- Step 2:
  - In-game smoke: `/pc set Loot.LOOT_ITEM_CREATED_SELF.format "LOOT-WINS"` then `/pc set Tradeskill.LOOT_ITEM_CREATED_SELF.format "TRADE-WINS"` then `/reload`. Run `/run print(_G.LOOT_ITEM_CREATED_SELF)` — must print `TRADE-WINS`. Run `/reload` again twice; same result. Determinism verified.
  - Source check: `grep -n 'pairs(PrettyChatDefaults)' prettychat/PrettyChat.lua` returns ZERO hits.
- Step 3: `git add prettychat/PrettyChat.lua prettychat/Schema.lua && git commit -m "PC-6: deterministic ApplyStrings order via Schema.applyOrder; Tradeskill wins cross-registered globals"`.

### M3.3 — Document the new invariant
- Files: `prettychat/ARCHITECTURE.md`, `prettychat/docs/override-pipeline.md`, `prettychat/CLAUDE.md`.
- Step 1: append to ARCHITECTURE.md `## Invariants worth not breaking` a bullet: `**Deterministic ApplyStrings order.** Iterates ns.Schema.applyOrder (CATEGORY_ORDER × sorted-name); for cross-registered globals, the later category wins (today: Tradeskill > Loot).` Mirror the same line into CLAUDE.md "Hard rules" and into docs/override-pipeline.md.
- Step 2: `grep -l "Tradeskill > Loot" prettychat/ARCHITECTURE.md prettychat/CLAUDE.md prettychat/docs/override-pipeline.md` lists all three files.
- Step 3: `git add prettychat/ARCHITECTURE.md prettychat/CLAUDE.md prettychat/docs/override-pipeline.md && git commit -m "PC-6: document deterministic apply order across ARCHITECTURE / CLAUDE / docs"`.

**Checkpoint M3.** Stop. Smoke-test in-game before continuing.

---

## M4 — Compat + Locale scaffolds + SV migration runner (PC-9, PC-10, PC-7 wave 1)

### M4.1 — Compat.lua scaffold (PC-10)
- Files: `prettychat/Compat.lua` (new), `prettychat/PrettyChat.toc`, `prettychat/PrettyChat.lua`, `prettychat/Config.lua`.
- Step 1: create `prettychat/Compat.lua`:
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
  Insert into `PrettyChat.toc` between the `Libs\AceGUI-3.0\AceGUI-3.0.xml` line and the GlobalStrings block: `Compat.lua` (so it loads before Constants/Defaults/PrettyChat).
  In `PrettyChat.lua:7-8` and `Config.lua:13-14`, replace the inline `(C_AddOns and C_AddOns.GetAddOnMetadata and ...) or ...` patterns with `ns.Compat.GetAddOnMetadata(addonName, "Version")` / `ns.Compat.GetAddOnMetadata(addonName, "Notes")`.
- Step 2: launch the addon, `/pc help` shows `v1.3.0 — slash commands ...` (version still resolves via Compat).
- Step 3: `git add prettychat/Compat.lua prettychat/PrettyChat.toc prettychat/PrettyChat.lua prettychat/Config.lua && git commit -m "PC-10: add Compat.lua and route GetAddOnMetadata calls through it"`.

### M4.2 — Database.lua + schemaVersion (PC-9)
- Files: `prettychat/Database.lua` (new), `prettychat/PrettyChat.toc`, `prettychat/PrettyChat.lua`.
- Step 1: create `prettychat/Database.lua`:
  ```lua
  local addonName, ns = ...
  ns.Database = ns.Database or {}

  -- Migration runner. Stamped at v1 for fresh installs; future schema changes
  -- (e.g. Blizzard renaming a GlobalString and us migrating the user's saved
  -- override across to the new key) increment schemaVersion and add an
  -- if g.schemaVersion < N then ... end branch.
  function ns.Database.RunMigrations(db)
      local g = db.global
      g.schemaVersion = g.schemaVersion or 1
      -- if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
  end
  ```
  Insert into TOC after `Compat.lua`, before `Constants.lua`: `Database.lua`.
  In `PrettyChat.lua:17-28`, extend `defaults`:
  ```lua
  local defaults = {
      profile = { categories = {} },
      global  = { schemaVersion = 1 },
  }
  ```
  In `PrettyChat:OnInitialize`, after `:New`, add `ns.Database.RunMigrations(self.db)`.
- Step 2: log in, `/run print(PrettyChatDB.global.schemaVersion)` prints `1`.
- Step 3: `git add prettychat/Database.lua prettychat/PrettyChat.toc prettychat/PrettyChat.lua && git commit -m "PC-9: add Database.lua migration runner and schemaVersion in defaults"`.

### M4.3 — Locale.lua scaffold + first wave (PC-7)
- Files: `prettychat/Locale.lua` (new), `prettychat/PrettyChat.toc`, `prettychat/PrettyChat.lua`.
- Step 1: create `prettychat/Locale.lua`:
  ```lua
  local addonName, ns = ...
  ns.L = setmetatable({}, { __index = function(_, k) return k end })
  local L = ns.L

  -- enUS canonical; values equal keys so missing-key fallback is identity.
  L["cannot open settings during combat — Blizzard's category-switch is protected"]
      = "cannot open settings during combat — Blizzard's category-switch is protected"
  L["could not open settings panel — category not registered"]
      = "could not open settings panel — category not registered"
  L["(could not auto-expand the Pretty Chat sub-tree — click the parent row to expand)"]
      = "(could not auto-expand the Pretty Chat sub-tree — click the parent row to expand)"
  L["schema not ready yet"]                 = "schema not ready yet"
  L["unknown command '%s'"]                 = "unknown command '%s'"
  L["unknown category '%s'. Valid: %s"]     = "unknown category '%s'. Valid: %s"
  L["setting not found: '%s'"]              = "setting not found: '%s'"
  L["all settings reset to defaults"]       = "all settings reset to defaults"
  ```
  Insert into TOC immediately after `Compat.lua`, before `Database.lua`: `Locale.lua`.
  In `PrettyChat.lua`, replace each English literal at the matching call site with `ns.L["..."]` or `(ns.L["unknown command '%s'"]):format(name)`. Touch sites: `:85`, `:92`, `:97`, `:354`, `:475`, `:521`, `:528`, `:537`, `:612`. Do NOT change `[PC]` prefix or `Test()` body — those are chat content, not chrome.
- Step 2: `/pc unknownverb` prints `unknown command 'unknownverb'` (still English; metatable identity).
- Step 3: `git add prettychat/Locale.lua prettychat/PrettyChat.toc prettychat/PrettyChat.lua && git commit -m "PC-7: add Locale.lua scaffold and wave-1 string extraction"`.

**Checkpoint M4.** Stop.

---

## M5 — Slash to AceConsole (PC-11)

PC-11 was misclassified — AceConsole is already in use (`PrettyChat.lua:33-34`). This milestone is verify-only.

### M5.1 — Verify
- Files: none.
- Step 1: `grep -n 'RegisterChatCommand\|SLASH_' prettychat/PrettyChat.lua` — confirm only `:RegisterChatCommand` lines, no `SLASH_*` constants.
- Step 2: in-game `/pc help` and `/prettychat help` both work.
- Step 3: no commit. If any cargo-cult mention exists in docs, edit and `git commit -m "docs: drop stale SLASH_* mention (PC-11 verify pass)"`.

**Checkpoint M5.** Stop.

---

## M6 — Lib cleanup (PC-8 + PC-5)

### M6.1 — Drop dead AceConfig-3.0 (PC-8)
- Files: `prettychat/Libs/AceConfig-3.0/` (delete).
- Step 1: `rm -rf prettychat/Libs/AceConfig-3.0/`.
- Step 2: `grep -rn 'AceConfig' prettychat/*.lua prettychat/PrettyChat.toc` returns zero hits in source/TOC. (Hits in `ARCHITECTURE.md:65-67` will be cleaned in step 3.)
- Step 3: edit `prettychat/ARCHITECTURE.md:65-67` to drop the "vendored on disk but not loaded" paragraph; `git add -A prettychat/Libs prettychat/ARCHITECTURE.md && git commit -m "PC-8: remove vendored-unused AceConfig-3.0"`.

### M6.2 — Rename `Libs/` → `libs/` (PC-5, case-insensitive hazard)
- Files: `prettychat/Libs/` (rename), `prettychat/PrettyChat.toc` (path edits), `prettychat/.luacheckrc` (drop `Libs/` from exclude list), `prettychat/.pkgmeta` (already says `libs/`).
- Step 1: two-stage rename:
  ```
  cd prettychat
  mv Libs _libs_temp_
  mv _libs_temp_ libs
  cd ..
  ```
  Edit `prettychat/PrettyChat.toc:12-17` — change every `Libs\` to `libs\`.
  Edit `prettychat/.luacheckrc` — change `exclude_files = { "libs/", "Libs/", ... }` to `exclude_files = { "libs/", ... }`.
- Step 2:
  - `ls prettychat/libs/` lists Ace3 dirs; `ls prettychat/Libs/ 2>&1` errors.
  - `git status` shows the case rename as `renamed: Libs/... -> libs/...`.
  - In-game: `/reload`; `/pc help` works (libs still load).
- Step 3: `git add -A prettychat && git commit -m "PC-5: rename Libs/ to libs/ via two-stage case-flip"`.

**Checkpoint M6.** Stop.

---

## M7 — GlobalStrings RAM diet (PC-12)

### M7.1 — Extend splitter to emit referenced-only file
- Files: `prettychat/GlobalStrings/split_globalstrings.py`.
- Step 1: read the existing splitter; add a CLI flag `--referenced PATH_TO_DEFAULTS_LUA` that:
  - Parses keys appearing as `KEYNAME = {` inside any `strings = { ... }` block of the supplied Defaults.lua file (regex `\s*([A-Z][A-Z0-9_]+)\s*=\s*\{`).
  - Emits `GlobalStrings/GlobalStrings_referenced.lua` containing only those `PrettyChatGlobalStrings["KEY"] = "value"` lines, drawn from the master `GlobalStrings/GlobalStrings.lua` source dump.
- Step 2: `python3 prettychat/GlobalStrings/split_globalstrings.py --referenced prettychat/Defaults.lua`. Inspect `prettychat/GlobalStrings/GlobalStrings_referenced.lua` — should be ~80 lines, one assignment per `PrettyChatDefaults[*].strings[KEY]`.
- Step 3: `git add prettychat/GlobalStrings/split_globalstrings.py prettychat/GlobalStrings/GlobalStrings_referenced.lua && git commit -m "PC-12: splitter --referenced flag emits ~80-entry slim dictionary"`.

### M7.2 — Switch parent TOC to slim dictionary
- Files: `prettychat/PrettyChat.toc`.
- Step 1: in `PrettyChat.toc:19-28`, replace the 10 `GlobalStrings\GlobalStrings_001..010.lua` lines with a single line `GlobalStrings\GlobalStrings_referenced.lua`.
- Step 2:
  - In-game `/reload`.
  - `/run print(0); local n=0; for _ in pairs(PrettyChatGlobalStrings) do n=n+1 end; print(n)` — should print ~80.
  - Open settings panel; "Original Format String" disabled inputs render correctly per category.
  - `/run print(collectgarbage("count"))` taken before/after toggling addon — delta target <100 KB.
- Step 3: `git add prettychat/PrettyChat.toc && git commit -m "PC-12: parent TOC loads only the slim referenced-globals dictionary"`.

### M7.3 — Document the slim-dictionary contract
- Files: `prettychat/docs/global-strings.md`, `prettychat/CLAUDE.md`.
- Step 1: in `docs/global-strings.md` add a top section: "**Active dictionary is the slim referenced-globals file** (`GlobalStrings_referenced.lua`, ~80 entries). The full chunked dictionary (`GlobalStrings_001..010.lua`) is still on disk and is loaded only by the LoadOnDemand sub-addon `PrettyChat - GlobalStrings` for any future on-demand consumer (currently none). When `Defaults.lua` adds a new global, **regenerate** the slim file: `python3 GlobalStrings/split_globalstrings.py --referenced ../Defaults.lua`." Mirror the regen instruction in `CLAUDE.md` "Working environment".
- Step 2: visual review.
- Step 3: `git add prettychat/docs/global-strings.md prettychat/CLAUDE.md && git commit -m "PC-12: document slim dictionary regen step and LoD fallback"`.

**Checkpoint M7.** Stop.

---

## M8 — Folder rename `prettychat` → `PrettyChat` (PC-4)

This is the highest-risk milestone. **Verify SV preservation on a real WoW install before merging.**

### M8.1 — WTF SavedVariables sanity test (pre-rename probe)
- Files: none modified.
- Step 1: in your WoW client, ensure prettychat is currently running. Edit one format (e.g. `/pc set Loot.LOOT_ITEM_SELF.format "PRE-RENAME-TEST"`). Log out fully. Inspect `WTF/Account/<acct>/SavedVariables/prettychat.lua`. Confirm it contains `PrettyChatDB = { ["profile"] = { ["categories"] = { ["Loot"] = { ["strings"] = { ["LOOT_ITEM_SELF"] = "PRE-RENAME-TEST" } } } } }` or similar shape. Note: the file is named for the *folder* (lowercase), the global is `PrettyChatDB`.
- Step 2: read-only sanity check; no commit.
- Step 3: copy `prettychat.lua` to `prettychat.lua.backup` outside the WTF tree as a safety net.

### M8.2 — Two-stage folder rename
- Files: directory rename only.
- Step 1:
  ```
  cd /mnt/d/Profile/Users/Tushar/Documents/GIT
  mv prettychat _pc_temp_
  mv _pc_temp_ PrettyChat
  ```
- Step 2:
  - `ls PrettyChat/PrettyChat.toc` succeeds; `ls prettychat 2>&1 | grep -q "No such"` succeeds.
  - `cd PrettyChat && git status` shows files as `renamed:` (git tracks case via the intermediate name).
- Step 3: hold for M8.4 commit.

### M8.3 — One-time release banner in OnEnable
- Files: `PrettyChat/PrettyChat.lua`, `PrettyChat/Database.lua`.
- Step 1: in `Database.RunMigrations`, after the schemaVersion stamp, add:
  ```lua
  -- One-time post-rename notice. Set the flag inside global so it persists.
  if not g.renameNoticeShown then
      g.renameNoticeShown = true
      ns._showRenameNotice = true
  end
  ```
  In `PrettyChat:OnEnable` (after `ApplyStrings`, before `RegisterPanels`), add:
  ```lua
  if ns._showRenameNotice then
      ns._showRenameNotice = nil
      ns.Print(ns.L["Pretty Chat folder renamed prettychat → PrettyChat. Settings preserved. If you installed manually, delete the old prettychat folder."])
  end
  ```
  Add the corresponding key to `Locale.lua`.
- Step 2: in a fresh test SV, log in once, see the banner; log in again, no banner.
- Step 3: hold for M8.4 commit.

### M8.4 — Test SV preservation post-rename + commit
- Files: rename + banner code.
- Step 1: drop `PrettyChat/` into `Interface/AddOns/`, log in to a character that had pre-rename settings. Run `/pc list Loot` — confirm `LOOT_ITEM_SELF` shows `"PRE-RENAME-TEST"`. Log out, inspect `WTF/.../SavedVariables/`. Expect `PrettyChat.lua` to now exist with the same data; `prettychat.lua` orphaned (delete manually per release notes).
- Step 2: if data is **lost**, abort: revert via `git mv` back to `prettychat`, escalate. (See TECHNICAL_DESIGN_prettychat.md §4 PC-4 "If the empirical test shows orphaning" for the dual-TOC fallback plan.)
- Step 3: `cd /mnt/d/Profile/Users/Tushar/Documents/GIT && git add -A && git commit -m "PC-4: rename folder prettychat → PrettyChat and add one-time post-rename notice"`.

### M8.5 — Release notes draft for README "Version History"
- Files: `PrettyChat/README.md`.
- Step 1: prepend to the Version History table a row:
  | 1.4.0 | 2026-05-05 | Folder renamed `prettychat` → `PrettyChat` (matches addon Title casing). **Settings are preserved automatically** — Blizzard reads SavedVariables off the addon's declared `PrettyChatDB` key, so your customizations carry over. If you installed manually, delete the old `prettychat` folder from `Interface/AddOns/` after updating. Cross-registered loot/tradeskill formats now resolve deterministically (Tradeskill wins for `LOOT_ITEM_CREATED_SELF[_MULTIPLE]`). RAM footprint reduced by dropping the eagerly-loaded 22,879-entry GlobalStrings dictionary (the LoadOnDemand sub-addon still ships the full reference). |
- Step 2: visual review.
- Step 3: hold for M10 (version bump) — no separate commit.

**Checkpoint M8.** Stop. **Do not proceed to M9 until live SV-preservation has been verified on your account.**

---

## M9 — Locale wave 2 (PC-7 follow-up)

### M9.1 — Extract Defaults.lua label fields
- Files: `PrettyChat/Locale.lua`, `PrettyChat/Config.lua`.
- Step 1: every distinct `label = "..."` value in `Defaults.lua` (e.g. `"Battle Pet Loot"`, `"Currency Refund"`, ...) — add to `Locale.lua` as `L["<value>"] = "<value>"`. **Do NOT modify `Defaults.lua` itself** (its labels are data; wrap them at *display* time). In `Config.lua` wherever a row's `label` is rendered into a widget, route it through `ns.L[label]`. The metatable returns the key on miss, so behavior is identical for the canonical English path.
- Step 2: panel renders identically to before. Spot-check a deDE client (if available): all labels still English, but the path is now translation-ready.
- Step 3: `git add PrettyChat/Locale.lua PrettyChat/Config.lua && git commit -m "PC-7 wave 2: route Defaults.lua label rendering through ns.L"`.

### M9.2 — Extract panel page titles + button text
- Files: `PrettyChat/Locale.lua`, `PrettyChat/Config.lua`.
- Step 1: the parent page `PARENT_TITLE = "Ka0s Pretty Chat"` (`Config.lua:11`) — leave as-is (addon name is not localized). Page section headings in `Config.lua` (search for `:SetText(` and string literals on AceGUI labels) — extract through `ns.L[...]`.
- Step 2: panel visual unchanged.
- Step 3: `git add PrettyChat/Locale.lua PrettyChat/Config.lua && git commit -m "PC-7 wave 2: route Config.lua section headings through ns.L"`.

**Checkpoint M9.** Stop.

---

## M10 — Release prep

### M10.1 — Version bump to 1.4.0
- Files: `PrettyChat/PrettyChat.toc`, `PrettyChat/README.md` (badge), `PrettyChat/CLAUDE.md`, any code constant if present.
- Step 1: change `## Version: 1.3.0` → `## Version: 1.4.0` in `PrettyChat.toc`. Update README badge URL if version-pinned. Confirm no other version constants. (Per `wow-addon:version-bump` skill template.)
- Step 2: `grep -rn '1\.3\.0\|1\.4\.0' PrettyChat/PrettyChat.toc PrettyChat/README.md PrettyChat/CLAUDE.md` — only `1.4.0` remains.
- Step 3: hold for M10.4 single-commit release.

### M10.2 — Sync README / CLAUDE / ARCHITECTURE
- Files: README, CLAUDE, ARCHITECTURE in `PrettyChat/`.
- Step 1: run the `wow-addon:sync-docs` skill (or do equivalent manual sweep): verify count claims (81 rows / 79 globals), slash table (no SLASH_*), library list drops AceConfig, mention `Compat.lua` / `Database.lua` / `Locale.lua` in CLAUDE.md key-files table and ARCHITECTURE.md module map.
- Step 2: `grep -n 'AceConfig' PrettyChat/ARCHITECTURE.md PrettyChat/CLAUDE.md` returns zero hits.
- Step 3: hold.

### M10.3 — Smoke test in 12.0.5 client
- Files: none.
- Step 1: full smoke per `docs/smoke-tests.md` Boot / Override / Panel / Slash / Sync / Persistence groups. Plus the M3.2 deterministic-order check, the M7.2 RAM check, the M8.4 SV preservation check.
- Step 2: every group passes.
- Step 3: hold.

### M10.4 — Final release commit
- Files: any trailing edits.
- Step 1: `git add -A PrettyChat`.
- Step 2: `git status` clean.
- Step 3: `git commit -m "PrettyChat 1.4.0 — full standards remediation (PC-1..PC-15)"`.

**Checkpoint M10.** Stop. Tag `git tag v1.4.0` only on user instruction.

---

## Release notes paragraph (canonical text for README "Version History")

> **1.4.0 (2026-05-05).** Standards-compliance pass. Folder renamed `prettychat` → `PrettyChat`; settings carry over automatically because Blizzard reads SavedVariables off the addon's declared `PrettyChatDB` key. Manual installers should delete the old `prettychat` folder. Cross-registered loot/tradeskill formats (`LOOT_ITEM_CREATED_SELF` / `_MULTIPLE`) now resolve deterministically — Tradeskill wins; previously the winner could flip on `/reload`. RAM footprint reduced: parent TOC loads a slim ~80-entry GlobalStrings dictionary instead of the full 22,879-entry dump (the full dictionary still ships as the `PrettyChat - GlobalStrings` LoadOnDemand sub-addon). Added `.pkgmeta`, `.luacheckrc`, `Compat.lua`, `Database.lua` migration runner, `Locale.lua` scaffold. Removed dead `AceConfig-3.0` vendor and the dead `attachTooltip` HookScript branch. No user-visible chat-output changes.

---

**End of Execution Plan.** 41 tasks across 10 milestones.
