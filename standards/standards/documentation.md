> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Documentation

Documentation is a **first-class compliance surface**, not an afterthought. Every Ka0s addon ships a fixed, predictable doc set so any human or agent lands in the same place in every repo. **Root of the repo** ships exactly three docs plus `LICENSE`, and never a fourth doc: a **full** `README.md` (documentation-§1), a **stub** `CLAUDE.md` (documentation-§2), and `DEPENDENCIES.md` (documentation-§7). Everything else lives under `docs/`.

**`CHANGELOG.md` is named explicitly, because the count alone left it arguable.**

- **In an addon repo, a root `CHANGELOG.md` is FORBIDDEN.** The player-facing history already has a
  home the standard mandates — `## Version History` in the README (documentation-§1, item 10) — and a second history is precisely the drift the never-a-fourth-doc
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
   | 4 | **standard** (**not** a link) | `![Standard](https://img.shields.io/badge/Ka0s-WoW_Addon_Standard-yellow)` | Static |
   | 5 | **`[tests]`** pass | `![Tests](https://img.shields.io/badge/Tests-<X>%2F<Y>_passing-green)` | **Dynamic data, static badge — MUST track the test inventory (testing-§5)** |

   - **The standard badge uses `_`, not `%20`, for its spaces — and MUST NOT be "corrected" back.** shields.io renders both identically on GitHub, but **CurseForge does not decode the percent-escape**, so a `%20` badge shows the literal escape on the project page every player actually looks at. The underscore is the form shields.io documents for a space and is what the whole collection already used; the `%20` form was a transcription error in this template, not a decision.
   - **The standard badge is deliberately NOT a link, and MUST NOT be re-wrapped in one.** The template is the bare image — `![Standard](…)` — never `[![Standard](…)](https://github.com/tusharsaxena/WowAddonStandards)`. The standards-repo reference that actually binds an addon lives in the two places documentation-§6 makes normative and a reader can act on: the TOC `## X-Standard:` field and the root `CLAUDE.md` `## Standards compliance (read first)` section. The badge is the third place, and its job there is to *declare* — a marker on a page written for players, telling them this addon is built to a house standard. It is not a navigation affordance, because the person reading it is not the person who needs the repo: a player who follows the link lands in a document that tells them nothing about the addon they installed, and the contributor who does need it already has it in the two files they open first. Wrapping it costs a player a dead end and buys a maintainer nothing they did not already have. Like the `_`-not-`%20` rule above, this is stated as a **MUST NOT** because the two forms look almost identical in a diff and the link reads as an omission to anyone tidying up.
   - Placeholders: `<Expansion>` is the current Retail expansion name and `<X.Y.Z>` the client patch the TOC `## Interface:` encodes (e.g. `Midnight_12.0.7`); `<projectId>` is the CurseForge project id; `<X>`/`<Y>` are the passed/total case counts from the generated `docs/test-cases.md` (testing-§5).
   - The **published-version** badge (#2) is a **live** shields.io endpoint that auto-updates from the distribution site — no manual upkeep; add it only after first publish (Wago's equivalent endpoint is acceptable in its place).
   - **Keep-in-sync rule (MUST DO).** Badges #1 (`[wow]`) and #5 (`[tests]`) render **static text** and therefore go stale silently unless updated with the data they mirror. They **MUST** be updated **in the same change** that moves their source of truth, never deferred to a follow-up:
     - **`[wow]`** — whenever the TOC `## Interface:` is bumped (each Retail patch, `wow-addon:bump-interface`), update the badge to the same expansion/client version so the two always show one number (toc-file-§3, versioning-git).
     - **`[tests]`** — whenever the suite changes (a case added/removed/renamed, or the pass count moves — i.e. whenever a failing test is resolved), regenerate `docs/test-cases.md` and update the badge's `<X>/<Y>` together (testing-§5).
3. **Description** — 1–2 paragraphs of what the addon does and why; **MAY** inline a short feature bullet list **or a summary table** (e.g. the addon's core objects/commands at a glance) and a closing line on how to configure it (Blizzard Settings panel + `/<slash>`). **MUST**.
4. **`## Screenshots`** — captioned images of the addon and its settings sub-panels. **SHOULD** (**MUST** once published).
5. **`## Usage`** — **MUST**. **Prose, not tables.** Describe how a player actually uses the addon: how its display is shown, hidden, moved and locked; how a preview or test mode is reached and what it is for; the controls the addon's own chrome carries; and whatever the addon's core interactions are (hovering, clicking, drilling in, exporting). Write it in **paragraphs**, in the order a new player meets the addon rather than the order the commands are declared. **Aim for five paragraphs or fewer**; a genuinely complex addon may need more, and that is not a breach.
   - **Close with one line pointing at configuration**, and nothing more: the addon's page under the game's own **Settings → AddOns**, and the slash verb that prints the command list (both the short and long forms). One sentence. It is a signpost, not a summary.
   - **It MUST NOT carry a slash-command table or a settings-page table.** Both were mandated here until v2.41.0 and both were the wrong content for the audience. A generated `Command | What it does` table tells a player what exists without telling them what to do, and it is a second copy of a list `/<slash> help` already prints from `NS.COMMANDS` — the authority slash-commands-§4 names. A `Tab | Covers` table is a contents page for a panel the player can simply open. Neither is deleted from the collection: the command list stays generated from `NS.COMMANDS` and reachable from `/<slash> help` and the settings landing page, and the **`Tab | Covers` table moves to `docs/settings-panel.md`** (documentation-§3), which is its canonical home and already carries the finer page → tab → row tree beneath it.
   - **Write it like a person.** This section is read by players, not by an auditor, and it is the section where machine-shaped prose shows most: uniform paragraph lengths, `**Bold lead.**` sentence openers, see-saw pairs ("That is the manual version. The automatic version is…"), and the same contrast made three times in three sections. A README that reads as generated is a README nobody finishes.
6. **`## How <it> works`** — **MUST**. A short, player-facing narrative — a numbered pipeline or prose — of how the addon produces what the user sees, titled for the domain (e.g. `## How picking & ranking works`, `## How the bar works`). Center it on the addon's core mechanic (ranking, attribution, scheduling, pick-selection, the value it tracks, …) and describe what happens, not the code behind it. Required even when the mechanic is simple — give the reader the one-paragraph "what's going on" rather than omit the section.
7. **`## FAQ`** — **SHOULD**; a **Question | Answer** table.
8. **`## Troubleshooting`** — **SHOULD**; a **Symptom | Fix** table.
9. **`## Issues and feature requests`** — **MUST**. A short paragraph pointing users to the addon's **GitHub issues** (`<repo>/issues`) as the **single source of truth for the backlog**, asking them to file there rather than in comments. (This is why a released addon ships no `TODO.md` — documentation-§4.)
10. **`## Version History`** — **MUST**. A **Version | Date | Highlights** table, most-recent first, written for players — user-visible changes, not internal refactors. It is the addon's only player-facing history; the top row is the current release. **Every highlight in the Highlights cell MUST be prefixed `- `, and highlights are separated by `<br>`** — including in a row with only one highlight, so the column reads uniformly down the table. Markdown will not render a real `<ul>` inside a table cell, so the literal hyphen is the mechanism rather than a workaround for one; without it a release with six or eight highlights renders on GitHub as a single justified paragraph and a reader cannot see where one item ends and the next begins. Adding the prefixes is **punctuation only**: no highlight is reworded, reordered, merged or split, and a row already carrying `- ` is left alone rather than given a second one.
11. **`## Credits`** — **MAY**, and **only** for genuinely **external** credit: third-party artwork, a font, a sound pack, another author's work the addon builds on or ships. It is the **last** section, after `## Version History`, because it is an acknowledgment rather than something a player came here to read. It **MUST NOT** carry a vendored-library list of any kind — see the rule immediately below. An addon with nothing external to credit ships no `## Credits` section at all; an empty or library-only one is a deviation, not a courtesy.

**The README MUST NOT carry a logo image.** No `![…](media/logos/…)` line, no `<img>`, no banner or
artwork above or below the title: the page opens on the H1, the badge row and the description. The
addon's logo belongs in game, on the settings landing page (options-ui-§5), and its art stays under
`media/logos/` for that page, which this rule does not touch. The list above had a *Logo* section until
v2.45.0; `wow-addon:standards-audit` now flags one (anti-pattern #79).

**Every edit to `README.md` MUST go through a de-AI writing pass before it is committed** — the `/humanize` skill, or an equivalent audit against a published AI-writing pattern catalog. Fix what it finds, then commit.

**This binds `README.md` and nothing else, deliberately.** It is the one document in the repo written for **players** rather than for contributors or agents; it is the page a stranger judges the addon by on GitHub and CurseForge; and machine-shaped prose is most visible exactly where the audience did not opt into reading a technical document. `docs/`, `CLAUDE.md`, `DEPENDENCIES.md`, commit messages and code comments are contributor surfaces and are explicitly **out of scope** — a rule that binds every file is a rule nobody runs, and a code comment optimized for voice is worse than one optimized for precision. Apply the pass to **what you changed**: a README already through it does not get re-audited section by section on every later edit.

**What the pass is looking for**, so this is not a vibe check: uniform paragraph and sentence length (the strongest structural signal), `**Bold lead.**` openers on every bullet, see-saw pairs ("That is the manual version. The automatic version is…"), the same rhetorical move repeated across sections, rhetorical-question openers, rule-of-three padding, em-dash overuse, and the AI vocabulary set (delve, leverage, robust, seamless, testament to, showcase, foster). Removal is half of it: prose with every tell stripped and no voice put back reads as a press release, which is its own tell.

**The README MUST NOT carry a bundled-library inventory.** No `## Libraries`, `## Bundled libraries`, `## Libraries and credits`, `## Credits and libraries`, `## Credits and bundled libraries` — and no library list smuggled into the intro prose, which is where the rule was most often satisfied in letter and broken in fact. That means the Ace3 / LibSharedMedia / LibDataBroker / LibDBIcon roll-call, the "everything ships inside the addon, nothing else to install" library paragraph, and the `LibKa0s` provenance sentence all come out of the README together.

Which libraries a build vendors is a **contributor** fact, and it already has two homes that are read by the people it is for: `DEPENDENCIES.md` (documentation-§7) names every dependency with the evidence for it, and `docs/ARCHITECTURE.md` (documentation-§3) says what the addon does with each one. The **LibKa0s provenance line** — `Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).` — moves to root `CLAUDE.md` (documentation-§2), where the vendored-payload gate now reads it. A player has no decision to make with any of this: the libraries ship inside the addon, there is nothing to install, and nothing to choose. A third copy of the inventory on the player-facing page is one more place to go stale, and the one place no gate has ever looked.

What survives the removal is external credit and nothing else. If the deleted section carried a third-party artist, a font or a sound pack, keep those lines as a plain `## Credits` (item 11) holding **only** them. If nothing external remains, delete the section outright — along with any link, table-of-contents row or cross-reference elsewhere in the README that pointed at it, since a live link to a deleted heading is the same failure one step removed.

There is **no** `## Testing` section in the README (removed in the standard's v2.1.0 — it was contributor-facing). How to verify the addon — the headless harness (`lua tests/run.lua`), lint (`luacheck .`), the generated case inventory (`docs/test-cases.md`, testing-§5), and the in-game smoke tests (`docs/smoke-tests.md`) — lives entirely under `docs/` (testing, audit-review-history). The README still carries the `[tests]` X/Y badge in its badge row (item 2); the badge is the only test-related thing that belongs in the README.

- The optional sections (4, 7, 8) are **SHOULD** — omit one only when it would be empty — and `## Credits` (11) is **MAY**, omitted entirely when there is nothing external to credit. When present, their **relative order MUST** be preserved.
- `wow-addon:sync-docs` keeps the README's slash-command and version-history tables in lockstep with code; `wow-addon:standards-audit` flags a README that departs from this canonical structure.
- The README `[wow]` badge and the TOC `## Interface:` **MUST** show the same single number and move together (`wow-addon:bump-interface` / `bump-version`).

### 2. Root `CLAUDE.md` — stub

**A STUB** — a short pointer, **not** a full agent brief. **MUST NOT** carry a full agent brief at root (anti-pattern #26), and **MUST NOT** point at an in-repo one: the scaffolding brief is fetched at runtime and never lives in the repo (documentation-§3). It **MUST** contain, in this order:

1. **H1 title** — `# CLAUDE.md — Ka0s <Name>`.
2. **Adherence line** — states the addon adheres to the **Ka0s WoW Addon Standard** with the repo URL <https://github.com/tusharsaxena/WowAddonStandards>.
3. **`## Standards compliance (read first)` section** — **MUST** be present, verbatim in substance (documentation-§6). It states that all work here MUST conform to the standard; that a change which would deviate MUST **stop and be flagged** (never silently deviate, never silently "fix" to match); and that the user decides whether it is (a) an **accepted deviation** (recorded as a row in `docs/ARCHITECTURE.md` → `## Documented deviations`, with its `filename-§N` Rule, its reason and its re-check trigger — documentation-§3) or (b) a **change to the standard itself** (made upstream in this repo, after which the addon follows the new rule). Closes with "when in doubt, treat conformance as a hard requirement and ask."
4. **A "read the docs" pointer list** — directs the reader into `docs/` for the full context: `docs/ARCHITECTURE.md` (module map — what this addon actually is), `docs/testing.md` (how to verify), then the topic-detail docs. **MUST NOT** point at a `docs/agent-context.md`; that file does not exist in a Ka0s addon (documentation-§3).
5. **The green-gate line** — the commit gate (`lua tests/run.lua` + `luacheck .`), per testing.
6. **The LibKa0s provenance line** — **MUST**, in any addon that vendors `libs/LibKa0s/`; absent (and only absent) in one that does not. Exact template:

   ```markdown
   Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).
   ```

   `vX.Y.Z` is the **tag** the vendored payload was copied from — the library repo's semver tag, not any file's LibStub minor (library-stack-§7 keeps those axes apart). It names the tag for **both** vendored payloads, `libs/LibKa0s/` and `tests/_kit/`, which are compared against the same ref.

   **It moves in the same commit as the bytes.** A re-vendor that updates the payload and leaves the line at the old tag is the drift anti-patterns #45 describes, now with a document asserting the wrong answer; a line bumped ahead of a re-vendor is worse, because it reads as done.

   **The gate reads this file, and only this file.** `tests/_kit/vendor_sync.lua` greps root `CLAUDE.md` with the Lua pattern `[Bb]undles %[LibKa0s%]%b() (v[%d%.]+)`, so both a standalone sentence and a mid-sentence phrasing satisfy it, and the line **MAY** be written either way. A repo that leaves the line in `README.md` reads to the gate as having **no provenance line at all** and fails, naming `CLAUDE.md`. There is deliberately no fallback: a fallback would let a repo sit half-migrated with two lines that can disagree, and a gate silently preferring one of them is the same shape as the drift it exists to catch (testing-§11).

Reference implementation (in the collection): the absorb-shield tracker's root `CLAUDE.md`.

### 3. `docs/`

Every addon **MUST** ship this **canonical trio** under `docs/` (all three are universal across the collection):

- **`docs/ARCHITECTURE.md`** — engineer context, and the **hub** of the doc set (documentation-§3's tier model). **Ten** mandated sections, all ten named because a bare count goes stale silently: **Overview**, **Module Map**, **Settings Schema** (which, for every structural registry the addon holds, names its storage keys, its one registry writer and its load pass, and for every piece of **named non-setting state** — geometry only a drag or a resize determines, a remembered view, learned or recorded data, a vendored library's own writes — its storage key, its one owner module and every function that writes it, wherever each lives; that sentence is the compliance and no register row is needed — architecture-§5), **Message Bus** (named messages with sender/payload/consumers), **Slash Commands** (table from `NS.COMMANDS`), **Event Subscriptions**, **Taint Notes**, **Known Limitations**, **`## Documentation map`** — the per-addon doc register specified below — and **`## Documented deviations`** — the register specified immediately below.
- **`docs/testing.md`** — the **verify-how-to** doc: how to run the headless harness (`lua tests/run.lua`) and lint (`luacheck .`), the green commit gate and local toolchain, and pointers to `docs/test-cases.md` (the generated inventory / authoritative pass count) and `docs/smoke-tests.md` (the in-game suite). This is the contributor-facing "how to verify" material that **MUST NOT** live in the README (documentation-§1); the README carries only the `[tests]` badge. Consolidates testing-§2/§3/§4/§5 as a per-addon page. Where it tabulates the four out-of-game suites, the table **MUST** carry the **checkpoint** per suite — run/commit versus the tag — and **MUST NOT** leave a `Gates? no — recorded only` cell unqualified, since that is true of a commit and false of a release (testing-§6, automated-tests-§3/§4).
- **`docs/smoke-tests.md`** — the in-game smoke-test suite (audit-review-history), linked from `docs/testing.md`.

**`docs/` is not where a forbidden root doc goes to live.** documentation-§1 forbids `CHANGELOG.md` at
an **addon** root; moving it to `docs/CHANGELOG.md` does not satisfy that rule, it only hides the second
history one directory down. An addon has one history, in the README's
`## Version History` table. (A **library** repo's required `CHANGELOG.md` stays at **root**, where
testing-§10's versioning suite reads it.)

#### `## Documented deviations` — the single home for a ratified deviation (MUST)

`documentation-§2` and `documentation-§6` both instruct an agent to *record it as a documented
deviation* and, until now, named no file. The result was predictable: every repo invented its own home —
a table in `ARCHITECTURE.md` here, `docs/scope.md` there, a paragraph in root `CLAUDE.md`, a
issue-audit issue on the repo — and two failures followed from the same cause. An audit that cannot
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
- **This is the single home.** A decision **MAY** be *reasoned* at length in the **GitHub issue** the
  pending audit filed for it on the addon's own repo — labeled `state:triaged` or
  `state:will-not-do` (audit-review-history) — or in an audit or review bundle, and the row **SHOULD** cite that issue
  number or bundle id in **Why**; but **a deviation not in the register is not ratified**. An issue
  declining a rule with no corresponding register row is itself the deviation, and an audit files it
  as one.
- **MUST NOT** be a graveyard. An entry whose cited rule the standard has since changed — so the
  behavior is now mandated or permitted outright — **MUST** be retired, and an audit that finds one
  reports it (audit-review-history). A register that only ever grows stops being read, and a register
  nobody reads is worse than none, because its existence is taken as evidence that the deviations are
  known.

Beyond the trio, an addon ships **topic-detail docs** in **three tiers** — a required set with fixed
filenames, a conditional set with fixed filenames and stated triggers, and a free-form set the standard
never names. The tiers and the rule that keeps `ARCHITECTURE.md` from swallowing them are specified in
*The topic-detail tiers* below. **Five** of those docs are the **verification-and-record** members,
required by the testing and automated-test rules rather than by this section's tier model —
`test-cases.md`, `performance.md`, `perf-analysis/README.md`, `automated-tests/README.md` and
`automated-tests/RESULTS.md` — of which **four are unconditional and one, `perf-analysis/README.md`, is
required only while the performance harness is wired** (performance-§12). The count is never written
bare for exactly this reason: an addon holding a recorded no-combat-path exemption ships **four**, and
naming them is what keeps that from reading as a missing doc. These five, together with `testing.md`
and `smoke-tests.md`, are the **seven documents that belong to no tier**, and `## Documentation map`'s
fourth table — `### Verification and record`, specified below — is where they are registered; the one
of the seven that also carries a Tier 2 trigger, `perf-analysis/README.md`, registers with its trigger
instead, and the fourth table's own specification says why.

- **`docs/test-cases.md`** — the generated test-case inventory (testing-§5).
- **`docs/performance.md`** — **required unconditionally**, including under the performance-§12 exemption. When the harness is wired it is the addon's own performance page: which hot paths are bracketed and why, how to run a capture (`/<slash> perf`), how to read the report, and what the harness can and cannot resolve (performance). The shared protocol and record contract live with the library — this page points there rather than restating them. When the addon is **exempt** the page stays, and shrinks to **one screen**: that the addon brackets nothing, which of performance-§12's (b)/(c) applies, where the committed sweep lives, and what would re-arm the wiring. The question the page answers — *how much does this addon cost?* — does not go away with the harness; only the answer changes.
- **`docs/perf-analysis/README.md`** — **the one conditional member of the five**: required while the harness is wired, and **not shipped** by an addon holding a recorded performance-§12 exemption, which produces no in-game captures and therefore has no store to document. When present it is the standing **in-game** capture store's doc, and it covers: the bundle naming — one **frozen dated bundle per capture** at `docs/perf-analysis/<YYYYMMDD-HHMMSS>/`, stamped in local time from the record's own timestamp — and the three artifacts each bundle carries (`report.md`, the verbatim one-line `dump.json`, and `ANALYSIS.md`); a schema summary with a pointer to the library's canonical field-by-field contract rather than a second copy of it; how a capture is taken in **this addon's own** slash verb; the note that offline runs live in `docs/automated-tests/` (performance-§8, automated-tests-§7); and an **index of the captures taken so far**, one row per bundle, so a reader after the last capture on a given version does not have to open every directory. It is the one file in the store that is rewritten — the bundles are frozen. Cumulative rather than tied to one investigation, so in-game runs compare across addon versions.
- **`docs/automated-tests/README.md`** — what the automated-test record is and how to produce it (automated-tests).
- **`docs/automated-tests/RESULTS.md`** — one row per run across all four suites, **one file overwritten in place** so its git history is the trend line, plus the current complexity watch list and a short standing section per suite (automated-tests-§4). It is **generated** — table, watch-list rows and standing sections are all the runner's — and never hand-edited, with exactly one exception: the watch list's **`Disposition`** column, which is the owner's judgment and which the runner carries forward while its entry is unchanged (automated-tests-§4, *the one boundary*). Through v2.38.0 this line read "generated, never hand-edited" flat, against an automated-tests-§4 that MUST'd narrative no runner emitted; the record was stale in ten of ten repositories because the file could not be written correctly by anybody.

  `docs/complexity.md` was a required doc through v2.18.0 and is **retired** as of v2.19.0: its raw output is `complexity.txt` in each run bundle and its trend-line role is `RESULTS.md`'s (automated-tests-§7).

**MUST NOT** ship a `TODO.md` once released (documentation-§4).

#### The topic-detail tiers — required, conditional, and addon-specific (MUST)

Through v2.22.0 this section said topic-detail docs "legitimately vary per addon and are **not** fixed
by the standard." That was true of *which subjects* an addon has to explain and false of *whether it
has to explain them*, and leaving both to the addon produced two failures with one cause.

- **The doc set collapsed into `ARCHITECTURE.md`, or it didn't, and nothing decided which.** Two
  addons in the collection wrote every subject into the hub and reached **669 and 1071 lines**; six
  split the same material across nine to twelve topic docs and hold their hub between **210 and 472**.
  Same rule, opposite shapes, and the monolith is the one that loses: a reader looking for the settings
  schema in a thousand-line file has no landmark, and an agent editing it rewrites sections it never
  needed to open.
- **The addons that *did* split gave the same content a different filename in almost every repo.**
  SavedVariables shape was `schema.md`, `data-model.md` **and** `saved-variables.md`; the core pipeline
  was `data-flow.md`, `pipeline.md`, `capture-pipeline.md`, `override-pipeline.md` and
  `attribution.md`; the options panel was `settings-panel.md` and `settings-system.md`; client
  workarounds were `midnight-quirks.md` and `wow-quirks.md`. The whole point of a fixed doc set is that
  a reader who learns one repo has learned all of them, and per-repo vocabulary spends that for nothing.

So the tier is fixed and the *content* stays per-addon. A doc belongs in **Tier 1** when the question it
answers is guaranteed to exist in any addon built to this standard **and** the answer is genuinely
per-addon. Both halves bind. The second is why the shared substrate is **not** here: every Ka0s addon
has a `Compat` layer, a message bus and a debug console, but they come from `LibKa0s` and the library
documents them once (library-stack-§7). A required per-addon page for those would be eight copies of
someone else's documentation, which is the drift this section exists to prevent.

##### Tier 1 — required, unconditional, canonical filename

Every addon **MUST** ship all six, under **exactly** these names:

| Doc | Answers | MUST cover |
|---|---|---|
| `docs/scope.md` | what is this addon for? | what it does, and — explicitly — what it deliberately does **not** do. The out-of-scope half is the load-bearing half; it is the answer to "why doesn't it just also…" |
| `docs/module-map.md` | where does the code live? | every non-vendored file, its one-line responsibility, and **load order** (the TOC's file order and why it is that order) |
| `docs/schema.md` | what is persisted? | the SavedVariables shape, every default, and the **migration** path for each schema version bump (savedvariables) |
| `docs/settings-panel.md` | how is it configured? | **the `Tab \| Covers` table** (one row per settings subcategory, options-ui-§5) — moved here from the README at v2.41.0, because it is a contents page for a panel rather than something a player reads before opening it — then the panel/subcategory tree, per-option behavior, and how each control maps to its schema key (options-ui-§5). Since every page is a tab strip (options-ui-§13), the tree is **page → tab → row** and is written that way — one heading per page, the tabs in `group` declaration order, the rows under each. The table is **derived from the schema**, which is also where an audit reads it from, so a page → tab list here that the schema does not produce is the finding rather than the record |
| `docs/data-flow.md` | how does it actually work? | the core mechanic as a pipeline — event or trigger in, processing, what the user ends up seeing. The engineer counterpart to the README's player-facing `## How <it> works` (documentation-§1 item 8); the two describe one pipeline at two levels and **MUST NOT** contradict each other |
| `docs/common-tasks.md` | how do I change it? | recipes for the changes actually made most often in *this* addon — add a setting, add a slash command, add a tracked entity, add a locale string — each as concrete steps naming real files |

Each is already the majority habit in the collection; this ratifies the shape the addons converged on
rather than inventing one.

##### Tier 2 — required when its trigger fires, canonical filename

**MUST** ship under exactly these names **when** the stated trigger holds:

| Doc | Required when |
|---|---|
| `docs/perf-analysis/README.md` | the performance harness is wired (performance-§12) — specified above |
| `docs/slash-dispatch.md` | `NS.COMMANDS` carries **eight or more** commands, or **any** subcommand tree |
| `docs/midnight-quirks.md` | the addon carries **at least one** client-version workaround of its own |
| `docs/compat-layer.md` | `core/Compat.lua` publishes **three or more** addon-specific shims beyond what `LibKa0s` supplies |
| `docs/message-bus.md` | the addon defines **more than ten** distinct messages |
| `docs/profiles.md` | AceDB profiles are **user-visible** (a profile control ships in the options UI) |
| `docs/debug.md` | the addon ships debug surfaces **beyond** the `LibKa0s` default console |

**The `compat-layer.md` trigger counts, and this is what it counts.** A shim is one entry point
published on the addon's own `Compat` table — the wrapper a feature module calls in place of a
version-variant or optional client API. It is counted mechanically, over the addon's own file and
nothing else:

```
grep -cE '^\s*function\s+[A-Za-z_][A-Za-z0-9_]*\.' core/Compat.lua
```

Shims `LibKa0s` supplies are **not** counted and **MUST NOT** be re-documented here: the library
documents its own substrate once, under library-stack-§7, and an addon page restating it is a copy of
someone else's documentation going stale in eight places, which is the drift this whole section exists
to stop.

**Why the number, and why it is three.** Until this rule carried one, `compat-layer.md` was the only
Tier 2 trigger written as pure judgment — "carries addon-specific shims" — sitting between
`slash-dispatch.md`'s *eight or more* and `message-bus.md`'s *more than ten*. Read as judgment it was
read four ways, and the readings do not track size. `MultiMeters/core/Compat.lua` is 761 lines
publishing 28 shims and the repo ships no `docs/compat-layer.md`; `BankLedger/core/Compat.lua` (175
lines, 13 shims), `KickCD/core/Compat.lua` (496, 13) and `LootHistory/core/Compat.lua` (416, 23) each
ship one. The cleanest evidence that the old wording decided nothing is the pair four lines apart:
`BankLedger/core/Compat.lua` at 175 lines has the doc and `PanelMaster/core/Compat.lua` at 173 lines
(8 shims) does not. The two the auditor was actually being asked to decide were the small ones —
`ConsumableMaster/core/Compat.lua` (83 lines, 6 shims) and `WhatGroup/core/Compat.lua` (130 lines, 7
shims, at `:24`, `:40`, `:52`, `:62`, `:83`, `:105`, `:125`) — and they were decided differently from
one cycle to the next, at the cost of the same argument every audit.

Three sits deliberately below every `core/Compat.lua` the collection ships, because excluding somebody
is not the number's job: **settling the small cases without an argument is.** It still leaves a real
floor — an addon whose Compat file is one or two wrappers owes a *Not applicable* row in
`## Documentation map` rather than a page that is more heading than content — and it moves no
repository's answer away from what a careful reader would already have given it.

**Not applicable is a valid state, and it MUST be stated.** A Tier 2 doc whose trigger has not fired is
recorded as a row in `## Documentation map` carrying the trigger — not silently absent. This is
deliberately **not** a `## Documented deviations` row: the addon is complying, not deviating, and
filing compliance in the deviation register is what turns that register into the graveyard
documentation-§3 forbids. The cost of the row is one line; what it buys is that an audit can tell
*not applicable* from *not written*, which by inspection of the directory alone it cannot.

##### Tier 3 — addon-specific, free-form name

Anything genuinely particular to one addon — its artwork spec, its macro manager, its browser window,
its icon grid — **MAY** ship under **any** name, and the standard **MUST NOT** name it. This tier is
the reason the tier model does not have to be conservative: a subject that belongs to one addon has a
home that does not require an upstream change to create.

Two obligations, and only two:

- **MUST** appear in `## Documentation map` with a one-line description.
- **MUST NOT** duplicate a Tier 1 or Tier 2 doc's content. Where a Tier 3 doc needs that material it
  **links** to it. A second copy of the schema under a domain name is the drift the canonical filenames
  were fixed to stop, wearing a Tier 3 badge.

##### `ARCHITECTURE.md` is a hub, and the spill rule keeps it one (MUST)

`ARCHITECTURE.md`'s mandated sections **summarize and link**; they are not the storage. Two rules,
both stated as thresholds because "keep it short" demonstrably did not hold:

- **A mandated section that exceeds roughly 60 lines MUST spill** into its canonical topic doc,
  leaving behind a summary and exactly **one** link. *Module Map* spills to `module-map.md`, *Settings
  Schema* to `schema.md`, *Slash Commands* to `slash-dispatch.md`, *Message Bus* to `message-bus.md`.
- **The whole file SHOULD stay under roughly 400 lines.** A hub past that has stopped being an index.

Both numbers are approximate on purpose — the failure they catch is 1071 lines, not 412 — and an audit
reports the shape, not the arithmetic.

##### `## Documentation map` — the tenth `ARCHITECTURE.md` section (MUST)

The register that makes the tiers checkable **in both directions**. Every `.md` under `docs/` appears
in **exactly one** of its four tables, and every table row points at a file that exists — so a missing
required doc and an orphaned undocumented one are both findings, where previously neither was.

Frozen and generated material is **out of scope** and **MUST NOT** be enumerated row by row:
`docs/audits/`, `docs/reviews/`, `docs/automated-tests/<run>/`, `docs/perf-analysis/<run>/`,
`docs/superpowers/` and `docs/investigations/` are named as directories, once each. A register that
grows a row per audit is a register nobody re-reads.

###### `### Verification and record` — the fourth table (MUST)

Through v2.38.0 this register named **three** tables, one per tier, and it was **unsatisfiable as
written**. Seven documents belong to no tier and never did: `testing.md` and `smoke-tests.md` are
canonical-trio members rather than topic detail, and the five verification-and-record docs —
`test-cases.md`, `performance.md`, `perf-analysis/README.md`, `automated-tests/README.md` and
`automated-tests/RESULTS.md` — are required by `testing` and `automated-tests` rather than by this
section's tier model, which is what this section already says of them a page above. A MUST that every
`.md` sit in exactly one of three **tier** tables, written over a doc set whose seven members the same
section deliberately places outside the tiers, cannot be complied with; and filing them under a tier
anyway would misstate where their requirement comes from, which is the one fact the register exists to
carry.

**Nine of nine addons wrote the missing table before the standard named it**, independently and under
the same heading: AbsorbTracker `docs/ARCHITECTURE.md:332`, BankLedger `:199`, ConsumableMaster `:287`,
KickCD `:204`, LootHistory `:360`, MultiMeters `:660`, PanelMaster `:148`, PrettyChat `:190`, WhatGroup
`:320`. Two audits filed it — `PRETTYCHAT-A-09` and `WHATGROUP-A-15` — as a gap in the rule rather than
a defect in the repo, and both were right. This amendment ratifies what the collection already ships.
**No addon moves a table on account of it**, and any repo carrying a note that justifies the extra
table against the old three-table MUST deletes that note: the table is now the rule.

- **MUST** carry `### Verification and record` as the fourth table, in the shape `| Doc | Covers |`,
  placed after `### Conditional` and before `### Addon-specific` — the order all nine converged on.
- It holds **exactly** `testing.md`, `smoke-tests.md`, `test-cases.md`, `performance.md`,
  `automated-tests/README.md` and `automated-tests/RESULTS.md`. Six rows, in every addon, in every
  state — this table has no conditional member and therefore no *Not applicable* row. It is **not** a
  spare tier for a doc whose tier is awkward.
- **`perf-analysis/README.md` registers in `### Conditional`, not here**, in *both* of its states. It
  is the one member of the five that is also a **Tier 2** doc with a stated trigger (the performance
  harness is wired, performance-§12), and only the conditional table has the Status and Trigger columns
  that answer it; a `| Doc | Covers |` row cannot express *not applicable*, which is the state five of
  the nine addons are in. Registering it in both tables is the "exactly one" MUST broken by the
  standard's own two-way classification, so this settles it: **the trigger decides the table**.

###### Does `ARCHITECTURE.md` register itself? — **MAY**, and an audit files neither state (MUST NOT)

The hub is itself a `.md` under `docs/`, so the scope sentence above reads as covering it, and the
collection split five to four on whether to write the row. Five open their first table with a
`| ARCHITECTURE.md | This file — the hub: … |` row — BankLedger `docs/ARCHITECTURE.md:179`,
ConsumableMaster `:267`, KickCD `:185`, LootHistory `:340`, MultiMeters `:656` — and four do not:
AbsorbTracker, PanelMaster, PrettyChat and WhatGroup. Left unsettled that is four findings or five,
cycle after cycle, over a row that changes nothing.

It is settled as a **MAY**, deliberately, because neither of the register's two failure modes exists
for the file that carries the register. A missing required doc is caught by a table row with no file
behind it; an orphaned undocumented one by a file with no row. `ARCHITECTURE.md` can be neither — it is
the document being read, and its absence takes the map with it. A self-row is **orientation**, not a
check: it tells a reader who landed on the map that the hub is part of the set it is looking at. That
is worth something and it is not worth a rule, so:

- An addon **MAY** register `ARCHITECTURE.md`, and when it does the row is the **first row of
  `### Required`**, described as the hub — the form the five that do it already use.
- An audit **MUST NOT** file the presence of that row, and **MUST NOT** file its absence. This is the
  only exception to "every `.md` under `docs/` appears in exactly one table", and it is stated here so
  that the exception lives with the rule rather than in nine repositories' heads.

```markdown
## Documentation map

### Required (documentation-§3, Tier 1)

| Doc | Covers |
|---|---|
| `scope.md` | What the ledger tracks, and what it deliberately leaves to other addons |
| … | … |

### Conditional (documentation-§3, Tier 2)

| Doc | Status | Trigger |
|---|---|---|
| `slash-dispatch.md` | Present | 11 commands in `NS.COMMANDS` |
| `perf-analysis/README.md` | Not applicable | The `performance-§12` exemption is held; no harness is wired |
| `profiles.md` | Not applicable | No profile control ships in the options UI |

### Verification and record (documentation-§3)

| Doc | Covers |
|---|---|
| `testing.md` | How to run the harness and lint; the green commit gate |
| `smoke-tests.md` | The in-game smoke-test suite |
| `test-cases.md` | The generated case inventory (authoritative pass count) |
| `performance.md` | The addon performance page |
| `automated-tests/README.md` | What the automated-test record is and how to produce it |
| `automated-tests/RESULTS.md` | One row per run; generated by the runner, never hand-edited apart from the watch list's `Disposition` column (automated-tests-§4) |

### Addon-specific (documentation-§3, Tier 3)

| Doc | Covers |
|---|---|
| `artwork-spec.md` | Source dimensions and slice geometry for the panel frame art |
```

`wow-addon:sync-docs` keeps the map in lockstep with what is on disk;
`wow-addon:standards-audit` checks the required set, the conditional set's stated status, the
verification-and-record set, orphans, non-canonical filenames, and the hub's shape.

##### Retired topic-detail docs

- **`file-index.md` is retired** as of v2.23.0 — folded into `module-map.md`, which four addons carried
  alongside it as the same table twice. An addon shipping one **MUST** merge it in and delete it.
- **`conventions.md` is retired** as of v2.23.0. It restated `naming-cheatsheet` and the standard's own
  rules, which is exactly the per-addon copy of upstream text that goes stale without anyone noticing;
  whatever is genuinely local moves to `common-tasks.md`.

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
2. **README standard badge** — the standard badge in the README badge row (documentation-§1 #2). The user-facing **declaration**, and deliberately **not a link**: it tells a player the addon is built to a house standard, and the reader who needs the repo itself has it in items 1 and 3, which are the two places a contributor or an agent actually opens. Re-wrapping it in a link is a **MUST NOT** (documentation-§1 #2).
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
   reference. That register is the single home: the reasoning may live in the issue-audit GitHub
   issue or an audit bundle and the row cites it, but a deviation not in the register is not ratified.
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
  section — a citation numbered `§41` against `options-ui.md`, which has never carried forty
  sections. Both are worse than the retired form, because
  the retired form tells the reader "this is old" while these send the reader to a section that does
  not exist and looks current doing it. **Range-check against the section file's own heading count,
  which is the only authority** — `grep -c '^### [0-9]' standards/standards/<file>`. No live upper
  bound is written into this sentence on purpose: a range pinned in prose goes stale the next time a
  section is added, and a stale upper bound turns every legitimate citation above it into a MUST fix
  for an agent applying the rule literally. That has already happened once here, to `options-ui`.

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

### 8. What binds a documentation-and-tooling repo

Everything above is written for an **addon**. `library-stack-§7` already carves out the second repo kind — a **Ka0s-owned library repo**, which has no TOC and is audited against its own applicability lists. This section carves out the **third**: a **documentation-and-tooling repo**, which ships no Lua to the WoW client and is not a library either.

There are two today, both named in `ADDONS.md` → *Documentation-and-tooling repos*: **`WowAddonStandards`** (this repo — the standard and its four process playbooks) and **`wow-addon`** (the Claude Code plugin that consumes them). `line-endings-§2` has recognized this kind since it was written — it is the *"ships nothing to the client"* half of the two-pin rule, and it names *"the standards and plugin repos"* in as many words — but nothing said which of the **other** twenty-six sections reach such a repo. The cost of that silence was the predictable one: this repo carried three locally-argued deviation rows restating the same exemption the standard should have granted once, and `AUDIT.md` step 1 asserted that *a repo with no `.toc` is a Ka0s-owned library repo*, which is false for both repos named above.

**How to tell the three kinds apart.** A repo with a `.toc` is an **addon**. A repo with no `.toc` that ships a **client-bound Lua payload** vendored into addons' `libs/` is a **Ka0s-owned library repo** (library-stack-§7). A repo with **neither** — no `.toc`, no payload any addon vendors into `libs/` — is a **documentation-and-tooling repo**, and takes the lists below. The discriminator is the same one `line-endings-§2` already uses to choose the pin, so an audit that has resolved the pin has resolved the kind.

**The three lists are exhaustive, and the default is that a section applies.** Between them they classify **every** section in `STANDARDS.md`'s Sections list, and an audit of such a repo may check that mechanically. A section this standard gains later, which nobody has thought about in these terms, **applies unchanged** until it is placed in one of the lists. *Does not apply* is the only list that is an exception to that default.

**Applies, unchanged:**

| Section | Why it binds a documentation-and-tooling repo |
|---|---|
| `line-endings` | The **LF** pin (`line-endings-§2`), the `*.sh text eol=lf` carve-out mandatory in both kinds, the binary marks and the `§5` canonical body. This section already named this repo kind before this one existed. |
| `versioning-git` | Semver and trunk-based git discipline. The standard's own version is the clearest case in the collection: every rule change bumps it, and consumers cite the version they were written against. |
| `documentation-§4` | **No root `TODO.md`.** A backlog belongs in the issue store, not in a file that rots at the root — and a repo whose entire product is documents has the least excuse. |
| `documentation-§5` | Keeping the docs in sync. Here this is nearly the whole job rather than a chore beside the code. |
| `documentation-§6` | The `filename-§N` citation scheme and the citation rules. **Load-bearing here beyond any addon:** this is where the cited text lives, so a malformed or out-of-range reference in this repo is wrong at the source rather than in one copy of it. |
| `localization-§5` | US English in authored text. A British spelling in a section file is copied into every addon that quotes the rule. |
| `audit-review-history` | The frozen dated bundles, all three MUSTs on the deviation register, and the GitHub-issue decision store. |
| `open-evolutions` | In the only sense it binds anywhere: a record of recorded directions, not a rule an audit files against. |

**Does not apply:**

- **`toc-file`, `options-ui`, `slash-commands`, `preview-mode`, `launcher`, `savedvariables`, `standalone-windows`, `debug-logging`, `events-frames-taint`, `compat`, `public-api`, `packaging`.** There is no TOC, no settings canvas, no slash surface, no on-screen display, no minimap button or broker object, no SavedVariables file, no combat surface, no client API to shim, no exported Lua surface and no CurseForge package. Each binds an addon, and each is audited there.
- **`architecture`.** Namespace bootstrap, AceAddon registration, the module pattern and the message bus all describe a Lua addon's runtime. There is none.
- **`library-stack`.** The repo vendors nothing into a `libs/` and publishes no LibStub major. Its own consumers reach it over HTTPS at runtime, which is not vendoring and is governed by nothing in that section.
- **`lint`, `testing`, `performance`, `automated-tests`.** All four presuppose Lua source to lint, load, measure and record. A repo with no `.lua` has no `.luacheckrc`, no `tests/` harness, no buckets and no four-suite battery, and a bundle recording four skips is a record of nothing. **This is a statement about Lua, not about verification**: if such a repo grows executable content, see *Read here*, below.
- **`documentation-§1`'s player-facing README structure and badge row.** There are no players. The `README.md` is written for contributors and agents.
- **`documentation-§2`'s addon `CLAUDE.md` stub as written.** The stub's shape assumes an addon; see the substitution below.
- **`documentation-§3`'s `docs/` trio as written, its three-tier topic-detail model, and the five verification-and-record documents** (`test-cases.md`, `performance.md`, `perf-analysis/README.md`, `automated-tests/README.md`, `automated-tests/RESULTS.md`). `testing.md` and `smoke-tests.md` describe how to verify a Lua addon out of game and in the client, and both are inapplicable where neither exists. The five verification-and-record documents record what `testing`, `performance` and `automated-tests` produce, and those three sections do not apply here. Together with `testing.md` and `smoke-tests.md` they are the seven documents documentation-§3 places outside the tiers, and none of the seven binds this repo kind. Tier 1's `scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`, `data-flow.md` and `common-tasks.md` describe an addon's runtime shape and settings canvas. **`ARCHITECTURE.md` itself still binds, in a reduced shape** — see *Read here*.

**Applies, read for a documentation-and-tooling repo:**

| Section | How it reads here |
|---|---|
| `documentation-§3`'s `ARCHITECTURE.md` | **Binds, with a reduced section set.** Six of the ten mandated sections — Settings Schema, Message Bus, Slash Commands, Event Subscriptions, Taint Notes, and Module Map *as a Lua module map* — describe a runtime this repo kind does not have, and a file recording six "not applicable" headings is worse than one that never claimed them. The mandated set here is **five**: **Overview**, **Module Map** *read as the file-and-path map* (which paths exist, what reads each one, and which are addressed by URL and therefore breaking to rename), **Known Limitations**, **`## Documentation map`**, and **`## Documented deviations`**. The last two bind unchanged and for the same reasons they bind anywhere. Writing the other five as "not applicable" rows is **not** required and **SHOULD NOT** be done: this section is the exemption, and restating it per repo is the duplication it exists to end. |
| `documentation-§7` | **Binds.** A new machine needs the toolchain list whatever the repo ships, and the reader must not have to infer "nothing" from an absent file. Where a repo genuinely requires almost nothing, the honest content is **a short required list and an explicit *not used here* list with reasons** — `git` alone is a complete answer. **MUST NOT** invent entries to fill the addon-shaped shape: §7's evidence-based MUST already forbids it, and a padded list here would be the first thing to go stale. §7's *Runtime (in-game)* group has no instance and is omitted rather than answered. |
| `layout` | The **folder casing** rules bind. The `core/ defaults/ settings/ locales/ modules/` skeleton and the folder load order do not — there is no TOC to order. The **1500-line cap** (`layout-§1`) binds *authored `.lua`*, so it has no instance while the repo has none; it is not re-read onto Markdown, whose length is governed by nothing here. `layout-§1`'s **`tools/`** MUST binds if and when such a repo authors a **generator** — a script that writes a file the repo commits — and its `.pkgmeta` condition is simply void, since `packaging` does not apply here at all. It does **not** reach the scripts a tooling repo exists to ship: the `wow-addon` plugin's `scripts/` holds hooks and a bounded-run wrapper that its own `hooks/hooks.json` invokes by path, and a hook is a program the repo's consumers run, not a generator producing committed output. Moving those would break the manifest for no rule's benefit. |
| `naming-cheatsheet` | Binds to whatever identifiers the repo authors — a shell script's functions, a JSON config's keys. With no Lua the surface is small, not absent. |
| `anti-patterns` | Binds, whole and unchanged. Entries keyed to an addon artifact simply have no instance; nothing is exempted. |
| `lint`, `testing`, `automated-tests` (**if executable content appears**) | Listed in *Does not apply* above **because there is no Lua today**, and that is a statement about the tree rather than a permanent grant. A repo of this kind that grows a Lua file, a test harness or a script complex enough to have a failure mode **MUST** re-read these three against what it actually has, and record the outcome. The trigger is stated so it cannot be missed: **the first `.lua` file this repo tracks outside a frozen bundle.** A shell script alone does not fire it — the standard mandates no shell linter — but it does oblige the script's own documentation under `documentation-§5`. |

**Substitutes — a documentation-and-tooling repo MUST carry these instead:**

1. A root **`CLAUDE.md`** carrying `## Standards compliance (read first)` or an equivalent *what this repo is* opening. Of `documentation-§6`'s three places a standards reference lives, this is the only one that exists in a repo with no TOC `## X-Standard:` line and no player README badge row.
2. A root **`DEPENDENCIES.md`**, in the honest shape described above.
3. A **`docs/ARCHITECTURE.md`** carrying the five sections named above, including the deviation register.
4. A **`README.md` written for contributors and agents**, naming what the repo is and how it is consumed.

**A note on this repo.** `WowAddonStandards` publishes the standard it is audited against, and the temptation is to treat that as either an exemption or an embarrassment. It is neither. A rule this repo cannot satisfy is evidence about the **rule's scope**, not about the repo — which is precisely how this section came to exist, out of three deviation rows that were each individually reasonable and collectively a sign the standard was missing a repo kind.
