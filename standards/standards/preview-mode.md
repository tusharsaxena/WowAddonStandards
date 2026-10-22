> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Preview / test mode

Addons with a **positionable on-screen display** (a bar, an icon grid, a nameplate widget, a tracker frame, a window or popup the player places) **MUST** ship a **preview mode** (a.k.a. test / demo mode) that renders **representative placeholder data**, so the user can see and position the display without waiting for a real in-game event to populate it.

Reference implementation (in the collection): the modular tracker's cast bar shows a placeholder preview — a question-mark icon, a fake spell name, a `0.0 / 0.0` timer, and a bar filled to mid — **while the frame is unlocked**, so the user can drag it into place against realistic content.

- **SHOULD** trigger the preview automatically while the display is **unlocked** (drag/reposition mode), and/or via an explicit `/<slash> preview` (a.k.a. `test`) verb in the `COMMANDS` table (slash-commands-§3).
- **MUST** ship a **test mode** — the preview as a mode of its own, turned on and left on until turned off, independent of the lock, session-only, ended when combat starts and refused during it — and expose it as the **`Test mode`** checkbox in General → Master controls (options-ui-§15). A one-shot test verb MAY stay beside the mode but does not replace it. **Exception:** when unlocking already shows the display with its placeholder content, the unlocked view is the test mode and *Lock frame* is its switch — no separate test mode, row or `test` verb. A one-shot value hold, if the addon keeps one, lives at `/<slash> debug hold <value> [secs]`, which is not a test mode (options-ui-§15).
- **A test mode MUST say so on the display (v2.86.0).** While the explicit test mode is on, every display drawing placeholder data **MUST** carry a visible **text** marker saying it is showing test data. The marker:
  - is readable without hovering;
  - is localized (localization);
  - is visible in **every layout in which the placeholder data is visible**, a hidden header and a compact layout included.

  A display that is minimized with its header hidden shows no placeholder data, so it owes no marker in that state; the rule binds every layout in which placeholder data is visible. The measured failure: a meter window's test text rode its header and vanished with it when the header was turned off, while the sample bars stayed. The marker's form is the addon's: a title badge, inline title text, or a strip. For a standalone window with a filter bar, standalone-windows names the recommended form.

  What is not a marker:
  - The launcher tooltip's `Test mode: On` and the Master-controls `Test mode` checkbox, because neither is on the display.
  - Placeholder data that merely looks plausible. Placeholder content whose visible text names the test **is** a marker: a group popup whose placeholder content reads *Test Group — …* says so on the display and owes nothing more.

  The rule covers the **explicit test mode only**. Under the exception above, where unlocking is the preview and *Lock frame* is its switch, it does not apply. Missing, hover-only or layout-hidden markers are anti-pattern #97.
- **The launcher's right-click menu drives this same switch** — its *Test mode* entry where the addon has a test mode, its *Locked* entry where unlocking is the preview — through the addon's own handler, the one the `test` / `lock` / `unlock` verbs and the Master-controls checkbox use, never a copy of the state; both entries are grayed while the addon is disabled (launcher-§2). The launcher's left-click opens the settings panel and drives neither; until v2.67.0 it drove this switch in an addon with no primary window.
- **SHOULD** feed the preview through the **same render path** as live data (placeholder values in, real widget out) so it exercises the real layout, not a separate mock.
- **MUST** clear the preview and return to live data when the preview verb is toggled off, and, where unlocking *is* the preview (the exception above), when the display is re-locked. A **test mode** is not cleared by re-locking — it ends only by its own switch, by combat start, or by *Reset all settings*.
- Utility addons with no positionable display: **N/A**.
