> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Documentation

Documentation is a **first-class compliance surface**, not an afterthought. Every Ka0s addon ships a fixed, predictable doc set so any human or agent lands in the same place in every repo. **Root of the repo** ships exactly three docs (plus `LICENSE`): a **full** `README.md`, a **stub** `CLAUDE.md`, and `LICENSE`. Everything else lives under `docs/`.

### 1. Root `README.md` — canonical structure

The README is a **player-facing** document. It **MUST** be written for the person who installed the addon, not for a contributor: what the addon does, how to use it, and how to fix common problems. Developer- and contributor-facing material — the test harness, lint, build/packaging, and internal implementation detail — **MUST NOT** appear in the README; it lives under `docs/` (how to verify in `docs/testing.md`, the engineer brief in `docs/ARCHITECTURE.md` and `docs/agent-context.md`).

Write it in **plain language**. Prose **MUST** be short, direct, and free of internal jargon — describe what the player sees, not the code behind it. A reader should never need a term from the codebase (schema, export contract, denormalized row, message bus, and the like) to understand the README, and should not be able to tell it was written by a machine: no stacked em-dash clauses, no hedging, no filler that restates the same point.

Every Ka0s `README.md` **MUST** follow one structure so all addons read identically. Reference implementation (in the collection): the consumables & macro manager's README. Sections in **this exact order**:

1. **H1 title** — `# Ka0s <Name>`. **MUST**.
2. **Badge row** — a fixed set of five shields.io badges, in **this exact order**, matching these canonical templates verbatim (label casing, colours, and `%2F`-encoding included). **MUST**. Reference implementation (in the collection): the loot-history browser's README badge row.

   | # | Badge | Canonical Markdown template | Kind |
   |---|-------|-----------------------------|------|
   | 1 | **`[wow]`** interface | `![WoW](https://img.shields.io/badge/WoW-<Expansion>_<X.Y.Z>-purple)` | **Dynamic data, static badge — MUST track TOC `## Interface:`** |
   | 2 | **published version** | `![CurseForge Version](https://img.shields.io/curseforge/v/<projectId>)` | Live endpoint (auto-updates); add only once published |
   | 3 | **`[license]`** | `![License](https://img.shields.io/badge/License-MIT-orange)` | Static |
   | 4 | **standard** (linked) | `[![Standard](https://img.shields.io/badge/Ka0s-WoW%20Addon%20Standard-yellow)](https://github.com/tusharsaxena/WowAddonStandards)` | Static |
   | 5 | **`[tests]`** pass | `![Tests](https://img.shields.io/badge/Tests-<X>%2F<Y>_passing-green)` | **Dynamic data, static badge — MUST track the test inventory (testing-§5)** |

   - Placeholders: `<Expansion>` is the current Retail expansion name and `<X.Y.Z>` the client patch the TOC `## Interface:` encodes (e.g. `Midnight_12.0.7`); `<projectId>` is the CurseForge project id; `<X>`/`<Y>` are the passed/total case counts from the generated `docs/test-cases.md` (testing-§5).
   - The **published-version** badge (#2) is a **live** shields.io endpoint that auto-updates from the distribution site — no manual upkeep; add it only after first publish (Wago's equivalent endpoint is acceptable in its place).
   - **Keep-in-sync rule (MUST DO).** Badges #1 (`[wow]`) and #5 (`[tests]`) render **static text** and therefore go stale silently unless updated with the data they mirror. They **MUST** be updated **in the same change** that moves their source of truth, never deferred to a follow-up:
     - **`[wow]`** — whenever the TOC `## Interface:` is bumped (each Retail patch, `wow-addon:bump-interface`), update the badge to the same expansion/client version so the two always show one number (toc-file-§3, versioning-git).
     - **`[tests]`** — whenever the suite changes (a case added/removed/renamed, or the pass count moves — i.e. whenever a failing test is resolved), regenerate `docs/test-cases.md` and update the badge's `<X>/<Y>` together (testing-§5).
3. **Logo** — the addon logo image. **MUST**.
4. **Description** — 1–2 paragraphs of what the addon does and why; **MAY** inline a short feature bullet list **or a summary table** (e.g. the addon's core objects/commands at a glance) and a closing line on how to configure it (Blizzard Settings panel + `/<slash>`). **MUST**.
5. **`## Screenshots`** — captioned images of the addon and its settings sub-panels. **SHOULD** (**MUST** once published).
6. **`## Usage`** — **MUST**, with two subsections:
   - **`### Slash commands`** — one intro line (short + long slash form, and the `[XY]` chat prefix), then a **Command | What it does** table generated from `NS.COMMANDS` so it stays in lockstep with `/<slash> help` (slash-commands-§4).
   - **`### Settings panel`** — a **Tab | Covers** table, one row per settings subcategory (options-ui-§5). **MAY** follow the table with per-panel prose (bolded panel/section names + option bullets) where a panel is rich enough to warrant it.
7. **`## How <it> works`** — **SHOULD** for addons whose result hinges on a non-obvious core mechanic (ranking, attribution, scheduling, pick-selection, …). A narrative explainer — a numbered pipeline or prose — of how the addon reaches its result, titled for the domain (e.g. `## How picking & ranking works`).
8. **`## FAQ`** — **SHOULD**; a **Question | Answer** table.
9. **`## Troubleshooting`** — **SHOULD**; a **Symptom | Fix** table.
10. **`## Issues and feature requests`** — **MUST**. A short paragraph pointing users to the addon's **GitHub issues** (`<repo>/issues`) as the **single source of truth for the backlog**, asking them to file there rather than in comments. (This is why a released addon ships no `TODO.md` — documentation-§4.)
11. **`## Version History`** — **MUST**. A **Version | Date | Highlights** table, most-recent first, written for players — user-visible changes, not internal refactors.

There is **no** `## Testing` section in the README (removed in the standard's v2.1.0 — it was contributor-facing). How to verify the addon — the headless harness (`lua tests/run.lua`), lint (`luacheck .`), the generated case inventory (`docs/test-cases.md`, testing-§5), and the in-game smoke tests (`docs/smoke-tests.md`) — lives entirely under `docs/` (testing, audit-review-history). The README still carries the `[tests]` X/Y badge in its badge row (item 2); the badge is the only test-related thing that belongs in the README.

- The optional sections (5, 7, 8, 9) are **SHOULD** — omit one only when it would be empty — but when present their **relative order MUST** be preserved.
- `wow-addon:sync-docs` keeps the README's slash-command and version-history tables in lockstep with code; `wow-addon:standards-audit` flags a README that departs from this canonical structure.
- The README `[wow]` badge and the TOC `## Interface:` **MUST** show the same single number and move together (`wow-addon:bump-interface` / `bump-version`).

### 2. Root `CLAUDE.md` — stub

**A STUB** — a short pointer, **not** the full agent brief (the brief lives in `docs/agent-context.md`, documentation-§3). **MUST NOT** carry the full agent brief at root (anti-pattern #26). It **MUST** contain, in this order:

1. **H1 title** — `# CLAUDE.md — Ka0s <Name>`.
2. **Adherence line** — states the addon adheres to the **Ka0s WoW Addon Standard** with the repo URL <https://github.com/tusharsaxena/WowAddonStandards>.
3. **`## Standards compliance (read first)` section** — **MUST** be present, verbatim in substance (documentation-§6). It states that all work here MUST conform to the standard; that a change which would deviate MUST **stop and be flagged** (never silently deviate, never silently "fix" to match); and that the user decides whether it is (a) an **accepted deviation** (recorded in the addon with a reason) or (b) a **change to the standard itself** (made upstream in this repo, after which the addon follows the new rule). Closes with "when in doubt, treat conformance as a hard requirement and ask."
4. **A "read the docs" pointer list** — directs the reader into `docs/` for the full context: `docs/agent-context.md` (full brief) and `docs/ARCHITECTURE.md` (module map), then the topic-detail docs.
5. **The green-gate line** — the commit gate (`lua tests/run.lua` + `luacheck .`), per testing.

Reference implementation (in the collection): the absorb-shield tracker's root `CLAUDE.md`.

### 3. `docs/`

Every addon **MUST** ship this **canonical trio** under `docs/` (all three are universal across the collection):

- **`docs/agent-context.md`** — the **full agent-context pack**: the detailed working brief the root `CLAUDE.md` points to (stack, layout, hard rules, invariants, the `NS` bus, working environment, response style). This is the file that carries the full context the stub deliberately omits. Its **`## Hard rules`** section **MUST** open with the "conform to the Ka0s WoW Addon Standard" rule and point back to the root `CLAUDE.md` "Standards compliance" section (documentation-§6). Built by dropping in the contents of `NEW_ADDON_CONTEXT.md` (see that pack).
- **`docs/ARCHITECTURE.md`** — engineer context. Sections: Overview, Module Map, Settings Schema, Message Bus (named messages with sender/payload/consumers), Slash Commands (table from `NS.COMMANDS`), Event Subscriptions, Taint Notes, Known Limitations.
- **`docs/smoke-tests.md`** — the in-game smoke-test suite (audit-review-history), linked from the README's Testing section.

Beyond the trio, **MAY** ship any number of **topic-detail docs** (`schema.md`, `module-map.md`, `data-flow.md`, `settings-panel.md`, `slash-dispatch.md`, `midnight-quirks.md`, `scope.md`, `file-index.md`, …) — these legitimately vary per addon and are **not** fixed by the standard. One topic-detail doc is **required**, not optional: `docs/test-cases.md`, the generated test-case inventory (testing-§5). **MUST NOT** ship a `TODO.md` once released (documentation-§4).

### 4. No `TODO.md`

- A **released** addon **MUST NOT** ship a `TODO.md` anywhere (root or `docs/`). All bugs, enhancements, and outstanding work are tracked in the addon's **GitHub issues** — the single source of truth for the backlog, surfaced via the README's "Issues and feature requests" section (documentation-§1).
- **Exception:** an **unreleased, in-development** addon (before its first tagged/published release) **MAY** keep a `docs/TODO.md` as a scratch backlog **during the development phase only**. It **MUST** be deleted at (or before) the first release, with any remaining items migrated to GitHub issues.
- Rationale: two backlogs drift. A checked-in `TODO.md` competes with the issue tracker, goes stale, and hides work from anyone not reading the repo. GitHub issues are searchable, assignable, closable, and linkable from commits/PRs.

### 5. Keeping docs in sync

- **MUST** keep the doc set in sync with code. Drift is the #1 gripe surfaced in every `docs/audits/` run. The `wow-addon:sync-docs` skill exists exactly for this; run it before every release.

### 6. Standards reference (every addon)

Every Ka0s addon **MUST** maintain a clear, durable, in-repo reference to this standard —
<https://github.com/tusharsaxena/WowAddonStandards> — so the standard is always **in the addon's project memory and context**: any human or agent that opens the repo (and specifically any agent that reads `CLAUDE.md` and the `docs/` brief before touching code) is told, up front, that the addon is built to this standard and how to behave when a change would deviate from it. The reference is not decorative — it is the mechanism that keeps the whole collection converged on one standard over time.

The reference **MUST** appear in **all four** of these places (a Ka0s addon missing any of them is non-compliant — anti-pattern #34):

1. **TOC `## X-Standard:`** — `## X-Standard: https://github.com/tusharsaxena/WowAddonStandards` (toc-file-§1). The machine-readable declaration.
2. **README standard badge** — the badge/line linking the standard in the README badge row (documentation-§1 #2). The user-facing declaration.
3. **`CLAUDE.md` → `## Standards compliance (read first)`** — the agent-facing directive at the first doc every agent reads (documentation-§2 #3). **MUST** instruct the agent to **stop and flag** any change that would deviate rather than silently deviate or silently conform, and to let the user classify it as an accepted deviation (recorded in the addon) or a change to the standard itself (made upstream here, then adopted).
4. **`docs/agent-context.md` → `## Hard rules`** — the same rule restated as the **first hard rule** in the full agent brief (documentation-§3), pointing back to the `CLAUDE.md` "Standards compliance" section so the two never drift.

Items 1–2 already existed (toc-file-§1, documentation-§1); items 3–4 are the **memory-and-context** requirement: the standard reference lives inside the two documents an agent loads as working context, not only in shipping metadata. The `/wow-addon:standards-audit` playbook checks all four.

Canonical wording (adapt the `<Name>`; keep the substance verbatim):

```markdown
<!-- in root CLAUDE.md -->
## Standards compliance (read first)

This repo is built to the **Ka0s WoW Addon Standard**
(https://github.com/tusharsaxena/WowAddonStandards). All development here — features, refactors,
doc changes — MUST conform to it. The standard is the source of truth for layout, TOC shape, the
Ace substrate, schema-driven settings, slash/prefix conventions, locales, Compat, tests/lint, and
doc structure.

**If a change would deviate from the standard, STOP and flag the deviation explicitly.** Do not
silently deviate and do not silently "fix" to match. Surface it and let the user decide which of
two things it is:

1. **An accepted deviation** — this addon intentionally differs; record it as a documented
   deviation (e.g. in the TOC/README/`docs/` and in the audit bundle), with the reason.
2. **A change to the standard itself** — the standard's definition should evolve; the update
   belongs upstream in the WowAddonStandards repo, after which this addon conforms to the new rule.

When in doubt, treat standard conformance as a hard requirement and ask.
```

```markdown
<!-- in docs/agent-context.md, as the FIRST bullet of ## Hard rules -->
- **Conform to the Ka0s WoW Addon Standard** (https://github.com/tusharsaxena/WowAddonStandards).
  It is the source of truth for layout, TOC, the Ace substrate, schema-driven settings,
  slash/prefix conventions, locales, Compat, tests/lint, and doc structure. **If a change would
  deviate, STOP and flag it** — never silently deviate or silently conform. The user decides
  whether it is (a) an accepted, documented deviation for this addon, or (b) a change to the
  standard itself (updated upstream in the standards repo, then this addon follows the new rule).
  See the root [CLAUDE.md](../CLAUDE.md) "Standards compliance" section.
```

Reference implementation (in the collection): the absorb-shield tracker carries both blocks — the `## Standards compliance (read first)` section in its root `CLAUDE.md` and the matching first `## Hard rules` bullet in its `docs/agent-context.md`.
