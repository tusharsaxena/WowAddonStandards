# New Addon — Playbook

**Invoked by `/wow-addon:new-addon`.** This is the step-by-step spec for scaffolding a new Ka0s WoW
addon that is **born compliant** with the Ka0s WoW Addon Standard. It runs **in the new addon's own
repository**.

This playbook is the entry point; the substance lives in `standards/`:

- **[`standards/STANDARDS.md`](standards/STANDARDS.md)** — the canonical rules (the `§`-sections).
- **[`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md)** — the full context pack:
  kickstart walkthrough, the modular starter tree, starter snippets (TOC, entry, `Compat`, `Locale`, `Database`,
  `Settings`, debug console, tests, message bus, `.luacheckrc`, `.pkgmeta`), hard-rules cheat sheet,
  and the Definition-of-Done checklist. **It is scaffolding you read, never a file you ship** (see step 2).

## Steps

**Step 0 — before step 1, and before any other file exists: write `.gitattributes` (`line-endings`).**
The repo's **first** commit carries a root `.gitattributes` holding the **client-bound** body verbatim
from `line-endings-§5` — the `* text=auto eol=crlf` pin, the `*.sh text eol=lf` carve-out, and the
`binary` markings. The text to copy is the context pack's `### .gitattributes` starter snippet; copy
it rather than composing one, since eight hand-written 22-to-68-line variants of this policy exist
today precisely because there was never one canonical text. **It goes first because it is the one file
whose cost grows with everything already committed**: retrofitted later it needs
`git add --renormalize .` plus a whole-tree re-checkout, producing a diff that touches every line of
every straggler — which against a young repo is not reviewed, it is approved. Written first, it costs
one file and every commit after it is correct by construction. Do **not** stop at the `*.sh` line: a
`.gitattributes` carrying the carve-out with no pin above it is the near-miss `line-endings-§1` names
explicitly, and it is how one repo in this collection reached 111 of 185 tracked text files
disagreeing with the collection's intent while looking, in review, like it had been handled.

1. **Scaffold the skeleton.** Lay down the Ace3 stack: AceAddon registration, AceDB saved variables,
   the modular folder layout, MIT `LICENSE`, and an AceConsole slash command. The root
   `.gitattributes` from step 0 is already in place; everything laid down here inherits its endings.
   This is the skeleton the rest of the pack fills in.
2. **Read the context pack — do NOT copy it in.** Fetch `standards/NEW_ADDON_CONTEXT.md` to a
   **temp directory**, work from it for this session, and discard it. It **MUST NOT** be written
   into the addon under any name (documentation-§3, anti-pattern #49): it is scaffolding, every
   question it answers is answered the moment the addon exists, and a stored copy is loaded as
   working context — so a stale one gets *followed*, not ignored. Leave a short root `CLAUDE.md`
   **stub** carrying identity and `## Standards compliance (read first)`, and put the durable
   per-addon context where the standard requires it: `docs/ARCHITECTURE.md` (what this addon is),
   `docs/testing.md` (how to verify it), and root `DEPENDENCIES.md` (what to install to work on it —
   step 7). The root ships exactly those three docs plus `LICENSE` — `README.md`, the `CLAUDE.md`
   stub, `DEPENDENCIES.md` — and never a fourth. In particular, **never scaffold a `CHANGELOG.md`**:
   at an addon root it is forbidden, because the player-facing history is already mandated twice in
   the README's `## Version History`, and moving it to `docs/CHANGELOG.md` is the
   same second history one directory down. It is required only at a **Ka0s-owned library** root,
   which this playbook does not scaffold (documentation-§1/§3, library-stack-§7).
3. **Lay out files.** Use the single modular layout — `core/ modules/ defaults/ settings/ locales/` —
   for every addon regardless of size (a small addon just has thin folders). See *Layout* and the
   starter tree in the context pack. The folder load order is `libs/*` → `locales/*` → `core/*` →
   `defaults/*` → `modules/*` → `settings/*` (layout-§1), which is the same order the TOC's `#`
   section headers express (toc-file-§5). Inside `core/` there is **no fixed prefix**: order by what
   the files actually resolve at load — which for a new addon is decided by the setup-file list in
   step 4 — and annotate each load-bearing position at its TOC line (toc-file-§5). Copy the vendored `libs/` set you actually
   `LibStub()` from an existing Ka0s addon so versions stay consistent (library-stack-§3 — libraries are vendored
   and committed). Then vendor the two Ka0s-owned payloads (library-stack-§7) from the **`LibKa0s`
   repo's own ship folders**, byte-identical, rather than from a sibling addon's copy, which may
   itself have drifted (anti-pattern #45):
   - the repo's inner **`LibKa0s/` folder → `libs/LibKa0s/`**, copied **whole** — every module, not
     only the ones the first release calls — and TOC-listed as the single line
     `libs\LibKa0s\LibKa0s.xml` in the `# Libraries` block **after Ace3** (toc-file-§4/§5). Copying
     part of a multi-file major is anti-pattern #48: the dependent modules refuse to register without
     `Core.lua` and go silently **absent**, and a shell without its attach file `:New`s successfully
     and fails at **call** time, a panel build later.
   - the repo's **`testkit/` folder → `tests/_kit/`** — the shared headless harness (testing). It goes
     under `tests/`, **never** `libs/`, because it must not ship with the addon.
4. **Fill in the starters.** Work through the *Starter snippets* and *Hard rules cheat sheet* in the
   context pack: the TOC (fixed field order + `#`-section file listing, toc-file-§1/toc-file-§5), entry file, compat
   shims, locale, database/migrations, schema-driven settings (architecture-§5), and the message bus
   (architecture-§4).
   **The shared subsystems are not written here — they are consumed.** The chat printer, the debug
   console, the options toolkit, the slash dispatcher and the performance harness are `LibKa0s`
   modules; a new addon is born with one **setup file** per module, each holding a **descriptor** and
   a **degradation stub** for when the library is absent, and nothing else. Hand-building any of them
   is anti-pattern #47. In TOC load order:
   - `core/MediaSetup.lua` — `LibKa0s-Media-1.0` (library-stack-§8): `NS.Icon(name)` /
     `NS.MediaFont(name)` over the shared catalog, and the one `Media.RegisterLSM(addonName)` call at
     file load. **First of the setup files**, because `core/Constants.lua` resolves `FONT_MONO` from
     the seam it publishes and a Constants that loaded first would take the fallback on a healthy
     install. Every call passes the addon's own **folder name** — a texture path is absolute from
     `Interface\AddOns\` and the library is vendored, so it cannot know which folder it was copied
     into, and a wrong path draws nothing and raises nothing.
   - `core/EnvSetup.lua` — `LibKa0s-Env-1.0`: TOC metadata, the addon's own version (the fallback
     stays visible at the call site, as an argument), and the player's map ID and zone. Wired by
     every addon in the collection, because every addon reads at least its own version; a six-line
     `GetAddOnMetadata` ladder in `core/Compat.lua` is the eleven-copy duplication this module ended.
   - `core/PoolSetup.lua` — `LibKa0s-Pool-1.0`: the free/active widget pool, in the array shape or
     the keyed shape — wired by any addon that re-renders rows, bars or chart elements. The two
     shapes are not interchangeable; pick one per pool. Only skip this if the addon draws nothing
     repeatedly, and remember that a hand-rolled pool whose `active` list is never drained looks
     correct and leaks frames for the whole session.
   - `core/ItemSetup.lua` — `LibKa0s-Item-1.0`: id and quality from a link, the quality label, and
     the cache-then-callback load — wired only by an addon that handles items. It holds **no policy**
     about what an uncached item means; that decision stays in the addon and gets written down.
   - `core/CoreSetup.lua` — `LibKa0s-Core-1.0`: the secret-safe stringifier and the prefixed chat
     printer (`NS.Print` / `NS.Util.print`, one function object — architecture-§2). Placed after the
     file defining `NS.PREFIX` and before everything that prints; pass the prefix as a **function**
     so a later change to it is not frozen in at load.
   - `core/PerfSetup.lua` — `LibKa0s-Perf-1.0` (performance): the descriptor's declared buckets with
     their `within` nesting, `<Addon>PerfDB` as `sv`, `suspend`/`resume`, gated brackets on the hot
     paths, and the reserved `perf` verb dispatched by the host. Placed before any module taking
     `local Perf = NS.Perf` as a load-time upvalue. **Pass no `decorate` hook.** From `PerfPanel.lua`
     minor 4 the library draws the step panel's close control from the addon's own name, so the panel
     matches the debug console with nothing wired; a hook whose only job is a close button is a copy
     of library behavior that can fall behind it, and the copy that shipped in this collection did
     (performance-§4, anti-pattern #65). Add one only for chrome the library does not draw — and if
     you do, build the close control through `NS.MakeCloseButton`, never with a bare two-argument
     call to any factory.
   - `core/DebugLogSetup.lua` — `LibKa0s-DebugLog-1.0` (debug-logging): the frame-name prefix, the
     title, the monospace font (from `NS.MediaFont`, not a copy the addon ships), **`addonName`** so
     the console's close/copy/clear draw the shared marks, the `isEnabled`/`setEnabled` pair over the
     addon's **own** flag, and the `[Init]` session summary. Publishes the gated sink `NS.Debug`.
     `addonName` and `name` are different fields: the second seeds frame globals, and passing it for
     the first hands the library a path into nowhere.
   - the **slash descriptor** in `settings/Slash.lua` — `LibKa0s-Slash-1.0` (slash-commands): the
     addon keeps its ordered `NS.COMMANDS` table and its host verbs and passes them in; the library
     supplies the dispatcher, help renderer, formatters and the type-aware value parser.
   - `settings/OptionsSetup.lua` — `LibKa0s-Options-1.0` (options-ui): the `get`/`set`/`applyDefault`
     seams, `rowsForPage`/`allRows`, the color codecs, and eager settings-category registration with a
     lazily-built body **and a lazily-built header Defaults button** (options-ui-§1/§5). Loads before
     every `settings/<page>.lua`.
   Each stub **MUST** answer every member the addon actually calls — a stub missing one is a crash
   moved to a rarer code path, not a fallback.

   **Draw every mark from the shared catalog** (library-stack-§8). The payload just vendored carries
   the icons, the monospace face and the bar textures, so a new addon starts with them and has no
   reason to ship art of its own beyond its logo: window close controls come from
   `MakeCloseButton(parent, onClick, addonName)` — **wrapped once, in `core/CoreSetup.lua`, and never
   called directly (MUST)**, because the third argument is the folder name, cannot be inferred by a
   vendored library, and omitting it draws the fallback glyph with nothing raised and no gate able to
   see it; the wrapper exists so the mistake is at least greppable (standalone-windows, anti-patterns
   #64/#65). Build **every** close control the addon has through it, including inside any decoration
   hook handed to a shared module. A title-bar control strip and any modal draw catalog
   marks, and a wide action button gains a mark **beside** its label rather than instead of it. A mark
   the catalog lacks is added upstream in the `LibKa0s` repo, in the same style, by the generator that
   produced the rest — never drawn one-off here.

   **Scaffold the first settings page to the shape every Ka0s page has** (options-ui-§13/§14/§15/§16/§17/§18).
   A new addon gets this for free by starting from it; retrofitting it later is a rename pass across
   every page file, and one of the rules cannot be retrofitted at all without a migration.
   - **Every settings page renders through the tabbed renderer**, starting with `General` and
     including a page with a single section — a one-tab strip is the correct rendering of a
     one-section page. The untabbed form is for the pages the host does not render through the flow
     engine, and today that is **two**: the AceConfig-drawn Profiles sub-page, and the **landing
     page**, whose body is your own `buildMain` (options-ui-§5) — logo, tagline, *Slash Commands*
     heading, one Label per `COMMANDS` row. Do **not** put a tab strip on the landing page
     (options-ui-§13). Give **every** schema row a `group`; a row without one belongs to no tab.
   - **The General page's first tab is named exactly `Master controls`** and is built by the library's
     master-controls composer from **one** declaration — `Enable <Addon>` | `General visibility` /
     `Master scale` | `Master alpha` / `Lock frame` | `Debug console` / `Reset position` |
     `Reset all settings` — including only the rows the addon has the state for. A frameless addon
     omits exactly the four frame-only rows and **MUST NOT** invent a movable frame to fill the tab
     out (options-ui-§15). Declare `General visibility` as the four-value dropdown from the start:
     shipping the *show only in combat* boolean instead buys a migration later for nothing.
   - **Font, border and bar controls come from the composers**, never typed out — one call each emits
     the canonical rows in the canonical order, and anything extra the surface needs is appended
     after the block rather than interleaved into it (options-ui-§16). A tab mixing two of them gives
     each a `subgroup` heading (options-ui-§7).
   - **Every color row ships with its class-color companion** as the next row, defaulting **off**,
     with `classColorSource` declared on both rows, and resolved through the library's one resolver —
     which keeps the swatch's alpha, falls through to the stored swatch when the class cannot be
     resolved, and reads the tracked unit's class where the surface describes a unit
     (options-ui-§17). Never `disabledIf` on a color row. Write nothing private here: the four-copies
     version is what this rule was written out of.
   - **Anything a player orders is the shared drag-to-reorder list**, never arrow buttons; the handle
     and the bounded row box are the library's and the row's contents are yours, and the controller is
     canceled at the top of the render (options-ui-§18).
   - **Page-wide controls sit in the chrome block above the strip**, not under one tab, and that block
     is never boxed a second time (options-ui-§14).

   Mirror every row into `defaults/Profile.lua` and give every new `label` **and** `desc` an `enUS`
   key as you write it — the suite checks labels, and descs are checked by nothing, which is why they
   are the ones that go missing.
5. **Write tests first.** Stand up `tests/` on the vendored `tests/_kit/` harness and drive every
   behavior **test-first** (testing). Test what is **yours** — the descriptors, the degradation stubs,
   and the addon's own logic — and do not re-test the library's internals: they are covered in the
   `LibKa0s` repo, and a second copy of those cases is the duplication this whole arrangement exists
   to remove. `lua tests/run.lua` green **and** `luacheck .` clean is the commit gate.
6. **Write the README to the canonical structure.** It is a **player-facing**, plain-language document
   (no contributor material — that lives under `docs/`). Root `README.md` follows documentation-§1 (title → badges
   incl. the standard badge, which is **not** a link and MUST NOT be wrapped in one → logo → description →
   Screenshots → Usage (prose, no tables) → How it works → FAQ →
   Troubleshooting → Issues and feature requests → Version History → optional `## Credits`, last — there is
   **no** `## Testing` section; verify-how-to lives in `docs/`, and the README keeps only the `[tests]` badge).
   The README carries **no bundled-library inventory** — no `## Libraries` / `## Bundled libraries` /
   `## Libraries and credits` section and no library list in the intro prose; that fact lives in
   `DEPENDENCIES.md` and `docs/ARCHITECTURE.md`, and the LibKa0s provenance line lives in root
   `CLAUDE.md` (step 6a). `## Credits` is optional and carries **only external** credit — artwork, a
   font, a sound pack, another author's work.
6a. **Put the LibKa0s provenance line in root `CLAUDE.md`.** `Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) vX.Y.Z (MIT).`
   naming the **tag** `libs/LibKa0s/` and `tests/_kit/` were vendored from, moving in the same commit as
   the bytes. `tests/_kit/vendor_sync.lua` reads it out of `CLAUDE.md` — since LibKa0s v1.8.1 / testkit
   revision 9, with **no fallback** to `README.md` — so a line in the wrong file fails the gate
   (documentation-§2 item 6, library-stack-§7, testing-§11).
6b. **Write the `docs/` set to documentation-§3's tier model.** The canonical trio
   (`ARCHITECTURE.md`, `testing.md`, `smoke-tests.md`) plus **all six Tier 1 docs, under exactly
   these names**: `scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`, `data-flow.md`,
   `common-tasks.md`. They are unconditional — a v0.1.0 addon writes each one short rather than
   omitting it, because the tier model's whole value is that the same question has the same filename
   in every repo, and a slot left for later is a slot the next agent fills with a name of its own.
   Then evaluate each **Tier 2** trigger against the code you just wrote and either ship the doc or
   record it as a *Not applicable* row carrying the trigger. Finally write `ARCHITECTURE.md`'s
   `## Documentation map` listing every `docs/` page in exactly one of its four tables — Required,
   Conditional, **Verification and record** and Addon-specific, in that order. The fourth holds
   `testing.md`, `smoke-tests.md` and the record docs, which sit outside the tier model; a v0.1.0
   addon writes all six of its rows. This is the register `standards-audit` reads, and it is easiest
   to write now, while you still know why each file exists. `ARCHITECTURE.md` is a **hub**: keep it
   under ~400 lines and spill any section
   past ~60 lines into its canonical topic doc, leaving a summary and one link. Do **not** create
   `file-index.md` or `conventions.md` — both retired in v2.23.0.
7. **Write the root `DEPENDENCIES.md`.** The toolchain contract (documentation-§7): every piece of
   software needed to build, run, test or release this addon, split into **runtime (in-game)**,
   **development** and **release / assets**, with copy-pasteable WSL2 / Ubuntu install commands and a
   one-line verification command per tool. Write it from **evidence** — the TOC's dependency fields, a
   script's imports, the command the harness actually runs — never from what a new addon usually
   needs; a speculative entry costs the reader's trust in the whole list. A new addon's honest runtime
   section is normally "World of Warcraft (Retail); nothing else", because every library is vendored
   (library-stack). It answers *what to install*; `docs/testing.md` answers *how to verify* — point at
   it rather than restating it.
8. **Produce the first automated-test bundle.** Run the **vendored** runner from the repo root —
   `tests/_kit/run-automated-tests.sh --release 0.1.0` — which writes a frozen
   `docs/automated-tests/<YYYYMMDD-HHMMSS>/` bundle across all four out-of-game suites (lint, tests,
   perf, complexity) and rolls the run into `docs/automated-tests/RESULTS.md`. Then write the bundle's
   `ANALYSIS.md` and the `RESULTS.md` standing sections by hand — the runner does not
   (`../AUTOMATED_TESTS.md`, Steps 2–3). Do this **before** tagging `v0.1.0`: the record's value is the
   diff between releases, so the first release is what gives every later one something to diff against.
   **`docs/complexity.md` is retired** (automated-tests-§7) — do not create one; the raw `lizard` output
   is the bundle's `complexity.txt` and the trend line is `RESULTS.md`. The **tag** is gated on all four
   suites passing plus zero functions above CCN 15 (automated-tests-§3); the **commit** gate stays
   lint + the harness only (testing-§4).
   **The in-game capture store starts empty, and that is correct.** A scaffolded addon with the perf
   harness wired ships `docs/perf-analysis/README.md` — the bundle naming, the three artifacts, the
   schema summary and its pointer to the library's contract, how a capture is taken in this addon's
   own slash verb, and an empty capture index stating plainly that no capture has been taken yet
   (performance-§8, documentation-§3). It does **not** get a first bundle: nobody has played the
   addon, there is no client paste, and `../PERF_ANALYSIS.md` forbids assembling one from the offline
   scenarios or the source. The first real capture is a later, separate run of
   `/wow-addon:perf-analysis`. An addon holding the performance-§12 no-combat-path exemption ships
   **no** store at all — not an empty directory.
9. **Check the Definition of Done.** Walk the DoD checklist at the bottom of the context pack before
   tagging `v0.1.0`. Its perf row expects `docs/performance.md` and `docs/perf-analysis/README.md`
   with an empty, honestly-labeled capture index — not a bundle.
10. **Register in the roster.** Add the addon's row to
    [`standards/ADDONS.md`](standards/ADDONS.md) in the `WowAddonStandards` repo. This is the one edit
    that brings the addon into the collection's scope for the next standards refresh.

## Identity (defaults every Ka0s addon uses)

- **Author:** add1kted2ka0s (Ka0s) — **License:** MIT (always) — **Substrate:** Ace3
- **Scope:** Retail only — a single latest-Retail `## Interface:` line (toc-file-§3)
- **TOC `Title`:** `Ka0s <Human Name>` — **SavedVariables:** `<Addon>DB` + `<Addon>PerfDB` (savedvariables-§4) — **Slash:** 2–3 lowercase chars
- **Folder name:** PascalCase (the TOC Title's CamelCase form, minus `Ka0s `)
- **Standard:** built to & references <https://github.com/tusharsaxena/WowAddonStandards>

## Hard rules

- **Born compliant, not retrofitted.** Build to `standards/STANDARDS.md` from the first commit; don't
  scaffold loosely and clean up later.
- **The context pack is the source of detail.** Don't restate its snippets here — read them from
  `standards/NEW_ADDON_CONTEXT.md`. When the two disagree, the standard/context-pack wins.
- **Keep it maintainable afterward** with the `wow-addon:` skills (`review`, `sync-docs`,
  `bump-version`, `bump-interface`, `standards-audit`, `automated-tests`, `run-tests`,
  `perf-analysis`).
