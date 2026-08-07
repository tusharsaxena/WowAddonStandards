# New Ka0s Addon — Context Pack (v2.28.0, 2026-08-06)


> ## ⚠ CRITICAL — FETCH THIS, NEVER STORE IT
>
> This pack is **scaffolding**. It is fetched at runtime, used for the session that scaffolds an
> addon, and **discarded**. It **MUST NOT** be copied into an addon repo — not as
> `docs/agent-context.md`, not under any other name (documentation-§3, anti-pattern #49).
>
> ```sh
> curl -fsSL https://raw.githubusercontent.com/tusharsaxena/WowAddonStandards/master/standards/NEW_ADDON_CONTEXT.md \
>   -o "$TMPDIR/NEW_ADDON_CONTEXT.md"      # a temp dir. NEVER the addon's docs/.
> ```
>
> Everything below is a **starter**: a kickstart walkthrough, a starter tree, starter snippets and a
> "definition of done for v0.1.0". Every question it answers is answered the moment the addon
> exists. Stored in the repo it becomes a brief that describes the addon on the day it was born,
> forever — and because it is loaded as **working context**, a stale copy does not go quiet, it
> gets followed. A pack still showing how to hand-write a debug console, a slash dispatcher or a
> test harness will get one hand-written, in an addon that replaced all three with `LibKa0s`
> (anti-pattern #47). Nothing goes red: no test covers a doc, and lint does not read prose.
>
> The durable per-addon context has its own required homes — the root `CLAUDE.md` stub (identity,
> standards compliance), `docs/ARCHITECTURE.md` (what this addon *is*) and `docs/testing.md` (how
> to verify it). Put lasting facts there. Never here.

**Work from this file in a temp directory for the scaffolding session, then discard it — it MUST NOT be written into the addon under any name (documentation-§3, anti-pattern #49).** Leave a short `CLAUDE.md` stub at the addon root, and put the durable per-addon context in `docs/ARCHITECTURE.md` and `docs/testing.md` (documentation). Self-contained — no external lookups required for an LLM or new contributor to scaffold a fully standards-compliant addon.

Authoritative reference: `WowAddonStandards/standards/STANDARDS.md`. This document is its operational distillation. Every Ka0s addon is built to the standard and references it: <https://github.com/tusharsaxena/WowAddonStandards>.

**Scope:** Retail (Mainline) only.

---

## Kickstart walkthrough

The ordered process for starting a new Ka0s addon that is **born compliant** with the current
standard. Steps run in the **new addon's repo** unless marked *[standards repo]*.

1. **Scaffold.** Run the `wow-addon:new-addon` skill (Ace3 stack, AceDB saved variables, modular
   folder layout, MIT license, AceConsole slash command). This lays down the skeleton the rest of this
   pack fills in.
2. **Work from this pack — never write it in.** Read it from your temp copy and build from it; it
   **MUST NOT** be written into the addon under any name (documentation-§3, anti-pattern #49). Leave
   a short root `CLAUDE.md` stub — the repo's only agent brief — and put the durable per-addon
   context in `docs/ARCHITECTURE.md` and `docs/testing.md` (documentation).
3. **Lay out files.** Use the modular `core/ defaults/ settings/ locales/ modules/` layout — see
   *Layout* below (it is the only layout; a small addon just has thin folders). Copy the vendored
   `libs/` set you actually `LibStub()` from an existing Ka0s addon so versions stay consistent, then
   vendor the **two Ka0s-owned payloads** from the `LibKa0s` repo's own folders — **byte-identical**,
   never from a sibling addon's possibly-stale copy (library-stack-§7, anti-pattern #45):
   - the repo's inner **`LibKa0s/` folder → `libs/LibKa0s/`**, copied **whole**, every module, even
     the ones the first release does not wire — and TOC-listed as the single line
     `libs\LibKa0s\LibKa0s.xml` in the `# Libraries` block **after Ace3**. Copying part of a
     multi-file major is anti-pattern #48.
   - the repo's root-level **`testkit/` folder → `tests/_kit/`** — a *sibling* of the ship folder, not
     inside it, so there is no `LibKa0s/testkit/` to copy from. It goes under `tests/`, **never**
     `libs/`, because it must not ship to the player (testing-§1).
4. **Fill in the starters.** Work through the *Starter snippets* (TOC, entry, `Compat`, `Locale`,
   `Database`, `Schema`, the five setup files, tests, message bus, `.luacheckrc`, `.pkgmeta`,
   `DEPENDENCIES.md`) and the
   *Hard rules cheat sheet* below. **The shared subsystems are consumed, not written**: the chat
   printer, the debug console, the slash dispatcher, the options toolkit and the performance harness
   are `LibKa0s` modules, and the addon is born with one **setup file** per module — a **descriptor**
   and a **degradation stub**, nothing else. Hand-building any of them is anti-pattern #47. When
   stuck, reproduce the described patterns in *Patterns to reproduce*.
5. **Write tests first.** Stand up `tests/` on the vendored `tests/_kit/` harness (testing) and drive
   each behavior test-first. Test what is **yours** — the descriptors, the degradation stubs, the
   addon's own logic — and do not re-test a library's internals; those cases live in the `LibKa0s`
   repo, and a second copy of them is exactly the duplication this arrangement exists to remove
   (testing-§8).
6. **Check Definition of Done.** Walk the checklist at the bottom before tagging `v0.1.0`.
7. **Register in the roster.** *[standards repo]* Add the addon's row to
   `WowAddonStandards/standards/ADDONS.md`. This puts it in scope for the next standards refresh — it
   is the only edit needed to bring a new addon into the collection.

Then keep it compliant over time with the `wow-addon:` skills listed at the end of this file
(`review`, `sync-docs`, `bump-version`, …) and re-audit it as part of the collection.

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

## Layout

Every Ka0s addon uses one **modular** layout — `core/ defaults/ settings/ locales/ modules/` — no matter how small (layout). There is no flat variant: a three-file utility and a multi-feature suite share the same skeleton, so every repo reads identically and each file has one obvious home. A small addon simply has thin folders (a single `modules/` file, a one-row `settings/Schema.lua`), not a different structure.

---

## Starter tree

```
<Addon>/
  <Addon>.toc            -- single Interface line (latest Retail)
  core/
    Compat.lua           -- LOAD FIRST
    Constants.lua
    Namespace.lua        -- NS.PREFIX, the mandatory cyan chat tag (slash-commands-§4)
    State.lua            -- session-only state incl. NS.State.debug (never in SV)
    CoreSetup.lua        -- NS.Print from LibKa0s-Core-1.0:New{prefix=...} (slash-commands-§4)
    PerfSetup.lua        -- NS.Perf = LibStub("LibKa0s-Perf-1.0"):New(descriptor) (performance-§1)
    DebugLogSetup.lua    -- NS.DebugLog = LibKa0s-DebugLog-1.0:New(descriptor); publishes NS.Debug
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
    Slash.lua            -- NS.COMMANDS + the LibKa0s-Slash-1.0 descriptor (slash-commands-§3)
    OptionsSetup.lua     -- NS.Helpers = LibKa0s-Options-1.0:New(descriptor) (options-ui-§1)
    <Page>.lua           -- one per settings page; registers its rows and its builder
  modules/
    <Feature>.lua
  media/                 -- typed subfolders (logos/, screenshots/, ...)
    fonts/               -- the shipped monospace TTF + its OFL.txt (debug-logging-§2)
  libs/                  -- vendored, committed
    LibKa0s/             -- the WHOLE ship folder; byte-identical to its repo (library-stack-§7)
  tests/
    _kit/                -- vendored from the LibKa0s repo's testkit/; never edited (testing-§1)
    run.lua              -- this addon's load list, lifecycle kick and suite list
    wow_mock.lua         -- thin extender over _kit/mock_base.lua
    test_*.lua           -- one suite per module
    perf.lua             -- offline scenario runner; OUTSIDE the green gate (performance-§9)
  docs/                  -- ARCHITECTURE.md, testing.md, smoke-tests.md, planning; NO agent-context.md (documentation-§3); no TODO.md once released (documentation-§4)
    performance.md       -- required: the addon's perf page (performance)
    perf-runs/README.md  -- required: the standing IN-GAME capture store (performance-§8)
    automated-tests/     -- required: the consolidated test record (automated-tests)
      README.md          --   what it is and how to run it
      RESULTS.md         --   GENERATED trend line, overwritten in place (automated-tests-§4)
      <run>/             --   one frozen bundle per run (automated-tests-§1)
    audits/<YYYY-MM-DD>/ -- retained audit-run history (audit-review-history)
    reviews/<YYYY-MM-DD>/-- retained code-review history (audit-review-history)
  README.md (root, full)  CLAUDE.md (root, stub)  DEPENDENCIES.md (root)  LICENSE (root)
  .luacheckrc  .pkgmeta  .gitattributes   -- written FIRST, before anything above it (line-endings)
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
## SavedVariables: <Addon>DB, <Addon>PerfDB
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
libs\LibKa0s\LibKa0s.xml                 -- ONE line; the .xml is itself the file list

# Locales
locales\enUS.lua

# Core
core\Compat.lua
core\Constants.lua                       -- incl. FONT_MONO, the shipped console font path
core\Namespace.lua                       -- NS.PREFIX
core\State.lua                           -- NS.State.debug
core\CoreSetup.lua                       -- after NS.PREFIX, before anything that prints
core\PerfSetup.lua                       -- before anything taking NS.Perf as an upvalue
core\DebugLogSetup.lua                   -- after Constants/State/CoreSetup, before any NS.Debug call
core\<Addon>.lua
core\Database.lua

# Defaults
defaults\Profile.lua

# Modules
modules\<Feature>.lua

# Settings (last — depend on everything else being initialized)
settings\Schema.lua
settings\Slash.lua
settings\OptionsSetup.lua                -- before every settings\<Page>.lua
settings\<Page>.lua
```

`libs\LibKa0s\LibKa0s.xml` is a **single** entry — naming the module files individually is the same
partial-vendoring mistake spelled differently, and it drifts the moment the library gains a file
(library-stack-§7). The library block never carries an addon-authored `embeds.xml` (anti-pattern #38).

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
  NS.CreateOptionsPanel() -- EAGER settings-category registration (options-ui-§1) — always visible in
                          -- the options list. Published by settings/OptionsSetup.lua; the page
                          -- BODIES stay lazy (first OnShow), only the category is eager.
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
-- Input side (localization-§4): match game data on stable IDs/tokens — spellID, itemID,
-- classFile ("PRIEST"), instanceID, Enum.* — NEVER on a localized name string.
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

### `core/CoreSetup.lua` — the chat printer (`LibKa0s-Core-1.0`)

The secret-safe stringifier and the `NS.PREFIX`-tagged printer are the library's; what is the addon's
is the tag and the fallback. Sits after the file that defines `NS.PREFIX` and before everything that
prints (`core/PerfSetup.lua` first).

```lua
local addonName, NS = ...
NS.Util = NS.Util or {}

local lib = LibStub and LibStub("LibKa0s-Core-1.0", true)
if not lib then
  -- Degrade, never error. Four settings files do `local print = NS.Print` at load, so a nil printer
  -- takes the whole settings UI with it and a no-op one makes /<slash> answer nothing. Keep short
  -- pre-library fallbacks, and say "not installed" ONCE — on the first line printed, not on every one.
  return
end

NS.IsConcatSafe, NS.SafeToString = lib.IsConcatSafe, lib.SafeToString

-- The prefix goes in as a FUNCTION, not as the value of NS.PREFIX: the printer is built once at
-- load, and the function form keeps a later change to the constant from being frozen out.
local printer = lib:New({ prefix = function() return NS.PREFIX end })

-- NS.Print and NS.Util.print MUST be the SAME function object. AceAddon:NewAddon(NS, …,
-- "AceConsole-3.0") stamps AceConsole's :Print over NS.Print; core/<Addon>.lua reclaims it by
-- repointing NS.Print at NS.Util.print, which only restores what the settings files captured
-- because it is the identical object (architecture-§2, anti-pattern #36).
NS.Print = printer.Print
NS.Util.print = NS.Print
```

### `settings/Schema.lua`

One row per setting — the single source that drives panel widgets, the slash CLI and defaults reset.
The write seam is the addon's, and both the panel and the CLI go through it.

```lua
local addonName, NS = ...

NS.Schema = {
  { path = "display.scale", default = 1.0, type = "number", min = 0.5, max = 2.0,
    page = "general", label = "Scale", widget = "Slider",
    onChange = function(v) NS:OnScaleChanged(v) end },
}

-- The single write seam. `/<slash> set`, the panel checkbox and a reset all land here.
function NS.SetByPath(path, value)
  local row = NS.FindSchemaRow(path)
  if not row then return false, "unknown path: " .. path end
  -- write → row.onChange → NS.Debug("Set", "%s = %s", path, value) → panel refresh
end
```

### `settings/Slash.lua` — `NS.COMMANDS` + the dispatcher descriptor (`LibKa0s-Slash-1.0`)

The dispatcher, the help renderer, the row and key/value formatters, the list builder and the
type-aware value parser are the library's. What stays here is the **ordered verb table** and the host
verbs that reach into this addon's own state. Entries are **positional triples** `{name, desc, fn}` —
a table of named fields is silently invisible to the library and every verb becomes unknown.

```lua
local addonName, NS = ...
NS.Slash = NS.Slash or {}
local Sl, print = NS.Slash, NS.Print

local SlashLib = LibStub and LibStub("LibKa0s-Slash-1.0", true)
local cli      -- built at the bottom, once NS.COMMANDS exists; handlers reach it at CALL time
local runPerf  -- and the host verbs, forward-declared for the same reason

NS.COMMANDS = {
  {"help",     "List available commands",                    function()     cli:PrintHelp() end},
  {"config",   "Open the settings panel",                    function()     NS.OpenOptionsPanel() end},
  {"list",     "List every setting and its current value",   function()     cli:CliList() end},
  {"get",      "Print a setting's current value",            function(rest) cli:CliGet(rest) end},
  {"set",      "Set a setting",                              function(rest) cli:CliSet(rest) end},
  {"reset",    "Reset one setting to its default",           function(rest) cli:CliReset(rest) end},
  {"resetall", "Reset every setting to defaults",            function()     cli:CliResetAll() end},
  {"debug",    "Toggle the debug console — `on`/`off` enable/disable logging",
    function(rest)
      local a = rest and tostring(rest):lower():match("^%s*(%S*)") or ""
      if a == "on" then NS.DebugLog:SetEnabled(true)
      elseif a == "off" then NS.DebugLog:SetEnabled(false)
      else NS.DebugLog:Toggle() end   -- bare: toggle the WINDOW, the flag untouched
    end},
  {"perf",     "Measure performance — try `/<slash> perf` for the workflow",
                                                             function(rest) runPerf(rest) end},
  {"version",  "Print the addon version",                    function()     cli:CliVersion() end},
}

if not SlashLib then
  -- Degrade, never error: `/<slash>` is registered unconditionally, so something must answer it.
  -- Carry every member the addon calls (OnSlash, PrintHelp, LandingRows, SetRowAnnotator, each Cli*).
  -- The host verbs never went to the library, so they keep working; what is lost is the schema CLI,
  -- and each of those verbs NAMES the missing library instead of going quiet. Copy NOTHING of the
  -- library's rendering into the stub — no row formatter, no parser, no `key = value` shape.
end

cli = SlashLib:New({
  slash        = "/<slash>",
  slashAliases = { "/<addonname>" },
  commands     = NS.COMMANDS,                                  -- passed IN, never owned by the lib
  aliases      = { options = "config" },                       -- legacy spelling → real verb
  print        = function(line) print(line) end,               -- the HOST's tagged printer
  version      = function() return NS.Compat.GetAddOnMetadata(NS.name, "Version") or NS.version end,
  get          = function(path) return NS.GetSetting(path) end,
  set          = function(path, v) NS.SetByPath(path, v) end,  -- the single write seam
  findRow      = function(path) return NS.FindSchemaRow(path) end,
  applyDefault = function(row) NS.ApplyDefault(row) end,
  allRows      = function() return NS.Schema end,              -- in the order `list` should print
  groupKey     = function(row) return row.page end,            -- the heading a row lists under
})

function Sl:LandingRows() return cli:LandingRows() end          -- same rows, unindented, for the panel

function Sl:Register()
  NS.addon:RegisterChatCommand("<slash>", function(msg) cli:OnSlash(msg) end)
  NS.addon:RegisterChatCommand("<addonname>", function(msg) cli:OnSlash(msg) end)
end
```

`NS.COMMANDS` is passed **in** rather than owned by the library because the options landing page
renders the same table (options-ui-§5); a library that owned it would force the options library to
consume this one, and two libraries reaching for each other is a real dependency cycle. `perf` is a
**reserved verb** and **MUST** be registered here by the addon, never by the harness that implements
it (performance-§4).

**Chat tag & CLI output (slash-commands-§4–§5).** The **tag is the host's** — a library shared by every addon has nothing to derive it from. `NS.PREFIX` is the mandatory **cyan** bracketed tag — `|cff00ffff[XY]|r` (initials `XY`; the cyan `00ffff` is required, not just an example) — exposed once and handed to the descriptor's `print`. The **output shape is the library's**, and the addon gets it by wiring the descriptor correctly rather than by formatting anything: `list` prints `Available settings`, then `  [page]` group headers, then `    path = value` rows; `get`/`set`/`reset` print the single-line `path = value`, echoing the *stored* value after a write so clamping is visible. The color scheme is fixed — header green (`33ff99`), group headers azure (`3399ff`), keys/paths gold (`ffff00`), values white (`ffffff`), ` = ` uncolored, **no trailing colon** on any line — and values are type-aware and unit-annotated (`<n> px`, `1.00x`, `true`/`false`, `{r, g, b, a}`). Do **not** re-spell any of it at a call site. Where a rendered value needs a caveat only the addon knows (a setting currently mirrored, overridden or inert), supply a **row annotator** rather than reformatting the line.

### `settings/OptionsSetup.lua` — the settings panel (`LibKa0s-Options-1.0`)

The canvas shell, the schema-row → AceGUI widget makers, the two-column flow engine, the header and
the always-shown scrollbar patch are the library's across **three** files (`Options.lua`,
`OptionsWidgets.lua`, `OptionsScroll.lua`). The descriptor is entirely *where a value lives*, never
*how a panel looks*. Loads after `settings/Slash.lua` and **before** every `settings/<Page>.lua`.

```lua
local addonName, NS = ...
local print = NS.Print

-- Named ONCE and enforced twice — by the library through skipRestoreAll, and by the stub's own
-- reset loop. Two literal copies of the rule is one added page away from a reset that eats profiles.
local function vetoedFromResetAll(row) return row.page == "profiles" end

local lib = LibStub and LibStub("LibKa0s-Options-1.0", true)

local descriptor = {
  parentTitle   = "Ka0s <Name>",
  mainPanelName = "<Addon>MainPanel",          -- the one field the library validates (it raises)

  get          = function(path) return NS.GetSetting(path) end,
  set          = function(path, value) NS.SetByPath(path, value) end,   -- single write seam
  applyDefault = function(row) NS.ApplyDefault(row) end,
  allRows      = function() return NS.Schema end,
  rowsForPage  = function(pageKey, filter) return NS.SchemaForPage(pageKey, filter) end,

  skipRestoreAll  = vetoedFromResetAll,
  afterRestoreAll = function() NS.ResetPositions() end,   -- state no schema row owns

  colorDecode = function(c) c = type(c) == "table" and c or {}
                            return c.r or 1, c.g or 1, c.b or 1, c.a or 1 end,
  colorEncode = function(r, g, b, a) return { r = r, g = g, b = b, a = a or 1 } end,

  buildMain     = function(ctx) NS.BuildAboutPage(ctx) end,   -- the landing body IS the host's
  getLSM        = function() return NS.GetLSM() end,
  scheduleTimer = function(fn, delay) return NS.addon:ScheduleTimer(fn, delay) end,
  validate      = function() NS.ValidateSchema() end,
  onAceGUI      = function(AceGUI) NS.AceGUI = AceGUI end,
  print         = function(line) print(line) end,
  debug         = function(tag, fmt, ...) NS.Debug(tag, fmt, ...) end,
}

if not lib then
  -- THE ONE EXCEPTION to the member-answering stub (options-ui-§1). Page files call
  -- Helpers.LSMValues INSIDE schema-row literals, at FILE LOAD — with it nil the page file raises,
  -- its RegisterSchemaRows never runs, and a third of the schema silently vanishes along with
  -- list/get/set/reset and the profile defaults. So this stub is LOAD-COMPLETING: publish every
  -- member a page file touches at load (measure that set by deleting one and re-running the
  -- library-absent load, not by reading), keep the global reset real because the user whose panel
  -- will not open is the one who needs it, and make everything else a no-op or one honest line.
  -- Copy NO widget maker, no flow engine, no header, no LAYOUT constant into it.
  return
end

-- NS.Helpers IS the instance, decorated in place — never a fresh table copying members across. A
-- host page helper added later can then call the library's own members, and a suite that swaps one
-- out to spy on it is swapping the one the library's callers actually see.
NS.Helpers = lib:New(descriptor)

-- Publish the three entry points the rest of the addon calls. Without these the pack's own
-- OnInitialize and page files reference nothing, and the addon errors at load.
NS.RegisterOptionsPage = NS.Helpers.RegisterOptionsPage
NS.CreateOptionsPanel  = NS.Helpers.CreateOptionsPanel
NS.OpenOptionsPanel    = NS.Helpers.OpenOptionsPanel   -- the `config` verb calls this
```

A page registers itself through the library's registry at file load and builds lazily:

```lua
NS.RegisterOptionsPage("general", "General", function(ctx)
  local rendered = false
  ctx.panel:SetScript("OnShow", function()
    NS.Helpers.EnsureDefaultsButton(ctx.panel)   -- EVERY OnShow; builds once (options-ui-§5)
    if rendered then return end                  -- body: first OnShow only
    rendered = true
    NS.Helpers.RenderSchema(ctx, "general")
  end)
  return ctx.subcategory
end)
```

The **category** registers eagerly at load (always visible in the options list) and the **body** and
the header **Defaults button** both build in the first `OnShow` — the same lazy shape for two
different reasons: AceGUI lays out against a container width that is zero at registration, and a
widget created before a UI skin installs its `RegisterAsWidget` hook keeps Blizzard's stock red art
for the session (options-ui-§5, anti-pattern #42). Panel-open **refuses** under combat lockdown with
a gray notice — the gate is inside the open function, so a second un-gated open path is forbidden.

### `core/DebugLogSetup.lua` — the debug console (`LibKa0s-DebugLog-1.0`)

The console window, the copy window, both formatters, the 500-line buffer, the scrollbar, the line
counter and the enable seam are the library's — **none of it is the addon's code to write, and an
audit MUST NOT ask for it in the addon's source**. This file supplies the frame-name prefix, the
title, the monospace font path, where the flag lives, and what the `[Init]` line says. Sits after
`core/Constants.lua` (the font path), `core/State.lua` (the flag) and `core/CoreSetup.lua` (the
printer), and before everything that calls the sink.

```lua
local addonName, NS = ...

local lib = LibStub and LibStub("LibKa0s-DebugLog-1.0", true)

if not lib then
  -- Degrade, never error. The stub carries EVERY member the addon calls — the bare Debug sink, Add,
  -- SetEnabled, IsEnabled, Show/Hide/Toggle/IsShown, Clear, ConsoleCheckbox, the raw buffer — and
  -- SetEnabled still flips NS.State.debug and still prints the ack, because the flag is OURS and a
  -- user who types `/<slash> debug on` must not be told nothing happened. What is lost is the
  -- window, said once, honestly. Reproduce NO formatter and NO color code here.
  NS.Debug = function() end
  return
end

NS.DebugLog = lib:New({
  name  = addonName,                    -- seeds the frame globals and the UISpecialFrames entries
  title = "Ka0s <Name>",
  font  = NS.Constants.FONT_MONO,       -- 10pt is the library's default; pass fontSize to deviate
  slash = "/<slash>",                   -- composes the console checkbox's tooltip

  -- The flag stays the ADDON's. The library never stores a copy: a second copy is a second truth,
  -- and the show-decision ladder and the settings panel read this one too.
  isEnabled  = function() return NS.State and NS.State.debug or false end,
  setEnabled = function(on) if NS.State then NS.State.debug = on end end,

  -- Thin CALL-TIME forwarders, never captured references: NS.Print is reclaimed from AceConsole's
  -- embed in a file that loads later, and a captured one would freeze to whatever existed at load.
  print        = function(line) NS.Print(line) end,
  safeToString = function(v) return NS.SafeToString(v) end,

  -- Only the host can know what the summary says; only the library knows when it lands (on enable,
  -- because the session-only flag is off at login and a load-time summary would never render).
  initSummary = function()
    return ("%s v%s, schema v%s, profile '%s'"):format(NS.name, NS.version,
      NS.db.global.schemaVersion, NS.db:GetCurrentProfile())
  end,

  -- So a console opened by `/<slash> debug` moves the checkbox on an already-open options panel.
  onVisibilityChanged = function() if NS.Helpers then NS.Helpers.RefreshAllPanels() end end,
})

-- The gated sink, published bare under the addon's own name. It is a plain function, not a method,
-- precisely so call sites stay `NS.Debug("Loot", "%s x%d", name, qty)`.
NS.Debug = NS.DebugLog.Debug
```

**What the addon still has to get right.** Wiring is only half of it; these are contracts the
descriptor expresses rather than code to write.

- **Ship the monospace font.** `media/fonts/` + its `OFL.txt`, LSM-registered at load, its path
  exposed as `NS.Constants.FONT_MONO` and handed over as `font`. It is a **sanctioned** styling
  exception (debug-logging-§2) — an audit must not flag it — and the addon **MUST NOT** call
  `SetFont` on the console's own regions.
- **The enabled flag is session-only and window-independent** (debug-logging-§5): `NS.State.debug`,
  default off, **never in SV**, reset every `/reload`. Capture runs with the console closed, so a bug
  can be reproduced first and the log opened after. `/<slash> debug` toggles the **window** only;
  `on`/`off` route through the single `SetEnabled` seam, which is also what the title-bar
  `Debug: ON`/`Debug: OFF` toggle uses — one seam, so no two paths can diverge.
- **Call the sink correctly** (debug-logging-§4). Tag first, format deferred:
  `NS.Debug("Loot", "%s x%d", name, qty)` — **never** `NS.Debug("Loot", ("%s x%d"):format(...))`,
  which pays for the formatting on every pass forever, gate or no gate. Use the ungated
  `NS.DebugLog:Add(tag, msg)` only for lines that must land regardless of the flag.
- **Coalesce.** One summary line per pass, never one per item/slot/frame, with the string-building
  itself behind the gate (debug-logging-§9). The buffer is 500 lines, so per-item spam *evicts* the
  signal rather than merely burying it.
- **Log settings changes once**, at the single write seam, as `[Set] <path> = <value>`; a downstream
  reactor logs only a material effect the `[Set]` line cannot imply (debug-logging-§10).
- **Secret-safe by construction** (events-frames-taint-§8). In combat, retail returns absorb/health/
  threat totals as opaque *secret* values that survive `tostring()` **and `..`** but raise in
  `table.concat`/`string.format`; on a repeating ticker one unguarded secret freezes the feature
  until `/reload`. The library routes every vararg through `safeToString`, whose detector probes
  `table.concat` — **do not** write a `..`-based probe, which passes secrets straight through
  (anti-pattern #35). For *display*, hand the raw secret to `AbbreviateNumbers()` or a widget setter
  — never `tonumber()` or `<`.
- **A no-window utility addon MAY** fall back to `NS.PREFIX`-tagged chat; any addon that has a main
  window **MUST** use the console.

### Performance harness (performance)

> **Scaffold with the wiring.** performance-§12's no-combat-path exemption is claimed from a **committed sweep** of the addon's real event handlers, and a new addon has neither the sweep nor any idea what it will grow into — so a v0.1.0 is born **wired**, and the exemption is a later, recorded decision (a register row in `docs/ARCHITECTURE.md`), never a scaffolding shortcut.

Measurement is a **vendored Ka0s-owned library**, not per-addon code — do not hand-roll a probe. Vendor `libs/LibKa0s/` (byte-identical to its source repo, library-stack-§7), list it in the TOC after Ace3, and build **one instance at load** in `core/PerfSetup.lua`:

```lua
local lib = LibStub and LibStub("LibKa0s-Perf-1.0", true)
if not lib then
    -- Degrade, never error: a missing diagnostics harness must not break the addon. Carry every
    -- member the addon actually calls — the gate, the sink, and whatever the slash layer touches.
    NS.Perf = { on = false, suspended = false, Note = function() end,
                OnCommand = function() return { "perf harness unavailable — LibKa0s is missing" } end }
    return
end

NS.Perf = lib:New({
    name    = addonName,
    version = NS.version,
    sv      = addonName .. "PerfDB",              -- declared in the TOC (toc-file-§2)
    slash   = "/<slash>",
    buckets = {                                    -- declared, in report order; nesting declared
        { key = "<event>" },
        { key = "<pass>" },
        { key = "<perItem>", within = "<pass>" },
    },
    suspend = function() --[[ unregister events, cancel queued work; visibility refuses at the
                              source, never by hiding frames (performance-§6) ]] end,
    resume  = function() --[[ re-register from CURRENT state, republish ]] end,
    log     = function(line) NS.DebugLog:Add("Perf", line) end,
    print   = function(line) NS.Print(line) end,
    showLog = function() NS.DebugLog:Show() end,   -- host decides when the console appears
    decorate = function(frame, api) --[[ console's own close-button factory (debug-logging-§12) ]] end,
})
```

Then bracket the hot paths — **this exact shape**, one upvalue read + one field read + one boolean test when capture is off (performance-§2):

```lua
local Perf = NS.Perf                              -- load-time upvalue, never an NS lookup
local t0 = Perf.on and debugprofilestop()
-- ... work ...
if t0 then Perf.Note("<pass>", debugprofilestop() - t0) end
```

Wire `perf` into `NS.COMMANDS` (the lib returns lines; the addon prints them) and check `Perf.suspended` as step 0 of the show-decision ladder. `<Addon>PerfDB` goes in the TOC and in `.luacheckrc`'s `globals`; `debugprofilestop` goes in `read_globals`.

### Tests (`tests/`, testing)

Headless plain-Lua-5.1 harness. The registry, the assertions, the source loader and the base WoW-API
mock are a **shared kit** vendored from the `LibKa0s` repo's root-level `testkit/` folder into
`tests/_kit/` — never hand-rolled (anti-pattern #47), never placed under `libs/` (it must not ship),
and never **edited** in a consumer: a kit problem is a fix upstream plus a re-vendor. Run
`lua tests/run.lua` from the repo root.

```
tests/
  _kit/              -- vendored, never edited: framework.lua, loader.lua, mock_base.lua, README.md
  run.lua            -- this addon's load list, lifecycle kick and suite list — and nothing else
  wow_mock.lua       -- a THIN extender over _kit/mock_base.lua, not a replacement
  test_<module>.lua  -- one suite per module
  perf.lua           -- offline scenario runner, outside the gate (performance-§9)
```

`tests/run.lua`:

```lua
local Kit    = dofile("tests/_kit/framework.lua")
local Loader = dofile("tests/_kit/loader.lua")
local mocks  = dofile("tests/wow_mock.lua")()
local NS = {}
Loader.addonName = "<Addon>"

-- The vendored library's files, in the order LibKa0s.xml uses them. The TOC pulls them in through
-- that one .xml, which tocFiles cannot see, so they are spelled out here — ALL of them. Omit one
-- and its module refuses to register, the host takes its degradation stub, and the suite happily
-- measures the stub: green, and testing nothing (testing-§9).
local LIB_FILES = {
  "libs/LibKa0s/Core.lua", "libs/LibKa0s/DebugLog.lua", "libs/LibKa0s/Slash.lua",
  "libs/LibKa0s/Options.lua", "libs/LibKa0s/OptionsWidgets.lua", "libs/LibKa0s/OptionsScroll.lua",
  "libs/LibKa0s/Perf.lua", "libs/LibKa0s/PerfPanel.lua",
}
-- The addon's own files come from the TOC rather than a copy of it, so this runner cannot drift
-- from what the client loads. A suite named here but missing from disk is SKIPPED, not failed.
local ADDON_FILES = Loader.tocFiles("<Addon>.toc")

Loader.loadAll(LIB_FILES, NS, mocks)
Loader.loadAll(ADDON_FILES, NS, mocks)

NS:InitDB()             -- mirror the in-game lifecycle …
NS.CreateOptionsPanel() -- … so the schema → widget layer is exercised as the client exercises it

_G.<ADDON>_TEST = Kit.expose{ NS = NS, mocks = mocks, loadedAddonFiles = ADDON_FILES }
Kit.run{ dir = "tests/", suites = { "test_loadorder", "test_schema", "test_database", ... } }
```

Suite shape — unchanged by the move to the shared kit, which is what made adoption one commit:

```lua
local T = _G.<ADDON>_TEST   -- Kit.expose merges in test + fail/assertEqual/assertTrue/assertFalse/
local NS = T.NS             -- assertNil/assertNear/assertError alongside your own keys
local test, assertEqual = T.test, T.assertEqual
test("Schema: every path resolves against defaults", function()
  assertEqual(NS.ValidateSchema(), 0)   -- 0 unresolved paths
end)
```

**What to test, now that most of the machinery is a library.** The library's internals are covered in
the `LibKa0s` repo and a second copy of those cases is the duplication this arrangement exists to
remove (testing-§8). What stays here is an **integration** suite over the wiring the addon owns: that
each descriptor is well-formed, that every declared perf bucket is reached by a real bracket, that
suspend genuinely makes *this* addon inert, and that the **degraded path** works — verified by
actually loading the addon with the library **absent** (feed the loader a deliberately partial file
list), never by hand-stubbing the member under test. And a test that cannot fail is worse than no
test: prove any negative assertion by mutating the implementation and watching it go red
(testing-§12).

Local toolchain (the full list, with `lizard` and its `pipx` workaround, is the root
`DEPENDENCIES.md` — see its starter snippet below):

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

### `.gitattributes`

**Write this file FIRST — before the TOC, before any Lua, before the first commit** (`line-endings`).
This is the canonical **client-bound** body from `line-endings-§5`, verbatim. Copy it; do not compose
your own. Eight repos in this collection hand-wrote this same policy into files of 22 to 68 lines,
which is why the body is now fixed rather than described. A **non-client** repo — one that ships
nothing into the WoW client — swaps the first pin line to `* text=auto eol=lf` and adjusts the two
sentences that name the direction; nothing else changes. A new addon is always the client-bound one.

Written first, it costs one file. Retrofitted later it costs `git add --renormalize .` plus a
whole-tree re-checkout, and that diff touches every line of every straggler — the kind of diff that
gets approved rather than reviewed. Do **not** ship a `.gitattributes` holding only the `*.sh` line:
the carve-out without the pin above it is explicitly **not** compliance (`line-endings-§1`).

```gitattributes
# =============================================================================
# Ka0s WoW Addon Standard — line-ending policy (line-endings-§2)
#
# Every repo in the Ka0s collection carries an explicit .gitattributes. There
# are exactly two variants of this file and they differ in one decision only:
# the pin below. Everything after it is byte-identical across the collection,
# so diffing a client-bound repo against a non-client one shows one decision,
# not two documents.
#
# Having no .gitattributes — or one that lists only exceptions to a rule that
# was never stated — is itself the defect. It leaves what lands on disk at the
# mercy of each contributor's `core.autocrlf` / `core.eol`.
# =============================================================================

# THIS REPO IS CLIENT-BOUND. It ships Lua into the WoW client, either directly
# as an addon or vendored into an addon's libs/ folder. The client expects
# CRLF in addon source, so the working tree is pinned CRLF on every platform.
#
# `text=auto` lets git classify text vs binary by content at add time. Text is
# always stored LF in the repository, so diffs and blame stay clean; `eol=crlf`
# pins what lands on disk at checkout and converts back on add. Because
# .gitattributes overrides per-user config, a Linux contributor on
# `core.autocrlf=input` and a Windows contributor on `true` end up with
# identical bytes, and LF stragglers written by tools that bypass git's filters
# (sed, WSL editors, generators) are corrected the moment they are staged.
* text=auto eol=crlf

# Shell scripts are LF, ALWAYS — even in a CRLF-pinned repo, where everything
# else is CRLF. `#!/usr/bin/env bash` followed by CRLF makes the kernel look for
# an interpreter literally named "bash\r", and every `case`/`in` line becomes a
# syntax error. The vendored tests/_kit/run-automated-tests.sh is the file this
# protects (automated-tests-§2); without this carve-out the runner is broken on
# every checkout rather than in one contributor's working tree.
*.sh text eol=lf

# Binaries — never line-end converted, never diffed as text. `text=auto` would
# usually detect these, but detection is content-based and a truncated or
# odd-header asset can fool it; marking them is cheap and removes the class of
# bug entirely. The list is the union of every binary type present anywhere in
# the collection plus the WoW media types an addon may add at any time.
#
# Images and textures
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.bmp binary
*.ico binary
*.tga binary
*.blp binary
# Fonts
*.ttf binary
*.otf binary
# Audio
*.mp3 binary
*.ogg binary
*.wav binary
# Archives and opaque data (model weights, tool payloads)
*.zip binary
*.tar binary
*.gz binary
*.7z binary
*.pdf binary
*.bin binary
*.param binary

# Renormalizing after this file is added or changed. The attributes only take
# effect for content as it passes through git, so an existing checkout must be
# rewritten once, in this order:
#
#   git add .gitattributes
#   git add --renormalize .
#   git status                 # review, then commit
#
# `--renormalize` rewrites the INDEX; it does not rewrite files already on
# disk. To fix a straggler in the WORKING TREE, delete it and check it out
# again (`rm <path> && git checkout -- <path>`), then count the bytes:
#   tr -dc '\r' < <path> | wc -c     # must equal…
#   tr -dc '\n' < <path> | wc -c     # …this, in a CRLF repo.
# Not `file <path>`: it reports nothing about line terminators for JSON or
# for any binary, so it passes files it never examined (line-endings-§7).
```

Then add `- .gitattributes` to `.pkgmeta`'s `ignore:` block below — it is dev-only, exactly as
`.gitignore` and `.luacheckrc` are (`packaging`).

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
  "Settings", "CreateColor", "debugprofilestop",   -- the perf bracket's clock (performance-§2)
}
globals = {
  "<Addon>DB",      -- the SavedVariables write target
  "<Addon>PerfDB",  -- the diagnostics capture ring (performance-§5)
}
```

### `.pkgmeta`

```yaml
package-as: <Addon>

# Libraries are vendored in libs/ and committed to git — NOT fetched as externals.

ignore:
  - .luacheckrc
  - .gitignore
  - .gitattributes   # dev-only: the repo's line-ending policy (line-endings)
  - docs        # holds docs/audits/ and docs/reviews/ too — all dev-only
  - tests
  - _dev
  - "*.bak"
```

Libraries are **vendored under `libs/` and committed** (`STANDARDS.md library-stack-§3`). Copy the folder-per-lib set you actually `LibStub()` from an existing Ka0s addon's `libs/` so versions stay consistent across the suite, and list them **first** in the TOC (`.xml` where the lib ships one, `.lua` otherwise). Pull libs the suite doesn't yet vendor (LibDataBroker-1.1, LibDBIcon-1.0, …) from a current retail install or the upstream release.

`libs/LibKa0s/` is the exception to "vendor only what you use": its **ship payload is the whole folder, always**, even the modules this release does not wire, because four of the five majors refuse to register without `Core.lua` and a shell without its attach file `:New`s successfully and then fails a panel build later (anti-pattern #48). It is also the one library that needs an ongoing **sync** rather than a one-time copy — `diff -r <LibKa0s>/LibKa0s libs/LibKa0s` must be empty, and every library change needs a **re-vendor commit** here, in its own commit, because both repos stay green while the copies diverge (anti-pattern #45). The `tests/_kit/` copy of `testkit/` is under the same discipline. Nothing under `libs/` is ever edited locally, not even a one-line fix that is plainly correct: the next re-vendor reverts it silently, with no cause anywhere in this repo's history.

### Docs — the root three + the `docs/` trio

Root ships exactly three docs plus `LICENSE`, and never a fourth: a **full** `README.md`, a **stub** `CLAUDE.md`, and `DEPENDENCIES.md` (documentation, documentation-§7). Everything else lives under `docs/`. The stub is short and **MUST** carry a `## Standards compliance (read first)` section (documentation-§6). **This pack is NOT copied into the addon** — see the banner at the top of this file. The `docs/` trio is `ARCHITECTURE.md`, `testing.md`, `smoke-tests.md`; five topic-detail docs are required alongside it — `test-cases.md`, `performance.md`, `perf-runs/README.md`, `automated-tests/README.md` and `automated-tests/RESULTS.md` (documentation-§3).

```markdown
<!-- root CLAUDE.md (STUB — never the full brief) -->
# CLAUDE.md — Ka0s <Name>

**Ka0s WoW addon.** Adheres to the **Ka0s WoW Addon Standard** —
https://github.com/tusharsaxena/WowAddonStandards

## Standards compliance (read first)

This repo is built to the **Ka0s WoW Addon Standard** (URL above). All development here — features,
refactors, doc changes — MUST conform to it. The standard is the source of truth for layout, TOC
shape, the Ace substrate, schema-driven settings, slash/prefix conventions, locales, Compat,
tests/lint, and doc structure.

**If a change would deviate from the standard, STOP and flag the deviation explicitly.** Do not
silently deviate and do not silently "fix" to match. Surface it and let the user decide which of
two things it is:

1. **An accepted deviation** — this addon intentionally differs; record it as a row in
   `docs/ARCHITECTURE.md` -> `## Documented deviations`, shaped
   `| Rule | What differs | Why | Decided | Re-check trigger |`. That register is the single home:
   a deviation not in it is not ratified.
2. **A change to the standard itself** — the standard's definition should evolve; the update
   belongs upstream in the WowAddonStandards repo, after which this addon conforms to the new rule.

When in doubt, treat standard conformance as a hard requirement and ask.

Start here, then read the docs:

- **`docs/ARCHITECTURE.md`** — module map, settings schema, message bus, slash surface, event
  wiring, taint notes, known limitations, documented deviations. What this addon actually is.
- **`docs/testing.md`** — how to verify: the headless harness, lint, and the green commit gate.
- Topic detail in `docs/` as needed (`schema.md`, `settings-panel.md`, `smoke-tests.md`, …).

Green gate before every commit: `lua tests/run.lua` and `luacheck .` (0/0). Never auto-stage/commit/
push and never bump the version without an explicit instruction.

Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).
```

That last line is **required** in any addon that vendors `libs/LibKa0s/` and belongs in **this** file,
not the README (documentation-§1 keeps the player-facing page free of a vendored-library inventory).
`vX.Y.Z` is the **tag** both vendored payloads — `libs/LibKa0s/` and `tests/_kit/` — were copied from,
and it moves in the **same commit** as the bytes. `tests/_kit/vendor_sync.lua` greps it with
`[Bb]undles %[LibKa0s%]%b() (v[%d%.]+)`, so it may stand alone as above or sit inside a sentence; since
**LibKa0s v1.8.1 / testkit revision 9** the gate reads `CLAUDE.md` and there is **no fallback** to
`README.md`, so a line left there fails the case naming `CLAUDE.md` (documentation-§2, testing-§11).

### Root `DEPENDENCIES.md` — the toolchain contract

The one doc a **new machine** needs first, which is exactly when the reader cannot yet run the addon
to find out what is missing. It sits at root, next to `README.md`, and answers *what to install*;
`docs/testing.md` answers *how to verify* — neither repeats the other (documentation-§7).

Fill in the blanks below, and **delete nothing but the placeholders**. Three rules do the work: every
entry names the **evidence** for itself (a file:line, a script's import, a documented command — a
speculative entry is worse than an omission), the three groups stay **separate** because most readers
need only one of them, and every install line is one that **actually works on WSL2 / Ubuntu** with a
one-line verification beside it. A `pip install lizard` on Ubuntu 24.04 fails on PEP 668's
`EXTERNALLY-MANAGED` marker — the reader concludes the tool is unavailable rather than that the doc
is stale, which is anti-pattern #50.

The baseline for a new Ka0s addon is: **lua5.1 + luac, luacheck (via luarocks), lizard (via pipx),
git, a POSIX shell** — and, for most addons, **no release or asset tooling at all**. Say so plainly
rather than deleting the heading: "none" is a result.

````markdown
# Dependencies — Ka0s <Name>

What you need installed to build, run, test or release this addon. Commands are for
**WSL2 / Ubuntu** (the collection's development environment). How to *verify* the addon once
you are set up is `docs/testing.md`; this file only covers *what to install*.

Every entry says what needs it and how that is known. Anything only plausibly required is
marked as such rather than listed as a requirement.

## Runtime (in-game) — what a player needs

- **World of Warcraft (Retail).** Single `## Interface:` line in `<Addon>.toc` — Retail only.
- **Nothing else.** Every library is vendored under `libs/` and committed (library-stack), so the
  player installs no separate library addon. `## OptionalDeps:` names the vendored libs for load
  ordering, not as things to download.
- *(If the addon has a real optional integration, name it here with its `IsAddOnLoaded` guard's
  file:line, and say what degrades without it.)*

## Development — the contributor toolchain

| Tool | Version | Needed for | Evidence |
|---|---|---|---|
| `lua5.1` (+ `luac`) | **5.1 exactly** | the headless suite, `lua tests/run.lua` | `tests/_kit/loader.lua` uses `setfenv` |
| `luacheck` | any recent | `luacheck .`, the other half of the green gate | `.luacheckrc` at the repo root |
| `lizard` | any recent | the `complexity` suite of `tests/_kit/run-automated-tests.sh` (automated-tests) | `lizard --version` |
| `git` | any recent | vendoring, `diff -r` against the LibKa0s repo | library-stack-§7 |
| POSIX shell | any | the commands in this file and in `docs/testing.md` | — |

**Lua 5.1 is a requirement, not a preference.** The harness sandboxes each source file with
`setfenv`, which was removed in 5.2 — "5.2 will probably work" is false and costs an hour to
disprove.

```sh
# Lua 5.1 and luacheck
sudo apt-get update
sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck

# lizard — via pipx, NOT pip. Ubuntu 24.04 marks its Python EXTERNALLY-MANAGED (PEP 668),
# so `pip install lizard` fails; pipx installs it into its own venv and puts it on PATH.
sudo apt-get install -y pipx
pipx ensurepath          # then open a new shell, or: source ~/.bashrc
pipx install lizard

# verify — each of these must print a version
lua5.1 -v                # Lua 5.1.5 …   (if `lua` is not 5.1, use lua5.1 explicitly)
luacheck --version
lizard --version
git --version
```

Versions are pinned only where a version matters: `lua5.1` is hard, `luacheck` and `lizard` are
"any recent" and pinning them would be false precision.

## Release / assets

**None.** This addon is packaged from the committed tree — nothing is generated at build time,
and no image or font tooling is needed to produce what ships. **None of this group is required to
build, run or test the addon.**

*(If that ever stops being true — a Python script that regenerates an atlas, a vendored binary and
the system library it links against — list it here with the script's import as evidence, and keep
the "not needed to build, run or test" sentence.)*

## Am I set up correctly?

```sh
lua tests/run.lua                                     # the suite — must be green
luacheck .                                            # must be 0 warnings / 0 errors
lizard -l lua -x "./libs/*" -x "./tests/_kit/*" .     # the complexity report (release-time)
```

See `docs/testing.md` for what those commands mean and when each is run.
````

Keep it current **in the change that adds the import**, not at the next audit: a dependency list that
is wrong is the specific failure that makes a new contributor's first hour their last. It is checked
at release with the rest of the doc set (documentation-§5). And listing a library here never licenses
fetching it at build time — libraries are vendored and committed (documentation-§7).

---

## Hard rules cheat sheet (memorize)

1. Every file starts with `local addonName, NS = ...`. No `_G[addonName] = {}`.
2. SavedVariables: `<Addon>DB` with `schemaVersion`, plus **`<Addon>PerfDB`** — the diagnostics capture ring, the one sanctioned non-AceDB global, deliberately outside the profile tree (savedvariables-§4, performance-§5). Exactly those two; a third is non-compliant.
3. License: MIT.
4. Folder casing: `<Addon>/` PascalCase, all subfolders lowercase (`libs/` not `Libs/`).
5. TOC: single latest-Retail `## Interface:` (Retail only), plus `X-Standard`, and `X-Curse-Project-ID` (mandatory once published on CurseForge). `X-Wago-ID` / `X-WoWI-ID` are optional — include each only if the addon is actually listed on that platform.
6. Slash: AceConsole `:RegisterChatCommand`. Never raw `SLASH_*`.
7. Locale: metatable fallback `__index = function(_,k) return k end`. Never AceLocale strict.
7a. **US English everywhere** (localization-§5): every English word you author — locale keys and their `enUS` values, chat/console output, options labels and tooltips, slash help, README and `docs/` prose, code comments, and identifiers — uses **US** spelling. `color` not `colour`, `gray` not `grey`, `behavior` not `behaviour`, `center`/`centered` not `centre`/`centred`, `canceled` not `cancelled`, `-ize`/`-ization` not `-ise`/`-isation`, `catalog`/`dialog`/`defense`/`license`/`analyze`. WoW's own API is US-spelled (`SetTextColor`, `GRAY_FONT_COLOR`), so a British-spelled identifier sits one letter from the Blizzard symbol beside it and greps miss. Locale **keys are the English string**, so fixing a spelling **changes the key** — update it in every `locales/*.lua` and at every call site in the same change, or the metatable silently renders the raw key on that client. Reproduce verbatim (never "correct"): Blizzard/library symbols, quoted external text, published proper nouns, and a deliberate `locales/enGB.lua` translation.
8. Options UI: **consume `LibKa0s-Options-1.0`** — one instance from a descriptor in `settings/OptionsSetup.lua`, and `NS.Helpers` **is** that instance, decorated in place, never a copy-across (options-ui-§1). Never hand-roll the shell, the widget makers, the flow engine, the header or the scrollbar patch (anti-pattern #47), and never copy a `LAYOUT` constant into the addon. Behind it: Blizzard `Settings.RegisterCanvasLayoutCategory` + raw AceGUI body, **category registered eagerly at load** (always visible), **body built lazily** on first `OnShow`, and the header's **Defaults button built lazily too**, in that same first `OnShow`, never at registration time (options-ui-§5) — AceGUI is shared and UI skins hook `RegisterAsWidget`, so a widget created during load keeps Blizzard's stock red `UI-Panel-Button-Up` art forever while later-created ones come out skinned, making the look a race against addon load order. Never AceConfigDialog for content; never defer registration to first `/config`. This one setup file's fallback is **load-completing, not member-answering** — the documented exception, because page files call into it inside schema-row literals at file load.
8a. Slash: **consume `LibKa0s-Slash-1.0`** — the dispatcher, help renderer, formatters, list builder and type-aware parser (slash-commands-§1). The addon keeps its ordered `NS.COMMANDS` table of **positional triples** `{name, desc, fn}` and passes it in; the library never owns it and never registers a chat command. Reserved verbs — `help get set list reset resetall config version debug perf` — mean the same thing in every Ka0s addon; `reset` takes a **path**, not a page.
9. Schema-as-single-source: one table drives panel widgets + slash + defaults reset. One write seam — the descriptors' `set`/`applyDefault` route through it, so a CLI change takes exactly the path a checkbox change takes.
10. Closed message bus: modules talk via `Ka0s_<Addon>_<Event>` messages, one sender each. No cross-module table reach.
11. All deprecated-API calls live in `Compat.lua`. Modules call `NS.Compat.X`. No `WOW_PROJECT_ID` flavor branching (Retail only).
12. Combat lockdown: gate `InCombatLockdown()` (secure writes — settings setters, secure-frame attributes) and defer those with `PLAYER_REGEN_ENABLED`. **Exception — options-panel open (options-ui-§2): refuse under lockdown, do not defer.** Print a gray `NS.PREFIX` notice ("cannot open settings during combat — Blizzard's category-switch is protected") and return; **never** `Settings.OpenToCategory` under lockdown, and **never** auto-open on `PLAYER_REGEN_ENABLED`. For combat-reactive *display/logic* use `UnitAffectingCombat(unit)` — **not** `InCombatLockdown()` (which is player-only and can raise *action blocked* if it gates a secure call at the combat boundary).
13. Per-frame loops: cache db values into module locals, refresh via `M:RefreshUpvalues()` on settings change.
14. ≥10 dynamic frames: use object pool (Acquire/Release/HideAll).
15. File LOC cap: ~1500. Peel when exceeded.
16. Vendor everything: commit all libs in `libs/`, loaded first in the TOC. Never use `.pkgmeta` `externals:` for libraries. **`libs/LibKa0s/` is copied WHOLE, every time** — every module, even unwired ones; a partial copy costs the addon majors it was not even touching (anti-pattern #48) — TOC-listed as the single line `libs\LibKa0s\LibKa0s.xml`, and kept **byte-identical** to its source repo (`diff -r` empty), with a re-vendor commit here after every library change, because both repos stay green while the copies silently diverge (library-stack-§7, anti-pattern #45). Nothing under `libs/` is ever edited locally.
16b. **Consume, never fork** (anti-pattern #47): the chat printer, the debug console, the slash dispatcher, the options toolkit, the performance harness and the test harness are `LibKa0s`. Adopting one is a **descriptor plus a degradation stub** in the addon's own setup file. Anything genuinely missing goes back into the library as an **additive** descriptor field so every consumer gets it — never a local patch, and never a private lookalike.
16a. **Performance harness** (performance): vendor `LibKa0s-Perf-1.0`, build `NS.Perf` from a descriptor in `core/PerfSetup.lua` (degrading to a working stub if the lib is absent), bracket hot paths with the gated `local t0 = Perf.on and debugprofilestop()` form — **zero work when off**, evidenced by the offline zero-overhead scenario, never by a comment — declare buckets with their `within` nesting, expose the reserved **`perf`** verb through `NS.COMMANDS` (the lib returns lines; never let it register a slash), declare `<Addon>PerfDB`, and implement `suspend`/`resume` so the addon goes inert **without a `/reload`** with visibility refused at the **source** of the show decision. Never hand-roll a probe, and never let a shared harness own a frame on your behalf (anti-patterns #43/#44). The **static** half of the same question — where the addon is getting hard to change — is the `lizard` run recorded in every automated-test bundle (rule 20e, automated-tests).
17. Debug: **consume `LibKa0s-DebugLog-1.0`** — one instance from a descriptor in `core/DebugLogSetup.lua`, with `NS.Debug` bound **bare** off it (debug-logging-§1). The window, both formatters, the 500-line buffer, the scrollbar, the counter and the enable seam are the library's; the addon owns the shipped monospace font (10pt), the flag, the `[Init]` summary and which flows are worth tracing. Enabled-state is **session-only** (`NS.State.debug`, default off, reset every `/reload`; never in SV, never copied into the library), decoupled from window visibility. Call the sink tag-first with the format deferred, coalesce to one line per pass, and log a settings change once, at the write seam.
18. Preview/test mode (preview-mode): addons with a positionable display SHOULD show placeholder data while unlocked and/or via `/<slash> preview`.
19. Tests: **vendor the shared kit** — the LibKa0s repo's root-level `testkit/` → `tests/_kit/`, never `libs/`, never edited locally (testing-§1). `tests/run.lua` keeps only the load list, the lifecycle kick and the suite list; `tests/wow_mock.lua` is a **thin extender** over `_kit/mock_base.lua`. Derive the addon's file list from the **TOC** and spell out the vendored library files explicitly, in XML order (testing-§9). TDD. `lua tests/run.lua` green **and** `luacheck .` clean **before every commit**.
19a. Test-case inventory & badge (testing-§5): ship a **generated** `docs/test-cases.md` (full per-suite case enumeration + totals, produced by a `--list` mode of the runner — `lua tests/run.lua --list > docs/test-cases.md`, never hand-authored; it is the authoritative pass count) and a **static** X/Y `[tests]` README badge. Regenerate the doc and update the badge **in the same change** whenever the suite changes (a case added/removed/renamed or the count moved). No CI.
20. Docs: root ships **exactly three** docs plus `LICENSE`, and never a fourth — full `README.md`, **stub** `CLAUDE.md`, `DEPENDENCIES.md` (documentation-§7); everything else under `docs/`. Canonical `docs/` **trio** (all addons): `ARCHITECTURE.md`, `testing.md` (verify-how-to), `smoke-tests.md`. `ARCHITECTURE.md` carries **nine** mandated sections, named rather than counted: Overview, Module Map, Settings Schema, Message Bus, Slash Commands, Event Subscriptions, Taint Notes, Known Limitations, and **`## Documented deviations`** — the single home for a ratified deviation, rows shaped `| Rule | What differs | Why | Decided | Re-check trigger |` with Rule a `filename-§N` reference and Re-check trigger the condition that ends it. Present even when empty ("None."); a deviation not in the register is **not** ratified, and an audit reads it first rather than re-filing what it records (documentation-§3, audit-review-history). **Five** topic-detail docs are required, not optional: generated `test-cases.md` (testing-§5), `performance.md`, `perf-runs/README.md` (performance-§8, in-game captures), `automated-tests/README.md` and generated `automated-tests/RESULTS.md` (automated-tests); further topic-detail docs as needed. **MUST NOT** ship `docs/agent-context.md` — this pack is fetched at runtime, never stored (documentation-§3, anti-pattern #49). The **stub `CLAUDE.md`** carries, in order: the H1, the adherence line, `## Standards compliance (read first)`, the "read the docs" pointer list, the green-gate line, and — in any addon that vendors `libs/LibKa0s/` — the **LibKa0s provenance line**, exactly `Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).` naming the **tag** the payload was copied from and moving in the **same commit** as the bytes. `tests/_kit/vendor_sync.lua` greps that line out of `CLAUDE.md` with `[Bb]undles %[LibKa0s%]%b() (v[%d%.]+)` — a standalone sentence and a mid-sentence phrasing both satisfy it — and since **LibKa0s v1.8.1 / testkit revision 9** there is **no fallback to `README.md`**: a line left in the README reads as no line at all and the gate fails, naming `CLAUDE.md` (documentation-§2 item 6, testing-§11). Media in typed `media/` subfolders. No drift; sync before every release. (documentation-§3)
20d. **`DEPENDENCIES.md` at root** (documentation-§7): every piece of software needed to build, run, test or release the addon, each with the **evidence** for it (file:line, a script's import, a documented command — never a speculative entry), split **runtime / development / release-and-assets** because most readers need one group only, with copy-pasteable **WSL2 / Ubuntu** install commands that actually work and a one-line **verification** per tool. `lua5.1` is a hard version requirement (the harness uses `setfenv`); `luacheck`/`lizard` are "any recent". `pip install lizard` **fails** on Ubuntu 24.04 (PEP 668 `EXTERNALLY-MANAGED`) — use `pipx install lizard`. Refresh it in the change that adds the dependency, not at the next audit; an undocumented or drifted toolchain is anti-pattern #50.
20e. **Automated test record** (automated-tests): run the **vendored** `tests/_kit/run-automated-tests.sh` — never an addon-side copy — and commit the frozen bundle it writes to `docs/automated-tests/<YYYYMMDD-HHMMSS>/` (one file per suite plus `manifest.json`), plus the row it prepends to `docs/automated-tests/RESULTS.md`. **`lint` and `tests` gate; `perf` and `complexity` are recorded and never fail a run** — a threshold that fails a run teaches the collection to reach for `--no-verify`, after which the gate protects nothing and the habit remains. A missing tool is a **skip recorded with its reason**, never a pass: a green run that silently measured nothing is worse than a red one, because it is believed. `RESULTS.md` is **one** file overwritten in place — never dated, never a directory — so its git history is the trend line, and it carries the current complexity watch list with a one-line disposition for everything the tool warned on and every file in the 1000–1500 LOC band ("None." when empty). The checkpoint is **release, not commit**: a full bundle with an `ANALYSIS.md` in the same change that bumps the version, **before** the tag. Never gate commits on the full bundle (the green gate is `--suite lint --suite tests --no-bundle`, which writes nothing), never hand-write a number into a bundle, and never edit a bundle once written. `.gitattributes` **MUST** exist at the root and carry the **whole** policy rather than the exception alone: the pin its repo kind requires (`* text=auto eol=crlf` for an addon), `*.sh text eol=lf` — without which the vendored runner arrives CRLF and the kernel looks for an interpreter named `bash\r` — and the `binary` markings, all verbatim from `line-endings-§5`. A file carrying only the `*.sh` line satisfies nothing (`line-endings-§1/§2/§3/§4`, automated-tests-§2, anti-pattern #57).
20a. `README.md` is a **player-facing** document that renders on **CurseForge as well as GitHub** — so it **MUST NOT** use `<…>` angle-bracket placeholders anywhere (CurseForge strips them as HTML even inside backticks; write the argument bare, keep `[…]` for optional ones) nor percent-escapes for spaces in badge URLs. Deliberate HTML like `<br>` is fine. It is a document — written for the person who installed the addon (what it does, how to use it, how to fix common problems), in plain language, free of internal jargon and machine-generated tells; contributor material (test harness, lint, build, internals) stays out of it, under `docs/`. It follows the **canonical section order** (documentation-§1): title → badges (`[wow]` → version → license → standard → `[tests]`, that exact order and these exact templates: `![WoW](https://img.shields.io/badge/WoW-<Expansion>_<X.Y.Z>-purple)`, `![CurseForge Version](https://img.shields.io/curseforge/v/<projectId>)`, `![License](https://img.shields.io/badge/License-MIT-orange)`, `![Standard](https://img.shields.io/badge/Ka0s-WoW_Addon_Standard-yellow)`, `![Tests](https://img.shields.io/badge/Tests-<X>%2F<Y>_passing-green)`; the `[wow]` and `[tests]` badges MUST be updated in lockstep with the TOC `## Interface:` and the test inventory respectively; **the standard badge is deliberately NOT a link and MUST NOT be re-wrapped in one** — the binding standards-repo reference is the TOC `X-Standard` field and the `CLAUDE.md` "Standards compliance" section (documentation-§6), so the badge is a declaration on a player-facing page, not navigation for a reader who was never its audience) → logo → description → **What's new in `<X.Y.Z>`** (top user-facing highlights of the current release, mirroring the newest Version History row; rolled forward on every version bump) → Screenshots → Usage (Slash commands + Settings panel tables) → How it works → FAQ → Troubleshooting → **Issues and feature requests** (→ GitHub issues) → Version History → **optional `## Credits`, last** (there is **no** `## Testing` section — verify-how-to lives in `docs/`; the README keeps only the `[tests]` badge). **The README MUST NOT carry a bundled-library inventory** — no `## Libraries`, `## Bundled libraries`, `## Libraries and credits`, `## Credits and libraries` or `## Credits and bundled libraries` section, and no library list in the intro prose. Which libraries the build vendors is a contributor fact and lives in `DEPENDENCIES.md` and `docs/ARCHITECTURE.md`; the LibKa0s provenance line lives in root `CLAUDE.md` (rule 20, documentation-§2). A `## Credits` section is **optional** and carries **only external** credit — third-party artwork, another author's work, a font or a sound pack — never a vendored-library list; with nothing external to credit, ship no such section. TOC follows the fixed field order + `#`-section file listing (toc-file-§1/toc-file-§5).
20b. **No `TODO.md`** in a released addon — backlog lives in **GitHub issues** (documentation-§4). Only an unreleased, in-development addon may keep a `docs/TODO.md`, deleted before first release.
20c. **Standards reference in project memory & context** (documentation-§6): the reference to the standard MUST appear in **three** places — TOC `X-Standard`, README standard badge, and the root `CLAUDE.md` `## Standards compliance (read first)` section. There is no fourth place; the old one was a file the standard now forbids. STOP and flag any change that would deviate; the user classifies it as an accepted deviation (recorded here) or a change to the standard itself (made upstream, then adopted).
21. Audits & reviews: archive every audit under `docs/audits/<YYYY-MM-DD>/` and every code review under `docs/reviews/<YYYY-MM-DD>/`, each a 5-artifact bundle (audit-review-history). Kept, not deleted.
22. Versioning: semver. Bump TOC, code constants, README. `wow-addon:bump-version` automates this. Bump `## Interface:` + README `[wow]` badge each patch.
23. Git: trunk-based. Commit to the default branch on a **green** unit of work; no feature branches unless the human asks. Never push unless asked.
24. Standalone main window (data browser/log/tracker): non-secure `CreateFrame` (no combat gate), `UISpecialFrames` (ESC), persist pos/size in SV, scale setting, lazy tabs, pooled rows — and take the look from **`LibKa0s-Core-1.0`'s shared `SKIN` + `ApplySkin`** (and `MakeCloseButton`) rather than a private lookalike, so a re-skin has one touch point across the collection. Reach `ApplySkin` through Core itself; only `MakeCloseButton` is re-exported on the console instance. The look it draws is normative and is **two lines, not one** — a flat 1px black outer edge with a 1px gray highlight just inside it, plus a gold title and a gray divider; assign `frame.title` / `frame.divider` and let `ApplySkin` tint them, and **never** hardcode the values. See standalone-windows, "The Ka0s window edge".

## Forbidden patterns

- `_G[addonName] = {}` (use private NS).
- AceLocale strict mode.
- **Hand-rolling anything a `LibKa0s` module already provides** (anti-pattern #47) — a private debug console (window, buffer, formatters, scroll sync, copy box), a private options toolkit (shell, widget makers, flow engine, header, scrollbar patch), a private slash dispatcher/help renderer/value parser, a private chat printer or secret-safe stringifier, or a hand-written `tests/` framework. Each of these *was* per-addon code here, which is how the collection learned the rule: one formatter existed seven times over, subtly differently, and a fix landed in one of them with nothing going red to say so. Consuming is a descriptor plus a degradation stub.
- **Forking the vendored copy** — editing anything under `libs/LibKa0s/` or `tests/_kit/`, even a plainly correct one-liner. Fix it upstream and re-vendor; the next re-vendor reverts a local patch silently, leaving a regression with no cause in this repo's history.
- **Partial or per-module re-vendoring** of `LibKa0s` (anti-pattern #48) — copying `Perf.lua` without `Core.lua`, or a shell file without its attach file — or naming the module files individually in the TOC instead of the single `libs\LibKa0s\LibKa0s.xml`. Copy the ship folder whole.
- Copying a library `LAYOUT` constant, formatter, color code or parser into the addon (including into a degradation stub) — a host copy is the copy that goes stale.
- AceConfigDialog for non-Profiles content.
- Raw `SLASH_*` registration.
- `if cmd == "x" then elseif ...` slash dispatchers.
- Named-field entries in `NS.COMMANDS` — the library reads positional triples, so named fields make every verb unknown and the help block empty.
- Letting a library register a slash command, or own `NS.COMMANDS`.
- Vendoring the test kit to `libs/` (it must not ship) or editing it in place.
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
- Full agent brief in the root `CLAUDE.md` (root is a stub; there is no in-repo brief — `docs/ARCHITECTURE.md` and `docs/testing.md` carry the durable context).
- A fourth doc at root, or a missing one: root is `README.md` + `CLAUDE.md` + `DEPENDENCIES.md` + `LICENSE` (documentation-§7).
- `pip install <tool>` as an install instruction (fails on Ubuntu 24.04's PEP 668 marker — use `pipx`), or any dependency listed without the evidence for it (anti-pattern #50).
- A dated `docs/complexity/<date>.md` pile, a locally tuned `lizard` invocation, a hand-edited complexity report, or a regenerated one with no watch-list disposition for what newly crossed a threshold (anti-pattern #51).
- Gating **commits** on the complexity report — that checkpoint is lint + the harness only (performance-§10, testing-§4). The **release** is a different gate: all four suites plus zero functions above CCN 15, evaluated by the release command from the run's manifest before it edits anything, with a `skip` counting as NOT EVALUATED rather than a pass (automated-tests-§3).
- Implementing the release gate by editing the vendored runner's exit code — the same script is the commit gate, so the threshold would fire on every commit (automated-tests-§3).
- Bumping a version, rolling `## What's new` or cutting a tag on a run where a gate failed or a suite went unmeasured.
- A complexity watch list where every entry reads **"accepted"** — a disposition has a shelf life; carried across three consecutive release runs it is fixed or converted to a tracked deviation with an ID (anti-pattern #53).
- Refactoring to move a CCN number rather than to make the code readable — a body dumped into a `part2`/`doTheRest` helper so the wrapper scores well, or a dispatch table built **inside** the function it serves, which trades branches for a per-call allocation (anti-pattern #52, performance-§11).
- `t.k = stored.k or D.k` over a settings table — `or` cannot tell *unset* from *stored `false`*, `""` or an empty set, so the user's "off" comes back on. Test with `== nil` (savedvariables-§5, anti-pattern #54).
- Refactoring an untested function without first pinning its behavior in a characterization test **run against the unrefactored code** (testing-§13).
- Promoting a shape into `LibKa0s` because it is repeated rather than shared — one needing a behavior flag per consumer, or promoted on raw frequency where the shape carries almost no meaning (anti-pattern #55, library-stack-§7).
- `TODO.md` in a **released** addon (track the backlog in GitHub issues; allowed only in an unreleased, in-development addon, deleted before first release).
- Non-canonical `README.md` section order, or a TOC departing from the required field order / file-listing structure (documentation-§1, toc-file-§1/toc-file-§5).
- Missing the standards reference in project memory & context: no `## Standards compliance (read first)` section in `CLAUDE.md` (documentation-§6).
- Shipping this pack in the repo as `docs/agent-context.md` or under any other name (documentation-§3, anti-pattern #49).
- British spelling in authored English text — `colour`/`grey`/`behaviour`/`centre`/`cancelled`/`-ise`/`-isation` in a locale key or value, a player-visible string, a comment, an identifier, or docs (localization-§5, anti-pattern #46).
- Creating a feature branch without an explicit request (work trunk-based).

---

## Definition of done (new addon ready for v0.1.0 release)

- [ ] TOC has all required fields incl. single latest-Retail `## Interface:`, `X-Standard`, and `X-Curse-Project-ID` (once published on CurseForge). `X-Wago-ID` / `X-WoWI-ID` are optional — only if listed on that platform.
- [ ] `.pkgmeta` present with **no** `externals:` block; all libs vendored and committed under `libs/`.
- [ ] `.luacheckrc` present; `luacheck .` reports **0 errors**.
- [ ] **`libs/LibKa0s/` vendored WHOLE** from the library repo's ship folder — every module, byte-identical (`diff -r` empty, library-stack-§7) — and TOC-listed as the single line `libs\LibKa0s\LibKa0s.xml` in the `# Libraries` block after Ace3.
- [ ] **The five setup files present**, each a descriptor plus a degradation stub and nothing more: `core/CoreSetup.lua`, `core/PerfSetup.lua`, `core/DebugLogSetup.lua`, `settings/Slash.lua`, `settings/OptionsSetup.lua`. No hand-rolled console, options toolkit, dispatcher, printer or harness anywhere in the addon's own source (anti-pattern #47). Each stub answers **every** member the addon actually calls.
- [ ] `tests/_kit/` vendored from the LibKa0s repo's root-level `testkit/` (**not** under `libs/`, not edited); `tests/wow_mock.lua` is a thin extender over `mock_base.lua`; `tests/run.lua` derives the addon's file list from the TOC and lists the vendored library files explicitly in XML order (testing-§1, testing-§9).
- [ ] `tests/` harness present; `lua tests/run.lua` is **green**; behavior is covered test-first (testing).
- [ ] Generated `docs/test-cases.md` inventory present and in sync (`lua tests/run.lua --list`); README carries a static X/Y `[tests]` badge (testing-§5).
- [ ] `Compat.lua` exists (even if scaffold); no `WOW_PROJECT_ID` flavor branching.
- [ ] `Locale.lua` exists with metatable fallback.
- [ ] **US English spelling** throughout (localization-§5) — locale keys/`enUS` values, all player-visible strings, comments, identifiers, README and `docs/`; no `colour`/`grey`/`behaviour`/`centre`/`cancelled`/`-ise` in authored text (Blizzard/library symbols, quoted external text, and any `enGB.lua` translation excepted).
- [ ] `Database.lua` exists with `RunMigrations()` (even if no migrations yet).
- [ ] Schema has at least one row and one write seam; the slash and options descriptors both route `set`/`applyDefault` through it, so the CLI and the panel cannot drift onto different code paths.
- [ ] Slash dispatcher built from `LibKa0s-Slash-1.0` with the addon's own ordered `NS.COMMANDS` (positional triples) passed **in**; the reserved verbs answer identically, `reset` takes a **path**, and `perf` is registered by the addon, not the library.
- [ ] AceConsole `:RegisterChatCommand` registered (primary 2–3 char verb + full-name alias); no `SLASH_*`.
- [ ] Options panel built from `LibKa0s-Options-1.0` — `NS.Helpers` **is** the instance — using `Settings.RegisterCanvasLayoutCategory`, **category registered eagerly at load** (entry always visible), **body built lazily** on first `OnShow`, and a landing page whose command list is generated from `NS.COMMANDS`.
- [ ] The header **Defaults button** is created in the first `OnShow` (not at registration), via the library's `EnsureDefaultsButton` called at the **top of every `OnShow`**, with its callback parked on the panel (`panel.defaultsOnClick`) — options-ui-§5, anti-pattern #42.
- [ ] The options setup file's fallback is **load-completing** (the documented exception, options-ui-§1) and its member set was determined by **measurement** — deleting one and re-running the library-absent load — with both the member set and the resulting schema row count pinned by cases.
- [ ] Combat-lockdown: secure writes defer on `PLAYER_REGEN_ENABLED`; options-panel open **refuses** under lockdown (gray notice, no defer — options-ui-§2).
- [ ] **Debug console wired (debug-logging)** — `core/DebugLogSetup.lua` builds `NS.DebugLog` from a descriptor (`name`, `title`, `font`, `isEnabled`/`setEnabled` over the addon's **own** flag, `initSummary`, call-time `print`/`safeToString` forwarders) and publishes `NS.Debug` bare; the monospace TTF + its `OFL.txt` ship under `media/fonts/` and are LSM-registered; enabled-state is **session-only** and never in SV, decoupled from window visibility; `/<slash> debug` toggles the window and `on|off` route through the single `SetEnabled` seam. **The window, the formatters, the buffer, the scrollbar and the counter are NOT in the addon's source** — an audit must not ask for them. (No-window addons MAY use chat.)
- [ ] Debug **coverage** (debug-logging-§8–§10): the main functional flows traced as one gated line each including the not-recorded decisions, repeating paths coalesced to one summary line per pass with the string-building behind the gate, and every settings change logged once at the write seam.
- [ ] **Performance harness wired (performance)** — `core/PerfSetup.lua` builds `NS.Perf` from a descriptor and degrades to a working stub when the lib is absent; TOC lists `PerfSetup.lua` before its consumers; hot paths use the gated bracket idiom (performance-§2); declared buckets with `within` nesting (performance-§3); `perf` verb in `NS.COMMANDS` (performance-§4); `<Addon>PerfDB` declared in the TOC and `.luacheckrc`; `suspend`/`resume` make the addon inert without a reload, with visibility refused **at the source** (performance-§6).
- [ ] Integration suite covers the addon-side wiring of **every** adopted module — descriptors well-formed, **every declared perf bucket actually reached** by a real bracket, suspend genuinely inert, and each lib-absent path exercised by loading the addon **without** the lib rather than by hand-stubbing (testing-§8). No duplicate of the library's own cases (they live in the `LibKa0s` repo), and every negative assertion proven falsifiable by mutation (testing-§12).
- [ ] `tests/perf.lua` offline runner present, **outside** the green gate, asserting only deterministic quantities and shipping a zero-overhead scenario as evidence that instrumentation is free when capture is off (performance-§9). Its scenarios are **not** counted in `docs/test-cases.md` or the `[tests]` badge.
- [ ] `docs/performance.md` and `docs/perf-runs/README.md` present (documentation-§3); `perf-runs/` scoped to **in-game** captures (automated-tests-§7).
- [ ] **`.gitattributes` present at the repo root and byte-identical to the client-bound canonical body** (`line-endings-§5`) — `* text=auto eol=crlf`, `*.sh text eol=lf`, binaries marked `binary` — **and the working tree agrees with it**, proven by `git add --renormalize .` staging nothing and emitting no `LF will be replaced by CRLF` warning. It is the repo's **first** file (step 0), and it appears in `.pkgmeta`'s `ignore:` block (`line-endings-§1/§2/§3/§4/§6`, `packaging`).
- [ ] `tests/_kit/run-automated-tests.sh` vendored and executable, and `docs/automated-tests/{README.md,RESULTS.md}` exist (automated-tests-§2/§4). The runner's `*.sh` carve-out is covered by the line-endings checkbox above; this one covers the runner.
- [ ] **A full automated-test bundle produced by the vendored runner** — `tests/_kit/run-automated-tests.sh`, never an addon-side copy — committed under `docs/automated-tests/<YYYYMMDD-HHMMSS>/` with one file per suite plus `manifest.json`, and its row prepended to `docs/automated-tests/RESULTS.md`. `RESULTS.md` carries the current watch list with a disposition for everything `lizard` warned on and every file in the 1000–1500 LOC band ("None." if empty). Produced at every **release**, before the tag; commits are **not** gated on it, and `perf`/`complexity` never fail a run (automated-tests-§3/§4/§6, anti-pattern #51).
- [ ] Preview/test mode (preview-mode) if the addon has a positionable display.
- [ ] Media in typed `media/` subfolders (`logos/`, `screenshots/`, …).
- [ ] Root = the three docs plus `LICENSE`, and nothing else: full `README.md` (with `[wow]` badge + the **unlinked** standard badge), **stub** `CLAUDE.md`, `DEPENDENCIES.md`. Canonical `docs/` **trio** present (`ARCHITECTURE.md` — all **ten** mandated sections including `## Documentation map` and `## Documented deviations`, the latter written as "None." at v0.1.0 rather than omitted; `testing.md`; `smoke-tests.md`) plus the five verification-and-record docs (`test-cases.md`, `performance.md`, `perf-runs/README.md`, `automated-tests/README.md`, `automated-tests/RESULTS.md`) plus **all six Tier 1 topic-detail docs** under exactly those names (`scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`, `data-flow.md`, `common-tasks.md` — documentation-§3), with every **Tier 2** trigger evaluated and each doc either shipped or carrying a *Not applicable* row in `## Documentation map`, and every `.md` under `docs/` appearing in that map exactly once; **no `docs/agent-context.md`**, **no `docs/complexity.md`** (retired v2.19.0), **no `docs/file-index.md`** and **no `docs/conventions.md`** (retired v2.23.0); passes the drift check.
- [ ] **Root `DEPENDENCIES.md` present and evidence-based** (documentation-§7) — runtime / development / release-and-assets kept separate, every entry naming what needs it and how that is known, WSL2/Ubuntu install commands that actually run (`pipx install lizard`, **never** `pip install lizard` — PEP 668) with a one-line verification per tool, `lua5.1` stated as a hard requirement with its reason (`setfenv`), and the release/assets group saying "none" plainly when the addon has no such tooling.
- [ ] **Standards reference in memory & context (documentation-§6)** — all three present: TOC `X-Standard`, README standard badge (**not** wrapped in a link), and the root `CLAUDE.md` `## Standards compliance (read first)` section.
- [ ] `README.md` is player-facing and plain-language (no contributor material, no `## Testing` section) and follows the canonical section order (documentation-§1), including a **`## What's new in <X.Y.Z>`** highlights section above the screenshots (mirrors the top Version History row; rolled forward on each version bump), **Usage** (Slash-commands + Settings-panel tables), **Issues and feature requests** (→ GitHub issues), and **Version History**.
- [ ] **No bundled-library inventory in `README.md`** (documentation-§1, anti-pattern #58) — no `## Libraries` / `## Bundled libraries` / `## Libraries and credits` / `## Credits and libraries` / `## Credits and bundled libraries` section and no library list in the intro prose. An optional `## Credits` section, last, carries **only external** credit (artwork, fonts, sound packs, another author's work) and never a library list.
- [ ] **LibKa0s provenance line in root `CLAUDE.md`** (documentation-§2 item 6, anti-pattern #59) — `Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).` naming the tag `libs/LibKa0s/` and `tests/_kit/` were vendored from, landing in the same commit as the bytes. **Not** in `README.md`: the gate reads `CLAUDE.md` with no fallback and fails the case if the line is not there.
- [ ] TOC follows the fixed field order and `#`-section file-listing structure (toc-file-§1/toc-file-§5).
- [ ] **No `TODO.md`** at release (backlog is in GitHub issues); any pre-release `docs/TODO.md` has been removed (documentation-§4).
- [ ] LICENSE = MIT full text.
- [ ] First entry in `docs/audits/<YYYY-MM-DD>/` (even if just a "Hello world" smoke test).

---

## Patterns to reproduce (described, not named)

When stuck, reproduce these patterns — each already exists somewhere in the collection in the cited
dimension. (Per the standard's reading-guide convention, they are described by their role, not by addon name; the
named evidence is in `INDUSTRY_RESEARCH.md`.)

**Read this table as *wiring* patterns, not build instructions.** The console, the options toolkit,
the dispatcher and the test framework are `LibKa0s` modules — what an addon reproduces is the shape
of its **setup file**, never the machinery inside.

| Need | Reproduce this pattern |
|---|---|
| Adopting a shared module | One setup file per module holding exactly two things: a **descriptor** naming where the host's values live, and a **degradation stub** carrying every member the addon calls, resolved as `LibStub(major, true)` and guarded before `:New`. Nothing of the library's own rendering is copied into the stub. |
| Schema structure | A single `Schema` table whose rows (`path/default/type/label/widget/validate/onChange`) drive AceDB defaults, AceGUI widgets, slash dispatch, and reset — with a boot-time validator that warns on any `path` not resolving against defaults. |
| Macro/protected-API firewall | A single `MacroManager`-style module that is the **only** caller of `CreateMacro`/`EditMacro`; no other file touches protected macro APIs. |
| Modular layout | `core/` + `modules/` + `defaults/` + `settings/` + `locales/` with strict TOC load order and idempotent `NS.<Module> = NS.<Module> or {}` publication. |
| Closed message bus | A handful of `Ka0s_<Addon>_*` messages, one sender each, documented in `docs/ARCHITECTURE.md`; consumers register by name, no cross-module table reach. |
| Compat module | One `Compat.lua` that owns every deprecated/cross-patch API call and exposes shimmed wrappers (`Compat.GetSpellInfo`, `Compat.GetSpecialization`). |
| Taint-free chat formatting | Override `_G[GLOBALSTRING]` values rather than hooking chat events or replacing `AddMessage`; order filter registration deterministically. |
| Combat-lockdown cascade | A layered `InCombatLockdown()` guard on secure writes (settings-setter → secure-frame-show), each deferring on `PLAYER_REGEN_ENABLED`. **Config-open is the exception: it refuses with a gray notice, never defers** (options-ui-§2). |
| Eager settings registration + lazy body | Register the Blizzard **category** at load (bootstrap on `ADDON_LOADED(Blizzard_Settings)`/`PLAYER_LOGIN`, or in `OnInitialize`); build the panel body only in the first `OnShow`. |
| On-screen debug console | A descriptor handing `LibKa0s-DebugLog-1.0` the four things only the host knows — the frame-name prefix and title, the path of the monospace font the addon ships, an `isEnabled`/`setEnabled` pair over the addon's **own** session-only flag, and an `initSummary` callback the library emits on enable — plus `NS.Debug` bound bare off the instance. The window, the two formatters, the buffer, the scrollbar, the counter, Clear/Copy and the title-bar toggle come with it; none of them appear in the addon's source. |
| Debug coverage that reads back | Gated one-line traces at the main functional flows *including the not-recorded decisions*, a repeating pass collapsed to a single summary line carrying its counts and id lists (with the list-building itself behind the gate), and settings changes logged once at the write seam rather than re-echoed by every reactor. |
| Preview/test mode | Placeholder data fed through the real render path while the display is unlocked and/or via `/<slash> preview`. |
| Headless test harness | A vendored `tests/_kit/` (registry, assertions, sandboxed loader, base mock) consumed by a `tests/run.lua` that carries only the load list, the lifecycle kick and the suite list — the addon's own files derived from the **TOC**, the vendored library's files spelled out in XML order — plus a `wow_mock.lua` that extends the base mock per key rather than replacing it, and per-module `test_*.lua` suites. |
| Degraded-path proof | A second, deliberately partial file list that loads the addon **without** a library, so the host's own setup file takes its real fallback and the suite asserts on that — never a stub the test wrote for itself. |
| Lazy first-OnShow panel build | Latch (`rendered` flag) so the AceGUI body builds once, on first `OnShow`, when the panel width is non-zero. |
| Lazy header Defaults button | The library's `EnsureDefaultsButton(panel)` at the top of every `OnShow` (outside the `rendered` guard) builds the AceGUI `Button` once, after every addon has loaded — so a UI skin's `RegisterAsWidget` hook is already in place and the button isn't left on stock red art (options-ui-§5). |
| Soft-fallback discipline | Load-safe shims for missing optional libs (AceDB-missing flat table, LSM-missing Blizzard constants) so the addon runs with `OptionalDeps` absent. |
| Performance capture | One descriptor in `core/PerfSetup.lua` building a per-addon instance of the vendored harness; gated brackets at the real entry points (event handler, coalesced pass, per-item work) with declared nesting; a `perf` verb whose bare form opens a step panel that offers only the next legal step; `suspend`/`resume` making the addon inert without a reload, with the suspended check as step 0 of the show-decision ladder so nothing can re-show a frame behind suspend's back. |

---

## Skills you should use while building

(All under `wow-addon:` prefix in your local Claude Code plugin.)

- `wow-addon:new-addon` — scaffold a new addon (Ace3 stack, AceDB, modular folder layout, MIT license, slash command).
- `wow-addon:standards-audit` — audit the current addon against the standard. Produces the `docs/audits/<DATE>/` deviation + remediation bundle (audit-review-history).
- `wow-addon:review` — principal-engineer code review of the current addon. Produces a `docs/reviews/<DATE>/` findings bundle (audit-review-history).
- `wow-addon:sync-docs` — eliminate doc drift across README, CLAUDE.md, ARCHITECTURE.md.
- `wow-addon:bump-interface` — bump the single TOC Interface line to the latest Retail patch.
- `wow-addon:bump-version` — bump version everywhere (TOC, code constants, README badges + Version History, CLAUDE/ARCHITECTURE, CHANGELOG).
- `wow-addon:diff` — summarize uncommitted changes with risk assessment.
- `wow-addon:commit` — generated-message commit.
