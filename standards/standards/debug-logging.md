> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Debug / logging — on-screen debug console

Every addon **MUST** ship a debug seam. Debug output **MUST** route to a **dedicated on-screen debug console styled like the addon's own main window** — **not** the default chat frame. Reference implementation (in the collection): the loot-history browser's debug console (`modules/DebugLog.lua`).

### 1. Console window

- A standalone `BackdropTemplate` frame (e.g. `<Addon>DebugWindow`) parented to `UIParent` on **`DIALOG`** strata so it sits **above** the addon's main window, with a draggable title bar (`"<Addon> — Debug"`), a 1px divider, and a thin close glyph.
- **Default size `700 × 344`** — the reference width, wide enough that tagged lines rarely wrap. Movable, clamped to screen, registered in `UISpecialFrames` (ESC closes).
- **Reuses the addon's `SKIN`/`ApplySkin` seam** (standalone-windows) so it matches the main window.
- The log surface is a `ScrollingMessageFrame` with `SetMaxLines(500)`, mouse-wheel scroll, `SetJustifyH("LEFT")`, fading off.

### 2. Monospace font (shipped)

- The console log **MUST** render in a **monospace** font so timestamps and tags line up. The addon **SHOULD ship** a monospace TTF under `media/fonts/` (layout-§3) — the **Ka0s reference font is JetBrains Mono (Regular, OFL)**, `media/fonts/JetBrainsMono-Regular.ttf`, **vendored with its `OFL.txt` license file** — rather than depending on a user-installed font. Register it with LibSharedMedia-3.0 at load (`LSM:Register("font", "JetBrains Mono", path)`) and expose the path as a constant (e.g. `NS.Constants.FONT_MONO`), with a Blizzard font (e.g. `Fonts\ARIALN.TTF`) as the fetch-failure fallback.
- Apply it with `SetFont(NS.Constants.FONT_MONO, 10, "")` — **10pt is the reference size** — to **both** the log and the Copy `EditBox` (so the copied view matches the console).
- **Sanctioned styling exception (not a deviation).** This vendored monospace font is the addon's **one deliberate departure from Blizzard-default fonts**, and it is **expected** — a standards audit **MUST NOT** flag the shipped debug console font (nor the addon logo, options-ui-§6 / layout-§3) as non-Blizzard "shipped art." The exception is bounded: a fixed-width font is a hard readability requirement for the aligned `<HH:MM:SS> | [tag] …` columns and Blizzard ships **no** monospace font object, whereas every *other* text surface (options panel, in-window widgets) **MUST** still use stock Blizzard font objects (options-ui font summary) and the console frame is skinned from stock Blizzard textures (standalone-windows). The font is **developer-facing**; the addon **MAY** pin it by name without offering an in-addon font picker (the LibSharedMedia registration exists to expose it to other addons, not to require configurability).

### 3. Line format — timestamped, tagged, coloured

Each line **MUST** follow `<HH:MM:SS> | [<Tag>] <content>`:

- The **tag** is a single short word, rendered **verbatim** (no padding, no truncation), naming what the line is about — `Loot`, `Cast`, `Attr`, `Open`, `Mail`, … The set is **open**; modules add tags as needed.
- In the console, the **timestamp is muted steel-blue (`6f8faf`)** and the **`[tag]` is muted tan/gold (`c9a66b`)**; the `|` separator and the content stay the frame's **default colour (white)**. (`||` renders one literal pipe inside a colour-coded string.)
- The plain-text **Copy buffer mirrors the same line with no colour codes**, so copied logs paste clean.
- Provide **two pure formatters** (frame-free, unit-tested) so the coloured string can't drift from the plain one:

```lua
function DebugLog.FormatPlain(ts, tag, msg)      -- clean text, for the Copy buffer
  return ("%s | [%s] %s"):format(tostring(ts), tostring(tag or ""), tostring(msg))
end
function DebugLog.FormatColored(ts, tag, msg)    -- console view
  return ("|cff6f8faf%s|r || |cffc9a66b[%s]|r %s"):format(
    tostring(ts), tostring(tag or ""), tostring(msg))
end
```

### 4. The sink

```lua
function NS.Debug(tag, fmt, ...)
  if not (NS.State and NS.State.debug) then return end   -- gated; zero-alloc when off
  local msg = (select("#", ...) > 0) and string.format(fmt, ...) or fmt
  NS.DebugLog:Add(tag, msg)   -- append to the console, NOT print() to chat
end
```

- **MUST** be zero-allocation when off (the gate is the first line; no `string.format`, concat, or table build before it).
- The **tag is the first argument** so every call site self-documents its category: `NS.Debug("Loot", "%s x%d", name, qty)`.
- **MUST** be **secret-safe** (events-frames-taint-§8): a `...` value that can hold a combat-protected "secret" (unit absorb/health totals, etc.) must reach `string.format`/`table.concat` only through the secret-safe stringifier — otherwise the sink raises the instant it logs one in combat, and a sink on a repeating ticker freezes the feature until `/reload`.
- **MAY** support structured dump verbs (`/<slash> debug <topic>`) for large addons.

### 5. Enabled-state — session-only, decoupled from the window

The enabled-state (`NS.State.debug`) is a **runtime flag, independent of the console window's visibility**:

- **MUST** be **session-only**: default **off**, held in `NS.State.debug` (**never** in SavedVariables), and **reset to off on every `/reload` and fresh login**. *(A persisted debug flag too easily gets left on; persisting it is the documented deviation, not the default.)*
- Logging and the window are **independent** — capture runs even when the console is closed, so a bug can be reproduced first and the log opened after.
- Slash (slash-commands): `/<slash> debug` **toggles the window only** (state untouched); `/<slash> debug on` and `/<slash> debug off` set the flag. Each state change **MUST** print a `NS.PREFIX`-tagged chat ack whose **state word is colour-coded** — **`ON` green (`40ff40`)**, **`OFF` red (`ff4040`)** — e.g. `[XY] debug logging |cff40ff40ON|r` / `[XY] debug logging |cffff4040OFF|r`. The colours mirror the title-bar toggle's green/red (below) so the flag reads identically in chat and on the console header.
- Each state change **MUST** also append a **console line** at **both** transitions — `[Debug] logging enabled` on enable and `[Debug] logging disabled` on disable — so the log itself records when capture started and stopped. The disable line **MUST** still land after the flag has flipped off, so it is written through the console's raw append (`DebugLog:Add`), **not** through the flag-gated sink (`NS.Debug`), which would swallow it.
- On **enable**, the seam **MUST** additionally emit a one-line **`[Init]` session summary** to the console, immediately after the `[Debug] logging enabled` bracket: the addon **name + version**, the **schema/DB version**, and the **active profile** — e.g. `[Init] KickCD v1.2.0, schema v1, profile 'Default'`. Emit it **on enable, not at load/login**: the flag is session-only and off at login (this section), so a login-time summary would always be gated off and never render — the `SetEnabled` seam is the only point where the summary is both current and visible. This satisfies the §8 lifecycle boot-summary requirement and makes a pasted log self-identifying (which build, which schema, which profile) without asking the reporter.
- The title bar carries a **state toggle** on the left, styled like the Clear/Copy text buttons: **`Debug: ON`** in green when on, **`Debug: OFF`** in red when off. Clicking it flips the flag and the label re-renders on every state change.
- Route **all** state changes through one `DebugLog:SetEnabled(on)` seam so the slash command and the header toggle can't diverge (single write path: set flag → refresh header → chat ack → console line).

### 6. Copy / Clear

- **Clear** wipes both the visible log and the Copy buffer.
- **Copy** opens a read-through multiline `EditBox` pre-filled with the plain buffer and auto-highlighted for `Ctrl+C`; it uses the same monospace font. WoW exposes **no clipboard API** — the user's `Ctrl+C` inside an `EditBox` is the only copy path, so a button alone cannot write the OS clipboard. *(The colour-vs-clean-copy split is deliberate: the `ScrollingMessageFrame` gives the coloured live view, the `EditBox` gives code-free copies — one widget cannot do both, since selecting colour-coded text copies its `|c…|r` escapes.)*

### 7. Fallback

- **Utility addons with no on-screen window MAY** fall back to `NS.PREFIX`-tagged chat output instead of a console; any addon that *has* a main window (standalone-windows) **MUST** use the console.

Note: user-facing chat messages (help index, command acks, errors) still go to chat through the shared `NS.Print` printer with `NS.PREFIX` (slash-commands-§4; the same single-seam, secret-safe rules apply — events-frames-taint-§8) — that ordinary chat seam is separate from the debug console.

### 8. Coverage — trace the main functional flows (MUST)

Sections 1–7 govern the console's **shape**; this section governs its **content**. Debug **MUST**
trace the addon's **main functional flows**, so a log read back after a repro tells the story of
what the addon did — not just that it loaded. At minimum:

- **Lifecycle** — a one-line **`[Init]` session summary** (addon + version, schema/DB version,
  active profile, and any record/row count), emitted **when capture is enabled** — the flag is
  off at login, so it rides the `SetEnabled` seam, not load (§5); schema **migration** (only when
  one actually runs); and retention/**prune**.
- **The core capture / compute flow** — the addon's reason for existing (e.g. an item recorded,
  a cast resolved, a bar shown), including the **not-recorded / no-op decisions** that explain a
  *missing* entry (why a loot line was skipped, why a value was ignored). A log that shows only
  successes can't explain the bug the user is reporting.
- **All data mutations** — user-initiated purge/delete and any bulk rewrite of stored data.
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
buries the signal, and on a hot path it is a measurable cost **even gated**.

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
"capture disabled", "test data swapped in"), never a restatement of the new value. Window geometry
and other non-schema view state written outside the `Set` seam are **not** settings for this rule
and **SHOULD NOT** be logged per-change (a per-drag position write is noise).
