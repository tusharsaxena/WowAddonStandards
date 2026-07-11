# Execution Plan — ConsumableMaster Remediation

**Addon:** Ka0s Consumable Master
**Source:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/`
**Standard:** `_standards/2026-05-03/03_STANDARDS.md` v1.0
**Design doc:** `./TECHNICAL_DESIGN_ConsumableMaster.md`
**Deviations covered:** CM-1 .. CM-14
**Next minor:** 1.4.0 → 1.5.0

**Working agreement:**
- Each task is independently committable. Use `/wow-addon:commit` per task or batch within a milestone.
- Smoke-test playbook: `docs/smoke-tests.md`. Run "quick smoke" at every Checkpoint.
- Macro firewall is sacrosanct. After every milestone run:
  ```
  grep -rn 'CreateMacro\|EditMacro\|DeleteMacro' --include='*.lua' \
      ConsumableMaster/ | grep -v libs/ | grep -v reviews/
  ```
  Expect: hits only in `MacroManager.lua`. Zero hits for `DeleteMacro`.
- Do NOT bump version until M9. Version bump is the user's call (per `CLAUDE.md`).

---

## M1 — Tooling baseline (CM-1, CM-2, CM-3)

Pure mechanical. Parallel-safe.

### M1.T1 — Add `.pkgmeta` (CM-1)

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/.pkgmeta` (new).
- [ ] **Step 1 — code:** Write the file with the exact body from `TECHNICAL_DESIGN §4 CM-1`. (Externals for LibStub, CallbackHandler, AceAddon, AceEvent, AceDB, AceConsole, AceGUI; ignore reviews/docs/.luacheckrc/.git*/_dev/*.bak. **No** AceConfig external.)
- [ ] **Step 2 — verify:** `cat .pkgmeta` matches design. `yamllint .pkgmeta` (if available) returns 0.
- [ ] **Step 3 — commit:** `git add .pkgmeta && git commit -m "Add .pkgmeta for packager externals (CM-1)"`.

### M1.T2 — Add `.luacheckrc` with macro-firewall lint (CM-2)

- [ ] **Files:** `/mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/.luacheckrc` (new).
- [ ] **Step 1 — code:** Write the file with the exact body from `TECHNICAL_DESIGN §4 CM-2`, including the `files["MacroManager.lua"]` per-file `read_globals` override that whitelists `CreateMacro`/`EditMacro`/`DeleteMacro` only there.
- [ ] **Step 2 — verify:** Run `luacheck .` from the addon root. Expect 0 errors. Triage warnings (acceptable) but ensure no `113/CreateMacro` or `113/EditMacro` outside `MacroManager.lua`. Fix any found.
- [ ] **Step 3 — commit:** `git add .luacheckrc && git commit -m "Add .luacheckrc with macro-firewall lint rule (CM-2)"`.

### M1.T3 — TOC X-IDs (CM-3)

- [ ] **Files:** `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Insert after `## X-License: MIT`:
  ```
  ## X-Curse-Project-ID: 1522944
  ## X-Wago-ID: <fill in if a Wago listing exists; otherwise omit this line>
  ```
  Confirm Wago project ID with the user; if no Wago listing exists, omit (per design CM-3).
- [ ] **Step 2 — verify:** `head -15 ConsumableMaster.toc` shows the new line(s). Reload in-game; addon loads without TOC parse error.
- [ ] **Step 3 — commit:** `git add ConsumableMaster.toc && git commit -m "Add X-Curse-Project-ID (and X-Wago-ID) to TOC (CM-3)"`.

**Checkpoint M1:** Run quick smoke (`docs/smoke-tests.md`). Run `luacheck .` and macro-firewall grep. All clean. STOP and verify.

---

## M2 — Compat + Locale scaffolds (CM-9, CM-8)

### M2.T1 — Add `Compat.lua` (CM-9)

- [ ] **Files:** `Compat.lua` (new); `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Write `Compat.lua` with the exact body from `TECHNICAL_DESIGN §4 CM-9` (publishes `KCM.Compat`, sets `IsRetail`/`IsClassic`, exposes `GetSpellName` and `GetSpecialization` shims). Add `Compat.lua` to TOC immediately after `Core.lua` (the line `Core.lua` is currently first in the bootstrap section — insert `Compat.lua` after it; design §5.1 shows final order).
- [ ] **Step 2 — verify:** Reload. `/run print(KCM.Compat.IsRetail)` returns `true` on Midnight. `/run print(KCM.Compat.GetSpecialization())` returns the current spec index. Run quick smoke.
- [ ] **Step 3 — commit:** `git add Compat.lua ConsumableMaster.toc && git commit -m "Add Compat.lua shell for deprecated-API shims (CM-9)"`.

### M2.T2 — Add `Locale.lua` (CM-8)

- [ ] **Files:** `Locale.lua` (new); `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Write `Locale.lua` with the exact body from `TECHNICAL_DESIGN §4 CM-8` (publishes `KCM.L` with metatable `__index = function(_, k) return k end`; intentionally empty body). Add `Locale.lua` to TOC after `Compat.lua`.
- [ ] **Step 2 — verify:** Reload. `/run print(KCM.L["Hello"])` returns `Hello` (key-fallback works). Run quick smoke.
- [ ] **Step 3 — commit:** `git add Locale.lua ConsumableMaster.toc && git commit -m "Add Locale.lua shell with metatable fallback (CM-8)"`.

**Checkpoint M2:** Quick smoke + macro-firewall grep + `luacheck .`. STOP and verify.

---

## M3 — Slash to AceConsole (CM-7)

### M3.T1 — Verify and document closure

- [ ] **Files:** No code change expected.
- [ ] **Step 1 — code:** None. AceConsole is already in use (`Core.lua:65-66`). Verify by reading those two lines.
- [ ] **Step 2 — verify:** `grep -n "RegisterChatCommand\|^SLASH_KCM\|^_G.SLASH" Core.lua SlashCommands.lua` confirms zero raw `SLASH_KCM*` entries; both commands go through AceConsole. `/cm version` works in-game.
- [ ] **Step 3 — commit:** No code commit. Mark CM-7 closed in `reviews/` notes and in this checklist.

**Checkpoint M3:** No code change — proceed to M4.

---

## M4 — SV migration runner (CM-4)

### M4.T1 — Add migration scaffolding

- [ ] **Files:** `Core.lua`.
- [ ] **Step 1 — code:** In `Core.lua`:
  - Move `schemaVersion = 1` from `KCM.dbDefaults.profile` (currently at `Core.lua:27`) to `KCM.dbDefaults.global = { schemaVersion = 1 }`. Insert the `global` block before the `profile` block in the defaults table, or alongside it.
  - Add the `KCM.SCHEMA_VERSION = 1` constant.
  - Add the `MIGRATIONS = {}` registry (empty initial body) and `function KCM:RunMigrations()` body. Use the verbatim code from `TECHNICAL_DESIGN §4 CM-4`, including the legacy-hoist (`if p.schemaVersion and not g.schemaVersion then g.schemaVersion = p.schemaVersion end; p.schemaVersion = nil`).
  - Insert `self:RunMigrations()` in `OnInitialize` immediately after `self.db = LibStub("AceDB-3.0"):New(...)` and before `self:RegisterChatCommand(...)`.
  - Update the `OnInitialize` debug print to include `schemaVersion`.
- [ ] **Step 2 — verify:**
  - Reload with a fresh DB (`/console reloadui` after wiping `WTF/.../ConsumableMasterDB.lua`). `/run print(KCM.db.global.schemaVersion)` → `1`. `/run print(KCM.db.profile.schemaVersion)` → `nil`.
  - Reload with a 1.4.0 DB on disk (manually edit SV file to keep `profile.schemaVersion = 1`). After reload, profile's value is `nil`, global's is `1`. No data loss in `categories`/`statPriority`/`macroState`.
  - Run quick smoke. Run `luacheck .` (clean).
- [ ] **Step 3 — commit:** `git add Core.lua && git commit -m "Add SV migration runner scaffolding (CM-4)"`.

**Checkpoint M4:** Run quick smoke + macro-firewall grep + `luacheck .`. STOP and verify.

---

## M5 — Lib cleanup (CM-6, CM-13)

### M5.T1 — Remove dead AceConfig (CM-6)

- [ ] **Files:** `libs/AceConfig-3.0/` (delete); `embeds.xml` (edit if M5.T2 hasn't yet eliminated it).
- [ ] **Step 1 — code:** `git rm -r libs/AceConfig-3.0/`. Open `embeds.xml`, delete line 12 (`<Include file="libs\AceConfig-3.0\AceConfig-3.0.xml"/>`).
- [ ] **Step 2 — verify:** Reload. `/cm config` opens panel. `grep -rn AceConfig --include='*.lua' ConsumableMaster/` returns hits ONLY in `reviews/` and `docs/` (no production source). Run quick smoke.
- [ ] **Step 3 — commit:** `git add -A libs/ embeds.xml && git commit -m "Remove unused AceConfig-3.0 lib (CM-6)"`.

### M5.T2 — Eliminate `embeds.xml` (CM-13)

- [ ] **Files:** `ConsumableMaster.toc`; `embeds.xml` (delete).
- [ ] **Step 1 — code:** Edit TOC: replace the line `embeds.xml` with the seven lib lines from `TECHNICAL_DESIGN §5.1`:
  ```
  libs\LibStub\LibStub.lua
  libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
  libs\AceAddon-3.0\AceAddon-3.0.lua
  libs\AceEvent-3.0\AceEvent-3.0.lua
  libs\AceDB-3.0\AceDB-3.0.lua
  libs\AceConsole-3.0\AceConsole-3.0.lua
  libs\AceGUI-3.0\AceGUI-3.0.xml
  ```
  Then `git rm embeds.xml`.
- [ ] **Step 2 — verify:** Reload. No "could not find" errors. `/run print(LibStub("AceAddon-3.0"))` returns a table. `/cm config` opens panel (AceGUI loaded). `/cm set debug true` works. Macro pool changes trigger pipeline (AceEvent + AceAddon working). Run quick smoke.
- [ ] **Step 3 — commit:** `git add -A ConsumableMaster.toc embeds.xml && git commit -m "Eliminate embeds.xml; load libs directly from TOC (CM-13)"`.

**Checkpoint M5:** Quick smoke + macro-firewall grep + `luacheck .`. Open settings panel + drag a macro. STOP and verify.

---

## M6 — Doc reconciliation (CM-10, CM-11)

### M6.T1 — README `/cm enable` fix (CM-10)

- [ ] **Files:** `README.md`.
- [ ] **Step 1 — code:** Edit `README.md:172`. Replace `master enable toggle (\`/cm enable\`, Settings → General)` with `master enable toggle (\`/cm set enabled true|false\`, Settings → General)`.
- [ ] **Step 2 — verify:** `grep -n "/cm enable" README.md` returns no hits. Open README and confirm 1.4.0 row reads cleanly.
- [ ] **Step 3 — commit:** `git add README.md && git commit -m "Fix README slash-verb drift (/cm enable → /cm set enabled) (CM-10)"`.

### M6.T2 — `docs/module-map.md` stale exports (CM-11)

- [ ] **Files:** `docs/module-map.md`; potentially `ARCHITECTURE.md`, `CLAUDE.md`.
- [ ] **Step 1 — code:** From the addon directory, run `/wow-addon:sync-docs`. Review proposed changes. Accept deletions of dead exports; reject any invented surface. Manually scan for and delete any of: `HasPending`, `PendingCount`, `IsAdopted`, `IsPending`, `PendingIDs`, `Stats`, `GetAllItemIDs`, `MakeCheckbox`, `SchemaForPanel`. (These were flagged in `_raw/ConsumableMaster.md §18`.)
- [ ] **Step 2 — verify:** For every `KCM.<Module>.<fn>` listed in `docs/module-map.md`, confirm a matching `function KCM.<Module>.<fn>` exists in source via `grep -n`. Zero unresolved entries.
- [ ] **Step 3 — commit:** `git add docs/module-map.md ARCHITECTURE.md CLAUDE.md && git commit -m "Reconcile docs with source; drop dead exports (CM-11)"`.

**Checkpoint M6:** Skim README, module-map, ARCHITECTURE, CLAUDE side-by-side with source. Drift = zero. STOP and verify.

---

## M7 — Per-addon polish (CM-12, CM-14)

### M7.T1 — Async `ResetAllToDefaults` (CM-12)

- [ ] **Files:** `Core.lua`.
- [ ] **Step 1 — code:** Replace lines 281-283 of `Core.lua`:
  ```lua
  if KCM.Pipeline and KCM.Pipeline.Recompute then
      KCM.Pipeline.Recompute(reason)
  end
  ```
  with:
  ```lua
  if KCM.Pipeline and KCM.Pipeline.RequestRecompute then
      KCM.Pipeline.RequestRecompute(reason)
  end
  if KCM.Options and KCM.Options.Refresh then
      KCM.Options.Refresh()
  end
  ```
  Update the comment block at `Core.lua:255-265` to note that the path now uses `RequestRecompute` and that the immediate panel `Refresh` provides user feedback while the macro rewrite is deferred to the next frame.
- [ ] **Step 2 — verify:** Reload. `/cm reset` → confirm popup → panel rebuilds within ~1 frame, macros rewrite within ~1 frame, no taint pop. Run quick smoke including the reset section.
- [ ] **Step 3 — commit:** `git add Core.lua && git commit -m "ResetAllToDefaults uses RequestRecompute (CM-12)"`.

### M7.T2 — Delete dead `O.Register` (CM-14)

- [ ] **Files:** `settings/Panel.lua`; `docs/module-map.md` (sync the public-API listing).
- [ ] **Step 1 — code:** Delete `settings/Panel.lua:736-739`:
  ```lua
  function O.Register()
      registerPanel()
      return KCM.Settings.main ~= nil
  end
  ```
  In `docs/module-map.md` "Settings panel" section, remove the line `KCM.Options.Register()`.
- [ ] **Step 2 — verify:** `grep -rn "Options\.Register\|O\.Register" --include='*.lua' ConsumableMaster/` returns no production hits. `/cm config` still opens panel (uses `O.Open`). Run quick smoke.
- [ ] **Step 3 — commit:** `git add settings/Panel.lua docs/module-map.md && git commit -m "Delete dead KCM.Options.Register public surface (CM-14)"`.

**Checkpoint M7:** Quick smoke + reset path + macro-firewall grep + `luacheck .`. STOP and verify.

---

## M8 — SlashCommands peel (CM-5)

The largest task. Each sub-step is independently committable and reverts cleanly. Per design §5.4, target LOC budgets per file.

**Pre-step:** Create `Slash/` folder.
- [ ] `mkdir -p ConsumableMaster/Slash`

### M8.T1 — Move common helper `afterMutation` to public surface

- [ ] **Files:** `SlashCommands.lua`.
- [ ] **Step 1 — code:** Change `local function afterMutation(reason)` (line 81) to `function KCM.SlashCommands.AfterMutation(reason)`. Update its one in-file call site (in `SlashCommands.lua`) accordingly. This makes it reachable from sub-files without duplicating the body.
- [ ] **Step 2 — verify:** Reload. `/cm priority FOOD add 12345` (any valid id) → panel refreshes. Quick smoke.
- [ ] **Step 3 — commit:** `git add SlashCommands.lua && git commit -m "Promote SlashCommands.afterMutation to public surface (CM-5 prep)"`.

### M8.T2 — Peel `Slash/Schema.lua` (list/get/set verbs)

- [ ] **Files:** `Slash/Schema.lua` (new); `SlashCommands.lua`; `ConsumableMaster.toc`.
- [ ] **Step 1 — code:**
  - Create `Slash/Schema.lua` with header:
    ```lua
    -- Slash/Schema.lua — schema-driven /cm list / get / set verbs.
    local KCM = _G.KCM
    KCM.SlashCommands = KCM.SlashCommands or {}
    KCM.SlashCommands.Schema = KCM.SlashCommands.Schema or {}
    local S = KCM.SlashCommands.Schema

    local PREFIX = "|cff00ffff[CM]|r "
    local function say(s) print(PREFIX .. s) end
    ```
  - Move `listSettings`, `getSetting`, `setSetting` (and their local helpers) verbatim from `SlashCommands.lua:609-829` into this file. Rename to `function S.List()`, `function S.Get(rest)`, `function S.Set(rest)`.
  - In `SlashCommands.lua`, delete the moved functions. Update COMMANDS rows for `list`/`get`/`set` to dispatch to `KCM.SlashCommands.Schema.{List, Get, Set}`.
  - Add `Slash\Schema.lua` to TOC immediately before `SlashCommands.lua`.
- [ ] **Step 2 — verify:** Reload. `/cm list`, `/cm get debug`, `/cm set debug true` all work. `wc -l Slash/Schema.lua` ≤ 230. `wc -l SlashCommands.lua` < pre-peel value. `luacheck .` clean.
- [ ] **Step 3 — commit:** `git add Slash/Schema.lua SlashCommands.lua ConsumableMaster.toc && git commit -m "Peel slash schema verbs to Slash/Schema.lua (CM-5)"`.

### M8.T3 — Peel `Slash/Priority.lua`

- [ ] **Files:** `Slash/Priority.lua` (new); `SlashCommands.lua`; `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Same pattern as T2. Move `runPriority` (and local helpers) from `SlashCommands.lua:830-961`. Rename to `function P.Run(rest)`. In `SlashCommands.lua`, the COMMANDS row for `priority` becomes `function(rest) KCM.SlashCommands.Priority.Run(rest) end`. Add to TOC.
- [ ] **Step 2 — verify:** `/cm priority`, `/cm priority FOOD list`, `/cm priority FOOD add <id>`, `/cm priority FOOD up <id>`, `/cm priority FOOD reset` all work. `wc -l Slash/Priority.lua` ≤ 140.
- [ ] **Step 3 — commit:** `git add Slash/Priority.lua SlashCommands.lua ConsumableMaster.toc && git commit -m "Peel /cm priority to Slash/Priority.lua (CM-5)"`.

### M8.T4 — Peel `Slash/Stat.lua`

- [ ] **Files:** `Slash/Stat.lua` (new); `SlashCommands.lua`; `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Move `runStat` (and helpers) from `SlashCommands.lua:962-1123`. Rename to `function St.Run(rest)`. Wire COMMANDS. Add to TOC.
- [ ] **Step 2 — verify:** `/cm stat`, `/cm stat 4_3 primary AGI`, `/cm stat 4_3 secondary CRIT,HASTE`, `/cm stat 4_3 reset` all work. `wc -l Slash/Stat.lua` ≤ 165.
- [ ] **Step 3 — commit:** `git add Slash/Stat.lua SlashCommands.lua ConsumableMaster.toc && git commit -m "Peel /cm stat to Slash/Stat.lua (CM-5)"`.

### M8.T5 — Peel `Slash/AIO.lua`

- [ ] **Files:** `Slash/AIO.lua` (new); `SlashCommands.lua`; `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Move `runAIO` from `SlashCommands.lua:1124-1145`. Rename to `function A.Run(rest)`. Wire COMMANDS. Add to TOC.
- [ ] **Step 2 — verify:** `/cm aio`, `/cm aio hp_aio list`, `/cm aio hp_aio toggle HS`, `/cm aio hp_aio reset` all work. `wc -l Slash/AIO.lua` ≤ 30.
- [ ] **Step 3 — commit:** `git add Slash/AIO.lua SlashCommands.lua ConsumableMaster.toc && git commit -m "Peel /cm aio to Slash/AIO.lua (CM-5)"`.

### M8.T6 — Peel `Slash/Dump.lua`

- [ ] **Files:** `Slash/Dump.lua` (new); `SlashCommands.lua`; `ConsumableMaster.toc`.
- [ ] **Step 1 — code:** Move `dumpDispatch` and `DUMP_TARGETS` from `SlashCommands.lua:509-608`. Rename entry point to `function D.Run(rest)`. Wire COMMANDS. Add to TOC.
- [ ] **Step 2 — verify:** `/cm dump`, `/cm dump pick FOOD`, `/cm dump pick hp_aio`, `/cm dump db.profile.categories.FOOD` all work. `wc -l Slash/Dump.lua` ≤ 110.
- [ ] **Step 3 — commit:** `git add Slash/Dump.lua SlashCommands.lua ConsumableMaster.toc && git commit -m "Peel /cm dump to Slash/Dump.lua (CM-5)"`.

### M8.T7 — Verify final shape

- [ ] **Step 1:** `wc -l SlashCommands.lua Slash/*.lua` — confirm:
  - `SlashCommands.lua` ≤ 300
  - Each `Slash/*.lua` within budget per design §5.4.
  - Total ≤ 975.
- [ ] **Step 2:** Macro-firewall grep — confirm hits only in `MacroManager.lua`.
- [ ] **Step 3:** Run full `docs/smoke-tests.md` suite, not just quick smoke. STOP and verify before M9.

**Checkpoint M8:** All slash verbs work; LOC budgets met; firewall preserved; full smoke clean. STOP and verify.

---

## M9 — Release prep

### M9.T1 — Version bump

- [ ] **Files:** `ConsumableMaster.toc`, `Core.lua`, `README.md`, `CLAUDE.md` (if version is referenced).
- [ ] **Step 1 — code:** Run `/wow-addon:version-bump 1.5.0`. Verify it touches:
  - `## Version: 1.5.0` in TOC.
  - `KCM.VERSION = "1.5.0"` in `Core.lua:8`.
  - README badge, README Version History new row at the top describing this release.
- [ ] **Step 2 — verify:** `grep -rn "1\.4\.0" --include='*.lua' --include='*.md' --include='*.toc' ConsumableMaster/` returns hits only in historical contexts (Version History prior rows; review docs).
- [ ] **Step 3 — commit:** Skill commits this. Verify commit message references 1.5.0.

### M9.T2 — Sync README + ARCHITECTURE + CLAUDE

- [ ] **Files:** `README.md`, `ARCHITECTURE.md`, `CLAUDE.md`.
- [ ] **Step 1 — code:** Run `/wow-addon:sync-docs`. Review and accept proposed changes that:
  - Add the `Slash/` peel to ARCHITECTURE load-order.
  - Add `Compat.lua` and `Locale.lua` to ARCHITECTURE module map.
  - Add the migration runner to ARCHITECTURE "SavedVariables" section.
  - Update CLAUDE.md "Module publishing pattern" to mention `Slash/`.
- [ ] **Step 2 — verify:** All four canonical docs (README, CLAUDE, ARCHITECTURE, plus `docs/module-map.md`) reference the new layout. Drift = zero.
- [ ] **Step 3 — commit:** Skill commits this.

### M9.T3 — Final smoke + acceptance

- [ ] **Step 1:** Run full `docs/smoke-tests.md` suite end-to-end.
- [ ] **Step 2:** Walk acceptance criteria 1–10 from `TECHNICAL_DESIGN §7`. Tick each.
- [ ] **Step 3:** Macro-firewall grep one more time. Zero violations.
- [ ] **Step 4:** `luacheck .` clean.

**Checkpoint M9:** All ten acceptance criteria pass. STOP and verify with the user before any push.

---

**End of EXECUTION_PLAN_ConsumableMaster.md**
