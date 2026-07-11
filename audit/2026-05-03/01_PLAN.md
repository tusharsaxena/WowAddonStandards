# Addon Standardization — Master Plan

**Date:** 2026-05-03
**Author:** Claude (principal-engineer mode), for Ka0s
**Status:** DRAFT — awaiting sign-off

> Note: This is a research/analysis project, not a code-implementation project. I'm using a milestone+checkpoint structure rather than the TDD-step format from `writing-plans`, because the deliverables are reports, not code. No addon code will be modified by this work — only reports under `WowAddonStandards/`.

---

## Goal

Produce a definitive set of standards (tech stack, libraries, design patterns, code structure, naming, packaging, localization, settings, slash commands, debug, docs) for Ka0s WoW addons, grounded in:

1. The current state of the five in-scope addons.
2. Patterns observed in widely respected community addons.

Then deliver concrete, per-addon remediation guidance plus a reusable "context pack" to drop into any future new addon.

## Scope

**In-scope addons** (under `/mnt/d/Profile/Users/Tushar/Documents/GIT/`):

- `AbsorbTracker`
- `ConsumableMaster`
- `KickCD`
- `prettychat`
- `WhatGroup`

**Reference addons (read-only research):** Deadly Boss Mods (DBM), Big Wigs, Auctionator, Plater, Plumber, Details!, WeakAuras, ElvUI, Bagnon, OmniCD. Final list locked in M2.

**Out of scope:** Touching addon code. Any actual remediation is a follow-up project that uses the reports produced here.

## Deliverables

All written to `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards/`:

| # | File | Purpose |
|---|------|---------|
| 00 | `01_PLAN.md` | This document. |
| 01 | `02_CURRENT_STATE.md` | Per-addon snapshot: structure, libs, patterns, TOC metadata, settings, slash, locale, debug, packaging. One section per addon, side-by-side comparison matrix at the top. |
| 02 | `03_INDUSTRY_RESEARCH.md` | Patterns from reference addons. What they do, why, what to steal, what to avoid. |
| 03 | `01_STANDARD.md` | The canonical standard. Tech stack, library selection rationale, folder layout, file naming, module pattern, settings/AceDB schema, options (AceConfig) layout, slash commands, localization, debug/logging, error handling, events, frames, taint discipline, packaging (.pkgmeta), version-bump conventions, documentation set (README/CLAUDE.md/ARCHITECTURE.md). Prescriptive — "DO this, NOT that." |
| 04 | `04_DEVIATIONS.md` | Per-addon gap report. For each addon: what conforms, what deviates, severity (blocker/major/minor/nit), and a prioritized remediation backlog with effort estimates. |
| 05 | `02_NEW_ADDON_CONTEXT.md` | Drop-in `CLAUDE.md`-style context for new addons. Self-contained: standard layout, starter files, library list with versions, conventions checklist. Designed to paste into a new repo on day one. |
| 06 | `00_EXECUTIVE_SUMMARY.md` | One-page TL;DR: top 5 wins, top 5 risks, recommended sequencing for remediation. |

---

## Milestones & Checkpoints

Each milestone ends in a checkpoint where I stop and you review before I proceed.

### M1 — Plan sign-off ← YOU ARE HERE

- [ ] You review this plan.
- [ ] You approve scope, deliverables, reference-addon list, and output location, OR request changes.

**Checkpoint 1 (gate):** Explicit "go" from you. No work past this line until then.

---

### M2 — Inventory & current-state analysis

For each of the five addons, capture:

- TOC metadata (Interface, version, deps, SavedVariables, LoadOnDemand).
- Folder/file layout and module-loading order (TOC, XML, embeds).
- Library stack (Ace3 modules, LibStub libs, CallbackHandler, LibSharedMedia, etc.) and versions.
- Core architecture pattern (single-file vs module-per-file vs Ace3 AddOn:NewModule).
- Settings: storage (AceDB profile/char/global), schema definition, defaults, migration.
- Options UI: AceConfig vs Blizzard panel vs custom; registration approach.
- Slash commands: AceConsole vs raw `SLASH_*`; argument parsing; help output.
- Localization: AceLocale presence, locale file structure, coverage.
- Events: AceEvent vs raw frame OnEvent; combat-lockdown handling.
- Frames: XML vs Lua; pooling; secure templates.
- Debug/logging: presence, on/off mechanism, levels.
- Packaging: `.pkgmeta`, externals, CurseForge/Wago metadata, CI.
- Documentation: README, CLAUDE.md, ARCHITECTURE.md state and accuracy.
- Tests: any harness, smoke tests, lint config (luacheck).

**Output:** `02_CURRENT_STATE.md` with a comparison matrix at top + per-addon deep-dive.

**Checkpoint 2 (review):** I print a summary of major findings to chat. You skim `02_CURRENT_STATE.md` and confirm before I move on. (You can interrupt to add/remove reference addons for M3.)

---

### M3 — Industry research

Survey reference addons (sources: GitHub, Wago, CurseForge, public wikis). For each:

- Library stack and rationale.
- Folder layout.
- Settings/options approach.
- Notable patterns (event dispatch, module registration, throttling, taint avoidance).
- Anti-patterns to avoid (deprecated APIs, global pollution, taint hazards).

Cross-cut findings: what's converged across the ecosystem (de-facto standards) vs what's project-specific.

**Output:** `03_INDUSTRY_RESEARCH.md`.

**Checkpoint 3 (review):** I summarize the convergent patterns + the dissenting ones. You confirm direction (e.g., "yes, standardize on Ace3" vs "I want to evaluate non-Ace stack too") before I write the standard.

---

### M4 — Synthesize the standard

Write `01_STANDARD.md`. Prescriptive, opinionated, with rationale for each choice. Includes:

- Reference folder tree (the canonical layout).
- Required/recommended/optional libraries with current versions.
- Module pattern (template).
- AceDB schema conventions.
- AceConfig options tree conventions.
- Slash-command conventions (verbs, help text, completion).
- Localization conventions (enUS as source of truth, fallback strategy).
- Debug/logging conventions (single `D:Print` style, on/off SV).
- Event handling conventions.
- TOC field conventions (Interface, X-Curse-Project-ID, X-Wago-ID, etc.).
- `.pkgmeta` template.
- Documentation set requirements (README/CLAUDE.md/ARCHITECTURE.md sections).
- Naming: files, frames, global tables, saved-variable keys, locale keys.
- Versioning & changelog conventions.

**Checkpoint 4 (review):** You read `01_STANDARD.md` and approve, request edits, or push back on specific choices. This document is the source of truth for M5.

---

### M5 — Per-addon deviation reports + new-addon context pack

Two parallel write-ups:

**5a — `04_DEVIATIONS.md`:** For each of the five addons, walk the standard top-to-bottom and mark conforming/deviating. Each deviation gets: severity, evidence (file:line), proposed fix, effort (S/M/L). End each addon's section with a prioritized backlog.

**5b — `02_NEW_ADDON_CONTEXT.md`:** Self-contained context document an LLM (or human) can read before scaffolding a new addon. Includes:
- The standard layout as a tree.
- Starter TOC, `.pkgmeta`, `Core.lua`, `Settings.lua`, `Locales/enUS.lua` snippets.
- Library list with embed instructions.
- Naming/convention checklist.
- "Definition of done" for a new addon (docs + tests + packaging).

**Checkpoint 5 (review):** You read both. I revise based on feedback.

---

### M6 — Executive summary & handoff

Write `00_EXECUTIVE_SUMMARY.md`: one page, top wins, top risks, recommended sequencing for remediation work, links into the other reports.

**Checkpoint 6 (final):** You sign off; project complete. Any remediation work is a separate engagement.

---

## Method notes

- **Read-only.** No addon source code is modified by this project. All output lives under `WowAddonStandards/`.
- **Evidence-based.** Every claim about a current-state addon must cite `path/to/file.lua:line` so you can verify quickly.
- **Use existing reviews.** Each addon has a `reviews/` folder — I'll mine those for prior findings rather than re-deriving them.
- **Use existing CLAUDE.md / ARCHITECTURE.md.** Treat these as starting points, but verify against actual code (docs drift).
- **Industry research:** Will use WebFetch/WebSearch on GitHub repos and well-known wikis. I'll cite URLs. If a reference addon's repo is hard to access, I'll substitute and note it.
- **Parallelism:** Per-addon analyses in M2 and reference-addon surveys in M3 can fan out to subagents to keep the main context clean. Synthesis (M4–M6) stays in the main thread.

## Risks / open questions for sign-off

1. **Reference addon list** — confirm the list above, or amend. (Plater, Details!, WeakAuras, ElvUI, Bagnon, OmniCD added; remove any you don't want benchmarked.)
2. **Output location** — `WowAddonStandards/` under `GIT/`. OK, or prefer somewhere else (e.g., a dedicated `wow-addon-standards` repo)?
3. **Stack assumption** — I'll bias the standard toward the Ace3 stack you're already on, unless you want a clean-slate evaluation that includes non-Ace alternatives.
4. **Depth of industry research** — fast skim (folder structures + TOC + headline patterns) vs deep dive (read modules, trace taint patterns). Default: fast skim, deep dive only where convergent practice is unclear. OK?
5. **CI/packaging** — should the standard mandate GitHub Actions + BigWigsMods/packager? Or leave CI optional?

---

## Approval line

> **Sign-off:** Reply "approved" (or "approved with changes: ...") to unblock M2.
