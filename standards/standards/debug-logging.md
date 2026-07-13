> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Debug / logging — on-screen debug console

Every addon **MUST** ship a debug seam. Debug output **MUST** route to a **dedicated on-screen debug console styled like the addon's own main window** — **not** the default chat frame. Reference implementation (in the collection): the loot-history browser's debug console (`modules/DebugLog.lua`).

### 1. Console window

- A standalone `BackdropTemplate` frame (e.g. `<Addon>DebugWindow`) parented to `UIParent` on **`DIALOG`** strata so it sits **above** the addon's main window, with a draggable title bar (`"<Addon> — Debug"`), a 1px divider, and a thin close glyph.
- **Default size `700 × 344`** — the reference width, wide enough that tagged lines rarely wrap. Movable, clamped to screen, registered in `UISpecialFrames` (ESC closes).
- **Reuses the addon's `SKIN`/`ApplySkin` seam** (standalone-windows) so it matches the main window.
- The log surface is a `ScrollingMessageFrame` with `SetMaxLines(500)`, mouse-wheel scroll, `SetJustifyH("LEFT")`, fading off.

### 2. Monospace font (shipped)

- The console log **MUST** render in a **monospace** font so timestamps and tags line up. The addon **SHOULD ship** a monospace TTF under `media/fonts/` (tiered-layout-§4) — e.g. **JetBrains Mono** (OFL) — **vendored with its license file**, rather than depending on a user-installed font. Register it with LibSharedMedia-3.0 at load (`LSM:Register("font", "<Name>", path)`) and expose the path as a constant (e.g. `NS.Constants.FONT_MONO`).
- Apply it with `SetFont(NS.Constants.FONT_MONO, 10, "")` — **10pt is the reference size** — to **both** the log and the Copy `EditBox` (so the copied view matches the console).

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
- Slash (slash-commands): `/<slash> debug` **toggles the window only** (state untouched); `/<slash> debug on` and `/<slash> debug off` set the flag. Each state change prints a `NS.PREFIX`-tagged chat ack.
- Each state change **MUST** also append a **console line** at **both** transitions — `[Debug] logging enabled` on enable and `[Debug] logging disabled` on disable — so the log itself records when capture started and stopped. The disable line **MUST** still land after the flag has flipped off, so it is written through the console's raw append (`DebugLog:Add`), **not** through the flag-gated sink (`NS.Debug`), which would swallow it.
- The title bar carries a **state toggle** on the left, styled like the Clear/Copy text buttons: **`Debug: ON`** in green when on, **`Debug: OFF`** in red when off. Clicking it flips the flag and the label re-renders on every state change.
- Route **all** state changes through one `DebugLog:SetEnabled(on)` seam so the slash command and the header toggle can't diverge (single write path: set flag → refresh header → chat ack → console line).

### 6. Copy / Clear

- **Clear** wipes both the visible log and the Copy buffer.
- **Copy** opens a read-through multiline `EditBox` pre-filled with the plain buffer and auto-highlighted for `Ctrl+C`; it uses the same monospace font. WoW exposes **no clipboard API** — the user's `Ctrl+C` inside an `EditBox` is the only copy path, so a button alone cannot write the OS clipboard. *(The colour-vs-clean-copy split is deliberate: the `ScrollingMessageFrame` gives the coloured live view, the `EditBox` gives code-free copies — one widget cannot do both, since selecting colour-coded text copies its `|c…|r` escapes.)*

### 7. Fallback

- **Tier-1 utility addons with no on-screen window MAY** fall back to `NS.PREFIX`-tagged chat output instead of a console; any addon that *has* a main window (standalone-windows) **MUST** use the console.

Note: user-facing chat messages (help index, command acks, errors) still `print()` to chat with `NS.PREFIX` (slash-commands-§4) — that ordinary chat seam is separate from the debug console.
