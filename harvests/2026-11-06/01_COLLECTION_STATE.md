# Harvest 2026-11-06 — 01 Collection state

**Harvesting into:** Ka0s WoW Addon Standard **v2.101.0 (2026-11-04)** — `standards/STANDARDS.md:1`.
**Previous harvest:** `harvests/2026-09-22/`, which harvested into **v2.62.1** and released **v2.63.0**.
Thirty-eight minor releases have landed between the two runs, most of them from cross-repo runs planned in
Ka0sAddonsCommonTasks (skinning, keybinds and layout, sim and preview, smoke rounds), so the date filter does
most of the work this run.

**Scope of this run.** The owner asked for "all ka0s addons including Outfitter Reborn" and ruled on
2026-11-06 that Outfitter Reborn is a full member of the collection from now on. It was already on the roster
(`standards/ADDONS.md`, added in `c21052b`). **This is its first harvest**: the 2026-09-22 run read
`Outfitter/` as "a third-party fork, explicitly out of scope" (`harvests/2026-09-22/01_COLLECTION_STATE.md`,
*Roster drift*). Every repo was read from the working tree under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`,
on `master`, clean, and was not written to.

---

## Repos read

Measured on 2026-11-06. "Audit std" is the standard version the newest audit bundle's `01_CURRENT_STATE.md`
records; "LibKa0s" is the `Bundles [LibKa0s](…) vX` provenance line in the repo's `CLAUDE.md`.

| Repo | Kind | Version | LibKa0s | Newest audit (std) | Newest review | Newest automated-test run | `docs/midnight-quirks.md` |
|---|---|---|---|---|---|---|---|
| AbsorbTracker | addon | 1.12.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042117 | yes |
| AuraMaster | addon | 1.1.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042114 | yes |
| BankLedger | addon | 1.3.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042200 | yes |
| ConsumableMaster | addon | 1.8.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042111 | yes |
| DpsRace | addon | 0.1.0 | v1.85.0 | **never** | **never** | 20261104-042115 | no |
| DropWatcher | addon | 1.1.0 | v1.88.0 | 2026-10-14 (v2.80.0) | 2026-11-05 | 20261105-100457 | yes |
| KickCD | addon | 1.5.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042110 | yes |
| LibKa0sSkinTester | addon | 0.1.0 | v1.85.0 | **never** | **never** | 20261104-044542 | no |
| LootHistory | addon | 1.5.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042200 | yes |
| MultiMeters | addon | 1.2.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042118 | yes |
| OutfitterReborn | addon | 1.1.0 | v1.89.0 | 2026-11-04 (v2.96.0) | 2026-11-04 | 20261106-010454 | yes |
| PanelMaster | addon | 1.3.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042117 | no |
| PartyFrameEnhanced | addon | 1.2.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042115 | yes |
| PremadeGroupsFilterExtension | addon | 1.0.0 | v1.85.0 | 2026-10-10 (v2.78.0) | 2026-10-10 | 20261104-042256 | no |
| PrettyChat | addon | 1.7.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042351 | no |
| QuickComms | addon | 1.0.0 | v1.86.0 | 2026-10-25 (v2.88.0) | 2026-10-25 | 20261104-042401 | no |
| WhatGroup | addon | 1.6.0 | v1.85.0 | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261104-042405 | yes |
| LibKa0s | library | **v1.89.0** (newest tag, HEAD `1ca12c6`, kit revision 51) | — | 2026-10-07 (v2.76.1) | 2026-10-07 | 20261105-234356 | — |

**Age of the audit corpus.** Thirteen of the eighteen audited-or-auditable repos were last measured against
**v2.76.1**; the standard is at **v2.101.0**. Twenty-five releases — the whole skinning series, the keybinds and
layout run, the sim and preview run, smoke rounds 3–7 — have never been measured by an audit in those repos.
DpsRace and LibKa0sSkinTester have never been audited or reviewed. A finding in this run that rests on audit
frequency is therefore a finding about the collection as it stood on 2026-10-07, and is labeled so.

**Vendored payload integrity.** Every addon's `libs/LibKa0s/` and `tests/_kit/` match, byte for byte, the tag its
provenance line names (02_FINDINGS, category 8). Fourteen addons are on kit revision 50 and miss revision 51's
flake fix until their next re-vendor.

---

## Roster drift

**Rostered:** 17 addons, 1 library (LibKa0s), 2 documentation-and-tooling repos (WowAddonStandards,
dev-copilot).

**On disk:** all 17 rostered addon folders, LibKa0s, WowAddonStandards, dev-copilot. Also present and out of
scope: `Ka0sAddonsCommonTasks` (deliberately outside the rotation), `#Worktrees`, `wow-tools`,
`cultchampionssportsclub`, `ed-blackbox`.

- **Rostered but absent: none.** Every count in this run is against the full collection the standard
  believes it has.
- **On disk but unrostered: none.** The previous run's one unrostered `.toc` folder, `Outfitter/`, is now
  `OutfitterReborn/` and rostered.
- **Folder name and repository name differ for one addon.** Outfitter Reborn's folder is `OutfitterReborn/`;
  its GitHub repository is `tusharsaxena/Outfitter` (`standards/ADDONS.md`, its row). Any tool that derives one
  from the other gets this row wrong; the roster carries both, which is the fix.

---

## The issue store (category 6 input)

Read with `gh issue list --label "state:will-not-do" --state closed` and `--label "state:triaged" --state open`
for every repo on 2026-11-06. Totals: 103 `state:will-not-do`, 84 `state:triaged`.

**Never swept by `issue-audit`:** `LibKa0sSkinTester` and `Outfitter` carry **no `state:` labels at all**
(`gh label list` returned none). Neither is "a repo with no refusals"; neither has been triaged.
