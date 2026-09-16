# ARCHITECTURE.md — Ka0s WoW Addon Standard

Engineer context for **this** repository, and the hub of its doc set (documentation-§8).

> **This repo is a documentation-and-tooling repo** (`documentation-§8`) — the collection's third repo
> kind, alongside addons and Ka0s-owned library repos. It ships no Lua to the WoW client and vendors
> no payload into any addon's `libs/`, so §8's applicability lists govern it rather than the addon
> rule set. That section reduces this file's mandated sections from ten to **five**: Overview, Module
> Map read as the file-and-path map, Known Limitations, the documentation map and the deviation
> register. The five that describe an addon's runtime — Settings Schema, Message Bus, Slash Commands,
> Event Subscriptions and Taint Notes — are **not** written here as "not applicable" rows, because §8
> **SHOULD NOT**s exactly that: the exemption is granted once, in the standard, and restating it per
> repo is the duplication that section exists to end.

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

Read as the **file-and-path map** (`documentation-§8`): there is no Lua and there are no modules, so
what this section carries is which paths exist, what reads each one, and which are **addressed by**
**URL** and therefore breaking to rename.

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
| `DEPENDENCIES.md` | The toolchain contract (documentation-§7, read per §8) — git only, and why the rest is absent |
| `docs/ARCHITECTURE.md` | This file — the hub |
| `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`, `PERF_ANALYSIS.md` | The four process playbooks |
| `standards/STANDARDS.md` | The standard's index |
| `standards/standards/*.md` (26 files) | The canonical section files |
| `standards/ADDONS.md` | The roster |
| `standards/README.md`, `standards/EXECUTIVE_SUMMARY.md`, `standards/INDUSTRY_RESEARCH.md`, `standards/NEW_ADDON_CONTEXT.md` | Process entry point, summary, research, scaffold context pack |
| `standards/_raw/_industry/` | Frozen source material behind `INDUSTRY_RESEARCH.md` |
| `harvests/<date>/` | Frozen harvest bundles, named once here rather than per file |

`docs/testing.md` and `docs/smoke-tests.md` — the other two thirds of documentation-§3's canonical
trio — are absent, and that is **compliance rather than deviation**: `documentation-§8` places both
in its *does not apply* list, because each describes how to verify a Lua addon out of game and in
the client, and this repo has neither. No register row is owed for them.

## Documented deviations

**None.**

This repo carried three rows until 2026-09-16 — the absent `docs/testing.md` and `smoke-tests.md`, a
near-empty `DEPENDENCIES.md`, and six `ARCHITECTURE.md` sections recorded *not applicable*. All three
are **retired, and not by editing this repo**: each was individually reasonable and collectively a
sign that the standard was missing a **scope** rather than that this repo was non-compliant. The
third row said so outright and named the fix — a named applicability list for this repo kind, the way
`library-stack-§7` has one for `LibKa0s`.

That is now **`documentation-§8`**, added in standard **v2.51.0**. It grants all three exemptions once,
to both documentation-and-tooling repos, so nothing is restated here. Its own re-check trigger lives
in the section rather than in this table: **the first `.lua` this repo tracks outside a frozen
bundle**, at which point `lint`, `testing` and `automated-tests` are re-read against what the tree
actually has.

The heading stays, empty, because `documentation-§3` requires it present even when there is nothing in
it — an absent section is indistinguishable from an unwritten one.
