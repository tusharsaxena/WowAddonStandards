> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Automated tests & local build toolchain

Every addon **MUST** ship an automated, **headless** test harness and be developed **test-first (TDD)**. The harness itself is **not** per-addon code: the registry, the assertions, the source loader and the WoW-API mock are a **shared kit** the addon vendors, so a fix to the mock reaches every addon in the collection instead of being re-derived eight times with eight different bugs.

**Adoption strength.** **MUST** for the **wiring** — vendor the kit, extend the base mock rather than replace it, derive the runner's load list from the TOC, keep the green commit gate, ship the generated inventory. **SHOULD** for **breadth** — how much of an addon is covered headlessly is genuinely addon-specific. MUST on the wiring is what makes `lua tests/run.lua` and `lua tests/run.lua --list` mean the same thing in every Ka0s repo, and what makes a kit-level fix a re-vendor rather than a migration.

### 1. The shared test kit and the harness shape

The harness is a **Ka0s-owned shared kit**, not per-addon code. Addons **MUST NOT** hand-roll their own registry, assertion set, source loader, or base mock (anti-patterns #47).

- **MUST** vendor the whole of the LibKa0s repo's root-level **`testkit/`** folder to **`tests/_kit/`** — it is a *sibling* of the `LibKa0s/` ship folder, not inside it (library-stack-§7), so there is no `LibKa0s/testkit/` to copy from and nothing lands under `libs/` — `framework.lua` (the test registry, the assertions, the runner, the `--list` renderer), `loader.lua` (the sandboxed source loader and the TOC reader), and `mock_base.lua` (the universal WoW + Ace mock builder). Copy the folder, not the files you think you need (anti-patterns #48).
- **MUST NOT** vendor it to `libs/`. `libs/` is the **ship payload** inside `#@no-lib-strip@` — anything there gets zipped into the release, and a test harness in a player's AddOns folder is dead weight at best. Under `tests/` the **existing** `- tests` entry in every addon's `.pkgmeta` (packaging) already excludes it, so adopting the kit needs **no packaging change** and leaves no new ignore rule for the next scaffold to forget.
- **MUST NOT** edit `tests/_kit/` in a consumer. A kit problem is a finding to fix in the library repo and re-vendor; a local patch is a fork nobody knows about (library-stack-§5), and the next re-vendor silently reverts it. The byte-identity gate in §11 is what enforces this.
- The kit is **not a LibStub major**. It carries no `MAJOR`/`MINOR`, registers nothing, and is never loaded by the client, so the per-file-minor rule (library-stack-§7) does not apply to it and an audit **MUST NOT** flag the missing version registry.

```
tests/
  _kit/              -- vendored, never edited: framework.lua, loader.lua, mock_base.lua, README.md
  run.lua            -- this addon's runner: the load list, the lifecycle kick, the suite list
  wow_mock.lua       -- this addon's thin extender over mock_base
  test_<module>.lua  -- one suite per module (test_schema.lua, test_database.lua, ...)
  test_<rule-subject>.lua
                     -- one suite per standard rule this repo gates (test_surface_parity.lua, ...)
```

- **A suite whose subject is a rule rather than a module is named for the rule**, `test_<rule-subject>.lua`, and **the section that mandates it names the file**. The standard already does this at `tests/test_disabled.lua` (slash-commands-§7) and `tests/test_kitsync.lua` (§11); `tests/test_surface_parity.lua` (§8) and `tests/test_vendor_sync.lua` (§11) are named for the same reason. The filename is normative rather than habitual because an auditor grading one rule across eleven repos otherwise has to find the suite before grading it, and a repo that renames it fails nothing. Unanimous practice was already here — all eleven addons ship both files under exactly these names, and each opens with a header naming itself — so this writes down what the collection does rather than asking it to move.
- **`tests/run.lua`** **MUST** keep only what is genuinely this addon's. It `dofile`s the kit's `framework.lua` and `loader.lua`, builds the environment once by loading the vendored library files and then the addon's own files (§9), mirrors the in-game lifecycle (`NS:InitDB()`, and the settings-panel build if the addon has one, so the schema-to-widget layer is exercised as the client exercises it rather than through hand-called fictions), publishes the shared table via `Kit.expose`, and hands the ordered suite list to `Kit.run{ dir = "tests/", suites = { ... } }`. `Kit.run` exits **0** on success and **1** on any failure, so the green gate is a plain shell check.
- **`Kit.expose`** merges `test` and the assertions (`fail`, `assertEqual`, `assertTrue`, `assertFalse`, `assertNil`, `assertNear`, `assertError`) into the table you pass, so each repo keeps its own global name — `AT_TEST`, `LK_TEST`, … — and its own extra keys. Adopting the kit therefore requires **no change to any existing suite file**, which is what made adoption one commit per repo rather than a rewrite.
- **`loader.lua`** loads each source with `loadfile`, `setfenv`s it into an environment whose `__index` resolves WoW globals to the mock table first and falls back to `_G`, and calls the chunk as `chunk(addonName, NS)` when `Loader.addonName` is set — reproducing the client's `local addonName, NS = ...` header. Library chunks take no arguments, so a library-only repo leaves `addonName` nil. Its `__newindex` **writes through to `_G`**, deliberately: without that, a sandboxed write to a SavedVariables global or a `StaticPopupDialogs` registration is silently lost and the migration paths become untestable.
- **`tests/wow_mock.lua`** **MUST** be a **thin extender** over `mock_base.lua`, not a replacement: `local base = dofile("tests/_kit/mock_base.lua")`, then a builder that calls `base()` and overwrites the handful of keys this addon needs. Plain per-key overwrite — the base returns a fresh table per call, so there is no merge machinery to reason about. Use `M.__stubFrame()` for extra frame-shaped objects and `M.__libs` to register additional library fakes without reaching through LibStub's closure.
- Suites stay plain: `local T = _G.<ADDON>_TEST; local test, assertEqual = T.test, T.assertEqual` then `test("...", function() assertEqual(...) end)`.

**Mock fidelity (MUST).** The kit's `README.md` carries the fidelity rules in full; each exists because a friendlier mock already hid a real bug. An addon's extender **MUST** hold to the same five: a stub that silently succeeds is worse than no stub when production code branches on its return value; getters used in arithmetic or concatenation return real numbers and strings; anything a test needs to **observe** is recorded rather than no-opped (a no-op `RegisterUnitEvent` lets a widened or dropped per-unit event filter pass the entire suite); anything a test needs to **drive** is fireable; and the awkward real behavior is modeled rather than the convenient one (AceDB's in-place `copyDefaults`, AceConsole's `Embed` clobbering a same-named custom `Print`).

**Registration is not execution.** The kit **collects** every case and runs nothing until `Kit.run`. A runner that executes a case body at registration time and short-circuits it in list mode makes `--list` a second code path through the same file, and the inventory can then disagree with the run. An addon **MUST NOT** reintroduce that shape; `--list` is a pure filter over the registry and cannot drift from what actually runs.

**A gate closes a class of deviation only when it reads the whole of its own denominator.** Every gate the kit ships — and every gate a section below mandates — **MUST** state its scope, and that scope **MUST** be the whole set the gate's own rule is about, **enumerated from the tree** rather than hand-listed in the suite, minus the carve-outs the rule itself names. What that set *is* varies by rule, and the MUST is about never typing it out. A gate asserting a property of **the repository's files** takes the whole `git ls-files` set — the EOL gate (line-endings-§7) and the prose gate (localization-§5) both do. A gate whose rule is about a **named payload folder** takes that folder, and reads it **whole**: §11's kit-sync gate compares the source `testkit/` against the vendored `tests/_kit/`, and its consumer-side half compares `libs/<Lib>/` against the sibling checkout's ship folder — each by listing both directories and comparing the **sets**, never the files someone remembered. A gate whose rule is about an **adopted surface** takes the surface: §8's stub-surface parity case is scoped to the LibKa0s modules this addon adopts, which is exactly why its member list **MUST** come from a named `grep` rather than from reading. Anything narrower than the rule's own denominator reports green on the part it read and says nothing about the rest, while the run's pass line and the repo's inventory both read as coverage.

The collection has the controlled experiment: on 2026-09-08 the line-ending class went to zero in all ten repos that had strays the cycle before, three of them naming `tests/_kit/test_eol.lua` as the owner, because that gate asks `git check-attr` about every tracked path (line-endings-§7). On the same date, with the same kind of vendored gate, the British-spelling class did **not** close — the library repo's `tests/test_prose.lua:19` fixes its scope to two hand-written directory names and does not recurse, leaving 216 live hits invisible to a green suite, and a second repo's copy carried a private word list where the standard publishes a canonical one. The difference was not gate-versus-prose, and it was not `git ls-files` versus anything else: one gate derived its denominator from the tree and the other typed it in.

### 2. Commands

- **Run unit tests:** `lua tests/run.lua` from the repo root (exits non-zero on failure).
- **Lint:** `luacheck .` — **0 errors** (config in `.luacheckrc`, lint).
- **Syntax-check one file:** `luac -p path/to/file.lua`.

Every command here, and in the kit's own vendoring instructions, assumes the **repo root** as the working directory. Two documents giving the same command from two different working directories is a bug in the documents.

### 3. Local toolchain

WoW runs **Lua 5.1**, so the kit and every suite target 5.1. Install locally:

```sh
sudo apt-get update && sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck
```

There is no LuaFileSystem dependency and there **SHOULD NOT** be one: the kit's directory-listing needs are met by shelling out, so a fresh checkout tests with nothing but `lua5.1`.

### 4. TDD & the commit gate

- **MUST** be test-first: write or extend a **failing** test that pins the intended behavior, then implement until it passes.
- **MUST**, before **every** commit, run **`lua tests/run.lua`** (all suites green) **and** **`luacheck .`** (0 errors). A commit with red tests or lint errors is forbidden. The vendored runner's `--suite lint --suite tests --no-bundle` is exactly this pair and writes nothing, so it may be used for the gate; the **full** four-suite bundle is a release artifact and **MUST NOT** gate a commit (automated-tests-§3/§6).
- **MUST** add/extend a suite whenever a behavior changes — no logic change lands without a covering test.
- Pure/testable logic (schema validation, data collection, attribution, migrations, formatting) **MUST** be exercised headlessly. Genuinely in-client behavior (frame rendering, taint) is covered by the in-game smoke tests (audit-review-history), which complement — not replace — the unit suites.

### 5. Test-case inventory & coverage badge

Two visible-coverage artifacts make the suite's health legible; both are **local and
hand-runnable — no CI is required or expected**.

- **MUST** ship **`docs/test-cases.md`** — a **generated** full enumeration of every test case,
  grouped by suite, with per-suite and grand totals. It **MUST** be produced by the kit's
  non-executing `--list` mode (`lua tests/run.lua --list > docs/test-cases.md`), **not** hand-authored,
  and it is the addon's **authoritative pass count**. The renderer groups the registered cases by the
  `test_*.lua` suite they came from, in **declared suite order** rather than sorted, so the inventory
  reads the way the run reads.
- **MUST** surface a **test-pass badge** in the README badge row (documentation-§1) showing
  **X/Y passing** (passed / total) as a **static** shields.io badge — the canonical template
  (documentation-§1 #5) is `![Tests](https://img.shields.io/badge/Tests-<X>%2F<Y>_passing-green)`
  (label `Tests`, color `green`, `%2F`-encoded slash). **MUST NOT** require CI, a
  dynamic/endpoint badge, or a GitHub Action to produce it.
- **MUST** keep both in lockstep with the suite: whenever a case is added, removed, or renamed, or
  the pass count moves — i.e. **whenever a failing test is resolved** — regenerate `docs/test-cases.md`
  and update the README badge **as part of the same change**, never as a deferred follow-up.
- Both figures count **passes**. A case that registered as a **skip** (`Kit.skip`, §11) **MUST** be
  shown as a skip — in the inventory, with its reason — and **MUST NOT** be folded into either the
  passed count or the total. Counting a skip as a pass is the badge asserting a thing nobody measured;
  counting it as a failure makes a fresh clone red for a condition it cannot fix. The inventory is the
  place where *"this case did not run, and here is why"* is legible, so that is where it goes.

This complements §4: the green gate proves the suite passes on every commit; the inventory and badge
make the coverage **visible and honest**, and are the standing defense against the count drift that
silently creeps into hand-maintained status lines. §12 is the other half — an inventory is only honest
if every case in it can fail.

### 6. The verify-how-to doc

The human-facing "how to verify this addon" page — the commands and gate above (§2/§4), the local
toolchain (§3), and pointers to `docs/test-cases.md` (§5) and `docs/smoke-tests.md` — lives at
**`docs/testing.md`**, a **required** doc in the canonical `docs/` trio (`ARCHITECTURE.md`, `testing.md`, `smoke-tests.md`; documentation-§3). It is
the contributor-facing home for material the player-facing README deliberately excludes
(documentation-§1); the README keeps only the `[tests]` badge.

**The gate table MUST carry the checkpoint per suite.** Where that page tabulates the four out-of-game
suites, a *Gates?* column reading `no — recorded only` **MUST NOT** stand unqualified: it is true of a
**run** and of a **commit**, and false of the **tag**. Each row **MUST** name both checkpoints —
`lint` and `tests` gate the run and the commit (§4); `perf` and `complexity` gate **neither**, but the
**release** is gated on all four at `pass` plus zero functions above CCN 15
(automated-tests-§3, *The release gate*), where a `skip` is **not evaluated** rather than a pass. This
is the hand-written half of the same rule automated-tests-§4 puts on the runner's generated `RESULTS.md`
lead-in; the two halves say the same thing in different files, and only this one is the addon's to
edit.

This adds no obligation to restate the release gate's **mechanics** — that is the release command's
job, evaluated from the run's `manifest.json`. It forbids one specific sentence: a per-suite verdict
with no checkpoint attached, which collectively reads as *"these two never gate anything"*.

### 7. Measurement runners are outside the gate

> As of `automated-tests`, the vendored runner drives this file as its non-gating `perf` suite and
> keeps the output. That changes where the result is *recorded*, not whether it gates: it does not,
> and a perf result **MUST NOT** turn a run red (automated-tests-§3).

`tests/perf.lua` — the offline performance scenario runner (performance-§9) — lives in `tests/` but is
**not part of the green gate** and **MUST NOT** be run by `tests/run.lua`.

- **MUST** stay out of the gate. It measures rather than verifies, and folding it in would make every
  commit wait on it.
- **MUST NOT** assert on wall-clock time (performance-§9). A timing assertion in a suite anyone is
  required to pass is a flake generator, and a flaky gate teaches people to ignore red.
- The `--list` inventory and the `[tests]` badge (§5) count the **gate's** cases. A measurement runner's
  scenarios are not test cases and **MUST NOT** be counted in either.
- It is still a **load list**, and therefore still subject to §9. Being outside the gate is precisely
  what makes its list the one that rots while the figures it produces are still trusted.

### 8. Testing an addon that consumes a shared library

When behavior moves into a Ka0s-owned library (library-stack-§7), its unit coverage moves with it —
the addon **MUST NOT** keep a duplicate copy of those cases, because two suites over one behavior
means two places a fix has to land. This holds for every module the addon adopts, not only the
performance harness: the debug console, the slash dispatcher, the options shell and the widget makers
are all tested where they live.

What stays in the addon is a smaller **integration** suite proving the wiring the addon actually owns.
At minimum, **per adopted module** — the list below is per module the addon actually adopts, so the
three perf-specific entries apply only where the performance harness is wired. An addon holding a
recorded **no-combat-path exemption** (performance-§12) has no instance, no declared buckets and no
suspend contract, so it carries none of them, and a suite asserting on them there would be asserting on
a stub it wrote itself. Its remaining adopted modules are covered exactly as below:

- the **descriptor is well-formed** — the instance exists, and the fields the addon passes are the ones
  it means. For the performance harness that includes its declared buckets and their nesting;
- **every declared bucket is reached by a real bracket**, driving each bucket's genuine entry point. A
  declared bucket that no bracket reaches is a lie in every report, and nothing else will catch it
  (performance-§3);
- **suspend genuinely makes this addon inert** — events unregistered, queued work canceled, the
  show-decision ladder refusing (performance-§6) — and resume restores from current state;
- the **degraded path**: with the module absent, the addon loads and the surface the host exposes
  answers instead of erroring (performance-§1, debug-logging).

**MUST** verify the degraded path by actually loading the addon with the module missing, not by
hand-stubbing the namespace member the code under test reads. A test that builds the stub it then
asserts on proves only that the test can write a table. A module whose dependency guard returns
**before** `LibStub:NewLibrary` is **absent rather than half-wired** (library-stack-§7), so this is
loadable as a real scenario: feed the loader a deliberately partial file list and let the host's own
setup file take its fallback.

**Stub-surface parity (MUST).** The degraded-path case above proves the addon *loads*. That is not the
failure that ships. The failure that ships is a degradation stub whose **member set** has drifted from
what the host actually calls, which loads perfectly and then raises at the moment a user reaches the
one path that calls the missing member — anti-patterns #56.

- **MUST** live in **`tests/test_surface_parity.lua`**, declared in `tests/run.lua`'s suite list like
  any other suite (§1) and inside the green gate (§4). This is the rule-subject naming §1 states, and
  the file is the collection's own: all eleven addons already carry it under exactly that name, as does
  the library repo where the gate is asserted first.
- **MUST** carry, **per adopted LibKa0s module**, a **stub-surface parity case**: a declared list of the
  members the addon reaches on that instance, asserted **present on both arms** — the live instance and
  the library-absent stub. Both arms, not just the stub: a list that has drifted from the live surface
  asserts nothing about either.
- **MUST** derive the member list by **grep**, and **MUST** name the grep that produced it **in the
  case's comment** — `-- members from: grep -rno "NS\.Slash[:.][A-Za-z]*" core/ modules/ settings/`.
  The next author then re-runs one command instead of re-deriving the list by reading, which is the
  step that does not happen and the reason the list rots.
- **MUST** produce the degraded arm by **feeding the loader a deliberately partial file list**, never by
  hand-stubbing the namespace member under test. This is the paragraph above in its specific form: a
  case that writes the stub it then asserts on proves only that the test can write a table, and it
  proves it *especially* convincingly for a parity assertion, where the hand-written stub is by
  construction built from the same list the assertion checks.
- **MUST** treat a member present but **`nil`-valued** as a divergence, and **SHOULD** report **every**
  divergence in one message rather than raising on the first. A stub missing four members should cost
  one round of this, not four.
- The options stub's **load-completing** exception (options-ui-§1) narrows what the members must **do**,
  not **which members must exist**. An options stub is permitted to complete the load and answer
  inertly; it is **not** permitted to be missing a member the host calls. Both of the reproduced
  ConsumableMaster failures hid behind that exception, which is why it is stated here rather than left
  to be inferred.

The class is not hypothetical and no green suite sees it, because no suite loads the addon degraded:
`ConsumableMaster/settings/Panel.lua:571-572` and `:643`/`:833` reproduce as a session-long error loop
with a settings write landing **before** the raise, and `PanelMaster/settings/Slash.lua:316` is a stub
missing a `FormatKV` the host calls from five sites.

### 9. Load lists MUST be derived from the TOC

A repo typically names its files in load order in several places — the TOC (what the client actually
reads), `tests/run.lua`, the offline perf runner, a deliberately partial degraded-path list — and not
all of them are under the green gate.

- **MUST** derive the runner's list of the addon's **own** files from the TOC, with the kit's
  `Loader.tocFiles("<Addon>.toc")`, rather than carrying a hand-maintained copy. It skips blank lines,
  comments and `## Directive:` lines, skips `libs\` entries, and converts backslashes to forward
  slashes.
- **MUST** list the **vendored library files explicitly**, in the order their XML uses. A vendored
  library is pulled in through its own `.xml`, which `tocFiles` cannot see, so every file of
  `LibKa0s.xml` is spelled out in the runner — all of them, in dependency order (anti-patterns #48).
- **MUST** pin the derivation itself with cases: that the runner fed the loader exactly the TOC's files
  in the TOC's order (publish what it loaded through `Kit.expose` and compare against a fresh
  derivation), that every derived path exists on disk, and that no `libs/` path leaked in. An ungated
  runner such as `tests/perf.lua` is pinned by **reading its source** for the derivation call, since
  the gate does not run it.
- **MUST** pin the **suite list** — the third list, and the one this section used to be silent about.
  The ordered list of `test_*.lua` paths handed to `Kit.run` is as hand-maintained as the other two and
  is under exactly the same green gate that cannot see it go wrong. Pin it **in both directions**, with
  distinct messages per direction:
  - every `tests/test_*.lua` **on disk** appears in the declared list — otherwise a new suite is
    written, committed, and never runs;
  - every path **in the declared list** exists on disk — otherwise a renamed or deleted suite stops
    contributing cases while the run stays green.
  A runner that **auto-discovers** its suites from the directory satisfies this by construction and
  carries no declared list to pin; the rule binds a runner that **declares** one. The shape to write is
  a case in the repo's own harness suite that lists `tests/test_*.lua` off disk and compares it against
  the list the runner publishes — and this is not a rule nobody has written yet. Evidence that it is
  already writable: `BankLedger/tests/test_harness.lua:22-32` lists the directory, and
  `PanelMaster/tests/test_harness.lua:19-32` reads the runner's published list and asserts both
  directions against it.
- **A declaration is the pair (basename, directory), and a suite the vendored kit ships MUST be
  declared with an entry naming the kit directory** — `{ name = "test_prose", dir = "tests/_kit/" }`,
  not the bare `"test_prose"`. The bare form wires the repo's own file of that name, and the inventory
  check, keyed by basename, accepts it as covering the kit's file too. Two MUSTs follow. Both are
  **failures, not silent passes**, and the second carries the one carve-out — a decline the repo has
  written down — which reports as a skip rather than as a failure and is stated in full there:
  - a consumer suite whose basename collides with a file in `tests/_kit/`, declared without the kit
    directory, is a **collision to be reported** — naming **both** paths and saying **which one is
    running** — never silently accepted. A repo wires the kit's gate or its own, never both
    (localization-§5 states it for the prose gate; it is general), and the report is what makes the
    choice visible at the moment it is made rather than at the next audit;
  - the general form: **any suite file present in `tests/_kit/` that no declaration references** is the
    same hole and **MUST** be reported — **unless the repo has declined that gate** in favor of its own
    suite over the same subject **and recorded the decline** as a row in its `## Documented deviations`
    register (documentation-§3), keyed to the rule the gate serves. A recorded decline is reported
    **once, as a decline carrying that reason** (`Kit.skip`, §11): never as a hole, and never silently
    as a pass. An unreferenced kit file with **no** such row is a hole and a **failure**. The carve-out
    is not a softening — it is what the failure mode actually is. What this rule catches is a gate
    **nobody knows is not running**, and a register row is precisely the case where somebody knows;
    without it, the permission localization-§5 grants — a repo carrying its own prose gate wires the
    kit's copy or its own, **never both** — would be a permission no repo could exercise without
    failing this MUST. Together these two rules have exactly one reading: wire the kit's file, or wire
    your own **and** record why the kit's is unwired. Silence about it is the one state neither allows.
    That is also what makes the next kit gate arrive loudly in a repo that has not wired it, instead of
    landing as a file nothing loads.
  The reason is that a gate that silently does not run is **worse** than an absent one: an absent gate
  leaves a visible gap, while a shadowed one leaves the repo's own record — the runner's suite list,
  `docs/test-cases.md`, the pass count — asserting the rule is covered. Six of the twelve repos are in
  exactly that state today, each running a 262–443-line local copy of a gate the kit also ships, and
  the divergence is already real: the kit's copy reads its waiver file from disk while two of the local
  copies hardcode the waiver table. The published word lists those six shadow are byte-equal to the
  kit's **today**, which is why this is worth closing before the next amendment rather than after — an
  amendment arriving by re-vendor would reach six repos' dark copy and none of their live ones. This is
  §1's own-denominator rule applied to the suite inventory itself: the inventory reads two
  directories, so its key has to carry which one.
  Both reporting MUSTs above bind the kit's inventory check **from LibKa0s test-kit revision 25
  (LibKa0s v1.55.0)**, the revision in which the declaration key becomes the pair. They bind the kit,
  not the consumer: a repo whose vendored kit predates that revision owes the **re-vendor**, never a
  hand-written suite of its own (§1). What the consumer owes on its own account is the declaration —
  the kit-directory entry, or the register row that says it declined.
- The matching kit-side rule, and unlike the two above it carries **no commencement**, because it
  describes the kit already in the tree rather than one a later revision has to deliver. **`loadSuites`
  MUST raise on a listed-but-absent suite**, naming the path and the declaration's position in the
  list, rather than silently omitting it — and rather than reporting it as a skip. The reason is the
  bullet above: a silent omission is exactly the failure that bullet exists to catch, so the kit-side
  answer to it cannot be a status that is counted and passed over. **An error names the path; a skip
  buries it**, and a renamed or deleted suite is a defect in the inventory, not a deferral. The
  write-in-progress affordance the old silence was protecting is **declared, never inferred**: a suite
  deliberately absent while it is being written is listed as `{ name = …, pending = "why" }`, which
  registers as a **skip carrying that reason** (`Kit.skip`, §11) and says so in the run. Declaring it
  is what separates the two cases, which is why the marker cannot be left lying around either — a
  `pending` entry whose file **does** exist **MUST** raise as well, telling the author to drop the
  field so the suite's cases actually run. This is what LibKa0s test-kit revision 24 ships today
  (`testkit/framework.lua`, `loadSuites`), and the rule is written to it.

The rule exists because these failure modes are **silent, and the first two happened during the LibKa0s
extraction**:

- a suite named in the runner's list but missing from disk **was skipped rather than failed** —
  deliberately, so a suite could be listed while it was being written — so a renamed or deleted suite
  quietly stopped contributing cases while the run stayed green and the count barely moved. This is the
  one of the three the kit has since closed outright, by the bullet above: the absence now raises, and
  the deliberate case is declared `pending` instead of being inferred from the silence;
- a **library file omitted** from the load list makes the dependent module refuse to register (its
  dependency guard returns before `LibStub:NewLibrary`, library-stack-§7), so the host's setup file
  falls back to its stub and the suite happily measures **the stub** — green, and testing nothing;
- and the third, which is the first one's mirror image: a suite **on disk but absent from the declared
  list** is never registered at all, so it contributes nothing while looking, in the repo, exactly like
  a suite that runs. The count does not fall — it simply never rose — which is why nobody notices, and
  why this direction needs its own case rather than being the other one read backwards.

None of the three shows up in the pass/fail line. Derivation is what makes the first two impossible
rather than merely noticed; for the third, where no derivation is possible because the list *is* the
declaration, a two-directional case is the substitute — and `loadSuites` raising on the absence instead
of passing over it is what stops the first from being invisible in a repo whose runner still declares
its list by hand.

### 10. The versioning suite (repos that publish per-file LibStub minors)

Any repo that ships a LibStub library — a Ka0s-owned shared lib (library-stack-§7) above all — **MUST**
carry a **versioning suite**. LibStub picks a winner between vendored copies by comparing **minor
integers**, so a released change that does not bump its file's minor is **invisible**: every host
already carrying the old copy keeps running it, and the fix silently does not ship. Nothing in Lua can
notice that on its own. What a test **can** enforce is that the code and the changelog agree about what
version each file is at — which turns library-stack-§7's coupling from remembered into mechanical.
Reference implementation (in the collection): `LibKa0s`'s `tests/test_versioning.lua`.

- **MUST** iterate a **declared table of majors** — each with its major string, its file basenames, its
  primary file, and any paired secondary files — rather than naming files inline. A major added to the
  library's XML but forgotten in that table then surfaces as a versioning failure instead of as
  silence, and adding a module is one row rather than an edit scattered through the suite.
- **MUST** assert that **every declared major is actually registered**, and report the misses rather
  than raising on them — a declared-but-unregistered major is exactly what §9's second failure mode
  produces, and the suite should name it.
- **MUST** assert that **every file of every major appears in the live registry** (`lib.MODULES` or
  equivalent), naming each file explicitly rather than counting, and that the primary file's entry
  equals the major's own `MINOR`.
- **MUST** assert that **no file registers under a major it does not belong to**. The registry is
  per-major, so a stray entry means one file wrote into another's — and *"what am I running?"* would
  then answer with a number from the wrong module.
- **MUST** assert that **file basenames are unique across every major**. The changelog check below
  searches one shared `CHANGELOG.md` for `"<FileBasename> minor <N>"`, so two majors owning a
  same-named file would satisfy each other's assertion. This is why the Options module ships
  `OptionsWidgets.lua` and `OptionsScroll.lua` rather than the bare `Widgets.lua` / `ScrollPatch.lua` a
  future window module would also want — the collision would be **silent**.
- **MUST** assert that **every registered minor is a positive integer**, because LibStub compares
  integers.
- **MUST** assert that the **changelog accounts for the version every file is at**: loose about the
  wording, strict about the pair — the file's name and its current number must both appear. That fails
  both when someone bumps a minor and forgets the entry, and when someone writes an entry for a bump
  they did not make.
- **MUST** assert that each **paired secondary file records which primary it attached to** (the
  guard's `__<file>Minor` plus a field naming the primary's minor — `__<file>ShellMinor` in `LibKa0s-Options-1.0`,
  `__panelProbeMinor` in `LibKa0s-Perf-1.0`; assert the pairing, not a fixed spelling, or the suite reports a
  false miss on the one major that names it differently), because a secondary attached to a primary from
  a **different vendored copy** is the failure the per-module-major layout exists to prevent.
- **SHOULD** collect every miss before failing rather than asserting inside the loop. Aborting on the
  first missing entry leaves the rest unchecked — which is how this suite's own first run reported one
  gap while hiding a second.

### 11. A vendored payload is gated by a byte-identity test, not a remembered `diff`

Vendoring something you also author is an ongoing **sync**, not a one-time copy (library-stack-§7), and
a release checklist's manual `diff -r` is a step that gets skipped.

There are **two** such gates and this section covers **both halves**. They differ in what they compare
and therefore in what they are allowed to normalize, and conflating them is how the second one ends up
either absent or silently broken:

- **the library-side kit-sync gate** — the library repo's source `testkit/` against its **own** vendored
  `tests/_kit/`. Both sides are working-tree directories **in one checkout**;
- **the consumer-side vendored-payload gate** — a consuming repo's `libs/LibKa0s/` against the library
  repo's ship folder in a **sibling checkout**. Here one side is a working tree and the other is
  whatever the sibling checkout can be asked for, and the precondition — that the sibling exists — is
  not always met.

#### The library-side kit-sync gate

- **MUST** carry a **kit-sync suite** in the library repo comparing the source `testkit/` against its
  own vendored `tests/_kit/` — the manual diff, mechanical. Reference implementation: `LibKa0s`'s
  `tests/test_kitsync.lua`.
- The library repo **MUST** consume its own kit through `tests/_kit/` rather than reaching into
  `testkit/` directly, so it is a consumer on exactly the same terms as every addon and a kit change
  that would break a consumer **breaks the library repo first**.
- **MUST** assert **both** properties: the same **set** of filenames in both directories — so a file
  added to one and not the other is caught even though every existing file still matches — and
  **byte-identical content** for every one of them, **`README.md` included**. The file that actually
  diverged was a README, so a check restricted to `*.lua` would have caught nothing.
- **MUST** compare **raw bytes**, read in binary mode, with **no line-ending normalization**. This MUST
  is scoped to a comparison where **both sides are the same representation** — here, two working-tree
  directories in one checkout, both governed by the same `.gitattributes` — which every repo carries
  and which pins the whole tree one way (`line-endings-§1/§2`), so a byte difference is a real
  difference and nothing else. A repo that pins its line endings has already had a copy arrive
  through a normalizing path; a check that normalizes cannot see it. *The consumer-side
  vendored-payload gate* below states the one carve-out, and it is a carve-out precisely because that
  comparison is **not** same-representation.
- **MUST** fail, not pass, when the gate **cannot run**. Both directories are in this checkout, so a
  directory listing that yields nothing is a broken gate, not an absent precondition: the check could
  not look, and a gate that goes quiet when it cannot look is worse than no gate.
- **MUST** name the file and say **where and how** it differs. *"The kit is out of sync"* on its own
  costs the next person the manual diff the test exists to remove.

The rule is here because the failure already shipped: a documentation pass improved `testkit/README.md`,
did not re-vendor it, and released the divergence with **three documents asserting the gate was
passing**. Both copies keep working when they drift, so both suites stayed green (anti-patterns #45).

#### The consumer-side vendored-payload gate

- Every repo vendoring a Ka0s-owned library **MUST** carry a gate comparing its `libs/<Lib>/` against
  the library repo's ship folder in the sibling checkout. The library-side gate proves the library repo
  is self-consistent; it says nothing about whether **this** addon's copy is current, which is the
  divergence anti-patterns #45 is actually about.
- **MUST** carry it as **`tests/test_vendor_sync.lua`** (§1's rule-subject naming), and that file
  **MUST delegate** to the implementation inside the payload it checks — `tests/_kit/vendor_sync.lua` —
  rather than reimplement the comparison. Every copy in the collection is a registration of thirty-odd
  lines against the vendored implementation, and that is the shape to keep: two implementations of one
  gate means the kit can be fixed and eleven repos keep failing the old way, which is the argument
  library-stack-§7 already makes about the provenance line. The implementation shipping inside the
  payload it compares is deliberate — a local patch to it breaks the library-side gate's byte-identity
  assertion, which is the correct outcome.
- **The `<ref>` it compares against comes from the repo's own root `CLAUDE.md`** — the provenance line
  `Bundles [LibKa0s](…) vX.Y.Z (MIT).` (documentation-§2 item 6, library-stack-§7), read with the Lua
  pattern `[Bb]undles %[LibKa0s%]%b() (v[%d%.]+)` so a standalone sentence and a mid-sentence phrasing
  both satisfy it. The kit has read `CLAUDE.md` rather than `README.md` since **LibKa0s v1.8.1 /
  testkit revision 9**, and reads it through a named `provenanceFile` opt defaulting to `"CLAUDE.md"`.
  **There is no fallback to `README.md`, deliberately**: a repo that has not moved its line reads as
  carrying **no provenance line at all** and the case **fails**, naming `CLAUDE.md`. A fallback would
  let a repo sit half-migrated with two lines that can disagree and a gate silently preferring one of
  them, which is the same shape as the drift this gate exists to catch. A missing line is a **failure**,
  not a skip — unlike an absent sibling checkout below, the repo had everything it needed to answer.
- **The comparison is blob-versus-worktree, and exactly one normalization is permitted and required.**
  The sibling side is read as a **`git show <ref>:<path>` blob**, which is LF **by construction** —
  git stores normalized content — while the local side is a **working tree** pinned to CRLF by
  `.gitattributes` in **every repo that ships Lua to the client** (`line-endings-§2`), which is
  exactly the set of repos that vendor `libs/LibKa0s/`. *"Almost every repo"* was the honest phrasing
  only while the pin was an unstated habit; it is now a rule, so this gate's precondition is
  guaranteed rather than probable. Measured on a live pair:
  `git -C LibKa0s show HEAD:LibKa0s/Core.lua | tr -cd '\r' | wc -c` → **0**;
  `tr -cd '\r' < AbsorbTracker/libs/LibKa0s/Core.lua | wc -c` → **322**. The two sides are therefore
  **not** the same representation, and the library-side no-normalization MUST above does not reach here. The gate
  **MUST** strip **CR from the working-tree side and nothing else** — which compares the file against
  the blob it round-trips to — **or**, equivalently and normalization-free, compare
  `git hash-object <local file>` against the sibling's blob sha. It **MUST NOT** apply any other
  normalization: no whitespace trimming, no trailing-newline fixup, no case folding. A real fork in
  content still fails, which is the property both forms preserve.
  - **MUST** carry that reasoning in the case's own header comment. Without it the next author reads
    a lone `gsub("\r", "")` as sloppiness and deletes it, at which point the gate reddens on every
    checkout and gets deleted next.
- **MUST** register as a **skip carrying its reason** when the precondition is absent — the sibling
  checkout is not there, or the ref cannot be resolved. It **MUST NOT** register as a pass, and it
  **MUST NOT** fail: a fresh clone with no sibling has not proven the payload is current and has not
  proven it is stale, and a gate that reddens on every fresh clone is a gate people learn to ignore.
  This is the same doctrine `automated-tests-§3` already applies to an absent tool — a missing tool is
  recorded as a skip with its reason, never as a pass or a failure — extended from suites to cases.
- The primitive is the kit's **`Kit.skip(reason)`**. `Kit.skip` is a **third status**: counted
  separately from passed and failed, surfaced by `Kit.run` and by the `--list` renderer, and it
  **MUST NOT** change the process exit code. A skip is not a failure, so it does not break the green
  commit gate (§4).
- The reason **MUST** be visible in the case's **own recorded result** — the printed line, the `--list`
  inventory, `docs/test-cases.md` — and not only in a header comment. A reason a reader has to open the
  source to find is a reason the person reading the run output does not have.

### 12. A test that cannot fail is worse than no test

A test that passes no matter what the implementation does still prints `PASS`, still counts in the
`--list` inventory (§5), and still moves the badge — so it **reads as coverage** while providing none.
That is strictly worse than an absent test, which at least leaves a visible gap.

- **MUST** verify any case asserting a **negative** — a thing not resolved, a value not written, a
  handler not registered, a note not appended, a bucket not counted — by **mutating the implementation
  and watching the case go red**, then reverting. An assertion that a table stayed empty passes just as
  happily when the code path that would have filled it was never reached at all.
  - Mutation leaves no artifact in the repo, so this rule is **not mechanically auditable**. An audit
    **MUST NOT** record its absence as a deviation; it records it as *unverified*. To make it
    checkable, the case **SHOULD** carry a one-line comment naming the mutation that reddens it
    (`-- red under: drop the ClearScroll in RenderUnitPanel`) — which is also the cheapest way for
    the next author to re-run the check rather than re-derive it.
  - Restore the mutated file from a `cp` backup taken immediately before, never with
    `git checkout <file>`: mid-change the work is uncommitted, so `git checkout` reverts to HEAD and
    destroys it. This has cost a full milestone's rewrite in this collection.
- **MUST NOT** treat *"it raised"* as sufficient. Assert on **what** it raised; an assertion that
  something threw passes just as happily on a typo in the test itself.
- **MUST NOT** build the object under test inside the test and then assert on it. That is §8's
  degraded-path rule in its general form: the test proves only that the test can write a table.
- **SHOULD** record, in the case's own comment, the mutation used to prove it can fail, whenever the
  falsification is not obvious from reading it.

This is not theoretical: **unfalsifiable assertions were found in four separate milestones** of the
LibKa0s extraction — each written in good faith, each green, each proving nothing. The mutation costs
seconds at the moment the test is written, and effectively never happens afterward.

### 13. Characterization tests before a behavior-preserving refactor (MUST)

testing-§4's TDD rule governs **new behavior**: write the failing test, then the code. A refactor is
the opposite problem — the behavior already exists and the whole point is that it must not change —
and it needs its own rule, because the obvious move is wrong. Refactoring first and testing afterwards
produces a test that asserts whatever the new code happens to do, which proves only that the new code
does what the new code does.

- **MUST**, before refactoring a function that has **no coverage**, write a **characterization test**
  that pins its current behavior, and **run it against the unrefactored code** and watch it pass. That
  passing run is the entire value: it is the moment the test is known to describe the old behavior
  rather than the author's belief about it.
- **MUST** pin what a caller can actually observe — return values across the interesting input classes,
  the chat lines emitted, the SavedVariables keys written, the order of side effects. Not internal
  structure, which the refactor is allowed to change.
- **MUST NOT** weaken or delete an existing test to make a refactor pass. A test that goes red during a
  behavior-preserving refactor has done its job and is reporting a behavior change; the fix is in the
  refactor.
- **SHOULD** keep the characterization test after the refactor lands. It was written to protect one
  change, but it documents a contract that had none, and the function was untested for a reason that
  has not gone away.
- Where a function is genuinely unreachable headlessly — a `StaticPopup` handler needing a live frame,
  a render path needing real widget geometry — **MUST** extract the pure logic first, test **that**, and
  say so in the change. "It cannot be tested" is a claim about the current shape, not about the logic.
- A collection-wide complexity sweep in 2026-08 found **16 of 86** warned functions with no coverage at
  all. Those are, by construction, the functions a refactor is least safe to attempt and most likely to
  be aimed at: complexity and untestedness have the same cause (performance-§11).

### 14. The green gate MUST stay fast, and slowness MUST be measured before it is fixed (MUST)

A commit gate is run dozens of times a day, and its cost is paid in the one currency the toolchain
cannot mint: whether anyone actually runs it. A gate that takes two minutes gets run once at the end
instead of after each change, then gets skipped, then gets `--no-verify`'d — the same failure mode
`performance-§9` describes for a threshold that fails a build. Speed is therefore a property of the
gate, not a nicety, and it is governed here.

**The measurement comes first.**

- **MUST** establish *where* the time goes before changing anything, and **MUST** state the figure —
  wall clock, CPU, and the count of whatever turned out to dominate. A test suite is one of the
  easiest things in this collection to profile and one of the easiest to guess wrong about: the
  first instinct on Ka0s Multi Meters' 2m10s suite was "too many tests", and 1,246 cases were not
  the problem at all.
- **MUST** treat a low CPU-utilization figure as the diagnosis it is. That suite burned **32.7s of
  CPU across 130.8s of wall clock — 25%**. Three quarters of the run was a process sitting still,
  which is never fixed by making the code faster and is always fixed by doing fewer, or more
  concurrent, waits.
- **SHOULD** record the resulting figure in the repo's `docs/automated-tests/RESULTS.md` run, so a
  regression is visible as a number rather than as a feeling.

**Three costs dominate a headless WoW-addon suite, in this order.** Each is a MUST because each was
found live, and each is fixed in the vendored kit rather than per repo.

- **MUST NOT re-read and re-parse source the process has already read.** Suites build a fresh,
  isolated instance per case, which is correct — isolation comes from re-*running* the chunks under
  a new mock (§8) — but the bytes do not change between instances. `loadfile` re-opens and
  re-*parses* on every one of them. Measured: **1,246 cases drove 60,112 `loadfile` calls, 28.5s of
  31.4s of CPU.** On a WSL2 `/mnt` checkout each of those reads crosses a 9p mount at roughly 1.5ms,
  which is where the wall clock went. Kit revision 12's `Loader.load` compiles each path once per
  process and re-calls the cached chunk; a repo adopts it by re-vendoring and does nothing else.
  **That change alone took the suite from 2m10.8s to 11.6s.**
- **MUST NOT spawn one subprocess per item where one invocation answers the whole set.** Process
  spawn is tens of milliseconds and the work inside is often microseconds, so a per-item loop is a
  latency multiplier wearing a correctness disguise. The vendored-payload gate (§11) ran
  `git show <tag>:<path>` **once per file**, which for a payload of 49 icons, a font and the Lua was
  ~66 spawns and **7.5 seconds** — after the cache landed, the single longest thing in the suite.
  Kit revision 12 reads every blob with one `git cat-file --batch`. The same rule binds a directory
  walk, a `git check-attr` sweep, or any other shell-out written per file.
- **SHOULD** slice a batched reply by the **length** the tool states, never by pattern-matching its
  delimiters. `cat-file --batch` states each blob's byte count precisely so that a payload
  containing newlines, NUL bytes or CRLF round-trips unharmed; a parser that splits on newlines
  corrupts every binary in the payload and reports it as a line-ending problem in a file that has no
  lines.

**Parallelism is the last resort, not the first, and it is opt-in.**

- **MUST** exhaust the two rules above before reaching for `--jobs`. Fanning out duplicated work
  buys a fraction of what deleting the work buys, and it is strictly more complex. On Multi Meters
  the cache and the batch together were **16x**; parallelism on top of them was a further **2.2x**.
  Run in the other order, parallelism alone would have been a 1.4x improvement over a two-minute
  suite and the real defect would still be there.
- **SHOULD** switch `--jobs` on once a repo's serial gate exceeds roughly **10 seconds**, and
  **MUST** verify the sharded run agrees with the serial one — same totals, same exit code — before
  it becomes the gate. `Kit.run`'s default is `jobs = 1`; a repo opts in with
  `Kit.run{ ..., jobs = "auto" }`.
- **MUST** treat a suite that only passes because an earlier suite ran first as the **bug it always
  was**, not as a reason to stay serial. Sharding splits the process-wide state suites share — the
  `shared` instance, the SavedVariables globals — so it does not create that dependency, it
  *reveals* it. This is §12's rule one level up: a suite whose result depends on what ran before it
  is not measuring what its name says.
- **MUST** keep a parallel run's transcript **identical to a serial one**. Shards take *contiguous*
  slices of the declared suite list and their output is relayed in shard order. A gate whose output
  reshuffles on every run is a gate nobody diffs, and diffing two runs is how a flaky case is found.
- **MUST** fail the run when a shard dies without reporting. Its cases are then missing from the
  totals, and a total that silently shrank is the same lie §9's load-list rules and
  `assertSuiteInventory` exist to prevent — a gate that goes quiet when it cannot look is worse than
  no gate.
- **MUST NOT** let a shard spawn shards. `--shard` forces `jobs = 1` in the kit, so a runner
  carrying `jobs = "auto"` cannot fork a process tree.
- **MUST** fall back to a serial run, with a notice, where the platform has no POSIX shell to
  background workers from. A missing shell is a missing capability, not a test failure (§1's
  skip-is-not-a-pass rule, applied to the runner itself).

**Reference implementation:** LibKa0s `testkit` revision 12 — `loader.lua`'s chunk cache,
`vendor_sync.lua`'s batched blob reads, and `framework.lua`'s `--jobs` / `--shard` driver.
`docs/api/testkit/version-12-docs.md` in that repo is the contract; `tests/test_loader.lua` pins the
cache's isolation invariant and `tests/test_parallel.lua` pins the partition. End to end on Ka0s
Multi Meters, 1,246 cases: **2m10.8s to 3.7s**.

### 15. Every out-of-game run MUST be bounded — memory, time, process depth and leaks (MUST)

A headless run executes on a developer's machine, beside the editor and the agent session driving it,
and an unbounded one takes all three down together. In this collection one did, repeatedly. A scratch
probe left in Ka0s Kick CD's `tests/` — never committed, pointing at a sibling checkout by an absolute
path and doing its work the moment it loaded — was registered in the runner's suite list. One of the
suites runs `lua tests/run.lua --list` as a child process, the child loaded the probe, and the probe
started the next child: a chain of ~700 MB `lua` processes, growing at ~145 MB/s until the kernel's
OOM killer took the whole WSL2 VM. Separately, Ka0s Multi Meters' green gate peaked at **1.75 GB**
without anyone noticing, because the kit's own mock held every instance a case had built until the
process exited. Neither was visible as a test failure. This section makes both visible, and makes
neither able to take the machine with it.

**The bounds are the kit's, never the repo's.**

- **MUST** run every out-of-game entry point bounded: the headless suite, `tests/perf.lua`,
  `run-automated-tests.sh`, `luacheck` and `lizard`. Bounded means all four of:
  - a **per-process memory cap** (`ulimit -v`, `KA0S_KIT_PROC_MB`, default 2048). Lua 5.1 answers an
    allocation past it with a catchable `not enough memory`, so the case that crossed it fails by name;
  - a **wall-clock timeout** (`timeout --foreground`, `KA0S_KIT_TIMEOUT_S`, default 900), foreground
    so Ctrl-C still reaches the run;
  - a **process-tree memory cap** where the host supports cgroups — the outermost process runs inside
    `systemd-run --user --scope` with `MemoryMax` (`KA0S_KIT_TREE_MB`, default half of RAM), swap
    off, and `TasksMax` (`KA0S_KIT_TASKS`, default 256), so a runaway tree is killed as one unit by
    its own cgroup rather than by the kernel choosing among everything on the machine
    (`KA0S_KIT_CGROUP=off` drops only this layer; a host with no systemd skips it silently);
  - a **re-launch depth limit** (`KA0S_KIT_DEPTH`, `KA0S_KIT_MAX_DEPTH`, default 4): a process past
    the limit refuses to start, exit 3, naming the likely cause.
- **MUST** take those bounds from the vendored kit, never hand-roll them in a runner or a wrapper.
  `framework.lua` applies them **on load** — every runner's first act — by re-launching itself once
  under the bounds, so a repo adopts this section by re-vendoring and changes no code of its own.
  `run-automated-tests.sh` carries the same variables and defaults for `luacheck` and `lizard`, which
  load no kit.
- **MUST** understand why the depth limit exists, because the obvious fix does not work: a per-process
  cap alone would **not** have stopped Kick CD's chain, since every link fit under any sensible cap.
  The depth travels in an environment variable each guarded process exports one higher, so it holds
  even when a suite shells out through a bare `io.popen` that knows nothing of the kit; the guarded
  process recognizes itself by a marker **argument**, which unlike the variable its children do not
  inherit.
- **MUST NOT** set `KA0S_KIT_GUARD=off` anywhere a gate runs. It exists for a debugger attached to one
  process, and a gate run without it is not a gate run.

**The runner holds every case to a budget.**

- **MUST** fail a case whose run leaves the live heap over the **heap budget** (`heapBudgetMB`,
  default 1024, `KA0S_KIT_HEAP_MB`), and stop the run there. The check reads
  `collectgarbage("count")` and pays for a full collection only when that cheap reading is already
  over, so a run inside its budget never pays for it.
- **MUST** fail a case, and a suite file's load, that passes the **CPU ceiling** (`caseSeconds`,
  default 120, `KA0S_KIT_CASE_S`). A count hook raises past the ceiling and keeps raising, so a body
  that swallows the first error in its own `pcall` still cannot outrun it.
- **MUST** fail the run through the **leak gate** (`leakBudgetMB`, default 256, `KA0S_KIT_LEAK_MB`)
  when the live heap ends a suite more than the budget above where the run started. A harness that
  retains a constant amount per case is invisible to every single case and becomes gigabytes over a
  run; the gate reports once, against the suite in which the run crossed.
- **MUST** record a raised budget — a larger `heapBudgetMB`, `leakBudgetMB` or `caseSeconds` in a
  runner's `Kit.run{}` options — as a row in `## Documented deviations`, with the measured figure that
  needed it and a re-check trigger. An environment override is for a single diagnostic run and is
  never committed into a script. A budget quietly raised to make a gate pass is the leak it exists to
  catch, with the evidence removed.

**A suite does no work until it runs.**

- **MUST** keep a suite file to registering cases (§1's *Registration is not execution*, now enforced
  on the load itself by the CPU ceiling above). Work at load time runs in `--list` too, and in every
  child process that loads the runner — which is how Kick CD's probe recursed.
- **MUST NOT** name a path on a developer's machine in a suite: `/mnt/<drive>/`, `/home/<user>/`,
  `/Users/<user>/` or `<drive>:\Users\`. A suite reaches the repo through the runner's `root`. The kit
  refuses to load a suite that does, naming the file and the path.
- **MUST NOT** leave a scratch file, probe or one-off measurement script under `tests/`, committed or
  not. It belongs in a scratch directory outside the repo. The inventory gate (§9) catches an
  undeclared file; it cannot catch a stray one that someone also declared.

**An instance a case built is released when the case ends.**

- **MUST** let a fresh addon instance (`T.load()` and its equivalents) become unreachable once the case
  that built it returns. Nothing process-wide — a module-level table in a mock, a registry, a cache
  keyed by an instance — may keep a build alive after its last user.
- **MUST** know the Lua 5.1 trap that caused Multi Meters' 1.75 GB: **5.1 has no ephemerons.** A
  weak-keyed table whose *value* can reach its own *key* is never collected. The kit's AceEvent fake
  looked its build up through a process-wide `setmetatable({}, { __mode = "k" })` whose value, the
  build, reached the key again through AceEvent's `embeds`, so every build and every instance ever
  embedded in one stayed alive — 1,678 of them, 685 MB live, at exit. Keep such a reference **on** the
  object it describes (a field, or the object's metatable) so it lives and dies with it. After the fix
  the same suite peaks at **41 MB**, flat across all 1,678 instances.

**Parallelism is sized by memory as well as CPUs.**

- **MUST** cap `--jobs auto` (§14) by memory: no more workers than three quarters of `MemAvailable`
  holds at `KA0S_KIT_SHARD_MB` each (default 512). One worker per CPU, whatever each weighs, is more
  memory than a laptop has for a heavy suite. Several repos' suites **MAY** run at once; the bounds
  above are what make that safe, and serializing runs by hand is not a substitute for them.

**Reference implementation:** LibKa0s `testkit` revision 23 (LibKa0s v1.43.0) — `framework.lua`'s load-time guard
(`guardProcess`), the heap, leak and CPU budgets in `Kit.run`, the host-path refusal in suite loading,
the memory-capped `--jobs`; `mock_base.lua`'s build lookup moved onto the `__events` metatable; and
`run-automated-tests.sh`'s `bounded` wrapper. `docs/api/testkit/version-23-docs.md` in that repo is
the contract.

