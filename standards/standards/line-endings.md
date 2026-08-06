> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Line endings (`.gitattributes`)

Until this section existed, the standard mandated the **exception** and never the **rule**.
automated-tests-§2 required a repo to carve shell scripts out of *"a CRLF-pinned repo"* — a sentence
that presumes a pin no section anywhere states, and that a repo satisfies by not pinning at all.
`PanelMaster` is what that reads like in practice: a five-line `.gitattributes` containing the `*.sh`
carve-out and nothing else, and **111 of its 185 tracked text files** sitting LF in the working tree
against the collection's evident intent. Meanwhile eight repos — `LibKa0s`, `AbsorbTracker`,
`BankLedger`, `ConsumableMaster`, `KickCD`, `LootHistory`, `WhatGroup`, `prettychat` — had each
hand-written the same policy into files of **34, 36, 34, 35, 22, 31, 68 and 30 lines**, and the two
repos that ship the standard and the tooling — `WowAddonStandards` and `wow-addon` — had **no
`.gitattributes` at all**.

This section states the rule first and the exception second, fixes one canonical file body per repo
kind so a repo can be **diffed** against the standard rather than read against it, and specifies the
remediation, because adopting the file is only half of it.

**This is not cosmetic, and each failure it prevents has already happened somewhere.** A
`#!/usr/bin/env bash` shebang followed by CRLF makes the kernel look for an interpreter literally
named `bash\r`, so the vendored `tests/_kit/run-automated-tests.sh` does not run — for everyone, on
every checkout, with an error that names the wrong thing. A whole-file line-ending flip buries a
one-line real change inside a diff of every line in the file; across a repo it is a
**27,000-line diff** in which review is not merely hard but impossible, so it gets approved unread.
And a vendored-copy `diff -r` gate (testing-§11) goes red for a difference that is not a difference,
which trains its readers to ignore the one gate that exists to catch a real drift.

### 1. Every repo carries an explicit `.gitattributes` (MUST)

- Every repo in this collection — addon, library, standards, plugin — **MUST** carry a
  `.gitattributes` at its **root**, committed.
- **The absent file is the defect, not a neutral default.** With no attributes, what lands on disk is
  decided by whichever `core.autocrlf` / `core.eol` the contributor's git happens to carry, which
  differs per machine and is invisible to everyone but its owner. Two contributors then produce
  byte-different checkouts of the same commit and neither is doing anything wrong, so there is no
  conversation in which the disagreement surfaces.
- A file carrying **only exceptions** — the `*.sh` carve-out with no pin above it — **MUST NOT** be
  treated as satisfying this. It reads as a policy and is not one; it is the state that produced 111
  disagreeing files in `PanelMaster` while looking, in review, like the repo had been handled.
- **`.gitattributes` is a development artifact and MUST NOT ship to players** — it is listed in the
  `.pkgmeta` `ignore:` block for the same reason `.gitignore` and `.luacheckrc` are (`packaging`).

### 2. Two repo kinds, two pins (MUST)

- A repo that **ships Lua to the WoW client** — directly as an addon, or vendored into an addon's
  client-bound `libs/` folder — **MUST** pin CRLF:

  ```gitattributes
  * text=auto eol=crlf
  ```

  That is the eight addon repos (`AbsorbTracker`, `BankLedger`, `ConsumableMaster`, `KickCD`,
  `LootHistory`, `PanelMaster`, `WhatGroup`, `prettychat`) plus `LibKa0s`, whose ship folder lands
  in every one of their `libs/` trees. The client expects CRLF in addon source, and a Linux or macOS
  contributor on `core.autocrlf=input` would otherwise check out LF without noticing.

- A repo that **ships nothing to the WoW client** **MUST** pin LF:

  ```gitattributes
  * text=auto eol=lf
  ```

  That is `WowAddonStandards` and `wow-addon`. CRLF exists in this collection for exactly one reason
  — the client — and where the client is not involved the reason does not apply. These two are
  consumed by git, GitHub's renderer and shell tooling, all of which are LF-native.

- **The discriminator is mechanical**, and it is the one `AUDIT.md` step 1 already uses to switch
  rule sets: a repo with a `.toc`, or with a client-bound `libs/` folder it ships, takes CRLF; a repo
  with neither takes LF.
- `text=auto` **MUST** be kept on the pin line. It lets git classify text against binary by content
  at add time; text is stored **LF in the repository** either way, so diffs, blame and GitHub stay
  clean, and the `eol=` half governs only what lands on disk.
- A repo **MUST NOT** carry per-path pins that contradict the repo pin — `libs/** -text`,
  `tests/_kit/** -text`, or a single `docs/<file>.md text eol=crlf`. `LootHistory` carried all three
  and is the 68-line, 102-straggler outlier because of them. A per-path exemption asserts that one
  tree is exempt from the repo's own representation, which is exactly the claim testing-§11's gates
  are written to be able to make for themselves.

### 3. `*.sh` is LF in both kinds (MUST)

- Both variants **MUST** carry:

  ```gitattributes
  *.sh text eol=lf
  ```

  **including the LF-pinned repos**, where it is redundant. It is mandatory there anyway because the
  line is the thing a reader looks for, and a rule you can satisfy by omission is one that gets
  omitted the day someone changes the pin above it.
- The reason is unconditional: `#!/usr/bin/env bash` followed by CRLF makes the kernel look for an
  interpreter literally named `bash\r`, and every `case`/`in` line becomes a syntax error. The file
  this protects in a client-bound repo is the vendored `tests/_kit/run-automated-tests.sh`
  (automated-tests-§2); in `wow-addon` it is `scripts/normalize-crlf.sh`, the hook the plugin runs on
  every `Write`/`Edit`.
- The failure is uniform rather than intermittent — the script is broken on **every** checkout, not
  in one contributor's tree — which is why it reads as *"the script is wrong"* and sends the reader
  to the wrong repo.

### 4. Binary types are marked `binary` (MUST)

- Every binary type **MUST** be marked `binary`, so git never line-end converts it and never tries to
  diff it as text.
- `text=auto` usually detects these, but detection is **content-based**: a truncated asset, or one
  whose format is plain ASCII, can be classified as text and then rewritten. The live example is
  `PanelMaster/tools/artwork/bin/models/realesrgan-x4plus-anime.param` — ncnn's `.param` format is
  ASCII, so a CRLF pin would rewrite a model definition that sits beside its own weights. Marking is
  cheap; the class of bug it removes is not.
- The canonical list in §5 is the **union** of every binary type present anywhere in the collection
  (`.tga` — 109 files, the largest binary population — `.png`, `.ttf`, `.jpg`, `.jpeg`, `.gif`,
  `.bin`, `.param`) plus the WoW media types an addon may acquire at any time (`.blp`, `.ogg`,
  `.mp3`, `.wav`, `.otf`) and the archive types (`.zip`, `.tar`, `.gz`, `.7z`, `.pdf`). A stale entry
  costs nothing; a missing one costs a corrupted asset, so the list is deliberately ahead of the
  census and **MUST NOT** be trimmed to what a given repo happens to hold today.

### 5. The canonical file bodies (MUST)

A repo's `.gitattributes` **MUST** be one of these two files, byte-for-byte. They differ in **one
decision**: the pin, the paragraph above it declaring which kind of repo this is, and the two
word-level consequences of that inside the same paragraph and the closing verification line.
Everything else — the `*.sh` block, the binary block, the renormalization recipe — is identical, so
diffing a client-bound repo against a non-client one shows one decision rather than two documents.

Fixing the body is what makes this section **checkable**: an auditor diffs rather than reads, and the
eight hand-written 22-to-68-line variants that existed before it stop being eight things to keep in
sync.

**Client-bound repos** — the eight addons and `LibKa0s`:

```gitattributes
# =============================================================================
# Ka0s WoW Addon Standard — line-ending policy (line-endings-§2)
#
# Every repo in the Ka0s collection carries an explicit .gitattributes. There
# are exactly two variants of this file and they differ in one decision only:
# the pin below. Everything after it is byte-identical across the collection,
# so diffing a client-bound repo against a non-client one shows one decision,
# not two documents.
#
# Having no .gitattributes — or one that lists only exceptions to a rule that
# was never stated — is itself the defect. It leaves what lands on disk at the
# mercy of each contributor's `core.autocrlf` / `core.eol`.
# =============================================================================

# THIS REPO IS CLIENT-BOUND. It ships Lua into the WoW client, either directly
# as an addon or vendored into an addon's libs/ folder. The client expects
# CRLF in addon source, so the working tree is pinned CRLF on every platform.
#
# `text=auto` lets git classify text vs binary by content at add time. Text is
# always stored LF in the repository, so diffs and blame stay clean; `eol=crlf`
# pins what lands on disk at checkout and converts back on add. Because
# .gitattributes overrides per-user config, a Linux contributor on
# `core.autocrlf=input` and a Windows contributor on `true` end up with
# identical bytes, and LF stragglers written by tools that bypass git's filters
# (sed, WSL editors, generators) are corrected the moment they are staged.
* text=auto eol=crlf

# Shell scripts are LF, ALWAYS — even in a CRLF-pinned repo, where everything
# else is CRLF. `#!/usr/bin/env bash` followed by CRLF makes the kernel look for
# an interpreter literally named "bash\r", and every `case`/`in` line becomes a
# syntax error. The vendored tests/_kit/run-automated-tests.sh is the file this
# protects (automated-tests-§2); without this carve-out the runner is broken on
# every checkout rather than in one contributor's working tree.
*.sh text eol=lf

# Binaries — never line-end converted, never diffed as text. `text=auto` would
# usually detect these, but detection is content-based and a truncated or
# odd-header asset can fool it; marking them is cheap and removes the class of
# bug entirely. The list is the union of every binary type present anywhere in
# the collection plus the WoW media types an addon may add at any time.
#
# Images and textures
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.bmp binary
*.ico binary
*.tga binary
*.blp binary
# Fonts
*.ttf binary
*.otf binary
# Audio
*.mp3 binary
*.ogg binary
*.wav binary
# Archives and opaque data (model weights, tool payloads)
*.zip binary
*.tar binary
*.gz binary
*.7z binary
*.pdf binary
*.bin binary
*.param binary

# Renormalizing after this file is added or changed. The attributes only take
# effect for content as it passes through git, so an existing checkout must be
# rewritten once, in this order:
#
#   git add .gitattributes
#   git add --renormalize .
#   git status                 # review, then commit
#
# `--renormalize` rewrites the INDEX; it does not rewrite files already on
# disk. To fix a straggler in the WORKING TREE, delete it and check it out
# again (`rm <path> && git checkout -- <path>`), then confirm with
# `file <path>` — "CRLF line terminators" is the expected answer here.
```

**Non-client repos** — `WowAddonStandards` and `wow-addon`:

```gitattributes
# =============================================================================
# Ka0s WoW Addon Standard — line-ending policy (line-endings-§2)
#
# Every repo in the Ka0s collection carries an explicit .gitattributes. There
# are exactly two variants of this file and they differ in one decision only:
# the pin below. Everything after it is byte-identical across the collection,
# so diffing a client-bound repo against a non-client one shows one decision,
# not two documents.
#
# Having no .gitattributes — or one that lists only exceptions to a rule that
# was never stated — is itself the defect. It leaves what lands on disk at the
# mercy of each contributor's `core.autocrlf` / `core.eol`.
# =============================================================================

# THIS REPO IS NOT CLIENT-BOUND. It ships nothing into the WoW client; its
# consumers are git, GitHub and tooling. CRLF exists in this collection for
# exactly one reason — the client — and that reason does not apply here, so the
# working tree is pinned LF on every platform.
#
# `text=auto` lets git classify text vs binary by content at add time. Text is
# always stored LF in the repository, so diffs and blame stay clean; `eol=lf`
# pins what lands on disk at checkout and converts back on add. Because
# .gitattributes overrides per-user config, a Linux contributor on
# `core.autocrlf=input` and a Windows contributor on `true` end up with
# identical bytes, and CRLF stragglers written by tools that bypass git's
# filters (Windows editors, generators) are corrected the moment they are
# staged.
* text=auto eol=lf

# Shell scripts are LF, ALWAYS — even in a CRLF-pinned repo, where everything
# else is CRLF. `#!/usr/bin/env bash` followed by CRLF makes the kernel look for
# an interpreter literally named "bash\r", and every `case`/`in` line becomes a
# syntax error. The vendored tests/_kit/run-automated-tests.sh is the file this
# protects (automated-tests-§2); without this carve-out the runner is broken on
# every checkout rather than in one contributor's working tree.
*.sh text eol=lf

# Binaries — never line-end converted, never diffed as text. `text=auto` would
# usually detect these, but detection is content-based and a truncated or
# odd-header asset can fool it; marking them is cheap and removes the class of
# bug entirely. The list is the union of every binary type present anywhere in
# the collection plus the WoW media types an addon may add at any time.
#
# Images and textures
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.bmp binary
*.ico binary
*.tga binary
*.blp binary
# Fonts
*.ttf binary
*.otf binary
# Audio
*.mp3 binary
*.ogg binary
*.wav binary
# Archives and opaque data (model weights, tool payloads)
*.zip binary
*.tar binary
*.gz binary
*.7z binary
*.pdf binary
*.bin binary
*.param binary

# Renormalizing after this file is added or changed. The attributes only take
# effect for content as it passes through git, so an existing checkout must be
# rewritten once, in this order:
#
#   git add .gitattributes
#   git add --renormalize .
#   git status                 # review, then commit
#
# `--renormalize` rewrites the INDEX; it does not rewrite files already on
# disk. To fix a straggler in the WORKING TREE, delete it and check it out
# again (`rm <path> && git checkout -- <path>`), then confirm with
# `file <path>` — no "CRLF line terminators" in the output is the expected
# answer here.
```

### 6. Adopting or changing the pin: the index is not the working tree (MUST)

Attributes take effect only on content **as it passes through git**, so adding this file to a repo
that already has a checkout does nothing on its own. Remediation is two steps, and the second one is
the one that gets skipped.

**Step 1 — fix the INDEX:**

```sh
git add .gitattributes
git add --renormalize .
git status                 # review, then commit
```

**Step 2 — fix the WORKING TREE.** `--renormalize` rewrites what git has recorded; it does **not**
rewrite bytes already on disk. A file written by a tool that bypassed git's filters — `sed`, a Python
generator, a WSL editor, a shell redirect — stays LF on disk in a CRLF-pinned repo, and git says so
every time it is touched:

```
warning: in the working copy of 'core/Namespace.lua', LF will be replaced by CRLF the next time Git touches it
```

- That warning **MUST** be read as an unfinished remediation, not as noise. It is the symptom a
  maintainer actually sees, it is emitted on **every** subsequent `git add`, and because it is a
  warning rather than an error the usual response is to stop reading it — after which the repo has a
  policy, a clean `git status`, and a working tree that disagrees with both.
- **What clears it** is replacing the on-disk copy from the index, per file:

  ```sh
  rm <path> && git checkout -- <path>
  file <path>                # "CRLF line terminators" in a CRLF repo; absent in an LF repo
  ```

- The whole-tree form is `git rm --cached -r . && git reset --hard`. It **MUST NOT** be used with
  uncommitted work in the tree, and a per-file re-checkout is the SHOULD for that reason.
- A repo **MUST** end the change with `git add --renormalize .` producing **no** staged changes and
  no warning, which is the only statement that covers the index and the tree at once.
- The adoption commit **SHOULD** be the whole-repo renormalization **and nothing else**. That diff is
  every line of every straggler; anything real committed alongside it is unreviewable, which is the
  27,000-line problem stated at the top of this section, self-inflicted.

### 7. Checking it (MUST)

An audit **MUST** check all four properties mechanically and **MUST** report working-tree strays as
**one** rolled-up finding carrying the command that produced the count — never a file-by-file
enumeration, which inflates the tally for what is a single `--renormalize` sweep (documentation-§6
applies the same rolled-up rule to citation sweeps).

```sh
# (a) present at root, and (b)/(c)/(d) the pin, the carve-out and the binaries
test -f .gitattributes && grep -nE '^\* text=auto eol=(crlf|lf)$|^\*\.sh text eol=lf$|binary$' .gitattributes

# (e) does the WORKING TREE agree with the declared pin? — one number, not a list
git ls-files -z | xargs -0 -I{} sh -c '
  a=$(git check-attr eol -- "{}" | sed "s/.*: //")
  case "$a" in crlf) file "{}" | grep -q CRLF || echo "{}";;
               lf)   file "{}" | grep -q CRLF && echo "{}";; esac' 2>/dev/null | wc -l
```

- A count of `0` is the compliant state. Anything else is **one** finding: *"N tracked files disagree
  with the declared pin"*, with the command above quoted so the next reader can reproduce the number
  rather than trust it.
- Grade by **impact**, per `AUDIT.md` step 5: this is a config-and-repo-hygiene failure, so it is
  **Low** or **Info** even though every rule in this section is a MUST — and the entry **MUST** still
  name the MUST it fails.
