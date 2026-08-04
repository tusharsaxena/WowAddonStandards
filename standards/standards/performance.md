> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Performance instrumentation & measurement

Every Ka0s addon **MUST** be able to answer *"how much does this addon cost, and is this cost even ours?"* on demand, in a live client, in a form the user can paste back. That question cannot be answered from WoW's built-in Addon Profiler alone: the profiler bills a **shared** library's dispatch frame to whichever addon created it, so enabling and disabling addons moves the blame around, and the first-alphabetical Ace addon in an install absorbs cost that belongs to its siblings. The only trustworthy answer comes from an A/B on the **same fight** with load order and shared-frame ownership held fixed — which is what the harness this section mandates provides.

**Adoption strength.** **MUST** for the **wiring** — vendor the instrumentation lib, create one instance at load, expose the `perf` verb, declare `<Addon>PerfDB`, implement the `suspend`/`resume` contract. **SHOULD** for **coverage** — which hot paths get buckets is genuinely addon-specific, and some addons have almost no hot path. MUST on the wiring is what makes captures comparable across the collection and makes *"run `/<slash> perf` and send me the JSON"* true of **any** Ka0s addon.

### 1. The instrumentation lib

The measurement harness is a **Ka0s-owned shared library**, not per-addon code. Addons **MUST NOT** hand-roll a private probe.

- **MUST** vendor **`LibKa0s-Perf-1.0`** (the `Perf` module of `LibKa0s`) under `libs/LibKa0s/`, listed directly in the TOC's `# Libraries` section after Ace3 (toc-file-§4, library-stack-§7).
- **MUST** create **one instance per addon at load**, from a descriptor, and stash it on the namespace — resolved **silently**, then guarded: `local lib = LibStub and LibStub("LibKa0s-Perf-1.0", true)`, and `NS.Perf = lib:New(descriptor)` only `if lib`. A bare `LibStub(major)` **raises** when the major is absent, and the silent form without the guard indexes `nil` — either one errors on exactly the path the next bullet exists to make survivable. In its own core file (`core/PerfSetup.lua`), positioned in the TOC **before** any module that takes `local Perf = NS.Perf` as a load-time upvalue.
- **MUST** degrade rather than error when the lib is absent: the setup file falls back to a stub carrying every member the addon actually calls (the hot-path gate field, the bracket sink, and whatever the slash layer and the show-decision ladder touch) so a missing diagnostics harness cannot break the addon's own function. A stub that omits a member the slash layer calls is not a fallback — it is a crash moved to a rarer code path.
- **MUST NOT** share a frame between instances. Every frame the harness creates — the sampler, the step panel — belongs to the calling host. A lib-level shared frame reproduces the exact attribution pathology the harness exists to defeat: the measuring instrument corrupting the attribution it was built to fix (anti-patterns #44).
- The lib depends on **LibStub and `LibKa0s-Core-1.0`** — for secret-safe stringification and the shared window skin — and on **no addon framework**: no AceEvent, AceTimer, or AceGUI. The Ace-free half is the property to preserve when extending it, not an accident, because it is what lets the harness be adopted by addons that are not on the Ace substrate. The Core dependency costs nothing there, since Core is vendored in the same whole-folder copy and depends on LibStub alone; it is declared as a **minimum minor floor**, and Perf refuses to register at all when the floor is unmet rather than running half-wired (library-stack-§7).

### 2. The bracket idiom (MUST)

Instrumentation lives at the addon's own entry points, as a gated bracket around the work:

```lua
local Perf = NS.Perf                                    -- load-time upvalue, not an NS lookup

local function doRepaint()
    local t0 = Perf.on and debugprofilestop()
    -- ... the work ...
    if t0 then Perf.Note("repaintPass", debugprofilestop() - t0) end
end
```

- **MUST** use this exact shape. When capture is off it costs **one upvalue read, one field read and one boolean test** — no call, no table lookup through `NS`, no allocation. It is the same gating discipline the debug sink follows (debug-logging-§4).
- **MUST** keep the gate a plain **boolean field** on the instance and the sink a plain **dot-callable** function. A colon method, a metatable `__index`, or an accessor on the hot path defeats the point.
- **MUST NOT** allocate, concatenate, format, or call anything else inside a bracket while capture is off. Building a label, a table, or a string "ready for when capture starts" is an unconditional cost paid on every frame forever (anti-patterns #43).
- **MUST** treat the offline runner's zero-overhead scenario (performance-§9) as the **required evidence** for this rule. The claim "instrumentation is free when off" is not a comment; it is a measured, committed number.
- **MUST** add `debugprofilestop` to `.luacheckrc`'s `read_globals` (lint) — the bracket call sites are addon code and are linted, even though the lib under `libs/` is not.

### 3. Bucket declaration, including nesting (MUST)

Buckets are **declared in the descriptor**, in report order, and a bucket that runs inside another **declares its parent**:

```lua
buckets = {
    { key = "absorbEvent" },                          -- the event handler
    { key = "repaintPass" },                          -- one coalesced pass over every unit
    { key = "paintBar",   within = "repaintPass" },   -- per bar, inside the pass
    { key = "appearance", within = "repaintPass" },
},
```

- **MUST** declare every bucket the addon brackets, so the report renders in a stable, meaningful order rather than `pairs()` order.
- **MUST** declare nesting with `within` rather than explaining it in prose. A reader — human or agent — comparing two captures months apart cannot be expected to know which totals overlap.
- **MUST NOT** sum a parent bucket and its children. Nested totals are not disjoint; the parent already contains the child's time. The report labels this structurally, and a bucket set with no nesting says nothing rather than printing a hollow disclaimer.
- **SHOULD** bracket the addon's real hot paths and nothing else: the event handler that fires per combat-log event, the coalesced repaint/render pass, and the per-item work inside it. Bracketing a settings read that runs twice a session adds a row that will always read `0.000`.
- A bucket that no bracket ever reaches is a **lie in every report**. The addon's own test suite **MUST** pin that each declared bucket is actually reached (testing, performance-§9).

### 4. The `perf` slash verb (MUST)

`perf` is a **reserved verb** in every Ka0s addon (slash-commands-§2).

- **MUST** dispatch through the addon's own ordered `NS.COMMANDS` table like every other verb (slash-commands-§3), with the mandated cyan tag on its output (slash-commands-§4).
- **MUST NOT** be registered by the library. The lib exposes a command entry point that **returns lines**; the host prints them through its shared printer (events-frames-taint-§8). This keeps the addon's slash surface schema-driven and owned by the addon, and keeps the lib usable by third parties who do not follow the Ka0s command pattern.
- **MUST** make a bare `/<slash> perf` the **entry point to a run**, not merely a status line: it prints the current phase and opens the guided step panel. A capture protocol whose first step is a command you have to already know is a protocol nobody follows.
- **SHOULD** drive the run from a **clickable step panel** that offers only the next legal step. Ordering matters — arming the second measurement window before the pull, or reloading mid-run, silently ruins a capture — and a numbered list printed to chat scrolls away the moment combat starts. A panel that cannot be operated out of order cannot be operated wrongly.
- The panel is the lib's, styled by the host: the addon passes a decoration hook and gets its own close button and chrome (debug-logging-§12).

### 5. `<Addon>PerfDB` — the capture ring (MUST)

- **MUST** declare a **second top-level SavedVariables global**, `<Addon>PerfDB`, in the TOC (toc-file-§1, toc-file-§2) and hand its **name** to the lib in the descriptor. This is the one sanctioned non-AceDB SV global (savedvariables-§4).
- **MUST** keep it **outside the AceDB tree**. A capture ring inside the profile tree is copied by "copy profile", wiped by "reset profile", and swaps out from under a running capture on a profile switch — none of which is wanted from a diagnostics store.
- **MUST** be a bounded ring (a small number of most-recent captures, default 10). These are diagnostic snapshots read by hand, not telemetry.
- **MUST** be declared in `.luacheckrc`'s `globals` with a comment, like the addon's own SV global (lint).

### 6. The suspend / resume host contract (MUST)

The lib owns the state and the announcement; the **host** owns what "inert" means. Both halves of this contract have cost a real capture when broken.

- **MUST** make the addon **inert without a `/reload`**: unregister its event frames, cancel any queued work, and stop producing output. Reloading or disabling an addon **shifts shared-frame ownership**, which is precisely the confound that makes the built-in profiler useless for this question — so the measurement's independent variable has to be *"does our code run?"* and nothing else.
- **MUST** enforce visibility **at the source** — a suspended check inside the addon's own show-decision ladder — rather than by imperatively hiding frames. Hidden frames come back: a combat transition, a target swap, or a settings change re-shows a bar behind suspend's back, and the suspended arm then measures the addon still working.
- **MUST** restore from **current state** on resume, not from a snapshot taken at suspend time: rebuild per-unit event registrations from the enabled set as it is now, so a setting changed while suspended comes back correctly.
- **MUST NOT** persist the suspended flag. It is session-only; a suspended addon that stays suspended across a `/reload` is indistinguishable from a broken one.
- **MUST** resume **before** saving or reporting when a run ends. The second measurement arm leaves the addon inert, and with no manual resume verb the only other way back is a `/reload` — so an error in persistence or formatting **MUST NOT** be able to strand the addon dead for the rest of the session.

### 7. The capture protocol (MUST)

A capture is two **combat-gated windows** over comparable fights, differing only in whether the addon's code runs:

1. **Clean arm first** — the addon under test plus the stock UI, everything else disabled. This is the measurement that says what the addon costs.
2. **Suspend as the finer second arm** — same session, same fight, same load order, addon inert.

- **MUST** open and close each window on the **player's combat state**, not on a timer and not on the combat *events*. Suspend unregisters the addon's event frames, so the suspended arm would never see `PLAYER_REGEN_DISABLED` fire; the harness polls the cheap unit-combat call on a frame that exists only during a run (events-frames-taint-§2).
- **MUST NOT** compare arms taken with different addon sets, or across a `/reload`. Both change shared-frame ownership, and the resulting delta describes the environment rather than the addon.
- **SHOULD** run both arms at the same target, back to back, somewhere with no other players. Combat gating makes the arms equal in **duration**; it cannot make them equal in **environment**. A busy city square is not a repeatable arm, and a delta whose sign is backwards (the suspended arm reading *slower*) is the tell that the environment moved.
- **MUST** read the **bucket figures** as the addon's cost, and treat the frame-time delta as **unresolved** below the harness's measured run-to-run spread. A per-frame delta is a difference of two noisy aggregates; the buckets measure the addon's own code directly.
- **SHOULD** capture and store the run's context — character, spec, level, zone, group size — with the record. A capture read back weeks later is uninterpretable without knowing whether it was a solo dummy or a 20-man.

### 8. Record schema and `docs/perf-runs/` (MUST)

- **MUST** emit records in the **library's versioned record schema**, whose field-by-field contract lives with the lib. The addon does not define the shape; one reader handles a record from any Ka0s addon, which is the point.
- **MUST** stamp the emitting addon and its version into the record, so a record identifies itself outside the file it came from.
- **MUST** commit captures worth keeping under **`docs/perf-runs/`**, named `<YYYY-MM-DD>-<source>-<label>.json`, with a `README.md` in that directory documenting the naming, a schema summary, and a pointer to the lib's canonical contract. The directory is **standing and cumulative** — not tied to one investigation — so runs compare across addon versions.
- **MUST** treat committed records as **evidence**: the raw capture outlives the write-up that interprets it, and an interpretation without its record is an assertion.
- **SHOULD** write the interpretation up under `docs/investigations/<YYYY-MM-DD>-<topic>/` when a capture is used to answer a question, and treat dated investigation bundles as frozen once written (audit-review-history).

### 9. The offline scenario runner (`tests/perf.lua`)

A second, **offline** harness measures what a live client cannot measure repeatably: allocation and call counts per iteration of a hot path.

- **MUST** live at `tests/perf.lua`, run as `lua tests/perf.lua`, and stay **outside the green gate** (testing-§4). It is a measurement tool, not a test of correctness, and it is not run before every commit.
- **MUST NOT** assert on **wall-clock time**. Timings vary with the machine, the CPU governor, and what else is running; an assertion on them is a flake generator that trains people to ignore the suite.
- **MUST** assert only on **deterministic quantities** — API call counts and bytes allocated per iteration, isolated by a full collect either side of the measured loop.
- **MUST** ship a **zero-overhead scenario** that runs the addon's hottest bracketed path with capture **off** and pins that it allocates no more than the same path with the instrumentation absent. This is the evidence performance-§2 requires; without it, "free when off" is an unverified claim.
- **SHOULD** keep the scenarios per-addon. They are about that addon's own hot paths, so they stay in the addon rather than moving into the shared lib.
- Scenario output **SHOULD** state plainly that timings are for orientation only — compare scenarios within a run, never across machines.

### 10. Complexity reporting (MUST ship; refreshed at release)

The complexity report is the collection's standing answer to *"where is this addon getting hard to change?"* — and its value is almost entirely in the **difference between two releases**. One report is a page of numbers nobody acts on; the same path showing a function that went from CCN 9 to CCN 24 since the last tag is a finding with a name attached. That is why this section fixes three things that a bare "run `lizard` sometimes" left open: **the path**, **the exact invocation**, and **the moment it is regenerated**. Two reports produced by different invocations are not comparable, and a report nobody regenerates is a fossil that reads like a fact.

- **MUST** commit the report at **`docs/complexity.md`** — one file, **overwritten in place**, never dated and never a directory. The **git history of that single path is the trend line**; a `docs/complexity/<YYYY-MM-DD>.md` pile would scatter across files the one comparison the report exists to make. It is a required topic-detail doc (documentation-§3).
- **MUST** generate it with this exact invocation, run from the repo root:

  ```bash
  lizard -l lua -x "./libs/*" -x "./tests/_kit/*" .
  ```

  The two exclusions are the **vendored** trees — `libs/` and the shared harness at `tests/_kit/` are not this addon's surface (library-stack-§7, testing-§1), and including them swamps the addon's own numbers with library code that no consumer may edit. The addon's **own** `tests/` are measured: a test file that has become as tangled as the module it covers is exactly the signal this report is for. Do not add flags, do not re-tune thresholds per addon, and do not narrow the path to a subfolder — a locally "improved" invocation produces a report that cannot be diffed against the one before it, which costs more than any flag gains.
- **MUST** carry a generated-file header naming the tool version, the date, the command and the standard version, so a reader can tell staleness from a glance and reproduce the run without guessing:

  ```markdown
  # Complexity report

  <!-- GENERATED — do not hand-edit. Regenerate per performance-§10. -->

  - **Generated:** <YYYY-MM-DD>
  - **Tool:** lizard <version>
  - **Command:** `lizard -l lua -x "./libs/*" -x "./tests/_kit/*" .`
  - **Standard:** v<X.Y.Z>
  ```
- **MUST** carry a **`## Watch list`** above the raw output, naming every function `lizard` warned on (its default thresholds: CCN > 15, length > 1000, parameters > 100) and every file in layout-§1's **1000–1500 LOC on-notice band**, each with a one-line disposition — *accepted and why*, *peel next*, or *already tracked as `<deviation-id>`*. The raw table alone gets skimmed; a short list with dispositions is what actually gets read, and it is what makes the next release's diff meaningful. An empty watch list is a **result** — write "None." rather than dropping the heading.

#### The checkpoint: release, not commit

- **MUST NOT** gate commits on it. It is a **report**, read when deciding where to refactor — a threshold that fails a build turns a useful signal into an obstacle to route around, and cyclomatic complexity is a hint rather than a verdict. A pre-commit complexity gate is the fastest way to teach a collection to reach for `--no-verify`, after which the gate protects nothing and the habit remains.
- **MUST** regenerate the report and review its diff **as part of every release** — in the same change that bumps the version and rolls the README's `## What's new` and `## Version History` forward (versioning-git, documentation-§1), **before** the tag. This is the checkpoint: releases are already the moment the addon is looked at whole, they are infrequent enough that the diff carries signal, and the regenerated report lands in the release commit where the trend line stays readable.
- **MUST** record, in that release's watch list, any function that **newly crossed** a `lizard` threshold or any file that **newly entered** the 1000–1500 band since the previous report, with its disposition. Degradation that is noticed and knowingly accepted is a decision; degradation that is regenerated over in silence is the report failing at its only job.
- **SHOULD** regenerate mid-cycle when a change is what pushes a function over — recording it with the change that caused it is worth more than rediscovering it at release, when the author has moved on and the cause is one commit among thirty.
- `lizard` is an optional local dev tool, like `luacheck` (see DEPENDENCIES.md, documentation-§7). **Absent tooling means the report is stale, not that the addon is non-compliant** — but the staleness **MUST** be visible: leave the previous report committed with its original header (which dates itself), and say so in the release notes rather than deleting the file or hand-editing its numbers. A hand-edited complexity report is worse than an absent one, because it reads as measured.
