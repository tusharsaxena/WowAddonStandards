> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## TOC file

### 1. Required fields

The metadata block **MUST** use this **exact field order** (omit a line only when the field genuinely doesn't apply); no blank lines inside the block:

```
## Interface: 120007                     -- SINGLE number; latest Retail patch (toc-file-§3)
## Title: Ka0s <Human Name>              -- prefix every Ka0s addon
## Notes: <one-line user-facing description>
## Author: add1kted2ka0s
## Version: <semver>                     -- managed by version-bump skill
## IconTexture: <path|fileID>            -- optional but encouraged
## SavedVariables: <Addon>DB             -- single global SV per addon
## OptionalDeps: Ace3, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0
## DefaultState: enabled
## Category-enUS: <Combat|Group|Auction|Chat|UI|Misc>
## X-License: MIT
## X-Standard: https://github.com/tusharsaxena/WowAddonStandards
## X-Curse-Project-ID: <id>              -- mandatory if published
## X-Wago-ID: <id>                       -- mandatory if published
## X-WoWI-ID: <id>                       -- only if WoWI listing exists
```

- **MUST** follow the field order above so every Ka0s TOC reads identically. The file listing that follows the metadata block has its own required structure (toc-file-§5). Reference implementation (in the collection): the Tier-2 modular tracker's TOC.
- **MUST** have `X-License: MIT`. **MUST NOT** ship "All Rights Reserved".
- **MUST** have `X-Standard:` pointing at the standards repo, declaring the addon is built to this standard.
- **MUST** have `X-Curse-Project-ID` and `X-Wago-ID` once an addon is published anywhere.
- **SHOULD NOT** declare hard `Dependencies`. Use `OptionalDeps` and shim missing libs with soft fallbacks. Reference implementation (in the collection): the absorb-shield tracker ships an AceDB-missing flat-table shim and LSM-missing Blizzard fallback constants, so it loads even with no libs present.

### 2. SavedVariables naming

- **MUST** be `<Addon>DB`, single global (`<Addon>DB`). Already universal in the collection.
- **SHOULD NOT** use `SavedVariablesPerCharacter` unless the data is genuinely per-character (most Ka0s addons run profile-per-character via AceDB; that's enough).
- **MUST** declare a `schemaVersion` integer in defaults. **MUST** ship a `Database.lua` migration runner even if the body is empty — schema migration is a from-day-one concern.

### 3. Retail only — single Interface line

The collection targets **Retail (Mainline) only**. Classic/other flavors are out of scope for the standard.

- **MUST** ship a single TOC with a **single** `## Interface:` value = the **latest Retail patch** interface number (currently `120007`). Bump it each patch with the `wow-addon:bump-interface` skill.
- **MUST NOT** use a comma-separated multi-flavor Interface list, per-flavor TOC files, or `enable-toc-creation` flavor fan-out.
- **MUST NOT** ship `_Mainline`/`_Classic` data splits. Data files are plain (`Spells.lua`, `Data*.lua`).
- **MUST NOT** use `if WOW_PROJECT_ID == ...` ladders inline in feature code. Any genuine cross-patch version check is a Retail-patch check and is branched in `Compat.lua` behind a named flag (compat).
- The README `[wow]` badge (canonical template `![WoW](https://img.shields.io/badge/WoW-<Expansion>_<X.Y.Z>-purple)`, documentation-§1 #1) **MUST** show this same single Interface number and stay in lockstep with the TOC: bumping `## Interface:` and updating the badge is **one change**, never deferred (documentation).

### 4. File listing

- **MUST** list `.lua` files in dependency-correct order. **MUST NOT** rely on alphabetical loading.
- **SHOULD NOT** use `embeds.xml` at Tier 1. Tier 2 **MAY** use a single `embeds.xml` if file count justifies it — remove it if it doesn't earn its keep.

### 5. File-listing structure (after the metadata block)

The metadata block (toc-file-§1) is followed by **one blank line**, then the file listing broken into **commented sections in load order**. Every Ka0s TOC uses the same section comments so the load order is self-documenting. Reference implementation (in the collection): the Tier-2 modular tracker's TOC.

```
# Libraries (must load first)
libs\LibStub\LibStub.lua
libs\CallbackHandler-1.0\CallbackHandler-1.0.lua
libs\AceAddon-3.0\AceAddon-3.0.lua
...

# Locales
locales\enUS.lua

# Core
core\Compat.lua
core\Constants.lua
core\State.lua
core\Util.lua
core\Database.lua
core\<Addon>.lua

# Defaults
defaults\Profile.lua

# Modules
modules\<Feature>.lua

# Settings (last — depend on everything else being initialized)
settings\Panel.lua
settings\...
```

- **MUST** use `#` section headers, in the order **Libraries → Locales → Core → Defaults → Modules → Settings**, matching the Tier-2 load order (tiered-layout-§2). Libraries always load **first**; settings **last**.
- **Tier 1** addons keep the `# Libraries (must load first)` section, then list their flat source files (`Compat.lua`, `Locale.lua`, `<Addon>.lua`, `Database.lua`, `Settings.lua`) in dependency order under a single `# Addon` section — no `core/`/`modules/` split (tiered-layout-§1).
- **MUST** end the file with a single trailing newline.
