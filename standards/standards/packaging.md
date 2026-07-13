> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Packaging (`.pkgmeta`)

Every addon **MUST** ship `.pkgmeta` at the root for packager configuration (package name, ignore lists). Libraries are **vendored and committed** (library-stack-§3), so `.pkgmeta` **MUST NOT** contain an `externals:` block.

Minimum template:

```yaml
package-as: <Addon>

# Libraries are vendored in libs/ and committed to git — NOT fetched as externals.

ignore:
  - .luacheckrc
  - .gitignore
  - docs        # holds docs/audits/ and docs/reviews/ too — all dev-only
  - tests
  - _dev
  - "*.bak"
```

- **MUST** vendor and commit every library the addon uses (library-stack-§3). **MUST NOT** declare `externals:`; **MUST** commit `libs/` to git as part of the addon.
- **MUST** ignore `docs/` (which now holds the audit and review histories under `docs/audits/` and `docs/reviews/`, audit-review-history), `_dev/`, `tests/`, and lockfiles in the package (dev-only; not shipped to players).
- **MUST NOT** use `enable-toc-creation` flavor fan-out — the addon is Retail-only with a single TOC (toc-file-§3).
- **MAY** use `move-folders:` only when the repo is a monorepo for multiple addons (out of scope today).

CI (GitHub Actions) is **out of scope** for this standard per Ka0s decision. **Local** testing and linting are **in scope** — see testing.
