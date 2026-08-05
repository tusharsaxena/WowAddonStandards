> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Documentation

Documentation is a **first-class compliance surface**, not an afterthought. Every Ka0s addon ships a fixed, predictable doc set so any human or agent lands in the same place in every repo. **Root of the repo** ships exactly three docs plus `LICENSE`, and never a fourth doc: a **full** `README.md` (documentation-§1), a **stub** `CLAUDE.md` (documentation-§2), and `DEPENDENCIES.md` (documentation-§7). Everything else lives under `docs/`.

**`CHANGELOG.md` is named explicitly, because the count alone left it arguable.**

- **In an addon repo, a root `CHANGELOG.md` is FORBIDDEN.** The player-facing history already has two
  homes the standard mandates — `## What's new` and `## Version History` in the README
  (documentation-§1, items 5 and 12) — and a second history is precisely the drift the never-a-fourth-doc
  rule exists to prevent. `/wow-addon:bump-version` rolls those two README sections for an addon and
  writes no `CHANGELOG.md`.
- **In a Ka0s-owned library repo, a root `CHANGELOG.md` is REQUIRED** (library-stack-§7's applicability
  list). testing-§10's versioning suite **MUST** assert that the changelog accounts for the version
  every file is at, and it has nowhere else to look. A library has no player README to carry the history
  instead.

State the rule, not the count: an audit finding a root `CHANGELOG.md` cites this sentence, not "that is
a fourth doc."

### 1. Root `README.md` — canonical structure

The README is a **player-facing** document. It **MUST** be written for the person who installed the addon, not for a contributor: what the addon does, how to use it, and how to fix common problems. Developer- and contributor-facing material — the test harness, lint, build/packaging, and internal implementation detail — **MUST NOT** appear in the README; it lives under `docs/` (how to verify in `docs/testing.md`, the engineer brief in `docs/ARCHITECTURE.md`).

Write it in **plain language**. Prose **MUST** be short, direct, and free of internal jargon — describe what the player sees, not the code behind it. A reader should never need a term from the codebase (schema, export contract, denormalized row, message bus, and the like) to understand the README, and should not be able to tell it was written by a machine: no stacked em-dash clauses, no hedging, no filler that restates the same point. Spelling is **US English** throughout — here and in every file under `docs/` (localization-§5).

The README renders on **two** surfaces, and they are not the same renderer. GitHub is where it is
written and reviewed; **CurseForge is where players read it**, and CurseForge's renderer is stricter
about HTML and looser about escapes. Two consequences are normative, because both fail *silently on
the surface a maintainer never checks*:

- **Angle-bracket placeholders MUST NOT appear in shipped README content.** CurseForge strips
  `<setting>`, `<name>`, `<value>` and the like as unknown HTML tags — **including inside backticks**
  — so `` `/bl set <setting> <value>` `` renders to players as `/bl set` with both placeholders gone,
  while looking perfectly correct on GitHub. Write the argument bare (`` `/bl set setting value` ``);
  keep `[…]` for genuinely optional arguments, which survives both renderers. This applies to the
  README only — placeholders in *this* standard, in `docs/`, and in code comments are fine.
- **Percent-escapes MUST NOT be used for spaces in badge URLs** — see the badge table below.

Real HTML a README uses deliberately (`<br>` in a table cell, `<code>`, `<strong>`) is unaffected and
**MUST NOT** be stripped by a sweep for the above.

Every Ka0s `README.md` **MUST** follow one structure so all addons read identically. Reference implementation (in the collection): the consumables & macro manager's README. Sections in **this exact order**:

1. **H1 title** — `# Ka0s <Name>`. **MUST**.
2. **Badge row** — a fixed set of five shields.io badges, in **this exact order**, matching these canonical templates verbatim (label casing, colors, and `%2F`-encoding included). **MUST**. Reference implementation (in the collection): the loot-history browser's README badge row.

   | # | Badge | Canonical Markdown template | Kind |
   |---|-------|-----------------------------|------|
   | 1 | **`[wow]`** interface | `![WoW](https://img.shields.io/badge/WoW-<Expansion>_<X.Y.Z>-purple)` | **Dynamic data, static badge — MUST track TOC `## Interface:`** |
   | 2 | **published version** | `![CurseForge Version](https://img.shields.io/curseforge/v/<projectId>)` | Live endpoint (auto-updates); add only once published |
   | 3 | **`[license]`** | `![License](https://img.shields.io/badge/License-MIT-orange)` | Static |
   | 4 | **standard** (linked) | `[![Standard](https://img.shields.io/badge/Ka0s-WoW_Addon_Standard-yellow)](https://github.com/tusharsaxena/WowAddonStandards)` | Static |
   | 5 | **`[tests]`** pass | `![Tests](https://img.shields.io/badge/Tests-<X>%2F<Y>_passing-green)` | **Dynamic data, static badge — MUST track the test inventory (testing-§5)** |

   - **The standard badge uses `_`, not `%20`, for its spaces — and MUST NOT be "corrected" back.** shields.io renders both identically on GitHub, but **CurseForge does not decode the percent-escape**, so a `%20` badge shows the literal escape on the project page every player actually looks at. The underscore is the form shields.io documents for a space and is what the whole collection already used; the `%20` form was a transcription error in this template, not a decision.
   - Placeholders: `<Expansion>` is the current Retail expansion name and `<X.Y.Z>` the client patch the TOC `## Interface:` encodes (e.g. `Midnight_12.0.7`); `<projectId>` is the CurseForge project id; `<X>`/`<Y>` are the passed/total case counts from the generated `docs/test-cases.md` (testing-§5).
   - The **published-version** badge (#2) is a **live** shields.io endpoint that auto-updates from the distribution site — no manual upkeep; add it only after first publish (Wago's equivalent endpoint is acceptable in its place).
   - **Keep-in-sync rule (MUST DO).** Badges #1 (`[wow]`) and #5 (`[tests]`) render **static text** and therefore go stale silently unless updated with the data they mirror. They **MUST** be updated **in the same change** that moves their source of truth, never deferred to a follow-up:
     - **`[wow]`** — whenever the TOC `## Interface:` is bumped (each Retail patch, `wow-addon:bump-interface`), update the badge to the same expansion/client version so the two always show one number (toc-file-§3, versioning-git).
     - **`[tests]`** — whenever the suite changes (a case added/removed/renamed, or the pass count moves — i.e. whenever a failing test is resolved), regenerate `docs/test-cases.md` and update the badge's `<X>/<Y>` together (testing-§5).
3. **Logo** — the addon logo image. **MUST**.
4. **Description** — 1–2 paragraphs of what the addon does and why; **MAY** inline a short feature bullet list **or a summary table** (e.g. the addon's core objects/commands at a glance) and a closing line on how to configure it (Blizzard Settings panel + `/<slash>`). **MUST**.
5. **`## What's new`** — **MUST**. A headline highlights section — heading `## What's new in <X.Y.Z>` (the current version) — placed **immediately above `## Screenshots`**, so anyone who lands on the repo or the store page sees what changed in the **latest release** without scrolling down to Version History. It lists the top **user-facing** features/changes of the **current release** — the version in the TOC / the top `## Version History` row, i.e. everything since the last `x.y.z`-release tag — as a short bullet list (aim for **3–6** bullets), written for players, not a full log. Its content is the top Version History row surfaced up front, so the two **MUST agree**. **Roll-forward rule (MUST DO):** the section **MUST** be refreshed to the new version's highlights **in the same change** that bumps the version and adds the new `## Version History` row (`wow-addon:bump-version`) — never left pointing at an old version. A `## What's new` naming a stale version, or whose bullets don't match the newest Version History row, is non-compliant.
6. **`## Screenshots`** — captioned images of the addon and its settings sub-panels. **SHOULD** (**MUST** once published).
7. **`## Usage`** — **MUST**, with two subsections:
   - **`### Slash commands`** — one intro line (short + long slash form, and the `[XY]` chat prefix), then a **Command | What it does** table generated from `NS.COMMANDS` so it stays in lockstep with `/<slash> help` (slash-commands-§4).
   - **`### Settings panel`** — a **Tab | Covers** table, one row per settings subcategory (options-ui-§5). **MAY** follow the table with per-panel prose (bolded panel/section names + option bullets) where a panel is rich enough to warrant it.
8. **`## How <it> works`** — **MUST**. A short, player-facing narrative — a numbered pipeline or prose — of how the addon produces what the user sees, titled for the domain (e.g. `## How picking & ranking works`, `## How the bar works`). Center it on the addon's core mechanic (ranking, attribution, scheduling, pick-selection, the value it tracks, …) and describe what happens, not the code behind it. Required even when the mechanic is simple — give the reader the one-paragraph "what's going on" rather than omit the section.
9. **`## FAQ`** — **SHOULD**; a **Question | Answer** table.
10. **`## Troubleshooting`** — **SHOULD**; a **Symptom | Fix** table.
11. **`## Issues and feature requests`** — **MUST**. A short paragraph pointing users to the addon's **GitHub issues** (`<repo>/issues`) as the **single source of truth for the backlog**, asking them to file there rather than in comments. (This is why a released addon ships no `TODO.md` — documentation-§4.)
12. **`## Version History`** — **MUST**. A **Version | Date | Highlights** table, most-recent first, written for players — user-visible changes, not internal refactors. The top row and `## What's new` (item 5) carry the same highlights and move together.

There is **no** `## Testing` section in the README (removed in the standard's v2.1.0 — it was contributor-facing). How to verify the addon — the headless harness (`lua tests/run.lua`), lint (`luacheck .`), the generated case inventory (`docs/test-cases.md`, testing-§5), and the in-game smoke tests (`docs/smoke-tests.md`) — lives entirely under `docs/` (testing, audit-review-history). The README still carries the `[tests]` X/Y badge in its badge row (item 2); the badge is the only test-related thing that belongs in the README.

- The optional sections (6, 9, 10) are **SHOULD** — omit one only when it would be empty — but when present their **relative order MUST** be preserved.
- `wow-addon:sync-docs` keeps the README's slash-command and version-history tables in lockstep with code; `wow-addon:standards-audit` flags a README that departs from this canonical structure.
- The README `[wow]` badge and the TOC `## Interface:` **MUST** show the same single number and move together (`wow-addon:bump-interface` / `bump-version`).

### 2. Root `CLAUDE.md` — stub

**A STUB** — a short pointer, **not** a full agent brief. **MUST NOT** carry a full agent brief at root (anti-pattern #26), and **MUST NOT** point at an in-repo one: the scaffolding brief is fetched at runtime and never lives in the repo (documentation-§3). It **MUST** contain, in this order:

1. **H1 title** — `# CLAUDE.md — Ka0s <Name>`.
2. **Adherence line** — states the addon adheres to the **Ka0s WoW Addon Standard** with the repo URL <https://github.com/tusharsaxena/WowAddonStandards>.
3. **`## Standards compliance (read first)` section** — **MUST** be present, verbatim in substance (documentation-§6). It states that all work here MUST conform to the standard; that a change which would deviate MUST **stop and be flagged** (never silently deviate, never silently "fix" to match); and that the user decides whether it is (a) an **accepted deviation** (recorded as a row in `docs/ARCHITECTURE.md` → `## Documented deviations`, with its `filename-§N` Rule, its reason and its re-check trigger — documentation-§3) or (b) a **change to the standard itself** (made upstream in this repo, after which the addon follows the new rule). Closes with "when in doubt, treat conformance as a hard requirement and ask."
4. **A "read the docs" pointer list** — directs the reader into `docs/` for the full context: `docs/ARCHITECTURE.md` (module map — what this addon actually is), `docs/testing.md` (how to verify), then the topic-detail docs. **MUST NOT** point at a `docs/agent-context.md`; that file does not exist in a Ka0s addon (documentation-§3).
5. **The green-gate line** — the commit gate (`lua tests/run.lua` + `luacheck .`), per testing.

Reference implementation (in the collection): the absorb-shield tracker's root `CLAUDE.md`.

### 3. `docs/`

Every addon **MUST** ship this **canonical trio** under `docs/` (all three are universal across the collection):

- **`docs/ARCHITECTURE.md`** — engineer context. **Nine** mandated sections, all nine named because a bare count goes stale silently: **Overview**, **Module Map**, **Settings Schema**, **Message Bus** (named messages with sender/payload/consumers), **Slash Commands** (table from `NS.COMMANDS`), **Event Subscriptions**, **Taint Notes**, **Known Limitations**, and **`## Documented deviations`** — the register specified immediately below.
- **`docs/testing.md`** — the **verify-how-to** doc: how to run the headless harness (`lua tests/run.lua`) and lint (`luacheck .`), the green commit gate and local toolchain, and pointers to `docs/test-cases.md` (the generated inventory / authoritative pass count) and `docs/smoke-tests.md` (the in-game suite). This is the contributor-facing "how to verify" material that **MUST NOT** live in the README (documentation-§1); the README carries only the `[tests]` badge. Consolidates testing-§2/§3/§4/§5 as a per-addon page. Where it tabulates the four out-of-game suites, the table **MUST** carry the **checkpoint** per suite — run/commit versus the tag — and **MUST NOT** leave a `Gates? no — recorded only` cell unqualified, since that is true of a commit and false of a release (testing-§6, automated-tests-§3/§4).
- **`docs/smoke-tests.md`** — the in-game smoke-test suite (audit-review-history), linked from `docs/testing.md`.

**`docs/` is not where a forbidden root doc goes to live.** documentation-§1 forbids `CHANGELOG.md` at
an **addon** root; moving it to `docs/CHANGELOG.md` does not satisfy that rule, it only hides the second
history one directory down. An addon has one history, in the README's `## What's new` and
`## Version History`. (A **library** repo's required `CHANGELOG.md` stays at **root**, where
testing-§10's versioning suite reads it.)

#### `## Documented deviations` — the single home for a ratified deviation (MUST)

`documentation-§2` and `documentation-§6` both instruct an agent to *record it as a documented
deviation* and, until now, named no file. The result was predictable: every repo invented its own home —
a table in `ARCHITECTURE.md` here, `docs/scope.md` there, a paragraph in root `CLAUDE.md`, a
`docs/pending/LEDGER.md` entry — and two failures followed from the same cause. An audit that cannot
find a ratified decision **re-files it as an open MUST failure**, so the same argument is had every
cycle; and a register nobody re-reads goes stale in the dangerous direction, accumulating entries for
behavior the standard has since mandated or permitted, which reads as deviation and is not.

- **MUST** carry `## Documented deviations` in `docs/ARCHITECTURE.md` — the ninth mandated section,
  present even when empty (write "None." rather than omitting the heading; an absent section is
  indistinguishable from an unwritten one).
- **MUST** use this **exact row shape**:

  ```markdown
  | Rule | What differs | Why | Decided | Re-check trigger |
  |---|---|---|---|---|
  | `performance-§12` | No perf harness wired | No in-combat code path; sweep at <commit> | 2026-08-05 | The first OnUpdate, repeating ticker or in-combat event handler |
  ```

  **Rule** is a `filename-§N` reference into this standard — not a paraphrase, because a paraphrase
  cannot be checked against the rule it claims to deviate from. **Decided** is a date. **Re-check
  trigger** is the **condition that ends the deviation**, stated so a reader can tell whether it has
  already fired; `performance-§12`'s exemption is the model. A row without a trigger is a permanent
  opt-out wearing a table's clothes.
- **This is the single home.** A decision **MAY** be *reasoned* at length in `docs/pending/LEDGER.md`,
  an audit bundle or a review bundle, and the row **SHOULD** cite that id in **Why** — but **a deviation
  not in the register is not ratified**. A ledger entry declining a rule with no corresponding register
  row is itself the deviation, and an audit files it as one.
- **MUST NOT** be a graveyard. An entry whose cited rule the standard has since changed — so the
  behavior is now mandated or permitted outright — **MUST** be retired, and an audit that finds one
  reports it (audit-review-history). A register that only ever grows stops being read, and a register
  nobody reads is worse than none, because its existence is taken as evidence that the deviations are
  known.

Beyond the trio, **MAY** ship any number of **topic-detail docs** (`schema.md`, `module-map.md`, `data-flow.md`, `settings-panel.md`, `slash-dispatch.md`, `midnight-quirks.md`, `scope.md`, `file-index.md`, …) — these legitimately vary per addon and are **not** fixed by the standard. **Five** topic-detail docs are **required**, not optional — `test-cases.md`, `performance.md`, `perf-runs/README.md`, `automated-tests/README.md` and `automated-tests/RESULTS.md` — of which **four are unconditional and one, `perf-runs/README.md`, is required only while the performance harness is wired** (performance-§12). The count is never written bare for exactly this reason: an addon holding a recorded no-combat-path exemption ships **four**, and naming them is what keeps that from reading as a missing doc.

- **`docs/test-cases.md`** — the generated test-case inventory (testing-§5).
- **`docs/performance.md`** — **required unconditionally**, including under the performance-§12 exemption. When the harness is wired it is the addon's own performance page: which hot paths are bracketed and why, how to run a capture (`/<slash> perf`), how to read the report, and what the harness can and cannot resolve (performance). The shared protocol and record contract live with the library — this page points there rather than restating them. When the addon is **exempt** the page stays, and shrinks to **one screen**: that the addon brackets nothing, which of performance-§12's (b)/(c) applies, where the committed sweep lives, and what would re-arm the wiring. The question the page answers — *how much does this addon cost?* — does not go away with the harness; only the answer changes.
- **`docs/perf-runs/README.md`** — **the one conditional member of the five**: required while the harness is wired, and **not shipped** by an addon holding a recorded performance-§12 exemption, which produces no in-game captures and therefore has no store to document. When present it is the standing **in-game** capture store's doc: the record naming convention, a schema summary, a pointer to the library's canonical field-by-field contract, and the note that offline runs live in `docs/automated-tests/` (performance-§8, automated-tests-§7). Cumulative rather than tied to one investigation, so in-game runs compare across addon versions.
- **`docs/automated-tests/README.md`** — what the automated-test record is and how to produce it (automated-tests).
- **`docs/automated-tests/RESULTS.md`** — one row per run across all four suites, **one file overwritten in place** so its git history is the trend line, plus the current complexity watch list (automated-tests-§4). It is **generated**, never hand-edited.

  `docs/complexity.md` was a required doc through v2.18.0 and is **retired** as of v2.19.0: its raw output is `complexity.txt` in each run bundle and its trend-line role is `RESULTS.md`'s (automated-tests-§7).

**MUST NOT** ship a `TODO.md` once released (documentation-§4).

#### CRITICAL — the scaffolding pack is fetched, never stored

An addon repo **MUST NOT** contain `docs/agent-context.md`, under that name or any other. The
scaffolding brief — `standards/NEW_ADDON_CONTEXT.md` in this repo — is **fetched at runtime** into a
temporary directory for the session that needs it, and is **never written into the addon**:

```sh
# during scaffolding only, and NEVER into the repo
curl -fsSL https://raw.githubusercontent.com/tusharsaxena/WowAddonStandards/master/standards/NEW_ADDON_CONTEXT.md \
  -o "$TMPDIR/NEW_ADDON_CONTEXT.md"
```

This is a **MUST NOT**, not a preference, and the reason is that the failure is silent and it
compounds:

- **It is scaffolding, and scaffolding has an expiry.** The pack is a *starter* — a kickstart
  walkthrough, a starter tree, starter snippets, and a "definition of done for v0.1.0". Every one of
  those is answered the moment the addon exists. A copy left in the repo describes the addon on the
  day it was born, forever.
- **A stale brief does not merely go quiet — it actively misleads.** It is the file a session loads
  as *working context*, so its instructions are followed. A pack that still shows how to hand-write a
  debug console, a slash dispatcher or a test harness will get one hand-written, in an addon that
  replaced all three with `LibKa0s` (anti-patterns #47, #49). The drift is invisible to every gate:
  no test covers a doc, and lint does not read prose.
- **It cannot be kept in sync, because it is not about this addon.** The pack is collection-wide.
  Eight repos seeded from it drifted to eight different lengths — 72 to 764 lines — none of them
  wrong on the day they were written and none of them true now.
- **Nothing is lost.** The pack is one `curl` away, always current, and by definition only needed
  while scaffolding. What is genuinely per-addon and genuinely durable already has homes the
  standard requires: the root `CLAUDE.md` stub (identity + standards compliance), `docs/ARCHITECTURE.md`
  (what this addon *is*), and `docs/testing.md` (how to verify it).

An addon carrying the file is non-compliant (anti-pattern #49) and **MUST** delete it, moving any
genuinely addon-specific content that accumulated in it into `docs/ARCHITECTURE.md` (structure,
invariants) or the root `CLAUDE.md` stub (hard rules) first — the pack's *own* generic content is
deleted outright, never migrated.

### 4. No `TODO.md`

- A **released** addon **MUST NOT** ship a `TODO.md` anywhere (root or `docs/`). All bugs, enhancements, and outstanding work are tracked in the addon's **GitHub issues** — the single source of truth for the backlog, surfaced via the README's "Issues and feature requests" section (documentation-§1).
- **Exception:** an **unreleased, in-development** addon (before its first tagged/published release) **MAY** keep a `docs/TODO.md` as a scratch backlog **during the development phase only**. It **MUST** be deleted at (or before) the first release, with any remaining items migrated to GitHub issues.
- Rationale: two backlogs drift. A checked-in `TODO.md` competes with the issue tracker, goes stale, and hides work from anyone not reading the repo. GitHub issues are searchable, assignable, closable, and linkable from commits/PRs.

### 5. Keeping docs in sync

- **MUST** keep the doc set in sync with code. Drift is the #1 gripe surfaced in every `docs/audits/` run. The `wow-addon:sync-docs` skill exists exactly for this; run it before every release.

### 6. Standards reference (every addon)

Every Ka0s addon **MUST** maintain a clear, durable, in-repo reference to this standard —
<https://github.com/tusharsaxena/WowAddonStandards> — so the standard is always **in the addon's project memory and context**: any human or agent that opens the repo (and specifically any agent that reads `CLAUDE.md` and the `docs/` brief before touching code) is told, up front, that the addon is built to this standard and how to behave when a change would deviate from it. The reference is not decorative — it is the mechanism that keeps the whole collection converged on one standard over time.

The reference **MUST** appear in **all three** of these places (a Ka0s addon missing any of them is non-compliant — anti-pattern #34):

1. **TOC `## X-Standard:`** — `## X-Standard: https://github.com/tusharsaxena/WowAddonStandards` (toc-file-§1). The machine-readable declaration.
2. **README standard badge** — the badge/line linking the standard in the README badge row (documentation-§1 #2). The user-facing declaration.
3. **`CLAUDE.md` → `## Standards compliance (read first)`** — the agent-facing directive at the first doc every agent reads (documentation-§2 #3). **MUST** instruct the agent to **stop and flag** any change that would deviate rather than silently deviate or silently conform, and to let the user classify it as an accepted deviation (recorded as a row in the addon's `## Documented deviations` register — documentation-§3) or a change to the standard itself (made upstream here, then adopted).

Items 1–2 already existed (toc-file-§1, documentation-§1); item 3 is the **memory-and-context** requirement: the standard reference lives inside the document an agent loads as working context, not only in shipping metadata. The `/wow-addon:standards-audit` playbook checks all three.

There is deliberately **no fourth place.** Until v2.17.0 the rule was also restated in `docs/agent-context.md`'s `## Hard rules`. That file no longer exists in a Ka0s addon (documentation-§3), and a rule whose fourth home is a file the standard forbids is a rule that audits itself into a permanent failure.

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

1. **An accepted deviation** — this addon intentionally differs; record it as a row in
   `docs/ARCHITECTURE.md` → `## Documented deviations`, shaped
   `| Rule | What differs | Why | Decided | Re-check trigger |`, where Rule is the `filename-§N`
   reference. That register is the single home: the reasoning may live in `docs/pending/LEDGER.md`
   or an audit bundle and the row cites it, but a deviation not in the register is not ratified.
2. **A change to the standard itself** — the standard's definition should evolve; the update
   belongs upstream in the WowAddonStandards repo, after which this addon conforms to the new rule.

When in doubt, treat standard conformance as a hard requirement and ask.
```


Reference implementation (in the collection): the absorb-shield tracker's root `CLAUDE.md` carries the `## Standards compliance (read first)` section verbatim in substance.

**Citing the standard.** The three places above are *the reference to the standard*. This is the
narrower question of how an individual **citation** is written when authored text points at a specific
rule.

A reference to the standard in any authored text the repo owns — code comments, `.luacheckrc` and
`.pkgmeta` headers, `docs/` pages, commit-message bodies — **SHOULD** use the `filename-§N` form
(documentation-§5): the section file's basename without `.md`, then `-§`, then the section's **local**
number. `performance-§10` — not the retired dotted global form `§N.M`, not `STANDARDS.md` plus a
dotted number, not an abbreviated filename (`perf-` for `performance`).

*(This document deliberately never writes a literal dotted number. The sweep below is a plain regex
over the whole repo, and a normative document that spells out the form it forbids reddens its own
check.)*

**A reference that cannot resolve is the defect**, and it comes in two grades:

- **Retired global `§N.M` notation is a SHOULD.** The split standard replaced one document's global
  numbering with per-file local numbering, so a dotted global number no longer names anything. It is a **SHOULD**
  rather than a MUST because it is uniformly wrong in a way a reader decodes at a glance and a machine
  sweeps mechanically — `/wow-addon:revendor-standards` does exactly that. Sweep it; do not hand-triage
  it.
- **A malformed or out-of-range reference is a MUST fix.** Malformed means it does not parse as
  `filename-§N` at all (`slash-commands-§:`); out-of-range means the file exists but has no such
  section — a citation numbered `§41` against `options-ui.md`, which carries §1–§11. Both are worse
  than the retired form, because
  the retired form tells the reader "this is old" while these send the reader to a section that does
  not exist and looks current doing it. Range-check against the section file's own heading count.

**Some section files have no numbered subsections, and are cited by BARE FILENAME.** These carry a
single `## <Topic>` heading and prose beneath it, sometimes with unnumbered `###` headings. There is no
`§N` to name, so **any** `filename-§N` citation against one of them is out-of-range by construction —
the MUST grade above — no matter which number is used. Cite them as `lint`, `packaging`,
`standalone-windows`; where a specific passage matters, name its heading in words
(*`standalone-windows`, "The Ka0s window edge"*).

The full set, as measured by `grep -c '^### [0-9]' standards/standards/<file>` returning 0 — **eleven**
files, named rather than counted:

`anti-patterns`, `audit-review-history`, `compat`, `lint`, `naming-cheatsheet`, `open-evolutions`,
`packaging`, `preview-mode`, `public-api`, `standalone-windows`, `versioning-git`.

An unnumbered `###` heading is **not** a section number. `standalone-windows` and
`audit-review-history` each carry one, and counting it as "§2" is exactly the mistake this list exists
to stop: the count shifts the moment a heading is added above it, so the citation silently comes to
mean something else. If one of these files ever gains numbered subsections, it leaves this list in the
same change.

**Frozen bundles are exempt and MUST NOT be swept.** Anything under `docs/audits/`, `docs/reviews/` or
`docs/automated-tests/` is a point-in-time record and its notation is part of what it recorded —
the same carve-out `standards/_raw/_industry/` already has. Rewriting a citation inside a frozen bundle
corrupts evidence to satisfy a cosmetic rule.

**Reporting shape (MUST).** An audit records the notation sweep as **one** rolled-up finding carrying
the **command that produces the current count**, e.g.

```sh
grep -rEn '§[0-9]+\.[0-9]' . \
  --exclude-dir=libs --exclude-dir=_kit \
  --exclude-dir=audits --exclude-dir=reviews --exclude-dir=automated-tests
```

— never a per-site enumeration. Hand-counted enumerations are what two separate audits of this
collection got wrong, in both directions, on the same rule; the command is reproducible and the list is
not. Out-of-range and malformed references, being the MUST half, are enumerated individually — there are
few of them and each needs a decision.

### 7. Root `DEPENDENCIES.md` — the toolchain contract

Every addon **MUST** ship a root **`DEPENDENCIES.md`** naming every piece of software needed to build, run, test or release it, with **copy-pasteable install instructions for WSL2 / Ubuntu** — the collection's development environment.

Why root, and why its own file. Before this rule the answer to *"what do I need installed to work on this addon?"* was spread across `docs/testing.md`'s local-toolchain section, a line in `CLAUDE.md`, the `.toc`'s `## OptionalDeps`, and — for anything a script needed — nowhere at all. Each of those places is correct about its own slice and silent about the rest, so the only way to learn the full set was to run something and read the error. That is a fine way to discover a missing `luacheck`; it is a poor way to discover that a script wants Python with Pillow, or that a vendored binary needs a system library. A dependency list is also the one doc a **new machine** needs first, which is exactly when the reader cannot yet run the addon to find out. It sits at **root**, next to `README.md`, because a contributor arriving at the repo page must not have to know that `docs/` exists to get set up.

- **MUST** be **evidence-based**. Every entry names what needs it and how that is known — a file:line, a script's import, a documented command. Speculative entries are worse than omissions: a reader who installs three things that turn out to be unnecessary stops trusting the list, and then misses the one that mattered. Something only *plausibly* required is recorded as such, in words, or left out.
- **MUST** separate **runtime** from **development** from **release**, because most readers need only one group:
  1. **Runtime (in-game)** — what the *player* needs. Required and optional addon dependencies from the TOC (`## Dependencies`, `## OptionalDeps`), and the fact that every library is **vendored** under `libs/` so the player installs nothing extra (library-stack). For most Ka0s addons this section's honest content is "World of Warcraft (Retail); nothing else."
  2. **Development** — the toolchain a contributor installs: the Lua interpreter **at the version the harness actually requires**, `luacheck`, `lizard`, and anything the tests shell out to (`git`, POSIX `ls`). State the Lua version as a **requirement with its reason**, not a preference — the headless harness uses `setfenv`, which is Lua 5.1-only, so "5.2 will probably work" is false and costs an hour to disprove.
  3. **Release / assets** — anything needed only to package or to regenerate committed assets: Python and its packages, image tooling, vendored binaries and the system libraries they link against. **MUST** state plainly that these are **not** needed to build, run or test the addon, so a contributor does not install a graphics stack to fix a typo.
- **MUST** give the install commands, verbatim and runnable, for **WSL2 / Ubuntu**, including the workaround where the plain command fails on a current release. Ubuntu 24.04 marks its Python `EXTERNALLY-MANAGED` (PEP 668), so `pip install <tool>` **fails** — the instruction that works is `pipx`, and a `DEPENDENCIES.md` that says `pip install lizard` is a broken instruction that looks correct. **MUST** also give the one-line **verification** command per tool (`lua -v`, `luacheck --version`, `lizard --version`) — an install instruction without a way to confirm it worked sends the reader to the test suite to find out.
- **MUST** name **versions where a version matters** and say when it does not. `lua5.1` is a hard requirement; `lizard` and `luacheck` are "any recent" and pinning them would be false precision.
- **SHOULD** end with the exact **commands this repo is verified with** — lint, the headless suite, the complexity report — so the document doubles as the "am I set up correctly?" check. These point at `docs/testing.md` (documentation-§3) rather than restating its content; `DEPENDENCIES.md` answers *what to install*, `docs/testing.md` answers *how to verify*, and neither repeats the other.
- **MUST NOT** drift. It is **checked at release** alongside the rest of the doc set (documentation-§5): a new script, a new import, or a dropped tool changes this file in the same change. A dependency list that is wrong is the specific failure mode that makes a new contributor's first hour their last.
- **MUST NOT** be a substitute for vendoring. Libraries are vendored and committed (library-stack, packaging); listing a library here does **not** license fetching it at build time.
