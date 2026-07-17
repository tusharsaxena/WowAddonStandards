> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Standalone windows / data browsers

options-ui governs the **options** surface. An addon's own **main window** — a data browser, log, tracker, or dashboard — is a different surface with different rules. Reference implementation (in the collection): the standalone loot-history browser (a resizable, movable data-browser window with a tab strip and a scrolling record list).

- **MUST** be a plain **non-secure** `CreateFrame("Frame")` (movable/resizable) — **not** a Blizzard Settings canvas, **not** a secure/protected frame. A non-secure window touches no protected functions, so it needs **no combat-lockdown gate** and may open/refresh in combat. (Secure/action-button content is the exception and follows events-frames-taint-§2.)
- **MUST** register the window in `UISpecialFrames` so `Escape` closes it and it joins the standard close-stack.
- **MUST** persist window position and size in SavedVariables (e.g. `db.global.settings.window`), restored on open. **SHOULD** clamp to a readable minimum size and `SetClampedToScreen(true)`.
- **SHOULD** expose a scale setting (e.g. `windowScale`) applied via `frame:SetScale`.
- **SHOULD** use a tab strip with **lazy per-tab content build** — build each tab's body on first show, not up front.
- **SHOULD** centralize the window's look in a single `SKIN` table + one `ApplySkin(frame)` re-skin seam, built from **stock Blizzard textures** — no shipped *texture/border* art — so a future settings-driven re-skin has one touch point. The debug console (debug-logging) reuses this same seam. The **only** sanctioned shipped media across a Ka0s addon are the **debug console's monospace font** (debug-logging-§2) and the **addon logo** (options-ui-§6 / layout-§3); both are expected and **MUST NOT** be flagged as styling deviations in an audit.
- **MUST** pool rows for any high-churn list inside the window (events-frames-taint-§6) — never one frame per record.
- **SHOULD** provide explicit window verbs (`show` / `hide` / `toggle`) and/or a minimap/LDB launcher for display; bare `/<slash>` still prints help (slash-commands-§4).
