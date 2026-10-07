# 01 — Current state: WowAddonStandards (2026-10-07)

First standards audit of this repository. No earlier `docs/audits/` bundle exists here, so the
deviation-ID prefix is assigned now: **`WAS-`** (WowAddonStandards). Later runs reuse it.

## How this run was set up

| Item | Value |
|---|---|
| Repo | `/mnt/d/Profile/Users/Tushar/Documents/GIT/WowAddonStandards`, branch `feat/2026-10-07-review-audit-remediation` |
| HEAD | `f47238929230c0059409e1b0a8d69cea99123bd9` (2026-10-07 15:13 +0530), equal to `master` and `origin/master` |
| Tree | Clean apart from `?? docs/reviews/`, which a parallel `dev-copilot:review` run is writing in this same cycle |
| Repo kind | **Documentation and tooling.** `dev-copilot-profile` reported `profile=wow kind=standards reason=name:WowAddonStandards`. `standards/ADDONS.md:58-61` agrees: this repo is in the *Documentation-and-tooling repos* table. The discriminator agrees too: `git ls-files '*.toc'` returns 0 and there is no `libs/` payload. |
| Rule set | **documentation-§8's applicability lists** (the documentation lane): internal consistency, cross-reference resolution, worked-example currency and inventory currency, plus the line-ending policy and the register read. |
| Standard version | **v2.76.1 (2026-10-07)**, from `standards/STANDARDS.md:1` |
| Source of the rules | **Working tree, not a fetch.** This repo publishes the rules being audited, so reading them from raw GitHub `master` would compare the tree against a possibly older copy of itself. For the record, `master` was also fetched with `curl -fsSL`. `AUDIT.md`, `standards/STANDARDS.md`, all 27 section files and `standards/ADDONS.md` are byte-identical to the working tree (`cmp`, 30 of 30 files). **The fetched `master` did not differ.** |

## Tree inventory (from `git ls-files`)

- 67 tracked files: 63 `.md`, plus `.gitattributes`, `LICENSE`, `media/logos/ka0s.logo.jpg` and `media/logos/ka0s.logo.png`.
- 0 `.lua`, 0 `.sh`, 0 `.py`, 0 `.toc`. `git ls-files '*.lua' | grep -vE '^(libs/|tests/_kit/)'` returns 0, so `layout-§1`'s cap and its census have nothing to apply to.
- The standard has 27 section files under `standards/standards/`. `STANDARDS.md`'s Sections list links exactly those 27 (diffed, no extras and none missing). The index carries 99 changelog entries, v1.0.0 through v2.76.1.
- `anti-patterns` runs #1 to #92. No reference anywhere in the live docs points past #92.
- Eleven section files have no numbered subsections: `anti-patterns`, `audit-review-history`, `compat`, `lint`, `naming-cheatsheet`, `open-evolutions`, `packaging`, `preview-mode`, `public-api`, `standalone-windows`, `versioning-git`. This matches `CLAUDE.md:91-95` and documentation-§6.
- Frozen stores: `harvests/2026-08-25/` and `harvests/2026-09-22/` (12 files), and `standards/_raw/_industry/` (10 files).

## Section by section, against documentation-§8

documentation-§8 sorts every section into three lists: *Applies, unchanged*, *Does not apply*, and *Applies, read for a documentation-and-tooling repo*.

### Applies, unchanged

| Section | State here |
|---|---|
| `line-endings` | `.gitattributes` exists. Pin `* text=auto eol=lf` at `:28`, `*.sh text eol=lf` at `:36`, 20 `binary` lines. **`*.py text eol=lf` is missing**, and the shebang comment block at `:30-35` is the text from before v2.61.0, so the body does not diff clean against line-endings-§5's non-client canonical file (85 lines; this file is 82). Check (e) found **0** files disagreeing with the pin. See WAS-02. |
| `versioning-git` | Standard is versioned (v2.76.1). The changelog is newest-first except at one point: v2.19.0 (`STANDARDS.md:218`) sits below v2.17.1 (`:217`). See WAS-13. |
| `documentation-§4` | No `TODO.md` is tracked (`git ls-files` match count 0). Compliant. |
| `documentation-§5` | This section carries most of the findings. Several docs say no audit lands here (WAS-01), the adoption-state claims are stale (WAS-03), file:line examples have rotted (WAS-04/05), the inventories are stale (WAS-06), and two summaries list the Tier 2 docs incompletely (WAS-11). |
| `documentation-§6` | Retired dotted notation: 0 hits. Malformed references: 2 in changelog entries (`STANDARDS.md:120`, `:168`) and 1 wrong item pointer (`documentation.md:259`). See WAS-08. §6's frozen-store exemption list disagrees with documentation-§3's (WAS-09). |
| `localization-§5` | The British-spelling sweep finds forms only where a document quotes the forbidden spelling as an example (`CLAUDE.md:138`, `anti-patterns.md:52`, `localization.md:182-251`, `NEW_ADDON_CONTEXT.md:1485/1575/1593`) or inside changelog entries that describe the sweep. Compliant. |
| `audit-review-history` | The deviation register exists (`docs/ARCHITECTURE.md:90-92`, "**None.**"). The issue store uses `state:` and `severity:` labels, has no `[status]` title prefixes, and there is no `docs/pending/LEDGER.md`. **This bundle is the first `docs/audits/` store in the repo**, and a `docs/reviews/` store is being written beside it. Several repo docs still say neither ever lands here (WAS-01). |
| `open-evolutions` | A record of open directions. Nothing is filed against it. |

### Does not apply (documentation-§8, recorded as compliance, not as deviation)

`toc-file`, `options-ui`, `slash-commands`, `preview-mode`, `launcher`, `savedvariables`, `standalone-windows`,
`debug-logging`, `events-frames-taint`, `compat`, `public-api`, `packaging`, `architecture`, `library-stack`, `lint`,
`testing`, `performance` and `automated-tests` do not apply here. Neither do documentation-§1's player README shape,
documentation-§2's addon stub, or documentation-§3's trio, tier model and verification-and-record set. The repo has
no `.lua`, so none of them has anything to bind to.

The mechanical checks that bind only to Lua or a vendored payload are recorded **not applicable**, with the reason:

- `luacheck`: no `.luacheckrc` and no Lua.
- The headless runner: no `tests/`.
- The vendored-library `diff -r` and the `CLAUDE.md` provenance line: no `libs/` and no `tests/_kit/`.
- The `lizard` / sighted complexity suite: no functions.
- The disabled-state census: no addon runtime.

### Applies, read for a documentation-and-tooling repo

| Section | State here |
|---|---|
| documentation-§3's `ARCHITECTURE.md` (five sections) | `docs/ARCHITECTURE.md` (108 lines) carries all five: `## Overview` `:15`, `## Module Map` `:29` (read as the file-and-path map), `## Known Limitations` `:52`, `## Documentation map` `:67`, `## Documented deviations` `:90`. It does not write the other five sections as "not applicable" rows. Compliant in shape. The map does not name `docs/audits/` or `docs/reviews/`, and its claim that "every `.md` in this repo appears in exactly one row" (`:69`) stops being true once this bundle is committed (WAS-01a). |
| `documentation-§7` | `DEPENDENCIES.md` gives git as the only required tool and has a not-used-here table with reasons. Compliant in shape. Its census line (`:14`, "67 tracked files: 63 Markdown") is right today and goes stale when this bundle commits (WAS-01b). Its claim that the file is "the non-client canonical body" (`:63-65`) is false while WAS-02 stands. |
| `layout` | Folder casing: `docs/`, `harvests/`, `media/logos/`, `standards/`, `standards/standards/`, `standards/_raw/_industry/`. Compliant. The cap, census and `tools/` rule have nothing to apply to (0 Lua, 0 generators). |
| `naming-cheatsheet` | No authored identifiers. Nothing applies. |
| `anti-patterns` | Applies whole. #57, the `*.sh`-only `.gitattributes`, does not fire because the pin line is present. Every other entry is keyed to an addon artifact and has nothing here to fire on. |
| `lint` / `testing` / `automated-tests` re-read trigger | The trigger is "the first `.lua` this repo tracks outside a frozen bundle". It has not fired (0 tracked `.lua`). |

### Substitutes (documentation-§8 items 1–4)

1. Root `CLAUDE.md` opens with `## What this repo is` (`:5`). Present.
2. `DEPENDENCIES.md`. Present.
3. `docs/ARCHITECTURE.md` with five sections. Present.
4. `README.md` written for contributors. Present.

## The four documentation-lane checks, in summary

| Check | Result |
|---|---|
| Internal consistency between rules | **Five inconsistencies:** documentation-§3 numbers the hub's sections ninth and tenth in the opposite order from its own list (WAS-07). documentation-§6's frozen-store exemption disagrees with documentation-§3's out-of-scope stores (WAS-09). documentation-§8 calls its lists exhaustive and misses localization-§1–§4 and documentation-§9 (WAS-10). documentation-§8's line-endings row contradicts line-endings-§3 (WAS-02a). EXECUTIVE_SUMMARY says "eleven" where documentation-§3 says "nine of nine" (WAS-06). |
| Cross-references resolve | 27 of 27 Sections links resolve. Outside placeholder templates and frozen bundles, every `filename-§N` resolves except two malformed changelog references and one wrong item pointer (WAS-08). All 16 distinct `dev-copilot:<command>` names resolve to `../dev-copilot/commands/*.md`. Every `tests/_kit/<file>` a doc names exists in `LibKa0s/testkit/` on `master`. No relative Markdown link is broken (the 40 apparent hits are placeholders or sibling-repo paths that exist). |
| Worked examples match the cited repo | **61 file:line citations re-read in 13 sibling repos. 12 still match, 43 point at different content, and 6 name files that no longer exist** (WAS-04). The one citation inside the executed playbook (`AUDIT.md:523`) is among those that rotted (WAS-05). |
| Inventories match the tree | The `LibKa0s` count is right everywhere: "fifteen majors across thirty-four files" matches `LibKa0s` v1.70.0 (34 ship `.lua`, 15 `major =` lines, 34 `<Script` lines). The section count (27), anti-pattern count (92), bare-filename list (11), roster (11 addons, 14 repos) and industry study (10) are right. **Stale:** the re-vendor store figures (68 bundles in 10 stores, now 225 in 11), the cap-heading census (4 repos, now 11), the hub self-row split (5 to 4, now 6 to 5), `LSMPatch.lua` (5 files, now 0), the Compat sizes, PrettyChat's generator location, and the launcher, Lifecycle and test_disabled adoption state (WAS-03, WAS-06). |

## Register read

- `docs/ARCHITECTURE.md:90-92`: `## Documented deviations`, "**None.**"
- `gh issue list --state all`: 7 issues, all closed. `state:done`: #1, #6, #7. `state:will-not-do`: #2, #3, #4, #5. Every issue carries a `severity:` label.
  - #3, #4 and #5 decline proposed **collection work**: backfilling `ANALYSIS.md`, annotating every TOC line, and a one-step lint flip.
  - #2 declines a duplicate of #1's contradiction report. Re-checked: `toc-file-§5` and `layout-§1` now give the same order, Libraries → Locales → Core → Defaults → Modules → Settings (`layout.md:55`, `toc-file.md:110`).
  - None of the four is a departure of **this repo** from a MUST or SHOULD, so none owes a register row, and the inverse-rule finding does not fire (WAS-14).
- `CLAUDE.md` carries no accepted-deviation note. There is no `docs/scope.md`.
