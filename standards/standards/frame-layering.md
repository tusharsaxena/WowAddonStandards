> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Frame layering: strata and frame level

Every frame an addon draws sits somewhere in the client's draw order: strata first (`BACKGROUND`, `LOW`, `MEDIUM`, `HIGH`, `DIALOG`, `FULLSCREEN`, `FULLSCREEN_DIALOG`, `TOOLTIP`), then frame level within the strata, then draw layer and sublevel for regions within one level. This section says where each kind of element goes, so that "what strata?" is a lookup rather than a choice, and so that every visual element of one addon layers by one rule.

Two client facts drive most of it. **A child frame draws over every region of its parent**, whatever the region's draw layer, so an `OVERLAY` texture on a button sits under the button's cooldown or border child. **A child with no explicit level is at parent + 1**, so siblings tie, and a tie between overlapping frames that both draw is broken by creation order, which pooling and lazy builds scramble. The 2026-10-24 collection review found both in more than half the addons.

### 1. Strata separates roles; level orders within a role (MUST)

Elements of different roles are separated by **strata**. Elements within one role are ordered by **named level bands** (§3). An addon **MUST NOT** rely on a frame-level race to keep its window above another addon's or Blizzard's frame in the same strata.

| tier | element class | strata | layers-table key |
|---|---|---|---|
| T0 | non-visual frames: event frames, binding click targets, ESC proxies, measurers, hidden parents | none (exempt) | — |
| T1 | HUD display: a world-anchored, persistent display (bar, icon grid, cast bar, meter, pad) | `MEDIUM`, set on the display root | `HUD` |
| T2 | edit-mode chrome: drag handles, unlock outlines, overlaying test and sim markers, unlock-only grips | the display's strata (§2) | `CHROME` |
| T3 | HUD popup: a transient surface opened from a HUD element | one strata above the HUD root, or its Blizzard equivalent's | `HUD_POPUP` |
| T4 | window: persistent (kept up while playing) / on demand (opened to read) | `MEDIUM` / `HIGH` | `WINDOW` |
| T5 | alert: interactive toast / non-interactive screen alert | `HIGH` / `FULLSCREEN`, mouse disabled | `ALERT` / `SCREEN_ALERT` |
| T6 | modal and tool window: dialogs the player answers, the debug console, perf and sim panels; Blizzard StaticPopups live here | `DIALOG` | `MODAL` |
| T7 | detached child window opened from a T6 window | `FULLSCREEN` | `CHILD` |
| T8 | transient popup: menu, autocomplete, suggestion list, context menu, pullout, color picker, a borrowed confirmation lifted while shown, a drag-time full-screen highlight | `FULLSCREEN_DIALOG` | `POPUP` |
| T9 | cursor: tooltips, drag ghosts, an overlay that labels the frame under the cursor | `TOOLTIP` | `CURSOR` |

What the ladder guarantees, and why each line is where it is:

- A HUD never covers the addon's own dialogs, popups or tooltips, and never covers the Blizzard Settings panel (`HIGH`) by default.
- **Dropdowns, menus and tooltips are never covered.** Nothing an addon draws sits at `FULLSCREEN_DIALOG` or above except T8 and T9 surfaces, so AceGUI pullouts, the `LibKa0s-Widgets-1.0` menu and Blizzard's `Menu` open over every window. A window that wants a pullout to open over it **MUST** stay at or below `FULLSCREEN`.
- A frame opened from another frame sits **at least one strata above its opener** (T4 < T6 < T7 < T8). The library's copy window, `FULLSCREEN` over the `DIALOG` console that opens it, is the reference.
- A non-interactive alert is not in the popup strata, so a menu opened while it shows draws over it.

**Variants of T1.**
- **Player-chosen strata.** A display whose strata is a setting **MUST** offer `BACKGROUND`, `LOW`, `MEDIUM` and `HIGH` only. A knob that shipped before v2.88.0 with `DIALOG` or higher keeps its stored values (a value-set change needs a migration and an owner decision), and its tooltip **MUST** say what those values cover: the addon's own popups and debug console, and the Settings window.
- **Host-matched surfaces.** A surface grafted onto another addon's or Blizzard's frame **MUST** take the host's strata by reading it (`host:GetFrameStrata()`) or by inheriting it, never by restating it as a literal, and raises its level by a named offset over the host. Elements that decorate a host's frames copy its strata and stack one level over its highest readable descendant, the read guarded against secret values and forbidden frames.
- **Player-layered backdrops.** An addon whose purpose is letting the player compose strata and level (a backdrop panel addon) **MAY** offer every strata, as a row in its `## Documented deviations`; it **MUST** keep its own confirmations answerable while its frames are unlocked (§4).

**Documented exceptions** (each **MUST** carry a reasoned comment at the call site and a `## Documented deviations` row):
- **The secure fixed point.** A secure frame that shows in combat cannot change strata in combat, so its strata is chosen first and every insecure frame that must sit over it moves up a tier. A window that shares a strata with the addon's own modal band **MUST NOT** be toplevel or `Raise()`d, because a raise lifts it over the modal's catcher.
- **The event-raised notice previewed from Settings.** A popup raised by a game event that the player sizes or places from the Settings panel **MAY** sit at `DIALOG`, not toplevel, `Raise()`d on an explicit show out of combat, provided every true dialog at `DIALOG` is toplevel.

### 2. Edit-mode chrome (MUST)

Chrome lives in the display's strata at the **top of the display's band** (§3), above every content level of every display of the same addon that can overlap it.

- Where the display's strata can be below `MEDIUM` (a player choice, a host it follows), mouse-enabled chrome **MUST** be floored at `max(display, MEDIUM)`; mouse-off chrome **MAY** float at `max(display, HIGH)`. A child given its own strata **MUST** be `SetFixedFrameStrata(true)` and re-lifted after every `SetFrameStrata` on its parent, which otherwise takes it back. A lift is never below the parent.
- A drag affordance (handle, close mark, grip) **SHOULD NOT** inherit the display's content alpha: `SetIgnoreParentAlpha(true)`, or `LibKa0s-Widgets-1.0` `DragHandle`'s `ignoreParentAlpha` (DragHandle minor 5, `LibKa0s v1.77.0`; its `level` spec field sets the handle's offset over its parent before the help and close marks are built, and `handle:ApplyLevel()` re-applies it after the host re-levels the parent, so a host never re-levels the handle by hand). An affordance that fades to invisible while still clickable is anti-pattern #101.
- A drag **backplate** (a holder the display is dragged by) sits at the display root's level, under every element, and the elements over it pass the mouse through or forward their drag.
- Order within chrome: outline < overlaying marker < handle and its marks. A marker and a handle that never show together **MAY** share or invert a slot only when the exclusion is enforced in code.
- A test or sim strip that **displaces** content (pushes it down by its height) stays at the content's chrome level; one that **covers** content is raised above the content band.

### 3. Level bands (MUST)

**Every level is relative**: `base:GetFrameLevel() + LAYERS.LEVEL.<NAME>`. An addon **MUST NOT** call `SetFrameLevel` with an absolute number, and **MUST NOT** set a level relative to a sibling. A player-chosen level is a base, not an exception; a measured level (the library's combat cover, computed over the deepest descendant and capped at 10000) is relative by construction. A level read under a restricted anchor goes through a secret-safe guard (events-frames-taint-§8).

**Inside one display element** (a bar, an icon, a button, a row) the order is normative:

| rung | reference offset from the element root | holds |
|---|---|---|
| root | +0 (regions) | background, icon texture, a fill drawn on the root |
| `FILL` | +1 | progress: the StatusBar fill, the cooldown swipe (given an explicit level, never the implicit default), a spark riding the fill |
| `BORDER` | +2 | borders: backdrop edges, icon borders, dispel edges. A border is a frame **above** the fill, or the fill is inset by the full border width |
| `EFFECT` | +3 | glow hosts. `LibKa0s-Glow-1.0`'s `Start` **MUST** be passed an explicit small `frameLevel`, so LibCustomGlow's default +8 does not leap over the overlay |
| `OVERLAY` | +4 | one **mouse-off overlay child frame** holding text, marks and padlocks (sublevel 0) and state veils, washes and highlights (higher sublevels) |

The order is a **MUST**; the offsets are a **SHOULD**, and an addon-specific class (an indicator, a spark, a dispel edge) slots between rungs under its own name as long as the order holds. **A region never has to draw over a child frame of its own frame**: anything that marks or overlays a child frame lives on the overlay frame. An overlay frame laid over a clickable or secure button **MUST** be `EnableMouse(false)`.

**Inside one HUD display** (root level `L`): backplate `L`; content `L+1` to `L+19`, with per-class sub-bands where sibling classes overlap; label `L+20`; outline `L+30`; overlaying marker `L+40`; handle `L+50`. **Inside one window** (base `W`): chrome `W+1` (title or drag bar, header controls, tab strip, body, displacing strips); content `W+2` to `W+8`; the library grip `W+10`; popovers over the window's own content `W+30` and up, **in the window's strata**. A popover over its own window is a level problem, never a reason to jump strata.

- **Siblings.** Two overlapping siblings that both draw **MUST** have explicit, distinct levels. A sibling that draws nothing and takes no mouse, or siblings kept apart by documented geometry, need no band.
- **Re-assert what moves.** An explicit level **MUST** be set again after every `SetParent` (which re-derives it) and by the code that re-levels its base, never only in a memoized restyle. Set a frame's level before its children are built where possible. Art deliberately sunk to its parent's level is re-sunk by any code that re-levels the parent.
- **Peers stack whole.** Several frames of one kind that can overlap (bars, windows, panels) **MUST** have a defined order: toplevel or an explicit `Raise()` on interaction, or a deterministic per-instance base with a stride at least the element's band height. Where the player sets equal levels, interleaving **MAY** stay if the setting's tooltip says so.
- **Library bands are part of the map.** The library's grip (+10), reorder drop line (+20) and reorder box (−1) are named in the addon's table comment, and a window's content stays at or below +8. A degraded fallback reproduces the library's offsets.

### 4. Windows, modals and popups (MUST)

- **Windows are toplevel.** A movable window **MUST** call `SetToplevel(true)`, so a click raises it among its strata peers (the Settings panel included, for a `HIGH` window). A window whose own frame takes no mouse adds `Raise()` on drag start. The two §1 exceptions apply.
- **Modals and tool windows** sit at `DIALOG`, toplevel, clamped. A destructive confirmation is never buried by a window the same addon showed after it: a toplevel tool window re-raises a shown StaticPopup when it shows (the library's debug console, perf panel and sim panel do, from `LibKa0s v1.77.0`: toplevel, and on show each re-raises any shown `StaticPopup1`...`StaticPopup4`).
- **Transient popups** sit at `FULLSCREEN_DIALOG`, **MUST** be clamped as their opener is, **MUST** close on every path their opener closes (its `OnHide`, the disable ladder, Escape), and **MUST** be dismissed by a `GLOBAL_MOUSE_DOWN` listener that ignores presses inside the popup. A full-screen click catcher behind a transient popup is forbidden: it swallows the click that dismisses, which is why the library retired its own (Widgets minor 5). A modal's dimming scrim that closes with its modal is not a catcher. The library's IdList suggestion list closes when combat starts over its page, from `LibKa0s v1.77.0`.
- **A HUD popup** sits one strata above its HUD root, set **once at construction** (never per refresh, never by a runtime strata switch), clamped like its root, and where Blizzard ships an equivalent (an action-button flyout), at that equivalent's strata.
- **Never switch strata to fix an order.** Set a level. The exceptions are a strata the player chose, and a borrowed **shared** Blizzard frame (a StaticPopup) lifted while it is shown and put back, on hide, to the strata recorded on show, never to a hard-coded value.
- **Nothing invisible stays mouse-live.** A frame soft-hidden at alpha 0 because it parents a secure child **MUST** be made mouse-dead; a secure child that cannot be (its `EnableMouse` is refused in combat) is disarmed at `PLAYER_REGEN_DISABLED`, or the residual is a `## Documented deviations` row.
- **Combat.** Strata, level and toplevel writes on a protected frame, or on a frame secure elements are anchored to, go through the addon's secure queue (events-frames-taint-§2).

### 5. One layers table per addon (MUST)

An addon that sets any strata or level **MUST** declare them once, in `core/Constants.lua`:

    NS.Constants.LAYERS = {
      STRATA = { HUD = "MEDIUM", MODAL = "DIALOG", ... },   -- §1's keys
      LEVEL  = { FILL = 1, BORDER = 2, EFFECT = 3, OVERLAY = 4, HANDLE = 50, ... },
    }

Its header comment states the addon's whole stack once, the library- and Blizzard-owned tiers it relies on included (debug console `DIALOG`, copy window `FULLSCREEN`, menus `FULLSCREEN_DIALOG`, grip +10). Every `SetFrameStrata` and `SetFrameLevel` in the addon reads it, so `grep -rn 'SetFrameStrata("' core modules settings` returns nothing and every `SetFrameLevel` argument names a `LAYERS.LEVEL` member. An addon with a single explicit strata call **MAY** use one named local constant carrying the same comment. `docs/ARCHITECTURE.md` points at the table in one line rather than copying it, because a copied tier table goes stale the first time a library choice changes.

**A frameless addon owns no strata.** An addon whose only surfaces are the Settings canvas, library windows and Blizzard or Ace3 popups **MUST NOT** call `SetFrameStrata`, `SetFrameLevel`, `SetToplevel` or `Raise` itself, and **SHOULD** pin that with a static test.

**No library tier table (recorded rejection, v2.88.0).** The tier keys are published here, not as a `LibKa0s` constant: a library table carries no behavior (the values are the client's strings); every addon needs its own table for its level bands anyway; and a library minor would re-tier every addon's frames at once, where a value every Ka0s window shares is a standard change first. Re-check if two addons' tables diverge on a tier §1 fixes.

### 6. Library-owned tiers (reference)

What a Ka0s addon inherits, so its own tiers are placed around known neighbors. Changing a library row is a standard change first.

| frame | strata | level | toplevel / clamped |
|---|---|---|---|
| `LibKa0s-DebugLog-1.0` console, `LibKa0s-Perf-1.0` panel, `LibKa0s-Sim-1.0` step panel | `DIALOG` | inherited | toplevel (from `LibKa0s v1.77.0`; not toplevel before) / clamped |
| `LibKa0s-Widgets-1.0` `CopyWindow` | `FULLSCREEN` | inherited | not toplevel / clamped |
| `LibKa0s-Widgets-1.0` dropdown menu, autocomplete; `LibKa0s-Options-1.0` IdList suggestions | `FULLSCREEN_DIALOG` | inherited | clamped (menu and autocomplete from `LibKa0s v1.77.0`) |
| `LibKa0s-Widgets-1.0` reorder ghost | `TOOLTIP` | — | — |
| `LibKa0s-Core-1.0` resize grip | inherited | +10 | — |
| `LibKa0s-Options-1.0` combat cover | inherited | `max(panel + 100, deepest + 1)`, capped 10000 | — |
| Blizzard Settings panel | `HIGH` | Blizzard | toplevel |
| Blizzard StaticPopups | `DIALOG` | Blizzard | toplevel |
| AceGUI pullouts and color picker | `FULLSCREEN_DIALOG` | AceGUI | clamped |
| AceGUI-3.0-SharedMediaWidgets pullouts; AceConfigDialog confirmation | `TOOLTIP` (the latter at level 100) | — | — |
| LibDBIcon minimap button | `MEDIUM`, fixed | 8, fixed | — |

Third-party rows are documented, not fought: an addon **MUST NOT** re-strata a third-party or shared Blizzard frame except by the lift-and-restore of §4.

### 7. Commencement

Each addon's next release after v2.88.0. Library rows marked *from `LibKa0s v1.77.0`* bind from the addon's first re-vendor of that tag; before it a tool window that is not toplevel or a menu that is not clamped is the library's finding, not the addon's. A player strata knob shipped before v2.88.0 keeps its stored values (§1). A defect is filed against the subsection it breaks; the anti-patterns are #99 to #105; the audit step is AUDIT.md's layering check.
