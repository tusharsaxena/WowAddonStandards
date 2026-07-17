> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Options UI

### 1. Canonical pattern

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
- **MUST register the category eagerly at addon load** — in `OnInitialize`, or from a bootstrap frame firing on `PLAYER_LOGIN` / `ADDON_LOADED → Blizzard_Settings` — so the addon's entry is **always present** in the Blizzard options list, even before its panel body is built. **MUST NOT** defer the `Register*Category` calls to the first `/<slash> config` / panel-open (options-ui-§9). Reference implementations (in the collection): the modular tracker registers from a bootstrap frame on `ADDON_LOADED(Blizzard_Settings)`/`PLAYER_LOGIN`; the loot-history browser registers in `OnInitialize`. Both are taint-free because they register **after** `Blizzard_Settings` is available and keep the body lazy.
- **MUST** render content with **raw AceGUI** inside the canvas. **MUST NOT** use AceConfigDialog for content. (Industry: the two largest boss-mod / aura frameworks use AceConfig at a scale that justifies the tax; the big UI-replacement and nameplate suites hand-roll. Ka0s sits in the AceGUI sweet spot.)
- **MUST** build the **body** lazily in first `OnShow`. (Universal Ka0s pattern; AceGUI lays out against the panel's current width, which is 0 before first show.)
- **MUST** wrap any panel-build that can run at file-load in `C_Timer.After(0, ...)` (the group-utility taint-fix pattern) — but this defers the *body*, never the category registration.
- The single-category snippet above is the minimum entry point; options-ui-§5–§8 extend it into the mandatory **landing-page + subcategory** structure, **two-column** body, and **section-header** styling that every Ka0s panel now shares.

### 2. Combat lockdown

- **MUST** check `InCombatLockdown()` before **opening** the options panel — for the `config` slash verb **and** every programmatic caller. Put the gate **inside the panel-open function itself** (not only the slash dispatcher) so other addons, `/run` scripts, and future internal callers are gated too. (This gates panel *open*, not category *registration*, which happens taint-free at load per options-ui-§1.)
- Under lockdown the addon **MUST refuse** the open: print a single `NS.PREFIX`-tagged **grey notice** and return. The canonical text is **"cannot open settings during combat — Blizzard's category-switch is protected"**. It **MUST NOT** call the protected category-switch (`Settings.OpenToCategory`) under lockdown — doing so taints the panel for the rest of the session — and **MUST NOT** silently no-op.
- **MUST NOT** defer-and-replay the open (registering `PLAYER_REGEN_ENABLED` to auto-open when combat ends). A panel that pops itself open the instant combat drops is surprising and steals focus during post-pull recovery; the house behaviour is an explicit, greppable refusal now, and the user re-runs `/<slash> config` when they choose. *(The safe move for a taint-prone protected path is to not touch it at all and say why — distinct from a deferred **secure frame write**, which legitimately queues on `PLAYER_REGEN_ENABLED`; see events-frames-taint-§2.)* Reference implementation (in the collection): the chat-formatting addon refuses in its `OpenConfig` with exactly this grey notice.
- **SHOULD** apply the same `InCombatLockdown()` gate to any settings setter that creates/destroys frames.

### 3. Profiles sub-page

- **MAY** ship a Profiles sub-category using AceDBOptions-3.0 + AceConfigDialog-3.0. **If included**, vendor AceConfig in `libs/` like every other lib (library-stack-§3).
- **SHOULD** be the **only** legitimate use of AceConfig in a Ka0s addon.

### 4. Lazy options loading (large addons)

- For addons with ≥5 options sub-panels or whose options code is large, **SHOULD** ship options as a sibling LoadOnDemand addon (`<Addon>_Options.toc` with `## LoadOnDemand: 1`). None of the current Ka0s addons need this.

### 5. Landing page + subcategories

Every Ka0s options panel **MUST** be built as a **parent canvas category = landing page** with one or more **canvas subcategories** for the actual settings (the first named "General"). Reference implementations (in the collection): the modular tracker's `settings/Panel.lua` and the loot-history browser's `settings/Panel.lua`.

```lua
local main = Settings.RegisterCanvasLayoutCategory(mainPanel, "Ka0s <Addon>")
Settings.RegisterAddOnCategory(main)
local sub  = Settings.RegisterCanvasLayoutSubcategory(main, generalPanel, "General")
```

- The **landing page** (parent panel) **MUST** render, top to bottom: the addon **logo**, a full-width **tagline** Label (`GameFontHighlight`), a **"Slash Commands"** section heading, then one Label per command generated from the addon's `COMMANDS` table (so the list stays in lockstep with `/<slash> help`). Command rows use `|cffffff00/<slash> <verb>|r  —  <desc>`.
- **Logo asset:** ship a **`.tga`** (or `.blp`) under **`media/logos/`** — WoW **cannot** load `.jpg`/`.png` textures at runtime. Reference it by absolute path `Interface\AddOns\<Folder>\media\logos\<name>.tga`, display at **300×300**; source art SHOULD be power-of-two (e.g. 512×512). Keep the original `.jpg`/`.png` beside it for editing.
- **Header (both parent and subcategory):** left-aligned title in `GameFontNormalHuge`, a gold `Options_HorizontalDivider` tinted to the title's colour, and (subcategories) a **Defaults** button top-right. Subcategory titles render as a breadcrumb **"Ka0s <Addon> ▸ <Page>"** with the arrow via `|A:common-icon-forwardarrow:16:16|a`.
- **The Defaults button MUST be an AceGUI `Button`, not a raw `CreateFrame("Button", …, "UIPanelButtonTemplate")` parented onto the Settings canvas.** A `UIPanelButtonTemplate` button created as a **direct child of the Blizzard Settings canvas** inherits the canvas's **red** button skin; AceGUI creates its button under `UIParent` and reparents the `.frame`, sidestepping that skinning so the button keeps the standard dark/gold options look. Build it as `AceGUI:Create("Button")` → `:SetText(...)` → `:SetWidth(DEFAULTS_W)` → `btn.frame:SetParent(panel)` / `:ClearAllPoints()` / `:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PADDING_X, -HEADER_TOP)`. The same rule applies to any other header/action button parented onto the canvas.
- Bodies **MUST** build lazily in first `OnShow` (options-ui-§1) — AceGUI lays out against the panel's current width, which is 0 before the panel is first shown.

### 6. Two-column layout (default)

Schema-driven panels **MUST** default to a **two-column grid**: pair consecutive schema rows into 50%/50% widgets (`widget:SetRelativeWidth(0.5)`) inside a full-width Flow `SimpleGroup`, with a small vertical spacer between rows.

```lua
-- pair rows; flush the row once it holds two widgets (or on a wide row / group change)
if not pendingRow then pendingRow = flowGroup() end
makeWidget(row, pendingRow, 0.5)
if #pendingRow.children >= 2 then flushRow() end
```

- A row that is intrinsically wide (a multi-check block, a long list) **MAY** set `wide = true` to break onto its own full-width line.
- The pairing is **schema-driven**: each row's `group` names its section (options-ui-§7) and row order within a group drives the pairing — no per-panel layout code.
- A widget that **fills its cell edge-to-edge** — an action `Button`, e.g. the 50/50 pair at the foot of a group (*Reset position | Reset all settings*) — **MUST** inset to **`SetRelativeWidth(0.492)`** (constant `BUTTON_PAIR_REL`, options-ui-§8), never a flush `0.5`. AceGUI's Flow layout spills the right cell ~2px past the content width, and because the scroll content fills the `ScrollFrame` clip rect exactly (options-ui-§10), that spill — including the button's right border — is otherwise shaved off. Label-inset controls (dropdowns, sliders, checkboxes) are immune because their art sits inset from the cell edge; a cell-filling button is not. Centralise the inset in the shared button-pair maker so every panel inherits it — never hand-set `0.5` on a paired button.

### 7. Section headers

Group options under **section headers** rendered as an AceGUI **`Heading`** (a centred label flanked by horizontal dividers), font bumped to `GameFontNormalLarge`, with a small spacer above (except the first) and below.

```lua
local h = AceGUI:Create("Heading")
h:SetText(groupName); h:SetFullWidth(true)
h.label:SetFontObject(GameFontNormalLarge)
```

This is the same widget used for the landing page's "Slash Commands" divider, so headers read identically across the landing page and every subcategory.

### 8. Layout constants (exact values)

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
| `BUTTON_PAIR_REL` | **0.492** | per-button width of a 50/50 action-button pair — a hair under `0.5` so the right button clears the `ScrollFrame` clip (options-ui-§6, options-ui-§10) |
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

### 9. Registration timing (anti-pattern)

- **MUST NOT** gate the settings-**category** registration behind a slash command, a first panel-open, or any user action. Deferring `Settings.RegisterCanvasLayoutCategory` / `RegisterAddOnCategory` until the user runs `/<slash> config` leaves the addon **missing from the options list** until they act — a real defect (the group-utility addon in the collection did exactly this until it was corrected: it deferred registration inside its `config` handler to dodge a **misdiagnosed** boot-time GameMenu taint that in fact came from AceHook `RawHook`/`SecureHook` closures and a secure button, **not** the category registration). The taint-safe fix is **not** to defer registration but to register **after `Blizzard_Settings` is loaded** and keep the **body** lazy (options-ui-§1) — the pattern every Ka0s addon uses. **The category registration itself never taints** — don't confuse it with the genuine boot-taint sources (secure buttons/frames, `UISpecialFrames`, insecure hooks), which are what stay deferred.

### 10. Scroll container

The two-column body (options-ui-§6) renders inside a single AceGUI `ScrollFrame` per subcategory. Two rules keep every panel — short or long — rendering identically.

- **Always-visible scrollbar.** The body's `ScrollFrame` **MUST** keep its vertical scrollbar shown **even when the content fits without scrolling**: park the thumb at the top and disable interaction (grey it out) rather than hiding the bar. AceGUI's stock `FixScroll` auto-hides the bar when `viewheight < height`; rebind it to keep the bar shown and inert. This reserves a consistent right-edge gutter (options-ui-§8, scroll inset `BOTTOMRIGHT`) so a short subcategory (e.g. *General*) and a long one (e.g. *Icons*) have the **same body width and right margin** — a panel that hides its bar on short pages and shows it on long ones jitters its content width between tabs. Reference implementation (in the collection): the modular tracker's always-show-scrollbar `FixScroll` rebind.
- **Clip-safe cell edges.** The scroll content frame fills the `ScrollFrame`'s clip rect exactly, so a widget whose art reaches the right edge of its cell is shaved by ~2px (AceGUI Flow spills the right cell past the content width). Cell-filling widgets — action buttons — therefore inset their relative width per options-ui-§6 (`BUTTON_PAIR_REL`, options-ui-§8); label-inset controls (dropdowns, sliders, checkboxes) are unaffected.

### 11. Panel refresh — in place, on-screen only

An open panel **MUST** reflect live state after a mutation (a checkbox write, a slash `set`, a list add/remove), but **how** it refreshes decides whether the client hitches. The Blizzard Settings window shows exactly **one** subcategory at a time — refreshing off-screen pages is wasted work.

- **Scalar widgets MUST refresh in place.** Each rendered widget registers a cheap **updater closure** (re-read the value → `widget:SetValue(...)`); a refresh runs those closures, it does **not** rebuild the page. Keep a per-panel `refreshers` list and have the refresh entry point run them. Reference implementation (in the collection): the modular tracker's `refreshers` list, run by `RefreshAllPanels`.
- **A structural rebuild — list rows added/removed, so widgets can't just be re-valued — MUST be scoped to the on-screen subcategory.** Rebuild only the panel that is currently shown (`ctx.panel:IsShown()`); flag every other rendered panel **dirty** and rebuild it lazily on its next `OnShow` (extend the first-show guard to also re-render when dirty). A backgrounded page then picks up the change the next time the user opens it, at zero cost until then.
- **MUST NOT** re-run **every** rendered sub-page's full renderer on each mutation. Rebuilding all N visited pages (a complete AceGUI teardown + rebuild each) turns one checkbox toggle into O(N) page rebuilds and stalls the client for a visible beat once a handful of sub-pages have been opened — **anti-pattern #39**. Drawn from a Ka0s Consumable Master pass where a 15-sub-page panel froze ~0.5s on every settings interaction.
