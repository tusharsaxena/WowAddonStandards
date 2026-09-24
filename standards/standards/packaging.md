> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Packaging (`.pkgmeta`)

Every addon **MUST** ship `.pkgmeta` at the root for packager configuration (package name, ignore lists). Libraries are **vendored and committed** (library-stack-§3), so `.pkgmeta` **MUST NOT** contain an `externals:` block.

Minimum template:

```yaml
package-as: <Addon>

# Libraries are vendored in libs/ and committed to git — NOT fetched as externals.

ignore:
  - .luacheckrc
  - .pkgmeta         # dev-only: this file configures the packager; it is not part of the package
  - .gitignore
  - .gitattributes   # dev-only: the repo's line-ending policy (line-endings)
  # - .claude        # ONLY in a repo that HAS a .claude/ — dev-only agent tooling, never loaded by
  #                    the client. Copied in when the directory appears, and left out until then.
  # - .superpowers   # ONLY in a repo that HAS a .superpowers/ — same tooling, same condition.
  - docs        # holds docs/audits/, docs/reviews/ and docs/revendor/ too — all dev-only
  - tests
  # - tools          # ONLY in a repo that HAS a tools/ (layout-§1: the home for a generator the
  #                    repo authors and commits). Copied in when the folder appears, and left out
  #                    until then — PanelMaster/.pkgmeta:10-15 records the collection's own call
  #                    on this, that "a list padded with absent entries goes stale in the other
  #                    direction". The audit check gates on `[ -d tools ]` for the same reason.
  - media/logos/*.png   # the editable logo source (layout-§4): committed, never loadable, never shipped
  - media/logos/*.jpg   # a .jpg render of the logo, for the project page; same reason
  - _dev
  - "*.bak"
```

**This is a template, and an entry binds only when the entry exists.** A list padded with absent entries
goes stale in the direction nobody notices: an ignore line for a directory that is not there asserts
something false, and the next reader cannot tell a forward declaration from a mistake. What a repo owes is
the strong form below — the root entries it actually has, each ignored or justified.

- **MUST** vendor and commit every library the addon uses (library-stack-§3). **MUST NOT** declare `externals:`; **MUST** commit `libs/` to git as part of the addon.
- **MUST** ignore `docs/` (which now holds the audit, review and re-vendor histories under `docs/audits/`, `docs/reviews/` and `docs/revendor/`, audit-review-history), `_dev/`, `tests/`, `tools/` **if the repo has one** (the home layout-§1 gives a generator the repo authors and commits — an addon with no generator has no such folder and owes no such line, which is why the template above carries it commented out and `AUDIT.md`'s check gates on `[ -d tools ]`), lockfiles, the root dev-only dotfiles `.luacheckrc`, `.pkgmeta`, `.gitignore` and `.gitattributes`, and the **agent-tooling directories** `.claude/` and `.superpowers/` **where the repo has them**, in the package (dev-only; not shipped to players). `.gitattributes` is mandatory at every repo root (`line-endings-§1`) and governs the git checkout rather than the packaged addon, so it belongs on this list for exactly the reason `.gitignore` already does. `.claude/` and `.superpowers/` are named here rather than left to the reader's judgment because the judgment call was made wrong five times: the rule has said *dev-only; not shipped to players* since the section existed, and five addons still had a multi-file agent-tooling directory inside the packaged AddOn, one of them re-filed unchanged on two consecutive audit dates. The condition is not a loophole: a repo that has either directory owes the line, and the strong form below catches it whether or not this template named it. **Seven** of the eleven addons have only one of the two directories, or neither — three hold `.superpowers` alone, two hold `.claude` alone, and two hold neither. Those seven fall into three states. **Four** of them argue the omission in a committed `.pkgmeta` comment, in the terms this bullet uses: no such directory exists at this root, so naming one would assert something false. **One** simply says nothing about the directory it does not have, which the strong form permits and which this bullet does not require it to defend — the condition binds what a repo *lists*, not what it explains. **Two** carry an `ignore:` line for a directory they do not have — one for `.claude`, one for both — which is the same mistake pointed the other way, and it is invisible because an ignore line for an absent path costs nothing at package time and so is never contradicted by a build, which is why `AUDIT.md`'s packaging check needed a third branch before any run could see it at all. Two audits then filed the same gap from opposite directions, one for omitting a present directory and one for naming an absent one. That is the split this condition settles. `.pkgmeta` ignores itself for the same reason `.luacheckrc` does — it is packager configuration, consumed before the zip is built and of no use to a player inside it — and it is named here because the template above used to omit it. That block listed `.luacheckrc`, `.gitignore`, `.gitattributes`, `.claude` and `.superpowers` and left out the one file it is itself an instance of, so the seven addons that copied it faithfully — AbsorbTracker (`.pkgmeta:5-17`), BankLedger, KickCD, LootHistory, PanelMaster, PrettyChat and WhatGroup — failed the strong-form check below on a line this section never gave them; only ConsumableMaster (`.pkgmeta:12`) and MultiMeters (`.pkgmeta:9`) wrote it unprompted. A minimum template that cannot itself satisfy the section's own MUST manufactures non-compliance in every repo that trusts it, which is a defect in this document rather than in nine `.pkgmeta` files.
- **The list is the ignore rule's weak form; the check below is its strong one (MUST).** Every root dotfile and dot-directory present in the repo **MUST** either appear in `.pkgmeta`'s `ignore:` list, or carry a comment beside it saying why it is **deliberately packaged**. Branch two is narrow on purpose, and it is narrower than it used to read. A **commented-out** `ignore:` line — the shape the template above uses for `.claude`, `.superpowers` and `tools` — is an *absent entry carrying its own explanation*, not a justification for shipping anything; a repo that has the directory and leaves its line commented out satisfies **neither** branch and fails this MUST. Read the other way, the template would discharge the strong form for every entry it names in advance, and the MUST would assert nothing about any repo. An enumeration goes stale the moment a new tool writes a new dot-directory, and the failure is silent in exactly the direction that matters — the package grows and nothing says so. The check belongs in the audit run rather than in an auditor's memory; `AUDIT.md` carries it.
- **MUST NOT** use `enable-toc-creation` flavor fan-out — the addon is Retail-only with a single TOC (toc-file-§3).
- **MAY** use `move-folders:` only when the repo is a monorepo for multiple addons (out of scope today).

CI (GitHub Actions) is **out of scope** for this standard per Ka0s decision. **Local** testing and linting are **in scope** — see testing.
