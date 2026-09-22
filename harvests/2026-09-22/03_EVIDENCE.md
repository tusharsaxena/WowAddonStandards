# Harvest 2026-09-22 — 03 Evidence

The verbatim excerpts the surviving proposals rest on, each quoted with its source. Every quote below was
read out of the working tree at `/mnt/d/Profile/Users/Tushar/Documents/GIT/` on 2026-09-22, at the line
given, and nothing here is paraphrase. Where one quirk was written up in several repos, **all** the
versions are quoted and the deepest is marked, because a merge that averages three write-ups down to their
common denominator throws away the part that cost someone an afternoon.

Line numbers drift. Where a proposal's own citation pointed at the wrong line, the correct line is quoted
here and the drift is noted, so the ripple plan resolves against what is actually there.

---

## C8-F02 — the LibKa0s inventory, wrong in nine places (with C5-F03, C8-F01, C8-F04, C8-F05, C8-F06)

**What the library actually ships.** `ls LibKa0s/LibKa0s/*.lua | wc -l` → **18**:

> Core.lua DebugLog.lua Env.lua Item.lua Launcher.lua Lifecycle.lua Media.lua Options.lua
> OptionsCompose.lua OptionsScroll.lua OptionsTabs.lua OptionsWidgets.lua Perf.lua PerfPanel.lua
> Pool.lua Slash.lua Widgets.lua WidgetsDragHandle.lua

`LibKa0s/tests/majors.lua:68-78` — the repo's own gate-backed manifest, read by both `tests/run.lua` and
`tools/gen-api-members.lua`:

> ```lua
>   {
>     major = "LibKa0s-Options-1.0",
>     files = { "Options", "OptionsWidgets", "OptionsTabs", "OptionsCompose", "OptionsScroll" },
>     primary = "Options",
>     paired = {
>       { file = "OptionsWidgets", minorField = "__widgetsMinor", probeField = "__widgetsShellMinor" },
>       { file = "OptionsTabs",    minorField = "__tabsMinor",    probeField = "__tabsShellMinor" },
> ```

`LibKa0s/LibKa0s/OptionsTabs.lua:1-12` — the file the standard never names, and what it owns:

> ```lua
> -- LibKa0s-Options-1.0 — the page's CHROME: the tab strip, the page banner, the header block and
> -- the secondary strip, plus the client art all four are drawn from.
> --
> -- Peeled out of OptionsWidgets.lua at v1.39.0 (issue #16), along the seam that file was already
> -- built along rather than a new one: the chrome half and the widget half do not reach into each
> -- other. …
> --
> -- Since minor 2 it also carries the combat lock's page chrome (options-ui-§2): the one event frame
> -- the lock listens on, the cover over a page and the level that puts it above the strip.
> ```

`LibKa0s/LibKa0s/OptionsTabs.lua:40`:

> ```lua
> local TABS_MINOR = 3
> ```

### The nine places the standard states it wrongly

`standards/standards/library-stack.md:82`:

> **The modules.** `LibKa0s` ships **twelve LibStub majors across seventeen files** … The file count is
> not the major count and never was: `Options` spans four files and `Perf` two. **Both figures are
> recounted, not incremented.**

`standards/standards/library-stack.md:94` — the Options row, four files:

> | `LibKa0s-Options-1.0` | `Options.lua`, `OptionsWidgets.lua`, `OptionsCompose.lua`, `OptionsScroll.lua` | …

`standards/standards/library-stack.md:91` — the Widgets row, one file:

> | `LibKa0s-Widgets-1.0` | `Widgets.lua` | the collection's flat dropdown and the single popup menu …

`standards/standards/library-stack.md:103`:

> … and **ten of the eleven majors refuse to r**[egister without `Core.lua`]

`standards/standards/library-stack.md:113` — the sentence that contradicts itself mid-line:

> **Inter-module dependencies (MUST).** **Eleven of the twelve majors** need `LibKa0s-Core-1.0` … and
> three of the ten gate on it without calling a single member — `Lifecycle` among them …

`standards/standards/options-ui.md:13`:

> The major spans **three** files (`Options.lua`, `OptionsWidgets.lua`, `OptionsScroll.lua`) and depends
> on `LibKa0s-Core-1.0`; copying one file and not its siblings yields a shell with no widget makers and
> no scrollbar patch (**anti-pattern #48**).

`standards/standards/anti-patterns.md:54` — #48, the rule whose job is to diagnose a partial vendor:

> … or a shell file (`Options.lua`, `Perf.lua`) without the attach file that completes it
> (`OptionsWidgets.lua`/`OptionsScroll.lua`, `PerfPanel.lua`) … **Four of LibKa0s's five majors** `return`
> **before** `LibStub:NewLibrary` when Core is missing or older than their floor …

`standards/NEW_ADDON_CONTEXT.md:817` — the pack's own test runner file list:

> ```lua
>   "libs/LibKa0s/Options.lua", "libs/LibKa0s/OptionsWidgets.lua", "libs/LibKa0s/OptionsScroll.lua",
> ```

`standards/NEW_ADDON_CONTEXT.md:1037` — the copy a new addon is born reading:

> … because **ten of the eleven majors** refuse to register without `Core.lua` and a shell without its
> attach file `:New`s successfully and then fails a panel build later (anti-pattern #48).

`standards/EXECUTIVE_SUMMARY.md:56`:

> - Shared Ka0s-owned code ships as the vendored **`LibKa0s`** library — twelve LibStub majors across
> seventeen files …

`standards/standards/open-evolutions.md:13` — **the copy neither sweep found**, and the reason the fix must
be a ripple rather than an edit:

> - **Further `LibKa0s` modules.** … Shipped so far: the secret-safe/printer seams (Core), the client-fact
> reader (Env), the widget pool (Pool), the item primitives (Item), the shared media catalog (Media), the
> flat dropdown and copy window (Widgets) …

`standards/STANDARDS.md:57` — the Sections-list blurb:

> the Ka0s-owned `LibKa0s` umbrella — twelve majors across seventeen files — vendored whole

**Rollout is nil.** `OptionsTabs.lua` is byte-identical (md5 `deef16f2e6a8abc072dedafdf53c53d4`) in LibKa0s
and in all eleven addons' `libs/LibKa0s/`, so no addon becomes non-compliant.

---

## C8-F03 — `Widgets.DragHandle`, extracted for two hands-built copies and named nowhere

`LibKa0s/LibKa0s/WidgetsDragHandle.lua:1-8` — the library's own argument, which is `library-stack-§7`'s
bar 1 stated in the library's voice:

> ```lua
> -- LibKa0s-Widgets-1.0 — the unlocked drag handle: a labeled strip with a help mark, dragged to move
> -- the frame it belongs to.
> --
> -- ── WHY THIS IS A LIBRARY AND NOT TWO COPIES ────────────────────────────────────────────────
> --
> -- AuraMaster drew one per container (modules/Anchors.lua) and ConsumableMaster drew one over its
> -- macro bar (modules/MacroBar.lua), and the two were the same widget twice: the same 18px strip,
> -- the same 2px gap, the same 24px of padding, the same centered gold GameFontNormalSmall label,
> ```

`LibKa0s/tests/majors.lua:48-51` — version-paired, so the file is load-bearing rather than incidental:

> ```lua
>     major = "LibKa0s-Widgets-1.0",
>     files = { "Widgets", "WidgetsDragHandle" },
>     primary = "Widgets",
>     paired = { { file = "WidgetsDragHandle", minorField = "__dragMinor", probeField = "__dragShellMinor" } },
> ```

**Three consumers, eight non-consumers.** `grep -rn "DragHandle"` over the addons' own code:

> `AuraMaster/modules/Anchors.lua:414`: `if not (KW and KW.DragHandle) then return nil end`
> `AuraMaster/modules/Anchors.lua:416`: `local handle = KW.DragHandle(anchor, {`
> `ConsumableMaster/modules/MacroBar.lua:176`: `local handle = Widgets and Widgets.DragHandle and Widgets.DragHandle(frame, {`
> `KickCD/modules/Castbar_Handle.lua:88`: `if not (KW and KW.DragHandle) then return nil end`
> `KickCD/modules/Castbar_Handle.lua:89`: `local handle = KW.DragHandle(frame, {`

`grep -rn "DragHandle\|DRAG_HANDLE" WowAddonStandards` → **zero hits, repo-wide.** The comparison that makes
this a rule question rather than only a table fix is the sibling member in the same major,
`standards/standards/library-stack.md:91`:

> **`ReorderList`** — the drag-to-reorder list every ordered setting in the collection is required to use
> (options-ui-§18), which owns the hamburger handle, the bounded row box …

Four addons consume `ReorderList` and it is a MUST; three consume `DragHandle` and nothing mentions it. The
difference between the two members is a rule, not a quality gap.

---

## C1-F03 — `tests/test_surface_parity.lua` (with C1-F04)

**Eleven for eleven, and every one names the file at line 1.** Four quoted; the other seven are the same shape.

> `AbsorbTracker/tests/test_surface_parity.lua:1`
> `-- tests/test_surface_parity.lua — every degradation stub carries the whole live surface.`
>
> `AuraMaster/tests/test_surface_parity.lua:1-2`
> `-- tests/test_surface_parity.lua — every degradation stub carries the whole live surface it stands`
> `-- in for, minus the members named here with the reason (testing-§8).`
>
> `ConsumableMaster/tests/test_surface_parity.lua:1-2`
> `-- tests/test_surface_parity.lua — one stub-surface parity case per adopted`
> `-- LibKa0s seam (testing-§8, anti-pattern #56).`
>
> `PartyFrameEnhanced/tests/test_surface_parity.lua:1-2`
> `-- tests/test_surface_parity.lua — every degradation stub carries the whole live surface it stands in`
> `-- for (testing-§8). The degraded arm comes from a real library-absent load (tests/degraded_env.lua),`

A twelfth, in the library itself — `LibKa0s/tests/test_surface_parity.lua:1`:

> `-- tests/test_surface_parity.lua — the degradation-stub gate, asserted here first.`

**What the section says, and does not.** `standards/standards/testing.md:164-175` (the proposal cited `:1`,
which is section boilerplate; the rule is here):

> **Stub-surface parity (MUST).** … The failure that ships is a degradation stub whose **member set** has
> drifted from what the host actually calls, which loads perfectly and then raises at the moment a user
> reaches the one path that calls the missing member — anti-patterns #56.
>
> - **MUST** carry, **per adopted LibKa0s module**, a **stub-surface parity case**: a declared list of the
>   members the addon reaches on that instance, asserted **present on both arms** …
> - **MUST** derive the member list by **grep**, and **MUST** name the grep that produced it **in the
>   case's comment** …

Four bullets of detail and no filename. `grep -rn "surface_parity" standards/standards/` returns hits only in
`anti-patterns.md:65` and `testing.md:164,169`, in none of them as a filename.

**The cheatsheet's only test row** — `standards/standards/naming-cheatsheet.md:11`:

> | Test suites | `test_<module>.lua` | `test_database.lua` |

There is no module called SurfaceParity.

**The standard's own precedent, which makes this an outlier rather than a general gap** —
`standards/standards/slash-commands.md:271`:

> Every addon **MUST** carry a **`tests/test_disabled.lua`** suite, listed in `tests/run.lua`'s suite list
> like any other (testing-§1), inside the green gate (testing-§4).

That is a rule-subject conformance suite named by filename at the point it is mandated. §8 simply did not.

---

## C1-F06 — the bus-message constant table (`NS.MSG`)

**What the standard's own example does** — `standards/standards/architecture.md:83-87`:

> ```lua
> -- Producer (one per message; send on any embed — SendMessage fans out to all receivers)
> NS.bus:SendMessage("Ka0s_<Addon>_RosterChanged", roster)
>
> -- Consumer (MUST register on its OWN target, never the shared bus — see the receiver rule)
> NS.<Module>.__ev:RegisterMessage("Ka0s_<Addon>_RosterChanged", function(_, roster) ... end)
> ```

The literal is typed at both call sites. The four MUSTs that follow (`:90-93`) govern the prefix, the
documentation, the single sender and the per-receiver target — and none of them the constant.

**The five that publish it once.** `AbsorbTracker/core/Bus.lua:87-92`:

> ```lua
> -- Message-name catalog. Prefixed Ka0s_<Addon>_ to avoid cross-addon collision.
> NS.MSG = {
>     REPAINT    = "Ka0s_AbsorbTracker_RepaintRequested",
>     APPEARANCE = "Ka0s_AbsorbTracker_AppearanceChanged",
>     VISIBILITY = "Ka0s_AbsorbTracker_VisibilityChanged",
>     POSITION   = "Ka0s_AbsorbTracker_PositionChanged",
> ```

`AuraMaster/core/Bus.lua:30-36` — the same table, and the sender comment the SHOULD would ratify:

> ```lua
> NS.MSG = {
>     -- Sender: modules/ContainerManager.lua. Payload: none. A container was created, deleted,
>     -- renamed or duplicated, or the profile under the registry changed. …
>     CONTAINERS_CHANGED = "Ka0s_AuraMaster_ContainersChanged",
>     -- Sender: settings/Schema.lua (the single write seam). Payload: ({ section, containerId, path }).
> ```

`ConsumableMaster/core/Bus.lua:78` (`KCM.MSG = {`) and `PartyFrameEnhanced/core/Bus.lua:135` (`NS.MSG = {`)
are the same shape under a different holder — which is why the rule must be written against the namespace
seam rather than the literal token `NS`.

`MultiMeters/core/Constants.lua:507-515` — the fullest statement of the reason, and the third repo that
names senders in-file:

> ```lua
> -- Modules talk to each other through AceEvent messages named
> -- "Ka0s_MultiMeters_<Event>" and never by reaching into another module's table
> -- (architecture-§4). Every name is declared here so the catalog in
> -- docs/ARCHITECTURE.md has one place to be checked against, and so a typo in a
> -- subscriber is a nil-index at load rather than a callback that silently never
> -- fires.
> --
> -- ONE SENDER EACH. The owner is named in the comment beside each constant; a
> -- second sender is a bug, not a convenience.
> Constants.MSG = {
> ```

**The sixth repo, which the finding counted as debt and which already conforms** —
`PanelMaster/modules/Registry.lua:17-21`:

> ```lua
> -- view must be rebuilt; `PanelChanged` means one panel's fields changed and only it needs
> -- repainting. Keeping them distinct is what lets a drag repaint one frame instead of all of them.
> local MSG_PANELS = "Ka0s_PanelMaster_PanelsChanged"
> local MSG_PANEL  = "Ka0s_PanelMaster_PanelChanged"
> R.MSG_PANELS, R.MSG_PANEL = MSG_PANELS, MSG_PANEL
> ```

**The real debt** — `KickCD/core/Database.lua:44`, a literal at the publisher:

> ```lua
>         NS:SendMessage("Ka0s_KickCD_PROFILE_CHANGED", { newProfileKey = key })
> ```

---

## C1-F07 — the casing of `<Event>`

`standards/standards/naming-cheatsheet.md:20` — the row, and the column that is empty where its neighbours
are not:

> | Bus messages | `Ka0s_<Addon>_<Event>` | `Ka0s_ExampleBar_RosterChanged` |

Compare the rows above it, which do state a convention: `| Addon folder | PascalCase | ExampleBar |`,
`| Lua files | PascalCase.lua | IconGrid.lua |`, `| Subfolders | lowercase | core/, modules/ … |`.

**Seven PascalCase, uniformly.** `AbsorbTracker/core/Bus.lua:89` (`REPAINT = "Ka0s_AbsorbTracker_RepaintRequested"`),
`AuraMaster/core/Bus.lua:34` (`CONTAINERS_CHANGED = "Ka0s_AuraMaster_ContainersChanged"`),
`ConsumableMaster/core/Bus.lua:80` (`PANEL_REFRESH = "Ka0s_ConsumableMaster_PanelRefresh"`),
`PartyFrameEnhanced/core/Bus.lua:136` (`LAYOUT = "Ka0s_PartyFrameEnhanced_LayoutChanged"`),
`BankLedger/core/Database.lua:106`, `LootHistory/core/Database.lua:292`, `PanelMaster/modules/Registry.lua:19`.

**Two SCREAMING_SNAKE, uniformly.** `KickCD/core/Database.lua:44`:

> ```lua
>         NS:SendMessage("Ka0s_KickCD_PROFILE_CHANGED", { newProfileKey = key })
> ```

`KickCD/core/State.lua:171`:

> ```lua
>         NS:SendMessage("Ka0s_KickCD_COMBAT_STATE", { inCombat = State.inCombat })
> ```

`MultiMeters/core/Constants.lua:542` (the proposal cited `:507`, which is the header prose):

> ```lua
>     CONFIG_CHANGED      = "Ka0s_MultiMeters_CONFIG_CHANGED",      -- { section, windowId }
> ```

Note what the two divergent repos are not the same about: MultiMeters holds a constant table whose
SCREAMING_SNAKE key matches a SCREAMING_SNAKE value, so its casing leaked from the constant into the wire
name; KickCD has **no** table at all and types the literal, so nothing leaked — it simply chose the casing
WoW's own event names use. And three of KickCD's five names are state nouns (`COMBAT_STATE`,
`SPELL_STATE`, `GRID_LAYOUT`), so "past participle" is a semantic rename there, not a case change.

---

## C1-F08 — the self-naming file header (with C9-F09)

**The convention, in the repos that keep it.** `ConsumableMaster/core/BagScanner.lua:1-3`:

> ```lua
> -- BagScanner.lua — Enumerate bag contents into { [itemID] = count }.
> --
> -- Retail API: C_Container.GetContainerNumSlots(bag) and
> ```

`MultiMeters/modules/Row_NameCell.lua:1-3`:

> ```lua
> -- modules/Row_NameCell.lua
> --
> -- The leading column's cell: the icon strip, the name string and the two
> ```

`AuraMaster/modules/Anchors.lua:1-3` — note the placement, **after** the bootstrap, which is the second
divergence C9-F09 raised and C1-F08 does not address:

> ```lua
> local _, NS = ...
>
> -- modules/Anchors.lua — where a container sits, and the handle a player drags it by.
> ```

**The repos that do not.** `PanelMaster/core/Util.lua:1-4` — namespace prologue and nothing else:

> ```lua
> local _, NS = ...
> NS.Util = NS.Util or {}
> local Util = NS.Util
> local C = NS.Constants
> ```

`LootHistory/modules/Collector.lua:1-3`:

> ```lua
> local _, NS = ...
> NS.Collector = NS.Collector or {}
> local Collector = NS.Collector
> ```

**Re-measured, because the proposal's framing was wrong.** Files with a header naming their own path, over
authored `.lua` outside `libs/` and `tests/`: ConsumableMaster 63/63, WhatGroup 18/18, MultiMeters 56/58,
KickCD 36/38, AuraMaster 41/47, PartyFrameEnhanced 33/38 — and PrettyChat 9/19, AbsorbTracker 13/28,
BankLedger 8/30, LootHistory 5/30, PanelMaster 1/28. Not "100% or 5%". In the low repos the headers sit
almost exclusively on the LibKa0s seam files (`EnvSetup`, `MediaSetup`, `LauncherSetup`, `OptionsSetup`),
where they arrived with the wiring template. Even the strongest repos leave the same scaffolded files bare —
`core/CoreSetup.lua`, `settings/Slash.lua`, `core/Constants.lua`, `core/Namespace.lua`, `core/State.lua` —
which is where the rule would have to be seeded if it lands.

---

## C3-F05 — retail raises on an unknown event name

Five repos met this and no two guard it the same way. All five versions are quoted; **BankLedger's is the
deepest**, and the reason is the sentence nobody else writes.

**BankLedger — DEEPEST.** `BankLedger/docs/midnight-quirks.md:53-59`:

> ## Modern retail raises on an unknown event name
>
> It does not ignore it. A bare registration loop therefore turns **one** retired event into a silently
> deaf addon: every registration after the throw goes unbound, with no visible error unless the player
> has script errors switched on. Registration is isolated per event
> (`Ledger:RegisterEventSafely`), rejected names are recorded in `Ledger.unavailableEvents`, and
> `/bl debug scan` reports them.

It is the only one with a complete mechanism rather than a mitigation.
`BankLedger/modules/Ledger.lua:846-852`:

> ```lua
> -- switched on. That is exactly how this addon shipped able to see `BANKFRAME_OPENED` and nothing
> -- else. Isolating each registration means a name this build lacks is recorded and skipped while
> -- every other event still binds.
> function L:RegisterEventSafely(addon, event, handler)
>   local ok = pcall(addon.RegisterEvent, addon, event, handler)
>   local list = ok and L.registeredEvents or L.unavailableEvents
>   list[#list + 1] = event
> ```

**MultiMeters — the complementary front gate, with its own reason for not relying on it alone.**
`MultiMeters/core/MultiMeters.lua:117-131`:

> ```lua
> --- Register `event` only if this client has heard of it.
> ---
> --- C_EventUtils.IsEventValid is the cheap ask; where even that is missing the
> --- registration is attempted under pcall, because the failure mode being avoided
> --- is a hard error at load on a client one patch behind, not a wrong answer.
> local function registerIfValid(target, event, handler)
>     local utils = _G.C_EventUtils
>     if utils and utils.IsEventValid then
>         if not utils.IsEventValid(event) then return false end
> ```

And the worked judgment call, `MultiMeters/docs/midnight-quirks.md:90-93`:

> `PLAYER_IS_GLIDING_CHANGED` is **probed** through `C_EventUtils.IsEventValid` rather than registered
> outright: it is the newest of the set and a client that has not got it raises on `RegisterEvent`.
> Losing that one edge is survivable where losing the block is not …

**ConsumableMaster — the instance fixed, no isolation kept.**
`ConsumableMaster/docs/midnight-quirks.md:112-114`:

> Blizzard removed `LEARNED_SPELL_IN_TAB` from retail; AceEvent throws `Attempt to register unknown event`
> when registering it. The addon uses its modern replacement `LEARNED_SPELL_IN_SKILL_LINE` …
>
> If a future patch removes another event the addon listens for, the failure mode is the same: AceEvent
> throws on registration. Replace with whatever modern event covers the same trigger.

**PanelMaster — the client behaviour asserted in a test.** `PanelMaster/tests/test_harness.lua:114-123`:

> ```lua
> test("Harness: NS.addon refuses an event the client does not know", function()
>   -- Retail raises on an unknown event name rather than ignoring it, and one retired name in a
>   -- RegisterEvent list takes the rest of the addon's events down with it. M.__badEvents is how a
>   -- case reproduces that; it is read at call time, so swapping the table is heard.
> ```

**LibKa0s — the kit already models the raise**, which is why this finding's better half is tooling.
`LibKa0s/testkit/mock_base.lua:713-727`:

> ```lua
> -- The events registry's onUsed is the client's frame:RegisterEvent: for an event in
> -- `M.__badEvents` it raises `Attempt to register unknown event "<NAME>"`, on the event's first
> -- registrant only, after the callback is stored -- because that is where and when the client
> -- raises. `M.__badEvents` is read at call time, so a test that swaps the table is heard.
> …
>     if type(bad) == "table" and bad[event] then
>       error("Attempt to register unknown event \"" .. event .. "\"", 4)
> ```

**AbsorbTracker is NOT a sixth guard — it records the opposite model**, and this is a defect to correct
during rollout rather than a variant. `AbsorbTracker/docs/midnight-quirks.md:118-120`:

> ## When an event you depend on gets removed in retail
>
> If Blizzard removes an event the addon listens for … the failure mode is that the registration succeeds
> but the event never fires.

**What the standard says.** `standards/standards/events-frames-taint.md:5-9` — §1 in full:

> - **MUST** use AceEvent-3.0 (`addon:RegisterEvent("X")`). **MUST NOT** create per-module frames just for
>   events …
> - **SHOULD** centralize CLEU dispatch on a single shared frame …
> - **MAY** use AceEvent's `:RegisterMessage`/`:SendMessage` for the closed message bus (architecture-§4).

Nothing about the raise, and nothing requiring a registration block to survive one bad name.

---

## C3-F07 — `Settings.OpenToCategory` and the collapsed sibling tree

Four repos wrote this up. All four are quoted; **ConsumableMaster's is the deepest** on the expand walk and
**WhatGroup's** carries the sharper failure modes.

**ConsumableMaster — DEEPEST on the walk.** `ConsumableMaster/docs/midnight-quirks.md:74-78`:

> ## `Settings.OpenToCategory` wants the numeric category ID, not a frame
>
> `Settings.RegisterCanvasLayoutCategory` (parent) and `Settings.RegisterCanvasLayoutSubcategory`
> (sub-pages) both return a category object whose `:GetID()` is the numeric ID
> `Settings.OpenToCategory` accepts. Passing the frame produces a range error. Capture the ID at
> registration time:

And the part the other three assert without justifying, `:85`:

> `SettingsCategoryMixin` does NOT expose a `SetExpanded` method — that lives on the visual list-entry
> element. To force the parent's sub-pages to render unfolded by default, reach into
> `SettingsPanel:GetCategoryList():GetCategoryEntry(category):SetExpanded(true)`. The whole walk is
> wrapped in `pcall` because every step … is private Blizzard API …

And the ordering constraint that makes the fix work at all, `:106`:

> Call it AFTER `Settings.OpenToCategory` so `SettingsPanel` is realized and the entry element exists.
> Re-running on every `KCM.Options.Open` means a manual mid-session collapse doesn't stick across the
> next `/cm config`.

**WhatGroup — the enumerated wrong forms, including the silent one.**
`WhatGroup/docs/midnight-quirks.md:39-46`:

> ```lua
> Settings.OpenToCategory(self._settingsCategory:GetID())  -- correct
> Settings.OpenToCategory("Ka0s WhatGroup > General")        -- WRONG (not a valid form)
> Settings.OpenToCategory(self._settingsCategory)            -- WRONG (object, not ID)
> ```
>
> `category:GetID()` returns the auto-assigned integer ID. **Do not overwrite `category.ID` with a
> string.** Doing so silently breaks the lookup and `OpenToCategory` becomes a no-op.

**WhatGroup's second element, which must NOT be promoted as new** — `WhatGroup/docs/midnight-quirks.md:29-31`:

> **Quirk: when a parent has subcategories, its own panel widgets are hidden.** … Make the parent a thin
> landing page (just a title + a hint pointing at the subcategory) and put every actual setting on a
> subcategory.

The standard already mandates that structure, at `standards/standards/options-ui.md:84`:

> Every Ka0s options panel **MUST** be a **parent canvas category = landing page** with one or more
> **canvas subcategories** for the actual settings (the first named "General").

…and at `:91` it mandates a parent **body** that every addon in fact renders (logo, tagline, a "Slash
Commands" heading, one Label per `COMMANDS` entry), which is the blanket form of WhatGroup's claim shown to
be false in the collection.

**AbsorbTracker — the same two facts, from the library's side.**
`AbsorbTracker/docs/midnight-quirks.md:77`:

> `libs/LibKa0s/Options.lua` captures `mainCategory:GetID()` at parent registration into `mainCategoryID`;
> `OpenOptionsPanel` calls `Settings.OpenToCategory(mainCategoryID)` … and then calls
> `expandMainCategory()` … `expandMainCategory` reaches into `SettingsPanel:GetCategoryList()` private
> API; the whole call is wrapped in `pcall` …

**KickCD — the AceConfig variant, plus the clearest statement of the collapsed-tree symptom.**
`KickCD/docs/midnight-quirks.md:127-128`:

> - **`AceConfigDialog:AddToBlizOptions`** returns `(frame, categoryID)` on modern clients.
>   `Settings.OpenToCategory` wants the **numeric ID**; passing the frame produces a range error.
> - **Blizzard's CategoryList only auto-expands the subcategory tree when a *child* is selected.**
>   Selecting a parent category in `Settings.OpenToCategory` leaves its subcategory tree collapsed in the
>   left nav, hiding the sibling tabs the user is trying to navigate to. … if any link in the chain goes
>   missing we silently fall through to "parent opened, tree collapsed" …

**The library already does all of it, once, for everyone.** `LibKa0s/LibKa0s/Options.lua:597-598`:

> ```lua
>   local mainCategory           -- Settings.RegisterCanvasLayoutCategory return
>   local mainCategoryID         -- numeric ID for OpenToCategory
> ```

`LibKa0s/LibKa0s/Options.lua:1386-1399`:

> ```lua
>   -- Expand the parent category in the Blizzard left tree so every sub-page is visible. Wrapped in
>   -- pcall: SettingsPanel internals are private API and could shift between patches.
>   local function expandMainCategory()
>     if not (mainCategory and SettingsPanel) then return end
>     pcall(function()
>       local list = SettingsPanel.GetCategoryList and SettingsPanel:GetCategoryList() or SettingsPanel.CategoryList
> ```

**What the standard legislates instead** — `standards/standards/options-ui.md:64-67` is four bullets on the
combat refusal, and nothing on either fact. `grep` over every section file for `GetID()`, `SetExpanded`,
`GetCategoryEntry` and `CategoryList` returns nothing.

---

## C4-F03 — nothing pins the automated-test record to the tree it describes

`standards/standards/automated-tests.md:179-183` — §4 in full on what a row carries:

> ### 4. `RESULTS.md` — the trend line (MUST)
>
> - **MUST** maintain **`docs/automated-tests/RESULTS.md`**: **one** file, **overwritten in place**,
>   never dated and never a directory, carrying one row per run across **all four** suites.

No commit SHA, no clean flag. A grep across every section file for `sha|dirty|clean tree|uncommitted`
returns nothing on point.

**The record going stale — measured.** `AbsorbTracker/docs/reviews/2026-09-07/01_FINDINGS.md:283`:

> ### `ABSORBTRACKER-R-06` — the automated-test record is two source-moving commits stale `[tests]`

…with the numbers at `:48`:

> | `docs/automated-tests/RESULTS.md` (newest row `20260825-103352`) | 508 tests, 7997 NLOC, 1126 funcs, max CCN 14 | 547 tests, 8903 NLOC, 1253 funcs, max CCN 15 | **stale** — see `ABSORBTRACKER-R-06` |

`MultiMeters/docs/audits/2026-09-08/02_DEVIATIONS.md:222`:

> ## MM-A-17 *(Info)* — The newest run bundle predates `master` by four commits

**The record becoming *unknowable*, which is the sharper half** —
`LibKa0s/docs/reviews/2026-09-07/01_FINDINGS.md:355`:

> ### F-012 — The v1.25.0 release bundle records a dirty tree, so it cannot be reproduced from its own SHA `[tests]`

**The cadence that makes staleness expected and unbounded** —
`KickCD/docs/reviews/2026-09-07/01_FINDINGS.md:82`:

> `docs/automated-tests/RESULTS.md` is regenerated at **release** (`/wow-addon:bump-version`), so being

…stale between releases is expected, and nothing anywhere says by how much.

---

## C5-F02 — packaging's ignore template versus its own strong form  *(OWNER CALL)*

**The template, unconditional** — `standards/standards/packaging.md:19-20`:

> ```yaml
>   - .claude          # dev-only: agent tooling; never loaded by the client
>   - .superpowers     # dev-only: agent tooling; never loaded by the client
> ```

**`tools` one bullet earlier, conditional, commented out, with its reason** — `packaging.md:23-27`:

> ```yaml
>   # - tools          # ONLY in a repo that HAS a tools/ (layout-§1: the home for a generator the
>   #                    repo authors and commits). Copied in when the folder appears, and left out
>   #                    until then — PanelMaster/.pkgmeta:10-15 records the collection's own call
>   #                    on this, that "a list padded with absent entries goes stale in the other
>   #                    direction". The audit check gates on `[ -d tools ]` for the same reason.
> ```

**The MUST, with `tools` conditioned and the two dot-directories not** — `packaging.md:33`:

> **MUST** ignore `docs/` …, `_dev/`, `tests/`, `tools/` **if the repo has one** (the home layout-§1 gives
> a generator the repo authors and commits — an addon with no generator has no such folder and owes no
> such line …), lockfiles, the root dev-only dotfiles … and the **agent-tooling directories** `.claude/`
> and `.superpowers/` in the package …

**The strong form, scoped to what is present** — `packaging.md:34`:

> **The list is the ignore rule's weak form; the check below is its strong one (MUST).** Every root dotfile
> and dot-directory **present in the repo** **MUST** either appear in `.pkgmeta`'s `ignore:` list or be
> justified in a comment beside it.

**The runner bakes the split in** — `WowAddonStandards/AUDIT.md:208-212`:

> ```sh
>      # (a) the named dev-only entries are ignored. `tools` is conditional: layout-§1 puts a
>      #     generator the repo authors there, so the ignore is owed only by a repo that HAS the folder.
>      entries=".luacheckrc .pkgmeta .gitignore .gitattributes .claude .superpowers docs tests _dev"
>      [ -d tools ] && entries="$entries tools"
> ```

**Seven repos each wrote their own paragraph, and they do not all reach the same answer.**
`PanelMaster/.pkgmeta:10-14`:

> ```yaml
>   # Those four are every root dot-entry this repo actually has, which is what
>   # packaging.md:28's strong form asks for. There is deliberately no .claude or
>   # .superpowers line: neither directory exists at this root, and the audit
>   # finding that named them was rejected this cycle for exactly that -- a sweep
>   # cannot have seen what is not there, and a list padded with absent entries
> ```

`BankLedger/.pkgmeta:14-22` — the opposite call on the other directory, argued just as carefully:

> ```yaml
>   # Agent tooling, and untracked — the directory holds one entry, sdd, and
>   # `git ls-files .superpowers` returns nothing — so no packager clone has ever
>   # carried it and this line changes no downloaded byte. It is listed because
>   # packaging.md:28 MUSTs every root dot-entry present in the repo be named or
>   # justified, tracked or not … There is deliberately no .claude line, because
>   # no such directory exists at this root, and naming one that does not is how
>   # the identical filing was rejected in two sibling repos this cycle.
>   - .superpowers   # untracked; listed under packaging.md:28
> ```

`WhatGroup/.pkgmeta:15-19` — the mirror image again:

> ```yaml
>   # Agent tooling, and untracked here — `git ls-files .claude` returns nothing,
>   # so no packager clone has ever carried it and this line changes no downloaded
>   # byte. It stays because packaging.md:28 MUSTs every root dot-entry present in
>   # the repo be named or justified, tracked or not.
>   - .claude     # untracked; listed under packaging.md:28
> ```

**Two audits filed it from opposite directions.** `LootHistory/docs/audits/2026-09-08/02_DEVIATIONS.md:57`,
graded **Info**:

> | **LH-61** *(new)* | `packaging` | **MUST** (weak form) / passes the strong form | Info | **`.pkgmeta`
> omits `.claude` from an ignore list that `packaging` names it in.** … §29 makes the **strong** form the
> real check … and that sweep prints **zero** unaccounted entries.

`MultiMeters/docs/audits/2026-09-07/02_DEVIATIONS.md:84`, graded **Medium** and in the other direction:

> ## MM-A-04 — `.pkgmeta` ships `.claude/` and `.superpowers/` to players

**And the upstream ask, in the audit's own words** —
`LootHistory/docs/audits/2026-09-08/04_TECHNICAL_DESIGN.md:164`:

> The tension is upstream. `packaging-§28` reads as a flat MUST list; `packaging-§29` scopes the real
> [check to entries present in the repo] … settle it in WowAddonStandards.

**One fact that tempers severity:** `git ls-files .claude` and `git ls-files .superpowers` return zero in all
eleven addons, so neither directory is tracked anywhere and no packager clone carries either today.

---

## C7-F02 — private event frames, and what obedience costs  *(OWNER CALL)*

**The rule** — `standards/standards/events-frames-taint.md:7`:

> - **MUST** use AceEvent-3.0 (`addon:RegisterEvent("X")`). **MUST NOT** create per-module frames just for
>   events (boss-mod-scale hand-rolling is overkill below 1000 events/min).

The parenthetical is what the MUST NOT was aimed at. What it catches is different.

**AbsorbTracker — a bare frame per unit, with a ratified row.**
`AbsorbTracker/core/AbsorbTracker.lua:150-156`:

> ```lua
>         frames = {}
>         for _, unit in ipairs(NS.Units.LIST) do
>             local f = CreateFrame("Frame")
>             f:SetScript("OnEvent", onEvent)
>             frames[unit] = f
>         end
>         self.__unitEventFrames = frames
> ```

`AbsorbTracker/docs/ARCHITECTURE.md:601`:

> | `events-frames-taint-§1` | `UNIT_ABSORB_AMOUNT_CHANGED` and `UNIT_MAXHEALTH` are registered on a
> private `CreateFrame` **per tracked unit** via `RegisterUnitEvent`, not through AceEvent-3.0 | Both
> events fire for every unit the client knows about; AceEvent shares one frame and structurally cannot
> `RegisterUnitEvent`, so it would pay a full C→Lua dispatch per unit only to discard all but ours. …

**KickCD — a general-purpose private-frame factory, NO register row.**
`KickCD/core/Util.lua:437-444`:

> ```lua
> function Util.RegisterUnitCastEvent(module, unit, eventName, handlerName)
>     local f = CreateFrame("Frame")
>     f:RegisterUnitEvent(eventName, unit)
>     f:SetScript("OnEvent", function(_, event, evUnit, ...)
> ```

Live, not dead code: called at `KickCD/modules/IconGrid.lua:821` and `KickCD/modules/Castbar.lua:1030`.

**LootHistory — a module-held frame, NO register row.**
`LootHistory/modules/Attribution.lua:363-369`:

> ```lua
>   -- HELD ON THE MODULE, not in a local: Attribution:Disable has to reach it to unregister, and a
>   -- frame only the closure knows about is a per-unit registration no stand-down can take out and no
>   -- suite can see. Re-used across a disable/enable cycle rather than rebuilt, so the cycle does not
>   -- leak one frame per turn of the switch.
>   local spellFrame = self.__spellFrame or CreateFrame("Frame")
>   self.__spellFrame = spellFrame
>   spellFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
> ```

**PartyFrameEnhanced is NOT a violator, and its own ratified row says so.**
`PartyFrameEnhanced/docs/ARCHITECTURE.md:332`:

> | `events-frames-taint-§1` | `UNIT_SPELLCAST_*`, `UNIT_TARGET` and the pet unit events are registered
> with `RegisterUnitEvent` on each element's own frame, not through AceEvent | … **The frames are the
> elements themselves, not frames made for events.** | 2026-09-15 | AceEvent or LibKa0s gains a
> unit-filtered registration |

**The addon that obeys, and the bill it wrote down.** `AuraMaster/modules/TimedSpells.lua:13-18`:

> ```lua
> -- HOW IT LISTENS. Through AceEvent on this file's own target, never a private frame
> -- (events-frames-taint-§1). The vendored AceEvent has no RegisterUnitEvent, so UNIT_AURA arrives for
> -- every unit, raid members and nameplates included, and the handler keeps only the player and pet.
> -- That cost is bounded by registering UNIT_AURA only while a scan could read anything: out of combat
> -- lockdown and while auras are not secret. …
> ```

**The standard has already legislated around the frames §1 forbids — twice.**
`standards/standards/slash-commands.md:186`:

> - **Every event, message and bucket registration the addon owns is actually UNREGISTERED.** Every
>   `RegisterEvent`, `RegisterUnitEvent`, `RegisterMessage`, `RegisterBucketEvent` and raw
>   `frame:RegisterEvent` the addon made, on every frame and every AceEvent target it owns, **including
>   the per-unit frames** — gone, not gated.

`standards/standards/testing.md:32`:

> **Mock fidelity (MUST).** … anything a test needs to **observe** is recorded rather than no-opped (a
> no-op `RegisterUnitEvent` lets a widened or dropped per-unit event filter pass the entire suite) …

A rule written to tear down the per-unit frames, and a mock-fidelity MUST written to catch a drifted
per-unit filter, both presuppose frames §1 says must not exist.

---

## C9-F01 — `docs/revendor/<date>/`, the fifth frozen store (with C1-F01)

**The standard's exhaustive list, which stops one directory short** —
`standards/standards/documentation.md:329-331`:

> Frozen and generated material is **out of scope** and **MUST NOT** be enumerated row by row:
> `docs/audits/`, `docs/reviews/`, `docs/automated-tests/<run>/`, `docs/perf-analysis/<run>/`,
> `docs/superpowers/` and `docs/investigations/` are named as directories, once each.

`grep -rn "docs/revendor" WowAddonStandards/standards/` → **nothing.**

**Ten repos amended that sentence by hand, and the amendments have diverged.**

`AbsorbTracker/docs/ARCHITECTURE.md:541` — the only copy still carrying `docs/investigations/`:

> Frozen and generated directories are named once each and never enumerated per run: `docs/audits/`,
> `docs/reviews/`, `docs/automated-tests/`, `docs/superpowers/`, `docs/perf-analysis/`,
> `docs/investigations/`, `docs/revendor/`.

`KickCD/docs/ARCHITECTURE.md:324` — the same sentence without it:

> generated directories are named once each and never enumerated per run: `docs/audits/`,
> `docs/reviews/`, `docs/automated-tests/`, `docs/superpowers/`, `docs/perf-analysis/`, `docs/revendor/`.

`AuraMaster/docs/ARCHITECTURE.md:769-771` — a further unrecognised store added to the same list:

> Every `.md` under `docs/` appears in exactly one table below (documentation-§3). Frozen and
> generated directories are named once and never enumerated: `docs/audits/`, `docs/reviews/`,
> `docs/automated-tests/<run>/`, `docs/perf-analysis/<run>/`, `docs/revendor/<date>/`,

`MultiMeters/docs/ARCHITECTURE.md:415` **and** `:477` — named in the scope sentence *and* given a table row,
which is the "exactly one table" MUST broken against its own amendment:

> `docs/revendor/` and `docs/superpowers/` are frozen through and through and get one row apiece.

> | `revendor/` | Frozen — one dated bundle per LibKa0s re-vendor: the payload delta and what was
> adopted, declined or filed from it |

`PartyFrameEnhanced/docs/ARCHITECTURE.md:282-284` — **no scope sentence at all**, and no store:

> ## Documentation map
>
> ### Required (documentation-§3, Tier 1)

**The store, measured.** 68 bundles across ten repos. The five-document shape appears in **40** of them; 19
lack `04_EXECUTION_PLAN.md` (nothing was adopted) and 9 carry only `01_DELTA.md` + `05_SUMMARY.md`. Folder
naming splits 40 `<date>-v<tag>` against 28 bare `<date>`. No repo has ever written a
`docs/revendor/README.md`, against six that ship `docs/perf-analysis/README.md`.

---

## C9-F02 — the convention lapsed everywhere at once

**Every store's newest bundle**, `ls -1 <repo>/docs/revendor/ | sort | tail -1`:

> AbsorbTracker → `2026-09-14`
> AuraMaster, BankLedger, ConsumableMaster, KickCD, LootHistory, MultiMeters, PanelMaster, PrettyChat,
> WhatGroup → `2026-09-13-v1.34.0`
> PartyFrameEnhanced → *(no store)*

**What those bundles cover.** `AbsorbTracker/docs/revendor/2026-09-14/05_SUMMARY.md:1`:

> `# 05 — Summary: LibKa0s v1.34.0 → v1.35.0`

`AuraMaster/docs/revendor/2026-09-13-v1.34.0/05_SUMMARY.md:1`:

> `# 05 — Summary: LibKa0s v1.33.0 → v1.34.0`

The library is at **v1.54.2**. Measured by re-vendor commits for tags past each repo's newest bundle, the
undocumented span runs from roughly 15 commits (AbsorbTracker) to 20 (BankLedger).

**The trigger the check would read is already mandated** —
`standards/standards/versioning-git.md:9`:

> … a lib change **MUST** produce a **re-vendor commit** in every consuming addon, and that commit
> **SHOULD** stand alone so the sync is legible in history.

**And the bundle itself is already mandated — in the tooling repo, not the standard** —
`wow-addon/commands/revendor-libka0s.md:307`:

> The bundle lives at `<Addon>/docs/revendor/<YYYY-MM-DD>/` and is **frozen**: a later run makes a new
> dated folder, and the difference between two folders is the record of what moved.
> `/wow-addon:harvest-standards` reads these as evidence …

That is why the convention lapsed without anything going red: it is enforced by a command that twenty
library releases' worth of bulk sweeps never invoked, and by nothing upstream at all.

---

## C10-F01 — the 1500-line cap gate, five hand-written copies

**The rule, and the three terminal states the gate would assert.**
`standards/standards/layout.md:57`:

> - **MUST** cap any single `.lua` file at 1500 LOC. Files in the 1000–1500 band are on notice; a >1500
>   file is a bug — peel it.

`standards/standards/layout.md:67`:

> **A file over the cap has three terminal states, not one.** Peeled (the **MAY** above); or an open issue
> in the addon's issue store (audit-review-history) naming the seam a peel would follow; or a ratified
> deviation row under `## Documented deviations` (documentation-§3) carrying a re-check trigger. … What is
> **not** a terminal state is a file over the cap that nothing anywhere remarks on …

**Five copies, none byte-identical, and they already disagree about what they read.**

`ConsumableMaster/tests/test_layout_cap.lua:34-36` (232 lines):

> ```lua
> local CAP = 1500
> local ARCHITECTURE = "/docs/ARCHITECTURE.md"
> local CENSUS_HEADING = "### Files over the 1500-line cap"
> ```

`LibKa0s/tests/test_layout_cap.lua:39-41` (206 lines) — a different hub and a different heading level:

> ```lua
> local CAP = 1500
> local REGISTER = "CLAUDE.md"
> local CENSUS_HEADING = "## Files over the 1500-line cap"
> ```

`PanelMaster/tests/test_layout_cap.lua:41-45` (209 lines) — a different heading **name**, because it is the
copy that also polices the band:

> ```lua
> local CAP  = 1500   -- `layout-§1`: over this is a bug, and needs one of the three terminal states
> local BAND = 1000   -- `layout-§1`: at or above this a file is "on notice", and needs a row
>
> local ARCHITECTURE    = "docs/ARCHITECTURE.md"
> local CENSUS_HEADING  = "### Files by the `layout-§1` band"
> ```

MultiMeters (221 lines) and PrettyChat (380 lines, carrying a per-path carve-out) are the other two. Seven
addons — AbsorbTracker, AuraMaster, BankLedger, KickCD, LootHistory, PartyFrameEnhanced, WhatGroup — have no
gate at all.

**The precedent the extraction follows** — `LibKa0s/testkit/test_prose.lua:8-15`:

> IT SHIPS IN THE KIT, so a consumer inherits it instead of writing its own … A rule enforced by eleven
> hand-written copies is eleven chances to carry a subset.

---

## C10-F02 — the documentation-shape gate, five names and five coverage sets (with C9-F07)

**The census, measured** (`ls <repo>/tests | grep -E 'test_(docs|docmap|doc_structure|register|deviation_register)'`):

> AbsorbTracker `test_docs.lua` · AuraMaster `test_docs.lua` · BankLedger `test_docs.lua` `test_register.lua`
> ConsumableMaster `test_docmap.lua` `test_register.lua` · KickCD `test_doc_structure.lua`
> LootHistory `test_doc_structure.lua` · MultiMeters `test_deviation_register.lua` `test_doc_structure.lua` `test_docmap.lua`
> PanelMaster `test_docs.lua` `test_register.lua` · **PartyFrameEnhanced — none**
> PrettyChat `test_doc_structure.lua` `test_register.lua` · WhatGroup `test_doc_structure.lua` `test_docmap.lua` `test_register.lua`

**The six checks already exist as prose** — `WowAddonStandards/AUDIT.md:106-116`:

> listing, so measure it rather than reading prose.** Six checks, and all six are mechanical:
> (a) **Tier 1 present**, under exactly those names — `scope.md`, `module-map.md`, `schema.md`,
> `settings-panel.md`, `data-flow.md`, `common-tasks.md`; a missing one is a MUST failure.
> (b) **Tier 2 accounted for** … evaluate the trigger **against the code** (count `NS.COMMANDS`, count
> distinct messages, count the shims `core/Compat.lua` publishes with documentation-§3's own grep — it is
> a count now, not a judgment) …

**What measuring once a cycle costs, in the collection's own words** —
`PrettyChat/docs/audits/2026-09-08/02_DEVIATIONS.md:55` (`PC-74`):

> `docs/ARCHITECTURE.md:341` carries a second, unmandated doc inventory … Two inventories of one doc set is
> one more place to go stale, and it already has … **Nothing gates it, because the gate
> `tests/test_doc_structure.lua` checks the map.**

---

## C10-F03 — a consumer suite silently shadows the kit suite of the same name

**The mechanism, in three lines of the kit.**
`LibKa0s/testkit/framework.lua:649-660` — `declared` is keyed by **bare name**, and `dirs` is kept separately:

> ```lua
> local function suiteDeclarations(suites)
>   local declared, order, pending, dirs = {}, {}, {}, {}
>   for i, entry in ipairs(suites or {}) do
>     local name, why, entryDir = suiteEntry(entry)
>     name = tostring(name)
>     declared[name] = i
> …
>     if entryDir then dirs[name] = entryDir end
> ```

`LibKa0s/testkit/framework.lua:740-745` — and the kit-directory pass is handed that same name-keyed set:

> ```lua
>   collectUndeclared(problems, dir, onDisk, declared, undeclaredHere)
>
>   local kitDir = dir .. "_kit/"
>   if fileExists(kitDir .. "framework.lua") then
>     collectUndeclared(problems, kitDir, suiteNamesOrFail(kitDir), declared, undeclaredInKit)
>   end
> ```

So a bare `"test_prose"` declared from `tests/` satisfies `tests/_kit/test_prose.lua`, and the kit copy is
never loaded.

**The rule the gate cannot enforce** — `LibKa0s/testkit/README.md:145-146`:

> **A repo that already has its own copy wires one or the other, never both.** Two gates over one
> rule is two lists to keep whole, which is the divergence this file exists to end.

**And the claim the hole falsifies** — `LibKa0s/testkit/README.md:109-111`:

> `Kit.assertSuiteInventory` scans `tests/_kit/` for suites as well as `tests/`, so a re-vendor that
> lands this file in a repo that has not declared it goes **red** naming the entry to add. That is
> deliberate: a gate that arrives silently and runs nothing is the failure this kit already refuses

**Six repos are in that state.** `BankLedger/tests/run.lua:24-26` — a bare name, so the local 262-line copy runs:

> ```lua
>   "test_marks", "test_libka0s", "test_vendor_sync", "test_poolsetup", "test_itemsetup",
>   "test_lifecycle", "test_disabled", "test_surface_parity", "test_register", "test_docs",
>   "test_lintconfig", "test_prose",
> ```

**Six are wired correctly.** `AbsorbTracker/tests/run.lua:103`:

> ```lua
>     { name = "test_prose", dir = "tests/_kit/" },
> ```

Measured across the twelve: BankLedger, ConsumableMaster, LootHistory, PrettyChat, WhatGroup and LibKa0s
ship a local `tests/test_prose.lua` and declare it bare; AbsorbTracker, AuraMaster, KickCD, MultiMeters,
PanelMaster and PartyFrameEnhanced declare the kit path and ship no local copy.

---

## C10-F04 — the `.gitattributes` body, unchecked and drifted  *(OWNER CALL on the §7 reversal)*

**The canonical bodies, and the two lines at issue.**
`standards/standards/line-endings.md:147` heads the section:

> ### 5. The canonical file bodies (MUST)

`line-endings.md:196-199` (the CRLF body) and `:287-290` (the LF body) carry the identical carve-out block:

> ```
> # under tools/ (layout-§1). Without these carve-outs each is broken on every
> # checkout rather than in one contributor's working tree.
> *.sh text eol=lf
> *.py text eol=lf
> ```

**The census.** `grep -c '\*\.py text eol=lf' <repo>/.gitattributes` across all fourteen:

> AuraMaster **1** · LibKa0s **1**
> AbsorbTracker 0 · BankLedger 0 · ConsumableMaster 0 · KickCD 0 · LootHistory 0 · MultiMeters 0 ·
> PanelMaster 0 · PartyFrameEnhanced 0 · PrettyChat 0 · WhatGroup 0 · WowAddonStandards 0 · wow-addon 0

`*.sh text eol=lf` is present in all fourteen. File lengths: 81 lines in nine addons, 82 in LibKa0s and both
tooling repos, 84 in AuraMaster, 87 in PanelMaster (a legitimate §5 appendix — the realesrgan binary mark).

**It is body drift, not twelve independent omissions.** `AuraMaster/.gitattributes:35-37`:

> ```
> # checkout rather than in one contributor's working tree.
> *.sh text eol=lf
> *.py text eol=lf
> ```

`AbsorbTracker/.gitattributes:4-8` — the superseded shell-only block, and the invariant the file asserts
about itself while failing it:

> ```
> # Every repo in the Ka0s collection carries an explicit .gitattributes. There
> # are exactly two variants of this file and they differ in one decision only:
> # the pin below. Everything after it is byte-identical across the collection,
> # so diffing a client-bound repo against a non-client one shows one decision,
> # not two documents.
> ```

**Why nothing reports it** — `line-endings.md:466-468`:

> - A green suite **MUST NOT** be read as covering (a) through (d). The gate compares bytes against
>   declared attributes; it cannot tell you the `.gitattributes` body is byte-for-byte one of the two
>   canonical ones (§5) … Those stay the [audit's work, every cycle.]

**Why the narrowing reading fails.** Five repos track Python — AuraMaster (`tools/spell-research/research.py`),
LibKa0s (two under `tools/artwork/`), PanelMaster (four under `tools/`), PrettyChat
(`GlobalStrings/split_globalstrings.py`), wow-addon (two under `scripts/`) — and **three of those five lack
the line** while shipping `#!/usr/bin/env python3` scripts. The correlation the second reading rests on does
not hold, and the kernel-level breakage §5 describes is live in three repos.

---

## Standing argument for the tooling proposals — corrected

The tooling proposals (C10-F01, C10-F02, C10-F03, C10-F04, and C4-F04's surviving half) were argued from a
claim that three collection-wide deviation classes each stopped recurring the moment a vendored gate took
ownership. **That claim is half false, and the corrected version is the one to use**, because it names the
condition under which a gate works.

Line endings did close: ten repos had strays in their 2026-09-07 bundles and the 2026-09-08 bundles return
zero, with three repos naming the owner verbatim — `ConsumableMaster/docs/audits/2026-09-08/02_DEVIATIONS.md:69`,
`KickCD/…:32`, `MultiMeters/…:247`:

> … and `tests/_kit/test_eol.lua` (kit revision 15) now owns the check.

The British-spelling class did **not**, on the same date, with the same kind of gate:

> `PrettyChat/docs/audits/2026-09-08/02_DEVIATIONS.md:56` — `PC-75`: "49 British spellings across 19
> authored files"
> `AbsorbTracker/docs/audits/2026-09-08/02_DEVIATIONS.md:48` — `AT-66`: the repo's gate "carries a private
> list where v2.39.0 publishes a canonical one"
> `LibKa0s/docs/audits/2026-09-08/02_DEVIATIONS.md:48` — `LK-28d`: `tests/test_prose.lua:19` sets
> `SHIPPED = { "LibKa0s", "testkit" }` and does not recurse, so "216 live hits are invisible to a green suite"

The difference between the two is not gate-versus-prose. **A gate closes a class when it reads the whole
tracked set, and leaves the class open when its scope is narrower than the rule's.** That is the qualifier
every proposal in this bundle's tooling group has to satisfy, and it is why C10-F01's and C10-F02's scope
parameters are the part of those proposals worth arguing about.
