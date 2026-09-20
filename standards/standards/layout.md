> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Layout

Every Ka0s addon uses one **modular** folder layout — `core/`, `defaults/`, `settings/`, `locales/`, `modules/` — regardless of size. There is no flat/small-addon variant; a three-file utility and a multi-feature suite share the same skeleton so every repo reads identically and any file has one obvious home.

### 1. Modular layout

```
<AddonName>/
  <AddonName>.toc          -- single file, single Interface line (latest Retail), lists all .lua in dependency order
  core/
    Compat.lua             -- deprecated-API shims
    Constants.lua          -- numeric constants, enum-like tables
    Namespace.lua          -- bootstrap: local addonName, NS = ...; sets up shared upvalues
    State.lua              -- mutable runtime state, message bus
    Util.lua               -- pure helpers
    <Module>Setup.lua      -- one seam file per wired LibKa0s module (library-stack-§7);
                           -- its position is often load-bearing and is declared in the TOC (toc-file-§5)
    <AddonName>.lua        -- AceAddon registration; promotes NS to AceAddon
    Database.lua           -- AceDB profile/global setup, migration runner
  defaults/
    Profile.lua            -- C = profile defaults table
    Global.lua             -- G = global defaults table (rare; only when needed)
    Spells.lua / Data*.lua -- Retail data tables (no per-flavor suffix; Retail only)
  settings/
    Schema.lua             -- one row per setting: {path, default, type, label, widget, validate, onChange}
    Panel.lua              -- Blizzard Settings.RegisterCanvasLayoutCategory + raw AceGUI render
    Slash.lua              -- AceConsole binding; reads Schema for get/set/list/reset
  locales/
    enUS.lua               -- canonical
    deDE.lua, frFR.lua, ... -- gated with `if GetLocale() ~= "deDE" then return end`
    PostLoad.lua           -- derived-key aliases (L[2806] = L[2706])
  modules/
    <Feature>.lua          -- one file per feature module; max ~1500 LOC each
    ...
  media/                   -- typed subfolders only (layout-§3)
  libs/                    -- vendored Ace3 + other libs, committed to git (library-stack-§3)
  tests/                   -- headless Lua 5.1 harness (testing)
  tools/                   -- dev-only generators; .pkgmeta-ignored; never loaded by the client
                           -- NOT a source folder; absent from the TOC (layout-§1)
  docs/                    -- ARCHITECTURE.md, testing.md, smoke-tests.md, planning/reference (documentation)
                           -- NO agent-context.md: the scaffolding pack is fetched at runtime (documentation-§3)
    audits/<YYYY-MM-DD>/   -- audit-run history (retained; audit-review-history)
    reviews/<YYYY-MM-DD>/  -- code-review history (retained; audit-review-history)
  README.md                -- full, user-facing (stays at root)
  CLAUDE.md                -- STUB: short pointer into docs/ (documentation)
  LICENSE
  .luacheckrc
  .pkgmeta
  .gitattributes           -- MANDATORY: the CRLF pin + *.sh carve-out + binary markings (line-endings)
```

- **MUST** use this folder layout — source lives under `core/`, `defaults/`, `settings/`, `locales/`, `modules/`; never loose at the root. A small addon simply has thin folders (a single `modules/` file, a one-row `settings/Schema.lua`), not a different structure.
- **MUST** load in this **folder** order: `libs/*` → `locales/*` → `core/*` → `defaults/*` → `modules/*` → `settings/*`. Libraries first because everything resolves against them; settings **last**, because a settings panel depends on every module it configures already being initialized. This is the same order the TOC's `#` section headers express (toc-file-§5) — one order stated in two places, and if the two ever disagree that is a defect in this document rather than a choice an addon gets to make.
- **MUST** load `core/*` in **dependency-correct order**, and **MUST** declare each load-bearing position at its own TOC line (toc-file-§5). There is no fixed `core/` prefix. The seam files `library-stack-§7` introduced — one `*Setup.lua` per wired module — resolve library members **at file scope**, so which file must precede which is a property of what the addon actually wires, and no list written here can anticipate it. `Compat.lua` → `Constants.lua` → `Namespace.lua` is the **illustrative** shape for an addon with no seam files and nothing resolving at load; an addon whose `Namespace.lua` publishes the `NS` table the other `core/` files attach to, or whose `Constants.lua` resolves a font from a media seam at file load, orders around that constraint and says so in the TOC comment. A dependency-correct order with its load-bearing positions declared is compliant; an order that matches the illustration but breaks a load-time resolution is not.
- **MUST** cap any single `.lua` file at 1500 LOC. Files in the 1000–1500 band are on notice; a >1500 file is a bug — peel it. **What the cap binds, and the two carve-outs, are stated below the list**; do not infer its scope from the five source folders named in the first bullet.
- **MAY** peel an oversized file into 2-3 sibling files in the same folder (e.g. `settings/Schema.lua` → `settings/Schema_Core.lua`, `settings/Schema_Display.lua`).

**What the cap binds (MUST).** Every **authored** `.lua` file the repository tracks, wherever in the tree it sits — `tests/` included, and a Ka0s-owned library repo's own module folder included (library-stack-§7). The cap is not a statement about what the client loads. It is a statement about how much a reader has to hold in their head to change one file safely, and a 2700-line test file costs that exactly as much as a 2700-line module — arguably more, because a suite is read under failure, by someone who is already looking for something else. The skeleton above lists `tests/` on its own line for this reason: it is inside the picture this section draws. The five folders named in the layout **MUST** are where *source* lives; they are not the denominator of the cap, and reading them as one is what left half a collection's largest files unclassified.

Two carve-outs, and no others:

- **Vendored code is not authored here.** `libs/` and `tests/_kit/` arrive by whole-folder copy from upstream (library-stack-§3, testing-§1) and are audited in the repo that writes them. Neither the cap nor the 1000–1500 band applies to a file this repo **MUST NOT** edit.
- **Generated non-shipping data is capped at its generator, not at its output.** A file is exempt when **all three** hold: it is **generated rather than authored** — a machine wrote it and the next regeneration overwrites any hand edit, whether the producer is a script the repository authors and commits — which lives under `tools/`, *Where an authored generator lives* below, while the **output** stays wherever its consumer needs it, because only the program moves — or an extraction from the client, and a comment at the top of the file says so — nothing loads it (absent from the TOC and from every test load list — a fixture a test *reads as data* still qualifies), and it is `.pkgmeta`-ignored so no player downloads it (in a repo that has no `.pkgmeta` — a Ka0s-owned library repo, library-stack-§7 — read that third condition as *excluded from the vendored payload*). Any generator committed here is itself authored, and is capped like any other file. A file failing any one of the three is an ordinary source file with an unusual origin, and the cap binds it. Peeling a generated dump is work the next regeneration throws away, which is the whole reason this carve-out exists — and the reason it stops where it does: a chunk a generator emits **for something to load** fails the second condition, so both the cap and the band bind it exactly as they bind hand-written source.

**A file over the cap has three terminal states, not one.** Peeled (the **MAY** above); or an open issue in the addon's issue store (audit-review-history) naming the seam a peel would follow; or a ratified deviation row under `## Documented deviations` (documentation-§3) carrying a re-check trigger. All three are compliant, and an audit **MUST NOT** re-file `layout-§1` against a file covered by the second or the third. What is **not** a terminal state is a file over the cap that nothing anywhere remarks on — the count sitting in a bundle manifest that no document reads. An audit files against that silence rather than against the line count.

**Why the scope is written down rather than left to reading.** The section was silent and four repositories answered it four different ways in the same audit cycle. MultiMeters filed a `layout-§1` **MUST** against seven *source* files over the cap (`docs/audits/2026-09-07/02_DEVIATIONS.md:24`) and against none of its seven test files over it, in the same bundle — `tests/test_window.lua` is 2737 lines and went unremarked while `modules/Row.lua` at 1702 did not. ConsumableMaster filed the mirror image, one finding against a test file alone (`docs/audits/2026-09-07/02_DEVIATIONS.md:43`, `tests/test_macrobar.lua` at 1894). LibKa0s graded its two breaches **Low** and left them there because nothing said the cap reached a library repo at all (`docs/audits/2026-09-07/02_DEVIATIONS.md:29`). And PrettyChat registered a deviation — the row is live today at `docs/ARCHITECTURE.md:269`, filed against `layout-§2`, and its **Why** cell reads "The modular layout has no home for bulk generated reference data" — for `GlobalStrings/GlobalStrings.lua`, a 23,842-line dump that ships to nobody, loads nowhere and is regenerated by a script beside it. That repo's own gate records what the row was asking for before the cap half of it was retired: `tests/test_layout_cap.lua:11-12` says the register row "asked in as many words for 'a `layout` revision that sanctions a generated-data folder'". Each of those four readings is defensible against the text as it stood, which is the tell that the defect was here and not in any of them.

**Where an authored generator lives (MUST).** `tools/`. A generator **this repository authors** and commits — the script that writes a generated data file, the pipeline that derives a shipped list from the client's own data — **MUST** sit under `tools/`, **MUST NOT** be loaded by the client or listed in the TOC, and **MUST** be `.pkgmeta`-ignored (packaging); in a repo that has no `.pkgmeta` — a Ka0s-owned library repo, library-stack-§7 — read that last condition exactly as the generated-data carve-out above says to read its own, as *excluded from the vendored payload*, because a rule that names a file the repo is forbidden to have is a rule nothing can satisfy. **Authored** is the load-bearing word here, and it is deliberately the same one *What the cap binds* uses above — "every **authored** `.lua` file the repository tracks" — so the first carve-out above, *Vendored code is not authored here*, fixes the scope of this **MUST** too and no special case has to be written: `libs/` and `tests/_kit/` arrive by whole-folder copy from upstream (library-stack-§3, testing-§1), a script inside either is authored in the repo that writes it, and it is audited there rather than here. The instance that would otherwise read as a collection-wide breach is `tests/_kit/run-automated-tests.sh`, which sits outside `tools/` in every repo that vendors the kit at once; it is out of scope twice over, being a file this repo **MUST NOT** edit and a test *runner* rather than a generator — it writes no tracked file the repo would otherwise have authored. Moving it would break the byte-identity the vendored-payload gate asserts (testing-§11), which is the plainest evidence that this paragraph never reached it. What moves is the **program**, and only the program: a generated file stays wherever the thing that reads it needs it, and the carve-out above keeps governing the output on its own three conditions. `tools/` is **not** a sixth source folder. The first bullet's "source lives under `core/`, `defaults/`, `settings/`, `locales/`, `modules/`; never loose at the root" is unchanged and binds exactly what it bound before, because nothing under `tools/` is source: nothing here runs in a play session, and an addon that moves a module into `tools/` to get out from under a folder rule has broken the first bullet rather than satisfied this one. The LOC cap binds an authored generator here like anywhere else — the carve-out above already says "any generator committed here is itself authored, and is capped like any other file", and this paragraph only settles where *here* is.

**A non-Lua generator sits outside the green gate — plan around it, do not read it as an exemption.** The commit gate is the linter plus the headless harness (testing-§4), and neither reads a Python or a shell file. A generator written in anything but Lua is therefore unlinted and untested by everything the collection runs, and a break in it surfaces whenever somebody next runs it — a patch later, or never. Three habits **SHOULD** follow, and they are what buys the distance from the gate rather than new obligations this section invents: the generator fails loudly and exits non-zero rather than emitting a thin or empty result, because a silent under-run produces exactly the plausible-looking output a reviewer accepts; its output is reviewed as a diff before anything derived from it is committed, which is easiest when the tool writes beside a source file rather than over it; and `DEPENDENCIES.md` names the interpreter it needs — which documentation-§7 already **MUST**s under its *Release / assets* group, "anything needed only to package or to regenerate committed assets: Python and its packages", so this is an instance of a standing rule and not a second one. These are stated as a SHOULD deliberately. They began as Aura Master's own local design decisions for one Python pipeline, and promoting three local decisions to collection-wide **MUST**s on the strength of a single instance is how a standard acquires rules nothing in the collection was consulted about — the same over-reach the cap-scope revision above was careful not to commit. A generator written **in Lua** is an ordinary authored Lua file and none of this applies — the linter reads it like any other file, and the harness can load it if it earns a case.

**Why the home is named here rather than left to each repo, and what it costs Pretty Chat.** The carve-out above has contemplated a generator the repo authors and commits since it was written, and never said where one goes. Aura Master hit that silence directly: its spell-research process (`tusharsaxena/AuraMaster#11`) derives the Hard CC and Soft CC spell lists from the client's own DB2 data every patch, which is a Python 3 pipeline the repo has to commit if the derivation is to be repeatable at all — and the standard offered it no home. The five source folders exclude it by their own **MUST**, "never loose at the root" excludes the root, and `docs/` is where the frozen run bundle belongs, not where the program that produced the bundle belongs. Three repos had already answered the silence for themselves, in the two different ways a silence gets answered. Panel Master put its artwork importer under `tools/` and ignored it at `.pkgmeta:18` ("the artwork importer — build-time only, and not even Lua"), which is exactly what this paragraph now requires of everyone; Lib Ka0s did the same at `tools/artwork/` and `tools/gen-api-members.lua`, and has no `.pkgmeta` to ignore them in, which is why the packaging condition above carries the library carve-out. Pretty Chat answered it the other way and is **newly non-compliant**: its splitter sits at `GlobalStrings/split_globalstrings.py`, beside the twenty-six chunks it writes, documented at `DEPENDENCIES.md:141-150`. It already satisfies both other conditions — the whole `GlobalStrings` folder is `.pkgmeta`-ignored and no TOC line loads any of it — so what it owes is the move, the program to `tools/split_globalstrings.py`, the generated chunks staying where `tests/test_defaults.lua` reads them. That migration is named in this version's changelog rather than waved at, and it is the program's move alone — the `layout-§2` register row at that repo's `docs/ARCHITECTURE.md:269` is about the **folder's** name and place, and its re-check trigger ("the folder moving under `tests/` now that it is a fixture rather than shipped data") is a separate decision this section does not make for it. This is the same class of defect as the cap-scope silence above — a question the section leaves open, that every addon reaching it has to answer privately — and three repositories answering it three different ways is what that looks like a year on. It is answered here so the fourth addon does not have to invent an answer and the auditor does not have to adjudicate one.

**What this actually breaks, swept rather than assumed.** `git ls-files '*.py' '*.sh'` across the fifteen Ka0s repositories checked out side by side returns, outside `tools/`, exactly one authored generator: Pretty Chat's splitter. Everything else it returns is out of scope for a reason this paragraph can name. `tests/_kit/run-automated-tests.sh` is vendored into twelve of the fifteen and is excluded by *Vendored code is not authored here*, as the **MUST** above spells out. Outfitter's `tests/run-all.sh` and Lib Ka0s's `testkit/run-automated-tests.sh` — the upstream original of that vendored copy — are authored where they sit, but both are test **runners**, and a runner is not a generator. Each does write a tracked bundle under `docs/automated-tests/` — that is the point of the automated-tests record — but what it writes is a *record of a run*, not derived content the repo ships, loads or reads back as data: nothing resolves against it, and re-running produces a new dated bundle beside the old rather than a new version of the same file. The rule binds the program that produces committed **content**, and it is the derived content that has to sit where the reader can find its producer. So neither runner moves; each stays the entry point of the suite it runs. The `wow-addon` plugin repo's `scripts/` holds five authored files, and they are hooks and a bounded-run wrapper the plugin's own manifest invokes by path (`hooks/hooks.json:9` and `:20`), not generators — and that repo is a documentation-and-tooling repo, which reads `layout` through documentation-§8's applicability list rather than as an addon. One repository, one file, one move: that is the whole cost, and it is written down here so nobody has to take the count on trust.

### 2. Casing

- Addon root folder: **PascalCase** matching the `## Title:` in TOC (minus the `Ka0s ` prefix).
- Subfolders: **lowercase** (`core/`, `modules/`, `libs/`, `media/`, `defaults/`, `settings/`, `locales/`, `docs/`, `docs/audits/`, `docs/reviews/`, `tests/`, `tools/`). **MUST** use `libs/` lowercase (not `Libs/`).
- Lua files: **PascalCase.lua** (`Database.lua`, `IconGrid.lua`).
- Non-source folders that ship: lowercase.

### 3. Media subfolders

Shipped media **MUST** live in **typed subfolders** under `media/` — nothing loose directly in `media/`:

- `media/logos/` — the addon logo art (the runtime `.tga`/`.blp` plus the source `.jpg`/`.png`); its required members and their format are **layout-§4**.
- `media/screenshots/` — README/store screenshots and any demo GIFs.
- `media/fonts/`, `media/sounds/`, `media/textures/` — as needed for shipped assets of that kind, **and only for assets the shared media library does not already carry**.

**`media/` is for what only THIS addon has.** The icon set, the monospace face and the bar textures every Ka0s addon draws with ship inside the vendored payload at `libs/LibKa0s/media/` (library-stack-§8) and arrive with `Core.lua` in the same copy — so an addon **MUST NOT** ship its own copy of one, and **MUST NOT** copy one out of `libs/` into `media/` to shorten a path. What legitimately remains here is the addon's own identity and its own subject matter: the logo, the screenshots, and any asset that would be meaningless in another addon. An addon whose `media/fonts/` or `media/textures/` holds a second copy of a library asset is anti-pattern #63, and the tell is a `media/` folder that two Ka0s addons could swap without either noticing.

Reference implementation (in the collection): the standalone loot-history browser ships its logo under `media/logos/`. **MUST** keep the runtime texture in a WoW-loadable format (`.tga`/`.blp`) and the editable source (`.jpg`/`.png`) beside it (options-ui-§5).

### 4. The addon logo

`media/logos/` carries the addon's identity, and **two** of its files are required. They are different files doing different jobs, and neither substitutes for the other:

| File | Size | Used by |
|---|---|---|
| `<addon>.logo.128.tga` | 128×128 | `## IconTexture` (toc-file-§1), the minimap button's icon, the broker object's icon (launcher-§4) |
| `<addon>.logo.tga` | drawn at 300×300 | the settings panel's landing page (options-ui-§5) |

Beside them sits the **editable source** — the 2000×2000 `.png` the collection's logo art is authored at — which ships but is never loaded by the client (WoW cannot load `.png`/`.jpg` at runtime).

- **`<addon>` is the addon's folder name, lowercased** in both names (`partyframeenhanced.logo.tga`, `partyframeenhanced.logo.128.tga`), so both paths are derivable from the folder without opening it. The landing-page file is the **unsuffixed** name and every addon in the collection already ships it under exactly that name — it is named here so an audit has a path to check for **both** files rather than only the new one. Nothing about the landing-page file changes: its size, its format and its compression are whatever it already is (options-ui-§5), and it is **not** graded against the 128 file's format rules below.
- **The 128 file MUST be uncompressed, 32-bit — TGA image type 2, 32 bpp.** This is not a style preference. One file in the collection is **proven** to render as an `IconTexture` in-game, and it is type 2 / 32 bpp; the **RLE-compressed (type 10)** logos the collection also ships are unproven in that role, and an icon that silently fails to load draws nothing and raises nothing, so no gate would report it. **128×128 is also power-of-two**, which several existing logos (300×300) are not. Cost is roughly **64 KB** per addon — the whole reason an uncompressed file is affordable here at all.
- **The recipe is fixed, so the file is reproducible** rather than a one-off export somebody has to remember the settings for. From the `.png` source already in `media/logos/`:

```python
from PIL import Image
Image.open(src).convert("RGBA").resize((128, 128), Image.LANCZOS).save(out, format="TGA")
```

  `convert("RGBA")` is what makes it 32 bpp; Pillow's TGA writer emits type 2 (uncompressed) for this call. Regenerate rather than hand-edit: an edited TGA is a file nobody can reproduce.
- **MUST NOT** substitute a Blizzard icon, a numeric file id, or another addon's art for the 128 file (**anti-pattern #82**). The point of the file is that the addon looks like itself in the AddOns list, on the minimap and in a broker display at once.
