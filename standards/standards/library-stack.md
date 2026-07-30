> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Library stack

### 1. Mandatory libs (every Ace3 addon)

| Lib | Purpose | Embedded as |
|---|---|---|
| LibStub | lib registry | vendored |
| CallbackHandler-1.0 | Ace3 dependency | vendored |
| AceAddon-3.0 | addon + module lifecycle | vendored |
| AceDB-3.0 | profile / char / global SV | vendored |
| AceEvent-3.0 | event subscription | vendored |
| AceTimer-3.0 | timers | vendored |
| AceConsole-3.0 | slash registration | vendored |
| AceGUI-3.0 | options panel widgets | vendored |

All libraries are **vendored in `libs/` and committed** (library-stack-§3).

### 2. Common optional libs

| Lib | When |
|---|---|
| LibSharedMedia-3.0 | any addon with user-facing fonts/textures/sounds |
| AceDBOptions-3.0 | only if Profiles sub-page is wired |
| AceConfig-3.0 / AceConfigDialog-3.0 | **only if** the addon ships a Profiles sub-page using AceDBOptions; otherwise the canonical pattern is Blizzard Settings + raw AceGUI |
| LibDualSpec-1.0 | spec-aware profile switching |
| LibSerialize | export/import |
| LibDeflate | export/import compression |
| LibDBIcon-1.0 | minimap LDB icon |

### 3. Vendoring over externals

Ka0s addons **MUST ship every library vendored in `libs/` and committed to git**. The addon must be fully self-contained — installable by copying the folder into `Interface/AddOns/` with no packager step required to obtain libraries.

- **MUST** vendor all Ace3 and third-party libs under `libs/` and commit them. **MUST NOT** use `.pkgmeta` `externals:` to fetch libraries.
- **MUST** use the standard folder-per-lib layout (`libs/AceAddon-3.0/AceAddon-3.0.xml`, `libs/LibStub/LibStub.lua`, …) and load libs **first** in the TOC — the lib's `.xml` where it ships one (it pulls the lib's `.lua` + any sub-files), the `.lua` otherwise.
- **SHOULD** copy the folder-per-lib set from an existing Ka0s addon's `libs/` so lib versions stay consistent across the suite. Pull libs the suite doesn't yet vendor (LibDataBroker-1.1, LibDBIcon-1.0, …) from a current retail install or the upstream release.
- **MUST** vendor only libs the addon actually `LibStub("X")` — vendor what you use, nothing more. Prune dead weight (e.g. AceConfig where only Profiles needs it; AceLocale/AceBucket/AceComm/AceHook/AceSerializer/AceTab where unloaded).
- **MAY** vendor an addon-private micro-lib (e.g. an 80-line object-pool mixin) the same way.

### 4. Lib registry pattern

- **SHOULD** call `LibStub("X")` exactly once at addon load and stash on the addon's namespace: `NS.LSM = LibStub("LibSharedMedia-3.0")`. **SHOULD NOT** call `LibStub` from per-frame code.

### 5. Forking Ace libs is forbidden

- **MUST NOT** privately fork an Ace3 lib. Private lib forks seen in some large UI suites (renamed copies of Ace3) block on every Ace3 update and are an anti-pattern.
- **MUST** extend AceGUI via `AceGUI:RegisterWidgetType("Ka0s_X", ...)` if a custom widget is needed.

### 6. No addon-suite dependencies (self-contained)

A Ka0s addon **MUST** stand on its own. The vendoring rule (library-stack-§3) makes it self-contained with respect to **shared libraries** (LibStub-registered code embedded under `libs/`); this rule makes it self-contained with respect to **other addons** — i.e. standalone addons and addon *suites* such as ElvUI, EllesmereUI, DBM, WeakAuras, BigWigs, Plater, etc. Suites are **not** dependencies. The distinction: a **library** is LibStub-registered code you vendor and own; a **suite** is a separate installed addon with its own lifecycle, and you never require it.

- **MUST NOT** hard-depend on any addon suite or standalone addon: no `## Dependencies:` / `## RequiredDeps:` naming one, and no code path that assumes a suite's globals, API, callbacks, or frames exist (`ElvUI`, `DBM`, `WeakAuras`, `BigWigs`, …).
- **MUST** be fully functional and behave **identically** with no other addon installed. Every texture, font, sound, and layout the addon needs is either vendored under `media/` (layout-§3) or drawn from LibSharedMedia's built-ins — **MUST NOT** read a suite's media files, textures, fonts, or SavedVariables, and **MUST NOT** rely on a suite having skinned or repositioned any frame.
- **MUST NOT** embed, copy, or private-fork a suite's code, media, or a suite-renamed Ace library (this is the library-stack-§5 fork ban applied to suites — depend on nothing you did not vendor and own).
- **MAY** *optionally* integrate with a suite that happens to be present — e.g. register an ElvUI/EllesmereUI skin for the addon's own frames, or subscribe to a DBM/BigWigs timer callback — **only when all** of the following hold: (a) the integration is presence-guarded (`C_AddOns.IsAddOnLoaded("ElvUI")`) and never assumes the suite loaded; (b) the suite is listed in `## OptionalDeps:`, never `## Dependencies:`; (c) with the suite absent the addon falls back to its own styling/behavior with no loss of core function. This is the same soft-fallback discipline required for optional libraries (library-stack-§3–§4): the addon is whole on its own and the integration is pure enhancement.

### 7. Ka0s-owned shared libs

Some shared code is **authored inside the collection** rather than pulled from the ecosystem. These are still **libraries** in the library-stack-§6 sense — LibStub-registered code you vendor and own, never a dependency addon — and every rule above applies. This section adds the two rules that only bite when the library's author and its consumers are the same person.

| Lib | Purpose | Source | Embedded as |
|---|---|---|---|
| `LibKa0s` | umbrella for Ka0s-owned shared modules, vendored at `libs/LibKa0s/` exactly as Ace3 is; **one LibStub major per module**, e.g. `LibKa0s-Perf-1.0` (the performance harness, performance-§1) | <https://github.com/tusharsaxena/LibKa0s> — the repo's inner `LibKa0s/` folder is the ship payload; `tests/` and `docs/` stay upstream | vendored |

Vendor from **that repo's** ship folder, not from a sibling addon's `libs/` — a sibling's copy may itself have drifted (anti-patterns #45).

- **MUST** vendor and TOC-list only the modules the addon actually uses (library-stack-§3), and **MUST NOT** list `LibKa0s` under `## Dependencies:` — a Ka0s addon works with no other addon installed (library-stack-§6).
- **MUST** use **one LibStub major per module**, not one for the whole umbrella. LibStub picks the highest **minor of a major**: under a single major, an addon vendoring a copy that predates a module would be served a lib missing that module, and every host would need presence guards. Per-module majors keep version skew narrow and make adding a module purely additive — each addon adopts on its own schedule instead of in a lockstep migration.
- **MUST** keep a **module's descriptor / API contract additive-only** within a major. A field may be added in a later minor, never removed or repurposed: once several addons have vendored copies, you cannot know who holds what.

**Vendor sync (MUST).** Vendoring a third-party lib is a one-time copy that stays stable for months. Vendoring a lib you also author is an ongoing **sync**, and the drift window is a single afternoon.

- The vendored copy **MUST** be **byte-identical** to the source repo's ship folder. `diff -r <LibRepo>/<Lib> <Addon>/libs/<Lib>` **MUST** be empty. A hand-patched `libs/` copy is a fork nobody knows about (library-stack-§5).
- A change to a Ka0s-owned lib **MUST** be followed by a **re-vendor commit in every consumer** that depends on it, and that commit **SHOULD** be its own so the sync is legible in history rather than buried in a feature diff.
- **This is the step that gets forgotten, and nothing about "the tests are green" will catch it**: the library's suite passes against the library, and the consumer's suite passes against a stale copy that still works. Both repos stay green while the copies diverge (anti-patterns #45). The `diff -r` check belongs in the audit's evidence set (`AUDIT.md`).

**Module versioning (MUST).** The other half of the same rule, and the reason a missed sync fails silently instead of loudly.

- Each **file** within a module's major **MUST** carry a LibStub **MINOR** integer that increments on **every released change to that file**. LibStub compares those integers to pick a winner between vendored copies, so **a released change that skips its bump does not ship** — every host already carrying the old copy keeps running it, with nothing to say so.
- Files **MUST NOT** be bumped in lockstep. Bumping every file whenever any file changes discards the narrow-skew property that made per-module majors worth choosing.
- A multi-file major **MUST** pair its files by version, not merely by presence: a file that attaches to the module's main table **MUST** re-attach whenever the table underneath it came from a different copy, or a host ends up running one file from copy A and another from copy B — the mismatch the single-major layout exists to prevent.
- The library **MUST** publish the **live minor of every file** on its table (a `MODULES` registry or equivalent), so version skew is answerable at runtime rather than by reading source. With several consumers each carrying a copy, "which half came from where?" is a question someone will need answered from in-game.
- The lib repo's own **semver tag is a separate axis** from any file minor and **MUST NOT** be conflated with one (versioning-git).
- The lib repo **SHOULD** make the coupling mechanical rather than remembered: a test that fails when a file's minor and the changelog entry for it disagree, and a written release order ending in *re-vendor every consumer*. — e.g. register an ElvUI/EllesmereUI skin for the addon's own frames, or subscribe to a DBM/BigWigs timer callback — **only when all** of the following hold: (a) the integration is presence-guarded (`C_AddOns.IsAddOnLoaded("ElvUI")`) and never assumes the suite loaded; (b) the suite is listed in `## OptionalDeps:`, never `## Dependencies:`; (c) with the suite absent the addon falls back to its own styling/behavior with no loss of core function. This is the same soft-fallback discipline required for optional libraries (library-stack-§3–§4): the addon is whole on its own and the integration is pure enhancement.
