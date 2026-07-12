# Executive Summary — Ka0s Addon Audit (2026-05-03)

**One-page TL;DR of this audit run.** Audited against the standard: [`../../standards/01_STANDARD.md`](../../standards/01_STANDARD.md). Full evidence: [`01_PLAN.md`](01_PLAN.md), [`02_CURRENT_STATE.md`](02_CURRENT_STATE.md), [`03_DEVIATIONS.md`](03_DEVIATIONS.md), and per-addon remediation plans in [`remediation/`](remediation/). (The industry research this run produced has since been promoted to the standards process — [`../../standards/03_INDUSTRY_RESEARCH.md`](../../standards/03_INDUSTRY_RESEARCH.md).)

---

## The state of the collection

Five addons audited (AbsorbTracker, ConsumableMaster, KickCD, prettychat, WhatGroup) plus 10 reference addons researched (DBM, BigWigs, Auctionator, Plater, Plumber, Details!, WeakAuras, ElvUI, Bagnon, OmniCD).

**Headline:** Ka0s addons are already converging on a coherent house style. Five-of-five share the schema-as-single-source pattern, the Blizzard `Settings.RegisterCanvasLayoutCategory` + raw AceGUI options approach, soft-fallback discipline, lazy panel rendering, combat-lockdown gating, and `reviews/<DATE>/` audit folders. The standard ([`../../standards/01_STANDARD.md`](../../standards/01_STANDARD.md)) codifies what already works and closes the gaps.

---

## Top 5 wins lifted to canonical status

1. **Schema-as-single-source-of-truth** — one row drives panel widget + slash + defaults reset. AbsorbTracker has the cleanest implementation; KickCD the most complete. Now codified as MUST in §4.5.
2. **KickCD's modular layout** — `core/` `modules/` `defaults/` `settings/` `locales/` is now the canonical Tier 2 reference layout (§1.2).
3. **prettychat's chat-formatter approach** — overriding `_G[GLOBALSTRING]` instead of hooking chat events. Architecturally taint-free; rare in the ecosystem; codified as the SHOULD pattern in §9.5.
4. **WhatGroup's combat-lockdown discipline** — 3-layer cascade with deferred SettingsPanel/UISpecialFrames/popup. Now the reference implementation for §9.2.
5. **ConsumableMaster's macro firewall** — single module is sole caller of protected `CreateMacro`/`EditMacro` APIs. Codified as MUST in §9.4 for any addon touching protected APIs.

## Top 5 risks & gaps

1. **No `.pkgmeta`, `.luacheckrc`, or X-IDs in any of the 5 TOCs.** Pure tooling debt; ~1 day to fix across the collection.
2. **Vendored-but-unused libs in 4 of 5 addons** (especially KickCD: AceLocale, AceBucket, AceComm, AceHook, AceSerializer, AceTab, AceTimer all in `libs/` and never loaded). Standard v1.1 keeps libs **vendored** but requires pruning the ones you don't `LibStub()` (§3.3).
3. **No localization in 4 of 5 addons** despite hand-rolled or vendored AceLocale infrastructure. The standard codifies the metatable-fallback `__index → key` pattern (§8.1) — KickCD's hand-rolled approach was actually correct industry practice; AceLocale strict mode is the deviation.
4. **AbsorbTracker hand-rolls `SLASH_*` registration** despite vendoring AceConsole. Mechanical migration to `:RegisterChatCommand`. (See `remediation/README.md` — the other 4 addons already use AceConsole; the original "5/5 hand-roll" finding was corrected.)
5. **File-LOC violations** — KickCD's `IconGrid.lua` (1753) and `settings/Panel.lua` (1258); ConsumableMaster's `SlashCommands.lua` (1257). Standard caps at 1500.

## Bonus risk worth flagging

**ConsumableMaster declares `schemaVersion = 1` with no migration code anywhere.** A future v2 migration will silently corrupt user SVs. Trivial S-effort fix; high blast-radius if not done. ([`03_DEVIATIONS.md`](03_DEVIATIONS.md) CM-4.)

---

## Recommended remediation sequencing

[Detailed in [`03_DEVIATIONS.md`](03_DEVIATIONS.md) §"Cross-cutting summary" and reconciled in [`remediation/README.md`](remediation/README.md).]

| Sprint | Effort | Scope | Outcome |
|---|---|---|---|
| 1 | 1 day | `.pkgmeta` + `.luacheckrc` + X-IDs across all 5 | Tooling baseline; unblocks every downstream improvement |
| 2 | 1 day | Compat + Locale + Debug scaffolds in all 5 | Standards compliance scaffolding |
| 3 | 0.5 day | AbsorbTracker `SLASH_*` → AceConsole migration | Mechanical (only AbsorbTracker needs it) |
| 4 | 1 day | Prune dead vendored libs (keep used libs vendored — no externals, Standard v1.1) | Repo size + maintenance win |
| 5 | 2-3 days | Per-addon high-value bugs + file peels (PC race, CM-4 migration, KCD-4 Compat, KCD/WG file peels) | Per-addon polish |

**Total: ~5-6 days of focused work** to bring all 5 addons to "standards-compliant". After the final sprint, the entire collection conforms to `../../standards/01_STANDARD.md` and any new addon scaffolded from `../../standards/02_NEW_ADDON_CONTEXT.md` is born compliant.

---

## What this report does NOT do

- **No code is modified.** All deliverables are reports. Remediation is a follow-up engagement.
- **CI / GitHub Actions intentionally out of scope** per Ka0s decision.

---

## Deliverables index (this run)

```
audit/2026-05-03/
  00_EXECUTIVE_SUMMARY.md       -- this file
  01_PLAN.md                    -- approved milestone plan
  02_CURRENT_STATE.md           -- per-addon snapshot + matrix
  03_DEVIATIONS.md              -- per-addon gap report + sprints
  _raw/                         -- full per-addon evidence
    AbsorbTracker.md  ConsumableMaster.md  KickCD.md  prettychat.md  WhatGroup.md
  remediation/                  -- per-addon TECHNICAL_DESIGN + EXECUTION_PLAN (+ README index)

# Industry research (03_INDUSTRY_RESEARCH.md + _raw/_industry/) was promoted to the standards
# process and now lives under ../../standards/.
```

---

**Audit status: complete.** Next user actions:

1. Review [`../../standards/01_STANDARD.md`](../../standards/01_STANDARD.md) and approve / request edits.
2. Drop [`../../standards/02_NEW_ADDON_CONTEXT.md`](../../standards/02_NEW_ADDON_CONTEXT.md) content into the next new addon's `CLAUDE.md`.
3. Schedule the remediation sprints against [`03_DEVIATIONS.md`](03_DEVIATIONS.md), executing the per-addon plans in [`remediation/`](remediation/).
