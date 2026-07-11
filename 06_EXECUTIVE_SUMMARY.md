# Executive Summary — Ka0s Addon Standardization (2026-05-03)

**One-page TL;DR.** Full evidence: [01_CURRENT_STATE](01_CURRENT_STATE.md), [02_INDUSTRY_RESEARCH](02_INDUSTRY_RESEARCH.md), [03_STANDARDS](03_STANDARDS.md), [04_DEVIATIONS](04_DEVIATIONS.md), [05_NEW_ADDON_CONTEXT](05_NEW_ADDON_CONTEXT.md).

---

## The state of the collection

Five addons audited (AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup) plus 10 reference addons researched (DBM, BigWigs, Auctionator, Plater, Plumber, Details!, WeakAuras, ElvUI, Bagnon, OmniCD).

**Headline:** Ka0s addons are already converging on a coherent house style. Five-of-five share the schema-as-single-source pattern, the Blizzard `Settings.RegisterCanvasLayoutCategory` + raw AceGUI options approach, soft-fallback discipline, lazy panel rendering, combat-lockdown gating, and `reviews/<DATE>/` audit folders. The standard ([03_STANDARDS.md](03_STANDARDS.md)) codifies what already works and closes the gaps.

---

## Top 5 wins to lift to canonical status

1. **Schema-as-single-source-of-truth** — one row drives panel widget + slash + defaults reset. AbsorbTracker has the cleanest implementation; KickCD the most complete. Now codified as MUST in §4.5.
2. **KickCD's modular layout** — `core/` `modules/` `defaults/` `settings/` `locales/` is now the canonical Tier 2 reference layout (§1.2).
3. **prettychat's chat-formatter approach** — overriding `_G[GLOBALSTRING]` instead of hooking chat events. Architecturally taint-free; rare in the ecosystem; codified as the SHOULD pattern in §9.5.
4. **WhatGroup's combat-lockdown discipline** — 3-layer cascade with deferred SettingsPanel/UISpecialFrames/popup. Now the reference implementation for §9.2.
5. **ConsumableMaster's macro firewall** — single module is sole caller of protected `CreateMacro`/`EditMacro` APIs. Codified as MUST in §9.4 for any addon touching protected APIs.

## Top 5 risks & gaps

1. **No `.pkgmeta`, `.luacheckrc`, or X-IDs in any of the 5 TOCs.** Pure tooling debt; ~1 day to fix across the collection.
2. **Vendored-but-unused libs in 4 of 5 addons** (especially KickCD: AceLocale, AceBucket, AceComm, AceHook, AceSerializer, AceTab, AceTimer all in `libs/` and never loaded). Standard mandates externals over vendoring (§3.3).
3. **No localization in 4 of 5 addons** despite hand-rolled or vendored AceLocale infrastructure. The standard codifies the metatable-fallback `__index → key` pattern (§8.1) — KickCD's hand-rolled approach was actually correct industry practice; AceLocale strict mode is the deviation.
4. **All 5 addons hand-roll `SLASH_*` registration** despite vendoring AceConsole. Mechanical migration to `:RegisterChatCommand`.
5. **File-LOC violations** — KickCD's `IconGrid.lua` (1753) and `settings/Panel.lua` (1258); ConsumableMaster's `SlashCommands.lua` (1257). Standard caps at 1500.

## Bonus risk worth flagging

**ConsumableMaster declares `schemaVersion = 1` with no migration code anywhere.** A future v2 migration will silently corrupt user SVs. Trivial S-effort fix; high blast-radius if not done. ([04_DEVIATIONS](04_DEVIATIONS.md) CM-4.)

---

## Recommended remediation sequencing

[Detailed in 04_DEVIATIONS §"Cross-cutting summary".]

| Sprint | Effort | Scope | Outcome |
|---|---|---|---|
| 1 | 1 day | `.pkgmeta` + `.luacheckrc` + X-IDs across all 5 | Tooling baseline; unblocks every downstream improvement |
| 2 | 1 day | Drop empty `Compat.lua` + `Locale.lua` scaffolds in all 5 | Standards compliance scaffolding |
| 3 | 1 day | `SLASH_*` → AceConsole migration in all 5 | Mechanical |
| 4 | 1 day | Lib externals migration; remove dead vendored libs | Repo size + maintenance win |
| 5 | 1-2 days | Per-addon high-value bugs (PC-6 race, CM-4 migration, KCD-4 Compat, KCD-5 / WG-4 file peels) | Per-addon polish |

**Total: ~5 days of focused work** to bring all 5 addons to "standards-compliant".

After Sprint 5, the entire collection conforms to `03_STANDARDS.md` and any new addon scaffolded from `05_NEW_ADDON_CONTEXT.md` is born compliant.

---

## What this report does NOT do

- **No code is modified.** All deliverables are reports. Remediation is a follow-up engagement.
- **CI / GitHub Actions intentionally out of scope** per Ka0s decision.
- **Long-term `Ka0s-Core` sibling addon** (Bagnon-style engine extraction) is recorded as a future direction in `03_STANDARDS.md §20`, not pursued now.

---

## Deliverables index

```
WowAddonStandards/
  00_PLAN.md                    -- approved milestone plan
  01_CURRENT_STATE.md           -- per-addon snapshot + matrix
  02_INDUSTRY_RESEARCH.md       -- 10 reference addons synthesized
  03_STANDARDS.md               -- THE STANDARD (canonical)
  04_DEVIATIONS.md              -- per-addon gap report + sprints
  05_NEW_ADDON_CONTEXT.md       -- drop-in CLAUDE.md for new addons
  06_EXECUTIVE_SUMMARY.md       -- this file
  _raw/                         -- full per-addon evidence
    AbsorbTracker.md  ConsumableMaster.md  KickCD.md  prettychat.md  WhatGroup.md
    _industry/                  -- 10 reference-addon raw reports
      DBM.md  BigWigs.md  Auctionator.md  Plater.md  Plumber.md
      Details.md  WeakAuras.md  ElvUI.md  Bagnon.md  OmniCD.md
```

---

**Project status: complete.** Next user actions:

1. Read `03_STANDARDS.md` and approve / request edits.
2. Drop `05_NEW_ADDON_CONTEXT.md` content into the next new addon's `CLAUDE.md`.
3. Schedule the 5-sprint remediation against `04_DEVIATIONS.md`.
