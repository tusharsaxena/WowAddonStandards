# WhatGroup — Current-State Analysis (2026-05-03)

Read-only principal-engineer analysis. All claims cited to `relative/path:line`. Verification done against source, not docs.

## 1. TOC metadata

Full quote of `WhatGroup.toc:1-24`:

```
## Interface: 120000,120001,120005
## Title: Ka0s WhatGroup
## Notes: Notifies you of group details after joining via Premade Group Finder
## Author: add1kted2ka0s
## Version: 1.2.0
## iconTexture: 134149
## SavedVariables: WhatGroupDB
## DefaultState: enabled
## Category-enUS: Chat & Communication
## X-License: MIT

# Libraries (must load first)
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
libs\AceEvent-3.0\AceEvent-3.0.lua
libs\AceConsole-3.0\AceConsole-3.0.lua
libs\AceDB-3.0\AceDB-3.0.lua
libs\AceGUI-3.0\AceGUI-3.0.xml

# Core
WhatGroup.lua
WhatGroup_Settings.lua
WhatGroup_Frame.lua
```

- Multi-toc Interface line `120000,120001,120005` (`WhatGroup.toc:1`) — retail-only by design (CLAUDE.md confirms; no `_Cata`/`_Vanilla` variants).
- No `## Dependencies`, `## OptionalDeps`, `## LoadManagers`, `## SavedVariablesPerCharacter` — single account-shared profile (`WhatGroup.lua:234` `AceDB:New("WhatGroupDB", defaults, true)`).
- No localization metadata (`## X-Localizations`) — absent by design.

## 2. Folder/file layout

```
WhatGroup/
├── ARCHITECTURE.md
├── CLAUDE.md
├── LICENSE                            (MIT)
├── README.md
├── WhatGroup.toc                      24 lines
├── WhatGroup.lua                     921 lines
├── WhatGroup_Settings.lua          1,056 lines
├── WhatGroup_Frame.lua               319 lines
├── docs/                            (9 topic docs)
├── libs/                            (7 libs)
├── media/screenshots/               (logo + 2 screenshots)
└── reviews/2026-05-02/              (5 review files)
```

LOC total: 2,296 lua + 24 toc.
- `WhatGroup.lua` — 921 lines
- `WhatGroup_Settings.lua` — 1,056 lines
- `WhatGroup_Frame.lua` — 319 lines

No subdirs under the addon root for source. Three flat `.lua` files. No XML manifest beyond AceGUI's lib-internal `.xml`.

## 3. Module-loading order (TOC)

Per `WhatGroup.toc:13-24`:

1. `libs/LibStub/LibStub.lua`
2. `libs/CallbackHandler-1.0/CallbackHandler-1.0.lua`
3. `libs/AceAddon-3.0/AceAddon-3.0.lua`
4. `libs/AceEvent-3.0/AceEvent-3.0.lua`
5. `libs/AceConsole-3.0/AceConsole-3.0.lua`
6. `libs/AceDB-3.0/AceDB-3.0.lua`
7. `libs/AceGUI-3.0/AceGUI-3.0.xml`  *(only XML manifest used; pulls widgets)*
8. `WhatGroup.lua`              — bootstrap, hooks, capture, slash
9. `WhatGroup_Settings.lua`     — schema + helpers + panel
10. `WhatGroup_Frame.lua`       — popup dialog

Order is correct: `WhatGroup.lua` registers `WhatGroup` via `NewAddon` (`WhatGroup.lua:23-25`); `WhatGroup_Settings.lua:27` resolves it via `GetAddon("WhatGroup")`. `OnInitialize` (`WhatGroup.lua:226`) reads `self.Settings.BuildDefaults` — which is set by `WhatGroup_Settings.lua` loading second (file-load runs before ADDON_LOADED → OnInitialize).

## 4. Library stack

Vendored under `libs/`:

| Lib | Version (MAJOR/MINOR) | Source line |
|---|---|---|
| LibStub | r2 | `libs/LibStub/LibStub.lua:3` |
| CallbackHandler-1.0 | r8 | `libs/CallbackHandler-1.0/CallbackHandler-1.0.lua:2` |
| AceAddon-3.0 | r13 | `libs/AceAddon-3.0/AceAddon-3.0.lua:33` |
| AceEvent-3.0 | r4 | `libs/AceEvent-3.0/AceEvent-3.0.lua:15` |
| AceConsole-3.0 | r7 | `libs/AceConsole-3.0/AceConsole-3.0.lua:13` |
| AceDB-3.0 | r33 | `libs/AceDB-3.0/AceDB-3.0.lua:44` |
| AceGUI-3.0 | r41 | `libs/AceGUI-3.0/AceGUI-3.0.lua:28` |

No `AceHook-3.0`, no `AceConfig-3.0`, no `LibSharedMedia` — deliberate omissions per CLAUDE.md taint hard rule.

NewAddon mixin list (`WhatGroup.lua:23-25`): `AceConsole-3.0` (slash) and `AceEvent-3.0` (events) only. AceDB used directly via `LibStub("AceDB-3.0"):New(...)` (`WhatGroup.lua:234`). AceGUI used directly across `WhatGroup_Settings.lua` (e.g. `:28`, `:649`, `:699`, etc.).

**Are libs necessary at this size?** Mostly yes:

- AceAddon — gives lifecycle (OnInitialize/OnEnable) and the addon-table identity used by Settings/Frame to fetch.
- AceDB — single-line saved-variables with profile semantics; DIY would be ~30 lines but lose profile/defaults plumbing.
- AceConsole — saves `SlashCmdList` boilerplate (5 lines) + arg trimming.
- AceEvent — registers events on a self-frame; trivially replaceable but the savings are minor.
- **AceGUI** — heavily used for the canvas Settings panel (ScrollFrame, CheckBox, Slider, SimpleGroup/Flow, Heading, Label, Button). This is the biggest dependency by code size and arguably the most justified — hand-rolling the schema-driven render loop in `WhatGroup_Settings.lua:817-862` against raw Blizzard frames would be a large cost.

The Ace stack here is justified — drop AceGUI and you'd hand-roll ~600 lines of UI glue. It's not "overkill for 3 lua files" because two of those files are 1,000+ LOC.

## 5. Core architecture pattern

Three-file split:

- `WhatGroup.lua` — AceAddon bootstrap, hooks, capture/state machine, slash dispatch, teleport-spell table, chat notification, labels.
- `WhatGroup_Settings.lua` — schema rows, helpers (Get/Set/Resolve/RestoreDefaults), schema validation, AceGUI canvas panel, lazy registration.
- `WhatGroup_Frame.lua` — single popup dialog, lazy `buildFrame()`, secure-action teleport button.

Entry point — `WhatGroup.lua:22-26`:

```lua
local existing = _G.WhatGroup or {}
local WhatGroup = LibStub("AceAddon-3.0"):NewAddon(
    existing, "WhatGroup",
    "AceConsole-3.0", "AceEvent-3.0")
_G.WhatGroup = WhatGroup
WhatGroup.VERSION = "1.2.0"
```

Hooks installed at file-load (NOT in OnEnable) — `WhatGroup.lua:39-51`. The deliberate file-load placement is documented at `WhatGroup.lua:29-38`: registering the hooks in OnEnable was tainting GameMenu's Logout closures.

`OnInitialize` (`WhatGroup.lua:226-243`) builds AceDB + registers slash. `OnEnable` (`WhatGroup.lua:245-259`) only registers events; everything else (Settings panel, popup, StaticPopup) is lazy.

Mediator: `WhatGroup` global table is the shared bus. `Settings` and `Frame` reach into `WhatGroup.pendingInfo`, `WhatGroup.db`, `WhatGroup.Labels`, `WhatGroup._print`, `WhatGroup._dbg` directly. No formal interfaces.

## 6. Settings / saved variables

- AceDB — yes. `WhatGroup.lua:234` — `self.db = LibStub("AceDB-3.0"):New("WhatGroupDB", defaults, true)`. Third arg `true` = single shared `Default` profile across all chars/realms (intentional, CLAUDE.md hard rule).
- SavedVariables: `WhatGroupDB` (`WhatGroup.toc:7`).
- No `SavedVariablesPerCharacter`.
- Defaults built from schema by `Settings.BuildDefaults()` — `WhatGroup_Settings.lua:306-323` walks `Schema` and threads each row's `default` into a nested `out.profile` table.
- Schema rows (`WhatGroup_Settings.lua:77-184`):
  - `enabled` (bool, default true)
  - `frame.autoShow` (bool, default true)
  - `notify.enabled` (bool, default true)
  - `debug` (bool, default false)
  - `notify.delay` (number, default 1.5, min 0, max 10, step 0.5)
  - `notify.showInstance` / `showType` / `showLeader` / `showPlaystyle` / `showClickLink` / `showTeleport` (all bool, all default true)
- Schema-shape validation at `WhatGroup_Settings.lua:265-298` — runs at panel-register time; missing/empty `path`, invalid `type`, non-string `section/group/label` print errors but don't abort.
- No migration code, no `db.global.version`, no upgrade path. Adding a setting = one `default`-bearing schema row; AceDB merges it for existing users on next login (standard AceDB behavior).

## 7. Options UI

`WhatGroup_Settings.lua` approach:

- Two-page canvas hierarchy registered via Blizzard's modern Settings API:
  - Parent "Ka0s WhatGroup" (`WhatGroup_Settings.lua:1010-1013`) — `Settings.RegisterCanvasLayoutCategory` + `Settings.RegisterAddOnCategory`. Body = logo + TOC notes + slash command list (`Helpers.BuildMainContent`, `WhatGroup_Settings.lua:879-942`).
  - Sub-page "General" (`:1052-1054`) — `Settings.RegisterCanvasLayoutSubcategory` parented to the canvas. Body = schema-driven widget render.
- Both panel bodies are deferred to OnShow → `C_Timer.After(0, ...)` (`:1000-1008`, `:1031-1050`) so the AceGUI build runs on the next frame in a non-secure context. Boot taint avoidance.
- Registration is fully lazy (`Settings.Register()` at `:963` is only invoked from `runConfig` first call, `WhatGroup.lua:880-882`).
- `RenderSchema` (`:817-862`) pairs widgets into 50/50 Flow rows; rows tagged `solo = true` get their own line.
- Custom always-visible scrollbar patch (`Helpers.PatchAlwaysShowScrollbar`, `:534-641`) ported from KickCD — overrides AceGUI ScrollFrame's `FixScroll` so the bar greys out instead of disappearing.
- Each widget registers a refresher into `Settings._refreshers` keyed by path with order in `Settings._refresherOrder` (`:732-737`, `:757-762`). `Helpers.RefreshAll` (`:344-354`) re-syncs widgets after `/wg set` / `/wg reset`.
- `Helpers.Set` (`:231-245`) is the orchestrated single write-path: write → onChange → RefreshAll. CLI, widget callbacks, and `RestoreDefaults` all route through it.

## 8. Slash commands

Registered (`WhatGroup.lua:241-242`):
- `/wg`
- `/whatgroup` (alias)

Verbs from `COMMANDS` table (`WhatGroup.lua:654-674`):

| Verb | Description (verbatim) |
|---|---|
| `help` | List available commands |
| `show` | Show the last group info dialog |
| `test` | Inject synthetic group info and run the full notify + frame flow |
| `config` | Open the Ka0s WhatGroup Settings panel |
| `list` | List every setting and its current value |
| `get` | Print a setting's current value — `/wg get <path>` |
| `set` | Set a setting — `/wg set <path> <value>` (try /wg list) |
| `reset` | Reset every setting to defaults |
| `debug` | Toggle debug logging |

Bare `/wg` → help. Unknown command → "unknown command" + help (`WhatGroup.lua:703-704`). Help iterates the table (`:682-688`) so it auto-syncs.

## 9. Localization

- AceLocale: **absent**. Not in TOC, not vendored, not used.
- Hardcoded English strings (non-exhaustive but representative):
  - Chat prefix `"|cff00FFFF[WG]|r"` (`WhatGroup.lua:53`).
  - Group-type labels `"Mythic+"`, `"Raid (Current)"`, `"Heroic Raid"`, `"PvP"`, `"Dungeon"`, `"Raid"`, `"Group"` (`WhatGroup.lua:373-388`).
  - Notification body strings (`Group:`, `Instance:`, `Type:`, `Leader:`, `Playstyle:`, `Teleport:`) — `WhatGroup.lua:417-446`.
  - Click-link label `"[Click here to view details]"` (`WhatGroup.lua:414`).
  - Slash command descriptions (`WhatGroup.lua:655-672`).
  - All schema labels/tooltips (`WhatGroup_Settings.lua:77-184`).
  - Popup row labels `"Group:"`, `"Instance:"`, `"Type:"`, `"Leader:"`, `"Playstyle:"`, `"Teleport:"` (`WhatGroup_Frame.lua:101-109`).
  - Popup title "WhatGroup — Group Info" (`WhatGroup_Frame.lua:66`); Close button text (`:141`).
  - "No data" / "Unknown" placeholders (`WhatGroup.lua:273-275`, `WhatGroup_Frame.lua:240-244`).
  - Reset confirmation popup body (`WhatGroup_Settings.lua:377`); uses `YES`/`NO` globals as fallback (`:378-379`).
  - **Smart fallback**: `WhatGroup.Labels.PLAYSTYLE` (`WhatGroup.lua:364-369`) reads Blizzard's localized `GROUP_FINDER_GENERAL_PLAYSTYLE1..4` globals — matches the LFG UI's current locale. The server-rendered `info.playstyleString` (`WhatGroup.lua:284`, `:392-395`) is also locale-aware.

CLAUDE.md confirms English-only is a deliberate non-goal (see `docs/scope.md`).

## 10. Events

Registered events (`WhatGroup.lua:256-257`):

- `GROUP_ROSTER_UPDATE` — handler at `WhatGroup.lua:543-562`. Detects in/out-of-group transitions; fires `_TryFireJoinNotify("ROSTER transition")` on not-in→in flip; calls `WipeCapture()` on leave.
- `LFG_LIST_APPLICATION_STATUS_UPDATED` — handler at `WhatGroup.lua:564-619`. Status routing: `applied` → push capture into `pendingApplications[appID]`; `invited` → wait; `inviteaccepted` → choose better of fresh/queued capture (mapID-preference, `:589-598`), set `pendingInfo`, fire `_TryFireJoinNotify("inviteaccepted")`.

Plus one event registered ad-hoc inside the popup:

- `PLAYER_REGEN_ENABLED` — registered on `f` inside `ConfigureTeleportButton` when in combat (`WhatGroup_Frame.lua:175-186`); also registered on a dedicated wait frame when first-show is in combat (`:289-300`).

Hooks (not events) — both file-load `hooksecurefunc` (`WhatGroup.lua:39-51`):

- `C_LFGList.ApplyToGroup` post-hook → `WhatGroup:OnApplyToGroup`.
- `SetItemRef` post-hook filtered on `^WhatGroup:` link prefix → `WhatGroup:OnSetItemRef`.

No `PLAYER_LOGIN`, no `LFG_LIST_APPLICANT_LIST_UPDATED`, no `PLAYER_ENTERING_WORLD` — minimal event surface.

## 11. Frames

`WhatGroup_Frame.lua` — pure Lua, no XML. One global frame `WhatGroupFrame` (`:35`).

- Lazy creation in `buildFrame()` (`:32-235`); guarded one-shot via `if f then return end` (`:33`).
- `BackdropTemplate` for the panel (`:35`), `UIPanelButtonTemplate` for Close (`:138`), `SecureActionButtonTemplate` for the teleport button (`:124`).
- Drag handle = title-bar sub-frame with `OnMouseDown`/`OnMouseUp` start/stop (`:60-62`).
- Teleport button uses macro-attribute pathway (`btn:SetAttribute("type","macro")`, `btn:SetAttribute("macrotext","/cast "..spellName)`, `:216-217`) — sidesteps the non-secure `CastSpellByID` taint.
- `tinsert(UISpecialFrames, "WhatGroupFrame")` (`:150`) deferred to first popup build (the comment block `:144-149` explains: file-load registration was tainting Logout).
- ESC closes the popup (via UISpecialFrames).
- Combat handling:
  - Reconfiguring the secure button mid-combat: `ConfigureTeleportButton` checks `InCombatLockdown()` (`:173`) and stashes pending info + waits for `PLAYER_REGEN_ENABLED`.
  - First-show-in-combat defer: `ShowFrame` checks `not f and InCombatLockdown()` (`:282`) and queues build until `PLAYER_REGEN_ENABLED`.

Group-frame integration risks:
- The popup is standalone — no integration with `CompactPartyFrame` / `PartyFrame` / `RaidFrame`. No risk.
- The secure button is anonymous (no `name`) and parented to `f` (`WhatGroup_Frame.lua:124`); position is computed at build time from `lblPort:GetLeft()/GetTop()` (`:121-122`) — sensitive to font/scale changes between `lblPort` creation and button creation, but they're created in the same frame on the same load, so layout is consistent.

## 12. Debug/logging

- `WhatGroup.debug` boolean seeded from `db.profile.debug` (`WhatGroup.lua:239`).
- Local `dbg(...)` (`WhatGroup.lua:63-67`) prints with cyan `[WG]` + orange `[DBG]` prefixes when flag is on. Exposed publicly as `WhatGroup._dbg` (`:75`) so `WhatGroup_Frame.lua` can use it (`WhatGroup_Frame.lua:190-195`, `:307-314`).
- `p(...)` (`WhatGroup.lua:69-71`) is the cyan-prefixed user-facing print; exposed as `WhatGroup._print` (`:72`); the Settings layer's `pout` (`WhatGroup_Settings.lua:48-51`) routes through it.
- Callsites: `dbg` is used liberally — e.g. `WhatGroup.lua:268`, `:317-319`, `:462`, `:474`, `:506`, `:521`, `:549-551`, `:565`, `:602-605`. Around 12 dbg sites in capture-flow, useful for diagnostics.
- `/wg debug` (`WhatGroup.lua:908-921`) toggles persisted via `Helpers.Set("debug", ...)` so the schema row's onChange (`WhatGroup_Settings.lua:114`) keeps `WhatGroup.debug` in sync.

## 13. Error handling

- `pcall` usage:
  - `WhatGroup.lua:895-905` — wraps `SettingsPanel` private-internal CategoryEntry unfold (well-justified; private API).
  - `WhatGroup_Settings.lua:236` — wraps schema `onChange` callbacks.
  - `WhatGroup_Settings.lua:348` — wraps refresher callbacks.
  - `WhatGroup_Settings.lua:790` — wraps `InlineButton` onClick.
- Nil checks: extensive defensive guards throughout `WhatGroup.lua:266-321`, `:404-447`, `:543-619`. Examples: `info.name or "Unknown"`, `info.activityIDs or {}`, multi-arg `or` chains for `C_Spell.GetSpellName` falling back to `GetSpellInfo` (`WhatGroup_Frame.lua:203-206`).
- Deprecated APIs:
  - `GetRaidRosterInfo` — **absent**. Not used.
  - `GetNumGroupMembers` — **absent**. The code uses `IsInGroup()` (`WhatGroup.lua:258`, `:511`, `:544`) which is the modern equivalent.
  - `GetSpellInfo` — used as fallback only when `C_Spell.GetSpellName` is unavailable (`WhatGroup_Frame.lua:204`); same for `C_Spell.GetSpellTexture` vs `GetSpellTexture`-by-id default 134400 (`:205-206`). Forward-compatible.
  - `GetAddOnMetadata` — used as fallback to `C_AddOns.GetAddOnMetadata` (`WhatGroup_Settings.lua:900`).
  - `IsSpellKnown` — guarded with `IsSpellKnown and IsSpellKnown(...)` (`WhatGroup.lua:331`, `:336`).
- `LFG_LIST_APPLICATION_STATUS_UPDATED:inviteaccepted` reuses `appID` as a search-result-info ID (`WhatGroup.lua:588`); the comment at `:581-587` flags this as a TODO (F-004 in reviews) — works today only because for the player's own application, `appID == searchResultID`.
- No global error handler / `geterrorhandler` integration.

## 14. Packaging

- `.pkgmeta` — **absent**. No CurseForge/WoWInterface auto-package config.
- `.gitattributes` — present (`WhatGroup/.gitattributes`); per CLAUDE.md, enforces CRLF for `.lua/.toc/.xml`.
- `.gitignore` — present.
- README badge references `curseforge/v/1489907` (`README.md:4`) suggesting an existing CurseForge listing, but no `.pkgmeta` to drive automation. Manual upload, presumably.
- No GitHub Actions / CI config.

## 15. Documentation — drift check

### README.md (5 claims)

1. README.md:5 — "license-MIT": confirmed by `LICENSE` and `## X-License: MIT` in `WhatGroup.toc:10`. **OK.**
2. README.md ~`/wg` table: 9 verbs listed. Source (`WhatGroup.lua:654-674`) has the same 9 verbs in same order. **OK.**
3. README.md "lightweight, single-folder" — accurate; flat layout (`WhatGroup.lua/_Settings/_Frame`). **OK.**
4. README.md "every panel control has a CLI peer via /wg get / /wg set" — confirmed: schema-driven CLI at `WhatGroup.lua:711-798` iterates same `Schema` the panel renders. **OK.**
5. README.md badge "WoW-Midnight_12.0.5" — TOC interface line `120000,120001,120005` (`WhatGroup.toc:1`) covers 12.0.0/12.0.1/12.0.5. **OK.**

### CLAUDE.md (5 claims)

1. "Both hooks are direct hooksecurefunc calls (one on C_LFGList.ApplyToGroup, one on SetItemRef)" — confirmed `WhatGroup.lua:39`, `:45`. **OK.**
2. "AceHook-3.0 has been removed from libs/ and from the NewAddon mixin list" — confirmed: `libs/` listing has no `AceHook-3.0`; `WhatGroup.lua:25` mixin list = AceConsole + AceEvent only. **OK.**
3. "Schema-first... `Settings.Schema` (`WhatGroup_Settings.lua`)" — confirmed at `WhatGroup_Settings.lua:32`. **OK.**
4. "Single AceDB profile. AceDB:New('WhatGroupDB', defaults, true)" — confirmed `WhatGroup.lua:234`. **OK.**
5. "Cyan [WG] chat prefix on all addon output ... CHAT_PREFIX = '|cff00FFFF[WG]|r'" — confirmed `WhatGroup.lua:53`. **OK.**

CLAUDE.md is **clean** — no drift detected.

### ARCHITECTURE.md (5 claims)

1. "Two hooks: ApplyToGroup capture + SetItemRef link" — confirmed `WhatGroup.lua:39`, `:45`. **OK.**
2. "C_Timer.After(notify.delay)" — confirmed `WhatGroup.lua:522`. **OK.**
3. "ROSTER transition + inviteaccepted both call _TryFireJoinNotify, notifiedFor flag prevents double-fire" — confirmed `WhatGroup.lua:501-530`, `:555`, `:617`. **OK.**
4. "COMMANDS table → /wg help + /wg <verb> dispatch" — confirmed `WhatGroup.lua:654-705`. **OK.**
5. "Settings.Schema → panel widget + /wg list/get/set + AceDB defaults + /wg reset" — confirmed `WhatGroup_Settings.lua:817-862`, `:711-798` (CLI), `:306-323` (BuildDefaults), `:330-339` (RestoreDefaults). **OK.**

ARCHITECTURE.md is **clean** — no drift detected.

(reviews/2026-05-02 was run yesterday; the addon's docs are fresh.)

## 16. Tests / lint

- `.luacheckrc` — **absent**.
- No automated tests; CLAUDE.md confirms "No automated tests. Validation is manual, in-game."
- Manual smoke tests live in `docs/smoke-tests.md` (referenced from CLAUDE.md and README via `docs/` index).
- `/wg test` (`WhatGroup.lua:832-861`) injects synthetic data and exercises the full notify+popup pipeline — the closest thing to a built-in test harness.
- Schema validation at panel-register time (`WhatGroup_Settings.lua:265-298`) catches a class of authoring bugs.

## 17. Notable strengths

1. **Taint discipline is exemplary.** Every taint hazard is documented at the callsite (`WhatGroup.lua:29-38`, `:245-255`, `:865-879`; `WhatGroup_Frame.lua:11-19`, `:144-149`; `WhatGroup_Settings.lua:362-371`, `:946-998`). Hooks at file-load (not OnEnable), Settings registration deferred to first `/wg config`, StaticPopup deferred to first reset, popup creation deferred to first show, UISpecialFrames insert deferred to first show, panel body builds wrapped in `C_Timer.After(0, ...)` — all motivated by reproduced ADDON_ACTION_FORBIDDEN bugs on Logout.
2. **Schema-first design pays off.** One schema row in `WhatGroup_Settings.lua:77-184` produces five surfaces: panel widget, AceDB default, `/wg list/get/set`, and `/wg reset`. The orchestrated `Helpers.Set` (`:231-245`) means user-facing CLI, panel callbacks, and reset never drift on side-effects. Schema validator (`:265-298`) catches authoring bugs at register time.
3. **Combat-safety is plumbed end-to-end.** `runConfig` blocks during combat (`WhatGroup.lua:868-870`), `Settings.Register` re-checks (`WhatGroup_Settings.lua:975-980`), `ShowFrame` defers first-build (`WhatGroup_Frame.lua:282-303`), `ConfigureTeleportButton` defers attribute writes (`:173-187`). Three independent guards at three layers.
4. **Capture state machine is robust.** Dual-trigger fire (`_TryFireJoinNotify` from both ROSTER and inviteaccepted, `WhatGroup.lua:501-530`) handles retail's variable event ordering; `notifiedFor` and `notifyGen` guards prevent double-fire and stale-fire after wipe (`:514-526`); `WipeCapture` (`:535-541`) cleanly resets everything on group-leave or master-switch off.
5. **Smart locale fallback without AceLocale.** Pulls Blizzard's `GROUP_FINDER_GENERAL_PLAYSTYLE1..4` globals (`WhatGroup.lua:364-369`) and prefers server-rendered `playstyleString` (`:284`, `:392-395`). Free localization for the playstyle column without dragging in AceLocale.
6. **Three flat files is right-sized for this addon.** Two of the three are 1,000+ LOC; splitting `WhatGroup.lua` further would scatter the capture state machine across files for no clear win. Splitting `WhatGroup_Settings.lua` (1,056 LOC) is the only candidate (e.g. peel the always-visible-scrollbar patch into a helper file), but the schema/helpers/panel coupling is tight enough that flat-here is justified.

## 18. Notable weaknesses

1. **`WhatGroup_Settings.lua` at 1,056 lines is the largest file** and mixes five concerns: schema rows, AceDB-path helpers, schema validation, AceGUI panel/scrollbar/widget plumbing, and Blizzard Settings registration. A modest split (`Settings_Schema.lua` + `Settings_Panel.lua` keeping helpers in either) would reduce the cognitive load. This is the only place where flat-vs-modular is genuinely a question.
2. **No `.pkgmeta`.** README badges suggest an existing CurseForge listing (`README.md:4` — `curseforge/v/1489907`), but packaging/publication is presumably manual. A 20-line `.pkgmeta` would automate releases and dedupe vendored libs against a `Curse:` source.
3. **`appID` reused as `searchResultID` in the inviteaccepted handler** (`WhatGroup.lua:588`). The TODO at `:581-587` flags this; works today by undocumented Blizzard parity. If Blizzard ever decouples them, mapID-driven teleport and fresh-vs-queued capture choice both break silently.
4. **No `.luacheckrc`.** No static analysis runs against the addon. The codebase is clean enough that this hasn't bitten, but a basic luacheck config (defining WoW globals, ignoring `_G` reads) is ~20 lines of investment.
5. **Public API on `WhatGroup` global is fuzzy.** `_print`, `_dbg`, `_parentSettingsCategory`, `_settingsCategory`, `_settingsRegistered`, `_frameBuildQueued`, `RunTest`, `WipeCapture`, `ShowFrame`, `Labels`, `COMMANDS`, `pendingInfo`, `Settings.*` — mix of intentional cross-file plumbing and "leaked because it had to be." A short comment in `WhatGroup.lua` declaring the cross-file contract would help.
6. **TOC `## DefaultState: enabled`** is unusual on a regular addon — generally only meaningful for LoadOnDemand. Harmless but cargo-culted.

---

## Summary verdict on flat-vs-modular

WhatGroup is **right-sized at three flat lua files**. Two of the three are dense (>900 LOC) but each has a coherent single responsibility:

- `WhatGroup.lua` — bootstrap + state machine + slash + chat + teleport-spell table.
- `WhatGroup_Settings.lua` — schema + helpers + canvas panel.
- `WhatGroup_Frame.lua` — popup dialog.

The only file where modularization would help is `WhatGroup_Settings.lua` — and that's a within-folder peel (e.g. `Settings/Schema.lua` + `Settings/Panel.lua` + `Settings/Scrollbar.lua`), not a wholesale modular reshape. The capture pipeline + slash dispatch + teleport-spell table belong together in `WhatGroup.lua` because they share the `pendingInfo` lifecycle. Forcing the standard "AceAddon collection of modular .lua files" pattern here would scatter coherent logic for no win. **Stay flat.**
