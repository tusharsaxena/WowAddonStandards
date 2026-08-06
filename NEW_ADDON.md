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

1. **Scaffold the skeleton.** Lay down the Ace3 stack: AceAddon registration, AceDB saved variables,
   the modular folder layout, MIT `LICENSE`, and an AceConsole slash command. This is the skeleton the
   rest of the pack fills in.
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
   the README's `## What's new` and `## Version History`, and moving it to `docs/CHANGELOG.md` is the
   same second history one directory down. It is required only at a **Ka0s-owned library** root,
   which this playbook does not scaffold (documentation-§1/§3, library-stack-§7).
3. **Lay out files.** Use the single modular layout — `core/ modules/ defaults/ settings/ locales/` —
   for every addon regardless of size (a small addon just has thin folders). See *Layout* and the
   starter tree in the context pack. Copy the vendored `libs/` set you actually
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
   - `core/CoreSetup.lua` — `LibKa0s-Core-1.0`: the secret-safe stringifier and the prefixed chat
     printer (`NS.Print` / `NS.Util.print`, one function object — architecture-§2). Placed after the
     file defining `NS.PREFIX` and before everything that prints; pass the prefix as a **function**
     so a later change to it is not frozen in at load.
   - `core/PerfSetup.lua` — `LibKa0s-Perf-1.0` (performance): the descriptor's declared buckets with
     their `within` nesting, `<Addon>PerfDB` as `sv`, `suspend`/`resume`, gated brackets on the hot
     paths, and the reserved `perf` verb dispatched by the host. Placed before any module taking
     `local Perf = NS.Perf` as a load-time upvalue.
   - `core/DebugLogSetup.lua` — `LibKa0s-DebugLog-1.0` (debug-logging): the frame-name prefix, the
     title, the monospace font, the `isEnabled`/`setEnabled` pair over the addon's **own** flag, and
     the `[Init]` session summary. Publishes the gated sink `NS.Debug`.
   - the **slash descriptor** in `settings/Slash.lua` — `LibKa0s-Slash-1.0` (slash-commands): the
     addon keeps its ordered `NS.COMMANDS` table and its host verbs and passes them in; the library
     supplies the dispatcher, help renderer, formatters and the type-aware value parser.
   - `settings/OptionsSetup.lua` — `LibKa0s-Options-1.0` (options-ui): the `get`/`set`/`applyDefault`
     seams, `rowsForPage`/`allRows`, the color codecs, and eager settings-category registration with a
     lazily-built body **and a lazily-built header Defaults button** (options-ui-§1/§5). Loads before
     every `settings/<page>.lua`.
   Each stub **MUST** answer every member the addon actually calls — a stub missing one is a crash
   moved to a rarer code path, not a fallback.
5. **Write tests first.** Stand up `tests/` on the vendored `tests/_kit/` harness and drive every
   behavior **test-first** (testing). Test what is **yours** — the descriptors, the degradation stubs,
   and the addon's own logic — and do not re-test the library's internals: they are covered in the
   `LibKa0s` repo, and a second copy of those cases is the duplication this whole arrangement exists
   to remove. `lua tests/run.lua` green **and** `luacheck .` clean is the commit gate.
6. **Write the README to the canonical structure.** It is a **player-facing**, plain-language document
   (no contributor material — that lives under `docs/`). Root `README.md` follows documentation-§1 (title → badges
   incl. the standard-link badge → logo → description → Screenshots → Usage → How it works → FAQ →
   Troubleshooting → Issues and feature requests → Version History — there is **no** `## Testing` section;
   verify-how-to lives in `docs/`, and the README keeps only the `[tests]` badge).
6b. **Write the `docs/` set to documentation-§3's tier model.** The canonical trio
   (`ARCHITECTURE.md`, `testing.md`, `smoke-tests.md`) plus **all six Tier 1 docs, under exactly
   these names**: `scope.md`, `module-map.md`, `schema.md`, `settings-panel.md`, `data-flow.md`,
   `common-tasks.md`. They are unconditional — a v0.1.0 addon writes each one short rather than
   omitting it, because the tier model's whole value is that the same question has the same filename
   in every repo, and a slot left for later is a slot the next agent fills with a name of its own.
   Then evaluate each **Tier 2** trigger against the code you just wrote and either ship the doc or
   record it as a *Not applicable* row carrying the trigger. Finally write `ARCHITECTURE.md`'s
   `## Documentation map` listing every `docs/` page in exactly one of its three tables — this is
   the register `standards-audit` reads, and it is easiest to write now, while you still know why
   each file exists. `ARCHITECTURE.md` is a **hub**: keep it under ~400 lines and spill any section
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
9. **Check the Definition of Done.** Walk the DoD checklist at the bottom of the context pack before
   tagging `v0.1.0`.
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
  `bump-version`, `bump-interface`, `standards-audit`).
