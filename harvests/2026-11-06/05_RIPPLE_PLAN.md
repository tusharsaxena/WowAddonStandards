# Harvest 2026-11-06 — 05 Ripple plan

For each proposal, every file the change must touch, resolved to paths in this repo. `06_OUTCOME.md` discharges
this list item by item. Common to every accepted proposal: the changelog entry in `standards/STANDARDS.md`, the
previous entry moved verbatim to the top of `standards/CHANGELOG.md`, the front-matter version and date, the
`EXECUTIVE_SUMMARY.md` current-version pointer, the `NEW_ADDON_CONTEXT.md` pack version, the version cited in
`CLAUDE.md`'s doc-set paragraph, and `bash scripts/check-standard.sh` exiting 0.

## P-01
- `standards/standards/library-stack.md` — *The modules* count and list; the module table (new IconBrowser row;
  Toast row; Widgets row); *Inter-module dependencies* counts.
- `standards/STANDARDS.md` — the library-stack blurb's count.
- `standards/EXECUTIVE_SUMMARY.md` — the LibKa0s count and module list.
- `standards/standards/open-evolutions.md` — the two "twenty" counts; close *A library context menu*.
- `scripts/check-standard.sh` — the `libka0s-counts` check.
- `DEPENDENCIES.md` — the check list and how the new check is verified.
- `standards/NEW_ADDON_CONTEXT.md` — only if it states the count (it does not: grep on 2026-11-06).

## P-02
- `standards/standards/events-frames-taint.md` — §2.
- `standards/STANDARDS.md` — the events-frames-taint blurb does not state the timing: not applicable.
- `standards/NEW_ADDON_CONTEXT.md` — grep for "true from `PLAYER_REGEN_DISABLED`"; update if present.

## P-03
- `standards/standards/packaging.md` — the template and the MUST bullets.
- `standards/STANDARDS.md` — the packaging blurb lists the conditional entries; add it.
- `standards/NEW_ADDON_CONTEXT.md` — the `.pkgmeta` template.
- `AUDIT.md` — only if it enumerates the conditional entries.

## P-04 (Reading B)
- `standards/standards/documentation.md` — §5 and §6.
- `standards/STANDARDS.md` — the documentation blurb.
- `standards/NEW_ADDON_CONTEXT.md` — the docs guidance.
- `AUDIT.md` — the documentation-§5 check's fix direction.

## P-05
- `standards/standards/client-quirks.md` — new section.
- `standards/STANDARDS.md` — the Sections list entry.
- `standards/standards/documentation.md` — Tier 2 `midnight-quirks.md` trigger and content rule.
- `standards/standards/events-frames-taint.md` — §1's pointer to "the addon's quirks doc".
- `CLAUDE.md` — the eleven-unnumbered-files list if the new section has no numbered subsections.
- `standards/NEW_ADDON_CONTEXT.md`, `standards/EXECUTIVE_SUMMARY.md`, `AUDIT.md`.

## P-06 (Reading A)
- `standards/standards/documentation.md` — §3 hub and Tier 2 list.
- `CLAUDE.md` — the Tier 2 member list in the doc-set paragraph.
- `standards/STANDARDS.md` — the documentation blurb.
- `standards/NEW_ADDON_CONTEXT.md`, `AUDIT.md`.

## P-07
- `standards/standards/open-evolutions.md` only.

## P-08
- `standards/standards/documentation.md` — §3, the `docs/superpowers/` passage.
- `standards/NEW_ADDON_CONTEXT.md` — if it describes the store (grep).
