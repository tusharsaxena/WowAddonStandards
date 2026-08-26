# Harvest 2026-08-25 — 03 Evidence

Verbatim excerpts the findings in `02_FINDINGS.md` rest on.

---

## §A — The section order every addon actually uses (F-01)

The `#` section headers, in file order, one addon per block. All nine read
`Libraries → Locales → Core → Defaults → Modules → Settings` — `toc-file-§5`, not `layout-§1`.

**AbsorbTracker** (`AbsorbTracker/AbsorbTracker.toc`)

```
AbsorbTracker.toc:15:# Libraries (vendored in libs/ — load first)
AbsorbTracker.toc:32:# Locales
AbsorbTracker.toc:35:# Core (the LibKa0s-Env seam loads first)
AbsorbTracker.toc:55:# Defaults
AbsorbTracker.toc:58:# Modules
AbsorbTracker.toc:63:# Settings (last — depend on everything else being initialized)
```

**BankLedger** (`BankLedger/BankLedger.toc`)

```
BankLedger.toc:15:# Libraries (vendored in libs/ — load first)
BankLedger.toc:31:# Locales
BankLedger.toc:35:# Core (Compat loads first)
BankLedger.toc:66:# Defaults
BankLedger.toc:69:# Modules (Filters before Ledger — the capture gate reads the lists)
BankLedger.toc:79:# Settings (last — depend on everything else being initialized)
```

**ConsumableMaster** (`ConsumableMaster/ConsumableMaster.toc`)

```
ConsumableMaster.toc:19:# Libraries (vendored in libs/ — load first)
ConsumableMaster.toc:38:# Locales
ConsumableMaster.toc:41:# Core
ConsumableMaster.toc:114:# Defaults
ConsumableMaster.toc:137:# Modules
ConsumableMaster.toc:149:# Settings
```

**KickCD** (`KickCD/KickCD.toc`)

```
KickCD.toc:16:# Libraries (must load first)
KickCD.toc:31:# Locales
KickCD.toc:34:# Core
KickCD.toc:57:# Defaults (the only place a profile default is hardcoded — savedvariables-§2)
KickCD.toc:61:# Modules
KickCD.toc:71:# Settings (last — depend on everything else being initialized)
```

**LootHistory** (`LootHistory/LootHistory.toc`)

```
LootHistory.toc:15:# Libraries (vendored in libs/ — load first)
LootHistory.toc:29:# Locales
LootHistory.toc:32:# Core (Compat loads first)
LootHistory.toc:57:# Defaults
LootHistory.toc:60:# Modules (Attribution before Collector)
LootHistory.toc:70:# Settings
```

**MultiMeters** (`MultiMeters/MultiMeters.toc`)

```
MultiMeters.toc:16:# Libraries (must load first)
MultiMeters.toc:33:# Locales
MultiMeters.toc:36:# Core
MultiMeters.toc:62:# Defaults (the only place a profile default is hardcoded — savedvariables-§2)
MultiMeters.toc:65:# Modules
MultiMeters.toc:82:# Settings (last — depend on everything else being initialized)
```

**PanelMaster** (`PanelMaster/PanelMaster.toc`)

```
PanelMaster.toc:15:# Libraries (vendored in libs/ — load first)
PanelMaster.toc:32:# Locales
PanelMaster.toc:36:# Core (Compat loads first)
PanelMaster.toc:62:# Defaults
PanelMaster.toc:66:# Modules (Registry before Canvas — the renderer reads the registry)
PanelMaster.toc:80:# Settings (last — depend on everything else being initialized)
```

**PrettyChat** (`PrettyChat/PrettyChat.toc`)

```
PrettyChat.toc:15:# Libraries (must load first)
PrettyChat.toc:24:# Locales (locale table — no earlier-load dependency; toc-file-§5 section order)
PrettyChat.toc:27:# Core (the LibKa0s seams load first)
PrettyChat.toc:46:# Defaults (data tables — must precede settings\Schema.lua)
PrettyChat.toc:50:# Modules (the override pipeline)
PrettyChat.toc:53:# Settings (last — depend on everything else being initialized)
```

**WhatGroup** (`WhatGroup/WhatGroup.toc`)

```
WhatGroup.toc:15:# Libraries (must load first)
WhatGroup.toc:27:# Locales
WhatGroup.toc:30:# Core (CoreSetup first: it publishes the printer every later file reads, and
WhatGroup.toc:46:# Defaults
WhatGroup.toc:50:# Modules
WhatGroup.toc:53:# Settings
```

---

## §B — The load-bearing / conventional annotation (F-05)

Every hit of either word across the nine TOCs. All nine use **load-bearing**; seven also use
**conventional** as its explicit opposite. The same case — a media/seam file before `Constants.lua`,
because `Constants` resolves `FONT_MONO` at file scope — carries a position comment in all nine
TOCs, four of them stating the consequence without reaching for the word (e.g.
`AbsorbTracker.toc:39-40`, `ConsumableMaster.toc:58-63`).

```
AbsorbTracker/AbsorbTracker.toc:37:# at load, so this position is conventional rather than load-bearing.
BankLedger/BankLedger.toc:39:# LibStub lookup, so unlike core\MediaSetup.lua below this position is conventional.
BankLedger/BankLedger.toc:43:# NS.Item.QualityLabel — so this position is load-bearing, not conventional.
BankLedger/BankLedger.toc:45:# The LibKa0s-Media seam. BEFORE Constants, deliberately and load-bearingly: C.FONT_MONO is
BankLedger/BankLedger.toc:63:# SessionWindow all take NS.Pool at call time, so this is conventional rather than load-bearing.
ConsumableMaster/ConsumableMaster.toc:60:# LOAD-BEARING: core\DebugLogSetup.lua resolves the console's font path EAGERLY at
ConsumableMaster/ConsumableMaster.toc:63:# not merely conventionally early.
ConsumableMaster/ConsumableMaster.toc:74:# `/cm version` banner and the About page's notes). Position is conventional --
KickCD/KickCD.toc:42:# LOAD-BEARING POSITION: core/Constants.lua resolves Const.FONT_MONO from
LootHistory/LootHistory.toc:35:# nothing here resolves at load, so the position is conventional rather than load-bearing.
LootHistory/LootHistory.toc:37:# The LibKa0s-Item seam. LOAD-BEARING POSITION: publishes NS.Item, whose QualityLabel
LootHistory/LootHistory.toc:41:# LOAD-BEARING POSITION: publishes NS.MediaFont, which core\Constants.lua reads at file
MultiMeters/MultiMeters.toc:38:# The LibKa0s-Env seam. LOAD-BEARING POSITION, and not merely "after Compat, whose metadata
PanelMaster/PanelMaster.toc:39:# reader out of it. Its position is conventional, not load-bearing: nothing here resolves at file
PanelMaster/PanelMaster.toc:43:# MediaSetup BEFORE Constants, and that position is load-bearing rather than conventional:
PrettyChat/PrettyChat.toc:28:# core\EnvSetup.lua loads BEFORE core\Namespace.lua and the position is load-bearing:
PrettyChat/PrettyChat.toc:34:# core\MediaSetup.lua loads BEFORE core\Constants.lua and the position is load-bearing:
WhatGroup/WhatGroup.toc:34:# NS.MediaFont at load, so this slot is load-bearing, not conventional.
WhatGroup/WhatGroup.toc:40:# both call sites read inside a function, so this slot is conventional, not load-bearing.
```

And the standard, for comparison:

```
$ grep -nE "load-bearing|conventional" standards/standards/toc-file.md standards/standards/layout.md
(no output — neither word appears in either section)
```


---

## §C — One quirk, three write-ups (F-08)

`Settings.OpenToCategory` and the parent-expand walk, written up independently in three addons.
All three are quoted; the depth verdict follows each.

### C1 — AbsorbTracker (`AbsorbTracker/docs/midnight-quirks.md:73-77`)

> ## `Settings.OpenToCategory` wants a numeric ID, not a category object
> 
> `Settings.RegisterCanvasLayoutCategory(panel, name)` returns a category *object* with a `:GetID()` method; `Settings.RegisterCanvasLayoutSubcategory(parent, panel, name)` returns the same shape. `Settings.OpenToCategory` accepts the numeric ID directly — passing the object produces a range error.
> 
> `libs/LibKa0s/Options.lua` captures `mainCategory:GetID()` at parent registration into `mainCategoryID`; `OpenOptionsPanel` calls `Settings.OpenToCategory(mainCategoryID)` so `/at config` always lands on the parent (about page) and then calls `expandMainCategory()` to expand the sub-page tree so every sub-page is visible at once. `expandMainCategory` reaches into `SettingsPanel:GetCategoryList()` private API; the whole call is wrapped in `pcall` so a future Blizzard refactor that renames or removes those internals degrades gracefully (the panel still opens, the tree just doesn't auto-expand).

*Deepest on **where the guard lives** (inside the library's `OpenOptionsPanel`, so every caller is covered) — not on the quirk itself.*

### C2 — ConsumableMaster (`ConsumableMaster/docs/midnight-quirks.md:74-109`)

> ## `Settings.OpenToCategory` wants the numeric category ID, not a frame
> 
> `Settings.RegisterCanvasLayoutCategory` (parent) and `Settings.RegisterCanvasLayoutSubcategory` (sub-pages) both return a category object whose `:GetID()` is the numeric ID `Settings.OpenToCategory` accepts. Passing the frame produces a range error. Capture the ID at registration time:
> 
> ```lua
> local main = Settings.RegisterCanvasLayoutCategory(panel, PANEL_TITLE)
> KCM._settingsCategoryID = main:GetID()
> ```
> 
> `/cm config` (in `settings/Slash.lua`'s `COMMANDS` table) uses the parent's ID stored in `KCM._settingsCategoryID` to land on the About splash.
> 
> ## Forcing a parent category to render expanded in the AddOns sidebar
> 
> `SettingsCategoryMixin` does NOT expose a `SetExpanded` method — that lives on the visual list-entry element. To force the parent's sub-pages to render unfolded by default, reach into `SettingsPanel:GetCategoryList():GetCategoryEntry(category):SetExpanded(true)`. The whole walk is wrapped in `pcall` because every step (`SettingsPanel`, `GetCategoryList`, `GetCategoryEntry`) is private Blizzard API and could shift between patches; if any call goes missing the panel still opens, just without the parent unfolded.
> 
> ```lua
> local function expandMainCategory()
>     local main = KCM.Settings.main
>     if not (main and SettingsPanel) then return end
>     pcall(function()
>         local list = SettingsPanel.GetCategoryList
>             and SettingsPanel:GetCategoryList()
>             or SettingsPanel.CategoryList
>         if not (list and list.GetCategoryEntry) then return end
>         local entry = list:GetCategoryEntry(main)
>         if entry and entry.SetExpanded then
>             entry:SetExpanded(true)
>         end
>     end)
> end
> ```
> 
> Call it AFTER `Settings.OpenToCategory` so `SettingsPanel` is realized and the entry element exists. Re-running on every `KCM.Options.Open` means a manual mid-session collapse doesn't stick across the next `/cm config`.
> 
> The Settings panel is protected during combat (`InCombatLockdown()` blocks `Settings.OpenToCategory`). Two guards cover both entry points: `KCM.Options.Open` early-returns with a chat notice (covers `/cm` and `/cm config`), and `Helpers.SetRenderer`'s panel `OnShow` callback closes `SettingsPanel` and prints the same notice when a panel is shown during combat (covers a direct ESC → AddOns sidebar click that bypasses `O.Open`).
> 

*__Deepest on the expand walk.__ The only write-up that says why the private walk is necessary — `SettingsCategoryMixin` has no `SetExpanded`, it lives on the visual list entry — and the only one that pins the call ordering (after `OpenToCategory`, so `SettingsPanel` is realized).*

### C3 — WhatGroup (`WhatGroup/docs/midnight-quirks.md:34-44`)

> ## `Settings.OpenToCategory` requires the integer ID
> 
> ```lua
> Settings.OpenToCategory(self._settingsCategory:GetID())  -- correct
> Settings.OpenToCategory("Ka0s WhatGroup > General")        -- WRONG (not a valid form)
> Settings.OpenToCategory(self._settingsCategory)            -- WRONG (object, not ID)
> ```
> 
> `category:GetID()` returns the auto-assigned integer ID. **Do not overwrite `category.ID` with a string.** Doing so silently breaks the lookup and `OpenToCategory` becomes a no-op.
> 
> WhatGroup's `/wg config` goes through `Helpers.OpenOptionsPanel()` — `LibKa0s-Options-1.0`'s member since the adoption, holding the main category's own ID rather than reading either of the handles `settings/Panel.lua` records. It calls `Settings.OpenToCategory` against the **parent** and then reaches into `SettingsPanel:GetCategoryList():GetCategoryEntry(parent):SetExpanded(true)` — the path the expand-arrow click handler itself uses — so the subcategory tree comes up unfolded. That whole traversal is wrapped in `pcall` because `CategoryList` / `GetCategoryEntry` / the `CategoryEntry:SetExpanded` shape are private Blizzard internals that can shift between patches; if any link goes missing the panel still opens, just without auto-unfold. The slash command also refuses to open during `InCombatLockdown()` — the Settings UI uses secure templates and opening it mid-combat can taint other addons' secure handlers.

*__Deepest on the ID form.__ The only write-up that enumerates all three wrong forms, and the only one that names the silent failure: overwriting `category.ID` with a string makes `OpenToCategory` a **no-op** rather than an error.*


---

## §D — The four undocumented majors, and the declines against them (F-03, F-04)

The library's own file list, which is the answer to "how many majors":

```
$ grep -o '"[A-Za-z]*\.lua"' LibKa0s/LibKa0s/LibKa0s.xml
"Core.lua" "Env.lua" "Pool.lua" "Item.lua" "Media.lua" "Widgets.lua" "DebugLog.lua"
"Slash.lua" "Options.lua" "OptionsWidgets.lua" "OptionsScroll.lua" "Perf.lua" "PerfPanel.lua"

$ grep -n 'local MAJOR' LibKa0s/LibKa0s/*.lua
Core.lua:18:      local MAJOR, MINOR = "LibKa0s-Core-1.0", 6
DebugLog.lua:37:  local MAJOR, MINOR = "LibKa0s-DebugLog-1.0", 12
Env.lua:39:       local MAJOR, MINOR = "LibKa0s-Env-1.0", 1
Item.lua:33:      local MAJOR, MINOR = "LibKa0s-Item-1.0", 1
Media.lua:56:     local MAJOR, MINOR = "LibKa0s-Media-1.0", 3
Options.lua:24:   local MAJOR, MINOR = "LibKa0s-Options-1.0", 8
Perf.lua:25:      local MAJOR, MINOR = "LibKa0s-Perf-1.0", 7
Pool.lua:49:      local MAJOR, MINOR = "LibKa0s-Pool-1.0", 3
Slash.lua:21:     local MAJOR, MINOR = "LibKa0s-Slash-1.0", 7
Widgets.lua:36:   local MAJOR, MINOR = "LibKa0s-Widgets-1.0", 7
```

Against the standard's claim:

> `standards/standards/library-stack.md:70` — "**The modules.** `LibKa0s` ships **six LibStub majors
> across nine files**, loaded by one aggregate `LibKa0s.xml`, plus one non-code payload (`media/`,
> library-stack-§8)"

> `standards/standards/library-stack.md:95` — "**Inter-module dependencies (MUST).** **Five of the
> six** majors need `LibKa0s-Core-1.0`"

And the stale entry in the standard's own ledger:

> `standards/standards/open-evolutions.md`, *Further `LibKa0s` modules* — "Shipped so far: … **six
> majors across nine files** … Candidates the collection still duplicates: the `Compat` shim, the
> message bus, the Schema runtime, and **the object pool**."

`LibKa0s-Pool-1.0` is at minor 3 and is consumed by BankLedger, KickCD, LootHistory and MultiMeters.

### The declines (F-04) — informational, not a defect

`LibKa0s-Widgets-1.0`, declined in six repos, all `severity:low`:

- <https://github.com/tusharsaxena/AbsorbTracker/issues/26> — "no control in this addon wants it"
- <https://github.com/tusharsaxena/ConsumableMaster/issues/28> — same
- <https://github.com/tusharsaxena/KickCD/issues/12> — same
- <https://github.com/tusharsaxena/PanelMaster/issues/43> — same
- <https://github.com/tusharsaxena/PrettyChat/issues/11> — same
- <https://github.com/tusharsaxena/WhatGroup/issues/12> — same

`LibKa0s-Item-1.0`, declined in seven, each naming a domain reason rather than a cost:

- AbsorbTracker `#27` "this addon has no item domain" · ConsumableMaster `#30` "the addon's items are
  numeric IDs, never links" · KickCD `#14` "a spell-cooldown addon with no item concept" ·
  MultiMeters `#20` "a damage meter has no item surface" · PanelMaster `#45` "a backdrop-panel addon
  has no item domain" · PrettyChat `#12` "the addon edits format templates, never links" ·
  WhatGroup `#13` "LFG metadata and spell IDs, no items"

`LibKa0s-Pool-1.0`, declined in five: AbsorbTracker `#28` "a fixed three-frame set has nothing to
recycle" · ConsumableMaster `#31` "both widget sets are keyed and secure, not anonymous" ·
PanelMaster `#46` "the pool is keyed by frame name and releases per object" · PrettyChat `#13`
"AceGUI is already the pool" · WhatGroup `#14` "a one-shot singleton window with a fixed field set".

Every one is a host saying the module does not fit its domain — the per-module-major design
(`library-stack-§7`) working exactly as specified.

---

## §E — The recurring deviations (F-02, F-07)

Same ID, consecutive dates, unchanged text — the no-teeth shape.

> `ConsumableMaster/docs/audits/2026-08-04/02_DEVIATIONS.md:38` and
> `ConsumableMaster/docs/audits/2026-08-05/02_DEVIATIONS.md:36`
>
> | **CM-49** | `layout-§1` | MUST | **The `core/` load order does not begin `Compat → Constants →
> Namespace`.** The TOC loads `core/Namespace.lua → core/ConsumableMaster.lua …`

> `ConsumableMaster/docs/audits/2026-08-04/05_EXECUTION_PLAN.md:23`
>
> | 0.2 | Raise the `layout-§1` conflict upstream: (a) `Compat → Constants → Namespace` may be
> unsatisfiable for any addon whose `Namespace.lua` bootstraps `NS` …

> `KickCD/docs/audits/2026-08-04/02_DEVIATIONS.md:49` and
> `KickCD/docs/audits/2026-08-05/02_DEVIATIONS.md:51`
>
> | **A-3** | `packaging` | `.superpowers/` (54 files) and `.claude/settings.local.json` are dev-only
> and are **not** in `.pkgmeta`'s ignore list. The section's MUST names `docs/`, `_dev/` …

And the one repo that fixed it, which is where the proposed text comes from:

> `ConsumableMaster/.pkgmeta`
>
> ```yaml
> ignore:
>   - docs        # includes docs/audits/ and docs/reviews/ bundles
>   - tests
>   - .luacheckrc
>   - .pkgmeta
>   - .gitignore
>   - .gitattributes
>   - .claude        # agent tooling config — dev-only, never loaded by the client
>   - .superpowers   # same
>   - "*.bak"
>   - media/screenshots
> ```

---

## §F — The unpublished-addon blocker (F-06)

> `MultiMeters/MultiMeters.toc:13-14`
>
> ```
> # X-Curse-Project-ID / X-Wago-ID are deliberately absent: the addon is not published yet, and a
> # placeholder ID here would make the packager upload to somebody else's project.
> ```

> <https://github.com/tusharsaxena/PanelMaster/issues/22> — "Deviation D-001 blocked on a CurseForge
> project id that does not exist until first upload … Blocked on a CurseForge project id that does
> not exist until first upload. Not actionable until PLAN-02."
> Evidence: `PanelMaster/docs/audits/2026-07-30/02_DEVIATIONS.md` ▸ D-001, hash `a17b259f`.

> <https://github.com/tusharsaxena/PanelMaster/issues/23> — "Same blocker as PLAN-03; the bundle
> defines the two as one atomic change."

And the rule as it stands:

> `standards/standards/toc-file.md:30` — "**MUST** have `X-Curse-Project-ID` once the addon is
> published on CurseForge (the collection's distribution platform)."

---

## §G — The settled clusters (F-10)

The three `X-Wago-ID` refusals, all quoting a rule that has since been rewritten:

> <https://github.com/tusharsaxena/PrettyChat/issues/7> — "The 2026-07-18 standards audit filed PC-10
> against `toc-file-§1`, **which asks a published addon to carry both distribution ids** … PrettyChat
> is distributed through CurseForge only … A future standards audit will still flag the missing
> field."

> <https://github.com/tusharsaxena/WhatGroup/issues/5> — "the addon distributes on Curse only and
> carries no `X-Wago-ID` field, **so the TOC fails the metadata MUST**."

> <https://github.com/tusharsaxena/ConsumableMaster/issues/17> — "Audit item CM-32 offered two
> branches for the missing Wago project-ID field … **A future standards audit will still flag the
> missing field.**"

Against today's text:

> `standards/standards/toc-file.md:30` — "`X-Wago-ID` and `X-WoWI-ID` are **optional** (**MAY**) —
> include each only when the addon is actually listed on that platform … an addon that doesn't
> publish there simply omits the line."

Three closed refusals now argue against a rule that does not exist, and all three predict a re-flag
that cannot happen. The correction belongs in those repos, not here.

---

## §H — The scaffolding pack already sides with the collection (F-01, F-02)

`NEW_ADDON_CONTEXT.md` is the standard's own answer to "what does a compliant addon look like on day
one". Its starter tree states the `layout-§1` prefix:

> `standards/NEW_ADDON_CONTEXT.md:106-108`
>
> ```
>   core/
>     Compat.lua           -- LOAD FIRST
>     Constants.lua
>     Namespace.lua        -- NS.PREFIX, the mandatory cyan chat tag (slash-commands-§4)
> ```

…and then its **own TOC template**, eighty lines later, does something else:

> `standards/NEW_ADDON_CONTEXT.md:186-196`
>
> ```
> # Locales
> locales\enUS.lua
>
> # Core
> core\Compat.lua
> core\MediaSetup.lua                      -- BEFORE Constants: it publishes the seam FONT_MONO reads
> core\Constants.lua                       -- incl. FONT_MONO, resolved from NS.MediaFont
> core\Namespace.lua                       -- NS.PREFIX
> ```

Two things follow, and they are the evidence rather than an inference:

1. **Locales before Core** — the pack ships `toc-file-§5`'s order, not `layout-§1`'s (F-01).
2. **`Compat → MediaSetup → Constants → Namespace`** — the pack cannot satisfy `layout-§1`'s
   three-file prefix either, and it says why on the line itself, in the same words the nine addons
   use (F-02, F-05).

`NEW_ADDON.md:73-78` says it a third time, normatively: `core/MediaSetup.lua` is "**First of the
setup files**, because `core/Constants.lua` resolves `FONT_MONO` from the seam it publishes".

**An addon scaffolded exactly as the standard instructs is born failing `layout-§1`.** That is not
nine addons drifting.
