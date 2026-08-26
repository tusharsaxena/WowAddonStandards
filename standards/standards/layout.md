> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Layout

Every Ka0s addon uses one **modular** folder layout — `core/`, `defaults/`, `settings/`, `locales/`, `modules/` — regardless of size. There is no flat/small-addon variant; a three-file utility and a multi-feature suite share the same skeleton so every repo reads identically and any file has one obvious home.

### 1. Modular layout

```
<AddonName>/
  <AddonName>.toc          -- single file, single Interface line (latest Retail), lists all .lua in dependency order
  core/
    Compat.lua             -- deprecated-API shims
    Constants.lua          -- numeric constants, enum-like tables
    Namespace.lua          -- bootstrap: local addonName, NS = ...; sets up shared upvalues
    State.lua              -- mutable runtime state, message bus
    Util.lua               -- pure helpers
    <Module>Setup.lua      -- one seam file per wired LibKa0s module (library-stack-§7);
                           -- its position is often load-bearing and is declared in the TOC (toc-file-§5)
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
  docs/                    -- ARCHITECTURE.md, testing.md, smoke-tests.md, planning/reference (documentation)
                           -- NO agent-context.md: the scaffolding pack is fetched at runtime (documentation-§3)
    audits/<YYYY-MM-DD>/   -- audit-run history (retained; audit-review-history)
    reviews/<YYYY-MM-DD>/  -- code-review history (retained; audit-review-history)
  README.md                -- full, user-facing (stays at root)
  CLAUDE.md                -- STUB: short pointer into docs/ (documentation)
  LICENSE
  .luacheckrc
  .pkgmeta
  .gitattributes           -- MANDATORY: the CRLF pin + *.sh carve-out + binary markings (line-endings)
```

- **MUST** use this folder layout — source lives under `core/`, `defaults/`, `settings/`, `locales/`, `modules/`; never loose at the root. A small addon simply has thin folders (a single `modules/` file, a one-row `settings/Schema.lua`), not a different structure.
- **MUST** load in this **folder** order: `libs/*` → `locales/*` → `core/*` → `defaults/*` → `modules/*` → `settings/*`. Libraries first because everything resolves against them; settings **last**, because a settings panel depends on every module it configures already being initialized. This is the same order the TOC's `#` section headers express (toc-file-§5) — one order stated in two places, and if the two ever disagree that is a defect in this document rather than a choice an addon gets to make.
- **MUST** load `core/*` in **dependency-correct order**, and **MUST** declare each load-bearing position at its own TOC line (toc-file-§5). There is no fixed `core/` prefix. The seam files `library-stack-§7` introduced — one `*Setup.lua` per wired module — resolve library members **at file scope**, so which file must precede which is a property of what the addon actually wires, and no list written here can anticipate it. `Compat.lua` → `Constants.lua` → `Namespace.lua` is the **illustrative** shape for an addon with no seam files and nothing resolving at load; an addon whose `Namespace.lua` publishes the `NS` table the other `core/` files attach to, or whose `Constants.lua` resolves a font from a media seam at file load, orders around that constraint and says so in the TOC comment. A dependency-correct order with its load-bearing positions declared is compliant; an order that matches the illustration but breaks a load-time resolution is not.
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
- `media/fonts/`, `media/sounds/`, `media/textures/` — as needed for shipped assets of that kind, **and only for assets the shared media library does not already carry**.

**`media/` is for what only THIS addon has.** The icon set, the monospace face and the bar textures every Ka0s addon draws with ship inside the vendored payload at `libs/LibKa0s/media/` (library-stack-§8) and arrive with `Core.lua` in the same copy — so an addon **MUST NOT** ship its own copy of one, and **MUST NOT** copy one out of `libs/` into `media/` to shorten a path. What legitimately remains here is the addon's own identity and its own subject matter: the logo, the screenshots, and any asset that would be meaningless in another addon. An addon whose `media/fonts/` or `media/textures/` holds a second copy of a library asset is anti-pattern #63, and the tell is a `media/` folder that two Ka0s addons could swap without either noticing.

Reference implementation (in the collection): the standalone loot-history browser ships its logo under `media/logos/`. **MUST** keep the runtime texture in a WoW-loadable format (`.tga`/`.blp`) and the editable source (`.jpg`/`.png`) beside it (options-ui-§5).
