> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Standalone windows / data browsers

options-ui governs the **options** surface. An addon's own **main window** — a data browser, log, tracker, or dashboard — is a different surface with different rules. Reference implementation (in the collection): the standalone loot-history browser (a resizable, movable data-browser window with a tab strip and a scrolling record list).

- **MUST** be a plain **non-secure** `CreateFrame("Frame")` (movable/resizable) — **not** a Blizzard Settings canvas, **not** a secure/protected frame. A non-secure window touches no protected functions, so it needs **no combat-lockdown gate** and may open/refresh in combat. (Secure/action-button content is the exception and follows events-frames-taint-§2.)
- **MUST** register the window in `UISpecialFrames` so `Escape` closes it and it joins the standard close-stack.
- **MUST** persist window position and size in SavedVariables (e.g. `db.global.settings.window`), restored on open. **SHOULD** clamp to a readable minimum size and `SetClampedToScreen(true)`.
- **SHOULD** expose a scale setting (e.g. `windowScale`) applied via `frame:SetScale`.
- **SHOULD** use a tab strip with **lazy per-tab content build** — build each tab's body on first show, not up front.
- **MUST** take the window's look from `LibKa0s-Core-1.0`'s shared `SKIN` table and `ApplySkin(frame)` seam — stock Blizzard textures, no shipped *texture/border* art — rather than building a private lookalike (anti-patterns #47). Ownership runs the other way round from how it used to: the seam is the library's, and the debug console consumes the same one, so a re-skin has one touch point across the whole collection. A host **MAY** override per-window via the descriptor's `skin` field where a module offers it. The **only** sanctioned shipped media across a Ka0s addon are the **debug console's monospace font** (debug-logging-§2 — which the same section also sanctions for an individual **glyph** the default font lacks, e.g. ▲/▼ in a table cell) and the **addon logo** (options-ui-§5 / layout-§3); both are expected and **MUST NOT** be flagged as styling deviations in an audit.

### The Ka0s window edge

The shared seam decides the look; this is what it draws, and it is **normative** so a new addon inherits it without a decision and an audit has something to compare against. It became the definition after five debug consoles were put side by side and did not read as one suite of addons: two hosts had converged on this treatment for their own windows and overridden the library to keep matching it, while three sat on the library's old 12px `UI-Tooltip-Border`. Specified in `LibKa0s-Core-1.0` from **Core minor 3** (LibKa0s v1.3.0).

| Part | Value | Drawn by |
|---|---|---|
| Background | `Interface\Buttons\WHITE8x8` at `0.06, 0.06, 0.08, 0.92` | `SetBackdrop` + `SetBackdropColor` |
| Outer edge | the same flat white texture at `edgeSize = 1`, inset 1 on all four sides, tinted **black** (`0, 0, 0, 1`) | `SetBackdropBorderColor` |
| Inner highlight | a 1px child frame inset one pixel on both axes, tinted `0.24, 0.24, 0.27, 0.85` | a `BackdropTemplate` child `ApplySkin` creates **once** |
| Title | Blizzard gold, `1.0, 0.82, 0.0` | `frame.title:SetTextColor` |
| Divider | `0.24, 0.24, 0.27, 0.85` | `frame.divider:SetColorTexture` |

- The edge is **two lines, not one**: a hard black outer border with a lighter grey line just inside it. A single-line border of either colour is the deviation, and it is the one that is hardest to see in a screenshot taken on its own — it only reads as wrong beside a window that has both.
- A window **MUST NOT** draw an edge that **diverges** from this one. Where `LibKa0s-Core-1.0` is reachable, `ApplySkin` **SHOULD** be what draws it — assign `frame.title` and `frame.divider` first and it tints them; omit either and it skips that call. A host helper that skins the addon's own windows is **not** a deviation and is often necessary (a main window is the host's frame, and the host may want one re-skin seam of its own); it **MUST** produce exactly the values above, and **SHOULD** delegate to `Core.ApplySkin` rather than restate them. The **same** treatment therefore covers the main window, the debug console, the console's copy window and the perf panel, which is the point — a user with four Ka0s addons open should not be able to tell which of them drew which window.
- A host **MAY** pass a module's `applySkin` **function** hook where one exists (debug-logging) — to route the module's window through the host's own re-skin seam, or for chrome differing in **shape** (an extra element, a different anchor). What an audit **SHOULD** flag is a hook or a helper whose **output differs** from the table above, not its existence: a second implementation that agrees is redundancy, and one that disagrees is the drift this section exists to end (anti-patterns #47).
- **The edge is shared; the close control is not.** A window's × comes from `LibKa0s-Core-1.0`'s `MakeCloseButton`, and a host **MAY** draw a different one on **its own** windows where the design calls for it (a large data browser reasonably closes with a larger, more visible glyph than a small diagnostic window). But a window a **library** draws — the debug console, its copy window, the perf panel — **MUST** keep the library's, and a host **MUST NOT** push its own glyph onto them through a module's `makeCloseButton` hook. Those windows belong to the library and are the surface a user compares across addons; the host's main window is not. Reserve the hook for a close control genuinely **different in kind**, and note that no addon in the collection needs it.
- Changing any value here is a **standard** change, not a library one: it alters every Ka0s window at once, so it lands in this section first and in `Core.SKIN` second.
- **MUST** pool rows for any high-churn list inside the window (events-frames-taint-§6) — never one frame per record.
- **SHOULD** provide explicit window verbs (`show` / `hide` / `toggle`) and/or a minimap/LDB launcher for display; bare `/<slash>` still prints help (slash-commands-§4).
