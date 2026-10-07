# 05 — Execution plan: WowAddonStandards (2026-10-07)

This plan is handed to the separate remediation engagement. Every step is a text edit in this repo
unless it says otherwise. A step is done when a commit whose subject starts with its ID exists
(for example `WAS-03: …`). Run everything on the cross-repo feature branch the owner authorizes.
Nothing merges to `master` without the owner's go-ahead.

**Figures.** These are the same figures `02_DEVIATIONS.md` and `03_EVIDENCE.md` use: 15 roots and 20
including dependents; 61 citations re-read, of which 12 match, 43 have rotted and 6 are gone; 225
re-vendor bundles in 11 stores; 140 `docs/superpowers/` notation hits.

## Sprint 1: changes that alter the next run (Medium)

| Step | IDs | Change | Check |
|---|---|---|---|
| 1.1 | WAS-03 | `AUDIT.md:541-543` and `:652-657`, `launcher.md:92`, `slash-commands.md:200`: put the dated census in the past tense and delete "expect findings / expected non-compliant". | `grep -nE 'Expect findings here|expected to be non-compliant until|non-compliant with this section until it adopts' AUDIT.md standards/standards/*.md` returns nothing. |
| 1.2 | WAS-05 | `AUDIT.md:523`: cite `` `modules/Browser.lua` `B:MakeCloseButton` `` instead of `:98`. | `git -C ../BankLedger show master:modules/Browser.lua \| grep -n 'function B:MakeCloseButton'` hits, and the AUDIT.md text names that symbol. |
| 1.3 | WAS-09 | `documentation.md:625-637`: point the frozen-store exemption at documentation-§3's list, add the repo-own-frozen-store clause (`harvests/`, `standards/_raw/`), and replace the sweep command with a `git ls-files` pipeline that excludes those stores. | In LootHistory, the new command reports 0 hits under `docs/superpowers/`. In this repo it still reports 0. |
| 1.4 | WAS-01, 01a, 01b | Qualify "no audits here" in `CLAUDE.md:11-12/:61-62/:107-110`, `docs/ARCHITECTURE.md:23-24`, `README.md:17-18/:154-156/:160-161`, `standards/README.md:5-6`, `standards/ADDONS.md:5-7/:80-82` and `AUDIT.md:3-6`. Add `docs/audits/<date>/` and `docs/reviews/<date>/` rows to the map. Replace the file count at `DEPENDENCIES.md:14`. | Every `.md` under `docs/` is matched by a map row, with the frozen stores matched as directories. `grep -n 'does \*\*not\*\* run audits' CLAUDE.md` returns nothing. |

## Sprint 2: consistency in the standard (Low, MUST)

| Step | IDs | Change | Check |
|---|---|---|---|
| 2.1 | WAS-02 | Replace `.gitattributes` with line-endings-§5's non-client body, extracted mechanically. | `diff <(head -n 85 .gitattributes) <canon_lf>` is empty, the tail is empty, `git add --renormalize .` stages nothing, and the (e) one-liner returns 0. |
| 2.2 | WAS-02a, 02b, 02c | `documentation.md:675`, `CLAUDE.md:123-124`, `EXECUTIVE_SUMMARY.md:52`: name `*.py text eol=lf` beside `*.sh`. | `grep -n 'eol=lf' documentation.md CLAUDE.md EXECUTIVE_SUMMARY.md` shows `*.py` on each touched line. |
| 2.3 | WAS-07 | `documentation.md:170` and `:347`: ordinals consistent with `:148`, or removed. | Read `:148`, `:170` and `:347` together; they agree. |
| 2.4 | WAS-08 | `STANDARDS.md:120` becomes `preview-mode`, `:168` becomes `automated-tests-§3`, and `documentation.md:259`'s item 8 becomes item 6. | The xref sweep (E8 script) reports only placeholders, `harvests/`, `STANDARDS.md:236` and the `documentation.md:596` example. |
| 2.5 | WAS-10 | documentation-§8: add `localization-§1–§4` to *Does not apply* and `documentation-§9` to *Applies, unchanged*, and fix the `:698` arithmetic. | Each of the 27 section files, and each numbered subsection that §8 splits out, is named in exactly one list. |
| 2.6 | WAS-11 | `CLAUDE.md:155-156` and `EXECUTIVE_SUMMARY.md:38`: add `perf-analysis/README.md` to Tier 2. | `grep -n 'slash-dispatch.md' CLAUDE.md standards/EXECUTIVE_SUMMARY.md` lines also name `perf-analysis/README.md`. |

## Sprint 3: examples and inventories (Low)

| Step | IDs | Change | Check |
|---|---|---|---|
| 3.1 | WAS-04 | Add the citation SHOULD to documentation-§6 or §5: cite `Repo@sha:path:line` or a symbol or heading. Then work through E5's 49 rotted and gone sites: pin historical ones to the authoring-date SHA, re-point present-tense ones to a symbol, and put gone ones in the past tense. | Re-run E5's three sets. Every citation is MATCH, SHA-pinned or symbol-named. |
| 3.2 | WAS-06 | Re-derive or date every inventory in the WAS-06 row, using 04's table. | Re-run the E6 commands. Every present-tense figure equals the measurement, or carries an "as of" date. |
| 3.3 | WAS-13 | Move `STANDARDS.md` v2.19.0 above v2.18.0. `standards/README.md:13` becomes "after the Sections map". | The E9 parse reports 0 non-monotonic pairs. |
| 3.4 | WAS-12 (optional) | Remove the hard-coded roster at `README.md:47-49`, or record the exception in `CLAUDE.md:76-78`. | n/a (Info). |

## Sprint 4: release the standard

| Step | IDs | Change | Check |
|---|---|---|---|
| 4.1 | all of the above | Bump to **v2.76.2**. If the owner treats WAS-09's narrowed sweep as a rule change, bump to v2.77.0 instead. Add one changelog entry, first in `## Changelog`, naming each WAS ID. Update `README.md`'s Status line (`:160`). | `head -1 standards/STANDARDS.md` and `README.md:160` agree. |
| 4.2 | WAS-15 | Carry the matching edits to `dev-copilot`'s documentation-lane prompt: `*.py` beside `*.sh`, no "11 of 11 expected to fail", and no rungs (a) and (b). This happens in that repo's own run. | `dev-copilot` commit referencing WAS-15. |

## Not in this plan

- **Editing `harvests/`, `standards/_raw/` or any prior bundle.** They are frozen. The 9 malformed references inside `harvests/` stay as recorded.
- **Re-measuring each addon's disabled-state conformance (WAS-03).** That belongs to each addon's own audit. This plan only stops the playbook from assuming the result.
- **A mechanical gate for this repo**, as `docs/ARCHITECTURE.md` *Known Limitations* says is missing. The E8 xref script and the E5 citation re-read would make a good first one. Adding it would be this repo's first executable content and would fire documentation-§8's re-read trigger only if it were Lua, so it needs a separate decision by the owner.
