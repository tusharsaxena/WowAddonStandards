> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Localization

Localization is two-directional. Sections 1–3 govern the addon's **output** — its own text translated
into the player's language via `NS.L`. Section 4 governs the addon's **input** — the game's data
arrives *already* in the player's language, so any logic that branches on a localized display string
silently breaks on every client whose locale differs from the author's. Both directions are mandatory.
Section 5 fixes the **source dialect** every English string in the collection is written in.

### 1. Module shape

```lua
-- locales/enUS.lua  (loads always)
local addonName, NS = ...
NS.L = setmetatable({}, { __index = function(_, k) return k end })
local L = NS.L
L["Scale"] = "Scale"
L["Reset all settings to defaults?"] = "Reset all settings to defaults?"
```

```lua
-- locales/deDE.lua (locale-gated)
if GetLocale() ~= "deDE" then return end
local addonName, NS = ...
local L = NS.L
L["Scale"] = "Skalierung"
```

- **MUST** export `NS.L` with a metatable that returns the key on miss. Replaces AceLocale strict mode (which hard-errors on missing keys) and is industry-aligned (the major aura framework, party-cooldown trackers, modular QoL addons, and the collection all do this).
- **MAY** use AceLocale-3.0 in non-strict mode if you prefer it. Strict mode is forbidden.
- **MUST** gate non-enUS files with `if GetLocale() ~= "<locale>" then return end` at top of file. (Loading every locale for every player — a QoL-addon anti-pattern — is wasteful.)
- **SHOULD** put derived-key aliases in `locales/PostLoad.lua`: `L["Use original"] = L["Original"]`. Translators don't duplicate work.
- **SHOULD** route every user-facing string through `NS.L` — settings labels and tooltips, chat lines, slash help, error text. This is **the routing SHOULD**, and localization-§3 states the two **terminal** compliant states it can end in. Note that concatenating a routed fragment with an unrouted one (`L["Scale"] .. ": " .. v`) leaves the sentence unroutable for a translator, so route the whole sentence with a format placeholder instead.

### 2. Source-of-truth keys

- **MUST** use the English string itself as the key. Reasons: missing-key fallback yields English; keys are self-documenting; no separate string-table maintenance.
- **SHOULD NOT** use opaque IDs like `L.STR_42`.

### 3. Coverage

- **MUST** at minimum ship `enUS.lua`. Any additional locale is opt-in.
- **MUST NOT** rely on Blizzard `_G` strings as a substitute for a locale module. (Leaning on `_G` strings is acceptable for a tiny utility addon but it should still ship a locale module shell.)

**The routing SHOULD has two terminal compliant states.** Both MUSTs above are unconditional — the
`NS.L` seam is exported (localization-§1) and `enUS.lua` ships — and neither is affected by anything
here. What follows governs only localization-§1's routing SHOULD.

An addon is **compliant, and the matter is closed**, in either of these states:

1. **Routed.** User-facing strings go through `NS.L`.
2. **English-only, recorded.** The addon has decided it ships English only, and that decision is a row
   in its `## Documented deviations` register (documentation-§3) citing `localization-§1`, with a
   **re-check trigger**: *the first non-English locale file added to `locales/`*.

An addon in state 2 is **compliant, not open**. An audit reads the register first, records the row as
accepted with its id, and **MUST NOT** re-file the routing SHOULD against it (audit-review-history).

The reason this is written down: four of eight addons in the collection independently reached state 2
and met both MUSTs while leaving the SHOULD open, so four audits filed the same row and four
remediation plans deferred it. A SHOULD that a majority of adopters decline the same way, for the same
reason, is mis-specified — the decline is the answer, and it needs a place to be final. The register row
is that place, and the re-check trigger is what stops "English-only" from silently outliving the
decision: the moment a `deDE.lua` lands, the row's trigger has fired and the routing work is owed.

**A recorded decision is not a license to leave the seam unused.** Strings the addon *does* route stay
routed, and `enUS.lua` **MUST NOT** accumulate keys nothing reads — a dead key is a claim about
coverage that is not true (documentation-§5). Delete it or wire it.

### 4. Match game data on IDs, not localized strings

The game hands you spell names, item names, class/race names, zone names, and unit names **already
translated into the player's locale**. Comparing any of them against a hardcoded English string makes
the branch true only on an enUS client and dead everywhere else — a bug that never reproduces for an
English-speaking author and silently disables the feature for every deDE/frFR/ruRU/koKR/zhCN/… player.

- **MUST** identify game entities by their stable numeric ID or non-localized token — **never** by a
  localized display string. The canonical keys:

  | Entity | Match on (stable) | Never on (localized) |
  | --- | --- | --- |
  | Spell / aura | `spellID` (number) | the `name` field of `C_Spell.GetSpellInfo` / `UnitAura` / `AuraUtil` |
  | Item | `itemID` | the item name |
  | Class | `classFile` token — 2nd return of `UnitClass`, or `UnitClassBase` — `"WARRIOR"` | the 1st return, `"Warrior"` |
  | Race | race token — 2nd return of `UnitRace` | the 1st return |
  | Faction | `"Alliance"`/`"Horde"` token — 2nd return of `UnitFactionGroup` | `UnitFactionGroup`'s 1st return |
  | Unit / NPC | `creatureID` parsed from `UnitGUID` | `UnitName` |
  | Zone / instance | `uiMapID` (`C_Map.GetBestMapForUnit`) or `instanceID` (8th return of `GetInstanceInfo`) | `GetZoneText` / `GetRealZoneText` / `GetSubZoneText` |
  | Fixed set | an `Enum.*` member | any string spelling of it |

- **MUST**, when logic genuinely has to match Blizzard-generated combat-log or error text, compare against
  the FrameXML **GlobalString constant** (`_G.ERR_*`, `SPELL_FAILED_*`, `_G.COMBATLOG_*`), which is itself
  localized — **never** hardcode that string's English value.
- **SHOULD** resolve a name for *display only* from the ID (`C_Spell.GetSpellInfo(spellID).name`), never
  the reverse. IDs flow to names; names never flow back into logic.
- **MUST NOT** call an ID-returning API with a localized **name** argument (e.g. `C_Spell.GetSpellInfo("Power
  Word: Shield")`). Pass the `spellID`.

```lua
-- WRONG — dead on every non-enUS client
if C_Spell.GetSpellInfo(spellID).name == "Power Word: Shield" then ...
local _, _, class = ...; if UnitClass("player") == "Priest" then ...
if GetRealZoneText() == "Orgrimmar" then ...

-- RIGHT — locale-independent
local PWS = 17          -- spellID
if spellID == PWS then ...
local _, classFile = UnitClass("player"); if classFile == "PRIEST" then ...
if select(8, GetInstanceInfo()) == 1637 then ...   -- Orgrimmar instanceID
```

**Uppercase tokens are the fix, not the bug.** `classFile == "PRIEST"`, `Enum.PowerType.Mana`, unit
tokens (`"player"`, `"target"`), and event names (`"UNIT_AURA"`) are non-localized Blizzard identifiers,
identical on every client — matching on them is correct and required. Only *localized display text* is
forbidden.

### 5. US English is the source dialect

Every English word a Ka0s addon **authors MUST use US English spelling** — never British. This is not
a preference expressed once in a style note; it is a rule an audit checks, and it holds across
**every** surface the addon writes:

- locale keys and their `enUS` values (`locales/enUS.lua`, localization-§1/§2);
- everything the player reads — chat and console output, options labels, descriptions and tooltips,
  slash help text, window titles, button captions;
- prose in `README.md` and every file under `docs/` (documentation);
- **code**: comments, and identifiers — module names, fields, functions, settings keys, bus message
  names, perf bucket names (naming-cheatsheet).

| Use (US) | Never (British) |
| --- | --- |
| `color`, `colored`, `coloring`, `colorize` | `colour`, `coloured`, `colouring`, `colourise` |
| `gray` | `grey` |
| `behavior` | `behaviour` |
| `center`, `centered` | `centre`, `centred` |
| `canceled`, `canceling` | `cancelled`, `cancelling` |
| `initialize`, `normalize`, `serialize`, `organize`, `optimize`, `capitalization` (`-ize`/`-ization`) | `initialise`, `normalise`, `serialise`, `organise`, `optimise`, `capitalisation` (`-ise`/`-isation`) |
| `analyze`, `catalog`, `dialog`, `defense`, `license`, `favor`, `labeled`, `traveled`, `fulfill` | `analyse`, `catalogue`, `dialogue`, `defence`, `licence`, `favour`, `labelled`, `travelled`, `fulfil` |

Three reasons this is a MUST rather than taste:

1. **The game's own API is US English** — `SetTextColor`, `GRAY_FONT_COLOR`, `Settings.OpenToCategory`.
   A British-spelled identifier sits one letter from the Blizzard symbol beside it, so mixed dialects
   turn `grep -r color` into a search that misses half the call sites it exists to find.
2. **One dialect makes the collection greppable as a unit** — a rename, an audit, or a locale sweep
   across every Ka0s addon is one pattern, not two.
3. **`enUS` is the base locale** (localization-§3) and the metatable fallback every uncovered locale
   renders through (localization-§1), so its strings are what most players actually see.

- **A spelling fix in a locale key is a key change.** Keys *are* the English string (localization-§2),
  so correcting `L["Bar colour"]` → `L["Bar color"]` **MUST** update that key in **every**
  `locales/*.lua` file and at every call site **in the same change**. A missed translation file does
  not error — the metatable silently falls through and renders the raw English key on that client,
  which looks like a missing translation rather than a typo.

**Exceptions — reproduce these verbatim; "correcting" them is the bug:**

- **Blizzard and third-party symbols** — API names, GlobalString constants (`_G.ERR_*`), event names,
  atlas/texture paths, `Enum.*` members, and library names (`LibStub("AceGUI-3.0")`). These are
  identifiers, not prose, and a "fixed" one simply does not resolve.
- **A `locales/enGB.lua` translation** **MAY** carry British spellings — that is exactly what a locale
  file is for. `enUS` remains the source of truth; enGB is a translation of it like any other.
- **Quoted external text** — an upstream error string, a third-party doc, a changelog line, or research
  evidence quoted for the record keeps its original wording.
- **Proper nouns already published** — an addon name, repo name, or CurseForge slug keeps its spelling;
  renaming a published identifier is a breaking change, not a spelling fix.

#### The canonical list

The table above is prose. People read it; nothing runs it. Every attempt in this collection to run it
anyway has produced a **private** list — LibKa0s's six substrings in `tests/test_prose.lua`,
AbsorbTracker's whole-word map in `tests/test_docs.lua` — and a private list is a coverage claim that
nobody outside that repo can check. Two of LibKa0s's six entries are not in the table above at all,
and its gate has stayed green for months while `CANCELLED` shipped in chat text a player reads. That
is `testing-§12`'s failure mode — a check that reads as coverage and provides none — sitting inside
the gate for this very section. So the list is published here, once, and every mechanical gate
**MUST** use it **whole**.

There are two lists because one cannot do the job. `BRITISH` holds lowercase **substrings**, matched
case-insensitively, so a single entry covers a word's whole family: `colour` catches *coloured*,
*colourise* and *colours*; `normalis` catches *normalise*, *normalised* and *normalisation*. That
economy is also the trap, because a few correct US words contain one of those substrings — *analysis*
contains `analys`, *organism* contains `organis`, *specialist* contains `specialis`, *programmer*
contains `programme`. `ALLOWED` names them.

```lua
-- localization-§5 · US English is the source dialect. Copy BOTH lists whole.
-- BRITISH: lowercase substrings, matched case-insensitively.
-- ALLOWED: correct US words that contain a BRITISH substring; removed as WHOLE WORDS first.

local BRITISH = {
  -- -our → -or
  "colour", "behaviour", "favour", "honour", "neighbour", "armour", "flavour",
  "labour", "rumour", "humour", "endeavour", "rigour", "vigour", "saviour",
  -- -re → -er
  "centre", "centring", "metre", "fibre", "calibre", "theatre", "manoeuvre",
  -- -ce → -se
  "defence", "licence", "offence", "pretence", "practis",
  -- -ise / -isation → -ize / -ization, and the -yse verbs
  "initialis", "normalis", "generalis", "specialis", "optimis", "customis",
  "serialis", "summaris", "utilis", "organis", "authoris", "prioritis",
  "alphabetis", "categoris", "sanitis", "visualis", "minimis", "maximis",
  "itemis", "randomis", "tokenis", "capitalis", "localis", "modularis",
  "standardis", "memois", "recognis", "synchronis", "analys", "paralys",
  "synthesis", "emphasis",
  -- a doubled consonant before a suffix, where US English keeps one
  "cancelled", "cancelling", "cancellable", "labelled", "labelling",
  "travelled", "travelling", "modelled", "modelling", "signalled",
  "signalling", "levelled", "levelling", "fuelled", "fuelling", "totalled",
  "totalling", "fulfil",
  -- -ogue → -og
  "catalogue", "dialogue", "analogue",
  -- no family, just British
  "grey", "artefact", "whilst", "amongst", "learnt", "ageing", "enquir",
  "acknowledgement", "judgement", "sceptic", "mould", "sulphur", "programme",
}

local ALLOWED = {
  "analysis", "analyses", "analyst", "analysts",
  "organism", "organisms", "organist",
  "specialist", "specialists", "generalist", "generalists",
  "optimism", "optimist", "optimists", "optimistic", "optimistically",
  "paralysis", "paralyses", "synthesis", "syntheses", "emphasis", "emphases",
  "fulfill", "fulfills", "fulfilled", "fulfilling", "fulfillment",
  "programmer", "programmers", "programmed",
  "synchronism", "synchronisms", "synchronistic",
}
```

**The published counts are 92 and 33.** `BRITISH` holds **92** entries and `ALLOWED` **33** (from
v2.65.0, which added `synchronis` and, because *synchronism*, *synchronisms* and *synchronistic* are
correct US words that contain it, allowed those three; kit revision 26 pins the same pair in the kit's
gate). A gate's copy
with any other count is not whole, and this line moves in the same change as the lists.

**How a gate MUST read them.**

- **Whole, both of them.** A gate **MUST** carry every `BRITISH` entry and every `ALLOWED` entry, and
  **MUST NOT** carry an entry that is not published here. A subset is not a smaller gate; it is a gate
  whose green means nothing, because no reader of the suite can tell which spellings it covers.
- **A new entry lands here first.** A sweep or a review that finds a British form the list misses
  amends this section, and the gates take it on their next sync. A private addition **MUST NOT**
  outlive the change that discovered it.
- **`ALLOWED` is removed as whole words, before the scan.** Delimit on non-letters, drop the matched
  tokens, then run the `BRITISH` substrings over what remains. Matching `ALLOWED` as a *substring*
  instead would swallow *analysed* inside the allowance for *analyses* and hide the defect the gate
  exists to find.
- **A `BRITISH` entry MUST NOT be a substring of a correct US word** unless that word is on `ALLOWED`.
  This is the admissibility test for any future entry, and it is why the list is shaped the way it is:
  `cancelled` and `cancelling` are listed separately rather than as `cancell`, because *cancellation*
  is US-correct; `synthesis` and `emphasis` are entries whose own noun forms sit on `ALLOWED`;
  `synchronis` is admissible only beside *synchronism*, *synchronisms* and *synchronistic*; and
  `fulfil` is admissible **only** because *fulfill* and its inflections are allowed beside it.
- **Some words are deliberately absent, and stay absent.** *towards*, *afterwards*, *forwards* and
  *learned* are acceptable US English, not British-only, and a gate that reddens on a correct word
  gets deleted rather than obeyed. The British verb *analyses* escapes by construction, because
  *analyses* is also the US plural of *analysis*; review catches that one, and the list does not
  pretend otherwise.

**What a gate scans, and what it MUST skip.** The scope is authored text as this section defines it
above — source, locale files, prose in `README.md` and `docs/`. Four exclusions, and each one **MUST**
be named file by file or directory by directory in the gate itself rather than inferred from a
pattern, so the exclusion list cannot quietly grow: vendored code (`libs/`, `tests/_kit/`), which the
consuming repo MUST NOT edit; frozen dated bundles and released changelog entries, which are the
record and are not rewritten; `locales/enGB.lua`, which is what a locale file is for; and a document
whose subject is this rule and which therefore quotes a forbidden spelling **in order to forbid it** —
this section, `anti-patterns` #46, any downstream restatement of either, and the gate's own copy of
the lists.

**A spelling that is not the repository's English to correct MAY be waived, per FILE and per WORD.**
The exclusions above answer *which files a gate reads*; this answers the narrower question they do
not, which is what to do when a scanned file legitimately holds a forbidden spelling. Three shapes
recur and none of them is a defect:

- **A library's field name.** `AceTimer-3.0` spells its cancellation flag the British way, and a
  timer handle records it under that name because that is the name the kit's live-timer survey reads
  off a handle. Correcting it would not fix prose; it would stop the survey seeing a canceled timer
  as canceled and leave a stand-down suite's timer assertion quietly unfalsifiable, which
  `slash-commands-§7` forbids outright.
- **Game data matched on its own token.** Blizzard spells its `LFG_LIST_APPLICATION_STATUS_UPDATED`
  status the British way; an addon matches it verbatim off the event, and a respelling is a lookup
  that never matches. This section already requires matching game data on stable IDs and tokens —
  the waiver is that rule reaching the gate.
- **A generated dump of the client's own strings**, such as a vendored `GlobalStrings` table. That
  is the game's English arriving whole, not the addon's.

Three MUSTs govern it, and they exist because a waiver is the one part of this gate that can hide
the defect it was built to find:

- **Per file AND per word.** A whole-file waiver is forbidden. It hides every *other* British
  spelling in a file the repository edits often, which is how a gate acquires a blind spot the size
  of a module.
- **The reason is written beside it.** A waiver with no stated reason is indistinguishable from a
  spelling nobody got round to fixing, and the next sweep either re-fixes it or widens it.
- **It waives, it never extends.** A waiver MUST NOT add an entry to `BRITISH` or remove one from
  `ALLOWED`; those lists stay whole and are this section's alone, as above.

The kit implementation reads waivers from an optional `tests/prose_waivers.lua` returning
`{ skipDirs, skipFiles, waived = { [path] = { word = true } } }`. A file that exists but does not
return a table is a **failure**, not an empty one: the alternative silently widens the gate.

**The gate SHOULD be the one the test kit ships** (`tests/_kit/test_prose.lua`, kit revision 24),
wired as one entry in the runner's suite list, rather than hand-written per repository. Eleven
hand-written copies are eleven chances to carry a subset, and the collection proved it: by the time
the kit shipped one, seven repositories had written their own under three different filenames and
four had none at all. A repository that still carries its own copy wires one or the other, **never
both** — two gates over one rule is two lists to keep whole.

**Declining the kit's copy is a deviation from the SHOULD above, and it MUST be recorded** — a row in
the repository's `## Documented deviations` register (documentation-§3) keyed `localization-§5`,
carrying the re-check trigger that ends it. The row is not paperwork: it is what the suite inventory
reads the decline off. An unreferenced `tests/_kit/test_prose.lua` with a row behind it is reported
once as a **decline**; with no row it is a gate that silently does not run, which is a hole and a
**failure** (testing-§9). The two rules therefore have one reading between them — wire the kit's copy,
or wire your own **and** record why the kit's is unwired — and neither permits the third state, the
kit's copy sitting unwired and unmentioned. Six of the twelve repositories are in exactly that state
today: each declares a bare `test_prose` naming its own file, and not one of the six carries a row for
it. That reporting lands with the kit's inventory check **from LibKa0s test-kit revision 25 (LibKa0s
v1.55.0)**; a repository whose vendored kit predates that revision owes the re-vendor, not a
hand-written suite (testing-§9).

Lint cannot catch any of this (`luacheck` does not read English), so enforcement is three-layered:
the gate above for the mechanical part, `/wow-addon:standards-audit`, which flags a British spelling
in authored text as a deviation, and review for the rest — the locale-key ripple, the four exceptions,
and the forms no substring can decide.
