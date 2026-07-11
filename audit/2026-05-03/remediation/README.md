# Remediation Documents — Index (2026-05-03)

Per-addon technical designs (HLD+LLD) and execution plans (subagent-ready, checkbox-tracked) for bringing each addon to full standards compliance per [`../../../standards/01_STANDARD.md`](../../../standards/01_STANDARD.md).

| Addon | Technical Design | Execution Plan | Tasks | Notable scope decisions |
|---|---|---|---|---|
| AbsorbTracker | [TECHNICAL_DESIGN_AbsorbTracker.md](AbsorbTracker/TECHNICAL_DESIGN_AbsorbTracker.md) | [EXECUTION_PLAN_AbsorbTracker.md](AbsorbTracker/EXECUTION_PLAN_AbsorbTracker.md) | 17 + 6 checkpoints | Piggybacks `schemaVersion` + empty `RunMigrations` onto AT-7. Adds AceEvent/Timer/Console as externals. |
| ConsumableMaster | [TECHNICAL_DESIGN_ConsumableMaster.md](ConsumableMaster/TECHNICAL_DESIGN_ConsumableMaster.md) | [EXECUTION_PLAN_ConsumableMaster.md](ConsumableMaster/EXECUTION_PLAN_ConsumableMaster.md) | 22 across 9 milestones | CM-5 SlashCommands peel into `Slash/` subfolder (forces Tier-2 promotion). Macro firewall encoded in `.luacheckrc`. |
| KickCD | [TECHNICAL_DESIGN_KickCD.md](KickCD/TECHNICAL_DESIGN_KickCD.md) | [EXECUTION_PLAN_KickCD.md](KickCD/EXECUTION_PLAN_KickCD.md) | ~38 across 10 milestones | IconGrid.lua → 7 files; Panel.lua → 6 files; both with explicit line-range region maps. KCD-13 per-zone profiles deferred to v2. |
| prettychat | [TECHNICAL_DESIGN_prettychat.md](prettychat/TECHNICAL_DESIGN_prettychat.md) | [EXECUTION_PLAN_prettychat.md](prettychat/EXECUTION_PLAN_prettychat.md) | 41 across 10 milestones | PC-4 folder rename via `prettychat → _pc_temp_ → PrettyChat` two-stage; live-account SV-preservation probe required. |
| WhatGroup | [TECHNICAL_DESIGN_WhatGroup.md](WhatGroup/TECHNICAL_DESIGN_WhatGroup.md) | [EXECUTION_PLAN_WhatGroup.md](WhatGroup/EXECUTION_PLAN_WhatGroup.md) | 14 across 6 milestones | Stays Tier 1 flat (per standard §1.1). Settings peel: 3 files, all ≤500 LOC. |

---

## Deviation report corrections (surfaced by design agents)

The design agents read the actual source while writing each design. They surfaced **5 stale findings** in [`../04_DEVIATIONS.md`](../04_DEVIATIONS.md) that should be marked as already-compliant rather than implemented:

| Finding | Status | Evidence |
|---|---|---|
| **WG-7** "no persistent debug toggle" | ✅ Already compliant | `db.profile.debug` schema row at `WhatGroup_Settings.lua:108-115` |
| **WG-8** "hand-rolled `SLASH_*`" | ✅ Already compliant | AceConsole mixin at `WhatGroup.lua:23-25`, `:RegisterChatCommand` at `:241-242` |
| **CM-7** "hand-rolled `SLASH_*`" | ✅ Already compliant | AceConsole `:RegisterChatCommand` at `Core.lua:65-66` |
| **PC-11** "hand-rolled `SLASH_*`" | ✅ Already compliant | AceConsole `:RegisterChatCommand` at `PrettyChat.lua:33-34` |
| **KCD-7** "hand-rolled `SLASH_*`" | ✅ Already compliant | AceConsole `:RegisterChatCommand` at `core/KickCD.lua:60-61`; zero `SLASH_*` globals |

**Net effect:** the cross-cutting "5/5 hand-roll `SLASH_*`" finding in `04_DEVIATIONS.md` and `00_EXECUTIVE_SUMMARY.md` is **wrong**. Reality: **AbsorbTracker is the only addon with hand-rolled `SLASH_*`**; the other 4 already use AceConsole. Verified via grep across all 5 source trees.

This collapses Sprint 3 (Slash → AceConsole migration) from a 1-day cross-collection sprint to a 1-task AbsorbTracker fix (covered in AT-5 / its execution plan M3).

**Other corrections:**
- **KCD-4** had **3 call sites** to wrap, not 2 — third site at `core/KickCD.lua:553-562`. KickCD plan covers all three.
- **CM-4** design hoists `schemaVersion` from `profile` to `global` (per standard §5.1) with a one-time migration; plan ships `MIGRATIONS = {}` empty but with the v1→v2 interface in place.

These corrections do **not** require rewriting the deviation report — the per-addon plans handle them as "verify-only" tasks. The corrected reality is captured here for future reference.

---

## How to execute these plans

Each `EXECUTION_PLAN_<Addon>.md` is designed to be handed to:

- **A single executing agent** — use the `superpowers:executing-plans` skill (inline with checkpoints).
- **A subagent-driven workflow** — use the `superpowers:subagent-driven-development` skill (one fresh subagent per task; review between).

Recommended sequencing across the collection (revised given the corrections above):

| Sprint | Effort | Target | Plans involved |
|---|---|---|---|
| 1 | 1 day | Tooling baseline (`.pkgmeta`, `.luacheckrc`, X-IDs) | All 5 plans, M1 each |
| 2 | 1 day | Compat + Locale + Debug scaffolds | All 5 plans, M2 each |
| 3 | 0.5 day | AbsorbTracker only — SLASH_* → AceConsole | AbsorbTracker M3 |
| 4 | 1 day | Lib externals migration | All 5 plans, lib-cleanup milestone |
| 5 | 2-3 days | High-value bugs + file peels | KickCD M7-M8, ConsumableMaster M8, WhatGroup M5, prettychat M3 + M8 (folder rename) |
| 6 | 1 day | Doc reconciliation + release prep | All 5 plans, final milestone |

Total ~6 days. After Sprint 6, every addon ships a new minor version that conforms fully to `01_STANDARD.md`.
