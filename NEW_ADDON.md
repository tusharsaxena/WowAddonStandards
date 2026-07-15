# New Addon — Playbook

**Invoked by `/wow-addon:new-addon`.** This is the step-by-step spec for scaffolding a new Ka0s WoW
addon that is **born compliant** with the Ka0s WoW Addon Standard. It runs **in the new addon's own
repository**.

This playbook is the entry point; the substance lives in `standards/`:

- **[`standards/STANDARDS.md`](standards/STANDARDS.md)** — the canonical rules (the `§`-sections).
- **[`standards/NEW_ADDON_CONTEXT.md`](standards/NEW_ADDON_CONTEXT.md)** — the full context pack:
  kickstart walkthrough, the modular starter tree, starter snippets (TOC, entry, `Compat`, `Locale`, `Database`,
  `Settings`, debug console, tests, message bus, `.luacheckrc`, `.pkgmeta`), hard-rules cheat sheet,
  and the Definition-of-Done checklist. **Drop this file's contents into the new addon** (see step 2).

## Steps

1. **Scaffold the skeleton.** Lay down the Ace3 stack: AceAddon registration, AceDB saved variables,
   the modular folder layout, MIT `LICENSE`, and an AceConsole slash command. This is the skeleton the
   rest of the pack fills in.
2. **Drop in the context pack.** Put the *contents* of `standards/NEW_ADDON_CONTEXT.md` into the new
   addon's `docs/` as the full agent context, and leave a short root `CLAUDE.md` **stub** that points
   to it (documentation). Now every agent and contributor has the complete standards brief with no external
   lookups.
3. **Lay out files.** Use the single modular layout — `core/ modules/ defaults/ settings/ locales/` —
   for every addon regardless of size (a small addon just has thin folders). See *Layout* and the
   starter tree in the context pack. Copy the vendored `libs/` set you actually
   `LibStub()` from an existing Ka0s addon so versions stay consistent (library-stack-§3 — libraries are vendored
   and committed).
4. **Fill in the starters.** Work through the *Starter snippets* and *Hard rules cheat sheet* in the
   context pack: the TOC (fixed field order + `#`-section file listing, toc-file-§1/toc-file-§5), entry file, compat
   shims, locale, database/migrations, schema-driven settings (architecture-§5), eager settings-category
   registration (options-ui-§1), the debug console (debug-logging), and the message bus (architecture-§4).
5. **Write tests first.** Stand up `tests/` (headless Lua 5.1 harness) and drive every behavior
   **test-first** (testing). `lua tests/run.lua` green **and** `luacheck .` clean is the commit gate.
6. **Write the README to the canonical structure.** It is a **player-facing**, plain-language document
   (no contributor material — that lives under `docs/`). Root `README.md` follows documentation-§1 (title → badges
   incl. the standard-link badge → logo → description → Screenshots → Usage → How it works → FAQ →
   Troubleshooting → Issues and feature requests → Version History — there is **no** `## Testing` section;
   verify-how-to lives in `docs/`, and the README keeps only the `[tests]` badge).
7. **Check the Definition of Done.** Walk the DoD checklist at the bottom of the context pack before
   tagging `v0.1.0`.
8. **Register in the roster.** Add the addon's row to
   [`standards/ADDONS.md`](standards/ADDONS.md) in the `WowAddonStandards` repo. This is the one edit
   that brings the addon into the collection's scope for the next standards refresh.

## Identity (defaults every Ka0s addon uses)

- **Author:** add1kted2ka0s (Ka0s) — **License:** MIT (always) — **Substrate:** Ace3
- **Scope:** Retail only — a single latest-Retail `## Interface:` line (toc-file-§3)
- **TOC `Title`:** `Ka0s <Human Name>` — **SavedVariables:** `<Addon>DB` — **Slash:** 2–3 lowercase chars
- **Folder name:** PascalCase (the TOC Title's CamelCase form, minus `Ka0s `)
- **Standard:** built to & references <https://github.com/tusharsaxena/WowAddonStandards>

## Hard rules

- **Born compliant, not retrofitted.** Build to `standards/STANDARDS.md` from the first commit; don't
  scaffold loosely and clean up later.
- **The context pack is the source of detail.** Don't restate its snippets here — read them from
  `standards/NEW_ADDON_CONTEXT.md`. When the two disagree, the standard/context-pack wins.
- **Keep it maintainable afterward** with the `wow-addon:` skills (`review`, `sync-docs`,
  `bump-version`, `bump-interface`, `standards-audit`).
