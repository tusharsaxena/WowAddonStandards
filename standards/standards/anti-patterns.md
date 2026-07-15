> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Anti-patterns (forbidden)

For quick reference, the rules above as a do-not list:

1. `_G[addonName] = {}` (global namespace) — use private `NS`.
2. AceLocale strict mode — use metatable fallback.
3. Hand-rolled options framework — use Settings + AceGUI.
4. AceConfig for non-Profiles content — use raw AceGUI.
5. `SLASH_*` direct registration — use AceConsole.
6. `if cmd == "x" then elseif ...` slash dispatcher — use schema + COMMANDS table.
7. `.pkgmeta` `externals:` for libraries — vendor and commit all libs instead (library-stack-§3).
8. Forking Ace libs — use `RegisterWidgetType` extension instead.
9. `if WOW_PROJECT_ID == ...` game-flavor branching — Retail only; route any Retail-patch check through Compat (compat).
10. Direct calls to deprecated APIs — route through Compat.
11. `:Hide()` on Blizzard frames you replace — reparent to hidden parent.
12. Replacing `AddMessage` — override globals or use AddMessageEventFilter.
13. Hard `## Dependencies:` (use OptionalDeps + soft fallback).
14. `## X-License: All Rights Reserved` — must be MIT.
15. Multi-flavor / Classic support (comma Interface lists, per-flavor TOCs, `_Classic` data splits, `enable-toc-creation` fan-out) — Retail only, single Interface line (toc-file-§3).
16. Files >1500 LOC — peel.
17. Multiple senders for the same bus message.
18. Debug output to the chat frame when the addon has a main window — use the on-screen debug console (debug-logging).
19. Cross-module direct table access — use the bus.
20. User-supplied Lua execution — banned at the standard level (no Ka0s addon needs it).
21. Creating a feature/topic branch without an explicit request — work trunk-based (versioning-git).
22. Deferring settings-**category** registration until first `/config`/panel-open — register the category eagerly at load; only the body is lazy (options-ui-§1, options-ui-§9).
23. Committing with red `lua tests/run.lua` or non-clean `luacheck .` — the commit gate is green tests + clean lint (testing).
24. No `tests/` harness, or a logic change with no covering test — TDD is mandatory (testing).
25. Loose files directly in `media/` — use typed subfolders (layout-§3).
26. Full agent brief in the root `CLAUDE.md` — root `CLAUDE.md` is a stub; the brief lives in `docs/` (documentation).
27. A checked-in `TODO.md` in a **released** addon — track the backlog in GitHub issues; a `TODO.md` is allowed only in an unreleased, in-development addon during its development phase (documentation-§4).
28. Non-canonical `README.md` section order, or a TOC that departs from the required field order / file-listing structure — follow documentation-§1 and toc-file-§1/toc-file-§5.
29. Hard-depending on an addon suite or standalone addon (ElvUI/EllesmereUI/DBM/WeakAuras/…), or reading its media/API/frames/SavedVariables — addons are fully self-contained; suite integration is optional, presence-guarded, and degrades gracefully (library-stack-§6).
30. Hiding the options-panel scrollbar on short pages (bar shown only when content overflows) — the body `ScrollFrame` keeps its bar always shown and inert so body width is identical across subcategories (options-ui-§10).
31. A 50/50 paired action button left at `SetRelativeWidth(0.5)` — cell-filling buttons inset to `BUTTON_PAIR_REL` (0.492) so the right button clears the `ScrollFrame` clip (options-ui-§6, options-ui-§8, options-ui-§10).
32. Two receivers of the same bus message registering on the **shared** bus object (`NS.bus`/`NS.addon` as `self`) — CallbackHandler keys callbacks by `(message, target)`, so the later registrant silently clobbers the earlier (last-registrant-wins, no error, masked by `/reload`); each receiver MUST own a distinct AceEvent target — an AceAddon module `self`, or a private `NS.NewBusTarget()` embed (architecture-§4).
33. A bus test mock with no-op `RegisterMessage`/`SendMessage` — it can't catch same-target receiver clobbering; the mock MUST key by target and fan `SendMessage` out to all targets (architecture-§4, testing).
34. Missing the standards reference in **project memory and context** — a `CLAUDE.md` with no `## Standards compliance (read first)` section, or a `docs/agent-context.md` whose `## Hard rules` don't open with the conform-to-the-standard rule pointing back to that section. The reference MUST live in all four places: TOC `X-Standard`, README badge, `CLAUDE.md`, and `docs/agent-context.md` (documentation-§6).
35. Feeding a combat-protected "secret" value (unit absorb/health totals, threat, …) into `table.concat`/`string.format`/`print`, or detecting one with a `..`-based probe — secrets **propagate silently through `..`** and only raise in `table.concat`, so a `..` probe passes them through; route every chat/debug arg through the shared secret-safe stringifier (events-frames-taint-§8).
36. Embedding AceConsole-3.0 into the **same table** that exposes a same-named custom printer — `AceAddon:NewAddon(NS, …, "AceConsole-3.0")` stamps AceConsole's `:Print` mixin directly onto `NS`, **silently overwriting** a custom `NS.Print` defined earlier (e.g. in an already-loaded `Util`). Every `print(msg)` call site then hits AceConsole's `Print`, which — called as `NS.Print(msg)` with the message as `self` — renders `|cff33ff99<msg>|r:` (green text, **trailing colon, NO cyan tag**), violating the mandated prefix (slash-commands-§4) with no error, masked by `/reload`, and invisible to any headless test whose AceAddon mock doesn't reproduce the embed. The **MUST** rule and its two fixes (name the printer `NS.Util.print`, or reclaim `NS.Print = NS.Util.print` right after `NewAddon`) — plus the mock-fidelity requirement (same as #33) — are in **architecture-§2**.
