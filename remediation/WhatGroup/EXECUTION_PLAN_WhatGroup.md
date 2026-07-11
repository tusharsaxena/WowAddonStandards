# EXECUTION_PLAN — WhatGroup

Companion to `TECHNICAL_DESIGN_WhatGroup.md`. Bite-sized checkboxed tasks. Executing agent has no other context — every task lists files, step 1 (code), step 2 (verify), step 3 (commit).

**Working directory:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/`

**Hard constraints (read CLAUDE.md):**
- Do NOT bump version. Do NOT auto-commit unless instructed. Do NOT push.
- Each commit step below is the suggested message; the user runs `/wow-addon:commit` to authorize.

---

## M1 — Tooling baseline (WG-1, WG-2, WG-3, WG-11)

### Task M1.1 — Create `.pkgmeta`

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/.pkgmeta` (new).
- [ ] **Step 1 — code:** Write `.pkgmeta` with `package-as: WhatGroup`, externals for LibStub, CallbackHandler-1.0, AceAddon-3.0, AceEvent-3.0, AceConsole-3.0, AceDB-3.0, AceGUI-3.0 (all `https://repos.curseforge.com/wow/ace3/trunk/<libname>` `tag: latest`), `ignore:` for `.luacheckrc`, `reviews`, `docs/internal`, `_dev`, `*.bak`.
- [ ] **Step 2 — verify:** `cat .pkgmeta` shows the file. (Packager runs are out of scope; we trust the YAML.)
- [ ] **Step 3 — commit:** `chore(WhatGroup): add .pkgmeta with Ace3 externals`.

### Task M1.2 — Create `.luacheckrc`

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/.luacheckrc` (new).
- [ ] **Step 1 — code:** `std = "lua51"`, `max_line_length = false`, `codes = true`, `exclude_files = { "libs/", "reviews/", "_dev/" }`, `ignore = { "212/self", "212/event" }`. `read_globals` enumerated in TECHNICAL_DESIGN §WG-2. `globals = { "WhatGroupDB", "WhatGroup", "WhatGroupFrame", "WhatGroupParentPanel", "WhatGroupGeneralPanel" }`.
- [ ] **Step 2 — verify:** `luacheck .` (if luacheck installed). Address blocking warnings; suppress noise via `-- luacheck: ignore <code>` with one-line justification.
- [ ] **Step 3 — commit:** `chore(WhatGroup): add .luacheckrc`.

### Task M1.3 — TOC: add X-IDs, drop DefaultState

- [ ] **Files:** `WhatGroup.toc`.
- [ ] **Step 1 — code:**
  - After `## X-License: MIT` add `## X-Curse-Project-ID: 1489907` (matches README badge `curseforge/v/1489907`).
  - Add `## X-Wago-ID: TBD-WAGO-ID` (placeholder; user fills if known).
  - Delete the line `## DefaultState: enabled` (`WhatGroup.toc:8`).
- [ ] **Step 2 — verify:** in-game `/reload` — addon still loads; `Get C_AddOns.GetAddOnMetadata("WhatGroup", "X-Curse-Project-ID")` returns `1489907`.
- [ ] **Step 3 — commit:** `chore(WhatGroup): add X-Curse/X-Wago IDs, drop cargo-cult DefaultState`.

**Checkpoint stop:** confirm M1 is green before M2.

---

## M2 — Compat + Locale + Debug scaffolds (WG-5, WG-6, WG-7)

### Task M2.1 — Create `Compat.lua` shell

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/Compat.lua` (new), `WhatGroup.toc` (add line).
- [ ] **Step 1 — code:** in `Compat.lua`:
  ```lua
  -- Compat.lua — deprecated-API shims and per-flavor flags.
  local _, NS = ...
  WhatGroup = WhatGroup or {}
  WhatGroup.Compat = WhatGroup.Compat or {}
  local Compat = WhatGroup.Compat

  Compat.IsRetail  = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  Compat.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

  -- (Body intentionally minimal: WhatGroup currently uses no deprecated APIs
  -- through this module. Future shims live here.)
  ```
  In `WhatGroup.toc` insert `Compat.lua` immediately after `WhatGroup.lua`.
- [ ] **Step 2 — verify:** `/reload`; `/dump WhatGroup.Compat.IsRetail` → `true`.
- [ ] **Step 3 — commit:** `feat(WhatGroup): add Compat.lua shell per Ka0s standard §11`.

### Task M2.2 — Create `Locale.lua` shell

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/Locale.lua` (new), `WhatGroup.toc`.
- [ ] **Step 1 — code:** in `Locale.lua`:
  ```lua
  -- Locale.lua — metatable-fallback locale per Ka0s standard §8.1.
  -- enUS-only today; future contributors may add deDE.lua, frFR.lua, ...
  -- gated with `if GetLocale() ~= "<locale>" then return end`.
  local _, NS = ...
  WhatGroup = WhatGroup or {}
  WhatGroup.L = setmetatable({}, { __index = function(_, k) return k end })
  local L = WhatGroup.L

  -- Stub keys to prove the seam. Schema labels/tooltips are not migrated
  -- in this milestone; substitute L["..."] for hardcoded English at leisure.
  L["Defaults"] = "Defaults"
  L["Test"] = "Test"
  L["Reset every WhatGroup setting to its default? The active profile is the only one affected."] =
      "Reset every WhatGroup setting to its default? The active profile is the only one affected."
  L["all settings reset to defaults"] = "all settings reset to defaults"
  L["Cannot register settings panel during combat."] = "Cannot register settings panel during combat."
  ```
  In `WhatGroup.toc` insert `Locale.lua` after `Compat.lua`.
- [ ] **Step 2 — verify:** `/reload`; `/dump WhatGroup.L["Defaults"]` → `"Defaults"`; `/dump WhatGroup.L["NotAKey"]` → `"NotAKey"` (metatable fallback proves the seam).
- [ ] **Step 3 — commit:** `feat(WhatGroup): add Locale.lua shell per Ka0s standard §8.1`.

### Task M2.3 — Document persistent debug toggle (WG-7)

- [ ] **Files:** `ARCHITECTURE.md`.
- [ ] **Step 1 — code:** append a paragraph under "Known Limitations" (or create the section): "Debug toggle is persistent via `db.profile.debug` (schema row in `WhatGroup_Settings_Schema.lua`). Standard §12 wording prefers `db.global.debug`; for a single-account-shared-profile addon (`AceDB:New(..., true)`), profile and global are functionally identical. No migration is required." Reference: `WhatGroup.lua:239` seeds `WhatGroup.debug` from db on init.
- [ ] **Step 2 — verify:** `/wg debug` on, `/reload`, `/wg list | grep debug` shows `debug = true`. Toggle off and reload; confirms persistence.
- [ ] **Step 3 — commit:** `docs(WhatGroup): clarify persistent debug-toggle storage in ARCHITECTURE.md`.

**Checkpoint stop:** confirm M2 is green before M3.

---

## M3 — Slash to AceConsole (WG-8)

### Task M3.1 — Verify already-compliant; close WG-8

- [ ] **Files:** none (audit only). Reference `WhatGroup.lua:23-25` (mixin includes `AceConsole-3.0`) and `WhatGroup.lua:241-242` (`self:RegisterChatCommand("wg", "OnSlash")`, `self:RegisterChatCommand("whatgroup", "OnSlash")`).
- [ ] **Step 1 — verify (no code change):** `grep -n "SLASH_" /mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/*.lua` returns no addon-author registration. Per TECHNICAL_DESIGN §WG-8: WhatGroup already uses `AceConsole:RegisterChatCommand`. WG-8 closes as misclassification.
- [ ] **Step 2 — verify:** `/wg help` works in-game; both `/wg` and `/whatgroup` route to OnSlash.
- [ ] **Step 3 — commit (docs only):** add a one-line note in `ARCHITECTURE.md` "Slash Commands" section: "Registered via AceConsole-3.0 `RegisterChatCommand` (`WhatGroup.lua:241-242`)." → `docs(WhatGroup): note AceConsole registration in ARCHITECTURE.md`.

**Checkpoint stop:** confirm M3 is green before M4.

---

## M4 — Doc/comment polish (WG-9, WG-10)

### Task M4.1 — Document `appID`-as-`searchResultID` parity (WG-9)

- [ ] **Files:** `WhatGroup.lua` (around `:581-588`); `ARCHITECTURE.md`.
- [ ] **Step 1 — code:** Expand the comment block at `WhatGroup.lua:581-587` to read:
  ```lua
  -- BLIZZARD-PARITY INVARIANT (F-004): for the player's own application,
  -- C_LFGList treats appID and searchResultID as equivalent integers.
  -- We pass appID where searchResultID is documented, and the backing
  -- query (C_LFGList.GetSearchResultInfo) returns the joined group's
  -- info correctly. If Blizzard ever decouples the two ID spaces, this
  -- breaks silently — mapID-driven teleport and fresh-vs-queued capture
  -- choice both stop working. See ARCHITECTURE.md "Known Limitations".
  ```
  Append to `ARCHITECTURE.md` "Known Limitations" → bullet: "`appID` is reused as `searchResultID` (`WhatGroup.lua:588`). Works on retail today; documented as an undocumented Blizzard parity invariant."
- [ ] **Step 2 — verify:** `/wg test` still fires popup; `/wg show` after a real LFG join still resurfaces the captured info.
- [ ] **Step 3 — commit:** `docs(WhatGroup): document appID/searchResultID parity invariant (F-004)`.

### Task M4.2 — Document cross-file contract; decline public API (WG-10)

- [ ] **Files:** `ARCHITECTURE.md`.
- [ ] **Step 1 — code:** add a "Cross-file contract" section listing the leading-underscore "internal-but-cross-file" symbols on `WhatGroup`: `_print`, `_dbg`, `_parentSettingsCategory`, `_settingsCategory`, `_settingsRegistered`, `_frameBuildQueued`, plus the leading-uppercase methods used across files: `RunTest`, `WipeCapture`, `ShowFrame`, `Labels`, `COMMANDS`, `pendingInfo`, `Settings.*`. Note: WhatGroup exposes **no** public API for third-party consumption; no `WhatGroup.API.v1` is introduced.
- [ ] **Step 2 — verify:** `grep -n "^WhatGroup\._" /mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/WhatGroup.lua` shows the same six leaked-by-design names listed in the new section.
- [ ] **Step 3 — commit:** `docs(WhatGroup): document cross-file contract; no public API exposure`.

**Checkpoint stop:** confirm M4 is green before M5.

---

## M5 — In-folder peel of `WhatGroup_Settings.lua` (WG-4) — **largest task**

**Pre-task (already done in TECHNICAL_DESIGN):** End-to-end read of `WhatGroup_Settings.lua` complete; section boundaries identified.

### Region map (to be applied mechanically):

| Source lines (current) | Section | Target file |
|---|---|---|
| 1-51 | File-header, AceAddon/AceGUI lookup, `Settings`/`Schema`/`Helpers`/`_refreshers`/`_refresherOrder`/`_panels` init, `pout` helper | `WhatGroup_Settings_Schema.lua` (head) |
| 53-184 | Schema rows | `WhatGroup_Settings_Schema.lua` |
| 186-251 | `Resolve`, `Helpers.Get`, `Helpers.RawSet`, `Helpers.Set`, `Helpers.FindSchema` | `WhatGroup_Settings_Schema.lua` |
| 253-298 | `Helpers.ValidateSchema` (+ `_validTypes` upvalue) | `WhatGroup_Settings_Schema.lua` |
| 300-323 | `Settings.BuildDefaults` | `WhatGroup_Settings_Schema.lua` |
| 325-339 | `Helpers.RestoreDefaults` | `WhatGroup_Settings_Schema.lua` |
| 341-354 | `Helpers.RefreshAll` | `WhatGroup_Settings_Schema.lua` |
| 356-388 | `Settings.EnsureResetPopup` (StaticPopupDialogs deferred write) | `WhatGroup_Settings_Schema.lua` |
| 390-402 | Layout constants (PADDING_X, HEADER_TOP, HEADER_HEIGHT, DEFAULTS_W, SECTION_*, ROW_VSPACER) | `WhatGroup_Settings_Panel.lua` |
| 404-436 | `attachTooltip` (file-local) | `WhatGroup_Settings_Panel.lua` |
| 438-483 | `buildHeader` | `WhatGroup_Settings_Panel.lua` |
| 485-518 | `Helpers.CreatePanel` | `WhatGroup_Settings_Panel.lua` |
| 520-641 | `Helpers.PatchAlwaysShowScrollbar` | `WhatGroup_Settings_Scrollbar.lua` |
| 643-678 | `ensureScroll` (rename to `Helpers.EnsureScroll`) | `WhatGroup_Settings_Scrollbar.lua` |
| 680-690 | `addSpacer` (file-local) | `WhatGroup_Settings_Panel.lua` |
| 692-710 | `Helpers.Section` | `WhatGroup_Settings_Panel.lua` |
| 712-799 | `applyWidth`, `makeCheckbox`, `makeSlider`, `Helpers.RenderField`, `Helpers.InlineButton` | `WhatGroup_Settings_Panel.lua` |
| 801-862 | `Helpers.RenderSchema` | `WhatGroup_Settings_Panel.lua` |
| 864-942 | `MAIN_LOGO_*` constants + `Helpers.BuildMainContent` | `WhatGroup_Settings_Panel.lua` |
| 944-1056 | `Settings.Register` | `WhatGroup_Settings_Panel.lua` |

### Task M5.1 — Pre-flight: enumerate cross-file references

- [ ] **Files:** none (read-only).
- [ ] **Step 1 — analysis:** Confirm in-source which file-local helpers are called only from one peeled file (stay local) vs across boundaries (promote to `Helpers.*`).
  - `addSpacer`: used by `Section`, `RenderSchema`, `BuildMainContent`, `InlineButton` — all in Panel. **Stays file-local in Panel.**
  - `attachTooltip`: used by `buildHeader`, `makeCheckbox`, `makeSlider`, `InlineButton` — all in Panel. **Stays file-local in Panel.**
  - `applyWidth`, `makeCheckbox`, `makeSlider`, `startRow`, `flushRow`: file-local in Panel. **Stay local.**
  - `_validTypes`: used only by `ValidateSchema` in Schema. **Stays file-local in Schema.**
  - `pout`: used by Schema (Helpers.Set, ValidateSchema, RestoreDefaults via Set, EnsureResetPopup OnAccept) AND Panel (InlineButton onClick). **Re-declare per-file** (3 lines).
  - `ensureScroll`: used by Panel (Section, RenderField, InlineButton, RenderSchema, BuildMainContent). Lives in Scrollbar. **Promote to `Helpers.EnsureScroll`.**
- [ ] **Step 2 — verify:** open all four peeled files in the head (after drafting) and grep that no file references a file-local from another file.
- [ ] **Step 3:** no commit.

### Task M5.2 — Create `WhatGroup_Settings_Schema.lua`

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/WhatGroup_Settings_Schema.lua` (new).
- [ ] **Step 1 — code:** copy the regions per the table above. File head (~10 lines):
  ```lua
  -- WhatGroup_Settings_Schema.lua — Schema rows + db.profile helpers + defaults +
  -- StaticPopup. Peeled from WhatGroup_Settings.lua. See TECHNICAL_DESIGN §WG-4.
  local WhatGroup = LibStub("AceAddon-3.0"):GetAddon("WhatGroup")
  WhatGroup.Settings = WhatGroup.Settings or {}
  local Settings    = WhatGroup.Settings
  Settings.Schema           = Settings.Schema or {}
  Settings.Helpers          = Settings.Helpers or {}
  Settings._refreshers      = Settings._refreshers or {}
  Settings._refresherOrder  = Settings._refresherOrder or {}
  Settings._panels          = Settings._panels or {}
  local Schema  = Settings.Schema
  local Helpers = Settings.Helpers
  local function pout(...) if WhatGroup._print then return WhatGroup._print(...) end print(...) end
  ```
  Then paste the bodies for: `add` local, all `add{}` schema rows, `Resolve`, `Helpers.Get`, `Helpers.RawSet`, `Helpers.Set`, `Helpers.FindSchema`, `_validTypes`, `Helpers.ValidateSchema`, `Settings.BuildDefaults`, `Helpers.RestoreDefaults`, `Helpers.RefreshAll`, `Settings.EnsureResetPopup`. **Verbatim copy** — comments included.
- [ ] **Step 2 — verify:** lua-syntax sanity (`luac -p WhatGroup_Settings_Schema.lua`); LOC ≤ 300.
- [ ] **Step 3:** no commit yet (peel commits as one).

### Task M5.3 — Create `WhatGroup_Settings_Scrollbar.lua`

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/WhatGroup_Settings_Scrollbar.lua` (new).
- [ ] **Step 1 — code:** file head:
  ```lua
  -- WhatGroup_Settings_Scrollbar.lua — Always-visible AceGUI ScrollFrame patch
  -- + lazy ScrollFrame container helper. Peeled from WhatGroup_Settings.lua.
  local WhatGroup = LibStub("AceAddon-3.0"):GetAddon("WhatGroup")
  local AceGUI    = LibStub("AceGUI-3.0")
  local Settings  = WhatGroup.Settings
  local Helpers   = Settings.Helpers
  ```
  Paste verbatim: `Helpers.PatchAlwaysShowScrollbar` (was `PatchAlwaysShowScrollbar` — already on `Helpers`, no rename). Paste `ensureScroll` body but **rename** the function to `Helpers.EnsureScroll` (was file-local `ensureScroll`). Internal callers don't exist in this file; Panel will be updated.
- [ ] **Step 2 — verify:** `luac -p`; LOC ≤ 130.
- [ ] **Step 3:** no commit yet.

### Task M5.4 — Create `WhatGroup_Settings_Panel.lua`

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/WhatGroup_Settings_Panel.lua` (new).
- [ ] **Step 1 — code:** file head:
  ```lua
  -- WhatGroup_Settings_Panel.lua — Header builder, panel factory, widget creators,
  -- schema-driven render, parent-page content, Settings.Register.
  -- Peeled from WhatGroup_Settings.lua. See TECHNICAL_DESIGN §WG-4.
  local WhatGroup = LibStub("AceAddon-3.0"):GetAddon("WhatGroup")
  local AceGUI    = LibStub("AceGUI-3.0")
  local Settings  = WhatGroup.Settings
  local Helpers   = Settings.Helpers
  local Schema    = Settings.Schema
  local function pout(...) if WhatGroup._print then return WhatGroup._print(...) end print(...) end
  ```
  Paste verbatim: layout constants → `attachTooltip` → `buildHeader` → `Helpers.CreatePanel` → `addSpacer` → `Helpers.Section` → `applyWidth` → `makeCheckbox` → `makeSlider` → `Helpers.RenderField` → `Helpers.InlineButton` → `Helpers.RenderSchema` → MAIN_* constants → `Helpers.BuildMainContent` → `Settings.Register`.
  
  **Mechanical edit during paste:** replace every call to file-local `ensureScroll(ctx)` with `Helpers.EnsureScroll(ctx)` (5 callsites: `Section`, `RenderField` via `parent or ensureScroll(ctx)`, `InlineButton`, `RenderSchema`, `BuildMainContent`).
- [ ] **Step 2 — verify:** `luac -p`; LOC ≤ 500.
- [ ] **Step 3:** no commit yet.

### Task M5.5 — Update TOC; delete old file

- [ ] **Files:** `WhatGroup.toc`; delete `WhatGroup_Settings.lua`.
- [ ] **Step 1 — code:** in TOC, replace the single `WhatGroup_Settings.lua` line with three lines in dependency order:
  ```
  WhatGroup_Settings_Schema.lua
  WhatGroup_Settings_Scrollbar.lua
  WhatGroup_Settings_Panel.lua
  ```
  (Place after `Locale.lua`, before `WhatGroup_Frame.lua`.)
  Then delete `WhatGroup_Settings.lua` from disk: `rm /mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/WhatGroup_Settings.lua`.
- [ ] **Step 2 — verify:** `ls /mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/*.lua` lists exactly: `WhatGroup.lua`, `Compat.lua`, `Locale.lua`, `WhatGroup_Settings_Schema.lua`, `WhatGroup_Settings_Scrollbar.lua`, `WhatGroup_Settings_Panel.lua`, `WhatGroup_Frame.lua` (7 files; 6 if Scrollbar later folds). `wc -l` each ≤ 700.
- [ ] **Step 3:** no commit yet.

### Task M5.6 — In-game smoke test post-peel

- [ ] **Files:** none.
- [ ] **Step 1 — verify in client:**
  - `/reload`. No Lua errors.
  - `/wg config` opens parent "Ka0s WhatGroup" landing page (logo + Notes + Slash Commands list).
  - Click "General" subcategory in the Settings tree. Schema widgets render in two-column flow; scrollbar always visible (greyed out when content fits).
  - Toggle a setting (e.g. Auto Show off). `/wg get frame.autoShow` returns `false`. `/reload`. State persists.
  - Click Defaults button. Confirm popup. All settings reset.
  - `/wg test` fires the popup notification + WhatGroupFrame.
  - `/wg debug`. Toggle on; `/reload`; toggle remains on.
  - Open Settings panel during combat — chat message "Cannot register settings panel during combat." appears (combat-lockdown layer 2 still works).
- [ ] **Step 2 — verify boot in combat scenario:** `/console reloadui` while in combat (training dummy). Panel doesn't taint Logout — click GameMenu → Logout — no `ADDON_ACTION_FORBIDDEN` errors.
- [ ] **Step 3 — commit (single peel commit):** `refactor(WhatGroup): peel WhatGroup_Settings.lua into Schema/Scrollbar/Panel (WG-4)` — message body lists region map and notes "stays Tier 1 flat; 7 source files vs 8-cap".

**Checkpoint stop:** confirm M5 is green before M6.

---

## M6 — Release prep

### Task M6.1 — Sync docs

- [ ] **Files:** `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `docs/file-index.md`.
- [ ] **Step 1 — code:** invoke `/wow-addon:sync-docs` skill or manually:
  - Update `docs/file-index.md` with the three peeled files (replacing the old single entry).
  - Update `CLAUDE.md` if it referenced `WhatGroup_Settings.lua` directly (search-and-replace to point at the right peeled file).
  - Update `ARCHITECTURE.md` "Module Map" with the 6-or-7 file post-peel layout.
  - README.md "Layout" section (if present) reflects new file count.
- [ ] **Step 2 — verify:** `grep -rn "WhatGroup_Settings\.lua" /mnt/d/Profile/Users/Tushar/Documents/GIT/WhatGroup/{README,CLAUDE,ARCHITECTURE}.md docs/` returns no stale hits (or only historical-context hits in `reviews/`).
- [ ] **Step 3 — commit:** `docs(WhatGroup): sync README/CLAUDE/ARCHITECTURE/file-index with peeled Settings layout`.

### Task M6.2 — Final smoke test

- [ ] **Files:** none.
- [ ] **Step 1 — verify:** run `docs/smoke-tests.md` checklist end-to-end. All sections green (boot, slash, panel, /wg test, real LFG round-trip, regression checks).
- [ ] **Step 2 — verify:** `luacheck .` clean (or with documented suppressions).
- [ ] **Step 3:** no commit (smoke tests are validation, not artefact).

### Task M6.3 — Optional version bump

- [ ] **Files:** none unless user instructs.
- [ ] **Step 1:** **Do not bump** unless the user explicitly says so. Per CLAUDE.md: "Don't bump the version without explicit instruction." If user says yes, invoke `/wow-addon:version-bump <X.Y.Z>` skill.
- [ ] **Step 2 — verify:** if bumped, TOC, code constant, README badge, README Version History all match.
- [ ] **Step 3 — commit (only if bumped):** `chore(WhatGroup): release vX.Y.Z`.

**Checkpoint stop:** WhatGroup remediation complete. Hand off to user for review and `/wow-addon:commit` invocations.
