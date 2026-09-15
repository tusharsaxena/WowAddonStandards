> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Preview / test mode

Addons with a **positionable on-screen display** (a bar, an icon grid, a nameplate widget, a tracker frame, a window or popup the player places) **MUST** ship a **preview mode** (a.k.a. test / demo mode) that renders **representative placeholder data**, so the user can see and position the display without waiting for a real in-game event to populate it.

Reference implementation (in the collection): the modular tracker's cast bar shows a placeholder preview — a question-mark icon, a fake spell name, a `0.0 / 0.0` timer, and a bar filled to mid — **while the frame is unlocked**, so the user can drag it into place against realistic content.

- **SHOULD** trigger the preview automatically while the display is **unlocked** (drag/reposition mode), and/or via an explicit `/<slash> preview` (a.k.a. `test`) verb in the `COMMANDS` table (slash-commands-§3).
- **MUST** ship a **test mode** — the preview as a mode of its own, turned on and left on until turned off, independent of the lock, session-only, ended when combat starts and refused during it — and expose it as the **`Test mode`** checkbox in General → Master controls (options-ui-§15). Unlocking MAY also show the preview, and a one-shot test verb MAY stay beside the mode, but neither replaces it.
- **SHOULD** feed the preview through the **same render path** as live data (placeholder values in, real widget out) so it exercises the real layout, not a separate mock.
- **MUST** clear the preview and return to live data when the display is re-locked or the preview verb is toggled off.
- Utility addons with no positionable display: **N/A**.
