# Harvest 2026-08-25 — 01 Collection state

**Harvesting into:** Ka0s WoW Addon Standard **v2.33.0 (2026-08-25)**.
**First harvest run.** `harvests/` did not exist before this bundle; there is no prior watch list to
promote from, and every finding below is measured from scratch.

## Repos read

All eleven were read from the working tree at
`/mnt/d/Profile/Users/Tushar/Documents/GIT/`, plus each repo's GitHub issue store.

| Repo | Version | Last audit | Last review | Audited against |
|---|---|---|---|---|
| AbsorbTracker | 1.9.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| BankLedger | 1.0.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| ConsumableMaster | 1.5.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| KickCD | 1.2.1 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| LootHistory | 1.2.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| MultiMeters | 0.1.0 | *(none)* | *(none)* | — |
| PanelMaster | 1.0.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| PrettyChat | 1.4.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| WhatGroup | 1.3.0 | 2026-08-05 | 2026-08-05 | v2.21.0 |
| LibKa0s (library) | — | 2026-08-05 | 2026-08-05 | v2.21.0 |
| WowAddonStandards (self) | v2.33.0 | — | — | — |

**Every audit in the corpus was measured against v2.21.0 (2026-08-04).** Twelve minor versions have
landed since. The date filter (Step 3.1) therefore does real work in this run rather than being a
formality — see `02_FINDINGS.md`, where three otherwise-strong clusters are dismissed as settled.

**MultiMeters has never been audited or reviewed.** It is on the roster and shipping at 0.1.0; every
"N of 9" count below that rests on audit-bundle evidence rests on eight bundles, and MultiMeters
contributes only working-tree evidence.

## Roster drift

**On disk, unrostered — two repos, and their learnings have never been harvested by anything:**

- `BuffTextNotifications` (`BuffTextNotifications.toc:1-6`) — a Tushar-authored addon with a TOC, a
  `docs/ARCHITECTURE.md` written 2026-08-25, and no `## X-Standard` line, no `docs/` trio, no
  `.pkgmeta`, no audit history. It is not built to this standard and nothing in the collection's
  processes can see it.
- `WhoGotLoots` (`WhoGotLoots.toc:1-6`) — same shape, plus a five-file `docs/` set in an entirely
  different naming scheme (`DATA-STRUCTURES.md`, `EVENTS-AND-INTERACTIONS.md`, `MODULES.md`,
  `UI-SYSTEM.md`) and a multi-flavor `## Interface: 110002, 120000` that `toc-file-§3` forbids.

Neither is proposed for the roster here — that is a scope decision (`ADDONS.md`, "Adding an addon"),
not a standards finding. What matters for this run is that **the collection is 9 addons for every
count in this bundle, and 11 on disk.**

**Rostered but absent from this machine:** none. All nine rostered addons and `LibKa0s` were read.

Also present on disk and correctly out of scope: `Ka0sAddonsCommonTasks`, `wow-addon` (the plugin),
`dev-copilot`, and six non-WoW repos.

## Issue store coverage

Every rostered repo carries `state:` and `severity:` labels — no repo returned an empty label set,
so no repo in this sweep is un-swept. Totals read: **61 `state:will-not-do`** issues (closed) and
**86 `state:triaged`** issues (open) across the eleven repos. No `docs/pending/LEDGER.md` survives
anywhere; the migration to GitHub issues (v2.26.0) is complete, and every refusal read below carries
its `Provenance` line back to the ledger row it came from.
