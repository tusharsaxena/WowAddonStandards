# Executive Summary — The Ka0s Addon Standard

**One-page TL;DR of the standard.** Full text: [`STANDARDS.md`](STANDARDS.md). Drop-in starter brief for new addons: [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md). Each addon is audited **in its own repo** via `/wow-addon:standards-audit` — see the [`../AUDIT.md`](../AUDIT.md) playbook.

---

## What this is

The house standard for the Ka0s World of Warcraft addon collection — the canonical set of rules for tech stack, libraries, design patterns, code structure, naming, packaging, localization, settings, slash commands, debug, and docs. It codifies what already works across the collection and closes the gaps, so every future addon is **born compliant**.

**Substrate:** Ace3. **License:** MIT (always). **Scope:** Retail only. Every addon must be built to this standard and **reference it in four places** — the TOC `X-Standard` field, the README standard badge, the root `CLAUDE.md` "Standards compliance (read first)" section, and `docs/agent-context.md`'s "Hard rules" — so <https://github.com/tusharsaxena/WowAddonStandards> is always in the addon's project memory and context (documentation-§6). The standard is versioned; see the changelog at the top of `STANDARDS.md` (current: **v1.13.0**).

## The five patterns it makes canonical

These were validated against the Ka0s collection and the broader ecosystem (see [`INDUSTRY_RESEARCH.md`](INDUSTRY_RESEARCH.md)) and are now mandated by the standard:

1. **Schema-as-single-source-of-truth** — one schema row drives panel widget + slash + defaults reset. (`architecture-§5`, MUST)
2. **Modular `core/ modules/ defaults/ settings/ locales/` layout** — the canonical Tier 2 reference structure. (`tiered-layout-§2`)
3. **Chat-formatter via `_G[GLOBALSTRING]` override** instead of hooking chat events — architecturally taint-free. (`events-frames-taint-§5`, SHOULD)
4. **Combat-lockdown discipline** — secure frame writes defer on `PLAYER_REGEN_ENABLED`, but the options-panel open **refuses** under lockdown (grey notice, no defer-replay). (`events-frames-taint-§2`, `options-ui-§2`)
5. **Macro firewall** — a single module is the sole caller of protected `CreateMacro`/`EditMacro` APIs. (`events-frames-taint-§4`, MUST for any addon touching protected APIs)

## How to use it

1. Read [`STANDARDS.md`](STANDARDS.md) and approve or request edits.
2. Drop [`NEW_ADDON_CONTEXT.md`](NEW_ADDON_CONTEXT.md) into any new addon's `CLAUDE.md` so it starts compliant.
3. Audit existing addons against the standard periodically — run `/wow-addon:standards-audit` in each addon's repo; it writes a dated `docs/audits/<date>/` bundle there (see the [`../AUDIT.md`](../AUDIT.md) playbook).

## Scope boundaries

- **Retail (Mainline) only.** Classic/other flavors are out of scope; addons ship a single latest-Retail `## Interface:` line (`toc-file-§3`).
- **CI / GitHub Actions** are intentionally out of scope per Ka0s decision. **Local** testing and linting are **in scope** — a headless Lua 5.1 harness plus `luacheck` (`testing`).
- A long-term **`Ka0s-Core`** sibling addon (shared-engine extraction, including the debug-console + test scaffolding) is recorded as a future direction in `STANDARDS.md open-evolutions`, not pursued now.
