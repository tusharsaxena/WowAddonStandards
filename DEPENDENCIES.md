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
> The repo is Markdown, plus `LICENSE`, `.gitattributes`, the logo images and one shell script,
> `scripts/check-standard.sh`, the on-demand check of the standard's own invariants. No line of it
> reaches the WoW client.

## The short version

Clone it and open a Markdown editor. There is no build, no interpreter, no linter, no test suite and
no release step in this repository. There is one on-demand check script, run before committing a
change to the standard.

```sh
git clone https://github.com/tusharsaxena/WowAddonStandards.git
cd WowAddonStandards
bash scripts/check-standard.sh
```

## Required

| Software | Why this repo needs it | Install (WSL2 / Ubuntu) | Verify |
|---|---|---|---|
| **git** ≥ 2.34 | It carries the content, and `.gitattributes` carries the line-ending pin this repo is checked against — `git check-attr` is the one command below that reads it correctly. `scripts/check-standard.sh` reads the tracked set through `git ls-files` and `git grep`. | `sudo apt update && sudo apt install -y git` | `git --version` |
| **bash** ≥ 4 | Runs `scripts/check-standard.sh` (arrays, `<<<` here-strings, `<( )` process substitution). | preinstalled on Ubuntu; else `sudo apt install -y bash` | `bash --version` |
| **coreutils, GNU grep, awk, diff** | The script's text tools: `grep -E -o -n -H`, `awk` (any POSIX awk; `mawk` and `gawk` both work), `diff`, `sed`, `sort`, `wc`, `tr`, `xargs`. | preinstalled on Ubuntu; else `sudo apt install -y coreutils grep gawk diffutils findutils sed` | `grep --version; awk -W version 2>/dev/null \|\| awk --version; diff --version` |

That is the whole list. You can edit the standard with git alone; the other two rows are what the
check script needs.

## Not used here, and why

Each of these is required by the standard **of an addon**, and each is genuinely absent here. They
are listed so a reader who arrived from an addon's `DEPENDENCIES.md` can tell "not installed" from
"not applicable".

| Software | Status | Why |
|---|---|---|
| **Lua 5.1** | **not used here** | No Lua source and no `tests/` harness. The one executable file is a shell script (see *How the check script is verified*, below). |
| **luacheck** | **not used here** | Lint needs Lua to lint. There is no `.luacheckrc`. |
| **lizard** | **not used here** | Cyclomatic complexity over zero functions is not a measurement. |
| **A WoW client** | **not used here** | Nothing here loads as an addon; there is no `.toc` and no smoke-test suite. |
| **packager / release tooling** | **not used here** | There is no `.pkgmeta` and no artifact to publish. The standard is consumed from `master` by the plugin at runtime, not released. |

## Consumers, which is where the real toolchain lives

This repo is **read at runtime** by the [`dev-copilot`](https://github.com/tusharsaxena/dev-copilot)
Claude Code plugin. The four root playbooks — `AUDIT.md`, `AUTOMATED_TESTS.md`, `NEW_ADDON.md`,
`PERF_ANALYSIS.md` — are fetched over HTTPS by the plugin's skills and executed **inside an addon's
own repo**, never here. So:

- The tools those playbooks name (Lua, luacheck, lizard) must be installed **in the addon repo you
  are running the command from**, and that repo's own `DEPENDENCIES.md` is the contract for them.
- Editing a playbook here changes what every addon does on its next run. There is no local way to
  execute one; the verification is the next run in a real addon repo.

## Verifying your setup

There is no test suite. There is one check script, and it exits `0` on a healthy tree:

```sh
bash scripts/check-standard.sh; echo "exit $?"   # 0 = every check passed
```

It runs seven mechanically decidable checks and prints `ok` or `FAIL <check>: <detail>` for each:
`cr-bytes` (no tracked file carries a CR), `gitattributes` (`.gitattributes` is line-endings-§5's LF
body byte for byte), `citations` (every `filename-§N` in a live doc names a real section file and an
existing `### N.` heading, none targets an unnumbered file, none is malformed), `sections` (the
`STANDARDS.md` Sections list names exactly the tracked section files), `anti-patterns` (numbered
#1–#N with no gap, and the index blurb agrees), `version-stamps` (the `STANDARDS.md` title version and
date are restated in `README.md` Status, `EXECUTIVE_SUMMARY.md`, `NEW_ADDON_CONTEXT.md` line 1 and
`CLAUDE.md`'s "As of" line) and `links` (every relative `.md` link in a live doc resolves). The frozen
stores (`harvests/`, `standards/_raw/`, `docs/audits/`, `docs/reviews/`) and `standards/CHANGELOG.md`
are history and are skipped by the citation and link checks. Run it before committing a change to
the standard. It is **not** a commit hook, on purpose: see `CLAUDE.md`, *The two checkpoints*.

The line endings can also be checked by hand (line-endings-§2/§5). This is the **non-client
canonical body**, pinned to **LF**, unlike the addons, which are pinned to CRLF:

```sh
# what the repo declares for a path — the authoritative answer, and it works on an untracked file
git check-attr text eol -- README.md

# nothing tracked should be carrying a CR
git grep -Il $'\r' -- . ; echo "exit $? (1 = clean)"
```

If the second command prints a path, that file has CRLF against an LF pin — fix the terminator, not
the `.gitattributes`.

### How the check script is verified

documentation-§8 requires a documentation-and-tooling repo to record here how any non-Lua executable
content is verified; a shell script does not pull in `lint`, `testing` or `automated-tests`. The
standard mandates no shell linter, so `scripts/check-standard.sh` is verified this way:

- **Clean tree:** `bash scripts/check-standard.sh` exits `0` on `master`.
- **Injected defects:** in a throwaway clone (`git clone . /tmp/ws`, never in this working tree),
  one defect per check must turn it red with the check named: a CR in a tracked `.md`
  (`cr-bytes`), the `*.py text eol=lf` line dropped from `.gitattributes` (`gitattributes`),
  a citation numbered past `toc-file`'s last section and a numbered citation against the unnumbered
  `compat`, both written into a live doc (`citations`; spelled out here they would redden this file), a Sections link removed
  (`sections`), an anti-pattern renumbered (`anti-patterns`), the `README.md` Status version changed
  (`version-stamps`), and a link to a missing `.md` (`links`). Repeat this when the script changes.
- **Syntax and line endings:** `bash -n scripts/check-standard.sh` is silent,
  `git check-attr eol -- scripts/check-standard.sh` reads `lf` (the `*.sh` carve-out,
  line-endings-§3), and the file is executable.

## Related

- **`CLAUDE.md`** — what this repo is, its layout, and how to change the standard.
- **`standards/STANDARDS.md`** — the standard's index and its section files.
- **`docs/ARCHITECTURE.md`** — how this repo is put together, in the five sections `documentation-§8`
  mandates for a repo of this kind.
