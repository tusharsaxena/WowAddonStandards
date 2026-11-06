# Harvest 2026-11-06 — 03 Evidence

The verbatim excerpts and citations the findings in `02_FINDINGS.md` rest on. Parts A–D are the four sweeps of
this run, kept as written on 2026-11-06 by the read-only sweep agents and checked by the lead where a proposal
rests on them (each proposal in `04_PROPOSALS.md` names the lines it re-read). Part E is the issue store as
`gh` returned it. Citations of the form `Repo path:line` are to the working trees on 2026-11-06 and are
historical from the day after: pin them with the repos' heads on that date, listed in `01_COLLECTION_STATE.md`.

Where one quirk was written up several times, Part A quotes every version and marks the deepest.

---

# Part A — Midnight quirks (category 3)


Researcher: read-only sweep, 2026-11-06. Standard read at **v2.101.0 (2026-11-04)**
(`WowAddonStandards/standards/STANDARDS.md:1`). All paths are relative to
`/mnt/d/Profile/Users/Tushar/Documents/GIT/`. `libs/`, `tests/_kit/`, `.superpowers/` and the frozen
bundles (`docs/audits|reviews|automated-tests|perf-analysis|superpowers|revendor`) were excluded from
the code greps. Line numbers below were read today.

**Sources read in full:** every `docs/midnight-quirks.md` (11 files), `OutfitterReborn/docs/{taint,
known-limitations,compat-layer}.md`, OR's private inventory catalogue
(`OutfitterReborn/docs/superpowers/specs/2026-11-03-outfitter-feature-inventory.md` §16), the
`core/Secrets.lua` headers (AuraMaster, DpsRace, MultiMeters, OutfitterReborn), `LibKa0s/LibKa0s/Compat.lua`
header, `events-frames-taint.md`, `compat.md`, and the relevant parts of `options-ui.md`,
`localization.md`, `frame-layering.md`, `documentation.md`. Prior harvests checked so this does not
re-file refuted work: `WowAddonStandards/harvests/2026-08-25/` (P-07) and `harvests/2026-09-22/02_FINDINGS.md`
(C3-F01..F08).

---

### A 0. The quirks-catalogue evidence numbers

| Measure | 2026-08-25 (P-07) | 2026-09-22 (C3-F01) | **2026-11-06 (now)** |
|---|---|---|---|
| Repos keeping `docs/midnight-quirks.md` | 6 | 9 | **11** |
| Total lines in those files | n/a | n/a | **2,073** |
| Headed entries in those files (DropWatcher's table rows counted) | n/a | n/a | **≈133** |
| Entries belonging to a cluster written up in ≥2 quirks docs | 3 write-ups of 1 behavior | "two behaviours" | **≈81 of ≈133 (~60%)** |
| Distinct clusters written up in ≥2 quirks docs | 1 | 2 | **21** |
| …of which the standard fully covers | 0 | 2 | **5** |
| …partially covers | n/a | n/a | **7** |
| …does not cover | n/a | n/a | **9** |
| Additional clusters seen in ≥2 repos only through code comments / other docs | n/a | n/a | **7** |
| Quirks docs that open with their own restatement of the 12.0 secret-value contract | n/a | n/a | **9 of 11** (+4 `core/Secrets.lua` contract headers) |

**The 11:** AbsorbTracker (124 lines), AuraMaster (864), BankLedger (130), ConsumableMaster (114),
DropWatcher (33, a 21-row table), KickCD (134), LootHistory (104), MultiMeters (158), OutfitterReborn
(60), PartyFrameEnhanced (157), WhatGroup (195).
**Without one:** DpsRace, PanelMaster, PremadeGroupsFilterExtension, PrettyChat, QuickComms,
LibKa0sSkinTester. Three of these carry client workarounds anyway, in other files (possible
documentation-§3 Tier-2 trigger misses, worth an audit look, not a finding here):
- DpsRace: `docs/known-limitations.md:97-99` ("the client writes a secret to SavedVariables as `nil`
  (the reload probe, 2026-10-25)"), `core/Secrets.lua:5-11` (its own measured contract),
  `modules/Watchers.lua:49` (empower events).
- QuickComms: `docs/known-limitations.md:20` ("A chat lockdown that clears with no event of its own is
  re-read on `ENCOUNTER_END`…"), `modules/Restrictions.lua:8-11`.
- PanelMaster: `core/Compat.lua:75-78` (lockdown lags `PLAYER_REGEN_DISABLED`).

**OutfitterReborn keeps a second private catalogue**: §16 "Quirks to preserve (consolidated)" of
`docs/superpowers/specs/2026-11-03-outfitter-feature-inventory.md:1123-1148` (25 entries, inherited
from the legacy addon; code cites them as "INV §16 quirk N", e.g. `modules/Commands.lua:10`,
`modules/Triggers.lua:20`, `defaults/Items.lua:110`). Most are addon behavior, but #3 (secure rows never
re-anchored), #5 (aura restriction gate, IsSecret before nil) and #14 ("134400 means no icon") are client
facts that other repos also wrote up.

**The standard itself drives one duplication.** `events-frames-taint.md:47` tells every addon to "Take
the trade deliberately and write it down in the addon's quirks doc", which is why the unknown-event
quirk now has **8** copies in quirks docs. `options-ui.md:90` records the same pattern for the
`OpenToCategory` pair: "Four addons in the collection each wrote both up in their own quirks file before
either reached the standard". All four copies are still there.

**Reading for/against the deferred P-07.**
- *For:* coverage moved from 1 duplicated behavior to 21 clusters. Nine clusters with 2–7 independent
  write-ups have no home in the standard. Three clusters carry **live contradictions** between repos,
  and two of them contradict the standard's own text (§2 below). That is exactly the drift a single
  catalogue with build stamps would stop. Repos already cross-cite each other's quirks as an informal
  catalogue: `DpsRace/modules/Hud_Breakdown.lua:12-13` ("(MultiMeters' measured layout rule)"),
  `PartyFrameEnhanced/docs/midnight-quirks.md:124-125` ("(KickCD's finding)"),
  `LootHistory/core/Ledger.lua:49` ("(BankLedger)").
- *Against / caveats:* the rot risk P-07 named is real and visible today. `AbsorbTracker/docs/midnight-quirks.md:84`
  still pins `## Interface: 120105`. KickCD's probe table is stamped "12.0.7" and says "a snapshot…
  not a contract" (`KickCD/docs/midnight-quirks.md:80`). C3-F06 (2026-09-22) ruled the
  `ADDON_RESTRICTION_STATE_CHANGED` signature settled, and three repos now record the opposite (Q10).
  Several of the uncovered clusters are better promoted *into existing sections* (§8, §2, §1,
  savedvariables, testing) than into a new catalogue. Count per cluster below.

---

### A 1. Clusters written up in more than one repo

Notation: **[D]** = in a quirks doc; **[C]** = code comment; **[O]** = other doc. ★ = deepest write-up.

#### Q1. Retail raises on an unknown event name; one bad name deafens the block (8 quirks docs)
- AbsorbTracker `docs/midnight-quirks.md:120` [D]: "**registering an unknown name raises** — `Attempt to register unknown event "<NAME>"`"
- AuraMaster `docs/midnight-quirks.md:456-459, 472-486` [D] ★: "Every name this addon registers is valid on 12.1, so the failure is latent", then a per-event list of what each refusal costs ("a refused `UNIT_AURA` leaves the timed-spell scan not listening…").
- BankLedger `docs/midnight-quirks.md:54-56` [D]: "It does not ignore it. A bare registration loop therefore turns **one** retired event into a silently deaf addon"
- ConsumableMaster `docs/midnight-quirks.md:110-114` [D]: "Blizzard removed `LEARNED_SPELL_IN_TAB` from retail; AceEvent throws `Attempt to register unknown event`"
- LootHistory `docs/midnight-quirks.md:80-101` [D]: "If a patch retired `ENCOUNTER_START`, loot would still record, and boss loot would lose its encounter detail"
- MultiMeters `docs/midnight-quirks.md:122-124` [D]: "here that was the three `DAMAGE_METER_*` events, which are registered last"
- PartyFrameEnhanced `docs/midnight-quirks.md:148-157` [D]: "an AceEvent target only raises for an event's first registrant in the client-wide registry"
- WhatGroup `docs/midnight-quirks.md:184` [D]
- plus tests: `KickCD/tests/test_events.lua:12`, `PanelMaster/tests/test_disabled.lua:836`.
- **Deepest:** AuraMaster, for the per-event cost table (the trade §1:47 asks for). PartyFrameEnhanced adds the one fact nobody else has: the raise is first-registrant-only.
- **Standard: COVERED.** `events-frames-taint.md:38-49` (§1). The 2026-09-22 note that AbsorbTracker recorded the opposite model is **fixed**: `AbsorbTracker/docs/midnight-quirks.md:120` now states the raise.

#### Q2. `Settings.OpenToCategory` takes the numeric ID; a parent opens collapsed (4 docs)
- AbsorbTracker `docs/midnight-quirks.md:75`: "passing the object produces a range error."
- ConsumableMaster `docs/midnight-quirks.md:86` ★ (the why): "`SettingsCategoryMixin` does NOT expose a `SetExpanded` method — that lives on the visual list-entry element"
- KickCD `docs/midnight-quirks.md:133-134`: "Blizzard's CategoryList only auto-expands the subcategory tree when a *child* is selected." Adds a retry: "capped at 3, 0.5 s apart".
- WhatGroup `docs/midnight-quirks.md:39-44` ★ (the wrong forms): "**Do not overwrite `category.ID` with a string.** Doing so silently breaks the lookup and `OpenToCategory` becomes a no-op."
- **Standard: COVERED.** `options-ui.md:92-93` (§2), both halves, merged deepest-first. The four local copies are now redundant restatements, and the code lives in `LibKa0s/LibKa0s/OptionsRegistry.lua:243`.

#### Q3. The category switch is protected in combat (4 docs)
- AbsorbTracker `docs/midnight-quirks.md:57-71` ★, ConsumableMaster `:106`, WhatGroup `:46`, AuraMaster `:790-802`.
- **Standard: COVERED.** `options-ui.md:83-85` (§2) + anti-pattern #88 (`anti-patterns.md:117`).

#### Q4. A secret survives `tostring`/`..` and raises in `table.concat` (6 docs + 1 dissent)
- AbsorbTracker `docs/midnight-quirks.md:14` ★: "A secret string passes through `tostring()` unchanged, **and the `..` operator does not raise on it either** … What *does* raise is `table.concat`"
- BankLedger `docs/midnight-quirks.md:101-105`: "So a secret-value detector built on `..` lets a combat-protected value through to the real concat and crashes there."
- ConsumableMaster `docs/midnight-quirks.md:60`: "`tostring` and `..` silently propagate secretness"
- KickCD `docs/midnight-quirks.md:11-12`: "`tonumber(secret)` | Still secret." / "`tostring(secret)` | Still secret."
- MultiMeters `docs/midnight-quirks.md:44-46`: "`tostring` on a secret neither raises nor launders it: it answers a **secret string**, which then poisons the `find` and the `gsub`"
- LootHistory `docs/midnight-quirks.md:5` (the seam note).
- **Dissent:** OutfitterReborn `docs/midnight-quirks.md:10-11`: "A secret cannot be compared, formatted, concatenated, used in arithmetic or used as a table key; any of those raises." and `core/Secrets.lua:9`: "It may NOT … concatenate it". MultiMeters `core/Secrets.lua:24` says the opposite: "Tainted code MAY: … concatenate them".
- **Standard: COVERED** at `events-frames-taint.md:117-126` (§8). OutfitterReborn's two lines contradict §8:119. That is a per-repo doc defect to file, not a standard change.

#### Q5. Does `string.format` accept a secret? CONTESTED (5 vs 2)
- "Raises": standard `events-frames-taint.md:120` ("raises the instant it reaches `table.concat` (and `string.format`)"); KickCD `docs/midnight-quirks.md:15` ("`:format("%.1f", secret)` | Errors."); AbsorbTracker `:26`; PartyFrameEnhanced `:10` ("formatting it in Lua raises"); AuraMaster `core/Secrets.lua:14`.
- "Allowed": MultiMeters `core/Secrets.lua:24-25` ("concatenate them, and call string.format / string.join / string.concat with them"); DpsRace `core/Secrets.lua:9-10` ("…and string.format it"), backed by a probe, `docs/superpowers/specs/2026-10-23-dps-race-pve-design.md:50`: "Mid-combat, spell names display, and so do numbers via `string.format`."
- **Likely reconciliation (unverified):** the format specifier matters (`%s` passes a secret through, `%d`/`%.1f` do arithmetic), or the result is a secret string that only a widget can show. Nobody has probed specifier by specifier.
- **Standard: PARTIALLY COVERED, and possibly wrong.** §8:120 states the raise flatly. **Recommend** a client probe (`%s` vs `%d` vs `%.1f`, in combat, on a `C_DamageMeter` value and a `UnitHealth` value) before anyone edits §8.

#### Q6. A secret BOOLEAN cannot be tested at all (4 docs + 3 contract headers = 7 repos)
- KickCD `docs/midnight-quirks.md:72` ★: "**Secret BOOLEANS are unusable, not merely unprintable.** `HasExpired`, `HasStarted`, `IsActive` and `IsZero` all come back secret-tainted in combat … Only `HasSecretValues()` stays plain". Probe table at `:57-68`, stamped 12.0.7.
- PartyFrameEnhanced `docs/midnight-quirks.md:30`: "**A secret boolean never meets an `if`.**", routed C-side through `C_CurveUtil.EvaluateColorValueFromBoolean` / `SetAlphaFromBoolean`.
- DropWatcher `docs/midnight-quirks.md:15`: "A secret boolean cannot be tested at all. | The cautious answer: a secret chat lockdown reads as locked and a secret restriction state as active"
- AuraMaster `docs/midnight-quirks.md:87-96`: measured "attempt to compare local 'v' (a secret boolean value)", and `IsShown` on an engine button "can answer a SECRET boolean out of combat".
- MultiMeters `core/Secrets.lua:31-34`; OutfitterReborn `core/Secrets.lua:9-10, 106` ("secret boolean raises; a nil answer is 'no claim'"); DpsRace `core/Secrets.lua:10`.
- **Two answers coexist:** C-side evaluation (KickCD, PFE) versus fail-cautious nil or "unknown" (DW, OR, MM, AM). Within the C-side pair there is a recorded correctness disagreement (gate first or not), `LibKa0s/docs/api/Compat/version-1-docs.md:269`.
- **Standard: NOT COVERED.** `grep -c 'boolean'` finds nothing on this in §8, which is a printing rule. C3-F02 (2026-09-22) refuted this at "2 true + 2 adjacent". **It is now 7 repos.** Re-file.

#### Q7. A secret used as a table key raises (5 docs + 2 code = 7 repos)
- MultiMeters `docs/midnight-quirks.md:15-17` ★: "In a follower dungeon `UnitGUID("party3pet")` answers a secret string, and keying on one raises `attempted to perform indexed assignment on a table that cannot be indexed with secret keys` on every refresh tick." The only verbatim client error in the collection.
- PartyFrameEnhanced `docs/midnight-quirks.md:10`: "using it as a table key … raises"
- OutfitterReborn `docs/midnight-quirks.md:11`, `core/Secrets.lua:10` ("key a table with it"), `core/Compat.lua:599` ("A pet whose GUID is secret is never a handle")
- DropWatcher `docs/midnight-quirks.md:31`: "guards every payload with `IsSecret` before it is compared or used as a key"; code `core/Compat.lua:413`
- AuraMaster `docs/midnight-quirks.md:14-15` + `core/Secrets.lua:14`; DpsRace `core/Secrets.lua:10`; QuickComms `core/Compat.lua:342, 351`.
- **Standard: PARTIALLY COVERED.** `library-stack.md:92` names `IsSafeKey` as a LibKa0s-Compat guard ("may it be a table key"). §8 never names keying as a failure. C3-F03 said "re-run when a third repo hits it". **Seven have.**

#### Q8. A frame handed a secret has secret geometry, and it propagates down the anchor chain (3 docs + 3 code = 6 repos + library)
- AuraMaster ★ `docs/midnight-quirks.md:556-560` ("A frame anchored to an aura engine container — or to any frame anchored to one — inherits its secret geometry… Its width, its points and its frame level (`FrameLevel` is a `SecretAspect`)"), `:583-588` (Backdrop.lua:226 arithmetic raise on a secret size), `:122-124` (empty engine height secret "even out of combat"), `:291-293` (`IsAnchoringSecret` true out of combat), `:718-720`. Several measured and dated.
- MultiMeters `core/Secrets.lua:48-52`: "calling StatusBar:SetValue(secret) marks that frame HasSecretValues, which makes its anchoring and position data secret too, and that propagates to anything anchored to it." Plus `docs/midnight-quirks.md:29-38` ("**a frame that is never handed a value keeps readable geometry**").
- PartyFrameEnhanced `docs/midnight-quirks.md:34`: "**After `SetAlphaFromBoolean`, `GetAlpha()` is secret.** Keep your own record of the alpha you asked for".
- DpsRace `modules/Hud_Breakdown.lua:12` [C] (cites MultiMeters); OutfitterReborn `modules/Tooltips_Compare.lua:19` [C] ("A tooltip that shows hidden information has secret geometry"); DropWatcher `docs/midnight-quirks.md:14` + `modules/TipGrid.lua:20` (a tooltip font string's width is a secret number "whose `type` is `number`, so a type check alone lets it through"); LibKa0s `docs/api/Widgets/version-10.2-docs.md:653`.
- **Standard: PARTIALLY COVERED.** `frame-layering.md:42` ("the read guarded against secret values and forbidden frames") and `:61` ("A level read under a restricted anchor goes through a secret-safe guard") cover level reads only. Neither the propagation rule ("compute layout from config, never read it back") nor Backdrop's hidden arithmetic is stated.

#### Q9. Restricted spell cooldowns: plain `isActive`/`isEnabled`, secret timings, the duration-object route (3 docs + 1 = 4 repos)
- KickCD `docs/midnight-quirks.md:20-34, 36-95` ★ (probe table, fresh object per call, ~10 redundant emits/s, "`GetSpellCooldownDuration` returns a ZEROED object, not nil").
- ConsumableMaster `docs/midnight-quirks.md:49-50`: "**`isEnabled` and `isActive` are documented NeverSecret** … `Cooldown:SetCooldownFromDurationObject` accepts it from a tainted caller, which makes it the only way to paint a restricted cooldown."
- PartyFrameEnhanced `docs/midnight-quirks.md:19` (duration getters secret; passed straight to `SetTimerDuration`).
- WhatGroup `docs/compat-layer.md:149-150` [O]: "It returns `nil` in exactly one case, a secret cooldown pair … every caller handles that case explicitly by deciding from `isActive`." (This closes the per-repo defect C3-F04 recorded.)
- **Standard: PARTIALLY COVERED.** `events-frames-taint.md:174-177` names the secret fields in the trigger set. It does not give the escape route (branch on `isActive`, paint with `SetCooldownFromDurationObject`) or the ban on raw `SetCooldown` with a secret.

#### Q10. `ADDON_RESTRICTION_STATE_CHANGED`: `Activating` fires before enforcement; the payload shape; Map never clears (4 docs + 2 = 6 repos)
- AuraMaster `docs/midnight-quirks.md:39-42` ★ (measured 12.1.0, 2026-09-18): "`ADDON_RESTRICTION_STATE_CHANGED` carries `(type, active)`. Type `0` tracked combat… Types `1` and `5` went active together at `ENCOUNTER_START`… Type `4` went active on entering a dungeon and did not clear, yet auras stayed readable there out of combat."
- DropWatcher `docs/midnight-quirks.md:21-22`: "fires just before a restriction starts, with the state `Activating`" / "has been seen carrying `(type, active)` with a boolean, as well as the numeric state."
- MultiMeters `docs/midnight-quirks.md:76-79` + `core/Secrets.lua:42-45`: "`state = Activating` **before** enforcement begins and access is still permitted during that dispatch"
- QuickComms `modules/Restrictions.lua:8-11` [C]: "The state arrives as a number (the AddOnRestrictionState) or a boolean; a secret one reads as active."
- OutfitterReborn `docs/midnight-quirks.md:31-33`: "read with the restriction type's name, never a raw number, because the combat member of `Enum.AddOnRestrictionType` can be missing on some builds."
- ConsumableMaster `docs/ARCHITECTURE.md:180` [O] (type 0 left to `PLAYER_REGEN_ENABLED`).
- **Note:** C3-F06 (2026-09-22) refuted a payload-shape disagreement as "resolvable in two greps", on the grounds that AuraMaster read no payload. Today three repos (AM measured, DW, QC) record a **boolean** second argument and handle both shapes, while MM documents `(type, state)`. Treat the shape as unresolved until someone probes it.
- **Standard: NOT COVERED** (`debug-logging.md:146` only names the event).

#### Q11. `PLAYER_REGEN_DISABLED` fires before lockdown begins (2 docs + 5 code/other = 6 repos). Contradicts the standard
- AbsorbTracker `docs/midnight-quirks.md:43-51` ★ (debug capture): "When `PLAYER_REGEN_DISABLED` fires (`addon:OnEnterCombat`), `InCombatLockdown()` still returns **false**; secure lockdown engages a fraction of a second later." Stated cost: "The bar never recovered for the rest of the fight". Code `modules/Display.lua:305-307`.
- AuraMaster `docs/midnight-quirks.md:445-446`; `modules/TimedSpells.lua:149-151` ("so InCombatLockdown() still answers false inside that handler"); `modules/EmptyWatch.lua:24`; `core/AuraMaster.lua:164` (uses the window for secure writes).
- PanelMaster `core/Compat.lua:75-78` [C]: "Lockdown is the wrong clock for it: it starts AFTER PLAYER_REGEN_DISABLED".
- OutfitterReborn `docs/taint.md:41` [O]: "The window is **hidden inside `PLAYER_REGEN_DISABLED`**, while protected calls are still allowed"; `core/SecureQueue.lua:27`.
- LootHistory `core/Compat.lua:797-799` [C]; QuickComms `modules/SendEngine.lua:8` [C].
- **Standard: PARTIALLY COVERED, with an inaccuracy.** `events-frames-taint.md:57-64` (§2) has the right rule (display uses the combat flag, secure writes use lockdown) and even cites the AbsorbTracker bug at :63. But **:59 says `InCombatLockdown()` is "true from `PLAYER_REGEN_DISABLED`"**, and :64 says the events "fire exactly at the lockdown boundary". Four repos measured or rely on the opposite, and `frame-layering.md:89` itself depends on the window ("disarmed at `PLAYER_REGEN_DISABLED`"). Recommend a patch-class correction of §2:59 and :64 that names the window as usable for last secure writes.

#### Q12. Empowered casts fire `UNIT_SPELLCAST_EMPOWER_*`, not the channel events (2 docs + 1 code)
- KickCD `docs/midnight-quirks.md:119` ★: "reported by `UnitChannelInfo`, not `UnitCastingInfo`, but it does **not** fire `UNIT_SPELLCAST_CHANNEL_START` / `_STOP`".
- PartyFrameEnhanced `docs/midnight-quirks.md:116-120`: "`isEmpowered`, is read only when it is plain; the triggering event … decides otherwise."
- DpsRace `modules/Watchers.lua:49-51` [C]: "its release fires SUCCEEDED with the same castGUID".
- **Standard: NOT COVERED.**

#### Q13. `notInterruptible` is secret; the interruptibility events make it plain; `CastingBarFrameTemplate` raises on another unit (2 docs)
- KickCD `docs/midnight-quirks.md:98-115` ★ ("The 12.0-correct pattern: split the gate in two", plus the plain-after-flip invariant); `docs/castbar.md:137`: "Its built-in `OnUpdate` does `GetTime() < self.maxValue`, which becomes `GetTime() < <secret>` and errors".
- PartyFrameEnhanced `docs/midnight-quirks.md:36-38` ("Do not optimize the color path into an `if` because 'it's plain now'"), `:122-125` ("(KickCD's finding)").
- **Standard: NOT COVERED.** The repos also disagree on the cast-info override, recorded at `LibKa0s/docs/api/Compat/version-1-docs.md:268`.

#### Q14. Blizzard aura buttons are forbidden to addon code (2 docs + 1 code)
- PartyFrameEnhanced `docs/midnight-quirks.md:97-107` ★: "In an instance (seen in M+) the same aura buttons answer `IsForbidden()` `false` and still refuse every read, `GetChildren` included".
- AuraMaster `docs/midnight-quirks.md:65-67, 287-290`: "In combat every call on the button's objects raises 'Attempt to access forbidden object from code tainted by an AddOn'".
- OutfitterReborn `modules/SlotEnables.lua:88` [C] (`pcall(f.IsForbidden, f)`).
- **Standard: PARTIALLY COVERED.** `frame-layering.md:42` ("guarded against … forbidden frames"). The fact that `IsForbidden()` can lie in M+ is not stated.

#### Q15. Item data is nil until cached, and the load event has holes (4 docs + 3 code = 7 repos)
- ConsumableMaster `docs/midnight-quirks.md:27` ★ (the hole): "`GET_ITEM_INFO_RECEIVED` does **not** fire for it on the addon's first scan."
- LootHistory `docs/midnight-quirks.md:37` ("an uncached item does *not* hand back an empty tooltip. It hands back a perfectly legible one reading `RETRIEVING_ITEM_INFO`") and `:47`.
- DropWatcher `docs/midnight-quirks.md:16`: "`GetItemInfo` answers nothing until the item is cached."
- AuraMaster `docs/midnight-quirks.md:411-416` (enchant name: "a failed load drops that wait, and nothing else asks again").
- BankLedger `core/Compat.lua:17, 171` [C]; OutfitterReborn `docs/test-cases.md:440` [O]; DpsRace `modules/Results_Loadout.lua:152` [C].
- **Standard: PARTIALLY COVERED (library only).** No section names it (`grep GetItemInfo` = 0). `LibKa0s-Item-1.0` (`LoadItem`) and its doc's recorded guess-vs-refuse disagreement (`LibKa0s/docs/api/Item/version-1-docs.md:33-36`) are the only shared home.

#### Q16. `C_TooltipInfo` returns raw templates with `|4singular:plural;` unexpanded (2 docs)
- ConsumableMaster `docs/midnight-quirks.md:13-16`: "`C_TooltipInfo.GetItemByID` returns **raw template strings**" (also NBSP, which Lua's `%s` does not match).
- DropWatcher `docs/midnight-quirks.md:29` ★ (in-game capture, 12.1.5): "`for the next 3 |4hour:hrs; 49 min (including time offline).` … a decoder that knew only `hour` and `hrs` read no window and called the drop expired". Code `core/TextParse.lua:38-73` handles three-form locales.
- **Standard: NOT COVERED** (localization §4 covers matching GlobalStrings, not template grammar).

#### Q17. Tooltip line text can be secret (2 docs)
- DropWatcher `docs/midnight-quirks.md:14, 30` ★; `docs/known-limitations.md:36-37` ("under an addon restriction that line can read secret").
- OutfitterReborn `docs/midnight-quirks.md:57`: "`TooltipDataProcessor` replaces tooltip hooking by scanning, and its line text can be secret."
- **Standard: NOT COVERED.**

#### Q18. Blizzard renumbers enums, so resolve them by member name (2 docs + 3 code = 5 repos)
- DropWatcher `docs/midnight-quirks.md:24` ★ ("the research's `TradeTimeRemaining = 36` and `ItemUpgradeLevel = 32` are one build's values"), `core/Compat.lua:9-10`.
- OutfitterReborn `docs/midnight-quirks.md:31-32` (restriction type by name; a member "can be missing on some builds"), `modules/ItemInfo.lua:15-16`.
- BankLedger `core/Constants.lua:106-107` [C]: "a numeric guess for a member the build doesn't expose lands on a completely unrelated container"
- LootHistory `core/Constants.lua:294-295` [C] (`Characterbanktab = -2, Accountbanktab = -3` on 12.0.7); MultiMeters `core/Constants.lua:106-108` [C].
- **Standard: PARTIALLY COVERED.** `localization.md:92` ("Fixed set | an `Enum.*` member | any string spelling of it") forbids strings but never says "never a raw number".

#### Q19. Client state lags its own event, or changes with no event at all, so a settle pass or retry is needed (4 docs + 2 = 6 repos)
- MultiMeters `docs/midnight-quirks.md:147-152` ★ + `core/Constants.lua:597-600`: "SOME CLIENT STATE LAGS ITS OWN EVENT. IsMounted() has already flipped by the time PLAYER_MOUNT_DISPLAY_CHANGED arrives; C_PlayerInfo.GetGlidingInfo's canGlide has not always done so".
- BankLedger `docs/midnight-quirks.md:65-66` ("switching between those tabs fires **no event at all**"), `:73-75` ("the live warband tab has been observed taking **over a second** to catch up").
- DropWatcher `docs/midnight-quirks.md:26` ("After `INSPECT_READY` some slots can still answer an item id with no link"; 0.15 s read, 3 retries 0.3 s apart).
- PartyFrameEnhanced `docs/midnight-quirks.md:61, 70` (no unit events for compound tokens, so a gated timer).
- QuickComms `docs/known-limitations.md:20` [O] (chat lockdown clears with no event); LootHistory `core/Ledger.lua:49` [C] (settle timeout borrowed from BankLedger).
- **Standard: NOT COVERED.** Distinct instances, one shared pattern ("answer at the edge and once more after a settle"). A candidate for a rule in events-frames-taint rather than a catalogue entry.

#### Q20. A valid event that registers fine and never fires (4 docs)
- BankLedger `docs/midnight-quirks.md:9-12` ★: "`GUILDBANKFRAME_OPENED` is a **valid name that registers without complaint and never fires** on 12.0.7."
- KickCD `docs/midnight-quirks.md:131`: "**`UNIT_SPELLCAST_SUCCEEDED` is suppressed for protected interrupts.**"
- ConsumableMaster `docs/midnight-quirks.md:27` (`GET_ITEM_INFO_RECEIVED` for cached items).
- PartyFrameEnhanced `docs/midnight-quirks.md:61` ("`UNIT_HEALTH` never fires for `party1target`"), `:70` (`UNIT_NAME_UPDATE`).
- **Standard: NOT COVERED.** §1 covers unknown names only. The inverse failure, a valid name that stays silent, is silent too and has no surface. BankLedger's `/bl debug scan` "dead rows" is the only detector.

#### Q28. `134400` is the `?` dynamic-icon sentinel (2 docs + OR INV)
- ConsumableMaster `docs/midnight-quirks.md:66-68` ★ (macro icon overrides `#showtooltip`); WhatGroup `docs/midnight-quirks.md:174-180`; OutfitterReborn INV §16 #14 ("134400 means no icon").
- **Standard: NOT COVERED.** Trivial. Not worth promoting.

#### Q29. Spec readers moved to `C_SpecializationInfo` (2 docs)
- DropWatcher `docs/midnight-quirks.md:20`; OutfitterReborn `docs/midnight-quirks.md:38`; QuickComms `docs/compat-layer.md:36` [O].
- **Standard: COVERED.** `compat.md:261-262` + LibKa0s-Compat (`library-stack.md:92`).

### Code-only / other-doc clusters (≥2 repos, ≤1 quirks doc)

| # | Behavior | Repos (citations) | Standard |
|---|---|---|---|
| Q21 | A secret must never reach SavedVariables; the client writes it as `nil` | DpsRace `docs/known-limitations.md:97-99` (★ measured: "the client writes a secret to SavedVariables as `nil` (the reload probe, 2026-10-25)"), `core/Secrets.lua:8` ("a value captured then STAYS secret after combat"); MultiMeters `tests/test_roster.lua:537-538` ("a secret GUID reached SavedVariables as a KEY"); OutfitterReborn `core/Secrets.lua:84` | **Not covered** (`savedvariables.md` has no "secret") |
| Q22 | `FontString:SetText(): Font not set` on a template-less string with no font | OutfitterReborn `modules/Dock.lua:309-310`; MultiMeters `tests/mock_frame.lua:229-238` ("taking the whole addon down before a single window existed. Every test passed"); BankLedger `tests/test_mock.lua:173`; LibKa0s `docs/api/Widgets/version-2-docs.md:187` (shipped in v1.11.0/1.11.1) | **Not covered.** A mock-fidelity point for testing-§1 as much as a quirk |
| Q23 | `Cannot anchor protected frames to regions` | WhatGroup `docs/midnight-quirks.md:124-143` ★; OutfitterReborn `modules/Window_Rows.lua:21-24`, `modules/Dock.lua:6-7` ("a protected frame restricts both the frames it is parented to and the frames it is anchored to") | **Not covered.** See contradiction C4 |
| Q24 | ESC (`UISpecialFrames`) runs a protected `Hide()` in combat | WhatGroup `docs/midnight-quirks.md:154` (escape proxy); OutfitterReborn `docs/taint.md:44` ("`CloseSpecialWindows` can never hit a protected Hide (C13)") | **Not covered** |
| Q25 | `GetNormalizedRealmName` is nil early in login; chat drops spaces/hyphens | DropWatcher `docs/midnight-quirks.md:23` ★; LootHistory `core/Compat.lua:997` ("nil early in login: never a bare 'Name-'"); BankLedger `core/Compat.lua:38`; QuickComms `core/Compat.lua:136` | **Not covered** |
| Q26 | `SendChatMessage` moved to `C_ChatInfo` (11.2.0) | DropWatcher `docs/midnight-quirks.md:18`; DpsRace `core/Compat.lua:12`; MultiMeters `core/Compat.lua:869` | **Partially** (compat.md's general rule; LibKa0s candidate at `docs/api/Compat/version-1-docs.md:300`) |
| Q27 | `InChatMessagingLockdown` may be secret; read it cautiously | DropWatcher `core/Compat.lua:218-221`; QuickComms `core/Compat.lua:170-173` (byte-identical); DpsRace `modules/Share.lua:117-118` | **Not covered.** Library candidate deferred at `LibKa0s/docs/api/Compat/version-1-docs.md:303` |

---

### A 2. Live contradictions (the strongest catalogue argument)

| # | Topic | Side A | Side B | Action |
|---|---|---|---|---|
| C1 | `string.format` on a secret (Q5) | raises: standard §8:120, KickCD:15, AT:26, PFE:10, AM `Secrets.lua:14` | allowed: MM `Secrets.lua:24-25`, DpsRace `Secrets.lua:9-10` + measured spec:50 | Probe per specifier, then fix whichever side is wrong |
| C2 | `..` on a secret (Q4) | propagates without raising: standard §8:119, AT:14, BL:101, CM:60, MM `Secrets.lua:24` | raises: OR `midnight-quirks.md:11`, OR `Secrets.lua:9` | OR doc defect (per-repo issue) |
| C3 | Lockdown at `PLAYER_REGEN_DISABLED` (Q11) | standard §2:59 "true from `PLAYER_REGEN_DISABLED`", §2:64 "fire exactly at the lockdown boundary" | AT (measured), AM, PM, OR, and `frame-layering.md:89` relies on the gap | Correct the standard (patch) |
| C4 | Anchoring a secure button to its parent (Q23) | WG:124-137: `secureBtn:SetAllPoints(parent)` FAILS at load, use the implicit-parent form | OR `Window_Rows.lua:21-24`, `taint.md:45`: "anchored with `SetAllPoints(row)` **at birth only**", treated as working | Reconcile. OR's smoke O11 is still owed (`known-limitations.md:97`) |
| C5 | `ADDON_RESTRICTION_STATE_CHANGED` 2nd arg (Q10) | MM: `(type, state)` enum | AM (measured), DW, QC: boolean seen too | Probe. Do not repeat C3-F06's "settled" |
| C6 | Secret boolean to a C setter (Q6) | PFE gates on `IsSecret` first | KickCD deliberately ungated (`KickCD/docs/castbar.md:133` per C3-F08) | Already recorded at `LibKa0s/docs/api/Compat/version-1-docs.md:269`. Leave it |

---

### A 3. OutfitterReborn: first harvest

OR is the newest repo (port of the legacy Outfitter, 2026-11-03..05). Its client knowledge is spread over
five places: `docs/midnight-quirks.md` (60 lines, 5 entries), `docs/taint.md` (163), `docs/known-limitations.md`
(118, with an 18-row "Client checks still owed" table, :87-109), `core/Secrets.lua` / `core/Compat.lua` headers, and
the inventory spec §16 (25 inherited quirks).

**What OR adds that nobody else wrote up:**
1. **The widest list of secret reads** (`docs/midnight-quirks.md:8-10`): "`UnitHealth`, `UnitPower`, `UnitStat`, `UnitLevel`, item links in some contexts, aura fields, tooltip text, a spellcast's spellID, the mouseover or target GUID and name." `UnitStat`, `UnitLevel` and item links appear nowhere else. **Caveat:** this list is not marked as measured.
2. **A stated cost** (`docs/midnight-quirks.md:13-15`): "a raise inside an event handler aborted it after it had called `BeginEquipmentUpdate`, leaving the update counter above zero, which silently stopped every later equipment update for the session." Fix: `NS.Equip.Batch`, "an `xpcall` that always restores its depth". This generalises: a secret raise between paired begin/end calls strands state. **Watch-list.**
3. **The combat member of `Enum.AddOnRestrictionType` "can be missing on some builds"** (`:31-33`). It joins Q10/Q18.
4. **"Aura getters raise while restricted, so the aura scan checks the restriction first and checks `IsSecret` before nil"** (`:33-34`). This agrees with AuraMaster's measured "raised on every call" (`AuraMaster/docs/midnight-quirks.md:33-35`).
5. **Zones** (`:44-53`): "Blizzard re-issues some battlegrounds under a second map ID (Alterac Valley's `30` and `2197`)"; "Brawl maps (`1170`, `1280`, `1691`, `2799`) give the generic Battleground state only"; "Subzones have no ID route at all (no API exposes the current areaID)". Single-repo. localization §4 covers the map-ID rule, not these exceptions.
6. **The secure-window pattern** (`docs/taint.md:37-48`): hide the window inside `PLAYER_REGEN_DISABLED` while protected calls are still allowed; disarm secure attributes before hiding; let `UISpecialFrames` in only because the window is never shown in combat. It overlaps Q11, Q23 and Q24.
7. **`hooksecurefunc` on a missing global raises** (`core/Compat.lua:638`, `modules/QuickSlots.lua:159, 429`). **Covered:** `events-frames-taint.md:226` (§9).
8. **`SetFont` on a bad path "draws nothing and raises nothing"** (`core/Constants.lua:9`) and **`SetText` with no font raises "Font not set"** (`modules/Dock.lua:309`). The second joins Q22.
9. **An unverified-assumption ledger** (`docs/known-limitations.md:87-109`: O5…O44, H8). This is the same device as DropWatcher's `COMPAT-*` smoke rows (`DropWatcher/docs/midnight-quirks.md:8-9`), DpsRace's C1–C26 (`DpsRace/docs/known-limitations.md:64-65`) and AuraMaster's "Not yet settled in game" (`AuraMaster/docs/midnight-quirks.md:96`). Four repos independently keep a "client fact not yet confirmed" ledger beside their quirks. That is the expiry discipline P-07 asked for, already practised locally.

**OR doc defect to file (per-repo, not upstream):** C2. `docs/midnight-quirks.md:11` and `core/Secrets.lua:9`
say concatenating a secret raises, against §8:119 and four repos' measurements.

---

### A 4. Single-repo quirks with an explicit stated cost (watch-list candidates)

Promote one when a second repo hits it.

| Repo:file:line | Quirk | Stated cost |
|---|---|---|
| AbsorbTracker `docs/midnight-quirks.md:30-37` | `SetBackdrop` is a no-op when the table identity is unchanged | "The backdrop will look stale until the next `/reload`." (Other repos call `SetBackdrop(nil)` only to remove, e.g. `MultiMeters/modules/Tooltip_Lines.lua:541`) |
| BankLedger `docs/midnight-quirks.md:33-39` | `GUILDBANKBAGSLOTS_CHANGED` is pushed at login and whenever another guild member moves something | "opened a banking session in the middle of a field, and the session could not end" (issue #12) |
| BankLedger `:48-52` | `GetGuildBankMoney()` returns 0, not nil, when closed | "would … write a fabricated gold row" |
| BankLedger `:43-46` | Guild-bank tabs hold no data until `QueryGuildBankTab` | "sees five empty ones and one real one" |
| ConsumableMaster `:66-68` | A stored macro icon overrides `#showtooltip` | wrong icon on every bar addon |
| KickCD `:38-40` | `GetSpellCooldownDuration` mints a fresh object per call | "~10 redundant … emits per second per spell on cooldown" |
| KickCD `:132` | `C_Spell.GetSpellInfo(id).castTime` fully secret in combat vs an interruptible target | unusable as a timeline fallback |
| LootHistory `:28` | `Enum.ItemBind` lies (item 278014 reports OnEquip) | "it has been shipped twice" (`:26`) |
| LootHistory `:39` | The `…_UNTIL_EQUIP` bind globals can be nil at runtime | every warbound-UE drop degrades to plain warbound |
| LootHistory `:71` | `GetCurrencyListInfo` skips collapsed headers | the row keeps `itemSubType = nil` for good |
| MultiMeters `:84-110` | Enemies report `sourceDisplayType` `None`; the PvP dummy is `None` + `WARRIOR` | a mob admitted as a companion row (#56) |
| MultiMeters `:141-145` | `PLAYER_CAN_GLIDE_CHANGED` / `PLAYER_IS_GLIDING_CHANGED` carry a boolean in arg1 | "swallowed both skyriding edges" |
| PartyFrameEnhanced `:63-67` | `UnitExists` on a compound token can be secret in combat | "repainted every hidden button five times a second" (perf capture 20260915-161824) |
| PartyFrameEnhanced `:77` | `UnitIsUnit` on a compound token is always secret | the feature cannot exist |
| WhatGroup `:9-12, 149-160` | A boot-time secure-surface touch taints the GameMenu Logout closure; `SetItemRef` falls through for an unhandled link type | `ADDON_ACTION_FORBIDDEN … 'callback()'` on Logout; a dead chat link |
| WhatGroup `:48-65` | AceGUI containers in a Settings canvas get width 0 until first show | every relative-width widget collapses |
| DropWatcher `:17` | `C_Item.GetItemStats` / `GetItemSpecInfo` answer for the spec you play | wrong eligibility (ITEM-5) |
| DropWatcher `:30` | PrettyChat's defaults spell `LOOT_ITEM_PUSHED*` exactly as `LOOT_ITEM*` | "every loot line read as pushed and your own drops were refused" (a cross-addon quirk inside the collection) |
| AuraMaster `:333-393` | Addon font files load lazily; the aura engine writes a name once | blank bar names for the aura's whole life (#24) |
| AuraMaster `:31-35` | `ShouldAurasBeSecret()` true in every combat context; by-index aura APIs raise (7,500/7,500 calls) | no aura id readable in combat. #8 dropped |
| AuraMaster `:149-155` | `GameTooltip:SetOwner` under a `DisableUntrustedLayoutScriptsTemplate` chain raises | handle tooltip must be owned by `UIParent` |
| DpsRace `docs/known-limitations.md:97-99` | A secret is written to SavedVariables as `nil` | the damage chart is lost across `/reload` (joins Q21) |
| OutfitterReborn `docs/midnight-quirks.md:13-15` | A raise mid `BeginEquipmentUpdate` strands the counter | "silently stopped every later equipment update for the session" |
| QuickComms `docs/known-limitations.md:20-25` | Chat lockdown clears with no event of its own | padlock stays until the next restriction or combat edge (joins Q19) |

---

### A 5. Promotion shortlist (by evidence weight)

1. **Q11: correct `events-frames-taint.md:59` and `:64`** (patch). Six repos, plus the standard's own `frame-layering.md:89`, depend on the fact the text denies.
2. **Q6 + Q7 + Q8: extend §8 beyond printing** (minor). A secret boolean cannot be tested (7 repos), a secret cannot be a key (7 repos), and a frame handed a secret has secret geometry that propagates down anchors (6 repos + library). All three were refused at 2 repos in 2026-09-22 and have since tripled.
3. **Q10: the restriction event facts**, stated with build and date (`Activating` window, types 0/1/5/4 behavior, both payload shapes seen) (6 repos).
4. **Q5: probe `string.format`** before any edit. The standard may be wrong.
5. **Q19 + Q20: "answer at the edge and once more"** and "a valid event can be silent" as a §1/§2 addendum (6 and 4 repos).
6. **Q21: secrets never reach SavedVariables** (savedvariables; 3 repos, one measured).
7. **Q9: name the cooldown escape route** in §8's trigger-set bullet (`isActive`, `SetCooldownFromDurationObject`) (4 repos).
8. Lower: Q12/Q13 (cast-bar pair, 2–3 repos), Q15 (item cache, already the library's), Q16/Q17 (tooltip text), Q22 (testing-§1 mock fidelity), Q23/Q24 after C4 is reconciled.

**On the deferred catalogue (P-07):** if the owner still prefers no catalogue, items 1–7 land in
existing sections and retire roughly 40 of the ≈81 duplicated entries' reasons to exist. Delete the
duplicated local copies once their content is upstream: today ~28 local entries restate Q1–Q4/Q29
material the standard already carries. A catalogue would still be needed for the measured, build-stamped
facts with no rule attached (AuraMaster's restriction-type table, KickCD's probe table, the per-API secret
lists). That is the case for a catalogue with an expiry rule: an entry names its client build and its
probe, and an entry nobody can reproduce is deleted. Four repos already run that rule as
unverified-assumption ledgers (§3 item 9).

---

# Part B — The audit and review corpus (categories 4, 5, 7)


Read-only research, 2026-11-06. Standard measured against: **v2.101.0 (2026-11-04)**. The previous harvest was
2026-09-22 (into v2.63.0). Its C4 findings C4-F02 (toc-file-§5, "failed by eight repos and checked by
nothing") and C4-F04 (citation drift, "the collection's most common deviation class") **did not survive** into
its 04_PROPOSALS/06_OUTCOME accepted list. Its C7-F07 (architecture-§5) and C7-F08 (events-frames-taint-§8)
were not promoted either. Its C5 findings and O1 to O3 were ruled at v2.63.0.

Method: I listed every `docs/audits/<date>/02_DEVIATIONS.md` and `docs/reviews/<date>/01_FINDINGS.md`. A
script split each deviation file into entries and tallied themes per repo and date. The script and its
output are `scratchpad/themes.py` and `scratchpad/themes.txt`. Keyword hits for categories 5 and 4 are in
`scratchpad/c5grep.txt`. A `date:line` in the tallies is the entry's line in that bundle's
`02_DEVIATIONS.md`. Each candidate was then checked against today's section files and `standards/CHANGELOG.md`.
I also checked it against the two remediation bundles that rewrote the standard after the harvest:
Ka0sAddonsCommonTasks `docs/2026-09-23-…/02_UPSTREAM_CHANGES.md` (WS-01..08 → v2.65.0) and
`docs/2026-10-07-…/02_UPSTREAM_CHANGES.md` (WS-01..11 → v2.77.0).
Where an audit could not settle a question, I measured the live trees, and each such measurement is marked.

---

### B 1. Inventory

| Repo | Newest audit | Standard it measured | Newest review |
|---|---|---|---|
| AbsorbTracker | 2026-10-07 | v2.76.1 | 2026-10-07 |
| AuraMaster | 2026-10-07 | v2.76.1 | 2026-10-07 |
| BankLedger | 2026-10-07 | v2.76.1 | 2026-10-07 |
| ConsumableMaster | 2026-10-07 | v2.76.1 | 2026-10-07 |
| DpsRace | none | none | none |
| DropWatcher | 2026-10-14 | v2.80.0 | 2026-11-05 |
| KickCD | 2026-10-07 | v2.76.1 | 2026-10-07 |
| LibKa0sSkinTester | none | none | none |
| LootHistory | 2026-10-07 | v2.76.1 | 2026-10-07 |
| MultiMeters | 2026-10-07 | v2.76.1 | 2026-10-07 |
| OutfitterReborn | 2026-11-04 | v2.96.0 | 2026-11-04 |
| PanelMaster | 2026-10-07 | v2.76.1 | 2026-10-07 |
| PartyFrameEnhanced | 2026-10-07 | v2.76.1 | 2026-10-07 |
| PremadeGroupsFilterExtension | 2026-10-10 | v2.78.0 | 2026-10-10 |
| PrettyChat | 2026-10-07 | v2.76.1 | 2026-10-07 |
| QuickComms | 2026-10-25 | v2.88.0 | 2026-10-25 |
| WhatGroup | 2026-10-07 | v2.76.1 | 2026-10-07 |
| LibKa0s | 2026-10-07 | v2.76.1 | 2026-10-07 |
| WowAddonStandards | 2026-10-07 | v2.76.1 | 2026-10-07 |
| dev-copilot | 2026-10-07 | v2.76.1 | 2026-10-07 |

There are 66 post-harvest bundles. Every audit dated 2026-09-23 or later counts (09-23, 10-07, PGFE 10-09/10,
DW 10-11/14, QC 10-13/25, OR 11-04). **Corpus caveat:** 13 of 18 audited repos were last audited at
v2.76.1. Twenty-five standard releases, including the whole skinning series v2.89 to v2.100, have never
been audited in those repos. DpsRace and LibKa0sSkinTester have never been audited.

---

### B 2. Category 4: recurrence and cross-repo deviations

#### 4-A. documentation-§5 drift: every repo, every audit, and mostly hand-stated counts and in-repo `file:line` (LIVE)

- **Breadth.** documentation-§5 is failed in **17 of 18** newest audits. PGFE is the exception, because
  PGE-22 closed. AT-80, AM-37, BL-45, CM-97, DRW-07, KICKCD-C-08, LH-73, MM-A-24, OR-01, PM-044, PFE-01,
  PC-104, QC-24, WG-77, LK-29, WAS-01..13 and DC-06..09 all fail it.
- **Recurrence.** It was filed at every date in every repo, for example
  `PartyFrameEnhanced 09-15:26 PFE-01 → 09-23:44 PFE-01 → 10-07:34 PFE-01` and
  `ConsumableMaster 09-07 CM-75 → 09-08 CM-82 → 09-23 CM-94 → 10-07 CM-97`.
- **What drifts.** In 12 repos the drifted items are hand-written counts of the repo's own tree, or in-repo
  `file:line` citations:
  - AT-80: "*thirty-two files* in four places … `LibKa0s.xml` lists **34**".
  - LH-73: "47 shims — the standard's grep answers **57**", "1296 lines — it is **1476**", "**Seven** TOC
    positions … carries **nine**".
  - KICKCD-C-08: "Eight do … The tree has **9 and 41**".
  - DRW-07: "Ninety-four authored files … The TOC loads **97**" and "62 … gives **83**". Its fix direction
    reads "Better, drop the spelled-out file count".
  - OR-01a: "14 commands … **35**", "73 hand-written shims … **77**". Its fix reads "state them without a
    count that rots".
  - QC-08: "27 shims; the documented grep answers **31**".
  - PFE-01(3): "15 shims".
  - CM-97: "**19 `file:line` citations in `docs/ARCHITECTURE.md` point at the wrong lines**".
  - LK-29: "44 lines of room … **42**".
  - WAS-01b: "Drop the hard count".
  - DC-08: "61 tracked files … the tree has 62". `scripts/bounded-runs-hook.sh:33` is past the end of a
    31-line file.
  - MM-A-24: hub inventory.
- **Today's rule.** documentation-§6 (`documentation.md:707-726`) has the discipline: no bare line number in
  a present-tense citation, and counts written as a rule or dated. It is scoped to "**another repo's** code"
  and to "a present-tense count or inventory **of the collection**". An addon's counts of its own tree and
  its own in-repo `file:line` citations are outside it. v2.78.2 applied the rule to the standard's own text
  only.
- **Filter.** **Live.** The previous harvest's C4-F04 named the same class and was not promoted. The class
  has since recurred in two more audit rounds. Reading A: the collection is non-compliant and owes one sync
  pass per repo. Reading B: the rule shape manufactures the failure, and extending §6's count and citation
  form to in-repo docs would remove most rows.

#### 4-B. toc-file-§5 load-bearing annotations: 14 repos, recurring after two rewrites, and no gate (LIVE)

- **Breadth.** 14 repos have filed it since 2026-09-07. In the newest audits, 6 repos fail it:
  - AT-84/AT-85 (10-07:51-52)
  - CM-98 (10-07:31)
  - LH-78, with dependents LH-79..81 (10-07:41)
  - DRW-08 (10-14:136)
  - PGE-06/07/08/28 (10-10:60-63)
  - QC-26 (10-25:46)
- **Recurrence within one repo.** AbsorbTracker files it at 09-08 (AT-64/65), 09-23 (AT-64/65/69/70/71) and
  10-07 (AT-84/85). ConsumableMaster files it at 09-07, 09-08, 09-23 and 10-07. LootHistory files it at 09-08,
  09-23 and 10-07. PGFE files it at 10-09 and 10-10. QuickComms files it at 10-13 (QC-10) and 10-25 (QC-26).
- **The rule has been rewritten twice.** v2.77.0 (WS-04) widened the denominator to every position. v2.81.0
  (DW F23) made the test positional and added kind (b), "a row appended to a TOC-ordered table". QC-26 is a
  kind (b) failure *after* v2.81.0: "every one is labeled `# Conventional: data` … even while naming the
  constraint".
- **Gate.** No gate exists. LibKa0s `testkit/` has no TOC-annotation check. The six `tests/test_loadorder.lua`
  (AT, AM, DpsRace, MM, OR, PFE) check that load lists derive from the TOC, not the labels. Only `AUDIT.md`
  (lines 434-448) checks it.
- **Filter.** **Live.** It is the same finding as 2026-09-22 C4-F02, which was not promoted. The fix does not
  stick and the standard has no mechanical gate.

#### 4-C. The documentation-§3 hub: spill MUST and ~400-line SHOULD (LIVE; measured in today's trees)

- **Newest audits.** AM-25, LH-60, DRW-03 and QC-22 fail the MUST. PM-042, MM-A-06, PFE-27 and PC-105 fail
  the ~400 SHOULD. That is 8 repos. MM-A-06 recurs at 09-07, 09-08, 09-23 and 10-07. LH-60 recurs at 09-08,
  09-23 and 10-07.
- **Today's trees** (`wc -l docs/ARCHITECTURE.md`, measured 2026-11-06). **14 of 17** addon hubs are over 400
  lines: BL 739, DpsRace 732, MM 704, LH 666, CM 649, PFE 620, KC 603, AT 574, DW 558, WG 534, PGFE 519,
  AM 498, PM 486 and PC 467. Only SkinTester (138), OR (312) and QC (400) are under.
- **New since every audit: a `## Skins` hub section in 14 of 17 hubs, 70 to 197 lines long.** CM is 197,
  KC 164 and PFE 133. The section was added by the 2026-10-29 skinning rollout (for example KickCD
  `81c497c` "KC-05: Document the skin: ARCHITECTURE…"). It is not one of documentation-§3's ten mandated
  sections, so the spill MUST (`documentation.md:362-372`, which binds *mandated* sections) does not reach
  it and it has no named spill target. skinning.md says nothing about docs. Event Subscriptions is also past
  60 lines in BL (61), DpsRace (98), DW (84) and LH (86). Taint Notes is past 60 in DpsRace (100).
- **Filter.** **Live.** It has not been settled since v2.81.0, which only added spill targets. This is a
  category 7 candidate (see §4).

#### 4-D. slash-commands-§1: the degraded stub copies `FormatRow`'s em-dash row (LIVE; 2 live repos, unfiled)

- **Filed after the v2.65.0 rule.** The rule reads "In particular it MUST NOT copy `FormatRow`.
  A degraded help row prints `cmd  desc` plainly … no em dash", at `slash-commands.md:31`. It was then
  filed as AM-38 (10-07:172), PM-050 (10-07:95) and QC-17 (10-25:37), and earlier the 09-23 PFE-23 asked
  "how the two rules interact". AM, PM and QC are fixed today.
- **Still failing today and unfiled.** I measured these 2026-11-06:
  - `DropWatcher/settings/Slash.lua:124` `helpRow … " — " .. entry[2]`
  - `PremadeGroupsFilterExtension/settings/Slash.lua:79` `helpRow … " — " .. entry[2]`

  Neither newest audit (DW 10-14, PGFE 10-10) filed it.
- **Gate.** No gate exists. The kit pins only `DISABLED_LINE_FORMAT` (`Kit.assertLibraryConstant`), not the
  help-row shape.
- **Filter.** **Live**, with 5 repos failing since the ruling. It is a recurrence of the rule, not a rule
  change. The standard-side companion is the stub-burden question in 5-E.

#### 4-E. slash-commands-§7 conformance suite gaps (mostly SETTLED v2.81.0; one inventory gap is LIVE)

- 13 repos have filed it since 09-23. In the newest audits it is DRW-04, QC-03 (recurring 10-13 and 10-25),
  PGE-05 (10-09 and 10-10), OR-06 and MM-A-30.
- v2.81.0 settled the reading: step 6 must prove reach (F22) and `AUDIT.md` walks steps 1-10 (F29). That is
  **settled-by v2.81.0**.
- **Live gap.** The kit ships the step-10 helper `Kit.assertLatchHoldOrder` (`LibKa0s/testkit/latch.lua`,
  kit revision 39: "every addon in the collection wrote it by hand"). Only DpsRace, DropWatcher and
  OutfitterReborn use it. `grep -rn assertLatchHoldOrder WowAddonStandards/standards WowAddonStandards/AUDIT.md`
  returns **0**, so the standard never names it. This is the same shape as the 2026-09-22 C8 findings.

#### 4-F. Re-vendor bundle missing (SETTLED by practice; recurred twice)

- AT-82, AM-21, BL-41, CM-91, KICKCD-C-01, MM-A-19, PM-048, PFE-26, PC-103 and WG-71: the same two tags,
  v1.69.0 and v1.70.0, were missing in 10 of 11 addons at 10-07. Every one was "a plain `chore:` re-vendor
  that bypassed `/dev-copilot:wow-revendor-libka0s`" (PFE-26). Nine of them had already been filed at 09-23,
  where PC-82 was 26 tags.
- **Today** (measured): every addon's newest `docs/revendor/` bundle matches its `CLAUDE.md` provenance tag
  (v1.85.0 to v1.89.0).
- **Settled-by practice** after the 2026-10-07 remediation. No newer audit confirms it.

#### 4-G. Smaller recurring classes

| Class | Repos | Status today |
|---|---|---|
| Raw `lizard` quoted as the complexity gate: AT-83, CM-100, LH-84, MM-A-29, PM-054 | 5 (all at 10-07) | Ripple debt from v2.74.0; not re-filed in DW, QC or OR. **Settled-by remediation.** MM-A-29's "owner decides" on the lizard pin is a one-repo call. |
| Kit `--list` Totals fold skips (testing-§5): LH-88, KICKCD-D-03, BL-53, AT Info-4, plus reviews AT F-007, AM F-003, PM F-009, PC F-007 | 7 | **Settled-by** kit revision 38 (LibKa0s v1.71.0, 10-07 remediation LK-01). |
| Compat dead fallback rung: MM-A-27, PM-051, LK-39 | 3 | **Settled-by** remediation LK-06. |
| architecture-§5 named state or writers: LH-86, PM-052, PGE-02 (recurring 10-09 and 10-10), QC-23, OR-04, plus 09-23 AM-33, BL-43, PM-039 | 9 | **Live** as a class (prior C7-F07, not promoted). PGE-02 carries issue #10. |
| debug-logging-§9 hand-rolled log-on-change memo: AT-87, PGE-25, CM-101, QC-11 | 4 | **Live, minor.** CM-101 asks the library for a counting `DebugChanged`; `DebugLogGates.lua:138` has no count. AT memo `modules/Display.lua:391` is still present. |
| events-frames-taint-§8 pre-formatting (SHOULD): AT-78 (09-08, 09-23, 10-07), LH-77, plus earlier KC, WG, BL, AM, PM | 7 | **Live** as a SHOULD (prior C7-F08). |
| Issue `state:` label disagreeing with open/closed: AT, AM, BL, CM, KC, LH, PM-055, PFE, LK-40, OR-09 | 10 | **Live, small.** Measured 2026-11-06 with `gh`: KickCD#38 and MultiMeters#60 are closed and still `state:triaged`. Recurs after 2026-09-22 C6-F11. |
| automated-tests-§4 "record N commits behind HEAD" Info: 14 repos, every audit (for example PC-76 at 09-07, 09-08, 09-23 and 10-07, and PM-033) | 14 | Not a rule failure, because the checkpoint is the release. It is **audit noise**: one Info row per repo per audit with no action. A playbook question rather than a standard one. |

---

### B 3. Category 5: tensions and silences inside the standard

The settled list first, so nothing below is re-argued:

| Candidate (source) | Settled by |
|---|---|
| PC-84 "**The standard contradicts itself here**": events-frames-taint-§1 against library-stack-§1 (PC 09-23:75) | v2.65.0 WS-04 |
| PC-93 compat "every addon MUST ship" against an addon with zero shims (PC 09-23) | v2.65.0 WS-05 |
| KICKCD 09-23:123 reserved verbs in a sub-tree; WG-56 `Tab \| Covers` granularity; WG-82(3) `.png ships`; WG F-015 minimap CLI polarity | v2.65.0 WS-06 and WS-07 |
| WG F-003 `schemaVersion` as an AceDB default | v2.65.0 WS-03 |
| PC-69 testing-§8 against options-ui-§13 on who pins a library strip | v2.65.0 WS-06 |
| PC-100 architecture-§1 `addonName` against lint's `211` | v2.75.0 / v2.77.0 (KICKCD-C-08 cites "v2.75.0's `addonName = addonName`") |
| DC U-1 line-endings-§7 test_eol MUST against documentation-§8 (dev-copilot 10-07:47 "a contradiction between two MUSTs") | v2.77.0 WS-03/WS-05 (`line-endings.md:446`, `:570` scope it) |
| DC U-2 documentation-§8 three triggers then one; WAS-07, WAS-09, WAS-10; LK U3 | v2.77.0 WS-05 |
| DC U-3 / DC-12 versioning-git trunk-based against the collection's feature branches | v2.77.0 WS-08 (`versioning-git.md:14`) |
| LK U2 compat worked case against `Env.lua` "deprecated but still present" | v2.77.0 / LK-06 |
| WG review F-008 events-frames-taint-§8 cooldown fields missing | v2.77.0 WS-09 (`GetSpellCooldown` 3 hits) |
| DW U-1..U-6 (F23 toc-file-§5 positional against reads-at-load, F24 spill against architecture-§5 naming, F25 spill targets, F26 options-ui-§19 reparent, F27 refusal by hold, F28 compat "member") | v2.81.0 |
| PGE-23 options-ui-§15 extras justified by §16 | v2.84.0 (Master controls may carry addon-wide rows after the canonical set) |
| OR-05 public-api "the section's two MUSTs disagree on the path" | v2.99.1 erratum (2) |
| QC-20 `.jpg` logo ships | packaging template now carries `media/logos/*.jpg` (`packaging.md:30`) |

**Live entries:**

**5-A. options-ui-§17: no `disabledIf` on a swatch, against a feature that is wholly off. VOTE for the
open-evolutions entry "Gating a swatch on its feature's own switch (deferred, owner call CALL-05)".**
- QC-18 (QuickComms 10-25:38): "Eleven color pairs gray out on their feature's switch". It is now a
  ratified register row, `QuickComms/docs/ARCHITECTURE.md:384`.
- AuraMaster AM-03 is an `options-ui-§17` register row (09-11:76, accepted at 10-07:234).
- WowAddonStandards#13 is open, `state:triaged`.
- Rule unchanged: `options-ui.md:497` "`disabledIf` on a color row is forbidden".
- **Live**, 2 repos, both holding ratified rows against the rule.

**5-B. slash-commands-§7 survivors name only `hooksecurefunc`, and a one-shot third-party registration is
unnamed. NOT in open-evolutions.**
- PGE-29 (PGFE 10-10:81): "`EllesmereUI.RegisterSkin(…, onFacade)` has no unregister … §7's carve-out names
  only `hooksecurefunc` bodies, so a one-shot third-party callback is unnamed rather than non-compliant."
  Its fix direction: "Upstream: name the one-shot third-party registration in §7's survivor list".
- WowAddonStandards#10 is open.
- Today's text is unchanged (`slash-commands.md:212`, "The one sanctioned exception is a hook that cannot
  be undone"). `grep -i 'third-party\|one-shot' slash-commands.md` returns 0.
- **Live**, 1 repo.

**5-C. Chat an addon sends on the player's behalf has no rule. NOT in open-evolutions as a rule question;
only LibKa0s#49's chat *sender* rejection is there.**
- DropWatcher register row `docs/ARCHITECTURE.md:542`: "**(no rule yet)** chat sent by an addon | The addon
  whispers and posts to group chat on the player's behalf". DRW-09 re-checked it at 10-14.
- WowAddonStandards#11 is open: "Proposal: a rule for chat an addon sends on the player's behalf".
- QuickComms is a chat-sending addon with no such row.
- **Live**, with 1 ratified repo and a second exposed one.

**5-D. frame-layering-§4: the catcher prohibition covers transient popups only and is silent for a secure HUD
popup that cannot use `GLOBAL_MOUSE_DOWN` in combat.**
- QC-30 (QuickComms 10-25:50): "`frame-layering-§4` forbids a catcher behind a **transient popup** (T8) but
  says nothing for a secure **HUD popup** (T3)". Its fix: "Ask upstream whether T3 secure…".
- Today's text (`frame-layering.md:86-87`) still has the catcher sentence under transient popups only.
- **Live**, 1 repo. It was recorded in QC's Known Limitations, not its register.

**5-E. library-absent stubs: mandated in full, though the packager can never produce a library-less install.
VOTE for the open-evolutions entry "Whether an adopted major needs a full library-absent stub (recorded,
not ruled)".**
- PrettyChat review 10-07 F-008: "**758 lines of degradation stubs serve an install the packager cannot
  produce** … `library-stack.md:110` mandates these stubs … The question belongs to the standard."
- Supporting evidence (4-D): the stub's one prescribed detail, the plain help row, is still copied wrong in
  DW and PGFE, and was copied wrong in AM, PM and QC after the rule.
- **Live**, 1 voice plus 5 repos as evidence of cost.

**5-F. events-frames-taint-§1 unit-filter frame: "filter `UNIT_*` events" (plural) against "not a budget to
spend on a second event".**
- AuraMaster 10-07, *Checked and not filed* (`02_DEVIATIONS.md:252-257`): "`CM.viewFrame` and
  `CM.viewPlayerFrame` each filter **two** `UNIT_*` events (`UNIT_FACTION`, `UNIT_FLAGS`) … The wording is
  ambiguous enough to raise upstream."
- Today's text is unchanged (`events-frames-taint.md:17` "filter `UNIT_*` events", `:19` "not a budget to
  spend on a **second** event").
- **Live**, 1 repo.

**5-G. options-ui-§15: a one-shot test action "MAY stay beside" a Test mode row that a frameless addon does
not have.**
- PrettyChat 10-07 register check (`02_DEVIATIONS.md:77`): "For a frameless addon the standard still names
  no place."
- Today's text is unchanged: `options-ui.md:420` "MAY stay beside it as a verb or the composer's
  `leadButton`", with "Two kinds of addon omit the row. A frameless addon …".
- **Live**, 1 repo, low value.

**5-H. Extension addons (an addon that extends another addon's frame) have no rule.**
- PGFE register rows PGE-R01 and PGE-R02 (10-10:47-48) have the triggers "the standard gains an
  extension-addon rule" and "… or the standard gains a carve-out".
- PGE-17: an attached panel wears PGF's or EllesmereUI's chrome, not the Ka0s edge.
- PGE-19: "The owner has not recorded whether an attached panel counts as frameless".
- `grep -i extension` over library-stack, standalone-windows and toc-file finds no such rule.
- **Live**, 1 repo with 4 rows.

**5-I. The packaging template is silent on `media/screenshots`, which layout-§1 sanctions and every addon
ignores.**
- AM-40 (AuraMaster 10-07:215): "No rule fails here … layout-§4 names `media/screenshots/` as a legitimate
  folder, and packaging's template does not mention it … **This is the owner's call** … the template change
  belongs upstream".
- Today, measured 2026-11-06: all **15 of 15** addons that track `media/screenshots/` carry
  `- media/screenshots` in `.pkgmeta`, under five different comments. That covers 39 MB in LootHistory,
  26 MB in AuraMaster and 12 MB in PanelMaster.
- `packaging.md:15-31` has no such line, while `layout.md:118` names the folder.
- **Live** as a convergent practice the standard is silent on. It is a clear win.

**5-J. documentation-§6's count and citation discipline stops at the collection and other repos.** This is
the standard-side half of 4-A. **Live.**

---

### B 4. Category 7: MUSTs that many repos fail

| Rule | Repos failing (newest audits) | Reading A: the collection is non-compliant | Reading B: the rule is wrong or ill-shaped |
|---|---|---|---|
| documentation-§5 keep docs in sync | **17 of 18** | One sync pass each; `/dev-copilot:sync-docs` exists. | 12 of 17 fail on self-counts and in-repo `file:line` that §6 lets authors write; the rule invites the drift it forbids (4-A, 5-J). |
| documentation-§3 hub spill MUST and ~400 SHOULD | 8 in audits; **14 of 17** hubs over 400 lines today | Spill sections to their targets. | The ~400 SHOULD is failed by about 82% of hubs, and the largest section in 14 hubs (`## Skins`) is non-mandated and has no target, so the spill MUST cannot shrink it. The rule needs a target for a non-mandated section, or a cap on what may live in the hub. |
| toc-file-§5 annotations | 6 of 18, and 14 since 09-07 | Annotate. | It recurs after two rewrites (v2.77.0, v2.81.0) with no mechanical gate, so the rule is not the problem; the missing gate is. |
| slash-commands-§1 stub row | 5 since v2.65.0, 2 live (DW, PGFE) | Fix 2 lines. | Tied to 5-E's stub-burden question. |
| audit-review-history re-vendor bundle | 10 of 11 at 10-07 | Held today. | **Settled-by practice.** |
| slash-commands-§7 conformance suite | 5 in newest audits | Fill the steps. | **Settled-by v2.81.0**, plus the unnamed kit helper (4-E). |

**No section qualifies for a retirement question this round.** public-api now has a consumer (OR-05, settled
by v2.99.1). This corpus did not re-examine launcher, which was the previous harvest's C7-F05.

---

# Part C — Convergent, divergent and emergent patterns (categories 1, 2, 9)


Read-only sweep, 2026-11-06, of the 17 roster addons' addon-owned code (`core/ modules/ settings/
defaults/ tools/ tests/`, excluding `libs/` and `tests/_kit/`) against standard v2.101.0 and
`standards/standards/open-evolutions.md` (OE). LibKa0s checked at `LibKa0s/LibKa0s/*.lua`,
`testkit/` and `docs/api/`. Repos were read on their checked-out branch (all `master`). Line numbers
are at the working tree as read today.

Labels: **STD** = standard change (codify or pick one). **LIB** = LibKa0s change (library major or
testkit). **WATCH** = below the evidence bar or a likely §7 rejection.

---

### C 1. Convergent patterns (3+ addons, standard silent)

#### C1. Keyed combat-end queue: LIB (new member, Lifecycle or Core), plus STD shape
Four addons built the same thing: `Run(key, fn)` runs now out of lockdown, otherwise files fn under
key, **latest wins**, first-queued order, drained on `PLAYER_REGEN_ENABLED`.
- OutfitterReborn `core/SecureQueue.lua:1-40` (`NS.SecureQueue.Run/Flush/Clear`; registers the event only while something waits; pcall per entry; `Clear` for stand-down)
- PartyFrameEnhanced `core/PartyFrameEnhanced.lua:62-74` (`NS.RunSecure(key, fn)`), flush `:94-107` (xpcall + `geterrorhandler`)
- QuickComms `modules/SendEngine.lua:294-315` (`SE.Queue`, `SE.RunOrQueue(key, fn)`, `SE.Drain`)
- WhatGroup `modules/Frame.lua:289-305` (`NS.FrameQueueForCombatEnd(key, fn)`, drained in a **fixed** `COMBAT_END_ORDER`)

Where they differ: error isolation (pcall at OR, xpcall+geterrorhandler at PFE, "one line" at QC, none visible at WG); order (insertion order vs a fixed table at WG); registration (only while waiting at OR, permanent elsewhere); stand-down clear (OR only, explicit). events-frames-taint-§2 (`events-frames-taint.md:53,64`) requires the defer-and-replay but never says what shape it takes. The library already has the internal idea, a parked queue registered only while something is parked (`LibKa0s/OptionsRegistry.lua:57-70`), but does not export it. Not in OE.

#### C2. Coalesced refresh ("one run per burst"): LIB (Lifecycle-aware `Coalesce`), with a real bug as evidence
- KickCD `core/Util.lua:186` `Util.Throttle(ms, fn)` (last-args, `C_Timer.NewTimer`)
- LootHistory `core/Util.lua:292` `Util.Coalesce(fn, delay)` on `NS.After` (`core/LifecycleSetup.lua:61`). Its comment documents a shipped bug: a flag that is cleared only inside the body stays set when the stand-down cancels the timer, so the surface froze for the session after `/lh disable`.
- BankLedger `modules/Browser.lua:472,489` (AceTimer `ScheduleTimer`, two hand copies), `modules/Insights.lua:706`, `modules/Ledger.lua:624`
- DropWatcher `modules/Window.lua:716-730` (`C_Timer.After(0)` with a boolean flag, and no cancel on stand-down)
- OutfitterReborn `modules/Bar.lua:409-418` (AceTimer at 0 s, checks `IsStoodDown` when it fires), plus `Companion.lua:87`, `Equip.lua:94`, `Inventory.lua:395`, `States_Zone.lua:118`
- AuraMaster `modules/EmptyWatch.lua:271`, `modules/TimedSpells.lua:112`

The copies use four different timer APIs and three stand-down policies, and only LH survives a cancelled handle. DW's `C_Timer.After` has no headless fallback, where LH and BL run inline when no timer exists. Lifecycle (`LibKa0s/Lifecycle.lua:108-224`) owns the stand-down but ships no tracked deferral. OE has nothing on it. performance-§ and slash-commands-§7 forbid a stray timer but do not give the shape.

#### C3. Secret-safe `PlainString` / `PlainNumber`: LIB (Compat), reopens a recorded rejection
Same semantics everywhere (nil unless non-secret and of the right type):
- DpsRace `core/Secrets.lua:70,81,91` (`Secrets.PlainNumber/PlainString/PlainTruth`)
- OutfitterReborn `core/Secrets.lua:77,87,109` (copied from DpsRace through `docs/superpowers/specs/2026-11-03-dpsrace-blueprint.md`, so §7 bar 3 treats it as a same-author copy)
- QuickComms `core/Compat.lua:63,69` (`Compat.PlainNumber/PlainString`)
- DropWatcher `core/Compat.lua:40,46` **and again** `core/CompatCollect.lua:22,27` (two local copies in one addon)
- MultiMeters `core/Secrets.lua:267,294,333` (`PlainTruth`, `CanAccessTable`, `SafeIterate`), and the same table members at DpsRace `core/Compat.lua:75` and OR `core/Compat.lua:88`

LibKa0s Compat ships only `IsSecret`/`IsSafeKey` (`LibKa0s/Compat.lua:110,138`). Its API doc (`docs/api/Compat/version-1-docs.md:287`) filed "the table members, SafeIterate" under **One consumer** when only AM and MM had `Secrets.lua`. There are now four `core/Secrets.lua` files (AM, DR, MM, OR), and QC and DW hold independent Plain readers, so the census is stale. **OE vote:** *Further LibKa0s modules* (Compat: "what the collection still duplicates beyond those").

#### C4. Window/frame position save and restore: STD (pick the stored shape), LIB candidate (Widgets)
Fourteen implementations in thirteen addons: AbsorbTracker `modules/Bar.lua:25`; AuraMaster `modules/Anchors.lua:431`; ConsumableMaster `modules/MacroBar.lua:108,117`; DpsRace `modules/Hud.lua:369`, `modules/Results.lua:90`; DropWatcher `modules/Window.lua:319`; KickCD `core/Util.lua:41`, `modules/Castbar_Frame.lua:87`; LibKa0sSkinTester `core/Util.lua:20,30`; MultiMeters `modules/Window_Placement.lua:65,78`; OutfitterReborn `modules/Bar.lua:484`, `modules/UIDialogs.lua:102`; PartyFrameEnhanced `modules/Anchor.lua:423`; QuickComms `modules/Pad.lua:95`; WhatGroup `core/Util.lua:50-85` (`NS.Windows.PointOf/Save/Restore`, the same file as the tester's).

They diverge in the **stored field name**: `relPoint` in AT, CM, LST, PM, QC and WG, and `relativePoint` in DR, MM, PFE and most of KC. AuraMaster uses both spellings (10 against 8 assignments). Rounding happens only at DR (`Hud.lua:375`). `GetPoint()` and `GetPoint(1)` are mixed, and the fallback is either CENTER (KC, MM) or no write (WG, DR). standalone-windows (`standalone-windows.md:10`) says MUST persist without giving a shape, and the field name is a SavedVariables schema fact that a later library adoption would have to migrate. The DragHandle's `onDragStop` (`LibKa0s/WidgetsDragHandle.lua:920`) leaves saving to the host. **OE vote (partial):** *Whether an unlock anchor has to be the library's handle*. Its "what the eight non-consumers actually draw" survey would find these persistence copies.

#### C5. Chat capture in tests: LIB (testkit `Kit.captureChat`)
`capture*`/`captureChat` helpers appear in tests of 14 repos (counted by name: AT 11, AM 13, BL 12, LH 10, KC 5, PM 3, PC 3, CM 2, MM 2, PFE 2, DW 1, PGFE 1, WG 1). Byte-identical copies sit **three times in one repo**, BankLedger `tests/test_debuglog.lua:9`, `tests/test_disabled.lua:63` and `tests/test_launcher.lua:36`. The variants diverge: a table return (BL) against a `concat`-ed string (AT `tests/test_debuglog.lua:101`); `error(err, 0)` against `error(err)`; swapping `DEFAULT_CHAT_FRAME.AddMessage` against slicing `T.mocks.__chat` (PanelMaster `tests/test_slash.lua:11`). The testkit has no capture helper (`testkit/asserts.lua` lists only assert*), and testing.md says nothing about it.

#### C6. `tests/mock_menu.lua`: LIB (move into testkit)
Twelve addon copies (AT, AM, CM, KC, LST, LH, MM, PM, PFE, PC and WG as `mock_menu.lua`; BankLedger as `menu_mock.lua`), 93 to 122 lines each, about 1,300 lines in total, with **11 distinct md5s**. The file's own header says why: *"Modeled on LibKa0s's own tests/mock_menu.lua, which is repo-local there and not in the kit, so a consumer keeps its own"* (AbsorbTracker `tests/mock_menu.lua:9-10`; library copy `LibKa0s/tests/mock_menu.lua`). OutfitterReborn swaps in a one-line `MenuUtil` per test instead (`tests/test_launcher.lua:14,41`). The standard and the kit README never mention it.

#### C7. Test deep-equal and deep-copy: LIB (testkit: expose `deepcopy`, add `assertDeepEqual`)
Locally defined `deepEqual` in KickCD `tests/test_sim_e2e.lua:28`, `test_sim_interference.lua:39`, `test_sim_session.lua:58` and `test_units.lua:271`; LootHistory `tests/test_schema.lua:357` and `test_testdata.lua:12`; OutfitterReborn `tests/test_em_sync.lua:83`; BankLedger `tests/sim_support.lua:196`. A local `copy` is repeated **seven times** in DpsRace tests (`test_insights.lua:665`, `test_results*.lua:44/32/42/39/52/40/40`), alongside BL/KC/PM/CM `wow_mock.lua` deepcopies. The kit already has one but keeps it private (`testkit/mock_base.lua:89,276` `M.__deepcopy`).

#### C8. Generator `--check` mode, and a generator the gate actually covers: STD (layout, generator section)
- `--check` (write nothing, exit 1 on drift): PanelMaster `tools/artwork/update_catalog.py:18`, `tools/sunn/build_manifest.py:32,187`; AuraMaster `tools/spell-research/research.py:1918` (`--check-shipped`); OutfitterReborn `tools/rekey-locales.lua` (header).
- **OutfitterReborn alone** writes its generators in Lua and loads them from the suite: `tests/test_locale.lua:410` (`dofile(T.root .. "/tools/rekey-locales.lua")`), `:546`. That is the direct answer to layout's "a non-Lua generator sits outside the green gate" (`layout.md:96`), which today offers only SHOULD habits. Candidate rule: a generator SHOULD have `--check`, and a Lua generator whose check runs in the suite is the preferred form.

#### C9. One table deep copy per addon (runtime): STD (WATCH as LIB)
Identical recursive `DeepCopy` sits in `core/Util.lua` or `core/Database.lua` of AuraMaster `core/Database.lua:15`, KickCD `core/Util.lua:145`, LootHistory `core/Util.lua:17`, PanelMaster `core/Util.lua:311` and PartyFrameEnhanced `core/Util.lua:35`. Local `copy`/`deepcopy` functions add about 40 more definitions in all 17 repos, **ten in DropWatcher alone** (`modules/Gear.lua:79`, `Inspect.lua:492`, `SimWorld.lua:493`, `WindowInsights.lua:42`, `settings/Editors.lua:25`, `Schema.lua:22`, `SchemaSetup.lua:19`, …). Only ConsumableMaster uses the client's `CopyTable` (`settings/MacroBar.lua:711`). As a library member this is frequency with low content, which §7 rejects (as in the *#56 "Solid"* row). The useful ruling is a standard line: one copy per addon, or `CopyTable`. WATCH-grade for LIB.

---

### C 2. Divergent patterns (same problem, N solutions)

#### D1. The SkinSetup host glue: LIB (a host factory on `LibKa0s-Skin-1.0`)
`core/SkinSetup.lua` exists in all 17 addons and totals **11,779 lines**, from 264 lines (LST) to 900 (BL); see `wc -l */core/SkinSetup.lua`. A function-name census finds the same roughly 20 host functions in 15 or 16 files: `NS.WriteSkinChoice`, `NS.SkinChoice`, `NS.ApplySkinChoice/Ignore/Override/Outline`, `NS.SkinPaintAceTree`, `NS.MaybeShowSkinPicker` (defined twice in some files, 30 definitions over 16 files), `NS.HideSkinPicker`, `NS.RunSkinVerb`, `NS.MaybeShowSkinNotice`, `NS.SkinPickerSpec`, `NS.SkinOverride`, and the locals `storedKey`, `storedIgnore`, `pickerDue`, `pickerClosed`, `noticeGlobal`, `dropPickerDeferral` (12). The copies drift cosmetically: compare AbsorbTracker `core/SkinSetup.lua:133-147` with PartyFrameEnhanced's `WriteSkinChoice` (`local set = NS.SetByPath` against bare calls). The library's documented host example (`docs/api/Skin/version-16…-docs.md:360-390`) is about 20 lines, while the real hosts run 560 to 900, and skinning-§1 (`skinning.md:14`) only says "one setup file". **OE votes:** *A per-addon adoption command* (adoption keeps growing per-host files) and *Whether an adopted major needs a full library-absent stub* (the degraded Skin facade at `AbsorbTracker core/SkinSetup.lua:398-477`).

#### D2. Schema library-absent stub: five names, 17 copies of SplitPath and copy: STD or OE ruling
Every addon re-implements `SplitPath` and a deep copy inside its Schema stub, under five different host-object names: `stubLib` (AT `settings/Schema.lua:99`, CM `settings/SchemaStub.lua:43`, KC `settings/SchemaSetup.lua:227`, LH `settings/Schema.lua:685`, PM `settings/Schema.lua:327`), `Stub` (DR `settings/Schema.lua:24`, OR `settings/Schema.lua:39`), `HostSchemaStub` (DW `settings/SchemaSetup.lua:25`, LST `:50`, PFE `settings/Schema.lua:60`, PGFE `settings/SchemaSetup.lua:20`, QC `:25`, WG `:50`), `stub` (BL `settings/Schema.lua:696`, MM `settings/Schema_Paths.lua:113`), `SchemaStub` (PC `settings/SchemaStub.lua:38`), and AM's `hostSplitPath` (`settings/Schema.lua:145`). The file home diverges too: `Schema.lua`, `SchemaSetup.lua` or `SchemaStub.lua`. **OE vote:** *Whether an adopted major needs a full library-absent stub (recorded, not ruled)*, which can add this count to PrettyChat's 758-line figure. If stubs stay, the standard should name the stub object and file.

#### D3. Player "Name-Realm" key: five shapes, one correctness split: LIB (Compat) or STD
- BankLedger `core/Compat.lua:36-42` and LootHistory `core/Util.lua:6-12` fall back to `GetRealmName()`, strip **whitespace only** (keeping the hyphen), and write `"Unknown"` into identity.
- DropWatcher `core/Compat.lua:270-279` strips spaces **and hyphens** (matching the normalized form), returns nil when nothing is known, and is secret-guarded.
- QuickComms `core/Compat.lua:130-153` tries `UnitFullName` first, then `GetNormalizedRealmName`, secret-guarded. The same code sits twice in one file (`playerFullName` and inside `PlayerIdentity`).
- OutfitterReborn `modules/Triggers_Params.lua:321-330` builds a target key, secret-guarded.

On a hyphenated realm, the BL/LH fallback produces a different key from the normalized one, so a row written early in login (when `GetNormalizedRealmName` is nil) would be keyed under a different character. LibKa0s has no realm reader (`grep Realm LibKa0s/{Compat,Env,Core}.lua` is empty) and the standard never mentions `GetNormalizedRealmName`. Not in OE.

#### D4. Class color by token: LIB (extend `Core.ClassColor` to take a classFile)
The library ruled `RAID_CLASS_COLORS` and ships `lib.ClassColor(unit)`, unit-keyed (`LibKa0s/Core.lua:393-442`; options-ui `options-ui.md:498` "One resolver"). Lookups by classFile re-implement it: BankLedger `modules/Browser.lua:387`, `InsightsWidgets.lua:137`; DpsRace `modules/Hud_Appearance.lua:165`, `Results_Table.lua:99`; KickCD `settings/Spells_Header.lua:57`; LootHistory `core/CoreSetup.lua:71`, `modules/AnalyticsFormat.lua:94`, `AnalyticsLedger.lua:232`; PartyFrameEnhanced `modules/Element.lua:373`. **Divergent against the ruling:** DropWatcher `core/Compat.lua:952-960` reads `C_ClassColor.GetClassColor` **first**. The fallback also varies: LH returns gold `{1,.82,0}` and the rest return nil. The degraded stubs in AT/AM/PFE `core/CoreSetup.lua:66/50/49` repeat the lookup as well.

#### D5. Secret-safe number abbreviation ladder: WATCH, leaning LIB
MultiMeters `modules/Format.lua:39-41,541-551` goes NumericRuleFormatter, then `AbbreviateNumbers`, then `SafeToString` (`"<secret>"`). DpsRace `modules/Format.lua:80-107` goes formatter, then a Lua `abbreviate` for plain values, then `AbbreviateNumbers`, then the **raw secret**. AbsorbTracker calls `AbbreviateNumbers` directly (`modules/Display.lua:476`), and its sim has a fourth form (`modules/Sim.lua:39`, `"%gk"`). The last rung differs: one shows "<secret>", the other passes the raw secret through. The Compat doc rejected only the formatter's presence guard (`version-1-docs.md`, "Two consumers, but no content"), not the ladder. Three consumers, but DR and MM differ on purpose, so WATCH until they agree.

#### D6. Slash `format` hook drops the library's color decode: LIB fix
`LibKa0s/Slash.lua:413-417,504-518`: a host `format` replaces `FormatValue` "outright … taking precedence over colorDecode". A host that needs one custom row type therefore has to re-implement the library's color branch, and two have: AuraMaster `settings/Slash.lua:528-541` and ConsumableMaster `settings/Slash.lua:522-530` (both call `colorDecode` and then `SlashLib.FormatValue`). Per-host value renderers also exist at BankLedger `modules/Diagnostics.lua:119` (the table type) and MultiMeters `settings/Schema_Paths.lua:589`. Fix: let `format` return nil to fall through, or pass it the default renderer. Two repos plus a concrete cost (the copied branch drifts from `Slash.lua:513-517`).

#### D7. Tooltip line readers: OE #49 vote (trigger count met, semantics still disagree)
Four addons now read `C_TooltipInfo` lines: ConsumableMaster `core/TooltipCache.lua:439-445`, DropWatcher `core/Compat.lua:131-160` (`ReadTooltipLine`, first answer wins, typed line first), LootHistory `core/Compat.lua:308-327` (`ScanBound`), and OutfitterReborn `core/Compat.lua:530-560` (all lines with colors). The guards are split: only LH excludes the `RETRIEVING_ITEM_INFO` placeholder, which it notes "settles every row while learning nothing", and only OR (and DW's own Plain path) secret-guards `leftText`. **OE vote:** *#49 tooltip line reader and duration decoder*. The count trigger (a second reader) has fired, but not with the same first-answer semantics, so the rejection holds. The two guards are rule material for a standard line (events-frames-taint or compat), whatever the library decides.

#### D8. Where the degraded-environment builder lives: STD (name the home)
testing-§8 (`testing.md:161-210`) mandates a real degraded load but not where the builder goes. Six repos use `tests/degraded_env.lua` (AT, AM, BL, LH, PM, PFE; 15 to 66 lines, near-identical headers), six use `tests/loader.lua` (DW, LST, PGFE, PC, QC, WG), and the rest build it inside `tests/run.lua` (CM, KC, MM, PC; `git grep -l degraded tests/`).

#### D9. Skin-gate facts fixture name: STD or testkit README (pick one)
The facts file for the kit's `skinSwitch`/`skinValues` goes by four names: `tests/skin_surfaces.lua` (9: DR, LST, LH, OR, PM, PGFE, PC, QC, WG), `tests/skin_facts.lua` (4: BL, KC, MM, PFE), `tests/skin_switch_facts.lua` (2: CM, DW) and `tests/skin_gate.lua` (AM). LootHistory also carries `skin_support.lua`. The testkit README (`testkit/README.md:532-560`) describes the facts without naming a file.

#### D10. Notes for audit, not harvest
- DropWatcher parses item IDs by hand (`modules/History.lua:190,465`, `modules/SimWorld.lua:281`) even though it adopted `LibKa0s-Item-1.0` (`ItemIDFromLink`, `LibKa0s/Item.lua:57`).
- AceDB `copyDefaults` is re-implemented in addon `wow_mock.lua` (KickCD `tests/wow_mock.lua:207`, plus CM, OR, PGFE, BL) although `testkit/mock_record.lua:178` ships one. That is testing-§1 thin-extender drift: `wow_mock.lua` totals 11,481 lines over 17 repos.
- File-name drift: PanelMaster `core/BusSetup.lua` against `core/Bus.lua` in 8 repos (architecture.md:97 names `core/Bus.lua`); AbsorbTracker `core/Lifecycle.lua` against `core/LifecycleSetup.lua` in 16; OutfitterReborn `modules/IconBrowserSetup.lua` against QuickComms `core/IconBrowserSetup.lua` (setup files belong in `core/`).

---

### C 3. Emergent conventions (docs/, directories, tools, naming)

| # | Convention | Repos | Standard today | Call |
|---|---|---|---|---|
| E1 | `docs/superpowers/{specs,plans}/` with `<YYYY-MM-DD>-<topic>-design.md` / `<YYYY-MM-DD>-<topic>.md` | 16/17 (all but LibKa0sSkinTester). Conformance: specs 110/121 design-named; plans 141/167 dated. Outliers: AuraMaster (4 specs, 7 plans), DropWatcher (19 undated plans), OutfitterReborn (5 specs not `-design`: `2026-11-03-dpsrace-blueprint.md`, `-outfitter-feature-inventory.md`, `-standard-checklist.md`, `2026-11-05-recon/`), QuickComms (2 specs). Extra `research/` subfolder: AuraMaster, DropWatcher | `documentation.md:394` names the directory as out of scope and nothing more. The naming rule lives only in Ka0sAddonsCommonTasks `CLAUDE.md` | **STD codify** (documentation: the store's shape, the naming, and a sanctioned `research/`) |
| E2 | `docs/brainstorm/` pre-scaffold frozen store (research, mockups, go/no-go) | DpsRace (`mockup/`), QuickComms (`01..04-*.md`, `go-no-go`, `mockup`, `reference`) | Not named. Registered two ways: QC as "its own frozen store" (`QuickComms/docs/ARCHITECTURE.md:312,355`), DR as a Tier row (`DpsRace/docs/ARCHITECTURE.md:704`), the split documentation.md:394-405 warns about | **WATCH** (2 repos); codify with E1 if a third addon is brainstormed before scaffold |
| E3 | Screenshot filenames `<addon>.screenshot.NN.<ext>` | 11 (AT, AM, BL, DW, MM, OR, PM, PFE, PC, QC, WG). Outliers: ConsumableMaster `kcm-01-general.png`, KickCD `kickcd.image.01.addon.png` / `kickcd.video.01.gif`, LootHistory `loothistory-screenshot-01.png` (+ `skins/`), PGFE `screenshot.01.png`; AuraMaster ships `.jpg` and `.png` pairs; DpsRace and LST have no `media/screenshots/` | `layout.md:118` and `naming-cheatsheet.md:9` name the folder only | **STD codify** (naming-cheatsheet row; a `skins/vN/` sub-store, per LootHistory) |
| E4 | Dev-tool dot-dirs (`.superpowers/`, `.claude/`), ignored but not tracked | `.superpowers/` in 9 (AT, AM, BL, CM, KC, LH, MM, QC + PFE/PM per `.gitignore`); `.gitignore` names it in 8; BankLedger has **no `.gitignore`** and MultiMeters' does not name it (both ignored only by a global exclude); stray `.pytest_cache/` (LH) and `tools/__pycache__/` (QC) | packaging.md:19-42 covers `.pkgmeta`, not `.gitignore` | **WATCH** / small STD line: `.gitignore` names every dev-tool dir |
| E5 | `tools/` generators: Python (AM, PM, PGFE, PC, QC) against Lua (OR ×3, QC `render-shine-preview.lua`); `--check` mode in AM, PM, OR | 7 repos have `tools/` | layout.md:94-96 | see **C8** |
| E6 | `core/Util.lua` grab-bag | 8 (BL, KC, LST, LH, PM, PFE, PC, WG). Contents overlap: `DeepCopy` ×4, `SplitPath` ×2, `PlayerKey`/`FormatMoney`/`FormatClock`/`FormatDate`/`FormatBytes` ×2 (BL and LH, a same-author pair), `NS.Windows.*` ×2 (LST, WG) | not named in layout | **WATCH**; it holds C4/C9/D3 material, and naming it would mostly give the duplicates a sanctioned home |
| E7 | Split English locale (`enUS_<Area>.lua`) | DropWatcher, OutfitterReborn | localization: check | **WATCH** (2 repos) |

Already covered and **not** proposed: the canonical `docs/*.md` set (17/17 for the 14 Tier files, `compat-layer.md` 13, `midnight-quirks.md` 11, `message-bus.md` 5, `known-limitations.md` 5, all named in documentation.md), `docs/revendor|audits|reviews|automated-tests|perf-analysis`, `prose_waivers.lua` (13 repos, the testkit's), `Bindings.xml` (10, launcher).

---

### C 4. OutfitterReborn: first harvest

Joined 2026-11-03 (conversion of Outfitter, 330 commits, LibKa0s **v1.89.0**, the newest in the collection, where 14 repos are on v1.85.0).

**Done here and nowhere else:**
- A dedicated, documented `core/SecureQueue.lua` (C1). Of the four keyed combat queues it has the best shape: it registers only while something waits, isolates errors per entry, and has a stand-down `Clear`.
- Generators written in Lua and loaded by the suite (`tests/test_locale.lua:410,546`), with `--check` (C8).
- `tests/fixtures/` holding a captured **legacy** SavedVariables set (`tests/fixtures/legacy/*.lua`, 12 files) and a capture tool (`tools/legacy_capture.lua`). This is the only repo with a migration-from-foreign-addon fixture store.
- Scene fixtures for UI tests (`tests/bar_scene.lua`, `dialog_scene.lua`, `dock_scene.lua`, `perf_scenes.lua`, `spy.lua`, `unit_load.lua`, `mock_world.lua`, `mock_gear*.lua`).
- A per-test `MenuUtil` stub instead of `tests/mock_menu.lua` (`tests/test_launcher.lua:14,41`). That is a lighter answer to C6.
- `LibKa0s icons: all (icon browser)`, the second addon to declare it (with QuickComms). **This fires OE `#55 picker-credit helper`** ("Re-check when a second addon ships a player-facing icon chooser, and so earns `all`"). Both READMEs hand-write the same three-set credit block (`OutfitterReborn/README.md:124-129`, `QuickComms/README.md:136-140`), worded differently.
- Spec names that break the `-design` convention (E1), since conversion artifacts (`dpsrace-blueprint`, `feature-inventory`, `standard-checklist`, `recon/`) have no slot.

**Others do, OR does not:** no `core/Util.lua` (helpers stay module-local, but 5 local `copy` functions: `modules/Dialog_TriggerFields.lua:39`, `EquipmentManager.lua:77`, `Outfits.lua:58`, `settings/Schema.lua:32`, `tools/legacy_capture.lua:194`); no `tests/degraded_env.lua` (its degraded path is in `test_surface_parity.lua`); no `docs/superpowers/research/`; `IconBrowserSetup.lua` in `modules/`, not `core/`.

**Copied rather than independent:** `core/Secrets.lua` and the `CanAccessTable` in `core/Compat.lua:88` match DpsRace's (blueprint spec). Count OR as a **same-author copy** under §7 bar 3 for C3, not as an independent consumer.

---

### C 5. Watch-list (below the bar)
- `tests/sim_support.lua` shared simulator fixture: BL (213 lines), KC (258), LH (249), MM (138); purposes are similar but not compared line by line. A testkit Sim-harness candidate if a fifth appears.
- Short-name and realm-strip helpers: DropWatcher has four copies (`modules/Asks.lua:99`, `FeedRecords.lua:22`, `History.lua:459`, `WindowCells.lua:164`), and MM `modules/Targets.lua:183`, BL `InsightsWidgets.lua:144`, LH `AnalyticsFormat.lua:108` add more. `Ambiguate` is used only by MM. Mostly local duplication; fold into D3 if Compat gains a realm reader.
- Money/clock/date/bytes formatters: BL and LH only (a same-author pair). Watch for a third.
- OE *A collapsed-group key convention*: no third `\001` key found (DropWatcher keys `collapsed[groupKey]` without the separator, `core/State.lua:44`). No vote.

### C 6. OE cross-reference summary
| OE entry | Vote from |
|---|---|
| Further LibKa0s modules (Compat duplicates) | C3 |
| A per-addon adoption command | D1 |
| Whether an adopted major needs a full library-absent stub | D1, D2 (also D4's CoreSetup stubs) |
| Whether an unlock anchor has to be the library's handle | C4 (partial) |
| #49 tooltip line reader | D7 (count met, semantics not: rejection holds) |
| #55 picker-credit helper | §4: **trigger fired** (OR + QC both `all`) |
| New, not in OE | C1, C2, C5, C6, C7, C8, D3, D5, D6, D8, D9, E1, E3 |

---

# Part D — LibKa0s against the standard, and tooling (categories 8, 10)


Read-only research, 2026-11-06. Paths are relative to `/mnt/d/Profile/Users/Tushar/Documents/GIT/`.
`LS` = `WowAddonStandards/standards/standards/library-stack.md`.

### D State read

- LibKa0s `master` HEAD `1ca12c6` (LK-K3 merge). Newest tag **v1.89.0** (2026-11-05). Tags since v1.84.0:
  v1.85.0 (11-01, re-cut 18 times, last `550ef68` on 11-04), v1.86.0 (11-04), v1.87.0 (11-05), v1.88.0 (11-05), v1.89.0 (11-05).
- Kit: `LibKa0s/testkit/framework.lua:20` `Kit.VERSION = 51`.
- Shipped: `LibKa0s/tests/majors.lua` lists **21 majors** (`grep -c 'major = '`) across **67 files**
  (`LibKa0s/LibKa0s/LibKa0s.xml` has 67 `file=` entries; 67 `.lua` under `LibKa0s/LibKa0s/`).
- Standard: v2.101.0 (`WowAddonStandards` HEAD `baebb21`).
- Method: compared each major's newest `LibKa0s/docs/api/<Major>/members-<key>.json` (generated by
  `tools/gen-api-members.lua`) against the backticked names in its §7 row; compared each major's
  `files` in `majors.lua` against the row's Files cell; grepped every `O.`/`W.`/`Skin:`/`Core.`... name
  in the standard against the live library source. Scripts: scratchpad `memcmp.py`, `stdnames.py`.

### D A. Library vs prose

#### A1. A whole major is undescribed: `LibKa0s-IconBrowser-1.0` (gap, severity: high for an index)

- Library: `LibKa0s/tests/majors.lua` row `LibKa0s-IconBrowser-1.0` (files `IconBrowserSources`,
  `IconBrowserWindow`, `IconBrowser`); shipped in **v1.86.0** (`LibKa0s/CHANGELOG.md:86`, key 1.1.1, Quick
  Comms' browser promoted, `CHANGELOG.md:90`). Public surface (`docs/api/IconBrowser/members-1.1.1.json`):
  `BUILTIN_TABS`, `ColorFrom`, `GLYPH_LABELS`, `IsGlyph`, `MacroIcons`, `New`, `STRINGS`, `Sources`, `Tint`,
  `ValidColor`, `WOWHEAD_ICONS`, ... Floors: `IconBrowserSources.lua:66` `NEEDS_CORE, NEEDS_MEDIA = 1, 5`;
  calls Core members at `IconBrowserWindow.lua:118,296` and Skin at `:128,163`, Widgets at `IconBrowser.lua:933`.
- Consumers: QuickComms (`core/IconBrowserSetup.lua`, v1.86.0) and OutfitterReborn (`modules/IconBrowserSetup.lua`, v1.89.0).
- Standard: **zero** mentions of `IconBrowser` anywhere under `WowAddonStandards/standards/` (grep -ri). No §7 row,
  not in the module list, not in open-evolutions' "Shipped so far" (`open-evolutions.md:13`). The only "icon browser"
  text is the icon-declaration spelling `all (icon browser).` (`LS:189-191`).

#### A2. Stale counts (all from the same omission)

| Claim | Location | Today |
|---|---|---|
| "twenty LibStub majors across sixty-four files", list of 20 | `LS:86` | 21 / 67 |
| "Nineteen of the twenty majors floor on Core" | `LS:135` | twenty of twenty-one (IconBrowser floors on Core and also on Media minor 5; it calls Core members, so it joins the "reach a Core member" list, not the "eleven") |
| "twenty LibStub majors across sixty-four files" + list | `standards/EXECUTIVE_SUMMARY.md:60` | 21 / 67 |
| "twenty majors across sixty-four files" | `standards/STANDARDS.md:57` (index blurb) | 21 / 67 |
| "adoption spans twenty majors" | `open-evolutions.md:36` | 21 |
| "Eleven of the twenty LibKa0s majors" | `open-evolutions.md:182` | of twenty-one |

- Last recount: `LS:86` ends "...recounted for ... 2026-11-01, answer **20 and 64**" (v1.84.0 / standard v2.94.1,
  `standards/CHANGELOG.md:19`). This is the **fourth** drift of this paragraph; the paragraph itself records three
  ("this table has now fallen behind three times") and asserts "the library's release run re-runs them rather than
  trusting this sentence". The library's release guide *did* move: `LibKa0s/docs/releasing.md:28` ("sixty-seven"),
  `:60` ("twenty-one today"), `:286` ("the sixty-seven `.lua` files"). The fix lands in the library and never
  propagates to the standard: nothing in the release run hands the standard an item.
- Newest LibKa0s tag the standard cites anywhere is **v1.85.0** (16 citations, e.g. anti-patterns #110-#112,
  `anti-patterns.md:139-141`); v1.86.0-v1.89.0 are never cited. Every tag the standard cites exists.
- Kit revisions cited are dated facts (highest: revision 50, `skinning.md`), not "current" claims; revision 51
  (`CHANGELOG.md` v1.89.0, a `mock_ace.lua` CallbackHandler unregister guard) changes no member, so no prose is wrong.

#### A3. Members shipped but undescribed in an existing row

The §7 table is a summary that defers to `docs/api/`, so most facade constants (`STRINGS`, `New`) being unnamed is
by design. The ones that are real behaviour changes since the last recount:

- **Toast stack (v1.88.0, Toast minor 4).** Row `LS:96` still says the toast "shows one payload at a time and queues
  the rest". Toast minor 4 adds an opt-in stack: descriptor `stack`, `stackGrow`, `stackGap`, facade
  `lib.STACK_GAP` (6), instance `SetStack`, `Visible`, `FrameFor` (`LibKa0s/CHANGELOG.md` v1.88.0 "The stack (`LK-T1`)";
  `docs/api/Toast/members-4.json`). The sentence is still true for the default (stack 1), but the
  capability and the stub's three new instance members are missing. Consumer: DropWatcher (#14).
- **Widgets `W.ContextMenu`** shipped at Widgets minor 21 (`docs/api/Widgets/version-21.5.12.6.6.4-docs.md:23`,
  present in every manifest from `members-21.5.12.6.6.4.json`), and v1.87.0 (Widgets minor 23) added cascading
  `submenu = rows`. `open-evolutions.md:221-226` still records "A library context menu, `W.ContextMenu` (recorded,
  not ruled)" as a *future* surface. Row `LS:100` does not name it. The evolution entry should be closed and the
  row should name it (LootHistory/BankLedger's hand-built menus were the trigger).
- **Rows with whole public families unnamed** (from the manifests; low value unless the table is meant to be an
  index): Core `MakeResizable`, `ResolveColor`, `ClassColor`, `RGBA`, `SafeRegisterEvent(s)/UnitEvent` (the
  latter named at `LS:135` instead); Media `Font/Border/Background/Texture/Icon/IconAuthor/RegisterLSM`,
  `ICON_SETS`; Pool all eight members; Skin 45 of 55 facade members (`GetChoice`, `SetOverride`, `ResetToSkin`,
  `RegisterSkin`, `PaintAce`, ...); Options `PatchAlwaysShowScrollbar`, `LAYOUT`.

#### A4. Members described but no longer present (the worse direction)

**None found.** Every member-shaped name in a §7 row that is absent from the facade manifests is either an instance
member that exists in source (`Clear`/`Hold`/`Release`/`Preview` in `Toast.lua`; `SetMany`/`ApplyDefault` in
`Schema.lua`; `StandDown`/`StandUp` in `Bus.lua`; `DebugAtEnable`... in `DebugLogGates.lua`; Options composer
members in `OptionsCompose.lua`/`OptionsKeybinds.lua`/`OptionsAppearance.lua`; Perf `Open/Close/Measure/...`
in `PerfSampler.lua`/`PerfCommands.lua`), or is explicitly named as rejected/internal/removed (`LS:94` Item's
`LinkDetail`/`BetterLink`/...; `LS:95` Glow's `IconStyle`/`O.GlowGroup`/`STYLES`; `LS:105` `RunTo` "Sim-internal",
`StepPanel` "No major publishes"; `LS:132-133` `O.__releaseChrome`, `lib.__PatchLSM30Border` removals). A sweep of
every `O./W./Skin./Core./Media./...` name across all standard section files, NEW_ADDON_CONTEXT, EXECUTIVE_SUMMARY and
STANDARDS.md found only those plus git config keys (`core.autocrlf`) and a placeholder (`preview-mode.md:42`
`Compat.Member`). All `Kit.*` names the standard cites exist in `LibKa0s/testkit/`. Per-major file lists in every
existing row match `majors.lua` exactly (no extra, no missing file).

#### A5. Degradation stub contract

The standard's contract (`LS:137-140`: return before `NewLibrary` on an unmet floor; host falls back to its stub;
no reduced-mode negotiation) is honoured by the new major (`IconBrowserSources.lua:67-68`). Stub growth since
v1.84.0 that a consumer owes at re-vendor: Widgets `ContextMenu` (may answer nil), Toast instance `SetStack`,
`Visible`, `FrameFor`. The kit's surface-parity gate (`testkit/asserts.lua`, `assertSurfaceParity`) catches these at
the consumer's re-vendor, so this is not silent; but the standard has no IconBrowser stub guidance at all (what a
library-absent host shows instead of the browser).

### D B. Consumer drift

Every roster addon's `libs/LibKa0s/` and `tests/_kit/` was compared byte-for-byte (`diff -rq`, no CR stripping)
against `git archive <tag> LibKa0s testkit` for the tag its `CLAUDE.md` "Bundles [LibKa0s](...) vX" line claims.
`media/icons/` files absent in the addon were excluded (declaration-driven prune). All repos on `master`, clean.

| Addon | Claims | Byte diffs | Last payload commit |
|---|---|---|---|
| AbsorbTracker | v1.85.0 | 0 | `50847a2` R6-RV2 (re-cut) |
| AuraMaster | v1.85.0 | 0 | `f5dbcef` R6-RV2 |
| BankLedger | v1.85.0 (`CLAUDE.md:48`) | 0 | `572205b` R6-RV2 |
| ConsumableMaster | v1.85.0 | 0 | `1714fc6` R6-RV2 |
| DpsRace | v1.85.0 | 0 | `11fe1b4` R6-RV2 |
| DropWatcher | v1.88.0 | 0 | `59e323d` DW-T1 |
| KickCD | v1.85.0 | 0 | `cc61a05` R6-RV2 |
| LibKa0sSkinTester | v1.85.0 | 0 | `ddad584` R6-RV2 |
| LootHistory | v1.85.0 (`CLAUDE.md:58`) | 0 | `4dede61` R6-RV2 |
| MultiMeters | v1.85.0 | 0 | `47fa201` R6-RV2 |
| OutfitterReborn | v1.89.0 | 0 | `7f512f0` Re-vendor v1.89.0 |
| PanelMaster | v1.85.0 | 0 | `763455c` R6-RV2 |
| PartyFrameEnhanced | v1.85.0 | 0 | `1cb3864` R6-RV2 |
| PremadeGroupsFilterExtension | v1.85.0 | 0 | `63f3ed5` R7-PG (adds `media/icons/eye.tga` only, a declaration change) |
| PrettyChat | v1.85.0 | 0 | `d9ccc92` R6-RV2 |
| QuickComms | v1.86.0 | 0 | `7398649` Re-vendor v1.86.0 |
| WhatGroup | v1.85.0 | 0 | `be6f5d5` R6-RV2 |

**No drifted vendored copy.** The kit's `testkit/vendor_sync.lua` (consumer-side gate: payload == tag named in
CLAUDE.md) is doing its job. What the history shows instead:

1. **Tag re-cuts are the recurring event, not drift.** v1.85.0 was re-cut 18 times (`550ef68` "Record the v1.85.0
   eighteenth release re-cut"; 42 LibKa0s commit subjects mention re-cut). Every consumer then needed a second
   re-vendor (`R6-RV2` in 14 repos on 11-04) under an unchanged provenance string, so "v1.85.0" named different bytes
   on 11-01 and 11-04. Re-vendor bundles are inconsistent about it: KickCD and PartyFrameEnhanced have
   `docs/revendor/2026-11-01-v1.85.0-recut/`, the other twelve have only the 11-01 bundle for an 11-04 re-vendor
   commit (tension with `audit-review-history` "A re-vendor commit implies a bundle"). The standard says nothing about
   re-cutting a tag (no hit for re-cut/recut/retag in `versioning-git.md` or elsewhere). Missing feature: provenance
   by tag *and* commit (e.g. `v1.85.0 (550ef68)`), or a rule that a released tag is never moved.
2. **Vendoring a branch tip under a tag name.** DropWatcher `b2726c7` "Re-vendor LibKa0s v1.87.0 from the
   toast-stack branch tip", replaced by `59e323d` "from the v1.88.0 tag, replacing the toast-stack tip that was
   labelled v1.87.0". The kit gate would have reddened (the v1.87.0 tag did not hold those bytes), and did its job,
   but the shape recurs whenever a consumer co-develops with the library.
3. **Lag, not drift.** 14 of 17 addons sit four tags behind on kit revision 50. Revision 51 fixes a CallbackHandler
   fake flake (`invalid key to 'next'` about one run in six in OutfitterReborn) that any consumer whose suites
   unregister during dispatch can hit; it reaches them only at their next re-vendor (`CHANGELOG.md` v1.89.0:
   "every other host takes v1.89.0 at its next re-vendor").

### D C. Tooling gaps (category 10)

#### C1. `scripts/check-standard.sh` result

`bash scripts/check-standard.sh` in WowAddonStandards: **exit 0, all 7 checks pass** (cr-bytes; gitattributes;
citations 2280 resolve; sections 29 listed; anti-patterns #1-#112 contiguous; version-stamps v2.101.0 in four
places; links across 43 live docs). Its header says it checks only mechanically decidable, repo-internal invariants
(`scripts/check-standard.sh:9-11`), so it cannot see A1/A2.

#### C2. Gaps and where a check could live

1. **LibKa0s majors/files figures (the drift above, 4th occurrence).** Proposed `libka0s-counts` check in
   `check-standard.sh`: when `../LibKa0s` exists, compare the "N LibStub majors across M files" sentences in `LS:86`,
   `STANDARDS.md:57`, `EXECUTIVE_SUMMARY.md:60` and the `| \`LibKa0s-*-1.0\` |` rows of `LS` against
   `tests/majors.lua` at the newest tag (`git -C ../LibKa0s show <tag>:tests/majors.lua`); skip with a notice when the
   sibling is absent. Also: every major in `majors.lua` has a §7 row, and each row's Files cell equals `files`
   (the comparison in this report is ~20 lines of awk/python). Alternatively the library's release step 9
   (`docs/releasing.md`) files an item against the standard when a major or file is added.
2. **Re-vendor implies a bundle (`audit-review-history`)** - flagged in AM-21, PM-048 (recurring), and now the
   12-repo re-cut gap. Mechanically checkable in the kit's `vendor_sync.lua`: the provenance tag in CLAUDE.md must have
   a `docs/revendor/*-v<tag>*/` folder, and (stronger) the bundle date is not earlier than the last commit touching
   `libs/LibKa0s/`. No kit file references `audit-review-history` today.
3. **`packaging` / `layout-§4` logo exclusion** - QC-20 (`.pkgmeta` ignores `media/logos/*.png` but not the 1.6 MB
   `.jpg`), AM-35, AM-40. A kit case can read `.pkgmeta`'s `ignore:` globs and assert every tracked file under
   `media/logos/` matches one. Nothing in `testkit/` reads `.pkgmeta` (only prose gates mention the word).
4. **`slash-commands-§1` library-absent stub must not copy `FormatRow`** - AM-38, PM-050, QC-17 (three repos, same
   finding). A generic kit case: load the addon's slash setup with `LibKa0s-Slash-1.0` absent and assert the stub's
   help-row shape. `testkit/asserts.lua` has surface parity but no degraded-output assertion.
5. **`documentation-§5` count claims** (AM-37, PM-044, PGE-22, QC-08 "27 shims" vs grep 31, QC-24 default drift) -
   the most-cited rule in the latest audits (4 repos). Covered only by `/dev-copilot:sync-docs`' count-claim pass,
   which is advisory. Narrow mechanical slice: a kit case that compares documented defaults in `docs/schema.md`
   against `defaults/Profile.lua`.
6. **`toc-file-§5` file-scope capture annotations** (PGE-07/08/28, QC-26, PM-036/037) - heuristic only; a kit
   lint could flag `NS.X.Y` captured into a file-scope local in a file whose TOC comment says "resolve at call time".
   Lower confidence.
7. **`options-ui-§12` global reset wording / one act** (BL-34, PM-049) - no kit coverage; a fixture-level assertion
   that exactly one confirm-gated reset path exists is plausible via the options fixture.
8. **Tag immutability** - no rule and no check. `vendor_sync.lua` could record the tag's commit sha in the provenance
   line so a moved tag reddens visibly with "tag moved" rather than a byte diff.

`.luacheckrc` is the wrong home for any of these (they are cross-file and doc-vs-code). The kit (`tests/_kit/`) is
the right home for 2-7 since every consumer inherits it; `check-standard.sh` for 1.

Latest audit bundles are mostly 2026-10-07 (one month old; DpsRace and LibKa0sSkinTester have none), so the
frequency figures above (rule cited by N repos in their newest `02_DEVIATIONS.md`: documentation-§5 4;
toc-file-§5, slash-commands-§1, slash-commands-§7, packaging, layout-§4, documentation-§3, compat,
automated-tests-§3/§4, audit-review-history 3 each) lag the current tree.

---

# Part E — The issue store (category 6)

Read on 2026-11-06. `wnd` = closed `state:will-not-do`; `tri` = open `state:triaged`. Citations of the standard found in each body are listed after the bar.

#### AbsorbTracker — tri (8)

- [#15](https://github.com/tusharsaxena/AbsorbTracker/issues/15) `severity:low` Allow configuring the bar maximum instead of always using max health
- [#9](https://github.com/tusharsaxena/AbsorbTracker/issues/9) `severity:low` Add support for Frame Strata
- [#8](https://github.com/tusharsaxena/AbsorbTracker/issues/8) `severity:low` Add support for Absorb and Heal Absorbs as separate bars
- [#6](https://github.com/tusharsaxena/AbsorbTracker/issues/6) `severity:low` Add support for attaching to frame (with frame selector, attach anchor points and offset)
- [#5](https://github.com/tusharsaxena/AbsorbTracker/issues/5) `severity:low` Add support for Edit Mode
- [#4](https://github.com/tusharsaxena/AbsorbTracker/issues/4) `severity:low` Add support for fill direction support LTR or RTL
- [#3](https://github.com/tusharsaxena/AbsorbTracker/issues/3) `severity:low` Add support for Border offset
- [#2](https://github.com/tusharsaxena/AbsorbTracker/issues/2) `severity:low` Add support for text placement (inside, outside, left ,right, center)

#### AbsorbTracker — wnd (8)

- [#31](https://github.com/tusharsaxena/AbsorbTracker/issues/31) `severity:low` LibKa0s-Compat-1.0: no spell, specialization or secret reader here for it to route
- [#28](https://github.com/tusharsaxena/AbsorbTracker/issues/28) `severity:low` LibKa0s-Pool-1.0: declined — a fixed three-frame set has nothing to recycle
- [#27](https://github.com/tusharsaxena/AbsorbTracker/issues/27) `severity:low` LibKa0s-Item-1.0: declined — this addon has no item domain
- [#26](https://github.com/tusharsaxena/AbsorbTracker/issues/26) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#23](https://github.com/tusharsaxena/AbsorbTracker/issues/23) `severity:low` Convert the About page's LandingRows render loop to RenderGrid
- [#22](https://github.com/tusharsaxena/AbsorbTracker/issues/22) `severity:low` Bisect the combat FPS drop across other addons
- [#21](https://github.com/tusharsaxena/AbsorbTracker/issues/21) `severity:low` Correct the frozen 2026-07-31 review bundle's final summary
- [#16](https://github.com/tusharsaxena/AbsorbTracker/issues/16) `severity:low` Optional sound / TTS alert when absorb shields expire

#### AuraMaster — tri (3)

- [#9](https://github.com/tusharsaxena/AuraMaster/issues/9) `severity:medium` Import/export strings for profiles and containers
- [#7](https://github.com/tusharsaxena/AuraMaster/issues/7) `severity:medium` Sorting applies per aura group, not across the container
- [#1](https://github.com/tusharsaxena/AuraMaster/issues/1) `severity:medium` Support party members (party1-party4) as container units

#### AuraMaster — wnd (3)

- [#20](https://github.com/tusharsaxena/AuraMaster/issues/20) `severity:low` Adopt the LibKa0s-Bus-1.0 stand-down record for bus receivers | architecture-§4 slash-commands-§7
- [#8](https://github.com/tusharsaxena/AuraMaster/issues/8) `severity:low` Cache auras seen on screen as an autocomplete source, with time-bound cleanup
- [#5](https://github.com/tusharsaxena/AuraMaster/issues/5) `severity:low` Minimum duration filter (not possible on 12.1)

#### BankLedger — tri (1)

- [#1](https://github.com/tusharsaxena/BankLedger/issues/1) `severity:medium` Capture store-to-store transfers (bank → warband tab)

#### BankLedger — wnd (9)

- [#20](https://github.com/tusharsaxena/BankLedger/issues/20) `severity:low` Adopt LibKa0s-Compat-1.0 in place of core/Compat.lua | library-stack-§7
- [#15](https://github.com/tusharsaxena/BankLedger/issues/15) `severity:low` Withdraw the ratified performance-§12 exemption: declined — the citations rotted, the argument did not | performance-§12
- [#10](https://github.com/tusharsaxena/BankLedger/issues/10) `severity:low` Adopt LibKa0s Options `RestoreAllDefaults`, `InlineButtonPair` and `runRefreshers` | anti-pattern #47
- [#9](https://github.com/tusharsaxena/BankLedger/issues/9) `severity:low` Adopt `LibKa0s-Perf-1.0` and wire a performance harness | performance-§12
- [#8](https://github.com/tusharsaxena/BankLedger/issues/8) `severity:low` Change the standard or LibKa0s over the panel-refresh write seam
- [#7](https://github.com/tusharsaxena/BankLedger/issues/7) `severity:low` Port the `LIST_GROUP_ORDER` constant onto the library-backed `/bl list`
- [#6](https://github.com/tusharsaxena/BankLedger/issues/6) `severity:low` Adopt the library's `D:ConsoleCheckbox()` for the debug-console option
- [#5](https://github.com/tusharsaxena/BankLedger/issues/5) `severity:low` Adopt LibKa0s-Core-1.0 window chrome (`SKIN`, `ApplySkin`, `MakeCloseButton`)
- [#4](https://github.com/tusharsaxena/BankLedger/issues/4) `severity:low` Track currencies as a ledger entry kind

#### ConsumableMaster — tri (9)

- [#15](https://github.com/tusharsaxena/ConsumableMaster/issues/15) `severity:low` Add a `/cm gc` verb to sweep the discovered set on demand
- [#13](https://github.com/tusharsaxena/ConsumableMaster/issues/13) `severity:low` Surface `_viewedSpecAuto` as a user-visible checkbox
- [#12](https://github.com/tusharsaxena/ConsumableMaster/issues/12) `severity:low` Session-scoped memo for the per-render `craftingQualityAtlas` lookup
- [#11](https://github.com/tusharsaxena/ConsumableMaster/issues/11) `severity:medium` Handle items that are only usable in certain zones
- [#9](https://github.com/tusharsaxena/ConsumableMaster/issues/9) `severity:low` Macro bar: styling for slots with no current pick
- [#8](https://github.com/tusharsaxena/ConsumableMaster/issues/8) `severity:low` Macro bar: configurable cooldown and count styling
- [#7](https://github.com/tusharsaxena/ConsumableMaster/issues/7) `severity:low` Macro bar: per-slot keybindings
- [#4](https://github.com/tusharsaxena/ConsumableMaster/issues/4) `severity:low` Checkbox to enable
- [#3](https://github.com/tusharsaxena/ConsumableMaster/issues/3) `severity:low` Stat Weights

#### ConsumableMaster — wnd (15)

- [#41](https://github.com/tusharsaxena/ConsumableMaster/issues/41) `severity:low` RenderTabbedSchema not adopted on the Stat Priority, Macros and Macro Bar pages
- [#31](https://github.com/tusharsaxena/ConsumableMaster/issues/31) `severity:low` LibKa0s-Pool-1.0: declined — both widget sets are keyed and secure, not anonymous
- [#30](https://github.com/tusharsaxena/ConsumableMaster/issues/30) `severity:low` LibKa0s-Item-1.0: declined — the addon's items are numeric IDs, never links
- [#28](https://github.com/tusharsaxena/ConsumableMaster/issues/28) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#26](https://github.com/tusharsaxena/ConsumableMaster/issues/26) `severity:medium` Hoist the GCD-suppress curve into LibKa0s instead of duplicating KickCD's copy
- [#25](https://github.com/tusharsaxena/ConsumableMaster/issues/25) `severity:low` Patch the vendored LibKa0s Slash.lua colour and enum shape mismatches in place (original evidence, later superseded)
- [#24](https://github.com/tusharsaxena/ConsumableMaster/issues/24) `severity:low` Adopt the LibKa0s options page registry and refresh trio over the addon's own (original regressions, later superseded) | options-ui-§2
- [#23](https://github.com/tusharsaxena/ConsumableMaster/issues/23) `severity:low` Adopt the LibKa0s options page registry and refresh trio now that the regressions are fixed (pre-adoption state, later superseded)
- [#22](https://github.com/tusharsaxena/ConsumableMaster/issues/22) `severity:low` Adopt the LibKa0s options row widget makers over the addon's own (original blockers, later superseded)
- [#21](https://github.com/tusharsaxena/ConsumableMaster/issues/21) `severity:low` Adopt the LibKa0s schema-row widget makers now that the upstream blockers are fixed (pre-adoption state, later superseded)
- [#20](https://github.com/tusharsaxena/ConsumableMaster/issues/20) `severity:low` Replace core/SlashCommands.lua's hand-written dispatcher with LibKa0s-Slash-1.0 (original reasoning, later superseded)
- [#19](https://github.com/tusharsaxena/ConsumableMaster/issues/19) `severity:low` Optimize formatNumber
- [#18](https://github.com/tusharsaxena/ConsumableMaster/issues/18) `severity:low` Wire the remaining config consumers onto FireConfigChanged
- [#17](https://github.com/tusharsaxena/ConsumableMaster/issues/17) `severity:low` Add a Wago project ID or record its absence as a tracked deviation
- [#14](https://github.com/tusharsaxena/ConsumableMaster/issues/14) `severity:low` Session-scoped memo for `craftingQualityAtlas` (restates PLAN-05)

#### DpsRace — tri (2)

- [#15](https://github.com/tusharsaxena/DpsRace/issues/15) `severity:low` Automatic target count: bring it back only if the client can measure it
- [#1](https://github.com/tusharsaxena/DpsRace/issues/1) `severity:low` PvP burst race: run the duel probe and decide feasibility

#### DpsRace — wnd (2)

- [#18](https://github.com/tusharsaxena/DpsRace/issues/18) `severity:low` Late-cast flag counts Disengage End (199558), an automatic follow-up spell
- [#4](https://github.com/tusharsaxena/DpsRace/issues/4) `severity:low` Spell hit counts in the HUD and the Results breakdown

#### DropWatcher — tri (9)

- [#15](https://github.com/tusharsaxena/DropWatcher/issues/15) `severity:low` Run the owed in-game smoke checks (ITEM-6/7, SKIN-3/14/15/32/38/40/45), marked passed provisionally
- [#8](https://github.com/tusharsaxena/DropWatcher/issues/8) `severity:low` Record received trades in Ka0s Loot History as "Traded from X"
- [#7](https://github.com/tusharsaxena/DropWatcher/issues/7) `severity:low` Loot-spec nudge on entering an instance
- [#6](https://github.com/tusharsaxena/DropWatcher/issues/6) `severity:low` Droptimizer or SimC import for a "% DPS" column
- [#5](https://github.com/tusharsaxena/DropWatcher/issues/5) `severity:low` Read-only interop with the PLH and PLR loot protocols
- [#4](https://github.com/tusharsaxena/DropWatcher/issues/4) `severity:low` Addon comms between Drop Watcher users
- [#3](https://github.com/tusharsaxena/DropWatcher/issues/3) `severity:low` Void Core and bonus-roll awareness
- [#2](https://github.com/tusharsaxena/DropWatcher/issues/2) `severity:low` Tier-set and catalyst flags, and a verdict for tier tokens
- [#1](https://github.com/tusharsaxena/DropWatcher/issues/1) `severity:low` Wishlist with tiers (BiS, Need, Nice, Mog) and a groupmate-looted alert

#### DropWatcher — wnd (0)


#### KickCD — tri (7)

- [#35](https://github.com/tusharsaxena/KickCD/issues/35) `severity:low` A large Text Label font reaches down into the icon grid
- [#34](https://github.com/tusharsaxena/KickCD/issues/34) `severity:low` Cast bar drag handle does not move when a cast-bar-attached label is toggled
- [#5](https://github.com/tusharsaxena/KickCD/issues/5) `severity:low` Add the ability to add items along with spells for tracking
- [#4](https://github.com/tusharsaxena/KickCD/issues/4) `severity:medium` Icon Zoom
- [#3](https://github.com/tusharsaxena/KickCD/issues/3) `severity:medium` Partial Charge Swipe
- [#2](https://github.com/tusharsaxena/KickCD/issues/2) `severity:low` Cast bar background animation
- [#1](https://github.com/tusharsaxena/KickCD/issues/1) `severity:low` Add more customization options for the glow effects

#### KickCD — wnd (4)

- [#23](https://github.com/tusharsaxena/KickCD/issues/23) `severity:low` Linked-Focus page keeps its host-drawn strip: RenderTabbedSchema opts cannot replace the rows with a link notice
- [#14](https://github.com/tusharsaxena/KickCD/issues/14) `severity:low` LibKa0s-Item-1.0: declined — a spell-cooldown addon with no item concept
- [#12](https://github.com/tusharsaxena/KickCD/issues/12) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#11](https://github.com/tusharsaxena/KickCD/issues/11) `severity:low` Adopt LibKa0s `RenderGrid` as a second consumer for KickCD's settings lists

#### LibKa0s — tri (5)

- [#65](https://github.com/tusharsaxena/LibKa0s/issues/65) `severity:low` Skin: a skin editor for the Ka0s skins, built on LibKa0sSkinTester
- [#44](https://github.com/tusharsaxena/LibKa0s/issues/44) `severity:low` WoW:F client support (collection-wide)
- [#6](https://github.com/tusharsaxena/LibKa0s/issues/6) `severity:low` Add localization (i18n) support to LibKa0s
- [#5](https://github.com/tusharsaxena/LibKa0s/issues/5) `severity:low` Perf: in-combat and out-of-combat capture variants
- [#3](https://github.com/tusharsaxena/LibKa0s/issues/3) `severity:low` Publish LibKa0s to CurseForge as a library project

#### LibKa0s — wnd (10)

- [#70](https://github.com/tusharsaxena/LibKa0s/issues/70) `severity:low` Promote the line chart now the Skin Tester draws one
- [#50](https://github.com/tusharsaxena/LibKa0s/issues/50) `severity:low` Options: a grid composer for rows of mixed controls | options-ui-§19 options-ui-§8
- [#49](https://github.com/tusharsaxena/LibKa0s/issues/49) `severity:low` Promotion candidates from Drop Watcher: chat sender, tooltip line reader, loot-line parser, restriction tracker | library-stack-§7
- [#26](https://github.com/tusharsaxena/LibKa0s/issues/26) `severity:low` Cut any release beyond v1.26.0 and v1.27.0: declined — owner decision 5, this cycle does not ship
- [#25](https://github.com/tusharsaxena/LibKa0s/issues/25) `severity:low` Ship a RESULTS.md figure by hand: declined — a hand-edit is the defect C08 is about, not its fix | documentation-§3
- [#24](https://github.com/tusharsaxena/LibKa0s/issues/24) `severity:low` Publish a no-op Options surface from LibKa0s: declined — it would live in the payload the stub exists for the absence of
- [#23](https://github.com/tusharsaxena/LibKa0s/issues/23) `severity:low` Flip the shared mock's GetHeight in this plan: declined — kit 15 is additive, the flip is kit 16
- [#22](https://github.com/tusharsaxena/LibKa0s/issues/22) `severity:low` Rename the minimise icon key: declined — the key is half a texture path, not user-facing text | localization-§5
- [#21](https://github.com/tusharsaxena/LibKa0s/issues/21) `severity:low` Rebind lib.MakeCloseButton: declined — the library cannot infer the vendor path it would need
- [#10](https://github.com/tusharsaxena/LibKa0s/issues/10) `severity:low` LibKa0s-Options-1.0: the flat dropdown skin belongs to OptionsWidgets makeDropdown, not to each consumer

#### LibKa0sSkinTester — tri (0)


#### LibKa0sSkinTester — wnd (0)


#### LootHistory — tri (4)

- [#17](https://github.com/tusharsaxena/LootHistory/issues/17) `severity:low` Confirm the LOOT_ROLL_YOU_WON assumption with a real group-loot roll win
- [#16](https://github.com/tusharsaxena/LootHistory/issues/16) `severity:medium` Handle item-returning refunds ("You are refunded: [item]" on CHAT_MSG_LOOT)
- [#11](https://github.com/tusharsaxena/LootHistory/issues/11) `severity:low` UI: configurable window styling (border/background/font)
- [#9](https://github.com/tusharsaxena/LootHistory/issues/9) `severity:low` UI: column chooser (reorder + show/hide table columns)

#### LootHistory — wnd (6)

- [#29](https://github.com/tusharsaxena/LootHistory/issues/29) `severity:low` Withdraw the ratified performance-§12 exemption: declined — the citations rotted, the argument did not | performance-§12
- [#22](https://github.com/tusharsaxena/LootHistory/issues/22) `severity:low` Wire LibKa0s-Perf-1.0 and a performance harness
- [#21](https://github.com/tusharsaxena/LootHistory/issues/21) `severity:low` Move the AH Price settings page onto LibKa0s Options SetRenderer
- [#20](https://github.com/tusharsaxena/LootHistory/issues/20) `severity:low` Draw the inverted set pickers with a LibKa0s Options widget maker
- [#19](https://github.com/tusharsaxena/LootHistory/issues/19) `severity:low` Adopt LibKa0s Core's window chrome (SKIN / ApplySkin / MakeCloseButton) for this addon's windows
- [#18](https://github.com/tusharsaxena/LootHistory/issues/18) `severity:low` Add a serialized v2 export format

#### MultiMeters — tri (8)

- [#57](https://github.com/tusharsaxena/MultiMeters/issues/57) `severity:low` Death recap: the two-pane window needs its own event capture; the diagnostic still points at closed #1
- [#18](https://github.com/tusharsaxena/MultiMeters/issues/18) `severity:low` Date a death against the run it happened in ("time into the fight")
- [#12](https://github.com/tusharsaxena/MultiMeters/issues/12) `severity:low` Keep snapped windows attached, so they move as one block
- [#11](https://github.com/tusharsaxena/MultiMeters/issues/11) `severity:low` Snap windows to each other and to the screen
- [#10](https://github.com/tusharsaxena/MultiMeters/issues/10) `severity:low` Automatic screenshot of the end-of-dungeon summary
- [#9](https://github.com/tusharsaxena/MultiMeters/issues/9) `severity:low` End-of-dungeon summary popup, after a delay | architecture-§4
- [#8](https://github.com/tusharsaxena/MultiMeters/issues/8) `severity:low` Multiple class / role / spec icon sets
- [#2](https://github.com/tusharsaxena/MultiMeters/issues/2) `severity:medium` Enemy damage taken belongs in its own window, not in a column

#### MultiMeters — wnd (6)

- [#53](https://github.com/tusharsaxena/MultiMeters/issues/53) `severity:low` Decline RenderTabbedSchema opts.tabs for the Columns page
- [#46](https://github.com/tusharsaxena/MultiMeters/issues/46) `severity:low` Split any file for the 1500-line cap: declined — the fifteen breaches are remarked, not moved | layout-§1
- [#25](https://github.com/tusharsaxena/MultiMeters/issues/25) `severity:high` Deaths column counts feign death as a death
- [#20](https://github.com/tusharsaxena/MultiMeters/issues/20) `severity:low` LibKa0s-Item-1.0: declined — a damage meter has no item surface
- [#16](https://github.com/tusharsaxena/MultiMeters/issues/16) `severity:high` A pet's interrupts vanish mid-run, and its rows never fold out of combat
- [#15](https://github.com/tusharsaxena/MultiMeters/issues/15) `severity:medium` Recover Targets section names during a pull via the player's own breakdown

#### Outfitter — tri (0)


#### Outfitter — wnd (0)


#### PanelMaster — tri (7)

- [#26](https://github.com/tusharsaxena/PanelMaster/issues/26) `severity:low` Localization pass held: 0.1.0 ships English-only with the NS.L seam already wired
- [#13](https://github.com/tusharsaxena/PanelMaster/issues/13) `severity:low` Autosize a panel to a target frame, with per-side padding
- [#11](https://github.com/tusharsaxena/PanelMaster/issues/11) `severity:low` Let players supply their own artwork via a companion addon folder
- [#10](https://github.com/tusharsaxena/PanelMaster/issues/10) `severity:low` Ship bundled artwork as optional download packs to cut download size
- [#8](https://github.com/tusharsaxena/PanelMaster/issues/8) `severity:low` Animate the mouseover fade instead of snapping
- [#5](https://github.com/tusharsaxena/PanelMaster/issues/5) `severity:low` Live preview while dragging the editor's geometry sliders
- [#2](https://github.com/tusharsaxena/PanelMaster/issues/2) `severity:low` Add an optional text label inside a panel | options-ui-§11 options-ui-§8

#### PanelMaster — wnd (17)

- [#55](https://github.com/tusharsaxena/PanelMaster/issues/55) `severity:low` Settings: one page per instance with pinned nav rail and tab strip (AuraMaster#6 pattern) | options-ui-§13
- [#53](https://github.com/tusharsaxena/PanelMaster/issues/53) `severity:low` LibKa0s-Compat-1.0 has no member this addon's core/Compat.lua could hand over
- [#51](https://github.com/tusharsaxena/PanelMaster/issues/51) `severity:medium` Drag-stop writes a panel's anchor with no architecture-§5 register row | architecture-§5 debug-logging-§10 events-frames-taint-§8 localization-§1 options-ui-§16
- [#46](https://github.com/tusharsaxena/PanelMaster/issues/46) `severity:low` LibKa0s-Pool-1.0: declined — the pool is keyed by frame name and releases per object
- [#45](https://github.com/tusharsaxena/PanelMaster/issues/45) `severity:low` LibKa0s-Item-1.0: declined — a backdrop-panel addon has no item domain
- [#43](https://github.com/tusharsaxena/PanelMaster/issues/43) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#31](https://github.com/tusharsaxena/PanelMaster/issues/31) `severity:low` Adopt LibKa0s-Perf-1.0 and wire a performance capture | options-ui-§2
- [#30](https://github.com/tusharsaxena/PanelMaster/issues/30) `severity:low` Adopt LibKa0s Options' RestoreAllDefaults, InlineButtonPair, LSMValues and color codecs
- [#29](https://github.com/tusharsaxena/PanelMaster/issues/29) `severity:low` Port the /pm list LIST_GROUP_ORDER constant onto LibKa0s-Slash-1.0
- [#28](https://github.com/tusharsaxena/PanelMaster/issues/28) `severity:low` Adopt LibKa0s-DebugLog-1.0's ConsoleCheckbox() for the debug console row
- [#27](https://github.com/tusharsaxena/PanelMaster/issues/27) `severity:low` Re-export LibKa0s-Core-1.0's window chrome (SKIN, ApplySkin, MakeCloseButton) from the host
- [#25](https://github.com/tusharsaxena/PanelMaster/issues/25) `severity:low` Review follow-ups kept open as baselines with no plan
- [#24](https://github.com/tusharsaxena/PanelMaster/issues/24) `severity:medium` Review follow-up: performance-§1–§4 became MUST after the audit baseline and have no counterpart here | performance-§1
- [#18](https://github.com/tusharsaxena/PanelMaster/issues/18) `severity:low` Known limitation already ratified as accepted deviation A-008
- [#17](https://github.com/tusharsaxena/PanelMaster/issues/17) `severity:low` No login-time sweep to reposition panels
- [#16](https://github.com/tusharsaxena/PanelMaster/issues/16) `severity:low` Class color is read from the player's own class only
- [#4](https://github.com/tusharsaxena/PanelMaster/issues/4) `severity:low` Keep preview placeholders out of the persisted registry

#### PartyFrameEnhanced — tri (9)

- [#15](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/15) `severity:low` Settings missing and LUA errors when opening some settings on WoW:F
- [#11](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/11) `severity:low` Support arena frames
- [#9](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/9) `severity:low` Translate the addon (deDE, frFR, and others) | localization-§1
- [#8](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/8) `severity:low` Attach the player's row to PlayerFrame in Blizzard's classic party layout
- [#7](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/7) `severity:low` Show auras and target-of-target on target frames
- [#6](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/6) `severity:low` Show the cast's target on the cast bar
- [#5](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/5) `severity:low` Allow per-unit style overrides
- [#4](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/4) `severity:low` Draw empowered-cast stage markers on cast bars
- [#2](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/2) `severity:low` Attach to more frame systems: ElvUI, Cell, Grid2, VuhDo, DandersFrames | library-stack-§6

#### PartyFrameEnhanced — wnd (1)

- [#1](https://github.com/tusharsaxena/PartyFrameEnhanced/issues/1) `severity:low` Support raid frames

#### PremadeGroupsFilterExtension — tri (0)


#### PremadeGroupsFilterExtension — wnd (0)


#### PrettyChat — tri (3)

- [#6](https://github.com/tusharsaxena/PrettyChat/issues/6) `severity:low` Known limitation: positional %n$s format rendering is WoW-only
- [#3](https://github.com/tusharsaxena/PrettyChat/issues/3) `severity:low` Known limitation: load-time snapshot needs /reload for newly added globals
- [#2](https://github.com/tusharsaxena/PrettyChat/issues/2) `severity:low` Add a Custom replacements section to the Settings panel

#### PrettyChat — wnd (11)

- [#17](https://github.com/tusharsaxena/PrettyChat/issues/17) `severity:low` LibKa0s-Bus-1.0: this addon publishes and receives no message
- [#16](https://github.com/tusharsaxena/PrettyChat/issues/16) `severity:low` LibKa0s-Compat-1.0: no version-variant API or secret value passes through this addon
- [#14](https://github.com/tusharsaxena/PrettyChat/issues/14) `severity:low` Withdraw the ratified performance-§12 exemption: declined — the citations rotted, the argument did not | performance-§12
- [#13](https://github.com/tusharsaxena/PrettyChat/issues/13) `severity:low` LibKa0s-Pool-1.0: declined — AceGUI is already the pool
- [#12](https://github.com/tusharsaxena/PrettyChat/issues/12) `severity:low` LibKa0s-Item-1.0: declined — the addon edits format templates, never links
- [#11](https://github.com/tusharsaxena/PrettyChat/issues/11) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#10](https://github.com/tusharsaxena/PrettyChat/issues/10) `severity:low` LIBKA0S-12: Perf declined on two independent structural grounds | performance-§12
- [#8](https://github.com/tusharsaxena/PrettyChat/issues/8) `severity:low` Expose per-character or per-realm profile scoping
- [#7](https://github.com/tusharsaxena/PrettyChat/issues/7) `severity:low` Add `## X-Wago-ID` to PrettyChat.toc | toc-file-§1
- [#5](https://github.com/tusharsaxena/PrettyChat/issues/5) `severity:low` Known limitation: Retail only, Classic untested
- [#1](https://github.com/tusharsaxena/PrettyChat/issues/1) `severity:low` Update default format strings

#### QuickComms — tri (7)

- [#12](https://github.com/tusharsaxena/QuickComms/issues/12) `severity:low` Rebuild Share: export and import strings
- [#7](https://github.com/tusharsaxena/QuickComms/issues/7) `severity:low` Re-evaluate whisper-to-target / whisper-to-focus channels
- [#5](https://github.com/tusharsaxena/QuickComms/issues/5) `severity:low` Callout keybind: a direct key for a single callout
- [#4](https://github.com/tusharsaxena/QuickComms/issues/4) `severity:low` Callout mark: apply a raid marker to the target when sending
- [#3](https://github.com/tusharsaxena/QuickComms/issues/3) `severity:low` Callout cooldown: per-callout spam protection
- [#2](https://github.com/tusharsaxena/QuickComms/issues/2) `severity:low` Callout confirm: require a second click before sending
- [#1](https://github.com/tusharsaxena/QuickComms/issues/1) `severity:low` Callout variants: several wordings picked at random

#### QuickComms — wnd (1)

- [#11](https://github.com/tusharsaxena/QuickComms/issues/11) `severity:low` Stop graying color pairs (options-ui-§17, anti-pattern #74) | anti-pattern #74 options-ui-§17

#### WhatGroup — tri (2)

- [#24](https://github.com/tusharsaxena/WhatGroup/issues/24) `severity:low` In-game simulator (like Drop Watcher's /dw sim) | compat-§1
- [#2](https://github.com/tusharsaxena/WhatGroup/issues/2) `severity:medium` Validate the MapIDs and SpellIDs

#### WhatGroup — wnd (10)

- [#21](https://github.com/tusharsaxena/WhatGroup/issues/21) `severity:low` LibKa0s-Bus-1.0: no bus in this addon for it to wrap | architecture-§4
- [#18](https://github.com/tusharsaxena/WhatGroup/issues/18) `severity:low` Withdraw the ratified performance-§12 exemption: declined — the citations rotted, the argument did not | performance-§12
- [#14](https://github.com/tusharsaxena/WhatGroup/issues/14) `severity:low` LibKa0s-Pool-1.0: declined — a one-shot singleton window with a fixed field set
- [#13](https://github.com/tusharsaxena/WhatGroup/issues/13) `severity:low` LibKa0s-Item-1.0: declined — LFG metadata and spell IDs, no items
- [#12](https://github.com/tusharsaxena/WhatGroup/issues/12) `severity:low` LibKa0s-Widgets-1.0: declined — no control in this addon wants it
- [#11](https://github.com/tusharsaxena/WhatGroup/issues/11) `severity:low` LIBKA0S-05: DebugLog console window position not persisted (library gap)
- [#10](https://github.com/tusharsaxena/WhatGroup/issues/10) `severity:low` LIBKA0S-08: global reset stays host-owned as Helpers.RestoreAllDefaults
- [#9](https://github.com/tusharsaxena/WhatGroup/issues/9) `severity:low` LIBKA0S-09: Helpers.InlineButton stays host-owned
- [#7](https://github.com/tusharsaxena/WhatGroup/issues/7) `severity:low` LIBKA0S-15: Perf declined — ratified in ARCHITECTURE Documented deviations
- [#5](https://github.com/tusharsaxena/WhatGroup/issues/5) `severity:low` Add an `X-Wago-ID` to `WhatGroup.toc` or ratify a Curse-only deviation

