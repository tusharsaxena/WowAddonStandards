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

  **One marker per mode on screen (SHOULD NOT, v2.87.0).** Where a display shows the strip (standalone-windows), it **SHOULD NOT** also draw the same mode's word in its header. The header word remains the marker in any state that hides the strip but still shows the display, a minimized window or a load with no Widgets library, and in any display that has no strip.

  What is not a marker:
  - The launcher tooltip's `Test mode: On` and the Master-controls `Test mode` checkbox, because neither is on the display.
  - Placeholder data that merely looks plausible. Placeholder content whose visible text names the test **is** a marker: a group popup whose placeholder content reads *Test Group — …* says so on the display and owes nothing more.

  The rule covers the **explicit test mode only**. Under the exception above, where unlocking is the preview and *Lock frame* is its switch, it does not apply. Missing, hover-only or layout-hidden markers are anti-pattern #97.
- **The launcher's right-click menu drives this same switch** — its *Test mode* entry where the addon has a test mode, its *Locked* entry where unlocking is the preview — through the addon's own handler, the one the `test` / `lock` / `unlock` verbs and the Master-controls checkbox use, never a copy of the state; both entries are grayed while the addon is disabled (launcher-§2). The launcher's left-click opens the settings panel and drives neither; until v2.67.0 it drove this switch in an addon with no primary window.
- **SHOULD** feed the preview through the **same render path** as live data (placeholder values in, real widget out) so it exercises the real layout, not a separate mock.
- **MUST** clear the preview and return to live data when the preview verb is toggled off, and, where unlocking *is* the preview (the exception above), when the display is re-locked. A **test mode** is not cleared by re-locking — it ends only by its own switch, by combat start, or by *Reset all settings*.
- Utility addons with no positionable display: **N/A**.

### The in-game simulator (MAY)

An addon **MAY** ship an in-game simulator: a session that plays scripted events through the addon's real engine, so a player can watch it work without a group, an instance or a real event. It is not a test mode. A test mode draws placeholder data on a display; a simulator feeds the engine, and the displays draw whatever the engine makes of it.

A described reference implementation: the simulator wraps the addon's `NS.Compat` table once, in a setup file loaded straight after the compat family (`Sim:NewSeam(compat, opts)`); binds one session to that seam with a descriptor of scenarios, a `deliver` into the addon's own event handlers and a `prepare` that builds its world (`Sim:New(d)`); and is driven by one feature-verb row, `/<slash> sim …`, whose words reach `sim:RunVerb`. The library's docked step panel shows the scenario's steps while it runs. From `LibKa0s v1.76.0` a session started from the verb or the panel plays on its own at the host's step delay. Pause holds it, and a step typed or a row clicked while it plays holds it first and then plays by hand.

An addon that ships one:

- **MUST** build it on **`LibKa0s-Sim-1.0`** when the simulator is first shipped on `LibKa0s v1.75.0` or later (library-stack-§7). Adoption is otherwise required of none: a simulator a host wrote before v1.75.0 is not anti-pattern #47 until the host adopts the major, and once it has, a private session, seam, timeline or step panel beside the major is #47.
- **MUST** route every client read the simulation answers, and every outward action, through its `NS.Compat` table (compat), because that table is what the seam wraps. Each is a `Compat` member read at call time. The seam is installed right after the compat family loads; a member captured in a local before then, or at any time (`local x = Compat.Member`), is the live one and answers live data during a session, silently.
- **MUST** refuse to start:
  - while the addon is stood down, with the line by hold (slash-commands-§7, *Which refusal, by hold*, the **SHOULD** it is there);
  - while test mode is on;
  - in combat, in an instance, or in a group.

  The host supplies every one of these through its descriptor's `refusal`, which the major runs inside `seam:Live`, so it reads the real world. The major adds no world rule and relaxes none. What it computes itself is the order (an unknown scenario, then a session already running, then the host's `refusal`) and a backstop that refuses while the descriptor's `isStoodDown` answers true.
- **MUST NOT**:
  - send anything: every outward member (chat, whisper, addon message, trade) is in the host's guarded set (`opts.guarded`), which the seam answers in place of the client while a session runs;
  - act on a real player;
  - write SavedVariables from a simulated event. The step panel's position is session-only. A session log the host keeps in memory and drops at stop is not SavedVariables.
- **MUST** leave the addon exactly as it was at stop. Every module the session touched registers its cleanup (`sim:OnStopGuarded` for a step that must still see simulated answers, `sim:OnStop` once the seam is off), and every timer inside the simulation is `sim:After`, so it dies with the session.
- **MUST** mark the session on the display while it runs, as a test mode is marked (the marker bullet above). The major's step panel on screen satisfies this. A window that marks test mode with the strip **SHOULD** mark a running simulation with the strip's simulation flavor (`kind = "sim"`, Widgets minor 14, `LibKa0s v1.76.0`), under the same one-marker rule; the step panel on screen still satisfies the MUST on its own.
- Is **slash-only**: one `/<slash> sim …` feature verb, which the dispatcher refuses while the addon is disabled, with **no launcher entry and no key binding**. A launcher entry would bring launcher-§6's binding with it.
- Keeps its host members off the library instance. The host holds its own table for its own fields, and a running session's host fields go on the session table (`sim:Session()`).
- Asserts in its own suite that `seam:Unwrapped()` is empty after the whole addon loads: a `Compat` member added after the seam, or replaced by assignment, escapes it.

These are the host's contract. The library guarantees only what it computes, the refusal order with its stood-down backstop and a guarded member that never reaches the client while a session runs, and never advertises the rest as enforced (`LibKa0s#54`). The full descriptor and its obligations are in the `LibKa0s-Sim-1.0` API document (`docs/api/Sim/` in the library repo).

### Kept current at every release (MUST)

This applies to every addon that ships a test mode, a preview drawn by unlocking, or a simulator. A frameless addon, with no positionable display and no simulator, owes only the *Not applicable* answer below.

At every version bump (versioning-git) the addon **MUST** re-look at its placeholder data, its simulator scenarios and the suites that cover them, on three counts:

- **Coverage.** Every display element and feature the release adds or changes that the preview draws appears in the placeholder data. Every event-driven feature added since the previous release that a scenario could exercise is in a scenario step, or the scenario list says why it is not.
- **Currency.** Data naming game content (item, spell, encounter, instance, currency and affix ids or names, the season's dungeon list, level and item-level ranges) matches the season and patch the release targets, which the TOC `## Interface:` names (toc-file-§3).
- **Fidelity.** The data and the scenarios still drive the current render path, verbs and UI: no field the display stopped reading, no removed option, and no step driving a control that is gone.

The addon **MUST** record the outcome in that release run's `ANALYSIS.md`, under `## Preview and simulation data` (automated-tests-§5), with exactly one answer:

- **Current**: nothing needed changing.
- **Refreshed**: the data or scenarios were brought up to date, citing the commits.
- **Deferred**: the re-look found work that did not land in this release, naming the reason; it **SHOULD** cite a GitHub issue.
- **Not applicable**: the addon is frameless, as above.

The section also lists the files reviewed. `/dev-copilot:bump-version` asks the question before its release gate and writes the section; a release recorded by hand asks the owner the same question.

Why at release: data naming game content ages with every patch, and nothing else revisits it. The measured shape: the test-mode strip and the simulator arrived in v2.86.0, and their data and scenarios have no other checkpoint.

The rule commences with each addon's first release after v2.87.0. Release bundles frozen earlier are not backfilled (automated-tests-§5). It carries no anti-pattern number: a missing section, or one without an answer, is a **MUST** finding against preview-mode.
