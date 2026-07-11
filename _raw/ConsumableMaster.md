# ConsumableMaster — current-state analysis

Date: 2026-05-03. Read-only review of `/mnt/d/Profile/Users/Tushar/Documents/GIT/ConsumableMaster/`. Citations are `relative/path:LINE` (relative to the addon root).

## 1. TOC metadata

`ConsumableMaster.toc:1-12`:

```
## Interface: 120000,120001,120005
## Title: Ka0s Consumable Master
## Notes: Auto-managed account-wide consumable macros.
## Author: Ka0s
## Version: 1.4.0
## SavedVariables: ConsumableMasterDB
## IconTexture: Interface\Icons\inv_cooking_100_roastduck
## DefaultState: enabled
## Category-enUS: Action Bars & Buttons
## X-License: MIT

embeds.xml
```

- Interface versions (3): `120000, 120001, 120005` (Midnight 12.0.x).
- Version: `1.4.0` (matches `Core.lua:8` `KCM.VERSION = "1.4.0"`).
- `SavedVariables: ConsumableMasterDB` (single account-wide DB).
- `SavedVariablesPerCharacter`: **absent**.
- `Dependencies` / `OptionalDeps` / `LoadOnDemand`: **absent**.
- X-* fields: **absent** (no `X-Curse-Project-ID`, `X-Wago-ID`, `X-WoWI-ID`). Only `X-License: MIT`.
- `DefaultState: enabled`, `Category-enUS: Action Bars & Buttons`, `IconTexture` set.

## 2. Folder/file layout

Root tree (excluding `.git`, `.claude`, `media/`, `libs/` lib internals):

```
ConsumableMaster/
├── ConsumableMaster.toc        (54L)
├── embeds.xml                  (13L)
├── Core.lua                    (362L)
├── Debug.lua                   (42L)
├── BagScanner.lua              (56L)
├── Classifier.lua              (167L)
├── Ranker.lua                  (455L)
├── Selector.lua                (426L)
├── MacroManager.lua            (523L)
├── TooltipCache.lua            (354L)
├── SpecHelper.lua              (104L)
├── SlashCommands.lua           (1257L)
├── KCMIconButton.lua           (145L)
├── KCMScoreButton.lua          (115L)
├── KCMMacroDragIcon.lua        (179L)
├── KCMItemRow.lua              (310L)
├── ARCHITECTURE.md             (77L)
├── CLAUDE.md                   (70L)
├── README.md                   (176L)
├── LICENSE / .gitattributes / .gitignore
├── defaults/
│   ├── Categories.lua          (134L)
│   ├── Defaults_StatPriority.lua (133L)
│   ├── Defaults_Food.lua, _Drink, _StatFood, _HPPot, _MPPot,
│   │   _Healthstone, _CombatPot, _Flask         (13–57L each)
│   └── README.md
├── settings/
│   ├── Panel.lua               (832L)
│   ├── Category.lua            (591L)
│   ├── General.lua             (116L)
│   └── StatPriority.lua        (289L)
├── docs/                       (10 topic md files; see CLAUDE.md doc index)
├── reviews/2026-05-02/         (5 review files)
└── libs/                       (Ace3 stack — see §4)
```

- 16 production `.lua` files in root + 4 in `settings/` + 9 in `defaults/` + 7 in `libs/*` totalling 9933 lines (`wc -l`).
- Largest production files: `SlashCommands.lua` 1257L, `settings/Panel.lua` 832L, `settings/Category.lua` 591L, `MacroManager.lua` 523L.
- XML embeds: `embeds.xml:5-12` `<Script>`/`<Include>` tags load LibStub, CallbackHandler, AceAddon, AceEvent, AceDB, AceConsole, AceGUI, AceConfig (no addon `.lua` referenced from XML — TOC owns those).

## 3. Module-loading order

`embeds.xml` is loaded first (`ConsumableMaster.toc:12`). Lua files thereafter follow TOC list order (`ConsumableMaster.toc:19-54`):

1. `Core.lua` — creates `_G.KCM = LibStub("AceAddon-3.0"):NewAddon(...)` (`Core.lua:5-6`).
2. `Debug.lua`.
3. `defaults/Categories.lua` then 9 `defaults/Defaults_*.lua` files.
4. Pure modules: `SpecHelper`, `TooltipCache`, `BagScanner`, `Classifier`, `Ranker`, `Selector`, `MacroManager`.
5. AceGUI widget registrations: `KCMIconButton`, `KCMScoreButton`, `KCMMacroDragIcon`, `KCMItemRow`.
6. Settings framework: `settings/Panel.lua` then `settings/General.lua`, `StatPriority.lua`, `Category.lua`.
7. `SlashCommands.lua` last.

Load-order assumption: `_G.KCM` exists before any other file (called out at `ConsumableMaster.toc:14-18`). `settings/Panel.lua` must precede the per-tab files because it publishes `KCM.Settings.RegisterTab` and `Helpers` (`settings/Panel.lua:684`, `settings/Panel.lua:32-33`). Pipeline + event handler bodies in `Core.lua:90-353` reference modules that load later but are only invoked after `OnEnable` / Ace events fire (intentional, comment at `Core.lua:14-18` / `ARCHITECTURE.md:77`).

## 4. Library stack

Vendored under `libs/`:

| Library | Version (MAJOR, MINOR) | Source | Embed |
|---|---|---|---|
| LibStub | "LibStub", 2 | `libs/LibStub/LibStub.lua:3` | `<Script>` in `embeds.xml:5` |
| CallbackHandler-1.0 | "CallbackHandler-1.0", 8 | `libs/CallbackHandler-1.0/CallbackHandler-1.0.lua:31` (verified via xml include) | `<Include>` in `embeds.xml:6` |
| AceAddon-3.0 | "AceAddon-3.0", 13 | `libs/AceAddon-3.0/AceAddon-3.0.lua:33` | `<Include>` in `embeds.xml:7` |
| AceEvent-3.0 | "AceEvent-3.0", 4 | `libs/AceEvent-3.0/AceEvent-3.0.lua:15` | `<Include>` in `embeds.xml:8` |
| AceDB-3.0 | "AceDB-3.0", 33 | `libs/AceDB-3.0/AceDB-3.0.lua:44` | `<Include>` in `embeds.xml:9` |
| AceConsole-3.0 | "AceConsole-3.0", 7 | `libs/AceConsole-3.0/AceConsole-3.0.lua:13` | `<Include>` in `embeds.xml:10` |
| AceGUI-3.0 | "AceGUI-3.0", 41 | `libs/AceGUI-3.0/AceGUI-3.0.lua:28` | `<Include>` in `embeds.xml:11` |
| AceConfig-3.0 | "AceConfig-3.0", 3 | `libs/AceConfig-3.0/AceConfig-3.0.lua:18` | `<Include>` in `embeds.xml:12` |

Unused libraries:

- **AceConfig-3.0** is included via `embeds.xml:12` but the addon never calls `AceConfig:RegisterOptionsTable` or `AceConfigDialog` anywhere (`grep AceConfig`/`AceConfigDialog` against non-libs `.lua` returns zero hits). The settings UI is hand-built on `Settings.RegisterCanvasLayoutCategory` (`settings/Panel.lua:707`) and `RegisterCanvasLayoutSubcategory` (`settings/General.lua:111`, etc.). Confirmed by reviews/2026-05-02/01_FINDINGS.md "Notes & non-issues" line: "addon doesn't use AceConfigDialog at all".
- **AceConsole-3.0** is mixed-in (`Core.lua:5` `:NewAddon(..., "AceConsole-3.0")`) and is used via `self:RegisterChatCommand` (`Core.lua:65-66`). Used.

## 5. Core architecture pattern

**AceAddon `:NewAddon` published on `_G.KCM`.** Entry point:

```lua
-- Core.lua:5-6
local KCM = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0")
_G.KCM = KCM
```

Every other module follows the publish idiom (`Core.lua` documents this in `CLAUDE.md` "Module publishing pattern", verified live):

```lua
local KCM = _G.KCM
KCM.Foo = KCM.Foo or {}
local F = KCM.Foo
```

Examples: `Debug.lua:3-4`, `BagScanner.lua:13-15`, `Classifier.lua:20-22`, `Ranker.lua:22-24`, `Selector.lua:16-18`, `MacroManager.lua:13-15`, `TooltipCache.lua:32-34`, `SpecHelper.lua:7-9`, `Categories.lua:23-24`. There is **no** AceAddon `:NewModule` usage — modules are plain tables hung on `KCM`.

`KCM*` widgets register as AceGUI widget types via `AceGUI:RegisterWidgetType(Type, Constructor, Version)` (`KCMIconButton.lua:145`, `KCMScoreButton.lua:115`, `KCMMacroDragIcon.lua:179`, `KCMItemRow.lua:311`). `Type` strings: `"KCMIconButton"`, `"KCMScoreButton"`, `"KCMMacroDragIcon"`, `"KCMItemRow"` (versions 1, 1, 1, 2). They are not Lua modules in the `KCM.*` namespace — they're consumed by `AceGUI:Create("KCMItemRow")` etc. from `settings/Category.lua`.

The TOC comment block at `ConsumableMaster.toc:14-18` documents the load contract.

## 6. Settings / saved variables

Single AceDB profile, no perCharacter, no global namespace:

```lua
-- Core.lua:64
self.db = LibStub("AceDB-3.0"):New("ConsumableMasterDB", KCM.dbDefaults, true)
```

Third arg `true` = "use the default profile across all characters" → effectively account-wide. `dbDefaults` is at `Core.lua:25-61`. Top-level shape:

- `profile.schemaVersion = 1` (`Core.lua:27`) — declared but no migration code referenced anywhere; `grep schemaVersion` only hits this line.
- `profile.enabled` (master toggle, `Core.lua:28`).
- `profile.debug` (`Core.lua:29`).
- `profile.categories[CATKEY]` for each of the 10 categories (`Core.lua:30-57`). Single-pick categories carry `{added, blocked, pins, discovered}`. Spec-aware ones carry `{bySpec = {}}` lazy-populated by `Selector.GetBucket` (`Selector.lua:35-70`). Composites (`HP_AIO`, `MP_AIO`) carry `{enabled, orderInCombat, orderOutOfCombat}` and **no** item buckets — invariant called out at `Core.lua:39-46`.
- `profile.statPriority` user overrides (`Core.lua:58`).
- `profile.macroState[macroName] = { lastItemID, lastBody, lastIcon, lastCat }` fingerprint cache (`MacroManager.lua:353-358`, `448-453`).

Defaults are split into:

- `defaults/Categories.lua` — category metadata (LIST + BY_KEY + Get/All) — see §1.
- `defaults/Defaults_*.lua` — pure data tables that publish into `KCM.SEED.<CATKEY>` arrays of itemIDs. `defaults/Defaults_StatPriority.lua:68-133` populates `KCM.SEED.STAT_PRIORITY[<classID>_<specID>]` (39 specs).

Schema validation lives at `settings/Panel.lua:103-148` (`Helpers.ValidateSchema`) and is invoked by `registerPanel` at `settings/Panel.lua:702`. It validates schema rows used by `/cm list/get/set`, not the full DB shape.

Migration logic: **absent** — no `if schemaVersion < N` guard anywhere. `KCM.ResetAllToDefaults` (`Core.lua:269-285`) is the centralized wipe-and-resync; both the panel's "Reset all priorities" (`settings/General.lua:50-55`) and `/cm reset` StaticPopup (`SlashCommands.lua:38-44`) delegate to it.

Discovered-set TTL GC: `Selector.SweepStaleDiscovered` (`Selector.lua:362-388`) runs from `OnPlayerEnteringWorld` (`Core.lua:293-294`); cutoff is 30 days (`Selector.lua:343`).

## 7. Options UI

**Hand-rolled canvas panel using Blizzard's modern `Settings.RegisterCanvasLayoutCategory` / `RegisterCanvasLayoutSubcategory` API** — not AceConfig.

- Main parent: `settings/Panel.lua:704-708` (`Settings.RegisterCanvasLayoutCategory(mainCtx.panel, PANEL_TITLE)` then `Settings.RegisterAddOnCategory(main)`).
- Sub-tabs registered via `KCM.Settings.RegisterTab(key, builder)` (`settings/Panel.lua:684-693`); each tab module calls into `Settings.RegisterCanvasLayoutSubcategory(mainCategory, ctx.panel, "...")` — e.g. `settings/General.lua:111`.
- Order: `KCM.Settings.order` at `settings/Panel.lua:26-30`.
- Bootstrap defers registration until Blizzard_Settings is ready: `settings/Panel.lua:823-832` (PLAYER_LOGIN / ADDON_LOADED frame). `OnInitialize` does **not** call `KCM.Options.Register` (only `Core.lua:71-73` debug print runs there) — so the bootstrap is the de facto sole registration path. The `Core.lua:67-69` comment explicitly delegates to it.
- Combat-protected open: `settings/Panel.lua:802-805` early-returns with chat notice.
- `Settings.OpenToCategory` is called with the numeric `categoryID` retrieved at registration (`settings/Panel.lua:715`, used at `settings/Panel.lua:807-810`).

## 8. Slash commands

**`AceConsole:RegisterChatCommand` registers two slashes** (`Core.lua:65-66`): `/cm` and `/consumablemaster`, both routed to `KCM:OnSlashCommand` at `SlashCommands.lua:1246-1257`.

Dispatch is **hand-rolled** — not via AceConsole's `:GetArgs` — over a single `COMMANDS` table (`SlashCommands.lua:1147-1214`) plus `ALIASES` (`SlashCommands.lua:1218-1220`). Top-level verbs:

`help`, `config`, `version`, `debug`, `resync`, `rewritemacros` (alias `rewrite`), `reset`, `list`, `get`, `set`, `priority`, `stat`, `aio`, `dump`.

Sub-namespaces:

- `/cm priority <cat> [list|add|remove|up|down|reset]` — `runPriority` (`SlashCommands.lua:830`).
- `/cm stat [<spec>] [primary|secondary|reset]` — `runStat` (`SlashCommands.lua:962`).
- `/cm aio <hp_aio|mp_aio> [list|toggle|up|down|reset]` — `runAIO` (`SlashCommands.lua:1124`).
- `/cm dump <target>` — `dumpDispatch` (`SlashCommands.lua:509`).

Note: README (`README.md:172`) advertises `/cm enable` as new in 1.4.0, but no `enable` row exists in the COMMANDS table — the master enable is editable via `/cm set enabled true|false` through the schema-driven path. See §15.

## 9. Localization

**No AceLocale present.** Project scope is explicitly English-only (`CLAUDE.md` "Hard rules": *English-only*; `Classifier.lua:7-9`; `TooltipCache.lua:37`).

- `Classifier.lua:28-30` compares against literal English subtypes `"Potions"`, `"Food & Drink"`, `"Flasks & Phials"`.
- `TooltipCache.lua:40-70` patterns are English ("Restores N health", "of your maximum mana", etc.).
- `STAT_TOKENS` at `TooltipCache.lua:74-82` matches stat names by literal English string.
- All chat messages are English literals via `say()` (`SlashCommands.lua:23-25`) or inline `|cff00ffff[CM]|r` (`MacroManager.lua:305`, `MacroManager.lua:489`, etc.).

Hardcoded strings outside any locale file: every user-facing string in `settings/*.lua`, `SlashCommands.lua`, `MacroManager.lua`, `defaults/Categories.lua` `displayName` / `emptyText`. Per the project's invariant this is intentional, not a defect.

## 10. Events

**AceEvent mix-in** (`Core.lua:5` includes `"AceEvent-3.0"`). All event registration is centralized in `KCM:OnEnable` (`Core.lua:355-362`):

| Event | Handler | Site |
|---|---|---|
| `PLAYER_ENTERING_WORLD` | `OnPlayerEnteringWorld` | `Core.lua:287-297` |
| `BAG_UPDATE_DELAYED` | `OnBagUpdateDelayed` | `Core.lua:299-302` |
| `PLAYER_SPECIALIZATION_CHANGED` | `OnSpecChanged` | `Core.lua:304-315` |
| `PLAYER_REGEN_ENABLED` | `OnRegenEnabled` | `Core.lua:317-324` |
| `GET_ITEM_INFO_RECEIVED` | `OnItemInfoReceived` | `Core.lua:326-345` |
| `LEARNED_SPELL_IN_SKILL_LINE` | `OnLearnedSpell` | `Core.lua:347-353` |

Modern replacement for removed `LEARNED_SPELL_IN_TAB` is correct (Midnight 12.0).

The `settings/Panel.lua:823-826` bootstrap registers a *separate* `CreateFrame("Frame")` listener for `PLAYER_LOGIN` and `ADDON_LOADED` — not via AceEvent — to defer panel registration. Idempotent and unregistered after `KCM.Settings.main` is set.

Combat-lockdown discipline: macro-write paths gate on `InCombatLockdown()` and queue (`MacroManager.lua:328`, `425`, `471`). `PLAYER_REGEN_ENABLED` calls `MacroManager.FlushPending` (`Core.lua:319`). Settings-panel open is combat-blocked (`settings/Panel.lua:802-805`). Pure modules (Selector, Ranker, Classifier, BagScanner, TooltipCache) never touch protected APIs — invariant called out at `MacroManager.lua:1-3`.

## 11. Frames / widgets

All four `KCM*` widgets are **Lua-only AceGUI custom widgets**, no XML templates. None are secure templates, none manage action bars directly:

- **`KCMIconButton`** (`KCMIconButton.lua`): generic icon button with hover swatch (gold 25% alpha) used for row action buttons. `CreateFrame("Button", nil, UIParent)` (`KCMIconButton.lua:101`). Not pooled — AceGUI's pool reuse handles lifecycle.
- **`KCMScoreButton`** (`KCMScoreButton.lua`): like IconButton with no-op SetLabel; tooltip-title repurposed for the per-row Ranker.Explain breakdown.
- **`KCMItemRow`** (`KCMItemRow.lua`): priority row (owned glyph + item icon + quality glyph + name + pick star). Drives real `GameTooltip:SetItemByID` / `SetSpellByID` directly (`KCMItemRow.lua:288-298`). Truncates name (`SetMaxLines(1)`).
- **`KCMMacroDragIcon`** (`KCMMacroDragIcon.lua`): draggable macro pickup. `frame:RegisterForDrag("LeftButton")` + `PickupMacro(idx)` (`KCMMacroDragIcon.lua:128-129, 153-158`). `PickupMacro` is **unprotected**; this widget never calls `CreateMacro`/`EditMacro`/`DeleteMacro`. `GetMacroIndexByName` and `GetMacroInfo` are read-only.

Taint hazards: addon manipulates **macros** (taint-sensitive), but the surface is narrow:

- Only `MacroManager.lua` calls `CreateMacro` (`MacroManager.lua:260`) or `EditMacro` (`MacroManager.lua:271`). `DeleteMacro` is **never called** anywhere (verified via grep) — slot is the user's per `CLAUDE.md` invariant.
- Both write sites guard on `InCombatLockdown()` and queue (`MacroManager.lua:328-343`, `MacroManager.lua:425-438`). Bounded retry: `MAX_FLUSH_ATTEMPTS = 3` at `MacroManager.lua:19` enforced in `FlushPending` (`MacroManager.lua:486-496`).
- Body-size ceiling: 255 bytes (`MacroManager.lua:18`) — when exceeded falls back to empty body and prints a one-shot warning per cat (`MacroManager.lua:293-309`).
- `KCM.ResetAllToDefaults` calls `Pipeline.Recompute` directly rather than `RequestRecompute` (`Core.lua:282`); this is safe today only because every protected-API caller (MacroManager) self-defers (called out as F-011 in prior review and is unfixed).

## 12. Debug / logging

`Debug.lua` (42L, single file):

- Gated by `KCM.db.profile.debug` (`Debug.lua:8-10`). No level system — debug is binary on/off.
- `KCM.Debug.Print(fmt, ...)` early-returns when off (`Debug.lua:38`), then `pcall(string.format, fmt, ...)` and prefixes `|cff00ffff[CM]|r ` (`Debug.lua:6, 41`).
- Toggle path: `KCM.Debug.Toggle()` (`Debug.lua:12-35`) routes through `KCM.Settings.Helpers.SetAndRefresh("debug", v)` so the panel checkbox stays in sync, with a defensive direct-DB-write fallback for early boot.
- Perf impact: when off, every `KCM.Debug.Print` call is a `IsOn()` table lookup + early return — cheap. The format-substitution is wrapped in `pcall` only when on.
- A specific high-frequency log is permanently commented out at `Core.lua:111-114` because it would fire N×M times during login — replace-with-flag pattern instead of leaving live noise.

## 13. Error handling

- `pcall` is used in three categories:
  - Per-category recompute isolation: `pcall(P.RecomputeOne, cat.key, scoreCache, reason)` (`Core.lua:137`) so one bad scorer can't break the seven other macros.
  - `MacroManager.FlushPending` wraps each retry in `pcall` (`MacroManager.lua:481-484`).
  - Settings tab builder execution: `pcall(builder, KCM.Settings.main)` (`settings/Panel.lua:688, 720`).
  - `KCMIconButton` / `KCMScoreButton`'s `SettingsPanel` expand uses `pcall` to tolerate Blizzard private-API drift (`settings/Panel.lua:787`).
  - `Debug.Print`'s `string.format` is `pcall`'d (`Debug.lua:39`).
- Nil checks: pervasive defensive guards (`if not (KCM.Categories and KCM.Selector and KCM.MacroManager) then return end` at `Core.lua:91-93`, etc.). `BagScanner.Scan` checks `C_Container` presence (`BagScanner.lua:28-30`).
- API forward-compat: `MacroManager.spellNameFor` (`MacroManager.lua:53-68`) tries `C_Spell.GetSpellName`, then `C_Spell.GetSpellInfo`, then legacy `GetSpellInfo`. `Classifier.lua:127-133` does the same for `C_Item.GetItemInfoInstant` → legacy `GetItemInfo`. `KCMItemRow.lua:80-91` fallback chain `C_Item.GetItemNameByID` → `_G.GetItemInfo`.
- Deprecated APIs: `GetItemInfo` is still in use as a multi-return for quality/ilvl/subType (`Ranker.lua:70`, `TooltipCache.lua:324`, `Classifier.lua:132`, `KCMItemRow.lua:87`/`127`). It is the documented retail API; not yet removed in 12.0.x. `GetItemIcon` is referenced as a legacy fallback (`KCMMacroDragIcon.lua:50`).

## 14. Packaging

- `.pkgmeta`: **absent** (verified by `ls`).
- `.gitattributes` and `.gitignore` present (`.gitattributes` declares CRLF for Lua/XML/MD per project convention).
- `LICENSE` is MIT (matches `## X-License: MIT` in TOC).

No CurseForge/Wago/WoWInterface project IDs in the TOC; the README badge references CurseForge `1522944` (`README.md:4`) but TOC does not declare `## X-Curse-Project-ID:`.

## 15. Documentation

Three top-level docs: `README.md` (176L), `CLAUDE.md` (70L), `ARCHITECTURE.md` (77L). Plus a `docs/` directory of 10 topic files referenced from the `CLAUDE.md` doc index, and `defaults/README.md`.

### Drift verification — README.md

5 spot-checked claims:

1. **"Ten account-wide global macros"** (`README.md:9`) — verified: `defaults/Categories.lua:26-121` defines 10 entries (8 single + 2 composite).
2. **Category table with macro names** (`README.md:13-22`) — `KCM_FOOD/KCM_DRINK/KCM_HP_POT/KCM_MP_POT/KCM_HS/KCM_FLASK/KCM_CMBT_POT/KCM_STAT_FOOD/KCM_HP_AIO/KCM_MP_AIO` — all match `defaults/Categories.lua` `macroName` fields exactly.
3. **"Macro writes that would land during combat are queued and applied when you leave combat"** (`README.md:24`) — verified at `MacroManager.lua:328-343` and flushed via `Core.lua:317-324` → `MacroManager.FlushPending`.
4. **Version 1.4.0 added "master enable toggle (`/cm enable`, Settings → General)"** (`README.md:172`) — *partially false*. The master enable toggle exists in DB (`Core.lua:28`) and as a panel checkbox (`settings/General.lua:74-79`), but there is **no `/cm enable` verb** in the COMMANDS table (`SlashCommands.lua:1147-1214`). The toggle is reachable only via `/cm set enabled true|false` (schema-driven). README drift.
5. **"Newly-learned spell entries hydrate without a reload"** (1.1.0 changelog, `README.md:176`) — verified: `OnLearnedSpell` at `Core.lua:347-353` registers `LEARNED_SPELL_IN_SKILL_LINE` and triggers `RequestRecompute`.

### Drift verification — CLAUDE.md

5 spot-checked claims:

1. **"`MacroManager` is the only module allowed to call protected macro APIs"** — verified: only `MacroManager.lua:260, 271` call `CreateMacro`/`EditMacro`. No other file matches.
2. **"`perCharacter=false` puts them in the account-wide pool"** — verified: `MacroManager.lua:260` `CreateMacro(macroName, icon, body, false)`.
3. **"Composite categories don't pick items — they compose other categories' picks"** — verified: `Core.lua:96-105` branches on `cat.composite` and dispatches to `MacroManager.SetCompositeMacro` (`MacroManager.lua:374-460`).
4. **"`KCM.ResetAllToDefaults(reason)` in `Core.lua` wipes + resyncs"** — verified at `Core.lua:269-285`.
5. **Module publishing pattern `KCM.Foo = KCM.Foo or {}`** — verified across `Debug.lua:4`, `BagScanner.lua:14`, `Classifier.lua:21`, `Ranker.lua:23`, `Selector.lua:17`, `MacroManager.lua:14`, `TooltipCache.lua:33`, `SpecHelper.lua:8`, `Categories.lua:24`.

### Drift verification — ARCHITECTURE.md

5 spot-checked claims:

1. **"Ten account-wide global macros (`KCM_FOOD`, ..., `KCM_MP_AIO`)"** (`ARCHITECTURE.md:7`) — verified.
2. **"`embeds.xml` is the load manifest"** and lib list (`ARCHITECTURE.md:50-62`) — verified against `embeds.xml:5-12`.
3. **"The TOC's `## Interface:` line is `120000, 120001, 120005`"** (`ARCHITECTURE.md:62`) — matches `ConsumableMaster.toc:1`.
4. **Load-order list at lines 64-77** — matches `ConsumableMaster.toc:19-54` exactly.
5. **"`schemaVersion`"** appears nowhere in ARCHITECTURE.md though `Core.lua:27` defines it; minor omission, not drift.

Drift summary: only the `/cm enable` claim in `README.md:172` is wrong against source. CLAUDE.md and ARCHITECTURE.md are accurate.

## 16. Tests / lint

- `.luacheckrc`: **absent** (verified by `ls`).
- No test harness, mock framework, or CI configs (`.github/`, `tests/`, `spec/`, etc. all absent).
- "No automated tests. Validation is manual, in-game" stated in `CLAUDE.md` line "Working environment". Smoke-test playbook is `docs/smoke-tests.md` (referenced from `CLAUDE.md` doc index).

## 17. Notable strengths

1. **Hard taint firewall.** `MacroManager` is the sole caller of `CreateMacro`/`EditMacro` (`MacroManager.lua:260`/`271`); `DeleteMacro` is never called. Every other module is provably pure. Combat-deferral is encapsulated entirely inside MacroManager — Selector/Ranker/Classifier/BagScanner/TooltipCache run freely in combat.
2. **Coalescing recompute pipeline.** `RequestRecompute` (`Core.lua:158-175`) collapses event flurries into a single `C_Timer.After(0, ...)` tail call. Per-pass `scoreCache` (`Core.lua:132`) memoizes GetItemInfo + tooltip parse + `bestImmediate` walk (`Ranker.lua:282-302`) so cross-category overlap doesn't re-parse. Debounced panel refresh with cap (`settings/Panel.lua:752-774`) handles GIIR storms.
3. **Opaque numeric ID convention.** Positive = itemID, negative = `KCM.ID.AsSpell(spellID)` (`Core.lua:18-23`); only MacroManager and the UI fork on the sign — every other layer treats them as plain numeric keys. Single helper module, well documented.
4. **Selective bag-vs-non-bag GIIR handling.** `OnItemInfoReceived` (`Core.lua:326-345`) distinguishes bag items (full pipeline) from priority-list items (panel refresh only). This is a well-reasoned perf optimization that avoids the dozens-of-recomputes-per-second tax during first panel open.
5. **English-only by design with `ST_*` constants pinned** (`Classifier.lua:28-30`, `TooltipCache.lua:74-82`). Tooltip text normalization handles NBSP and `|4singular:plural;` grammar escapes (`TooltipCache.lua:99-103`) — both real Midnight gotchas.
6. **Centralized reset.** Panel button (`settings/General.lua:50-55`) and `/cm reset` StaticPopup (`SlashCommands.lua:38-44`) both delegate to `KCM.ResetAllToDefaults` (`Core.lua:269-285`). One reset path, predictable semantics.
7. **Schema-driven `/cm list/get/set`** with validation at registration (`settings/Panel.lua:103-148`) and combat-deferred hot reset (`MacroManager.InvalidateState` at `MacroManager.lua:517-523`).
8. **Per-category pcall isolation** in `Pipeline.Recompute` (`Core.lua:137`): one bad scorer fails its own macro write, leaves the other seven intact.

## 18. Notable weaknesses / hazards

Several findings from `reviews/2026-05-02/01_FINDINGS.md` have been **fixed since that review**:

- F-005 secondary-stat dedup: now dedupes (`settings/StatPriority.lua:122-128`).
- F-008 composite skip in MatchAny: now skipped (`Classifier.lua:161-163`).
- F-009 bestImmediate memoization: now cached on scoreCache (`Ranker.lua:288-298`).
- F-014 `Helpers.Set` section param: now drops `section` (`settings/Panel.lua:76-81`).
- F-015 `next` shadow: renamed `nextValue` (`Debug.lua:17`).
- F-001 `/cm set` rejected-write: now early-returns with chat notice (`SlashCommands.lua:603-605`).

Still-live weaknesses verified against source:

1. **AceConfig-3.0 is embedded but completely unused.** `embeds.xml:12` plus `libs/AceConfig-3.0/` ship the library; no production code references it. Pure dead weight (~58L of code + AceConfigRegistry/Cmd/Dialog transitively).
2. **Dead public exports.** Symbols documented in `docs/module-map.md` that have **zero** call sites in production: `BagScanner.GetAllItemIDs`, `MacroManager.HasPending`/`PendingCount`/`IsAdopted`, `TooltipCache.IsPending`/`PendingIDs`/`Stats`, `settings/Panel.lua` `SchemaForPanel`/`MakeCheckbox`. Verified via `grep -rln <sym>` against non-libs `.lua`. Each returns no hits — the symbols don't even exist as definitions in current source (likely already removed but docs/grep targets carry the cruft from the prior review).
3. **`/cm enable` verb advertised in README but missing from COMMANDS table.** `README.md:172` 1.4.0 changelog says "master enable toggle (`/cm enable`, ...)". Actual toggle path is `/cm set enabled <bool>` via the schema (`SlashCommands.lua:1204-1205`). Cosmetic but breaks README-promised UX.
4. **Two panel-registration paths run on every login.** `OnInitialize` does **not** call `KCM.Options.Register()` (only the bootstrap event does), so today there's only one live path — but `KCM.Options.Register` (`settings/Panel.lua:736-739`) is still exposed and reachable via `O.Register()`. F-006 from prior review described dual init; current state has been simplified, but the public `O.Register` still exists.
5. **`KCM.ResetAllToDefaults` calls `Pipeline.Recompute` (synchronous) not `RequestRecompute`** (`Core.lua:282`). Correct today only because every protected-API caller (MacroManager) self-defers; if any future module calls a protected API outside MacroManager this becomes a taint hazard. Comment at `Core.lua:255-265` explains, but the code chooses immediate over deferred.
6. **`schemaVersion` declared but no migration logic exists.** `Core.lua:27` sets `schemaVersion = 1`; nothing in source ever reads it. When v2 lands, callers who expect a migration will discover the absence of one.
7. **Non-debounced `Recompute` skips panel refresh when `enabled=false`.** F-003 from prior review: `Core.lua:125-156` — when master enable is off, the inner branch returns at `Core.lua:144` (well, the elseif at 142-143) before `Options.RequestRefresh` at line 151… actually `Core.lua:151-155` is **outside** the `enabled` branch, so it does fire. Re-verified — F-003 in the prior review described this and it's fine in current source. Not a current weakness.
8. **`/cm priority <cat> reset` chat confirmation does not mention discovered-set preservation** (`SlashCommands.lua:787-799`). F-013 from prior review still applies — the panel popup does, the CLI message does not.
9. **`OnSpecChanged` does not always force `_viewedSpec` retrack.** `Core.lua:310-313` only retracks when `_viewedSpecAuto` is true. F-004 from prior review still applies and is intentional but sticky.
10. **Hot-path duplication in `KCMItemRow.craftingQualityAtlas`** (`KCMItemRow.lua:125-142`) calls `GetItemInfo` per row in addition to the `iconForItem` / `itemDisplayName` calls in the same `RefreshDisplay` (`KCMItemRow.lua:177-225`). With 30 rows × full re-render this is ~30 redundant `GetItemInfo` calls. F-020 from prior review — unchanged.
11. **`KCMItemRow.applyLabelWidth` hardcodes constants** (`KCMItemRow.lua:108-115`) that mirror the named constants at file top — same F-019 layout-fragility concern, unchanged.
12. **Spec-change retrack of `_viewedSpec`** — F-004, see #9 above.
13. **`formatNumber` allocates `string.reverse` chain per call** (`settings/Category.lua:78-85`) — F-017, unchanged. Per panel render with 30 rows × ~5 signals ≈ 300 calls.
14. **Bag-scan in `BagScanner.Scan` is fully recomputed each call** (`BagScanner.lua:24-47`); a memoization with dirty flag driven by BAG_UPDATE_DELAYED is acknowledged in the file header as deferred (`BagScanner.lua:9-11`). At 5 bags × ~30 slots × N items the cost is small but it runs N times during a recompute (once explicitly via `Pipeline.RunAutoDiscovery`, plus per-cat selector probes).
15. **`SlashCommands.lua` is 1257 lines long** with all command logic in one file. The dispatch is clean (single `COMMANDS` table) but the file mixes parsing, formatting, dispatch, sub-namespaces, and dump targets. Smaller files would aid review.
16. **Schema migration absent** — see #6.
