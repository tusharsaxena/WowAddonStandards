> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Clients — Retail and WoW Forever

The collection supports **two game clients**: Retail, and WoW Forever (Blizzard's vanilla-era game type, "Camelot"). By default each addon serves both from **one codebase**: one repo, one unsuffixed TOC, one `libs/` tree. There are no separate per-client copies of an addon, and no Classic flavors. This section says which clients exist, how an addon declares the ones it supports, how it asks which one it is on, and how a feature or a seeded list that only one client can have is kept apart from the other. It is the owner's ruling of 2026-11-07, amended by the owner's ruling of 2026-11-10 on single-client addons, and the rules that follow from it are these, which the sections below and skinning-§2 apply:

- **Both clients is the default; single-client is the owner's decision** (owner ruling of 2026-11-10). An addon is built for Retail and WoW Forever unless the owner decides it ships on one client only, which the owner allows when the addon's core does not exist on the other client. A single-client addon is `Retail` (clients-§7) or `Forever` (clients-§9) in the roster, and its README and `docs/ARCHITECTURE.md` record why (clients-§2).
- **A feature is absent, never just hidden, on a client that cannot support it.** A Forever player never sees a Retail-only feature (the group finder, the warband bank, Mythic+, transmog, the Encounter Journal), and a Retail player never sees a Forever-only one.
- **Seed lists are kept per client.** Spells, items, talents and similar seeded data, and the actions built on them, have one list per client. Forever gets its own list, not a filtered Retail one.
- **The default skin is per client** (owner ruling of 2026-11-08): WoW Forever on Forever, Ka0s Default on Retail, answered by the library and never by an addon's own client check (skinning-§2).
- **A Forever data addon is evidence at dev time and optional at runtime** (owner rulings of 2026-11-25). ForeverDB may back a Forever seed check for the server-side facts DB2 lacks (clients-§10), and a Forever feature may read it through `LibKa0s-ForeverDB-1.0` (clients-§11); no player ever needs it installed, and its GPL data never enters a Ka0s repo.

### 1. The supported clients

| Client | Roster token | Detected by (clients-§3) | Identity |
|---|---|---|---|
| Retail (Mainline) | `retail` | `Compat.IsRetail()`, `ClientKey() == "retail"` | `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE`; the current Retail interface number is what the Retail addons ship (toc-file-§3). |
| WoW Forever (Camelot) | `forever` | `Compat.IsForever()`, `ClientKey() == "forever"` | client 1.60.1, build 70790, interface **16001**, `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT == 18`. |

`WOW_PROJECT_CAMELOT` is **nil on Retail**, so an expression that reads it must tolerate nil, and that is one more reason the read lives in one place (clients-§3). A third token, `both`, exists in a feature's declaration (clients-§4) and means "this feature serves both clients"; it is never a client.

Nothing else is supported. The Classic Era, Season of Discovery, Cataclysm Classic and Mists Classic flavors are out of scope, and an addon **MUST NOT** carry code written for them.

### 2. The roster declaration

- **MUST** be declared in the roster: `ADDONS.md`'s **Clients** column holds one of `Retail · Forever`, `Retail`, `Forever` or `Retail (port pending)` for every addon. The column is normative, is the single source of truth that `dev-copilot` and the audit read, and records what the addon **ships today** (ADDONS.md, *The Clients column is normative input to an audit*). Do not restate the addon list here or anywhere else.
- **MUST** flip the row in the same change that lands the port. An addon that gains Forever support and keeps its `Retail (port pending)` row, or the reverse, is a deviation.
- **MUST** match the TOC to the row (toc-file-§3): `Retail · Forever` ships `## Interface: <retail>, <forever>`; `Retail` ships one Retail number plus the two Retail load-gating lines; `Forever` ships one Forever number plus the two Forever load-gating lines; `Retail (port pending)` ships one number and no gating line.
- **`Retail · Forever` is the default.** A single-client value, `Retail` or `Forever`, is set only by the owner's decision, and the owner allows it when the addon's **core** does not exist on the other client (a feature or two that one client lacks is clients-§4's job, not a reason to drop a client). A single-client addon **MUST** record that reason in two places: its README, in the supported-clients sentence of the description (documentation-§1), and its `docs/ARCHITECTURE.md`, in the per-client feature table's place (clients-§4). A single-client row with no recorded reason is a deviation.
- The audit applies a per-value check set, and the table in ADDONS.md is where it is defined. A `Retail (port pending)` addon is not flagged for a missing dual-client shape, but **is** flagged for a new Retail-only feature added with no declaration (clients-§4), because that is how a pending port grows harder.

### 3. Detection goes through Compat, and only there

- **MUST** ask which client it is on **only** through `LibKa0s-Compat-1.0`: `IsForever()`, `IsRetail()` and `ClientKey()`, which answers `"retail"`, `"forever"` or nil (an unknown client). An addon reaches them as `NS.Compat.IsForever()` and so on, routed from `core/Compat.lua` (compat, library-stack-§7). The library reads `WOW_PROJECT_ID` on each call, against the project constants read at that call, and owns the nil-tolerance of `WOW_PROJECT_CAMELOT` (v2.113.0: the text said "once", which the code never did).
- **SHOULD** read the player's specialization and the role it plays through `LibKa0s-Role-1.0` (from `LibKa0s v1.95.0`, library-stack-§7), adopted on the addon's own schedule: `Spec()`, `SpecsForClass(classFile)`, `Groups()` and `Resolve(store)`, which answers `role, source, detail`, with `SetOverride(store, role)` for the player's own choice. On WoW Forever every class has one specialization, so the spec API's role is class-wide and wrong for every hybrid; `Resolve` asks the talent group with the most points spent there, and the spec API on Retail.
- **MUST NOT** read `WOW_PROJECT_ID`, `WOW_PROJECT_MAINLINE`, `WOW_PROJECT_CAMELOT` or `WOW_PROJECT_CLASSIC` outside `LibKa0s-Compat-1.0`, and **MUST NOT** decide the client from an interface number (`select(4, GetBuildInfo())`, a comparison against `16001` or a Retail patch number). The interface number changes every patch and says nothing about the game type.
- **MUST NOT** treat `== WOW_PROJECT_MAINLINE` as meaning "a modern client". Forever carries modern APIs and Retail carries old ones; the question an addon needs answered is "is this Retail" or "is this Forever", and `ClientKey()` answers it.
- **MAY** use **feature detection** (`if C_Foo and C_Foo.Bar then`) for one specific API gap **inside a feature the client supports**: one function missing from one build, tolerated at its call site or in the compat family. Feature detection **MUST NOT** decide whether a whole feature exists; that is a declaration (clients-§4).
- **SHOULD NOT** branch on the client at all in feature code where a declaration or a per-client table does the job. A client branch in feature code is a smell, and the compat family is where one belongs (compat).

### 4. Per-client features are declared and gated at registration

A **feature** is a module, a settings page or tab, a slash verb, a launcher menu entry, a key binding, or an event registration. A feature that exists on only one client:

- **MUST** be **declared** with the client it serves, in the registration call itself: the `clients` field of the library's descriptor, `clients = { "retail" }`, whose tokens are `retail`, `forever` and `both` (clients-§1). A feature with **no** declaration serves both clients.
- **MUST** be **gated at registration**: through that descriptor field where the library registers the feature (options, slash, launcher, bindings), and through `Compat.ForClient(clients)` where the addon registers it itself (a module's `OnInitialize`, an event registration). `ForClient` returns true when the running client is among `clients`, so a gated registration is one `if` that either runs the registration or does not.
- **MUST NOT** be registered and then hidden. Hiding, graying out or disabling a feature on the client that cannot support it at runtime (a `Hide()`, a `SetEnabled(false)`, a "not available on this client" row) **does not meet the rule**: the feature must be absent, not present and inert. A Forever player's settings panel, slash help, launcher menu and key bindings list show no trace of a Retail-only feature.
- **A key binding is the one feature registration cannot fully gate (note, v2.113.0).** The client lists every `<Binding>` in a root `Bindings.xml` in its Key Bindings panel on every client that loads the addon, whatever the addon registers. Gating the binding's button, its `NS.BINDINGS` row and its label at registration keeps a Retail-only key from doing anything on WoW Forever, but its line can still list there. That gap is the client's, not the addon's: an addon that gates everything it registers is not graded for the line. A client-suffixed bindings file that keeps the line off the other client is not yet a rule of this standard, so an addon that ships one records it as a documented deviation (documentation-§3) until a per-client bindings shape is designed (open-evolutions).
- **MUST** carry a **per-client feature table** in `docs/ARCHITECTURE.md`, in the section that lists the addon's modules: one row per declared feature (module, page or tab, verb, menu entry, binding), its client, and the file that gates it. An addon with no per-client feature records "all features serve both clients" in its place. A single-client addon (`Retail` or `Forever`) declares no per-client feature, and records in its place "all features serve <client>; the addon is <client>-only by owner decision", followed by the reason (clients-§2).

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

How each list is derived from its own client's game data, and re-validated when the client moves, is clients-§10.

### 6. Tests and smoke

- **MUST** run a dual-client addon's headless suite under **both** kit profiles of the vendored test kit, chosen by the environment variable `KA0S_KIT_CLIENT=retail|forever`, with **retail** the default. The retail profile leaves `WOW_PROJECT_CAMELOT` nil, as Retail does. A suite that passes on one profile and not the other is a failing suite. A per-client feature **MUST** have a test on each profile: present where declared, absent where not.
- **MUST** run a single-client addon's suite under **its own client's** profile only: a `Retail` or `Retail (port pending)` addon the default profile, a `Forever` addon `KA0S_KIT_CLIENT=forever` on every run, the commit gate included (testing). A `Forever` addon run on the default profile is testing a client it does not ship on.
- **MUST** cover both clients in `docs/smoke-tests.md` for a dual-client addon: every check names the client it runs on, and a check that applies to one client only says so. A feature absent on a client gets a smoke check that it is **not there**, as well as one that it works on the other. A single-client addon's smoke file covers its one client, and a gated (`Retail` or `Forever`) one adds a check that the other client does **not** list it in its AddOns list.
- **MUST NOT** be marked passed by an agent. In-client smoke is the owner's (testing).

### 7. The Retail-only shape (by decision)

An addon the owner has decided stays Retail-only carries `Retail` in the roster and:

- **MUST** keep one `## Interface:` number and **add** `## AllowLoadGameType: standard` and `## ExcludeLoadGameType: camelot` (toc-file-§3), so that the Forever client never lists it. Both lines are needed: the wiki warns that an allow-list the client does not recognize counts as a match, so the exclude line is the one that holds if the allow line is not understood.
- **MUST** record why it is Retail-only in its README and its `docs/ARCHITECTURE.md` (clients-§2, clients-§4).
- **MUST NOT** carry a Forever branch, a Forever seed list or a `forever` token: they would be dead code.
- **MUST** carry `docs/midnight-quirks.md` (the Retail catalog, client-quirks-§1) and **no** `docs/forever-quirks.md`, which its documentation map records as *Not applicable* (documentation-§3). A `Retail (port pending)` addon carries the same one file until its port lands, and the port adds `docs/forever-quirks.md` in the change that flips the row.

### 8. The port-pending shape

An addon that is Retail today and not yet ported carries `Retail (port pending)` and:

- **MUST** keep one `## Interface:` number and **MUST NOT** carry the load-gating lines. Forever players already run some of these addons out of date (PartyFrameEnhanced#15) and a gate would cut them off before the port decides anything.
- **MUST** declare any **new** Retail-only feature it adds with `clients = { "retail" }` (clients-§4), so the port later finds the Retail-only surface already enumerated.
- The audit does not flag the missing dual-client shapes of this row.
- **MUST** leave the state by a port: the port flips the row to `Retail · Forever` (or, on the owner's decision, to `Retail` with the gating lines) in the change that lands it. Each port is its own owner decision.

### 9. The Forever-only shape (by decision)

An addon the owner has decided ships on WoW Forever only, because its core does not exist on Retail (clients-§2), carries `Forever` in the roster and:

- **MUST** keep one `## Interface:` number, Forever's (`16001`, clients-§1), and **add** `## AllowLoadGameType: camelot` and `## ExcludeLoadGameType: standard` (toc-file-§3), so that the Retail client never lists it. This is clients-§7's pair with the game types swapped, and both lines are needed for the same reason: an allow-list the client does not recognize counts as a match, so the exclude line (a directive from client 12.0.0, which every live Retail client is past) is the one that holds on Retail.
- **MUST** record why it is Forever-only in its README and its `docs/ARCHITECTURE.md` (clients-§2, clients-§4).
- **MUST NOT** carry a Retail branch (an `IsRetail()` read, a `ClientKey() == "retail"` test), a Retail seed list or a `clients = { "retail" }` declaration: they would be dead code. A seeded data file is the Forever list alone (a `<Name>_Forever.lua` file, clients-§5), not one half of a pair.
- **SHOULD NOT** read the client at all: on its one client the answer is fixed. The library still answers per client where it decides (the default skin, skinning-§2, is WoW Forever here), and that is the library's read, not the addon's.
- **MUST** run its suite as Forever and cover only Forever in its smoke file, plus the not-listed-on-Retail check (clients-§6).
- **MUST** carry `docs/forever-quirks.md` (the Forever catalog, forever-quirks-§1) and **no** `docs/midnight-quirks.md`, which is a retired name in a Forever-only addon (documentation-§3): an addon that became Forever-only renames its file with `git mv` and keeps its own section. A dual-client (`Retail · Forever`) addon carries both files.

### 10. Validating seed data against the client's own DB2 (wago.tools)

clients-§5 says a seed list exists once per client. This subsection says where each list comes from and how it is kept current. The client ships its game data as DB2 tables, and what an addon seeds (spells, the auras they apply, who can cast them, items and what they do) is rows in those tables. A list kept by hand, from memory, a wiki or another addon's list, drifts a patch at a time and nothing reports it. The rules here are **SHOULD**: an addon that ships a seed list **SHOULD** derive it, or re-validate it, against its client's DB2 as below. An addon that does not records in `docs/ARCHITECTURE.md`, where it describes the seed, how the list is maintained instead.

**What wago.tools is.** A community site, not Blizzard's, that extracts the client's data for every build of every product Blizzard ships and serves it over HTTP. The parts this subsection relies on, each checked live on 2026-11-15:

| URL | What it returns |
|---|---|
| `https://wago.tools/api/builds` | JSON keyed by product. Each product holds its builds newest first, each with `version` (`12.1.5.70783`), `created_at` and `is_bgdl` (a background-download build, not yet live). |
| `https://wago.tools/db2/<Table>/csv?build=<version>` | One DB2 table of that build as CSV, with a header row. A table the build does not have answers HTTP 400 with `{"errors":"Table not found."}`. |
| `https://wago.tools/db2` | The table browser: every table name, and a page per table for reading rows by hand. |
| `https://wago.tools/db2-diff`, `https://wago.tools/builds` | Build-to-build comparison in the browser. |
| `https://wago.tools/hotfixes` | The hotfixes Blizzard pushed after a build shipped. |
| `https://wago.tools/api/files` | The listfile, file data id to path, as one JSON object (about 144 MB). |

The two products this standard uses are `wow` (Retail live; `12.1.5.70783` on 2026-11-15) and `wowf` (WoW Forever; `1.60.1.70938` on 2026-11-15). The API lists others: `wowt` (the Retail PTR), `wowxptr`, `wow_beta`, `wowlivetest`, `wowz`, `wow_cn_beta`, and the Classic flavors, which clients-§1 puts out of scope. A reader takes the product list from the API and does not assume it.

Three things about the CSV that a reader has to allow for. Column headers carry a locale suffix (`Name_lang`, `NameSubtext_lang`). Array fields are flattened with an index (`Attributes_0` to `Attributes_16`, `ImplicitTarget_0`, `ImplicitTarget_1`). A field with no known name carries a build-specific placeholder (`Node__Field_12_0_0_63534_001` in Retail's `SpellEffect`). So a reader addresses a column by its header name and never by its position. And a URL with no `?build=` does **not** mean live Retail: on 2026-11-15 the build-less `SpellName` CSV was byte-identical to the PTR's (`wowt` `12.1.7.70892`), not to live `12.1.5.70783`'s.

**Which table answers which question.** Every table below resolved for both products on 2026-11-15, except the two marked Retail-only, which answer HTTP 400 on the Forever build.

| Question | Tables (the columns that answer it) |
|---|---|
| What is this spell called, and which rank is it? | `SpellName` (`Name_lang`); `Spell` (`NameSubtext_lang`, the rank text, e.g. `Rank 3`). |
| What does it do: which aura, which trigger, on whom? | `SpellEffect` (`Effect`, `EffectAura`, `EffectTriggerSpell`, `EffectMechanic`, `ImplicitTarget_0`/`_1`, `DifficultyID`, `SpellID`). |
| Which mechanic is it (stun, root, snare, fear, …)? | `SpellCategories` (`Mechanic`), named by `SpellMechanic`. |
| Is it passive, and what are its flags? | `SpellMisc` (`Attributes_0` to `Attributes_16`; `Attributes_0` bit `0x40` is passive). |
| What is its cooldown? | `SpellCooldowns`. |
| Which class's spell family is it in? | `SpellClassOptions` (`SpellClassSet`, `SpellClassMask_0` to `_3`). |
| Who can learn it? | `SkillLine` and `SkillLineAbility` (`SkillLine`, `Spell`, `ClassMask`, `SupercedesSpell`). |
| Which specialization gets it? | `ChrSpecialization`; `SpecializationSpells` (**Retail-only**). |
| Which talent grants it? | Retail: `TraitDefinition`, `TraitNodeEntry`, `TraitNodeXTraitNodeEntry`, `TraitNode`, `TraitTreeLoadout` (the last **Retail-only**). Forever: `Talent` (`TabID`, `ClassID`, `SpellRank_0` to `_8`) and `TalentTab`. |
| Which item is it, and what does using it do? | `Item`, `ItemSparse`; `ItemXItemEffect` to `ItemEffect` for the spell an item casts. |

**How to use it.** A run that derives or re-validates a seed list:

- **SHOULD** pin **one build per run**, resolved once from the builds API or passed explicitly, and record it. Every table a run reads comes from that one build, and every request names it with `?build=`, so that the build-less default (the PTR, above) can never leak into a list.
- **SHOULD** run against the **client's own product**: `wow` for the Retail list and `wowf` for the Forever list. One client's list is never derived by filtering the other's (clients-§5); a spell id the two share is a fact each client's own tables establish separately.
- **SHOULD** cache each download per build, outside what the addon packages and git-ignored (under the generator's own folder in `tools/`, which layout places there and `.pkgmeta` ignores), and **SHOULD** stream the large tables rather than read them in as one string: Retail's `SpellEffect` was 57 MB and its `SpellMisc` 46 MB on 2026-11-15 (Forever's, 3.9 MB and 3.1 MB).
- **SHOULD** freeze each run that changes, or confirms, a shipped list as a dated bundle under the addon's `docs/` (not packaged, packaging; never edited after the fact, as audit-review-history's bundles are not), holding: the raw tables the run actually read as `*.csv.gz`; a `SOURCES.md` naming the product, the build, the fetch time and every URL; the derived data; a `DIFF` against what the addon ships; the `RULINGS` applied; and a hand-written `ANALYSIS.md`. A bundle **SHOULD** be enough to replay the derivation offline, from its own `raw/`, with no network and no cache. ForeverDB evidence is the one exception: its bundle keeps no `raw/` and replays by its pinned tag (*A second evidence source for Forever: ForeverDB*, below).
- **SHOULD** take the run's date as an **argument**, never from the clock. The caller names the bundle, and a run that dates itself cannot be replayed under the name it was filed under.
- **SHOULD** treat DB2 as proposing and a human as deciding. Every candidate a run proposes gets a ruling, accepted or rejected, with a reason, and the rulings are stored as data in the repo beside the generator. A re-run on a new build then reproduces the shipped list from the rulings and surfaces only what is new. A generator never ships a candidate nobody ruled on.
- **SHOULD** fail loudly when the derivation comes up thin: a run checks that ids it must find (sentinels chosen from the game, not from its own output) are present, and exits non-zero when they are not, rather than emitting a short list that reads as a plausible diff (layout, *A non-Lua generator sits outside the green gate*).
- **SHOULD** send an identifying `User-Agent` (`-A "<addon>-seed-check"`, or the header set in the script). The site answers HTTP 403 to Python urllib's default agent, so in practice a run without one fetches nothing. This is identification, not a workaround for a limit, and the cache above is what keeps a run from fetching a table twice; a run **SHOULD NOT** re-download what it already holds for the pinned build.
- **SHOULD** re-run after each major patch, and whenever the builds API shows a live build for the client newer than the one the last bundle recorded.

**What DB2 cannot tell you.** A run reads these limits before it accepts a diff:

- **Some auras have no table edge from the cast.** An aura applied by a server-side spell script, by a summoned creature or totem, or by an area trigger is not linked from the cast's `SpellEffect` rows. A derivation that follows only `EffectAura` and `EffectTriggerSpell` misses it.
- **DB2 says what is possible, not what a player gets.** A spell a class can learn is not a spell a given spec takes, and a talent is not a pick. Which ids a spec actually casts or receives is a combat log's answer, not DB2's.
- **Rows have difficulty variants.** `SpellEffect`, `SpellMisc` and `SpellCategories` carry `DifficultyID`; the base row is `DifficultyID` `0`, and a reader that does not filter on it double-counts.
- **Forever keeps each vanilla rank as its own id.** Frostbolt is eleven spell ids on the Forever build (`Rank 1`, id `116`, to `Rank 11`, id `25304`), each its own row. A Forever list carries every rank, or says why it carries one.
- **Names are not unique.** On the same build forty-seven `SpellName` rows were named `Frostbolt`, and only those eleven carry a rank; the rest are copies other casters (NPCs among them) use, and variants. A name match is a candidate, never a conclusion: the id is what is shipped, and the effect and learn rows are what confirm it.
- **Live data can move after a build.** Blizzard hotfixes rows after a build ships (the hotfixes page, above). A ruling that turns on one row's value is checked there when the result surprises.

**A second evidence source for Forever: ForeverDB (v2.121.0).** DB2 is the client's own data, so it knows nothing the server supplies: which creatures exist and where they spawn, who trains what, which vendor sells an item, who gives and ends a quest, and which world objects there are. The collection has hit that wall three times: a damage meter's Forever training-dummy list, a gear addon's quest NPCs and a profession addon's trainer positions, each a candidate no DB2 table could rule on. ForeverDB (<https://github.com/foreverfraddons/forever-db>, CurseForge `forever-db`) is a load-on-demand data addon for WoW Forever, rebuilt about twice a day from classic-era server dumps (QuestieDB, VMaNGOS, cMaNGOS, pfQuest) merged with in-game recordings, and it carries exactly those facts: NPCs with their levels, rank and faction, items, quests with their givers and enders, drops with chances, vendors with the prices seen, map spots and trainers. Each build is an immutable git tag, `vYYYY.MM.DD.N`, whose TOC `## Version` is the tag without its `v`. Its data is **GPL-3.0**, and every Ka0s repo is MIT. A contract that uses it:

- **MAY** name ForeverDB as a **secondary** evidence source for the `forever` flavor, and for server-side facts only: creatures and their spawns, trainers, vendors, quest givers and enders, and objects.
- **MUST** keep DB2 primary for everything DB2 has. ForeverDB never overrides a DB2 answer; where the two disagree, the result is a flag for a ruling, not an answer.
- **MUST** pin **one ForeverDB tag per run** and record it, with its commit sha. The tag is immutable, so the tag is the build pin for this source, as `?build=` is for wago.tools.
- **MUST** treat ForeverDB as **evidence, not truth.** Its sources are classic-era server dumps merged with Forever data, and Forever is not the classic era, so a mismatch between it and a shipped value is a candidate for a human ruling, never an automatic apply. A contract **MAY** record a standing ruling of its own on how much to trust it (one profession addon's owner ruled "trust the sources (the 1.12 dump) over owner smoke" for its trainers); that ruling is the contract's and is not a collection rule.
- **MUST NOT** copy ForeverDB's rows into the repo, the bundle or a test fixture: GPL data does not enter an MIT repo. The bundle stores a `SOURCES.md` (the tag, its commit sha, the sha256 of every file read, the fetch date, the URLs and, when one was read, the version of the local install), per-id **verdicts** (`found`, `missing`, `name-mismatch`, `position-off`, each with the shipped value) and the hand-written `ANALYSIS.md`. A verdict **MAY** quote the one field it compares, such as an NPC's name, which is a fact rather than a copy of the database. A fixture uses invented values in ForeverDB's shape (made-up names, ids of 900000 and up, made-up coordinates).
- **MUST NOT** keep a `raw/` of ForeverDB files, and **SHOULD** replay by re-fetching its pinned tag, which cannot move. This is the one exception to the bundle rule above: a ForeverDB-backed bundle may not keep the rows, so its tag is its replay source. The `dev-copilot` plugin's `scripts/foreverdb.py` resolves the newest tag (`status`) and fetches, verifies and caches one (`fetch --tag <tag> --date <date>`, from GitHub or from a local install, outside every repo); `/dev-copilot:validate-seeds` takes the pin as `--foreverdb <tag>`.
- **MUST NOT** read ForeverDB for the `retail` flavor. A Retail row that names it is a stop.

ForeverDB at runtime, as a player-optional data addon a feature reads, is clients-§11. Using it here, at dev time, needs nothing from a player.

**Reference implementation (in the collection):** the aura-tracking addon's spell-research pipeline, a Python 3 generator under its `tools/spell-research/` with its own `README.md`. One script derives the crowd-control buckets from `SpellCategories.Mechanic` and `SpellEffect.EffectMechanic`, against a pinned build, with a cache in its own git-ignored `.cache/`, a `--bundle docs/spell-research/<date>` freeze, a `--replay` that re-derives a past run from that bundle's `raw/*.csv.gz` alone, and a coverage gate on sentinel ids. A second script derives that addon's other Forever categories from four candidate sources and applies a rulings file (JSON, one entry per candidate key holding `ruling`, `accept` or `reject`, and `reason`) so that every candidate is decided once and re-runs show only what is new. A Retail re-validation run of the same shape is being added. The loop itself, newest-build check, freeze, derive, rule, apply and gate, is `/dev-copilot:validate-seeds`, which reads each repo's own `docs/validate-seeds.md` contract; each repo keeps its own scripts, and extracting their shared download, cache and Lua-reading code into the plugin is open (LibKa0s#91, closed 2026-11-16, and its follow-up dev-copilot#1; open-evolutions).

### 11. Optional runtime data addons

An **external data addon** is a separately installed addon that holds game data and no behavior of its own, for other addons to read: ForeverDB (clients-§10) is the first the collection uses, for WoW Forever's drops, vendors, quests, NPCs, map spots and trainers. It is a suite in library-stack-§6's sense (a separate addon with its own lifecycle, never a library the addon vendors), so every rule there holds, and these add what is particular to data: its size, its license and the client it serves. A Ka0s addon whose feature uses one (owner rulings of 2026-11-25, LibKa0s#105, Ka0sAddonsCommonTasks `docs/2026-11-25-SEEDS_AND_FOREVERDB/`):

- **MUST** read it only at runtime, through `LibKa0s-ForeverDB-1.0` (from `LibKa0s v1.114.0`), and **MUST NOT** wire it itself: no `ForeverDB` global read, no `LoadAddOn("ForeverDB")` call and no table walk in the addon's own code. The adapter is the one place that knows the data addon's shape; it answers plain tables or nil, never errors on a missing, old or reshaped install, and hands out fresh tables, never the data addon's own rows.
- **MUST** list it in `## OptionalDeps`, **MAY** list it under `.pkgmeta`'s `optional-dependencies` (CurseForge slug `forever-db`) so that the project page shows the relationship, and **MUST NOT** list it in `## Dependencies` or under `.pkgmeta`'s `required-dependencies` (library-stack-§6, anti-pattern #13). A player never needs it installed. ForeverDB's own README tells a consumer to make it required; the collection deliberately does not.
- **MAY** also use it at dev time, as seed-validation evidence (clients-§10). That use needs nothing from a player and reads nothing at runtime.
- **MUST** load it only when a feature first asks, never at login: the adapter's `Available()` is the only call that loads it, the first lookup is what calls `Available()`, and no file-load, `OnInitialize`, `OnEnable` or login-event path makes a lookup. ForeverDB is about 12 MB on disk, and a player who never opens the feature never pays for it.
- **MUST** work unchanged without it. The feature reads nothing, adds nothing and errors nowhere when the data addon is absent, disabled or fails to load, and its tooltip or settings row says the feature needs ForeverDB. This is not anti-pattern #115: the client can support the feature, and a missing optional addon is the player's choice, not the client's.
- **MUST** gate the feature on Forever at registration (clients-§4): `clients = { "forever" }` on its descriptor, or `Compat.ForClient`, so that on Retail it is absent, not present and inert. The adapter's own Retail answer, `false, "client"`, is the backstop, not the gate.
- **MUST NOT** vendor or copy its data, test fixtures included (clients-§10's licensing rule). A suite tests the feature on the kit's `mock_foreverdb` fake (its `present`, `missing`, `loadfails` and `reshaped` presets), whose invented rows carry ForeverDB's shape, plus a Retail-profile case that proves the feature absent.
- **MUST** record what the data addon costs on the performance page of the addon that loads it, `docs/performance.md` (documentation-§3): its size on disk, that the load happens on first use rather than at login and, once measured, the memory it adds. Until a capture measures that memory the page says it is unmeasured (open-evolutions).

ForeverDB's two sibling addons, `ForeverDB_Full` and `ForeverDB_Locales`, are not read by the adapter's first version; reading them is a later minor of the library (open-evolutions).
