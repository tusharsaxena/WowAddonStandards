# Executive Summary — The Ka0s Addon Standard

**One-page TL;DR of the standard.** Full text: [`01_STANDARD.md`](01_STANDARD.md). Drop-in starter brief for new addons: [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md). Compliance evidence and the audit that produced this standard live under [`../audit/`](../audit/).

---

## What this is

The house standard for the Ka0s World of Warcraft addon collection — the canonical set of rules for tech stack, libraries, design patterns, code structure, naming, packaging, localization, settings, slash commands, debug, and docs. It codifies what already works across the collection and closes the gaps, so every future addon is **born compliant**.

**Substrate:** Ace3. **License:** MIT (always). The standard is versioned; see the changelog at the top of `01_STANDARD.md` (current: **v1.3**).

**Since v1.0:** libraries are now **vendored in `libs/` and committed** (no `.pkgmeta` externals) — v1.1; development is **trunk-based** (no feature branches unless asked, never push unless asked) — v1.2; addons with their own main window follow **§6A Standalone windows / data browsers** — v1.3.

## The five patterns it makes canonical

These were validated against the Ka0s collection and the broader ecosystem (see the audit) and are now mandated by the standard:

1. **Schema-as-single-source-of-truth** — one schema row drives panel widget + slash + defaults reset. (`§4.5`, MUST)
2. **Modular `core/ modules/ defaults/ settings/ locales/` layout** — the canonical Tier 2 reference structure. (`§1.2`)
3. **Chat-formatter via `_G[GLOBALSTRING]` override** instead of hooking chat events — architecturally taint-free. (`§9.5`, SHOULD)
4. **Combat-lockdown discipline** — deferred SettingsPanel / UISpecialFrames / popup in a layered cascade. (`§9.2`)
5. **Macro firewall** — a single module is the sole caller of protected `CreateMacro`/`EditMacro` APIs. (`§9.4`, MUST for any addon touching protected APIs)

## How to use it

1. Read [`01_STANDARD.md`](01_STANDARD.md) and approve or request edits.
2. Drop [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md) into any new addon's `CLAUDE.md` so it starts compliant.
3. Audit existing addons against the standard periodically — see [`../audit/`](../audit/) for the run-per-date compliance reports and remediation plans.

## Scope boundaries

- **CI / GitHub Actions** are intentionally out of scope per Ka0s decision.
- A long-term **`Ka0s-Core`** sibling addon (Bagnon-style engine extraction) is recorded as a future direction in `01_STANDARD.md §20`, not pursued now.
