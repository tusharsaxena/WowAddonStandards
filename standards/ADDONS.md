# Ka0s Addon Roster

**The single, editable list of addons in the Ka0s collection.** This roster is a
**standards-process input**: it defines *which* addons the standard codifies rules for, and whose
current state feeds the [next standards refresh](README.md). Compliance auditing is no longer run from
this repo — each addon audits **itself**, in its own repo, via `/wow-addon:standards-audit` (see
[`../AUDIT.md`](../AUDIT.md)).

> **This is the one place to edit collection scope.** Add a row when you ship a new Ka0s addon so it
> is picked up by the *next* standards refresh. Remove a row to retire an addon.

## In-scope addons

Each addon lives in its own repository, as a **sibling folder** next to this repo under
`/mnt/d/Profile/Users/Tushar/Documents/GIT/`. Paths below are relative to this file (`standards/`).

| Addon | Folder | Repository | Launcher menu entries (launcher-§2) |
|---|---|---|---|
| Ka0s Absorb Tracker | [`../../AbsorbTracker/`](../../AbsorbTracker/) | https://github.com/tusharsaxena/AbsorbTracker | Enabled · Locked |
| Ka0s Aura Master | [`../../AuraMaster/`](../../AuraMaster/) | https://github.com/tusharsaxena/AuraMaster | Enabled · Locked · Test mode |
| Ka0s Bank Ledger | [`../../BankLedger/`](../../BankLedger/) | https://github.com/tusharsaxena/BankLedger | Enabled · Locked · Test mode · Show window (the ledger browser) |
| Ka0s Consumable Master | [`../../ConsumableMaster/`](../../ConsumableMaster/) | https://github.com/tusharsaxena/ConsumableMaster | Enabled · Locked (the macro bar) |
| Ka0s KickCD | [`../../KickCD/`](../../KickCD/) | https://github.com/tusharsaxena/KickCD | Enabled · Locked |
| Ka0s Loot History | [`../../LootHistory/`](../../LootHistory/) | https://github.com/tusharsaxena/LootHistory | Enabled · Locked · Test mode · Show window (the History browser) |
| Ka0s Multi Meters | [`../../MultiMeters/`](../../MultiMeters/) | https://github.com/tusharsaxena/MultiMeters | Enabled · Locked · Test mode · Show window (its meter windows) |
| Ka0s Panel Master | [`../../PanelMaster/`](../../PanelMaster/) | https://github.com/tusharsaxena/PanelMaster | Enabled · Locked |
| Ka0s Party Frame Enhanced | [`../../PartyFrameEnhanced/`](../../PartyFrameEnhanced/) | https://github.com/tusharsaxena/PartyFrameEnhanced | Enabled · Locked |
| Ka0s Pretty Chat | [`../../PrettyChat/`](../../PrettyChat/) | https://github.com/tusharsaxena/PrettyChat | Enabled |
| Ka0s WhatGroup | [`../../WhatGroup/`](../../WhatGroup/) | https://github.com/tusharsaxena/WhatGroup | Enabled · Locked · Test mode · Show window (the group popup) |

**The launcher column is normative input to an audit, not decoration.** Every addon ships one minimap button and one
broker plugin, from one LibDataBroker-1.1 object (launcher). **Left-click opens the settings panel and right-click opens
the options menu in every row above** (launcher-§2). The column lists that menu's entries, which are the toggles the addon
has, in the menu's fixed order — **Enabled** always, then **Locked** where it has a lock, **Test mode** where it has a
test mode, and **Show window** where it has a primary window, a parenthesis naming the window or what the lock holds — read from each addon's
`core/LauncherSetup.lua` and Master-controls rows, so an audit checks the descriptor against it rather than re-deriving
it from the addon's shape. A new addon lists its entries with its row. The column replaced v2.66.0's left-click rung
column when v2.67.0 retired the rungs.

## Ka0s-owned library repos

Shared code authored inside the collection lives in its **own** repository and is vendored into the
addons (library-stack-§7). Such a repo **is** in scope for the standards process and is audited — but
against **library-stack-§7's applicability list**, not the addon rule set: it has no TOC, no
player-facing README, no settings panel and no install, so the addon-shaped sections do not bind it.

| Library repo | Folder | Repository |
|---|---|---|
| LibKa0s | [`../../LibKa0s/`](../../LibKa0s/) | https://github.com/tusharsaxena/LibKa0s |

## Documentation-and-tooling repos

The **third repo kind** (`documentation-§8`). These ship **no Lua to the WoW client** and vendor no
payload into any addon's `libs/`, so they are neither addons nor Ka0s-owned libraries. They are in
scope for the standards process and are audited — against **`documentation-§8`'s applicability
lists**, not the addon rule set and not `library-stack-§7`'s.

| Repo | Folder | Repository |
|---|---|---|
| WowAddonStandards | [`../`](../) | https://github.com/tusharsaxena/WowAddonStandards |
| wow-addon | [`../../wow-addon/`](../../wow-addon/) | https://github.com/tusharsaxena/wow-addon |

`WowAddonStandards` is this repo — listed because a roster that omits the repo it lives in is the
one place nobody thinks to look, and because `AUDIT.md` resolves a repo's kind from this file.

**Not in the rotation:** `Ka0sAddonsCommonTasks` is deliberately outside it and is not audited.

## Adding an addon

1. Add one row above (display name, folder, repository URL, launcher menu entries). Keep the table alphabetical by folder.
2. That's it for scope. The addon is now covered by **the next standards refresh** — its current
   habits become an input to [`STANDARDS.md`](STANDARDS.md) (see [`README.md`](README.md)).
3. New addons should be scaffolded from the standard so they are born compliant — see
   [`../NEW_ADDON.md`](../NEW_ADDON.md) and [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md).

## Notes

- **Do not modify the addons from this repo.** This repository holds the standard and the process
  playbooks only; each addon's code lives in its own repository and is changed there.
- **Audits live with the addon.** Each addon's compliance runs are written to *its own*
  `docs/audits/<YYYY-MM-DD>/` folder (see [`../AUDIT.md`](../AUDIT.md)), not here. Changing this roster
  affects which addons feed the next standards refresh — nothing in another repo.
