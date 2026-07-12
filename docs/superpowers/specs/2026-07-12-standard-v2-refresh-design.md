# Design — Ka0s Addon Standard v2.0 refresh (2026-07-12)

**Type:** documentation refresh of the living standard (no addon code is touched).
**Trigger:** owner request to refresh `standards/` per `standards/README.md` → *How to (re)build
`01_STANDARD.md`*. This is a **standards refresh, not an audit** — no dated `audit/` run is produced.

**Gold-standard addons** (tie-breakers when the standard is silent): **Ka0s Loot History** and
**Ka0s KickCD**. Findings below are grounded in their actual code.

## Owner decisions (locked)

1. **Flavor scope:** Retail only. Drop the multi-flavor apparatus.
2. **Planning/review docs:** *keep* them — the "delete after commit" idea from the request was
   withdrawn. §16 retention stands; no removal rule is added.
3. **Version:** major bump to **v2.0**.
4. **Root docs:** `README.md` stays full at root; `CLAUDE.md` becomes a **stub** pointer at root;
   `ARCHITECTURE.md` and all other docs move under `docs/`.
5. **Media folder:** typed subfolders, logos folder named **`media/logos/`** (plural).
6. **Debug SV persistence:** **SHOULD** (strong guideline), not MUST.

## Standards repo URL

All addons must reference **https://github.com/tusharsaxena/WowAddonStandards** and declare adherence.

## Global rule — no named addon implementations in the normative standard

The normative documents (`01_STANDARD.md`, `00_EXECUTIVE_SUMMARY.md`, `02_NEW_ADDON_CONTEXT.md`)
**MUST NOT** name a specific addon (Ka0s-collection or industry) as a reference implementation.
Instead, **describe** the implementation — what it does and how — in enough detail to be actionable
on its own. This keeps the standard self-contained and durable as addons change or are renamed.
A `§0` note records this convention. The companion research doc `03_INDUSTRY_RESEARCH.md` is the
**cited-evidence layer** and keeps its named references (its whole purpose is attributing patterns to
the addons they were observed in); `§0` makes this split explicit. De-naming map used consistently:
Loot History → "the collection's standalone loot-history data-browser addon"; KickCD → "the
collection's Tier-2 modular interrupt/cooldown group tracker"; AbsorbTracker → "the collection's
absorb-shield tracker"; WhatGroup → "the collection's Tier-1 flat group-composition utility";
prettychat → "the collection's chat-formatting addon"; ConsumableMaster → "the collection's
consumables & macro manager"; industry names → described by class ("large boss-mod frameworks",
"the major aura framework", "full UI-replacement suites", "nameplate frameworks", "damage meters",
"party-cooldown trackers", "bag-replacement addons", "auction-house addons").

---

## Change set

Each item lists the rule change and the sections/files it ripples into. Primary edits land in
`standards/01_STANDARD.md`; every item also ripples into `00_EXECUTIVE_SUMMARY.md` and
`02_NEW_ADDON_CONTEXT.md` (trees, cheat-sheet, forbidden list, Definition of Done) unless noted.

### A. Version & framing
- `01_STANDARD.md` title → **v2.0 (2026-07-12)**; new changelog entry summarizing B–J.
- `00_EXECUTIVE_SUMMARY.md`: bump "current vX" + the "Since v1.0" line.
- `02_NEW_ADDON_CONTEXT.md`: header → v2.0.
- `03_INDUSTRY_RESEARCH.md`: short **v2.0 addendum** paragraph (headless Lua/luacheck testing,
  on-screen debug consoles, unlock/preview modes). Not a full 10-addon re-survey — these changes are
  collection-preference-driven.

### B. Retail-only, single Interface *(reverses §2.1, §2.3, §1.2, §11, anti-pattern #15)*
- §2.1 TOC example → `## Interface: 120007` (one number, latest Retail patch).
- §2.3 rewritten: **Retail only.** No comma multi-flavor lists, no per-flavor TOCs, no
  `_Mainline`/`_Classic` data splits. Bump the single number each patch (`wow-addon:bump-interface`).
- §1.2 tree: "single Interface line (latest Retail)"; `defaults/` data files drop the flavor suffix
  (`Spells.lua`, `Data*.lua`).
- §11 Compat: keep `Compat.lua` for deprecated-API shims across Retail patches; **drop**
  `Compat.IsClassic` and the `WOW_PROJECT_ID` ladder framing (anti-pattern #9 reframed to
  "route Retail-patch version checks through Compat").
- Anti-pattern #15 ("per-flavor TOC duplication") → replaced by "multi-flavor / Classic support —
  out of scope; Retail only."
- Grounding: KickCD `KickCD.toc:1` and LootHistory `LootHistory.toc:1` already ship
  `## Interface: 120007`.

### C. Vendor all libs — already law
Already mandated since v1.1 (§3.3, §13). No rule change; reaffirmed in the v2.0 changelog only.

### D. Docs → `docs/`; root = README + stub CLAUDE.md *(reverses §15 layout)*
- Root keeps **only**: `README.md` (full, user-facing), `CLAUDE.md` (**stub** — a short pointer to
  `docs/` for the full agent context), `LICENSE`.
- `ARCHITECTURE.md`, the full agent-context pack, `TODO.md`, and all planning/reference docs live
  under `docs/`.
- Update the §1.1 and §1.2 file trees accordingly; `.pkgmeta` already ignores `docs/`.
- Note: gold-standard addons currently keep a *full* `CLAUDE.md` + `ARCHITECTURE.md` at root — the
  rule leads them; they close the gap at remediation.

### E. Testing / TDD / lint / local build *(new §14A; LootHistory reference)*
- Every addon **MUST** ship a `tests/` folder using LootHistory's headless plain-Lua-5.1 harness:
  - `run.lua` — runner + micro-framework (`test`, `assertEqual`, `assertTrue`, `assertFalse`;
    exposes them to suites via a `_G.<ADDON>_TEST` table; exits non-zero on any failure).
  - `loader.lua` — headless source loader: `loadfile` each source, `setfenv(chunk, makeEnv(mocks))`,
    call `chunk(addonName, NS)` to reproduce the `local addonName, NS = ...` header, in TOC order.
  - `wow_mock.lua` — WoW API mock builder (self-returning no-op frame stub; `CreateFrame`,
    `UIParent`, `Settings.*`, `LibStub` with `AceDB-3.0`/`AceAddon-3.0` fakes).
  - `test_<module>.lua` — one suite per module.
- Commands: run `lua tests/run.lua` (repo root); lint `luacheck .` = **0 errors**; single-file syntax
  `luac -p <file>`.
- Local toolchain: `sudo apt-get install -y lua5.1 luarocks` then `sudo luarocks install luacheck`.
  WoW runs Lua 5.1, so tests target 5.1.
- **TDD MUST:** write/extend a failing test first → implement → both `lua tests/run.lua` (all pass)
  **and** `luacheck .` (0 errors) **before every commit**.
- Reconcile the old "CI out of scope" note: **local** testing is now in scope; GitHub Actions stays
  out of scope.
- Ripple: `.luacheckrc` and `.pkgmeta` `ignore:` exclude `tests/`; §16 in-game smoke tests remain and
  complement unit tests; Definition of Done gains a test/lint gate.

### F. Preview / test mode *(new §6B; KickCD reference)*
- Addons with a positionable/persistent UI **SHOULD** ship a **preview (a.k.a. test/demo) mode** that
  renders representative placeholder data so the user can see and position the frame without waiting
  for real events. Reference: KickCD castbar preview (`modules/Castbar.lua` `ShowPreview`, shown while
  the frame is unlocked). Trigger via unlock-coupling and/or an explicit `/<slash> preview` verb.
  Utility addons with no such surface: N/A.

### G. Debug container *(extends §12; LootHistory reference)*
- Addons with a standalone main window (§6A) **MUST** route debug output to a **dedicated on-screen
  debug console styled like the addon's main window**, not the chat frame. Reference: LootHistory
  `modules/DebugLog.lua` (`LootHistoryDebugWindow`):
  - `BackdropTemplate` frame on **DIALOG** strata (above the main window), draggable title bar,
    1px divider, ElvUI-style close glyph, **Clear** + **Copy** buttons.
  - Log surface: `ScrollingMessageFrame`, `SetMaxLines(500)`, mouse-wheel, `GameFontHighlightSmall`.
  - **Copy** window: read-through multiline `EditBox` dumping the buffer, auto-highlighted for Ctrl+C.
  - Registered in `UISpecialFrames` (ESC closes); reuses the addon `SKIN`/`ApplySkin` seam.
  - Sink `NS.Debug(fmt, ...)`: zero-alloc gate when off; timestamps each line (grey `HH:MM:SS`).
  - Toggle via `/<slash> debug`.
- Enabled-state **SHOULD** persist in SavedVariables (strong guideline, not MUST). KickCD persists
  (`db.profile.debugLog`); LootHistory's session-only `NS.State.debug` is acceptable under SHOULD.
- Tier-1 utility addons with no window **MAY** fall back to `NS.PREFIX`-tagged chat output.
- §12 keeps its existing "MUST ship a debug seam / MUST be zero-allocation when off / MUST be
  toggleable via slash" rules; this item upgrades the *destination* to an on-screen console.

### H. Settings entry always visible *(extends §6.1; WhatGroup is the anti-pattern)*
- **MUST** register the Blizzard settings **category eagerly at load** (in `OnInitialize`, or a
  `PLAYER_LOGIN`/`ADDON_LOADED→Blizzard_Settings` bootstrap) so the entry is **always** present in
  the options list; build the **body lazily** on first `OnShow`. Reference: KickCD
  (`settings/Panel.lua` bootstrap frame) + LootHistory (`core/LootHistory.lua` `OnInitialize`).
- **MUST NOT** defer category registration to first `/config`/panel-open. WhatGroup
  (`WhatGroup.lua` `runConfig` → `WhatGroup_Settings.lua:1010`) does exactly this; its own comment
  frames it as boot-taint avoidance, but the correct taint-free fix is *register after
  Blizzard_Settings is available + keep the body lazy*, which is what both gold-standard addons do.
- New anti-pattern: "Deferring settings-category registration until first slash/panel-open."

### I. Media subfolders *(extends §1 trees, §6.5)*
- Shipped media **MUST** live in typed subfolders — **`media/logos/`**, `media/screenshots/`, plus
  `media/fonts/`, `media/sounds/`, `media/textures/` as needed; nothing loose directly in `media/`.
- Update §6.5 logo path guidance from `media/logo/` → **`media/logos/`** (plural, owner decision).
  LootHistory's `media/logo/` becomes a remediation gap.

### J. Reference the standards repo *(new; §15 + TOC)*
- Every addon **MUST** reference **https://github.com/tusharsaxena/WowAddonStandards** and declare
  adherence:
  - `README.md`: a line/badge — "Built to the Ka0s WoW Addon Standard" linking the repo.
  - root `CLAUDE.md` stub: a line stating adherence to the standard at that URL.
  - TOC: new field `## X-Standard: https://github.com/tusharsaxena/WowAddonStandards`.
- Added to Definition of Done and the §2.1 TOC field list.

---

## Files edited (this repo only)

- `standards/01_STANDARD.md` — primary; all of B–J + A changelog/version.
- `standards/00_EXECUTIVE_SUMMARY.md` — version line, "since v1.0" line, pattern list touch-ups.
- `standards/02_NEW_ADDON_CONTEXT.md` — trees, TOC snippet, cheat-sheet, forbidden list,
  Definition of Done, reference table.
- `standards/03_INDUSTRY_RESEARCH.md` — brief v2.0 addendum.
- `standards/README.md` — only if the rebuild-process description needs a testing/Retail touch-up.

No sibling addon repositories are modified (remediation is a separate engagement). Existing
`audit/2026-05-03/` stays frozen.

## Out of scope

- Running an audit / producing a new `audit/<date>/` run.
- Editing the sibling addons to comply (that is remediation).
- GitHub Actions / CI (local testing only).
- Re-surveying all 10 industry reference addons (only a light `03_` addendum).
