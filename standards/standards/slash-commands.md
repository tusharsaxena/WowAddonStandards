> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Slash commands

Every Ka0s addon answers `/<slash>` the same way: the same help block, the same `list` / `get` / `set` shape, the same colors, the same reserved verbs meaning the same things. That uniformity is the point — a user running six of these addons learns one command surface, and a maintainer reading a bug report knows exactly what the pasted line came from. Uniformity written as prose drifts; uniformity carried by **one shared implementation** cannot. The dispatcher, the help renderer, the row and key/value formatters, the list builder and the type-aware value parser are therefore a Ka0s-owned library, and this section is mostly about what the addon hands it and what stays the addon's own.

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
- **Reserved sub-verbs.** `help`, `get`, `set`, `list`, `reset`, `resetall`, `config`, `version`, `debug` and **`perf`** are reserved across the collection and **MUST** mean the same thing in every addon (slash-commands-§3). `perf` is the guided performance capture (performance-§4): it **MUST NOT** be re-used for anything else, and — although the run itself is implemented by a vendored library — the verb **MUST** be registered by the addon through its own `COMMANDS` table, never by the library. **Reserved always; registered when wired.** An addon holding a recorded no-combat-path exemption (performance-§12) does not register `perf` — there is no instance to dispatch into — but the verb stays reserved there exactly as it is everywhere else, so it can never be given a second meaning in one addon, and so re-arming the harness later is a registration rather than a rename.
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
- **MUST** render `/<slash>` (no args) as the help output, generated from `COMMANDS` — no hand-maintained help string. (Browser-first addons **MAY** map bare `/<slash>` to their main window instead — a documented deviation — but `/<slash> help` MUST still print the index; see slash-commands-§4.)
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
- **Annotations are the host's.** Where a rendered value needs a caveat the library cannot know — that a setting is currently overridden, mirrored, or inert — the addon **SHOULD** supply a row annotator rather than reformatting the line. The library decides only **where** an annotation may appear: after the colored pair, on `list` / `get` / `set`, and **never** on `reset` or `resetall`, where an explanation of what a value means is noise stapled to an acknowledgement that the value went away.

### 6. Value parsing

Parsing typed input is **the library's**, and an addon **MUST NOT** re-implement it. The behavior below is the collection's contract, not an implementation note — a user learns it once.

- **bool** accepts `true` / `false`, `on` / `off`, `1` / `0`, `yes` / `no` (case-insensitive). Anything else fails.
- **number** is read with `tonumber`, then **clamped** to the row's `min` / `max`. Out of range **clamps rather than fails**, because a user typing a width larger than the panel allows means *"as wide as it goes"* — and the echo of the stored value then shows them what they actually got.
- **string** **MUST** match one of the row's declared allowed values, and **fails** otherwise. There is no charitable reading of a misspelt texture name, so an enum is validated where a number is clamped. Allowed values are resolved **at call time**, since a media list is populated by another addon and is not knowable when the row is declared.
- **color** takes `r g b [a]`, and rescales by 255 **jointly** when any of r/g/b exceeds 1 — `255 128 0` is one color expressed in one scale, and dividing only the components that happen to exceed 1 would mangle the rest. Alpha rescales independently and defaults to 1. All components clamp to 0–1.
- A failure prints `Invalid value for <path>` followed by an indented reason. **MUST NOT** silently store a value the addon cannot honor: a CLI that accepts what it will not apply is worse than one that refuses.
- An addon with a genuinely exotic row type **MAY** supply its own parser through the descriptor's `parse` field, which keeps the override at the one seam instead of forking the dispatcher (anti-patterns #47).

Reference implementation: Absorb Tracker's `settings/Slash.lua`.
