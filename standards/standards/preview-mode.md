> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Preview / test mode

Addons whose main job is a **positionable or persistent on-screen display** (a bar, an icon grid, a nameplate widget, a tracker frame) **SHOULD** ship a **preview mode** (a.k.a. test / demo mode) that renders **representative placeholder data**, so the user can see and position the display without waiting for a real in-game event to populate it.

Reference implementation (in the collection): the modular tracker's cast bar shows a placeholder preview — a question-mark icon, a fake spell name, a `0.0 / 0.0` timer, and a bar filled to mid — **while the frame is unlocked**, so the user can drag it into place against realistic content.

- **SHOULD** trigger the preview automatically while the display is **unlocked** (drag/reposition mode), and/or via an explicit `/<slash> preview` (a.k.a. `test`) verb in the `COMMANDS` table (slash-commands-§3).
- **MUST**, when the preview has a switch of its own — a **test mode** the player turns on and that stays on until turned off — also expose that switch as the **`Test mode`** checkbox in General → Master controls (options-ui-§15): session-only, composed by the library, and in step with the verb. A preview reached only by unlocking has its switch in *Lock frame* already, and a one-shot test action (a sample printed once) is not a test mode.
- **SHOULD** feed the preview through the **same render path** as live data (placeholder values in, real widget out) so it exercises the real layout, not a separate mock.
- **MUST** clear the preview and return to live data when the display is re-locked or the preview verb is toggled off.
- Utility addons with no positionable display: **N/A**.
