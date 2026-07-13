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

| Addon | Folder | Repository |
|---|---|---|
| Ka0s Absorb Tracker | [`../../AbsorbTracker/`](../../AbsorbTracker/) | https://github.com/tusharsaxena/absorbtracker |
| Ka0s Consumable Master | [`../../ConsumableMaster/`](../../ConsumableMaster/) | https://github.com/tusharsaxena/consumablemaster |
| Ka0s KickCD | [`../../KickCD/`](../../KickCD/) | https://github.com/tusharsaxena/kickcd |
| Ka0s Loot History | [`../../LootHistory/`](../../LootHistory/) | https://github.com/tusharsaxena/LootHistory |
| Ka0s Pretty Chat | [`../../prettychat/`](../../prettychat/) | https://github.com/tusharsaxena/prettychat |
| Ka0s WhatGroup | [`../../WhatGroup/`](../../WhatGroup/) | https://github.com/tusharsaxena/WhatGroup |

## Adding an addon

1. Add one row above (display name, folder, repository URL). Keep the table alphabetical by folder.
2. That's it for scope. The addon is now covered by **the next standards refresh** — its current
   habits become an input to [`01_STANDARD.md`](01_STANDARD.md) (see [`README.md`](README.md)).
3. New addons should be scaffolded from the standard so they are born compliant — see
   [`../NEW_ADDON.md`](../NEW_ADDON.md) and [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md).

## Notes

- **Do not modify the addons from this repo.** This repository holds the standard and the process
  playbooks only; each addon's code lives in its own repository and is changed there.
- **Audits live with the addon.** Each addon's compliance runs are written to *its own*
  `docs/audits/<YYYY-MM-DD>/` folder (see [`../AUDIT.md`](../AUDIT.md)), not here. Changing this roster
  affects which addons feed the next standards refresh — nothing in another repo.
