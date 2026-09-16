> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Library stack

### 1. Mandatory libs (every Ace3 addon)

**"Mandatory" means mandatory *when used*, and library-stack-§3's prune rule governs this table.** What follows is the set a Ka0s addon vendors *once it reaches the lib* — the canonical Ace3 substrate for this collection, not a floor every addon carries whether it touches it or not. Read as a floor it contradicts §3's "vendor what you use, nothing more" outright, and an addon caught between the two halves cannot comply with either; the note below the table is the instance that proved it.

| Lib | Purpose | Vendored |
|---|---|---|
| LibStub | lib registry | always |
| CallbackHandler-1.0 | Ace3 dependency | always — reached by Ace3's own files, never by yours |
| AceAddon-3.0 | addon + module lifecycle | always |
| AceDB-3.0 | profile / char / global SV | always |
| AceEvent-3.0 | event subscription | when used |
| AceTimer-3.0 | timers | when used |
| AceConsole-3.0 | slash registration | when used |
| AceGUI-3.0 | options panel widgets | when used — including where a lib you vendor is what reaches it |
| LibDataBroker-1.1 | the launcher object (one per addon) | always — every addon ships a launcher (launcher-§1) |
| LibDBIcon-1.0 | the minimap button drawn from that object | always — same |

Every lib the addon does vendor is **vendored in `libs/` and committed** (library-stack-§3). Nothing in this table obliges an addon to vendor a lib nothing in its install reaches, and "when used" is decided by library-stack-§3's reachability test, not by eye.

**The case this wording was written for.** PrettyChat reaches neither AceEvent-3.0 nor AceTimer-3.0: it starts no timers, and the two combat-boundary events its visibility watcher needs go on a plain frame it creates lazily and drops again (`PrettyChat/modules/Override.lua:67-80`, argued in place). Under the old table it had to vendor both; under §3 it had to vendor neither; it could not do both, so it filed the collision against **itself** — audit `PC-52` of 2026-08-04, carried since as a deviation row at `PrettyChat/docs/ARCHITECTURE.md:230` whose re-check trigger is, in as many words, "the next `library-stack` edit". This is that edit. An addon holding a ratified-deviation row for a contradiction that lives upstream is exactly the graveyard the register exists to prevent, manufactured here rather than there; the row is retired, not re-argued, and PrettyChat vendoring six of the eight **Ace3** rows above is compliant. (The table's last two rows, LibDataBroker-1.1 and LibDBIcon-1.0, are not Ace3 and are not "when used": every addon reaches them, because every addon ships a launcher.)

### 2. Common optional libs

| Lib | When |
|---|---|
| LibSharedMedia-3.0 | any addon with user-facing fonts/textures/sounds |
| AceDBOptions-3.0 | only if Profiles sub-page is wired |
| AceConfig-3.0 / AceConfigDialog-3.0 | **only if** the addon ships a Profiles sub-page using AceDBOptions; otherwise the canonical pattern is Blizzard Settings + raw AceGUI |
| LibDualSpec-1.0 | spec-aware profile switching |
| LibSerialize | export/import |
| LibDeflate | export/import compression |

**LibDBIcon-1.0 left this table.** It and LibDataBroker-1.1 are now §1 rows, vendored *always*: every Ka0s addon ships a launcher (launcher-§1), so neither is optional any more.

### 3. Vendoring over externals

Ka0s addons **MUST ship every library vendored in `libs/` and committed to git**. The addon must be fully self-contained — installable by copying the folder into `Interface/AddOns/` with no packager step required to obtain libraries.

- **MUST** vendor all Ace3 and third-party libs under `libs/` and commit them. **MUST NOT** use `.pkgmeta` `externals:` to fetch libraries.
- **MUST** use the standard folder-per-lib layout (`libs/AceAddon-3.0/AceAddon-3.0.xml`, `libs/LibStub/LibStub.lua`, …) and load libs **first** in the TOC — the lib's `.xml` where it ships one (it pulls the lib's `.lua` + any sub-files), the `.lua` otherwise.
- **SHOULD** copy the folder-per-lib set from an existing Ka0s addon's `libs/` so lib versions stay consistent across the suite. Pull libs the suite doesn't yet vendor (LibDataBroker-1.1, LibDBIcon-1.0, …) from a current retail install or the upstream release.
- **MUST** vendor every lib the addon **reaches at runtime**, and only those — vendor what you use, nothing more. Prune dead weight (**except a Ka0s-owned umbrella such as `LibKa0s`, whose ship payload is the whole folder even where the addon wires up only some of its modules — library-stack-§7, anti-patterns #48**) (e.g. AceConfig where only Profiles needs it; AceLocale/AceBucket/AceComm/AceHook/AceSerializer/AceTab where unloaded). This rule is what qualifies library-stack-§1's table: a lib in it that nothing reaches is not vendored, and a lib outside it that something reaches is.
- **"Reaches" is not "writes `LibStub("X")`" (MUST).** This rule's test used to be the addon's own `LibStub` call, and taken at its word it prunes libs every addon in the collection needs — which is how it ended up contradicting §1's table instead of governing it. There are **three** ways a vendored lib gets reached, and only the first is a `LibStub` call in the addon's own source. Clear all three before calling a lib dead:
  1. **The addon `LibStub`s it directly** — `LibStub("AceGUI-3.0")`, `LibStub("LibSharedMedia-3.0")`. The only case the old wording covered.
  2. **An Ace3 mixin name string**, which AceAddon resolves through `LibStub` on the addon's behalf and which greps as a bare quoted string, not as a call: `AceAddon:NewAddon(NS, addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")` (`BankLedger/core/BankLedger.lua:4`, `WhatGroup/core/WhatGroup.lua:31-33`) and `addon:NewModule("Castbar", "AceEvent-3.0")` (`KickCD/modules/Castbar.lua:68`). Neither BankLedger nor WhatGroup writes `LibStub("AceTimer-3.0")` anywhere, and both would break without AceTimer-3.0 vendored.
  3. **A lib you vendor reaching another lib you vendor.** `libs/LibKa0s/Options.lua:306` takes `LibStub("AceGUI-3.0", true)`, so an addon whose only options surface is `LibKa0s-Options-1.0` still vendors AceGUI-3.0 without ever naming it. CallbackHandler-1.0 is the same case at its limit: **no** addon in this collection `LibStub`s it — the count is nine of nine — and all nine load Ace3 files that do.
  The sweep is therefore two greps, not one: `grep -rn '"X"' --include='*.lua' . | grep -v '/libs/'` for cases 1 and 2, then the same pattern **inside** `libs/` for case 3. A single `grep -rn 'LibStub("X")'` outside `libs/` answers only case 1 and will tell you to delete a lib the addon cannot load without.
- **MAY** vendor an addon-private micro-lib (e.g. an 80-line object-pool mixin) the same way.

### 4. Lib registry pattern

- **SHOULD** call `LibStub("X")` exactly once at addon load and stash on the addon's namespace: `NS.LSM = LibStub("LibSharedMedia-3.0")`. **SHOULD NOT** call `LibStub` from per-frame code.

### 5. Forking Ace libs is forbidden

- **MUST NOT** privately fork an Ace3 lib. Private lib forks seen in some large UI suites (renamed copies of Ace3) block on every Ace3 update and are an anti-pattern.
- **MUST** extend AceGUI via `AceGUI:RegisterWidgetType("Ka0s_X", ...)` if a custom widget is needed. That sanction is about a **new** name the addon defines; **re-registering an existing** widget type writes into a process-global table and is `LibKa0s`'s to do, never an addon's (library-stack-§9).

### 6. No addon-suite dependencies (self-contained)

A Ka0s addon **MUST** stand on its own. The vendoring rule (library-stack-§3) makes it self-contained with respect to **shared libraries** (LibStub-registered code embedded under `libs/`); this rule makes it self-contained with respect to **other addons** — i.e. standalone addons and addon *suites* such as ElvUI, EllesmereUI, DBM, WeakAuras, BigWigs, Plater, etc. Suites are **not** dependencies. The distinction: a **library** is LibStub-registered code you vendor and own; a **suite** is a separate installed addon with its own lifecycle, and you never require it.

- **MUST NOT** hard-depend on any addon suite or standalone addon: no `## Dependencies:` / `## RequiredDeps:` naming one, and no code path that assumes a suite's globals, API, callbacks, or frames exist (`ElvUI`, `DBM`, `WeakAuras`, `BigWigs`, …).
- **MUST** be fully functional and behave **identically** with no other addon installed. Every texture, font, sound, and layout the addon needs is either vendored under `media/` (layout-§3) or drawn from LibSharedMedia's built-ins — **MUST NOT** read a suite's media files, textures, fonts, or SavedVariables, and **MUST NOT** rely on a suite having skinned or repositioned any frame.
- **MUST NOT** embed, copy, or private-fork a suite's code, media, or a suite-renamed Ace library (this is the library-stack-§5 fork ban applied to suites — depend on nothing you did not vendor and own).
- **MAY** *optionally* integrate with a suite that happens to be present — e.g. register an ElvUI/EllesmereUI skin for the addon's own frames, or subscribe to a DBM/BigWigs timer callback — **only when all** of the following hold: (a) the integration is presence-guarded (`C_AddOns.IsAddOnLoaded("ElvUI")`) and never assumes the suite loaded; (b) the suite is listed in `## OptionalDeps:`, never `## Dependencies:`; (c) with the suite absent the addon falls back to its own styling/behavior with no loss of core function. This is the same soft-fallback discipline required for optional libraries (library-stack-§3–§4): the addon is whole on its own and the integration is pure enhancement.

### 7. Ka0s-owned shared libs

Some shared code is **authored inside the collection** rather than pulled from the ecosystem. These are still **libraries** in the library-stack-§6 sense — LibStub-registered code you vendor and own, never a dependency addon — and every rule above applies. This section adds the rules that only bite when the library's author and its consumers are the same person.

| Lib | Purpose | Source | Embedded as |
|---|---|---|---|
| `LibKa0s` | umbrella for Ka0s-owned shared modules, vendored at `libs/LibKa0s/` exactly as Ace3 is; **one LibStub major per module**, e.g. `LibKa0s-Perf-1.0` (the performance harness, performance-§1) | <https://github.com/tusharsaxena/LibKa0s> — the repo's inner `LibKa0s/` folder is the ship payload; `tests/`, `testkit/` and `docs/` stay upstream | vendored |

Vendor from **that repo's** ship folder, not from a sibling addon's `libs/` — a sibling's copy may itself have drifted (anti-patterns #45).

**The modules.** `LibKa0s` ships **ten LibStub majors across fourteen files** — `Core`, `Env`, `Item`, `Pool`, `Media`, `Widgets`, `DebugLog`, `Slash`, `Options`, `Perf` — loaded by one aggregate `LibKa0s.xml`, plus one non-code payload (`media/`, library-stack-§8). The file count is not the major count and never was: `Options` spans four files and `Perf` two. Count it against `LibKa0s/LibKa0s.xml`'s `Script` entries, which is the one list that cannot be a release behind:

| Major | Files | What it owns |
|---|---|---|
| `LibKa0s-Core-1.0` | `Core.lua` | secret-safe stringification (`IsConcatSafe`, `SafeToString`), the shared window skin (`SKIN`, `ApplySkin`, `MakeCloseButton`), and a prefixed chat printer built from a descriptor |
| `LibKa0s-Env-1.0` | `Env.lua` | the handful of client facts every addon reads, read one way — TOC metadata, the addon's own version with a caller-supplied fallback, and the player's current map ID and zone |
| `LibKa0s-Pool-1.0` | `Pool.lua` | the free/active widget pool, in both shapes — the array `active` list and the keyed map that gives a host an O(1) index into it (the two are not interchangeable) |
| `LibKa0s-Item-1.0` | `Item.lua` | item identity as four primitives and no policy: id and quality from a link, the quality label, and the cache-then-callback load |
| `LibKa0s-Media-1.0` | `Media.lua` (+ `media/`) | the shared art and type every Ka0s addon draws with — the icon set, the monospace face and the bar textures, the paths that reach them, and the LibSharedMedia registration (library-stack-§8) |
| `LibKa0s-Widgets-1.0` | `Widgets.lua` | the collection's flat dropdown and the single popup menu every instance of it drops, the shared copy window, and **`ReorderList`** — the drag-to-reorder list every ordered setting in the collection is required to use (options-ui-§18), which owns the hamburger handle, the bounded row box (`Widgets.ROW_BOX`, options-ui-§8), the drag ghost, the insertion line, the index arithmetic and the section-boundary clamp while the row's contents stay the consumer's; every piece of art arrives as a parameter, so it needs no media module |
| `LibKa0s-DebugLog-1.0` | `DebugLog.lua` | the on-screen debug console and its copy window, both line formatters, the 500-line buffer, and the enable seam (debug-logging) |
| `LibKa0s-Slash-1.0` | `Slash.lua` | the slash dispatcher, the help renderer, the `list`/`get`/`set`/`reset` schema CLI, and the type-aware value parser (slash-commands) |
| `LibKa0s-Options-1.0` | `Options.lua`, `OptionsWidgets.lua`, `OptionsCompose.lua`, `OptionsScroll.lua` | the Blizzard settings-canvas panel shell, the widget makers for the schema row types, **the composers that emit the canonical font, border, bar, color-pair and master-controls row sets** rather than leaving nine addons to hand-write them (options-ui-§15–§16), the two-column flow engine, and the always-shown scrollbar patch (options-ui) |
| `LibKa0s-Perf-1.0` | `Perf.lua`, `PerfPanel.lua` | the A/B performance capture harness and its guided step panel (performance) |

Hand-rolling any of these inside an addon — a private debug console, a private options toolkit, a private slash dispatcher, a private test harness — is forking the toolkit, and is exactly the duplication the umbrella exists to end (anti-patterns #47).

**Ship payload vs adoption (MUST).** These are two different questions and they get opposite answers. What you **copy** is all of it; what you **wire** is only what you use.

- The **ship payload is the whole folder, always**. Re-vendoring **MUST** copy the source repo's entire inner `LibKa0s/` folder over `libs/LibKa0s/` — every file, every time. **MUST NOT** copy individual module files, or "just the one that changed" (anti-patterns #48). A partial copy is precisely how cross-major minor skew gets manufactured: the addon ends up carrying a new `Perf.lua` over an old `Core.lua`, or a `Core.lua` that never arrived at all — and nine of the ten majors refuse to register without Core, so a partial copy costs the addon modules it was not even touching.
- The TOC **MUST** list the single aggregate `libs\LibKa0s\LibKa0s.xml` (toc-file-§5), which is itself the file list. Naming module files individually in the TOC is the same partial-vendoring mistake spelled differently, and it drifts the moment the library gains a file.
- **Adoption is per module, on the addon's own schedule.** An addon wires only the modules it actually uses — one setup file per module, each resolving its major with `LibStub(major, true)` and degrading to a stub when it is absent (performance-§1 is the worked example). Carrying the source of a module the addon never wires costs a few kilobytes of never-executed file and buys the guarantee that no consumer ever has to reason about which half arrived.
- **MUST NOT** list `LibKa0s` under `## Dependencies:` — a Ka0s addon works with no other addon installed (library-stack-§6).
- **`media/` IS part of the ship payload**, and it is the first part of it that is not code. Every consumer therefore carries the icon set, the monospace face and the bar textures whether or not it wires `LibKa0s-Media-1.0` — the whole-folder rule already required this the day the folder appeared, and library-stack-§8 is about what follows from carrying it.
- The library repo's `testkit/` is **not** part of the ship payload. It is the headless test harness, vendored into a consumer's `tests/_kit/`, and **MUST NOT** be placed under `libs/`: everything under `libs/` is TOC-loadable and ships to the player's install, and a test harness has no business there (testing).

- **MUST** use **one LibStub major per module**, not one for the whole umbrella. LibStub picks the highest **minor of a major**: under a single major, an addon vendoring a copy that predates a module would be served a lib missing that module, and every host would need presence guards. Per-module majors keep version skew narrow and make adding a module purely additive — each addon adopts on its own schedule instead of in a lockstep migration.
- **MUST** keep a **module's descriptor / API contract additive-only** within a major. A field may be added in a later minor, never removed or repurposed: once several addons have vendored copies, you cannot know who holds what.

**Inter-module dependencies (MUST).** **Nine of the ten majors** need `LibKa0s-Core-1.0` — for secret-safe stringification, the window skin, or both — i.e. every module except `Core` itself, and two of the nine gate on it without calling a single member, so that a host holding a partial payload gets *every* module absent rather than a mixed set. There is exactly one second edge: `LibKa0s-DebugLog-1.0` also floors on `LibKa0s-Widgets-1.0`, since its copy window is that module's. The dependency is declared and enforced in exactly one direction.

- A module that needs another **MUST** declare a **minimum minor floor** for it, and **MUST `return` before `LibStub:NewLibrary`** when that floor is unmet — dependency missing, or present at a lower minor. The major is then **never registered**, so `LibStub("LibKa0s-X-1.0", true)` yields nil and the module is **absent** rather than half-wired. The host's setup file sees the nil, says once that the library is missing, and falls back to its stub. That is the honest failure, and it is the only one a host can actually act on.
- **MUST NOT** negotiate in the other direction. A module **MUST NOT** feature-detect a too-old dependency and run a reduced version of itself, and a dependent **MUST NOT** patch a member onto its dependency to satisfy the floor. Half a module is a defect that surfaces at some arbitrary later call site, in the hands of a user; an absent module surfaces at load, where the fallback already lives.
- **Raising a floor is a breaking change to the VENDORING, not to the API.** Nothing in the signature moved, the library's own suite is green, and every consumer whose `libs/` still holds the older dependency loses the **whole module** until it re-vendors. A floor bump is therefore a re-vendor trigger, and **MUST** be called out as one in the changelog entry rather than left to be discovered in-game.
- **A multi-file major can fail at CALL time rather than at load time**, and this is the sharpest reason the payload is whole-folder. If the shell file loads and an attach file does not, the major still registers and `:New` still succeeds: the host is handed an instance that looks whole, and stays looking whole until something reaches the missing member — possibly a panel build away, possibly only on a page the user opens twice a year. A module **MAY** ship no-op fallbacks for members hosts are expected to call unconditionally, and **SHOULD** where a host would otherwise need a guard at every call site, but no arrangement of fallbacks makes a partial copy safe. Copy the folder.

**A vendored `libs/` folder is read-only (MUST).** The library is yours, which makes the temptation worse rather than better.

- **MUST NOT** edit anything under `libs/` — including a one-line fix that is plainly correct and plainly urgent. A library defect found while working in a consumer is a **finding to fix upstream and re-vendor**, never a local patch.
- The reason is the shape of the failure, not purity: the next re-vendor overwrites the patch silently, and the behavior it fixed comes back as a regression with **no cause anywhere in the consumer's history** — the change that reverted it was a file copy, not a commit anyone will find by reading the log. This is the library-stack-§5 fork ban applied to a library you own (anti-patterns #45).

**Vendor sync (MUST).** Vendoring a third-party lib is a one-time copy that stays stable for months. Vendoring a lib you also author is an ongoing **sync**, and the drift window is a single afternoon.

- The vendored copy **MUST** be **byte-identical** to the source repo's ship folder, whole-folder and file-for-file. `diff -r <LibRepo>/<Lib> <Addon>/libs/<Lib>` **MUST** be empty — which is also what catches a partial re-vendor, since a missing or stale file shows up in the same diff.
- A change to a Ka0s-owned lib **MUST** be followed by a **re-vendor commit in every consumer** that depends on it, and that commit **SHOULD** be its own so the sync is legible in history rather than buried in a feature diff.
- **This is the step that gets forgotten, and nothing about "the tests are green" will catch it**: the library's suite passes against the library, and the consumer's suite passes against a stale copy that still works. Both repos stay green while the copies diverge (anti-patterns #45). The `diff -r` check belongs in the audit's evidence set (`AUDIT.md`).
- **The consumer names the tag it vendored, in root `CLAUDE.md`** — `Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).` (documentation-§2 item 6). That line is not decoration: it is the **input** to the consumer-side vendored-payload gate (testing-§11), which resolves the named tag in the sibling checkout and compares both payloads against it. Without it the gate has no ref to compare to.
  - It lives in **`CLAUDE.md`, not `README.md`.** It answers *"which LibKa0s does this build carry?"* — a maintainer's question — and documentation-§1 forbids the player-facing README from carrying a vendored-library inventory at all, so a gate reading its input from the README would have been reading a file whose job is to stop mentioning it. `tests/_kit/vendor_sync.lua` has read `CLAUDE.md` since **LibKa0s v1.8.1 / testkit revision 9**, with **no fallback** to `README.md`: a repo that has not moved its line reads as having none and fails, naming `CLAUDE.md`.
  - The line **MUST** move in the **same commit** as the bytes, in both directions. A payload re-vendored past its line leaves a document asserting the wrong version; a line bumped ahead of the payload reads as done and is not.

**Module versioning (MUST).** The other half of the same rule, and the reason a missed sync fails silently instead of loudly.

- Each **file** within a module's major **MUST** carry a LibStub **MINOR** integer that increments on **every released change to that file**. LibStub compares those integers to pick a winner between vendored copies, so **a released change that skips its bump does not ship** — every host already carrying the old copy keeps running it, with nothing to say so.
- Files **MUST NOT** be bumped in lockstep. Bumping every file whenever any file changes discards the narrow-skew property that made per-module majors worth choosing.
- A multi-file major **MUST** pair its files by version, not merely by presence: a file that attaches to the module's main table **MUST** re-attach whenever the table underneath it came from a different copy, or a host ends up running one file from copy A and another from copy B — the mismatch the single-major layout exists to prevent.
- The library **MUST** publish the **live minor of every file** on its table (a `MODULES` registry or equivalent), so version skew is answerable at runtime rather than by reading source. With several consumers each carrying a copy, "which half came from where?" is a question someone will need answered from in-game.
- The lib repo's own **semver tag is a separate axis** from any file minor and **MUST NOT** be conflated with one (versioning-git).
- The lib repo **MUST** make the coupling mechanical rather than remembered: a test that fails when a file's minor and its changelog entry disagree, and a written release order ending in *re-vendor every consumer*. Remembered coupling fails on precisely the release where it matters — the small one, shipped in a hurry — and there is a working reference implementation of that test now (testing), so a lib repo leaving this to discipline is a choice rather than a constraint.

**What earns promotion into a Ka0s-owned lib (MUST).** anti-patterns #47 forbids hand-rolling what a
`LibKa0s` module already provides. This is the counterweight, and it is needed just as badly: the
opposite failure — promoting a shape that only *looks* shared — is harder to reverse, because the
additive-only rule above means a wrong abstraction is surface the library keeps forever.

A shape **MUST** clear all three bars before it moves upstream:

1. **Two or more consumers, with the same semantics** — not merely the same shape. Two addons filtering
   records is not two consumers of one filter; two addons calling `frame:SetPoint` through the same
   guard is.
2. **No per-consumer escape hatches.** If adopting it requires a behavior flag per consumer, those
   flags *are* the consumers' divergence re-encoded as configuration, and the library now owns a
   decision it cannot make. One optional presentation argument is fine; a flag that changes what the
   function *does* is the tell.
3. **A stable abstraction, not a coincidence of today's code.** Ask what would have to change for the
   shared version to be wrong, and whether that change is plausible this year.

And the rule that catches the most tempting mistake:

- **MUST NOT** promote on frequency alone. **High frequency plus low semantic content is the signature
  of a shape that should stay inline.** The collection's most-repeated shape is the optional-object
  guard (`if obj and obj.method then obj:method(...) end`) at 400+ sites across nine repos — and it
  must not be promoted, because a `CallIf(obj, "method", ...)` helper turns a compile-time method call
  into a stringly-typed lookup that is invisible to `grep`-for-callers and to `luacheck`, and because
  those guards exist for **three different reasons** (an API absent on this client build, an optional
  module not yet loaded, a headless mock with holes) that one spelling would erase at every site.
- **MUST NOT** promote a shape whose consumers disagree about **correctness**, as opposed to
  presentation. The worked example is the schema-migration runner, nominated from eight repos and
  rejected: those eight hold five incompatible variants that disagree on who stamps the version (the
  runner, or each step), when (per step, or once at the end), whether a failed step still stamps, and
  what a missing step does — and in one addon the premise is that the stamp **cannot be trusted at
  all**, because AceDB's defaults merge backfills `schemaVersion` to current the moment `db.global` is
  first read, masking a legacy account as already-current. A shared runner needs five escape hatches to
  own an eight-line loop, and the blast radius of getting it wrong is silent corruption of users'
  SavedVariables. **Duplication was the cheaper answer**, and the complexity win it was nominated for
  was available locally anyway (anti-patterns #55).
- **SHOULD** record a rejection with its reason where the next author will look, not just the
  acceptances. A candidate rejected once will be re-nominated — the shape really does look shared —
  and the reason is the only thing that stops the second attempt from succeeding.
- **A promotion into `Core` is not free** even when it is right: the other majors declare a **minimum
  minor floor** on Core, and raising a floor is a breaking change to the vendoring (library-stack-§7,
  above). So a helper added to `Core` **MAY** ship for hosts immediately while the library's own
  sibling modules keep their duplicate copy until a floor raise is being made for other reasons. That
  is a deliberate, documented duplication, and it **MUST** be commented as one at both copies rather
  than left to look like an oversight.

**Applicability — what binds the library repo itself (MUST).** Everything above governs how an *addon*
vendors and consumes a Ka0s-owned lib. The **library's own repository** — `LibKa0s` today — is also in
scope for this standard, but it is not an addon: it has no TOC, no player-facing README, no settings
panel and no install. Auditing it against the addon rule set manufactures findings the standard never
meant. The **three applicability lists** below are the ones an audit of a Ka0s-owned library repo uses
instead (`ADDONS.md` lists which repos those are); the *Substitutes* list that follows them answers a
different question — not whether a section binds, but what the library carries in place of the addon
artifacts the *Does not apply* list removes — and is not one of the three.

**The three lists are exhaustive, and the default is that a section applies.** Between them they
classify **every** section in `STANDARDS.md`'s Sections list, and an audit of a library repo may check
that mechanically. A section this standard gains later, and which nobody has thought about in a
library's terms, **applies unchanged** until it is placed in one of the lists — the default runs
toward the rule binding, because the failure mode of the other default is a section that governs
nothing anywhere and nobody notices. *Does not apply* is the only list that is an exception to that
default; the other two record how a section that binds is read here.

**Applies, unchanged:**

| Section | Why it binds a library repo |
|---|---|
| testing-§1, testing-§9, testing-§10, testing-§11 | The headless suite, the derived-and-pinned load lists, the versioning suite, and the kit-sync gate are the library's core quality contract — testing-§10 names this repo as the reference implementation for exactly that family of gates. |
| `lint` | `luacheck .` is 0 warnings / 0 errors here as everywhere. |
| `automated-tests` | The four out-of-game suites and the `docs/automated-tests/` record are repo-shaped, not addon-shaped. |
| `versioning-git` | Semver tags, branch and commit discipline. The repo's tag axis stays separate from any file minor (above). |
| `line-endings` | The library ships Lua into every consumer's client-bound `libs/` folder, so it is **client-bound** and takes the CRLF pin (`line-endings-§2`) and the canonical body of `line-endings-§5` unchanged — plus the `*.sh text eol=lf` carve-out for its own `testkit/run-automated-tests.sh`, which is the file the addons then vendor. It is named here rather than left to inference because a library repo has no `.toc`, and `line-endings-§2`'s discriminator would otherwise read it as non-client — which is the exact ambiguity that section exists to end. |
| localization-§5 | US English in authored comments, docstrings and strings — a British spelling vendored into eight consumers is eight findings. |
| documentation-§5 | The `filename-§N` citation scheme and documentation-§6's citation rules. |
| documentation-§7 | A root `DEPENDENCIES.md`: a new machine needs the toolchain list as much for a library as for an addon. |

**Does not apply:**

- **documentation-§1's player-facing README structure and badge row.** A library has no players. Its
  `README.md` is a consumer-facing document and is structured for that audience.
- **documentation-§2's addon `CLAUDE.md` stub as written.** The stub's shape assumes an addon; see the
  substitution below.
- **documentation-§3's `docs/` trio** — `ARCHITECTURE.md`, `testing.md`, `smoke-tests.md` — **the
  five verification-and-record docs** (`test-cases.md`, `performance.md`, `perf-analysis/README.md`,
  `automated-tests/README.md`, `automated-tests/RESULTS.md`) **and the whole topic-detail tier model**
  (Tier 1's `scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`, `data-flow.md`,
  `common-tasks.md`; Tier 2; `## Documentation map`). These describe an addon's runtime shape, its
  settings canvas and its in-game verification, and a library has none of them.
- **`toc-file`, `options-ui`, `slash-commands`, `preview-mode`, `launcher`, `savedvariables`, `packaging`.** There
  is no TOC, no settings canvas, no slash surface, no on-screen display, no minimap button or broker
  object, no SavedVariables file and no CurseForge package. Each of these binds the *consumer* that wires the module, and is audited there.

**Applies, read for a library repo:** these bind, and the only thing that changes is what the words
point at. They were absent from both lists above until this was written, and the cost of that silence
was not theoretical — the library repo's own two `layout-§1` cap breaches sat graded **Low** for
exactly the reason that nothing here said whether `layout` reached it (`LibKa0s/docs/audits/2026-09-07/02_DEVIATIONS.md:29`).

| Section | How it reads here |
|---|---|
| `layout` | The **cap and the band** (layout-§1) and the **casing** rules bind unchanged; a library's authored `.lua` is authored `.lua`. The `core/ defaults/ settings/ locales/ modules/` **skeleton** and the folder load order do not — a library has no TOC to order and no settings folder. Its shape is the payload folder plus `tests/`, `docs/` and `testkit/`, and `layout-§3`'s typed subfolder rule binds both `media/` folders it has — the payload's, which every consumer receives (library-stack-§8), and the repo's own. |
| `library-stack` | This section binds itself. `§7` is where the repo's own rules live — the payload shape, the API-document-per-minor contract, the three promotion bars, and this applicability block — and `§8` governs the media payload it ships. `§1`–`§6` are written for the *consumer* and describe acts the library repo does not perform: it vendors nothing — there is no `libs/` here, because the headless suite runs on the kit's mocks — so the mandatory table, the optional list, the vendoring rules and the registry pattern have no instance. `§5`'s no-forking prohibition and `§6`'s self-containment survive as constraints on what the payload may **contain**, and are audited as such. `§9` binds the library repo **directly** rather than by reading: the widget-type re-registration it forbids an addon to perform is one the library is required to publish, sentinel and all. |
| `architecture` | The module pattern and the closed message bus bind **inside** the library where it uses them; the namespace bootstrap and AceAddon registration (architecture-§1, §2) do not — a library registers with LibStub, not with AceAddon, and has no addon namespace to bootstrap. |
| `performance` | `performance-§10`'s `lizard` measurement and its release checkpoint bind, and the release gate in automated-tests counts a library's warnings like anyone's. The **wiring** MUST — a `PerfSetup.lua`, a `<Addon>PerfDB`, a `perf` verb — does not: there is no addon to wire it into and no slash surface to reach it from. The library **writes** the harness; it is measured by its consumers. |
| `compat` | Binds. A deprecated or cross-patch API call inside the payload is exactly the thing a single `Compat` owner exists for, and a shim scattered through ten consumers' vendored copies is the worst version of the problem this section describes. |
| `anti-patterns` | Binds, whole and unchanged. The entries keyed to an addon artifact (a TOC line, a SavedVariables key) simply have no instance here; nothing is exempted. |
| `public-api` | Binds, and is closer to load-bearing here than in any addon: a library major **is** a public API. Its surface is versioned by the file's own `MINOR` and its API document under `docs/api/` (above), which is the library's form of the `NS.API.v1` contract. |
| `debug-logging` | Binds where the library **draws** a console; the addon-side rule that log output goes to the console rather than the chat frame is inherited by every consumer through the module. |
| `events-frames-taint` | Binds. Combat lockdown, taint and frame pooling are properties of the client, not of the repo kind, and a library frame that taints taints every consumer at once. |
| `standalone-windows` | Binds to the window **chrome the library owns** — the normative Ka0s edge, the title-bar controls drawn from the shared catalog, the one close-button wrapper. A library repo has no window of its own to audit, so in practice this is checked at the consumer; the rule still governs what the payload draws. |
| `naming-cheatsheet` | Binds. The conventions table is about identifiers, and identifiers vendored into ten trees are ten copies of whatever was decided once. |
| `audit-review-history` | Binds: the frozen dated `docs/audits/` and `docs/reviews/` bundles, all **three** MUSTs on the deviation register — including the trigger-and-evidence evaluation, which a library repo needs most, since its register rows cite bundle dates and minors that move every tag — and the GitHub-issue decision store. The register's **home** moves — `documentation-§3` puts it in `docs/ARCHITECTURE.md`, which a library repo does not have, so it lives in the root `CLAUDE.md` alongside the documentation map (see *Substitutes*, below). |
| `documentation-§4` | Binds unchanged: **no root `TODO.md`**. `§3`'s trio and tier model do not apply here (above), but the reason `§4` exists does — a backlog belongs in the issue store (audit-review-history), where it can be triaged and closed, not in a file that rots at the root. So do `§4`'s siblings that the first list already names: `§5` keeping the docs in sync, `§6`'s citation rules, `§7`'s `DEPENDENCIES.md`. The `documentation` sections that do **not** bind are `§1`, `§2` and `§3`, and they are listed above. |
| `open-evolutions` | Binds in the only sense it binds anywhere: it is a record of recorded directions, not a rule an audit files against. A library-repo entry goes in it like any other. |

**Substitutes — the library repo MUST carry these instead:**

1. A root **`CLAUDE.md`** carrying `## Standards compliance (read first)`. Of documentation-§6's three
   places a standards reference lives, this is the only one that exists in a repo with no TOC
   `## X-Standard:` line and no player README badge row, so it is where the pointer goes.
2. A root **`DEPENDENCIES.md`** (documentation-§7, above — listed in both lists deliberately: it is the
   substitute *and* it is simply required).
3. A **`README.md` pointer to the standard**, naming the version the repo is written against.
4. A **`## Documentation map` in that root `CLAUDE.md`**, listing every `.md` under `docs/` in one
   table and naming the frozen directories once each. The **tier model** above does not bind a library
   — four of Tier 1's six docs have no subject here, since there is no settings canvas, no
   SavedVariables and no in-game pipeline — but the register's *purpose* survives the tiers that
   inapplicability removes: a reader must be able to tell a doc that is missing from one that was
   never meant to exist, and no page should be reachable only by listing the directory. It goes in
   `CLAUDE.md` for the same reason the deviation register does: `documentation-§3`'s home for both is
   `docs/ARCHITECTURE.md`, which a library repo does not have, and a register with no file is a
   register nobody keeps. An audit checks it in both directions — every file has a row, every row
   resolves — and checks nothing about tiers.

A root **`CHANGELOG.md` is required** here and forbidden at an addon root — see documentation-§1, and
testing-§10, whose versioning suite asserts that the changelog accounts for the version every file is
at and has nowhere else to look.

### 8. The shared media library (MUST)

`LibKa0s-Media-1.0` ships the **art and type this collection draws with** — an icon set, a monospace
face, and a family of statusbar textures — inside the vendored payload, at `libs/LibKa0s/media/`.
Introduced in **LibKa0s v1.9.0**; the icon path spelling and the texture family settled at v1.9.1 and
v1.9.2.

**Every Ka0s addon ships it, and that is not a choice it makes.** The payload is whole-folder
(library-stack-§7), so `media/` arrives with `Core.lua` in the same `cp -r`. The consequence is the
rule: an addon that already carries the art has **no reason left** to ship its own, and every reason
not to — two copies of a mark is two licenses to track, two provenance stories, and a collection
whose addons stop reading as one author's work the first time one copy is regenerated and the other
is not.

**What the module answers.** Everything it returns is a **path**, and every path is **extensionless**
(the client appends it; a path carrying `.tga` is one of the two spellings recorded as drawing
nothing at all — and a texture that does not load draws nothing and raises nothing).

| Member | Answers |
|---|---|
| `Icon(addonName, name)` | The icon path, or `nil` when `name` is not in `ICONS` |
| `Font(addonName, name)` | The face path, or `nil` when `name` is not in `FONTS` |
| `Texture(addonName, name)` | The statusbar path, or `nil` when `name` is not in `TEXTURES` |
| `RegisterLSM(addonName)` | Registers every face and texture with LibSharedMedia under its catalog name; answers `fonts, bars`, and `0, 0` where LSM is absent |
| `ICONS` / `FONTS` / `TEXTURES` | The catalogs — enumerate these, never hard-code a list |

**Every call takes the host's own addon FOLDER name (MUST).** A texture path is absolute from
`Interface\AddOns\`, and this library is vendored: there is no one path to it, there are as many as
there are consumers, and a copy cannot know which folder it was copied into. The host has that string
as the first vararg of every file its TOC loads and nothing else does. A host **MUST NOT** pass a
value that merely *happens* to equal it — a frame-name prefix, an `## Title`, a constant typed by
hand — because the failure is invisible: the wrong path draws nothing and raises nothing.

- **MUST** wire it through one setup file (`core/MediaSetup.lua`), matching the one-file-per-module
  pattern in library-stack-§7, publishing the addon's own `NS.Icon(name)` / `NS.MediaFont(name)`
  wrappers and making the single `RegisterLSM` call.
- That file **MUST** load **before** anything that resolves a shipped path at load time — a
  `Constants.FONT_MONO` read from the seam is the common case, and a `core/Constants.lua` that loaded
  first would resolve it to the fallback on a perfectly healthy install.
- **MUST** register at **file load**, not at `PLAYER_LOGIN`. LibSharedMedia is vendored under `libs/`
  and has already run by the time the TOC reaches the addon's own files, and a shipped default naming
  a face LSM has not heard of yet resolves to nothing.

**The catalog is the vocabulary (MUST).** Where the addon needs a mark, it **MUST** use the catalog's:

- **MUST NOT** ship a private icon, face or bar texture that duplicates one the library already
  carries, and **MUST NOT** copy one out of `libs/LibKa0s/media/` into the addon's own `media/`
  (layout-§3, anti-patterns #63).
- **A mark the catalog lacks is added UPSTREAM**, in the same style, by the generator that produced
  the rest — never drawn one-off into an addon. The generators are the provenance record for the art:
  which upstream glyph each name draws, every transformation applied, and for the synthesized
  textures every value that decides a pixel. Art separated from them is a folder of binaries nobody
  can regenerate, relicense or resize. Adding one is a library minor plus a re-vendor, which is the
  same cost as any other library change and is not a reason to draw a local substitute.
- **The art ships WHITE**, because WoW tints a texture by **multiplying**: white art becomes any color
  a caller asks for and gray art mutes it. Art contributed upstream **MUST** be white with its shape
  in the alpha channel, or one icon in the set silently stops obeying the color a host sets.
- **MUST** treat `nil` as a real answer. Both an absent library and an unknown name answer `nil`, and
  a caller **MUST** have somewhere to go — the fallback ladder a host already needs for a texture that
  fails to load. A host **MUST NOT** build a path by string concatenation to work around a `nil`.

**Where the marks belong.** The surfaces below are where a user meets an addon, and they are ranked by
how visible an inconsistency is. This list is a floor, not a ceiling: an addon **SHOULD** sweep its own
user-facing frames for the same shapes.

| Surface | What draws from the catalog |
|---|---|
| The debug console and its copy window | close, copy, clear — the host passes `addonName` in the `LibKa0s-DebugLog-1.0` descriptor and the library does the rest (debug-logging-§7) |
| Any window's close control | `Core.MakeCloseButton(parent, onClick, addonName)` (standalone-windows) |
| A main window's title-bar strip | the controls it offers — lock, settings, reset, minimize, export, sort |
| A modal and its copy window | the close control, and any action button (below) |
| An action button with a label | the mark goes **beside** the label, never instead of it — a `spreadsheet` on *Export to CSV*, a `chat` on *Print to Chat*. The mark says where the action lands; the word says what it does |

- **A label is not replaced by a mark without a reason (SHOULD NOT).** Dropping a word costs the one
  thing the word was doing. It is right for a **title-bar control**, where the strip is a row of small
  square targets, the vocabulary is short and every Ka0s window uses the same one; it is wrong for a
  wide button that does something outward, where "which one posts to guild?" becomes a question
  answered by hovering.
- **A tooltip is not the fix for an unclear mark.** One shipped on the debug console's copy and clear
  for a single release and was removed rather than repositioned: anchored under the control it covered
  the first line of the log, which is the thing the window exists to show. If a mark needs a tooltip
  to be understood on a crowded window, that is evidence the label should have stayed.
- **The options surface is deliberately out of scope for now.** The settings panel's widgets are
  `LibKa0s-Options-1.0`'s, so iconifying it is a library change with a collection-wide blast radius,
  and it is tracked as an open evolution rather than done piecemeal per addon.

### 9. A widget-type re-registration is the library's (MUST)

AceGUI's widget registry is **process-global**. `AceGUI:RegisterWidgetType(name, ctor, version)` writes
into `AceGUI.WidgetRegistry` — one table, shared by every addon loaded in the client, Ka0s or not — and
the highest version registered for a name wins for the rest of the session. library-stack-§5 and
anti-patterns #8 sanction that call and continue to: extending a widget beats forking the library that
ships it. What neither of them said is **where the call may live**, and the silence cost this collection
five copies of one patch.

**The case this is written against.** Five addons ship a private `core/LSMPatch.lua` that re-registers
`LSM30_Border` at `AceGUI:GetWidgetVersion("LSM30_Border") + 1`, wrapping whatever constructor the
registry held, to collapse a 42px border-preview tile that reads as misaligned on a canvas-layout
settings page: `AbsorbTracker/core/LSMPatch.lua:20` (50 lines, exposed as a callable
`NS.ApplyLSMBorderPatch()` and invoked from `core/AbsorbTracker.lua:52`),
`ConsumableMaster/core/LSMPatch.lua:43` (65), `KickCD/core/LSMPatch.lua:46` (68),
`MultiMeters/core/LSMPatch.lua:80` (101) and `PanelMaster/core/LSMPatch.lua:44` (66) — the last four
installed from a `PLAYER_LOGIN` frame. Five files, five distinct md5s, one intent. Each is defensible
read on its own, which is why two audit bundles graded the same code differently — `KICKCD-R-01` **High**
and `PANELMASTER-R-01` **Medium** — and neither could name a rule it broke.

Read together they are a different object. Every wrapper closes over whatever the registry held when it
ran, so with all five loaded the last addon to reach `PLAYER_LOGIN` wraps the fourth, which wraps the
third: the same work done five times, five constructors deep, with the outermost one belonging to
**whichever addon the client happened to load last**. And the registration is the *session's*, not the
addon's — the next Border dropdown anything opens, Ka0s or not, is drawn by a Ka0s wrapper it never asked
for. The behavior is a function of load order, which is exactly why no addon's suite can see it: each one
loads one copy, registers once, and passes.

- **Re-registering a widget type the addon did not itself define** — a name already present in
  `AceGUI.WidgetRegistry` when the addon loaded, whether AceGUI's own or a shared-media widget's —
  **MUST** be done by `LibKa0s`, published as a member of the owning major, and **MUST NOT** be done from
  an addon's `core/`, `modules/` or `settings/`. The addon **calls** the library's member; it does not
  perform the registration.
- The library's registration **MUST** be **idempotent behind a sentinel on the library table**, because
  every consumer carries its own vendored copy and every copy will call it. N vendored copies loaded in
  one session **MUST** produce exactly one registration, and the sentinel is what makes the count
  independent of how many addons are installed and in what order.
- **One consumer is enough to send it upstream.** §7's three promotion bars ask whether a shape is
  *shared*; this rule does not ask that, and does not wait for a second caller. What makes the
  registration the library's is the blast radius, not the number of callers — and a second Ka0s addon
  reaching the same conclusion independently is not a duplicate, it is a collision.
- **Registering a NEW widget type the addon itself defines is untouched.** A `Ka0s_X` name nothing else
  in the process claims collides with nobody, and library-stack-§5's extend-don't-fork sanction applies
  to it unchanged. This rule is about **where** a re-registration lives, never about **whether**
  extension is legitimate.
- Where the wanted change is **per-instance** — a hidden child, a re-anchored region, a restyled cap —
  an addon **MAY** simply make it at **its own creation site**, on the widget it just acquired, and leave
  the registry alone. That answer is always available, needs no library minor and affects nobody else;
  what is forbidden is reaching the same end by editing the table every other addon in the client reads.
