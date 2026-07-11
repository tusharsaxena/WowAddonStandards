# AbsorbTracker Remediation — Execution Plan

> For agentic workers: tasks use `- [ ]` checkboxes. Use the superpowers:executing-plans skill or subagent-driven-development to run.

**Goal:** Bring AbsorbTracker to full standards compliance with `/mnt/d/Profile/Users/Tushar/Documents/GIT/_standards/2026-05-03/03_STANDARDS.md` v1.0 and ship as v1.9.0, addressing deviations AT-1..AT-11 from `04_DEVIATIONS.md`.

**Architecture:** AbsorbTracker stays Tier 1 (flat). New top-level files: `Compat.lua`, `Locale.lua`, `.pkgmeta`, `.luacheckrc`. `Panel/` subfolder is renamed to `panel/`. `Utils.lua` debug seam moves to a SV-persistent flag. Slash registers via AceConsole. Vendored libs (`libs/`) leave git tree in favour of `.pkgmeta` externals. See `TECHNICAL_DESIGN_AbsorbTracker.md` for full rationale.

**Source path:** /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker

**Standard references:** `03_STANDARDS.md §1.1` (Tier 1 layout), `§2.1` (TOC), `§3.3` (externals), `§7.1` (AceConsole), `§8.1` (Locale), `§11` (Compat), `§12` (Debug seam), `§13` (.pkgmeta), `§14` (.luacheckrc), `§15` (Docs), `§17` (Versioning).

---

## M1 — Tooling baseline (AT-1, AT-2, AT-3)

Three blockers in parallel — get the addon to "compliant TOC + tooling" before any code change.

### Task 1.1 — Create `.pkgmeta` (AT-1, §13)

- [ ] **Files:** create `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/.pkgmeta`
- [ ] **Step 1 — write the file** with this exact content:

```yaml
package-as: AbsorbTracker

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
  libs/AceGUI-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0
    tag: latest
  libs/AceConfig-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0
    tag: latest
  libs/AceConsole-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0
    tag: latest
  libs/AceEvent-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0
    tag: latest
  libs/AceTimer-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceTimer-3.0
    tag: latest
  libs/AceDBOptions-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0
    tag: latest
  libs/LibSharedMedia-3.0:
    url: https://repos.wowace.com/wow/libsharedmedia-3-0/trunk/LibSharedMedia-3.0
    tag: latest
  libs/AceGUI-3.0-SharedMediaWidgets:
    url: https://repos.wowace.com/wow/ace-gui-3-0-sharedmediawidgets/trunk/AceGUI-3.0-SharedMediaWidgets
    tag: latest

ignore:
  - .luacheckrc
  - reviews
  - docs/internal
  - _dev
  - "*.bak"
```

- [ ] **Step 2 — verify:** `test -f /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/.pkgmeta && grep -c '^  libs/' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/.pkgmeta` — expected output: `12`.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add .pkgmeta
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-1: add .pkgmeta with Ace3 + LSM externals (standards §13)"
```

### Task 1.2 — Create `.luacheckrc` (AT-2, §14)

- [ ] **Files:** create `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/.luacheckrc`
- [ ] **Step 1 — write the file** with this exact content:

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "reviews/", "_dev/" }
ignore = {
    "212/self",
    "212/event",
}
read_globals = {
    "_G", "LibStub", "CreateFrame", "GetTime", "UnitName", "UnitGUID",
    "GetSpellInfo", "C_Spell", "C_AddOns", "GetAddOnMetadata",
    "C_SpecializationInfo", "GetSpecialization",
    "InCombatLockdown", "PlaySound", "GetLocale",
    "Settings", "SettingsPanel", "InterfaceOptionsFrame_OpenToCategory",
    "C_Timer", "hooksecurefunc", "CreateColor",
    "UIParent", "WorldFrame",
    "UnitGetTotalAbsorbs", "UnitHealthMax", "AbbreviateNumbers",
    "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC",
    "BackdropTemplateMixin",
    "StaticPopup_Show", "StaticPopupDialogs",
    "format",
}
globals = {
    "AbsorbTrackerDB",
    "SLASH_ABSORBTRACKER1",
    "SLASH_ABSORBTRACKER2",
    "AbsorbTrackerFrame",
    "SlashCmdList",
}
```

- [ ] **Step 2 — verify (manual smoke test):** if `luacheck` is installed, run `cd /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker && luacheck . --no-color` and expect a small list of unused-arg warnings only — no `undefined global` errors. If errors remain, add the missing global to `read_globals` and re-run.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add .luacheckrc
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-2: add .luacheckrc baseline (standards §14)"
```

### Task 1.3 — Add X-IDs and IconTexture casing to TOC (AT-3, §2.1)

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc` lines 1-11.
- [ ] **Step 1 — replace lines 1-11** of the TOC. Current content of lines 1-11:

```
## Interface: 120000,120001,120005
## Title: Ka0s Absorb Tracker
## Notes: Display your total absorb shield value in a clean, customizable bar interface.
## Author: add1kted2ka0s
## Version: 1.8.0
## iconTexture: 512902
## SavedVariables: AbsorbTrackerDB
## OptionalDeps: LibStub, CallbackHandler-1.0, Ace3, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: Combat
## X-License: MIT
```

Replace with (note: version stays 1.8.0 here — bumped in M6):

```
## Interface: 120000, 120001, 120005
## Title: Ka0s Absorb Tracker
## Notes: Display your total absorb shield value in a clean, customizable bar interface.
## Author: add1kted2ka0s
## Version: 1.8.0
## IconTexture: 512902
## SavedVariables: AbsorbTrackerDB
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: Combat
## X-License: MIT
## X-Curse-Project-ID: 0
## X-Wago-ID: 0
```

- [ ] **Step 2 — verify:**
```bash
grep -E '^## X-(Curse-Project|Wago)-ID:' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc
```
Expected: two lines printed (`## X-Curse-Project-ID: 0` and `## X-Wago-ID: 0`).
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add AbsorbTracker.toc
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-3: TOC adds X-Curse-Project-ID / X-Wago-ID, normalize IconTexture (standards §2.1)"
```

### Checkpoint 1

- [ ] **Stop and let user verify before proceeding to M2.** Confirm `.pkgmeta`, `.luacheckrc`, and the TOC X-IDs are in place; addon still loads in a 12.0.5 client without errors (`/console reloadui`).

---

## M2 — Compat + Locale + Persistent debug (AT-7, AT-8, AT-6)

### Task 2.1 — Create `Compat.lua` (AT-8, §11)

- [ ] **Files:** create `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Compat.lua`. Edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc`.
- [ ] **Step 1a — write** `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Compat.lua`:

```lua
-- AbsorbTracker: Compat.lua — deprecated-API shim point.
-- Currently no deprecated calls in the addon. This file exists per
-- standards §11 so the next API deprecation has a single home.
local AddonName, AddonTable = ...

AddonTable.Compat = AddonTable.Compat or {}
local Compat = AddonTable.Compat

Compat.IsRetail  = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Compat.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

-- Future shim example (not currently called):
-- function Compat.GetSpellInfo(id)
--     if C_Spell and C_Spell.GetSpellInfo then
--         local info = C_Spell.GetSpellInfo(id)
--         if info then return info.name, nil, info.iconID end
--     end
--     return GetSpellInfo and GetSpellInfo(id)
-- end
```

- [ ] **Step 1b — edit TOC** to insert `Compat.lua` immediately before `Core.lua`. After the edit, lines 25-28 of the TOC must read exactly:

```
Compat.lua
Core.lua
Utils.lua
LSMPatch.lua
```

(insert `Compat.lua` as the first .lua line in the load section, ahead of `Core.lua`).

- [ ] **Step 2 — verify (manual smoke test):** load addon in 12.0.5 client; `/run print(AbsorbTracker_NS or "ok")` — addon loads without error. `/run local _,t = ...; print(t)` won't work directly; use `/dump AbsorbTrackerDB` or open `/at config` to confirm load.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add Compat.lua AbsorbTracker.toc
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-8: add Compat.lua scaffold + TOC entry (standards §11)"
```

### Task 2.2 — Create `Locale.lua` (AT-6, §8.1)

- [ ] **Files:** create `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Locale.lua`. Edit `AbsorbTracker.toc`. Edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Options/General.lua`.
- [ ] **Step 1a — write** `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Locale.lua`:

```lua
-- AbsorbTracker: Locale.lua — string table with metatable fallback.
-- §8.1: missing-key fallback yields the English source string (key = string).
-- Ka0s ships English-only today; this file is the seam for any future locale.
local AddonName, AddonTable = ...

AddonTable.L = setmetatable({}, { __index = function(_, k) return k end })
local L = AddonTable.L

-- StaticPopup strings (Options/General.lua)
L["Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone."] = "Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone."
L["Yes"] = "Yes"
L["No"]  = "No"

-- Slash messages (SlashCommands.lua) — minimum coverage.
L["Bar locked"]                           = "Bar locked"
L["Bar unlocked"]                         = "Bar unlocked"
L["Hidden"]                               = "Hidden"
L["Shown"]                                = "Shown"
L["Forced refresh"]                       = "Forced refresh"
L["All settings reset to defaults"]       = "All settings reset to defaults"
L["All settings reset to defaults."]      = "All settings reset to defaults."
L["Bar position reset"]                   = "Bar position reset"
L["Profile reset to defaults"]            = "Profile reset to defaults"
L["Cannot delete the current profile"]    = "Cannot delete the current profile"
L["Profile system requires AceDB-3.0"]    = "Profile system requires AceDB-3.0"
L["Cannot open settings panel during combat. Try again after combat ends."] = "Cannot open settings panel during combat. Try again after combat ends."
L["AceGUI-3.0 not available; settings panel unavailable."] = "AceGUI-3.0 not available; settings panel unavailable."
L["No settings registered yet"]           = "No settings registered yet"
L["Available settings:"]                  = "Available settings:"
L["Available profiles:"]                  = "Available profiles:"
L["Profile commands:"]                    = "Profile commands:"
```

- [ ] **Step 1b — edit TOC** to insert `Locale.lua` between `Core.lua` and `Utils.lua`. After this edit lines 25-29 must read:

```
Compat.lua
Core.lua
Locale.lua
Utils.lua
LSMPatch.lua
```

- [ ] **Step 1c — edit `Options/General.lua`** StaticPopup at line 68. Find this block:

```lua
StaticPopupDialogs["ABSORBTRACKER_RESET_ALL"] = {
    text         = "Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone.",
    button1      = "Yes",
    button2      = "No",
```

Replace with (also add the `local L` line near the top of the file, after `local AddonName, AddonTable = ...`):

```lua
local L = AddonTable.L
StaticPopupDialogs["ABSORBTRACKER_RESET_ALL"] = {
    text         = L["Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone."],
    button1      = L["Yes"],
    button2      = L["No"],
```

(If a `local L = AddonTable.L` already exists in the file from a prior edit, don't add a second one.)

- [ ] **Step 2 — verify (manual smoke test):** load addon, run `/at resetall` → click the dialog. Confirm popup text is identical to current behaviour. Pick "No" to abort. Confirm chat sees no errors.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add Locale.lua AbsorbTracker.toc Options/General.lua
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-6: add Locale.lua with metatable fallback; wire reset-all popup (standards §8.1)"
```

### Task 2.3 — Persistent `/at debug` (AT-7, §12)

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Core.lua`, `Utils.lua`, `Events.lua`, `SlashCommands.lua`.
- [ ] **Step 1a — edit `Core.lua`.** Replace the entire `AddonTable.defaults = { ... }` block (lines 10-32) with:

```lua
AddonTable.defaults = {
    profile = {
        barTexture = "Blizzard Raid Bar",
        bgTexture = "Blizzard Raid Bar",
        border = "Blizzard Tooltip",
        borderSize = 12,
        borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
        font = "Friz Quadrata TT",
        fontSize = 12,
        fontFlags = "OUTLINE",
        barWidth = 200,
        barHeight = 20,
        barColor = { r = 0.4, g = 0.7, b = 1.0, a = 0.8 },
        bgColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.8 },
        useClassColorBar = false,
        useClassColorBg = false,
        useClassColorBorder = false,
        locked = false,
        hidden = false,
        updateInterval = 1.0,
        position = nil,
    },
    global = {
        schemaVersion = 1,
        debug = false,
    },
}

function AddonTable.RunMigrations()
    local g = AddonTable.db and AddonTable.db.global
    if not g then return end
    g.schemaVersion = g.schemaVersion or 1
    -- if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
end
```

(The `flatDefaults = AddonTable.defaults.profile` line at the bottom of `Core.lua:35` stays as-is.)

- [ ] **Step 1b — replace the entire contents** of `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Utils.lua` with:

```lua
-- AbsorbTracker: Utils module - Debug functions and helpers
local AddonName, AddonTable = ...

-- In-memory mirror of the persistent debug flag. Hot-path readers
-- (Display.lua per-tick) check this directly to keep the gate
-- zero-allocation. SetDebug keeps the mirror and the SV in sync.
AddonTable.DEBUG = false

-- Every chat message from the addon goes through this helper so it gets the cyan [AT] prefix.
local PREFIX = "|cFF00FFFF[AT]|r"
function AddonTable.Print(...)
    print(PREFIX, ...)
end

local print = AddonTable.Print

local function isDebugOn()
    local db = AddonTable.db
    if db and db.global and db.global.debug ~= nil then
        return db.global.debug
    end
    return AddonTable.DEBUG
end

function AddonTable.IsDebug() return isDebugOn() end

function AddonTable.SetDebug(on)
    AddonTable.DEBUG = on and true or false
    local db = AddonTable.db
    if db and db.global then
        db.global.debug = AddonTable.DEBUG
    end
end

function AddonTable.DebugPrint(...)
    if isDebugOn() then
        print(...)
    end
end
```

- [ ] **Step 1c — edit `Events.lua`.** Inside the `PLAYER_LOGIN` branch, after `AddonTable.db = AceDB:New("AbsorbTrackerDB", defaults, true)` (line 40), add hydration. Replace lines 36-65 with:

```lua
    if event == "PLAYER_LOGIN" then
        -- Initialize AceDB if available
        if LibStub then
            local AceDB = LibStub("AceDB-3.0", true)
            if AceDB then
                AddonTable.db = AceDB:New("AbsorbTrackerDB", defaults, true)
                AddonTable.db.RegisterCallback(AddonTable, "OnProfileChanged", AddonTable.OnProfileChanged)
                AddonTable.db.RegisterCallback(AddonTable, "OnProfileCopied", AddonTable.OnProfileChanged)
                AddonTable.db.RegisterCallback(AddonTable, "OnProfileReset", AddonTable.OnProfileChanged)
                if AddonTable.RunMigrations then AddonTable.RunMigrations() end
                AddonTable.DEBUG = AddonTable.db.global and AddonTable.db.global.debug == true
            end
        end
        -- Fallback if AceDB not available
        if not AddonTable.db then
            AbsorbTrackerDB = AbsorbTrackerDB or {}
            -- Create a minimal db-like structure for compatibility
            AddonTable.db = { profile = AbsorbTrackerDB, global = AbsorbTrackerDB.__global or {} }
            AbsorbTrackerDB.__global = AddonTable.db.global
            AddonTable.db.global.schemaVersion = AddonTable.db.global.schemaVersion or 1
            if AddonTable.db.global.debug == nil then AddonTable.db.global.debug = false end
            AddonTable.DEBUG = AddonTable.db.global.debug == true
            -- Migrate old flat settings to profile if needed.
            -- Deep-copy table defaults so an in-place mutation of a saved
            -- variable can't reach back and corrupt flatDefaults.
            for key, defaultVal in pairs(flatDefaults) do
                if AddonTable.db.profile[key] == nil then
                    if type(defaultVal) == "table" then
                        local copy = {}
                        for k, v in pairs(defaultVal) do copy[k] = v end
                        AddonTable.db.profile[key] = copy
                    else
                        AddonTable.db.profile[key] = defaultVal
                    end
                end
            end
        end
```

(Lines 66 onward — `ClearLSMCache()`, etc. — stay unchanged.)

- [ ] **Step 1d — edit `SlashCommands.lua` `runDebug`** (lines 224-227). Replace the function body:

```lua
function runDebug()
    AddonTable.SetDebug(not AddonTable.IsDebug())
    print("Debug mode " .. (AddonTable.IsDebug() and "ENABLED" or "DISABLED"))
end
```

- [ ] **Step 2 — verify (manual smoke test):**
  1. `/at debug` → chat shows "Debug mode ENABLED".
  2. `/reload`.
  3. `/at update` (forces a refresh and any subsequent absorb event will fire `DebugPrint`); take damage to a target dummy and observe `[AT] UNIT_ABSORB_AMOUNT_CHANGED - <n>` in chat — proving the flag survived reload.
  4. `/at debug` → "DISABLED". `/reload`. Verify no DebugPrint output.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add Core.lua Utils.lua Events.lua SlashCommands.lua
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-7: persist /at debug flag in db.global.debug; add schemaVersion + migration stub (standards §12, §5.1)"
```

### Checkpoint 2

- [ ] **Stop and let user verify before proceeding to M3.** Confirm in-game: `/at debug` survives `/reload`. Reset-all popup still displays correctly. Addon loads cleanly.

---

## M3 — Slash to AceConsole (AT-5)

### Task 3.1 — Add AceConsole-3.0 to TOC libs

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc`.
- [ ] **Step 1 — insert AceConsole** in the `#@no-lib-strip@` block right after the `AceGUI-3.0` line. After edit, the block (originally lines 13-23) reads:

```
#@no-lib-strip@
libs\LibStub-1.0\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.xml
libs\Ace3\AceAddon-3.0\AceAddon-3.0.xml
libs\Ace3\AceDB-3.0\AceDB-3.0.xml
libs\Ace3\AceGUI-3.0\AceGUI-3.0.xml
libs\Ace3\AceConsole-3.0\AceConsole-3.0.xml
libs\Ace3\AceConfig-3.0\AceConfig-3.0.xml
libs\Ace3\AceDBOptions-3.0\AceDBOptions-3.0.xml
libs\LibSharedMedia-3.0\lib.xml
libs\Ace3\AceGUI-3.0-SharedMediaWidgets\widget.xml
#@end-no-lib-strip@
```

- [ ] **Step 2 — verify:** `grep -c 'AceConsole-3.0' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc` returns `1`.
- [ ] **Step 3 — commit (deferred to 3.2 — combined commit).**

### Task 3.2 — Migrate slash registration to AceConsole

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/SlashCommands.lua`.
- [ ] **Step 1 — replace lines 334-355** (the `SLASH_ABSORBTRACKER1` block + dispatcher) with this exact block:

```lua
local function dispatch(msg)
    local raw = (msg or ""):match("^%s*(.-)%s*$") or ""
    if raw == "" then return printHelp() end

    -- Lowercase only the command name; preserve case in `rest` so
    -- schema paths like `barTexture` survive `/at set ...`.
    local cmd, rest = raw:match("^(%S+)%s*(.*)$")
    cmd  = (cmd or ""):lower()
    rest = rest or ""

    -- Backward-compat alias: `/at options` -> `/at config`.
    if cmd == "options" then cmd = "config" end

    local entry = findCommand(cmd)
    if entry then return entry[3](rest) end

    print("Unknown command '" .. cmd .. "'")
    printHelp()
end

AddonTable.OnSlash = dispatch

local AceConsole = LibStub and LibStub("AceConsole-3.0", true)
if AceConsole then
    -- AceConsole:Embed gives AddonTable :RegisterChatCommand.
    AceConsole:Embed(AddonTable)
    AddonTable:RegisterChatCommand("at", dispatch)
    AddonTable:RegisterChatCommand("absorbtracker", dispatch)
else
    -- Soft fallback: keep raw SLASH_* registration if AceConsole missing.
    SLASH_ABSORBTRACKER1 = "/absorbtracker"
    SLASH_ABSORBTRACKER2 = "/at"
    SlashCmdList["ABSORBTRACKER"] = dispatch
end
```

- [ ] **Step 2 — verify (manual smoke test):**
  1. `/reload`.
  2. `/at help` — full help block prints.
  3. `/absorbtracker help` — same block.
  4. `/at config` — panel opens.
  5. `/at set barWidth 250` — bar resizes.
  6. `/at options` — panel opens (alias preserved).
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add SlashCommands.lua AbsorbTracker.toc
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-5: register slashes via AceConsole-3.0 with soft fallback (standards §7.1)"
```

### Checkpoint 3

- [ ] **Stop and let user verify before proceeding to M4.** Confirm both `/at` and `/absorbtracker` slashes work; help block, set, get, list, reset, profile, debug all behave per docs. No `Lua error: AceConsole...` in client.

---

## M4 — Lib cleanup (AT-4)

### Task 4.1 — Remove `libs/` from version control

- [ ] **Files:** delete `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/libs` from the git index. Edit `.gitignore`.
- [ ] **Step 1a — git remove libs/ tracked-files only** (do not rm from disk yet — keep them for live test):
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker rm -r --cached libs
```
- [ ] **Step 1b — append `libs/` to `.gitignore`.** Open `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/.gitignore` and append a new line:
```
libs/
```
- [ ] **Step 2 — verify:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker ls-files libs | wc -l
```
Expected: `0`. The `libs/` directory still exists on disk (untracked); the addon still loads via the existing TOC `libs\...` references.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add .gitignore
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-4: remove vendored libs/ from version control; rely on .pkgmeta externals (standards §3.3)"
```

### Task 4.2 — Document developer workflow in CLAUDE.md

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md`.
- [ ] **Step 1 — find the "Working environment" section** (lines starting with `## Working environment`). Find the bullet `- **Bundled libs in \`libs/\`.** ...` and replace it with:

```markdown
- **External libs via `.pkgmeta`.** Per standards §3.3 the Ace3 stack and LibSharedMedia-3.0 are declared as `externals:` in `.pkgmeta` and are no longer committed to git. Release zips are built by the BigWigs Packager (`packager -dlz`), which fetches and embeds libs at build time. For local-developer ad-hoc testing of the working tree directly inside `World of Warcraft/_retail_/Interface/AddOns/AbsorbTracker/`, copy a `libs/` folder from a prior release zip alongside the working tree (the directory is `.gitignore`d and the TOC's `#@no-lib-strip@` block loads from it).
```

- [ ] **Step 2 — verify:** `grep -c 'External libs' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md` returns `1`.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add CLAUDE.md
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-4: CLAUDE.md documents .pkgmeta externals + developer workflow"
```

### Checkpoint 4

- [ ] **Stop and let user verify before proceeding to M5.** Confirm `git ls-files AbsorbTracker/libs` is empty; addon still loads in-game (libs/ remains on disk untracked). User must run BigWigs Packager to validate release zip; that's deferred to M6 release prep.

---

## M5 — Per-addon polish (AT-9, AT-11, partial AT-10)

### Task 5.1 — ScrollPatch shape guard (AT-9)

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Panel/ScrollPatch.lua` (still PascalCase at this milestone — rename happens in 5.2).
- [ ] **Step 1 — replace the function head** of `Helpers.PatchAlwaysShowScrollbar` (lines 20-22) so the file's first function block becomes:

```lua
function Helpers.PatchAlwaysShowScrollbar(scroll)
    if not scroll or scroll._atAlwaysScrollbar then return end

    -- AceGUI ScrollFrame internal-shape sniff. The patch reaches into
    -- scroll.scrollbar / .scrollframe / .content / .FixScroll. If a
    -- future AceGUI release renames any of these, we bail out and leave
    -- the stock auto-hide behavior rather than crashing.
    local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
    local minor  = AceGUI and AceGUI.WidgetVersions and AceGUI.WidgetVersions["ScrollFrame"]
    local shapeOK =
        type(scroll.scrollbar)   == "table" and
        type(scroll.scrollframe) == "table" and
        type(scroll.content)     == "table" and
        type(scroll.FixScroll)   == "function"

    if not shapeOK then
        if not Helpers._scrollPatchWarned then
            Helpers._scrollPatchWarned = true
            local msg = "AbsorbTracker: ScrollPatch disabled (AceGUI ScrollFrame internals shape mismatch"
            if minor then msg = msg .. ", widget version " .. tostring(minor) end
            msg = msg .. "); falling back to stock scrollbar behavior."
            print(msg)
        end
        return
    end

    scroll._atAlwaysScrollbar = true
```

(Everything from `local origFixScroll = scroll.FixScroll` down to end of the function stays unchanged. Note the original `scroll._atAlwaysScrollbar = true` line at line 22 is now placed **after** the shape check — previously it set the flag before any work; now it sets it only when we proceed.)

- [ ] **Step 2 — verify (manual smoke test):**
  1. `/reload`.
  2. `/at config` — panel opens, scrollbar visible on every sub-page (General, Bar, Border, Font).
  3. No new chat warning printed (shape is OK).
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add Panel/ScrollPatch.lua
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-9: ScrollPatch shape-sniff guard with one-shot warning (standards §3.5 spirit)"
```

### Task 5.2 — Rename `Panel/` → `panel/` step 1 (transitional name)

- [ ] **Files:** rename `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Panel` to `_panel_` via `git mv`.
- [ ] **Step 1 — close WoW client first** to avoid file-locking on Windows. Then run:
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker mv Panel _panel_
```
- [ ] **Step 2 — verify:**
```bash
ls /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/_panel_ && test ! -d /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/Panel && echo OK
```
Expected: four files listed, then `OK`.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-11: rename Panel/ -> _panel_/ (case-rename step 1 of 2)"
```

### Task 5.3 — Rename `_panel_/` → `panel/` step 2 (final lowercase)

- [ ] **Files:** rename `_panel_` to `panel`. Edit TOC.
- [ ] **Step 1a — git mv:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker mv _panel_ panel
```
- [ ] **Step 1b — edit `AbsorbTracker.toc`** lines that reference `Panel\`. Replace each of the four lines:
```
Panel\Helpers.lua
Panel\ScrollPatch.lua
Panel\Widgets.lua
Panel\About.lua
```
with:
```
panel\Helpers.lua
panel\ScrollPatch.lua
panel\Widgets.lua
panel\About.lua
```
- [ ] **Step 2 — verify:**
```bash
ls /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/panel | wc -l
```
Expected: `4`. And:
```bash
grep -c '^panel\\' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc
```
Expected: `4`. And:
```bash
grep -c '^Panel\\' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc
```
Expected: `0`.
- [ ] **Step 3 — manual smoke test:** restart WoW client (not just `/reload` — folder cache). Verify addon loads, panel opens, scrollbar still visible.
- [ ] **Step 4 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add AbsorbTracker.toc panel
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-11: rename _panel_/ -> panel/ (case-rename step 2); update TOC paths (standards §1.3)"
```

### Checkpoint 5

- [ ] **Stop and let user verify before proceeding to M6.** Confirm `panel/` directory is lowercase on disk; TOC references `panel\`; addon loads in-game with full panel functionality.

---

## M6 — Release prep

### Task 6.1 — Bump version to 1.9.0

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc`. Edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/README.md`.
- [ ] **Step 1a — TOC.** Change `## Version: 1.8.0` to `## Version: 1.9.0`.
- [ ] **Step 1b — README badge.** Find `1.8.0` in the README badge area (typically near the top within a `![Version](...)` shield URL or a plain version line); replace with `1.9.0`.
- [ ] **Step 1c — README Version History table.** Add a new row at the top of the Version History table:
```
| 1.9.0 | Standards-compliance pass: .pkgmeta + .luacheckrc, AceConsole slash, persistent /at debug, Compat.lua + Locale.lua scaffolds, panel/ folder rename, ScrollPatch shape guard. |
```
(Match the existing column structure of that table; if it has more columns like a date column, add the date `2026-05-03`.)
- [ ] **Step 2 — verify:**
```bash
grep -F '## Version: 1.9.0' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/AbsorbTracker.toc && grep -c '1\.9\.0' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/README.md
```
Expected: TOC line printed; README count ≥2 (badge + history row).
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add AbsorbTracker.toc README.md
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AbsorbTracker 1.9.0: standards-compliance release (AT-1..AT-11)"
```

### Task 6.2 — Sync ARCHITECTURE.md (AT-10)

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/ARCHITECTURE.md`.
- [ ] **Step 1 — update file map.** Find any section listing top-level Lua files / folder layout. Add `Compat.lua`, `Locale.lua` to the file list. Change `Panel/` references to `panel/`. Find the "Bundled libs" subsection and rename / rewrite it to "External libs (declared in `.pkgmeta`)" listing the 12 externals. Add a brief note: "Persistent debug flag lives at `db.global.debug`; toggled by `/at debug` (Utils.lua: `IsDebug` / `SetDebug`)."
- [ ] **Step 2 — verify:**
```bash
grep -F 'Compat.lua' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/ARCHITECTURE.md && grep -F 'Locale.lua' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/ARCHITECTURE.md && grep -cF 'panel/' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/ARCHITECTURE.md
```
Expected: both greps print a line; the count is ≥1.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add ARCHITECTURE.md
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-10: ARCHITECTURE.md sync — Compat/Locale/panel/.pkgmeta + persistent debug (standards §15)"
```

### Task 6.3 — Sync CLAUDE.md (AT-10 continued)

- [ ] **Files:** edit `/mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md`.
- [ ] **Step 1 — additions:**
  1. In the "What this addon is" section, append: `Layout tier: **Tier 1 (flat)** per standards §1.1.`
  2. In "Hard rules", append a bullet: `- **Persistent debug flag.** \`/at debug\` toggles \`AddonTable.db.global.debug\` (Utils.lua \`SetDebug\` / \`IsDebug\`). The in-memory mirror \`AddonTable.DEBUG\` is what the per-tick gate in Display.lua reads; \`SetDebug\` keeps the mirror and the SV in sync. Don't read the SV from the hot path.`
  3. In "Hard rules", append: `- **Locale lookup via \`AddonTable.L\`.** \`Locale.lua\` exports \`L\` with a metatable that returns the key on miss; new user-facing strings should pass through \`L["..."]\` so future locales just override the key. Don't introduce hardcoded user-facing strings.`
- [ ] **Step 2 — verify:**
```bash
grep -F 'Tier 1' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md && grep -F 'AddonTable.L' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md && grep -F 'db.global.debug' /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker/CLAUDE.md
```
Expected: three lines printed.
- [ ] **Step 3 — commit:**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker add CLAUDE.md
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -m "AT-10: CLAUDE.md sync — Tier 1, persistent debug, locale lookup (standards §15)"
```

### Task 6.4 — Final smoke test

- [ ] **Files:** none modified. Manual in-game pass.
- [ ] **Step 1 — manual smoke test on a 12.0.5 client:**
  1. Start client with a clean `WTF/Account/.../SavedVariables/AbsorbTracker.lua` (or a backup of an existing 1.8 SV — backwards compat check).
  2. Verify `AbsorbTrackerDB` loads without errors.
  3. `/at help` — full help.
  4. `/at config` — panel opens; scrollbar visible on every sub-page.
  5. `/at set barWidth 250` — bar resizes; `/at get barWidth` → `250`.
  6. `/at debug` → "ENABLED". `/reload`. Take damage, see DebugPrint output. `/at debug` → "DISABLED".
  7. `/at resetall` → popup with text "Reset every General, Bar, Border, and Font...". Click Yes; chat reports `[AT] All settings reset to defaults.`.
  8. `/at profile list` → at least one profile.
  9. Combat lockdown gate: enter combat, `/at config` → chat refuses with the combat message.
  10. `/run print(_G.AbsorbTrackerFrame:GetName())` → `AbsorbTrackerFrame`.
- [ ] **Step 2 — verify acceptance criteria checklist** at end of `TECHNICAL_DESIGN_AbsorbTracker.md` §7. Tick each.
- [ ] **Step 3 — commit (only if any docs were touched during smoke test):**
```bash
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker status
# If nothing changed, skip. Otherwise:
git -C /mnt/d/Profile/Users/Tushar/Documents/GIT/AbsorbTracker commit -am "AbsorbTracker 1.9.0: post-smoke-test fixups"
```

### Checkpoint 6 — Done

- [ ] **Stop. Hand back to user.** Report: AT-1..AT-11 closed. Version 1.9.0 ready. Release zip is built by user via BigWigs Packager (out of scope for this plan). User authorizes any `git push`.
