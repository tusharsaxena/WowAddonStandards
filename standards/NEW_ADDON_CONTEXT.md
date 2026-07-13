# New Ka0s Addon — Context Pack (v1.4.0, 2026-07-13)

**Drop this file's *contents* into the new addon's `docs/` as the full agent context, and leave a short `CLAUDE.md` stub at the addon root that points to it (documentation).** Self-contained — no external lookups required for an LLM or new contributor to scaffold a fully standards-compliant addon.

Authoritative reference: `WowAddonStandards/standards/STANDARDS.md`. This document is its operational distillation. Every Ka0s addon is built to the standard and references it: <https://github.com/tusharsaxena/WowAddonStandards>.

**Scope:** Retail (Mainline) only.

---

## Kickstart walkthrough

The ordered process for starting a new Ka0s addon that is **born compliant** with the current
standard. Steps run in the **new addon's repo** unless marked *[standards repo]*.

1. **Scaffold.** Run the `wow-addon:new-addon` skill (Ace3 stack, AceDB saved variables, modular
   folder layout, MIT license, AceConsole slash command). This lays down the skeleton the rest of this
   pack fills in.
2. **Drop in this pack.** Put the contents of this file into the new addon's `docs/` as the full agent
   context, and leave a short root `CLAUDE.md` stub pointing to it (documentation), so every agent and
   contributor has the full standards brief with no external lookups.
3. **Pick a tier and lay out files.** Tier 1 (flat, ≤8 files) or Tier 2 (modular) — see *Pick a tier*
   below. Copy the vendored `libs/` set you actually `LibStub()` from an existing Ka0s addon so
   versions stay consistent.
4. **Fill in the starters.** Work through the *Starter snippets* (TOC, entry, `Compat`, `Locale`,
   `Database`, `Settings`, debug console, tests, message bus, `.luacheckrc`, `.pkgmeta`) and the
   *Hard rules cheat sheet* below. When stuck, reproduce the described patterns in *Patterns to
   reproduce*.
5. **Write tests first.** Stand up `tests/` (testing) and drive each behavior test-first.
6. **Check Definition of Done.** Walk the checklist at the bottom before tagging `v0.1.0`.
7. **Register in the roster.** *[standards repo]* Add the addon's row to
   `WowAddonStandards/standards/ADDONS.md`. This puts it in scope for the next standards refresh — it
   is the only edit needed to bring a new addon into the collection.

Then keep it compliant over time with the `wow-addon:` skills listed at the end of this file
(`review`, `sync-docs`, `version-bump`, …) and re-audit it as part of the collection.

---

## Identity

- **Author:** add1kted2ka0s (Ka0s)
- **License:** MIT (always; no exceptions)
- **Substrate:** Ace3
- **Scope:** Retail only — single latest-Retail `## Interface:` line
- **TOC `Title` prefix:** `Ka0s <Human Name>`
- **SavedVariables:** `<Addon>DB`
- **Slash:** 2-3 lowercase chars
- **Folder name:** PascalCase = TOC Title's CamelCase form (minus `Ka0s `)
- **Standard:** built to & references <https://github.com/tusharsaxena/WowAddonStandards>

## Pick a tier

- **Tier 1 (flat, ≤8 source files)** — utility addons. Reference: a small flat utility addon (a few source files, one Settings module, no `core/`/`modules/` split).
- **Tier 2 (modular)** — multi-feature addons. Reference: the collection's Tier-2 modular tracker (`core/`, `modules/`, `defaults/`, `settings/`, `locales/`, a closed message bus).

If unsure, start Tier 1; promote when file count would exceed 8. Tier 1 → Tier 2 promotion is mechanical (move files into `core/` `modules/` `defaults/` `settings/` `locales/`).

---

## Tier 1 starter tree

```
<Addon>/
  <Addon>.toc
  <Addon>.lua            -- entry, AceAddon registration, message bus init
  Settings.lua           -- Schema rows + AceDB defaults + panel registration + slash dispatch
  Locale.lua             -- L = setmetatable({}, {__index=function(_,k) return k end})
  Compat.lua             -- deprecated-API shims (start as empty scaffold)
  Database.lua           -- migration runner (start as empty function)
  README.md              -- FULL, user-facing (root)
  CLAUDE.md              -- STUB pointer into docs/ (root)
  LICENSE                -- MIT full text (root)
  .luacheckrc
  .pkgmeta
  libs/                  -- vendored, committed
  media/                 -- typed subfolders: logos/, screenshots/, ...
  tests/                 -- run.lua, loader.lua, wow_mock.lua, test_*.lua
  docs/                  -- agent-context.md (this pack) + ARCHITECTURE.md + smoke-tests.md; no TODO.md once released (documentation-§4)
    audits/<YYYY-MM-DD>/ -- retained audit-run history (audit-review-history)
    reviews/<YYYY-MM-DD>/-- retained code-review history (audit-review-history)
```

## Tier 2 starter tree

```
<Addon>/
  <Addon>.toc            -- single Interface line (latest Retail)
  core/
    Compat.lua           -- LOAD FIRST
    Constants.lua
    Namespace.lua
    State.lua
    Util.lua
    <Addon>.lua          -- AceAddon registration; promotes NS to AceAddon
    Database.lua         -- AceDB + migration
  defaults/
    Profile.lua
    Global.lua           -- only if needed
  locales/
    enUS.lua             -- canonical
    PostLoad.lua         -- derived-key aliases
  settings/
    Schema.lua
    Panel.lua
    Slash.lua
  modules/
    <Feature>.lua
  media/                 -- typed subfolders (logos/, screenshots/, ...)
  libs/                  -- vendored, committed
  tests/                 -- run.lua, loader.lua, wow_mock.lua, test_*.lua
  docs/                  -- agent-context.md, ARCHITECTURE.md, smoke-tests.md, planning; no TODO.md once released (documentation-§4)
    audits/<YYYY-MM-DD>/ -- retained audit-run history (audit-review-history)
    reviews/<YYYY-MM-DD>/-- retained code-review history (audit-review-history)
  README.md  (root, full)   CLAUDE.md (root, stub)   LICENSE (root)
  .luacheckrc  .pkgmeta
```

---

## Starter snippets

### TOC

Fixed field order (toc-file-§1), then a blank line, then the file listing in commented sections (toc-file-§5):

```
## Interface: 120007
## Title: Ka0s <Name>
## Notes: <one-line description>
## Author: add1kted2ka0s
## Version: 0.1.0
## IconTexture: <path|fileID>
## SavedVariables: <Addon>DB
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: <Combat|Group|Auction|Chat|UI|Misc>
## X-License: MIT
## X-Standard: https://github.com/tusharsaxena/WowAddonStandards
## X-Curse-Project-ID: <id>
## X-Wago-ID: <id>

# Libraries (must load first) — vendored in libs/, .xml where the lib ships one, else .lua
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.xml
libs\AceAddon-3.0\AceAddon-3.0.xml
# ...(one line per lib you LibStub)

# Locales
locales\enUS.lua

# Tier 1: one # Addon section, files in dependency order
# (Tier 2: # Core / # Defaults / # Modules / # Settings sections instead — toc-file-§5)
Compat.lua
Locale.lua
<Addon>.lua
Database.lua
Settings.lua
```

The `## Interface:` is a **single** latest-Retail number (Retail only, toc-file-§3); bump it each patch with `wow-addon:bump-interface`, and keep the README `[wow]` badge in lockstep. Field order and section comments are fixed (toc-file-§1, toc-file-§5).

### `<Addon>.lua` (entry)

```lua
local addonName, NS = ...
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
NS.addon = addon

function addon:OnInitialize()
  NS:InitDB()            -- Database.lua
  NS:RunMigrations()     -- Database.lua
  NS.Settings:Register() -- EAGER settings-category registration (options-ui-§1) — always visible in options list
end

function addon:OnEnable()
  -- subscribe to events
  -- self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEnter")
end
```

### `Compat.lua`

```lua
local addonName, NS = ...
NS.Compat = NS.Compat or {}
local Compat = NS.Compat
-- Retail only: shims cross-patch API differences, NOT game flavors.

function Compat.GetSpellInfo(id)
  if C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(id)
    if info then return info.name, nil, info.iconID end
  end
  return GetSpellInfo and GetSpellInfo(id)
end

function Compat.GetSpecialization()
  return (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()) or GetSpecialization()
end
```

### `Locale.lua`

```lua
local addonName, NS = ...
NS.L = setmetatable({}, { __index = function(_, k) return k end })
-- For non-enUS locales, gate at top of file:
-- if GetLocale() ~= "deDE" then return end
-- local L = NS.L
-- L["Scale"] = "Skalierung"
```

### `Database.lua`

```lua
local addonName, NS = ...

NS.defaults = {
  profile = { -- defaults referenced by Schema rows
    -- NOTE: the debug flag is NOT here. It is session-only (NS.State.debug,
    -- default off, reset every /reload) and never persisted to SV (debug-logging-§5).
  },
  global = { schemaVersion = 1 },
}

function NS:InitDB()
  NS.db = LibStub("AceDB-3.0"):New(addonName .. "DB", NS.defaults, true)
end

function NS:RunMigrations()
  local g = NS.db.global
  g.schemaVersion = g.schemaVersion or 1
  -- if g.schemaVersion < 2 then ... ; g.schemaVersion = 2 end
end
```

### `Settings.lua`

```lua
local addonName, NS = ...
NS.Settings = NS.Settings or {}
local S = NS.Settings

-- Schema: one row per setting. Drives panel widget, slash dispatch, and reset.
S.Schema = {
  { path = "display.scale", default = 1.0, type = "number", min = 0.5, max = 2.0,
    label = "Scale", widget = "Slider",
    onChange = function(v) NS:OnScaleChanged(v) end },
}

-- Single write seam. Panel and slash both call this.
function S:Set(path, value)
  local row = S:FindRow(path)
  if not row then return false, "unknown path: " .. path end
  if row.validate and not row.validate(value) then return false, "invalid value" end
  S:WritePath(NS.db.profile, path, value)
  if row.onChange then row.onChange(value) end
  return true
end

-- AceConsole binding
local COMMANDS = {
  { name = "config", desc = "Open options", fn = function() S:Open() end },
  { name = "set",    desc = "Set a value",  fn = function(arg) S:CliSet(arg) end },
  { name = "get",    desc = "Get a value",  fn = function(arg) S:CliGet(arg) end },
  { name = "list",   desc = "List all",     fn = function() S:CliList() end },
  { name = "reset",  desc = "Reset one",    fn = function(arg) S:CliReset(arg) end },
  { name = "resetall", desc = "Reset all",  fn = function() S:CliResetAll() end },
  { name = "preview", desc = "Toggle preview", fn = function() NS:TogglePreview() end },  -- if preview-mode applies
  { name = "debug",  desc = "Window; 'on'/'off' set logging", fn = function(rest)  -- debug-logging (on|off|toggle)
      local a = rest and tostring(rest):lower():match("^%s*(%S*)") or ""
      if a == "on" then NS.DebugLog:SetEnabled(true)
      elseif a == "off" then NS.DebugLog:SetEnabled(false)
      else NS.DebugLog:Toggle() end   -- bare: toggle the WINDOW, state untouched
    end },
}
NS.COMMANDS = COMMANDS

function S:Register()
  NS.addon:RegisterChatCommand("<slash>", "OnSlash")     -- 2-3 char verb
  NS.addon:RegisterChatCommand("<addonname>", "OnSlash") -- full-name alias
  -- Register the Blizzard settings CATEGORY now (eager, options-ui-§1) so the entry is always visible.
  -- Build the panel BODY lazily on first OnShow.
end

function NS.addon:OnSlash(input)
  if input == nil or input == "" then return S:PrintHelp() end
  local verb, rest = input:match("^(%S+)%s*(.-)$")
  for _, cmd in ipairs(COMMANDS) do
    if cmd.name == verb:lower() then return cmd.fn(rest) end
  end
  print(NS.PREFIX .. " unknown command '" .. verb .. "'"); S:PrintHelp()
end
```

**Chat tag & CLI output (slash-commands-§4–§5).** `NS.PREFIX` is the mandatory **cyan** bracketed tag — `|cff00ffff[XY]|r` (initials `XY`; the cyan `00ffff` is required, not just an example) — exposed once and prepended to every chat line. `list`/`get`/`set` follow the canonical output shape in slash-commands-§5: `list` prints `Available settings:` then `  [page]` group headers then `    path = value` rows; `get`/`set` print the single-line `path = value` (echoing the *stored* value after a set). Values are **type-aware and unit-annotated** through one shared formatter — `<n> px`, `1.00x`, `true`/`false`, `{r, g, b, a}` — so `list` and `get`/`set` never diverge.

### Debug console (debug-logging)

Debug output routes to a **dedicated on-screen console styled like the main window**, not chat. Full reference: `STANDARDS.md debug-logging`. Minimal sink — note the **tag is the first argument**:

```lua
function NS.Debug(tag, fmt, ...)
  if not (NS.State and NS.State.debug) then return end   -- gated; zero-alloc when off
  local msg = (select("#", ...) > 0) and string.format(fmt, ...) or fmt
  NS.DebugLog:Add(tag, msg)   -- append to the console, NOT print() to chat
end
-- call site: NS.Debug("Loot", "%s x%d", name, qty)
```

**Secret-safe (events-frames-taint-§8) — mandatory if you ever log a combat value.** In combat, retail returns absorb/health/threat totals as opaque *secret* values that survive `tostring()` **and `..`** but raise in `table.concat`/`string.format`. An unguarded secret in a debug line crashes — and on a repeating ticker it freezes the feature until `/reload`. The `NS.PREFIX` printer (slash-commands-§4) and this sink MUST route args through one secret-safe stringifier whose detector probes `table.concat`, **not** `..`:

```lua
local function probeConcat(v) return table.concat({ v }) end
function NS.IsConcatSafe(v) return (pcall(probeConcat, v)) end     -- `..` would pass secrets through
function NS.SafeToString(v)
  if v == nil then return "nil" end
  if type(v) == "boolean" then return tostring(v) end
  if NS.IsConcatSafe(v) then return tostring(v) end
  return "<secret>"
end
-- For display, hand the raw secret to AbbreviateNumbers() / widget setters — never tonumber() or `<`.
```

The console: a `BackdropTemplate` frame (`<Addon>DebugWindow`) on `DIALOG` strata, **default size `700×344`**, draggable title bar, a `ScrollingMessageFrame` (`SetMaxLines(500)`) rendered in a **shipped monospace font** (`media/fonts/`, e.g. JetBrains Mono OFL, LSM-registered) at **10pt**. Lines follow `<HH:MM:SS> | [<Tag>] <content>` — timestamp coloured `6f8faf`, `[tag]` `c9a66b`, separator/content white; the plain **Copy buffer** mirrors the same line code-free (two pure formatters, `FormatPlain`/`FormatColored`). **Clear** + **Copy** (copy = read-through multiline `EditBox`, same font), registered in `UISpecialFrames`, reusing the addon's `SKIN`/`ApplySkin` seam (standalone-windows).

**Enabled-state is session-only and window-independent** (debug-logging-§5): `NS.State.debug`, default off, **never in SV**, reset every `/reload`. `/<slash> debug` toggles the *window* only; `/<slash> debug on|off` set the flag via a single `DebugLog:SetEnabled(on)` seam; a left-aligned title-bar toggle shows **`Debug: ON`** (green) / **`Debug: OFF`** (red) and flips the same flag. The `SetEnabled` seam **also appends a console line at both transitions** — `[Debug] logging enabled` / `[Debug] logging disabled` — via the raw `DebugLog:Add` (the disable line must land after the flag flips off, so it can't go through the gated `NS.Debug` sink). Tier-1 addons with no window MAY fall back to `NS.PREFIX`-tagged chat.

### Tests (`tests/`, testing)

Headless plain-Lua-5.1 harness. Run `lua tests/run.lua` from the repo root.

```
tests/
  run.lua            -- runner + micro-framework (test/assertEqual/assertTrue/assertFalse); exits non-zero on failure
  loader.lua         -- loadfile each source, setfenv(chunk, makeEnv(mocks)), chunk(addonName, NS), TOC order
  wow_mock.lua       -- WoW API mock builder: self-returning no-op frame; CreateFrame/UIParent/Settings/LibStub fakes
  test_<module>.lua  -- one suite per module
```

Suite shape:

```lua
local T = _G.MYADDON_TEST      -- run.lua exposes { NS, mocks, test, assertEqual, assertTrue, assertFalse }
local NS = T.NS
local test, assertEqual = T.test, T.assertEqual
test("Schema: every path resolves against defaults", function()
  assertEqual(NS.Schema:Validate(), 0)   -- 0 unresolved paths
end)
```

Local toolchain:

```sh
sudo apt-get update && sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck
```

### Message bus

```lua
-- Producer (pick exactly one; send on any embed — SendMessage fans out to all receivers)
NS.addon:SendMessage("Ka0s_<Addon>_RosterChanged", roster)

-- Consumer — MUST register on its OWN AceEvent target, never the shared bus-as-self:
-- CallbackHandler keys callbacks by (message, target), so two receivers sharing one object
-- clobber each other (last registrant wins, silently). See architecture-§4.
NS.<Module>.__ev = NS.NewBusTarget()   -- AceEvent:Embed({}); or an AceAddon module `self`
NS.<Module>.__ev:RegisterMessage("Ka0s_<Addon>_RosterChanged", function(_, roster) ... end)
```

### `.luacheckrc`

```lua
std = "lua51"
max_line_length = false
codes = true
exclude_files = { "libs/", "docs/audits/", "docs/reviews/", "_dev/", "tests/" }
ignore = { "212/self", "212/event" }
read_globals = {
  "_G", "LibStub", "CreateFrame", "GetTime", "UnitName", "UnitGUID",
  "GetSpellInfo", "C_Spell", "C_SpecializationInfo", "GetSpecialization",
  "InCombatLockdown", "PlaySound", "GetLocale", "C_Timer", "hooksecurefunc",
  "Settings", "CreateColor",
}
globals = {
  "<Addon>DB",  -- the SavedVariables write target
}
```

### `.pkgmeta`

```yaml
package-as: <Addon>

# Libraries are vendored in libs/ and committed to git — NOT fetched as externals.

ignore:
  - .luacheckrc
  - .gitignore
  - docs        # holds docs/audits/ and docs/reviews/ too — all dev-only
  - tests
  - _dev
  - "*.bak"
```

Libraries are **vendored under `libs/` and committed** (`STANDARDS.md library-stack-§3`). Copy the folder-per-lib set you actually `LibStub()` from an existing Ka0s addon's `libs/` so versions stay consistent across the suite, and list them **first** in the TOC (`.xml` where the lib ships one, `.lua` otherwise). Pull libs the suite doesn't yet vendor (LibDataBroker-1.1, LibDBIcon-1.0, …) from a current retail install or the upstream release.

### Docs — root `CLAUDE.md` stub + `docs/agent-context.md`

Root ships a **full** `README.md`, a **stub** `CLAUDE.md`, and `LICENSE`; everything else lives under `docs/` (documentation). The stub is short and **MUST** carry a `## Standards compliance (read first)` section; the contents of *this* pack become `docs/agent-context.md`, whose `## Hard rules` **MUST** open with the conform-to-the-standard rule pointing back to the stub (documentation-§6).

```markdown
<!-- root CLAUDE.md (STUB — never the full brief) -->
# CLAUDE.md — Ka0s <Name>

**Tier <1|2>** WoW addon. Adheres to the **Ka0s WoW Addon Standard** —
https://github.com/tusharsaxena/WowAddonStandards

## Standards compliance (read first)

This repo is built to the **Ka0s WoW Addon Standard** (URL above). All development here — features,
refactors, doc changes — MUST conform to it. The standard is the source of truth for layout, TOC
shape, the Ace substrate, schema-driven settings, slash/prefix conventions, locales, Compat,
tests/lint, and doc structure.

**If a change would deviate from the standard, STOP and flag the deviation explicitly.** Do not
silently deviate and do not silently "fix" to match. Surface it and let the user decide which of
two things it is:

1. **An accepted deviation** — this addon intentionally differs; record it as a documented
   deviation (e.g. in the TOC/README/`docs/` and in the audit bundle), with the reason.
2. **A change to the standard itself** — the standard's definition should evolve; the update
   belongs upstream in the WowAddonStandards repo, after which this addon conforms to the new rule.

When in doubt, treat standard conformance as a hard requirement and ask.

Start here, then read the docs:

- **`docs/agent-context.md`** — the full agent brief (stack, tier layout, hard rules, invariants,
  the `NS` bus, working environment, response style).
- **`docs/ARCHITECTURE.md`** — module map, settings schema, message bus, slash surface, event
  wiring, taint notes, known limitations.
- Topic detail in `docs/` as needed (`schema.md`, `settings-panel.md`, `smoke-tests.md`, …).

Green gate before every commit: `lua tests/run.lua` and `luacheck .` (0/0). Never auto-stage/commit/
push and never bump the version without an explicit instruction.
```

```markdown
<!-- docs/agent-context.md — the FIRST bullet of ## Hard rules -->
- **Conform to the Ka0s WoW Addon Standard** (https://github.com/tusharsaxena/WowAddonStandards).
  It is the source of truth for layout, TOC, the Ace substrate, schema-driven settings, slash/prefix
  conventions, locales, Compat, tests/lint, and doc structure. **If a change would deviate, STOP and
  flag it** — never silently deviate or silently conform. The user decides whether it is (a) an
  accepted, documented deviation for this addon, or (b) a change to the standard itself (updated
  upstream in the standards repo, then this addon follows the new rule). See the root
  [CLAUDE.md](../CLAUDE.md) "Standards compliance" section.
```

---

## Hard rules cheat sheet (memorize)

1. Every file starts with `local addonName, NS = ...`. No `_G[addonName] = {}`.
2. SavedVariables: `<Addon>DB`, single global, with `schemaVersion`.
3. License: MIT.
4. Folder casing: `<Addon>/` PascalCase, all subfolders lowercase (`libs/` not `Libs/`).
5. TOC: single latest-Retail `## Interface:` (Retail only), plus `X-Standard`, `X-Curse-Project-ID`, `X-Wago-ID` (the last two mandatory if published).
6. Slash: AceConsole `:RegisterChatCommand`. Never raw `SLASH_*`.
7. Locale: metatable fallback `__index = function(_,k) return k end`. Never AceLocale strict.
8. Options UI: Blizzard `Settings.RegisterCanvasLayoutCategory` + raw AceGUI body. Register the **category eagerly at load** (always visible); build the **body lazily** on first `OnShow`. Never AceConfigDialog for content; never defer registration to first `/config`.
9. Schema-as-single-source: one table drives panel widgets + slash + defaults reset. One write seam.
10. Closed message bus: modules talk via `Ka0s_<Addon>_<Event>` messages, one sender each. No cross-module table reach.
11. All deprecated-API calls live in `Compat.lua`. Modules call `NS.Compat.X`. No `WOW_PROJECT_ID` flavor branching (Retail only).
12. Combat lockdown: gate `InCombatLockdown()` at panel-open, settings setters, secure-frame attribute writes. Defer with `PLAYER_REGEN_ENABLED`.
13. Per-frame loops: cache db values into module locals, refresh via `M:RefreshUpvalues()` on settings change.
14. ≥10 dynamic frames: use object pool (Acquire/Release/HideAll).
15. File LOC cap: ~1500. Peel when exceeded.
16. Vendor everything: commit all libs in `libs/`, loaded first in the TOC. Never use `.pkgmeta` `externals:` for libraries.
17. Debug: on-screen **console** styled like the main window (debug-logging), not chat, if the addon has a window. Monospace font (10pt) + tagged colour-coded lines via `NS.Debug(tag, …)`; zero-alloc when off. Enabled-state is **session-only** (`NS.State.debug`, default off, reset every `/reload`; never in SV), decoupled from window visibility.
18. Preview/test mode (preview-mode): addons with a positionable display SHOULD show placeholder data while unlocked and/or via `/<slash> preview`.
19. Tests: ship a headless `tests/` harness. TDD. `lua tests/run.lua` green **and** `luacheck .` clean **before every commit**.
20. Docs: root = full `README.md` + **stub** `CLAUDE.md` + `LICENSE`; everything else under `docs/`. Canonical `docs/` trio (all addons): **`agent-context.md`** (full agent brief), `ARCHITECTURE.md`, `smoke-tests.md`; topic-detail docs as needed. Media in typed `media/` subfolders. No drift; sync before every release. (documentation-§3)
20a. `README.md` follows the **canonical section order** (documentation-§1): title → badges (`[wow]`/version/license/standard) → logo → description → Screenshots → Usage (Slash commands + Settings panel tables) → How it works → FAQ → Troubleshooting → **Issues and feature requests** (→ GitHub issues) → Testing → Version History. TOC follows the fixed field order + `#`-section file listing (toc-file-§1/toc-file-§5).
20b. **No `TODO.md`** in a released addon — backlog lives in **GitHub issues** (documentation-§4). Only an unreleased, in-development addon may keep a `docs/TODO.md`, deleted before first release.
20c. **Standards reference in project memory & context** (documentation-§6): the reference to the standard MUST appear in **four** places — TOC `X-Standard`, README standard badge, the root `CLAUDE.md` `## Standards compliance (read first)` section, and `docs/agent-context.md`'s first `## Hard rules` bullet (pointing back to the `CLAUDE.md` section). STOP and flag any change that would deviate; the user classifies it as an accepted deviation (recorded here) or a change to the standard itself (made upstream, then adopted).
21. Audits & reviews: archive every audit under `docs/audits/<YYYY-MM-DD>/` and every code review under `docs/reviews/<YYYY-MM-DD>/`, each a 5-artifact bundle (audit-review-history). Kept, not deleted.
22. Versioning: semver. Bump TOC, code constants, README. `wow-addon:version-bump` automates this. Bump `## Interface:` + README `[wow]` badge each patch.
23. Git: trunk-based. Commit to the default branch on a **green** unit of work; no feature branches unless the human asks. Never push unless asked.
24. Standalone main window (data browser/log/tracker): non-secure `CreateFrame` (no combat gate), `UISpecialFrames` (ESC), persist pos/size in SV, scale setting, lazy tabs, one `SKIN` + `ApplySkin` seam, pooled rows. See `STANDARDS.md standalone-windows`.

## Forbidden patterns

- `_G[addonName] = {}` (use private NS).
- AceLocale strict mode.
- Hand-rolled options framework (use Settings + AceGUI).
- AceConfigDialog for non-Profiles content.
- Raw `SLASH_*` registration.
- `if cmd == "x" then elseif ...` slash dispatchers.
- `.pkgmeta` `externals:` for libraries (Ka0s vendors and commits all libs).
- Forking Ace libs.
- Multi-flavor / Classic support: comma `Interface` lists, per-flavor TOCs, `_Classic` data splits, `enable-toc-creation` fan-out (Retail only, single Interface line).
- `if WOW_PROJECT_ID ==` game-flavor branching (Retail only; Retail-patch checks go in Compat).
- Direct calls to deprecated APIs (route through Compat).
- `:Hide()` on Blizzard frames you replace (reparent to hidden parent).
- Replacing `_G.AddMessage`.
- Hard `## Dependencies:` (use OptionalDeps + soft fallback).
- Hard-depending on an addon suite or standalone addon (ElvUI/EllesmereUI/DBM/WeakAuras/…), or reading its media/API/frames/SavedVariables — the addon is fully self-contained and works identically standalone; suite integration is optional, presence-guarded (`C_AddOns.IsAddOnLoaded`), `OptionalDeps`-listed, and degrades gracefully (library-stack-§6). Vendored **libraries** are unaffected — a library is not a suite.
- `X-License: All Rights Reserved`.
- Files >1500 LOC.
- Multiple senders per bus message.
- Debug output to the chat frame when the addon has a main window (use the on-screen console).
- Deferring settings-**category** registration until first `/config`/panel-open (register eagerly at load).
- Cross-module direct table access.
- User-supplied Lua execution.
- Committing with red `lua tests/run.lua` or non-clean `luacheck .`; a logic change with no covering test.
- Loose files directly in `media/` (use typed subfolders).
- Full agent brief in the root `CLAUDE.md` (root is a stub; brief lives in `docs/`).
- `TODO.md` in a **released** addon (track the backlog in GitHub issues; allowed only in an unreleased, in-development addon, deleted before first release).
- Non-canonical `README.md` section order, or a TOC departing from the required field order / file-listing structure (documentation-§1, toc-file-§1/toc-file-§5).
- Missing the standards reference in project memory & context: no `## Standards compliance (read first)` section in `CLAUDE.md`, or `docs/agent-context.md`'s `## Hard rules` not opening with the conform-to-the-standard rule pointing back to it (documentation-§6).
- Creating a feature branch without an explicit request (work trunk-based).

---

## Definition of done (new addon ready for v0.1.0 release)

- [ ] TOC has all required fields incl. single latest-Retail `## Interface:`, `X-Standard`, `X-Curse-Project-ID`, `X-Wago-ID`.
- [ ] `.pkgmeta` present with **no** `externals:` block; all libs vendored and committed under `libs/`.
- [ ] `.luacheckrc` present; `luacheck .` reports **0 errors**.
- [ ] `tests/` harness present; `lua tests/run.lua` is **green**; behavior is covered test-first (testing).
- [ ] `Compat.lua` exists (even if scaffold); no `WOW_PROJECT_ID` flavor branching.
- [ ] `Locale.lua` exists with metatable fallback.
- [ ] `Database.lua` exists with `RunMigrations()` (even if no migrations yet).
- [ ] Settings module exposes Schema with at least one row, single write seam, slash dispatch from `COMMANDS` table.
- [ ] AceConsole `:RegisterChatCommand` registered.
- [ ] Options panel uses `Settings.RegisterCanvasLayoutCategory`, **category registered eagerly at load** (entry always visible), **body built lazily** on first `OnShow`.
- [ ] Combat-lockdown guard on panel-open.
- [ ] Debug **console** (debug-logging) — on-screen, styled like the main window; monospace font (10pt) + tagged colour-coded lines `<ts> | [<Tag>] <content>`; `/<slash> debug` toggles the window, `/<slash> debug on|off` set logging; enabled-state **session-only** (never in SV), decoupled from window visibility; title-bar `Debug: ON/OFF` toggle. (Tier-1 no-window addons MAY use chat.)
- [ ] Preview/test mode (preview-mode) if the addon has a positionable display.
- [ ] Media in typed `media/` subfolders (`logos/`, `screenshots/`, …).
- [ ] Root = full `README.md` (with `[wow]` badge + standard link) + **stub** `CLAUDE.md` + `LICENSE`; canonical `docs/` trio present (`agent-context.md`, `ARCHITECTURE.md`, `smoke-tests.md`); passes the drift check.
- [ ] **Standards reference in memory & context (documentation-§6)** — all four present: TOC `X-Standard`, README standard badge, `CLAUDE.md` `## Standards compliance (read first)` section, and `docs/agent-context.md`'s first `## Hard rules` bullet pointing back to it.
- [ ] `README.md` follows the canonical section order (documentation-§1), including **Usage** (Slash-commands + Settings-panel tables), **Issues and feature requests** (→ GitHub issues), **Testing**, and **Version History**.
- [ ] TOC follows the fixed field order and `#`-section file-listing structure (toc-file-§1/toc-file-§5).
- [ ] **No `TODO.md`** at release (backlog is in GitHub issues); any pre-release `docs/TODO.md` has been removed (documentation-§4).
- [ ] LICENSE = MIT full text.
- [ ] First entry in `docs/audits/<YYYY-MM-DD>/` (even if just a "Hello world" smoke test).

---

## Patterns to reproduce (described, not named)

When stuck, reproduce these patterns — each already exists somewhere in the collection in the cited
dimension. (Per the standard's reading-guide convention, they are described by their role, not by addon name; the
named evidence is in `INDUSTRY_RESEARCH.md`.)

| Need | Reproduce this pattern |
|---|---|
| Schema structure | A single `Schema` table whose rows (`path/default/type/label/widget/validate/onChange`) drive AceDB defaults, AceGUI widgets, slash dispatch, and reset — with a boot-time validator that warns on any `path` not resolving against defaults. |
| Macro/protected-API firewall | A single `MacroManager`-style module that is the **only** caller of `CreateMacro`/`EditMacro`; no other file touches protected macro APIs. |
| Tier-2 modular layout | `core/` + `modules/` + `defaults/` + `settings/` + `locales/` with strict TOC load order and idempotent `NS.<Module> = NS.<Module> or {}` publication. |
| Closed message bus | A handful of `Ka0s_<Addon>_*` messages, one sender each, documented in `docs/ARCHITECTURE.md`; consumers register by name, no cross-module table reach. |
| Compat module | One `Compat.lua` that owns every deprecated/cross-patch API call and exposes shimmed wrappers (`Compat.GetSpellInfo`, `Compat.GetSpecialization`). |
| Taint-free chat formatting | Override `_G[GLOBALSTRING]` values rather than hooking chat events or replacing `AddMessage`; order filter registration deterministically. |
| Combat-lockdown cascade | A layered `InCombatLockdown()` guard at config-open → settings-register → frame-show, each deferring on `PLAYER_REGEN_ENABLED`. |
| Eager settings registration + lazy body | Register the Blizzard **category** at load (bootstrap on `ADDON_LOADED(Blizzard_Settings)`/`PLAYER_LOGIN`, or in `OnInitialize`); build the panel body only in the first `OnShow`. |
| On-screen debug console | A `DIALOG`-strata `700×344` `BackdropTemplate` window; a `ScrollingMessageFrame` in a shipped monospace font (10pt) with tagged, colour-coded lines (`<ts> \| [<Tag>] <content>`), Clear/Copy, `UISpecialFrames`, reusing the main window's `SKIN`/`ApplySkin`; a gated `NS.Debug(tag, …)` sink that appends there instead of chat; session-only window-independent enabled-state with a title-bar `Debug: ON/OFF` toggle. |
| Preview/test mode | Placeholder data fed through the real render path while the display is unlocked and/or via `/<slash> preview`. |
| Headless test harness | `tests/run.lua` micro-framework + `tests/loader.lua` (`setfenv` over ordered sources) + `tests/wow_mock.lua` (self-returning no-op frame; CreateFrame/Settings/LibStub fakes); per-module `test_*.lua` suites. |
| Lazy first-OnShow panel build | Latch (`rendered` flag) so the AceGUI body builds once, on first `OnShow`, when the panel width is non-zero. |
| Soft-fallback discipline | Load-safe shims for missing optional libs (AceDB-missing flat table, LSM-missing Blizzard constants) so the addon runs with `OptionalDeps` absent. |

---

## Skills you should use while building

(All under `wow-addon:` prefix in your local Claude Code plugin.)

- `wow-addon:new-addon` — scaffold a new addon (Ace3 stack, AceDB, modular folder layout, MIT license, slash command).
- `wow-addon:standards-audit` — audit the current addon against the standard. Produces the `docs/audits/<DATE>/` deviation + remediation bundle (audit-review-history).
- `wow-addon:review` — principal-engineer code review of the current addon. Produces a `docs/reviews/<DATE>/` findings bundle (audit-review-history).
- `wow-addon:sync-docs` — eliminate doc drift across README, CLAUDE.md, ARCHITECTURE.md.
- `wow-addon:audit-conventions` — walk multiple addons and report drift in shared conventions.
- `wow-addon:bump-interface` — bump the single TOC Interface line to the latest Retail patch.
- `wow-addon:version-bump` — bump version everywhere (TOC, code constants, README badges + Version History, CLAUDE/ARCHITECTURE, CHANGELOG).
- `wow-addon:normalize-readme` — reshape README to match a reference addon's section structure.
- `wow-addon:diff` — summarize uncommitted changes with risk assessment.
- `wow-addon:commit` — generated-message commit.
