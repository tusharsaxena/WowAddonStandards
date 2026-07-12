# KickCD — Technical Design (HLD + LLD)

**Addon:** KickCD
**Tier:** 2 (canonical reference for Tier 2 layout)
**Source root:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/KickCD`
**Standard:** `WowAddonStandards/standards/01_STANDARD.md`
**Deviation list:** `WowAddonStandards/audit/2026-05-03/03_DEVIATIONS.md` (KCD-1..KCD-13)
**Raw audit:** `WowAddonStandards/audit/2026-05-03/_raw/KickCD.md`

---

## 1. Goal

Bring KickCD to full compliance with `01_STANDARD.md (v1.0, 2026-05-03)` and reduce file LOC under the 1500 cap. KickCD is already the **canonical Tier 2 reference**; remediation refines what exists rather than restructuring it. The two big lifts are:

1. Peel `modules/IconGrid.lua` (1753 LOC) and `settings/Panel.lua` (1258 LOC) under the 1500 cap.
2. Add the missing tooling (`.pkgmeta`, `.luacheckrc`), shop IDs, Compat shims, and lib hygiene.

Everything else is mechanical S-effort cleanup.

---

## 2. Scope

In scope: KCD-1, KCD-2, KCD-3, KCD-4, KCD-5, KCD-6, KCD-7, KCD-8, KCD-9, KCD-10, KCD-11, KCD-12.

**Deferred to v2:** KCD-13 — per-zone profile trees (OmniCD-style `profile.party.arena|party|raid`, std §5.3). XL effort, requires schema rework, settings UI re-cut, and migration. Captured below in §6 "Out of scope" as future direction.

---

## 3. HLD — System view

### 3.1 Current layout (already canonical)

```
KickCD/
├── KickCD.toc                  -- single TOC, multi-Interface (120000,120001,120005)
├── ARCHITECTURE.md / CLAUDE.md / README.md / LICENSE
├── core/
│   ├── Compat.lua    (431)     -- LOADED FIRST; creates _G.KickCD
│   ├── Constants.lua  (70)
│   ├── State.lua     (152)     -- bootstrap PLAYER_REGEN_* listener; combat flag
│   ├── Util.lua      (228)     -- RegisterTargetEvent, print, anchor helpers
│   ├── Database.lua  (542)     -- AceDB:New, BuildSpells, MigrateProfile
│   ├── LSMPatch.lua   (62)
│   └── KickCD.lua    (895)     -- AceAddon:NewAddon promotion of NS; slash dispatch
├── defaults/
│   └── Spells.lua    (333)
├── locales/
│   └── enUS.lua      (373)     -- metatable __index = key fallback
├── modules/
│   ├── Cooldowns.lua (431)
│   ├── IconGrid.lua  (1753) ⚠  -- OVER CAP — peel target
│   └── Castbar.lua   (1422)
├── settings/
│   ├── Panel.lua     (1258) ⚠  -- OVER CAP — peel target
│   ├── General.lua   (156)
│   ├── Icons.lua     (376)
│   ├── Castbar.lua   (530)
│   ├── Spells.lua    (953)
│   └── Profiles.lua   (69)
├── libs/  (19 entries; 7 vendored-unused)
├── media/
├── reviews/2026-05-02/
└── docs/
```

Remediation does **not** restructure folders. It (a) peels two oversized files into in-folder sub-trees, (b) deletes unused libs, (c) adds tooling files at the root.

### 3.2 Critical patterns to preserve

These are non-negotiable invariants — every refactor below must preserve them:

| Pattern | Source of truth | Notes |
|---|---|---|
| Closed message bus, 5 messages, 1 sender each | `core/Compat.lua:19` (NS bootstrap), `core/State.lua:149-151`, `core/Database.lua:496-498`, `modules/Cooldowns.lua:266`, `modules/IconGrid.lua` Layout, `settings/Panel.lua:60-64` | std §4.4 reference impl |
| Schema-as-single-source | `KickCD.Settings.Schema` rows added in `settings/General.lua:29-89`, etc. | std §4.5 reference impl |
| Bootstrap-namespace AceAddon promotion | `core/Compat.lua:19` then `core/KickCD.lua:21-33` (`AceAddon:NewAddon(existing, ...)` mutates the same table) | std §4.2 reference impl |
| Compat / State / Constants three-way split | `core/{Compat,State,Constants}.lua` | enforced in CLAUDE.md |
| Ordered slash dispatch table | `core/KickCD.lua:117-148` (COMMANDS), `:150-188` (DEBUG_COMMANDS), `:787-802` (SPELLS_COMMANDS) | help text generated from same table — std §7.3 |
| `Util.RegisterTargetEvent` | `core/Util.lua:197-205` | unit-filtered events C-side; used by IconGrid for 8 `UNIT_SPELLCAST_*` events |
| Module publishing idiom `KickCD.Foo = KickCD.Foo or {}` | every core/module file | order-independent |

### 3.3 Message bus diagram

```
                                 (bus: AceEvent :SendMessage / :RegisterMessage)

  Cooldowns ───SendMessage──► KickCD_SPELL_STATE ──► IconGrid:OnSpellState
                                payload = {spellID, ready, isActive,
                                           cdObject, chargeCdObject, charges}

  settings/Panel ─SendMsg──► KickCD_CONFIG_CHANGED ──► IconGrid:OnConfigChanged
                                payload = section ("general"|"icons"|"castbar")  ─► Castbar:OnConfigChanged

  Database ──SendMessage──► KickCD_PROFILE_CHANGED ──► IconGrid:OnProfileChanged
                                payload = "OnProfileChanged"|"Copied"|"Reset"   ─► Cooldowns
                                                                                ─► Castbar

  IconGrid ──SendMessage──► KickCD_GRID_LAYOUT ──► Castbar (anchor relative to grid)
                                payload = nil

  State (bootstrap) ─SendMsg─► KickCD_COMBAT_STATE ──► IconGrid:OnCombatStateChanged
                                payload = {inCombat = bool}                     ─► Castbar
```

Every message has **exactly one sender**. Adding a sixth requires updating `ARCHITECTURE.md`, `docs/message-bus.md`, and the producer + every consumer.

---

## 4. LLD — Per-deviation design

### KCD-1 — Add `.pkgmeta` (🔴, S)

**Current:** absent.
**Target:** `.pkgmeta` at `KickCD/.pkgmeta` declaring all Ace3 + LSM + LCG libs as `externals:` and ignoring `reviews/`, `docs/internal/`, `_dev/`.
**Migration:**
1. Copy std §13 template.
2. Replace `<Addon>` with `KickCD`.
3. Add externals for: `LibStub`, `CallbackHandler-1.0`, `AceAddon-3.0`, `AceDB-3.0`, `AceDBOptions-3.0`, `AceEvent-3.0`, `AceConsole-3.0`, `AceGUI-3.0`, `AceGUI-3.0-SharedMediaWidgets`, `AceConfig-3.0`, `AceConfigDialog-3.0`, `LibSharedMedia-3.0`, `LibCustomGlow-1.0`. (AceConfig stays — used by `settings/Profiles.lua:22-24`.)
**Risks:** none. File is additive.
**Verification:** `bigwigs-packager --check` (or visual inspection) parses without warnings.

### KCD-2 — Add `.luacheckrc` (🔴, S)

**Current:** absent.
**Target:** root `.luacheckrc` per std §14.
**Migration:**
1. Copy std §14 baseline.
2. Add KickCD-specific reads: `Mixin`, `BackdropTemplateMixin`, `CooldownFrameTemplate`, `UnitCastingInfo`, `UnitChannelInfo`, `UnitClass`, `C_Spell`, `C_SpecializationInfo`, `GetSpecialization`, `GetSpecializationInfo`, `issecretvalue`, `securecallfunction`, `Settings`, `RegisterStateDriver`, `UIParent`, `WOW_PROJECT_ID`, `WOW_PROJECT_MAINLINE`, `WOW_PROJECT_CLASSIC`.
3. Add KickCD-specific writes: `KickCDDB`.
4. Exclude `libs/`, `reviews/`, `_dev/`, `docs/`.
**Verification:** `luacheck .` returns 0 errors (warnings allowed).

### KCD-3 — TOC X-IDs (🔴, S)

**Current:** `KickCD.toc:1-10` lacks `X-Curse-Project-ID`, `X-Wago-ID`.
**Target:** add both fields after `X-License: MIT`.
**Migration:** user supplies the two integer IDs at execution time; placeholder is `0` (lint OK; flagged in plan).
**Verification:** `grep '^## X-' KickCD.toc` returns 3 lines (License, Curse, Wago).

### KCD-4 — Compat shim for `GetSpecialization*` (🔴, S)

**Current:**
- `modules/Cooldowns.lua:78-82` — direct `GetSpecialization()` and `GetSpecializationInfo(idx)`.
- `modules/IconGrid.lua:286-290` — same pair, same shape.
- `core/KickCD.lua:553-562` — also calls `GetSpecialization`/`GetSpecializationInfo` (per raw audit §13).

These bypass `Compat`, violating std §11.

**Target:** add two shims to `core/Compat.lua`:

```lua
--- Spec resolution. WoW 11.x deprecated bare GetSpecialization* in
--- favour of C_SpecializationInfo.*. Older flavors keep the bare APIs.
function Compat.GetSpecialization()
    if _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecialization then
        return _G.C_SpecializationInfo.GetSpecialization()
    end
    if _G.GetSpecialization then return _G.GetSpecialization() end
    return nil
end

function Compat.GetSpecializationInfo(specIndex)
    if _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecializationInfo then
        return _G.C_SpecializationInfo.GetSpecializationInfo(specIndex)
    end
    if _G.GetSpecializationInfo then return _G.GetSpecializationInfo(specIndex) end
    return nil
end
```

**Migration steps (per call site):**
- `modules/Cooldowns.lua:78-82` — replace `GetSpecialization and GetSpecialization()` with `KickCD.Compat.GetSpecialization()`; replace `GetSpecializationInfo(idx)` with `KickCD.Compat.GetSpecializationInfo(idx)`.
- `modules/IconGrid.lua:286-290` — identical replacement.
- `core/KickCD.lua:553-562` — identical replacement (search for `GetSpecialization` in the file).

**Risks:** none if the shim returns the same shape. Both wrappers preserve the multi-return contract from `GetSpecializationInfo` (the consumers destructure `local _, specName = ...`).

**Verification:** `grep -rn "GetSpecialization" core/ modules/ settings/` returns hits **only** in `core/Compat.lua`. In-game: `/kcd debug spells` after `/reload` and after a spec switch must report the correct spec.

### KCD-5 — File peel (🔴, L) — see §4.5 below

This is the largest risk. Detailed region maps follow.

### KCD-6 — Lib cleanup (🟠, S)

**Current vendored:** `AceAddon-3.0`, `AceBucket-3.0`, `AceComm-3.0`, `AceConfig-3.0`, `AceConsole-3.0`, `AceDB-3.0`, `AceDBOptions-3.0`, `AceEvent-3.0`, `AceGUI-3.0`, `AceGUI-3.0-SharedMediaWidgets`, `AceHook-3.0`, `AceLocale-3.0`, `AceSerializer-3.0`, `AceTab-3.0`, `AceTimer-3.0`, `CallbackHandler-1.0`, `LibCustomGlow-1.0`, `LibSharedMedia-3.0`, `LibStub`.

**Used (verified by `grep -rn "LibStub(" core/ modules/ settings/`):**
| Lib | Used? | Call site |
|---|---|---|
| AceAddon-3.0 | yes | `core/KickCD.lua:23`, every module's `:GetAddon` |
| AceDB-3.0 | yes | `core/Database.lua:507` |
| AceDBOptions-3.0 | yes | `settings/Profiles.lua:21` |
| AceConfig-3.0 | yes | `settings/Profiles.lua:22` |
| AceConfigDialog-3.0 | yes | `settings/Profiles.lua:23` |
| AceGUI-3.0 | yes | `settings/Panel.lua:21`, `settings/Spells.lua:790`, `core/LSMPatch.lua:31`, `settings/Profiles.lua:24` |
| AceGUI-3.0-SharedMediaWidgets | yes | provides registered widget types used by Panel |
| AceConsole-3.0 | yes | mixed in via `:NewAddon(... "AceConsole-3.0")` at `core/KickCD.lua:23-26` (NB: TOC must continue to load this lib) |
| AceEvent-3.0 | yes | mixed in via `:NewAddon(...)` and `:NewModule(... "AceEvent-3.0")` |
| LibSharedMedia-3.0 | yes | `modules/IconGrid.lua:215, :826`, `modules/Castbar.lua:91`, `settings/Panel.lua:196` |
| LibCustomGlow-1.0 | yes | `modules/IconGrid.lua:512` |
| LibStub | yes | every file |
| CallbackHandler-1.0 | yes | dependency of every Ace lib |
| **AceBucket-3.0** | **no** | grep clean — DELETE |
| **AceComm-3.0** | **no** | grep clean — DELETE |
| **AceHook-3.0** | **no** | grep clean — DELETE |
| **AceLocale-3.0** | **no** | grep clean (KickCD uses metatable locale, std §8.1) — DELETE |
| **AceSerializer-3.0** | **no** | grep clean — DELETE |
| **AceTab-3.0** | **no** | grep clean — DELETE |
| **AceTimer-3.0** | **no** | grep clean — DELETE (KickCD uses bare `C_Timer.NewTicker`/`After`) |

**Target:** delete the 7 unused lib folders from `libs/`. Move every USED lib to `externals:` in `.pkgmeta` (from KCD-1) so `git rm -r libs/<UsedLib>` becomes possible at packager time. **For this remediation we keep the used libs vendored** (deletion of vendored externals is a separate sweep across the whole collection); externals declaration is sufficient compliance for §3.3.

**Risks:** if any `LibStub("X-3.0", true)` reads silently nil-fall-through and feature-gates without complaint, deletion is invisible. Mitigated by the grep table above being complete.

**Verification:** post-delete, in-game `/reload` produces no errors; `grep -rn 'LibStub("Ace\(Bucket\|Comm\|Hook\|Locale\|Serializer\|Tab\|Timer\)' .` returns 0 hits.

### KCD-7 — Slash to AceConsole (🟠, S) — **already implemented**

**Re-audit:** `core/KickCD.lua:60-61` already calls `self:RegisterChatCommand("kickcd", "OnSlashCommand")` and `self:RegisterChatCommand("kcd", "OnSlashCommand")`; AceConsole-3.0 is mixed in at `:23-26`. `grep -n "SLASH_" core/ modules/ settings/` returns **zero hits**. The deviation listing in `03_DEVIATIONS.md` is stale relative to the current source.

**Target:** confirm via grep, document in remediation execution log, mark KCD-7 as **already met**. No code change.

**Verification:** `grep -rn "^SLASH_KICKCD\|SLASH_KCD\|_G\.SLASH_" .` returns 0; `/kcd help` works.

### KCD-8 — Locale unification (🟠, S)

**Current:** `locales/enUS.lua:12-17` uses metatable `__index = function(_,k) return k end` (correct std §8.1 pattern). `libs/AceLocale-3.0/` is vendored but NOT loaded by TOC and NOT called via `LibStub`.

**Decision:** **delete `libs/AceLocale-3.0/`** (already part of KCD-6 sweep above — listed there). Standard accepts both metatable-fallback and AceLocale non-strict; KickCD picks metatable-fallback. The vendored AceLocale is dead weight.

**Migration steps:**
1. Confirm `grep -rn 'LibStub("AceLocale-3.0"' .` returns 0 hits outside `libs/`.
2. `git rm -r libs/AceLocale-3.0/`.
3. Confirm `KickCD.toc` does not reference `AceLocale` (it doesn't).

**Risks:** none — verified unused.

**Verification:** post-delete, `/reload` produces no error; locale fallback (e.g. `print(KickCD.L["NeverDefinedKey"])` returns the key) still works.

### KCD-9 — Doc reconciliation (🟡, S)

**Current:** `ARCHITECTURE.md:38` (subsystem table) says **"4 messages, sender/listener/payload"** while `:53` correctly states 5. The 5 messages are listed in the same table at the row for `core/State.lua` (`KickCD_COMBAT_STATE`).

**Target:** edit `ARCHITECTURE.md:38` to read **"Closed message contract (5 messages, sender/listener/payload)"**. Run `wow-addon:sync-docs` to verify count parity across `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `docs/message-bus.md`.

**Verification:** `grep -n "messages" ARCHITECTURE.md README.md CLAUDE.md docs/message-bus.md` shows uniform "5".

### KCD-10 — Spell-list class validation (🟡, S)

**Current:** `core/Database.lua:292-299` `EnsureSpellList(class, spec)` lazy-creates `db.profile.spells[class][spec] = {}` for any input. Typo via `/kcd spells add <id> <typo>` permanently bloats SVs.

**Target:** add a class allowlist gate in `EnsureSpellList`. Reject unknown class tokens with a chat error and a one-shot list of valid tokens.

**Pseudocode:**

```lua
-- core/Database.lua, near top of file
local VALID_CLASSES = {
    DEATHKNIGHT=true, DEMONHUNTER=true, DRUID=true, EVOKER=true,
    HUNTER=true, MAGE=true, MONK=true, PALADIN=true, PRIEST=true,
    ROGUE=true, SHAMAN=true, WARLOCK=true, WARRIOR=true,
}

function Database:EnsureSpellList(class, spec)
    class = class and class:upper()
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

Callers (`/kcd spells add ...` in `core/KickCD.lua`'s SPELLS_COMMANDS) must check the nil return and abort with a clear chat error.

**Risks:** strict validation could reject a legitimate future class addition. Mitigation: the allowlist is one constant, easy to extend.

**Verification:** `/kcd spells add 1766 ROGE OUTLAW` (typo) prints the error and does not bloat `KickCDDB.profiles.Default.spells.ROGE`.

### KCD-11 — Glow-gate sentinel cleanup (🟡, S)

**Current:** `modules/IconGrid.lua:1684-1700` (`RefreshAllGlows`) uses string `"secret"` as a tri-state sentinel mixed with bools `true`/`false`/`nil`. Works but is brittle.

**Target:** declare a named-enum table at file top:

```lua
-- Glow-gate interruptibility sentinel. Tri-state across:
--   true            -- target's cast IS interruptible
--   false           -- explicitly NOT interruptible
--   nil             -- no cast / no target
--   GLOW_SECRET     -- value is secret-tainted; can't compare in Lua,
--                      treat as "moved" (forces re-iteration)
local GLOW_SECRET = {} -- unique table sentinel; never equal to any bool/nil
```

Then in the function body replace `interruptible = "secret"` with `interruptible = GLOW_SECRET` and the equality compare `interruptible ~= "secret"` with `interruptible ~= GLOW_SECRET`.

**Risks:** none — local-scope refactor. The sentinel is referenced only inside one function and the module-private cache (`self._lastGlowGate`).

**Verification:** in-game cast on a hostile target with `/kcd debug interrupt` running prints the same sequence pre/post change.

### KCD-12 — Review-TODO reconciliation (🟡, S)

**Current:** `modules/IconGrid.lua:226-228` carries TODO comment referencing F-015/F-016 (perf) from the 2026-05-02 review. The review's `05_FINAL_SUMMARY.md` deferred them.

**Target:** delete the TODO comment from source. Add a single line under `reviews/2026-05-02/05_FINAL_SUMMARY.md`'s deferred-list confirming F-015 / F-016 stay deferred. Capture in `docs/icon-grid.md`'s "Future" section that `BuildCurves` and `Castbar:Reskin` rebuild on every relevant CONFIG_CHANGED — accepted cost.

**Risks:** none.

**Verification:** `grep -rn "F-015\|F-016\|TODO(perf)" modules/ settings/ core/` returns 0 hits.

### KCD-13 (deferred) — see §6.

---

## 4.5 LLD — File peel (KCD-5)

This is the highest-risk part of the remediation. Both files violate the 1500-LOC cap. The peels below are designed to be **mechanical** — each region of the existing file maps to exactly one new sub-file. No semantic refactor; cut, paste, fix `local` declarations, fix forward references.

### 4.5.1 `modules/IconGrid.lua` (1753 LOC) → 6 files under `modules/IconGrid/`

**Why a sub-folder.** The file already documents 6 distinct regions in its own banner comments (lines `:55-56, :86-87, :293-294, :487-488, :850-851, :900-901, :942-943, :1014-1015, :1380-1381, :1427-1428, :1460-1461, :1543-1544, :1739-1740`). Std §1.2 allows sub-folders for Tier 2 modules.

**Loading.** Replace the single `modules/IconGrid.lua` line in `KickCD.toc` with the 6 new lines below in order. The current `IconGrid.lua` becomes the **first** file in the sequence (`Init.lua`) so the `KickCD.IconGrid = KickCD.IconGrid or {}` namespace publication happens first.

**Region map (read directly from `modules/IconGrid.lua`):**

| Source lines | Source content | Target file | LOC budget |
|---|---|---|---|
| 1-86 | File banner + module-local state (pool, ordered, grid, _textIcons) + module require + `KickCD.IconGrid = KickCD.IconGrid or {}` namespace + module registration `KickCD:NewModule("IconGrid","AceEvent-3.0")` | `modules/IconGrid/Init.lua` | ~90 |
| 87-292 | Helpers section: `isEnabled` (120), `isTargetCasting` (133), `visibilityMode` (144), `shouldBeVisible` (163), `ApplyInterruptibilityMask` (189), `safeUnpackColor` (203), `fetchBorderTexture` (214), `BuildCurves` (229), `getActiveSpecKey` (282) | `modules/IconGrid/Helpers.lua` | ~210 |
| 293-849 | Per-icon widget construction: `CreateIconWidget` (302), `Icon:StartCooldownText` (438), `Icon:StopCooldownText` (456), `Icon:_RenderCooldownText` (467); ready-glow region: `unpackGlowColor` (541), `Icon:StopGlow` (546), `Icon:StartGlow` (559), `triggerSatisfied` (602), `Icon:UpdateGlow` (629), `applyGcdSuppressionAlpha` (665), `Icon:Apply` (698), `Icon:ApplyAppearance` (789), `Icon:ApplyTextConfig` (819) | `modules/IconGrid/Icon.lua` | ~560 |
| 850-941 | Shared cooldown-text ticker (`_tickAllTextIcons`, `IconGrid:_RegisterTextIcon`, `IconGrid:_UnregisterTextIcon`); pool (`IconGrid:AcquireIcon`, `IconGrid:ReleaseAll`) | `modules/IconGrid/Pool.lua` | ~95 |
| 942-1379 | Active spell list (`IconGrid:BuildActiveList`); layout helpers (`parseAnchor`, `parseGrow`, `placeBlock`, `layoutBlock`); `IconGrid:Layout`; `IconGrid:ApplyGeneral` | `modules/IconGrid/Layout.lua` | ~440 |
| 1380-1459 | Lock + drag + frame setup (`onDragStart`, `onDragStop`, `IconGrid:ApplyLock`, `IconGrid:EnsureGrid`) | `modules/IconGrid/Anchor.lua` | ~80 |
| 1460-1753 | Module lifecycle (`OnEnable`, `OnDisable`); message + event handlers (`OnSpellState`, `OnConfigChanged`, `OnProfileChanged`, `RefreshVisibility`, `OnTargetCastEvent`, `OnTargetChanged`, `RefreshAllGlows`, `OnCombatStateChanged`, `OnSpecChanged`, `OnPlayerEnteringWorld`, `OnSpellsChanged`); public accessors (`GetGridFrame`, `GetPrimaryIcon`) | `modules/IconGrid/Events.lua` | ~295 |

**Total LOC after peel:** ~1770 (sum) — every file under cap (560 max in Icon.lua, well under 1500).

**Cross-file local mechanics:**

- The current `IconGrid.lua` declares many file-local helpers (`local function isEnabled()`, `local function shouldBeVisible()`, etc.) that are referenced from later sections. After peel, these can no longer be `local function`. **Decision:** lift them onto a private namespace `KickCD.IconGrid._helpers` (publicized at `Init.lua` top: `M._helpers = M._helpers or {}`). Each helper becomes `local helpers = M._helpers; function helpers.isEnabled() ... end`. Consumers in other files do `local helpers = M._helpers; if helpers.isEnabled() then ... end`. This preserves visibility semantics (private to module) without forcing 12 helpers onto `_G`.
- Module-local mutable state: `pool`, `ordered`, `grid`, `_textIcons`, `_textTicker`, `LCG_KEY`, `_textPaused` — keep on `M._state = { pool={...}, ordered={}, grid=nil, _textIcons={}, ... }` published at `Init.lua` top. Every consumer reads `local state = M._state`.
- `Icon` mixin table — published as `M._Icon`. `CreateIconWidget` does `Mixin(button, M._Icon)`.
- `IconGrid:` (the colon-method) — these are methods on `M` itself; cross-file definition (`function M:BuildActiveList()` in Layout.lua) is fine, no special handling needed.

**Migration sequence:**

1. Create `modules/IconGrid/Init.lua` containing namespace + state + private-helper publishing scaffold.
2. Cut each region from the old file, paste into target, edit `local function X` → `function helpers.X` and call sites accordingly.
3. Replace single TOC line `modules/IconGrid.lua` with the 6 ordered lines.
4. Delete the old `modules/IconGrid.lua`.
5. `/reload` and run the smoke tests in `docs/smoke-tests.md`.

**Risks:**
- **Forward-reference breakage.** A function defined in a later sub-file referenced by an earlier one. Mitigation: every helper goes on `M._helpers`; the namespace table exists at `Init.lua` load, members are populated by the time any handler fires (handlers fire post `OnEnable`, after every file has loaded).
- **Local upvalue capture changes.** `_textTicker` is upvalued to `_tickAllTextIcons`. After peel, `_textTicker` becomes `state._textTicker`; the closure references must be rewritten as field accesses.
- **`Icon:` colon-call dispatch.** `Icon:StartGlow(...)` is a method on the mixin table. Moving it to `Icon.lua` with `function M._Icon:StartGlow(...)` works because `M._Icon` was published in `Init.lua`.

**Verification:**
- `wc -l modules/IconGrid/*.lua` → every file under 700.
- Smoke tests from `docs/smoke-tests.md` all pass: cold install, visibility modes, lock/drag, secret-value cast.
- `/kcd debug spells` and `/kcd debug interrupt` produce identical output to a known-good baseline.

### 4.5.2 `settings/Panel.lua` (1258 LOC) → 5 files under `settings/Panel/`

**Region map (read directly from `settings/Panel.lua`):**

| Source lines | Source content | Target file | LOC budget |
|---|---|---|---|
| 1-90 | File banner + `local KickCD = LibStub(...)`; `KickCD.Settings = KickCD.Settings or {}`; `local Helpers = {}; KickCD.Settings.Helpers = Helpers`; `Resolve`, `Helpers.Get`, `Helpers.FireConfigChanged`, `Helpers.Set` (the read/write seam, lines 38-72) | `settings/Panel/Init.lua` | ~95 |
| 91-256 | Schema-shape validation: `Helpers.SchemaForPanel`, `Helpers.FindSchema`, `_printSchemaError`, `Helpers.ValidateSchema`, `Helpers.AnchorValues`, `Helpers.LSMValues`; layout constants block (215-222) | `settings/Panel/Schema.lua` | ~165 |
| 257-501 | Header builder (`buildHeader` 261), `Helpers.CreatePanel` (312), tooltip helper `attachTooltip` (229) — actually lines 224-256 — keep in this file (the header / canvas-frame creators); always-visible scrollbar patch (`Helpers.PatchAlwaysShowScrollbar` 360-501) | `settings/Panel/Frame.lua` | ~245 |
| 502-900 | Lazy AceGUI scroll container (`ensureScroll` 508), `fireOnChange`, `Helpers.Section` (579), `addSpacer`; widget creators: `applyWidth` (610), `makeCheckbox` (618), `snapToStep`, `makeSlider` (651), `makeDropdown` (688), `makeColorPicker` (745); generic dispatch `Helpers.RenderField` (801); `Helpers.InlineButton` (810), `Helpers.InlineButtonPair` (840), `Helpers.Button` (871) | `settings/Panel/Widgets.lua` | ~400 |
| 901-1095 | Schema-driven render: `Helpers.RenderSchema` (924), `Helpers.RefreshAllPanels`, `Helpers.RestoreDefaults`, `Helpers.RestoreAllDefaults`, `Helpers.SetAndRefresh`, `Helpers.ResetIconPosition`, `Helpers.ResetAll` | `settings/Panel/Render.lua` | ~195 |
| 1096-1258 | Main-page content (`addBlock`, `Helpers.BuildMainContent`); tab + main-category registration (`KickCD.Settings.RegisterTab`, `RegisterPanel`); bootstrap frame (PLAYER_LOGIN + ADDON_LOADED Blizzard_Settings) | `settings/Panel/Register.lua` | ~165 |

**Total LOC after peel:** ~1265 (sum) — every file well under 700.

**Cross-file local mechanics:**

- `Helpers` is already an addon-public table (`KickCD.Settings.Helpers = Helpers` in `Init.lua`). Every cross-file write becomes `function Helpers.X(...)` and every read becomes `local Helpers = KickCD.Settings.Helpers; Helpers.X(...)`.
- File-locals `attachTooltip` and `addSpacer` (used inside Section/Widgets) get lifted onto `Helpers._private = {}` to keep them out of the public surface.
- `RegisterPanel` is the bootstrap; `Register.lua` keeps the bootstrap CreateFrame + event registration so the addon-load-order behavior is unchanged.

**Migration sequence:**

1. Create `settings/Panel/Init.lua` first; everything else loads after it in TOC.
2. Cut regions per the table, lift file-locals onto `Helpers.*` or `Helpers._private.*` as needed.
3. Replace the single TOC line `settings/Panel.lua` with 5 ordered lines.
4. Delete the old `settings/Panel.lua`.
5. Lint + reload + walk every settings tab.

**Risks:**
- `Helpers.ValidateSchema` is called at the **end** of bootstrap (`RegisterPanel` body). The validator must be defined before that call site fires; load order Schema.lua → Frame.lua → Widgets.lua → Render.lua → Register.lua satisfies this.
- The widget creators (`makeSlider`, `makeDropdown`) reference `applyWidth` and `snapToStep` — keep them all in `Widgets.lua`.
- The bootstrap frame at `:1248-1257` listens for `PLAYER_LOGIN` and `ADDON_LOADED` for `Blizzard_Settings` — keep verbatim in `Register.lua`.

**Verification:**
- `wc -l settings/Panel/*.lua` → every file under 700.
- `/kcd config` opens the panel; every tab renders with its widgets bound to db.profile.
- `/kcd resetall` works; `/kcd set <path> <v>` updates both the SV and the visible widget.
- `Helpers.ValidateSchema()` prints `OK` (or no errors) on a clean profile.

---

## 5. Cross-cutting

### 5.1 Locale strategy

KickCD already complies with std §8.1 via the metatable-fallback pattern (`locales/enUS.lua:12-17`). Standard accepts both metatable-fallback and AceLocale-3.0 non-strict mode. **Decision: keep metatable-fallback; delete vendored AceLocale.** Reasons:
- Already working; no string-table maintenance.
- AceLocale would require migrating ~241 keys with no behavioral gain.
- Eliminates a vendored-but-unused lib (KCD-6 sweep).

### 5.2 Lib cleanup confirmation table

See §4.5/KCD-6 above. Seven libs (`AceBucket`, `AceComm`, `AceHook`, `AceLocale`, `AceSerializer`, `AceTab`, `AceTimer`) confirmed unreferenced via `grep -rn 'LibStub("X-3.0"' .` and `grep -rn 'LibStub.*X' .`. Safe to delete.

### 5.3 Compat shim for `GetSpecialization*`

See §4/KCD-4. Call sites: `modules/Cooldowns.lua:78-82`, `modules/IconGrid.lua:286-290`, `core/KickCD.lua:553-562`. Shim added to `core/Compat.lua`.

### 5.4 Doc reconciliation

See §4/KCD-9. `ARCHITECTURE.md:38` has a stale "4 messages" inside the subsystem table; corrected to "5 messages". Run `wow-addon:sync-docs` afterward.

### 5.5 Review-TODO reconciliation

See §4/KCD-12. F-015 and F-016 are formally deferred; the in-source TODO comments in `modules/IconGrid.lua:226-228` are removed. The deferred-list in `reviews/2026-05-02/05_FINAL_SUMMARY.md` carries them.

### 5.6 Glow-gate sentinel

See §4/KCD-11. Replace string `"secret"` with `GLOW_SECRET = {}` table sentinel.

### 5.7 Spell-list class validation

See §4/KCD-10. Allowlist of 13 valid class tokens; `EnsureSpellList` rejects unknown tokens with a chat error and returns nil; callers in `core/KickCD.lua` SPELLS_COMMANDS must check the nil return.

---

## 6. Out of scope

- **KCD-13 — Per-zone profile trees** (XL, deferred to v2). OmniCD's `profile.party.{arena,party,raid,pve,pvp}` model would let a player carry separate icon/glow/anchor/spell sets per group context. Requires schema reshape, settings-UI re-cut (zone selector at the top of every tab), and a `schemaVersion 1 → 2` migration that splits the current single-bucket profile into the new zone-keyed tree. Capture as a v2 epic; out of this remediation.
- **Combat-log dispatcher rework.** No CLEU usage in KickCD; not applicable.
- **Spell-data table updates** (`defaults/Spells.lua`). Out of scope; data refresh runs on a separate cadence with the season patch cycle.
- **`modules/Castbar.lua` (1422 LOC)** — under cap. No peel.
- **`settings/Spells.lua` (953 LOC)** — under cap. No peel.

---

## 7. Acceptance criteria

The remediation is complete when **all** of the following are true:

1. **LOC cap.** Every `.lua` file under `core/`, `modules/`, `settings/`, `defaults/`, `locales/` is ≤1500 LOC. `find core modules settings defaults locales -name '*.lua' -exec wc -l {} \; | awk '$1 > 1500'` returns 0 lines.
2. **Lint.** `luacheck .` returns 0 errors with the new `.luacheckrc` in place.
3. **No deprecated-API direct calls.** `grep -rn "GetSpecialization\b\|GetSpecializationInfo\b" core/ modules/ settings/` returns hits **only** in `core/Compat.lua`.
4. **Bus parity.** `ARCHITECTURE.md`, `CLAUDE.md`, `README.md`, `docs/message-bus.md` all state **5 messages**, and the source has exactly the 5 named messages with one sender each (verified by grep `SendMessage("KickCD_`).
5. **Lib hygiene.** `libs/AceBucket-3.0`, `libs/AceComm-3.0`, `libs/AceHook-3.0`, `libs/AceLocale-3.0`, `libs/AceSerializer-3.0`, `libs/AceTab-3.0`, `libs/AceTimer-3.0` deleted. `.pkgmeta` declares all used libs as externals.
6. **Tooling.** `.pkgmeta` and `.luacheckrc` exist at repo root; TOC carries `X-Curse-Project-ID` and `X-Wago-ID`.
7. **SVs unchanged.** Existing `KickCDDB` saved-vars from a pre-remediation install load post-remediation with no migration warning (or, if a migration was added, schemaVersion bumps cleanly with no key loss).
8. **Smoke tests.** `docs/smoke-tests.md` checklist passes end-to-end (cold install, visibility modes, lock/drag, cast bar, spec/talent/pet, profiles, secret values).

---

**End of TECHNICAL_DESIGN_KickCD.md.**
