> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Slash commands

Every Ka0s addon answers `/<slash>` the same way: bare, it opens the settings panel on the addon's landing page; `help` prints the same help block, the same `list` / `get` / `set` shape, the same colors, the same reserved verbs meaning the same things. That uniformity is the point — a user running six of these addons learns one command surface, and a maintainer reading a bug report knows exactly what the pasted line came from. Uniformity written as prose drifts; uniformity carried by **one shared implementation** cannot. The dispatcher, the help renderer, the row and key/value formatters, the list builder and the type-aware value parser are therefore a Ka0s-owned library, and this section is mostly about what the addon hands it and what stays the addon's own.

**Adoption strength.** **MUST** for the **wiring** — vendor `LibKa0s-Slash-1.0`, build one dispatcher from a descriptor, register it through AceConsole, degrade to a stub when the lib is absent, and keep the tagged printer and the `COMMANDS` table on the host side. **SHOULD** for **surface** — which host verbs an addon offers beyond the reserved set is genuinely addon-specific. MUST on the wiring is what makes *"try `/<slash> list`"* a sentence that works in any Ka0s addon without checking first.

### 1. The dispatcher library and registration

The dispatcher is **shared**, not per-addon code. Addons **MUST NOT** hand-roll one (anti-patterns #47) — four-plus divergent copies across the collection are exactly what the extraction ended, and the divergence was not cosmetic: one shape coerced values with a bare `tonumber`, so `set barWidth 99999` stored 99999 and a color read back as a table address.

- **MUST** vendor **`LibKa0s-Slash-1.0`** (the `Slash` module of `LibKa0s`) by copying the **whole `LibKa0s/` folder** under `libs/LibKa0s/` and listing `libs\LibKa0s\LibKa0s.xml` in the TOC's `# Libraries` section after Ace3 (toc-file-§4, library-stack-§7). **MUST NOT** vendor `Slash.lua` alone: the module requires `LibKa0s-Core-1.0` and **returns before `LibStub:NewLibrary`** when Core is missing or older than its floor, so a partial vendor produces an *absent* major rather than a broken one — a silent loss of the entire schema CLI (anti-patterns #48).
- **MUST** create **one dispatcher per addon**, from a descriptor, in the addon's own `settings/Slash.lua` — `LibStub("LibKa0s-Slash-1.0", true)` then `:New(descriptor)`. Build it **after** the `COMMANDS` table exists, since the table is passed in; handlers reach the instance at call time, so a forward-declared local is enough.
- **MUST** still register through **AceConsole-3.0 `:RegisterChatCommand`**, and **MUST NOT** hand-roll `SLASH_*` globals. The library owns dispatch, not registration — it never registers a chat command of its own, which is what keeps every verb's output flowing through the host's tagged printer (slash-commands-§4).

```lua
addon:RegisterChatCommand("<slash>", function(msg) Sl:OnSlash(msg) end)      -- 2-3 char primary verb
addon:RegisterChatCommand("<addonname>", function(msg) Sl:OnSlash(msg) end)  -- full lowercase alias
```

- **MUST** degrade rather than error when the lib is absent. `/<slash>` is registered unconditionally, so something has to answer it: the setup file falls back to a stub carrying every member the addon calls (`OnSlash`, `PrintHelp`, `LandingRows`, `SetRowAnnotator`, and each `Cli*` verb). The host verbs never went to the library, so they keep working; what is lost is the schema CLI, and each of those verbs **MUST** name the missing library rather than going quiet.
- The stub **MUST NOT** re-implement the library's rendering — no copied row formatter, no copied parser, no copied `key = value` shape. Hand-copying the strings whose drift the extraction exists to end is precisely the duplication testing-§8 forbids; a degraded help row renders plainly and says so.
- The lib depends on **LibStub and `LibKa0s-Core-1.0` and nothing else** — no AceEvent, AceGUI or AceConsole. That is a property to preserve when extending it: it is what lets a non-Ace addon adopt the same command surface.

### 2. Verb naming

- **MUST** use 2-3 lowercase chars as the primary verb. **SHOULD** also register the full lowercase addon name as an alias, and pass it in the descriptor's `slashAliases` so the help header names it.
- **MUST NOT** collide with existing well-known addon slashes.
- **Reserved sub-verbs.** `help`, `get`, `set`, `list`, `reset`, `resetall`, `config`, `version`, `debug`, **`enable`**, **`disable`** and **`perf`** are reserved across the collection and **MUST** mean the same thing in every addon (slash-commands-§3). `perf` is the guided performance capture (performance-§4): it **MUST NOT** be re-used for anything else, and — although the run itself is implemented by a vendored library — the verb **MUST** be registered by the addon through its own `COMMANDS` table, never by the library. **Reserved always; registered when wired.** An addon holding a recorded no-combat-path exemption (performance-§12) does not register `perf` — there is no instance to dispatch into — but the verb stays reserved there exactly as it is everywhere else, so it can never be given a second meaning in one addon, and so re-arming the harness later is a registration rather than a rename. **`lock` and `unlock` join the reserved list on the same footing** — reserved always, registered when the addon has something to lock (slash-commands-§8). They mean *lock the addon's frames* and *unlock them* in every addon that carries them, and **MUST NOT** be given a second meaning in one addon; whether an addon registers them at all is a **MAY**.
- **`enable` / `disable` are ALIASES, never a second switch.** Every addon already carries an addon-wide **`Enable <AddonName>`** checkbox as the first row of General → Master controls (options-ui-§15). `/<slash> enable` and `/<slash> disable` **MUST** exist and **MUST** write **that same stored path**, through **the same single write seam** the checkbox writes through (options-ui-§1, slash-commands-§3's `set`). They hold **no state of their own** — no second key, no session flag, no `NS.enabled` local — so the checkbox and the verbs can never show the player two different answers, and one `onChange` runs whichever surface was used. **SHOULD** confirm on one tagged line, in slash-commands-§5's `set` shape, so the player sees what changed — the shape is the house style and a verb that answers in some other words is untidy rather than broken, which is a SHOULD; an addon **MAY** also accept `/<slash> set <enabledPath> true|false`, which is the same write by its long name. **MUST NOT** re-use either verb for anything else — enabling a module, a feature or a unit is that thing's own verb or row, and `/<slash> disable` meaning *turn off one feature* in one addon and *turn off the addon* in the next is the collision the reserved list exists to prevent.
- **The dispatcher survives the disabled state, so the pair is never one-way.** `/<slash>` and every verb reachable from it — `enable` above all, and with it `help`, `config` and `version` — **MUST** keep working while the addon is **disabled**. *Disabled* means the addon stands its features down: it stops drawing, stops registering the events it watches, stops writing. It does **not** mean the addon unregisters its chat command, tears down its `COMMANDS` table or drops its dispatcher, and an addon that does any of those has built a switch that only goes one way — the player turns it off, the verb that turns it back on no longer exists, and the only route left is the settings panel they were trying not to open. The dispatcher and the settings registration are **setup**, not features: they come up on load in either state and stay up.
- **A disabled addon SHOULD refuse a feature verb rather than act on it.** Acting is the wrong answer twice over: the player asked for something the addon is currently standing down from doing, and a silent no-op leaves them with no clue why nothing happened. No addon implements this today, so here is the rule at the precision it needs to be implemented and audited.
  - **A verb that DRIVES THE ADDON'S FEATURES** — anything that draws, shows, hides, tracks, records, tests, clears or exports the thing the addon exists to do — **SHOULD** answer on **one** tagged line that names **`/<slash> enable`**, and **do nothing else**. No partial work, no side effect, no second line. One line is the whole courtesy; a paragraph explaining the state is a lecture stapled to a command the player is about to re-run anyway.
  - **These are never feature verbs, so the refusal is never turned on them**: `help`, `config`, `version`, `enable`, `disable`, `debug`, `perf`, and the schema CLI — `get`, `set`, `list`, `reset`, `resetall`. The paragraph above already **MUST**s that they keep answering; naming them here is the same rule from the other side, and it is spelled out because *"refuse while disabled"*, read literally, takes the entire command surface down with it. The reasoning is that a player must be able to **read and repair settings**, and to **reach the panel**, while the addon is off — which is precisely when they are most likely to need to — and **`enable` above all**, or the pair is one-way again. `debug` and `perf` are diagnostics rather than features: the usual reason to reach for either is that the addon is misbehaving.
  - **It stays a SHOULD, deliberately.** It is a courtesy rather than a correctness property — nothing breaks when a disabled addon's one feature verb quietly does nothing — and an addon with a single feature verb may reasonably read the refusal line as noise. An addon that declines it is not deviating and owes no register row. What it **MUST NOT** do is refuse anything on the live list above.
- **These five rules were reversed in v2.56.0 and RESTORED in v2.57.0, and the round trip is recorded rather than erased.** v2.56.0 narrowed the disabled surface to `enable` and `help`, refusing `config`, the schema CLI, `debug` and `perf`. In use that was wrong in the way rules about a disabled thing usually are: the owner hit `/<slash>` on a disabled addon expecting the panel — the one surface from which it can be switched back on by hand — and got a refusal. The narrowing's own *What the refusals cost* passage had already conceded this was the largest thing it gave up, and conceding a cost is not the same as being right to pay it. What v2.56.0 got right and KEEPS is slash-commands-§7's stand-down: a disabled addon is genuinely inert. That was always the substance; the slash surface was never the point.
- **`reset` takes a schema PATH, not a page.** `/<slash> reset <path>` resets exactly one setting, collection-wide. There is deliberately **no** page-shaped form: a page is a property of a settings panel, and every schema-driven page already carries a per-page **Defaults** button that resets it (options-ui). The capability is not lost — only its CLI route — and an addon that still accepts `/<slash> reset <page>` **MUST** converge onto the path form.
- **MAY** map a legacy spelling onto a current verb through the descriptor's `aliases` map (typed verb → real verb) rather than keeping a dead branch in the dispatcher.

### 3. Dispatch — the `COMMANDS` table stays the host's

Dispatch is **schema-driven**: `get`, `set`, `list`, `reset` and `resetall` walk the addon's schema through descriptor functions, and every other verb is a handler in an ordered table the **addon owns**.

- The ordered verb table **MUST** live in the addon (`NS.COMMANDS`) and be **passed into** the descriptor, never owned by the library. The reason is structural, not squeamishness: the addon's About/landing page renders the same table (slash-commands-§4), so a library that owned it would force the options library to consume this one — and two libraries reaching for each other is a real dependency cycle. The table crossing between them as **plain data** is what keeps them independent.
- Entries **MUST** be **positional triples** `{ name, description, handler }`. The library reads `entry[1]`, `entry[2]`, `entry[3]`; a table of named fields is silently invisible to it — every verb becomes unknown and the help block renders empty.
- The `handler` receives `rest` — everything after the verb, **case and internal spacing preserved**.

```lua
NS.COMMANDS = {
  {"help",     "List available commands",                        function()     printHelp()  end},
  {"config",   "Open the settings panel",                        function()     NS.OpenOptionsPanel() end},
  {"enable",   "Enable the addon",                               function()     setEnabled(true)  end},
  {"disable",  "Disable the addon",                              function()     setEnabled(false) end},
  {"list",     "List every setting and its current value",       function()     cli:CliList() end},
  {"get",      "Print a setting's current value — `/<slash> get <path>`",
                                                                 function(rest) cli:CliGet(rest) end},
  {"set",      "Set a setting — `/<slash> set <path> <value>`",  function(rest) cli:CliSet(rest) end},
  {"reset",    "Reset one setting to its default — `/<slash> reset <path>`",
                                                                 function(rest) cli:CliReset(rest) end},
  {"resetall", "Reset every setting to defaults",                function()     runResetAll() end},
  {"debug",    "Toggle the debug console — `on`/`off` enable/disable logging",
                                                                 function(rest) runDebug(rest) end},
  {"perf",     "Measure performance — try `/<slash> perf` for the workflow",
                                                                 function(rest) runPerf(rest) end},
  {"version",  "Print the addon version",                        function()     cli:CliVersion() end},
}
```

- The dispatcher is then built from a descriptor whose fields are the addon's **seams into its own state**:

```lua
cli = SlashLib:New({
    slash        = "/<slash>",
    slashAliases = { "/<addonname>" },
    commands     = NS.COMMANDS,
    aliases      = { options = "config" },      -- back-compat: `/<slash> options` -> `config`

    print        = function(line) print(line) end,   -- the HOST's tagged printer (slash-commands-§4)
    version      = getVersion,

    get          = function(path) return NS.GetSetting(path) end,
    set          = function(path, v) NS.SetByPath(path, v) end,   -- the single write seam
    findRow      = function(path) return NS.FindSchemaRow(path) end,
    applyDefault = function(row)   NS.ApplyDefault(row) end,
    allRows      = allRows,                                        -- every row, in listing order
    groupKey     = function(row)   return row.page end,            -- the heading a row lists under
})
```

- `set` and `applyDefault` **MUST** go through the addon's **single write seam** (the same one the options panel uses), not a bare table write, so a CLI change takes exactly the path a panel change does — the same debug line, the same `onChange`, the same panel refresh. The CLI and the checkbox then cannot drift onto different code paths.
- `allRows` **MUST** return rows in the order `list` should print them — the addon decides that order (panel page order, expanded per unit where a page is per-unit); the library preserves it and groups on whatever `groupKey` returns. A listing whose order disagrees with the panel is its own puzzle.
- **Bare `/<slash>` (no args) MUST open the settings panel on its landing page** — the reserved `config` verb's act, which the library's dispatcher runs for an empty command (LibKa0s v1.38.0, Slash minor 11) — and **`/<slash> help` MUST print the help index**, generated from `COMMANDS`, never a hand-maintained string. Where the panel refuses to open (combat, options-ui-§2), bare `/<slash>` prints the same refusal `config` does. The command list stays one word away, and the landing page it opens renders the same `COMMANDS` table (slash-commands-§4). There is no per-addon exception: an addon with a browser window reaches it through its own verbs (`show` / `toggle`) or launcher.
- **MUST** register a **`version`** verb that prints the addon's version on its own line — `/<slash> version` → `<tag> v<version>`. The help header (slash-commands-§4) already carries the version, but the standalone verb is the canonical, greppable single-line answer to "what version am I running?" that every Ka0s addon answers identically. Read the version from the TOC metadata (`GetAddOnMetadata(NS.name, "Version")`) with the in-code constant as fallback, so it can't drift from the packaged manifest, and hand that reader to the descriptor's `version` field so the header and the verb cannot disagree.
- Dispatch **MUST** lower-case **only the verb** and preserve case in the remainder, so schema paths survive `/<slash> set <path> <value>`. The library does this; an addon parsing `rest` itself **MUST NOT** fold its case.
- An **unknown verb MUST** print `unknown command '<verb>'` and then the help index — never silently no-op.
- **MUST NOT** use `if arg == "foo" then elseif arg == "bar" then` chains.

### 4. Help output & chat tag

**The tagged printer stays the host's, and the library cannot supply it.** The tag identifies *which addon* is speaking, and a library shared by all of them has nothing to derive it from. The addon builds the printer and hands it to the descriptor's `print`.

- Every line the addon prints to chat **MUST** carry a short **bracketed tag** — the addon's initials in `[...]`, wrapped in **the cyan color code** — exposed as a **single shared constant** (`NS.PREFIX`) so every module prints identically. Required format: `|cff00ffff[XY]|r` (initials `XY`, color `00ffff` cyan). The **cyan color is mandatory**, not merely an example: every Ka0s addon shares the same tag color so a user running several recognizes them at a glance. **MUST NOT** hand-write `"|cff…" .. addonName .. "|r"` per call site, and **MUST NOT** substitute a different color.
- The printer **MUST** be **secret-safe** (events-frames-taint-§8): build each line from the secret-safe stringifier, not raw `tostring` / `..` / `table.concat`, so a combat-protected value logs as `<secret>` instead of raising. `LibKa0s-Core-1.0`'s printer factory provides exactly this shape and **SHOULD** be what `NS.Print` is built from.
- **MUST** pass that printer as the descriptor's `print`. The library's own default sink — the chat frame, **untagged** — exists so a host that forgot the field still gets visible output while debugging its wiring; it is a visibility fallback, **not** a tagging mechanism, and shipping on it violates the rule above.
- **Guard the printer against AceConsole's `:Print` mixin.** If the addon embeds AceConsole-3.0 into the same table that exposes the custom printer (`NewAddon(NS, …)` with the printer at `NS.Print`), AceConsole's embedded `:Print` **overwrites** it and every line prints as `|cff33ff99<msg>|r:` (green, trailing colon, no cyan tag) — silently breaking the prefix rule above. The **MUST** rule and its two fixes are in **architecture-§2** (see also anti-pattern #36).

**One row formatter, two surfaces.** The help index and the settings landing page render the *same* `COMMANDS` table, so they **MUST** render through the **same formatter** — the library's — and differ only in indentation.

- Row shape: `|cFFFFFF00<slash> <name>|r — |cFFFFFFFF<desc>|r` — gold command, an **em dash with a single space either side**, white description. Produced by the library's row formatter; **MUST NOT** be re-spelled at a call site.
- The formatter is **not indented**. The **chat** form indents each row **two spaces**; the **panel** form does not. The indent is chat-only and belongs to the renderer, not the formatter: a chat line needs one to sit under its header, while in an AceGUI label a leading indent reads as a mistake rather than as structure. The library exposes both forms; an addon **MUST** take them from there rather than adding its own spaces to the panel rows.
- **Header:** `<tag> v<version> — slash commands (|cFFFFFF00/<alias>|r is an alias for |cFFFFFF00/<slash>|r)`. The alias clause appears only when `slashAliases` is given, and names its first entry.
- The help index — and the fallback shown after an unknown verb — **MUST** be generated from `COMMANDS`. A hand-maintained help string is a second source of truth that starts drifting on the next verb added.
- **No trailing colon (house style).** **No** chat line the addon prints — help header, command rows, `list`/`get`/`set` output (slash-commands-§5), profile sub-headers, or any other — **MUST** end in a trailing `:`. Introduce a list with the header text alone; the following indented rows already read as its members.

```lua
-- The chat help block and the About page's command list, from one formatter.
function Sl:PrintHelp()   cli:PrintHelp()        end   -- header + two-space-indented rows
function Sl:LandingRows() return cli:LandingRows() end  -- same rows, no indent, for the panel
```

### 5. Settings read/write output format

`list`, `get`, `set` and `reset` share one canonical output shape so every Ka0s addon reads identically in chat. This is the **contract the library satisfies**: an addon gets it by wiring the descriptor correctly, and the rules below are what a reviewer checks against a screenshot. Every line carries `NS.PREFIX` (slash-commands-§4).

- **`list`** **MUST** print a header, then one **`[group]` header** per schema page (in the addon's declared page order), then one indented **`path = value`** row per setting under that group (color codes shown stripped for legibility — see the color scheme below):

  ```
  [PFX] Available settings
  [PFX]   [general]
  [PFX]     enabled = true
  [PFX]     scale = 1.00x
  [PFX]   [icons]
  [PFX]     icons.primarySize = 64 px
  [PFX]     icons.anchor = RIGHT_MIDDLE
  ```

  - Header line: `Available settings`. With no rows registered, a single `No settings registered yet` line instead.
  - Group header: **two-space** indent, the group key in `[...]`. The key comes from the descriptor's `groupKey`, defaulting to the row's page; an addon with per-unit pages **SHOULD** compose a composite key (`bar / player`) so the listing is unambiguous.
  - Value row: **four-space** indent, the **full schema path** on the left (nested paths dotted, e.g. `icons.primarySize`), then ` = `, then the formatted value.
- **Color scheme (MUST).** Every Ka0s addon prints schema output in **one shared color scheme** so the surface reads identically across the collection (the same house-style intent as the mandated cyan chat tag, slash-commands-§4). No line **MUST** carry a **trailing colon**.

  | Element | Color | Code |
  | --- | --- | --- |
  | `Available settings` header | green | `\|cff33ff99…\|r` |
  | `[group]` header (brackets included) | azure | `\|cff3399ff…\|r` |
  | setting key / schema path | gold | `\|cFFFFFF00…\|r` |
  | value | white | `\|cFFFFFFFF…\|r` |

  The ` = ` separator stays default (uncolored). The `NS.PREFIX` tag keeps its mandated cyan (slash-commands-§4). These four colors are **mandatory, not merely examples** — **MUST NOT** substitute other colors or add a trailing colon. Hex **case** is not significant to the client: the row and key/value formatters emit uppercase, the header and group strings lowercase, and recasing either to match the other is a user-visible diff for no gain.
- **`get <path>`**, **`set <path> <value>`** and **`reset <path>`** **MUST** print the **single-line** `path = value` form (no header, no indent), in the same gold-key / white-value coloring as the `list` rows, from the same shared formatter. A `set` **MUST** read back the **stored** value after writing, so the echo reflects any clamping or coercion — a clamped number is only visible to the user because the echo reports what was actually stored. A `reset` echoes the same way.
- **Value formatting MUST be type-aware, unit-annotated, and schema-driven** (never hand-formatted per call site):
  - numbers → the row's own format string where it declares one (`64 px`, `1.00x`), otherwise the plain number
  - booleans → `true` / `false`
  - colors → `{r, g, b, a}`, two decimals each (e.g. `{1.00, 0.13, 0.13, 1.00}`)
  - enums / strings → the raw token or display string (e.g. `RIGHT_MIDDLE`, `Bui Prototype`); an empty string renders as `(none)` rather than as nothing at all
  - a nil stored value → `nil`
- The value formatter and the colored `key = value` helper are **one shared pair**, used by `list`, `get`, `set` and `reset` alike, so the coloring and the value shape can never drift between them. An addon **MUST NOT** wrap either in a private variant.
- Unknown path → `Setting not found: <path>`; a missing or empty argument → a `Usage: …` line naming the addon's own slash.
- **Annotations are the host's.** Where a rendered value needs a caveat the library cannot know — that a setting is currently overridden, mirrored, or inert — the addon **SHOULD** supply a row annotator rather than reformatting the line. The library decides only **where** an annotation may appear: after the colored pair, on `list` / `get` / `set`, and **never** on `reset` or `resetall`, where an explanation of what a value means is noise stapled to an acknowledgment that the value went away.

### 6. Value parsing

Parsing typed input is **the library's**, and an addon **MUST NOT** re-implement it. The behavior below is the collection's contract, not an implementation note — a user learns it once.

- **bool** accepts `true` / `false`, `on` / `off`, `1` / `0`, `yes` / `no` (case-insensitive). Anything else fails.
- **number** is read with `tonumber`, then **clamped** to the row's `min` / `max`. Out of range **clamps rather than fails**, because a user typing a width larger than the panel allows means *"as wide as it goes"* — and the echo of the stored value then shows them what they actually got.
- **string** **MUST** match one of the row's declared allowed values, and **fails** otherwise. There is no charitable reading of a misspelt texture name, so an enum is validated where a number is clamped. Allowed values are resolved **at call time**, since a media list is populated by another addon and is not knowable when the row is declared.
- **color** takes `r g b [a]`, and rescales by 255 **jointly** when any of r/g/b exceeds 1 — `255 128 0` is one color expressed in one scale, and dividing only the components that happen to exceed 1 would mangle the rest. Alpha rescales independently and defaults to 1. All components clamp to 0–1.
- A failure prints `Invalid value for <path>` followed by an indented reason. **MUST NOT** silently store a value the addon cannot honor: a CLI that accepts what it will not apply is worse than one that refuses.
- An addon with a genuinely exotic row type **MAY** supply its own parser through the descriptor's `parse` field, which keeps the override at the one seam instead of forking the dispatcher (anti-patterns #47).

Reference implementation: Absorb Tracker's `settings/Slash.lua`.

### 7. The disabled state is total (MUST)

**Disabled means the addon is not running.** Not hidden, not quiet, not skipping a repaint — **not running**. It stops drawing, it stops watching, it stops writing, and the only thing left alive is the surface that can turn it back on. A player who unticks *Enable `<AddonName>`* has asked for the same outcome they would get by unticking the addon in Blizzard's own AddOns list, minus the `/reload`; anything short of that is the addon deciding on the player's behalf that it should keep some of its claws in.

**This ratifies and sharpens a definition the standard already carried; it does not invent an obligation.** slash-commands-§2 has said since v2.53.0 that *disabled* means the addon "stands its features down: it stops drawing, stops registering the events it watches, stops writing." That sentence was correct and it was already normative. What it was not was **auditable** — it sat as an aside inside a paragraph whose subject was the dispatcher, it carried no test, and nothing in `AUDIT.md` read it. Eleven addons drifted underneath it in exactly the way an unchecked definition invites: **eleven of eleven implement disable as a draw gate** — a rung in a show-ladder, a boolean an early-return consults — and **not one of them genuinely stands down**. A sweep of the collection counted **107 survivors** of the disabled state: **34 live event registrations**, **26 things still drawing**, **18 SavedVariables writes**, **13 running timers**, and 16 others. The rule below is that same definition promoted to its own numbered MUST, stated exhaustively enough that a reviewer can check it and a test can fail on it, because vagueness is what produced the eleven draw gates and vagueness is the thing being fixed.

#### What MUST stand down

On the transition to disabled, in the same turn as the write — not at the next `PLAYER_ENTERING_WORLD`, not at the next `/reload`:

- **Every frame the addon owns is hidden**, and stays hidden. Hiding **MUST** be enforced at the source — inside the addon's own show-decision ladder — rather than imperatively, for the reason performance-§6 already gives about suspend: hidden frames come back. A combat transition, a target swap or a settings change re-shows a bar behind the switch's back, and the addon is then visibly running while it claims to be off.
- **Every event, message and bucket registration the addon owns is actually UNREGISTERED.** Every `RegisterEvent`, `RegisterUnitEvent`, `RegisterMessage`, `RegisterBucketEvent` and raw `frame:RegisterEvent` the addon made, on every frame and every AceEvent target it owns, including the per-unit frames — gone, not gated. **What goes is the registration, not the frame object**: a private unit-filter frame is unregistered and kept, because events-frames-taint-§1's carve-out requires that same frame to be re-used across a disable/enable cycle rather than rebuilt, and destroying it to satisfy this rule would leak one frame per flick of the switch. Unregistered and idle is the compliant state for the frame; the addon holds it where the enable path can find it again.
  - **A handler that merely early-returns does NOT satisfy this, and the distinction is the whole point of the rule.** An early return means the addon **did not stop watching — it stopped reacting**, and it still pays the dispatch: the client still walks its registration list on every `UNIT_AURA` in a twenty-five-man raid, still builds the argument frame, still enters Lua, still runs the comparison that decides to leave. That cost is precisely what a player turning the addon off is trying to stop paying, and it is invisible to every surface they can see. It is also why the draw gate survived eleven audits: from the outside it looks identical to standing down, and the only thing that tells them apart is reading the registration list.
  - **Recorded, not ruled: a settings panel's subscription to its own refresh message.** The collection reads it both as part of the panel body (*What MUST survive*, below) and as a message registration that goes, and open-evolutions records the question with the hosts on each side. Until it is ruled, each host keeps the reading it has, and neither reading is a finding. Every other message registration stands down as this bullet writes it.
  - The **one sanctioned exception is a hook that cannot be undone.** `hooksecurefunc` has no un-hook, so a hook installed through it **MUST** gate its own body on the disabled state and return — there is no other move available. Raw hooks and AceHook hooks **MUST** be un-hooked, because they can be. An addon **MUST NOT** generalize the `hooksecurefunc` carve-out to anything that has a real unregister; the carve-out exists because the API is one-way, not because gating is acceptable.
- **Every timer, ticker and `OnUpdate` is canceled.** `AceTimer` handles canceled, `C_Timer.NewTicker` handles canceled, `OnUpdate` scripts cleared — not left armed to wake up and find a flag. A coalescing repaint timer that re-arms up to ten times a second in combat and then discovers it has nothing to paint is the single most expensive shape this rule exists to kill, and one addon in the collection ships exactly it.
- **No SavedVariables write originates from a game event.** While disabled the addon **MUST NOT** write to its stored tree in response to anything the *game* does — entering combat, a group change, a loot event, a zone change. One addon in the collection writes `locked = true` and prints a line to chat when the player enters combat **while it is disabled**; that is the failure in its purest form, because the player's evidence that the addon is off is the absence of exactly that line.
- **Hooks and secure state drivers are stood down where they can be**, and where they cannot be stood down safely they are stood down **as soon as they can**. `UnregisterStateDriver`, `UnregisterAttributeDriver` and any secure-attribute rewrite **MUST NOT** be attempted in combat; the addon holds the stand-down pending and completes it on `PLAYER_REGEN_ENABLED`. That pending completion is the one event registration a disabled addon is permitted to keep, and it **MUST** be released the moment it fires.

#### What MUST survive, because it is SETUP and not a feature

The switch has to go both ways, so a short, named list is exempt. Everything on it is **setup** — it comes up on load in either state and stays up — and nothing on it is a feature:

- **The chat command registration, the dispatcher and the `COMMANDS` table** (slash-commands-§2). Without these, `/<slash> enable` does not exist and the player's only route back is the panel they were trying not to open.
- **The settings-category registration and the panel body.** The addon stays listed in Blizzard's Options → AddOns tree while disabled, and its *Enable `<AddonName>`* checkbox is live there. This is not a nicety: it is what `config` and the bare `/<slash>` open while disabled (slash-commands-§2), and the route a player not at a chat prompt uses to switch the addon back on.
- **The AceDB handle, the single write seam, and AceDB's `OnProfileChanged` / `OnProfileCopied` / `OnProfileReset` callbacks.** `enabled` is a stored setting like any other, and a **profile switch can flip it** — a player switching to a profile where the addon is enabled expects it to come up. The addon **MUST** re-evaluate the switch on those callbacks while disabled, which means it cannot drop them. A write the **player** causes, through the panel or through a live verb, is not a write "from a game event" and *What MUST stand down* does not reach it. Nor does it reach **LibDBIcon's own** `minimapPos` write when the player drags the button; that write is the library's and the addon does not make it.
- **The launcher's registration.** The minimap button and the broker row stay registered and stay visible; `minimap.hide` is a per-installation display preference (launcher-§3) and has nothing to do with whether the addon is running. What the **click** does while disabled is the next subsection.

#### The slash surface while disabled — unchanged, and that is the ruling

**This subsection narrowed the surface to `enable` and `help` in v2.56.0 and was REVERSED in
v2.57.0.** The round trip is left on the record because the reasoning on both sides is worth having.

The narrowing failed on contact with use. Its own *What the refusals cost* passage conceded that
taking the schema CLI away was "the largest thing given up here" and that refusing `debug` and
`perf` "costs diagnosis of a disabled addon" — and then paid both anyway. What settled it was
smaller and more ordinary: `/<slash>` on a disabled addon returned a refusal instead of the settings
panel, which is the one surface a player uses to switch it back on by hand. A rule that makes the
off switch harder to find has misunderstood which half of the pair it is protecting.

**So the disabled slash surface is exactly what slash-commands-§2 says and nothing here overrides
it.** Every verb answers: `config` and the bare `/<slash>` open the panel, `version` prints, `debug`
and `perf` run, and the whole schema CLI — `get`, `set`, `list`, `reset`, `resetall` — reads and
repairs settings, which is precisely when a player most needs it. §2's **SHOULD** that a *feature*
verb answers one tagged line naming `/<slash> enable` stands unchanged: it was written before this
section existed, it survived the reversal, and it is the only refusal in the disabled state.

**None of this weakens the stand-down.** *What MUST stand down* above is untouched and is what this
section is actually for. A disabled addon registers nothing, runs no timer, draws nothing and writes
nothing from a game event — and it answers every verb you type at it. Those two facts are not in
tension: the dispatcher and the settings registration are **SETUP, not features** (*What MUST
survive*), so keeping them live costs nothing the stand-down was trying to reclaim. The addon is
inert; its command surface is not the addon.

#### The launcher while disabled

The button stays on the minimap and the broker row stays in the display (*What MUST survive*), because their visibility is a separate preference. What the click does changes:

- **Left-click is refused on rungs (a) and (b)** — it prints the refusal line (*The refusal line*, below) and **does nothing else**. Those two rungs of launcher-§2 drive a primary window and a preview switch respectively, and both are features.
- **Rung (c) is unchanged**, because its left-click opens the settings panel and nothing else — which *What MUST survive* keeps standing. Refusing it would decline one button for doing precisely what the right button beside it is required to keep doing, which is not a rule so much as a contradiction. launcher-§2 carries the same carve-out in the same words.
- **A launcher click MUST NOT write SavedVariables while the addon is disabled.** The audit found an addon whose minimap button stays clickable with **no disabled gate at all**, so clicking it writes the stored tree of an addon the player has switched off. That is a bug under the old rule as much as the new one, and it is named here because nothing previously said so: the click is a game event in every sense that matters, and *What MUST stand down* reaches it.
- **Right-click still opens the settings panel**, unchanged, on every addon, in either state. The panel is **setup**, not a feature (*What MUST survive*), so the right button opens it for the same reason `config` and the bare `/<slash>` still do (slash-commands-§2); refusing it would make the mouse the one surface on which the off switch is harder to reach than from chat.

#### The refusal line — one shape, collection-wide

The one refusal a disabled addon prints — §2's feature-verb SHOULD, and the refused launcher click below — is **exactly one line**, through the addon's own tagged printer (slash-commands-§4), in this shape:

```
<NS.PREFIX> <BrandName> is disabled — enable it with |cFFFFFF00/<slash> enable|r
```

Rendered, with the color codes stripped for legibility:

```
[AT] Ka0s Absorb Tracker is disabled — enable it with /at enable
```

- **`<BrandName>` is the addon's brand name in plain text — `Ka0s <Name>`** — the **same string** launcher-§1 already **MUST**s as the LDB object's `label`. Reusing it is not an aesthetic choice: launcher-§1 already forbids escape sequences in that field, which is what makes it safe to drop into a colored line, and it means an addon has exactly one brand spelling rather than a second one invented for this message.
- The command is **gold** (`|cFFFFFF00…|r`), the same color the row formatter gives a command in the help index (slash-commands-§4), and it carries the **leading slash**. The rest of the line is default-colored. **MUST NOT** substitute other colors.
- **An em dash with a single space either side**, matching the row formatter. **No trailing colon** (slash-commands-§4's house style) and **no trailing period**.
- **One line, and the wording is the collection's, not the addon's.** It **MUST NOT** be re-spelled per addon, per verb or per call site, and it **MUST NOT** gain a second line explaining what the addon does, what the verb would have done, or how to reach the panel. A paragraph is a lecture stapled to a command the player is about to re-run anyway, and eleven addons each wording it slightly differently is the drift the shared printer and the shared formatters exist to end.

#### Disabled and perf-suspended are two holds on ONE latch

**The capability to stand down already exists in every addon, and disable simply declines to use it.** Every Ka0s addon ships the suspend/resume machinery performance-§6 requires for a capture's second arm, and that machinery does exactly what *What MUST stand down* asks for — Absorb Tracker's `core/PerfSetup.lua` calls `UnregisterAllEvents` on precisely the per-unit frames its *disable* leaves registered. It is built, it is wired, and it is exercised by an offline scenario. **The stand-down therefore MUST be built on that seam.** An addon that writes a second teardown path for disable has two mechanisms that must agree about what "inert" means, and they will diverge on the first module added after the second one was written — **a parallel lifecycle mechanism is the anti-pattern here**, not an implementation detail.

Two holds, one latch:

- The addon is **stood down whenever at least one hold is taken**, and **stood up only when the last one is released**. The holds are named and independent: **`disabled`**, taken from the stored `enabled` path, and **`perf`**, taken by the performance harness for the suspended arm.
- **Releasing one hold MUST NOT resurrect an addon the other is still holding down.** This is the trap, it is reachable today, and it needs stating: `/<slash> disable` is a live verb, so a player can disable the addon **during a suspended arm**; `/<slash> enable` is live too, so they can re-enable it there as well. A resume that calls a bare `StandUp()` brings the addon back mid-capture and silently ruins the run; a disable that calls a bare `StandUp()` on its way out does the same. Both **MUST** go through release-and-re-evaluate, never through a direct stand-up.
- **The two holds have different lifetimes and neither inherits the other's rule.** `perf` is **session-only** and **MUST NOT** be persisted (performance-§6, unchanged). `disabled` is **persisted** — it is the stored `enabled` path and surviving a `/reload` is the entire point of it.
- **performance-§6's "MUST resume before saving or reporting" is unchanged in force and sharpened in meaning:** it requires the harness to **release its own hold**, not to stand the addon up. An addon left disabled by the player at the end of a run stays disabled, and a persistence error still **MUST NOT** be able to strand the `perf` hold taken for the rest of the session.
- **performance-§6's restore-from-current-state rule applies to this latch in full.** Standing up rebuilds registrations from the enabled set **as it is now**, never from a snapshot taken when the last hold was acquired, so a setting changed while the addon was disabled comes back correctly.
- **`perf` answers while disabled** (*The slash surface while disabled*), because it is a diagnostic rather than a feature and v2.57.0 restored it. That is the right answer for its own reason: the harness's independent variable is *"does our code run?"*, and against a conformant disabled addon both arms are inert, so the capture would measure nothing and report it as a null result.

#### The conformance test every addon ships (MUST)

A definition with no test is what produced eleven draw gates, so this one ships with a test. Every addon **MUST** carry a **`tests/test_disabled.lua`** suite, listed in `tests/run.lua`'s suite list like any other (testing-§1), inside the green gate (testing-§4). **It MUST be able to fail against all eleven addons as they stand today** — a suite that passes on a draw gate is not a conformance test, it is a second draw gate (testing-§12).

It asserts, in order, driving the addon through the kit's **recording** mocks (testing-§1's fidelity rules — a no-op `RegisterUnitEvent` makes this entire suite unfalsifiable):

1. **Baseline.** Bring the addon up **enabled**, run the lifecycle `tests/run.lua` already runs, and capture three snapshots from the mock: the **registration set** `R_on` (every event, unit-event, message and bucket registration, by frame/target and name), the **armed-timer set** `T_on`, and the set of **shown frames** `F_on`. Assert `R_on` is **non-empty** — an addon that registers nothing when enabled would pass every later assertion trivially.
2. **Disable** by writing the enable path through the addon's **single write seam** (never by calling a teardown function directly — the test must exercise the route the checkbox and the verb take).
3. **The registration set is empty.** Assert from the mock's registry, by count and by name, that nothing the addon registered is still registered. **This is the assertion the whole suite exists for and the one that reddens all eleven addons today.** It **MUST NOT** be written as "call a handler and assert it returned early" — that is the draw gate passing its own test.
4. **No timer, ticker or `OnUpdate` remains armed**, and no new one is armed for the rest of the run.
5. **Every frame in `F_on` is hidden.**
6. **Fire every event in `R_on` at the mock anyway** — the client will not, but a survivor would — and assert **zero SavedVariables writes**, **zero printer calls** and **zero frame shows** result. Include the addon's combat-entry event by name; this step is what catches the `locked = true` write and the chat line one addon in the collection emits on entering combat while disabled.
7. **The slash surface.** Dispatch **every** entry in `NS.COMMANDS` through the real dispatcher while disabled. Assert that the reserved verbs and the schema CLI — `help`, `config`, `version`, `enable`, `disable`, `debug`, `perf`, `get`, `set`, `list`, `reset`, `resetall` — and the bare `/<slash>` all produce their **normal** output, because slash-commands-§2 **MUST**s that they keep answering. Assert that any verb the addon implements §2's feature-verb **SHOULD** for produces **exactly one line** matching *The refusal line* and reaches **no write seam**. An addon that declines that SHOULD asserts its feature verbs act normally instead; either is conformant, and the suite pins whichever this addon chose so the choice cannot drift silently. **This step is not the stand-down** — steps 1–6 are. A green step 7 says nothing about whether the addon is inert.

8. **The launcher.** Drive the LDB object's `OnClick` with `"LeftButton"` and assert **zero** SavedVariables writes and zero frame shows, and that one refusal line was printed; drive it with `"RightButton"` and assert the panel opener was called.
9. **Re-enable, and assert restoration from current state.** Write the enable path back to `true`; assert the registration set equals `R_on` again. Then repeat the disable/enable cycle with **one setting changed while disabled** and assert the rebuilt set reflects the new setting rather than the snapshot (performance-§6).
10. **The latch.** Take the `perf` hold; write `enabled = false`; release the `perf` hold; assert the addon is **still stood down** (registration set still empty). Then write `enabled = true` and assert it stands up. Repeat with the holds in the other order.

The suite **MUST** carry testing-§12's falsification comment on at least steps 3, 6 and 10 — the three negative assertions — naming the mutation that reddens each (`-- red under: drop the UnregisterAllEvents in StandDown`).

#### Adopting it

Every addon in the collection is **non-compliant with this section today**, all eleven of them, and that is the expected starting state rather than a sweep of surprises. The library seam landed **first**: this section's latch is `LibKa0s-Lifecycle-1.0` (library-stack's module table), which **ships from LibKa0s v1.40.0** (Lifecycle minor 1). **The adoption floor is LibKa0s v1.42.0**, not v1.40.0: v1.40.0's Slash minor 12 implemented v2.56.0's narrowed surface, v1.41.0's Slash minor 13 restored the v2.57.0 surface but still refused a reserved verb the host never registered, and **Slash minor 14 in v1.42.0** is the first dispatcher that answers slash-commands-§2 exactly. Both tags are released, so an addon's adoption is **overdue, not blocked**: re-vendor to v1.42.0 or later, route the stand-down through the latch, and ship the suite.

### 8. `lock` and `unlock` as verb aliases (MAY)

Ten of the eleven addons in the collection have a lock — a *Lock frame* checkbox in General → Master controls (options-ui-§15) — and **six of them** are on launcher rung (b), where **unlocking *is* the preview**: unticking *Lock frame* shows the display with its placeholder content, which is why those addons ship no separate *Test mode* row (options-ui-§15's exemption, preview-mode). Unlocking is therefore one of the two or three things a player actually does with those addons, and it is a checkbox three clicks deep in a settings panel. Seven of the ten already reach it from chat somehow, in **four different shapes**, because nothing said what the shape was.

- **An addon that has lock functionality at all MAY register `/<slash> lock` and `/<slash> unlock`** as verbs in its `COMMANDS` table (slash-commands-§3), each with a plain description in the help index.
- **Both verbs MUST write the same stored path, through the same single write seam, as the *Lock frame* checkbox** (options-ui-§1, architecture-§5). They carry the **same no-second-state rule `enable` / `disable` already carry** (slash-commands-§2): no second key, no session flag, no `NS.locked` local. The checkbox and the verbs can never show the player two different answers, because there is only ever one value, and one `onChange` runs whichever surface was used.
- **Where unlocking is the preview, the verbs drive that same switch** and never a copy of it — the preview follows from the stored lock exactly as it does when the checkbox is clicked (preview-mode, launcher-§2 rung (b)). An `unlock` verb that shows a preview by some other route is a second preview state to keep in step.
- **They are feature verbs, so slash-commands-§2's feature-verb SHOULD reaches them while the addon is disabled.** Unlocking a frame that is not drawn is not a coherent request, and the refusal line names `/<slash> enable`, which is the step the player actually needs; an addon that declines the SHOULD owes no register row.
- **SHOULD** confirm on one tagged line in slash-commands-§5's `set` shape, like `enable` / `disable`, so the player sees what changed.

**It is a MAY, and declining costs nothing.** An addon that ships the checkbox and no verbs is **not deviating and owes no row** in `docs/ARCHITECTURE.md` → *Documented deviations*. The register is for ratified departures from a MUST or a SHOULD; filing a declined MAY there would bury the real rows under noise. This is deliberately weaker than `enable` / `disable`, which are a **MUST** — the reason for the difference is that `enable` is the only way back from the disabled state, so its absence is a one-way switch, whereas a missing `unlock` costs three clicks.

**Against the shapes that exist today.** The collection already spells this five ways, and the rule is written to ratify the good ones rather than to churn them:

- **A full `lock` / `unlock` pair at top level** — Absorb Tracker, Aura Master, Panel Master, Party Frame Enhanced — is the canonical shape. Nothing changes for them beyond confirming the write goes through the one seam, and choosing whether they answer slash-commands-§2's feature-verb SHOULD while disabled.
- **A pair plus a toggle** — KickCD — is fine. The toggle **MAY** stay, it is not reserved, and it **MUST** write the same path through the same seam like the other two. Three verbs onto one stored boolean is still one state.
- **A pair under a sub-tree** — Consumable Master's `/cm bar lock` and `/cm bar unlock` — is fine as it stands, and the sub-tree form is the **whole** surface it owes. It **MAY** additionally carry top-level `/cm lock` and `/cm unlock` as aliases onto the sub-tree's act, **but only while the alias is unambiguous** — that is, while the addon has exactly one lockable frame. An addon with two lockable frames **MUST NOT** carry a bare top-level `lock`, because the verb would have to pick one of them silently, and a player who guesses wrong gets a frame they did not ask for moved out from under the mouse. Where the alias is ambiguous the sub-tree spelling is not a shortfall, it is the correct answer.
- **One verb with a boolean sub-verb** — Multi Meters' `/mm lock on|off`, with no `unlock` verb — is fine as it stands. It **MAY** gain a bare `/<slash> unlock` as an alias for `lock off`, and it **MUST NOT** be required to. **This MAY does not reach Multi Meters' ratified deviation and MUST NOT be read as invalidating it:** that row is about what `lock` **means** in that addon — its master-lock semantics — and this subsection is about which **verbs exist** and where they write. Adding an `unlock` alias would not change the semantics the row ratifies, and an auditor finding the row **MUST NOT** treat this section as superseding it. A ratified row is only unmade by the owner unmaking it.
- **A checkbox and no verbs** — Bank Ledger, Loot History, WhatGroup — is fine, and is the case the MAY exists to leave alone. They have lock functionality, so the option is open to them; taking it is a small convenience and declining it is not a finding.
- **No lock concept at all** — Pretty Chat — is **outside this subsection entirely**. An addon with nothing to lock **MUST NOT** invent a lockable frame, a stored lock path or a *Lock frame* row so that it can register the verbs. That inverts the rule: the verbs exist because the state does, and manufacturing state to satisfy an optional verb is how a chat-formatting addon acquires a movable frame nobody asked for.
