> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Events, frames, taint

### 1. Event registration

- **MUST** use AceEvent-3.0 (`addon:RegisterEvent("X")`). **MUST NOT** create per-module frames just for events (boss-mod-scale hand-rolling is overkill below 1000 events/min).
- **SHOULD** centralize CLEU dispatch on a single shared frame with a spellID hash table when CLEU is the hot path (the boss-mod `mod:Log(subevent, fn, spellId)` model). **MUST NOT** subscribe N modules separately to CLEU.
- **MAY** use AceEvent's `:RegisterMessage`/`:SendMessage` for the closed message bus (architecture-§4).

### 2. Combat lockdown

- **MUST** guard secure-environment writes (frame `:SetAttribute`, secure-template parents, focus-frame mutations) with `InCombatLockdown()` returning early and replaying on `PLAYER_REGEN_ENABLED`.
- Reference implementation (in the collection): the group-composition utility uses a 3-layer cascade (config open → settings register → frame show), each re-checking combat; the chat-formatting addon combat-gates its config open.

**`InCombatLockdown()` vs `UnitAffectingCombat("player")` — not interchangeable.** They answer different questions and usually (but not always) agree for the player:

- `InCombatLockdown()` — *"are protected actions forbidden right now?"* The authoritative gate for **secure operations**. No args (player-only); true from `PLAYER_REGEN_DISABLED` to `PLAYER_REGEN_ENABLED`.
- `UnitAffectingCombat(unit)` — the actual **combat flag** on any unit (`"player"`, `"target"`, `"party1"`, `"boss1"`…). The tool for **gameplay/UI state** (fade an out-of-combat frame, show an in-combat indicator, check a *non-player* unit).

- **MUST** gate secure writes on `InCombatLockdown()` — **MUST NOT** substitute `UnitAffectingCombat("player")`. The two can diverge at the combat boundary, and gating a secure call on the combat flag can raise *"action blocked / interface action failed"* in exactly those moments.
- **SHOULD** use `UnitAffectingCombat(unit)` for combat-reactive display/logic — that is what "is this unit in combat?" is *for*, and it is the only option for units other than the player. Using `InCombatLockdown()` here is a bug: a purely visual show/hide gated on lockdown state reads player-only lockdown, not the unit's actual combat status. (A live AbsorbTracker bug: the bar failed to appear in combat because visibility was gated on `InCombatLockdown()` instead of `UnitAffectingCombat("player")`.)
- **SHOULD** drive player combat *transitions* off the `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` events — they fire exactly at the lockdown boundary and flush any deferred-secure-write queue — rather than polling either function.

### 3. Taint-replacing Blizzard UI

If your addon replaces a Blizzard frame (bag UI, bag manager, group finder window):

- **MUST** `hooksecurefunc` on Toggle*. **MUST NOT** assign a replacement function to `_G.ToggleX`.
- **SHOULD** guard hooks with `debugstack():find("Manager")` to ignore Blizzard-internal recursion.
- **MUST** reparent hidden Blizzard frames to a hidden parent — **MUST NOT** call `:Hide()` on them (causes taint propagation).
- **MUST NOT** instantiate `MoneyFrame` directly; use `TooltipDataProcessor.AddLinePreCall` + `GetMoneyString()`.
- **SHOULD** ship a `core/TaintLess.xml` as the first XML include if XML is used.

### 4. Macro / protected-action APIs

If your addon writes macros or calls protected APIs (`CreateMacro`, `EditMacro`, `RunMacro`, `EditMacroByID`):

- **MUST** firewall: a single module is the **only** caller of those APIs. Reference implementation (in the collection): the consumables & macro manager routes every `CreateMacro`/`EditMacro` call through one `MacroManager` module, which is the sole caller. Audit this at lint time.
- **MUST NOT** call protected APIs from event handlers that can fire in combat.

### 5. Chat-frame manipulation

If your addon formats chat:

- **SHOULD** prefer overriding `_G[GLOBALSTRING]` over `ChatFrame_AddMessageEventFilter` and `hooksecurefunc(ChatFrame, "AddMessage")`. Reference implementation (in the collection): the chat-formatting addon overrides the relevant global strings rather than hooking chat events, so it is architecturally taint-free.
- **MUST NOT** replace `AddMessage` outright — breaks every other chat addon.
- **MUST** make cross-registration ordering deterministic (a `pairs()` over filters is order-nondeterministic). Use an ordered table.

### 6. Frame creation

- **MUST** prefer Lua `CreateFrame` over XML for non-templated frames in Tier 1 addons.
- **MAY** use XML for declarative groups of similar widgets in Tier 2 (the manifest-XML pattern used by auction-house addons).
- **MUST** use object pooling for any high-churn UI (≥10 dynamic frames): an ~80-line object-pool mixin (Acquire/Release/HideAll), the pattern party-cooldown trackers use so roster churn becomes free.

### 7. Hot-path upvalue cache

For per-frame loops:

```lua
-- module locals refreshed on settings change
local DB_AURA_ENABLED, DB_USE_RANGE = false, false
function M:RefreshUpvalues()
  DB_AURA_ENABLED = NS.db.profile.auraEnabled
  DB_USE_RANGE   = NS.db.profile.useRange
end
-- in OnUpdate / OnEvent
if DB_AURA_ENABLED then ... end
```

- **MUST** call `M:RefreshUpvalues()` at end of every settings setter that touches values used in the hot path. (The DB-upvalue-refresh pattern nameplate frameworks use.)

### 8. Combat-protected "secret" values

In combat, retail protects combat-sensitive return values — unit absorb/health totals, threat, some aura amounts — as **"secret" values**: an opaque token the addon cannot inspect. The trap is asymmetric and easy to get wrong:

- A secret **survives `tostring()`** (returns another secret string) **and survives the `..` operator** (which silently propagates secretness) — neither raises.
- A secret **raises the instant it reaches `table.concat`** (and `string.format`): `invalid value (secret) at index N in table for 'concat'`.
- Engine-side consumers accept secrets fine: `AbbreviateNumbers()` formats one for display, and widget setters (`FontString:SetText`, `StatusBar:SetValue`/`SetMinMaxValues`) take them directly.

Because chat/debug lines end in `table.concat`/`string.format`, an unguarded secret raises there — and if that line runs inside a **repeating timer** (a repaint ticker), the erroring callback stops rescheduling and the feature **freezes until `/reload`**. A debug log line is the classic trigger: harmless out of combat, fatal the moment combat makes the value secret.

- **MUST NOT** pass a value read from a combat-protected API into `table.concat`, `string.format`, `print`, or any Lua string builder without guarding it. For **display**, hand the raw value straight to `AbbreviateNumbers()` or the widget setter — never `tonumber()` it first (returns nil / loses the value) and never compare it with `<`/`>` (raises).
- The shared chat/debug output seam (the `NS.PREFIX` printer slash-commands-§4, the debug sink debug-logging-§4) **MUST** be secret-safe: route every argument through one **secret-safe stringifier** that substitutes a sentinel (e.g. `"<secret>"`) for any value a real `table.concat` would reject. Detection **MUST probe `table.concat`, not `..`** — a `..`-based probe reports a secret as *safe* (the operator propagates rather than raises) and lets it slip straight through to the real concat.

```lua
-- Detect via the operation that actually rejects a secret: table.concat (NOT `..`, which
-- propagates secretness without raising). There is no public issecret() API.
local function probeConcat(v) return table.concat({ v }) end
function NS.IsConcatSafe(v) return (pcall(probeConcat, v)) end

function NS.SafeToString(v)
  if v == nil then return "nil" end
  if type(v) == "boolean" then return tostring(v) end   -- never secret; concat rejects it anyway
  if NS.IsConcatSafe(v) then return tostring(v) end
  return "<secret>"
end
-- NS.Print / NS.Debug build each line from NS.SafeToString(arg) — never raw tostring / `..`.
```

- The addon **MUST** funnel **every** chat and debug line through a **single shared secret-safe printer** — one `NS.Print` for chat, one debug sink for the console (debug-logging-§4) — each building its line from the secret-safe stringifier. The guard then lives in exactly one place and every call site inherits it. Concretely, call sites **MUST NOT**:
  - call the global `print()` directly (it neither carries the `NS.PREFIX` tag nor secret-stringifies its args);
  - hand-write the `NS.PREFIX` tag per line (slash-commands-§4);
  - hand-roll secret handling, or feed chat/debug args through `..` / `tostring` / `table.concat` before the shared printer.

  Instead, each file does `local print = NS.Print` (and routes debug through the debug sink) and emits `print("message")` — the shared printer prepends the tag and secret-stringifies every argument. A file that calls the global `print()`, or pre-concatenates args before the printer, is **non-compliant even if it is never handed a secret today** — the next value routed through it may be one, and the whole point of the single seam is that no call site has to reason about that. Where AceConsole-3.0 is embedded, the shared `NS.Print` **MUST** be reclaimed after `NewAddon` so its `:Print` mixin cannot silently replace the secret-safe printer (architecture-§2, slash-commands-§4).

Reference implementation (in the collection): the absorb tracker's `NS.IsConcatSafe` / `NS.SafeToString` in `core/Util.lua`, routed through by both `NS.Print` and `NS.DebugPrint`; the loot-history browser applies the same seam (`core/Util.lua` printer, reclaimed in `core/LootHistory.lua`).
