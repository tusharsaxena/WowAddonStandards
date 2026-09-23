> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Line endings (`.gitattributes`)

Until this section existed, the standard mandated the **exception** and never the **rule**.
automated-tests-§2 required a repo to carve shell scripts out of *"a CRLF-pinned repo"* — a sentence
that presumes a pin no section anywhere states, and that a repo satisfies by not pinning at all.
The originating sweep measured what that produces. `PanelMaster` was what it reads like in practice:
a five-line `.gitattributes` containing the `*.sh` carve-out and nothing else, and **111 of its 185
tracked text files** sitting LF in the working tree against the collection's evident intent.
Meanwhile eight repos — `LibKa0s`, `AbsorbTracker`, `BankLedger`, `ConsumableMaster`, `KickCD`,
`LootHistory`, `WhatGroup`, `prettychat` — had each hand-written the same policy into files of
**34, 36, 34, 35, 22, 31, 68 and 30 lines**, and the two repos that ship the standard and the
tooling — `WowAddonStandards` and `wow-addon` — had **no `.gitattributes` at all**.

**That census is the state this section was written against, and half of it has since been closed.**
All fourteen repos in the collection carry an explicit root `.gitattributes` at its root, so §1 is
satisfied everywhere. §5 is not: measured on 2026-09-22, **one** of the fourteen diffs clean against
the canonical body and the other **thirteen** carry the pre-v2.61.0 shell-scripts comment, because
the edit that widened it never traveled past the two repos it was written in. That is the gap §7
gates rather than re-sweeps. The figures above are kept because they are why the rule reads the way
it does, not because they describe the collection today.

**Treat the straggler counts in that census, and in the v2.24.0 changelog, as indicative rather than
measured.** They were produced by the superseded §7 (e) check, which counted every binary and every
JSON file as a stray on every run — so `111` is an upper bound on `PanelMaster`'s disagreement, not a
count of it. Remeasured with the corrected command (v2.28.1), the collection stands at
`AbsorbTracker` 7, `ConsumableMaster` 7, `BankLedger` 5, `LootHistory` 5, `PanelMaster` 1, and `0` in
`KickCD`, `PrettyChat`, `WhatGroup`, `LibKa0s`, `WowAddonStandards` and `wow-addon`. The argument
this section makes does not rest on the size of those numbers — an unpinned repo diverges per machine
whether it has diverged yet or not — but a reader comparing an old audit against a new one **MUST**
be told that the instrument changed, not the trees.

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
  treated as satisfying this. It reads as a policy and is not one; it is the state that left
  `PanelMaster`'s working tree disagreeing with the collection's intent while looking, in review,
  like the repo had been handled.
- **`.gitattributes` is a development artifact and MUST NOT ship to players** — it is listed in the
  `.pkgmeta` `ignore:` block for the same reason `.gitignore` and `.luacheckrc` are (`packaging`).

### 2. Two repo kinds, two pins (MUST)

- A repo that **ships Lua to the WoW client** — directly as an addon, or vendored into an addon's
  client-bound `libs/` folder — **MUST** pin CRLF:

  ```gitattributes
  * text=auto eol=crlf
  ```

  That is the eleven addon repos — `AbsorbTracker`, `AuraMaster`, `BankLedger`,
  `ConsumableMaster`, `KickCD`, `LootHistory`, `MultiMeters`, `PanelMaster`, `PartyFrameEnhanced`,
  `PrettyChat`, `WhatGroup` — plus `LibKa0s`, whose ship folder lands in every one of their `libs/`
  trees. The client expects CRLF in addon source, and a Linux or macOS
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

### 3. A shebang file is LF in both kinds (MUST)

- Both variants **MUST** carry:

  ```gitattributes
  *.sh text eol=lf
  *.py text eol=lf
  ```

  **including the LF-pinned repos**, where it is redundant. It is mandatory there anyway because the
  line is the thing a reader looks for, and a rule you can satisfy by omission is one that gets
  omitted the day someone changes the pin above it.
- The reason is unconditional and is about the **shebang**, not about shell: `#!/usr/bin/env bash`
  followed by CRLF makes the kernel look for an interpreter literally named `bash\r`, and every
  `case`/`in` line becomes a syntax error. `#!/usr/bin/env python3` fails the same way, for the same
  reason, and the kernel's error names `python3\r` — a string nobody greps for. The files this
  protect in a client-bound repo are the vendored `tests/_kit/run-automated-tests.sh`
  (automated-tests-§2) and any generator under `tools/` (layout-§1), which since v2.61.0 the standard
  expressly contemplates being written in Python; in `wow-addon` it is `scripts/normalize-eol.sh`,
  the hook the plugin runs on every `Write`/`Edit`.
- **`*.py` is listed because the rule that sanctioned the file and the rule that keeps it runnable
  landed in the same version.** `layout-§1` gave a committed generator a home, and a CRLF-pinned repo
  would have handed the first one that arrived a broken shebang on every checkout — the rule creating
  the bug it already knew how to prevent. Extend the pair to any other interpreter the collection
  adopts: what binds is a tracked file whose first line is a shebang, and the two extensions named
  here are the two that exist.
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
- **The list is keyed by extension, so a binary that has none is unreachable by it.** Those are
  marked by **path**, in the §5 appendix, and this union list **MUST NOT** grow a path entry to
  carry one: a path is a fact about a single repo, and everything above it is a fact about the
  collection. Marking is still mandatory — §5 says where the mark goes, not whether it is owed.

### 5. The canonical file bodies (MUST)

A repo's `.gitattributes` **MUST** be one of these two files, byte-for-byte — optionally followed by
the appendix specified below it, which is the only thing that may sit outside the body. They differ
in **one decision**: the pin, the paragraph above it declaring which kind of repo this is, and the
two word-level consequences of that inside the same paragraph and the closing verification line.
Everything else — the `*.sh` block, the binary block, the renormalization recipe — is identical, so
diffing a client-bound repo against a non-client one shows one decision rather than two documents.

Fixing the body is what makes this section **checkable**: an auditor diffs rather than reads, and the
eight hand-written 22-to-68-line variants that existed before it stop being eight things to keep in
sync.

**Client-bound repos** — the eleven addons and `LibKa0s`:

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

# A file with a shebang is LF, ALWAYS — even in a CRLF-pinned repo, where
# everything else is CRLF. `#!/usr/bin/env bash` followed by CRLF makes the
# kernel look for an interpreter literally named "bash\r", and every `case`/`in`
# line becomes a syntax error; `#!/usr/bin/env python3` fails identically, and
# the error names "python3\r". The files this protects are the vendored
# tests/_kit/run-automated-tests.sh (automated-tests-§2) and any generator
# under tools/ (layout-§1). Without these carve-outs each is broken on every
# checkout rather than in one contributor's working tree.
*.sh text eol=lf
*.py text eol=lf

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
# again (`rm <path> && git checkout -- <path>`), then count the bytes:
#   tr -dc '\r' < <path> | wc -c     # must equal…
#   tr -dc '\n' < <path> | wc -c     # …this, in a CRLF repo.
# Not `file <path>`: it reports nothing about line terminators for JSON or
# for any binary, so it passes files it never examined (line-endings-§7).
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

# A file with a shebang is LF, ALWAYS — even in a CRLF-pinned repo, where
# everything else is CRLF. `#!/usr/bin/env bash` followed by CRLF makes the
# kernel look for an interpreter literally named "bash\r", and every `case`/`in`
# line becomes a syntax error; `#!/usr/bin/env python3` fails identically, and
# the error names "python3\r". The files this protects are the vendored
# tests/_kit/run-automated-tests.sh (automated-tests-§2) and any generator
# under tools/ (layout-§1). Without these carve-outs each is broken on every
# checkout rather than in one contributor's working tree.
*.sh text eol=lf
*.py text eol=lf

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
# again (`rm <path> && git checkout -- <path>`), then count the bytes:
#   tr -dc '\r' < <path> | wc -c     # must be 0 in an LF repo.
# Not `file <path>`: it reports nothing about line terminators for JSON or
# for any binary, so it passes files it never examined (line-endings-§7).
```

**The appendix: binaries no extension rule can reach.** The canonical list in §4 is keyed by
**extension**, and §4 MUSTs that every binary be marked. A repo that vendors a binary with **no
extension** — an ELF tool payload, a compiled helper, a downloaded model runner — therefore sits
between two MUSTs and can satisfy exactly one of them: mark it, and the file is no longer
byte-identical to the body above; leave it unmarked, and it is a §4 failure that §7's (e) check
re-reports every cycle for as long as the repo vendors it. `PanelMaster` has been in that position
since v2.24.0 and wrote it down rather than picking a side — its
`tools/artwork/bin/realesrgan-ncnn-vulkan` is the Real-ESRGAN upscaler behind `tools/artwork/`, an
extension-less executable no `*.ext` line can ever match.

A repo holding such a file **MAY** carry an **appendix** below the canonical body. The appendix is a
**compliant** state under this section, not a deviation from it:

- It **MUST** begin after the **last line** of the canonical body, which stays intact through its
  final byte, so a `diff` against the canonical file produces at most **one** hunk and that hunk is
  appended at the end. An entry placed beside the binary block — where it reads best, and where the
  first repo to need one put it — is what this rule forbids: it moves every line after it, and the
  diff that was supposed to show one decision starts showing two.
- Its first non-blank line **MUST** be exactly `# --- line-endings-§5 appendix ---`, and nothing may
  follow the appendix. That is what lets an auditor tell an appendix from an edited body without
  reading either.
- It **MUST** hold only marks an extension rule cannot express — a `binary` mark keyed by **path**.
  Anything reachable by extension belongs in §4's union list, upstream, where all fourteen repos get
  it; a private extension list in one repo's appendix is the eight-hand-written-files problem this
  section closed, restarted one repo at a time.
- Each entry **MUST** name a **single path** rather than a glob. `tools/**` swallows the text file
  somebody adds under it next year, silently, and a binary-marked text file is not diffed and not
  converted — the exact failure §4 exists to prevent, self-inflicted by the fix for it.
- Each entry **MUST** carry a one-line comment saying what the file is and why no extension reaches
  it, because the next reader's first question is whether the entry could have been an extension.
- The appendix is for **binary marks only**. It is not a place to pin, to re-pin, or to write a
  per-path `-text` exemption; §2 forbids those and this **MUST NOT** be read as reopening them.
- An auditor **MUST NOT** file a §5 finding against a file whose body diffs clean and whose extra
  lines are a conforming appendix, and a repo **MUST NOT** carry an `audit-review-history` register
  row for one. A row that predates this rule is retired by bringing the block into the shape above —
  that, and not the block's existence, was the thing worth recording.

An audit runs this beside §7's (a)–(e), and it is the check that keeps "byte-for-byte" checkable now
that a file may legitimately be longer than the body:

```sh
# is the body intact, and is anything extra a conforming appendix?
n=$(wc -l < <canonical>)                                  # 84 client-bound, 85 non-client
diff <(head -n "$n" .gitattributes) <canonical>           # MUST be empty
tail -n +"$((n + 1))" .gitattributes | tr -d '\r' | grep -m1 .   # nothing, or the delimiter
```

The `tr -d '\r'` is not decoration: in a CRLF-pinned repo a blank line is a lone `\r`, which
`grep .` matches, so without it the check reads the separator as the delimiter and passes an
appendix that has none.

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
  printf '%s CR / %s LF\n' "$(tr -dc '\r' < <path> | wc -c)" "$(tr -dc '\n' < <path> | wc -c)"
  # equal counts in a CRLF repo; CR must be 0 in an LF repo. Not `file <path>`:
  # it prints nothing about line terminators for JSON or for any binary (§7).
  ```

- The whole-tree form is `git rm --cached -r . && git reset --hard`. It **MUST NOT** be used with
  uncommitted work in the tree, and a per-file re-checkout is the SHOULD for that reason.
- A repo **MUST** end the change with `git add --renormalize .` producing **no** staged changes and
  no warning, which is the only statement that covers the index and the tree at once.
- The adoption commit **SHOULD** be the whole-repo renormalization **and nothing else**. That diff is
  every line of every straggler; anything real committed alongside it is unreviewable, which is the
  27,000-line problem stated at the top of this section, self-inflicted.

### 7. Checking it (MUST)

Every property this section states **MUST** be checked mechanically, and **MUST NOT** be eye-checked
against the text. Both halves are gated by the kit rather than by an auditor's attention — the working
tree from revision 15, the body from revision 25 — and an audit runs the hand equivalents below only
where the gate has not arrived. Whichever runs it, working-tree strays **MUST** be reported as **one**
rolled-up finding carrying the command that produced the count, never a file-by-file enumeration, which
inflates the tally for what is a single `--renormalize` sweep (documentation-§6 applies the same
rolled-up rule to citation sweeps).

**Property (e) is a test before it is a finding.** Every repo **MUST** carry the vendored EOL gate —
`tests/_kit/test_eol.lua`, LibKa0s test-kit revision 15 — loaded by `tests/run.lua` with the rest of
the suite, and that suite **MUST** be green. The one-liner below asks the same question by hand, and
the reason this section spent so long asking it by hand is the record: on 2026-09-07 this was the
collection's only **100%-failed** MUST, ten of ten repositories, two of the strays inside LibKa0s's own
shipped payload. That is not laziness and it is not disagreement. A rule with an auditor and no seam is
a rule that gets re-swept every cycle — the repair is a two-second re-checkout per file, nobody has
ever disputed it, and it comes back because between one audit and the next nothing in the repo ever
mentions it again. A red test mentions it on every green gate.

The gate asks `git check-attr` what each path's terminator is **declared** to be and then counts the
bytes on disk, over the whole `git ls-files` set. It asserts the invariant rather than any writer's
implementation, so it also catches a file no tool in the repo produces — an `ANALYSIS.md` an agent
dropped into a bundle after the runner exited, a document written with a shell redirect, a payload file
a re-vendor copied with `cp`. Scope is the whole tracked set for a reason: through kit revision 14 the
gate existed and read only `docs/automated-tests/`, which is how `LibKa0s/DebugLog.lua` and
`LibKa0s/Pool.lua` — two files in the **shipped** payload, vendored into nine addons — sat LF on disk
under an `eol=crlf` pin for nine kit revisions with a green suite above them.

- The gate **MUST** fail rather than pass when it cannot look: no git, no `ls`, no answer from
  `check-attr` is a failure and not a skip. A gate that goes quiet when it is blind reports success,
  which is worse than not existing.
- A red **MUST** be cleared by §6's per-file re-checkout, never by `git add --renormalize .`. The index
  is already correct in every repository measured — which is exactly why nothing ever reported these —
  so renormalizing rewrites what was never wrong and leaves the bytes on disk as it found them.
- **Through kit revision 24 a green suite MUST NOT be read as covering (a) through (d).** That case
  compares bytes against declared attributes, so it can say nothing about the body those attributes
  came from — whether it is byte-for-byte one of §5's two, or whether a newly vendored binary type
  reached §4's union list. **From LibKa0s test-kit revision 25 (LibKa0s v1.55.0) the second case
  below covers them**, and in a repo carrying that kit they stop being the audit's work every cycle.
- A repo whose vendored kit predates revision 15 still owes `(e)` by hand, and one predating revision
  25 still owes (a) through (d) by hand. That, and the two repos that run no suite at all, is the only
  reason the one-liner below stays in this section.

```sh
# (a) present at root, and (b)/(c)/(d) the pin, the carve-out and the binaries
test -f .gitattributes && grep -nE '^\* text=auto eol=(crlf|lf)$|^\*\.(sh|py) text eol=lf$|binary$' .gitattributes

# (e) does the WORKING TREE agree with the declared pin? — one number, not a list
git ls-files -z | xargs -0 -I{} sh -c '
  set -- $(git check-attr text eol -- "{}" | sed "s/.*: //")
  [ "$1" = unset ] && exit                      # binary: git converts nothing here
  cr=$(tr -dc "\r" < "{}" | wc -c); lf=$(tr -dc "\n" < "{}" | wc -c)
  case "$2" in crlf) [ "$lf" -gt 0 ] && [ "$cr" -ne "$lf" ] && echo "{}";;
               lf)   [ "$cr" -gt 0 ] && echo "{}";; esac' 2>/dev/null | wc -l
```

- **(e) asks git for `text` as well as `eol`, and it counts bytes rather than asking `file(1)`.**
  Both halves are corrections to a version of this check that over-reported by a factor of three.
  `binary` expands to `-text`, and it says nothing about `eol` — so `git check-attr eol` on a marked
  PNG returns `crlf`, inherited from the pin line, for a file git will never convert. Reading `text`
  first is what makes §4's marking mean something to §7. And `file(1)` is a type sniffer, not a byte
  test: it reports `JSON text data` for a fully-CRLF JSON file whatever its bytes, `no line
  terminators` for a file that has none, and `with CRLF line terminators` for a file where only
  **one** line ends CRLF — so it counts binaries and JSON as strays forever while passing the
  half-converted file, which is exactly what an edit into a CRLF file produces. Counting CR against
  LF answers the question that was actually asked. A file with no `\n` at all is not a straggler and
  is skipped: there is nothing on disk to convert.
- **The one accuracy the one-liner gives up is the lone `\r`.** Comparing totals treats every CR as
  half of a CRLF pair, so a file carrying a bare `\r` **inside** a line reads wrong in both
  directions — flagged when it is clean, and passed when a stray CR masks a real bare `\n`. The
  trade buys a check that stays pasteable, and the kit closes the gap it leaves: **from LibKa0s
  test-kit revision 26, `test_eol` counts lone CRs** (a byte 13 not followed by a byte 10) in every
  path it scans, so in a repo carrying that kit a lone `\r` turns the suite red rather than waiting
  for an audit to find it. A repo on an older kit that suspects one needs a scanner that counts
  `\r\n` pairs rather than this. **Do not "simplify" the
  command back toward `file(1)`** — that shape is the defect this replaced, not a shorter spelling of
  it.
- A count of `0` is the compliant state. Anything else is **one** finding: *"N tracked files disagree
  with the declared pin"*, with the command above quoted so the next reader can reproduce the number
  rather than trust it.
- Grade by **impact**, per `AUDIT.md` step 5: this is a config-and-repo-hygiene failure, so it is
  **Low** or **Info** even though every rule in this section is a MUST — and the entry **MUST** still
  name the MUST it fails.
- In a repo carrying the gate, that count is the suite's own and a stray is a **red test** rather than
  a discovered defect. An audit that finds strays where `tests/_kit/test_eol.lua` reports green
  **MUST** file the gate as the finding, not the files: the working tree is one commit from clean
  either way, and a check that passes over what it was written to catch is the more expensive defect.

**Properties (a)–(d) are a test too, from revision 25, and this section's own argument is why.** *A rule
with an auditor and no seam is a rule that gets re-swept every cycle* was written four paragraphs above
about the working tree, and it holds word for word for the body. The body was left to the eye, and the
measurement says what that produced. On 2026-09-22, **twelve of the fourteen repos were missing
`*.py text eol=lf`** — a §3 MUST since v2.61.0 — and **thirteen of the fourteen** diverged from §5's
canonical body. Every one of the thirteen diverged in the *same place*, on the *same* six lines: the
shell-scripts comment §3 widened to eight when it took in the shebang rule. `AuraMaster` and `LibKa0s`
carry the `*.py` line, and `AuraMaster` alone diffs clean. So thirteen repositories did not each make a
judgment about their `.gitattributes`. One edit failed to travel, and between the audit that shipped it
and the next one, nothing in any repository mentioned it again.

**And the missing line is not cosmetic in at least one of the twelve.** One repository tracks four
`#!/usr/bin/env python3` generators under `tools/`; with no `*.py` carve-out above them its CRLF pin
applies, and all four sit CRLF on disk — which is `python3\r`, on every checkout, for everyone. That is
precisely the failure §3 was extended to prevent, sitting in the tree since the release that extended
it, under a green suite, because the rule was published and the line that carries it was not.

**From LibKa0s test-kit revision 25 (LibKa0s v1.55.0), the body is gated by a second case in the kit's
existing `tests/_kit/test_eol.lua`** — a second case and not a second suite, because one file already
owns this question and two gates over one rule is two lists to keep whole (testing-§9). It is declared
by the pair (basename, kit directory) like any other kit suite, and it asserts:

- **(a)** `.gitattributes` is present at the repo **root** and tracked;
- **(b)** the file carries **exactly one** `* text=auto` pin, and it is the one §2 gives this repo kind
  — `eol=crlf` where the repo ships Lua to the client, `eol=lf` where it ships none. The gate decides
  which by §2's mechanical discriminator — a `.toc`, a client-bound `libs/`, or the tracked payload folder a Ka0s-owned library repo ships under `library-stack-§7`, which has neither of the first two — rather than by carrying a
  roster of its own: a list inside the gate is one more copy to update the day a repo is added;
- **(c)** §3's per-extension pins are both present — `*.sh text eol=lf` and `*.py text eol=lf` — along
  with §4's binary marks;
- **(d)** the file is **byte-identical to §5's canonical body for that kind** from its first byte through
  that body's final line, and the only thing permitted below it is a §5 appendix graded against §5's own
  rules: it begins after the body's last line, its first non-blank line is exactly
  `# --- line-endings-§5 appendix ---`, every entry is a single path carrying its one-line reason, and
  nothing follows it.

The two canonical bodies are **copied whole out of §5** into the kit rather than re-authored there, so
this section stays the one place the body is written down: changing a comment in §5 is then one kit
revision and one re-vendor, not fourteen hand edits that diverge the way the last one did. The case
**MUST** fail rather than pass when it cannot look — no git, no file, no answer from `check-attr` — on
the same bargain the working-tree case already strikes.

A repo whose vendored kit **predates revision 25 owes the re-vendor, not a hand-written suite**: a
fourteenth local copy of a gate the kit ships is the drift this paragraph exists to end. The two repos
with no `tests/` harness to wire it into — the documentation-and-tooling repos (documentation-§8) —
keep the audit's one-liner above, and that is what it is still for.
