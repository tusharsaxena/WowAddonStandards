> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Slash commands

### 1. Registration

- **MUST** use AceConsole-3.0 `:RegisterChatCommand`. **MUST NOT** hand-roll `SLASH_*` globals.

```lua
addon:RegisterChatCommand("<slash>", "OnSlash")       -- 2-3 char primary verb
addon:RegisterChatCommand("<addonname>", "OnSlash")   -- full lowercase name alias
```

### 2. Verb naming

- **MUST** use 2-3 lowercase chars as the primary verb. **SHOULD** also register the full lowercase addon name as an alias.
- **MUST NOT** collide with existing well-known addon slashes.

### 3. Dispatch

- **MUST** be schema-driven. Built-in subcommands `get`, `set`, `list`, `reset`, `resetall` walk `NS.Schema`. Custom verbs live in an ordered table:

```lua
NS.COMMANDS = {
  { name = "get",     desc = "Get a setting value",   fn = function(arg) ... end },
  { name = "set",     desc = "Set a setting value",   fn = function(arg) ... end },
  { name = "list",    desc = "List all settings",     fn = function() ... end },
  { name = "reset",   desc = "Reset one setting",     fn = function(arg) ... end },
  { name = "resetall", desc = "Reset all to defaults", fn = function() ... end },
  { name = "config",  desc = "Open options panel",    fn = function() NS.Panel:Open() end },
  { name = "version", desc = "Print addon version",   fn = function() ... end },   -- prints `<tag> v<version>`
  { name = "preview", desc = "Toggle preview mode",   fn = function() ... end },   -- if preview-mode applies
  { name = "debug",   desc = "Window; 'on'/'off' set logging", fn = function(rest) ... end },  -- debug-logging (on|off|toggle)
}
```

- **MUST** render `/<slash>` (no args) as the help output, generated from this table — no hand-maintained help string. (Browser-first addons **MAY** map bare `/<slash>` to their main window instead — a documented deviation — but `/<slash> help` MUST still print the index; see slash-commands-§4.)
- **MUST** register a **`version`** verb that prints the addon's version on its own line — `/<slash> version` → `<tag> v<version>` (the `NS.PREFIX` tag, slash-commands-§4, followed by `v` and the version string). The help header (slash-commands-§4) already carries the version, but the standalone verb is the canonical, greppable single-line answer to "what version am I running?" that every Ka0s addon answers identically. Read the version from the TOC metadata (`GetAddOnMetadata(NS.name, "Version")`) with the in-code constant as fallback, so it can't drift from the packaged manifest.
- **MUST NOT** use `if arg == "foo" then elseif arg == "bar" then` chains.

### 4. Help output & chat tag

Reference implementations (in the collection): the modular tracker's `printHelp` and the loot-history browser's `settings/Slash.lua`.

- Every line the addon prints to chat **MUST** carry a short **bracketed tag** — the addon's initials in `[...]`, wrapped in **the cyan colour code** — exposed as a **single shared constant** (`NS.PREFIX`) so every module prints identically. Required format: `|cff00ffff[XY]|r` (initials `XY`, colour `00ffff` cyan). The **cyan colour is mandatory**, not merely an example: every Ka0s addon shares the same tag colour so a user running several recognises them at a glance. **MUST NOT** hand-write `"|cff…" .. addonName .. "|r"` per call site, and **MUST NOT** substitute a different colour.
- The printer **MUST** be **secret-safe** (events-frames-taint-§8): build each line from the secret-safe stringifier, not raw `tostring` / `..` / `table.concat`, so a combat-protected value logs as `<secret>` instead of raising. A printer that concatenates raw args crashes the moment it is handed a combat "secret" value.
- **Guard the printer against AceConsole's `:Print` mixin.** If the addon embeds AceConsole-3.0 into the same table that exposes the custom printer (`NewAddon(NS, …)` with the printer at `NS.Print`), AceConsole's embedded `:Print` **overwrites** it and every line prints as `|cff33ff99<msg>|r:` (green, trailing colon, no cyan tag) — silently breaking the prefix rule above. The **MUST** rule and its two fixes are in **architecture-§2** (see also anti-pattern #36).
- The `help` index (and the fallback for an unknown verb) **MUST** be generated from `NS.COMMANDS`:
  - **Header:** `<tag> v<version> slash commands (/<alias> is an alias for /<slash>)`
  - **One row per command:** `<tag> |cffffff00/<slash> <name>|r — |cffffffff<desc>|r` — gold command, em-dash (`—`), white description.
- An **unknown verb MUST** print `unknown command '<verb>'` and then the help index — never silently no-op.
- Dispatch **MUST** lower-case only the verb and preserve case in the remainder, so schema paths survive `/<slash> set <path> <value>`.
- **No trailing colon (house style).** **No** chat line the addon prints — help header, command rows, `list`/`get`/`set` output (slash-commands-§5), profile sub-headers, or any other — **MUST** end in a trailing `:`. Introduce a list with the header text alone; the following indented rows already read as its members.

```lua
function Sl:PrintHelp()
  print(NS.PREFIX .. " v" .. NS.version ..
    " slash commands (|cffffff00/<alias>|r is an alias for |cffffff00/<slash>|r)")
  for _, cmd in ipairs(NS.COMMANDS) do
    print(NS.PREFIX .. (" |cffffff00/<slash> %s|r — |cffffffff%s|r"):format(cmd.name, cmd.desc))
  end
end
```

### 5. Settings read/write output format

`list`, `get`, and `set` share one canonical output shape so every Ka0s addon reads identically in chat. Every line carries `NS.PREFIX` (slash-commands-§4).

- **`list`** **MUST** print a header, then one **`[page]` group header** per schema page (in a stable, declared page order), then one indented **`path = value`** row per setting under that page (colour codes shown stripped for legibility — see the colour scheme below):

  ```
  [PFX] Available settings
  [PFX]   [general]
  [PFX]     enabled = true
  [PFX]     scale = 1.00x
  [PFX]   [icons]
  [PFX]     icons.primarySize = 64 px
  [PFX]     icons.anchor = RIGHT_MIDDLE
  ```

  - Header line: `Available settings`.
  - Group header: **two-space** indent, page key in `[...]`.
  - Value row: **four-space** indent, the **full schema path** on the left (nested paths dotted, e.g. `icons.primarySize`), then ` = `, then the formatted value.
- **Colour scheme (MUST).** Every Ka0s addon prints schema output in **one shared colour scheme** so the surface reads identically across the collection (the same house-style intent as the mandated cyan chat tag, slash-commands-§4). No line **MUST** carry a **trailing colon**.

  | Element | Colour | Code |
  | --- | --- | --- |
  | `Available settings` header | green | `\|cff33ff99…\|r` |
  | `[page]` group header (brackets included) | azure | `\|cff3399ff…\|r` |
  | setting key / schema path | gold | `\|cffffff00…\|r` |
  | value | white | `\|cffffffff…\|r` |

  The ` = ` separator stays default (uncoloured). The `NS.PREFIX` tag keeps its mandated cyan (slash-commands-§4). These four colours are **mandatory, not merely examples** — **MUST NOT** substitute other colours or add a trailing colon.
- **`get <path>`** and **`set <path> <value>`** **MUST** print the **single-line** `path = value` form (no header, no indent) — using the **same gold-key / white-value colouring** as the `list` value rows, produced by the same shared `key = value` formatter (below). A `set` **MUST** read back the *stored* value after writing, so the echo reflects any clamping/coercion.
- **Value formatting MUST be type-aware, unit-annotated, and schema-driven** (never hand-formatted per call site):
  - pixel / size numbers → `<n> px` (e.g. `64 px`)
  - scale → `<n.nn>x` (e.g. `1.00x`); plain ratios / alphas → two decimals (e.g. `0.50`, `1.00`)
  - booleans → `true` / `false`
  - colours → `{r, g, b, a}`, two decimals each (e.g. `{1.00, 0.13, 0.13, 1.00}`)
  - enums / strings → the raw token or display string (e.g. `RIGHT_MIDDLE`, `Bui Prototype`)
- A **single shared value formatter** (e.g. `NS.FormatSchemaValue(row, v)`) **MUST** produce these value strings for both `list` and `get`/`set`, so the two paths can never diverge. Likewise the coloured **`key = value` line** (gold key + white value) **MUST** come from **one shared helper** (e.g. `FormatKV(path, valueStr)`) reused by the `list` rows and the `get`/`set` echo, so the colouring can never drift between them.
- Unknown path → `Setting not found: <path>`; a missing / empty argument → a `Usage: …` line.

Reference implementation: the modular tracker's `listSettings` / `getSetting` / `setSetting` in `settings/Slash.lua`.
