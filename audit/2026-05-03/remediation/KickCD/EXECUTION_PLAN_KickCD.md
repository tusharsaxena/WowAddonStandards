# KickCD — Execution Plan

**Addon:** KickCD
**Tier:** 2 (canonical reference)
**Source root:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/KickCD`
**Companion design doc:** `./TECHNICAL_DESIGN_KickCD.md`
**Standards:** `WowAddonStandards/03_STANDARDS.md`
**Deviations:** KCD-1..KCD-12 (KCD-13 deferred to v2)

> **How to run this plan.** Each milestone is a sequence of small `- [ ]` tasks. Each task lists the files touched, a step-1 code snippet (or surgical instruction), a step-2 verification command, and a step-3 commit message. **Do not skip the verify step.** Milestones M7 and M8 end with a CHECKPOINT — STOP and wait for user review before continuing.

---

## M1 — Tooling baseline (KCD-1, KCD-2, KCD-3)

### M1.1 — Add `.pkgmeta`

- [ ] **Files:** `KickCD/.pkgmeta` (new)
- [ ] **Step 1.** Create file with content:

```yaml
package-as: KickCD

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
  libs/AceDBOptions-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0
    tag: latest
  libs/AceEvent-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0
    tag: latest
  libs/AceConsole-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0
    tag: latest
  libs/AceGUI-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0
    tag: latest
  libs/AceGUI-3.0-SharedMediaWidgets:
    url: https://repos.wowace.com/wow/ace-gui-3-0-sharedmediawidgets/trunk
    tag: latest
  libs/AceConfig-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0
    tag: latest
  libs/AceConfigDialog-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceConfigDialog-3.0
    tag: latest
  libs/LibSharedMedia-3.0:
    url: https://repos.curseforge.com/wow/libsharedmedia-3-0/trunk
    tag: latest
  libs/LibCustomGlow-1.0:
    url: https://repos.curseforge.com/wow/libcustomglow/trunk
    tag: latest

ignore:
  - .luacheckrc
  - reviews
  - docs/internal
  - _dev
  - "*.bak"
  - .gitattributes
```

- [ ] **Step 2 (verify).** `cat KickCD/.pkgmeta` and confirm exactly 13 externals. `python -c "import yaml; yaml.safe_load(open('KickCD/.pkgmeta'))"` parses without error.
- [ ] **Step 3 (commit).** `git add KickCD/.pkgmeta && git commit -m "KickCD: add .pkgmeta with externals (KCD-1)"`

### M1.2 — Add `.luacheckrc`

- [ ] **Files:** `KickCD/.luacheckrc` (new)
- [ ] **Step 1.** Create file:

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "reviews/", "_dev/", "docs/" }
ignore = {
  "212/self",   -- unused argument self
  "212/event",  -- unused argument event
  "212/_evt",   -- KickCD convention for unused AceEvent first arg
}
read_globals = {
  "_G", "LibStub",
  "CreateFrame", "CreateColor", "CreateColorFromHexString",
  "GetTime", "GetLocale",
  "UnitName", "UnitGUID", "UnitClass", "UnitExists", "UnitIsEnemy",
  "UnitCastingInfo", "UnitChannelInfo",
  "GetSpellInfo", "C_Spell", "C_SpecializationInfo",
  "GetSpecialization", "GetSpecializationInfo",
  "InCombatLockdown", "PlaySound",
  "Settings", "InterfaceOptionsFrame_OpenToCategory",
  "C_Timer", "hooksecurefunc",
  "Mixin", "BackdropTemplateMixin",
  "issecretvalue", "securecallfunction",
  "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC",
  "UIParent", "GameTooltip",
  "RegisterStateDriver",
  "C_AddOns",
}
globals = {
  "KickCDDB",
  "KickCD",  -- legacy bootstrap-namespace global; promoted in core/KickCD.lua
}
```

- [ ] **Step 2 (verify).** `cd KickCD && luacheck .` returns 0 errors. (Warnings allowed at this stage.)
- [ ] **Step 3 (commit).** `git add KickCD/.luacheckrc && git commit -m "KickCD: add .luacheckrc baseline (KCD-2)"`

### M1.3 — TOC X-IDs

- [ ] **Files:** `KickCD/KickCD.toc`
- [ ] **Step 1.** After the `## X-License: MIT` line (currently `KickCD.toc:10`), insert:

```
## X-Curse-Project-ID: 0
## X-Wago-ID: 0
```

(`0` is a placeholder; user supplies real IDs at publish time.)

- [ ] **Step 2 (verify).** `grep '^## X-' KickCD/KickCD.toc | wc -l` returns 3.
- [ ] **Step 3 (commit).** `git add KickCD/KickCD.toc && git commit -m "KickCD: add Curse/Wago shop ID placeholders (KCD-3)"`

**Checkpoint:** M1 complete — tooling baseline in place.

---

## M2 — Compat shim for Specialization (KCD-4)

### M2.1 — Add shim functions to `core/Compat.lua`

- [ ] **Files:** `KickCD/core/Compat.lua`
- [ ] **Step 1.** Append the following after the existing spell-API block (somewhere after the `Compat.GetSpellInfo` definition, near end of file but before any closing scope):

```lua
-- ---------------------------------------------------------------------------
-- Specialization APIs
-- ---------------------------------------------------------------------------
--
-- WoW 11.x consolidated GetSpecialization* under C_SpecializationInfo.*.
-- Older flavors (Classic / Cata Classic) keep the bare globals. Wrap
-- both behind Compat so call-site files never branch.

--- Current spec index (1..N) for the player. Returns nil if unavailable.
function Compat.GetSpecialization()
    if _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecialization then
        return _G.C_SpecializationInfo.GetSpecialization()
    end
    if _G.GetSpecialization then return _G.GetSpecialization() end
    return nil
end

--- Spec info tuple for a given index, matching Blizzard's legacy shape:
--- specID, specName, description, iconID, role, primaryStat
function Compat.GetSpecializationInfo(specIndex)
    if _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecializationInfo then
        return _G.C_SpecializationInfo.GetSpecializationInfo(specIndex)
    end
    if _G.GetSpecializationInfo then return _G.GetSpecializationInfo(specIndex) end
    return nil
end
```

- [ ] **Step 2 (verify).** `grep -n "Compat.GetSpecialization" KickCD/core/Compat.lua` returns 2 hits.
- [ ] **Step 3 (commit).** `git add KickCD/core/Compat.lua && git commit -m "KickCD: add Compat.GetSpecialization{,Info} shims (KCD-4 part 1)"`

### M2.2 — Replace call sites

- [ ] **Files:** `KickCD/modules/Cooldowns.lua`, `KickCD/modules/IconGrid.lua`, `KickCD/core/KickCD.lua`
- [ ] **Step 1.**
  - In `modules/Cooldowns.lua` around line 78-82, replace:
    ```lua
    local idx = GetSpecialization and GetSpecialization()
    ...
    local _, specName = GetSpecializationInfo(idx)
    ```
    with:
    ```lua
    local idx = KickCD.Compat.GetSpecialization()
    ...
    local _, specName = KickCD.Compat.GetSpecializationInfo(idx)
    ```
  - In `modules/IconGrid.lua` around line 286-290, replace identically.
  - In `core/KickCD.lua` around line 553-562, replace any direct `GetSpecialization`/`GetSpecializationInfo` reference with the `KickCD.Compat.` form (search the file with `grep -n "GetSpecialization" core/KickCD.lua`).

- [ ] **Step 2 (verify).** `grep -rn "\\bGetSpecialization\\b" KickCD/core KickCD/modules KickCD/settings` shows hits **only** in `core/Compat.lua`.
- [ ] **Step 3 (commit).** `git add KickCD/modules/Cooldowns.lua KickCD/modules/IconGrid.lua KickCD/core/KickCD.lua && git commit -m "KickCD: route GetSpecialization* through Compat (KCD-4 part 2)"`

**Checkpoint:** M2 complete — KCD-4 closed. In-game: `/reload`, switch specs, run `/kcd debug spells` — must show new spec immediately.

---

## M3 — Lib cleanup (KCD-6)

### M3.1 — Confirm zero call sites

- [ ] **Files:** none (audit-only)
- [ ] **Step 1.** Run for each candidate lib:
  ```sh
  for L in AceBucket AceComm AceHook AceLocale AceSerializer AceTab AceTimer; do
      echo "=== $L ==="
      grep -rn "LibStub.*${L}-3.0" KickCD/core KickCD/modules KickCD/settings KickCD/defaults KickCD/locales
  done
  ```
- [ ] **Step 2 (verify).** Every block prints `=== X ===` with no hits below.
- [ ] **Step 3 (commit).** No commit (audit-only).

### M3.2 — Delete unused libs

- [ ] **Files:** `KickCD/libs/AceBucket-3.0/`, `AceComm-3.0/`, `AceHook-3.0/`, `AceLocale-3.0/`, `AceSerializer-3.0/`, `AceTab-3.0/`, `AceTimer-3.0/`
- [ ] **Step 1.** `cd KickCD && git rm -r libs/AceBucket-3.0 libs/AceComm-3.0 libs/AceHook-3.0 libs/AceLocale-3.0 libs/AceSerializer-3.0 libs/AceTab-3.0 libs/AceTimer-3.0`
- [ ] **Step 2 (verify).** `ls KickCD/libs/` lists 12 entries (not 19). In-game `/reload` produces no errors.
- [ ] **Step 3 (commit).** `git commit -m "KickCD: delete vendored-unused libs (KCD-6)"`

**Checkpoint:** M3 complete — KCD-6 closed.

---

## M4 — Locale unification (KCD-8)

KCD-8 is fully resolved by M3.2 (AceLocale was the unused lib that drove the deviation). No further code change needed. Decision recorded:

- [ ] **Step 1.** Edit `KickCD/CLAUDE.md` "Conventions" section to state: "Locale uses metatable `__index = key` fallback (`locales/enUS.lua:12-17`). AceLocale is **not** used; the standard accepts both and we picked the lighter pattern."
- [ ] **Step 2 (verify).** `grep -n "AceLocale\|metatable" KickCD/CLAUDE.md` shows the new sentence.
- [ ] **Step 3 (commit).** `git add KickCD/CLAUDE.md && git commit -m "KickCD: document locale strategy decision (KCD-8)"`

**Checkpoint:** M4 complete — KCD-8 closed.

---

## M5 — Slash to AceConsole (KCD-7) — already implemented

The deviation is stale relative to source. Verify and document.

### M5.1 — Verify AceConsole

- [ ] **Files:** none (audit)
- [ ] **Step 1.** Run:
  ```sh
  grep -n "RegisterChatCommand" KickCD/core/KickCD.lua
  grep -rn "^SLASH_\|_G\.SLASH_" KickCD/core KickCD/modules KickCD/settings
  ```
- [ ] **Step 2 (verify).** First grep returns ≥2 lines (`kickcd`, `kcd` registrations at lines ~60-61). Second grep returns 0 hits.
- [ ] **Step 3 (commit).** No code change; record in execution log: "KCD-7 already met — `RegisterChatCommand` at `core/KickCD.lua:60-61`; no SLASH_* present."

**Checkpoint:** M5 complete — KCD-7 closed without source change.

---

## M6 — Polish (KCD-10, KCD-11, KCD-12)

### M6.1 — Glow sentinel (KCD-11)

- [ ] **Files:** `KickCD/modules/IconGrid.lua` (NB: do this **before** M8 peel so the rename only happens once)
- [ ] **Step 1.**
  - Near the top of the file's helpers section (around line 86), add:
    ```lua
    -- Glow-gate sentinel for the rare case where notInterruptible is a
    -- secret-tainted value we can't equality-compare in Lua. A unique
    -- table reference is never == any boolean or nil.
    local GLOW_SECRET = {}
    ```
  - Around lines 1684-1700 in `RefreshAllGlows`, replace `interruptible = "secret"` with `interruptible = GLOW_SECRET` and `interruptible ~= "secret"` with `interruptible ~= GLOW_SECRET`.

- [ ] **Step 2 (verify).** `grep -n '"secret"' KickCD/modules/IconGrid.lua` returns 0 hits inside the glow-gate region. Cast on a hostile target in-game; glow still cycles correctly.
- [ ] **Step 3 (commit).** `git add KickCD/modules/IconGrid.lua && git commit -m "KickCD: replace glow-gate string sentinel with table (KCD-11)"`

### M6.2 — Spell-list class validation (KCD-10)

- [ ] **Files:** `KickCD/core/Database.lua`, `KickCD/core/KickCD.lua`
- [ ] **Step 1.**
  - In `core/Database.lua`, near the top (after the requires, before `BuildSpells`), add:
    ```lua
    local VALID_CLASSES = {
        DEATHKNIGHT=true, DEMONHUNTER=true, DRUID=true, EVOKER=true,
        HUNTER=true, MAGE=true, MONK=true, PALADIN=true, PRIEST=true,
        ROGUE=true, SHAMAN=true, WARLOCK=true, WARRIOR=true,
    }
    ```
  - Replace the existing `Database:EnsureSpellList(class, spec)` (around `core/Database.lua:292-299`) with:
    ```lua
    function Database:EnsureSpellList(class, spec)
        class = class and class:upper() or nil
        if not VALID_CLASSES[class] then
            if KickCD.Util and KickCD.Util.print then
                KickCD.Util.print("unknown class token: "
                    .. tostring(class)
                    .. " (valid: DEATHKNIGHT, DEMONHUNTER, DRUID, EVOKER, "
                    .. "HUNTER, MAGE, MONK, PALADIN, PRIEST, ROGUE, "
                    .. "SHAMAN, WARLOCK, WARRIOR)")
            end
            return nil
        end
        local p = KickCD.db.profile.spells
        p[class] = p[class] or {}
        spec = KickCD.Util.NormalizeSpecToken(spec or "")
        p[class][spec] = p[class][spec] or {}
        return p[class][spec]
    end
    ```
  - In `core/KickCD.lua` SPELLS_COMMANDS (around `:787-802` and the `spells add`/`spells remove`/etc. handlers below), find every callsite of `EnsureSpellList(class, spec)` and after the call insert:
    ```lua
    if not list then return end  -- EnsureSpellList already printed the error
    ```

- [ ] **Step 2 (verify).** In-game: `/kcd spells add 1766 ROGE OUTLAW` prints the error and `/kcd spells list ROGE OUTLAW` reports nothing was added. Then `/kcd spells add 1766 ROGUE OUTLAW` succeeds.
- [ ] **Step 3 (commit).** `git add KickCD/core/Database.lua KickCD/core/KickCD.lua && git commit -m "KickCD: validate class token in EnsureSpellList (KCD-10)"`

### M6.3 — Dead TODOs (KCD-12)

- [ ] **Files:** `KickCD/modules/IconGrid.lua`, `KickCD/reviews/2026-05-02/05_FINAL_SUMMARY.md`, `KickCD/docs/icon-grid.md`
- [ ] **Step 1.**
  - Delete the TODO comment block at `modules/IconGrid.lua:226-228` (the `BuildCurves` perf TODO).
  - Search and remove any other `TODO(perf)` / `F-015` / `F-016` source comments: `grep -n "F-015\|F-016\|TODO(perf)" KickCD/modules KickCD/settings KickCD/core`.
  - In `reviews/2026-05-02/05_FINAL_SUMMARY.md`, under the deferred-list, add: "F-015, F-016 — remain deferred; `BuildCurves` and `Castbar:Reskin` rebuild on every relevant CONFIG_CHANGED is accepted as the trade-off until evidence of a hot-path miss appears."
  - In `docs/icon-grid.md`, under "Future" (or add such a section), add the same accepted-cost line.
- [ ] **Step 2 (verify).** `grep -rn "F-015\|F-016\|TODO(perf)" KickCD/modules KickCD/settings KickCD/core` returns 0 hits.
- [ ] **Step 3 (commit).** `git add -u KickCD && git commit -m "KickCD: reconcile F-015/F-016 deferred status (KCD-12)"`

**Checkpoint:** M6 complete — KCD-10, KCD-11, KCD-12 closed.

---

## M7 — File peel: `settings/Panel.lua` (1258 → 5 files)

This milestone restructures `settings/Panel.lua` into a sub-folder. **Do M7 before M8** — Panel is smaller and the failure mode is more visible (settings UI) so it's the better practice run.

### M7.1 — Create `settings/Panel/` directory + scaffold Init

- [ ] **Files:** `KickCD/settings/Panel/Init.lua` (new)
- [ ] **Step 1.** Create file with content:

```lua
-- settings/Panel/Init.lua
-- Bootstrap for the settings panel framework. Loads first within the
-- settings/Panel/ tree.
--
-- Publishes the public Helpers table (KickCD.Settings.Helpers) and the
-- private helpers table (Helpers._private) used by sibling files.

local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")

KickCD.Settings = KickCD.Settings or {}
KickCD.Settings.Schema   = KickCD.Settings.Schema or {}
KickCD.Settings.builders = KickCD.Settings.builders or {}
KickCD.Settings.sub      = KickCD.Settings.sub or {}
KickCD.Settings.order    = KickCD.Settings.order or {
    "general", "icons", "castbar", "spells", "profiles",
}
KickCD.Settings.ctx      = KickCD.Settings.ctx or {}

local Helpers = KickCD.Settings.Helpers or {}
Helpers._private = Helpers._private or {}
KickCD.Settings.Helpers = Helpers

local AceGUI = LibStub("AceGUI-3.0")
KickCD.Settings.AceGUI = AceGUI

local L = KickCD.L

-- ---------------------------------------------------------------------
-- Read/write seam (Helpers.Get / Helpers.Set / FireConfigChanged)
-- ---------------------------------------------------------------------
-- Lifted verbatim from the pre-peel settings/Panel.lua:38-72.

local function Resolve(path)
    if not (KickCD.db and KickCD.db.profile) then return nil, nil end
    local node, key = KickCD.db.profile, nil
    for seg in tostring(path):gmatch("[^.]+") do
        if key then node = node[key]; if type(node) ~= "table" then return nil, nil end end
        key = seg
    end
    return node, key
end

function Helpers.Get(path)
    local node, key = Resolve(path)
    if node and key then return node[key] end
    return nil
end

function Helpers.FireConfigChanged(section)
    if KickCD.SendMessage then
        KickCD:SendMessage("KickCD_CONFIG_CHANGED", section)
    end
end

function Helpers.Set(path, section, value)
    local node, key = Resolve(path)
    if node and key then node[key] = value end
    Helpers.FireConfigChanged(section)
end
```

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Init.lua` ≤ 100. `luacheck KickCD/settings/Panel/Init.lua` clean.
- [ ] **Step 3 (commit).** Defer commit until M7 finished.

### M7.2 — Extract Schema region → `settings/Panel/Schema.lua`

- [ ] **Files:** `KickCD/settings/Panel/Schema.lua` (new), `KickCD/settings/Panel.lua` (read source)
- [ ] **Step 1.** Cut lines 91-256 from the current `settings/Panel.lua` (`SchemaForPanel`, `FindSchema`, `_printSchemaError`, `ValidateSchema`, `AnchorValues`, `LSMValues`, layout constants block) and paste into a new file with this header:

```lua
-- settings/Panel/Schema.lua — schema query, validation, anchor + LSM values.
local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local Helpers = KickCD.Settings.Helpers
local L = KickCD.L

-- (paste cut content here; rewrite `local function _printSchemaError`
--  to `local _printSchemaError; function Helpers._private.printSchemaError`
--  if it's referenced from another file — otherwise keep file-local.)
```

Specifically:
- `_printSchemaError` (line 117 in source): keep `local`, used only by `ValidateSchema` in the same new file.
- All public `Helpers.*` definitions stay public.
- The layout-constants block (lines 215-222) becomes file-locals at the top of `Schema.lua`.

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Schema.lua` ≤ 200.
- [ ] **Step 3.** Defer commit.

### M7.3 — Extract Frame region → `settings/Panel/Frame.lua`

- [ ] **Files:** `KickCD/settings/Panel/Frame.lua` (new)
- [ ] **Step 1.** Cut lines 224-501 from current `settings/Panel.lua` (tooltip helper `attachTooltip` 229-256, header builder `buildHeader` 261-303, `Helpers.CreatePanel` 312-339, scrollbar patch `Helpers.PatchAlwaysShowScrollbar` 360-501). Header:

```lua
-- settings/Panel/Frame.lua — header, CreatePanel, scrollbar patch, tooltip helper.
local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local Helpers = KickCD.Settings.Helpers
local AceGUI = KickCD.Settings.AceGUI
local L = KickCD.L
```

- File-local `attachTooltip` and `buildHeader` stay `local`; only used inside this file.
- `Helpers.CreatePanel` and `Helpers.PatchAlwaysShowScrollbar` stay public.

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Frame.lua` ≤ 280.
- [ ] **Step 3.** Defer commit.

### M7.4 — Extract Widgets region → `settings/Panel/Widgets.lua`

- [ ] **Files:** `KickCD/settings/Panel/Widgets.lua` (new)
- [ ] **Step 1.** Cut lines 502-900 from current `settings/Panel.lua` (`ensureScroll` 508, `fireOnChange` 544, `addSpacer` 571, `Helpers.Section` 579, `applyWidth` 610, `makeCheckbox` 618, `snapToStep` 646, `makeSlider` 651, `makeDropdown` 688, `makeColorPicker` 745, `Helpers.RenderField` 801, `Helpers.InlineButton` 810, `Helpers.InlineButtonPair` 840, `Helpers.Button` 871). Header:

```lua
-- settings/Panel/Widgets.lua — widget primitives (checkbox / slider / dropdown / colorpicker / buttons / section heading).
local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local Helpers = KickCD.Settings.Helpers
local AceGUI = KickCD.Settings.AceGUI
local L = KickCD.L
```

- All file-locals (`ensureScroll`, `fireOnChange`, `addSpacer`, `applyWidth`, `snapToStep`, `makeCheckbox`, `makeSlider`, `makeDropdown`, `makeColorPicker`) stay `local`; only `Helpers.Section`, `Helpers.RenderField`, `Helpers.InlineButton`, `Helpers.InlineButtonPair`, `Helpers.Button` are public.

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Widgets.lua` ≤ 420.
- [ ] **Step 3.** Defer commit.

### M7.5 — Extract Render region → `settings/Panel/Render.lua`

- [ ] **Files:** `KickCD/settings/Panel/Render.lua` (new)
- [ ] **Step 1.** Cut lines 901-1095 from current `settings/Panel.lua` (`Helpers.RenderSchema` 924, `Helpers.RefreshAllPanels` 984, `Helpers.RestoreDefaults` 993, `Helpers.RestoreAllDefaults` 1022, `Helpers.SetAndRefresh` 1046, `Helpers.ResetIconPosition` 1066, `Helpers.ResetAll` 1088). Header:

```lua
-- settings/Panel/Render.lua — schema-driven panel rendering + refresh / reset.
local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local Helpers = KickCD.Settings.Helpers
local AceGUI = KickCD.Settings.AceGUI
local L = KickCD.L
```

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Render.lua` ≤ 220.
- [ ] **Step 3.** Defer commit.

### M7.6 — Extract Register region → `settings/Panel/Register.lua`

- [ ] **Files:** `KickCD/settings/Panel/Register.lua` (new)
- [ ] **Step 1.** Cut lines 1096-1258 from current `settings/Panel.lua` (`addBlock` 1110, `Helpers.BuildMainContent` 1119, `KickCD.Settings.RegisterTab` 1187, `RegisterPanel` 1198, `KickCD.Settings.Register = RegisterPanel` 1244-1245, bootstrap CreateFrame block 1248-1257). Header:

```lua
-- settings/Panel/Register.lua — main-page content + tab registration + bootstrap frame.
local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local Helpers = KickCD.Settings.Helpers
local AceGUI = KickCD.Settings.AceGUI
local L = KickCD.L
```

- [ ] **Step 2 (verify).** `wc -l KickCD/settings/Panel/Register.lua` ≤ 200. The bootstrap `CreateFrame` listener at the end is preserved verbatim.
- [ ] **Step 3.** Defer commit.

### M7.7 — Update TOC and delete the old file

- [ ] **Files:** `KickCD/KickCD.toc`, `KickCD/settings/Panel.lua` (delete)
- [ ] **Step 1.** In `KickCD.toc`, replace the line `settings\Panel.lua` (or `settings/Panel.lua`) with the 6 ordered lines:
  ```
  settings\Panel\Init.lua
  settings\Panel\Schema.lua
  settings\Panel\Frame.lua
  settings\Panel\Widgets.lua
  settings\Panel\Render.lua
  settings\Panel\Register.lua
  ```
  (Use `\` separators to match the existing TOC convention.)
- [ ] **Step 2.** `git rm KickCD/settings/Panel.lua`.
- [ ] **Step 3 (verify).**
  - `wc -l KickCD/settings/Panel/*.lua` — every file under 700.
  - In-game `/reload` produces zero errors.
  - `/kcd config` opens the panel; every tab (General, Icons, Castbar, Spells, Profiles) renders with widgets bound to live SVs.
  - `/kcd resetall` works and updates visible widgets.
  - `/kcd set general.scale 1.4` updates SV and widget.
- [ ] **Step 4 (commit).** `git add -u KickCD && git add KickCD/settings/Panel/ && git commit -m "KickCD: peel settings/Panel.lua into 6 files (KCD-5 part 1)"`

**CHECKPOINT: STOP for user review of M7. Do not proceed to M8 until user confirms settings panel works end-to-end.**

---

## M8 — File peel: `modules/IconGrid.lua` (1753 → 7 files)

The largest, riskiest milestone. Closures over file-local state (`pool`, `ordered`, `grid`, `_textIcons`, `_textTicker`) require lifting onto `M._state`. Helper closures lift onto `M._helpers`. The Icon mixin lifts onto `M._Icon`.

### M8.1 — Create `modules/IconGrid/Init.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Init.lua` (new)
- [ ] **Step 1.** Create file:

```lua
-- modules/IconGrid/Init.lua
-- Loads first within modules/IconGrid/. Owns:
--   * Module namespace publication.
--   * Module-local state (pool, ordered, grid, _textIcons, etc.) — published
--     on M._state so siblings can read/write through one anchor.
--   * Private helpers table (M._helpers) for cross-file file-locals.
--   * Icon mixin table (M._Icon) — populated by Icon.lua.
--
-- File banner content (architectural notes) is preserved verbatim from
-- the pre-peel modules/IconGrid.lua:1-54.

local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD:NewModule("IconGrid", "AceEvent-3.0")
KickCD.IconGrid = IconGrid  -- legacy alias

IconGrid._state = IconGrid._state or {
    pool        = { active = {}, free = {} },
    ordered     = {},
    grid        = nil,    -- created lazily in EnsureGrid
    _textIcons  = {},
    _textTicker = nil,
    _textPaused = false,
    LCG_KEY     = "KickCD",
}
IconGrid._helpers = IconGrid._helpers or {}
IconGrid._Icon    = IconGrid._Icon or {}

-- File banner from pre-peel IconGrid.lua:3-54 — paste verbatim as a
-- giant comment block here.
```

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Init.lua` ≤ 100 (excluding the banner comment).
- [ ] **Step 3.** Defer commit.

### M8.2 — Extract Helpers → `modules/IconGrid/Helpers.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Helpers.lua` (new)
- [ ] **Step 1.** Cut lines 87-292 from current `modules/IconGrid.lua` (`isEnabled` 120, `isTargetCasting` 133, `visibilityMode` 144, `shouldBeVisible` 163, `ApplyInterruptibilityMask` 189, `safeUnpackColor` 203, `fetchBorderTexture` 214, `BuildCurves` 229, `getActiveSpecKey` 282; plus the `GLOW_SECRET` sentinel from M6.1 and the `GCD_UPPER` constant block). Header:

```lua
-- modules/IconGrid/Helpers.lua — file-locals lifted onto M._helpers.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local helpers  = IconGrid._helpers
local state    = IconGrid._state
local L        = KickCD.L

-- File-local constants
local GCD_UPPER     = ... -- copy from source
local GLOW_SECRET   = {}
helpers.GLOW_SECRET = GLOW_SECRET   -- exported so Icon.lua can compare

-- Each `local function foo(...)` from the source becomes
-- `function helpers.foo(...)`. Internal call sites within this file
-- can also be rewritten to local upvalues for hot paths if needed:
--    local foo = helpers.foo
```

For each lifted helper:
- `isEnabled` → `helpers.isEnabled`
- `isTargetCasting` → `helpers.isTargetCasting`
- `visibilityMode` → `helpers.visibilityMode`
- `shouldBeVisible` → `helpers.shouldBeVisible`
- `ApplyInterruptibilityMask` → `helpers.ApplyInterruptibilityMask`
- `safeUnpackColor` → `helpers.safeUnpackColor`
- `fetchBorderTexture` → `helpers.fetchBorderTexture`
- `BuildCurves` → `helpers.BuildCurves` (also exports `state.curves` after build)
- `getActiveSpecKey` → `helpers.getActiveSpecKey`

Use `KickCD.Compat.GetSpecialization()` / `.GetSpecializationInfo()` from M2.

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Helpers.lua` ≤ 230.
- [ ] **Step 3.** Defer commit.

### M8.3 — Extract Icon mixin → `modules/IconGrid/Icon.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Icon.lua` (new)
- [ ] **Step 1.** Cut lines 293-849 from current source (`CreateIconWidget` 302, all `Icon:*` methods 438-849, `unpackGlowColor` 541, `triggerSatisfied` 602, `applyGcdSuppressionAlpha` 665). Header:

```lua
-- modules/IconGrid/Icon.lua — per-icon widget construction and Icon mixin.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local Icon     = IconGrid._Icon
local helpers  = IconGrid._helpers
local state    = IconGrid._state
local L        = KickCD.L

-- File-locals
local function unpackGlowColor(c) ... end
local function triggerSatisfied(trigger) ... end
local function applyGcdSuppressionAlpha(icon, cdObject) ... end

-- CreateIconWidget — file-local, exported on IconGrid for Pool.lua
local function CreateIconWidget(parent) ... end
IconGrid._CreateIconWidget = CreateIconWidget

-- All Icon:* methods become Icon:* on IconGrid._Icon, e.g.
function Icon:Apply(state) ... end
function Icon:UpdateGlow(state) ... end
function Icon:StartGlow(kind, color) ... end
-- ...etc.
```

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Icon.lua` ≤ 580.
- [ ] **Step 3.** Defer commit.

### M8.4 — Extract Pool → `modules/IconGrid/Pool.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Pool.lua` (new)
- [ ] **Step 1.** Cut lines 850-941 from source (`_tickAllTextIcons` 860, `IconGrid:_RegisterTextIcon` 878, `IconGrid:_UnregisterTextIcon` 889, `IconGrid:AcquireIcon` 904, `IconGrid:ReleaseAll` 919). Header:

```lua
-- modules/IconGrid/Pool.lua — icon pool + shared cooldown-text ticker.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local state    = IconGrid._state

local function _tickAllTextIcons() ... end
function IconGrid:_RegisterTextIcon(icon) ... end
function IconGrid:_UnregisterTextIcon(icon) ... end
function IconGrid:AcquireIcon(spellID)
    -- calls IconGrid._CreateIconWidget for cold path, then Mixin(button, IconGrid._Icon)
end
function IconGrid:ReleaseAll() ... end
```

- `_textTicker` becomes `state._textTicker`; reads/writes through `state`.
- The shared `C_Timer.NewTicker(0.1, _tickAllTextIcons)` lives here.

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Pool.lua` ≤ 110.
- [ ] **Step 3.** Defer commit.

### M8.5 — Extract Layout → `modules/IconGrid/Layout.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Layout.lua` (new)
- [ ] **Step 1.** Cut lines 942-1379 (`IconGrid:BuildActiveList` 952, `parseAnchor` 1058, `parseGrow` 1078, `placeBlock` 1093, `layoutBlock` 1170, `IconGrid:Layout` 1276, `IconGrid:ApplyGeneral` 1372). Header:

```lua
-- modules/IconGrid/Layout.lua — active-spell-list build, grid layout math.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local helpers  = IconGrid._helpers
local state    = IconGrid._state
local L        = KickCD.L

local function parseAnchor(value) ... end
local function parseGrow(value) ... end
local function placeBlock(...) ... end
local function layoutBlock(...) ... end

function IconGrid:BuildActiveList() ... end
function IconGrid:Layout()
    -- end with: KickCD:SendMessage("KickCD_GRID_LAYOUT")
end
function IconGrid:ApplyGeneral() ... end
```

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Layout.lua` ≤ 460.
- [ ] **Step 3.** Defer commit.

### M8.6 — Extract Anchor → `modules/IconGrid/Anchor.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Anchor.lua` (new)
- [ ] **Step 1.** Cut lines 1380-1459 (`onDragStart` 1384, `onDragStop` 1389, `IconGrid:ApplyLock` 1405, `IconGrid:EnsureGrid` 1431). Header:

```lua
-- modules/IconGrid/Anchor.lua — lock + drag persistence + grid frame creation.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local state    = IconGrid._state
local L        = KickCD.L

local function onDragStart(self) ... end
local function onDragStop(self) ... end

function IconGrid:ApplyLock() ... end
function IconGrid:EnsureGrid() ... end
```

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Anchor.lua` ≤ 100.
- [ ] **Step 3.** Defer commit.

### M8.7 — Extract Events → `modules/IconGrid/Events.lua`

- [ ] **Files:** `KickCD/modules/IconGrid/Events.lua` (new)
- [ ] **Step 1.** Cut lines 1460-1753 (`OnEnable` 1464, `OnDisable` 1531, `OnSpellState` 1547, `OnConfigChanged` 1557, `OnProfileChanged` 1588, `RefreshVisibility` 1615, `OnTargetCastEvent` 1630, `OnTargetChanged` 1639, `RefreshAllGlows` 1658 — uses `helpers.GLOW_SECRET`, `OnCombatStateChanged` 1713, `OnSpecChanged` 1717, `OnPlayerEnteringWorld` 1725, `OnSpellsChanged` 1734, `GetGridFrame` 1745, `GetPrimaryIcon` 1751). Header:

```lua
-- modules/IconGrid/Events.lua — module lifecycle, message + event handlers, public accessors.
local KickCD   = LibStub("AceAddon-3.0"):GetAddon("KickCD")
local IconGrid = KickCD.IconGrid
local helpers  = IconGrid._helpers
local state    = IconGrid._state
local L        = KickCD.L

function IconGrid:OnEnable() ... end
function IconGrid:OnDisable() ... end
-- (all message + event handlers)
function IconGrid:GetGridFrame() return state.grid end
function IconGrid:GetPrimaryIcon() return state.ordered[1] end
```

- [ ] **Step 2 (verify).** `wc -l KickCD/modules/IconGrid/Events.lua` ≤ 310.
- [ ] **Step 3.** Defer commit.

### M8.8 — Update TOC and delete old file

- [ ] **Files:** `KickCD/KickCD.toc`, `KickCD/modules/IconGrid.lua` (delete)
- [ ] **Step 1.** In `KickCD.toc`, replace `modules\IconGrid.lua` with the 7 ordered lines:
  ```
  modules\IconGrid\Init.lua
  modules\IconGrid\Helpers.lua
  modules\IconGrid\Icon.lua
  modules\IconGrid\Pool.lua
  modules\IconGrid\Layout.lua
  modules\IconGrid\Anchor.lua
  modules\IconGrid\Events.lua
  ```
- [ ] **Step 2.** `git rm KickCD/modules/IconGrid.lua`.
- [ ] **Step 3 (verify).**
  - `wc -l KickCD/modules/IconGrid/*.lua` — every file ≤ 600.
  - In-game `/reload` produces zero errors.
  - Smoke tests from `docs/smoke-tests.md` all pass:
    - Cold install (delete SV, /reload twice).
    - Visibility modes (`always`, `in_combat`, `target_casting`, `target_casting_interruptible`).
    - Lock/unlock + drag the grid.
    - Spec switch → grid rebuilds with new spec's spells.
    - Cast a kick on a hostile target → glow fires.
    - `/kcd debug spells`, `/kcd debug interrupt`, `/kcd debug log` produce expected output.
- [ ] **Step 4 (commit).** `git add -u KickCD && git add KickCD/modules/IconGrid/ && git commit -m "KickCD: peel modules/IconGrid.lua into 7 files (KCD-5 part 2)"`

**CHECKPOINT: STOP for user review of M8. Do not proceed to M9 until user confirms IconGrid + smoke tests pass.**

---

## M9 — Doc reconciliation (KCD-9)

### M9.1 — Fix ARCHITECTURE.md count drift

- [ ] **Files:** `KickCD/ARCHITECTURE.md`
- [ ] **Step 1.** Edit line 38. Replace `Closed message contract (4 messages, sender/listener/payload)` with `Closed message contract (5 messages, sender/listener/payload)`.
- [ ] **Step 2 (verify).** `grep -n "messages" KickCD/ARCHITECTURE.md KickCD/CLAUDE.md KickCD/README.md KickCD/docs/message-bus.md` shows uniform "5".
- [ ] **Step 3 (commit).** `git add KickCD/ARCHITECTURE.md && git commit -m "KickCD: fix ARCHITECTURE.md '4 messages' drift to 5 (KCD-9 part 1)"`

### M9.2 — Run sync-docs skill

- [ ] **Files:** `KickCD/README.md`, `KickCD/CLAUDE.md`, `KickCD/ARCHITECTURE.md`, `KickCD/docs/*.md`
- [ ] **Step 1.** From within `KickCD/`, invoke the `wow-addon:sync-docs` skill. Let it deep-analyze and rewrite the three top-level docs (and any `docs/` topic files it flags) to match current source after M1-M8 changes.
- [ ] **Step 2 (verify).** Manually skim README, CLAUDE, ARCHITECTURE — message-bus list shows 5 messages; module-map references the new `modules/IconGrid/` and `settings/Panel/` sub-folders; slash list matches `core/KickCD.lua` COMMANDS table.
- [ ] **Step 3 (commit).** `git add -u KickCD && git commit -m "KickCD: sync README/CLAUDE/ARCHITECTURE to post-peel source (KCD-9 part 2)"`

**Checkpoint:** M9 complete — KCD-9 closed.

---

## M10 — Release prep

### M10.1 — Version bump

- [ ] **Files:** TOC, `core/KickCD.lua`, `README.md`, `CLAUDE.md`, `CHANGELOG.md` (create if missing)
- [ ] **Step 1.** Bump from 1.1.0 to 1.2.0 (MINOR — internal restructuring + new tooling, no breaking SV changes). Use the `wow-addon:version-bump` skill: `wow-addon:version-bump 1.2.0`.
- [ ] **Step 2 (verify).** `grep -n "1.2.0" KickCD/KickCD.toc KickCD/core/KickCD.lua KickCD/README.md KickCD/CLAUDE.md` returns hits in every file.
- [ ] **Step 3 (commit).** Skill commits automatically; if not, `git add -u KickCD && git commit -m "KickCD: bump to 1.2.0"`.

### M10.2 — Final smoke test

- [ ] **Files:** none (in-game)
- [ ] **Step 1.** Walk every test in `KickCD/docs/smoke-tests.md`:
  - Cold install (delete `WTF/Account/.../SavedVariables/KickCDDB.lua`, login).
  - Visibility modes (cycle all 4).
  - Lock/unlock + drag.
  - Spec switch.
  - Cast bar appears on a hostile cast.
  - `/kcd config` opens and every tab renders.
  - `/kcd resetall` resets defaults.
  - `/kcd spells add 1766 ROGUE OUTLAW` succeeds; bad class token rejected.
  - `/kcd debug spells`, `/kcd debug interrupt`, `/kcd debug log` work.
- [ ] **Step 2 (verify).** Every line in the smoke-tests doc passes.
- [ ] **Step 3.** No commit (testing only).

### M10.3 — Final lint + LOC sweep

- [ ] **Files:** none
- [ ] **Step 1.**
  ```sh
  cd KickCD
  luacheck . | tail
  find core modules settings defaults locales -name '*.lua' -exec wc -l {} \; | awk '$1 > 1500 {print}'
  grep -rn "\\bGetSpecialization\\b\\|\\bGetSpecializationInfo\\b" core modules settings | grep -v Compat.lua
  ```
- [ ] **Step 2 (verify).**
  - `luacheck` returns 0 errors.
  - The `find … wc -l` block returns 0 lines.
  - The grep returns 0 lines.
- [ ] **Step 3.** No commit (audit-only).

### M10.4 — Final commit + tag

- [ ] **Files:** working tree
- [ ] **Step 1.** Confirm `git status` is clean. `git tag v1.2.0 -m "KickCD 1.2.0 — standards remediation"`.
- [ ] **Step 2 (verify).** `git log --oneline -20` shows the M1-M9 commits in order; `git tag --list` includes `v1.2.0`.
- [ ] **Step 3.** Done.

**Checkpoint:** M10 complete — KickCD on `1.2.0`, fully standards-compliant per `WowAddonStandards/03_STANDARDS.md`.

---

**End of EXECUTION_PLAN_KickCD.md.**
