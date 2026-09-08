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
  - .claude          # dev-only: agent tooling; never loaded by the client
  - .superpowers     # dev-only: agent tooling; never loaded by the client
  - docs        # holds docs/audits/ and docs/reviews/ too — all dev-only
  - tests
  - _dev
  - "*.bak"
```

- **MUST** vendor and commit every library the addon uses (library-stack-§3). **MUST NOT** declare `externals:`; **MUST** commit `libs/` to git as part of the addon.
- **MUST** ignore `docs/` (which now holds the audit and review histories under `docs/audits/` and `docs/reviews/`, audit-review-history), `_dev/`, `tests/`, lockfiles, the root dev-only dotfiles `.luacheckrc`, `.pkgmeta`, `.gitignore` and `.gitattributes`, and the **agent-tooling directories** `.claude/` and `.superpowers/` in the package (dev-only; not shipped to players). `.gitattributes` is mandatory at every repo root (`line-endings-§1`) and governs the git checkout rather than the packaged addon, so it belongs on this list for exactly the reason `.gitignore` already does. `.claude/` and `.superpowers/` are named here rather than left to the reader's judgment because the judgment call was made wrong five times: the rule has said *dev-only; not shipped to players* since the section existed, and five addons still had a multi-file agent-tooling directory inside the packaged AddOn, one of them re-filed unchanged on two consecutive audit dates. `.pkgmeta` ignores itself for the same reason `.luacheckrc` does — it is packager configuration, consumed before the zip is built and of no use to a player inside it — and it is named here because the template above used to omit it. That block listed `.luacheckrc`, `.gitignore`, `.gitattributes`, `.claude` and `.superpowers` and left out the one file it is itself an instance of, so the seven addons that copied it faithfully — AbsorbTracker (`.pkgmeta:5-17`), BankLedger, KickCD, LootHistory, PanelMaster, PrettyChat and WhatGroup — failed the strong-form check below on a line this section never gave them; only ConsumableMaster (`.pkgmeta:12`) and MultiMeters (`.pkgmeta:9`) wrote it unprompted. A minimum template that cannot itself satisfy the section's own MUST manufactures non-compliance in every repo that trusts it, which is a defect in this document rather than in nine `.pkgmeta` files.
- **The list is the ignore rule's weak form; the check below is its strong one (MUST).** Every root dotfile and dot-directory present in the repo **MUST** either appear in `.pkgmeta`'s `ignore:` list or be justified in a comment beside it. An enumeration goes stale the moment a new tool writes a new dot-directory, and the failure is silent in exactly the direction that matters — the package grows and nothing says so. The check belongs in the audit run rather than in an auditor's memory; `AUDIT.md` carries it.
- **MUST NOT** use `enable-toc-creation` flavor fan-out — the addon is Retail-only with a single TOC (toc-file-§3).
- **MAY** use `move-folders:` only when the repo is a monorepo for multiple addons (out of scope today).

CI (GitHub Actions) is **out of scope** for this standard per Ka0s decision. **Local** testing and linting are **in scope** — see testing.
