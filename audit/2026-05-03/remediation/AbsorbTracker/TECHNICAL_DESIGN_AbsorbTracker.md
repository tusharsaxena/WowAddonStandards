# AbsorbTracker — Technical Design (HLD + LLD)

> Companion to `EXECUTION_PLAN_AbsorbTracker.md`. Source standard: `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards/standards/01_STANDARD.md`. Source deviation report: `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards/audit/2026-05-03/03_DEVIATIONS.md` (rows AT-1..AT-11). Raw evidence: `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards/audit/2026-05-03/_raw/AbsorbTracker.md`.

## 1. Goal

Bring AbsorbTracker to full compliance with `01_STANDARD.md` v1.0 (2026-05-03) — Tier 1 (flat) — without behavior changes, shipping at v1.9.0.

## 2. Scope

**In scope (deviation IDs):** AT-1, AT-2, AT-3, AT-4, AT-5, AT-6, AT-7, AT-8, AT-9, AT-10, AT-11.

**Out of scope (deferred / not changed):**
- Bar visual behavior, ticker, painting, color resolution, secret-value handling (`Display.lua`, `Timer.lua`, `UI.lua`).
- Schema content (rows in `Options/*.lua`).
- Absorb computation (`UnitGetTotalAbsorbs` flow).
- Tier promotion (the addon stays Tier 1 flat — no `core/`, `modules/`, `defaults/`, `settings/`, `locales/` subfolders even after remediation; per §1.1 the only allowed Tier 1 subfolders are `libs/` and `media/`, and the existing `Options/` and `Panel/` are pre-existing peels that we preserve to avoid widescale churn — we only normalize their casing).
- AceAddon `:NewAddon` registration. Standard §4.2 says "any addon using Ace3 lifecycle"; AbsorbTracker uses AceDB only and the existing `AddonTable` bus is acceptable. Not migrating in this remediation. (`AddonTable` is the WoW-supplied per-addon vararg table; this is the canonical equivalent of `NS` from §4.1.)
- Schema migration runner (no schema change required for any of AT-1..AT-11; current `defaults` already in AceDB shape; no SV migration needed).

## 3. HLD — System view

### 3.1 Post-remediation file layout

```
AbsorbTracker/
  AbsorbTracker.toc
  .pkgmeta                          (NEW — AT-1)
  .luacheckrc                       (NEW — AT-2)
  Core.lua
  Compat.lua                        (NEW — AT-8)
  Locale.lua                        (NEW — AT-6)
  Utils.lua                         (modified — AT-7 persistent debug)
  LSMPatch.lua
  Settings.lua
  Schema.lua
  UI.lua
  Display.lua
  Timer.lua
  Events.lua
  SlashCommands.lua                 (modified — AT-5 AceConsole)
  OptionsPanel.lua
  panel/                            (RENAMED from Panel/ — AT-11)
    Helpers.lua
    ScrollPatch.lua                 (modified — AT-9 version guard)
    Widgets.lua
    About.lua
  Options/
    General.lua                     (modified — AT-6 popup uses L)
    Bar.lua
    Border.lua
    Font.lua
    Profiles.lua
  libs/                             (DELETED post-AT-4 — see §5.3)
  media/
  docs/
  reviews/
  README.md                         (touched — version 1.9.0 row, AT-10)
  ARCHITECTURE.md                   (touched — Compat/Locale/.pkgmeta sync, AT-10)
  CLAUDE.md                         (touched — same, AT-10)
  LICENSE
  .gitattributes
  .gitignore
```

### 3.2 Component responsibilities (post-remediation)

| File | Responsibility |
|------|----------------|
| `AbsorbTracker.toc` | Multi-Interface line; declarative file load order; X-Curse / X-Wago / X-WoWI IDs (AT-3). |
| `.pkgmeta` | Packager directives: externals for the 8 Ace3 libs + LibSharedMedia widgets; ignore `reviews/`, `docs/internal/`, `_dev/`, `*.bak`, `.luacheckrc` (AT-1). |
| `.luacheckrc` | Static lint config; `std="lua51"`, exclude `libs/` and `reviews/` (AT-2). |
| `Core.lua` | Defaults, math/format upvalues. Unchanged. |
| `Compat.lua` | Empty shim file that publishes `AddonTable.Compat = {}` with `IsRetail`/`IsClassic` flags. Loaded FIRST after no-strip block. (AT-8) |
| `Locale.lua` | Publishes `AddonTable.L` with metatable-fallback (returns key on miss); seeds at minimum the StaticPopup text + slash messages emitted today. (AT-6) |
| `Utils.lua` | `Print` + `DebugPrint` helpers; debug toggle now reads/writes `AddonTable.db.global.debug` with in-memory mirror. (AT-7) |
| `SlashCommands.lua` | AceConsole `:RegisterChatCommand` registration; same `AddonTable.SlashCommands` table; same dispatcher body. (AT-5) |
| `panel/ScrollPatch.lua` | Patch logic gated by AceGUI ScrollFrame internal-shape sniff; logs and no-ops on shape mismatch. (AT-9) |
| All other files | Unchanged from current state. |

### 3.3 Data flow (post-remediation)

```
[user types /at set ...]
        |
        v
SlashCmdList["ABSORBTRACKER"]  <-- registered via AceConsole:RegisterChatCommand("at"/"absorbtracker", handler) (AT-5)
        |
        v
SlashCommands handler -> findCommand(cmd) -> entry[3](rest)
        |
        v
AddonTable.SetByPath(path, value)   (Schema.lua — UNCHANGED single seam)
        |
        v
validate -> write db.profile[k] -> onChange()
        |
        +-- onChange repaints / restarts ticker / refreshes panel
        +-- AddonTable.RefreshOptionsPanel() walks ctx.refreshers
```

[user clicks AceGUI widget in panel] -> same `SetByPath` seam. Identical post-remediation. The addition of `Locale.lua` introduces only display-layer wrapping (`L["..."]`) at print/StaticPopup sites — no flow change. The persistent debug (AT-7) means `runDebug()` writes `AddonTable.db.global.debug` instead of in-memory `AddonTable.DEBUG` only.

### 3.4 New modules introduced

| Module | Status | Standard § | Why |
|--------|--------|-----------|-----|
| `Compat.lua` | NEW | §11 | Mandatory in every addon (even if no current deprecated calls). AT-8. |
| `Locale.lua` | NEW | §8.1 | Mandatory; AbsorbTracker has zero strings localized. AT-6. |
| `.pkgmeta` | NEW | §13 | Mandatory packaging file. AT-1. |
| `.luacheckrc` | NEW | §14 | Mandatory lint config. AT-2. |
| Persistent debug seam | EDIT to `Utils.lua` | §12 | "MUST gate via persistent SV flag." AT-7. |

## 4. LLD — Per-deviation design

Order: AT-3, AT-1, AT-2, AT-7, AT-5, AT-8, AT-4, AT-6, AT-9, AT-11, AT-10 (matches deviation-report sprint sequencing).

---

### AT-3 — TOC missing X-Curse-Project-ID / X-Wago-ID

**Standard:** §2.1 — "MUST have `X-Curse-Project-ID` and `X-Wago-ID` once an addon is published anywhere."

**Current state** (`AbsorbTracker.toc:1-11`):

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

Missing: `X-Curse-Project-ID`, `X-Wago-ID`, optional `X-WoWI-ID`. Also `## iconTexture:` should be `## IconTexture:` (proper case per §2.1 template).

**Target state:**

```
## Interface: 120000, 120001, 120005
## Title: Ka0s Absorb Tracker
## Notes: Display your total absorb shield value in a clean, customizable bar interface.
## Author: add1kted2ka0s
## Version: 1.9.0
## IconTexture: 512902
## SavedVariables: AbsorbTrackerDB
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: Combat
## X-License: MIT
## X-Curse-Project-ID: 0
## X-Wago-ID: 0
```

`X-Curse-Project-ID` / `X-Wago-ID` use placeholder `0` (the user supplies real IDs at publish time; the TOC field's presence is what the standard mandates). Comma-space on Interface line per §2.1 example.

**Migration steps:**
1. Edit `AbsorbTracker.toc` lines 1-11. Replace `## iconTexture:` with `## IconTexture:`. Add the two `X-*` IDs after `## X-License`.
2. Add the new file lines for `Compat.lua` (after no-strip block, before `Core.lua`) and `Locale.lua` (after `Core.lua`) per AT-8 / AT-6.
3. Update `Panel\` paths to `panel\` per AT-11.

**Risks / edge cases:** `X-Curse-Project-ID: 0` is harmless until the user wires real CurseForge project. WoW's TOC parser tolerates unknown `X-*` fields. The case correction (`iconTexture` → `IconTexture`) is cosmetic — Blizzard's parser is case-insensitive on TOC keys, but the standard names the canonical case in §2.1.

**Verification:** `grep -E '^## X-(Curse|Wago)' AbsorbTracker.toc` returns both lines.

---

### AT-1 — No `.pkgmeta`

**Standard:** §13. Reference: BigWigs `.pkgmeta`.

**Current state:** No `.pkgmeta` in addon root (verified at `_raw/AbsorbTracker.md` §14: "`.pkgmeta`: absent.").

**Target state:** Create `AbsorbTracker/.pkgmeta` with externals for every Ace3 lib in use and the LibSharedMedia stack. Note: `AceConfig-3.0` and `AceDBOptions-3.0` are kept (only legitimate use per §6.3 is the Profiles sub-page — which AbsorbTracker has, `Options/Profiles.lua:23-39`).

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

Includes `AceConsole-3.0`, `AceEvent-3.0`, `AceTimer-3.0` because the AceConsole migration in AT-5 introduces a hard dependency on AceConsole, and best-practice future-proofing covers AceEvent/AceTimer (they're already required by the Ace3 stack indirectly).

**Risks:** none — `.pkgmeta` is only consumed by the BigWigs/CurseForge packager. WoW client never reads it.

**Verification:** `test -f AbsorbTracker/.pkgmeta && grep -c '^  libs/' AbsorbTracker/.pkgmeta` returns ≥10.

---

### AT-2 — No `.luacheckrc`

**Standard:** §14. BigWigs base.

**Current state:** absent (`_raw/AbsorbTracker.md` §16).

**Target state:** Create `AbsorbTracker/.luacheckrc`:

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
    "SlashCmdList",
}
globals = {
    "AbsorbTrackerDB",
    "SLASH_ABSORBTRACKER1",  -- pre-AceConsole legacy; remove if AT-5 fully drops these
    "SLASH_ABSORBTRACKER2",
    "AbsorbTrackerFrame",    -- named CreateFrame in UI.lua
}
```

**Risks:** if any global is missing from the list, luacheck flags it as undefined. Easy to add as the list of warnings shows up.

**Verification:** `cd AbsorbTracker && luacheck .` returns exit 0 (or only acceptable warnings — see Acceptance Criteria).

---

### AT-7 — `/at debug` not persisted

**Standard:** §12 — "MUST gate via persistent SV flag (`NS.db.global.debug`)."

**Current state** (`Utils.lua:5` and `SlashCommands.lua:224-227`):

```lua
-- Utils.lua:5
AddonTable.DEBUG = false

-- SlashCommands.lua:224-227
function runDebug()
    AddonTable.DEBUG = not AddonTable.DEBUG
    print("Debug mode " .. (AddonTable.DEBUG and "ENABLED" or "DISABLED"))
end
```

`AddonTable.DEBUG` is a Lua local-to-runtime flag; resets to `false` every login.

**Target state:**

`Core.lua` — add a `global` scope with `debug` to defaults:

```lua
AddonTable.defaults = {
    profile = { ... unchanged ... },
    global  = {
        schemaVersion = 1,
        debug = false,
    },
}
```

`Utils.lua` — read SV-backed flag, fall back to in-memory mirror until DB ready:

```lua
local AddonName, AddonTable = ...

AddonTable.DEBUG = false

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

`SlashCommands.lua:224-227` — call setter:

```lua
function runDebug()
    AddonTable.SetDebug(not AddonTable.IsDebug())
    print("Debug mode " .. (AddonTable.IsDebug() and "ENABLED" or "DISABLED"))
end
```

`Events.lua` — after `AddonTable.db = AceDB:New(...)` succeeds, hydrate the in-memory mirror:

```lua
AddonTable.db = AceDB:New("AbsorbTrackerDB", defaults, true)
AddonTable.DEBUG = AddonTable.db.global.debug == true
```

Also hydrate at the bottom of the AceDB-missing fallback branch:

```lua
AddonTable.db.global = AddonTable.db.global or { schemaVersion = 1, debug = false }
AddonTable.DEBUG = AddonTable.db.global.debug == true
```

**Migration steps:**
1. Edit `Core.lua` to add `global` scope.
2. Edit `Utils.lua` per the block above.
3. Edit `SlashCommands.lua:runDebug` per the block above.
4. Edit `Events.lua` PLAYER_LOGIN branch + fallback branch to hydrate.

**Risks / edge cases:**
- Performance: `isDebugOn()` is one extra table-deref per `DebugPrint` call vs the current direct boolean read. The existing per-tick gate at `Display.lua:98-100` is `if AddonTable.DEBUG then ...` (direct boolean) — leaving that callsite using the cached `AddonTable.DEBUG` mirror keeps zero-allocation hot-path discipline (§12 "MUST be zero-allocation when off"). The `SetDebug` setter writes both the SV and the mirror, so the hot-path read stays a direct boolean.
- DB-not-ready: pre-`PLAYER_LOGIN` calls fall back to the in-memory mirror (defaults to `false`).

**Verification:** in-game, `/at debug` to enable, `/reload`. Issue a `/at update` — confirm `DebugPrint` output appears, proving the flag survived reload.

---

### AT-5 — Slash uses raw `SLASH_*`; should use AceConsole

**Standard:** §7.1 — "MUST use AceConsole-3.0 `:RegisterChatCommand`."

**Current state** (`SlashCommands.lua:334-355`):

```lua
SLASH_ABSORBTRACKER1 = "/absorbtracker"
SLASH_ABSORBTRACKER2 = "/at"

SlashCmdList["ABSORBTRACKER"] = function(msg)
    local raw = (msg or ""):match("^%s*(.-)%s*$") or ""
    if raw == "" then return printHelp() end
    local cmd, rest = raw:match("^(%S+)%s*(.*)$")
    cmd  = (cmd or ""):lower()
    rest = rest or ""
    if cmd == "options" then cmd = "config" end
    local entry = findCommand(cmd)
    if entry then return entry[3](rest) end
    print("Unknown command '" .. cmd .. "'")
    printHelp()
end
```

**Target state:** Replace lines 334-355 with AceConsole registration. Because AbsorbTracker does not use `AceAddon:NewAddon`, register on a tiny mixin embed:

```lua
local function dispatch(msg)
    local raw = (msg or ""):match("^%s*(.-)%s*$") or ""
    if raw == "" then return printHelp() end
    local cmd, rest = raw:match("^(%S+)%s*(.*)$")
    cmd  = (cmd or ""):lower()
    rest = rest or ""
    if cmd == "options" then cmd = "config" end
    local entry = findCommand(cmd)
    if entry then return entry[3](rest) end
    print("Unknown command '" .. cmd .. "'")
    printHelp()
end

AddonTable.OnSlash = dispatch

local AceConsole = LibStub and LibStub("AceConsole-3.0", true)
if AceConsole then
    -- AceConsole:Embed gives us :RegisterChatCommand on AddonTable.
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

**Migration steps:**
1. Replace lines 334-355 of `SlashCommands.lua` with the block above.

**Risks:**
- `AceConsole:RegisterChatCommand` requires AceConsole-3.0 lib to be loaded. The soft-fallback branch preserves backward behavior if the lib is absent (consistent with the addon's existing soft-fallback pattern, §2.1: "use OptionalDeps + soft fallback").
- AceConsole library file must be added to TOC. See AT-4 below.
- Existing `/options` alias preserved via the inline `if cmd == "options" then cmd = "config" end`.

**Verification:** in-game, `/at help`, `/absorbtracker help`, both produce the help block. `/at config` opens the panel.

---

### AT-8 — No `Compat.lua`

**Standard:** §11 — "Every addon **MUST** ship a `Compat.lua` … It is the **only** file that calls deprecated APIs."

**Current state:** No file. AbsorbTracker has no current deprecated-API calls (raw §13) — but the file must exist as a future shim point.

**Target state:** Create `AbsorbTracker/Compat.lua`:

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

Add to TOC immediately after no-strip block, before `Core.lua` (per Tier 2 ordering convention — Compat loads first; same applies in Tier 1 since Compat exposes `IsRetail`/`IsClassic` flags consumable elsewhere).

**Migration steps:**
1. Write `AbsorbTracker/Compat.lua`.
2. Insert `Compat.lua` line in TOC immediately before `Core.lua`.

**Risks:** none — `WOW_PROJECT_ID` and `WOW_PROJECT_MAINLINE` are stable globals available pre-PLAYER_LOGIN.

**Verification:** in-game, `/run print(AbsorbTrackerFrame and "loaded" or "no")` — confirms addon loads without error after Compat is added.

---

### AT-4 — Lib externals migration

**Standard:** §3.3 — "MUST declare Ace3 libs as `externals:` in `.pkgmeta`. MUST NOT commit them to git."

**Current state** (`_raw/AbsorbTracker.md` §4):
- All libs vendored in-tree under `libs/`, committed to git.
- Bundled: LibStub, CallbackHandler-1.0, LSM-3.0, AceAddon-3.0, AceDB-3.0, AceGUI-3.0, AceConfig-3.0, AceDBOptions-3.0, AceGUI-3.0-SharedMediaWidgets.
- AceAddon-3.0 is loaded but never `:NewAddon`d (carrier weight only).
- AceConfig + AceDBOptions used only by the Profiles sub-page (`Options/Profiles.lua`).
- TOC `#@no-lib-strip@` block (`AbsorbTracker.toc:13-23`) loads each lib via its `*.xml`.

**Target state:**
- `.pkgmeta` declares all of them as `externals:` (see AT-1 §4).
- `libs/` directory is **deleted from git**. The packager re-creates it at release-build time by fetching externals.
- TOC `#@no-lib-strip@` block stays — when the packager builds, it strips the block out and replaces it with packager-generated includes; when running directly from a working clone (developer mode), the block keeps loading from the not-stripped `libs/` folder.

Wait — if `libs/` is deleted from git, developer mode breaks. The standard's intent (§3.3) is that **release artifacts** ship lib externals; the working tree convention is up to the project. **Decision for AbsorbTracker:** per §3.3 "MUST NOT commit them to git." Remove `libs/` from version control (`git rm -r libs`). For local development, the packager command (`packager -dlz` per BigWigsMods convention) is the supported path; alternatively the developer copies a `libs/` from another addon for ad-hoc testing. This matches the BigWigs and DBM convention. Document the developer workflow in `CLAUDE.md`.

Additionally:
- Add `AceConsole-3.0` to externals (new dep from AT-5) and to TOC no-strip block:
  ```
  libs\Ace3\AceConsole-3.0\AceConsole-3.0.xml
  ```

**Migration steps:**
1. Confirm `.pkgmeta` exists from AT-1.
2. Add `AceConsole-3.0` to TOC no-strip block.
3. `git rm -r AbsorbTracker/libs`. Commit.
4. Update `.gitignore` to add `libs/` (so a developer who pulls libs locally for ad-hoc testing doesn't accidentally re-commit them).
5. Update `CLAUDE.md` "Working environment" section to document that libs are now externals.

**Risks:**
- Any developer pulling fresh post-commit will not be able to load the addon until they fetch libs. Mitigation: document the BigWigs Packager command in `CLAUDE.md`.
- Existing user installs (zipped from current release) keep working — they have the pre-1.9 vendored libs and the 1.9 release rebuilt by packager will ship libs again. This is purely about the **git tree**, not the **release zip**.
- `embeds.xml` is **not** used by AbsorbTracker (§2.4 — "SHOULD NOT use `embeds.xml` at Tier 1"). Continue to use the TOC no-strip block, not `embeds.xml`.

**Verification:** `git ls-files AbsorbTracker/libs | wc -l` returns 0. `.pkgmeta` validates with `yamllint .pkgmeta` (no errors).

---

### AT-6 — No locale module

**Standard:** §8.1 — "MUST export `NS.L` with a metatable that returns the key on miss."

**Current state:** No `Locale.lua`. Strings hardcoded in 20 files (raw §9). Highest-visibility user-facing strings:
- StaticPopup text at `Options/General.lua:69`: `"Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone."`
- StaticPopup buttons: `"Yes"`, `"No"`.
- Slash messages: `"Bar locked"`, `"Bar unlocked"`, `"Hidden"`, `"Shown"`, `"Forced refresh"`, `"All settings reset to defaults"`, etc. across `SlashCommands.lua`.
- Schema validator messages (`Schema.lua:191,195,200`).

**Target state:** Create `AbsorbTracker/Locale.lua`:

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

Wire the popup site (and at minimum, that one site is enough to fulfill the acceptance criterion):

`Options/General.lua:69` becomes:

```lua
local L = AddonTable.L
StaticPopupDialogs["ABSORBTRACKER_RESET_ALL"] = {
    text         = L["Reset every General, Bar, Border, and Font setting on this profile to defaults? Profiles are left alone."],
    button1      = L["Yes"],
    button2      = L["No"],
    ...
}
```

**Migration steps:**
1. Write `Locale.lua`.
2. Add `Locale.lua` to TOC after `Core.lua` and before `Utils.lua` (so `AddonTable.L` is available to all subsequent files).
3. Edit `Options/General.lua` StaticPopup site to read from `L`.
4. (Optional, deferred to a polish pass) wire the slash-message print sites.

**Risks:**
- Strings are loaded at file-load time; the metatable means a missing key returns the English source. So even if a wire site is missed, the runtime keeps working (the call site still passes through the literal key).

**Verification:** `grep -c '^L\["' AbsorbTracker/Locale.lua` returns ≥3. In-game `/at resetall` shows the StaticPopup with text identical to current.

---

### AT-9 — `Panel/ScrollPatch.lua` couples to AceGUI internals

**Standard:** §9.6 indirectly (frame/UI integrity); §3.5 "MUST NOT privately fork an Ace3 lib." This file isn't a fork but it does monkey-patch private fields. The deviation report flags fragility.

**Current state** (`Panel/ScrollPatch.lua:20-66`): patch reaches into `scroll.scrollbar`, `scroll.scrollframe`, `scroll.content.original_width`, `scroll.status`/`localstatus`, and replaces `FixScroll` / `MoveScroll` / `OnRelease` with no version guard.

**Target state:** Add a shape-sniff before applying the patch; if AceGUI's internal shape changes, log once and bail out (no-op) so the panel still renders (just without the always-visible-scrollbar override).

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
    -- ... rest unchanged ...
end
```

(`AceGUI.WidgetVersions["ScrollFrame"]` is a public field on AceGUI-3.0 since 2018; safe to query.)

**Migration steps:**
1. Insert the shape-sniff block at the top of `Helpers.PatchAlwaysShowScrollbar` after the early-exit guard.
2. Add a one-shot `Helpers._scrollPatchWarned` flag so the chat warning fires at most once per session.

**Risks / edge cases:**
- If AceGUI bumps ScrollFrame and renames `scrollframe` → `scrollFrame` (camelCase migration), `shapeOK` becomes false and the patch silently no-ops. User sees stock auto-hide scrollbar. Not ideal but non-fatal — exactly the safe-degradation §9.3 promotes.
- `LibStub` may not be loaded at `Helpers.lua` load time on some weird load orders — the `LibStub and ...` short-circuit handles that; `minor` ends up nil and the warning prints without a version number.

**Verification:** in-game, open the panel — scrollbar still always visible on a short page (current behavior). Force a shape mismatch by temporarily renaming `scroll.scrollbar` to `scroll.scrollbar2` in a dev build — confirm the panel still opens and a chat warning prints once.

---

### AT-11 — Folder rename `Panel/` → `panel/`

**Standard:** §1.3 — "Subfolders: **lowercase**."

**Current state:** `AbsorbTracker/Panel/` (PascalCase). Files: `Helpers.lua`, `ScrollPatch.lua`, `Widgets.lua`, `About.lua`. Referenced in `AbsorbTracker.toc:37-40` as `Panel\Helpers.lua` etc.

**Target state:** `AbsorbTracker/panel/` (lowercase) with the same four files. TOC paths updated to `panel\Helpers.lua` etc.

**Migration steps (Windows / WSL case-insensitive filesystem hazard):**

WSL on `/mnt/d` mounts an NTFS volume; NTFS is case-insensitive by default. A direct `git mv Panel panel` will be a no-op on disk (same inode after the OS coalesces the case). The classic two-step is required:

1. `git mv AbsorbTracker/Panel AbsorbTracker/_panel_` (rename to a transitional name).
2. `git commit -m "AbsorbTracker: rename Panel/ → _panel_/ (case-rename step 1)"` — this commits the rename so git records the casing transition.
3. `git mv AbsorbTracker/_panel_ AbsorbTracker/panel`.
4. `git commit -m "AbsorbTracker: rename _panel_/ → panel/ (case-rename step 2)"` — second commit completes the lowercase casing.
5. Edit `AbsorbTracker.toc` lines 37-40: `Panel\` → `panel\`.

Alternative: `git mv -f` with a same-name-different-case target sometimes works (`git config core.ignoreCase false` then `git mv Panel panel`) but is unreliable on `/mnt/d`. The two-step is bulletproof.

**Risks:**
- Anyone with the addon already loaded in WoW must close the client before the rename, then restart. WoW caches the folder listing at TOC parse time; a live `/reload` after the rename can fail to find `Panel\Helpers.lua` (the old path in the cached TOC) — restart the client.
- Deployed users (post-release) get the new folder via fresh install; CurseForge zips are case-preserving, so users on case-sensitive filesystems (Linux WoW via Wine) get `panel/` correctly first time.

**Verification:** `ls AbsorbTracker/panel/` returns the four files; `ls AbsorbTracker/Panel/` returns "No such file." `grep panel AbsorbTracker/AbsorbTracker.toc` returns four `panel\` lines, no `Panel\`.

---

### AT-10 — Doc re-verify at v1.9

**Standard:** §15. AT-10 is "MAY/SHOULD" — the May 2 sync left zero drift; only re-verify after the v1.9 changes.

**Current state:** `README.md`, `ARCHITECTURE.md`, `CLAUDE.md` synced at 2026-05-02 (raw §15).

**Target state:**
- `README.md` Version History row added: `1.9.0 — Standards-compliance pass: .pkgmeta + .luacheckrc, AceConsole slash, persistent /at debug, Compat.lua + Locale.lua scaffolds, panel/ folder rename, ScrollPatch shape guard.`
- `README.md` version badge bumped to 1.9.0.
- `ARCHITECTURE.md` updated:
  - File map now shows `Compat.lua`, `Locale.lua`, `panel/` (lowercase).
  - "Bundled libs" section updated to "External libs (declared in `.pkgmeta`)".
- `CLAUDE.md` updated:
  - Layout tier explicitly noted as Tier 1 (per §1).
  - "Bundled libs in `libs/`" section rewritten to point to `.pkgmeta` externals.
  - Persistent debug flag noted in "Hard rules" (`AddonTable.db.global.debug` — survives reload).
  - `AddonTable.L` mentioned in "Hard rules" or a new "Localization" subsection.

**Migration steps:** apply the `wow-addon:sync-docs` skill at the very end of the milestone, then spot-check the five highest-traffic claims (Interface line, file count, slash command list, sub-page count, debug persistence).

**Risks:** drift between code and docs is the standard's #1 gripe (§15); the sync skill is the established mitigation.

**Verification:** `grep -F '1.9.0' AbsorbTracker/README.md` returns the badge + Version History row. `grep -F 'Compat.lua' AbsorbTracker/ARCHITECTURE.md` and `grep -F 'Locale.lua' AbsorbTracker/ARCHITECTURE.md` both return ≥1 line.

---

## 5. Cross-cutting concerns

### 5.1 SavedVariables compatibility

No SV migration is needed for any of AT-1..AT-11.

- AT-7 adds `db.global.debug` — a brand-new key. AceDB merges in defaults non-destructively at load; existing `AbsorbTrackerDB` saved variables that lack a `global` namespace (because the current addon defines profile-only defaults) get the `global = { schemaVersion = 1, debug = false }` block injected by AceDB on first 1.9 load. No migration code needed; AceDB's defaults-merge does the work.
- AT-5 / AT-6 / AT-8 / AT-9 / AT-11 do not touch SVs.
- `schemaVersion = 1` is added (new in 1.9 since it wasn't declared before — §5.1 mandate). It's the **first** schemaVersion the addon ever ships; no migration runner needed yet (§5.1 still allows an empty migration body), but we ship a 4-line `RunMigrations` stub for future use:

```lua
-- Core.lua addition (after defaults table):
function AddonTable.RunMigrations()
    local g = AddonTable.db and AddonTable.db.global
    if not g then return end
    g.schemaVersion = g.schemaVersion or 1
    -- if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
end
```

Called from `Events.lua` PLAYER_LOGIN immediately after `AddonTable.db = AceDB:New(...)`.

### 5.2 Backward compatibility for existing AbsorbTrackerDB

A user upgrading from 1.8 to 1.9 has an `AbsorbTrackerDB` whose top-level structure is `{ profiles = {...}, namespaces = {...}, profileKeys = {...} }` (AceDB normalized) with no `global` key. AceDB on 1.9 load:
1. Reads old SV.
2. Sees `defaults.global = { schemaVersion=1, debug=false }`.
3. Merges defaults non-destructively → user gets `db.global.schemaVersion = 1`, `db.global.debug = false`.
4. All profile data preserved.

Verified pattern — same as every other AceDB-based addon adding a new global scope.

### 5.3 Lib externals migration (AT-4)

Externalized via `.pkgmeta`:

- `LibStub`, `CallbackHandler-1.0`, `AceAddon-3.0`, `AceDB-3.0`, `AceGUI-3.0`, `AceConfig-3.0`, `AceConsole-3.0`, `AceEvent-3.0`, `AceTimer-3.0`, `AceDBOptions-3.0`, `LibSharedMedia-3.0`, `AceGUI-3.0-SharedMediaWidgets`.

Stays vendored: **none**. AbsorbTracker has no addon-private micro-libs.

`embeds.xml`: **not used** (Tier 1 — §2.4). The TOC no-strip block remains the load-order driver for libs.

Note on `AceConsole-3.0`: required new dep introduced by AT-5. Add to TOC no-strip block immediately after `AceGUI-3.0` line.

### 5.4 Folder rename hazard (AT-11)

NTFS / `/mnt/d` is case-insensitive by default. A single-step `git mv Panel panel` produces a no-op on disk. **Use the two-commit interim step** documented in AT-11 §4 (`Panel` → `_panel_` → `panel`). Verified pattern; same trick is in the Linux kernel's history for case-renames.

## 6. Out of scope

- Bar painting, ticker, color resolution, secret-value `UnitGetTotalAbsorbs` handling — unchanged.
- Schema content (rows in `Options/*.lua`) — unchanged.
- ScrollPatch behavior on the happy path — unchanged. Only the shape-sniff guard is added.
- AceAddon `:NewAddon` migration — not required; the `AddonTable` bus pattern is acceptable per §4.1 (vararg per-addon table is the canonical equivalent of `NS`).
- Any new feature, bug fix, or schema row.
- Docs synthesis beyond the three v1.9-touched files (README/ARCHITECTURE/CLAUDE).

## 7. Acceptance criteria

- [ ] `AbsorbTracker.toc:5` shows `## Version: 1.9.0`. README badge and Version History both 1.9.0.
- [ ] `.pkgmeta` exists at `AbsorbTracker/.pkgmeta` with ≥10 `externals:` entries and `ignore:` block.
- [ ] `.luacheckrc` exists; `luacheck AbsorbTracker --no-color` exits 0 (or only with explicitly-justified warnings).
- [ ] `AbsorbTracker.toc` contains `## X-Curse-Project-ID:` and `## X-Wago-ID:` lines.
- [ ] `AbsorbTracker/Compat.lua` exists with `AddonTable.Compat`, `Compat.IsRetail`, `Compat.IsClassic` defined.
- [ ] `AbsorbTracker/Locale.lua` exists with `AddonTable.L` metatable + at least the StaticPopup text key + 2 slash strings keyed.
- [ ] `Options/General.lua` StaticPopup uses `L["..."]` for `text`, `button1`, `button2`.
- [ ] `Utils.lua` exposes `AddonTable.IsDebug` and `AddonTable.SetDebug`; `runDebug` in `SlashCommands.lua` calls `SetDebug`.
- [ ] After in-game `/at debug` → `/reload`, debug remains enabled (verified by issuing a debug-emitting action).
- [ ] AceConsole `:RegisterChatCommand("at", ...)` registered; `/at help` and `/absorbtracker help` both work.
- [ ] `AbsorbTracker/Panel/` does not exist; `AbsorbTracker/panel/` does, with the same four files.
- [ ] TOC paths reference `panel\` (lowercase), not `Panel\`.
- [ ] `panel/ScrollPatch.lua` `PatchAlwaysShowScrollbar` early-returns with a once-per-session warning if AceGUI ScrollFrame shape mismatches.
- [ ] `git ls-files AbsorbTracker/libs | wc -l` returns 0 (libs deleted from version control after AT-4).
- [ ] Addon loads on a 12.0.5 client without errors. Existing `AbsorbTrackerDB` SVs load unchanged. `/at config`, `/at set barWidth 250`, `/at resetall`, `/at profile list`, `/at debug` all behave per docs.
- [ ] README.md / ARCHITECTURE.md / CLAUDE.md reference Compat.lua, Locale.lua, panel/ (lowercase), `.pkgmeta`, persistent debug.
