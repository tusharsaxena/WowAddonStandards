# Technical Design — ConsumableMaster Remediation

**Addon:** Ka0s Consumable Master (`ConsumableMaster`)
**Source:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/`
**Standard:** `WowAddonStandards/standards/01_STANDARD.md` v1.0
**Deviation IDs:** CM-1 .. CM-14 (`WowAddonStandards/audit/2026-05-03/03_DEVIATIONS.md`)
**Tier:** Tier 1 borderline. 16 production root `.lua` files plus a `defaults/` and `settings/` cluster put us above the 8-file flat ceiling — but the standard explicitly permits "flat with folders" for addons whose extra folders are pure data (`defaults/`) or the canonical UI cluster (`settings/`). We retain the current flat-with-folders shape rather than promote to Tier 2 `core/modules/`. Promotion is deferred until a real `modules/` need emerges.

---

## 1. Goal

Bring ConsumableMaster to full standards compliance against `01_STANDARD.md` (2026-05-03) by closing CM-1 through CM-14 without weakening the addon's two strongest invariants:

- **The macro firewall.** `MacroManager.lua` is the sole caller of `CreateMacro` / `EditMacro`. The standard already cites this as the §9.4 reference implementation. Every remediation step preserves the firewall — the lint check we add (CM-2) treats a violation as an error.
- **The coalescing recompute pipeline.** `RequestRecompute` collapses event flurries into one `C_Timer.After(0, ...)` tick. Refactors that touch `Core.lua` must preserve `_recomputePending` / `_recomputeScheduled` semantics.

---

## 2. Scope

### In scope (this remediation)

| ID | Severity | Title | Effort |
|---|---|---|---|
| CM-1  | 🔴 | Add `.pkgmeta` | S |
| CM-2  | 🔴 | Add `.luacheckrc` (with macro-firewall lint rule) | S |
| CM-3  | 🔴 | Add `X-Curse-Project-ID` and `X-Wago-ID` to TOC | S |
| CM-4  | 🔴 | SV migration runner (scaffold even with empty body) | S |
| CM-5  | 🟠 | Peel `SlashCommands.lua` (1257 LOC) into sub-files | M |
| CM-6  | 🟠 | Remove embedded-but-unused `AceConfig-3.0` | S |
| CM-7  | 🟠 | Migrate to AceConsole `:RegisterChatCommand` (already done — verify and document) | S |
| CM-8  | 🟠 | Locale module shell (`Locale.lua`) — even though strings stay English | M |
| CM-9  | 🟠 | `Compat.lua` shell | S |
| CM-10 | 🟠 | README `/cm enable` doc drift | S |
| CM-11 | 🟠 | `docs/module-map.md` stale-export drift | S |
| CM-12 | 🟡 | `KCM.ResetAllToDefaults` → async via `RequestRecompute` | S |
| CM-13 | 🟡 | Remove `embeds.xml`; switch to TOC-only library loading | M |
| CM-14 | 🟡 | Delete dead `KCM.Options.Register` public surface | S |

### Out of scope (deferred)

- Actual classification logic, ranker scoring, or item-DB updates — pure feature work, unrelated to standards compliance.
- Promotion to Tier 2 (`core/modules/` layout). Triggered only when a non-data, non-settings module count exceeds eight.
- Localization of user-facing strings. Standard requires the **module shell** (CM-8); the project's "English-only" invariant in `CLAUDE.md` is preserved.
- Object pooling (§9.6). Current churn is well below the 10-frame threshold.
- Public API surface (§10). Addon exposes nothing externally.

---

## 3. HLD — System view

### 3.1 Post-remediation directory tree

```
ConsumableMaster/
├── .pkgmeta                              (NEW — CM-1)
├── .luacheckrc                           (NEW — CM-2)
├── ConsumableMaster.toc                  (CM-3, CM-13: TOC-only library load order)
├── LICENSE                               (MIT — already correct)
├── README.md                             (CM-10 fix)
├── CLAUDE.md
├── ARCHITECTURE.md
│
├── Core.lua                              (CM-4 migration runner; CM-12 async reset)
├── Compat.lua                            (NEW — CM-9 shell)
├── Locale.lua                            (NEW — CM-8 metatable-fallback shell)
├── Debug.lua
│
├── BagScanner.lua                        (pure)
├── Classifier.lua                        (pure)
├── Ranker.lua                            (pure)
├── Selector.lua                          (pure)
├── MacroManager.lua                      (★ FIREWALL — sole CreateMacro/EditMacro caller)
├── TooltipCache.lua
├── SpecHelper.lua
│
├── KCMIconButton.lua                     (AceGUI widget)
├── KCMScoreButton.lua
├── KCMMacroDragIcon.lua
├── KCMItemRow.lua
│
├── SlashCommands.lua                     (CM-5: now thin dispatcher, ~250 LOC)
├── Slash/                                (NEW — CM-5 peel)
│   ├── Schema.lua                        (list / get / set — schema-driven verbs)
│   ├── Priority.lua                      (per-category priority editor)
│   ├── Stat.lua                          (per-spec stat priority editor)
│   ├── AIO.lua                           (composite-category editor)
│   └── Dump.lua                          (diagnostics)
│
├── defaults/   (unchanged — pure data)
│   ├── Categories.lua
│   ├── Defaults_StatPriority.lua
│   └── Defaults_*.lua  ×8
│
├── settings/   (unchanged — UI cluster)
│   ├── Panel.lua                         (CM-14: O.Register deleted)
│   ├── Category.lua
│   ├── General.lua
│   └── StatPriority.lua
│
├── docs/                                 (CM-11 fix)
├── reviews/2026-05-02/
└── libs/                                 (CM-6: AceConfig removed; CM-13: NO embeds.xml)
```

**`embeds.xml` deleted (CM-13).** Library `.lua` files load directly from the TOC. No XML-only widgets exist (verified — every `KCM*` widget is Lua-only via `AceGUI:RegisterWidgetType`; no `<Frame>`/`<Button>`/`<Include>` references chain through `embeds.xml` other than the Ace3 lib XMLs themselves).

### 3.2 Component map

| Layer | Files | Role | Macro-firewall side |
|---|---|---|---|
| Bootstrap | `Core.lua`, `Compat.lua`, `Locale.lua`, `Debug.lua` | AceAddon registration, deprecated-API shims, locale metatable, debug seam | Pure |
| Pure data | `defaults/*`, `BagScanner.lua`, `Classifier.lua`, `Ranker.lua`, `Selector.lua`, `TooltipCache.lua`, `SpecHelper.lua` | Item classification, scoring, candidate-set computation | Pure (provably — never touches `CreateMacro`/`EditMacro`/`DeleteMacro`/`RunMacro`/`EditMacroByID`) |
| **Macro firewall** | `MacroManager.lua` | Body assembly, fingerprint cache, combat-deferred write queue | **Sole caller** of `CreateMacro` (`MacroManager.lua:260`) and `EditMacro` (`MacroManager.lua:271`) |
| UI widgets | `KCM*.lua` | AceGUI custom widgets | Pure (read-only `PickupMacro` in `KCMMacroDragIcon` only — that is unprotected) |
| Settings | `settings/*` | Blizzard Settings canvas + raw AceGUI body | Pure |
| Slash | `SlashCommands.lua`, `Slash/*` | AceConsole dispatcher, schema CLI, sub-namespace verbs | Pure (calls into `KCM.Pipeline` and `KCM.MacroManager.InvalidateState`; never the protected APIs directly) |

### 3.3 Macro firewall — invariant statement and remediation guarantee

**Invariant (preserved):** Only `MacroManager.lua` calls `CreateMacro` or `EditMacro`. `DeleteMacro` is never called anywhere. Every other module is provably pure with respect to protected-macro APIs.

**Lint enforcement (added by CM-2):** `.luacheckrc` declares `CreateMacro`, `EditMacro`, `DeleteMacro` as `read_globals` with a per-file write/use override that allows them only in `MacroManager.lua`. Any other file referencing them produces a luacheck violation with code `113`. The check runs on every commit (per §14).

**Why each in-scope CM step preserves the firewall:**

- **CM-5 (SlashCommands peel)** — none of the new `Slash/*.lua` files call `CreateMacro`/`EditMacro`. The peel is by sub-verb (priority, stat, aio, dump, schema CLI) — every existing call into the firewall is via `KCM.MacroManager.InvalidateState` (which is itself a non-protected helper that nukes fingerprint state). Preserved.
- **CM-12 (async reset)** — replacing `Pipeline.Recompute` with `Pipeline.RequestRecompute` *strengthens* the firewall by removing a transitively-synchronous protected-API call from the reset path. Preserved.
- **CM-13 (embeds.xml removal)** — pure load-mechanism change; no API calls move. Preserved.
- **CM-4 (migration runner)** — runs once at OnInitialize before any pipeline tick. Pure DB mutation. Preserved.
- **CM-7 (AceConsole)** — already done (`Core.lua:65-66`). No change to call graph. Preserved.

### 3.4 Data flow

```
                         events (PEW, BAG_UPDATE_DELAYED,
                          PLAYER_SPECIALIZATION_CHANGED, GIIR,
                          LEARNED_SPELL_IN_SKILL_LINE)
                                    │
                                    ▼
                    KCM.Pipeline.RequestRecompute(reason)
                         (frame-coalesced; one C_Timer.After(0))
                                    │
                                    ▼
                    KCM.Pipeline.Recompute(reason)
                                    │
                                    ▼
       ┌────────────────────────────┼────────────────────────────┐
       │                            │                            │
       ▼                            ▼                            ▼
  BagScanner ──▶ Classifier ──▶ Ranker ──▶ Selector ──▶ MacroManager ★
   (pure)         (pure)        (pure)     (pure)         (firewall)
                                                              │
                                                              ▼
                                              CreateMacro / EditMacro
                                              (combat-deferred queue;
                                               PLAYER_REGEN_ENABLED flush)
```

One-way arrows. No module below the firewall ever calls back upward. CM-12 makes `KCM.ResetAllToDefaults` rejoin this same flow at the top via `RequestRecompute`, instead of bypassing the coalescer with a synchronous `Recompute` call.

---

## 4. LLD — Per-deviation design

### CM-1 Add `.pkgmeta`

**Current state:** File absent. Verified by `ls /mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/.pkgmeta` returning ENOENT.

**Target state:** New file at addon root.

```yaml
package-as: ConsumableMaster

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
  libs/AceEvent-3.0:
    url: https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0
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
  - docs
  - "*.bak"
  - _dev
```

**AceConfig-3.0 deliberately omitted** — paired with CM-6 deletion. **No `enable-toc-creation`** — single multi-Interface TOC.

**Migration steps:** Create file. Verify in repo root. Commit.

**Risks:** None. Curse/Wago packagers consume `.pkgmeta` only at upload; missing externals would currently show as commit-tracked libs.

**Verification:** `bigwigs-packager` dry run (or visual diff against `WowAddonStandards/standards/01_STANDARD.md` §13 template).

### CM-2 Add `.luacheckrc`

**Current state:** Absent.

**Target state:**

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "reviews/", ".claude/" }
ignore = {
  "212/self",
  "212/event",
  "11./_.*",
}
read_globals = {
  "_G", "LibStub",
  "CreateFrame", "GetTime", "time", "GetLocale",
  "InCombatLockdown", "C_Timer", "hooksecurefunc",
  "C_Container", "C_Item", "C_Spell", "C_TooltipInfo",
  "C_SpecializationInfo", "GetSpecialization",
  "GetSpellInfo", "GetItemInfo", "GetItemIcon",
  "Settings", "SettingsPanel",
  "StaticPopupDialogs", "StaticPopup_Show",
  "GameTooltip",
  "PickupMacro", "GetMacroIndexByName", "GetMacroInfo",
  "RunMacro", "EditMacroByID",
  "CopyTable", "YES", "NO",
  "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE",
}
globals = {
  "ConsumableMasterDB",
  "KCM",                  -- private namespace promoted to _G per addon convention
  "SLASH_KCM1", "SLASH_KCM2",  -- only if any direct SLASH_* survive (none expected post-CM-7)
}

-- Macro-firewall lint: only MacroManager.lua may call protected macro write APIs.
files["MacroManager.lua"] = {
  read_globals = { "CreateMacro", "EditMacro", "DeleteMacro" },
}
-- All other files inherit the top-level read_globals which deliberately
-- omits CreateMacro / EditMacro / DeleteMacro — luacheck will flag any
-- reference outside MacroManager.lua as code 113 (accessing undefined variable).
```

**Migration steps:** Create file. Run `luacheck .` and resolve any incidental warnings.

**Risks:** Luacheck may flag legitimate unused variables; quiet selectively with inline `-- luacheck: ignore` (do not bulk-suppress).

**Verification:** `luacheck .` exits 0 (or only with explicitly-acknowledged warnings).

### CM-3 TOC X-IDs

**Current state:** `ConsumableMaster.toc:1-12` lacks `X-Curse-Project-ID` and `X-Wago-ID`. README badge references CurseForge `1522944`.

**Target state:** Insert after `## X-License: MIT`:

```
## X-Curse-Project-ID: 1522944
## X-Wago-ID: <fetch from Wago listing or leave commented if not yet listed>
```

**Migration steps:** Confirm Wago project ID with the user before commit. If no Wago listing exists, omit the line; CM-3 is satisfied by adding what's available — the standard reads "mandatory if published", and the addon is published only on CurseForge today.

**Risks:** None — TOC-only metadata.

**Verification:** Open TOC in a packager validator.

### CM-4 SV migration runner

**Current state:** `Core.lua:27` declares `schemaVersion = 1` inside `dbDefaults.profile`. No code reads it. No migration body exists. When v2 lands, AceDB will rehydrate v1 SV directly into v2 defaults with no version check.

**Target state:** A new `KCM.Database:RunMigrations()` function in `Core.lua` (no separate `core/Database.lua` since we stay flat). Move `schemaVersion` from `profile` to `global` to match §5.1 (`global.schemaVersion`) — that's a breaking-but-safe move because the migration runner is the very thing that handles it.

```lua
-- Core.lua (NEW section, between dbDefaults and OnInitialize)

KCM.SCHEMA_VERSION = 1   -- bump when introducing a migration; must equal
                          -- the largest `if g.schemaVersion < N then` seen
                          -- in MIGRATIONS below.

KCM.dbDefaults.global = KCM.dbDefaults.global or {}
KCM.dbDefaults.global.schemaVersion = KCM.SCHEMA_VERSION

-- Migration registry. Each entry runs in order if g.schemaVersion < target.
-- Add an entry by appending {to = N, fn = function(g, p) ... end}. The
-- runner is idempotent: re-running it on an already-migrated DB is a no-op.
local MIGRATIONS = {
  -- Example future entry (intentionally not yet active):
  -- { to = 2, fn = function(g, p)
  --     -- p.categories.NEW_CAT = { added = {}, ... }
  -- end },
}

function KCM:RunMigrations()
    if not (self.db and self.db.global and self.db.profile) then return end
    local g = self.db.global
    local p = self.db.profile

    -- One-time relocation: schemaVersion lived under profile in 1.4.0.
    -- If a v1 SV is loaded under the new code, hoist it into global so
    -- subsequent boots find it on the standard path.
    if p.schemaVersion and not g.schemaVersion then
        g.schemaVersion = p.schemaVersion
    end
    p.schemaVersion = nil       -- clean up legacy field
    g.schemaVersion = g.schemaVersion or 1

    for _, m in ipairs(MIGRATIONS) do
        if g.schemaVersion < m.to then
            local ok, err = pcall(m.fn, g, p)
            if ok then
                g.schemaVersion = m.to
                if KCM.Debug and KCM.Debug.Print then
                    KCM.Debug.Print("Migration to v%d applied", m.to)
                end
            else
                if KCM.Debug and KCM.Debug.Print then
                    KCM.Debug.Print("Migration to v%d FAILED: %s — aborting further migrations", m.to, tostring(err))
                end
                return
            end
        end
    end
end
```

Call site in `OnInitialize` immediately after AceDB:New:

```lua
function KCM:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ConsumableMasterDB", KCM.dbDefaults, true)
    self:RunMigrations()
    self:RegisterChatCommand("cm", "OnSlashCommand")
    self:RegisterChatCommand("consumablemaster", "OnSlashCommand")
    if KCM.Debug and KCM.Debug.Print then
        KCM.Debug.Print("Initialized (version %s, schemaVersion=%d, debug=%s)",
            KCM.VERSION, self.db.global.schemaVersion, tostring(self.db.profile.debug))
    end
end
```

**Function signature:** `KCM:RunMigrations() -> nil`. No return value. Idempotent. Failure of one migration aborts the chain (do not skip-ahead) so the user can be told to /reload after a fix lands.

**Version constants:** `KCM.SCHEMA_VERSION` (Lua constant, single source of truth) — must equal the highest `to =` in `MIGRATIONS`. CI-style check: `KCM.SCHEMA_VERSION` is asserted equal to `MIGRATIONS[#MIGRATIONS] and MIGRATIONS[#MIGRATIONS].to or 1` on first boot via `KCM.Debug.Print`. (Soft check; do not error on mismatch — it would brick a load.)

**How new fields get added without breaking v1 SVs:**

- New defaults in `dbDefaults.profile.<path>` are picked up automatically by AceDB; no migration needed for additive scalar/table additions.
- Renames or moves require an explicit migration entry. Pattern:
  ```lua
  { to = 2, fn = function(g, p)
      if p.categories.OLD then
          p.categories.NEW = p.categories.OLD
          p.categories.OLD = nil
      end
  end },
  ```
- Schema deletions follow the same pattern; never delete in-place without a migration.

**Migration steps:** Add `KCM.SCHEMA_VERSION` constant, `MIGRATIONS` registry (empty), `RunMigrations` body, and OnInitialize wiring. Move `schemaVersion = 1` from profile defaults to global defaults.

**Risks:** Existing v1 SVs have `profile.schemaVersion`. The hoist-and-clear logic above handles it. If a user reloads with a partial SV (corrupted shutdown), `RunMigrations` no-ops cleanly because AceDB defaults backfill missing tables before our function runs.

**Verification:** Manual smoke — load with a fresh DB; check `/cm dump db.global.schemaVersion` returns 1. Load with a 1.4.0 DB on disk; verify hoist clears `profile.schemaVersion` and global gets `1`. Add a no-op `to = 2` migration locally, reload, verify it runs once and only once.

### CM-5 Peel `SlashCommands.lua` (1257 LOC → ~250 LOC + 5 sub-files)

**Current state:** All slash logic in `SlashCommands.lua` at 1257 LOC. Function map (verified):

| LOC | Function |
|---|---|
| 1-49 | Header, prefix helper, `KCM_CONFIRM_RESET` popup |
| 50-100 | `trim`/`tokenize`/`lowerFirst`/`findCommand`/`afterMutation` |
| 101-509 | (interleaved) parsing helpers, format helpers |
| 509-608 | `dumpDispatch` + DUMP_TARGETS |
| 609-829 | `listSettings`, `getSetting`, `setSetting` (schema-driven verbs) |
| 830-961 | `runPriority` |
| 962-1123 | `runStat` |
| 1124-1145 | `runAIO` |
| 1147-1257 | COMMANDS table, ALIASES, `printHelp`, `OnSlashCommand` |

**Target state:** Five new sub-files under `Slash/`. `SlashCommands.lua` reduced to dispatcher + COMMANDS table + popup. **All sub-files use the established module-publishing idiom** so load order doesn't matter as long as `SlashCommands.lua` loads last.

| File | Lines (target) | Contents |
|---|---|---|
| `Slash/Schema.lua` | ~230 | `listSettings`, `getSetting`, `setSetting` (the schema-CLI verbs). Exports `KCM.SlashCommands.Schema = { List = ..., Get = ..., Set = ... }`. |
| `Slash/Priority.lua` | ~140 | `runPriority` and its helpers. Exports `KCM.SlashCommands.Priority.Run`. |
| `Slash/Stat.lua` | ~165 | `runStat` and its helpers. Exports `KCM.SlashCommands.Stat.Run`. |
| `Slash/AIO.lua` | ~30 | `runAIO`. Exports `KCM.SlashCommands.AIO.Run`. |
| `Slash/Dump.lua` | ~110 | `dumpDispatch` + DUMP_TARGETS. Exports `KCM.SlashCommands.Dump.Run`. |
| `SlashCommands.lua` | ~280 | Header, popup, common parsing helpers (`trim`, `tokenize`, `lowerFirst`, `findCommand`, `say`, `afterMutation`), COMMANDS table referencing the sub-modules, `printHelp`, `OnSlashCommand`. |

**Idiom for each sub-file:**

```lua
-- Slash/Priority.lua
local KCM = _G.KCM
KCM.SlashCommands = KCM.SlashCommands or {}
KCM.SlashCommands.Priority = KCM.SlashCommands.Priority or {}
local P = KCM.SlashCommands.Priority

local function say(s) print("|cff00ffff[CM]|r " .. s) end
-- ... helpers ...

function P.Run(rest) ... end  -- moved body of `runPriority`
```

`SlashCommands.lua` then references it:

```lua
{"priority", "Per-category priority list editor",
    function(rest) KCM.SlashCommands.Priority.Run(rest) end},
```

Common helpers (`say`, `tokenize`, ...) are duplicated trivially across sub-files (one `local function say(s)` per file) rather than published — keeps each file standalone and the duplication is ≤5 LOC each.

**TOC additions** (after `SlashCommands.lua`... no, **before** it — sub-files must load first):

```
Slash\Schema.lua
Slash\Priority.lua
Slash\Stat.lua
Slash\AIO.lua
Slash\Dump.lua
SlashCommands.lua
```

**Tier-1 `Slash/` subfolder is permitted** because `Slash/` carries 5 files — pushing the Tier 1 ceiling. If a 6th slash sub-file is ever added, **promote the addon to Tier 2** (CLAUDE.md update flagged in CM-9 acceptance).

**Migration steps (M8 in execution plan):**

1. Create `Slash/Schema.lua`. Move `listSettings`, `getSetting`, `setSetting` and their helpers verbatim. Verify `/cm list`, `/cm get`, `/cm set` work in-game.
2. Create `Slash/Priority.lua`. Move `runPriority` + helpers. Smoke-test `/cm priority FOOD list`.
3. Repeat for `Stat.lua`, `AIO.lua`, `Dump.lua` in that order.
4. After all five, `SlashCommands.lua` is reduced to dispatcher only. Verify line count <300. Verify no duplicate symbol definitions.
5. Update TOC.
6. Update `docs/module-map.md` and `ARCHITECTURE.md` to mention `Slash/` peel.

**Risks (macro-firewall preservation):**

- The peel only moves *pure dispatch* code. None of the moved verbs touch `CreateMacro`/`EditMacro`. The only protected-API-adjacent call is `KCM.MacroManager.InvalidateState` (a fingerprint-cache clear, not a Blizzard API), which stays in `SlashCommands.lua`'s `rewritemacros` verb where it already lives. Firewall preserved.
- Forward-decl `printHelp` currently defined in `SlashCommands.lua:1145` is referenced by COMMANDS[1].fn — keep both in `SlashCommands.lua`.
- `afterMutation(reason)` (line 81) is shared by all four panel-mutating sub-files (Priority, Stat, AIO). Two options: (a) duplicate per file, (b) publish on `KCM.SlashCommands.afterMutation`. Choose (b) — single canonical mutation funnel matches the addon's pattern.

**Verification (per peel step):**

- File loads without error (`/cm version` returns 1.4.0).
- The moved verb behaves identically to pre-peel (smoke test from `docs/smoke-tests.md`).
- `wc -l SlashCommands.lua` ≤ 300 after final step.
- `luacheck .` clean.

### CM-6 Remove embedded-but-unused `AceConfig-3.0`

**Current state:** `embeds.xml:12` includes `libs/AceConfig-3.0/AceConfig-3.0.xml`. No production code references `AceConfig` / `AceConfigDialog` / `AceConfigRegistry` / `AceConfigCmd` (verified by grep across non-`libs/` paths).

**Target state:** `libs/AceConfig-3.0/` directory deleted. (CM-13 will eliminate `embeds.xml` entirely; if CM-13 lands first, just delete the lib dir.)

**Migration steps:** `git rm -r libs/AceConfig-3.0/`. Drop the line from `embeds.xml` (until CM-13 removes the file).

**Risks:** None. Confirmed unreferenced.

**Verification:** `/reload` succeeds; `/cm config` opens panel; `grep -rn AceConfig ConsumableMaster/ --include='*.lua'` returns no production hits (only review docs).

### CM-7 AceConsole `:RegisterChatCommand`

**Current state:** Already done. `Core.lua:65-66`:

```lua
self:RegisterChatCommand("cm", "OnSlashCommand")
self:RegisterChatCommand("consumablemaster", "OnSlashCommand")
```

The deviation entry in `03_DEVIATIONS.md` flags CM-7 as needing migration, but the raw report (`_raw/ConsumableMaster.md` §8) and the source confirm AceConsole is already used. **No code change required** — verify and document closure in the execution plan.

**Verification:** `grep -n "RegisterChatCommand\|SLASH_KCM" Core.lua SlashCommands.lua` shows AceConsole only.

### CM-8 Locale module shell

**Current state:** No `Locale.lua`. Hardcoded English literals across UI/slash code (intentional per `CLAUDE.md` "English-only").

**Target state:** Add `Locale.lua` shell that exposes `KCM.L` with metatable fallback (per §8.1). The body is empty; standard requires the *shell*, not translated strings.

```lua
-- Locale.lua — minimal locale shell. The addon is English-only by design
-- (see CLAUDE.md "Hard rules"); this file exists so that future selective
-- translation can opt-in by populating L without restructuring callers.
--
-- Pattern: missing keys return the key itself so unkeyed strings keep
-- rendering verbatim. Replaces AceLocale strict mode.

local KCM = _G.KCM
KCM.L = KCM.L or setmetatable({}, { __index = function(_, k) return k end })
local L = KCM.L

-- Intentionally empty. Add entries in PRs that translate specific user-
-- facing strings; do not bulk-translate without a paired source-string
-- audit. Keys are the English source string verbatim (per §8.2).

-- Example (do not enable without a translation pass):
-- L["Reset all priorities"] = "Reset all priorities"
```

**TOC:** Insert after `Debug.lua`:

```
Debug.lua
Locale.lua

defaults\Categories.lua
...
```

**Migration steps:** Create file. Add to TOC. Do **not** bulk-replace English literals with `L["..."]` — out of scope per `CLAUDE.md` invariant.

**Risks:** None.

**Verification:** `/cm version` works (sanity); `print(KCM.L["foo"])` returns `"foo"` (metatable fallback works).

### CM-9 `Compat.lua` shell

**Current state:** No `Compat.lua`. Defensive forward-compat patterns are scattered (`MacroManager.spellNameFor` 53-68; `Classifier` 127-133; `KCMItemRow` 80-91).

**Target state:** Add `Compat.lua` with project flags and shimmed accessors. Existing call-site shims stay where they are for now (refactor out of scope); new code MUST go through `Compat`.

```lua
-- Compat.lua — deprecated-API shims and project-flavor flags. Every
-- new deprecated-API call site MUST route through here. Existing
-- in-place fallbacks (MacroManager.spellNameFor, Classifier subType
-- branch, KCMItemRow name fallback) are grandfathered until their
-- next significant refactor.

local KCM = _G.KCM
KCM.Compat = KCM.Compat or {}
local Compat = KCM.Compat

Compat.IsRetail  = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Compat.IsClassic = not Compat.IsRetail

function Compat.GetSpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        if info then return info.name end
    end
    return GetSpellInfo and GetSpellInfo(id)
end

function Compat.GetSpecialization()
    return (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization
            and C_SpecializationInfo.GetSpecialization())
        or (GetSpecialization and GetSpecialization())
end
```

**TOC:** Insert after `Locale.lua`. Compat must load before any module that calls into it; placing it directly after `Debug.lua` / `Locale.lua` and before `defaults/` is the safe choice. Final TOC order shown in §5 below.

**Migration steps:** Create file. Add to TOC.

**Risks:** None.

**Verification:** Reload; `print(KCM.Compat.IsRetail)` returns `true` on Midnight.

### CM-10 README `/cm enable` doc drift

**Current state:** `README.md:172` documents `/cm enable` as a 1.4.0 verb. The COMMANDS table (`SlashCommands.lua:1147-1214`) has no `enable` entry. Master toggle is reachable only via `/cm set enabled true|false`.

**Target state:** Two acceptable resolutions; **pick (a)** because it minimizes user surprise and matches the schema-driven path.

**(a) Fix the docs (recommended).** Edit `README.md:172`:

> **Added**: master enable toggle (`/cm set enabled true|false`, Settings → General); ...

**(b) Add the verb.** Insert into COMMANDS in `SlashCommands.lua` after `"set"`:

```lua
{"enable",  "Enable the addon (`/cm enable` ↔ `/cm set enabled true`)",
    function() KCM.Settings.Helpers.SetAndRefresh("enabled", true) end},
{"disable", "Disable the addon (master toggle off)",
    function() KCM.Settings.Helpers.SetAndRefresh("enabled", false) end},
```

Either eliminates the drift. The execution plan picks (a).

**Migration steps:** README edit only.

**Risks:** None.

**Verification:** `wow-addon:sync-docs` skill reports zero drift between README and COMMANDS table.

### CM-11 `docs/module-map.md` stale exports

**Current state:** Per `03_DEVIATIONS.md` CM-11, `docs/module-map.md` lists exports that do not exist (e.g. `HasPending`, `IsPending`, `Stats`, `MakeCheckbox`). Verified — searching the current source for `HasPending` / `PendingCount` / `IsAdopted` / `IsPending` / `MakeCheckbox` / `SchemaForPanel` returns no definitions (only the doc references the audit picked up from a prior version).

Reviewing the *current* `docs/module-map.md` shows it has actually been **mostly cleaned up** since the audit — the visible exports for MacroManager, Selector, Ranker, Classifier, BagScanner, TooltipCache, SpecHelper, Settings, and Debug all match real functions in the current source. The remaining drift to verify and fix is small.

**Target state:** Run `wow-addon:sync-docs` skill. Hand-verify the `## Public APIs` section line by line against the current source. Delete any entry whose function-definition site cannot be located.

**Migration steps:**

1. Run `/wow-addon:sync-docs` from the addon directory.
2. Diff the proposed changes; accept those that delete dead exports, reject anything that adds invented surface.
3. Manually scan for these specific suspects: `HasPending`, `PendingCount`, `IsAdopted`, `IsPending`, `PendingIDs`, `Stats`, `GetAllItemIDs`, `MakeCheckbox`, `SchemaForPanel`. Delete any survivor.
4. Add a new `Slash/` subsection covering the peel from CM-5.

**Risks:** Skill may reformat sections — review carefully, the doc has hand-tuned ASCII diagrams.

**Verification:** Every `KCM.<Module>.<fn>` listed in the doc has a matching `function KCM.<Module>.<fn>` in source.

### CM-12 Async `KCM.ResetAllToDefaults`

**Current state:** `Core.lua:282`:

```lua
if KCM.Pipeline and KCM.Pipeline.Recompute then
    KCM.Pipeline.Recompute(reason)
end
```

Calls `Recompute` synchronously rather than `RequestRecompute`. The block comment at `Core.lua:255-265` explicitly justifies it as "user clicked reset and expects refresh now" but admits it's only safe by transitive contract.

**Target state:** Replace with `RequestRecompute` for consistency with every other call site, and rely on `KCM.Options.Refresh()` (synchronous) to give the user immediate panel feedback.

```lua
function KCM.ResetAllToDefaults(reason)
    if not (KCM.db and KCM.db.profile) then return false end
    local defaults = KCM.dbDefaults and KCM.dbDefaults.profile or {}
    KCM.db.profile.categories   = CopyTable(defaults.categories or {})
    KCM.db.profile.statPriority = CopyTable(defaults.statPriority or {})
    reason = reason or "reset_all"
    if KCM.TooltipCache and KCM.TooltipCache.InvalidateAll then
        KCM.TooltipCache.InvalidateAll()
    end
    if KCM.Pipeline and KCM.Pipeline.RunAutoDiscovery then
        KCM.Pipeline.RunAutoDiscovery(reason)
    end
    -- Was: Pipeline.Recompute (synchronous). Switching to RequestRecompute
    -- removes a transitively-synchronous protected-API call from this path
    -- and keeps every recompute coalesced through the same coroutine.
    if KCM.Pipeline and KCM.Pipeline.RequestRecompute then
        KCM.Pipeline.RequestRecompute(reason)
    end
    -- Refresh the panel immediately so the user sees the reset reflected
    -- without waiting for the deferred recompute to land.
    if KCM.Options and KCM.Options.Refresh then
        KCM.Options.Refresh()
    end
    return true
end
```

**Migration steps:** Edit `Core.lua:269-285`. Update the comment block at `Core.lua:255-265` to reflect the new semantics.

**Risks:** A brief flicker between panel refresh (immediate) and macro rewrite (one frame later). Acceptable — macros are not user-visible during the inter-frame.

**Verification:** `/cm reset` → confirm popup → panel rebuilds, macros rewrite within ~1 frame, no taint pop.

### CM-13 Eliminate `embeds.xml`

**Current state:** `ConsumableMaster.toc:12` references `embeds.xml`. `embeds.xml:5-12` `<Script>`/`<Include>`s seven Ace3 lib XMLs (post-CM-6, six). No addon `.lua` is loaded via XML. No XML widget templates exist outside the lib dirs themselves.

**Target state:** Delete `embeds.xml`. Replace with TOC-direct lib loads.

**TOC change** — replace the `embeds.xml` line with the lib chain:

```
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
libs\AceEvent-3.0\AceEvent-3.0.lua
libs\AceDB-3.0\AceDB-3.0.lua
libs\AceConsole-3.0\AceConsole-3.0.lua
libs\AceGUI-3.0\AceGUI-3.0.xml
```

**Note:** `AceGUI-3.0` ships widget templates as XML; its `.xml` IS its primary loader. Loading `AceGUI-3.0.xml` directly from TOC works (the TOC supports `.xml`). **AceGUI is the lone XML survivor.** Every other library has a `.lua` entry point that internally `require`s its widget files; switch to those `.lua` paths.

**Verification of "no XML-only widget references":** Search confirms — every `KCM*.lua` widget is registered via `AceGUI:RegisterWidgetType("...", constructor, version)` (`KCMIconButton.lua:145`, `KCMScoreButton.lua:115`, `KCMMacroDragIcon.lua:179`, `KCMItemRow.lua:311`). None use `<Frame inherits="...">` XML templates. `embeds.xml` carries zero per-addon UI.

**Migration steps:**

1. Edit `ConsumableMaster.toc`: replace `embeds.xml` line with seven lib lines (six libs + AceGUI XML).
2. `git rm embeds.xml`.
3. Reload in-game.
4. Verify `/cm config` opens (AceGUI loaded), `/cm set debug true` works (AceConsole+AceDB loaded), pipeline runs (AceEvent+AceAddon loaded).

**Risks:** Lib load order matters: LibStub → CallbackHandler → AceAddon (depends on CallbackHandler) → AceEvent (depends on AceAddon's CallbackHandler) → AceDB → AceConsole → AceGUI. Get this wrong → `LibStub("X")` returns nil and the addon errors at file-load. The TOC list above already encodes the correct order.

**Verification:** `/reload`; `/cm version`; open settings; toggle `/cm debug`; touch macro pool to trigger recompute.

### CM-14 Delete dead `KCM.Options.Register`

**Current state:** `settings/Panel.lua:736-739`:

```lua
function O.Register()
    registerPanel()
    return KCM.Settings.main ~= nil
end
```

`Core.lua:67-69` is comment-only — never calls `O.Register`. The bootstrap frame at `settings/Panel.lua:823-832` is the only registration path. `O.Register` is dead public surface.

**Target state:** Delete the `O.Register` function. Audit for callers (verified none in production source). Update `docs/module-map.md` `### Settings panel` section to drop the `KCM.Options.Register()` line.

**Migration steps:** Delete the four-line function. Verify `/cm config` still opens panel (it relies on `O.Open`, not `O.Register`).

**Risks:** None. Confirmed unreferenced.

**Verification:** `grep -rn "Options\.Register\|O\.Register" ConsumableMaster/ --include='*.lua'` returns no production hits.

---

## 5. Cross-cutting

### 5.1 Final TOC layout (post-remediation)

```
## Interface: 120000,120001,120005
## Title: Ka0s Consumable Master
## Notes: Auto-managed account-wide consumable macros.
## Author: Ka0s
## Version: 1.5.0
## SavedVariables: ConsumableMasterDB
## IconTexture: Interface\Icons\inv_cooking_100_roastduck
## DefaultState: enabled
## Category-enUS: Action Bars & Buttons
## X-License: MIT
## X-Curse-Project-ID: 1522944
## X-Wago-ID: <fill in or omit>

# Libs (was: embeds.xml — CM-13)
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
libs\AceEvent-3.0\AceEvent-3.0.lua
libs\AceDB-3.0\AceDB-3.0.lua
libs\AceConsole-3.0\AceConsole-3.0.lua
libs\AceGUI-3.0\AceGUI-3.0.xml

# Bootstrap
Core.lua
Compat.lua
Locale.lua
Debug.lua

# Defaults (data)
defaults\Categories.lua
defaults\Defaults_StatPriority.lua
defaults\Defaults_Food.lua
defaults\Defaults_Drink.lua
defaults\Defaults_StatFood.lua
defaults\Defaults_HPPot.lua
defaults\Defaults_MPPot.lua
defaults\Defaults_Healthstone.lua
defaults\Defaults_CombatPot.lua
defaults\Defaults_Flask.lua

# Pure runtime modules
SpecHelper.lua
TooltipCache.lua
BagScanner.lua
Classifier.lua
Ranker.lua
Selector.lua
MacroManager.lua

# AceGUI custom widgets
KCMIconButton.lua
KCMScoreButton.lua
KCMMacroDragIcon.lua
KCMItemRow.lua

# Settings UI
settings\Panel.lua
settings\General.lua
settings\StatPriority.lua
settings\Category.lua

# Slash sub-modules (CM-5 peel)
Slash\Schema.lua
Slash\Priority.lua
Slash\Stat.lua
Slash\AIO.lua
Slash\Dump.lua

# Slash dispatcher (last so it sees every sub-module)
SlashCommands.lua
```

### 5.2 SV migration runner (CM-4) — design summary

- Single source of truth: `KCM.SCHEMA_VERSION` constant in `Core.lua`.
- `KCM.dbDefaults.global.schemaVersion` mirrors it; AceDB backfills missing.
- One-time hoist of legacy `profile.schemaVersion` → `global.schemaVersion`, then clear.
- Ordered `MIGRATIONS` list of `{to = N, fn = function(g, p) end}` entries.
- Runner advances `g.schemaVersion` after each successful migration; aborts the chain on failure.
- Idempotent: replays on the already-current version are no-ops.

### 5.3 Doc reconciliation (CM-10, CM-11)

- **README.md:** single line edit at `:172` replacing `/cm enable` with `/cm set enabled true|false`.
- **docs/module-map.md:** run `/wow-addon:sync-docs`. Hand-verify zero drift after; specifically search for the audited dead exports listed in `_raw/ConsumableMaster.md §18`.
- **ARCHITECTURE.md:** add the `Slash/` peel to the load-order list; add a one-line note about the migration runner under "SavedVariables".
- **CLAUDE.md:** add a short "Slash sub-modules" paragraph under "Module publishing pattern" pointing to `Slash/`.
- **Skill:** `wow-addon:sync-docs` does the heavy lifting; review and edit hand.

### 5.4 SlashCommands peel plan (CM-5) — at a glance

| File | LOC budget | Public symbol |
|---|---|---|
| `Slash/Schema.lua` | ≤230 | `KCM.SlashCommands.Schema.{List, Get, Set}` |
| `Slash/Priority.lua` | ≤140 | `KCM.SlashCommands.Priority.Run` |
| `Slash/Stat.lua` | ≤165 | `KCM.SlashCommands.Stat.Run` |
| `Slash/AIO.lua` | ≤30 | `KCM.SlashCommands.AIO.Run` |
| `Slash/Dump.lua` | ≤110 | `KCM.SlashCommands.Dump.Run` |
| `SlashCommands.lua` | ≤300 | `KCM:OnSlashCommand`, `KCM.SlashCommands.{PrintHelp, GetCommandSummary, afterMutation}` |

Total: ≤975 LOC across six files (vs 1257 in one). Largest: `SlashCommands.lua` ≤300, well under the 1500 cap and 1000-warning thresholds.

---

## 6. Out of scope

- **Classification logic.** Subtype-rename or tooltip-pattern fixes are content-driven (see `docs/midnight-quirks.md`).
- **Ranker scoring.** Stat-priority weight tuning, immediate-vs-HOT pot rebalancing.
- **Item DB.** `defaults/Defaults_*.lua` seed updates are quarterly maintenance.
- **Tier-2 layout promotion.** Defer until non-data, non-settings files exceed 8.
- **Locale translations.** Shell only; no en-loc opt-out planned.
- **Object pooling, hot-path upvalue cache, public API surface.** No current driver.

---

## 7. Acceptance criteria

The remediation is complete when all of the following hold simultaneously on a clean checkout of `master` after merge:

1. **Files exist:** `.pkgmeta`, `.luacheckrc`, `Compat.lua`, `Locale.lua`, `Slash/Schema.lua`, `Slash/Priority.lua`, `Slash/Stat.lua`, `Slash/AIO.lua`, `Slash/Dump.lua`. **Files do not exist:** `embeds.xml`, `libs/AceConfig-3.0/`.
2. **Lint passes:** `luacheck .` exits 0 with no `113` errors. The macro-firewall rule confirms `CreateMacro`/`EditMacro` references appear ONLY in `MacroManager.lua`.
3. **Macro firewall preserved:** `grep -rn 'CreateMacro\|EditMacro\|DeleteMacro' --include='*.lua'` (excluding `libs/` and `reviews/`) returns hits in `MacroManager.lua` only. `DeleteMacro` returns no hits anywhere.
4. **TOC published:** `## X-Curse-Project-ID: 1522944` present. `## X-Wago-ID:` present (or explicitly absent with confirmation no Wago listing exists).
5. **SV migration:** Loading the addon with a 1.4.0 SaveVariables snapshot produces a working v2-shape DB with `g.schemaVersion = 1`; `profile.schemaVersion` is removed; no data loss in `categories`, `statPriority`, `macroState`.
6. **Slash UX matches docs:** Either `/cm enable` exists (option b) OR README references `/cm set enabled true|false` (option a). README–COMMANDS parity is exact.
7. **Docs in sync:** `wow-addon:sync-docs` reports zero drift. Every `KCM.<Module>.<fn>` listed in `docs/module-map.md` resolves to a real function definition.
8. **Smoke tests pass:** `docs/smoke-tests.md` "quick smoke" passes end-to-end.
9. **Reset path:** `/cm reset` triggers the popup; on accept, the panel refreshes immediately and macros rewrite within one frame; no taint warnings on a clean retail client.
10. **Version bumped:** TOC `## Version:`, `KCM.VERSION` in `Core.lua`, README badge / Version History header all read the next minor (`1.5.0`).

When all ten hold, ConsumableMaster is fully aligned with `01_STANDARD.md` v1.0.

---

**End of TECHNICAL_DESIGN_ConsumableMaster.md**
