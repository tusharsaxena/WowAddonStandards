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

- **MUST** prefer Lua `CreateFrame` over XML for non-templated frames.
- **MAY** use XML for declarative groups of similar widgets (the manifest-XML pattern used by auction-house addons).
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

- The stringifier and the printer are **`LibKa0s-Core-1.0`'s**, not the addon's. An addon **MUST NOT**
  hand-roll either (anti-patterns #47): it publishes the library's own function values from its
  `core/CoreSetup.lua` seam — `NS.IsConcatSafe = lib.IsConcatSafe`, `NS.SafeToString = lib.SafeToString`
  — and builds its chat printer from `lib:New{ prefix = ... }`. The sentinel is `lib.SECRET`.

```lua
-- core/CoreSetup.lua — the seam, not the algorithm.
local lib = LibStub and LibStub("LibKa0s-Core-1.0", true)
if lib then
  NS.IsConcatSafe = lib.IsConcatSafe        -- pcall-probes table.concat, NOT `..`
  NS.SafeToString = lib.SafeToString        -- nil/boolean pass through; otherwise lib.SECRET
  NS.Print = lib:New{ prefix = function() return NS.PREFIX end }.Print
end
-- NS.Print / NS.Debug build each line from the library's stringifier — never raw tostring / `..`.
```

  The library probes `table.concat` rather than `..` for the reason above, and the probe lives in one
  place for the whole collection precisely so that no addon has to get it right twice. A degraded
  build (library absent) falls back to the addon's own guarded implementations in the same file — that
  branch is the **only** sanctioned place a second copy may exist, because a printer that answered
  "not installed" instead of printing would silence every line the addon emits (debug-logging-§7).

- The addon **MUST** funnel **every** chat and debug line through a **single shared secret-safe printer** — one `NS.Print` for chat, one debug sink for the console (debug-logging-§4) — each building its line from the secret-safe stringifier. The guard then lives in exactly one place and every call site inherits it. Concretely, call sites **MUST NOT**:
  - call the global `print()` directly (it neither carries the `NS.PREFIX` tag nor secret-stringifies its args);
  - hand-write the `NS.PREFIX` tag per line (slash-commands-§4);
  - hand-roll secret handling — the stringifier is the library's, in one place, for the whole collection;
  - feed chat/debug args through `..` / `tostring` / `table.concat` before the shared printer — **within the scope stated below**.

  Instead, each file does `local print = NS.Print` (and routes debug through the debug sink) and emits `print("message")` — the shared printer prepends the tag and secret-stringifies every argument. Where AceConsole-3.0 is embedded, the shared `NS.Print` **MUST** be reclaimed after `NewAddon` so its `:Print` mixin cannot silently replace the secret-safe printer (architecture-§2, slash-commands-§4).

**Scope of the pre-formatting rule.** *Pre-formatting is a MUST NOT at a call site whose arguments can
reach a value read from one of the combat-protected APIs named below, and a SHOULD NOT everywhere
else.*

That sentence is the whole scoping rule. What follows is the list it names and why the remainder is a
SHOULD.

**The named APIs — the MUST's trigger set.** A call site is in scope if any argument it builds is, or
derives from, a return value of:

- `UnitGetTotalAbsorbs`, `UnitGetTotalHealAbsorbs`, `UnitGetIncomingHeals`
- `UnitHealth`, `UnitHealthMax`
- `UnitThreatSituation`, `UnitDetailedThreatSituation`
- the amount / `points` fields of an aura payload — `C_UnitAuras.GetAuraDataByIndex`,
  `GetAuraDataBySlot`, `GetAuraDataBySpellName`, `GetPlayerAuraBySpellID` — and the same fields as they
  arrive on `UNIT_AURA`
- **any other API a client build protects in combat**, and **anything derived from a protected value**:
  secretness propagates silently through `..` and `tostring`, so a local computed from one is still in
  scope, and so is a field stored on a table and read back later.

This list is **the normative trigger set**. When a build protects a new API, extend the list here — that
is an upstream edit, not a per-repo judgement call, because the whole value of naming the APIs is that
every repo grades against the same set.

**Outside the trigger set it is a SHOULD, and the reason is drift, not secrets.** A site that formats
only values the addon owns — a setting name, a count it computed, a literal — cannot be handed a secret,
so a MUST there is unenforceable in the sense that matters: nothing checks it (`.luacheckrc` sees none
of these sites), no user can hit a failure, and a recurring finding across roughly fifty such sites
collection-wide costs triage and changes no behavior. It stays a **SHOULD** because the risk is real but
future-tense: a call site's argument list is not stable, and the day someone adds an absorb total to a
line that used to format a setting name, the guard should already be in the seam rather than in the
diff. Prefer `print("count", n)` over `print(("count %d"):format(n))` so that day costs nothing. A site
that later moves into the trigger set converts as a MUST, and an audit files it as one.

**Two things this scoping does not relax.**

1. **No addon calls the global `print()` for user-facing output — at any site, in scope or out.** That
   prohibition is independent of secrets: the global neither carries the `NS.PREFIX` tag every other
   line carries (slash-commands-§4) nor secret-stringifies anything, so a bare `print()` is a
   user-visible defect — an untagged chat line — whatever it is printing. It remains the unqualified
   MUST NOT stated above.
2. **The seam's own guarantee is unconditional.** The shared printer and the debug sink **MUST** route
   every argument through the secret-safe stringifier regardless of what any call site does, and the
   probe **MUST** still be `table.concat`-based. The scoping governs only what a *call site* may hand
   the seam; it never weakens what the seam does with what it is handed.

**Grading.** A pre-formatting site outside the trigger set is graded by impact like anything else
(`AUDIT.md`): no user, no SavedVariables and no session can reach it, so it is **Low or Info** — and it
still names the SHOULD it fails. Inside the trigger set it is a MUST, graded on what the value can do:
an unguarded secret on a repeating ticker stops the callback rescheduling and freezes the feature until
`/reload`.

Reference implementation: `LibKa0s-Core-1.0` (`Core.lua`) owns the probe, the stringifier and the prefixed printer; a consuming addon's `core/CoreSetup.lua` publishes them and reclaims `NS.Print` after `NewAddon` where AceConsole is embedded (architecture-§2). An addon that still defines its own stringifier is carrying a pre-library copy — that is the deviation, not the absence of one.
