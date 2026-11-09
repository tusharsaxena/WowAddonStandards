# Ka0s Addon Roster

**The single, editable list of addons in the Ka0s collection.** This roster is a
**standards-process input**: it defines *which* addons the standard codifies rules for, and whose
current state feeds the [next standards refresh](README.md). Compliance auditing is no longer run from
this repo — each addon audits **itself**, in its own repo, via `/dev-copilot:wow-standards-audit` (see
[`../AUDIT.md`](../AUDIT.md)).

> **This is the one place to edit collection scope.** Add a row when you ship a new Ka0s addon so it
> is picked up by the *next* standards refresh. Remove a row to retire an addon.

## In-scope addons

Each addon lives in its own repository, as a **sibling folder** next to this repo under
`/mnt/d/Profile/Users/Tushar/Documents/GIT/`. Paths below are relative to this file (`standards/`).

| Addon | Folder | Repository | Clients | Launcher menu entries (launcher-§2) | Skin picker preview (skinning-§10) | Sim mode checkbox (options-ui-§15) |
|---|---|---|---|---|---|---|
| Ka0s Absorb Tracker | `../../AbsorbTracker/` | https://github.com/tusharsaxena/AbsorbTracker | Retail · Forever | Enabled · Locked · Sim mode | unlock | next to Lock frame |
| Ka0s Aura Master | `../../AuraMaster/` | https://github.com/tusharsaxena/AuraMaster | Retail (port pending) | Enabled · Locked · Test mode | test | none |
| Ka0s Bank Ledger | `../../BankLedger/` | https://github.com/tusharsaxena/BankLedger | Retail (port pending) | Enabled · Locked · Test mode · Sim mode · Show window (the ledger browser) | test | next to Test mode |
| Ka0s Consumable Master | `../../ConsumableMaster/` | https://github.com/tusharsaxena/ConsumableMaster | Retail · Forever | Enabled · Locked (the macro bar) | unlock | none |
| Ka0s DPS Race | `../../DpsRace/` | https://github.com/tusharsaxena/DpsRace | Retail (port pending) | Enabled · Locked · Test mode · Sim mode · Show window (the race HUD) | test | next to Test mode |
| Ka0s Drop Watcher | `../../DropWatcher/` | https://github.com/tusharsaxena/DropWatcher | Retail (port pending) | Enabled · Locked · Test mode · Sim mode · Show window (the drop feed) | test | next to Test mode |
| Ka0s KickCD | `../../KickCD/` | https://github.com/tusharsaxena/KickCD | Retail (port pending) | Enabled · Locked · Sim mode | unlock | next to Lock frame |
| Ka0s Skin Tester | `../../LibKa0sSkinTester/` | https://github.com/tusharsaxena/LibKa0sSkinTester | Retail · Forever | Enabled · Show window (the skin showroom) | window (the skin showroom) | none |
| Ka0s Loot History | `../../LootHistory/` | https://github.com/tusharsaxena/LootHistory | Retail (port pending) | Enabled · Locked · Test mode · Sim mode · Show window (the History browser) | test | next to Test mode |
| Ka0s Multi Meters | `../../MultiMeters/` | https://github.com/tusharsaxena/MultiMeters | Retail (port pending) | Enabled · Locked · Test mode · Sim mode · Show window (its meter windows) | test | next to Test mode |
| Ka0s Outfitter Reborn | `../../OutfitterReborn/` | https://github.com/tusharsaxena/OutfitterReborn | Retail · Forever | Enabled · Locked (the outfit bar) · Test mode · Show window (the outfit window) | test | none |
| Ka0s Panel Master | `../../PanelMaster/` | https://github.com/tusharsaxena/PanelMaster | Retail · Forever | Enabled · Locked | unlock | none |
| Ka0s Party Frame Enhanced | `../../PartyFrameEnhanced/` | https://github.com/tusharsaxena/PartyFrameEnhanced | Retail · Forever | Enabled · Locked | unlock | none |
| Ka0s Premade Groups Filter Extension | `../../PremadeGroupsFilterExtension/` | https://github.com/tusharsaxena/PremadeGroupsFilterExtension | Retail | Enabled · Test mode (the attached panel shown on its own) | test | none |
| Ka0s Pretty Chat | `../../PrettyChat/` | https://github.com/tusharsaxena/PrettyChat | Retail · Forever | Enabled | console (the debug console, filled with `/pc test` sample lines) | none |
| Ka0s Quick Comms | `../../QuickComms/` | https://github.com/tusharsaxena/QuickComms | Retail (port pending) | Enabled · Locked · Test mode · Show window (its Comms Pads) | test | none |
| Ka0s Skill Master | `../../SkillMaster/` | https://github.com/tusharsaxena/SkillMaster | Forever | Enabled · Locked · Test mode · Sim mode · Show window (the skills window) | test | next to Test mode |
| Ka0s WhatGroup | `../../WhatGroup/` | https://github.com/tusharsaxena/WhatGroup | Retail | Enabled · Locked · Test mode · Show window (the group popup) | test | none |

**The Clients column is normative input to an audit, not decoration** (v2.103.0). It is the single source of truth that
`dev-copilot` and the audit read for which game clients an addon supports, and it records what the addon **ships today**,
not what it is planned to ship: a port flips its row in the same change that lands the port. The value decides the TOC
shape the addon needs (toc-file-§3) and what an audit flags (clients-§2). Four values, `Retail · Forever`, `Retail`, `Forever` and
`Retail (port pending)`, written verbatim. `Retail · Forever` is the default; `Retail` and `Forever` are single-client values the
owner sets when the addon's core does not exist on the other client, with the reason recorded in the addon's README and
`docs/ARCHITECTURE.md` (clients-§2, owner ruling of 2026-11-10):

| Value | Meaning | TOC shape it requires | What the audit flags |
|---|---|---|---|
| `Retail · Forever` | Ported. One codebase serves Retail and WoW Forever. | One unsuffixed TOC with a two-number line, `## Interface: <retail>, <forever>`. No load-gating line. | Any clients-§3..§6 shape that is missing or broken: detection outside Compat, an ungated per-client feature, a filtered seed list, a smoke file or test run that covers one client. |
| `Retail` | Retail-only **by the owner's decision**, not ported and not to be. | One number, plus `## AllowLoadGameType: standard` and `## ExcludeLoadGameType: camelot`, so Forever never lists it. | A missing or misspelled load-gating line; a `WOW_PROJECT_CAMELOT` read or a Forever branch (dead code in a Retail-only addon); no recorded reason in the README and `docs/ARCHITECTURE.md`. |
| `Forever` | Forever-only **by the owner's decision**, because the addon's core does not exist on Retail (clients-§9). | One number, `## Interface: 16001`, plus `## AllowLoadGameType: camelot` and `## ExcludeLoadGameType: standard`, so Retail never lists it. | A missing or misspelled load-gating line; an `IsRetail()` read or other Retail branch, a Retail seed list, or a `clients = { "retail" }` declaration (dead code in a Forever-only addon); a suite not run as `KA0S_KIT_CLIENT=forever`; no recorded reason in the README and `docs/ARCHITECTURE.md`. |
| `Retail (port pending)` | Retail today, not ported yet. A port flips the row to `Retail · Forever`. | One number and **no** load-gating line, because Forever players already run some of these addons out of date and must not be cut off. | A new Retail-only feature added with no declaration (clients-§4). It does **not** flag the missing dual-client shapes. |

Both clients are named in clients-§1. The Clients column gives no addon a Classic value, because the collection has no Classic support.

**The launcher column is normative input to an audit, not decoration.** Every addon ships one minimap button and one
broker plugin, from one LibDataBroker-1.1 object (launcher). **Left-click opens the settings panel and right-click opens
the options menu in every row above** (launcher-§2). The column lists that menu's entries, which are the toggles the addon
has, in the menu's fixed order — **Enabled** always, then **Locked** where it has a lock, **Test mode** where it has a
test mode, **Sim mode** where it has an in-game simulator (recorded from v2.99.0; launcher-§2 added the entry in the full
skinning run), and **Show window** where it has a primary window, a parenthesis naming the window or what the lock holds — read from each addon's
`core/LauncherSetup.lua` and Master-controls rows, so an audit checks the descriptor against it rather than re-deriving
it from the addon's shape. A new addon lists its entries with its row. The column replaced v2.66.0's left-click rung
column when v2.67.0 retired the rungs.

**Show window** also means the addon owes launcher-§6's key binding: a `CLICK` binding in a root `Bindings.xml` on the
same toggle handler. The audit reads this column for that too. No new column.

**The skin picker preview column is normative input too.** It names the mode the addon's skin picker enters while the
addon's main surface is hidden, and that its eye toggles: the first of **test**, **unlock**, **window** and **console** the
addon has (skinning-§10), read like the launcher column from the descriptor and Master-controls rows, with **console**
PrettyChat's by owner ruling. **none** is the
documented no-preview case: the picker draws no eye and enters nothing, and the parenthesis says why. No row reads **none**
today: PremadeGroupsFilterExtension's was the last, and it reads **test** from v2.100.0, when `/pgfe test` gave its attached
panel a session-only test mode of its own (owner ruling of 2026-11-04). A new addon lists its mode with its row; a new
**none** needs an owner ruling.

**The Sim mode checkbox column is normative input too** (v2.99.0). It names where an addon with an in-game simulator
(preview-mode, *The in-game simulator*) draws the session-only *Sim mode* checkbox in General → Master controls: **next to
Test mode** where the addon has a *Test mode* row, **next to Lock frame** where unlocking is its preview and there is no
*Test mode* row (`lockIsPreview`), and **none** for an addon with no simulator (options-ui-§15). It matches the launcher
column: an addon whose launcher lists *Sim mode* owes the checkbox, and one that does not owes none. Both read one
`isSimMode()`, ticked while the sim window is shown or a session is running and unticked when neither (v2.100.0). A missing
checkbox is anti-pattern #112. A new addon lists its answer with its row.

## Ka0s-owned library repos

Shared code authored inside the collection lives in its **own** repository and is vendored into the
addons (library-stack-§7). Such a repo **is** in scope for the standards process and is audited — but
against **library-stack-§7's applicability list**, not the addon rule set: it has no TOC, no
player-facing README, no settings panel and no install, so the addon-shaped sections do not bind it.

| Library repo | Folder | Repository |
|---|---|---|
| LibKa0s | `../../LibKa0s/` | https://github.com/tusharsaxena/LibKa0s |

## Documentation-and-tooling repos

The **third repo kind** (`documentation-§8`). These ship **no Lua to the WoW client** and vendor no
payload into any addon's `libs/`, so they are neither addons nor Ka0s-owned libraries. They are in
scope for the standards process and are audited — against **`documentation-§8`'s applicability
lists**, not the addon rule set and not `library-stack-§7`'s.

| Repo | Folder | Repository |
|---|---|---|
| WowAddonStandards | `../` | https://github.com/tusharsaxena/WowAddonStandards |
| dev-copilot | `../../dev-copilot/` | https://github.com/tusharsaxena/dev-copilot |

`WowAddonStandards` is this repo — listed because a roster that omits the repo it lives in is the
one place nobody thinks to look, and because `AUDIT.md` resolves a repo's kind from this file.

**Not in the rotation:** `Ka0sAddonsCommonTasks` is deliberately outside it and is not audited.

## Adding an addon

1. Add one row above (display name, folder, repository URL, launcher menu entries, skin picker preview). Keep the table alphabetical by folder.
2. That's it for scope. The addon is now covered by **the next standards refresh** — its current
   habits become an input to [`STANDARDS.md`](STANDARDS.md) (see [`README.md`](README.md)).
3. New addons should be scaffolded from the standard so they are born compliant — see
   [`../NEW_ADDON.md`](../NEW_ADDON.md) and [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md).

## Notes

- **Do not modify the addons from this repo.** This repository holds the standard and the process
  playbooks only; each addon's code lives in its own repository and is changed there.
- **Audits live with the addon.** Each addon's compliance runs are written to *its own*
  `docs/audits/<YYYY-MM-DD>/` folder (see [`../AUDIT.md`](../AUDIT.md)), not here; this repo's own
  `docs/audits/` holds only its own documentation-lane audits. Changing this roster
  affects which addons feed the next standards refresh — nothing in another repo.
