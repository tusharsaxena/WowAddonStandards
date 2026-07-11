# KickCD — Current-State Analysis (2026-05-03)

Read-only assessment. All citations against source.

## 1. TOC metadata

`KickCD.toc:1-10` (full quote of metadata block):

```
## Interface: 120000,120001,120005
## Title: Ka0s KickCD
## Notes: Tracks interrupt + CC cooldowns on a movable icon grid.
## Author: Ka0s
## Version: 1.1.0
## IconTexture: Interface\Icons\ability_kick
## SavedVariables: KickCDDB
## DefaultState: enabled
## Category-enUS: Combat
## X-License: MIT
```

No `## Title-XX` localized variants, no `## Notes-XX`, no `## SavedVariablesPerCharacter`. Triple-comma `Interface:` line targets three Midnight builds.

## 2. Folder/file layout

```
KickCD/
  KickCD.toc                (54 lines)
  ARCHITECTURE.md, CLAUDE.md, README.md, LICENSE
  .gitattributes (CRLF policy)
  core/        Compat (431), Constants (70), Database (542), KickCD (895),
               LSMPatch (62), State (152), Util (228)
  modules/     Castbar (1422), Cooldowns (431), IconGrid (1753)
  defaults/    Spells (333)
  settings/    Castbar (530), General (156), Icons (376), Panel (1258),
               Profiles (69), Spells (953)
  locales/     enUS (373)  — only locale present
  libs/        AceAddon-3.0, AceBucket-3.0, AceComm-3.0, AceConfig-3.0,
               AceConsole-3.0, AceDB-3.0, AceDBOptions-3.0, AceEvent-3.0,
               AceGUI-3.0, AceGUI-3.0-SharedMediaWidgets, AceHook-3.0,
               AceLocale-3.0, AceSerializer-3.0, AceTab-3.0, AceTimer-3.0,
               CallbackHandler-1.0, LibCustomGlow-1.0, LibSharedMedia-3.0,
               LibStub
  media/       screenshots + logo
  reviews/2026-05-02/  (5 files, prior code review artifact)
  docs/        13 topic markdown files
```

- File count (Lua, excluding libs): 18.
- Largest Lua: `modules/IconGrid.lua` at 1753 LOC.
- `modules/Castbar.lua` at 1422 LOC and `settings/Panel.lua` at 1258 LOC are next.

## 3. Module-loading order

TOC order (`KickCD.toc:13-52`): libs first, then `locales/enUS.lua`, then `core/{Compat,Constants,State,Util,Database,LSMPatch,KickCD}.lua`, then `defaults/Spells.lua`, then `modules/{Cooldowns,IconGrid,Castbar}.lua`, then `settings/{Panel,General,Icons,Castbar,Spells,Profiles}.lua`. Comment "(must load first)" on libs at `KickCD.toc:12`; "Settings (last — depend on everything else being initialized)" at `KickCD.toc:46`.

Bootstrap sequence:

- `core/Compat.lua:19` creates `_G.KickCD = KickCD or {}`. Comment at `core/Compat.lua:14-18` documents that this is the file that creates the global namespace before any other core file runs.
- Each subsequent core file uses the same idiom — `KickCD = KickCD or {}; KickCD.X = {}` (e.g. `core/State.lua:22-25`, `core/Util.lua:10-12`, `core/Database.lua:9-12`, `core/Constants.lua:14-16`).
- `core/KickCD.lua:21-33` is the promotion step: `existing = _G.KickCD or {}; addon = LibStub("AceAddon-3.0"):NewAddon(existing, "KickCD", "AceConsole-3.0", "AceEvent-3.0"); _G.KickCD = addon`. AceAddon mutates the passed table in-place, preserving `KickCD.Compat`/`State`/`Util`/`Database` while stamping mixin methods onto it.
- Modules self-register via `KickCD:NewModule(...)` after fetching the addon: `local KickCD = LibStub("AceAddon-3.0"):GetAddon("KickCD"); local Cooldowns = KickCD:NewModule("Cooldowns", "AceEvent-3.0")` (`modules/Cooldowns.lua:59-60`; same pattern at `modules/IconGrid.lua:52-53`, `modules/Castbar.lua:54-55`).
- AceAddon then calls `OnInitialize` (`core/KickCD.lua:42-62`) at `ADDON_LOADED`; that builds the AceDB via `Database:Init()` (`core/Database.lua:506-540`), restores `_debugLog`, registers `/kickcd` and `/kcd` slash. `OnEnable` (`core/KickCD.lua:64-67`) is empty — comment "Modules register themselves via NewModule(...) and AceAddon auto-enables them."
- Settings layer registers via a deferred bootstrap frame on `PLAYER_LOGIN`/`ADDON_LOADED Blizzard_Settings` (`settings/Panel.lua:1248-1257`).
- Per-tab files self-register builders via `KickCD.Settings.RegisterTab(key, Build)` at file load time (`settings/General.lua:154-156`, `settings/Profiles.lua:67-69`, etc.). The order list at `settings/Panel.lua:27` (`general, icons, castbar, spells, profiles`) drives final tab order independent of TOC line order.

## 4. Library stack

Vendored under `libs/`. Versions (read from each file):

- `LibStub` minor 2 — `libs/LibStub/LibStub.lua` (line 4 of grep: `LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2`)
- `AceAddon-3.0` minor 13 — `libs/AceAddon-3.0/AceAddon-3.0.lua:33`
- `AceDB-3.0` minor 33 — `libs/AceDB-3.0/AceDB-3.0.lua:44`
- `LibSharedMedia-3.0` 12000001 — `libs/LibSharedMedia-3.0/LibSharedMedia-3.0.lua:13`
- `LibCustomGlow-1.0` minor 24 — `libs/LibCustomGlow-1.0/LibCustomGlow-1.0.lua:9`

Embedding: every loaded lib has its own `.toc`/`.xml` stub, but TOC consumes `.lua` files directly for the small libs and `.xml` manifests for the multi-file libs (`KickCD.toc:13-24`). Several Ace modules ship in `libs/` but are NOT loaded by the TOC: AceBucket-3.0, AceComm-3.0, AceHook-3.0, AceLocale-3.0, AceSerializer-3.0, AceTab-3.0, AceTimer-3.0 (confirmed by absence in `KickCD.toc:12-24`). `ARCHITECTURE.md:79` documents this.

`.pkgmeta`: **absent** (`ls .pkgmeta` returns no such file). Libs are committed verbatim — no externals.

## 5. Core architecture pattern

- **Bootstrap & promotion** at `core/KickCD.lua:21-33` — already shown above. Single-object identity preserved across the AceAddon promotion.
- **Module publishing**: `KickCD.Foo = KickCD.Foo or {}; local F = KickCD.Foo` is documented as a hard rule in `CLAUDE.md` and used by every core file.
- **Module registration** for behavioural modules: `KickCD:NewModule("Name", "AceEvent-3.0")` at `modules/Cooldowns.lua:60`, `modules/IconGrid.lua:53`, `modules/Castbar.lua:55`. Modules then implement `OnEnable`/`OnDisable` (`modules/Cooldowns.lua:339-366`, `modules/IconGrid.lua:1480-1541`).
- **Cross-module access** uses `KickCD:GetModule("Name", true)` (silent-on-missing). Example: `modules/Castbar.lua:108-113` resolves the IconGrid module via this idiom rather than reaching into a global. Per the prior review (`reviews/2026-05-02/05_FINAL_SUMMARY.md` F-014), the previous direct `KickCD.IconGrid` reach was eliminated.
- **Closed message bus** — five messages (`KickCD_SPELL_STATE`, `KickCD_CONFIG_CHANGED`, `KickCD_PROFILE_CHANGED`, `KickCD_GRID_LAYOUT`, `KickCD_COMBAT_STATE`). Senders: Cooldowns sends `_SPELL_STATE` (`modules/Cooldowns.lua:266`), Settings sends `_CONFIG_CHANGED` (`settings/Panel.lua:60-64`), Database sends `_PROFILE_CHANGED` (`core/Database.lua:496-498`, `:424-427`), IconGrid sends `_GRID_LAYOUT`, State sends `_COMBAT_STATE` (`core/State.lua:149-151`). Each message has exactly one sender. Modules subscribe via `self:RegisterMessage(...)` (`modules/Cooldowns.lua:357-358`).
- **Lifecycle** — `OnInitialize` at `core/KickCD.lua:42-62` (DB init + debug-log restore + slash registration); `OnEnable` empty at `core/KickCD.lua:64-67`. Module `OnEnable` registers events + messages and triggers initial Rebuild. Module `OnDisable` releases private dispatch frames (`modules/IconGrid.lua:1531-1541`).
- **Constants/State/Compat split** documented as a hard rule in `CLAUDE.md`. Compat normalises Blizzard APIs only (`core/Compat.lua`); State holds shared mutable flags + visibility helpers (`core/State.lua:24-25, 67-113`); Constants holds magic numbers (`core/Constants.lua:14-16, 29, 39-70`).

## 6. Settings / saved variables

- AceDB instance built at `core/Database.lua:506-540`. `AceDB:New("KickCDDB", DEFAULTS, true)` — `true` (=> "Default" profile) so all characters share one profile by default. Saved variable `KickCDDB`.
- `DEFAULT_PROFILE` shape at `core/Database.lua:26-237`. Top-level keys: `dbVersion`, `enabled`, `locked`, `scale`, `alpha`, `debugLog`, `visibility`, `icons{}`, `castbar{}`, `anchors{icons,castbar}`, `spells{}`.
- `defaults/` only contains `Spells.lua`. `defaults/Spells.lua:22` writes `KickCD.DefaultSpells` keyed by class file token then normalised spec token. Loaded after core/ so it can reference `KickCD` (`defaults/Spells.lua:20`).
- `settings/` contains six panel registrants; each calls `KickCD.Settings.RegisterTab(key, Build)` at file load. The decoupling: `defaults/` provides seed data; `settings/` provides UI + slash schema rows; `core/Database.lua` owns the AceDB instance and merging policy.
- **Schema source-of-truth**: `KickCD.Settings.Schema` is a flat array of rows, each row carrying `{panel, section, group, path, type, label, tooltip, default, min/max/step/fmt, values, valueGate, onChange}`. Rows are registered via `add{...}` calls at file load (`settings/General.lua:29-89`, similarly in `Icons.lua` / `Castbar.lua`). The same schema feeds the AceGUI panel (`settings/Panel.lua` `RenderSchema`) and slash CLI `/kcd list|get|set` (`core/KickCD.lua:241-443`).
- **Schema validation**: `Helpers.ValidateSchema()` at `settings/Panel.lua:131-161` validates `panel`, `section`, `type` enums and required `path`. Runs at panel-registration time (`settings/Panel.lua:1210`). Only prints errors (non-fatal).
- **Spells merge policy**: AceDB defaults are NOT used for spells. `Database:BuildSpells()` at `core/Database.lua:338-413` runs once on first profile creation, deep-copies `KickCD.DefaultSpells` per (CLASS, SPEC), appends the player's racial cast-stopper. Idempotent on populated profiles (the `isEmpty` check at line 348). Re-fired on `OnProfileChanged`/`Copied`/`Reset` (`core/Database.lua:481-499`, `:537-539`).
- **Migration**: `CURRENT_DB_VERSION = 1` at `core/Database.lua:24`; `migrations` table empty at `:449-452`. `Database:MigrateProfile()` at `:457-475` walks profiles forward; today a no-op scaffold but wired into both `Init` and profile-change handlers.

## 7. Options UI

- Five subcategories under one parent (`settings/Panel.lua:27`): General, Icons, Castbar, Spells, Profiles. Each is a Blizzard `Settings.RegisterCanvasLayoutSubcategory` (`settings/General.lua:150-152`, `settings/Profiles.lua:63-64`).
- Custom unified header (title + Defaults button + horizontal divider) built by `Helpers.CreatePanel` (`settings/Panel.lua:312` onward). Sub-pages render breadcrumb "Ka0s KickCD ▸ <Page>" via inline atlas separator (`settings/Panel.lua:271-274`).
- Schema-driven panels (General, Icons, Castbar) use `Helpers.RenderSchema(ctx, panelKey, afterGroup)` to render rows as AceGUI widgets inside an AceGUI ScrollFrame (`settings/Panel.lua:11-14`).
- Spells panel is the largest (`settings/Spells.lua` 953 LOC) — custom AceGUI editor.
- Profiles panel uses AceDBOptions + AceConfigDialog rendered into an AceGUI SimpleGroup (`settings/Profiles.lua:36-61`).
- Late render: AceGUI lays out against parent width which is 0 at PLAYER_LOGIN, so each tab uses `OnShow`-deferred build (`settings/General.lua:127-148`, `settings/Profiles.lua:59-61`).

## 8. Slash commands

- Two slash names: `/kickcd` and `/kcd` (alias) registered at `core/KickCD.lua:60-61` via AceConsole.
- Single dispatcher: `KickCD:OnSlashCommand` at `core/KickCD.lua:222-239`. Two ordered dispatch tables drive everything:
  - `COMMANDS` at `core/KickCD.lua:117-148` — verbs: `help, config, lock, unlock, toggle, list, get, set, reset, resetall, resetposition, spells, debug`.
  - `DEBUG_COMMANDS` at `core/KickCD.lua:150-188` — `spells, castbar, interrupt, log`.
  - `SPELLS_COMMANDS` at `core/KickCD.lua:787-802` — `list, add, remove, enable, disable, category, reset`.
- Help is generated from the same tables (`core/KickCD.lua:196-201`) so adding a command requires only a row.
- `/kcd set <path> <value>` and `/kcd get <path>` walk the schema (`core/KickCD.lua:413-443`); `applyFromText` at `:276-387` parses values per `def.type`. Unknown dropdown values produce a hint that walks the `def.valueGate` cross-row dependency (`core/KickCD.lua:327-360`).
- `KickCD.COMMANDS` is published (`core/KickCD.lua:148`) so the parent settings page renders the same list (`settings/Panel.lua:1171-1180`).

## 9. Localization

- Single locale present: `locales/enUS.lua` (373 lines, ~241 keys). No deDE/frFR/etc.
- Bootstrap pattern: `KickCD = KickCD or {}; L = setmetatable({}, {__index = function(_,k) return k end}); KickCD.L = L` (`locales/enUS.lua:12-17`). Fallback returns key as value, so a missing key gracefully degrades.
- **AceLocale**: NOT used. The library is vendored at `libs/AceLocale-3.0/` but is NOT loaded by `KickCD.toc`. The locale is a hand-rolled `setmetatable` table.
- Coverage: ~241 string keys, all with English RHS values (`locales/enUS.lua:28+`). The metatable means new code can ship `L["..."]` without updating enUS first.
- Slash output is partially localised; the prior review left F-009 as deferred (full slash localisation), per `reviews/2026-05-02/05_FINAL_SUMMARY.md:38, :153-154`.

## 10. Events

Per-module registration via AceEvent. No central event bus.

- `core/State.lua:128-152` — bootstrap `CreateFrame` listener for `PLAYER_LOGIN`, `PLAYER_REGEN_DISABLED`, `PLAYER_REGEN_ENABLED`. **This is the only file that listens to `PLAYER_REGEN_*`** (per `ARCHITECTURE.md:58`). It sets `State.inCombat` then sends `KickCD_COMBAT_STATE` so subscribers see an explicit ordered transition (`core/State.lua:149-151`).
- `core/LSMPatch.lua:27-62` — bootstrap `CreateFrame` listener for `PLAYER_LOGIN`; unregisters after first fire.
- `settings/Panel.lua:1248-1257` — bootstrap `CreateFrame` listener for `PLAYER_LOGIN` + `ADDON_LOADED Blizzard_Settings`.
- `modules/Cooldowns.lua:339-366` — `OnEnable` registers `SPELL_UPDATE_COOLDOWN`, `_USABLE`, `_CHARGES`, `PLAYER_ENTERING_WORLD`, `PLAYER_SPECIALIZATION_CHANGED`, `SPELLS_CHANGED`, `TRAIT_CONFIG_UPDATED`, plus `KickCD_PROFILE_CHANGED`/`_CONFIG_CHANGED` messages.
- `modules/IconGrid.lua:1480-1529` — registers messages for the four `KickCD_*` it cares about plus `PLAYER_SPECIALIZATION_CHANGED`/`_ENTERING_WORLD`/`SPELLS_CHANGED`/`TRAIT_CONFIG_UPDATED`/`PLAYER_TARGET_CHANGED`. The eight `UNIT_SPELLCAST_*` events are registered through `Util.RegisterTargetEvent` private dispatch frames (`modules/IconGrid.lua:1514-1528`) so the unit filter happens C-side via `Frame:RegisterUnitEvent("target")`.
- `core/Util.lua:197-205` — `Util.RegisterTargetEvent(module, eventName, handlerName)` is the helper.

## 11. Frames

- 100% Lua-defined; no addon-side `.xml` files for frames (only `.xml` files are vendored libs').
- IconGrid pool: `pool = { active = {}, free = {} }` at `modules/IconGrid.lua:62`. `active` is keyed by spellID for O(1) `KickCD_SPELL_STATE` dispatch; `free` is a stack of released widgets so rebuild never churns frames. `ordered[]` (`:67`) keeps the laid-out ordering separately.
- Icon widget construction at `modules/IconGrid.lua:302+`: a `Button` (not Frame) so a future click-to-cast hook is one `:SetAttribute` away (`:303-306`); explicitly avoids `SecureActionButton` to keep the icon grid free of protected-frame taint (`:305`). Children: an icon Texture, a `BackdropTemplate` border child, a `CooldownFrameTemplate` Cooldown frame, and a manually driven cooldown FontString (lines `:312-348`).
- The cooldown FontString is driven by a single shared `C_Timer.NewTicker` (`modules/IconGrid.lua:78-84`) — comment notes the previous implementation used N per-frame OnUpdate scripts and was collapsed to one ticker.
- Castbar at `modules/Castbar.lua:388+` — `KickCDCastbar` plus a non-StatusBar Frame container (`frame.bar`) with two stacked `StatusBar` children (`frame.bar.interruptible` and `frame.bar.uninterruptible`, `:416-417`). Curve-switched on `notInterruptible` so only one is visible (`:403`). Two `BackdropTemplate` border frames (`:471-472`) for per-state borders.
- **Mixin pattern** (CLAUDE.md hard rule): `Mixin(frame, t)` is used instead of `setmetatable` because Blizzard widget methods live on the C-side metatable — replacing it nils them. `Icon` table at `modules/IconGrid.lua:300` is used via Mixin.
- **Party/raid frame integration**: NONE. KickCD does NOT attach to or modify party/raid frames; it exclusively reads state for `unit="target"` or `unit="player"`. Taint risk is therefore minimal — the only protected-frame-adjacent path is the Settings panel category open which is gated on `InCombatLockdown` at `core/KickCD.lua:865-872`.
- Anchors stored as `{point, relativePoint, x, y}` against `UIParent` only (`core/Util.lua:38-69`).

## 12. Debug/logging

- `KickCD._debugLog` is the runtime flag, persisted to `db.profile.debugLog` (`core/KickCD.lua:53-55`, `core/Database.lua:36`).
- Toggled by `/kcd debug log` (`core/KickCD.lua:171-188`) which routes through `Helpers.SetAndRefresh` so the General > Debug checkbox stays in sync.
- Only one level (on/off). Per-module `dprint` helpers gate on the flag, e.g. `modules/Cooldowns.lua:91-95`.
- `/kcd debug spells` calls `Cooldowns:DebugDump` (`modules/Cooldowns.lua:398-431`); `/kcd debug castbar` calls `Castbar:DebugDump`; `/kcd debug interrupt` calls `Compat.DebugInterrupt` (`core/Compat.lua:330-414`) which prints every position of `UnitCastingInfo`/`UnitChannelInfo` with type + secret-tainted flag — purpose-built diagnostic for 12.0 secret-value problems.
- Output prefix `|cff00ffff[KCD]|r` via `Util.print` (`core/Util.lua:211-228`); CLAUDE.md hard rule: never use bare `print` or own prefix.

## 13. Error handling

- `pcall` count by file: 3 in `core/KickCD.lua` (`:380, :848, :1051?`), 9 in `settings/Panel.lua`, 3 in `settings/Spells.lua`. None in modules.
- Defensive nil checks pervasive — every Helper call goes through `if H and H.X then ...` patterns (e.g. `core/KickCD.lua:251-253, :476-479`).
- 12.0 secret values: handled via `_G.issecretvalue(...)` checks at 11+ sites (see grep). Strategy is "never bind secrets to Lua locals; pass to C-side methods" — documented at `core/Compat.lua:53-91`, enforced at `modules/Cooldowns.lua:140-144` (charges), `modules/IconGrid.lua:1684-1691` (notInterruptible coercion), `core/State.lua:94-113` (`SetAlphaFromBoolean`).
- Deprecated APIs: explicit pre-12.0 fallbacks in `core/Compat.lua` (e.g. `core/Compat.lua:71-91` `GetSpellCooldown`; `:122-126` `GetSpellCooldownDuration` returns nil pre-12.0; `:153-156` `GetSpellInfo` falls back). Spec resolution uses `GetSpecialization`/`GetSpecializationInfo` (still current, but deprecated for `C_SpecializationInfo` in late patches) — `modules/Cooldowns.lua:78-82`, `modules/IconGrid.lua:286-290`. Class via `UnitClass("player")` (current).
- AceDB-centric profile reads guard for `KickCD.db and KickCD.db.profile` everywhere (e.g. `core/KickCD.lua:96-97`, `modules/Cooldowns.lua:230-233`).

## 14. Packaging

`.pkgmeta`: **absent**. No CurseForge / WoWInterface packager metadata. Libs are committed verbatim into `libs/`. No externals declaration. `.gitattributes` enforces CRLF working-tree + blob (`KickCD/.gitattributes`).

## 15. Documentation

`README.md` (15189 bytes), `CLAUDE.md` (11200 bytes), `ARCHITECTURE.md` (9738 bytes), `docs/` directory of 13 topic files. Drift check vs source:

**CLAUDE.md** — 5 claims verified:
- "Five AceEvent messages (`KickCD_SPELL_STATE, ...COMBAT_STATE`)" — confirmed against `core/State.lua:150`, `core/Database.lua:497`, `modules/Cooldowns.lua:266`. Accurate.
- "`Compat.lua` is the file that creates `_G.KickCD`" — confirmed `core/Compat.lua:19`. Accurate.
- "`Util.print` prepends a single cyan `[KCD]` banner" — confirmed `core/Util.lua:211`. Accurate.
- "`KickCD.Settings.Schema` is the single source of truth" — confirmed; rows added in `settings/General.lua:29-89` etc. and consumed by both `core/KickCD.lua:389-411` (CLI) and `settings/Panel.lua` (UI). Accurate.
- "Five-tab Blizzard subcategory (General / Icons / Cast bar / Spells / Profiles) with full slash-command parity" — `settings/Panel.lua:27` confirms the order. Accurate.

**ARCHITECTURE.md** — 5 claims verified:
- "Closed message bus: 5 messages" — `ARCHITECTURE.md:53` accurate, BUT the same file at `:38` describes it as "4 messages, sender/listener/payload" in the table — inconsistent (drift within the doc). `KickCD_GRID_LAYOUT` is the 5th and is documented in `ARCHITECTURE.md:29`. Verdict: minor inconsistency at `ARCHITECTURE.md:38`.
- "AceBucket, AceComm, AceHook, AceLocale, AceSerializer, AceTab, AceTimer ship under libs/ but are not loaded" — confirmed against `KickCD.toc`. Accurate.
- Load order list (`ARCHITECTURE.md:85-97`) matches `KickCD.toc:13-52`. Accurate.
- "AceDB:New(\"KickCDDB\", DEFAULTS, true)" semantics described — confirmed `core/Database.lua:521`. Accurate.
- "Cast bar was originally removed at commit 59fb5c0" — historical; not verified but plausible per `modules/Castbar.lua:35-41` comment.

**README.md** — claim sample (5):
- TOC `## Version: 1.1.0` — confirmed `KickCD.toc:5` and `core/KickCD.lua:36`. Accurate.
- Slash command list: README's `/kcd list|get|set|reset|resetall|resetposition|spells|debug` — matches `core/KickCD.lua:117-148`. Accurate.
- "13 anchor points × 8 grow directions" (icon grid layout) — anchor enum at `settings/Panel.lua:177-191` confirms 13 entries. Accurate.
- "AceLocale" not used — README does not falsely claim AceLocale.
- Did not exhaustively read README (15KB) but the spot checks above passed.

**Drift summary:** ARCHITECTURE.md `:38` carries a stale "4 messages" inside the subsystem table while `:53` says 5 (the prior review noted "5" was the corrected count). One small fix needed.

## 16. Tests / lint

- No `.luacheckrc` (verified with `ls`).
- No CI / lint config of any kind in the repo root.
- No test harness — `CLAUDE.md:69` explicitly: "No automated tests. Validation is manual, in-game." `docs/smoke-tests.md` and `docs/testing.md` provide a manual checklist.

## 17. Notable strengths (candidates to promote)

1. **Modular folder layout** — clean separation `core/` (infrastructure), `modules/` (behaviours), `settings/` (UI), `defaults/` (seed data), `locales/` (i18n), with a TOC-load-order discipline that makes dependencies explicit. This is the strongest structural template in the addon collection.
2. **Single-source-of-truth schema** — `KickCD.Settings.Schema` (rows added in `settings/General.lua:29-89`, consumed by `core/KickCD.lua:241-443` for CLI and `settings/Panel.lua` for UI plus `Helpers.RestoreDefaults` for resets). One row → UI widget + slash CLI + Defaults button + `/kcd resetall` automatically. Promote this as a core standard.
3. **Closed message bus contract** — five messages, exactly one sender each, documented enumerably in `ARCHITECTURE.md` and `CLAUDE.md`. Adding a message requires updating both source emitter and `docs/message-bus.md`. This is a strong invariant worth standardising.
4. **Ordered dispatch tables for slash** (`core/KickCD.lua:117-148, :150-188, :787-802`) — each entry `{name, description, fn}`; help text generated from the same tables. Single-row addition surfaces in chat output and Settings UI without further wiring.
5. **Module publishing idiom** — `KickCD.Foo = KickCD.Foo or {}; local F = KickCD.Foo` everywhere; documented as a hard rule in `CLAUDE.md`. Symmetrical with the AceAddon promotion pattern in `core/KickCD.lua:21-33` that preserves preexisting fields.
6. **Compat / State / Constants three-way split** — API normalisation (`core/Compat.lua`), shared mutable state + visibility helpers (`core/State.lua`), magic numbers (`core/Constants.lua`). Clean responsibility boundaries.
7. **Util.RegisterTargetEvent** (`core/Util.lua:197-205`) — wraps `Frame:RegisterUnitEvent("target")` because AceEvent doesn't expose unit-filtered registration. Returns the dispatch frame so the caller releases it in `OnDisable`. Worth lifting into a shared helper library.
8. **Schema validator** (`settings/Panel.lua:131-161`) — runs once at panel-registration time, prints malformed rows, never blocks load. Catches `panel`/`section`/`type`-enum typos.
9. **Single-source defaults reset** — `Helpers.ResetAll` (`settings/Panel.lua:1088-1093`) is called by both the panel's confirmation popup (`settings/General.lua:107`) and the `/kcd resetall` slash (`core/KickCD.lua:490-497`); zero divergence risk.
10. **Per-module debug dumpers** routed through `/kcd debug <topic>` (`core/KickCD.lua:150-188`).

## 18. Notable weaknesses

1. **`modules/IconGrid.lua` at 1753 LOC** is too big — pool, layout, glow, visibility, and per-icon widget construction in one file. Splitting widget construction into `modules/IconGrid/Icon.lua` (or similar) would aid review.
2. **`settings/Panel.lua` at 1258 LOC and `settings/Spells.lua` at 953 LOC** — the schema framework + the Spells editor each warrant a sub-folder.
3. **`ARCHITECTURE.md:38` drift** — "4 messages" stale relative to the 5-message reality everywhere else (the subsystem table row).
4. **`reviews/2026-05-02/05_FINAL_SUMMARY.md`'s F-015/F-016 perf TODOs are not fixed** — `BuildCurves` rebuilds on every "icons" CONFIG_CHANGED (`modules/IconGrid.lua:226-228` carries the TODO comment); `Castbar:Reskin` rebuilds on every "castbar" CONFIG_CHANGED. Captured but deferred.
5. **No `.pkgmeta`** — packaging would require manual ZIP staging. Most peer addons use BigWigs Packager.
6. **No `.luacheckrc` / lint** — no static analysis at all. Easy to add and ship a baseline.
7. **AceLocale shipped under `libs/` but unused** — should be removed from `libs/` to reduce confusion (or properly wired). Same for AceBucket / AceComm / AceHook / AceSerializer / AceTab / AceTimer.
8. **Glow-gate cache uses an "is the value secret?" string sentinel** (`modules/IconGrid.lua:1684-1700`) — string `"secret"` mixed with bools in a tri-state cache. Works but is brittle; a small comment-rich enum would be safer.
9. **`GetSpecialization`/`GetSpecializationInfo`** (deprecated wrappers in late patches) used at `modules/Cooldowns.lua:78-82`, `modules/IconGrid.lua:286-290`, `core/KickCD.lua:553-562`. Should migrate to `C_SpecializationInfo.GetSpecialization` / `.GetSpecializationInfo` and add Compat shims.
10. **Slash output mostly bare-English in `core/KickCD.lua`** (deferred F-009) — most slash strings bypass `KickCD.L`. Only an issue when a non-English locale ships.
11. **No CHANGELOG file** at repo root — version bumps in TOC + README "Version History" only.
12. **`runReset` and `setSetting` print "Settings layer not ready yet"** if called before `RegisterPanel` runs, which can race with early slash usage post-login (`core/KickCD.lua:392-393, :415, :431`). Mitigated for `OpenSettings` via deferred-retry (`core/KickCD.lua:884-893`) but not for the schema CLI.
13. **`spells[CLASS][SPEC]` write paths** lazy-create per-spec tables; if a user typoes a class name in `/kcd spells add ... CLASS SPEC` (after upper-normalisation passes), the lazy-create creates an empty table that will appear forever in saved-vars. `Database:EnsureSpellList` (`core/Database.lua:292-299`) does no class-name validation against the known set.

