# Ka0s Addon Roster

**The single, editable list of addons in scope for this repo.** Both processes read scope from
here: the [standards](standards/) process codifies rules *for these addons*, and each
[audit](audit/) run measures *these addons* against the standard.

> **This is the one place to edit scope.** Add a row when you ship a new Ka0s addon and it is
> automatically in scope for the *next* standards refresh and the *next* audit run. Remove a row to
> retire an addon. Nothing else in the repo needs editing to change scope.

## In-scope addons

Each addon lives in its own repository, as a **sibling folder** next to this one under
`/mnt/d/Profile/Users/Tushar/Documents/GIT/`. Paths below are relative to this repo's root.

| Addon | Folder | Repository |
|---|---|---|
| Ka0s Absorb Tracker | [`../AbsorbTracker/`](../AbsorbTracker/) | https://github.com/tusharsaxena/absorbtracker |
| Ka0s Consumable Master | [`../ConsumableMaster/`](../ConsumableMaster/) | https://github.com/tusharsaxena/consumablemaster |
| Ka0s KickCD | [`../KickCD/`](../KickCD/) | https://github.com/tusharsaxena/kickcd |
| Ka0s Loot History | [`../LootHistory/`](../LootHistory/) | https://github.com/tusharsaxena/LootHistory |
| Ka0s Pretty Chat | [`../prettychat/`](../prettychat/) | https://github.com/tusharsaxena/prettychat |
| Ka0s WhatGroup | [`../WhatGroup/`](../WhatGroup/) | https://github.com/tusharsaxena/WhatGroup |

## Adding an addon

1. Add one row above (display name, folder, repository URL). Keep the table alphabetical by folder.
2. That's it for scope. The addon is now covered by:
   - **The next standards refresh** — its current habits become an input to `01_STANDARD.md`
     (see [`standards/README.md`](standards/README.md)).
   - **The next audit run** — it gets its own deviation-ID prefix and a per-addon gap report
     (see [`audit/README.md`](audit/README.md)).
3. New addons should be scaffolded from the standard so they are born compliant — see
   [`standards/02_NEW_ADDON_CONTEXT.md`](standards/02_NEW_ADDON_CONTEXT.md).

## Notes

- **Do not modify the addons from this repo.** This repository describes what should change; the
  actual code lives in the sibling repositories and is changed there, as a separate engagement.
- **Historical audit runs are frozen.** A run under `audit/<date>/` records the scope *as it was on
  that date* and is never edited. Changing this roster affects future runs only, not past ones.
