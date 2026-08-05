# Standards Audit — Playbook

**Invoked by `/wow-addon:standards-audit`.** This is the step-by-step spec for auditing **one addon
repo** against the Ka0s WoW Addon Standard. It runs **inside the addon's own repository** and writes
its output there — this `WowAddonStandards` repo holds only the rules and this playbook, never an
addon's audit results.

The rules being audited against are canonical in
[`standards/STANDARDS.md`](standards/STANDARDS.md) (its section files and the `anti-patterns`
list). This playbook says *how to run the audit and where to put the results*; the standard says
*what to check*.

## What an audit is

A **read-only** compliance measurement: it snapshots the addon, measures it against the then-current
standard, catalogs every deviation with evidence, and produces a remediation **plan**. An audit
**never modifies addon code** — remediation is a separate, follow-up engagement that executes the
plan this audit writes.

Each run is a **frozen, point-in-time snapshot**. A new audit never edits an old one — it drops a new
dated folder beside it.

## Output structure

Everything lands under the audited addon's own repo, in a single dated folder under `docs/`:

```
<REPO_ROOT>/docs/audits/<YYYY-MM-DD>/
  01_CURRENT_STATE.md      -- snapshot of the addon against the standard (what it does today)
  02_DEVIATIONS.md         -- gap report: every deviation, each with a stable ID (see below)
  03_EVIDENCE.md           -- compliance evidence, file:line citations backing each finding
  04_TECHNICAL_DESIGN.md   -- remediation design (how to close the gaps)
  05_EXECUTION_PLAN.md     -- ordered remediation steps (what to change, in what order)
```

The folder is **flat** — one addon per repo, so there are no per-addon subfolders. `<YYYY-MM-DD>` is
the run date; if a folder for today already exists, either append to that run or start tomorrow's —
never overwrite a prior run.

### Deviation IDs

Each deviation in `02_DEVIATIONS.md` gets a **stable ID** with a short per-addon prefix (2–3 letters
from the addon name, e.g. `AT-*` for Absorb Tracker, `CM-*` for Consumable Master). IDs are the
shared key between `02_DEVIATIONS.md` and the remediation plans (`04_TECHNICAL_DESIGN.md` /
`05_EXECUTION_PLAN.md`) — **keep them stable across runs**: a deviation that persists keeps its ID.
Assign the addon a prefix on its first audit and reuse it thereafter.

## Steps

1. **Resolve the standard.** Read the canonical rules from `standards/STANDARDS.md` in the
   `WowAddonStandards` repo (the addon's TOC `## X-Standard:` URL points here). Use the current
   version — note it (e.g. "audited against v1.0.0") in `01_CURRENT_STATE.md` so the run is reproducible.
   - **Switch rule sets when the repo has no TOC.** A repo with no `.toc` is a **Ka0s-owned library
     repo** (`standards/ADDONS.md` → *Ka0s-owned library repos*), not an addon. Audit it against
     **library-stack-§7's applicability list** — what applies, what does not, and what substitutes —
     and say in `01_CURRENT_STATE.md` which list you used. Measuring a library against the addon
     sections manufactures findings the standard never meant (`documentation-§1`'s player README,
     `documentation-§3`'s `docs/` trio, `toc-file`, `options-ui`, `slash-commands`, `preview-mode`,
     `savedvariables`, `packaging`), and every one of them is noise.
2. **Create the run folder.** `<REPO_ROOT>/docs/audits/<today>/`. Never edit an existing run's folder.
3. **Snapshot current state** → `01_CURRENT_STATE.md`. Walk the addon section by section (layout,
   TOC, libraries, patterns, settings, slash, debug, tests, performance, packaging, the root doc set
   — `README.md`, the `CLAUDE.md` stub and `DEPENDENCIES.md` (documentation-§1/§2/§7) — and `docs/`)
   and record what it does now, citing files.
   - **Look in the right place for the shared subsystems.** The debug console, the options toolkit,
     the slash dispatcher, the performance harness and the test framework are **not** the addon's
     code — they are `LibKa0s` modules (library-stack-§7). What the addon owns is a **descriptor**
     and a **degradation stub** per module, in its own setup file: `core/CoreSetup.lua`,
     `core/DebugLogSetup.lua`, `settings/OptionsSetup.lua`, the slash descriptor (in the addon's
     slash file), `core/PerfSetup.lua`, and `tests/_kit/` for the harness. Snapshot **those**, not a
     search for a hand-built console.
4. **Measure against every section + anti-pattern.** Go through each section of the standard and the
   `anti-patterns` list. For each MUST/SHOULD it fails or partially meets, record a deviation.
   - **Consuming the library is the compliant state; hand-rolling is the deviation.** An addon that
     builds `NS.DebugLog`, `NS.Helpers`, its dispatcher or its harness from a LibKa0s descriptor is
     **compliant** and **MUST NOT** be flagged for "not implementing" what those sections describe —
     the sections describe behavior the library supplies. The deviation to raise is the opposite one:
     an addon carrying its own console window, widget makers/flow engine, dispatcher/parser or test
     framework, or a locally patched `libs/LibKa0s/` copy, is **anti-pattern #47**. Vendoring only
     part of the library — some files of a multi-file major, or a dependent module without
     `Core.lua` — is **anti-pattern #48**.
   - **Check the vendoring is whole.** `libs/LibKa0s/` is the library repo's whole ship folder and
     the TOC lists its packaged `libs\LibKa0s\LibKa0s.xml` once, in `# Libraries` after Ace3
     (toc-file-§4/§5). A TOC listing individual `LibKa0s` `.lua` files, or a folder missing files the
     ship folder has, is a deviation even when the addon currently works — the majors it does not use
     today are not the ones that will break.
   - **Check the degradation stub covers every member the addon calls.** For each setup file, list
     the members the addon reaches on the library instance (grep the call sites) and confirm the
     library-absent branch answers **all** of them; a stub missing one is not a fallback, it is a
     crash moved to a rarer code path (performance-§1). Two things not to misread as inconsistency:
     (a) the **Options** stub is deliberately **load-completing rather than member-answering** — its
     job is to let the settings page files finish loading (they call members like the shared-media
     value provider inside schema-row literals at file load), so it publishes real-enough load-time
     members and no-ops the rest, and it is **correct** that it does not print an honest line per
     member the way the other stubs do; (b) a stub that deliberately omits a member, with the reason
     written down, is a decision, not a gap — read the comment before raising it.
5. **Catalog deviations** → `02_DEVIATIONS.md`. One row/entry per gap, carrying five things: the **ID**;
   the **section violated**, written as `filename-§N` (documentation-§5/§6 — and by **bare filename**
   for the eleven section files that carry no numbered subsections); the **impact grade**; a **one-line
   description**; and the **fix direction**.

   **Grade by impact, not rule strength.** The grade answers *what can go wrong, and to whom* — never
   *was the word MUST or SHOULD*. A MUST is a statement about how firmly the standard holds a rule; it
   is not a prediction about consequences, and grading the two as if they were the same thing is what
   produces an audit whose High list is mostly documentation.

   | Grade | What earns it |
   |---|---|
   | **High** | Something a **user**, their **SavedVariables**, or their **session** can hit **today**: a crash or Lua error on a reachable path, corrupted or silently dropped saved data, a feature that stops working until `/reload`, a user-visible wrong value, a taint or combat-lockdown failure. |
   | **Medium** | Reachable, but degraded rather than broken — a fallback that is worse than it should be, a wrong or missing message on a path users do reach, a real defect gated behind an uncommon action. |
   | **Low** | Not reachable by a user in the current code: a latent risk, a structural or convention gap, a doc or config file that is wrong. |
   | **Info** | Observation, or a decision recorded elsewhere and confirmed here. |

   A **doc-only or config-only failure is Low or Info even when the rule it fails is a MUST** — and the
   entry **MUST still name that MUST**, so the grade never reads as the rule being optional. A missing
   `## Documented deviations` heading is a MUST failure and it is Low: no user can reach a heading. Say
   both.

   Where a section states its own **applicability condition** or names a **terminal compliant state**
   (architecture-§4, localization-§3, events-frames-taint-§8, performance-§12), check the condition
   **before** grading — an addon outside a rule's scope is compliant, not deviant, and is not an entry
   at all.

   **One root, derived dependents listed under it.** Where several observations follow from a **single
   unadopted subsystem or single upstream cause**, file **one root deviation** and list the rest as
   dependents shaped `derived from <ID>`. Dependents are **excluded from the headline tally** and from
   the MUST count. Without this rule one declined subsystem inflates into a dozen rows, the headline
   number stops meaning anything, and the actual decision — adopt the subsystem or record why not — is
   buried among its consequences.

   A dependent **graduates** to a root of its own when **any** of these holds, and the graduation is
   stated in the entry:
   - the root is **closed or accepted** and the dependent survives it;
   - the dependent is reachable by a user **independently** of the root — it would still be a defect if
     the subsystem were adopted tomorrow;
   - the dependent's own impact grade is **higher** than the root's. A High never hides under a Low.

   Report both numbers, never one: the **headline tally** (roots only) and the **total including
   dependents**. A tally whose basis is not stated is the failure this rule exists to prevent.
6. **Back every finding with evidence** → `03_EVIDENCE.md`. `file:line` citations that prove each
   deviation (and each compliance claim). Don't assert without a citation.
   - **Mechanical checks belong here — run, not reasoned about.** Record the command and its real
     output: `luacheck .`, `lua tests/run.lua`, and — for every **Ka0s-owned** vendored library
     (library-stack-§7) — **`diff -r <LibRepo>/<Lib> <Addon>/libs/<Lib>`**, proving the vendored copy
     has not drifted from its source repo. For `LibKa0s` that is
     **`diff -r <LibKa0sRepo>/LibKa0s <Addon>/libs/LibKa0s`** over the **whole folder** (every module,
     not just the ones the addon calls) plus
     **`diff -r <LibKa0sRepo>/testkit <Addon>/tests/_kit`** for the vendored test harness — which
     lives under `tests/`, never `libs/`, because it must not ship. Both **MUST** be empty. This check
     exists because drift is otherwise **invisible**: the library's suite passes against the library,
     the addon's suite passes against the stale copy, and **both repos stay green** while the two
     diverge (anti-pattern #45). A non-empty diff is the evidence for a #45 deviation; a *missing*
     file on the addon side is the evidence for **#48**. If the sibling library repo is not present on
     the machine, mark the check **not run** and say so — never infer it from the code looking
     reasonable, and never quietly skip it.
   - **The complexity report is measured, not read.** Run the standard's exact invocation from the
     repo root — **`lizard -l lua -x "./libs/*" -x "./tests/_kit/*" .`** — and compare the result
     against the **latest run bundle's `complexity.txt`** and the watch list in
     **`docs/automated-tests/RESULTS.md`** (automated-tests-§1/§4; `docs/complexity.md` was retired in
     v2.19.0 — an addon still carrying one is pre-adoption, and that is the finding). Record the
     **drift**: which functions crossed a `lizard` threshold or which files entered layout-§1's
     1000–1500 LOC band since the latest bundle, and how stale that bundle's stamp dates it. Run the
     invocation **verbatim** — a locally "improved" one produces numbers that cannot be compared with
     the recorded run, which is the whole point of the check. A record whose numbers no longer match
     the code is stale (anti-pattern #51); a hand-edited one is worse, because it reads as measured.
     The checkpoint is **release, not commit**, so a stale record is a finding about the release
     process — never a reason to flag the addon for failing to gate commits on complexity. If
     `lizard` is not installed on the machine, mark the check **not run** and say so — never reason
     the numbers out from reading the code, and never quietly skip it.
   - **Read the watch list as a decision record, not an inventory.** Count the entries whose
     disposition is **Accepted**, and check the previous runs' `RESULTS.md` rows in git history for how
     many consecutive release runs each has carried that disposition. Three or more is a deviation
     (anti-pattern #53): the entry is owed either a fix or a tracked deviation ID. A watch list where
     **every** entry reads "accepted", or one too long to read in a single pass, is the finding
     regardless of any individual entry's merit — that is a backlog wearing a watch list's clothes.
     Note also that `lizard` counts every `and`/`or` short-circuit as a decision, so a high CCN in Lua
     is usually dense **defaulting or guarding** rather than tangled control flow (performance-§10);
     say which it is when reporting a warned function, because the two carry different risk.
   - **A complexity refactor is audited against performance-§11, not just against the number.** Where
     the diff since the last audit contains refactors driven by the watch list, check for the shapes the
     standard forbids: a body dumped into one helper whose name describes nothing a reader would
     recognize (anti-pattern #52), a dispatch or defaults table built **inside** the function rather
     than at module level — a per-call allocation traded for branches, and worse on any per-frame path
     (#43) — an untested function refactored with no characterization test pinning its prior behavior
     (testing-§13), and `t.k = stored.k or D.k` introduced over fields whose stored `false`/`""`/empty
     set is a user choice (savedvariables-§5, anti-pattern #54).
   - **Evidence for a shared-subsystem finding cites the descriptor, not the behavior.** The
     compliance claim for e.g. the debug console is `core/DebugLogSetup.lua:<line>` showing the
     `LibStub("LibKa0s-DebugLog-1.0")` lookup, the descriptor fields, and the stub branch — plus the
     `diff -r` line proving the vendored module is the real one. Do **not** cite the library's own
     source as if it were the addon's implementation, and do not re-audit the library here: it is
     audited in its own repo.
7. **Design the remediation** → `04_TECHNICAL_DESIGN.md`. How to close the gaps: the modules/files to
   touch, the shape of the change, risks, and any ordering constraints. Reference deviation IDs.
8. **Plan the execution** → `05_EXECUTION_PLAN.md`. Ordered, checkable remediation steps grouped into
   sensible sprints, each step tied to its deviation ID(s). This is the hand-off to the separate
   remediation engagement.

## Hard rules

- **Read-only.** The audit produces documents only; it does not change addon code, TOC, or config.
- **Frozen runs.** Never edit a prior `docs/audits/<date>/`; a re-audit is a new dated folder.
- **Sourced findings.** Every deviation cites `file:line` evidence — no unsourced compliance claims.
- **Stable IDs.** A deviation that recurs across runs keeps its ID and prefix.
- **The standard wins.** When this playbook and `standards/STANDARDS.md` disagree on *what* to
  check, the standard is canonical; this playbook governs only *how* the run is structured.
