# ARCHITECTURE.md — Ka0s WoW Addon Standard

Engineer context for **this** repository, and the hub of its doc set (documentation-§3).

> **Why several sections below say "not applicable".** documentation-§3 mandates ten sections in a
> `docs/ARCHITECTURE.md`, and every one of them is written for an **addon**: a Lua payload with
> modules, a settings schema, a message bus, slash commands, event subscriptions and a taint surface.
> This repo has none of those — it ships **documents only**, and nothing in it loads into the WoW
> client. The sections are all present, in the mandated order, because an omitted heading is
> indistinguishable from an unwritten one; where the subject does not exist, the section says so and
> says why, which is a checkable claim rather than a gap. See `## Documented deviations` for the
> ratified decision behind that.

## Overview

The **house standard** for the Ka0s WoW addon collection, plus the four **process playbooks** the
[`wow-addon`](https://github.com/tusharsaxena/wow-addon) Claude Code plugin fetches at runtime.

The critical property is that **this repo does no work**. It is read, never run. Each playbook is a
thin orchestrator that says *how* a process runs and defers all substance to the canonical section
files under `standards/standards/`; the plugin fetches it over HTTPS and executes it **inside an
addon's own repo**, writing every artifact there. Nothing here reaches into a sibling repo, and no
audit, test record or scaffold output is ever written here.

That indirection is deliberate. It means the standard can change without a plugin release, and the
plugin can change without a standards release, and an addon picks up both on its next command.

## Module Map

**Not applicable** — there is no code, so there are no modules. The structural equivalent is the file
layout, which is load-bearing because the plugin addresses these paths by URL:

| Path | What it is | Read by |
|---|---|---|
| `AUDIT.md` | Playbook: per-addon self-audit | `/wow-addon:standards-audit` |
| `AUTOMATED_TESTS.md` | Playbook: per-addon test record | `/wow-addon:automated-tests` |
| `NEW_ADDON.md` | Playbook: scaffold a born-compliant addon | `/wow-addon:new-addon` |
| `PERF_ANALYSIS.md` | Playbook: per-addon in-game capture bundle | `/wow-addon:perf-analysis` |
| `standards/STANDARDS.md` | **The index.** Its Sections list is what a consumer follows to find every section file. | every standards-reading command |
| `standards/standards/*.md` | The 26 canonical section files — the substance of the standard | followed from the index |
| `standards/ADDONS.md` | The roster: which repos the standard covers | the standards-refresh process |
| `standards/NEW_ADDON_CONTEXT.md` | The context pack read at scaffold time, never written into the new addon | `/wow-addon:new-addon` |
| `standards/EXECUTIVE_SUMMARY.md`, `standards/INDUSTRY_RESEARCH.md`, `standards/_raw/` | Background and the research the standard was drawn from | humans |
| `harvests/<date>/` | Frozen bundles from `/wow-addon:harvest-standards` — what was proposed, what was accepted | humans |
| `media/logos/` | Collection logo art | humans |

**Renaming any path in the first block is a breaking change** for every addon in the collection,
because the plugin resolves it by URL at runtime and a 404 is the failure mode.

## Settings Schema

**Not applicable** — no SavedVariables, no settings, no registries, and no named non-setting state
(architecture-§5). This repo stores nothing at runtime because it has no runtime.

## Message Bus

**Not applicable** — architecture-§4's MUST binds an addon with two or more feature modules or any
module registering game events. There are no modules and no events here, so the rule is out of scope
rather than unmet.

## Slash Commands

**Not applicable as an addon surface** — there is no `NS.COMMANDS` table and this repo registers no
slash command. It is, however, the *definition* consumed by commands that run elsewhere; those are
listed in `## Module Map` above against the playbook each one reads.

## Event Subscriptions

**Not applicable** — nothing here registers a WoW event. There is no event surface at all.

## Taint Notes

**Not applicable** — taint is a property of code executing in the WoW client. Nothing in this repo
executes anywhere, so it cannot taint the secure environment.

The *rules about* taint that addons are held to live in
[`standards/standards/events-frames-taint.md`](../standards/standards/events-frames-taint.md); this
section is about **this repo's own** taint surface, which is empty.

## Known Limitations

- **No mechanical gate.** There is no suite that can catch a contradiction between two section files,
  a broken internal link, or a playbook step that names a path that has since moved. Every such
  defect is found by a human or by an agent reading the file, usually while doing something else.
  The one exception is line endings, which `git check-attr` and a `git grep` for CR will answer.
- **Cross-references are unenforced.** A `filename-§N` citation that goes out of range when a section
  is renumbered fails silently and keeps looking current. documentation-§6 makes this a MUST-fix when
  found, but nothing here *finds* it.
- **The roster is hand-maintained.** `standards/ADDONS.md` is edited by a person. A new sibling addon
  repo that nobody adds a row for is simply invisible to the standards process — there is no
  discovery pass over the parent directory.
- **A playbook edit takes effect immediately**, for every addon, on its next command, with no staging
  and no version pin. There is no way to try one against a single repo first.

## Documentation map

Every `.md` in this repo appears in exactly one row below.

| Doc | What it is |
|---|---|
| `README.md` | Repo overview and what you can do here |
| `CLAUDE.md` | Agent guidance: what this repo is, its layout, how to change the standard |
| `DEPENDENCIES.md` | The toolchain contract (documentation-§7) — near-empty here, and why |
| `docs/ARCHITECTURE.md` | This file — the hub |
| `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`, `PERF_ANALYSIS.md` | The four process playbooks |
| `standards/STANDARDS.md` | The standard's index |
| `standards/standards/*.md` (26 files) | The canonical section files |
| `standards/ADDONS.md` | The roster |
| `standards/README.md`, `standards/EXECUTIVE_SUMMARY.md`, `standards/INDUSTRY_RESEARCH.md`, `standards/NEW_ADDON_CONTEXT.md` | Process entry point, summary, research, scaffold context pack |
| `standards/_raw/_industry/` | Frozen source material behind `INDUSTRY_RESEARCH.md` |
| `harvests/<date>/` | Frozen harvest bundles, named once here rather than per file |

`docs/testing.md` and `docs/smoke-tests.md` — the other two thirds of documentation-§3's canonical
trio — are **deliberately absent**: there is nothing to verify out of game and nothing to walk in
game. That is covered by the deviation row below rather than left to be discovered.

## Documented deviations

| Rule | What differs | Why | Decided | Re-check trigger |
|---|---|---|---|---|
| documentation-§3 | `docs/` holds `ARCHITECTURE.md` only. `docs/testing.md` and `docs/smoke-tests.md` are absent, and six of ARCHITECTURE.md's ten mandated sections are recorded **not applicable** rather than filled. | The trio and those six sections presuppose a Lua payload that loads into the WoW client. This repo ships documents only — no code, no suite, no client surface — so the docs would have to be invented to exist, and an invented verification doc is worse than an absent one because it reads as measured. | 2026-09-16 | Any executable content landing in this repo — a script, a linter config, a test harness — at which point `docs/testing.md` becomes real and is owed. |
| documentation-§7 | Root `DEPENDENCIES.md` exists but names exactly one required tool (git) and lists the rest as **not used here**. | Same cause. The file is present because the rule's value is that a reader always finds it in the same place; its content is honest about a repo with no toolchain instead of padded to look like an addon's. | 2026-09-16 | The first tool this repo genuinely requires to work on. |
| library-stack-§7 | This repo has no Applicability block of its own, the way LibKa0s does. | §7's list was written for a Ka0s-owned **library** repo. A documentation-and-tooling repo is a third shape the standard does not yet name, so the two rows above carry the exemption locally instead. | 2026-09-16 | A third documentation-and-tooling repo entering the rotation — at which point the exemption should move upstream into the standard as a named applicability list rather than being restated per repo. |
