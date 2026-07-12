# Per-Addon Deviation Report (2026-05-03)

Each section walks one addon against `01_STANDARD.md` top-to-bottom. Severity tiers:

- **🔴 BLOCKER** — violates a MUST rule with material risk (taint, data loss, incompatibility, license).
- **🟠 MAJOR** — violates a MUST rule with no immediate risk but blocks promotion to "standards-compliant".
- **🟡 MINOR** — violates a SHOULD rule, or a MUST rule that's cosmetic.
- **⚪ NIT** — naming/casing/docs/cleanup.

Effort: **S** = <2h, **M** = half-day, **L** = full day, **XL** = multi-day.

Each addon ends with a **prioritized backlog** ordered by ROI (severity × inverse-effort).

Evidence cites the per-addon raw report under `_raw/`.

---

## AbsorbTracker

| # | Severity | Standard § | Deviation | Effort | Evidence |
|---|---|---|---|---|---|
| AT-1 | 🔴 | §13 | No `.pkgmeta`. | S | `_raw/AbsorbTracker.md` |
| AT-2 | 🔴 | §14 | No `.luacheckrc`. | S | same |
| AT-3 | 🔴 | §2.1 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | S | `AbsorbTracker.toc:1-23` |
| AT-4 | 🟠 | §3.3 | AceAddon-3.0 vendored but used only as AceDB carrier; `AceConfig-3.0` vendored, used only for Profiles sub-page. Remove libs not `LibStub()`'d; keep the rest vendored (Standard v1.1 — no externals). | M | raw §4 |
| AT-5 | 🟠 | §7.1 | Slash uses raw `SLASH_*` registration; should use AceConsole `:RegisterChatCommand`. | S | `SlashCommands.lua` |
| AT-6 | 🟠 | §8.1 | No locale module at all (no `Locale.lua`); strings hardcoded across 20 files. | M | raw §9 |
| AT-7 | 🟠 | §12 | `/at debug` toggle is in-memory only (`Utils.lua:5`); must persist in SV. | S | raw §12 |
| AT-8 | 🟠 | §11 | No `Compat.lua`. (Currently no deprecated calls — but the file must exist as a future shim point.) | S | — |
| AT-9 | 🟡 | §9.6 | `Panel/ScrollPatch.lua` reaches into AceGUI ScrollFrame private fields with no version guard — fragile across AceGUI bumps. | M | raw §11 |
| AT-10 | 🟡 | §15 | TOC `Title:` is `Ka0s Absorb Tracker` ✓. ARCHITECTURE.md, README.md, CLAUDE.md drift = zero (May 2 sync). Re-verify at v1.9. | S | raw §15 |
| AT-11 | ⚪ | §1.3 | Folder name `Panel/` (PascalCase) violates "subfolders lowercase" rule. Rename to `panel/`. | S | layout |

**Conforming** (highlight):
- ✅ Schema-as-single-source: `Schema.lua` with `RegisterSchemaRows` + `SetByPath` write seam — **the cleanest implementation in the collection**, candidate model for the standard's reference snippet.
- ✅ Soft-fallback discipline (AceDB-missing flat-table shim, LSM-missing Blizzard fallback).
- ✅ Lazy first-`OnShow` panel render across every sub-page.
- ✅ Per-tick allocation discipline (gated `DebugPrint`, re-armed-timer ColorPicker throttle).
- ✅ Documentation drift = zero.

**Prioritized backlog:**
1. AT-3, AT-1, AT-2 (S each, blockers, parallelizable) — gets the addon to "standards-compliant TOC + tooling" in <2 hours total.
2. AT-7 (S, persists `/at debug`).
3. AT-5 (S, AceConsole migration).
4. AT-8 (S, empty Compat.lua scaffold).
5. AT-4 (M, lib externals migration).
6. AT-6 (M, locale module + key extraction).
7. AT-9 (M, ScrollPatch version guard).
8. AT-11, AT-10 (cleanup).

---

## ConsumableMaster

| # | Severity | Standard § | Deviation | Effort | Evidence |
|---|---|---|---|---|---|
| CM-1 | 🔴 | §13 | No `.pkgmeta`. | S | raw |
| CM-2 | 🔴 | §14 | No `.luacheckrc`. | S | raw |
| CM-3 | 🔴 | §2.1 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | S | TOC |
| CM-4 | 🔴 | §5.1 | `schemaVersion = 1` declared (`Core.lua:27`) with **zero migration code**; v2 will silently corrupt SVs. | S | raw §6 |
| CM-5 | 🟠 | §1 | `SlashCommands.lua` at 1257 LOC — over the 1500 cap warning threshold; slash should be a thin dispatcher. Peel into `Slash/Get.lua`, `Slash/Set.lua`, etc. | M | raw §2 |
| CM-6 | 🟠 | §3.3 | `AceConfig-3.0` fully embedded in `embeds.xml:12` but unreferenced — pure dead weight. Remove. | S | raw §4 |
| CM-7 | 🟠 | §7.1 | Hand-rolled `SLASH_*`; migrate to AceConsole. | S | `SlashCommands.lua` |
| CM-8 | 🟠 | §8.1 | No locale module. | M | — |
| CM-9 | 🟠 | §11 | No `Compat.lua`. | S | — |
| CM-10 | 🟠 | §15 | `README.md:172` documents `/cm enable` slash verb that does not exist (`SlashCommands.lua:1147-1214` has no such entry); the toggle is only via `/cm set enabled`. Doc drift. | S | raw §15 |
| CM-11 | 🟠 | §15 | `docs/module-map.md` lists exports `HasPending`, `IsPending`, `Stats`, `MakeCheckbox` etc. with **zero in-source definitions**. Stale docs. | S | raw §18 |
| CM-12 | 🟡 | §4.3 | `KCM.ResetAllToDefaults` calls `Pipeline.Recompute` synchronously (`Core.lua:282`) instead of `RequestRecompute` — taint-safe only by transitive contract. Switch to async. | S | raw §11 |
| CM-13 | 🟡 | §2.4 | `embeds.xml` is the only Ka0s addon using XML loading; standard prefers TOC-only at this size. Migrate. | M | raw §3 |
| CM-14 | 🟡 | §6.1 | Bootstrap registration for options panel happens at `settings/Panel.lua:823-832` (a frame); `OnInitialize` no longer calls `KCM.Options.Register` (`Core.lua:67-69` is comment-only). Single bootstrap path is fine, but the dead `O.Register` API must be deleted. | S | raw §17 |

**Conforming** (highlight):
- ✅ **Hard taint firewall** — `MacroManager` is the sole caller of `CreateMacro`/`EditMacro` (`MacroManager.lua:260, 271`); `DeleteMacro` never called. Reference implementation for §9.4.
- ✅ Coalescing recompute pipeline (`Core.lua:158-175`) with debounced panel refresh.
- ✅ Selective bag-vs-non-bag GIIR handling (`Core.lua:326-345`).
- ✅ `KCM.ID` opaque numeric-ID convention is a clean model.
- ✅ Centralized reset (`Core.lua:269-285`) shared by panel button and slash.

**Prioritized backlog:**
1. CM-3, CM-1, CM-2 (S, parallelizable).
2. CM-4 (S, ship migration runner — even empty body — to prevent v2 trap).
3. CM-6 (S, delete dead AceConfig).
4. CM-10, CM-11 (S, doc reconciliation; partly automatable via `wow-addon:sync-docs`).
5. CM-9, CM-7 (S each).
6. CM-12 (S, async ResetAll).
7. CM-14 (S, delete dead O.Register).
8. CM-5 (M, peel SlashCommands).
9. CM-13 (M, eliminate embeds.xml).
10. CM-8 (M, locale module).

---

## KickCD

| # | Severity | Standard § | Deviation | Effort | Evidence |
|---|---|---|---|---|---|
| KCD-1 | 🔴 | §13 | No `.pkgmeta`. | S | raw |
| KCD-2 | 🔴 | §14 | No `.luacheckrc`. | S | raw |
| KCD-3 | 🔴 | §2.1 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | S | TOC |
| KCD-4 | 🔴 | §11 | Direct `GetSpecialization`/`GetSpecializationInfo` calls bypass Compat (`modules/Cooldowns.lua:78-82`, `modules/IconGrid.lua:286-290`). Wrap in `NS.Compat.GetSpecialization()`. | S | raw §13 |
| KCD-5 | 🔴 | §1.2 | `modules/IconGrid.lua` 1753 LOC and `settings/Panel.lua` 1258 LOC violate the 1500-LOC cap. Peel both. | L | raw §2 |
| KCD-6 | 🟠 | §3.3 | Vendored-but-unloaded libs: AceLocale, AceBucket, AceComm, AceHook, AceSerializer, AceTab, AceTimer in `libs/`. Remove all of them (unused); keep loaded libs vendored (Standard v1.1 — no externals). | S | raw §4 |
| KCD-7 | 🟠 | §7.1 | Slash uses raw `SLASH_*`. Migrate to AceConsole. | S | raw §8 |
| KCD-8 | 🟠 | §8.1 | Hand-rolled metatable locale (correct *pattern*) but AceLocale is vendored unused. Either delete AceLocale from libs or unify on AceLocale non-strict mode. Standard accepts both — pick one and remove the other. | S | raw §9 |
| KCD-9 | 🟡 | §15 | `ARCHITECTURE.md:38` says "4 messages" while `:53` correctly says 5 — internal contradiction. Reconcile. | S | raw §15 |
| KCD-10 | 🟡 | §10 | `EnsureSpellList` does no class-name validation; typo via `/kcd spells add ... <typo> SPEC` permanently pollutes saved-vars. Validate at boundary. | S | raw §18 |
| KCD-11 | 🟡 | §4.3 | Glow-gate cache uses string `"secret"` as a tri-state sentinel mixed with bools (`modules/IconGrid.lua:1684-1700`). Replace with explicit enum. | S | raw §18 |
| KCD-12 | 🟡 | §15 | F-015/F-016 from 2026-05-02 review still TODO in code (`modules/IconGrid.lua:226-228`). Either resolve or move out of code into the review's deferred list. | S | raw §18 |
| KCD-13 | ⚪ | §5.3 | KickCD currently treats all party/raid/arena contexts equally. Consider per-zone profile trees (OmniCD pattern, §5.3). Standard says SHOULD; defer if not needed. | XL | new from M3 |

**Conforming** (highlight — strong):
- ✅ **Reference Tier-2 layout** — `core/` `modules/` `defaults/` `settings/` `locales/` is the canonical model.
- ✅ Bootstrap-namespace promoted in place to AceAddon (`core/Compat.lua:19` → `core/KickCD.lua:21-33`) — cleanest model in the collection.
- ✅ Single-source `KickCD.Settings.Schema` driving widget + slash + Defaults + reset.
- ✅ **Closed message bus** with five named messages, one sender each. Reference for §4.4.
- ✅ Ordered slash dispatch table (`core/KickCD.lua:117-148`) renders help.
- ✅ Compat/State/Constants three-way split.
- ✅ `Util.RegisterTargetEvent` (`core/Util.lua:197-205`) for unit-filtered events.

**Prioritized backlog:**
1. KCD-3, KCD-1, KCD-2 (S, parallelizable).
2. KCD-4 (S, blocker but trivial — wrap two call sites).
3. KCD-6 (S, delete dead libs).
4. KCD-7, KCD-8 (S each).
5. KCD-9, KCD-12 (S, doc/review reconciliation).
6. KCD-10, KCD-11 (S each).
7. KCD-5 (L, file peels — IconGrid first).
8. KCD-13 (XL, defer to v2).

---

## prettychat

| # | Severity | Standard § | Deviation | Effort | Evidence |
|---|---|---|---|---|---|
| PC-1 | 🔴 | §13 | No `.pkgmeta`. | S | raw |
| PC-2 | 🔴 | §14 | No `.luacheckrc`. | S | raw |
| PC-3 | 🔴 | §2.1 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | S | TOC |
| PC-4 | 🔴 | §1.3 | Addon folder is lowercase `prettychat`; standard mandates PascalCase `PrettyChat`. **Renames break user installs** — must be coordinated with a release-notes communication and an alias TOC for one cycle. | M (incl. coordination) | raw |
| PC-5 | 🔴 | §1.3 | `Libs/` (PascalCase) violates lowercase rule. Rename to `libs/`. | S | raw |
| PC-6 | 🔴 | §9.5 | `LOOT_ITEM_CREATED_SELF[_MULTIPLE]` cross-registration race — `pairs()` ordering is non-deterministic (`PrettyChat.lua:138-153`, `Schema.lua:140-159`). Use ordered table. | S | raw §10 |
| PC-7 | 🟠 | §8.1 | No localization at all (no AceLocale, no `Locale.lua`); English-only. "Original" column shows enUS even on deDE/frFR clients. | M | raw §9 |
| PC-8 | 🟠 | §3.3 | AceConfig-3.0 vendored-but-unloaded — kilobytes of dead code. Remove. | S | raw §4 |
| PC-9 | 🟠 | §5.1 | No SavedVariables migration runner. | S | raw §6 |
| PC-10 | 🟠 | §11 | No `Compat.lua`. | S | — |
| PC-11 | 🟠 | §7.1 | Hand-rolled `SLASH_*`. Migrate to AceConsole. | S | — |
| PC-12 | 🟠 | §1.1 | 22,879-entry `GlobalStrings/` dictionary loaded eagerly for ~80 actually-referenced globals — material RAM waste. Either remove unused entries or genuinely load on demand (parent TOC currently defeats LoD intent). | M | raw §2 |
| PC-13 | 🟡 | §15 | `ARCHITECTURE.md:7` still says "81 strings total" while `docs/file-index.md` and the M0 review fixed it to "81 rows over 79 unique globals". Single residual drift. | S | raw §15 |
| PC-14 | 🟡 | §15 | `attachTooltip`'s `HookScript` branch (`Config.lua:46-48`) is dead — every call site is AceGUI. Delete. | S | raw §17 |
| PC-15 | 🟡 | §15 | `TODO.md` exists at root — the standard documents the four-doc set (README, CLAUDE, ARCHITECTURE, LICENSE); TODOs belong in `reviews/` or GitHub issues. Move out. | S | raw |

**Conforming** (highlight):
- ✅ **Architecturally taint-free chat formatter** — overrides `_G[GLOBALNAME]` instead of hooking chat events; zero `ChatFrame_AddMessageEventFilter` / `hooksecurefunc` / `AddMessage` replacement (`PrettyChat.lua:138-153`). **Reference for §9.5.**
- ✅ Single write path via `Schema.Set` (`Schema.lua:200-207`).
- ✅ Schema-driven slash + panel parity (`PrettyChat.lua:362-379`).
- ✅ 3-layer enable cascade (`PrettyChat.lua:109-129`).
- ✅ Defensive `OpenConfig` (combat gate + return-check + one-time-warn) (`PrettyChat.lua:62-99`).

**Prioritized backlog:**
1. PC-3, PC-1, PC-2, PC-5, PC-15 (S each).
2. PC-6 (S, fix race — high-value bug).
3. PC-9, PC-10, PC-11 (S each).
4. PC-8 (S, drop dead AceConfig).
5. PC-13, PC-14 (S each).
6. PC-12 (M, GlobalStrings RAM diet).
7. PC-7 (M, localization scaffold).
8. PC-4 (M, folder rename — last because it's user-visible).

---

## WhatGroup

| # | Severity | Standard § | Deviation | Effort | Evidence |
|---|---|---|---|---|---|
| WG-1 | 🔴 | §13 | No `.pkgmeta` despite active CurseForge listing. | S | raw |
| WG-2 | 🔴 | §14 | No `.luacheckrc`. | S | raw |
| WG-3 | 🔴 | §2.1 | TOC missing `X-Curse-Project-ID` / `X-Wago-ID`. | S | TOC |
| WG-4 | 🟠 | §1.1 | `WhatGroup_Settings.lua` 1056 LOC mixes 5 concerns. Standard allows in-folder peel for Tier 1: split into `WhatGroup_Settings_Schema.lua`, `WhatGroup_Settings_Panel.lua`, `WhatGroup_Settings_Scrollbar.lua`. | M | raw §2 |
| WG-5 | 🟠 | §11 | No `Compat.lua`. (No deprecated calls today — file must still exist as future shim point.) | S | — |
| WG-6 | 🟠 | §8.1 | No locale module — relies on Blizzard `_G` strings. Standard mandates locale module shell even if all values are `_G` lookups. | S | raw §9 |
| WG-7 | 🟠 | §12 | No persistent debug toggle. | S | raw §12 |
| WG-8 | 🟠 | §7.1 | Hand-rolled `SLASH_*`. Migrate to AceConsole. | S | — |
| WG-9 | 🟡 | §10 | `appID`-as-`searchResultID` reuse (`WhatGroup.lua:588`) — undocumented Blizzard parity, flagged TODO F-004. Document in code comment + ARCHITECTURE. | S | raw §17 |
| WG-10 | 🟡 | §10 | Cross-file public surface on `_G.WhatGroup` is fuzzy and undeclared. Standard mandates `WhatGroup.API.v1` versioned namespace if anything is public; otherwise keep it on `NS`. | S | raw §17 |
| WG-11 | ⚪ | §2.1 | `## DefaultState: enabled` is in TOC (`WhatGroup.toc:8`) — only meaningful for LoD addons; harmless cargo-cult but remove. | S | raw |

**Conforming** (highlight — strongest taint discipline in the collection):
- ✅ **Exemplary taint discipline** — file-load hooks (`WhatGroup.lua:39-51`); deferred Settings/StaticPopup/UISpecialFrames/popup; panel-body builds wrapped in `C_Timer.After(0, ...)` (`WhatGroup_Settings.lua:1003`, `:1035`). **Reference for §9.2/§9.3.**
- ✅ Schema-first ergonomics — one row drives panel + AceDB + slash get/set/list/reset (`WhatGroup_Settings.lua:77-184`).
- ✅ Three-layer combat safety (`WhatGroup.lua:868`, `WhatGroup_Settings.lua:975`, `WhatGroup_Frame.lua:173`).
- ✅ Robust capture state machine (`WhatGroup.lua:501-541`).
- ✅ Free locale fallback via Blizzard globals + `playstyleString` (`WhatGroup.lua:364-369`).
- ✅ Uses `IsInGroup()` only — no deprecated `GetRaidRosterInfo` / `GetNumGroupMembers`.
- ✅ Stays Tier 1 flat — analyst recommends NOT modularizing.

**Prioritized backlog:**
1. WG-3, WG-1, WG-2 (S, parallelizable).
2. WG-11 (S trivial).
3. WG-7, WG-8, WG-5, WG-6, WG-9, WG-10 (S each).
4. WG-4 (M, in-folder peel of `WhatGroup_Settings.lua`).

---

## Cross-cutting summary

| Deviation | Addons affected | Total effort |
|---|---|---|
| Missing `.pkgmeta` | 5/5 | 5×S |
| Missing `.luacheckrc` | 5/5 | 5×S |
| Missing `X-Curse-Project-ID` / `X-Wago-ID` | 5/5 | 5×S |
| Hand-rolled `SLASH_*` (no AceConsole) | 5/5 | 5×S |
| No `Compat.lua` scaffold | 4/5 | 4×S |
| No locale module | 4/5 (KickCD has hand-rolled) | 4×M |
| Vendored-unused libs | 4/5 | 4×S |
| No SV migration runner | 3/5 | 3×S |
| No persistent debug toggle | 2/5 | 2×S |
| Files >1500 LOC | KickCD (2 files), borderline ConsumableMaster | 1×L |
| Folder casing violations | prettychat | 1×M |

**Total estimated effort to bring all 5 addons to standards-compliant:** roughly 5 days of focused work, ~70% of which is the 25× S tasks (the "remediation sprint"); the rest is the per-addon M and L tasks.

**Recommended remediation sequencing** (highest ROI first):

1. **Sprint 1 — Tooling sweep** (1 day, parallel-safe): add `.pkgmeta`, `.luacheckrc`, X-IDs to all 5 addons. Pure mechanical work; unlocks every downstream improvement.
2. **Sprint 2 — Compat + locale scaffolds** (1 day): drop empty `Compat.lua` and `Locale.lua` shells into all 5; mandatory standards compliance even if bodies are minimal.
3. **Sprint 3 — Slash to AceConsole** (1 day): mechanical migration in all 5 addons.
4. **Sprint 4 — Lib cleanup** (1 day): remove vendored-*unused* libs; keep the rest vendored (Standard v1.1 — no externals).
5. **Sprint 5 — Per-addon high-value bugs** (1-2 days):
   - prettychat PC-6 (loot filter race)
   - prettychat PC-4 (folder rename — schedule with release notes)
   - ConsumableMaster CM-4 (migration runner)
   - KickCD KCD-4 (Compat for Specialization), KCD-5 (file peels — IconGrid)
   - WhatGroup WG-4 (Settings peel)

Sprints 1–4 are the "standards compliance" milestone. After Sprint 5 every addon is fully aligned with `01_STANDARD.md`.

---

## What's deliberately not on this list

The following were considered and rejected as deviation findings:

- **WhatGroup staying Tier 1 flat.** Standard explicitly allows it; its analyst made the case. No deviation.
- **AbsorbTracker's hybrid raw-AceGUI-inside-Blizzard-Settings.** Now codified as the canonical pattern (§6.1).
- **Hand-rolled metatable locale** (KickCD). Now codified as the standard (§8.1) — AceLocale strict is the deviation.
- **`reviews/<DATE>/` audit folders.** Codified as required (§16). Every addon already has them.
- **Soft-fallback discipline** (AceDB-missing, LSM-missing, etc.). Promoted to standard practice; not a deviation.
