> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Clients — Retail and WoW Forever

The collection supports **two game clients**: Retail, and WoW Forever (Blizzard's vanilla-era game type, "Camelot"). Each addon serves both from **one codebase**: one repo, one unsuffixed TOC, one `libs/` tree. There are no separate Forever addons, and no Classic flavors. This section says which clients exist, how an addon declares the ones it supports, how it asks which one it is on, and how a feature or a seeded list that only one client can have is kept apart from the other. It is the owner's ruling of 2026-11-07, and the rules that follow from it are these, which the sections below and skinning-§2 apply:

- **A feature is absent, never just hidden, on a client that cannot support it.** A Forever player never sees a Retail-only feature (the group finder, the warband bank, Mythic+, transmog, the Encounter Journal), and a Retail player never sees a Forever-only one.
- **Seed lists are kept per client.** Spells, items, talents and similar seeded data, and the actions built on them, have one list per client. Forever gets its own list, not a filtered Retail one.
- **The default skin is per client** (owner ruling of 2026-11-08): WoW Forever on Forever, Ka0s Default on Retail, answered by the library and never by an addon's own client check (skinning-§2).

### 1. The supported clients

| Client | Roster token | Detected by (clients-§3) | Identity |
|---|---|---|---|
| Retail (Mainline) | `retail` | `Compat.IsRetail()`, `ClientKey() == "retail"` | `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE`; the current Retail interface number is what the Retail addons ship (toc-file-§3). |
| WoW Forever (Camelot) | `forever` | `Compat.IsForever()`, `ClientKey() == "forever"` | client 1.60.1, build 70790, interface **16001**, `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT == 18`. |

`WOW_PROJECT_CAMELOT` is **nil on Retail**, so an expression that reads it must tolerate nil, and that is one more reason the read lives in one place (clients-§3). A third token, `both`, exists in a feature's declaration (clients-§4) and means "this feature serves both clients"; it is never a client.

Nothing else is supported. The Classic Era, Season of Discovery, Cataclysm Classic and Mists Classic flavors are out of scope, and an addon **MUST NOT** carry code written for them.

### 2. The roster declaration

- **MUST** be declared in the roster: `ADDONS.md`'s **Clients** column holds one of `Retail · Forever`, `Retail` or `Retail (port pending)` for every addon. The column is normative, is the single source of truth that `dev-copilot` and the audit read, and records what the addon **ships today** (ADDONS.md, *The Clients column is normative input to an audit*). Do not restate the addon list here or anywhere else.
- **MUST** flip the row in the same change that lands the port. An addon that gains Forever support and keeps its `Retail (port pending)` row, or the reverse, is a deviation.
- **MUST** match the TOC to the row (toc-file-§3): `Retail · Forever` ships `## Interface: <retail>, <forever>`; `Retail` ships one number plus the two load-gating lines; `Retail (port pending)` ships one number and no gating line.
- The audit applies a per-value check set, and the table in ADDONS.md is where it is defined. A `Retail (port pending)` addon is not flagged for a missing dual-client shape, but **is** flagged for a new Retail-only feature added with no declaration (clients-§4), because that is how a pending port grows harder.

### 3. Detection goes through Compat, and only there

- **MUST** ask which client it is on **only** through `LibKa0s-Compat-1.0`: `IsForever()`, `IsRetail()` and `ClientKey()`, which answers `"retail"`, `"forever"` or nil (an unknown client). An addon reaches them as `NS.Compat.IsForever()` and so on, routed from `core/Compat.lua` (compat, library-stack-§7). The library reads `WOW_PROJECT_ID` once and owns the nil-tolerance of `WOW_PROJECT_CAMELOT`.
- **MUST NOT** read `WOW_PROJECT_ID`, `WOW_PROJECT_MAINLINE`, `WOW_PROJECT_CAMELOT` or `WOW_PROJECT_CLASSIC` outside `LibKa0s-Compat-1.0`, and **MUST NOT** decide the client from an interface number (`select(4, GetBuildInfo())`, a comparison against `16001` or a Retail patch number). The interface number changes every patch and says nothing about the game type.
- **MUST NOT** treat `== WOW_PROJECT_MAINLINE` as meaning "a modern client". Forever carries modern APIs and Retail carries old ones; the question an addon needs answered is "is this Retail" or "is this Forever", and `ClientKey()` answers it.
- **MAY** use **feature detection** (`if C_Foo and C_Foo.Bar then`) for one specific API gap **inside a feature the client supports**: one function missing from one build, tolerated at its call site or in the compat family. Feature detection **MUST NOT** decide whether a whole feature exists; that is a declaration (clients-§4).
- **SHOULD NOT** branch on the client at all in feature code where a declaration or a per-client table does the job. A client branch in feature code is a smell, and the compat family is where one belongs (compat).

### 4. Per-client features are declared and gated at registration

A **feature** is a module, a settings page or tab, a slash verb, a launcher menu entry, a key binding, or an event registration. A feature that exists on only one client:

- **MUST** be **declared** with the client it serves, in the registration call itself: the `clients` field of the library's descriptor, `clients = { "retail" }`, whose tokens are `retail`, `forever` and `both` (clients-§1). A feature with **no** declaration serves both clients.
- **MUST** be **gated at registration**: through that descriptor field where the library registers the feature (options, slash, launcher, bindings), and through `Compat.ForClient(clients)` where the addon registers it itself (a module's `OnInitialize`, an event registration). `ForClient` returns true when the running client is among `clients`, so a gated registration is one `if` that either runs the registration or does not.
- **MUST NOT** be registered and then hidden. Hiding, graying out or disabling a feature on the client that cannot support it at runtime (a `Hide()`, a `SetEnabled(false)`, a "not available on this client" row) **does not meet the rule**: the feature must be absent, not present and inert. A Forever player's settings panel, slash help, launcher menu and key bindings list show no trace of a Retail-only feature.
- **MUST** carry a **per-client feature table** in `docs/ARCHITECTURE.md`, in the section that lists the addon's modules: one row per declared feature (module, page or tab, verb, menu entry, binding), its client, and the file that gates it. An addon with no per-client feature records "all features serve both clients" in its place.

```lua
-- Bad: registered on both clients, then hidden on the one that cannot show it.
local row = O.AddRow(page, { key = "groupFinder", label = L["Group finder"] })
if not NS.Compat.IsRetail() then row:Hide() end

-- Good: declared on the descriptor; the library does not register it on Forever.
{ key = "groupFinder", label = L["Group finder"], clients = { "retail" } },
```

### 5. Per-client seed data

Seeded lists (spells, items, talents, quest and currency ids, and similar) and the actions built on them:

- **MUST** exist as **two lists**, one per client, not one list. The two are `Retail` and `Forever` tables in one file, or a file pair such as `data/Seeds_Retail.lua` and `data/Seeds_Forever.lua`; both are compliant, and the rule is "two lists, picked once", not a file layout.
- **MUST** be **chosen once**, at load or at first use, by `ClientKey()`, into one local the rest of the addon reads. The code that consumes a seed never asks which client it is on.
- **MUST NOT** be a single Retail list filtered at runtime ("skip the ids Forever does not have"). A filter is a guess about what the other client has, and it silently gives Forever a Retail list with holes. A list for a client that has no seed for the feature is **empty by decision** and says so, or the feature is absent (clients-§4).

```lua
-- Bad: one Retail list, filtered.
for _, id in ipairs(SEEDS) do if IsSpellKnown(id) then add(id) end end

-- Good: two lists, picked once.
local SEEDS = (NS.Compat.ClientKey() == "forever") and NS.SeedsForever or NS.SeedsRetail
```

### 6. Tests and smoke

- **MUST** run a dual-client addon's headless suite under **both** kit profiles of the vendored test kit, chosen by the environment variable `KA0S_KIT_CLIENT=retail|forever`, with **retail** the default. The retail profile leaves `WOW_PROJECT_CAMELOT` nil, as Retail does. A suite that passes on one profile and not the other is a failing suite. A per-client feature **MUST** have a test on each profile: present where declared, absent where not.
- **MUST** cover both clients in `docs/smoke-tests.md`: every check names the client it runs on, and a check that applies to one client only says so. A feature absent on a client gets a smoke check that it is **not there**, as well as one that it works on the other.
- **MUST NOT** be marked passed by an agent. In-client smoke is the owner's (testing).

### 7. The Retail-only shape (by decision)

An addon the owner has decided stays Retail-only carries `Retail` in the roster and:

- **MUST** keep one `## Interface:` number and **add** `## AllowLoadGameType: standard` and `## ExcludeLoadGameType: camelot` (toc-file-§3), so that the Forever client never lists it. Both lines are needed: the wiki warns that an allow-list the client does not recognize counts as a match, so the exclude line is the one that holds if the allow line is not understood.
- **MUST NOT** carry a Forever branch, a Forever seed list or a `forever` token: they would be dead code.

### 8. The port-pending shape

An addon that is Retail today and not yet ported carries `Retail (port pending)` and:

- **MUST** keep one `## Interface:` number and **MUST NOT** carry the load-gating lines. Forever players already run some of these addons out of date (PartyFrameEnhanced#15) and a gate would cut them off before the port decides anything.
- **MUST** declare any **new** Retail-only feature it adds with `clients = { "retail" }` (clients-§4), so the port later finds the Retail-only surface already enumerated.
- The audit does not flag the missing dual-client shapes of this row.
- **MUST** leave the state by a port: the port flips the row to `Retail · Forever` (or, on the owner's decision, to `Retail` with the gating lines) in the change that lands it. Each port is its own owner decision.
