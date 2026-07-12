# Ka0s WoW Addon Standard (v2.4, 2026-07-12)

**Status:** Source of truth. All audit deviation reports and `02_NEW_ADDON_CONTEXT.md` template content derive from this document. When the standard changes, bump the date and version at the top.

**Adherence:** Every Ka0s addon **MUST** be built to this standard and **MUST** reference it: <https://github.com/tusharsaxena/WowAddonStandards> (see §15, §2.1).

**Changelog**

- **v2.4 (2026-07-12):** **§6 options-panel refinements** from the Tier-2 tracker's settings work. **(1)** New **§6.10 Scroll container** — the body's AceGUI `ScrollFrame` **MUST** keep its vertical scrollbar shown *even when the content fits* (park + disable the thumb; don't hide the bar), so every subcategory renders at an identical body width and right margin. Hiding the bar on short pages is now an anti-pattern (§19). **(2)** **§6.6 / §6.8** — a cell-filling action `Button` in a 50/50 pair **MUST** inset to `SetRelativeWidth(0.492)` (new constant `BUTTON_PAIR_REL`), not a flush `0.5`, so AceGUI Flow's ~2px right-cell spill isn't shaved off by the `ScrollFrame` clip rect. §19 anti-patterns updated.
- **v2.3 (2026-07-12):** **§12 debug console overhaul**, promoted from the loot-history reference implementation. The console now mandates: a **shipped monospace font** under `media/fonts/` (e.g. **JetBrains Mono**, OFL; LSM-registered) applied at **10pt**; a **tagged, colour-coded line format** — `<HH:MM:SS> | [<Tag>] <content>` with the timestamp in muted steel-blue (`6f8faf`), the `[tag]` in muted tan/gold (`c9a66b`), and the `|` separator + content in the default white — mirrored to a **code-free Copy buffer** via **two pure formatters** (`FormatPlain`/`FormatColored`) so the two never drift; a **`NS.Debug(tag, fmt, ...)`** sink with the **tag as the first argument**; a **default window size of `700×344`**; and **session-only, window-independent enabled-state** — `NS.State.debug`, default **off**, held out of SavedVariables and **reset every `/reload`**, toggled by `/<slash> debug on|off` (bare `/<slash> debug` toggles the *window* only) and an in-title-bar **`Debug: ON`/`OFF`** control (green/red). **This reverses the v2.0 "enabled-state SHOULD persist in SV" line** — debug is now session-only by default; persisting it is the documented deviation.
- **v2.2 (2026-07-12):** Added **§3.6 No addon-suite dependencies** — a Ka0s addon MUST be fully self-contained and behave identically with no other addon installed; it MUST NOT hard-depend on, embed, or read the media/API/SavedVariables of any addon *suite* or standalone addon (ElvUI, EllesmereUI, DBM, WeakAuras, BigWigs, …). Optional, presence-guarded integration that degrades gracefully is still allowed (the shared-**library** vendoring rule of §3.3 is unchanged — libraries are not suites). §19 anti-patterns updated.
- **v2.1 (2026-07-12):** Standardized the **root `README.md` structure** (§15.1) and the **TOC field order + file-listing structure** (§2.1, §2.5) — one canonical layout every addon follows, taken from the collection's Tier-2 modular tracker as the golden template. Added the **no-`TODO.md`** rule (§15.4): released addons track all issues/enhancements in **GitHub issues**, not a `TODO.md`; only an unreleased, in-development addon may keep a `TODO.md` during its development phase. §19 anti-patterns updated.
- **v2.0 (2026-07-12):** Major refresh.
  - **Retail-only.** Dropped the multi-flavor apparatus. A single `## Interface:` line carries the latest Retail patch number (currently `120007`); no comma-separated flavor lists, no per-flavor TOCs, no `_Mainline`/`_Classic` data splits. §1.2, §2.1, §2.3, §11, §19 updated.
  - **Docs relocated.** Root keeps `README.md` (full), a **stub** `CLAUDE.md` (pointer), and `LICENSE`; `ARCHITECTURE.md` and all other docs move under `docs/`. §1.1, §1.2, §15.
  - **Automated tests + local build (new §14A).** Every addon ships a headless plain-Lua-5.1 `tests/` harness (runner + micro-framework, headless source loader, WoW-API mocks, per-module suites); TDD, with `lua tests/run.lua` green **and** `luacheck .` clean required before every commit. Local toolchain documented. (CI stays out of scope; local testing is now in scope.)
  - **Preview / test mode (new §6B).** Addons with a positionable UI should ship a placeholder-data preview mode.
  - **Debug console (§12).** Debug output routes to a dedicated on-screen console styled like the addon's main window, not the chat frame; enabled-state should persist in SV.
  - **Settings entry always visible (§6.1).** The Blizzard settings **category** must be registered eagerly at load so the entry is always present; only the body builds lazily. Deferring registration to first `/config` is now an anti-pattern.
  - **Typed media subfolders (§1, §6.5).** Shipped media lives in `media/logos/`, `media/screenshots/`, etc. — nothing loose in `media/`.
  - **No named implementations (§0).** The normative standard describes reference implementations by their characteristics instead of naming specific addons; named evidence lives in `03_INDUSTRY_RESEARCH.md`.
  - Reaffirmed: libraries are vendored and committed (no externals; since v1.1).
- **v1.3 (2026-07-11):** Added **§6A Standalone windows / data browsers**.
- **v1.2 (2026-07-11):** Added the **git workflow** rule (trunk-based; no feature branches unless asked; never push unless asked). Renamed §17 and added the matching anti-pattern (§19).
- **v1.1 (2026-07-11):** Reversed the library-embedding rule — addons now **vendor all libraries in `libs/` and commit them**; `.pkgmeta` `externals:` for libs is forbidden. (v1.0 mandated externals.)
- **v1.0 (2026-05-03):** Initial standard.

**Audience:** future Ka0s and any agent (human or LLM) authoring or maintaining a Ka0s addon.

**Substrate:** Ace3. The ecosystem and Ka0s collection are aligned on it; deviations from Ace3 are case-by-case and must be justified.

**License:** MIT. Hostile licenses (`All Rights Reserved`) are forbidden.

---

## 0. Reading this document

Each section uses these markers:

- **MUST** — non-negotiable; deviations are bugs.
- **SHOULD** — strongly preferred; deviations require a comment in code explaining why.
- **MAY** — optional; pick when it fits.
- **MUST NOT** / **SHOULD NOT** — forbidden patterns with cited reasons.

**Reference implementations are described, not named.** This normative standard **MUST NOT** name a specific addon (from the Ka0s collection or the wider ecosystem) as a reference implementation. Instead it *describes* the implementation — what it does and how — in enough detail to be actionable on its own. This keeps the standard self-contained and durable when addons change or are renamed. The **named** research evidence behind these patterns (which real addons exhibit them) lives in the companion research document, `03_INDUSTRY_RESEARCH.md`, which is a standards-process input rather than part of the normative standard.

Where a Ka0s addon today already implements a rule well, it is called out as *"reference implementation (in the collection)"* with a description of the addon's role, never its name.

---

## 1. Tiered layout

A Ka0s addon is in one of two tiers. **MUST** declare the tier in the addon's root `CLAUDE.md` stub (or the `docs/` it points to) so reviewers know which rules to apply.

### 1.1 Tier 1 — Flat (≤8 source files)

For utility-class addons (e.g. a small group-composition utility at ~3 files, a chat-formatting addon at ~10 files).

```
<AddonName>/
  <AddonName>.toc
  <AddonName>.lua          -- entry; AceAddon registration
  Settings.lua             -- schema + AceDB defaults + panel
  Locale.lua               -- L = setmetatable({}, {__index=function(_,k) return k end})
  Compat.lua               -- deprecated-API shims (only if needed)
  README.md                -- full, user-facing (stays at root)
  CLAUDE.md                -- STUB: short pointer into docs/ (§15)
  LICENSE                  -- MIT
  .luacheckrc
  .pkgmeta
  libs/                    -- vendored Ace3 + other libs, committed to git (§3.3)
  media/                   -- typed subfolders only: logos/, screenshots/, ... (§1.4)
  tests/                   -- headless Lua 5.1 harness (§14A)
  docs/                    -- ARCHITECTURE.md, full agent context, planning/reference docs (§15)
```

- **MUST** stay flat — no `core/`, `modules/` subfolders for source.
- **MUST** keep each file under 1500 LOC. If a file exceeds 1000, plan a peel.
- **MAY** peel a single oversized file into 2-3 sub-files in the same folder (e.g. `Settings_Schema.lua`, `Settings_Panel.lua`) — **MUST NOT** introduce subfolders for source.
- Promotion to Tier 2 is mandatory once source-file count would exceed 8 (excluding `libs/`, `media/`, `docs/`, `tests/`, `reviews/`).

### 1.2 Tier 2 — Modular (>8 files or any addon with multiple feature modules)

Reference implementation (in the collection): the Tier-2 modular interrupt/cooldown group tracker.

```
<AddonName>/
  <AddonName>.toc          -- single file, single Interface line (latest Retail), lists all .lua in dependency order
  core/
    Compat.lua             -- deprecated-API shims; loaded FIRST
    Constants.lua          -- numeric constants, enum-like tables
    Namespace.lua          -- bootstrap: local addonName, NS = ...; sets up shared upvalues
    State.lua              -- mutable runtime state, message bus
    Util.lua               -- pure helpers
    <AddonName>.lua        -- AceAddon registration; promotes NS to AceAddon
    Database.lua           -- AceDB profile/global setup, migration runner
  defaults/
    Profile.lua            -- C = profile defaults table
    Global.lua             -- G = global defaults table (rare; only when needed)
    Spells.lua / Data*.lua -- Retail data tables (no per-flavor suffix; Retail only)
  settings/
    Schema.lua             -- one row per setting: {path, default, type, label, widget, validate, onChange}
    Panel.lua              -- Blizzard Settings.RegisterCanvasLayoutCategory + raw AceGUI render
    Slash.lua              -- AceConsole binding; reads Schema for get/set/list/reset
  locales/
    enUS.lua               -- canonical
    deDE.lua, frFR.lua, ... -- gated with `if GetLocale() ~= "deDE" then return end`
    PostLoad.lua           -- derived-key aliases (L[2806] = L[2706])
  modules/
    <Feature>.lua          -- one file per feature module; max ~1500 LOC each
    ...
  media/                   -- typed subfolders only (§1.4)
  libs/                    -- vendored Ace3 + other libs, committed to git (§3.3)
  tests/                   -- headless Lua 5.1 harness (§14A)
  docs/                    -- ARCHITECTURE.md, full agent context, planning/reference docs (§15)
  reviews/<YYYY-MM-DD>/    -- audit history (retained; §16)
  README.md                -- full, user-facing (stays at root)
  CLAUDE.md                -- STUB: short pointer into docs/ (§15)
  LICENSE
  .luacheckrc
  .pkgmeta
```

- **MUST** load order: `core/Compat.lua` → `core/Constants.lua` → `core/Namespace.lua` → other `core/*` → `defaults/*` → `locales/*` → `settings/*` → `modules/*`.
- **MUST** cap any single `.lua` file at 1500 LOC. Files in the 1000–1500 band are on notice; a >1500 file is a bug — peel it.

### 1.3 Casing

- Addon root folder: **PascalCase** matching the `## Title:` in TOC (minus the `Ka0s ` prefix).
- Subfolders: **lowercase** (`core/`, `modules/`, `libs/`, `media/`, `defaults/`, `settings/`, `locales/`, `docs/`, `reviews/`, `tests/`). **MUST** use `libs/` lowercase (not `Libs/`).
- Lua files: **PascalCase.lua** (`Database.lua`, `IconGrid.lua`).
- Non-source folders that ship: lowercase.

### 1.4 Media subfolders

Shipped media **MUST** live in **typed subfolders** under `media/` — nothing loose directly in `media/`:

- `media/logos/` — the addon logo art (the runtime `.tga`/`.blp` plus the source `.jpg`/`.png`).
- `media/screenshots/` — README/store screenshots and any demo GIFs.
- `media/fonts/`, `media/sounds/`, `media/textures/` — as needed for shipped assets of that kind.

Reference implementation (in the collection): the standalone loot-history browser ships its logo under `media/logos/`. **MUST** keep the runtime texture in a WoW-loadable format (`.tga`/`.blp`) and the editable source (`.jpg`/`.png`) beside it (§6.5).

---

## 2. TOC file

### 2.1 Required fields

The metadata block **MUST** use this **exact field order** (omit a line only when the field genuinely doesn't apply); no blank lines inside the block:

```
## Interface: 120007                     -- SINGLE number; latest Retail patch (§2.3)
## Title: Ka0s <Human Name>              -- prefix every Ka0s addon
## Notes: <one-line user-facing description>
## Author: add1kted2ka0s
## Version: <semver>                     -- managed by version-bump skill
## IconTexture: <path|fileID>            -- optional but encouraged
## SavedVariables: <Addon>DB             -- single global SV per addon
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: <Combat|Group|Auction|Chat|UI|Misc>
## X-License: MIT
## X-Standard: https://github.com/tusharsaxena/WowAddonStandards
## X-Curse-Project-ID: <id>              -- mandatory if published
## X-Wago-ID: <id>                       -- mandatory if published
## X-WoWI-ID: <id>                       -- only if WoWI listing exists
```

- **MUST** follow the field order above so every Ka0s TOC reads identically. The file listing that follows the metadata block has its own required structure (§2.5). Reference implementation (in the collection): the Tier-2 modular tracker's TOC.
- **MUST** have `X-License: MIT`. **MUST NOT** ship "All Rights Reserved".
- **MUST** have `X-Standard:` pointing at the standards repo, declaring the addon is built to this standard.
- **MUST** have `X-Curse-Project-ID` and `X-Wago-ID` once an addon is published anywhere.
- **SHOULD NOT** declare hard `Dependencies`. Use `OptionalDeps` and shim missing libs with soft fallbacks. Reference implementation (in the collection): the absorb-shield tracker ships an AceDB-missing flat-table shim and LSM-missing Blizzard fallback constants, so it loads even with no libs present.

### 2.2 SavedVariables naming

- **MUST** be `<Addon>DB`, single global (`<Addon>DB`). Already universal in the collection.
- **SHOULD NOT** use `SavedVariablesPerCharacter` unless the data is genuinely per-character (most Ka0s addons run profile-per-character via AceDB; that's enough).
- **MUST** declare a `schemaVersion` integer in defaults. **MUST** ship a `Database.lua` migration runner even if the body is empty — schema migration is a from-day-one concern.

### 2.3 Retail only — single Interface line

The collection targets **Retail (Mainline) only**. Classic/other flavors are out of scope for the standard.

- **MUST** ship a single TOC with a **single** `## Interface:` value = the **latest Retail patch** interface number (currently `120007`). Bump it each patch with the `wow-addon:bump-interface` skill.
- **MUST NOT** use a comma-separated multi-flavor Interface list, per-flavor TOC files, or `enable-toc-creation` flavor fan-out.
- **MUST NOT** ship `_Mainline`/`_Classic` data splits. Data files are plain (`Spells.lua`, `Data*.lua`).
- **MUST NOT** use `if WOW_PROJECT_ID == ...` ladders inline in feature code. Any genuine cross-patch version check is a Retail-patch check and is branched in `Compat.lua` behind a named flag (§11).
- The README `[wow]` badge **MUST** show this same single Interface number and stay in lockstep with the TOC (§15).

### 2.4 File listing

- **MUST** list `.lua` files in dependency-correct order. **MUST NOT** rely on alphabetical loading.
- **SHOULD NOT** use `embeds.xml` at Tier 1. Tier 2 **MAY** use a single `embeds.xml` if file count justifies it — remove it if it doesn't earn its keep.

### 2.5 File-listing structure (after the metadata block)

The metadata block (§2.1) is followed by **one blank line**, then the file listing broken into **commented sections in load order**. Every Ka0s TOC uses the same section comments so the load order is self-documenting. Reference implementation (in the collection): the Tier-2 modular tracker's TOC.

```
# Libraries (must load first)
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
...

# Locales
locales\enUS.lua

# Core
core\Compat.lua
core\Constants.lua
core\State.lua
core\Util.lua
core\Database.lua
core\<Addon>.lua

# Defaults
defaults\Profile.lua

# Modules
modules\<Feature>.lua

# Settings (last — depend on everything else being initialized)
settings\Panel.lua
settings\...
```

- **MUST** use `#` section headers, in the order **Libraries → Locales → Core → Defaults → Modules → Settings**, matching the Tier-2 load order (§1.2). Libraries always load **first**; settings **last**.
- **Tier 1** addons keep the `# Libraries (must load first)` section, then list their flat source files (`Compat.lua`, `Locale.lua`, `<Addon>.lua`, `Database.lua`, `Settings.lua`) in dependency order under a single `# Addon` section — no `core/`/`modules/` split (§1.1).
- **MUST** end the file with a single trailing newline.

---

## 3. Library stack

### 3.1 Mandatory libs (every Ace3 addon)

| Lib | Purpose | Embedded as |
|---|---|---|
| LibStub | lib registry | vendored |
| CallbackHandler-1.0 | Ace3 dependency | vendored |
| AceAddon-3.0 | addon + module lifecycle | vendored |
| AceDB-3.0 | profile / char / global SV | vendored |
| AceEvent-3.0 | event subscription | vendored |
| AceTimer-3.0 | timers | vendored |
| AceConsole-3.0 | slash registration | vendored |
| AceGUI-3.0 | options panel widgets | vendored |

All libraries are **vendored in `libs/` and committed** (§3.3).

### 3.2 Common optional libs

| Lib | When |
|---|---|
| LibSharedMedia-3.0 | any addon with user-facing fonts/textures/sounds |
| AceDBOptions-3.0 | only if Profiles sub-page is wired |
| AceConfig-3.0 / AceConfigDialog-3.0 | **only if** the addon ships a Profiles sub-page using AceDBOptions; otherwise the canonical pattern is Blizzard Settings + raw AceGUI |
| LibDualSpec-1.0 | spec-aware profile switching |
| LibSerialize | export/import |
| LibDeflate | export/import compression |
| LibDBIcon-1.0 | minimap LDB icon |

### 3.3 Vendoring over externals

Ka0s addons **MUST ship every library vendored in `libs/` and committed to git**. The addon must be fully self-contained — installable by copying the folder into `Interface/AddOns/` with no packager step required to obtain libraries.

- **MUST** vendor all Ace3 and third-party libs under `libs/` and commit them. **MUST NOT** use `.pkgmeta` `externals:` to fetch libraries.
- **MUST** use the standard folder-per-lib layout (`libs/AceAddon-3.0/AceAddon-3.0.xml`, `libs/LibStub/LibStub.lua`, …) and load libs **first** in the TOC — the lib's `.xml` where it ships one (it pulls the lib's `.lua` + any sub-files), the `.lua` otherwise.
- **SHOULD** copy the folder-per-lib set from an existing Ka0s addon's `libs/` so lib versions stay consistent across the suite. Pull libs the suite doesn't yet vendor (LibDataBroker-1.1, LibDBIcon-1.0, …) from a current retail install or the upstream release.
- **MUST** vendor only libs the addon actually `LibStub("X")` — vendor what you use, nothing more. Prune dead weight (e.g. AceConfig where only Profiles needs it; AceLocale/AceBucket/AceComm/AceHook/AceSerializer/AceTab where unloaded).
- **MAY** vendor an addon-private micro-lib (e.g. an 80-line object-pool mixin) the same way.

### 3.4 Lib registry pattern

- **SHOULD** call `LibStub("X")` exactly once at addon load and stash on the addon's namespace: `NS.LSM = LibStub("LibSharedMedia-3.0")`. **SHOULD NOT** call `LibStub` from per-frame code.

### 3.5 Forking Ace libs is forbidden

- **MUST NOT** privately fork an Ace3 lib. Private lib forks seen in some large UI suites (renamed copies of Ace3) block on every Ace3 update and are an anti-pattern.
- **MUST** extend AceGUI via `AceGUI:RegisterWidgetType("Ka0s_X", ...)` if a custom widget is needed.

### 3.6 No addon-suite dependencies (self-contained)

A Ka0s addon **MUST** stand on its own. The vendoring rule (§3.3) makes it self-contained with respect to **shared libraries** (LibStub-registered code embedded under `libs/`); this rule makes it self-contained with respect to **other addons** — i.e. standalone addons and addon *suites* such as ElvUI, EllesmereUI, DBM, WeakAuras, BigWigs, Plater, etc. Suites are **not** dependencies. The distinction: a **library** is LibStub-registered code you vendor and own; a **suite** is a separate installed addon with its own lifecycle, and you never require it.

- **MUST NOT** hard-depend on any addon suite or standalone addon: no `## Dependencies:` / `## RequiredDeps:` naming one, and no code path that assumes a suite's globals, API, callbacks, or frames exist (`ElvUI`, `DBM`, `WeakAuras`, `BigWigs`, …).
- **MUST** be fully functional and behave **identically** with no other addon installed. Every texture, font, sound, and layout the addon needs is either vendored under `media/` (§1.4) or drawn from LibSharedMedia's built-ins — **MUST NOT** read a suite's media files, textures, fonts, or SavedVariables, and **MUST NOT** rely on a suite having skinned or repositioned any frame.
- **MUST NOT** embed, copy, or private-fork a suite's code, media, or a suite-renamed Ace library (this is the §3.5 fork ban applied to suites — depend on nothing you did not vendor and own).
- **MAY** *optionally* integrate with a suite that happens to be present — e.g. register an ElvUI/EllesmereUI skin for the addon's own frames, or subscribe to a DBM/BigWigs timer callback — **only when all** of the following hold: (a) the integration is presence-guarded (`C_AddOns.IsAddOnLoaded("ElvUI")`) and never assumes the suite loaded; (b) the suite is listed in `## OptionalDeps:`, never `## Dependencies:`; (c) with the suite absent the addon falls back to its own styling/behavior with no loss of core function. This is the same soft-fallback discipline required for optional libraries (§3.3–§3.4): the addon is whole on its own and the integration is pure enhancement.

---

## 4. Architecture

### 4.1 Namespace bootstrap (both tiers)

Every file **MUST** start with:

```lua
local addonName, NS = ...
```

`NS` is a single shared private table populated by ordered TOC loading. `addonName` is a string constant. **MUST NOT** create a `_G[addonName]` table; if a public surface is needed, expose it via `NS.API.v1` (see §10).

Optional ergonomic alias for hot files:

```lua
local L = NS.L         -- locale
local C = NS.C         -- profile defaults / current values cache
local State = NS.State -- runtime state
```

### 4.2 AceAddon registration (Tier 2 / any addon using Ace3 lifecycle)

Reference implementation (in the collection): the Tier-2 tracker promotes its bootstrap namespace to an AceAddon at `core/<AddonName>.lua`.

```lua
local addonName, NS = ...
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
NS.addon = addon  -- keep NS reference; modules read state through NS, not _G
```

- **MUST** pass the NS table as the first arg to `:NewAddon` (Ace3 supports this) so the bootstrap and AceAddon point at the same object.
- **SHOULD NOT** use AceAddon's per-module submodule pattern (`addon:NewModule("Foo")`) for fewer than ~10 feature modules. Direct `NS.Foo = NS.Foo or {}` per-module tables are lighter and equally testable.

### 4.3 Module pattern

```lua
local addonName, NS = ...
NS.IconGrid = NS.IconGrid or {}
local M = NS.IconGrid

function M:OnInitialize() ... end  -- only if registered as AceAddon submodule
function M:HandleSomething(...) ... end
```

- **MUST** publish modules via `NS.<Module> = NS.<Module> or {}` (idempotent) so file load order can be re-arranged without breakage.
- **SHOULD NOT** call into another module's table at file-load. Cross-module wiring happens after `PLAYER_LOGIN` or via the message bus.

### 4.4 Closed message bus (Tier 2)

Modules **MUST** communicate via named messages, not direct calls.

```lua
-- Producer (one per message)
NS.bus:SendMessage("Ka0s_<Addon>_RosterChanged", roster)

-- Consumer
NS.bus:RegisterMessage("Ka0s_<Addon>_RosterChanged", function(_, roster) ... end)
```

- **MUST** prefix every message `Ka0s_<Addon>_` to avoid collision.
- **MUST** document each message in `docs/ARCHITECTURE.md` with: name, sender (one), payload schema, all consumers.
- **MUST NOT** have two senders for the same message.
- Implementation: AceEvent-3.0's `:SendMessage`/`:RegisterMessage` (already in the addon); no new lib needed.

### 4.5 Schema-as-single-source

The single most important Ka0s pattern. Already implemented well across the collection. **MUST** be present in every addon with ≥3 user-visible settings.

```lua
NS.Schema = {
  { path = "display.scale",         default = 1.0,    type = "number",  min = 0.5, max = 2.0,
    label = "Scale", widget = "Slider", validate = function(v) ... end,
    onChange = function(v) NS.Display:UpdateScale(v) end },
  { path = "display.color",         default = {1,1,1,1}, type = "color",
    label = "Color", widget = "ColorPicker",
    onChange = function(v) NS.Display:UpdateColor(v) end },
  ...
}
```

- **MUST** drive all of: AceDB defaults, AceGUI panel widgets, `/<slash> get|set|list|reset` dispatch, defaults reset.
- **MUST** route every mutation through one helper: `NS.Schema:Set(path, value)` calls validate → write → onChange. Panel and slash both call this.
- **MUST** validate at boot: every schema row's `path` resolves against the defaults table; warn loudly on mismatch. Reference implementation (in the collection): the absorb-shield tracker walks every schema row at load and prints a loud warning for any path that doesn't resolve against defaults; the validation count is exposed for the test harness (§14A).

### 4.6 Two-phase init (only when needed)

For Tier 2 addons with ≥6 modules, **SHOULD** use a two-phase init pattern (as large UI suites do): an "initial" queue that runs before AceDB is ready (Compat shims, Constants), and a "regular" queue that runs after (`OnInitialize`/`OnEnable`).

### 4.7 Prototype registry (optional)

For Tier 2 addons where TOC ordering has been fragile, **MAY** use a lazy table cache (the pattern large boss-mods use for their module prototypes):

```lua
NS._prototypes = setmetatable({}, { __index = function(t, k) t[k] = {}; return t[k] end })
function NS:GetPrototype(name) return NS._prototypes[name] end
```

Producer files write methods onto `GetPrototype("Foo")`; consumers read methods off it. Either side can load first.

---

## 5. SavedVariables / AceDB

### 5.1 Structure

```lua
NS.defaults = {
  profile = { display = {...}, behavior = {...} },
  global  = { schemaVersion = 1, ignored = {} },
  char    = {},   -- only if genuinely per-character
}
local AceDB = LibStub("AceDB-3.0")
NS.db = AceDB:New("<Addon>DB", NS.defaults, true)   -- true = use current profile
```

- **MUST** keep one global namespace `<Addon>DB`.
- **MUST** declare `schemaVersion` in the global namespace and ship a migration function in `core/Database.lua`:

```lua
function NS:RunMigrations()
  local g = NS.db.global
  g.schemaVersion = g.schemaVersion or 1
  if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
end
```

- **SHOULD** allow the user to opt out via a soft-fallback path (an AceDB-missing shim, as the absorb-shield tracker ships). Not mandatory.

### 5.2 Defaults

- **MUST** declare in `defaults/Profile.lua` (Tier 2) or in `Settings.lua` (Tier 1).
- **MUST** be the **only** place a default value is hardcoded. Schema rows `default =` reference these constants if reused.

### 5.3 Per-zone profile trees (optional)

For party/group/raid/PvP context-aware addons, **SHOULD** consider a per-zone profile model: `profile.party.arena`, `profile.party.party`, `profile.party.raid`, each carrying full settings (the model used by party-cooldown trackers).

---

## 6. Options UI

### 6.1 Canonical pattern

Already converged across the collection; codify:

```lua
-- settings/Panel.lua
local categoryID
function NS.Panel:Register()          -- called EAGERLY at load (see below)
  if categoryID then return end
  local frame = CreateFrame("Frame")
  frame.OnCommit = function() end
  frame.OnDefault = function() NS.Schema:ResetAll() end
  frame.OnRefresh = function() end
  local category = Settings.RegisterCanvasLayoutCategory(frame, addonName)
  category.ID = addonName
  Settings.RegisterAddOnCategory(category)   -- entry now visible in the options list
  categoryID = category:GetID()
  frame:SetScript("OnShow", function() NS.Panel:BuildBody(frame) end) -- lazy body
end
```

- **MUST** use `Settings.RegisterCanvasLayoutCategory` for the entry point. **MUST NOT** use the deprecated `InterfaceOptions_AddCategory`.
- **MUST register the category eagerly at addon load** — in `OnInitialize`, or from a bootstrap frame firing on `PLAYER_LOGIN` / `ADDON_LOADED → Blizzard_Settings` — so the addon's entry is **always present** in the Blizzard options list, even before its panel body is built. **MUST NOT** defer the `Register*Category` calls to the first `/<slash> config` / panel-open (§6.9). Reference implementations (in the collection): the Tier-2 tracker registers from a bootstrap frame on `ADDON_LOADED(Blizzard_Settings)`/`PLAYER_LOGIN`; the loot-history browser registers in `OnInitialize`. Both are taint-free because they register **after** `Blizzard_Settings` is available and keep the body lazy.
- **MUST** render content with **raw AceGUI** inside the canvas. **MUST NOT** use AceConfigDialog for content. (Industry: the two largest boss-mod / aura frameworks use AceConfig at a scale that justifies the tax; the big UI-replacement and nameplate suites hand-roll. Ka0s sits in the AceGUI sweet spot.)
- **MUST** build the **body** lazily in first `OnShow`. (Universal Ka0s pattern; AceGUI lays out against the panel's current width, which is 0 before first show.)
- **MUST** wrap any panel-build that can run at file-load in `C_Timer.After(0, ...)` (the group-utility taint-fix pattern) — but this defers the *body*, never the category registration.
- The single-category snippet above is the minimum entry point; §6.5–6.8 extend it into the mandatory **landing-page + subcategory** structure, **two-column** body, and **section-header** styling that every Ka0s panel now shares.

### 6.2 Combat lockdown

- **MUST** check `InCombatLockdown()` before **opening** the options panel from slash; defer with `RegisterEvent("PLAYER_REGEN_ENABLED")` and one-shot replay. (This gates panel *open*, not category *registration*, which happens taint-free at load per §6.1.)
- **SHOULD** apply the same gate to any settings setter that creates/destroys frames.

### 6.3 Profiles sub-page

- **MAY** ship a Profiles sub-category using AceDBOptions-3.0 + AceConfigDialog-3.0. **If included**, vendor AceConfig in `libs/` like every other lib (§3.3).
- **SHOULD** be the **only** legitimate use of AceConfig in a Ka0s addon.

### 6.4 Lazy options loading (large addons)

- For addons with ≥5 options sub-panels or whose options code is large, **SHOULD** ship options as a sibling LoadOnDemand addon (`<Addon>_Options.toc` with `## LoadOnDemand: 1`). None of the current Ka0s addons need this.

### 6.5 Landing page + subcategories

Every Ka0s options panel **MUST** be built as a **parent canvas category = landing page** with one or more **canvas subcategories** for the actual settings (the first named "General"). Reference implementations (in the collection): the Tier-2 tracker's `settings/Panel.lua` and the loot-history browser's `settings/Panel.lua`.

```lua
local main = Settings.RegisterCanvasLayoutCategory(mainPanel, "Ka0s <Addon>")
Settings.RegisterAddOnCategory(main)
local sub  = Settings.RegisterCanvasLayoutSubcategory(main, generalPanel, "General")
```

- The **landing page** (parent panel) **MUST** render, top to bottom: the addon **logo**, a full-width **tagline** Label (`GameFontHighlight`), a **"Slash Commands"** section heading, then one Label per command generated from the addon's `COMMANDS` table (so the list stays in lockstep with `/<slash> help`). Command rows use `|cffffff00/<slash> <verb>|r  —  <desc>`.
- **Logo asset:** ship a **`.tga`** (or `.blp`) under **`media/logos/`** — WoW **cannot** load `.jpg`/`.png` textures at runtime. Reference it by absolute path `Interface\AddOns\<Folder>\media\logos\<name>.tga`, display at **300×300**; source art SHOULD be power-of-two (e.g. 512×512). Keep the original `.jpg`/`.png` beside it for editing.
- **Header (both parent and subcategory):** left-aligned title in `GameFontNormalHuge`, a gold `Options_HorizontalDivider` tinted to the title's colour, and (subcategories) a **Defaults** button top-right. Subcategory titles render as a breadcrumb **"Ka0s <Addon> ▸ <Page>"** with the arrow via `|A:common-icon-forwardarrow:16:16|a`.
- Bodies **MUST** build lazily in first `OnShow` (§6.1) — AceGUI lays out against the panel's current width, which is 0 before the panel is first shown.

### 6.6 Two-column layout (default)

Schema-driven panels **MUST** default to a **two-column grid**: pair consecutive schema rows into 50%/50% widgets (`widget:SetRelativeWidth(0.5)`) inside a full-width Flow `SimpleGroup`, with a small vertical spacer between rows.

```lua
-- pair rows; flush the row once it holds two widgets (or on a wide row / group change)
if not pendingRow then pendingRow = flowGroup() end
makeWidget(row, pendingRow, 0.5)
if #pendingRow.children >= 2 then flushRow() end
```

- A row that is intrinsically wide (a multi-check block, a long list) **MAY** set `wide = true` to break onto its own full-width line.
- The pairing is **schema-driven**: each row's `group` names its section (§6.7) and row order within a group drives the pairing — no per-panel layout code.
- A widget that **fills its cell edge-to-edge** — an action `Button`, e.g. the 50/50 pair at the foot of a group (*Reset position | Reset all settings*) — **MUST** inset to **`SetRelativeWidth(0.492)`** (constant `BUTTON_PAIR_REL`, §6.8), never a flush `0.5`. AceGUI's Flow layout spills the right cell ~2px past the content width, and because the scroll content fills the `ScrollFrame` clip rect exactly (§6.10), that spill — including the button's right border — is otherwise shaved off. Label-inset controls (dropdowns, sliders, checkboxes) are immune because their art sits inset from the cell edge; a cell-filling button is not. Centralise the inset in the shared button-pair maker so every panel inherits it — never hand-set `0.5` on a paired button.

### 6.7 Section headers

Group options under **section headers** rendered as an AceGUI **`Heading`** (a centred label flanked by horizontal dividers), font bumped to `GameFontNormalLarge`, with a small spacer above (except the first) and below.

```lua
local h = AceGUI:Create("Heading")
h:SetText(groupName); h:SetFullWidth(true)
h.label:SetFontObject(GameFontNormalLarge)
```

This is the same widget used for the landing page's "Slash Commands" divider, so headers read identically across the landing page and every subcategory.

### 6.8 Layout constants (exact values)

Every Ka0s panel **MUST** use these exact pixel/font values so all addons render identically. Define them as named constants (e.g. `Const.PANEL_*` in `core/Constants.lua`, or locals at the top of `settings/Panel.lua`) — never inline magic numbers.

**Header** — parent landing page *and* every subcategory:

| Constant | Value | Meaning |
|---|---|---|
| `PADDING_X` | **16** | left/right edge inset for header, divider, and body |
| `HEADER_TOP` | **20** | vertical inset of the title (and the Defaults button) from the panel top — ≈½ the `GameFontNormalHuge` glyph height |
| `HEADER_HEIGHT` | **54** | panel-top → divider distance; in lockstep with `HEADER_TOP` so the title-to-divider gap is fixed |
| `DEFAULTS_W` | **110** | Defaults button width (fits "Restore Defaults" en-US) |
| body top inset | **−(HEADER_HEIGHT + 8) = −62** | body frame `TOPLEFT` y |

- **Title FontString:** `GameFontNormalHuge`, anchored `TOPLEFT` at `(PADDING_X, −HEADER_TOP)`.
- **Divider:** `Options_HorizontalDivider` atlas, `TOPLEFT`/`TOPRIGHT` at `(±PADDING_X, −HEADER_HEIGHT)`, `SetVertexColor(titleFS:GetTextColor())` so it tracks the title gold.
- **Defaults button** (subcategories only): `TOPRIGHT` at `(−PADDING_X, −HEADER_TOP)`.
- **Subcategory title** = breadcrumb `Ka0s <Addon> |A:common-icon-forwardarrow:16:16|a <Page>`; the **parent page** shows the title alone.

**Section headers:**

| Constant | Value | Meaning |
|---|---|---|
| `SECTION_HEADING_H` | **26** | AceGUI `Heading` height |
| `SECTION_TOP_SPACER` | **10** | spacer above each section (skipped before the first) |
| `SECTION_BOTTOM_SPACER` | **6** | spacer between the heading and its first widget |

- Heading label font: `GameFontNormalLarge`.

**Two-column body:**

| Constant | Value | Meaning |
|---|---|---|
| column width | `SetRelativeWidth(0.5)` | each paired widget = half the row |
| `BUTTON_PAIR_REL` | **0.492** | per-button width of a 50/50 action-button pair — a hair under `0.5` so the right button clears the `ScrollFrame` clip (§6.6, §6.10) |
| `ROW_VSPACER` | **8** | spacer between rows |
| scroll inset `TOPLEFT` | `(PADDING_X − 4, −8)` | AceGUI `ScrollFrame` vs body |
| scroll inset `BOTTOMRIGHT` | `(−(PADDING_X + 12), 8)` | reserves the scrollbar gutter |

**Landing page:**

| Constant | Value | Meaning |
|---|---|---|
| `LOGO_SIZE` | **300** | logo display size (source art power-of-two, e.g. 512²) |
| `GAP_AFTER_LOGO` | **8** | spacer below the logo |
| `GAP_AFTER_DESC` | **12** | spacer below the tagline |
| `GAP_BELOW_HEADING` | **6** | spacer below the "Slash Commands" heading |

- Tagline Label font: `GameFontHighlight`, left-justified, full width.
- The "Slash Commands" divider is the same AceGUI `Heading` (height 26, `GameFontNormalLarge`).

**Font summary:** title `GameFontNormalHuge` · section/landing headings `GameFontNormalLarge` · tagline `GameFontHighlight` · widget labels + slash rows the AceGUI defaults.

### 6.9 Registration timing (anti-pattern)

- **MUST NOT** gate the settings-**category** registration behind a slash command, a first panel-open, or any user action. Deferring `Settings.RegisterCanvasLayoutCategory` / `RegisterAddOnCategory` until the user runs `/<slash> config` leaves the addon **missing from the options list** until they act — a real defect (a current Tier-1 group-utility addon does exactly this, deferring registration inside its `config` handler to avoid boot-time GameMenu taint). The taint-safe fix is **not** to defer registration but to register **after `Blizzard_Settings` is loaded** and keep the **body** lazy (§6.1) — the pattern both gold-standard addons use.

### 6.10 Scroll container

The two-column body (§6.6) renders inside a single AceGUI `ScrollFrame` per subcategory. Two rules keep every panel — short or long — rendering identically.

- **Always-visible scrollbar.** The body's `ScrollFrame` **MUST** keep its vertical scrollbar shown **even when the content fits without scrolling**: park the thumb at the top and disable interaction (grey it out) rather than hiding the bar. AceGUI's stock `FixScroll` auto-hides the bar when `viewheight < height`; rebind it to keep the bar shown and inert. This reserves a consistent right-edge gutter (§6.8, scroll inset `BOTTOMRIGHT`) so a short subcategory (e.g. *General*) and a long one (e.g. *Icons*) have the **same body width and right margin** — a panel that hides its bar on short pages and shows it on long ones jitters its content width between tabs. Reference implementation (in the collection): the Tier-2 tracker's always-show-scrollbar `FixScroll` rebind.
- **Clip-safe cell edges.** The scroll content frame fills the `ScrollFrame`'s clip rect exactly, so a widget whose art reaches the right edge of its cell is shaved by ~2px (AceGUI Flow spills the right cell past the content width). Cell-filling widgets — action buttons — therefore inset their relative width per §6.6 (`BUTTON_PAIR_REL`, §6.8); label-inset controls (dropdowns, sliders, checkboxes) are unaffected.

---

## 6A. Standalone windows / data browsers

§6 governs the **options** surface. An addon's own **main window** — a data browser, log, tracker, or dashboard — is a different surface with different rules. Reference implementation (in the collection): the standalone loot-history browser (a resizable, movable data-browser window with a tab strip and a scrolling record list).

- **MUST** be a plain **non-secure** `CreateFrame("Frame")` (movable/resizable) — **not** a Blizzard Settings canvas, **not** a secure/protected frame. A non-secure window touches no protected functions, so it needs **no combat-lockdown gate** and may open/refresh in combat. (Secure/action-button content is the exception and follows §9.2.)
- **MUST** register the window in `UISpecialFrames` so `Escape` closes it and it joins the standard close-stack.
- **MUST** persist window position and size in SavedVariables (e.g. `db.global.settings.window`), restored on open. **SHOULD** clamp to a readable minimum size and `SetClampedToScreen(true)`.
- **SHOULD** expose a scale setting (e.g. `windowScale`) applied via `frame:SetScale`.
- **SHOULD** use a tab strip with **lazy per-tab content build** — build each tab's body on first show, not up front.
- **SHOULD** centralize the window's look in a single `SKIN` table + one `ApplySkin(frame)` re-skin seam, built from **stock Blizzard textures** (no shipped art), so a future settings-driven re-skin has one touch point. The debug console (§12) reuses this same seam.
- **MUST** pool rows for any high-churn list inside the window (§9.6) — never one frame per record.
- **SHOULD** provide explicit window verbs (`show` / `hide` / `toggle`) and/or a minimap/LDB launcher for display; bare `/<slash>` still prints help (§7.4).

---

## 6B. Preview / test mode

Addons whose main job is a **positionable or persistent on-screen display** (a bar, an icon grid, a nameplate widget, a tracker frame) **SHOULD** ship a **preview mode** (a.k.a. test / demo mode) that renders **representative placeholder data**, so the user can see and position the display without waiting for a real in-game event to populate it.

Reference implementation (in the collection): the Tier-2 tracker's cast bar shows a placeholder preview — a question-mark icon, a fake spell name, a `0.0 / 0.0` timer, and a bar filled to mid — **while the frame is unlocked**, so the user can drag it into place against realistic content.

- **SHOULD** trigger the preview automatically while the display is **unlocked** (drag/reposition mode), and/or via an explicit `/<slash> preview` (a.k.a. `test`) verb in the `COMMANDS` table (§7.3).
- **SHOULD** feed the preview through the **same render path** as live data (placeholder values in, real widget out) so it exercises the real layout, not a separate mock.
- **MUST** clear the preview and return to live data when the display is re-locked or the preview verb is toggled off.
- Utility addons with no positionable display: **N/A**.

---

## 7. Slash commands

### 7.1 Registration

- **MUST** use AceConsole-3.0 `:RegisterChatCommand`. **MUST NOT** hand-roll `SLASH_*` globals.

```lua
addon:RegisterChatCommand("<slash>", "OnSlash")       -- 2-3 char primary verb
addon:RegisterChatCommand("<addonname>", "OnSlash")   -- full lowercase name alias
```

### 7.2 Verb naming

- **MUST** use 2-3 lowercase chars as the primary verb. **SHOULD** also register the full lowercase addon name as an alias.
- **MUST NOT** collide with existing well-known addon slashes.

### 7.3 Dispatch

- **MUST** be schema-driven. Built-in subcommands `get`, `set`, `list`, `reset`, `resetall` walk `NS.Schema`. Custom verbs live in an ordered table:

```lua
NS.COMMANDS = {
  { name = "get",     desc = "Get a setting value",   fn = function(arg) ... end },
  { name = "set",     desc = "Set a setting value",   fn = function(arg) ... end },
  { name = "list",    desc = "List all settings",     fn = function() ... end },
  { name = "reset",   desc = "Reset one setting",     fn = function(arg) ... end },
  { name = "resetall", desc = "Reset all to defaults", fn = function() ... end },
  { name = "config",  desc = "Open options panel",    fn = function() NS.Panel:Open() end },
  { name = "preview", desc = "Toggle preview mode",   fn = function() ... end },   -- if §6B applies
  { name = "debug",   desc = "Window; 'on'/'off' set logging", fn = function(rest) ... end },  -- §12 (on|off|toggle)
}
```

- **MUST** render `/<slash>` (no args) as the help output, generated from this table — no hand-maintained help string. (Browser-first addons **MAY** map bare `/<slash>` to their main window instead — a documented deviation — but `/<slash> help` MUST still print the index; see §7.4.)
- **MUST NOT** use `if arg == "foo" then elseif arg == "bar" then` chains.

### 7.4 Help output & chat tag

Reference implementations (in the collection): the Tier-2 tracker's `printHelp` and the loot-history browser's `settings/Slash.lua`.

- Every line the addon prints to chat **MUST** carry a short **bracketed tag** — the addon's initials in `[...]`, wrapped in one colour code — exposed as a **single shared constant** (`NS.PREFIX`) so every module prints identically. Format example: `|cff00ffff[XY]|r` (initials `XY` in a single colour code). **MUST NOT** hand-write `"|cff…" .. addonName .. "|r"` per call site.
- The `help` index (and the fallback for an unknown verb) **MUST** be generated from `NS.COMMANDS`:
  - **Header:** `<tag> v<version> slash commands (/<alias> is an alias for /<slash>):`
  - **One row per command:** `<tag> |cffffff00/<slash> <name>|r — |cffffffff<desc>|r` — gold command, em-dash (`—`), white description.
- An **unknown verb MUST** print `unknown command '<verb>'` and then the help index — never silently no-op.
- Dispatch **MUST** lower-case only the verb and preserve case in the remainder, so schema paths survive `/<slash> set <path> <value>`.

```lua
function Sl:PrintHelp()
  print(NS.PREFIX .. " v" .. NS.version ..
    " slash commands (|cffffff00/<alias>|r is an alias for |cffffff00/<slash>|r):")
  for _, cmd in ipairs(NS.COMMANDS) do
    print(NS.PREFIX .. (" |cffffff00/<slash> %s|r — |cffffffff%s|r"):format(cmd.name, cmd.desc))
  end
end
```

---

## 8. Localization

### 8.1 Module shape

```lua
-- locales/enUS.lua  (loads always)
local addonName, NS = ...
NS.L = setmetatable({}, { __index = function(_, k) return k end })
local L = NS.L
L["Scale"] = "Scale"
L["Reset all settings to defaults?"] = "Reset all settings to defaults?"
```

```lua
-- locales/deDE.lua (locale-gated)
if GetLocale() ~= "deDE" then return end
local addonName, NS = ...
local L = NS.L
L["Scale"] = "Skalierung"
```

- **MUST** export `NS.L` with a metatable that returns the key on miss. Replaces AceLocale strict mode (which hard-errors on missing keys) and is industry-aligned (the major aura framework, party-cooldown trackers, modular QoL addons, and the collection all do this).
- **MAY** use AceLocale-3.0 in non-strict mode if you prefer it. Strict mode is forbidden.
- **MUST** gate non-enUS files with `if GetLocale() ~= "<locale>" then return end` at top of file. (Loading every locale for every player — a QoL-addon anti-pattern — is wasteful.)
- **SHOULD** put derived-key aliases in `locales/PostLoad.lua`: `L["Use original"] = L["Original"]`. Translators don't duplicate work.

### 8.2 Source-of-truth keys

- **MUST** use the English string itself as the key. Reasons: missing-key fallback yields English; keys are self-documenting; no separate string-table maintenance.
- **SHOULD NOT** use opaque IDs like `L.STR_42`.

### 8.3 Coverage

- **MUST** at minimum ship `enUS.lua`. Any additional locale is opt-in.
- **MUST NOT** rely on Blizzard `_G` strings as a substitute for a locale module. (Leaning on `_G` strings is acceptable for a tiny utility addon but it should still ship a locale module shell.)

---

## 9. Events, frames, taint

### 9.1 Event registration

- **MUST** use AceEvent-3.0 (`addon:RegisterEvent("X")`). **MUST NOT** create per-module frames just for events (boss-mod-scale hand-rolling is overkill below 1000 events/min).
- **SHOULD** centralize CLEU dispatch on a single shared frame with a spellID hash table when CLEU is the hot path (the boss-mod `mod:Log(subevent, fn, spellId)` model). **MUST NOT** subscribe N modules separately to CLEU.
- **MAY** use AceEvent's `:RegisterMessage`/`:SendMessage` for the closed message bus (§4.4).

### 9.2 Combat lockdown

- **MUST** guard secure-environment writes (frame `:SetAttribute`, secure-template parents, focus-frame mutations) with `InCombatLockdown()` returning early and replaying on `PLAYER_REGEN_ENABLED`.
- Reference implementation (in the collection): the group-composition utility uses a 3-layer cascade (config open → settings register → frame show), each re-checking combat; the chat-formatting addon combat-gates its config open.

### 9.3 Taint-replacing Blizzard UI

If your addon replaces a Blizzard frame (bag UI, bag manager, group finder window):

- **MUST** `hooksecurefunc` on Toggle*. **MUST NOT** assign a replacement function to `_G.ToggleX`.
- **SHOULD** guard hooks with `debugstack():find("Manager")` to ignore Blizzard-internal recursion.
- **MUST** reparent hidden Blizzard frames to a hidden parent — **MUST NOT** call `:Hide()` on them (causes taint propagation).
- **MUST NOT** instantiate `MoneyFrame` directly; use `TooltipDataProcessor.AddLinePreCall` + `GetMoneyString()`.
- **SHOULD** ship a `core/TaintLess.xml` as the first XML include if XML is used.

### 9.4 Macro / protected-action APIs

If your addon writes macros or calls protected APIs (`CreateMacro`, `EditMacro`, `RunMacro`, `EditMacroByID`):

- **MUST** firewall: a single module is the **only** caller of those APIs. Reference implementation (in the collection): the consumables & macro manager routes every `CreateMacro`/`EditMacro` call through one `MacroManager` module, which is the sole caller. Audit this at lint time.
- **MUST NOT** call protected APIs from event handlers that can fire in combat.

### 9.5 Chat-frame manipulation

If your addon formats chat:

- **SHOULD** prefer overriding `_G[GLOBALSTRING]` over `ChatFrame_AddMessageEventFilter` and `hooksecurefunc(ChatFrame, "AddMessage")`. Reference implementation (in the collection): the chat-formatting addon overrides the relevant global strings rather than hooking chat events, so it is architecturally taint-free.
- **MUST NOT** replace `AddMessage` outright — breaks every other chat addon.
- **MUST** make cross-registration ordering deterministic (a `pairs()` over filters is order-nondeterministic). Use an ordered table.

### 9.6 Frame creation

- **MUST** prefer Lua `CreateFrame` over XML for non-templated frames in Tier 1 addons.
- **MAY** use XML for declarative groups of similar widgets in Tier 2 (the manifest-XML pattern used by auction-house addons).
- **MUST** use object pooling for any high-churn UI (≥10 dynamic frames): an ~80-line object-pool mixin (Acquire/Release/HideAll), the pattern party-cooldown trackers use so roster churn becomes free.

### 9.7 Hot-path upvalue cache

For per-frame loops:

```lua
-- module locals refreshed on settings change
local DB_AURA_ENABLED, DB_USE_RANGE = false, false
function M:RefreshUpvalues()
  DB_AURA_ENABLED = NS.db.profile.auraEnabled
  DB_USE_RANGE   = NS.db.profile.useRange
end
-- in OnUpdate / OnEvent
if DB_AURA_ENABLED then ... end
```

- **MUST** call `M:RefreshUpvalues()` at end of every settings setter that touches values used in the hot path. (The DB-upvalue-refresh pattern nameplate frameworks use.)

---

## 10. Public API surface

If your addon exposes any function or data for third-party consumption:

- **MUST** version-namespace it: `NS.API = NS.API or {}; NS.API.v1 = {...}`. Public consumers reference `MyAddon.API.v1.SomeFunction`.
- **MUST** publish via `_G[addonName] = NS.API` (only the API surface; not the whole NS).
- **MUST** document the v1 contract in `docs/ARCHITECTURE.md` and treat it as semver-stable.
- **SHOULD NOT** break v1 even if the implementation changes; introduce v2 as a sibling table.
- Ka0s-internal addons currently expose nothing; this rule is for future addons that other addons anchor to, or that expose hooks.

---

## 11. Compat / deprecated APIs

Every addon **MUST** ship a `Compat.lua` (Tier 1) or `core/Compat.lua` (Tier 2). It is the **only** file that calls deprecated APIs and exposes shimmed versions. Retail-only, so it shims across **Retail patch** differences — not across game flavors.

```lua
local addonName, NS = ...
NS.Compat = NS.Compat or {}
local Compat = NS.Compat

-- Spell info: post-11.x consolidation
function Compat.GetSpellInfo(id)
  if C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(id)
    if info then return info.name, nil, info.iconID end
  end
  return GetSpellInfo and GetSpellInfo(id)
end

-- Specialization: post-11.x deprecation
function Compat.GetSpecialization()
  return (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()) or GetSpecialization()
end
```

- **MUST** route every deprecated-API call through `Compat`. Direct calls to deprecated spec/spell APIs scattered through feature modules are a violation — a current Tier-2 addon still calls `GetSpecialization`/`GetSpecializationInfo` directly in two modules and must be migrated.
- **MUST NOT** branch on `WOW_PROJECT_ID` for game flavor (Retail only). Any Retail-patch version check that is genuinely needed lives here behind a named flag.

---

## 12. Debug / logging — on-screen debug console

Every addon **MUST** ship a debug seam. Debug output **MUST** route to a **dedicated on-screen debug console styled like the addon's own main window** — **not** the default chat frame. Reference implementation (in the collection): the loot-history browser's debug console (`modules/DebugLog.lua`).

### 12.1 Console window

- A standalone `BackdropTemplate` frame (e.g. `<Addon>DebugWindow`) parented to `UIParent` on **`DIALOG`** strata so it sits **above** the addon's main window, with a draggable title bar (`"<Addon> — Debug"`), a 1px divider, and a thin close glyph.
- **Default size `700 × 344`** — the reference width, wide enough that tagged lines rarely wrap. Movable, clamped to screen, registered in `UISpecialFrames` (ESC closes).
- **Reuses the addon's `SKIN`/`ApplySkin` seam** (§6A) so it matches the main window.
- The log surface is a `ScrollingMessageFrame` with `SetMaxLines(500)`, mouse-wheel scroll, `SetJustifyH("LEFT")`, fading off.

### 12.2 Monospace font (shipped)

- The console log **MUST** render in a **monospace** font so timestamps and tags line up. The addon **SHOULD ship** a monospace TTF under `media/fonts/` (§1.4) — e.g. **JetBrains Mono** (OFL) — **vendored with its license file**, rather than depending on a user-installed font. Register it with LibSharedMedia-3.0 at load (`LSM:Register("font", "<Name>", path)`) and expose the path as a constant (e.g. `NS.Constants.FONT_MONO`).
- Apply it with `SetFont(NS.Constants.FONT_MONO, 10, "")` — **10pt is the reference size** — to **both** the log and the Copy `EditBox` (so the copied view matches the console).

### 12.3 Line format — timestamped, tagged, coloured

Each line **MUST** follow `<HH:MM:SS> | [<Tag>] <content>`:

- The **tag** is a single short word, rendered **verbatim** (no padding, no truncation), naming what the line is about — `Loot`, `Cast`, `Attr`, `Open`, `Mail`, … The set is **open**; modules add tags as needed.
- In the console, the **timestamp is muted steel-blue (`6f8faf`)** and the **`[tag]` is muted tan/gold (`c9a66b`)**; the `|` separator and the content stay the frame's **default colour (white)**. (`||` renders one literal pipe inside a colour-coded string.)
- The plain-text **Copy buffer mirrors the same line with no colour codes**, so copied logs paste clean.
- Provide **two pure formatters** (frame-free, unit-tested) so the coloured string can't drift from the plain one:

```lua
function DebugLog.FormatPlain(ts, tag, msg)      -- clean text, for the Copy buffer
  return ("%s | [%s] %s"):format(tostring(ts), tostring(tag or ""), tostring(msg))
end
function DebugLog.FormatColored(ts, tag, msg)    -- console view
  return ("|cff6f8faf%s|r || |cffc9a66b[%s]|r %s"):format(
    tostring(ts), tostring(tag or ""), tostring(msg))
end
```

### 12.4 The sink

```lua
function NS.Debug(tag, fmt, ...)
  if not (NS.State and NS.State.debug) then return end   -- gated; zero-alloc when off
  local msg = (select("#", ...) > 0) and string.format(fmt, ...) or fmt
  NS.DebugLog:Add(tag, msg)   -- append to the console, NOT print() to chat
end
```

- **MUST** be zero-allocation when off (the gate is the first line; no `string.format`, concat, or table build before it).
- The **tag is the first argument** so every call site self-documents its category: `NS.Debug("Loot", "%s x%d", name, qty)`.
- **MAY** support structured dump verbs (`/<slash> debug <topic>`) for large addons.

### 12.5 Enabled-state — session-only, decoupled from the window

The enabled-state (`NS.State.debug`) is a **runtime flag, independent of the console window's visibility**:

- **MUST** be **session-only**: default **off**, held in `NS.State.debug` (**never** in SavedVariables), and **reset to off on every `/reload` and fresh login**. *(This replaces the pre-v2.3 "SHOULD persist in SV" guidance — a persisted debug flag too easily gets left on. Persisting it is now the documented deviation, not the default.)*
- Logging and the window are **independent** — capture runs even when the console is closed, so a bug can be reproduced first and the log opened after.
- Slash (§7): `/<slash> debug` **toggles the window only** (state untouched); `/<slash> debug on` and `/<slash> debug off` set the flag. Each state change prints a `NS.PREFIX`-tagged chat ack.
- The title bar carries a **state toggle** on the left, styled like the Clear/Copy text buttons: **`Debug: ON`** in green when on, **`Debug: OFF`** in red when off. Clicking it flips the flag and the label re-renders on every state change.
- Route **all** state changes through one `DebugLog:SetEnabled(on)` seam so the slash command and the header toggle can't diverge (single write path: set flag → refresh header → print ack).

### 12.6 Copy / Clear

- **Clear** wipes both the visible log and the Copy buffer.
- **Copy** opens a read-through multiline `EditBox` pre-filled with the plain buffer and auto-highlighted for `Ctrl+C`; it uses the same monospace font. WoW exposes **no clipboard API** — the user's `Ctrl+C` inside an `EditBox` is the only copy path, so a button alone cannot write the OS clipboard. *(The colour-vs-clean-copy split is deliberate: the `ScrollingMessageFrame` gives the coloured live view, the `EditBox` gives code-free copies — one widget cannot do both, since selecting colour-coded text copies its `|c…|r` escapes.)*

### 12.7 Fallback

- **Tier-1 utility addons with no on-screen window MAY** fall back to `NS.PREFIX`-tagged chat output instead of a console; any addon that *has* a main window (§6A) **MUST** use the console.

Note: user-facing chat messages (help index, command acks, errors) still `print()` to chat with `NS.PREFIX` (§7.4) — that ordinary chat seam is separate from the debug console.

---

## 13. Packaging (`.pkgmeta`)

Every addon **MUST** ship `.pkgmeta` at the root for packager configuration (package name, ignore lists). Libraries are **vendored and committed** (§3.3), so `.pkgmeta` **MUST NOT** contain an `externals:` block.

Minimum template:

```yaml
package-as: <Addon>

# Libraries are vendored in libs/ and committed to git — NOT fetched as externals.

ignore:
  - .luacheckrc
  - .gitignore
  - reviews
  - docs
  - tests
  - _dev
  - "*.bak"
```

- **MUST** vendor and commit every library the addon uses (§3.3). **MUST NOT** declare `externals:`; **MUST** commit `libs/` to git as part of the addon.
- **MUST** ignore `reviews/`, `_dev/`, `docs/`, `tests/`, lockfiles in the package (dev-only; not shipped to players).
- **MUST NOT** use `enable-toc-creation` flavor fan-out — the addon is Retail-only with a single TOC (§2.3).
- **MAY** use `move-folders:` only when the repo is a monorepo for multiple addons (out of scope today).

CI (GitHub Actions) is **out of scope** for this standard per Ka0s decision. **Local** testing and linting are **in scope** — see §14A.

---

## 14. Lint (`.luacheckrc`)

Every addon **MUST** ship `.luacheckrc` at the root. Base it on the common WoW-addon `luacheck` config:

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "reviews/", "_dev/", "tests/" }
ignore = {
  "212/self",   -- unused argument self
  "212/event",  -- unused argument event
}
read_globals = {
  "_G", "LibStub", "CreateFrame", "GetTime", "UnitName", "UnitGUID",
  "GetSpellInfo", "C_Spell", "C_SpecializationInfo", "GetSpecialization",
  "InCombatLockdown", "PlaySound", "GetLocale",
  "Settings", "InterfaceOptionsFrame_OpenToCategory",
  "C_Timer", "hooksecurefunc",
  "CreateColor",
  -- per-addon globals are added per-repo
}
globals = {
  "<Addon>DB",        -- per-repo SavedVariables write target
}
```

- **MUST** run `luacheck .` with **0 errors** before every commit (§14A). `tests/` is excluded from lint (the harness is exercised by running it, not by linting it).
- **MUST NOT** add `globals` (write access) without a comment justifying it.

---

## 14A. Automated tests & local build toolchain

Every addon **MUST** ship an automated, **headless** test harness and be developed **test-first (TDD)**. Reference implementation (in the collection): the loot-history browser's `tests/` — a plain-Lua-5.1 harness (busted-compatible in spirit, no external framework required).

### 14A.1 Harness shape

```
tests/
  run.lua            -- runner + micro-framework; loads sources + suites, exits non-zero on any failure
  loader.lua         -- headless source loader
  wow_mock.lua       -- WoW API mock builder
  test_<module>.lua  -- one suite per module (test_util.lua, test_database.lua, ...)
```

- **`run.lua`** defines a tiny framework — `test(name, fn)`, `assertEqual`, `assertTrue`, `assertFalse` — and exposes them (plus `NS` and the mocks) to suites via a single global table (e.g. `_G.<ADDON>_TEST`). It builds the addon environment once by loading every source in TOC order, calls `NS:InitDB()`, then `dofile`s each `test_*.lua`, runs each test under `pcall`, prints `PASS`/`FAIL`, and `os.exit(failed == 0 and 0 or 1)`.
- **`loader.lua`** loads each source with `loadfile`, then `setfenv(chunk, makeEnv(mocks))` so WoW globals resolve to the mock table first (falling back to real `_G`), and calls each chunk as `chunk(addonName, NS)` — reproducing the `local addonName, NS = ...` header.
- **`wow_mock.lua`** returns a **builder** (a fresh env per run). It stubs time/player/world APIs and a **universal self-returning no-op frame** (`setmetatable(f, { __index = function() return function() return f end end })`), plus `CreateFrame`, `UIParent`, `Settings.*`, and `LibStub` with `AceDB-3.0`/`AceAddon-3.0` fakes.
- Suites are plain: `local T = _G.<ADDON>_TEST; local NS = T.NS; local test, assertEqual = T.test, T.assertEqual` then `test("...", function() assertEqual(...) end)`.

### 14A.2 Commands

- **Run unit tests:** `lua tests/run.lua` from the repo root (exits non-zero on failure).
- **Lint:** `luacheck .` — **0 errors** (config in `.luacheckrc`, §14).
- **Syntax-check one file:** `luac -p path/to/file.lua`.

### 14A.3 Local toolchain

WoW runs **Lua 5.1**, so the harness targets 5.1. Install locally:

```sh
sudo apt-get update && sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck
```

### 14A.4 TDD & the commit gate

- **MUST** be test-first: write or extend a **failing** test that pins the intended behavior, then implement until it passes.
- **MUST**, before **every** commit, run **`lua tests/run.lua`** (all suites green) **and** **`luacheck .`** (0 errors). A commit with red tests or lint errors is forbidden.
- **MUST** add/extend a suite whenever a behavior changes — no logic change lands without a covering test.
- Pure/testable logic (schema validation, data collection, attribution, migrations, formatting) **MUST** be exercised headlessly. Genuinely in-client behavior (frame rendering, taint) is covered by the in-game smoke tests (§16), which complement — not replace — the unit suites.

---

**Root of the repo** ships exactly three docs (plus `LICENSE`): a **full** `README.md`, a **stub** `CLAUDE.md`, and `LICENSE`. Everything else lives under `docs/`.

### 15.1 Root `README.md` — canonical structure

Every Ka0s `README.md` **MUST** follow one structure so all addons read identically. Reference implementation (in the collection): the Tier-2 modular tracker's README. Sections in **this exact order**:

1. **H1 title** — `# Ka0s <Name>`. **MUST**.
2. **Badge row** — in order: a **`[wow]`** interface badge (in lockstep with the TOC `## Interface:`, §2.3); a **published-version** badge (CurseForge/Wago) once published; a **`[license]`** MIT badge; and a badge/line linking the **Ka0s WoW Addon Standard** (<https://github.com/tusharsaxena/WowAddonStandards>). **MUST**.
3. **Logo** — the addon logo image. **MUST**.
4. **Description** — 1–2 paragraphs of what the addon does and why; **MAY** inline a short feature bullet list and a closing line on how to configure it (Blizzard Settings panel + `/<slash>`). **MUST**.
5. **`## Screenshots`** — captioned images of the addon and its settings sub-panels. **SHOULD** (**MUST** once published).
6. **`## Usage`** — **MUST**, with two subsections:
   - **`### Slash commands`** — one intro line (short + long slash form, and the `[XY]` chat prefix), then a **Command | Purpose** table generated from `NS.COMMANDS` so it stays in lockstep with `/<slash> help` (§7.4).
   - **`### Settings panel`** — a **Tab | Covers** table, one row per settings subcategory (§6.5).
7. **`## Critical settings`** — **SHOULD** for addons whose behavior hinges on a few key options; `###` subsections, each naming the option's setting path.
8. **`## FAQ`** — **SHOULD**; a **Question | Answer** table.
9. **`## Troubleshooting`** — **SHOULD**; a **Symptom | What to check** table.
10. **`## Issues and feature requests`** — **MUST**. A short paragraph pointing users to the addon's **GitHub issues** (`<repo>/issues`) as the **single source of truth for the backlog**, asking them to file there rather than in comments. (This is why a released addon ships no `TODO.md` — §15.4.)
11. **`## Testing`** — **MUST**. How to verify: the headless harness (`lua tests/run.lua`), lint (`luacheck .`), and the in-game smoke-test suite (link `docs/smoke-tests.md`), with a note to run it before tagging a release or after bumping `## Interface:` / refreshing libs (§14A, §16).
12. **`## Version History`** — **MUST**. A **Version | Date | Notes** table, most-recent first, last 5 entries.

- The optional sections (5, 7, 8, 9) are **SHOULD** — omit one only when it would be empty — but when present their **relative order MUST** be preserved.
- `wow-addon:normalize-readme` reshapes a README to this structure; `wow-addon:sync-docs` keeps the slash-command and version-history tables in lockstep with code.
- The README `[wow]` badge and the TOC `## Interface:` **MUST** show the same single number and move together (`wow-addon:bump-interface` / `version-bump`).

### 15.2 Root `CLAUDE.md` — stub

- **A STUB**: a short pointer that (a) names the tier, (b) states the addon adheres to the Ka0s WoW Addon Standard at <https://github.com/tusharsaxena/WowAddonStandards>, and (c) directs the reader into `docs/` for the full agent context. **MUST NOT** carry the full agent brief at root — that lives in `docs/`.

### 15.3 `docs/`

- `docs/ARCHITECTURE.md` — engineer context. Sections: Overview, Module Map, Settings Schema, Message Bus (named messages with sender/payload/consumers), Slash Commands (table from `NS.COMMANDS`), Event Subscriptions, Taint Notes, Known Limitations.
- The **full agent-context pack** (the detailed working notes the root `CLAUDE.md` points to).
- `docs/smoke-tests.md` (§16) and any planning / reference / design docs — **but no `TODO.md` once released** (§15.4).

### 15.4 No `TODO.md`

- A **released** addon **MUST NOT** ship a `TODO.md` anywhere (root or `docs/`). All bugs, enhancements, and outstanding work are tracked in the addon's **GitHub issues** — the single source of truth for the backlog, surfaced via the README's "Issues and feature requests" section (§15.1).
- **Exception:** an **unreleased, in-development** addon (before its first tagged/published release) **MAY** keep a `docs/TODO.md` as a scratch backlog **during the development phase only**. It **MUST** be deleted at (or before) the first release, with any remaining items migrated to GitHub issues.
- Rationale: two backlogs drift. A checked-in `TODO.md` competes with the issue tracker, goes stale, and hides work from anyone not reading the repo. GitHub issues are searchable, assignable, closable, and linkable from commits/PRs.

### 15.5 Keeping docs in sync

- **MUST** keep the doc set in sync with code. Drift is the #1 gripe surfaced in every `reviews/` folder. The `wow-addon:sync-docs` skill exists exactly for this; run it before every release.

---

## 16. Reviews / audit history

- **MUST** keep `reviews/<YYYY-MM-DD>/` folders for every audit. Five-artifact bundle: `01_FINDINGS.md`, `02_PROPOSED_CHANGES.md`, `03_SMOKE_TESTS.md`, `04_EXECUTION_PLAN.md`, `05_FINAL_SUMMARY.md`. The `wow-addon:review` skill produces this format.
- **SHOULD** retain every prior `reviews/` folder; they are the addon's institutional memory. (Reviews are **kept**, not deleted after commit.)
- `03_SMOKE_TESTS.md` catalogues **in-game** checks; they complement the headless unit suites (§14A), which cover testable logic.

---

## 17. Versioning & git workflow

- **MUST** use semver (`MAJOR.MINOR.PATCH`). MAJOR for backwards-incompatible API or SV changes; MINOR for new features; PATCH for fixes only.
- **MUST** bump in TOC `## Version:`, and in any code constants and README badges/Version History tables. The `wow-addon:version-bump` skill automates this.
- **MUST** bump the single TOC `## Interface:` (and the matching README `[wow]` badge) each Retail patch via `wow-addon:bump-interface` (§2.3).
- **MUST** increment `schemaVersion` (in defaults) whenever a SV migration is required.

**Git workflow**

- **MUST** work trunk-based: commit directly to the addon's default branch. Do **NOT** create feature/topic branches for routine work — branch **only** when the human explicitly asks (e.g. a risky spike needing isolation).
- **MUST NOT** push to a remote unless the human asks; the human pushes when ready.
- **MUST** commit only on a **green** unit of work — `lua tests/run.lua` passing and `luacheck .` clean (§14A) — not at every checkpoint.

---

## 18. Naming cheatsheet

| Thing | Convention | Example |
|---|---|---|
| Addon folder | PascalCase | `ExampleBar` |
| Subfolders | lowercase | `core/`, `modules/`, `libs/`, `tests/`, `docs/` |
| Media subfolders | lowercase, typed | `media/logos/`, `media/screenshots/` |
| Lua files | PascalCase.lua | `IconGrid.lua` |
| Test suites | `test_<module>.lua` | `test_database.lua` |
| Namespace upvalue | `NS` (private) | `local addonName, NS = ...` |
| Public API | `_G[addonName].API.v1` | `ExampleBar.API.v1` |
| SavedVariables | `<Addon>DB` | `ExampleBarDB` |
| Slash verbs | 2-3 lowercase | `/eb`, `/xb` |
| Bus messages | `Ka0s_<Addon>_<Event>` | `Ka0s_ExampleBar_RosterChanged` |
| Settings key | snake_case dotted path | `display.scale` |
| Locale keys | English source string | `L["Reset all settings"]` |
| Module table | `NS.<PascalCase>` | `NS.IconGrid` |

---

## 19. Anti-patterns (forbidden)

For quick reference, the rules above as a do-not list:

1. `_G[addonName] = {}` (global namespace) — use private `NS`.
2. AceLocale strict mode — use metatable fallback.
3. Hand-rolled options framework — use Settings + AceGUI.
4. AceConfig for non-Profiles content — use raw AceGUI.
5. `SLASH_*` direct registration — use AceConsole.
6. `if cmd == "x" then elseif ...` slash dispatcher — use schema + COMMANDS table.
7. `.pkgmeta` `externals:` for libraries — vendor and commit all libs instead (§3.3).
8. Forking Ace libs — use `RegisterWidgetType` extension instead.
9. `if WOW_PROJECT_ID == ...` game-flavor branching — Retail only; route any Retail-patch check through Compat (§11).
10. Direct calls to deprecated APIs — route through Compat.
11. `:Hide()` on Blizzard frames you replace — reparent to hidden parent.
12. Replacing `AddMessage` — override globals or use AddMessageEventFilter.
13. Hard `## Dependencies:` (use OptionalDeps + soft fallback).
14. `## X-License: All Rights Reserved` — must be MIT.
15. Multi-flavor / Classic support (comma Interface lists, per-flavor TOCs, `_Classic` data splits, `enable-toc-creation` fan-out) — Retail only, single Interface line (§2.3).
16. Files >1500 LOC — peel.
17. Multiple senders for the same bus message.
18. Debug output to the chat frame when the addon has a main window — use the on-screen debug console (§12).
19. Cross-module direct table access — use the bus.
20. User-supplied Lua execution — banned at the standard level (no Ka0s addon needs it).
21. Creating a feature/topic branch without an explicit request — work trunk-based (§17).
22. Deferring settings-**category** registration until first `/config`/panel-open — register the category eagerly at load; only the body is lazy (§6.1, §6.9).
23. Committing with red `lua tests/run.lua` or non-clean `luacheck .` — the commit gate is green tests + clean lint (§14A).
24. No `tests/` harness, or a logic change with no covering test — TDD is mandatory (§14A).
25. Loose files directly in `media/` — use typed subfolders (§1.4).
26. Full agent brief in the root `CLAUDE.md` — root `CLAUDE.md` is a stub; the brief lives in `docs/` (§15).
27. A checked-in `TODO.md` in a **released** addon — track the backlog in GitHub issues; a `TODO.md` is allowed only in an unreleased, in-development addon during its development phase (§15.4).
28. Non-canonical `README.md` section order, or a TOC that departs from the required field order / file-listing structure — follow §15.1 and §2.1/§2.5.
29. Hard-depending on an addon suite or standalone addon (ElvUI/EllesmereUI/DBM/WeakAuras/…), or reading its media/API/frames/SavedVariables — addons are fully self-contained; suite integration is optional, presence-guarded, and degrades gracefully (§3.6).
30. Hiding the options-panel scrollbar on short pages (bar shown only when content overflows) — the body `ScrollFrame` keeps its bar always shown and inert so body width is identical across subcategories (§6.10).
31. A 50/50 paired action button left at `SetRelativeWidth(0.5)` — cell-filling buttons inset to `BUTTON_PAIR_REL` (0.492) so the right button clears the `ScrollFrame` clip (§6.6, §6.8, §6.10).

---

## 20. Open evolutions

Items recorded for future versions of this standard:

- **Ka0s-Core sibling addon.** Long-term: extract Schema runtime, AceGUI panel scaffold, slash dispatcher, Compat templates, and the debug-console + test-harness scaffolding into a single `Ka0s-Core` addon (the shared-engine model bag-replacement addons use). Out of scope for now.
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- **Shared test scaffolding.** A copyable `tests/` skeleton (runner + WoW mocks) so new addons inherit the harness.
- **Multi-zone profile model adoption** for group-context addons.
- **Object pool standard** packaged as a copyable micro-lib.

---

**End of standard. Authoritative as of 2026-07-12. Bump on amendment.**
