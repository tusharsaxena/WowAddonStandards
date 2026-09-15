> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Options UI

Every Ka0s addon's settings surface is the **same** surface: a Blizzard canvas landing page, one canvas subcategory per topic, a two-column schema-driven body inside an always-scrollbarred `ScrollFrame`, a lazily built **Defaults** button top right, and a panel-open that refuses under combat. That sameness is the product, not a coincidence — a user who has configured one Ka0s addon has configured all of them — and it is now delivered by a **shared library** rather than by five copies of a toolkit drifting apart.

**Adoption strength.** **MUST** for the **wiring** — vendor `LibKa0s-Options-1.0`, create one instance at load from a descriptor, stash it on the namespace, degrade when it is absent. **MUST** for the **behavior contract** below (options-ui-§5 onward): those rules describe what a Ka0s panel *is*, and they hold whether or not a given release of the library implements them for you. **SHOULD** for which pages an addon splits its settings into — that is genuinely addon-specific. Hand-rolling the panel shell, the widget makers or the flow engine when the library provides them is **anti-pattern #47**.

### 1. The options library

The settings-canvas shell, the schema-row → AceGUI widget makers and the two-column flow engine are **Ka0s-owned shared code**, not per-addon code.

- **MUST** vendor **`LibKa0s-Options-1.0`** — the whole `LibKa0s/` folder, never a hand-picked subset — under `libs/LibKa0s/`, listed in the TOC's `# Libraries` section after Ace3 (toc-file-§4, library-stack-§7). The major spans **three** files (`Options.lua`, `OptionsWidgets.lua`, `OptionsScroll.lua`) and depends on `LibKa0s-Core-1.0`; copying one file and not its siblings yields a shell with no widget makers and no scrollbar patch (**anti-pattern #48**).
- **MUST** create **one instance per addon at load**, from a descriptor, and stash it on the namespace — in its own file (`settings/OptionsSetup.lua`), positioned in the TOC **after** the schema/slash files it reads and **before** every `settings/<page>.lua`, because page files touch the instance at file load (see the degradation rule below).

```lua
-- settings/OptionsSetup.lua
local lib = LibStub and LibStub("LibKa0s-Options-1.0", true)
-- ... descriptor, degradation stub ...
NS.Helpers = lib:New(descriptor)          -- the instance IS the namespace member
```

- **The host member MUST *be* the library instance**, decorated in place with the host's own non-generalizable pieces — never a fresh table that copies members across. Two things depend on it: a host page helper added later (`Helpers.RenderUnitPanel`) can call `Helpers.RenderRows` like any other page does, and a suite that swaps a member out to spy on it is swapping **the one the library's own callers see**. A copy-across gives the test a member nobody calls.
- **MUST** carry `OnCommit`, `OnDefault` and `OnRefresh` on every frame handed to `RegisterCanvasLayout(Sub)category`. Blizzard's Settings window calls all three — `OnCommit` on apply, `OnDefault` from **its own footer defaults control**, `OnRefresh` on re-show — and the footer control is the one that silently does nothing when it is missing, while the header Defaults button beside it keeps working. Two controls that look equivalent and are not is worse than offering only one. `LibKa0s-Options-1.0`'s `CreatePanel` stamps all three as of **Options minor 5**, so a host on the library gets them for free and **MUST NOT** set them itself: `OnDefault` **forwards** to whatever the page parked as `defaultsOnClick`, which is what keeps the footer control and the header button one implementation rather than two that can drift. `OnCommit` and `OnRefresh` are inert by design — writes land immediately through the single write seam below, and the library's renderer already owns re-show, so a second refresh path would race it.
- **MUST** degrade rather than error when the library is absent — see the degradation rule at the end of this section, which is the **one documented exception** to the member-answering stub every other Ka0s setup file uses.
- `mainPanelName` is the one descriptor field the library validates (it raises). The rest surface a page-build away with a stack that names the missing callback, whereas a nil panel name silently yields an anonymous canvas that `/framestack` cannot attribute and two addons can collide on.
- AceGUI-3.0 is **survivable, not a dependency**: the library resolves it through LibStub at panel-build time, prints one honest line and returns if it is missing. The addon still loads, still runs, and still answers its slash CLI.

**The descriptor** — the host's half of the contract. Everything in it is *where a value lives*, not *how a panel looks*:

| Field | Purpose |
|---|---|
| `parentTitle`, `mainPanelName` | brand string and the main canvas's frame name |
| `get(path)` / `set(path, value)` | the host's **single write seam** — see below |
| `applyDefault(row)` | reset one schema row |
| `rowsForPage(pageKey, filter)` / `allRows()` | the schema, per page and entire |
| `skipRestoreAll(row)` | rows a global reset must not touch (Profiles rows are user data) |
| `afterRestoreAll()` | state no schema row owns (a dragged frame's position) |
| `colorDecode` / `colorEncode` | the host's stored color shape (options-ui-§6) |
| `getLSM`, `scheduleTimer`, `validate`, `onAceGUI`, `buildMain`, `print`, `debug` | optional seams |

- **MUST** route `get`/`set` through the addon's own **single write seam** (the same function `/<slash> set` calls), never a bare table write. A panel checkbox then takes exactly the path a slash `set` takes: the debug line, the row's `onChange`, the panel refresh. Two write paths is two behaviors, and only one of them gets tested.
- **MUST** supply `colorDecode`/`colorEncode` when the addon stores colors in anything but the library's default `{r=,g=,b=,a=}` shape — and **SHOULD** write them out even when it matches, because the stored shape is a real contract with the rest of the addon and a silent default is a poor place for it to live.

**Degradation — LOAD-COMPLETING, not member-answering (MUST).** Every other Ka0s setup file falls back to a stub whose members each print an honest *"not installed"* line. This one **MUST NOT**, and the reason is not importance but **when** the missing code is reached: page files call `Helpers.LSMValues("statusbar")` *inside schema-row literals, at file load*. With that member nil the page file raises, so its `RegisterSchemaRows` never runs, so a third of the schema is missing — and `list`, `get`, `set`, `reset` and the profile defaults all break with it, silently. The addon would not degrade; it would half-load and say nothing.

- **MUST** publish, from the stub, every member a page file touches **at load time**, real enough for the file to finish. In the reference implementation that measured out to exactly one (`LSMValues`, returning a closure yielding an empty table).
- **MUST** determine that set by **measurement**, not by reading: delete a member, run the library-absent load, and compare the resulting schema row count against the fully-loaded environment. The addon's suite **MUST** pin both the member set and the row count (testing) — those cases are the only thing between the stub and a silent half-load.
- **SHOULD** keep the global-reset entry point real in the stub even though it is call-time. A user whose panel will not open is exactly the user who needs *reset everything*, and the schema loaded fine, so the reset still works with no panel at all.
- Everything else — the panel-open, the page registration, every widget maker — **MUST** be a no-op or a single honest line naming the missing library.
- **MUST NOT** carry a copy of a widget maker, the flow engine, the header, or any of the library's layout constants (options-ui-§8) into the stub. A host copy of a library constant is the copy that goes stale, and hand-copying the code whose drift the extraction exists to end is precisely the duplicate the standard forbids (**anti-pattern #47**).

**When the missing content is COMPOSED, the no-copy MUST wins (MUST).** The two rules above collide the moment a row set moves *behind* a library call. `LibKa0s-OptionsCompose`'s font, border, bar, color-pair and master-controls composers emit schema **content**, not merely rendering, so a stub that were load-completing in the fullest sense would have to hold a host copy of exactly the blocks options-ui-§16 and anti-pattern #73 exist to stop nine addons from re-deciding. No stub can satisfy both MUSTs, and this is the ruling: it does not try. The case this is written against is `KickCD/docs/ARCHITECTURE.md:241`, whose provisional register row measured a library-less load registering **112 of 228** schema rows and asked, correctly, that the standard say which MUST wins rather than each of nine addons deciding for itself.

- The stub's composer members **MUST** exist and **MUST** answer an **empty row list**. They are **load-completing, not content-completing**: what the load-completing MUST protects is that no page file raises, so no page loses the rows it declares *itself* — not that a library-less load reaches the same row count as a full one. A **hollow** composer is compliant. A host copy of a composed block inside the stub is **anti-pattern #73** and is not, and no addon may close the gap locally by writing one.
- **The exemption is bounded by the fall-together property, and an addon MUST show that property holds.** `LibKa0s` is vendored whole (anti-pattern #48), so the load that loses `LibKa0s-Options-1.0` loses `LibKa0s-Slash-1.0` in the same breath: the schema CLI answers `set` / `get` / `list` / `reset` with one *"unavailable"* line each, for a host-declared row exactly as for a composed one, and no panel opens either. There is no state in which a composed setting is **addressable but missing** — which is the harm the load-completing MUST actually names. An addon that *can* reach a composed row from a path still working without the Options major does **not** get this exemption and **MUST** close that path's gap instead.
- **Profile defaults MUST NOT be read off the schema.** They come from the addon's own defaults table, merged when the database opens, so a composed setting the player has already changed stays honored on a degraded load. That is what makes the absent rows unreachable rather than destructive, and it is the half of the load-completing MUST's stated harm that survives this ruling intact.
- **The suite MUST pin both counts and the delta between them.** The measurement MUST above pins the member set and *a* row count; against hollow composers that is not enough, because the figure the case has to defend is the **gap**. Pin the fully-loaded count, the library-absent count, and the difference as a named figure attributed to the composers it belongs to. The day a composer stops being hollow, or a page file starts declaring rows a composer used to, the case says so instead of staying green.
- **This shape needs no register row, and the rows already written for it retire** (audit-review-history). It was a deviation only for as long as §1 said two things about it; it is now what §1 says.
- **What ends the hollowness is upstream, not per-addon**: `LibKa0s-Options-1.0` shipping the composers from a file that loads and answers **without** the Options major, the way `LibStub` itself does. Until that lands, hollow is the compliant answer.

### 2. Combat lockdown

- **MUST** check `InCombatLockdown()` before **opening** the options panel, with the gate **inside the panel-open function itself** — not in the slash dispatcher — so every caller is gated: the `config` verb, another addon, a `/run` script, a future internal caller. The library puts it there; a host **MUST NOT** wire a second, un-gated open path around it. (This gates panel *open*, not category *registration*, which happens taint-free at load per options-ui-§1 and options-ui-§9.)
- Under lockdown the addon **MUST refuse** the open: one `NS.PREFIX`-tagged **gray notice** and return. The canonical text is **"cannot open settings during combat — Blizzard's category-switch is protected"**. It **MUST NOT** call the protected category-switch (`Settings.OpenToCategory`) under lockdown — that taints the panel for the rest of the session — and **MUST NOT** silently no-op.
- **MUST NOT** defer-and-replay the open on `PLAYER_REGEN_ENABLED`. A panel that pops itself open the instant combat drops steals focus during post-pull recovery; the house behavior is an explicit, greppable refusal, and the user re-runs `/<slash> config` when they choose. *(The safe move for a taint-prone protected path is to not touch it at all and say why — distinct from a deferred **secure frame write**, which legitimately queues on `PLAYER_REGEN_ENABLED`; see events-frames-taint-§2.)*
- **SHOULD** apply the same `InCombatLockdown()` gate to any settings setter that creates or destroys frames.

### 3. Profiles sub-page

- **MAY** ship a Profiles sub-category using AceDBOptions-3.0 + AceConfigDialog-3.0. **If included**, vendor AceConfig in `libs/` like every other lib (library-stack-§3).
- **SHOULD** be the **only** legitimate use of AceConfig in a Ka0s addon.
- **MUST** exclude its rows from a global reset, via the descriptor's `skipRestoreAll` (options-ui-§1). Profiles rows are AceDBOptions-supplied, and resetting them deletes user data — which is not what *"restore defaults"* means to anyone. Name the veto **once** and share it with the degradation stub's own reset loop; two literal copies of the rule is one added page away from a reset that eats profiles.

### 4. Lazy options loading (large addons)

- For addons with ≥5 options sub-panels or whose options code is large, **SHOULD** ship options as a sibling LoadOnDemand addon (`<Addon>_Options.toc` with `## LoadOnDemand: 1`). None of the current Ka0s addons need this.

### 5. Landing page + subcategories

Every Ka0s options panel **MUST** be a **parent canvas category = landing page** with one or more **canvas subcategories** for the actual settings (the first named "General"). The library owns the split: it registers the parent category and stamps the shared header on every panel; the host registers each subcategory from its page builder and draws the landing page's body.

- **MUST** use `Settings.RegisterCanvasLayoutCategory` / `RegisterCanvasLayoutSubcategory` for the entry points. **MUST NOT** use the deprecated `InterfaceOptions_AddCategory`.
- **MUST register the parent category eagerly at addon load** — the library's `CreateOptionsPanel` does this, and the host **MUST** call it once at `PLAYER_LOGIN` / after `Blizzard_Settings` is available — so the addon's entry is **always present** in the Blizzard options list, even before its body is built. **MUST NOT** defer registration to a first `/<slash> config` (options-ui-§9). The call is idempotent by design: a second one would register a second Blizzard category and permanently double the refresh fan-out.
- Each page **MUST** register itself through the library's page registry (`RegisterOptionsPage(key, name, builder)`) at file load, and its builder returns the `Settings.RegisterCanvasLayoutSubcategory` handle. A builder returning nil means the page opted out (an optional dependency the host did not find) — which is a legitimate outcome, not an error.
- **MUST** render content with **raw AceGUI** inside the canvas. **MUST NOT** use AceConfigDialog for content. (Industry: the two largest boss-mod / aura frameworks use AceConfig at a scale that justifies the tax; the big UI-replacement and nameplate suites hand-roll. Ka0s sits in the AceGUI sweet spot.)
- **MUST** build every **body** lazily in the panel's first `OnShow`, guarded by a `rendered` flag. AceGUI lays children out against the container's **current** width, which is zero at registration time. This applies to the landing page too — the library defers its `buildMain` hook the same way.
- The **landing page** (parent panel) **MUST** render, top to bottom: the addon **logo**, a full-width **tagline** Label (`GameFontHighlight`), a **"Slash Commands"** section heading, then one Label per command **generated from the addon's `COMMANDS` table** — so the list stays in lockstep with `/<slash> help` rather than drifting from it. Command rows use `|cffffff00/<slash> <verb>|r  —  <desc>`. This body is the **host's**, handed to the library as `buildMain`: the logo and the command list are the two things about a Ka0s panel that are genuinely per-addon.
- **Logo asset:** ship a **`.tga`** (or `.blp`) under **`media/logos/`** — WoW **cannot** load `.jpg`/`.png` textures at runtime. Reference it by absolute path `Interface\AddOns\<Folder>\media\logos\<name>.tga`, display at **300×300**; source art SHOULD be power-of-two (e.g. 512×512). Keep the original `.jpg`/`.png` beside it for editing.
- **Header (both parent and subcategory):** left-aligned title in `GameFontNormalHuge`, a gold `Options_HorizontalDivider` tinted **to the title's own font color** (so a future theme retune carries the divider with it), and — on subcategories — a **Defaults** button top right. Subcategory titles render as a breadcrumb **"Ka0s <Addon> ▸ <Page>"** with the arrow via `|A:common-icon-forwardarrow:16:16|a`; the parent page shows the brand alone. The library builds all of this from the panel factory, so hosts **MUST NOT** hand-build a header.
- **The Defaults button MUST be an AceGUI `Button`, not a raw `CreateFrame("Button", …, "UIPanelButtonTemplate")` parented onto the Settings canvas.** A `UIPanelButtonTemplate` button created as a **direct child of the Blizzard Settings canvas** inherits the canvas's **red** button skin; AceGUI creates its button under `UIParent` and reparents the `.frame`, sidestepping that skinning so the button keeps the standard dark/gold options look. The same rule applies to any other header or action button parented onto the canvas.
- **The Defaults button MUST be *created* lazily, in the panel's first `OnShow` — never while the category is being registered.** *When* the widget is created decides how it looks, independently of *what* creates it. AceGUI is a **shared library**: UI-skinning addons (ElvUI and friends) restyle its widgets by hooking `RegisterAsWidget`, so a widget created **before** that hook is installed keeps Blizzard's stock `UI-Panel-Button-Up` art — the **red stone button** — for the rest of the session, while every widget created **after** it comes out in the skin. Page builders run inside the load window, so a button built there is racing every other addon's load order: an addon whose folder sorts early loses the race and renders red, one that sorts late wins and renders skinned — **with identical code in both**. First `OnShow` is after every addon has loaded, so the race is gone (**anti-pattern #42**). Note this is the *same fix* as the lazy body for an entirely *different reason*; do not collapse the two rationales when editing either rule.
- The host **MUST** therefore: declare the intent when it creates the panel (`defaultsButton = true`, plus a `defaultsTooltip`), **park** the click handler on the panel (`ctx.panel.defaultsOnClick = ...`) because the widget does not exist yet, and call the library's `EnsureDefaultsButton(ctx.panel)` at the **top of every `OnShow`**, outside the `rendered` guard:

```lua
local rendered = false
ctx.panel:SetScript("OnShow", function()
    H.EnsureDefaultsButton(ctx.panel)      -- every OnShow; builds once
    if rendered then return end            -- body: first OnShow only
    rendered = true
    H.RenderSchema(ctx, "general", afterGroup, pairWith)
end)
```

  **Diagnosing it:** the difference is invisible in source and visible only in the live object's **region list** — a skinned button carries extra `BORDER`/`BACKGROUND` regions over the stock set, while an unskinned one is the bare 5-region `UI-Panel-Button-Up` (fileID `130828`). An addon **SHOULD** expose this through its debug console's structured-dump verb (debug-logging-§4) rather than guessing from screenshots.

### 6. Two-column layout (default)

Schema-driven panels **MUST** default to a **two-column grid**: consecutive schema rows pair into 50%/50% widgets (`SetRelativeWidth(0.5)`) inside a full-width Flow `SimpleGroup`, with a small vertical spacer between rows. The library's flow engine is the only implementation of this; hosts render a page by handing it a page key (or an explicit row list) and **MUST NOT** write per-panel layout code.

- The pairing is **schema-driven**: each row's `group` names its section (options-ui-§7), and row order within a group drives which two rows share a line. Re-columning a page is an edit to row `order`, not to a builder.
- A row that must not share its line **MUST** say so **in the schema**, with `solo` — it then renders alone on its own line. A row the host wants to draw bespoke (a header checkbox, a mirror toggle) **MUST** carry `skipRender`, which keeps it in the schema — so resets, the CLI and the defaults still see it — while the flow engine leaves it alone. A row omitted from the schema to keep it off a panel is a row that vanishes from `/<slash> list` too.
- Two seams attach **non-schema** widgets without breaking the grid: an *after-group* hook fires once after a group's last row is flushed (so inline action buttons start on a fresh line), and a *pair-with* hook attaches a widget as the **right half** of a named path's row — and only when that path is currently the lone widget on its line, since attaching to a full row would make it three-wide and break the 50/50 split for the rest of the page. Both are one-shot **per render**, so a page that re-renders (a unit switch, a filter change) gets them again.
- A widget that **fills its cell edge-to-edge** — an action `Button`, e.g. the 50/50 pair at the foot of a group (*Reset position | Reset all settings*) — **MUST** inset to **`SetRelativeWidth(0.492)`** (`BUTTON_PAIR_REL`, options-ui-§8), never a flush `0.5`. AceGUI's Flow layout spills the right cell ~2px past the content width, and because the scroll content fills the `ScrollFrame` clip rect exactly (options-ui-§10), that spill — including the button's right border — is otherwise shaved off. Label-inset controls (dropdowns, sliders, checkboxes) are immune because their art sits inset from the cell edge; a cell-filling button is not. The inset lives in the library's button-pair maker, so every panel inherits it — **MUST NOT** hand-set `0.5` on a paired button.
- Colors are stored in the **host's** shape and translated by the descriptor's `colorDecode`/`colorEncode` (options-ui-§1), because hosts genuinely disagree on the stored form. The picker throttles its drag commits; a host that wants that throttle to run on its own timer supplies `scheduleTimer`, and gets immediate commits if it does not.
- LSM-backed dropdowns **MUST** take their value list as a **deferred closure**, never a snapshot table. Every such row is evaluated inside a schema-row literal at **file load**, long before the addons that register media have run — a table there freezes the list at whatever happened to be registered first.

### 7. Section headers

Options on an **untabbed** page **MUST** be grouped under **section headers** rendered as an AceGUI **`Heading`** (a centered label flanked by horizontal dividers), font bumped to `GameFontNormalLarge`, with a small spacer above (**except the first** — a leading gap reads as a broken top margin) and below. The flow engine emits one automatically whenever a row's `group` changes, so a section header is declared by a row, never drawn by a builder.

This is the same widget used for the landing page's "Slash Commands" divider, so headers read identically across the landing page and every subcategory. The landing page is one of the **two** pages options-ui-§13 exempts from the tab strip (the other is the Profiles sub-page), so this untabbed form is that page's permanent rendering — not a stage on the way to a strip, and not a deviation to be filed against it.

On a **tabbed** page (options-ui-§13) the tab label carries the section's name, so that heading is suppressed: drawing a `Heading` that repeats the tab the user just clicked is the same label twice. The `group` field still declares the section either way — what changes is where it is drawn, never who declares it.

**A tab that mixes control types MUST break them up with subsection headings, and those are NOT suppressed.** A tab holding bar rows, background rows and border rows is three subjects under one label, and a player scanning it has no way to tell where one ends. The heading is declared by the row, exactly as the section heading is — a `subgroup` field, drawn whenever it changes within a group — so a subsection is still never drawn by a builder, and the tab list is still derivable from `group` alone. A `subgroup` **MUST NOT** repeat its tab's name, and it **MUST NOT** be used to fake a second tab level: if a subsection wants its own tab, give it one.

**One heading widget in the collection.** Subsection headings use the same `Heading` every other header uses. A hand-rolled label — a colored full-width `Label`, a bolded string — **MUST** be replaced by it (**anti-pattern #71**); two heading looks on one canvas is the drift the shared library exists to end.

### 8. Layout constants (exact values)

Every Ka0s panel renders identically because every panel reads **one** set of constants — the library's `LAYOUT` table. Hosts **MUST NOT** copy these values into their own constants file: a host copy is the copy that goes stale, and the whole point is that five addons cannot drift apart. Where a host needs one for its own bespoke widget (a spacer between hand-built rows), read it off the instance (`Helpers.ROW_VSPACER`, `Helpers.SECTION_HEADING_H`, `Helpers.BUTTON_PAIR_REL`) rather than restating the number. The values are pinned here because the standard, not the library, is what an audit reads.

**Header** — parent landing page *and* every subcategory:

| Constant | Value | Meaning |
|---|---|---|
| `PADDING_X` | **16** | left/right edge inset for header, divider, and body |
| `HEADER_TOP` | **20** | vertical inset of the title (and the Defaults button) from the panel top — ≈½ the `GameFontNormalHuge` glyph height |
| `HEADER_HEIGHT` | **54** | panel-top → divider distance; in lockstep with `HEADER_TOP` so the title-to-divider gap is fixed |
| `DEFAULTS_W` | **110** | Defaults button width |
| body top inset | **−(HEADER_HEIGHT + 8) = −62** | body frame `TOPLEFT` y |

- **Title FontString:** `GameFontNormalHuge`, anchored `TOPLEFT` at `(PADDING_X, −HEADER_TOP)`.
- **Divider:** `Options_HorizontalDivider` atlas, `TOPLEFT`/`TOPRIGHT` at `(±PADDING_X, −HEADER_HEIGHT)`, `SetVertexColor(titleFS:GetTextColor())` so it tracks the title gold.
- **Defaults button** (subcategories only): `TOPRIGHT` at `(−PADDING_X, −HEADER_TOP)`.
- **Subcategory title** = breadcrumb `Ka0s <Addon> |A:common-icon-forwardarrow:16:16|a <Page>`; the **parent page** shows the brand alone.

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
| `BUTTON_PAIR_REL` | **0.492** | per-button width of a 50/50 action-button pair — a hair under `0.5` so the right button clears the `ScrollFrame` clip (options-ui-§6, options-ui-§10) |
| `ROW_VSPACER` | **8** | spacer between rows |
| scroll inset `TOPLEFT` | `(PADDING_X − 4, −8)` | AceGUI `ScrollFrame` vs body |
| scroll inset `BOTTOMRIGHT` | `(−(PADDING_X + 12), 8)` | reserves the scrollbar gutter, which AceGUI parks 20px right of the scroll frame |

**Tab strip** — every page (options-ui-§13):

| Constant | Value | Meaning |
|---|---|---|
| `TAB_H` | **37** | the **button frame's** height — `SetHeight` on every tab button, selected or not. Deliberately **taller than the art it carries**, so the button's foot overlaps the content panel's top edge and the selected tab merges into the page instead of floating above it. This is a frame height, not an art height, and it is **not** the wrapped-row pitch |
| `TAB_PAD_X` | **20** | label inset each side; a tab's width is the label plus twice this |
| `TAB_GAP` | **4** | horizontal gap between two tabs in a row |
| `TAB_MIN_W` | **60** | a tab is never narrower, whatever its label measures |
| `CHROME_GAP` | **8** | between the chrome band's bottom and the scroll's top |
| row pitch | *measured*, and **≤ `TAB_H`** | the **unselected tab art's** own height — the atlas texture *inside* the 37px frame, which is shorter than it. **This, not `TAB_H`, is the vertical distance between the tops of two wrapped rows**, so a second row sits flush under the first rather than being pushed down by each button's empty top strip. It is a measurement rather than a constant because an atlas has no height until the client resolves one — but it is **one** measurement, taken from the **unselected** state, which no click can change (options-ui-§13). Where nothing can be measured (a headless harness, a font not yet loaded) it falls back to `TAB_H`, which is the pre-measurement behavior and the only case in which the two numbers coincide |

**Reorder rows** — every draggable list (options-ui-§18):

| Constant | Value | Meaning |
|---|---|---|
| handle gutter | **30** | the drag handle's width at the row's far left; row contents start beyond it |
| row fill | **1, 1, 1, 0.06** | the bounded box's background; **0.03** for a row drawn dimmed |
| row edge | **1, 1, 1, 0.12** | the box's 1px border, all four sides; **0.06** dimmed |

**The two are different quantities and both govern, in one formula.** The reserved chrome band is

```
band = bannerHeight + (rowCount − 1) × pitch + TAB_H
```

— the pitch stacks every row *above* the last one, and `TAB_H` is the last row's own height. A row's y offset is `−(bannerHeight + (rowIndex − 1) × pitch)`. Both inputs are a constant and a single cached measurement taken from a state no click can change, so the band and every row offset are the same numbers for every value of the selection — which is options-ui-§13's wrap-stability invariant, expressed arithmetically. An auditor checks the two inputs, not the rendered pixels: a strip that reads its pitch off the selected tab's art, its font or its backdrop is the finding, whatever the page currently measures.

These live in the library and are read off the instance (`Helpers.TAB_H`, `Widgets.ROW_BOX`), never copied into a host constants file — the sentence at the top of this section applies to them exactly as it applies to the rest.

**Landing page** (the host's `buildMain` body — these are the host's own constants, since the body is):

| Constant | Value | Meaning |
|---|---|---|
| `LOGO_SIZE` | **300** | logo display size (source art power-of-two, e.g. 512²) |
| `GAP_AFTER_LOGO` | **8** | spacer below the logo |
| `GAP_AFTER_DESC` | **12** | spacer below the tagline |
| `GAP_BELOW_HEADING` | **6** | spacer below the "Slash Commands" heading |

- Tagline Label font: `GameFontHighlight`, left-justified, full width.
- The "Slash Commands" divider is the same AceGUI `Heading` (height 26, `GameFontNormalLarge`).

**Font summary:** title `GameFontNormalHuge` · section/landing headings `GameFontNormalLarge` · tagline `GameFontHighlight` · widget labels + slash rows the AceGUI defaults.

### 9. Registration timing (anti-pattern)

- **MUST NOT** gate the settings-**category** registration behind a slash command, a first panel-open, or any user action. Deferring `Settings.RegisterCanvasLayoutCategory` / `RegisterAddOnCategory` until the user runs `/<slash> config` leaves the addon **missing from the options list** until they act — a real defect (the group-utility addon in the collection did exactly this until it was corrected: it deferred registration inside its `config` handler to dodge a **misdiagnosed** boot-time GameMenu taint that in fact came from AceHook `RawHook`/`SecureHook` closures and a secure button, **not** the category registration). The taint-safe fix is **not** to defer registration but to register **after `Blizzard_Settings` is loaded** and keep the **body** lazy (options-ui-§1, options-ui-§5) — which is what calling the library's `CreateOptionsPanel` once at login gives you. **The category registration itself never taints** — don't confuse it with the genuine boot-taint sources (secure buttons/frames, `UISpecialFrames`, insecure hooks), which are what stay deferred.
- **MUST** wrap any panel **body** build that can run at file-load in `C_Timer.After(0, ...)` — the group-utility taint-fix pattern above. This defers the *body* only, never the category registration: the registration is the thing that must happen eagerly, and the body is the thing that must not run during load. A host whose builder is reached from the library's lazy first-`OnShow` already satisfies this; the rule bites the addon that calls a build path from a file-load code path of its own.

### 10. Scroll container

The two-column body (options-ui-§6) renders inside a single AceGUI `ScrollFrame` per subcategory, created lazily with the body. Two rules keep every panel — short or long — rendering identically.

- **Always-visible scrollbar.** The body's `ScrollFrame` **MUST** keep its vertical scrollbar shown **even when the content fits without scrolling**: park the thumb at the top and disable interaction (gray it out) rather than hiding the bar. AceGUI's stock `FixScroll` auto-hides the bar when `viewheight < height`; the library rebinds it — statelessly, idempotently, and reversibly on widget release, with the stock function preserved — to keep the bar shown and inert. This reserves a consistent right-edge gutter (options-ui-§8, scroll inset `BOTTOMRIGHT`) so a short subcategory (e.g. *General*) and a long one (e.g. *Icons*) have the **same body width and right margin** — a panel that hides its bar on short pages and shows it on long ones jitters its content width between tabs (**anti-pattern #30**).
- **Clip-safe cell edges.** The scroll content frame fills the `ScrollFrame`'s clip rect exactly, so a widget whose art reaches the right edge of its cell is shaved by ~2px (AceGUI Flow spills the right cell past the content width). Cell-filling widgets — action buttons — therefore inset their relative width per options-ui-§6 (`BUTTON_PAIR_REL`, options-ui-§8); label-inset controls (dropdowns, sliders, checkboxes) are unaffected.
- The scroll frame is parented to a **Blizzard** frame rather than an AceGUI container, so AceGUI's own size propagation never fires. It **MUST** forward the real size in on `OnSizeChanged` and re-run layout, or the scrollbar stops tracking a body resize.

### 11. Panel refresh — in place, on-screen only

An open panel **MUST** reflect live state after a mutation (a checkbox write, a slash `set`, a profile switch, a list add/remove), but **how** it refreshes decides whether the client hitches. The Blizzard Settings window shows exactly **one** subcategory at a time — refreshing off-screen pages is wasted work.

- **Scalar widgets MUST refresh in place.** Every rendered widget registers a cheap **updater closure** on its panel's `refreshers` list (re-read the value → `widget:SetValue(...)`); a refresh runs those closures, it does **not** rebuild the page. The library's makers do this for every widget they create; a host that hand-builds a widget (a bespoke header control) **MUST** append its own refresher, or nothing will ever update it — and `RestoreDefaults` will reset the underlying value while the control still shows the old one.
- Each refresher **MUST** be `pcall`'d. One dead widget must not take the rest of the UI down with it.
- **Releasing a page's widgets MUST also drop that page's refreshers.** Every render appends closures capturing widgets that a re-render releases; keep them and every later write pcalls an ever-growing pile of dead closures. Replace the list, do not wipe it in place.
- **A structural rebuild — list rows added/removed, so widgets can't just be re-valued — MUST be scoped to the on-screen subcategory.** Rebuild only the panel currently shown (`ctx.panel:IsShown()`); flag every other rendered panel **dirty** and rebuild it lazily on its next `OnShow` (extend the first-show guard to also re-render when dirty). A backgrounded page then picks up the change the next time the user opens it, at zero cost until then.
- **MUST NOT** re-run **every** rendered sub-page's full renderer on each mutation. Rebuilding all N visited pages (a complete AceGUI teardown + rebuild each) turns one checkbox toggle into O(N) page rebuilds and stalls the client for a visible beat once a handful of sub-pages have been opened — **anti-pattern #39**. Drawn from a Ka0s Consumable Master pass where a 15-sub-page panel froze ~0.5s on every settings interaction.
- A **re-rendering refresher** — one that tears its own page down and rebuilds it — **MUST** be guarded against re-entrancy *and* **MUST** clear that guard on the error path too (`pcall` the body). Latched on a raise, the page silently declines to draw for the rest of the session and only `/reload` recovers it. It **MUST** also re-render only when the thing that invalidates the layout actually changed, never on every write: a rebuild releases the very widget whose callback is still on the stack — an open dropdown pullout, a slider mid-drag — and takes scroll position and tooltips with it.
- A **per-page** Defaults button refreshes **only its own page**; a page-scoped reset that swept every open panel would re-read values the user never asked about. A **global** reset runs the host's `afterRestoreAll` hook **before** the refresh, not after, because the hook exists to clear state no schema row owns and a refresh that ran first would paint the pre-hook values.

### 12. Global reset — one act, one wording

Every Ka0s addon offers **two** ways to say *"put this back the way it shipped"*: the **Reset all settings** control on the General page (with the header **Defaults** button and `/<slash> resetall` behind the same implementation, options-ui-§1), and — where a Profiles sub-page is shipped (options-ui-§3) — AceDBOptions' own **Reset Profile**. They **MUST** be the **same act**, and a player **MUST NOT** have to discover which of the two does more.

**The act is a profile reset, and its blast radius is the active profile (MUST).**

- The global reset **MUST** reset the **active profile only**, and **MUST NOT** touch any other profile or the profile *list*. Emptying one profile is not deleting any; that distinction is the whole reason the Profiles rows are vetoed (options-ui-§3).
- It **MUST** restore **everything the profile holds** — every page, every window/panel/entry the addon lets a player create, and every stored collection a schema row cannot address. What comes back **MUST** be indistinguishable from a profile the player had just created.
- Where the addon is on AceDB, the implementation **MUST** be `db:ResetProfile()` and **MUST NOT** be a second walk of the schema. AceDB empties the profile in place, the defaults merge back, and `OnProfileReset` reaches the host's profile-changed handler — which re-runs migrations, re-seeds whatever a fresh profile needs, and publishes the addon's own profile-changed message so every window and every open panel rebuilds off **one** message (architecture, savedvariables). A host that empties the profile itself skips all of that.

**Why a row-by-row sweep is wrong, and not merely slower.** Where paths are window-relative — `window.<group>.<key>` resolved against the *selected* window (options-ui-§1) — a sweep that walks the schema **once** resets the window the player happened to have selected and silently leaves every other one alone, while any position/geometry hook beside it re-centers them all: one action with two blast radii and nothing in the UI to say which you will get. It also cannot reach a stored **array** — a column list, a spell list, a category list — because an array is addressable as a whole and its members deliberately are not, so those survive a reset that took everything around them. Both failures are silent, and both were shipping in the collection.

**What the row walk is left with (MUST).** `skipRestoreAll` (options-ui-§1) **MUST** veto the Profiles page *and* every row whose value lives in the profile. Writing each row's default first announces the addon's config-changed message once per row for values that are about to be discarded whole, and still leaves the extra windows behind. What the walk **MUST** keep is exactly what a profile reset cannot reach: **session-only rows**, whose storage is their own `set()` rather than the db (preview mode, a debug console toggle, a test mode). Those survive a profile reset and **MUST** be restored row by row or they outlive a reset that took everything around them.

**One wording, and it warns (MUST).**

- The global reset **MUST** confirm through a `StaticPopupDialogs` entry before it runs, and **MUST NOT** run on the click.
- The confirmation text **MUST** be, verbatim and localized:

  > **Reset this profile to the addon's defaults? Everything you have configured or added in it is discarded — your other profiles are not affected.**

  It is deliberately **addon-agnostic**: it covers windows, panels, recorded history, spell lists and category overrides without an addon having to enumerate its own nouns, and it says the destructive part out loud. *"Reset settings"* does not sound like *"delete my three windows"*, and an `OnAccept` that does something the text did not warn about is how a player loses a layout they spent an evening on. **MUST NOT** re-word it per addon: eight phrasings of one act is how a collection reads as eight addons.
- The buttons are the house pair, **Yes** / **No**, with `timeout = 0`, `whileDead = true`, `hideOnEscape = true`.
- The control's own tooltip **SHOULD** name the equivalence rather than restate the popup: *"the same thing Profiles → Reset Profile does"*.

**An addon with no profile-scoped storage (MUST).** A few addons keep everything account-wide — an `AceDB` with a `global` section and no `profile` section at all, because what they store is a ledger of things that happened to the account rather than a per-character preference. `db:ResetProfile()` is meaningless there, and the rule is not waived, it is *translated*: the global reset **MUST** empty the addon's account-wide store wholesale and merge its declared defaults back, so what comes back is indistinguishable from a fresh install. **MUST NOT** enumerate the keys to clear — the failure a row-by-row sweep has is exactly the failure a hand-written key list has, one release later, and both are silent. AceDB offers no `ResetGlobal`, so the host writes it: wipe the table **in place** (anything holding `db.global` keeps the live table), then re-copy the defaults.

Such an addon takes the second canonical confirmation, verbatim, because the first one's closing clause is a promise it cannot keep:

  > **Reset this addon to its defaults? Everything you have configured or recorded is discarded, for every character on this account — this cannot be undone.**

Which of the two an addon uses follows from where it stores, not from taste: a `profile` section means the first, no `profile` section means the second. An addon with **both** uses the first and resets the profile — its account-wide store is not settings, and clearing it is a separate, separately-confirmed act (a *purge*, a *delete all*), never folded into *reset settings*.

**A geometry hook is not needed for this and MUST NOT be re-added.** Positions live in the profile, so a profile reset restores them along with everything else. A `ResetPositions`-style seam wired into `afterRestoreAll` exists only to serve a row-by-row sweep; with the sweep gone it has no caller and **MUST** be removed rather than left as a dead export (`public-api`). The addon's targeted *reset positions* verb, where it has one, is unaffected and keeps going straight at whatever owns re-anchoring a live frame. **"Where it has one" is about the slash verb, not about the control**: options-ui-§15 makes a *Reset position* **row** mandatory on the Master controls tab of every addon that is not frameless, and this sentence **MUST NOT** be cited to excuse a missing one. What is optional here is whether the addon also exposes the act as a slash verb and what that verb reaches for; what is not optional is the row.

**Testing (MUST).** The suite **MUST** prove the blast radius rather than the mechanism: after a global reset with **two or more** of whatever the addon lets a player create, exactly the shipped set survives; the profile *list* is unchanged and the active profile is still the one you were on; the session-only rows were swept; and the profile-changed message was published, because a reset that empties the profile without it leaves every live window drawing settings that are no longer there.

> **Harness note.** A vendored AceDB fake may store a registered callback and *call* it, which breaks the `CallbackHandler` **string-method** form (`db.RegisterCallback(obj, "OnProfileChanged", "OnProfileChanged")`) that hosts use. Left unfixed, `db:ResetProfile()` raises in tests and the whole profile-changed path is untestable with nothing reporting it. Fix it in the addon's **own** mock extender, not in the vendored kit (testing).

### 13. Tabbed pages

Every settings page **MUST** render its sections as a **tab strip** pinned above the scroll. This is not a size threshold and not a choice: a Ka0s page has a strip, so a player who has learned one page has learned all of them. A page with exactly **one** section draws a **one-tab strip** — the tab that cannot be clicked is that page's section label, which is what it always was.

**The exemption is a page the host does not render through the flow engine**, and today that is **two** pages, both of them:

- the **Profiles** sub-page (options-ui-§3), which AceConfigDialog draws whole; and
- the **landing page** (options-ui-§5), whose body is the host's own `buildMain` — logo, tagline, a *Slash Commands* heading and one Label per `COMMANDS` row. It declares no `group` and names no sections, so there is nothing for a strip to be a strip of; its heading is the untabbed `Heading` form (options-ui-§7) and stays that way.

The exemption is stated as a property of how the page is rendered rather than as the page's name, because a name-match is a rule that stops being true the first time a page is renamed and says nothing when it does. **Enumerate both, everywhere the exemption is enumerated.** An enumeration that names only the Profiles page reads as exclusive, and an audit agent holding it files a MUST failure against every addon's landing page — which is the mandated rendering of that page, not a deviation from it.

- **One tab per section, always.** A tab **MUST NOT** hold several sections and a section **MUST NOT** span several tabs. The tab label *is* the section name, so the two cannot drift and the flow engine's existing `group` field stays the single declaration of both. A second field naming a tab is a second selector to keep in step (options-ui-§1's reasoning against a separate `widget` field, arriving one layer up).
- **Every row carries a `group`.** A page whose rows declare none cannot draw a strip; the library reports it and renders the page untabbed rather than drawing an empty strip over a blank page, and the missing `group` is the defect to fix (**anti-pattern #69**).
- **The strip wraps.** When the labels exceed one row it **MUST** wrap to a second, never truncate, scroll horizontally, or shrink a label. A page **SHOULD** hold its section count low enough for one row at default UI scale; a wrapped second row is permitted and is not a defect.
- **A wrapped strip's geometry MUST NOT depend on which tab is selected.** The row pitch and the reserved chrome band are the same numbers for every value of the selection, and no layout number may be read off a **state-dependent** measurement — the selected tab's art, its font, its backdrop. A selected tab that is drawn differently is correct; a selected tab that MEASURES differently moves every row below it and the whole page with them (**anti-pattern #70**).
- **A tab that mixes control types MUST carry subsection headings** — see options-ui-§7. The tab label names the section; a heading inside it names each kind of control the section mixes.
- **A secondary strip is permitted inside one primary tab, and it lives in the scroll.** Where one tab's content is itself a list of like subjects — one per rewritten string, one per member of a set — it **MAY** be divided by a **secondary** strip drawn as ordinary page content. The primary strip is pinned; a secondary strip belongs to the content it divides and scrolls with it. Its selection is session state like the primary one, kept **per primary tab** so returning to a category returns to the subject you were on, and it **MUST NOT** be persisted. A page **MUST NOT** nest a third level.
- **Switching tabs is a structural re-render**, and it is **not** combat-guarded. options-ui-§2's refusal covers *opening or switching a settings category*, which Blizzard protects; redrawing widgets inside a panel that is already open is not a protected action, so a tab click works in combat and a host **MUST NOT** add a guard that refuses one. What a tab switch inherits is the re-render path itself — the same one a change of subject takes — not a refusal.
- **The active tab is session state, per page, and MUST NOT be persisted.** A stored tab is UI position masquerading as a setting: it makes one page look different to two characters on one account for a reason the player never asked for, and it turns a cosmetic default into a migration the day the sections are renamed.
- **The per-page Defaults button stays page-wide.** Its label and its position do not change, so its blast radius **MUST NOT** narrow to the visible tab. A button whose meaning quietly shrank is the failure options-ui-§12 spends its whole length preventing at the global scale.

**Testing (MUST).** The suite **MUST** pin the invariant rather than the mechanism: on a strip wide enough to **wrap**, the total reserved band and every row's y offset are **identical for every value of the selection**. A harness that answers one height for every atlas cannot fail this — the harness **MUST** answer a different height for the selected-state art, or the case is green against nothing (testing-§12). Name the mutation it dies under.

### 14. The page banner and the chrome block

The band above the tab strip is where a page says what it is about. Two things belong there and nothing else does.

A page that edits **one selected instance out of many** — a window, a unit, a panel, a profile — **MUST** say which one, in a **banner** pinned in that band. Six pages that silently retarget when a picker elsewhere moves is the panel lying about what a click will change.

- **The banner carries the picker itself**, not a read-only label. A player who can see which instance they are editing and cannot change it from there has been told about the problem rather than given the fix.
- **The banner is the ONLY picker.** Where a page already carried one for the same state, that picker **MUST** be deleted rather than kept in step: one writer, one control class, and no propagation code. The banner re-reads the pointer at render time, and the structural refresh the write already triggers re-renders every panel — so two banners cannot disagree, because there is only ever one value.
- **The selection survives a tab switch and a page change.** Changing instance from a sub-page **MUST** leave the active tab alone: comparing one surface across two instances is the reason to switch from a sub-page at all, and resetting the tab defeats exactly that.

**Controls that apply to every tab MUST sit in that band too, above the strip — never in the scroll below it.** A control that governs the whole page but is drawn under one tab reads as belonging to that tab, and it disappears the moment the player clicks a different one. Creating the thing the page edits, choosing which one is being edited, and the acts that apply to it whole — enable, unlock, copy, reset, delete — are page-wide and go above the strip. A page draws **at most one** such block; where it needs both a picker and other page-wide controls, the picker goes **inside** the block and the banner is not drawn separately, because two chrome blocks are two bands and the second one pushes the page down for nothing.

**The band is ONE ROW, and where the acts do not fit in it they move to a `General` first tab.** The paragraph above was written against a page carrying a picker and an act or two, and it does not survive a page carrying six. Stacked three rows deep the band stops being chrome and becomes a second page above the page, pushing the strip and everything under it down for controls a player touches once a session — the same cost this section already refuses to pay for a second chrome block, arriving by a different route.

So the band **MUST** carry the identity controls — the picker, and the create control where the page has one — and those alone are what page-wide is worth a permanent row for. Where the remaining acts (rename, copy-from, enable, unlock, reset, delete) do not fit **beside them on one row**, they **MAY** instead be drawn on the page's **first tab, which MUST be named `General`**. Three conditions, all of them:

- **The band keeps the picker.** A page that edits one instance out of many still says which one, permanently, above the strip. That is this section's first MUST and the escape does not touch it.
- **`General` is FIRST, so the page opens on it.** The objection to a page-wide control under a tab is that it vanishes the moment the player clicks elsewhere; a tab the page lands on has not vanished, it is where the player already is. A `General` tab anywhere but first re-earns that objection in full.
- **No page-wide control is drawn on any other tab.** The acts live in the band or on `General` and nowhere else. Splitting them across both is worse than either shape alone, because the player now has to learn which is where.

A page taking this escape has **one** band row and **one** `General` tab, not a partial move of both. And it is an escape for the acts, never for the picker: a page whose band is a bare divider because the picker moved into a tab is precisely the shape the first MUST exists to forbid.

The General **page**'s first tab is `Master controls` by §15 and is not this tab. The two cannot collide, because a page carrying a picker and six acts on one instance is not the General page.

**Once a control block is in the band, it MUST NOT also be boxed.** The band is already visually separated from the page by its own divider and by the content panel's top edge; a second bounded box drawn around the same controls is a border stating a boundary the band already states (**anti-pattern #72**). Delete the box, keep the controls.

### 15. The Master controls tab

Every addon's **General** page **MUST** exist and its **FIRST** tab **MUST** be named exactly **`Master controls`**. It carries the controls that govern the addon as a whole, so that the one thing every player looks for first — how do I turn this off, how do I make it smaller, how do I put it back — is in the same place, under the same words, in every Ka0s addon.

The canonical set, in this order, laid out two per line:

| | |
|---|---|
| Enable `<AddonName>` | General visibility |
| Master scale | Master alpha |
| Lock frame | Debug console |
| Test mode | |
| Reset position | Reset all settings |

- **The set is canonical, not a menu.** An addon includes every row that applies to it and **MUST NOT** reorder them, rename them, or split them across tabs.
- **An addon with no movable frame omits exactly the frame-only rows** — master scale, master alpha, lock frame, reset position — and nothing else. A **frameless** addon (one that draws no positionable frame at all) is the only thing that omits them, and it **MUST NOT** invent a movable frame to fill the tab out. Where an addon's frames are per-instance (per window, per panel, per unit), the master rows are the addon-wide ones and the per-instance scale/alpha/lock stay on the instance's own page — the two are different settings and **MUST NOT** be conflated.
- **General visibility is a dropdown**, not a boolean: `Always` / `Only in combat` / `Only out of combat` / `Never`. An addon that ships a *show only in combat* checkbox migrates it (`true` → `inCombat`, `false` → `always`), because a boolean can only ever answer two of the four. **This is a stored-value type change and takes the full savedvariables treatment** — a bumped `schemaVersion` and a step in the migration runner, in the **same** change that changes the row's type. Changing the type alone satisfies the letter of this rule and breaks every existing install: the panel meets a stored `true` where it expects one of four strings, and the player loses a setting they already made, silently. Contrast the tab **rename**: adopting the name `Master controls` moves a `group`, which is not a stored path and needs no migration. One of the two is a migration and the other is not, and the difference is whether a **stored value** changed shape.
- **Debug console belongs here**, as a session-only row (debug-logging), not as a bespoke checkbox bolted onto some other section.
- **Test mode belongs here, in every addon with a positionable display.** An addon whose display can be positioned (preview-mode applies to it) **MUST** ship a **test mode** — placeholder content on its display, turned on and left on until turned off — and its switch **MUST** be a **`Test mode`** checkbox as the row below *Lock frame* / *Debug console*, starting its own line, with the right-hand cell empty. The mode is **session-only**: never persisted, off after `/reload`, and ended by *Reset all settings* (the row declares `default = false`). It **shows** the display without requiring an unlock — it MAY unlock as a side effect, and a verb such as `/<slash> test` MAY drive the same switch — and **it ends when combat starts** (`PLAYER_REGEN_DISABLED`, while secure writes are still allowed), so no placeholder covers real data in a fight. The checkbox follows every start and stop, and a refused start leaves it unticked. It is **composed, never hand-written**: the `MasterControls` composer emits it from `testModePath` (LibKa0s v1.37.0), and the host binds its get/set the way it binds the console row's. A one-shot test action (a sample line printed, a flow run once, a value held for a few seconds) MAY stay beside it as a verb or the composer's `leadButton`, but does not replace it. **Only a frameless addon** — one that draws no positionable display — omits the row. A positionable display with no Test mode checkbox, or with its test mode drawn as a button or reachable only from chat, is **anti-pattern #80**.
- **The two resets are the tab's closing button pair** (`BUTTON_PAIR_REL`, options-ui-§8), and *Reset all settings* is options-ui-§12's global reset verbatim — the same one act, the same wording, the same blast radius. A frameless addon draws *Reset all settings* alone.
- **The rows are composed, not hand-written** (options-ui-§16's rule applies here too): the library's `MasterControls` composer emits the canonical set from one declaration, so nine addons cannot drift into nine orders.

A General page whose first tab is something else, or that has no tab strip at all, is **anti-pattern #68**.

### 16. Control groups — font, border, bar

Three kinds of control recur in every addon that paints anything, and a player who has set a font in one Ka0s addon **MUST** find the same rows in the same order in the next one. Each group is a fixed row-set with a fixed layout.

**Font.** Font controls **MUST** appear together, as one contiguous block, in this order:

| | |
|---|---|
| Font | Font size |
| Font color | Use class color |
| Font flags | Font shadow |

**Border.** A border group **MUST** carry these four rows in this order, optionally preceded by the group's own *Show border* toggle where the addon has one:

| | |
|---|---|
| Border style | Border thickness (px) |
| Border color | Use class color |

**Bar.** A bar group — a group over a **status bar**, a thing with a fill texture — **MUST** carry:

| | |
|---|---|
| Bar texture | Bar opacity |
| Bar color | Use class color |

- **The mandated rows come first, contiguous, in that order.** An addon **MAY** append further rows of the same kind **after** the block, under the same subsection — a border offset, a fill direction, a bar spacing. It **MUST NOT** interleave them, and it **MUST NOT** drop a mandated row because its addon has no use for it: a control the addon cannot honor is a control it should not have needed a group for.
- **A group over a background is not a bar group.** A container with a backdrop and no fill texture takes a background swatch and its class-color companion (options-ui-§17) and nothing else; inventing a texture picker for a surface that has no texture is a control wired to nothing.
- **These groups are COMPOSED, not typed out.** The library emits each block from one declaration; a hand-written copy is **anti-pattern #73**. The composer is what makes the order, the labels, the ranges and the companion identical in nine addons without nine people agreeing to be careful.
- **What the composer MUST binds is a BLOCK, and the shared-media grep is a finder rather than the finding.** An `LSM30_Font` / `LSM30_Border` / `LSM30_Statusbar` control outside a composer call site is a §16 finding when the rows around it **reproduce a mandated block** — recognizable by that block's *companions*: a font copy carries the size, color, flags or shadow rows, a border copy carries thickness and color, a bar copy carries opacity and color, and both color-bearing copies carry the class-color companion (options-ui-§17). A media row standing alone, carrying **none** of its block's companions, is not a copy of a block, and grading it as one reads the mechanical form against the rule's own stated intent — #73 names a hand-written *copy of a group*, not the presence of a media dropdown.
- **The addon-wide broadcast meta row is the named case, and it is exempt.** One *All surfaces* control — *Bar texture (all surfaces)*, *Font (all surfaces)* — whose `onChange` fans the chosen value out over the composed groups it broadcasts to is a **fan-out control, not a group**: there is no composer arm to call, because what the library composes is a group and this is a single row. The live case is `MultiMeters/settings/Schema.lua:1553-1566`. The exemption is bounded, and each bound is a MUST:
  - **One row per media kind**, under its **own subgroup** whose heading names the scope (options-ui-§7), with a **label that names the scope too**. A player MUST be able to tell the broadcast control from the per-surface one without clicking it.
  - Its `onChange` **MUST** write through the addon's single write seam (options-ui-§1), and the paths it writes **MUST** themselves be composed rows. A broadcast into hand-written groups is a hand-written group with an extra step in front of it.
  - It **MUST NOT** carry any of its block's companions — no thickness, no opacity, no swatch, no class-color companion. The moment it grows one it *is* a group, and §16 binds it whole.
  - It **MUST NOT** be the only place its media kind is settable. The per-surface groups it broadcasts to have to exist, and to be composed; a broadcast row over nothing is a group that skipped the composer.
  - **The exemption retires** the day `LibKa0s-OptionsCompose` exposes a broadcast-meta arm — at which point the row is composed like every other and the rule above binds it with no exception at all.
- **A tab holding more than one of these groups carries a subsection heading per group** (options-ui-§7). Merging a background group and a border group onto one tab is a legitimate choice and is not undone by this rule — what the rule requires is that the merged tab says where one stops and the next starts.

### 17. The class-color companion

**Every color-picker control in a Ka0s addon MUST be accompanied by a way to say *use the class color instead*, placed immediately to its right** in the two-column layout. A swatch on its own asks the player to hand-match a color the game already knows.

- **The companion is a checkbox — `Use class color` — or a color-mode dropdown whose value set includes `class`.** The dropdown is the richer form and satisfies this rule wherever a surface genuinely has more than two answers (a per-statistic color, a skin color, none). An addon that already ships the dropdown **MUST NOT** be converted back to a checkbox: that trades a three-value control for a two-value one and loses the modes the third value names. An addon that ships neither adds the checkbox.
- **Default OFF**, unless the addon already ships it on, in which case it stays on.
- **Which class.** The color resolves to the class of the unit the surface **DESCRIBES**: a per-unit bar, cast bar or label takes the **tracked unit's** class; everything else — chrome, panels, the player's own cooldowns and glows, anything not about a particular unit — takes the **player's**. The path a setting is stored under does **NOT** decide this: a control living under `units.<unit>.` that draws the player's own spells is player-scoped. Because the path cannot be trusted, the intent **MUST** be declared on the row (`classColorSource = "player" | "unit"`), and that declaration is what an audit reads.
- **An unresolvable class is not a color.** An NPC, an unknown unit, a class the client has not answered for — the control falls through to the **stored swatch**, never to white, never to gray, never to a substitute hue. A tenth color invented for the occasion is a color nobody chose.
- **The stored alpha survives the mode.** No class-color source carries an alpha, so the swatch's opacity always applies, under either mode.
- **The swatch is therefore NEVER disabled while the companion is on.** `disabledIf` on a color row is forbidden (**anti-pattern #74**): the row is still read — for its alpha — so graying it tells the player something untrue. Say it in words instead, in the swatch's tooltip: *not read while Use class color is on, except for its opacity, which always applies*.
- **One resolver.** The lookup is the library's (`RAID_CLASS_COLORS`, which is what every other UI on the player's screen is already using), not a fifth private copy, and the player's own answer is cached only on success while no other unit's is cached at all.
- **Palette-definition swatches are exempt**, and are the only exemption: a set of colors that *identifies* something other than a player — one color per statistic, per rarity, per category — has no class to take. A companion beside *Damage done color* is a control with no meaning.
- **A background swatch resolves through the addon's own background palette where it has one**, and through the shared resolver where it does not. A darkened per-class background set is a different set of hues, not the class color times a constant, and the two **MUST NOT** be substituted for each other.

### 18. Reorder lists

Where the **order** of a list is the setting, the player **MUST** be able to drag it, through the shared reorder widget (`LibKa0s-Widgets-1.0`'s `ReorderList`). Paired up/down arrow buttons are **anti-pattern #75** wherever the widget can be used: two clicks per position, no feedback about where an item is going, and a different set of arrows drawn in every addon that has them.

- **The library owns the chrome.** The drag handle — the hamburger mark from the shared icon catalog, in a fixed-width gutter at the row's **far left** — and the row's **bounded box** (background fill and a 1px border, values pinned in options-ui-§8) are the widget's, so every draggable list in the collection reads the same. So are the drag itself, the copy that follows the cursor, the insertion line and the index arithmetic.
- **The row's CONTENTS are entirely the consumer's** and are expected to differ: icons, checks, labels, right-aligned text, buttons. A host **MUST NOT** draw its own row fill, border or handle — that is the double chrome the shared widget exists to prevent — and **MUST NOT** make the whole row draggable, which would swallow presses aimed at the controls inside it.
- **Rows in one list are a uniform height.** The drop position is arithmetic on the row stride, not a hit test, so a list of unequal rows drops in the wrong place.
- **A drag never crosses a boundary the data does not have.** Where a list is divided into sections whose membership is fixed — in combat / out of combat, collecting / not collecting — a drag reorders **within** a section only, and the rule is enforced by the widget's boundary rather than by hoping.
- **The reorder controller MUST be canceled at the top of a render, before the first widget is created**, not merely before the list is rebuilt. Its handles and row boxes are pooled, and a controller released late leaves them attached to recycled widgets belonging to something else. This is a shipped-bug lesson, and it is the single most common way an adoption of this widget goes wrong.
- **Without the library there is no handle and no box.** That is an accepted cosmetic degradation, stated here so nobody re-solves it host-side: a host-drawn box is the drift this rule exists to end.
