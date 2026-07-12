# Executive Summary — The Ka0s Addon Standard

**One-page TL;DR of the standard.** Full text: [`01_STANDARD.md`](01_STANDARD.md). Drop-in starter brief for new addons: [`02_NEW_ADDON_CONTEXT.md`](02_NEW_ADDON_CONTEXT.md). Compliance evidence and the audit that produced this standard live under [`../audit/`](../audit/).

---

## What this is

The house standard for the Ka0s World of Warcraft addon collection — the canonical set of rules for tech stack, libraries, design patterns, code structure, naming, packaging, localization, settings, slash commands, debug, and docs. It codifies what already works across the collection and closes the gaps, so every future addon is **born compliant**.

**Substrate:** Ace3. **License:** MIT (always). **Scope:** Retail only. Every addon must be built to this standard and reference it: <https://github.com/tusharsaxena/WowAddonStandards>. The standard is versioned; see the changelog at the top of `01_STANDARD.md` (current: **v2.2**).

**Since v1.0:** libraries are **vendored and committed** (no externals) — v1.1; development is **trunk-based** — v1.2; addons with their own main window follow **§6A Standalone windows / data browsers** — v1.3. **v2.0** is a major refresh: **Retail-only** with a single latest-Retail `## Interface:` line (no multi-flavor); **docs relocated** to `docs/` with a full root `README.md` and a **stub** root `CLAUDE.md`; a mandatory **headless Lua 5.1 test harness + TDD commit gate** (`lua tests/run.lua` green **and** `luacheck .` clean before every commit — §14A); an on-screen **debug console** instead of chat output (§12); **settings category registered eagerly** so the entry is always visible (§6.1); an optional **preview/test mode** (§6B); **typed `media/` subfolders**; and a convention that the standard **describes reference implementations rather than naming addons** (§0). **v2.1** standardizes the root **`README.md` structure** (§15.1) and the **TOC field order + file-listing structure** (§2.1, §2.5) across every addon, and **bans a checked-in `TODO.md`** in released addons — backlog lives in **GitHub issues** (§15.4). **v2.2** adds **§3.6 No addon-suite dependencies**: every addon is fully **self-contained** and behaves identically standalone — no hard dependency on, or reading the media/API/SavedVariables of, any addon suite (ElvUI, EllesmereUI, DBM, …); optional, presence-guarded integration that degrades gracefully is still allowed (vendored **libraries** are unaffected — a library is not a suite).

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

- **Retail (Mainline) only.** Classic/other flavors are out of scope; addons ship a single latest-Retail `## Interface:` line (`§2.3`).
- **CI / GitHub Actions** are intentionally out of scope per Ka0s decision. **Local** testing and linting are **in scope** — a headless Lua 5.1 harness plus `luacheck` (`§14A`).
- A long-term **`Ka0s-Core`** sibling addon (shared-engine extraction, including the debug-console + test scaffolding) is recorded as a future direction in `01_STANDARD.md §20`, not pursued now.
