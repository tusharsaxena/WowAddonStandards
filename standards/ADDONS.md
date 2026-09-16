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

| Addon | Folder | Repository | Launcher left-click (launcher-§2) |
|---|---|---|---|
| Ka0s Absorb Tracker | [`../../AbsorbTracker/`](../../AbsorbTracker/) | https://github.com/tusharsaxena/AbsorbTracker | **(b)** test mode |
| Ka0s Aura Master | [`../../AuraMaster/`](../../AuraMaster/) | https://github.com/tusharsaxena/AuraMaster | **(b)** lock / unlock — unlocking is the preview |
| Ka0s Bank Ledger | [`../../BankLedger/`](../../BankLedger/) | https://github.com/tusharsaxena/BankLedger | **(a)** the ledger browser |
| Ka0s Consumable Master | [`../../ConsumableMaster/`](../../ConsumableMaster/) | https://github.com/tusharsaxena/ConsumableMaster | **(b)** lock / unlock — the macro bar's lock |
| Ka0s KickCD | [`../../KickCD/`](../../KickCD/) | https://github.com/tusharsaxena/KickCD | **(b)** lock / unlock — unlocking is the preview |
| Ka0s Loot History | [`../../LootHistory/`](../../LootHistory/) | https://github.com/tusharsaxena/LootHistory | **(a)** the browser |
| Ka0s Multi Meters | [`../../MultiMeters/`](../../MultiMeters/) | https://github.com/tusharsaxena/MultiMeters | **(a)** its windows |
| Ka0s Panel Master | [`../../PanelMaster/`](../../PanelMaster/) | https://github.com/tusharsaxena/PanelMaster | **(b)** lock / unlock — unlocking is the preview |
| Ka0s Party Frame Enhanced | [`../../PartyFrameEnhanced/`](../../PartyFrameEnhanced/) | https://github.com/tusharsaxena/PartyFrameEnhanced | **(b)** test mode |
| Ka0s Pretty Chat | [`../../PrettyChat/`](../../PrettyChat/) | https://github.com/tusharsaxena/PrettyChat | **(c)** the settings panel |
| Ka0s WhatGroup | [`../../WhatGroup/`](../../WhatGroup/) | https://github.com/tusharsaxena/WhatGroup | **(a)** the group popup |

**The launcher column is normative input to an audit, not decoration.** Every addon ships one minimap button and one
broker plugin, from one LibDataBroker-1.1 object (launcher). **Right-click opens the settings panel in every row above.**
Left-click follows launcher-§2's three rungs, first match wins — **(a)** a primary window, **(b)** else a preview switch,
**(c)** else the settings panel — and the column records which rung this addon sits on so an audit can check it rather
than re-derive it from the addon's shape. A new addon picks its rung by the rule and fills the column in with its row.

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

1. Add one row above (display name, folder, repository URL, launcher left-click rung). Keep the table alphabetical by folder.
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
