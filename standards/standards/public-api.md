> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Public API surface

If your addon exposes any function or data for third-party consumption:

- **MUST** version-namespace it: `NS.API = NS.API or {}; NS.API.v1 = {...}`. Public consumers reference `MyAddon.API.v1.SomeFunction`.
- **MUST** publish via `_G[addonName] = { API = NS.API }`, so the consumer path above resolves: the global holds only an `API` key carrying the versioned surface, never the whole NS and never `NS.API` itself (which would put `v1` at `MyAddon.v1`). Publish it with `rawset` where the lint config forbids setting a global.
- **MUST** document the v1 contract in `docs/ARCHITECTURE.md` and treat it as semver-stable.
- **SHOULD NOT** break v1 even if the implementation changes; introduce v2 as a sibling table.
- Ka0s-internal addons currently expose nothing; this rule is for future addons that other addons anchor to, or that expose hooks.
