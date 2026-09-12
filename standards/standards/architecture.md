> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Architecture

### 1. Namespace bootstrap

Every file **MUST** start with:

```lua
local addonName, NS = ...
```

`NS` is a single shared private table populated by ordered TOC loading. `addonName` is a string constant. **MUST NOT** create a `_G[addonName]` table; if a public surface is needed, expose it via `NS.API.v1` (see public-api).

Optional ergonomic alias for hot files:

```lua
local L = NS.L         -- locale
local C = NS.C         -- profile defaults / current values cache
local State = NS.State -- runtime state
```

### 2. AceAddon registration (any addon using Ace3 lifecycle)

Reference implementation (in the collection): the modular tracker promotes its bootstrap namespace to an AceAddon at `core/<AddonName>.lua`.

```lua
local addonName, NS = ...
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
NS.addon = addon  -- keep NS reference; modules read state through NS, not _G
```

- **MUST** pass the NS table as the first arg to `:NewAddon` (Ace3 supports this) so the bootstrap and AceAddon point at the same object.
- **A custom chat printer MUST survive the AceConsole embed.** Because `NS` *is* the addon object, `:NewAddon(NS, …, "AceConsole-3.0")` embeds AceConsole's mixins **directly onto `NS`**, and its `:Print` method **silently overwrites** any `NS.Print` a `Util`/bootstrap file defined earlier. Called as `NS.Print(msg)` (the message lands in `self`), AceConsole's `Print` renders `|cff33ff99<msg>|r:` — green text, a **trailing colon, and no cyan tag** — silently violating the mandated chat prefix (slash-commands-§4) with no error, masked by `/reload`, and invisible to any headless test whose AceAddon mock doesn't reproduce the embed. The addon **MUST** guarantee its own printer wins, one of two ways:
  - **Name the printer `NS.Util.print`** and call *that* at every site (never a bare `NS.Print`) — the embed then has nothing to collide with. (Reference implementation in the collection: the interrupt-cooldown tracker prints exclusively through `NS.Util.print`.)
  - **Reclaim `NS.Print` immediately after `:NewAddon`**, from the pristine copy the embed does not touch:
    ```lua
    local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
    NS.addon = addon
    if NS.Util and NS.Util.print then NS.Print = NS.Util.print end  -- AceConsole:Print clobbered ours; take it back
    ```
- **Test harness MUST model the embed.** A mock `:NewAddon` that doesn't stamp AceConsole's colliding `:Print` hides this bug — the clobber only manifests through the real embed. The AceAddon mock **MUST** stamp a `:Print` mixin onto the target (rendering `|cff33ff99<self>|r:` like the live mixin) so tests exercise the production print path. Same mock-fidelity rule as the bus receiver clobber (architecture-§4). See anti-pattern #36.
- **SHOULD NOT** use AceAddon's per-module submodule pattern (`addon:NewModule("Foo")`) for fewer than ~10 feature modules. Direct `NS.Foo = NS.Foo or {}` per-module tables are lighter and equally testable.

### 3. Module pattern

```lua
local addonName, NS = ...
NS.IconGrid = NS.IconGrid or {}
local M = NS.IconGrid

function M:OnInitialize() ... end  -- only if registered as AceAddon submodule
function M:HandleSomething(...) ... end
```

- **MUST** publish modules via `NS.<Module> = NS.<Module> or {}` (idempotent) so file load order can be re-arranged without breakage.
- **SHOULD NOT** call into another module's table at file-load. Cross-module wiring happens after `PLAYER_LOGIN` or via the message bus.

### 4. Closed message bus

Modules **MUST** communicate via named messages, not direct calls.

**Applicability.** This MUST binds an addon with **two or more feature modules**, or **any module that
registers game events**. Below that threshold — one feature module and no event traffic — direct calls
are **permitted**, and `docs/ARCHITECTURE.md`'s `## Message Bus` section (documentation-§3) **MUST**
record that there is no bus and why, in a sentence or two.

The condition is stated because the rule's entire rationale is the CallbackHandler same-target clobber
described below, and that hazard **cannot arise** with a single feature module and no events: there is
no second party to name a message to, and no second receiver to be overwritten. Without the condition
the MUST is unsatisfiable in principle for a single-module addon — it would be re-filed as a deviation
against every such addon, forever, including every future one. That is a defect in the **rule**, which
is why it is fixed here rather than absorbed one addon at a time by the deviation register
(documentation-§3).

Crossing the threshold is a real event, not a formality: the second feature module, or the first module
to register a game event, is the point at which the bus **MUST** exist. An addon sitting just under the
threshold **SHOULD** say so in that `## Message Bus` section, so the next author adding a module knows
what the addition costs.

```lua
-- Producer (one per message; send on any embed — SendMessage fans out to all receivers)
NS.bus:SendMessage("Ka0s_<Addon>_RosterChanged", roster)

-- Consumer (MUST register on its OWN target, never the shared bus — see the receiver rule)
NS.<Module>.__ev:RegisterMessage("Ka0s_<Addon>_RosterChanged", function(_, roster) ... end)
```

- **MUST** prefix every message `Ka0s_<Addon>_` to avoid collision.
- **MUST** document each message in `docs/ARCHITECTURE.md` with: name, sender (one), payload schema, all consumers.
- **MUST NOT** have two senders for the same message.
- **Each *receiver* MUST register on its own AceEvent target — never register two receivers of the same message on one shared object.** CallbackHandler keys callbacks by `(message, target)` (`events[message][self] = fn`), so if two consumers call `RegisterMessage("Ka0s_<Addon>_X", …)` on the *same* object (typically the shared `NS.bus`/`NS.addon`), the second **silently overwrites** the first — only the last registrant ever receives the message. There is no error, and it is easily masked: a `/reload` re-registers the survivor, so a live change (e.g. a settings toggle broadcast on `SettingsChanged`) appears to "work after a reload" while failing in-session. Two correct target shapes:
  - **AceAddon modules** — `addon:NewModule("<Name>", "AceEvent-3.0")` gives each module its own AceEvent embed; register on the module's `self`. (Reference: the interrupt-tracker's per-module handlers.)
  - **Plain-table modules on a single AceAddon object** — each receiver owns a private target from a one-line factory; never register on `NS.bus`/`NS.addon` as `self`:
    ```lua
    function NS.NewBusTarget()          -- fresh AceEvent-embedded table per receiver
      local AceEvent = LibStub("AceEvent-3.0", true)
      if not AceEvent then return nil end
      local t = {}; AceEvent:Embed(t); return t
    end
    -- in each consumer's enable path:
    NS.<Module>.__ev = NS.NewBusTarget()
    NS.<Module>.__ev:RegisterMessage("Ka0s_<Addon>_RosterChanged", function(_, roster) ... end)
    ```
- **Test harness MUST model real dispatch.** A no-op `RegisterMessage`/`SendMessage` mock hides this class of bug (the clobber only manifests through real `(message, target)` keying). The bus mock **MUST** key callbacks by target and fan `SendMessage` out to every target, so a test can assert two receivers of one message both fire.
- Implementation: AceEvent-3.0's `:SendMessage`/`:RegisterMessage` (already in the addon); no new lib needed.

### 5. Schema-as-single-source

The single most important Ka0s pattern. Already implemented well across the collection. **MUST** be present in every addon with ≥3 user-visible settings.

```lua
NS.Schema = {
  { path = "display.scale",         default = 1.0,    type = "number",  min = 0.5, max = 2.0,
    label = "Scale", widget = "Slider", validate = function(v) ... end,
    onChange = function(v) NS.Display:UpdateScale(v) end },
  { path = "display.color",         default = {1,1,1,1}, type = "color",
    label = "Color", widget = "ColorPicker",
    onChange = function(v) NS.Display:UpdateColor(v) end },
  ...
}
```

- **MUST** drive all of: AceDB defaults, AceGUI panel widgets, `/<slash> get|set|list|reset` dispatch, defaults reset.
- **MUST** route every write to a **schema-row path** through one helper: `NS.Schema:Set(path, value)` calls validate → write → onChange. Panel and slash both call this. *Every write* means every one: a whole-section or whole-table write to a path that holds rows goes through the helper, and so does a write to an **instance-relative** row inside a registry member (a window's, a container's, a panel's own rows) — the helper addresses the instance, by an argument or by resolved context, and the write does not go around it. A writer that writes rows of a member that is **not** the current one **MUST** be able to target that member through the helper (an explicit instance argument, say); moving session state so the helper points at it is going around it.
- **MUST** route every **membership change of a structural registry** through **one registry writer**, and **MUST** name that writer in `docs/ARCHITECTURE.md` → **Settings Schema** (documentation-§3). A leaf helper cannot carry these writes, and the reason is structural rather than a matter of effort: a row is a leaf with a fixed path, and *"container 7 exists"* is not a leaf. A collection the helper does take whole at one path is not a registry at all (test (3) below).
  - **What a structural registry is.** A persisted collection whose members the **player creates and deletes at runtime** — user-built windows, containers, panels, meters, tracked-spell lists, id sets — so that its key set is not known when the schema is written. A collection is a registry only if it passes **all three** tests: (1) the player **adds and removes** members, not only edits or reorders them; (2) the defaults ship it **empty or seeded**, never enumerating every member it can hold; (3) **the helper takes no path for it**: no row path, fixed or instance-relative, names a member's existence, and the helper accepts no **whole-value path** that writes the collection in one call. A collection that fails (3) only on that last clause — a set of ids the helper validates, normalizes, writes and announces at one path, like a row — is a **value**. Every membership change is then a whole write through the helper, and the collection needs no registry writer and no register row. An addon **MAY** take that route for a flat collection whose members carry no rows of their own; the writer route and the whole-value route are both compliant. A list over a **fixed** member set that the player only reorders or toggles — a priority cascade over known providers — fails (1) and (2): it is a **value**, written whole through the helper like any other row, or, with no row, it carries a `Documented deviations` row under the **MUST NOT** below. A **preference** the player sets on a member — a color, a size, a toggle, a position, an art choice — is not a registry either, whatever collection it lives in: it is a setting, and a setting with no row is a **missing row**. The test is what the field holds, not why it was left out. A missing row fails the drive-all-of MUST and the schema-row helper MUST both, unless it carries a `Documented deviations` row. Geometry **only a drag or a resize** determines — no control sets it and no row addresses it — is **named non-setting state** below whether or not it sits on a member: named, it needs no register row. A position a control also sets is a preference, and a drag that writes a field a row addresses is a schema-row write.
  - **What the writer owns.** Membership — create, delete, duplicate — plus the registry's **identity and bookkeeping**, and nothing else: the order, the id counter, the storage key, a stamped id, a frame name, a name that serves as a lookup key, and a sentinel recording that seeding has run. The list is **closed**; a preference on a member is not on it (the missing-row test above). **A row wins over a key.** If any row addresses a field, a write to it is a schema-row write even when the field is also identity: a name that is both a lookup key and a row goes through the helper, and the writer keeps only the uniqueness check and any re-index. Creating or duplicating a member writes it **whole**, initial contents included, since a member that did not exist has nothing for an `onChange` to tell. After that, a member field a row addresses goes through the helper **even when the registry writer is the caller** — a rename, a copy-from or a per-member reset that touches rows. A **registry reset** verb — one list, or every list, back to its seeded state — is a writer operation: it applies a player's choice, runs through the writer, and **MAY** call the same seed routine the load pass calls. *One* writer is one module or object owning every **runtime** write; a helper called only by the writer and its named load pass (an id mint, a shape backfill, a seed routine) is part of the writer and is named with it, whichever file it lives in. Panel code and slash handlers **call** the writer; they never append to, splice or `table.remove` the stored collection themselves. Each registry has one writer; two registries **MAY** have two. A traversal accessor that lazily creates an **empty** container on first read changes no membership and is not a writer.
  - **The load pass is part of the writer's surface, and is named with it.** The pass that runs at database initialization and again from AceDB's profile-changed / -copied / -reset callbacks — the savedvariables-§1 migration runner and any profile-preparation step called with it — **MAY** write the registry directly: seed a first-run member, re-key, drop malformed entries, backfill template fields into members, rebuild the order, bump the counter past the highest stored id, and set the sentinel that records seeding has run. It runs **before any reader has seen the data**, so there is nothing for `onChange` to tell, and routing it through the helper would fire reactors at modules that are not up yet. Two limits keep it from being a side door. Its **entry points** — the runner and the profile-preparation function — are reachable **only** from initialization and the AceDB profile callbacks, never from a slash verb or a panel control; a seed routine they share with the writer's reset verb is the writer's, and that sharing is no breach. And it **repairs and seeds; it never applies a player's choice**. Row leaves the same pass migrates or backfills are savedvariables-§1's runner, not a write the schema-row helper MUST above binds.
  - **Wholesale replacement is not a registry write.** The options-ui-§12 global reset (`db:ResetProfile()`, or the account-wide store emptied wholesale where nothing is profile-scoped) and AceDB's own profile swap and copy replace the store whole, and the load pass re-seeds after them. None of them routes through the writer and none needs a register row.
  - **Naming is the compliance.** For each registry, `ARCHITECTURE.md` names the storage keys, the writer and the load-pass function(s) — one sentence each is enough. A registry written only by its named writer and its named load pass is **compliant and carries no register row**; a `Documented deviations` row that exists only because the registry bypasses the helper is stale and retires as compliant. An unnamed writer is a doc-only MUST failure. Registry writes spread across more than one runtime module are a code finding (anti-patterns #78).
- **MUST NOT** write any other persistent state outside the helper without a `Documented deviations` row, **named non-setting state excepted** (the next bullet). What the row is left for is every other state, chiefly a preference with no row, on a member or not, and a list over a fixed member set with no row.
- **Named non-setting state MAY be written outside the helper.** It is persistent state that **no control sets and no row addresses**, in four classes and no others:
  - **geometry only a drag or a resize determines** — a frame's point, offsets and size, whether it is saved on drag-stop, on hide or at logout, where no row addresses it, on a registry member or not;
  - **a remembered view** — what a window restores when it opens (its filters, sort, range, tab), captured whole from what is on screen, whether on close or by a *Save view* act;
  - **learned or recorded data** — a cache or log the addon builds itself from what it observes: a set of spells seen carrying a duration, a movement log, a fingerprint of the last macro edit;
  - **a vendored library's own writes** into a table the addon hands it — LibDBIcon storing `minimapPos` when the player drags the minimap button.

  **Naming is the compliance**, as it is for a registry. `ARCHITECTURE.md` → Settings Schema names each piece: its storage key, its **one owner module**, and what writes it — every function that writes it, whichever file it lives in, and the act that reaches each (a drag-stop, a scan, a reset verb, the library). One sentence each is enough. **Complete naming is enough:** one named owner and every writer listed, wherever each lives. A writer outside the owner module — a reset in a settings file, a reset in a second module — is compliant once the naming lists it, and a direct write from outside the owner is **not** a finding when it is named. A registry writer's create or duplicate that writes such state, and any template backfill it calls, is listed among that state's writers. Named state carries **no `Documented deviations` row**, and a row that exists only for it is stale and retires as compliant. Unnamed state is a doc-only MUST failure, and so is a writer the naming leaves out; the remedy is the sentence, never a register row. The savedvariables-§1 load pass **MAY** migrate, backfill or seed it as it does rows, and is not a writer the naming has to list. An accessor that lazily creates an empty container on first read is not a writer either. Wholesale replacement (options-ui-§12, AceDB's swap and copy) replaces whatever of it lives in the store it replaces. debug-logging-§10 already treats it as non-schema and logs none of it per change.

  Four guards keep the classes from becoming a side door. Each is a test on the data, not on intent:
  - **A control makes it a preference.** If any control sets the value — a slider, an X/Y field, a dropdown, a checkbox, a slash verb that takes the value — it is a preference, not named state, and with no row it is a missing row that needs a row or a register row. A control *sets* a value when it chooses it. A reset that clears the state or puts back its shipped default chooses nothing, and neither does an act that captures what is already on screen, such as a drag or *Save view*. A value the addon derives chooses nothing either: a duplicate's offset, a template backfill, a copy that keeps the target's own value.
  - **A row wins.** A drag that writes a field a row addresses is a schema-row write and goes through the helper. So is a write that replaces a whole table holding a row path: seeding `minimap = { hide = false }` over a `minimap.hide` row is a whole-section write, whatever else the table holds. It is a schema-row write to fix, and until it is fixed the naming also lists it as a writer of any named state the table covers.
  - **Learned data holds no player choice.** Every entry is something the addon observed or derived. The player may delete entries or clear the whole, but authors no entry's value: a set the player adds ids to is a registry or a value (the three tests above), never learned data, and a value the player picks is a preference. A reset that clears learned data — a *forget*, a *purge*, a forced rebuild — and a per-entry delete are the **owner's operation** and belong in its naming, like any other writer. So is a prune the owner runs from a row's value, such as a retention period.
  - **The library clause covers the library's own writes only.** The addon writing into the table it handed the library outside the load pass — a seed, a backfill, a field it sets for the library's sake — is the addon's write, classified like any other: through the helper where a row addresses it, and otherwise under the MUST NOT above. A library write the addon makes from a control that chooses the value (calling LibDBIcon's `Lock` from a checkbox) is a preference.
- **MUST** validate at boot: every schema row's `path` resolves against the defaults table; warn loudly on mismatch. Reference implementation (in the collection): the absorb-shield tracker walks every schema row at load and prints a loud warning for any path that doesn't resolve against defaults; the validation count is exposed for the test harness (testing).

### 6. Two-phase init (only when needed)

For addons with ≥6 modules, **SHOULD** use a two-phase init pattern (as large UI suites do): an "initial" queue that runs before AceDB is ready (Compat shims, Constants), and a "regular" queue that runs after (`OnInitialize`/`OnEnable`).

### 7. Prototype registry (optional)

For addons where TOC ordering has been fragile, **MAY** use a lazy table cache (the pattern large boss-mods use for their module prototypes):

```lua
NS._prototypes = setmetatable({}, { __index = function(t, k) t[k] = {}; return t[k] end })
function NS:GetPrototype(name) return NS._prototypes[name] end
```

Producer files write methods onto `GetPrototype("Foo")`; consumers read methods off it. Either side can load first.
