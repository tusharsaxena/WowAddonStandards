> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Launcher — the minimap button and the broker plugin

Every Ka0s addon **MUST** ship a **launcher**: a minimap button, and the same addon shown in a broker display (Titan Panel, ElvUI's data texts, Bazooka). This is the entry point for the player who does not remember a slash verb, and it is the surface on which the collection is most visibly one collection — eleven buttons around one minimap, each wearing its own logo, each answering a click the same way.

**It is ONE object, registered twice — not two features.** The addon creates a single **LibDataBroker-1.1** object and hands that object to **LibDBIcon-1.0**; LibDBIcon draws the minimap button from it, and any broker display that is installed draws its own row from the very same object. One `OnClick`, one icon, one label, one identity. An addon that builds a minimap button with its own click handler and a broker object with a second one has written the same feature twice and will drift on the next behavior change — that is **anti-pattern #81**.

### 1. One object, registered twice

- **MUST** create exactly **one** LibDataBroker-1.1 object, of `type = "launcher"`, and **MUST** register it with **LibDBIcon-1.0**. `"launcher"` is the reason rather than a label: a broker display reads `type` to decide what to draw, and `"data source"` promises a `text` value that updates, which this object does not have — it exists to be clicked. A display handed the wrong type draws an empty value cell beside the icon forever. Both libraries are vendored under `libs/` like every other (library-stack-§1/§3).
- **MUST** use the **same name** for both registrations, and that name is the addon's **folder name** (`BankLedger`, `PartyFrameEnhanced`). This is **not cosmetic**: LibDBIcon keys the button's **saved position** by that name, so renaming it — or spelling it differently on the two registrations — drops the position the player dragged the button to and puts the button back at the library's default angle, while a broker display labels the plugin with the other spelling. The folder name is chosen because it is the one name the addon cannot change without changing what the client loads.
- The object's `OnClick` is the **only** click implementation in the addon. Both surfaces dispatch into it, so **launcher-§2 is satisfied on the minimap and in a broker display by construction** rather than by two implementations agreeing.
- The object's `icon` is the addon's own logo, the same file the TOC's `## IconTexture` names (launcher-§4).
- **MUST NOT** register the broker object conditionally, and there is deliberately **no setting** that enables or disables it. A broker display shows what it chooses to show, and it already offers the player a per-plugin toggle of its own; an addon that hides itself from a display is solving the display's problem in the wrong place, in a second settings row the player has to find first. The **minimap button** has a visibility row (launcher-§3); the **broker object** has none.
- **MAY** supply an `OnTooltipShow`. Its contents are the addon's own and nothing here binds them.

### 2. Click behavior

**Left-click follows a three-rung rule, first match wins.** The rungs are ordered by what the player most likely wants when they click the addon's own button, and the ordering is what makes the answer predictable across eleven addons without eleven decisions:

- **(a) The addon has a PRIMARY WINDOW** → left-click **toggles that window**. A data browser, a ledger, a meter window, a group popup — the thing the addon exists to show (standalone-windows).
- **(b) Else the addon has a PREVIEW SWITCH** → left-click **toggles it**: the **test mode** where the addon has one, or **lock / unlock** where unlocking *is* the addon's preview (the options-ui-§15 exemption, preview-mode). The switch is the addon's existing one — the launcher drives the same state the *Test mode* or *Lock frame* checkbox drives, through the same seam, and never holds a copy of it.
- **(c) Else** → left-click **opens the settings panel**.

**Right-click ALWAYS opens the settings panel**, on every addon, whatever rung its left-click sits on. The settings panel is therefore never more than one click away, which is what lets rungs (a) and (b) spend the left button on something better.

- The rung is a property of the addon, not a preference: there is **no setting** that reassigns either button.
- **Which rung each rostered addon sits on is recorded in `ADDONS.md`**, one column on the roster, so an audit reads it rather than re-deriving it from the addon's shape and guessing. A new addon picks its rung by the rule above and adds the column value with its roster row.
- An addon on rung (a) or (b) whose left-click opens the settings panel has not chosen a different design — it has skipped the rule, since the panel is already on the right button. That, and a right-click doing anything else, is **anti-pattern #81**.

### 3. Visibility — one row, and it is LibDBIcon's own table

The minimap button's visibility is a **Master controls** row (options-ui-§15), and its stored shape is **LibDBIcon's own `minimap` table** — the `hide` boolean LibDBIcon owns and writes when the player uses its own menu — **never** a second key alongside it.

- **MUST** store at `minimap.hide` in the addon's **global** store and hand that same table to LibDBIcon's `:Register(name, ldbObject, db.global.minimap)`. A parallel `minimap.show` or `showMinimapIcon` is a second copy of one state that has to be kept in step with a table a library also writes, and the day they disagree the button and the checkbox disagree (**anti-pattern #81**).
- **The scope is GLOBAL, and that is the decision rather than an accident of where the other rows live.** A minimap button belongs to the **installation**, not to a profile, and the global store is what makes two things true that the standard wants to be true. **Switching profiles does not move a player's buttons:** a profile is how a player configures what an addon *draws*, while the ring of buttons around the minimap is furniture they arranged once, and profile-scoped it would appear and vanish on a switch made for an unrelated reason. **And options-ui-§12's *Reset all settings* does not un-hide it:** that control is a **profile reset** by definition, so a profile-scoped `minimap.hide` would come back `false` and a button the player deliberately hid would reappear — a reset reaching past the settings it warned about into the frame furniture.
- **Most of the collection already stores it globally.** **Bank Ledger** and **Loot History** use `db.global.minimap`; **Multi Meters** uses `db.profile.minimap` and is the outlier, which adoption normalizes with a migration (launcher-§5).
- The row's **label says shown** and the stored boolean **says hidden**, so the row's `get`/`set` invert. That is the whole cost of storing the library's own key, and it is cheaper than the alternative. The `set` goes through the addon's **single write seam** (options-ui-§1, architecture-§5) like every other row, and calls LibDBIcon's `Show` / `Hide` so the button follows the checkbox immediately rather than at the next reload.
- **Seeding or backfilling the table is already settled elsewhere and is not restated as a rule here.** Writing `minimap = { hide = false }` over a path a row addresses is a whole-section write over a schema row, and **architecture-§5** governs it — as it governs LibDBIcon's own `minimapPos` writes into the same table, which are the library's and need no register row. The declared default is what materializes the table; cite architecture-§5, not this section.
- The row's **position** in the canonical set is fixed and is stated, with its reason, in options-ui-§15.

### 4. The icon is the addon's own logo

One file is the addon's face in **three** places — the AddOns list (the TOC's `## IconTexture`), the minimap button and a broker display — so a player who has seen the addon once recognizes it in all three.

- **MUST** point `## IconTexture` at that file, and **MUST** give the LDB object's `icon` field the same path (toc-file-§1). **MUST NOT** use a Blizzard icon path or a numeric file id for either: a borrowed icon makes the addon look like something else in the one list where the player is choosing what to turn off (**anti-pattern #82**).
- The file itself — its path, its exact format and the recipe that generates it — is **layout-§4**, which owns shipped media. It is `media/logos/<addon>.logo.128.tga`, 128×128, uncompressed 32-bit.
- The settings panel's **landing-page logo is a different, larger asset and is unchanged** (options-ui-§5). Two files, two jobs: one is read by the client as an icon at icon size, the other is drawn by the panel at 300×300.

### 5. Adopting it

Every addon in the collection is **non-compliant with this section until it adopts**, which is normal and expected — the section is new.

**The library minor lands FIRST, and no addon can adopt before it does.** options-ui-§15 and §16 require the Master-controls set to be **composed** by `LibKa0s-Options-1.0`'s `MasterControls` composer and never hand-written, and that composer has **no minimap seam**: there is no spec key for the row and nothing emits it (`OptionsCompose.lua`, compose minor 6, as shipped in LibKa0s v1.38.0). An addon that adopted today could satisfy this section only by hand-writing the row, which is the one thing §15/§16 forbid — so the standard's own rules would be in contradiction until the seam exists.

The seam is **`LibKa0s v1.39.0` (compose minor 7)**: a **`minimapPath`** spec key on `MasterControls`, exactly parallel to the existing `testModePath`, emitting the unconditional **`Minimap button`** row; and *Test mode* moves **off** `startsLine` so the two pair on one line as `[Minimap button] [Test mode]`, which is the column order options-ui-§15 states. Until an addon carries that tag, its adoption is **blocked rather than overdue**, and an audit records it as blocked — the gap is upstream, not in the addon.

Adoption is then one changeset per addon:

1. Vendor **LibDataBroker-1.1** and **LibDBIcon-1.0** under `libs/` and list them in the TOC's `# Libraries` section (toc-file-§4).
2. Generate `media/logos/<addon>.logo.128.tga` by layout-§4's recipe from the `.png` source already beside it, and point `## IconTexture` at it (toc-file-§1).
3. Build the one LDB object, give it the icon and an `OnClick` that implements the addon's rung plus right-click → settings panel (launcher-§1/§2), and register it with LibDBIcon.
4. Re-vendor **LibKa0s v1.39.0 or later**, add the `minimap.hide` row to the schema at `db.global.minimap.hide`, declare `minimapPath` on the `MasterControls` call so the composer emits the **Minimap button** row in its canonical position (options-ui-§15), and hand the same `minimap` table to LibDBIcon.
   - **An addon that already stores the table under `profile` migrates it.** `db.profile.minimap` → `db.global.minimap` is a stored-path move and takes the full savedvariables treatment — a bumped `schemaVersion` and a step in the migration runner, in the **same** change that moves the path — carrying the player's existing `hide` and `minimapPos` across so an adopted button does not jump back to the default angle. In the collection this is **Multi Meters** alone; Bank Ledger and Loot History already store globally and owe no migration.
5. Record the addon's rung in `ADDONS.md`, and document the launcher in `docs/settings-panel.md` (the row) and `docs/ARCHITECTURE.md` (the object and its owner).

An addon that has adopted the launcher but not yet the 128×128 logo ships a button that draws **nothing**, which is worse than the state before it adopted. Landing steps 2 and 3 together is therefore the obvious way to sequence the work, and it is **guidance, not a MUST of this section**: how a changeset is cut into commits is `versioning-git`'s subject, not this one's. What this section binds is the shipped state — a launcher registered with no icon file behind it is the finding, whatever the commit history looks like.
