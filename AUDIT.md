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
     `documentation-§3`'s `docs/` trio **and its whole topic-detail tier model**, `toc-file`,
     `options-ui`, `slash-commands`, `preview-mode`, `savedvariables`, `packaging`), and every one of
     them is noise. A library has no settings canvas and no in-game pipeline, so Tier 1's
     `settings-panel.md` and `data-flow.md` are not missing docs there — they are inapplicable.
2. **Create the run folder.** `<REPO_ROOT>/docs/audits/<today>/`. Never edit an existing run's folder.
3. **Snapshot current state** → `01_CURRENT_STATE.md`. Walk the addon section by section (layout,
   TOC, libraries, patterns, settings, slash, debug, tests, performance, packaging, **`.gitattributes`**
   (`line-endings` — record the pin verbatim, or record that the file is absent), the root doc set
   — `README.md`, the `CLAUDE.md` stub and `DEPENDENCIES.md` (documentation-§1/§2/§7) — and `docs/`)
   and record what it does now, citing files.
   - **Three cheap README/`CLAUDE.md` checks belong in this walk**, because each is a one-line grep
     and each is invisible to every suite: the standard badge is the **bare** `![Standard](…)` and
     not wrapped in a link (documentation-§1 #2); the README carries **no bundled-library inventory**
     — no `## Libraries` / `## Bundled libraries` / `## Libraries and credits` /
     `## Credits and libraries` heading and no library roll-call in the intro prose, with any
     surviving `## Credits` holding external credit only (documentation-§1, anti-pattern #58); and
     the **LibKa0s provenance line is in root `CLAUDE.md`**, not `README.md` (documentation-§2 item 6,
     anti-pattern #59 — see the step-6 `diff -r` evidence).
   - **Look in the right place for the shared subsystems.** The debug console, the options toolkit,
     the slash dispatcher, the performance harness and the test framework are **not** the addon's
     code — they are `LibKa0s` modules (library-stack-§7). What the addon owns is a **descriptor**
     and a **degradation stub** per module, in its own setup file: `core/CoreSetup.lua`,
     `core/DebugLogSetup.lua`, `settings/OptionsSetup.lua`, the slash descriptor (in the addon's
     slash file), `core/PerfSetup.lua`, and `tests/_kit/` for the harness. Snapshot **those**, not a
     search for a hand-built console.
4. **Measure against every section + anti-pattern.** Go through each section of the standard and the
   `anti-patterns` list. For each MUST/SHOULD it fails or partially meets, record a deviation.
   - **Check the documentation shape against documentation-§3's tier model — it is a directory
     listing, so measure it rather than reading prose.** Six checks, and all six are mechanical:
     (a) **Tier 1 present**, under exactly those names — `scope.md`, `module-map.md`, `schema.md`,
     `settings-panel.md`, `data-flow.md`, `common-tasks.md`; a missing one is a MUST failure.
     (b) **Tier 2 accounted for** — for each of `slash-dispatch.md`, `midnight-quirks.md`,
     `compat-layer.md`, `message-bus.md`, `profiles.md`, `debug.md`, `perf-analysis/README.md`, evaluate
     the trigger **against the code** (count `NS.COMMANDS`, count distinct messages, count the shims
     `core/Compat.lua` publishes with documentation-§3's own grep — it is a count now, not a
     judgment) and require either the doc or a *Not applicable* row carrying that trigger.
     An absent doc whose trigger **has** fired is a MUST failure; an absent doc with a fired trigger
     *and* a "Not applicable" row is worse, because the row asserts something false — grade it above
     the bare omission.
     (c) **`## Documentation map` present in `docs/ARCHITECTURE.md`** and covering **every** `.md`
     under `docs/` in exactly one table, with no row pointing at a file that does not exist. Orphans
     and dangling rows are both findings, and this is the check that makes them findable at all.
     The register has **four tables**, in order: Required, Conditional, **Verification and record**,
     Addon-specific (documentation-§3). The fourth is not optional and not a spare tier — it holds
     exactly `testing.md`, `smoke-tests.md`, `test-cases.md`, `performance.md`,
     `automated-tests/README.md` and `automated-tests/RESULTS.md`, six rows in every addon in every
     state, and `perf-analysis/README.md` is **not** among them: it carries a Tier 2 trigger, so it
     registers in `### Conditional` in both of its states. A hub with three tables is the finding;
     a hub whose extra table is this one, under this heading, is compliant, and a note justifying it
     against the old three-table MUST is what gets deleted. **One exception, and it runs both ways:
     `ARCHITECTURE.md`'s own row.** Registering the hub in its own map is a **MAY**, and an audit
     **MUST NOT** file its presence *or* its absence — the two failure modes the register exists to
     catch cannot exist for the file that carries the register, and the collection is split five to
     four over a row that changes nothing.
     (d) **Non-canonical filenames** — `data-model.md`, `saved-variables.md`, `pipeline.md`,
     `capture-pipeline.md`, `override-pipeline.md`, `settings-system.md`, `wow-quirks.md`,
     `slash-commands.md`, `debug-console.md` and the like are Tier 1/2 content under a per-repo name.
     File as **one rolled-up finding** naming each file and its canonical target, not one finding per
     file — the fix is a single `git mv` sweep and per-site enumeration only inflates the tally.
     (e) **Retired docs** — a surviving `file-index.md` or `conventions.md` (retired v2.23.0), a
     surviving `complexity.md` (retired v2.19.0), or a surviving **`docs/perf-runs/`** directory
     (retired v2.29.0). The store is `docs/perf-analysis/`, one frozen `<YYYYMMDD-HHMMSS>/` bundle
     per capture carrying `report.md`, `dump.json` and `ANALYSIS.md`; a directory still named
     `docs/perf-runs/`, and any flat `<YYYY-MM-DD>-ingame-<label>.json` record in it, is a deviation
     against **performance-§8**. File it **once** for the directory, naming the records it holds and
     that each still owes an `ANALYSIS.md` — not one finding per record, since the fix is a single
     migration.
     (f) **Hub shape** — a mandated `ARCHITECTURE.md` section past ~60 lines that has not spilled to
     its canonical topic doc, or a file past ~400 lines. Report the shape and the line count; do
     **not** argue the arithmetic, and do not file a 412-line hub whose sections have all spilled.
   - **Check the line-ending policy by running the commands, not by reading the file
     (`line-endings`).** Five checks, all mechanical, and the last one is the one that fails in
     practice:

     ```sh
     # (a) present at the repo root
     test -f .gitattributes || echo "MISSING — line-endings-§1"

     # (b) the pin matches the repo's KIND. A repo with a .toc, or one shipping a client-bound
     #     libs/ payload, is client-bound and pins CRLF; a repo with neither pins LF. Step 1 already
     #     switches rule sets on the absence of a .toc, so the discriminator is in hand.
     grep -n '^\* text=auto eol=\(crlf\|lf\)$' .gitattributes

     # (c) the *.sh carve-out, mandatory in BOTH kinds (line-endings-§3)
     grep -n '^\*\.sh text eol=lf$' .gitattributes

     # (d) binaries marked (line-endings-§4)
     grep -c ' binary$' .gitattributes

     # (e) does the WORKING TREE actually agree with the declared pin? ONE number.
     git ls-files -z | xargs -0 -I{} sh -c '
       set -- $(git check-attr text eol -- "{}" | sed "s/.*: //")
       [ "$1" = unset ] && exit                      # binary: git converts nothing here
       cr=$(tr -dc "\r" < "{}" | wc -c); lf=$(tr -dc "\n" < "{}" | wc -c)
       case "$2" in crlf) [ "$lf" -gt 0 ] && [ "$cr" -ne "$lf" ] && echo "{}";;
                    lf)   [ "$cr" -gt 0 ] && echo "{}";; esac' 2>/dev/null | wc -l
     ```

     A file carrying **only** the `*.sh` carve-out with no pin above it is **not** compliance — it is
     the near-miss `line-endings-§1` names explicitly, and it reads in review as a repo that has been
     handled. Compare the body against the canonical one for the repo's kind (`line-endings-§5`);
     that check is a diff, not a reading — and it is a diff over the **body**, because since v2.39.0
     a repo vendoring a binary no extension rule can reach **MAY** carry a `line-endings-§5 appendix`
     below it. Run the three lines §5 specifies: `diff` the first *n* lines against the canonical
     file (81 client-bound, 82 non-client), then read what is left. Nothing, or a block whose first
     non-blank line is exactly `# --- line-endings-§5 appendix ---`, is **compliant** and files
     nothing — neither a §5 finding nor a register row, and a row written for one before the rule
     existed is retired by bringing the block into that shape. Anything else in the tail, or an entry
     spliced into the body where it reads best, is the finding: the second moves every line after it
     and turns a one-hunk diff into a file nobody can compare. **Report (e) as ONE rolled-up finding** — *"N tracked files
     disagree with the declared pin"* — carrying the command above so the number can be reproduced,
     and **never** enumerate the files: the fix is a single `git add --renormalize .` plus a
     re-checkout, and a per-file tally inflates the count for one action. A correct `.gitattributes`
     over an unrenormalized tree is the failure (e) exists to catch, and it was **measured in four of
     the eleven repos** when the check was last corrected (`line-endings-§1`), so (e) earns its place.
     Grade by impact per step 5 — config-and-hygiene, so **Low** or **Info** — while still naming the
     MUST it fails. **Expect this count to be far lower than a pre-v2.28.1 audit bundle reported for
     the same repo**: the old command counted every binary and every JSON file as a stray. A frozen
     bundle is never edited, so say so in the finding rather than letting the two numbers sit
     unexplained side by side. **And check that (e) has an owner in the repo**: `line-endings-§7`
     MUSTs the vendored gate `tests/_kit/test_eol.lua` (LibKa0s test-kit revision 15), which asks
     this same question over the whole tracked set on every run of the suite. A repo whose kit
     predates 15 has no gate and (e) is the audit's alone; a repo that has the gate, reports green
     and still fails (e) here is a **gate** finding, not a file finding, and it outranks the strays
     it missed.
   - **Check the package ignore list by listing the repo's dot-entries, not by reading `.pkgmeta`
     (`packaging`).** Two mechanical checks, and the second is the one that has been missed:

     ```sh
     # (a) the named dev-only entries are ignored
     for e in .luacheckrc .pkgmeta .gitignore .gitattributes .claude .superpowers docs tests _dev; do
       grep -q "^  - $e\b" .pkgmeta || echo "NOT IGNORED — $e"
     done

     # (b) EVERY root dot-entry present in the repo is accounted for. The enumeration in (a) goes
     #     stale the moment a new tool writes a new dot-directory; this one cannot.
     for e in .[!.]*; do
       [ -e "$e" ] || continue
       grep -q "^  - $e\b" .pkgmeta || echo "UNACCOUNTED — $e"
     done
     ```

     `.git` is the one entry the packager never sees and never needs a row; everything else that (b)
     prints is either an ignore-list line the repo owes or a justification comment beside it. File
     **one** finding carrying the full list rather than one per entry — the fix is a handful of
     lines in a single file. The consequence is player-facing and concrete: a multi-file agent
     tooling directory inside the packaged AddOn, which is what (b) was added for after five addons
     shipped one and prose alone had already failed to stop it.
   - **Check the TOC's position annotations (`toc-file-§5`).** In the `# Core` block, every line
     whose position is **load-bearing** — a library major taken as an upvalue at file scope, a
     constant resolved from an earlier seam at file load — **MUST** carry a comment at the line
     naming what resolves. Read the seam files (`*Setup.lua`) and `core/Constants.lua` to establish
     which positions actually are load-bearing rather than trusting the comments to be complete; an
     unannotated load-bearing line is the MUST failure, and a load-bearing line annotated only as
     *"order matters"* without naming what resolves is the same failure in weaker form. A TOC that
     annotates its load-bearing lines but never marks a **conventional** position fails the SHOULD,
     not the MUST — grade it accordingly. Do **not** file the within-`core/` sequence itself as a
     deviation: dependency-correct order with its load-bearing positions declared is compliant,
     whatever the sequence (`layout-§1`).
   - **`X-Curse-Project-ID` on an unpublished addon is not a deviation (`toc-file-§1`).** If the
     field is absent and the TOC carries a comment in its position saying the addon is not published
     yet, that is **compliant** — record it as such and file nothing. A placeholder, invented, or
     borrowed id **is** a finding, and a serious one: the packager uploads to whatever project the
     id names. An absence with no comment is the SHOULD failure only.
   - **Read the deviation register before filing anything.** `docs/ARCHITECTURE.md`'s
     `## Documented deviations` is the **single** home of a ratified decision (documentation-§3), and
     `audit-review-history` binds this run **three** times, and the first two point in opposite
     directions on purpose. A gap matching a register row is recorded as **accepted, citing that
     row's rule and Decided date** — never re-filed as an open MUST failure, or the same ratified
     decline returns every cycle. Any row whose **cited rule the standard has since changed** is
     reported, so the register cannot quietly accumulate entries for behavior the standard now
     mandates. And **every row's re-check trigger is evaluated against the tree in front of you, and
     every evidence id the row cites is resolved** — the audit deviation id to a bundle under
     `docs/audits/`, the review finding id to one under `docs/reviews/`, the issue number to this
     repo's own issue store. A trigger that has **already fired** ended the deviation on the day it
     came true and the row is now asserting a live deviation that is not one; an id that resolves to
     nothing reads as evidence and leads to none. Both are as mechanical as the rule check above, and
     they catch the case it cannot: a row whose rule still exists, still says what the row claims,
     and stopped being true months ago. A reasoning trail in a issue-audit issue or an
     earlier bundle is not a substitute: a deviation with no register row is not ratified, and a
     `state:will-not-do` issue with no row is itself a finding.
   - **`docs/pending/LEDGER.md` is retired and its presence is a finding.** The durable store of
     issue-audit decisions is **GitHub issues on this addon's own repo**, status carried as a
     `state:done` / `state:will-not-do` (closed) / `state:triaged` / `state:untriaged` (open)
     **label**, alongside a `severity:` label — `audit-review-history`. A surviving `LEDGER.md`, or a
     `docs/pending/` directory holding one, is reported with the deferrals it still holds, since
     those are the rows that owe an open `state:triaged` issue; `done` and `wont-do` rows are
     terminal and migrate nowhere. Read issues with the **`gh` CLI subcommands**
     (`gh issue list --json number,title,state,labels` and a `--label` filter) — **never**
     `gh api graphql`. **A surviving `[status]` title prefix is its own finding** (anti-pattern #62):
     the labels are the store and the prefix is a stale second copy of it. An issue carrying no
     `state:` label at all is the ordinary stray the write commands repair, not a deviation.
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
   - **Check the shared media is used, not duplicated** (library-stack-§8, layout-§3). The payload is
     whole-folder, so `libs/LibKa0s/media/` is present in **every** addon whether or not it wires
     `LibKa0s-Media-1.0` — which makes both halves of this check mechanical:
     - **A private copy is a deviation** (anti-pattern #63). List the addon's own `media/` tree: a
       `fonts/`, `icons/` or `textures/` entry that also exists under `libs/LibKa0s/media/` is a
       second copy, and the monospace face is the usual one because it predates the library payload.
       What legitimately remains is the logo and the screenshots.
     - **A one-off mark where the catalog has one is the commoner deviation.** Grep the addon's own
       source for `SetText` on a control (`"X"`, `"\226\156\150"`, `"Copy"`, `"Clear"`), for
       `SetAtlas`, and for texture paths under `Interface\` that are not the shared payload; cross
       them against the module's `ICONS` catalog. Cite `file:line` and name the catalog entry that
       should have been used.
     - **Check the seam exists and is fed the folder name.** `core/MediaSetup.lua` (or wherever the
       addon wires it) passes the addon's own first vararg, loads **before** any file resolving a
       shipped path at load time, and makes one `RegisterLSM` call. A value that merely *happens* to
       equal the folder name — a frame-name prefix, a hand-typed constant, the DebugLog descriptor's
       `name` field — is a deviation even where it currently produces the right string.
     - **Check the console was told.** The `LibKa0s-DebugLog-1.0` descriptor carries `addonName`
       (debug-logging-§13). A console whose copy and clear draw marks while its close draws `×` is
       anti-pattern #64 in the wrapper beneath it, not a host defect — check the vendored payload's
       version before writing it up against the addon.
     - **Run the close-button grep. This is a MUST and it is mechanical:**

       ```sh
       grep -rn 'MakeCloseButton(' --include='*.lua' . | grep -v '/libs/' | grep -v '/tests/'
       ```

       Every line must be either the **one** wrapper definition in the addon's `LibKa0s-Core-1.0`
       setup file (`NS.MakeCloseButton = function(parent, onClick) return lib.MakeCloseButton(parent,
       onClick, addonName) end`), its degraded twin, a **call to that wrapper**, or — under a decline
       ratified in the register — the **one host factory** and calls to it. Anything else is
       a deviation: a direct `lib.MakeCloseButton(...)`, a `Core.MakeCloseButton(...)`, or — the
       measured shape — `NS.DebugLog.MakeCloseButton(frame, api.Hide)` inside a perf-panel decoration
       hook, which reaches the same three-argument function and supplies no name
       (standalone-windows, debug-logging-§12, performance-§4, anti-pattern #65).

       **Check for a decline ratified in the register before you write the row.**
       standalone-windows makes a reasoned decline of the wrapper a **terminal** compliant
       state on four conditions: the host's own windows only (never the console, its copy
       window or the perf panel), the same catalog `close` mark resolved through `NS.Icon`,
       exactly one host factory with every title bar reaching it, and a row in
       `docs/ARCHITECTURE.md` naming the section, the date and a re-check trigger. All four
       hold — file nothing, and record in `01_CURRENT_STATE` that the decline was checked
       against them. The first three hold and the row is missing — the deviation is the
       **missing register row** (`audit-review-history`), **not** a MUST breach against each
       title bar, and its cure is one row rather than a set of rewritten close controls a
       player would watch change for nothing. The measured case is BankLedger: three host title bars
       behind `modules/Browser.lua:98`, and a fourth close control on a copy window the library
       draws, which is the library's under condition 1 and not part of the decline.

       **File it on the grep, not on a screenshot.** The omission draws a perfectly good button and
       raises nothing, so it is invisible to lint, to the suite and to a smoke test that only checks
       the window opens. Severity is at least **medium**: it is a visible cross-window inconsistency
       in the surface a user compares between addons. If the addon carries **no** wrapper at all but
       builds close controls, the deviation is the missing wrapper, and every call site is evidence
       for it rather than a separate row — unless the four conditions above are met, in which case the
       decline is compliant and the only possible row is the register's.
     - **Check the perf panel's decoration hook earns its place.** From `PerfPanel.lua` minor 4
       (LibKa0s v1.10.2) the library draws the panel's close control with the host's own name, so a
       `decorate` hook whose entire body is a close button is a second copy of library behavior that
       can fall behind it — and did. Report it as a **low**-severity simplification: delete the hook.
       A hook drawing chrome the library does not draw is not a deviation.
     - **Not a deviation:** an addon on a LibKa0s tag older than v1.9.0 has no catalog to draw from.
       Say which tag it carries (root `CLAUDE.md`'s provenance line) and file the adoption as a
       re-vendor item rather than as a styling gap.
   - **Check the write paths against `architecture-§5` by grep, then classify every hit.** Grep the
     addon's own Lua (never `libs/` or `tests/_kit/`) for assignments into the stored tree —
     `db.profile`, `db.global`, `db.char` and the local aliases the files bind them to — and for
     `table.insert`, `table.remove` and `wipe` on stored tables. Every hit outside the write helper is
     exactly one of five things, and the class decides the finding:
     (a) a **schema-row write** — a fixed or instance-relative path a row addresses, whole-section
     writes included, and a field that is also a key included — is a MUST failure wherever it sits,
     **inside a registry writer included**;
     (b) a **structural registry write** — the collection passes all three of architecture-§5's tests,
     and the write is membership or an item on its closed identity-and-bookkeeping list (order, id
     counter, storage key, stamped id, frame name, a lookup-key name no row addresses, the seeding
     sentinel) — is compliant only inside the one writer `docs/ARCHITECTURE.md` names for that
     registry; a hit in a panel file or a slash handler is filed against the writer (anti-pattern #78),
     never as a demand that membership route through the helper. A collection the helper already takes
     whole at one normalized path fails test (3); it is a value, its writes are helper writes, and it
     files nothing;
     (c) the **load pass** is compliant when its entry points (the runner, the profile-prepare function)
     are reachable only from initialization and the AceDB profile callbacks and are named beside the
     writer; a slash verb or panel control that calls an entry point is a finding, while the writer's
     own reset verb calling a seed routine the load pass shares is not;
     (d) **wholesale replacement** by the options-ui-§12 global reset or AceDB's profile swap / copy is
     compliant and files nothing;
     (e) anything else — window geometry (a drag-written position on a registry member included), a
     remembered view, a preference the player sets on a member that no row addresses — needs its `Documented deviations` row, as it did before v2.43.0; a member
     preference with neither a row nor a register row is a missing row.
     Apply architecture-§5's three tests before filing (b): a list over a fixed member set the player
     only reorders is a **value**, and belongs to (a) or (e). A registry with **no named writer** is a
     doc-only MUST failure, Low. A register row whose only content is a named registry bypassing the
     helper is **stale** since v2.43.0 — file its retirement as compliant under the register's second
     MUST (audit-review-history), because the cited rule has changed, and under the third as well where
     the row's own trigger names WowAddonStandards#7; not the registry.
   - **Check the settings panel's CONTENT against `options-ui`, from the schema rather than from the
     screen.** Nine checks. Each is a read of the schema array or a grep, none needs judgment, and
     all nine are invisible to lint and to the headless suite — which is how every one of them
     shipped. Do them in this order; the first changes what the rest are counting.
     - **(a) Every page draws a tab strip (options-ui-§13).** List the addon's settings pages and,
       per page, the distinct `group` values in declaration order. A page with **no** `group` values,
       or whose builder calls the untabbed renderer, is a MUST failure — **including** a page with
       exactly one section, which draws a one-tab strip. The exempt pages are those the host does
       not render through the flow engine, and today that is **two** of them, both exempt: the
       AceConfig-drawn **Profiles** sub-page, and the **landing page**, whose body is the host's own
       `buildMain` (options-ui-§5) — a logo, a tagline and one Label per `COMMANDS` row, declaring no
       `group` at all. Neither is a finding, and the landing page in particular is **mandated** in
       that shape: do not file its missing strip. Read the renderer as well as the pages: a fallback
       to the untabbed form below some
       tab count is the finding even on a page that currently has enough tabs to dodge it, and so is
       an early return that skips the strip for some state (an empty list, a mirrored or linked
       unit). Report the **page → tab list**, before and after, as the evidence.
     - **(b) The General page's first tab is exactly `Master controls` (options-ui-§15).** Compare
       the first distinct `group` on the General page against that literal string. Then read the rows
       filed under it, in declaration order, against the canonical set — enable, general visibility,
       master scale, master alpha, lock frame, debug console, reset position, reset all settings.
       They **MUST** be a subsequence of that list, and every canonical row the addon has the state
       for **MUST** be present. A canonical row sitting under a different tab is a finding against
       **§15**, not against the tab it is in. An addon that draws no positionable frame — proven by a
       whole-repo `SetMovable` sweep, not assumed — legitimately omits exactly master scale, master
       alpha, lock frame and reset position; record that as compliant and file nothing.
       **Then ask for the migration.** `General visibility` is a four-value dropdown, and an addon
       that shipped a *show only in combat* **boolean** at that path has changed the stored type. A
       row whose type changed with **no** bumped `schemaVersion` and **no** migration step in
       `Database.lua`'s runner (savedvariables) is a finding in its own right, graded at least
       **medium**: the panel reads a stored `true` as an unrecognized dropdown value on every
       existing install, so the addon silently loses a setting the player already made. The
       migration is `true` → `inCombat`, `false` → `always`. Cite the runner's `file:line` and the
       version it bumped to as the evidence that it exists; adopting the *name* `Master controls`
       moved a `group` and needs no migration, and the two must not be confused for each other.
     - **(c) Every color row has its class-color companion beside it (options-ui-§17).** Grep the
       schema for color rows and, for each, require its companion — a `Use class color` bool or a
       color-mode dropdown whose values include `class` — as the **next** row in declaration order,
       so it lands in the right-hand column. Then check the declaration: both rows carry
       `classColorSource`, and its value is checked against what the drawing code actually means
       (cite the `file:line` where the render path decides whose class it reads — a control stored
       under a per-unit path that draws the player's own spells is `player`). Finally read the
       resolver: one function, the stored alpha used under both modes, and an unresolvable class
       falling through to the stored swatch. A literal gray or white fallback is at least **medium**
       — it is user-visible and reads exactly like the setting not working. Palette-definition
       swatches (one color per statistic, per rarity, per category) are exempt and are the only
       exemption.
     - **(d) No `disabledIf` on a color row (options-ui-§17).** One grep over the schema files. Every
       hit is a finding, because the row is still read for its alpha, so graying it tells the player
       something untrue.
     - **(e) Ordering is a drag (options-ui-§18).** One grep for the paired chat-scroll arrow art in
       a settings file:

       ```sh
       grep -rn 'ScrollUp-Up\|ScrollDown-Up' --include='*.lua' settings/ | grep -v '/libs/'
       ```

       Any hit over a stored array is a finding, and so is a `MoveUp`/`MoveDown`-shaped handler or a
       numeric position field. Where the shared reorder list **is** used, check the split instead: a
       consumer drawing its own row fill, border or handle, a control placed left of the handle, a
       list of unequal row heights, or a drag that can cross a fixed section boundary is the finding.
     - **(f) No hand-written font, border or bar group (options-ui-§16).** Grep the settings files for
       the shared-media dropdown controls (`LSM30_Font`, `LSM30_Border`, `LSM30_Statusbar`): on an
       addon whose vendored library carries the composers, the grep is a **finder, not the
       finding**: a hit is a deviation when the rows around it **reproduce a mandated block**,
       which is what its *companions* tell you — a font copy carries size, flags, shadow or the
       color pair, a border copy carries thickness and color, a bar copy carries opacity and
       color. A media row standing alone with **none** of its block's companions is not a
       hand-written group, and the addon-wide **broadcast meta row** — one *All surfaces* control
       whose `onChange` fans out over the composed groups — is the named exempt shape
       (options-ui-§16). Audit it against §16's five bounds instead: one row per media kind, its
       own scope-naming subgroup and label, a write through the single seam into paths that are
       themselves composed, no companions of its own, and per-surface composed groups behind it.
       Then read each real group's rows in declaration order against the canonical order. Two
       shapes, graded differently: a **reordered** group is low (convention), a **missing** mandated
       row — no border thickness, no bar opacity — is at least low and is reported with the
       **literal it should have replaced**, cited at the render path's `file:line`, because that
       number is the thing a player can see and cannot reach. While in the same files, check that a
       tab mixing control types carries a `subgroup` heading per group, and that no hand-rolled
       colored `Label` is standing in for the shared `Heading`.
     - **(g) One chrome block above the strip, and it is not boxed twice (options-ui-§14).** Per
       page, list what the builder draws into the chrome band and what it declares as schema rows.
       Then the mechanical test: **a page-wide control declared inside a `group` is in the scroll,
       and is the finding — unless that group is the page's FIRST tab and is named `General`.**
       Page-wide means it applies to every tab — the page's picker for the instance it edits, and
       the acts that apply to that instance whole: create, enable, unlock, copy, reset, delete.
       Report it with the tab it currently hides under, because a control that vanishes when the
       player clicks a different tab is what they actually see.

       **The `General` first tab is compliant, and has three conditions to check rather than one**
       (options-ui-§14, v2.40.0). A page whose acts would not fit beside the picker on one band row
       MAY draw them there instead, so verify: the band still carries the **picker** (and the create
       control, where the page has one); the `General` tab is **first**, because the escape rests
       entirely on the page opening there; and **no page-wide control is drawn on any other tab**,
       since acts split across the band and a tab are worse than either shape alone. A `General` tab
       that is not first, or a band left as a bare divider because the picker moved into it, is the
       finding. Do not file the tab itself — that was the rule until v2.40.0 and it was wrong about
       a page carrying six acts. Two findings share
       this check: a page drawing **two** chrome blocks (a banner plus a separate control band — the
       picker belongs *inside* the one block), and a **second box** around the band's contents. The
       second is one grep over the same builder: an `InlineGroup`, a backdropped `SimpleGroup`, or a
       hand-drawn border wrapping the band's controls is **anti-pattern #72** — the band is already
       delimited by its divider and the content panel's top edge. Delete the box, keep the controls.
     - **(h) A wrapped strip's geometry does not move with the selection (options-ui-§13).** Two
       reads, no live client needed. First, in the vendored library, find the number the strip packs
       its **wrapped rows** by and confirm it is taken from the **unselected** state and cached once
       — a pitch read off "whichever tab was drawn first", or off the selected tab's art, font or
       backdrop, is the finding whether or not this addon currently has a page that wraps, because
       it becomes visible the day a label is added. Note that the row pitch and `TAB_H` are two
       different quantities (options-ui-§8) and that reading the band off `TAB_H` alone is not the
       same defect. Second, the suite: a case asserting the reserved band **and every row's y
       offset** are identical for every value of the selection. Check what it runs against — a
       harness that answers **one** height for every atlas cannot fail the case, so it is green
       against nothing and is reported as a **missing** case, not a passing one (testing-§12). Name
       the mutation the case dies under.
     - **(i) A secondary strip lives in the scroll, and there is no third level (options-ui-§13).**
       Where a page divides one primary tab's content with a second strip, confirm three things from
       the builder: it is drawn as ordinary page content rather than pinned into the chrome band;
       its selection is kept **per primary tab** so returning to a category returns to the subject
       you were on; and that selection is session state, never written to the profile — a stored
       secondary selection is a finding against the same rule that forbids storing the primary one.
       Then check no third level exists, in either of its two shapes: a strip nested inside a
       secondary tab, and a `subgroup` heading used to fake one, which is a finding against
       options-ui-§7's rule that a subsection wanting its own tab should be given one.
     - **Not a deviation:** an addon on a LibKa0s tag that predates the composers, the reorder
       widget or the mandatory strip has nothing to adopt yet. Say which tag it carries (root
       `CLAUDE.md`'s provenance line) and file the adoption as a re-vendor item rather than as a
       panel deviation.
     - **File the strip and the tab rules as one root with dependents** (step 5's rule). An addon
       that has not adopted the tabbed page at all fails (a), (b), the heading half of (f), and
       (g), (h) and (i) — which have nothing to attach to on a page with no strip — as consequences
       of one decision; six roots would sextuple a single finding. The dependents are still listed
       under the root, because the remediation order is theirs.
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
     lives under `tests/`, never `libs/`, because it must not ship. Both **MUST** be empty. Diff
     against the **tag the addon's root `CLAUDE.md` names** — the provenance line
     `Bundles [LibKa0s](…) vX.Y.Z (MIT).` (documentation-§2 item 6) — which is the same ref the repo's
     own vendored-payload gate resolves. **The line missing from `CLAUDE.md`, or still sitting in
     `README.md`, is itself a finding** (anti-pattern #59): since LibKa0s v1.8.1 / testkit revision 9
     `tests/_kit/vendor_sync.lua` reads `CLAUDE.md` with no fallback, so that repo's gate is red. This check
     exists because drift is otherwise **invisible**: the library's suite passes against the library,
     the addon's suite passes against the stale copy, and **both repos stay green** while the two
     diverge (anti-pattern #45). A non-empty diff is the evidence for a #45 deviation; a *missing*
     file on the addon side is the evidence for **#48**. If the sibling library repo is not present on
     the machine, mark the check **not run** and say so — never infer it from the code looking
     reasonable, and never quietly skip it.
   - **Read the `.luacheckrc` before you quote the `0/0`: since v2.39.0 the test tree is in scope
     (`lint`).** A `0 warnings / 0 errors` line says nothing until you know what it was run
     over. `exclude_files` **MUST** narrow to `tests/_kit/` — the vendored kit, linted in its own
     repo — and nothing wider; a config still excluding bare `tests/` is the finding, and it is the
     finding even where the run is green, since across the collection that exclusion was hiding 308
     test files against 329 source files. The harness global belongs in a `files["tests/"]` stanza
     and **MUST NOT** sit in top-level `read_globals`, where it is a permission the addon's own
     shipped source can reach for. And a tree turned on behind a blanket `ignore` is worse than the
     exclusion it replaced: report the ignore list with the count it suppresses.
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
