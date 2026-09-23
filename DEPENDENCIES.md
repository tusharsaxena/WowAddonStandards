# DEPENDENCIES.md — Ka0s WoW Addon Standard

The toolchain contract for **this** repository (documentation-§7).

> **Read this first.** This is a **documentation-and-tooling repo** (`documentation-§8`), so
> `documentation-§7` binds but is read for that repo kind: a short **required** list and an explicit
> **not used here** list with reasons. §8 says outright that a repo needing almost nothing records
> that fact and **MUST NOT** invent entries to fill the addon-shaped shape — §7's evidence-based MUST
> already forbids it, and a padded list here would be the first thing to go stale. An absent row and
> a "not used here" row read identically to a human and differently to an auditor, which is why the
> second list exists. §7's *Runtime (in-game)* group has no instance and is omitted rather than
> answered.
>
> The repo is 67 tracked files: 63 Markdown plus `LICENSE`, `.gitattributes` and two logo images. No
> line of it reaches the WoW client.

## The short version

Clone it and open a Markdown editor. There is no build, no interpreter, no linter, no test runner and
no release step in this repository.

```sh
git clone https://github.com/tusharsaxena/WowAddonStandards.git
cd WowAddonStandards
```

## Required

| Software | Why this repo needs it | Install (WSL2 / Ubuntu) | Verify |
|---|---|---|---|
| **git** ≥ 2.34 | The only hard requirement. It carries the content, and `.gitattributes` carries the line-ending pin this repo is checked against — `git check-attr` is the one command below that reads it correctly. | `sudo apt update && sudo apt install -y git` | `git --version` |

That is the whole list.

## Not used here, and why

Each of these is required by the standard **of an addon**, and each is genuinely absent here. They
are listed so a reader who arrived from an addon's `DEPENDENCIES.md` can tell "not installed" from
"not applicable".

| Software | Status | Why |
|---|---|---|
| **Lua 5.1** | **not used here** | No Lua source and no `tests/` harness. Nothing in this repo executes. |
| **luacheck** | **not used here** | Lint needs Lua to lint. There is no `.luacheckrc`. |
| **lizard** | **not used here** | Cyclomatic complexity over zero functions is not a measurement. |
| **A WoW client** | **not used here** | Nothing here loads as an addon; there is no `.toc` and no smoke-test suite. |
| **packager / release tooling** | **not used here** | There is no `.pkgmeta` and no artifact to publish. The standard is consumed from `master` by the plugin at runtime, not released. |

## Consumers, which is where the real toolchain lives

This repo is **read at runtime** by the [`wow-addon`](https://github.com/tusharsaxena/wow-addon)
Claude Code plugin. The four root playbooks — `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`,
`PERF_ANALYSIS.md` — are fetched over HTTPS by the plugin's skills and executed **inside an addon's
own repo**, never here. So:

- The tools those playbooks name (Lua, luacheck, lizard) must be installed **in the addon repo you
  are running the command from**, and that repo's own `DEPENDENCIES.md` is the contract for them.
- Editing a playbook here changes what every addon does on its next run. There is no local way to
  execute one; the verification is the next run in a real addon repo.

## Verifying your setup

There is no test suite to run. The one mechanical property this repo is held to is its line endings
(line-endings-§2/§5): this is the **non-client canonical body**, pinned to **LF**, unlike the addons,
which are pinned to CRLF.

```sh
# what the repo declares for a path — the authoritative answer, and it works on an untracked file
git check-attr text eol -- README.md

# nothing tracked should be carrying a CR
git grep -Il $'\r' -- . ; echo "exit $? (1 = clean)"
```

If the second command prints a path, that file has CRLF against an LF pin — fix the terminator, not
the `.gitattributes`.

## Related

- **`CLAUDE.md`** — what this repo is, its layout, and how to change the standard.
- **`standards/STANDARDS.md`** — the standard's index and its section files.
- **`docs/ARCHITECTURE.md`** — how this repo is put together, in the five sections `documentation-§8`
  mandates for a repo of this kind.
