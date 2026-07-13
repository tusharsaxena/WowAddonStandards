> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Architecture

### 1. Namespace bootstrap (both tiers)

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

### 2. AceAddon registration (Tier 2 / any addon using Ace3 lifecycle)

Reference implementation (in the collection): the Tier-2 tracker promotes its bootstrap namespace to an AceAddon at `core/<AddonName>.lua`.

```lua
local addonName, NS = ...
local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
NS.addon = addon  -- keep NS reference; modules read state through NS, not _G
```

- **MUST** pass the NS table as the first arg to `:NewAddon` (Ace3 supports this) so the bootstrap and AceAddon point at the same object.
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

### 4. Closed message bus (Tier 2)

Modules **MUST** communicate via named messages, not direct calls.

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
- **MUST** route every mutation through one helper: `NS.Schema:Set(path, value)` calls validate → write → onChange. Panel and slash both call this.
- **MUST** validate at boot: every schema row's `path` resolves against the defaults table; warn loudly on mismatch. Reference implementation (in the collection): the absorb-shield tracker walks every schema row at load and prints a loud warning for any path that doesn't resolve against defaults; the validation count is exposed for the test harness (testing).

### 6. Two-phase init (only when needed)

For Tier 2 addons with ≥6 modules, **SHOULD** use a two-phase init pattern (as large UI suites do): an "initial" queue that runs before AceDB is ready (Compat shims, Constants), and a "regular" queue that runs after (`OnInitialize`/`OnEnable`).

### 7. Prototype registry (optional)

For Tier 2 addons where TOC ordering has been fragile, **MAY** use a lazy table cache (the pattern large boss-mods use for their module prototypes):

```lua
NS._prototypes = setmetatable({}, { __index = function(t, k) t[k] = {}; return t[k] end })
function NS:GetPrototype(name) return NS._prototypes[name] end
```

Producer files write methods onto `GetPrototype("Foo")`; consumers read methods off it. Either side can load first.
