> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Debug / logging — on-screen debug console

Every addon **MUST** ship a debug seam, and debug output **MUST** route to a **dedicated on-screen debug console** — **not** the default chat frame. A chat frame is shared with every other addon, scrolls away under combat spam, and cannot be copied clean; a bug report that arrives as *"it did something weird"* is the cost of not having a console.

The console itself is **not addon code**. It is a **Ka0s-owned shared library**, `LibKa0s-DebugLog-1.0`, that every addon in the collection vendors and instantiates. Seven hand-written consoles is what this section used to describe, and seven copies of a window, two formatters, a ring buffer and a scroll sync drifted in seven directions — the color codes agreed, the scrollbar behavior did not. What each addon still owns is the part only it can know: where its debug flag lives, what its session summary says, and which of its flows are worth tracing.

**Adoption strength.** **MUST** for the **wiring** — vendor the lib, create one instance at load from a descriptor, stash it on the namespace, bind the gated sink, degrade to a stub. **SHOULD** for **coverage** — §8–§10 govern *what* gets logged, and which flows matter is genuinely addon-specific. MUST on the wiring is what makes *"turn on `/<slash> debug on`, reproduce it, hit Copy, paste it to me"* true of **any** Ka0s addon, in the same format, with the same line numbers on the same scrollbar.

### 1. The console library

- **MUST** vendor **`LibKa0s-DebugLog-1.0`** (the `DebugLog` module of `LibKa0s`) under `libs/LibKa0s/`, listed directly in the TOC's `# Libraries` section after Ace3 (toc-file-§4, library-stack-§7). Vendor the **whole `LibKa0s/` folder** and its `LibKa0s.xml`, never a hand-picked subset of files — `DebugLog.lua` requires `LibKa0s-Core-1.0` and will not register without it (anti-patterns #48).
- **MUST NOT** hand-roll a console — a window, a buffer, formatters, a scroll sync, a copy box — when the module provides one. That is forking the collection's toolkit (anti-patterns #47), and the fork is silent: both copies work, and only the eighth addon's log reads differently from the other seven.
- **MUST** create **one instance per addon at load**, from a descriptor, and stash it on the namespace — resolved **silently**, then guarded: `local lib = LibStub and LibStub("LibKa0s-DebugLog-1.0", true)`, and `NS.DebugLog = lib:New(descriptor)` only `if lib`. The silent flag suppresses LibStub's raise but returns `nil`, so chaining `:New` straight off it errors on exactly the path §7 exists to make survivable. In its own core file (`core/DebugLogSetup.lua`), positioned in the TOC **after** the constants file that carries the mono font path, the state file that carries the flag, and the core printer, and **before** every module that calls the sink.
- **MUST** bind the gated sink **bare** off the instance — `NS.Debug = NS.DebugLog.Debug` — so call sites stay `NS.Debug(tag, fmt, ...)` (§4). It is a plain function, not a method, precisely so it can be published under the addon's own name without a wrapper.
- **MUST NOT** hold a lib-level console. One instance per host: a shared singleton would give two addons one window, one buffer, and — worse — one `UISpecialFrames` registration, so ESC would close the wrong addon's log.
- **MUST** degrade rather than error when the lib is absent. `DebugLog.lua` returns **before** `LibStub:NewLibrary` when `LibKa0s-Core-1.0` is missing or older than its floor, so the major is simply **never registered** and the `LibStub(..., true)` lookup answers `nil` — absent, not half-wired. The setup file then falls back to a stub (§7).
- The descriptor's five **required** fields are `name` (seeds the frame globals and the `UISpecialFrames` entries), `title`, `font` (§2), and `isEnabled` / `setEnabled` (§5). The useful optional ones are `fontSize` (default `10`), `print`, `safeToString`, `initSummary`, `onVisibilityChanged`, `slash` (composes the console checkbox's tooltip), `L` (locale override) and `skin`.
- **MUST** pass `print` and `safeToString` as **thin call-time forwarders** — `function(line) NS.Print(line) end`, not `NS.Print` — when the host's printer is established after this file loads. Capturing the reference freezes it to whatever happened to exist at load; an addon that reclaims its printer from AceConsole's embed later would then acknowledge through the wrong function forever (anti-patterns #36).

**What the library guarantees** (so the standard describes the behavior, not the build): a `BackdropTemplate` window named `<name>DebugWindow`, **700 × 344**, on **`DIALOG`** strata so it sits above the addon's main window, draggable, clamped to screen, registered in `UISpecialFrames`, skinned from `LibKa0s-Core-1.0`'s shared `SKIN` — the flat 1px black edge with its gray inner highlight, the gold title and the gray divider specified normatively in standalone-windows, "The Ka0s window edge" — with **Core's** close glyph — which the addon **MUST NOT** replace with its main window's, even where the two differ by design (standalone-windows); a `ScrollingMessageFrame` capped at `lib.MAX_BUFFER` (**1500**) lines — raised from a third of that because the perf capture workflow pastes out of this buffer, and a long run's `perf dump` overflowed the old cap and lost its head with nothing saying so — with the always-shown scrollbar and line counter of §11; the two formatters of §3; the Clear/Copy pair of §6; the title-bar state toggle and single `SetEnabled` seam of §5; and `ConsoleCheckbox()`, a plain `{ label, tooltip, get, set }` table a settings page renders itself (options-ui). None of that is an addon's code to write, and an audit **MUST NOT** ask for it in the addon's own source.

### 2. Monospace font (from the shared media library)

The **font path is the host's to hand over**, because only the host knows which addon folder the library was vendored into; the library takes the path and uses it for the log, the line counter, and the copy box.

**The face itself is no longer the addon's to ship.** JetBrains Mono moved into the vendored payload at `libs/LibKa0s/media/fonts/` in **LibKa0s v1.9.0** (library-stack-§8), so an addon resolves it through `NS.MediaFont("JetBrains Mono")` — or `Media.Font(addonName, …)` directly — and **MUST NOT** carry a second copy under its own `media/fonts/` (layout-§3, anti-patterns #63). Registration moved with it: `Media.RegisterLSM(addonName)` puts the face into LibSharedMedia under one key for the whole collection, which is what stops two addons registering the same name against two different paths. The rules below are otherwise unchanged, and an addon that has not yet re-vendored still satisfies them the old way.

- The console log **MUST** render in a **monospace** font so timestamps and tags line up. The **Ka0s reference font is JetBrains Mono (Regular, OFL)**, shipped in the library payload as `libs/LibKa0s/media/fonts/JetBrainsMono-Regular.ttf` with its `OFL.txt` beside it, rather than depending on a user-installed font. Expose the resolved path as a constant (e.g. `NS.Constants.FONT_MONO`) and let `Media.RegisterLSM` do the LibSharedMedia registration. **The fallback MUST be a real client font** (e.g. `Fonts\ARIALN.TTF` or `STANDARD_TEXT_FONT`), never `nil` and never a path into a payload that may be absent: `SetFont` accepts a path to a file that is not there, fails to load it, and the text simply does not draw.
- **MUST** hand that path to the library as the descriptor's `font`. **10pt is the reference size** and is the library's default; pass `fontSize` only to deviate. The addon **MUST NOT** call `SetFont` on the console's own regions — one font decision, applied by the library to both the log and the copy box, is what keeps the copied view matching the console.
- **Sanctioned styling exception (not a deviation).** This vendored monospace font is the addon's **one deliberate departure from Blizzard-default fonts**, and it is **expected** — a standards audit **MUST NOT** flag the shipped debug console font (nor the addon logo, options-ui-§5 / layout-§3) as non-Blizzard "shipped art." The exception is bounded: a fixed-width font is a hard readability requirement for the aligned `<HH:MM:SS> | [tag] …` columns and Blizzard ships **no** monospace font object, whereas every *other* text surface (options panel, in-window widgets) **MUST** still use stock Blizzard font objects (options-ui font summary) and the console frame is skinned from stock Blizzard textures (standalone-windows). The font is **developer-facing**; the addon **MAY** pin it by name without offering an in-addon font picker (the LibSharedMedia registration exists to expose it to other addons, not to require configurability).

  **The icon set is the first place to look before either.** Since LibKa0s v1.9.0 the payload also ships an icon catalog (library-stack-§8), so a mark that used to need a font glyph or a Blizzard atlas — a sort arrow, a copy, a bin, a gear — has a shipped white TGA drawn to be legible at header sizes. Prefer it. The two allowances below remain for what the catalog does not carry and for marks that must sit **inline with text**.

  **Second sanctioned use — a glyph the default font does not have.** The vendored monospace font **MAY** also be used for an **individual glyph** that WoW's default font lacks and would render as a **box** — e.g. the ▲/▼ (`U+25B2`/`U+25BC`) direction markers in a data table's cell. This is bounded to **glyphs**, never body text: the surrounding label keeps its stock Blizzard font object, and only the glyph's own `FontString` is switched. Prefer this to a texture when the mark must sit **inline with text** — a glyph sits on the label's own baseline (so it is vertically centered by construction) and takes the label's color from the same `SetTextColor` call, whereas Blizzard's arrow textures carry uneven padding (`Arrow-Up-Up`'s art sits low in its canvas, `Arrow-Down-Up`'s high) and visibly misalign against the row. Use a **texture** where the mark is not inline with text, and check the vendored font actually carries the codepoint before relying on it. An audit **MUST NOT** flag a glyph-scoped use of the vendored font.

### 3. Line format — timestamped, tagged, colored

Every line the library renders follows `<HH:MM:SS> | [<Tag>] <content>`. The format is the **library's**, and that is the point: a log pasted from any Ka0s addon parses the same way by eye.

- The **tag** is the addon's to choose — a single short word, rendered **verbatim** (no padding, no truncation), naming what the line is about: `Loot`, `Cast`, `Attr`, `Open`, `Mail`, … The set is **open**; modules add tags as needed. `Debug` and `Init` are the library's own (§5).
- In the console, the **timestamp is muted steel-blue (`6f8faf`)** and the **`[tag]` is muted tan/gold (`c9a66b`)**; the `|` separator and the content stay the frame's **default color (white)**. (`||` renders one literal pipe inside a color-coded string.)
- The plain-text **Copy buffer mirrors the same line with no color codes**, so copied logs paste clean.
- The library keeps the two views honest with **two pure formatters** — `lib.FormatPlain(ts, tag, msg)` and `lib.FormatColored(ts, tag, msg)`, frame-free and unit-tested in the library's own suite — so the colored string cannot drift from the plain one. They are exposed on the instance for tests that need them.
- The addon **MUST NOT** redefine, wrap, or hand-copy those formatters, and **MUST NOT** reproduce their color codes in a fallback stub (§7). Copying the exact strings whose seven-way drift this extraction exists to end is the one duplicate testing-§8 most specifically forbids.

### 4. The sink

```lua
NS.Debug("Loot", "%s x%d", name, qty)     -- NS.Debug = NS.DebugLog.Debug, bound at setup (§1)
```

- **MUST** call the library's gated sink at every trace site. It is a **plain, dot-callable function** and it is **zero-allocation when off**: the gate is the first thing it does, before any `string.format`, concat, or table build. This is the same gating discipline the performance bracket follows (performance-§2).
- The **tag is the first argument** so every call site self-documents its category.
- **MUST NOT** build the message before the call. `NS.Debug("Loot", "%s x%d", name, qty)` defers the formatting behind the gate; `NS.Debug("Loot", ("%s x%d"):format(name, qty))` pays for it on every pass forever, gate or no gate.
- Every logged value is **secret-safe** (events-frames-taint-§8): the library routes each vararg through the descriptor's `safeToString` — `LibKa0s-Core-1.0`'s `SafeToString` by default, which probes `table.concat` rather than `..`, because a `..` probe wrongly passes secrets through. This is why the sink is the library's and not a local `string.format` at the call site: an unguarded combat-protected absorb/health total raises the instant it is logged, and a sink on a repeating ticker then freezes the feature until `/reload`.
- The instance also exposes an **ungated raw append**, `NS.DebugLog:Add(tag, msg)`. It exists for the lines that **must** land regardless of the flag (§5's disable bracket) and for an explicit user-initiated diagnostic run (§12). Ordinary tracing **MUST NOT** use it — an ungated trace on a hot path is a cost paid forever.
- **MAY** support structured dump verbs (`/<slash> debug <topic>`) for large addons.

### 5. Enabled-state — the addon's flag, the library's seam

**The flag stays the addon's.** `isEnabled` and `setEnabled` are descriptor callbacks over the host's own `NS.State.debug`; the library never stores a copy, because a second copy is a second truth, and the flag is read by the addon's own show-decision ladder and settings panel as well as by the console.

- **MUST** be **session-only**: default **off**, held in `NS.State.debug` (**never** in SavedVariables), and **reset to off on every `/reload` and fresh login**. *(A persisted debug flag too easily gets left on; persisting it is the documented deviation, not the default.)*
- Logging and the window are **independent** — capture runs even when the console is closed, so a bug can be reproduced first and the log opened after.
- Slash (slash-commands): `/<slash> debug` **toggles the window only** (`NS.DebugLog:Toggle()`, state untouched); `/<slash> debug on` and `/<slash> debug off` route to `NS.DebugLog:SetEnabled(true|false)`. The verb dispatches through the addon's own ordered `NS.COMMANDS` table like every other verb (slash-commands-§3); the library registers **no** slash command of its own.
- **MUST** route **every** state change through that one `SetEnabled` seam — the slash verb, the title-bar toggle, and anything else — so no two paths can diverge. The seam's single write path is: write the host's flag → refresh the header label → print the chat ack → append the console bracket line → on enable, append the `[Init]` summary.
- The **chat ack** is color-coded by the library — **`ON` green (`40ff40`)**, **`OFF` red (`ff4040`)** — e.g. `[XY] debug logging |cff40ff40ON|r`. The addon supplies the `NS.PREFIX`-tagged printer via the descriptor's `print` (slash-commands-§4, events-frames-taint-§8); the coloring of the state word is not the addon's to restyle. The colors mirror the title-bar toggle so the flag reads identically in chat and on the console header.
- A **console line** lands at **both** transitions — `[Debug] logging enabled` / `[Debug] logging disabled`. The disable line is written through the raw append (§4), **not** the gated sink, because the flag has already flipped off by then and the sink would swallow it.
- On **enable**, the library additionally emits the host's one-line **`[Init]` session summary**, immediately after the bracket, tagged `[Init]` and passed through `safeToString`. The addon supplies it as the descriptor's `initSummary` callback — addon **name + version**, **schema/DB version**, **active profile**, e.g. `[Init] KickCD v1.2.0, schema v1, profile 'Default'`. **Only the host can know what it says; only the library knows when it lands.** It rides enable rather than login because the flag is session-only and off at login, so a load-time summary would always be gated off and never render. This satisfies §8's lifecycle boot-summary requirement and makes a pasted log self-identifying without asking the reporter.
- The title bar carries a **state toggle** on the left — **`Debug: ON`** in green, **`Debug: OFF`** in red — clicking it goes through the same `SetEnabled` seam. It is the library's widget; the addon does not draw it.
- The library's `ConsoleCheckbox()` spec toggles the console's **visibility only**, never the flag. A user who closes the console does not expect capture to stop. Pass `onVisibilityChanged` if an open options panel needs to re-read that checkbox when the window is closed by ESC or the slash verb.

### 6. Copy / Clear

The Clear and Copy controls are the library's; this is the behavior they guarantee and why it is shaped this way.

- **Clear** wipes both the visible log and the Copy buffer, and resets the line counter (§11).
- **Copy** opens a read-through multiline `EditBox` pre-filled with the plain buffer and auto-highlighted for `Ctrl+C`, in the same monospace font. WoW exposes **no clipboard API** — the user's `Ctrl+C` inside an `EditBox` is the only copy path, so a button alone cannot write the OS clipboard. *(The color-vs-clean-copy split is deliberate: the `ScrollingMessageFrame` gives the colored live view, the `EditBox` gives code-free copies — one widget cannot do both, since selecting color-coded text copies its `|c…|r` escapes.)*

### 7. Fallback — the stub when the library is absent

A missing vendored library **MUST NOT** error at load, and **MUST NOT** silently break the addon's own function.

- **MUST** fall back, in `core/DebugLogSetup.lua`, to a stub carrying **every member the addon actually calls** — the bare `Debug` sink, `Add`, `SetEnabled`, `IsEnabled`, `Show`/`Hide`/`Toggle`/`IsShown`, `Clear`, `ConsoleCheckbox`, the raw `buffer`, and whatever else the slash layer, the settings page and any shared module reach for. A stub that omits a member is not a fallback — it is a crash moved to a rarer code path.
- The stub **MUST** still flip the flag and still print the ack. `NS.State.debug` is the addon's, not the library's, and a user who types `/<slash> debug on` must not be told nothing happened. What is lost is the **window**, and the stub **SHOULD** say so once, honestly, through the addon's printer — once, not per call.
- The stub **MUST NOT** re-implement the formatters or the line format (§3).
- **Utility addons with no on-screen window MAY** fall back to `NS.PREFIX`-tagged chat output instead of a console; any addon that *has* a main window (standalone-windows) **MUST** use the console.
- The degraded path **MUST** be verified by **actually loading the addon with the lib missing**, not by hand-stubbing the member under test (testing-§8).

Note: user-facing chat messages (help index, command acks, errors) still go to chat through the shared `NS.Print` printer with `NS.PREFIX` (slash-commands-§4; the same single-seam, secret-safe rules apply — events-frames-taint-§8) — that ordinary chat seam is separate from the debug console.

### 8. Coverage — trace the main functional flows (MUST)

Sections 1–7 govern the console's **wiring**; this section governs its **content**, and content is the part no library can supply. Debug **MUST**
trace the addon's **main functional flows**, so a log read back after a repro tells the story of
what the addon did — not just that it loaded. At minimum:

- **Lifecycle** — the one-line **`[Init]` session summary** (addon + version, schema/DB version,
  active profile, and any record/row count), supplied as the descriptor's `initSummary` and emitted
  by the library **on enable** rather than at load, because the flag is off at login (§5); schema
  **migration** (only when one actually runs); and retention/**prune**.
- **The core capture / compute flow** — the addon's reason for existing (e.g. an item recorded,
  a cast resolved, a bar shown), including the **not-recorded / no-op decisions** that explain a
  *missing* entry (why a loot line was skipped, why a value was ignored). A log that shows only
  successes can't explain the bug the user is reporting.
- **All data mutations** — user-initiated purge/delete and any bulk rewrite of stored data. For
  architecture-§5's named non-setting state §10 decides: a purge, *forget* or delete of learned or
  recorded data is traced here, and a reset of geometry or of a remembered view is a **MAY**.
- **View open / recompute** — the main window opening, tab switches, and each table/analytics
  **recompute**, as a single summary line (see §9).
- **Every settings change** — see §10.

Each flow event is **one gated line**, tagged (§3). Coverage is judged by *"could I reconstruct
what happened from the log?"*, not by line count — which §9 then bounds from the other side.

### 9. Coalescing — one summary line per pass, never per item (MUST NOT)

A debug sink on a **repeating path** (a bag scan, a loot window's slots, a table re-render on every
filter keystroke, a per-frame tick) **MUST NOT** emit one line per item/slot/frame. It **MUST**
collapse to **one summary line per pass**, carrying the counts and the scanned/affected detail in
that single line — e.g. `Scanned 42 items, 3 new` with the id lists appended, or
`rendered 84/1423 rows (group=zone, sort=date desc, filters=2)`. The per-item trace is spam: it
buries the signal, and on a hot path it is a measurable cost **even gated**. The buffer is capped at
1500 lines (§1), so per-item spam does not merely bury the signal — it **evicts** it.

The string-building for the summary **MUST** stay behind the debug gate (the zero-alloc rule, §4):
build the id lists / counts / `table.concat` only when debug is on, never before the gate.
*(Reference pattern in the collection: an auto-discovery pass that fired one "no category match"
line per bag item on every bag update was collapsed to a single tagged summary line per pass —
the scanned + newly-discovered id lists in one line — with the per-item zero-match trace dropped
and all list-building moved behind the gate.)*

### 10. Settings changes — log once, at the single write seam (MUST)

Every settings mutation **MUST** be logged **once**, at the schema's single write seam
(schema-as-single-source, architecture; the `Set` path), as `[Set] <path> = <value>`. Downstream
reactors — modules handling the settings-changed message — **MUST NOT** re-echo the same change: a
second `[Cfg] …` line restating a value the `[Set]` line already showed is redundant spam. A
reactor logs **only** a *material effect* the reader cannot infer from the `[Set]` line (e.g.
"capture disabled", "test data swapped in"), never a restatement of the new value.

**A runtime-completing stub is outside this section** (options-ui-§1). On a load missing
`LibKa0s-Schema-1.0`, a host's library-absent stub of that shape is the single write seam, and it
logs no `[Set]` line, per row or bulk, and keeps neither the bulk bracket's tally nor the
profile-reset count. A degraded build that writes none of this section's lines through such a stub
is not a finding under this section. The writes, their validation and each row's `onChange` still
complete, and a host whose degraded seam is its own keeps logging as this section writes it.

**A batch through the helper logs per row, unless the act is a bulk copy or reset.** When one act
writes many rows through the helper, the act decides the shape of the log, never the row count:

- **A bulk copy or reset is one `[Set]` line.** An act whose purpose is to rewrite a set of rows
  wholesale — copying one member's or one unit's settings onto another, resetting a page or a
  section to its defaults — **MUST** be logged as **one** debug-logging-§8 flow line, and that line
  **MUST** be a `[Set]` line of the shape `[Set] <act> <scope>: N rows`, such as
  `[Set] copy target→focus: 110 rows` or `[Set] reset Appearance page: 59 rows`. The act **MUST
  NOT** emit a per-row `[Set]` line for any row it writes. **N is the number of rows the act
  actually wrote**, not the number in its scope: a row already at its default, or a session-only
  row the act skips, is not counted. Only the log collapses: validation and each row's `onChange`
  still run per row, and one change notification for the whole batch is fine.
- **Every other batch logs per row.** A batched write that is not a bulk copy or reset logs one
  `[Set] <path> = <value>` per row it writes, even when the batch sends a single change
  notification: a header click that writes the sort column, mode and direction is three `[Set]`
  lines.

*Bulk* is the purpose of the act, not its size: a reset of a two-row section is one line, and a
three-row sort change is three. Where this section's once-per-write line and debug-logging-§8/§9's
one-line bulk rewrite would both apply, this is the rule that decides.

**A profile-wide reset, copy or switch is not a batch through the helper.** When AceDB replaces the
whole profile — `db:ResetProfile()`, a profile copy, a profile switch — that is wholesale
replacement (options-ui-§12, architecture-§5), not a write through the helper, and the per-row
`onChange` clause above does not apply to it. It is logged **once**, by the addon's profile-event
handler, in words chosen by the event: `[Set] reset profile 'Default' to defaults (N rows)`,
`[Set] copied profile 'A' → 'B'`, `switched to profile 'X'`. No bulk bracket adds a second line.
The reset and copy lines carry the `[Set]` tag; a switch rewrites no rows and keeps whatever tag the
addon's profile tracing already uses. The row count is included where it is cheap to know and
**MAY** be omitted otherwise.

**Named non-setting state** (architecture-§5) — geometry only a drag or a resize determines, a
remembered view, learned or recorded data, a vendored library's own writes — is written outside the
`Set` seam and is **not** a setting for this rule: it **SHOULD NOT** be logged per change (a
per-drag position write, or one line per id a scan learns, is noise). A purge, *forget* or delete of
learned or recorded data is a data mutation debug-logging-§8 already traces; a reset of geometry or
of a view **MAY** be traced once and is not required to be. A structural registry's membership
change (architecture-§5) is not a schema-row write either and produces no `[Set]` line; a create or
delete is a functional flow, traced once by the registry writer under debug-logging-§8.

### 11. Scrollbar + line counter — a guarantee, and a hazard for anyone extending it

The log surface carries a **visible scrollbar** and a **line counter**, so the developer can read scroll position and buffer fill at a glance rather than guessing from a wheel-only wall of text. Both are the library's; the addon writes neither, and an audit **MUST NOT** ask for them in the addon's source. What follows is the behavior the library guarantees and the retail hazard that shaped it — still true of anyone extending the library, and the reason the rule is written down rather than left in the code.

- **Scrollbar.** A `ScrollingMessageFrame` has **no native scrollbar** — it is wheel-only — so the console adds a **thin vertical `Slider`** on the log's right edge, synced **both ways** to the log's scroll offset: dragging the thumb scrolls the log, and the mouse wheel moves the thumb. As with the options-panel body (options-ui-§10), the bar is **always shown** and goes **inert** (mouse disabled) when the whole log fits, so the right-edge gutter stays a constant width. The `OnValueChanged` → `SetScrollOffset` path is guarded against re-entrancy with a `_syncing` flag so the two-way sync cannot loop.

- **Scroll API — MUST use the Lua mixin methods.** On current retail the log is the **Lua `ScrollingMessageFrameMixin`**: drive it with **`GetMaxScrollRange()`**, **`GetScrollOffset()`**, **`SetScrollOffset(offset)`** — where **offset `0` = bottom (newest)** and **offset `== maxRange` = top (oldest)** (`ScrollUp` *increases* the offset). The old C getters **`GetNumLinesDisplayed()` / `GetCurrentScroll()` are `nil`** on this mixin and raise *"attempt to call a nil value"* — **MUST NOT** call them (anti-patterns #41). The vertical slider (value `0` = thumb top = oldest) maps as `sliderValue = maxRange − offset` and, on drag, `offset = maxRange − sliderValue`. **Guard method presence** before every call *and* type-check the returns, so a headless test mock — whose stub frame answers with itself — stays a clean no-op rather than a crash.

- **Line counter.** A thin **bottom status bar** — a 1px divider plus a right-aligned label in the **same monospace font** (§2) — shows the live count as **`N / MAX lines`**, where `MAX` is `lib.MAX_BUFFER` (1500, §1) and `N` is the current buffered line count. It updates on **every append** and resets to `0 / MAX` on Clear (§6).

- **Build order (robustness).** The **initial** scrollbar/counter sync runs at the **end** of the window-build function — after the header, the header refresh, and the `UISpecialFrames` registration — so a frame-API surprise inside the sync can never abort the rest of the console's setup. (A mid-build error otherwise leaves the header label blank and ESC-to-close unregistered, because the build returns early.)

### 12. The console as a host surface for shared windows (MUST)

The performance harness ships its own guided step panel (performance-§4), and that panel is the **library's** frame styled by the **addon**. The same relationship applies to any Ka0s-owned shared module that draws a window.

- The shared module **MUST NOT** assume the console exists. It draws a plain frame when the host supplies no decoration.
- The addon **MUST** decorate the shared window through the **same shared factory** the console uses — `LibKa0s-Core-1.0`'s `MakeCloseButton` and `ApplySkin` — rather than an inline lookalike. Reach `ApplySkin` through Core itself (`LibStub("LibKa0s-Core-1.0", true)`); only `MakeCloseButton` is re-exported on the console instance, and assuming the pair travel together fails at call time inside a decoration hook. Two near-copies of a close button is how a collection ends up with two subtly different close buttons; one factory is why it cannot.
- **The decoration hook builds its close control through the addon's own wrapper (MUST)** — the one-line `MakeCloseButton` passthrough of standalone-windows, which supplies `addonName` — and **MUST NOT** call any factory with two arguments, the console instance's re-export (`NS.DebugLog.MakeCloseButton`) included. That re-export is the same three-argument function; reaching it through the console does not supply the name. This is the measured failure: a perf panel calling `NS.DebugLog.MakeCloseButton(frame, api.Hide)` drew a multiplication sign for as long as it shipped, two inches from a console drawing the collection's mark, with lint clean and every suite green (anti-patterns #65). Prefer the wrapper (`NS.MakeCloseButton`) over the re-export in a hook for exactly this reason — it is the spelling that cannot drop the argument.
- **A hook that exists only to draw a close button SHOULD be deleted.** From `PerfPanel.lua` minor 4 the library's own no-`decorate` path builds the control with the host's name and gets the identical button, so such a hook is a second copy of the library's behavior that can fall behind it — as this one did. Keep `decorate` for chrome the library does not draw.
- The addon **MUST** route the shared module's log output through the **console sink** (§4) and its chat output through the shared printer (events-frames-taint-§8), so a capture's lifecycle lines land in the same timeline as `[Combat]` entered/left. Reconstructing which window a measurement happened in, from memory, afterwards, is guesswork.
- Output from an explicit user-initiated diagnostic run **MUST NOT** be gated on the debug flag (§5) — route it through the ungated raw append (§4). The flag exists to keep the addon free when idle; a capture is an explicit action, and a run whose console stays empty because logging happened to be off reads as a broken feature.
- Revealing the console is the **host's** call, not the shared module's: the addon supplies a "show my log window" hook the module calls at the few moments that warrant it (a run starting, a report or dump being asked for). A shared module that opens a window on every line it writes will pop a console over the game mid-combat.

### 13. The console draws the collection's marks (MUST)

The console is the surface a user compares across addons most directly — five of them look identical
by design — so it is the surface where a lone addon still drawing words is most visible.

- A host **MUST** pass **`addonName`** (its own folder name, from its first vararg) in the descriptor.
  Given it, the library draws **close, copy and clear** from the shared icon catalog on **both** its
  windows; omitted, it draws a multiplication sign and two words, which is also what a host without
  `LibKa0s-Media-1.0` and an install missing the art get. One branch, three cases.
- **MUST NOT** pass the descriptor's `name` field for it. That field seeds the frame globals and only
  *happens* to equal the folder name in most hosts; they are different questions, and a host where
  they diverge hands the library a path into nowhere, which draws nothing and raises nothing.
- The controls carry **no tooltip**, and an addon **MUST NOT** add one. One shipped for a single
  release and was removed rather than repositioned: anchored under the control it covered the first
  line of the log.
- Requires **DebugLog minor 10** (LibKa0s v1.10.1). Minor 9 accepted `addonName` but its own close
  forwarder dropped the third argument on the way to `Core.MakeCloseButton`, so the console came out
  with two icons and a multiplication sign — see anti-patterns #64 for the class.
