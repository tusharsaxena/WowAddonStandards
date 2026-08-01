> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Options UI

Every Ka0s addon's settings surface is the **same** surface: a Blizzard canvas landing page, one canvas subcategory per topic, a two-column schema-driven body inside an always-scrollbarred `ScrollFrame`, a lazily built **Defaults** button top right, and a panel-open that refuses under combat. That sameness is the product, not a coincidence — a user who has configured one Ka0s addon has configured all of them — and it is now delivered by a **shared library** rather than by five copies of a toolkit drifting apart.

**Adoption strength.** **MUST** for the **wiring** — vendor `LibKa0s-Options-1.0`, create one instance at load from a descriptor, stash it on the namespace, degrade when it is absent. **MUST** for the **behavior contract** below (options-ui-§5 through options-ui-§11): those rules describe what a Ka0s panel *is*, and they hold whether or not a given release of the library implements them for you. **SHOULD** for which pages an addon splits its settings into — that is genuinely addon-specific. Hand-rolling the panel shell, the widget makers or the flow engine when the library provides them is **anti-pattern #47**.

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

Options **MUST** be grouped under **section headers** rendered as an AceGUI **`Heading`** (a centered label flanked by horizontal dividers), font bumped to `GameFontNormalLarge`, with a small spacer above (**except the first** — a leading gap reads as a broken top margin) and below. The flow engine emits one automatically whenever a row's `group` changes, so a section header is declared by a row, never drawn by a builder.

This is the same widget used for the landing page's "Slash Commands" divider, so headers read identically across the landing page and every subcategory.

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
