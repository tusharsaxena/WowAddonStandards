# ElvUI — Industry Reference (read-only research)

Researched: 2026-05-03
Repo: https://github.com/tukui-org/ElvUI

ElvUI is the largest Ace3-based addon in the WoW ecosystem — a full UI replacement (not an overlay), shipping as three sibling addons (`ElvUI`, `ElvUI_Libraries`, `ElvUI_Options`) packaged from a single repo.

---

## 1. TOC

- Five flavor-specific TOCs in `ElvUI/`: `ElvUI_Mainline.toc`, `_Mists.toc`, `_TBC.toc`, `_Vanilla.toc`, `_Wrath.toc`. Each TOC loads a *single* file: `Game\load_mainline.xml` (or the corresponding flavor XML).
- Headers seen in `ElvUI_Mainline.toc`:
  - `## Interface: 120005`
  - `## Title: ElvUI`
  - `## Author: Elv, Simpy`
  - `## Version: @project-version@` (substituted at packaging by BigWigs/CurseForge packager)
  - `## SavedVariables: ElvDB, ElvPrivateDB`
  - `## SavedVariablesPerCharacter: ElvCharacterDB`
  - `## OptionalDeps: SharedMedia, Tukui, Masque, BigWigs`
  - `## X-Tukui-ProjectID: -2`
  - `## X-Tukui-ProjectFolders: ElvUI, ElvUI_Libraries, ElvUI_Options`
- Source: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/ElvUI_Mainline.toc

## 2. Layout

Top-level repo (https://github.com/tukui-org/ElvUI):

- `ElvUI/` — addon code
- `ElvUI_Libraries/` — vendored Ace3 + supporting libs (kept as a sibling addon, *not* embedded)
- `ElvUI_Options/` — separate addon for the AceConfig options tree
- `.pkgmeta`, `Makefile`, `CHANGELOG.md`, `LICENSE.md`, `README.md`, `ThirdPartyNotices.md`

Inside `ElvUI/`:

- `Game/` with one folder per flavor — `Mainline/`, `Classic/`, `Mists/`, `TBC/`, `Wrath/`, plus `Shared/`. Each has its own `load_<flavor>.xml`.
- `Locales/`
- `Bindings.xml`, `Bindings_Mainline.xml`

Inside `ElvUI/Game/Shared/`:

- `Defaults/`, `Developer/`, `Filters/`, `General/`, `Layout/`, `Media/`, `Modules/`, `Tags/`

Inside `ElvUI/Game/Shared/Modules/` (13 modules):

- `ActionBars/`, `Auras/`, `Bags/`, `Blizzard/`, `Chat/`, `DataBars/`, `DataTexts/`, `Maps/`, `Misc/`, `Nameplates/`, `Skins/`, `Tooltip/`, `UnitFrames/`

## 3. Module loading

The pattern (from `ElvUI/Game/Shared/General/Initialize.lua` — https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/General/Initialize.lua):

```lua
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0',
  'AceTimer-3.0', 'AceHook-3.0')
-- exposed as: ElvUI = { E, L, V, P, G }
-- consumers: local E, L, V, P, G = unpack(ElvUI)
```

Each module is its own AceAddon submodule, with its own embeds:

```lua
E.ActionBars = E:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0')
```

Two registration queues exist on E (from `Game/Shared/General/Core.lua`):

- `E:RegisterInitialModule(name)` — runs in `OnInitialize` phase
- `E:RegisterModule(name)` — runs in `OnEnable`/`PLAYER_LOGIN` phase

This split lets ElvUI guarantee dependency order (e.g. Skins core must initialize before any module that registers a skin callback).

Load order is centralized in `Game/Shared/Modules/load_modules.xml` and friends; the TOC delegates everything to XML so flavor-conditional includes stay declarative.

## 4. Libraries

`ElvUI_Libraries/` is its own addon, vendored via `.pkgmeta` externals (https://raw.githubusercontent.com/tukui-org/ElvUI/main/.pkgmeta):

- Ace3 set: AceAddon, AceGUI, AceComm, AceConsole, AceDB, AceDBOptions, AceEvent, AceHook, AceSerializer, AceTimer
- AceGUI-3.0-SharedMediaWidgets, CallbackHandler-1.0, LibStub
- LibSharedMedia-3.0, LibCustomGlow-1.0, LibDataBroker, LibTranslit-1.0, LibDualSpec-1.0, UTF8
- LibDispel (org-owned, GitHub external)
- TaintLess (Townlong-Yak external)
- Plain-copied (not external — bundled in-repo): Ace3-ElvUI fork, LibAceConfigHelper, LibActionButton-1.0, LibAnim, LibDeflate, LibElvUIPlugin-1.0, LibSimpleSticky, oUF, oUF_Plugins

Pattern: ElvUI maintains a private Ace3 fork (`Ace3-ElvUI`) alongside upstream Ace3 — they pin upstream by external but layer their own patches.

## 5. Architecture

- Single global handoff: `ElvUI = { E, L, V, P, G }`. Every module starts with `local E, L, V, P, G = unpack(ElvUI)`.
- AceDB layered: `E.data = AceDB:New('ElvDB', E.DF, true)` (profile/global), `E.charSettings = AceDB:New('ElvPrivateDB', E.privateVars)` (per-character). Three saved-variable namespaces total.
- Library access centralized via `E.Libs.<Name>` populated by `E:AddLib()` — no scattered `LibStub()` calls.
- Cross-cutting helpers live in `General/`: `API.lua` (~1200 LOC of utilities), `Math.lua`, `Fonts.lua`, `PixelPerfect.lua`, `Toolkit.lua`, `Movers.lua`, `Cooldowns.lua`, `Dropdown.lua`, `Config.lua`.
- Version parsed at runtime: `E.version, E.versionString, E.versionDev, E.versionGit = E:ParseVersionString('ElvUI')`.

## 6. Settings (DB)

- `ElvDB` (profile + global), `ElvPrivateDB` (account), `ElvCharacterDB` (per-char). Defaults split into `E.DF` (full default tree) and three default profile files in `Defaults/`.
- `RefreshGUI()` calls `AceConfigRegistry:NotifyChange('ElvUI')` to re-render without rebuilding the tree.

## 7. Options UI

Lives in a *separate addon* `ElvUI_Options` (loaded as OptionalDeps would, but always packaged together). Strictly one file per module under `ElvUI_Options/Game/Shared/`:

`ActionBars.lua, Auras.lua, Bags.lua, Chat.lua, Cooldown.lua, Core.lua, DataBars.lua, DataTexts.lua, Filters.lua, General.lua, Maps.lua, Nameplates.lua, Search.lua, Skins.lua, Tags.lua, Tooltip.lua, UnitFrames.lua`

Each file exports a `Create<Module>Config()` factory; `Core.lua` assembles them under `E.Options.args.<module>` and registers once:

```lua
E.Libs.AceConfig:RegisterOptionsTable('ElvUI', E.Options)
E.Libs.AceConfigDialog:SetDefaultSize('ElvUI', E:Config_GetDefaultSize())
```

ElvUI ships its own helper lib `LibAceConfigHelper` (used as `ACH` — `ACH:Group(...)`) to compress AceConfig boilerplate; this is how a 50k+ LOC option tree stays editable.

## 8. Slash commands

Registered via `E:LoadCommands()` in `Game/Shared/General/Commands.lua` using `E:RegisterChatCommand` (AceConsole-3.0):

`/kb`, `/ec` + `/elvui`, `/bgstats`, `/moveui` + `/emove`, `/resetui` + `/ereset`, `/edebug`, `/ehelp` + `/ecommands`, `/estatus`, `/efixdb`, `/egrid`, `/guildlist`, `/guildapply`.

Pattern: every command has a short alias and a long alias.

## 9. Locale

12 locale files under `ElvUI/Locales/` (enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW). All loaded before anything else (right after `Initialize.lua`). `L` is exposed via `unpack(ElvUI)`.

## 10. Events

AceEvent-3.0 embedded on E and on each module; `S:ADDON_LOADED` is the canonical example — the Skins module dispatches deferred work via this single event handler.

## 11. Frames

`PixelPerfect.lua` and `Toolkit.lua` provide the styling primitives. ElvUI uses `oUF` (vendored under `ElvUI_Libraries`) for unit frames, plus `LibActionButton-1.0` for action bars.

## 12. Debug

Dedicated `Game/Shared/Developer/` folder — Frame.lua exposes `/devcon`, `/getpoint`, `/frame` (sets global `FRAME`), `/texlist`, `/framelist` (frame stack with hidden/region filters). Plus `/edebug` toggles Lua error reporting. `TInspect.lua` and `Test.lua` are the other two devtools.

## 13. Packaging

`.pkgmeta` (https://raw.githubusercontent.com/tukui-org/ElvUI/main/.pkgmeta):

- `package-as: ElvUI`
- 19 `externals:` entries (libs pinned to CurseForge SVN/git)
- `manual-changelog: CHANGELOG.md` (markdown)
- `ignore:` `*.md`, `*.textile`, `LibStub/tests`, `Makefile`
- `plain-copy:` lists every game-flavor folder explicitly so the packager doesn't substitute keywords inside them
- `move-folders:` reorganizes `ElvUI/ElvUI`, `ElvUI/ElvUI_Libraries`, `ElvUI/ElvUI_Options` into top-level distribution folders
- `Makefile` at repo root for local builds

---

## How ElvUI scales the Ace3 module pattern

1. **Two-phase registration.** `RegisterInitialModule` vs `RegisterModule` lets ElvUI separate "I must exist before anyone touches me" (Skins, Tags) from "I'm a normal module that runs at PLAYER_LOGIN."
2. **Module-local embeds.** Every `E:NewModule(name, 'AceHook-3.0', 'AceEvent-3.0')` declares its own dependencies — no global "everything embeds everything."
3. **Single tuple export.** `ElvUI = { E, L, V, P, G }` + `unpack(ElvUI)` removes the per-file `local addonName, addonTable = ...` ceremony that hurts at hundreds of files.
4. **Centralized lib registry.** `E.Libs.AceDB`, `E.Libs.AceConfig` etc. — one `E:AddLib()` call site, zero scattered `LibStub()`.
5. **Flavor-routed XML manifests.** TOC -> `load_<flavor>.xml` -> `load_modules.xml` keeps Lua free of `if WOW_PROJECT_ID == ...` includes.

## Skinning system — third-party registration

(`Game/Shared/Modules/Skins/Skins.lua`)

Two public APIs that both delegate to `S:RegisterSkin`:

- `S:AddCallback(name, func, position)` — for Blizzard / non-addon-bound skins; queued in `S.nonAddonsToLoad`, drained at ElvUI init.
- `S:AddCallbackForAddon(addonName, name, func, forceLoad, bypass, position)` — third-party skins; stored in `S.addonsToLoad[addonName]` keyed by addon, executed from `S:ADDON_LOADED(_, addonName)`.

`S.allowBypass[addonName]` lets a skin run even before ElvUI itself finishes initializing (used for framework-style addons that load very early). `forceLoad` runs immediately if the target addon is already loaded at registration time.

The whole design is one event listener + three tables — surprisingly small for the surface it covers (150+ Blizzard skin files).

## Massive AceConfig tree — maintainability

- **Separate addon.** `ElvUI_Options` is its own TOC, loaded by `OptionalDeps`. Disabling it strips ~all option code from memory at runtime.
- **One file per module, factory-per-file.** `Create<Module>Config()` returns a sub-tree; `Core.lua` does the wiring.
- **`LibAceConfigHelper` (ACH).** Custom DSL: `ACH:Group(...)`, `ACH:Toggle(...)`, etc. — collapses 8-line AceConfig stanzas to 1-line calls. ElvUI ships this lib in `ElvUI_Libraries`.
- **`E:RefreshGUI()` -> `NotifyChange`.** Re-render in place; tree is built once.
- **Profile-copy is its own subtree.** `E.Options.args.profiles.args.modulecopy.args.elvui.args.<module>` mirrors module structure exactly — copy semantics fall out of the tree shape.

---

## Patterns to steal (small/medium scale)

1. **Tuple-export trick.** `MyAddon = { core, L, defaults }` + `local C, L, D = unpack(MyAddon)`. Cuts boilerplate and gives you a single, greppable handoff. Works at any size.
2. **`addon.Libs.X` registry.** One `addon:AddLib()` site, never call `LibStub` at use sites. Trivial to mock for tests, trivial to swap libs.
3. **Two-phase module init.** `RegisterInitialModule` vs `RegisterModule`. Even at 5 modules this prevents OnInitialize ordering bugs without hand-rolling deps.
4. **Skin-style deferred callbacks.** `mod:AddCallbackForAddon(name, fn)` + one `ADDON_LOADED` handler is a *much* better pattern than every module registering its own ADDON_LOADED.
5. **Options as a sibling addon.** Even at small scale, putting AceConfig tables in `MyAddon_Options/` (loaded via OptionalDeps) means options code is inert until the user opens the panel — measurable memory win.

## Anti-patterns (and why they only work for ElvUI)

1. **Global-by-design (`ElvUI = {...}`, global `E`).** ElvUI owns the whole UI; no other addon needs to coexist with it cleanly. Don't do this in a normal addon — you'll collide with someone.
2. **Vendoring a private Ace3 fork (`Ace3-ElvUI`).** Acceptable because Tukui-org is a huge org with QA bandwidth. For a normal addon this guarantees you'll diverge from upstream and never get fixes.
3. **One-XML-file TOC delegating everything.** Fine because ElvUI has 5 TOCs feeding 5 XML manifests. For a 20-file addon this is pure ceremony — list the .lua files in the TOC.
4. (bonus) **150+ Blizzard skin files always in memory.** Only justified when you *are* the UI. A normal addon should lazy-load by ADDON_LOADED.

---

## Citations

- Repo root: https://github.com/tukui-org/ElvUI
- TOC: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/ElvUI_Mainline.toc
- Game folder: https://github.com/tukui-org/ElvUI/tree/main/ElvUI/Game
- Shared folder: https://github.com/tukui-org/ElvUI/tree/main/ElvUI/Game/Shared
- Modules folder: https://github.com/tukui-org/ElvUI/tree/main/ElvUI/Game/Shared/Modules
- Initialize.lua: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/General/Initialize.lua
- Core.lua: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/General/Core.lua
- Skins.lua: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/Modules/Skins/Skins.lua
- Commands.lua: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/General/Commands.lua
- Developer/Frame.lua: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/Shared/Developer/Frame.lua
- load_mainline.xml: https://raw.githubusercontent.com/tukui-org/ElvUI/main/ElvUI/Game/load_mainline.xml
- .pkgmeta: https://raw.githubusercontent.com/tukui-org/ElvUI/main/.pkgmeta
- ElvUI_Options/Game/Shared: https://github.com/tukui-org/ElvUI/tree/main/ElvUI_Options/Game/Shared
