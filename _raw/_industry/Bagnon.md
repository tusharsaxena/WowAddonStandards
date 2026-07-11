# Bagnon — Principal-Engineer Research Notes

**Target:** Bagnon by Jaliborc (João Cardoso) & Tuller (Jason Greer)
**Repo:** https://github.com/Jaliborc/Bagnon
**Sibling/core:** https://github.com/Jaliborc/BagBrother
**Date of research:** 2026-05-03

Research is read-only and based on the master branch of each repo as of the fetch date.

---

## 1. Repository topology

Bagnon is intentionally **thin**. The actual engine — the frame primitives, item/bag classes, event bus, settings, sorting, skinning, slash commands, Blizzard UI override hooks, anti-taint shims, locale tables, even the options panels — all live in the **BagBrother** companion addon. Bagnon's repo only carries a handful of "presentation" files that compose those primitives into a specific bag layout.

Bagnon top-level (https://github.com/Jaliborc/Bagnon):

- `Bagnon.toc`, `Bagnon-Mainline.toc`, `Bagnon-TBC.toc` — three TOCs (see §2)
- `Bindings.xml` — keybindings (`BAGNON_TOGGLE`, `BAGNON_BANK_TOGGLE`, `BAGNON_VAULT_TOGGLE`, `BAGNON_GUILD_TOGGLE`)
- `Changelog.md`, `Description.html`, `README.md`
- `art/broom.tga` (single asset)
- `src/` — only 9 Lua files + 2 XML (`main.xml`, `templates.xml`): `frame.lua`, `title.lua`, `optionsButton.lua`, `searchBar.lua`, `searchToggle.lua`, `others.lua`, `skins.lua`, `defaults.lua`, `config.lua`. `test.lua` is commented out in `main.xml`.
- `.upconfig` — packager config (CurseForge project ID 1592). Bundles sibling addons `BagBrother`, `Bagnon_Bank`, `Bagnon_Config`, `Bagnon_GuildBank` and ignores test suites of embedded libs.
- `.gitmodules` — declares one legacy submodule (`legacy/LibItemCache-2.0`).

`src/main.xml` (https://raw.githubusercontent.com/Jaliborc/Bagnon/master/src/main.xml):

```xml
<Include file="templates.xml"/>
<Include file="..\..\BagBrother\core\core.xml"/>
<Include file="..\..\BagBrother\frames\inventory\inventory.xml"/>
<Script file="title.lua"/>
... etc
```

The cross-addon `..\..\BagBrother\core\core.xml` include is the load-time bridge — Bagnon and BagBrother are loaded as siblings, and Bagnon literally pulls BagBrother's XML graph into its own load order. This only works because both ship in the same packaged zip (driven by `.upconfig`).

BagBrother top-level (https://github.com/Jaliborc/BagBrother):

- `BagBrother.toc`, `BagBrother-Mainline.toc`, `BagBrother-TBC.toc`
- `core/` — `core.lua`, `core.xml`, plus subfolders `api/`, `classes/`, `features/`, `localization/`
- `frames/` — `bank/`, `guild/`, `inventory/`, `vault/`
- `config/` — `config.lua`, `config.xml`, `classes/`, `localization/`, `panels/`
- `libs/` — embedded libraries (see §4)
- `art/`

---

## 2. TOC strategy & multi-version support

Three TOCs sit at the project root. Both Bagnon and BagBrother use the same trick:

- `Bagnon.toc` — multi-interface line `## Interface: 120005, 50503, 40402, 30404, 20505, 11508` covering Mainline, MoP Classic, Cata Classic, Wrath, TBC, Vanilla in a single file.
- `Bagnon-Mainline.toc` — modern WoW only (`Interface: 120005`).
- `Bagnon-TBC.toc` — single classic flavor (`Interface: 20505`).

Sources:
- https://raw.githubusercontent.com/Jaliborc/Bagnon/master/Bagnon.toc
- https://raw.githubusercontent.com/Jaliborc/Bagnon/master/Bagnon-Mainline.toc
- https://raw.githubusercontent.com/Jaliborc/BagBrother/master/BagBrother.toc

Why three? Modern Blizzard clients prefer **flavor-specific** TOC files (`-Mainline`, `-Classic`, `-Wrath`, etc.) and will load whichever one matches the running client; the fallback `Bagnon.toc` provides legacy/CurseForge auto-packager compatibility for clients that look for a default-named TOC. The multi-interface line in the default TOC is belt-and-braces.

**Important:** all three TOCs reference the **same** `src/main.xml` (and BagBrother's all reference the same `core.xml`). There is no per-flavor source tree. Branching is done **at runtime** with three flags set in `core/core.lua`:

```lua
Addon.IsRetail  = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Addon.IsClassic = LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CLASSIC
Addon.IsModern  = LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_CATACLYSM
```

`C_Everywhere` (a Jaliborc shim, https://github.com/Jaliborc/C_Everywhere) is the second pillar of cross-version code: it polyfills the `C_*` namespace APIs on Classic clients so the rest of the code can call modern APIs unconditionally. It is included via `libs/libs.xml`.

Other metadata: `## SavedVariables: Bagnon_Sets` (Bagnon) and `## SavedVariables: BrotherBags` (BagBrother). Bagnon declares `## RequiredDeps: BagBrother`. License: "All Rights Reserved" (despite open-source repo). Marked `## Dev: True`.

---

## 3. Module loading

Pure XML chain — no Ace3 module system, no `LibStub` for module wiring.

- TOC loads only `src/main.xml`.
- `main.xml` Includes `templates.xml`, BagBrother's `core/core.xml`, and BagBrother's `frames/inventory/inventory.xml`, then `Script`s the Bagnon-specific Lua files in dependency order.
- `core.xml` Includes `..\libs\libs.xml`, `localization/localization.xml`, `api/api.xml`, `classes/classes.xml`, `features/features.xml`, then runs `core.lua`.
- `libs.xml` Includes `TaintLess`, `C_Everywhere`, `Poncho-2.0`, `Sushi-3.2`, `Unfit-1.0`, `ItemSearch-1.3` (https://raw.githubusercontent.com/Jaliborc/BagBrother/master/libs/libs.xml).

Bank/GuildBank/Config addons are **separate addons** that get **load-on-demand** when needed — `core/api/frames.lua` calls `AddOnUtil.LoadAddOn(ADDON..'_Bank')` the first time a frame of that kind is requested. Bagnon's `.upconfig` bundles them all into one packaged release so users only install one thing.

---

## 4. Embedded libraries

From `libs/libs.xml` and `.gitmodules` (https://raw.githubusercontent.com/Jaliborc/BagBrother/master/.gitmodules):

| Lib | Purpose | Owner |
|---|---|---|
| **LibStub** | Library version registry | Ace3 ecosystem |
| **CallbackHandler-1.0** | Event/callback dispatch | Ace3 ecosystem |
| **AceLocale-3.0** | Localization tables | Ace3 ecosystem |
| **LibDataBroker-1.1** | Broker plugin protocol | Ace3 ecosystem |
| **TaintLess** | Drops `TaintLess.xml` shim that strips known Blizzard UI taint | community |
| **C_Everywhere** | Polyfills `C_*` API on Classic | Jaliborc |
| **Poncho-2.0** | OOP base — class+inheritance, Super(), frame pooling, metatable wiring | Jaliborc |
| **Sushi-3.2** | GUI widget framework on top of Poncho — `:SetCall()` (multi-script), Choice/Group/Tab/Tooltip widgets, "release frees attributes" pool semantics | Jaliborc |
| **Unfit-1.0** | "Item not usable by class" detection | Jaliborc |
| **ItemSearch-1.3** | Item search query parser | Jaliborc |
| **CustomSearch-1.0** | Generic search-DSL engine ItemSearch builds on | Jaliborc |
| **MutexDelay-1.0** | Mutex+coalesced-delay primitive (used by event batcher) | Jaliborc |
| **StaleCheck-1.0** | Detects stale game cache state | Jaliborc |
| **WildAddon-1.1** | Lightweight addon-skeleton library — `:NewAddon()`, mixin support, signal bus | Jaliborc |
| **Poncho-2.0 / Sushi-3.2 tests** | WoWUnit suites (excluded from packaging) | Jaliborc |

`legacy/LibItemCache-2.0` is a deprecated submodule kept for backwards-compatibility consumers of the old API.

### Sushi as a sibling

Sushi is **not** copy-pasted into the addon. It is a git submodule under `BagBrother/libs/Sushi-3.2`. Its own `.toc` (https://raw.githubusercontent.com/Jaliborc/Sushi-3.2/master/Sushi-3.2.toc) is **never loaded** as a standalone addon — the include chain pulls in `Sushi-3.2.xml` directly, which `Script`s `Sushi-3.2.lua` and the per-class files. LibStub then mediates version conflicts if multiple addons embed it. Sushi requires Poncho (so `libs.xml` orders Poncho before Sushi). The pattern: keep the library a **first-class repo** with its own TOC and tests, embed via submodule, load via XML — never via `## OptionalDeps`.

---

## 5. Architecture

### Object model
Three layers, bottom-up:

1. **Poncho-2.0** — `Class:NewClass()`, instance pooling, `self:Super(Class):method(...)`.
2. **Sushi-3.2** — widget components on Poncho; `SetCall(event, fn)` for multi-binding; auto-cleanup on release.
3. **BagBrother classes** in `core/classes/` — `base.lua`, `frameBase.lua`, `bag.lua`, `bagGroup.lua`, `item.lua`, `itemGroup.lua`, `tab.lua`, `tabGroup.lua`, `currency.lua`, `currencyTracker.lua`, `playerMoney.lua`, `sortButton.lua`, `tipped.lua`, `parented.lua`, `brokerCarrousel.lua`, `offlineSelector.lua`. Bagnon's `src/frame.lua` then **subclasses** these:

```lua
-- Bagnon/src/frame.lua
local Frame = Addon.Frame  -- BagBrother class
function Frame:New(params)
    local f = self:Super(Frame):New(UIParent)
    ...
end
```
(https://raw.githubusercontent.com/Jaliborc/Bagnon/master/src/frame.lua)

### Addon kernel — WildAddon-1.1
`core/core.lua` does:

```lua
local Addon = LibStub('WildAddon-1.1'):NewAddon(ADDON, 'Addon', 'StaleCheck-1.0')
Addon:ContinueOn('PLAYER_ENTERING_WORLD', function() ... end)
AddonCompartmentFrame:RegisterAddon{ ... }
```
(summarised from https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/core.lua)

WildAddon provides `:NewAddon()`, mixin composition, signal bus (`:SendSignal`), and event registration. `:ContinueOn(event, fn)` is the deferred-init idiom used everywhere — works whether the event has fired already or not.

### API layer (`core/api/`)
- `events.lua` — bag-update event coalescing. Inherits `MutexDelay-1.0`. `QueueBag()` marks dirty bags, then `self:Delay(0.08, 'UpdateBags')` debounces. Emits `BAGS_UPDATED`, `BANK_OPEN/CLOSE`, `VAULT_OPEN/CLOSE` via `self:SendSignal(...)`.
- `frames.lua` — frame factory + registry (`{id='inventory', name=INVENTORY_TOOLTIP, icon=130716, addon=ADDON..'_Bank' for bank}`); lazy `LoadAddOn` on first `New(id)`; cached afterwards. `Toggle/Show/Hide`.
- `settings.lua` — saved-variable schema. `BrotherBags[realm][characterID]` for per-toon, `Addon.sets.global` for account-wide, plus `Addon.sets.profiles[realm][id]`. `OnLoad()` merges defaults; `Upgrade()` migrates legacy schemas.
- `owners.lua` — multi-character "owner" abstraction (the headline feature: see other characters' bags).
- `rules.lua` — filtering/category rule engine.
- `sorting.lua` — bag sort.
- `skinning.lua` — pluggable skin protocol for ElvUI/Masque/etc.

### Features (`core/features/`)
Each is a self-contained module: `caching.lua`, `displayEvents.lua`, `slashCommands.lua`, `uiOverrides.lua`, `antiMoneyTaint.lua`, `currencyTooltips.lua`, `itemTooltips.lua`, `basicRules.lua`, `brokerPlugin.lua`. Wired in via `features.xml`.

---

## 6. Settings

- Single SavedVariable `BrotherBags` for the engine, plus `Bagnon_Sets` for Bagnon-flavor presentation prefs.
- Three-tier resolution: per-character profile → per-realm → `global` fallback.
- Defaults supplied via a mixin into the SavedVariable on load (`SetDefaults(_G[VAR] or {}, Mixin({...}))`).
- `Upgrade()` on load migrates old key shapes; lets the project iterate the schema without breaking installs.
- Bagnon's own `src/defaults.lua` and `src/config.lua` set the Bagnon-specific defaults (`Config.components = true`, `Config.componentMenuHeight = 105`, `Config.columns = true`).

---

## 7. Options UI

Lives in **a separate addon** `Bagnon_Config`, which is load-on-demand. Triggered by `Settings`-panel hook in `core.lua` (lazy-loads only when player opens the settings panel) — startup stays cheap. Panels are vanilla Lua + Sushi widgets, organized as `displayOptions.lua`, `frameOptions.lua`, `generalOptions.lua`, `infoPanels.lua`, `slotOptions.lua`, `ruleEdit.lua` under `BagBrother/config/panels/`.

---

## 8. Slash commands

Single registration in `core/features/slashCommands.lua` (https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/features/slashCommands.lua). Two aliases per addon — full name and short (`/bgn` for Bagnon). Dispatch is a flat lowercase string match: `bags`/`inventory`, `bank`, `guild`, `vault`, `version`, `config`/`options`, `reset` (with confirm), default → help text. No Ace3 dependency; no command builder.

---

## 9. Locales

`AceLocale-3.0` via LibStub. `core/localization/localization.xml` `Script`-loads 11 locale files (`en, pt, cn, de, es, fr, it, ko, nl, ru, tw`); `en.lua` is `:NewLocale(ADDON, 'enUS', true)` (default-locale flag). All strings referenced as `L.Foo` via `LibStub('AceLocale-3.0'):GetLocale(ADDON)`.

---

## 10. Events

Two-tier model:

- **Blizzard events** — registered by WildAddon's `:RegisterEvent` / `:ContinueOn`.
- **Internal "signals"** — WildAddon's `:SendSignal('BAGS_UPDATED', queue)` / `:RegisterSignal`. Coalesced through MutexDelay so a torrent of `BAG_UPDATE` events results in one redraw.

Pattern is **debounce + coalesce + own bus**, never re-broadcast Blizzard events.

---

## 11. Frames

Frame factory in `core/api/frames.lua`. Frames are categorized by `id` (`inventory`/`bank`/`guild`/`vault`); each can live in its own optional addon. `Toggle(id, owner)` is the universal entry point; the `owner` parameter passes the character whose bags to render (the multi-character feature). On creation, frames are pushed to `UISpecialFrames` so ESC closes them. `frames/inventory/inventory.xml` etc. are loaded by Bagnon directly through the cross-addon include in `main.xml`.

---

## 12. Debug

No formal debug system. `test.lua` exists but is commented out in `main.xml`. Sushi and Poncho ship WoWUnit test suites in their submodules — `.upconfig` ignores them at packaging time but they live in the repo. `## OptionalDeps: WoWUnit` enables the test scaffolding when the developer has WoWUnit installed locally.

---

## 13. Packaging (`.upconfig`)

CurseForge / WowUp packager config. Project ID `1592`. Bundles `BagBrother`, `Bagnon_Bank`, `Bagnon_Config`, `Bagnon_GuildBank` so end users get one zip with multiple sibling AddOns folders. `ignore` list strips test code from embedded libs (`Sushi-3.2/tests`, `Poncho-2.0/tests`, `Unfit-1.0/tests`, `ItemSearch-1.3/tests`, `C_Everywhere/tests`, `src/test.lua`). Result: zero test code in shipped builds, full test suites in dev.

---

## 14. Sushi — "library as sibling" pattern (deep dive)

Sushi-3.2 is the flagship example of how Jaliborc treats his own libs as first-class siblings:

1. **Independent repo, independent TOC, independent tests.** `Sushi-3.2.toc` exists and could in principle load Sushi as a standalone addon for development, but in production it is never installed standalone.
2. **Embedded as git submodule** at `BagBrother/libs/Sushi-3.2` pinned to a commit.
3. **Loaded via XML include**, not TOC OptionalDeps. `libs/libs.xml` does `<Include file="Sushi-3.2/Sushi-3.2.xml"/>` and that XML in turn `Script`s the lua files. This means Sushi loads **inside** BagBrother's load context — its globals don't leak unless they explicitly register with LibStub.
4. **LibStub is the version arbiter.** Multiple addons can each embed a Sushi-3.2; whichever loads first wins, others silently no-op. The OOP class registry under Sushi is namespaced by major version (`Sushi-3.2`), so v3.x users are never broken by an addon shipping v4.x.
5. **API:** `LibStub('Sushi-3.2').Choice(parent)` returns a pooled widget; `:SetCall('OnClick', fn)` binds a script (and unlike `SetScript`, multiple binds compose); on release the widget zeros all attributes.
6. **Stack:** Sushi → Poncho-2.0 (OOP+pooling) → bare metatables. Load order in `libs.xml` enforces this.

Verbatim include order from `libs/libs.xml`:
```
TaintLess, C_Everywhere, Poncho-2.0, Sushi-3.2, Unfit-1.0, ItemSearch-1.3
```
(https://raw.githubusercontent.com/Jaliborc/BagBrother/master/libs/libs.xml)

---

## 15. Bag-frame replacement without taint (deep dive)

Source: `core/features/uiOverrides.lua` and `core/features/antiMoneyTaint.lua`.

### Replacing the open/close path
Bagnon does **not** delete or hide Blizzard's bag frames — that path causes taint when the player is in combat. It uses **`hooksecurefunc`** (a non-tainting Blizzard primitive) on `ToggleAllBags`, `ToggleBackpack`, `ToggleBag`:

```lua
hooksecurefunc('ToggleAllBags', function()
    if not debugstack():find('Manager') then
        Addon.Frames:Toggle('inventory')
    end
end)
```

The `debugstack():find('Manager')` guard prevents recursion when Blizzard's own ContainerFrameManager triggers the call (i.e. ignore Blizzard-internal recursion, only react to user input).

### Hiding Blizzard's frames
Blizzard frames are **reparented** to a hidden parent (`self.Disabled`) instead of `:Hide()`-ing or `:UnregisterAllEvents()`-ing them — reparenting is taint-safe whereas `Hide()` of a secure frame mid-combat would be locked-down. Their `OnHide` script handlers are conditionally cleared to avoid Blizzard's reposition logic running against a hidden parent.

### Money frame taint
`antiMoneyTaint.lua` solves the famous "MoneyFrame taints the whole game" bug. Instead of using `MoneyFrame_Update` (which Blizzard uses on tooltips and which leaks taint into spell casting via the Tooltip data flow), Bagnon hooks `TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, ...)` and rebuilds the SellPrice tooltip line manually with `GetMoneyString()` (a string-returning, taint-clean function). Result: tooltip looks identical, no MoneyFrame instantiated, no taint.

### TaintLess.xml
Loaded as the very first include (`libs.xml`). This is the community-maintained shim that suppresses several other classic taint bugs (UIDropDownMenu, OPie etc.) at file load. By having BagBrother load it, every Bagnon user automatically benefits even if they don't have a dedicated taint-fix addon.

**Net pattern:** secure-hook the toggle, reparent (don't hide) Blizzard's UI, never touch MoneyFrame, ship TaintLess.

---

## 16. Notable patterns to steal

1. **Library-as-sibling.** Treat your reusable libs as separate Git repos with their own TOCs and tests; embed via git submodule under `libs/`; load via an XML include from `libs/libs.xml`; let LibStub arbitrate versions. Lets you reuse code across addons without copy-paste, while keeping the lib unit-testable as a standalone addon.
2. **Engine + thin presentation split.** Put the entire engine (frame primitives, classes, settings, slash, locale) into a "core" addon (`BagBrother`); have each "flavor" addon (`Bagnon`, `Bagnonium`) ship maybe a dozen Lua files that subclass and compose. Bagnon proves you can ship a famous, mature addon with literally 9 Lua files in `src/`.
3. **Cross-addon XML include.** `<Include file="..\..\BagBrother\core\core.xml"/>` from a sibling addon's XML loads its load graph deterministically — cleaner than `## Dependencies` because order and granularity are explicit and you can pull just the parts you need.
4. **Three TOCs + runtime flavor flags.** Default multi-interface TOC for legacy clients, plus `-Mainline.toc` and `-TBC.toc` for modern Blizzard's flavor selection. **One source tree**; gate at runtime with `IsRetail`/`IsClassic`/`IsModern` and a `C_Everywhere` polyfill for missing C_ APIs.
5. **Coalesced internal signal bus.** Don't re-emit Blizzard events — debounce them through MutexDelay (`self:Delay(0.08, 'UpdateBags')`), then fire your own typed signals (`BAGS_UPDATED`, `BANK_OPEN`). UI subscribes to the bus, not to Blizzard. Massively reduces redraws on bag-thrash.
6. **Lazy-load options addon.** Options panels are a separate addon, loaded only when the user opens the Settings panel. Boot stays cheap; only the few players who actually open Settings pay the cost.
7. **Taint-safe Blizzard-UI replacement recipe.** `hooksecurefunc` on the toggle, reparent Blizzard frames to a hidden parent (don't `Hide`), guard with `debugstack()` against recursion, never instantiate `MoneyFrame`, ship `TaintLess.xml` as the first include.

## 17. Anti-patterns

1. **"All Rights Reserved" license despite a public GitHub repo.** Discourages forks, contributions, and downstream reuse. The submodule libraries (Sushi, Poncho, etc.) are GPL — the umbrella license being ARR is inconsistent and legally murky for anyone wanting to fork.
2. **Cross-addon relative-path includes (`..\..\BagBrother\core\core.xml`).** Works only because the packager bundles BagBrother and Bagnon side-by-side in the same install. Fragile to filesystem layout, breaks if a user installs only one of the two, and bypasses the proper `## Dependencies` mechanism. The fact it works does not mean it should be done.
3. **No formal test/debug subsystem in BagBrother itself.** Test files (`src/test.lua`) are commented out in XML rather than gated by a debug flag; there's no `/bgn debug` toggle, no log-level system. Embedded libraries (Sushi, Poncho) ship WoWUnit suites but the BagBrother engine layer — the bit with all the taint-sensitive logic — has none. Regressions are caught by users in production.
4. (Bonus) **String-match slash dispatcher with no command table.** `slashCommands.lua` is a flat `if cmd == 'bags' or cmd == 'inventory' then ...` chain. Fine at this size, but blocks help-text auto-generation, completion, and unit tests. A small `{ name=, aliases=, fn=, help= }` table would not have cost much.

---

## URL index

- Bagnon repo: https://github.com/Jaliborc/Bagnon
- BagBrother repo: https://github.com/Jaliborc/BagBrother
- Sushi-3.2: https://github.com/Jaliborc/Sushi-3.2
- Poncho-2.0: https://github.com/Jaliborc/Poncho-2.0
- C_Everywhere: https://github.com/Jaliborc/C_Everywhere
- Bagnon TOC: https://raw.githubusercontent.com/Jaliborc/Bagnon/master/Bagnon.toc
- Bagnon main.xml: https://raw.githubusercontent.com/Jaliborc/Bagnon/master/src/main.xml
- Bagnon frame.lua: https://raw.githubusercontent.com/Jaliborc/Bagnon/master/src/frame.lua
- Bagnon Bindings.xml: https://raw.githubusercontent.com/Jaliborc/Bagnon/master/Bindings.xml
- BagBrother core.xml: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/core.xml
- BagBrother core.lua: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/core.lua
- libs.xml: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/libs/libs.xml
- .gitmodules (BB): https://raw.githubusercontent.com/Jaliborc/BagBrother/master/.gitmodules
- slashCommands.lua: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/features/slashCommands.lua
- uiOverrides.lua: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/features/uiOverrides.lua
- antiMoneyTaint.lua: https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/features/antiMoneyTaint.lua
- events.lua (api): https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/api/events.lua
- frames.lua (api): https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/api/frames.lua
- settings.lua (api): https://raw.githubusercontent.com/Jaliborc/BagBrother/master/core/api/settings.lua
