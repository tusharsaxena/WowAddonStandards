# Ka0s WoW Addon Standard (v1.13.0, 2026-07-15)

**Status:** Source of truth. All audit deviation reports and `NEW_ADDON_CONTEXT.md` template content derive from this standard. When the standard changes, bump the date and version at the top of this file.

**Adherence:** Every Ka0s addon **MUST** be built to this standard and **MUST** reference it: <https://github.com/tusharsaxena/WowAddonStandards> (see `documentation`, `toc-file-§1`).

**Audience:** future Ka0s and any agent (human or LLM) authoring or maintaining a Ka0s addon.

**Substrate:** Ace3. The ecosystem and Ka0s collection are aligned on it; deviations from Ace3 are case-by-case and must be justified.

**License:** MIT. Hostile licenses (`All Rights Reserved`) are forbidden.

---

> **This file is the entry point and index for the standard.** The normative rules are split across
> the section files listed under [Sections](#sections) (in `standards/standards/`). To read — or
> audit against — the **complete** standard, read this index **and then every file linked under
> Sections**; this index alone is not the standard.
>
> **For tools (e.g. the `/wow-addon` plugin):** hard-code only this entry point
> (`standards/STANDARDS.md`) and discover the section files by **following the Sections list** —
> never hard-code an individual section filename. The standard can then be re-organized (files
> renamed, split, added, removed) with **no change to the tool**, as long as this file keeps its
> name and its Sections list stays current.

---

## Reading this document

Each section uses these markers:

- **MUST** — non-negotiable; deviations are bugs.
- **SHOULD** — strongly preferred; deviations require a comment in code explaining why.
- **MAY** — optional; pick when it fits.
- **MUST NOT** / **SHOULD NOT** — forbidden patterns with cited reasons.

**Cross-references use the `filename-§N` scheme.** Every section lives in its own file under
`standards/standards/` and numbers its subsections **locally, from 1**. Reference a whole section by
its **bare filename** (e.g. `architecture`, `audit-review-history`); reference a subsection as
**`<filename>-§<n>`** (e.g. `architecture-§5`, `options-ui-§10`). This is the **only** cross-reference
form — the old global `§N.M` numbering is retired. When you add or reorder a section, update the
[Sections](#sections) list here.

**Reference implementations are described, not named.** This normative standard **MUST NOT** name a specific addon (from the Ka0s collection or the wider ecosystem) as a reference implementation. Instead it *describes* the implementation — what it does and how — in enough detail to be actionable on its own. This keeps the standard self-contained and durable when addons change or are renamed. The **named** research evidence behind these patterns (which real addons exhibit them) lives in the companion research document, `INDUSTRY_RESEARCH.md`, which is a standards-process input rather than part of the normative standard.

Where a Ka0s addon today already implements a rule well, it is called out as *"reference implementation (in the collection)"* with a description of the addon's role, never its name.

---

## Sections

The normative standard, in reading order. **All of these are part of the standard — read every one.**
Reference a whole section by its filename, a subsection as `filename-§N`.

- **[tiered-layout](standards/tiered-layout.md)** — Tier 1 (flat, ≤8 files) vs Tier 2 (modular); folder casing; typed `media/` subfolders.
- **[toc-file](standards/toc-file.md)** — required TOC fields + exact field order; single latest-Retail Interface; `#`-sectioned file listing.
- **[library-stack](standards/library-stack.md)** — mandatory/optional Ace3 libs; vendor-and-commit over externals; no lib forks or suite dependencies.
- **[architecture](standards/architecture.md)** — namespace bootstrap; AceAddon; module pattern; closed message bus; schema-as-single-source.
- **[savedvariables](standards/savedvariables.md)** — AceDB structure; defaults; `schemaVersion` + migration runner.
- **[options-ui](standards/options-ui.md)** — Blizzard Settings + raw AceGUI; eager category / lazy body; landing page, two-column, layout constants, scroll container.
- **[standalone-windows](standards/standalone-windows.md)** — non-secure main windows / data browsers (no combat gate; `UISpecialFrames`; pooled rows).
- **[preview-mode](standards/preview-mode.md)** — placeholder-data preview/test mode for positionable displays.
- **[slash-commands](standards/slash-commands.md)** — AceConsole; schema-driven dispatch + `COMMANDS`; mandatory cyan chat tag; settings read/write output format.
- **[localization](standards/localization.md)** — metatable-fallback `NS.L`; English-string keys; locale-gated files.
- **[events-frames-taint](standards/events-frames-taint.md)** — AceEvent; combat lockdown; taint-safe Blizzard replacement; frame pooling; combat "secret" values.
- **[public-api](standards/public-api.md)** — versioned `NS.API.v1` surface (only if the addon exposes one).
- **[compat](standards/compat.md)** — a single `Compat` module owning every deprecated / cross-patch API call.
- **[debug-logging](standards/debug-logging.md)** — the on-screen debug console (styled like the main window), not the chat frame.
- **[packaging](standards/packaging.md)** — `.pkgmeta`: vendored libs, ignore lists, no `externals:`.
- **[lint](standards/lint.md)** — `.luacheckrc`: config and the zero-error gate.
- **[testing](standards/testing.md)** — headless Lua 5.1 test harness; TDD; the green commit gate.
- **[documentation](standards/documentation.md)** — root README + stub `CLAUDE.md`; the `docs/` trio; the four-place standards reference.
- **[audit-review-history](standards/audit-review-history.md)** — frozen dated `docs/audits/` + `docs/reviews/` bundles.
- **[versioning-git](standards/versioning-git.md)** — semver; trunk-based git workflow; commit only on green.
- **[naming-cheatsheet](standards/naming-cheatsheet.md)** — the naming conventions table.
- **[anti-patterns](standards/anti-patterns.md)** — the forbidden do-not list (#1–#35).
- **[open-evolutions](standards/open-evolutions.md)** — recorded directions for future versions.

---

## Related documents

Discovered by following the links here — not part of the normative standard, but part of the standards process:

- **[EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md)** — one-page TL;DR of the standard.
- **[NEW_ADDON_CONTEXT.md](NEW_ADDON_CONTEXT.md)** — drop-in context pack for scaffolding a new addon (born compliant).
- **[INDUSTRY_RESEARCH.md](INDUSTRY_RESEARCH.md)** — the research foundation the rules are synthesized from (a process input).
- **[ADDONS.md](ADDONS.md)** — the roster of in-scope addons.
- Process playbooks (repo root): **[../AUDIT.md](../AUDIT.md)** (`/wow-addon:standards-audit`) and **[../NEW_ADDON.md](../NEW_ADDON.md)** (`/wow-addon:new-addon`).

---

## Changelog

- **v1.13.0 (2026-07-15):** **testing** gains **testing-§5 — Test-case inventory & coverage badge**. Every addon **MUST** ship a **generated** `docs/test-cases.md` (a full per-suite enumeration of every headless test case + totals, produced by a non-executing `--list` mode of the runner — `lua tests/run.lua --list > docs/test-cases.md`, never hand-authored) as the **authoritative pass count**, and **MUST** surface a **static X/Y `[tests]` pass badge** in the README badge row. Both **MUST** be kept in lockstep with the suite — whenever a case is added/removed/renamed or the count moves (i.e. whenever a failing test is resolved), regenerate the doc and update the badge **in the same change**. **No CI** — this is deliberately local/hand-run (consistent with the existing Ka0s decision that CI/GitHub Actions are out of scope; local testing + lint are in scope). Ripples: **documentation-§1** adds `[tests]` to the canonical badge-row order and names `docs/test-cases.md` a **required** topic-detail doc (documentation-§3). Drawn from a Ka0s Loot History pass that surfaced hand-maintained test counts silently drifting (a docs status line stuck at 152 while the suite reported 166). Existing addons will surface this on their next `standards-audit`.
- **v1.12.0 (2026-07-15):** **debug-logging-§5** gains two house-style MUSTs on the `DebugLog:SetEnabled` seam, drawn from a Ka0s KickCD debug pass. (1) The state-change **chat ack MUST be colour-coded** — `ON` green (`40ff40`), `OFF` red (`ff4040`), e.g. `[XY] debug logging |cff40ff40ON|r` — mirroring the title-bar `Debug: ON/OFF` toggle so the flag reads identically in chat and on the console. (2) On **enable**, the seam **MUST** also emit a one-line **`[Init]` session summary** to the console immediately after the `[Debug] logging enabled` bracket — addon + version, schema/DB version, and active profile (e.g. `[Init] KickCD v1.2.0, schema v1, profile 'Default'`) — emitted **on enable, not login**: the session-only flag is off at login, so a load-time summary would always be gated off and never render, so it rides the visible `SetEnabled` seam. This is the §8 lifecycle boot-summary, now pinned to a concrete tag/format and emission point; **§8**'s Lifecycle bullet is updated to reference the `[Init]`-on-enable emission. Makes a pasted debug log self-identifying (which build, which schema, which profile).
- **v1.11.0 (2026-07-15):** **debug-logging** gains three new MUST subsections, **appended as debug-logging-§8/§9/§10** so the existing enabled-state/copy/fallback sections keep their numbers and every existing `debug-logging-§5` cross-reference stays valid (no renumbering). **§8 Coverage** — every addon **MUST** trace its main functional flows so a log read back reconstructs what happened: lifecycle (load/enable boot summary, schema migration, retention prune), the core capture/compute flow **including the not-recorded decisions** that explain a missing entry, all data mutations, view open/recompute, and every settings change. **§9 Coalescing** — a sink on a repeating path (bag scan, loot-window slots, a table re-render per filter keystroke, a per-frame tick) **MUST NOT** emit one line per item/slot/frame; it **MUST** collapse to **one summary line per pass** carrying the counts and affected detail, with the summary string-building kept **behind the debug gate** (zero-alloc, debug-logging-§4). **§10 Settings changes** — every settings mutation **MUST** be logged **once**, at the schema's single write seam (`[Set] <path> = <value>`); downstream reactors **MUST NOT** re-echo the same change. Drawn from a Ka0s Loot History debug pass: per-slot `LOOT_OPENED` spam collapsed to one summary, a redundant `[Cfg]` echo removed, and lifecycle/view traces (`[Init]`/`[Prune]`/`[Data]`/`[Table]`/`[Insights]`/`[UI]`) added.
- **v1.10.0 (2026-07-14):** **options-ui-§2** — under combat lockdown the options-panel open now **MUST refuse**, not defer. When `InCombatLockdown()` is true the panel-open (the `config` slash verb **and** every programmatic caller, gated inside the open function itself) **MUST** print a single `NS.PREFIX`-tagged **grey notice** — canonical text *"cannot open settings during combat — Blizzard's category-switch is protected"* — and return, and **MUST NOT** call the protected category-switch (`Settings.OpenToCategory`) or silently no-op. It **MUST NOT** defer-and-replay via `PLAYER_REGEN_ENABLED`: a panel that pops itself open the instant combat drops steals focus during post-pull recovery, so the house behaviour is an explicit, greppable refusal and the user re-runs `/<slash> config` when they choose. This is distinct from a deferred **secure frame write**, which legitimately queues on `PLAYER_REGEN_ENABLED` (events-frames-taint-§2). Reference implementation (in the collection): the chat-formatting addon refuses in its `OpenConfig` with exactly this notice. Ripples to any addon that currently defers its config open. (Category *registration* stays eager at load, taint-free — options-ui-§1 unchanged.)
- **v1.9.0 (2026-07-14):** **slash-commands-§3** — every addon now **MUST** register a standalone **`version`** verb that prints `<tag> v<version>` on its own line (read from TOC metadata with the in-code constant as fallback). Promoted from an optional convenience to a required verb so "what version am I running?" is answered identically across the collection and stays greppable without parsing the help header; the version already shown in the help header (slash-commands-§4) is unchanged. `version` added to the §3 `NS.COMMANDS` example. Drawn from ConsumableMaster smoke-test feedback confirming `/cm version` as a load-and-migration sanity check worth standardising. Also **events-frames-taint-§8** — the shared-printer secret-safe guard is promoted from a **SHOULD** ("the guard should live in the shared helper") to a **MUST**: every chat/debug line **MUST** funnel through one shared secret-safe printer (`NS.Print` for chat, the debug sink for the console), and call sites **MUST NOT** call the global `print()`, hand-write the `NS.PREFIX` tag, or pre-concatenate args through `..`/`tostring`/`table.concat` before it — non-compliant even if never handed a secret today. The **debug-logging-§4** "user-facing chat still `print()`s" note is tightened to route through the shared `NS.Print`. Drawn from a Ka0s Loot History pass where 24 raw `print()` sites bypassed any shared printer (and its debug sink fed args straight to `string.format`).
- **v1.8.0 (2026-07-13):** **events-frames-taint-§2** now distinguishes **`InCombatLockdown()` vs `UnitAffectingCombat("player")`** — not interchangeable. `InCombatLockdown()` answers *"are protected actions forbidden?"* and **MUST** gate secure writes (substituting `UnitAffectingCombat("player")` can raise *action blocked* at the combat boundary, where the two diverge); `UnitAffectingCombat(unit)` reads a unit's actual combat flag and **SHOULD** drive combat-reactive display/logic (and is the only option for non-player units). Player combat *transitions* **SHOULD** ride `PLAYER_REGEN_DISABLED`/`_ENABLED` rather than polling. Drawn from a live AbsorbTracker bug where the bar failed to show in combat because visibility was gated on `InCombatLockdown()` instead of `UnitAffectingCombat("player")`.
- **v1.7.0 (2026-07-13):** New **MUST rule in architecture-§2 — a custom chat printer MUST survive the AceConsole embed**, with anti-pattern #36 and a slash-commands-§4 guard pointing to it. `AceAddon:NewAddon(NS, …, "AceConsole-3.0")` embeds AceConsole's `:Print` mixin onto `NS`, silently overwriting a same-named custom `NS.Print` defined earlier; every `print(msg)` then renders as `|cff33ff99<msg>|r:` — green, trailing colon, no cyan tag — breaking the mandated prefix (slash-commands-§4) with no error, masked by `/reload`, and invisible to a headless mock that doesn't reproduce the embed. The rule mandates one of two fixes (name the printer `NS.Util.print`, or reclaim `NS.Print = NS.Util.print` right after `NewAddon`) and requires the AceAddon test mock to stamp the colliding `:Print` (same mock-fidelity rule as #33). A **naming-cheatsheet** row codifies `NS.Util.print` as the printer convention. Drawn from a live AbsorbTracker bug where `/at` output lost its `[AT]` tag and gained a trailing colon.
- **v1.6.0 (2026-07-13):** **slash-commands-§5** — the settings read/write output (`list`/`get`/`set`) now has a **mandated colour scheme**, promoted from uncoloured plain text. Every Ka0s addon **MUST** print the `Available settings` header in green (`33ff99`), `[page]` group headers in azure (`3399ff`), setting keys/paths in gold (`ffff00`), and values in white (`ffffff`); the ` = ` separator stays default and **no line carries a trailing colon**. The coloured `key = value` line **MUST** come from one shared helper reused by `list` rows and the `get`/`set` echo (same house-style rationale as the mandated cyan chat tag, slash-commands-§4). The `list` header example loses its trailing colon to match. **slash-commands-§4** — the no-trailing-colon rule is **generalized to every chat line the addon prints** (help header, command rows, profile sub-headers, all schema output): the help-index header format and its Lua example drop their trailing `:` accordingly. Drawn from AbsorbTracker's `/at list` colourisation and a follow-up pass removing the remaining literal trailing colons.
- **v1.5.0 (2026-07-13):** Standard **split into per-section files** for navigability. `01_STANDARD.md` renamed to **`STANDARDS.md`** and reduced to this index/entry point (front matter, the reading guide, the Sections map, and this changelog); every numbered section moved **verbatim — no rule text changed** — into its own file under **`standards/standards/`** with an unnumbered topic name (e.g. `tiered-layout.md`, `architecture.md`, `anti-patterns.md`). "Reading this document" stays inline here. Section numbers are now **local to each file** and cross-references use the **`filename-§N`** scheme (e.g. `architecture-§5`; a whole section is just its filename, e.g. `audit-review-history`) — the old global `§N.M` numbering is retired. Sibling docs de-numbered too: `00_EXECUTIVE_SUMMARY.md`→`EXECUTIVE_SUMMARY.md`, `02_NEW_ADDON_CONTEXT.md`→`NEW_ADDON_CONTEXT.md`, `03_INDUSTRY_RESEARCH.md`→`INDUSTRY_RESEARCH.md`. Consuming tools (the `/wow-addon` plugin) now hard-code only this entry point and discover section files by following the Sections list.
- **v1.4.0 (2026-07-13):** New **events-frames-taint-§8 — Combat-protected "secret" values**. In combat, retail returns absorb/health/threat totals as opaque *secret* values that survive `tostring()` **and the `..` operator** but raise in `table.concat`/`string.format`; an unguarded secret in a chat/debug line — especially one on a repeating ticker — crashes and can freeze the feature until `/reload`. The shared chat/debug seam (slash-commands-§4, debug-logging-§4) now MUST route every arg through a **secret-safe stringifier** whose detector probes `table.concat`, **not** `..` (a `..` probe wrongly passes secrets through). New anti-pattern #35. Drawn from a live AbsorbTracker crash where `/at debug on` in combat killed the repaint ticker.
- **v1.3.0 (2026-07-13):** Three chat/console-output rules tightened or added, from AbsorbTracker smoke-test feedback. **slash-commands-§4** — the bracketed chat tag's colour is now **mandated cyan** (`|cff00ffff[XY]|r`), promoted from example to requirement (house style; every Ka0s addon prints the same colour). **slash-commands-§5 (new)** — canonical **settings read/write output format** for `list`/`get`/`set`. **debug-logging-§5** — the `DebugLog:SetEnabled` seam now **MUST also append a `[Debug] logging enabled|disabled` console line at both transitions** (was chat-ack only), so the console self-documents when capture started and stopped. options-ui-§2 (combat panel-open) was reviewed and left unchanged — defer-and-replay remains the norm.
- **v1.2.0 (2026-07-13):** Audit and code-review run history moved under `docs/`: audit runs now live in **`docs/audits/<YYYY-MM-DD>/`** (was `audit/<YYYY-MM-DD>/`) and code-review runs in **`docs/reviews/<YYYY-MM-DD>/`** (was `reviews/<YYYY-MM-DD>/`) — `audit-review-history` retitled and rewritten to name both locations. Rippled the path through the tiered-layout trees (tiered-layout-§1/tiered-layout-§2), the casing list (tiered-layout-§3), the `.pkgmeta`/`.luacheckrc` templates (`packaging`/`lint`), and every cross-reference in the playbooks and repo docs.
- **v1.1.0 (2026-07-13):** Documentation section (`documentation`) made explicit and given a proper heading. Named the canonical `docs/` trio — `ARCHITECTURE.md`, `agent-context.md` (the full agent-context pack), `smoke-tests.md` (documentation-§3). Specified the exact required shape of the root `CLAUDE.md` stub, including a mandatory `## Standards compliance (read first)` section (documentation-§2). Added **documentation-§6 — Standards reference (every addon)**: the reference to this repo MUST live in four places — the TOC `X-Standard` field, the README standard badge, the `CLAUDE.md` "Standards compliance (read first)" section, and the `docs/agent-context.md` "Hard rules" — so every agent working in an addon carries it in memory and context. New anti-pattern #34.
- **v1.0.0 (2026-07-12):** Initial release of the Ka0s WoW Addon Standard.

---

**End of index. The normative rules live in the section files linked above. Authoritative as of 2026-07-15; bump on amendment.**
