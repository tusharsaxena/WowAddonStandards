# Auctionator — Principal-Engineer Research Notes

**Target:** Auctionator (plusmouse, Borjamacare). Auction-house workflow addon, ~10 locales, supports Mainline / Cata / Mists / Wrath / TBC / Vanilla / Classic Era from one source tree.

**Repo:** https://github.com/Auctionator/Auctionator
**Read-only research, 2026-05-03.**

---

## 1. TOC

- Single TOC file: `Auctionator.toc` (no `_Mainline.toc` / `_Vanilla.toc` split). Multi-flavor through the `## Interface:` line listing **all** TOC numbers comma-separated: `120005, 120001, 50503, 38000, 20505, 11508`. https://github.com/Auctionator/Auctionator/blob/master/Auctionator.toc
- `## SavedVariables:` lists 8 globals (`AUCTIONATOR_CONFIG`, `AUCTIONATOR_SAVEDVARS`, `AUCTIONATOR_SHOPPING_LISTS`, `AUCTIONATOR_PRICE_DATABASE`, `AUCTIONATOR_POSTING_HISTORY`, `AUCTIONATOR_VENDOR_PRICE_CACHE`, `AUCTIONATOR_RECENT_SEARCHES`, `AUCTIONATOR_SELLING_GROUPS`); `## SavedVariablesPerCharacter:` is `AUCTIONATOR_CHARACTER_CONFIG`.
- `## OptionalDeps: LibAHTab` (only optional dep — and notably, the **core code does not pull LibAHTab in**; it builds its own tab container, see §6).
- TOC body is a list of `<flavor>: <path>` style includes (`Source/Manifest.xml`, `Source_Mainline/...`, `Imports_ModernAH/...`, `Patches/TaintLess.xml`, etc.) with conditional flavor-gates so a single TOC drives all clients.
- 10 localization X-Locale variants declared in metadata.

## 2. Layout

```
Auctionator.toc                  (single, multi-flavor)
Source/                          shared, retail+classic
Source_Mainline/                 retail-only
Source_ModernAH/                 modern AH UI (Cata+)
Source_LegacyAH/                 vanilla/TBC/Wrath AH UI
Source_Classic/  Source_Vanilla/ Source_TBC/
Libs/                            LibStub, LibCBOR
Libs_ModernAH/                   LibAHTab, LibBattlePetTooltipLine
Imports_ModernAH/  Imports_LegacyAH/
Data_Vanilla/  Data_Cata/        baked data tables
DB2_Scripts/                     Python tooling for regenerating data
Locales/                         per-language Lua + Main.lua dispatcher
Patches/                         TaintLess.xml
Assets_LegacyAH.xml  Assets_ModernAH.xml
.pkgmeta  .luarc.json
```

The eight flavor-suffixed top-level folders are how Auctionator avoids `if WOW_PROJECT_ID == ...` in code: the TOC selects the right folder per flavor.

## 3. Module loading — XML manifest cascade

This is the cleanest pattern in the codebase. **No string-list of files in the TOC.** The TOC includes `Source/Manifest.xml`; every subfolder owns its own `Manifest.xml` and is composed via nested `<Include file="…/Manifest.xml"/>`.

- `Source/Manifest.xml`: opens with `<Script file="Objects.lua"/>`, then `<Script file="Locales\Main.lua"/>`, then `<Include>` for each subfolder (Constants → Components → Search → Utilities → Tooltips → Variables → Database → Shopping → Selling → PostingHistory → Config → CraftingInfo → Tabs → API → SlashCmd → **Initialize last**). https://github.com/Auctionator/Auctionator/blob/master/Source/Manifest.xml
- Files within a subfolder are leaves (`<Script file="Main.lua"/>`, `<Include file="Frame.xml"/>`).

Effect: file order is local to each module, the global TOC stays one line per area, and adding a new module is a single `<Include>` change. This is materially better than maintaining a flat list in the TOC.

## 4. Bootstrap

`Source/Objects.lua` is just **declarative namespace setup** — one global `Auctionator = {}` with empty sub-tables (`State`, `Search`, `Shopping`, `Selling`, `Cancelling`, `Config`, `Variables`, `Dialogs`, `API.v1`, `Enchant`, `CraftingInfo`, `PostingHistory`, …). No methods, no logic. https://github.com/Auctionator/Auctionator/blob/master/Source/Objects.lua

`Source/Initialize/Main.lua` defines `AuctionatorInitializeMixin` on a hidden frame that registers `ADDON_LOADED` + `PLAYER_LOGIN` via `FrameUtil.RegisterFrameForEvents`:

- On `ADDON_LOADED == "Auctionator"`: `Auctionator.Variables.Initialize()`, `Auctionator.SlashCmd.Initialize()`.
- On `PLAYER_LOGIN`: `Auctionator.Variables.InitializeLate()`.
- Also calls `C_ChatInfo.RegisterAddonMessagePrefix("Auctionator")`.

This is the modern equivalent of `OnInitialize` / `OnEnable` — without Ace.

## 5. Libraries — non-Ace stack

- `Libs/`: **only** `LibStub` and `LibCBOR` (price-db serialization). https://github.com/Auctionator/Auctionator/tree/master/Libs
- `Libs_ModernAH/`: `LibAHTab`, `LibBattlePetTooltipLine`. (LibAHTab listed as `OptionalDeps` in TOC but actually shipped here for modern AH only.)
- **No AceAddon, AceDB, AceConfig, AceLocale, AceConsole, AceEvent, AceGUI, CallbackHandler, LibSharedMedia.** Zero Ace surface area.
- Replacements:
  - AceAddon → mixin frame + `ADDON_LOADED` (§4)
  - AceDB → hand-rolled saved-vars init with `__dbversion` migration ladder
  - AceConfig/Options → Blizzard `Settings` API (§7)
  - AceLocale → `AUCTIONATOR_LOCALES = {}` + `GetLocale()` switch in `Locales/Main.lua`, then injected into `_G` as `AUCTIONATOR_L_*` globals so XML can reference them by name
  - AceConsole → `SLASH_AUCTIONATOR1`/`SLASH_AUCTIONATOR2` + dispatch table (§9)
  - AceEvent → no event bus; modules register Blizzard events directly on their own frames

## 6. Architecture

**Mixin-on-frame everywhere.** XML defines `<Frame name="Foo" mixin="AuctionatorFooMixin">`; matching Lua file does `AuctionatorFooMixin = {}` and methods. `OnLoad`, `OnShow`, `OnEvent` are wired in XML `<Scripts>` and resolve to mixin methods. This is the same pattern Blizzard's own UI uses (`AuctionHouseFrameMixin`, etc.).

**No custom event bus.** `Source/Components/Events.lua` is just a constants table mapping logical names (`EnterPressed = "components_enter_pressed"`) to strings; modules emit and listen via Blizzard's `CallbackRegistryMixin` / `RegisterCallback` machinery on each frame. There is no central pub/sub.

**Modules talk through the global namespace.** `Auctionator.Search.Foo()` is the interface. No dependency injection, no DI container. Loose coupling enforced by convention.

**API surface.** `Auctionator.API.v1` is explicitly versioned for third-party addons. Cancelling, Selling, Shopping all have public entry points there.

## 7. Settings / Options UI — modern non-Ace path

This is the headline finding. Auctionator uses the **Blizzard `Settings` API** introduced in 10.0, not InterfaceOptions, not AceConfig.

- `Source/Config/Main.lua` — pure data layer: `Auctionator.Config.Options` (string-constant keys), `Auctionator.Config.Defaults`, dual-storage routing (`AUCTIONATOR_CONFIG` global vs `AUCTIONATOR_CHARACTER_CONFIG` per-char), `Get(option)` / `Set(option, value)`, `IsValidOption()`. Independent of any UI. https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Main.lua
- `Source/Config/Mixins/PanelConfig.lua` — `AuctionatorPanelConfigMixin` registers the canvas panel:
  ```lua
  -- root panel:
  local category = Settings.RegisterCanvasLayoutCategory(self, self.name)
  Settings.RegisterAddOnCategory(category)
  -- subcategory:
  local sub = Settings.RegisterCanvasLayoutSubcategory(
      Auctionator.State.OptionsCategory, self, self.name)
  Settings.RegisterAddOnCategory(sub)
  ```
  No `InterfaceOptions_AddCategory` anywhere.
- `Source/Config/InitializeFrames.lua` — drives panel creation by template name:
  ```lua
  CreateFrame("FRAME",
              "AuctionatorConfig" .. name .. "Frame",
              SettingsPanel,
              "AuctionatorConfig" .. name .. "FrameTemplate")
  ```
- `Source/Config/Frames/*.xml` — each panel (Advanced, Profile, Shopping, …) is a `<Frame virtual="true" inherits="AuctionatorConfigurationFrameTemplate">` with checkboxes inheriting `AuctionatorConfigurationCheckbox`, headings inheriting `AuctionatorConfigurationHeadingFrame`. Localized labels by **global string name** (`AUCTIONATOR_L_CONFIG_DEBUG`).
- `Frame.xml`: `<Frame name="AuctionatorConfigurationFrameTemplate" mixin="AuctionatorConfigFrameMixin" hidden="true">` is the shared base. https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Frame.xml

**Net result:** options panel built entirely from XML templates + reusable widget templates + Settings API registration. No AceGUI tree, no AceConfig DSL. Looks visually identical to Blizzard's own option panels (because it *is* Blizzard's option panel).

## 8. Slash commands

`Source/SlashCmd/Main.lua`: classic globals + dispatch table.
```lua
SLASH_AUCTIONATOR1 = "/auctionator"
SLASH_AUCTIONATOR2 = "/atr"
SlashCmdList["AUCTIONATOR"] = Handler
```
Handler splits on first whitespace, looks up a `SLASH_COMMANDS` table (`p`/`post`, `cu`/`cancelundercut`, `c`/`config`, `h`/`help`, …), dispatches with the rest. Aliases are intentional first-class. No AceConsole.

## 9. Locale

`Locales/Main.lua` initializes `AUCTIONATOR_LOCALES = {}`; per-language files (`enUS.lua`, `deDE.lua`, …) populate it; Main.lua resolves with `GetLocale()` falling back to enUS, then **flattens into `_G` as `AUCTIONATOR_L_<KEY>`** so XML inherits/text fields can reference them by name. Trade-off: pollutes globals, but lets XML stay declarative. (No AceLocale.)

## 10. Events

No central bus. Each frame mixin owns its event subscriptions. `FrameUtil.RegisterFrameForEvents(self, EVENT_LIST)` is used in `Initialize/Main.lua`. Inter-module signalling uses Blizzard's `CallbackRegistryMixin` (the same machinery Blizzard's own UI uses).

## 11. Frames / XML mixin pattern

Every UI element is `<Frame mixin="AuctionatorXxxMixin">` with method names in `<Scripts>` (`<OnLoad method="OnLoad"/>`). Lua defines `AuctionatorXxxMixin = {}` and `function AuctionatorXxxMixin:OnLoad() …`. This is consistent across hundreds of templates. **`virtual="true"` templates are heavily used** for reusable widgets (e.g. `AuctionatorConfigurationCheckbox`, `AuctionatorConfigurationHeadingFrame`).

## 12. Debug

Debug is a Settings checkbox (`AUCTIONATOR_L_CONFIG_DEBUG`) bound to a config key, gated by `Auctionator.Config.Get("debug")`. Bug-grabber-friendly per README.

## 13. Packaging — `.pkgmeta`

`package-as: Auctionator`. Ignores `README.md`, `test-data`, `Scripts`, `DB2_Scripts`, `annotations.lua`. Multiple `plain-copy` directives for source/imports per flavor. **No `externals:` block** — i.e. libraries are vendored, not pulled at build time. https://github.com/Auctionator/Auctionator/blob/master/.pkgmeta

## 14. AH taint and secure-environment integration

This is the most interesting finding for a library author and worth dwelling on.

**(a) Pre-bundled Blizzard taint patch.** `Patches/TaintLess.xml` is townlong-yak's TaintLess (v22-09-15), included via TOC for vanilla/TBC/Wrath flavors. It patches three known taint sinks (`RefreshOverread` in dropdowns, `displayMode` taint, `IOFrameSelection` lingering after Interface Options closes) using `purgeKey()` + `issecurevariable()` validation. Auctionator ships it because legacy AH flavors still hit those sinks. https://github.com/Auctionator/Auctionator/blob/master/Patches/TaintLess.xml

**(b) Avoidance over circumvention on modern AH.** `Source_ModernAH/Core/Mixin.lua` does **not** replace `AuctionHouseFrame` — it parents children frames into it and uses `PLAYER_INTERACTION_MANAGER_FRAME_SHOW`/`HIDE` (interaction type Auctioneer) to drive visibility. This sidesteps the taint problem of intercepting AH show/hide.

**(c) Defensive scale check.** Direct comment in code: *"Workaround for TSM breaking the frame positioning when they 'hide' the AH window by scaling it to be really small."* If `AuctionHouseFrame:GetScale() < 0.5`, defer init via `OnUpdate`. Tells you these authors learned the AH addon ecosystem the hard way.

**(d) Tab system.** Despite shipping LibAHTab in `Libs_ModernAH`, the core code creates its own `AuctionatorAHTabsContainer` frame from a custom template, parented to `AuctionHouseFrame`, and clicks `chosenTab:Click()` on show. LibAHTab is presumably present for compatibility with other addons that key off it, not because Auctionator depends on it.

**(e) Throttling, not detainting.** `Source_ModernAH/AH/Wrappers.lua` queues most `C_AuctionHouse` calls through `Auctionator.AH.Queue:Enqueue()` to respect the AH server-side rate limit. State variables (`sentBrowseQuery`) gate result validation. **`CancelAuction()` is intentionally not queued** — it's a hardware-event-protected call and queuing it would break it. That's a deliberate design choice the comment calls out.

**Summary of the secure-env strategy:** stay out of Blizzard's secure code paths, parent into `AuctionHouseFrame` rather than replace it, drive show/hide from interaction-manager events, throttle non-protected calls through a queue, and ship TaintLess only on flavors that need it.

## 15. Versioning / saved-var migration

`Source/Variables/Main.lua` checks `__dbversion` keys and walks a migration ladder (`VERSION_8_3 → VERSION_SERIALIZED → VERSION_KEY_SERIALIZED`). On unrecognized version, the price database is reset (acceptable because it's regenerable from scans). Connected-realm import logic preserves data when realm names change. This is a hand-rolled but disciplined version of what AceDB profiles do automatically.

---

## Patterns to steal (top 5)

1. **Manifest.xml cascade per module.** Replace flat file lists in TOC with `<Include file="Module/Manifest.xml"/>`. Adding/removing modules becomes one line. Massively easier merges than TOC churn.
2. **Pure declarative namespace bootstrap (`Objects.lua`).** A single file that does nothing but declare `Addon = {}` + every sub-table. Eliminates load-order surprises for table assignment; methods append safely after.
3. **Reusable XML widget templates (`AuctionatorConfigurationCheckbox`, etc.).** Even an Ace3 addon should consider XML virtual templates for visual consistency — they cost nothing and inherit Blizzard's look.
4. **Single TOC for all flavors with flavor-suffixed Source folders.** `Source_Mainline/`, `Source_Vanilla/` selected by TOC conditional includes, not by `if WOW_PROJECT_ID` in Lua. Far cleaner than per-flavor `if` ladders.
5. **AH-style API versioning namespace (`Auctionator.API.v1`).** If a Ka0s addon exposes anything to other addons, pin it under a versioned subtable. Cheap, future-proofs breakage.

(Bonus 6th: **TaintLess.xml prebundled for legacy flavors** if a Ka0s addon ever touches dropdowns / Interface Options on Wrath/TBC.)

## Anti-patterns to avoid (3)

1. **Eight near-duplicate `Source_*` folders.** Great for flavor isolation, terrible for code reuse. Bug fixes need to be ported across folders manually. A diff between `Source_ModernAH` and `Source_LegacyAH` is largely the same logic with different APIs. Ka0s should prefer thin per-flavor shims with shared core.
2. **Localized strings flattened into `_G` as `AUCTIONATOR_L_*`.** Pollutes globals to make XML inherits work. Acceptable price for declarative XML, but a real cost. AceLocale's `L["Foo"]` keeps strings encapsulated.
3. **Hand-rolled DB version migration without profiles.** Auctionator doesn't have user profiles at all — global config or per-character, no "Default/PvP/Raid" profiles. For an addon as feature-rich as this it's surprising. AceDB profiles solve this for free.

## Verdict — does the modern non-Ace path beat Ace3 for new Ka0s addons?

**No, not for our use case.** Auctionator's stack is credible and elegant for a single-flagship addon with deep Blizzard-UI integration (the AH is itself a Blizzard `Settings`-style frame, so matching that idiom is natural). But it costs Auctionator: (a) hand-rolled SavedVariables migration with no profile concept, (b) no event bus — modules talk through global tables, (c) `_G`-polluting locale flattening, (d) no AceConsole-grade slash-arg parser, (e) ~8 forked source folders for flavor support.

For a **collection** of small-to-medium Ka0s addons that share conventions, Ace3 wins on:

- AceDB profiles (Auctionator has none),
- AceConfig auto-generated options trees (vs writing XML widget templates per option),
- AceLocale namespacing (vs `_G` flattening),
- AceEvent / CallbackHandler-1.0 message bus (vs nothing / direct frame events),
- shared library deduplication via LibStub embeds (Ka0s already standardizes this).

**Steal selectively from Auctionator** — the Manifest.xml cascade, the namespace bootstrap, the single-TOC-multi-flavor trick, the API versioning, the XML mixin pattern (which is orthogonal to Ace anyway). Keep Ace3 as the substrate. The Ace3-bias in the Ka0s standard is correct.

---

## Cited URLs

- Repo root: https://github.com/Auctionator/Auctionator
- TOC: https://github.com/Auctionator/Auctionator/blob/master/Auctionator.toc
- pkgmeta: https://github.com/Auctionator/Auctionator/blob/master/.pkgmeta
- Source/Manifest.xml: https://github.com/Auctionator/Auctionator/blob/master/Source/Manifest.xml
- Source/Objects.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Objects.lua
- Source/Initialize/Main.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Initialize/Main.lua
- Source/Config/Main.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Main.lua
- Source/Config/InitializeFrames.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Config/InitializeFrames.lua
- Source/Config/Frame.xml: https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Frame.xml
- Source/Config/Mixins/PanelConfig.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Mixins/PanelConfig.lua
- Source/Config/Frames/Advanced.xml: https://github.com/Auctionator/Auctionator/blob/master/Source/Config/Frames/Advanced.xml
- Source/SlashCmd/Main.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/SlashCmd/Main.lua
- Source/Variables/Main.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Variables/Main.lua
- Source/Components/Events.lua: https://github.com/Auctionator/Auctionator/blob/master/Source/Components/Events.lua
- Source_ModernAH/Core/Mixin.lua: https://github.com/Auctionator/Auctionator/blob/master/Source_ModernAH/Core/Mixin.lua
- Source_ModernAH/Core/AuctionatorAHFrame.xml: https://github.com/Auctionator/Auctionator/blob/master/Source_ModernAH/Core/AuctionatorAHFrame.xml
- Source_ModernAH/AH/Wrappers.lua: https://github.com/Auctionator/Auctionator/blob/master/Source_ModernAH/AH/Wrappers.lua
- Source_ModernAH/AH/Events.lua: https://github.com/Auctionator/Auctionator/blob/master/Source_ModernAH/AH/Events.lua
- Patches/TaintLess.xml: https://github.com/Auctionator/Auctionator/blob/master/Patches/TaintLess.xml
- Libs/: https://github.com/Auctionator/Auctionator/tree/master/Libs
- Libs_ModernAH/: https://github.com/Auctionator/Auctionator/tree/master/Libs_ModernAH
- Locales/: https://github.com/Auctionator/Auctionator/tree/master/Locales
