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
```

- **`tests/run.lua`** **MUST** keep only what is genuinely this addon's. It `dofile`s the kit's `framework.lua` and `loader.lua`, builds the environment once by loading the vendored library files and then the addon's own files (§9), mirrors the in-game lifecycle (`NS:InitDB()`, and the settings-panel build if the addon has one, so the schema-to-widget layer is exercised as the client exercises it rather than through hand-called fictions), publishes the shared table via `Kit.expose`, and hands the ordered suite list to `Kit.run{ dir = "tests/", suites = { ... } }`. `Kit.run` exits **0** on success and **1** on any failure, so the green gate is a plain shell check.
- **`Kit.expose`** merges `test` and the assertions (`fail`, `assertEqual`, `assertTrue`, `assertFalse`, `assertNil`, `assertNear`, `assertError`) into the table you pass, so each repo keeps its own global name — `AT_TEST`, `LK_TEST`, … — and its own extra keys. Adopting the kit therefore requires **no change to any existing suite file**, which is what made adoption one commit per repo rather than a rewrite.
- **`loader.lua`** loads each source with `loadfile`, `setfenv`s it into an environment whose `__index` resolves WoW globals to the mock table first and falls back to `_G`, and calls the chunk as `chunk(addonName, NS)` when `Loader.addonName` is set — reproducing the client's `local addonName, NS = ...` header. Library chunks take no arguments, so a library-only repo leaves `addonName` nil. Its `__newindex` **writes through to `_G`**, deliberately: without that, a sandboxed write to a SavedVariables global or a `StaticPopupDialogs` registration is silently lost and the migration paths become untestable.
- **`tests/wow_mock.lua`** **MUST** be a **thin extender** over `mock_base.lua`, not a replacement: `local base = dofile("tests/_kit/mock_base.lua")`, then a builder that calls `base()` and overwrites the handful of keys this addon needs. Plain per-key overwrite — the base returns a fresh table per call, so there is no merge machinery to reason about. Use `M.__stubFrame()` for extra frame-shaped objects and `M.__libs` to register additional library fakes without reaching through LibStub's closure.
- Suites stay plain: `local T = _G.<ADDON>_TEST; local test, assertEqual = T.test, T.assertEqual` then `test("...", function() assertEqual(...) end)`.

**Mock fidelity (MUST).** The kit's `README.md` carries the fidelity rules in full; each exists because a friendlier mock already hid a real bug. An addon's extender **MUST** hold to the same five: a stub that silently succeeds is worse than no stub when production code branches on its return value; getters used in arithmetic or concatenation return real numbers and strings; anything a test needs to **observe** is recorded rather than no-opped (a no-op `RegisterUnitEvent` lets a widened or dropped per-unit event filter pass the entire suite); anything a test needs to **drive** is fireable; and the awkward real behavior is modeled rather than the convenient one (AceDB's in-place `copyDefaults`, AceConsole's `Embed` clobbering a same-named custom `Print`).

**Registration is not execution.** The kit **collects** every case and runs nothing until `Kit.run`. A runner that executes a case body at registration time and short-circuits it in list mode makes `--list` a second code path through the same file, and the inventory can then disagree with the run. An addon **MUST NOT** reintroduce that shape; `--list` is a pure filter over the registry and cannot drift from what actually runs.

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
At minimum, per adopted module:

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

The rule exists because both failure modes are **silent, and both happened during the LibKa0s
extraction**:

- a suite named in the runner's list but missing from disk is **skipped, not failed** — deliberately,
  so a suite can be listed while it is being written — so a renamed or deleted suite quietly stops
  contributing cases while the run stays green and the count barely moves;
- a **library file omitted** from the load list makes the dependent module refuse to register (its
  dependency guard returns before `LibStub:NewLibrary`, library-stack-§7), so the host's setup file
  falls back to its stub and the suite happily measures **the stub** — green, and testing nothing.

Neither shows up in the pass/fail line. Derivation is what makes them impossible rather than merely
noticed.

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

### 11. A vendored kit is gated by a byte-identity test, not a remembered `diff`

Vendoring something you also author is an ongoing **sync**, not a one-time copy (library-stack-§7), and
a release checklist's manual `diff -r` is a step that gets skipped.

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
- **MUST** compare **raw bytes**, read in binary mode, with **no line-ending normalization**. A repo
  that pins its line endings has already had a copy arrive through a normalizing path; a check that
  normalizes cannot see it.
- **MUST** fail, not pass, when the gate **cannot run**. If the directory listing yields nothing, the
  check could not look — and a gate that goes quiet when it cannot look is worse than no gate.
- **MUST** name the file and say **where and how** it differs. *"The kit is out of sync"* on its own
  costs the next person the manual diff the test exists to remove.

The rule is here because the failure already shipped: a documentation pass improved `testkit/README.md`,
did not re-vendor it, and released the divergence with **three documents asserting the gate was
passing**. Both copies keep working when they drift, so both suites stayed green (anti-patterns #45).

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
