> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Layout

Every Ka0s addon uses one **modular** folder layout — `core/`, `defaults/`, `settings/`, `locales/`, `modules/` — regardless of size. There is no flat/small-addon variant; a three-file utility and a multi-feature suite share the same skeleton so every repo reads identically and any file has one obvious home.

### 1. Modular layout

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
  media/                   -- typed subfolders only (layout-§3)
  libs/                    -- vendored Ace3 + other libs, committed to git (library-stack-§3)
  tests/                   -- headless Lua 5.1 harness (testing)
  docs/                    -- ARCHITECTURE.md, agent-context.md, smoke-tests.md, planning/reference (documentation)
    audits/<YYYY-MM-DD>/   -- audit-run history (retained; audit-review-history)
    reviews/<YYYY-MM-DD>/  -- code-review history (retained; audit-review-history)
  README.md                -- full, user-facing (stays at root)
  CLAUDE.md                -- STUB: short pointer into docs/ (documentation)
  LICENSE
  .luacheckrc
  .pkgmeta
```

- **MUST** use this folder layout — source lives under `core/`, `defaults/`, `settings/`, `locales/`, `modules/`; never loose at the root. A small addon simply has thin folders (a single `modules/` file, a one-row `settings/Schema.lua`), not a different structure.
- **MUST** load order: `core/Compat.lua` → `core/Constants.lua` → `core/Namespace.lua` → other `core/*` → `defaults/*` → `locales/*` → `settings/*` → `modules/*`.
- **MUST** cap any single `.lua` file at 1500 LOC. Files in the 1000–1500 band are on notice; a >1500 file is a bug — peel it.
- **MAY** peel an oversized file into 2-3 sibling files in the same folder (e.g. `settings/Schema.lua` → `settings/Schema_Core.lua`, `settings/Schema_Display.lua`).

### 2. Casing

- Addon root folder: **PascalCase** matching the `## Title:` in TOC (minus the `Ka0s ` prefix).
- Subfolders: **lowercase** (`core/`, `modules/`, `libs/`, `media/`, `defaults/`, `settings/`, `locales/`, `docs/`, `docs/audits/`, `docs/reviews/`, `tests/`). **MUST** use `libs/` lowercase (not `Libs/`).
- Lua files: **PascalCase.lua** (`Database.lua`, `IconGrid.lua`).
- Non-source folders that ship: lowercase.

### 3. Media subfolders

Shipped media **MUST** live in **typed subfolders** under `media/` — nothing loose directly in `media/`:

- `media/logos/` — the addon logo art (the runtime `.tga`/`.blp` plus the source `.jpg`/`.png`).
- `media/screenshots/` — README/store screenshots and any demo GIFs.
- `media/fonts/`, `media/sounds/`, `media/textures/` — as needed for shipped assets of that kind.

Reference implementation (in the collection): the standalone loot-history browser ships its logo under `media/logos/`. **MUST** keep the runtime texture in a WoW-loadable format (`.tga`/`.blp`) and the editable source (`.jpg`/`.png`) beside it (options-ui-§5).
