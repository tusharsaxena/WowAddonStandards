# Harvest 2026-08-25 — 02 Findings

Every finding carries `repo:file:line` or an issue URL. Filter outcome is one of **live**,
**settled-by-date**, **duplicate-of-open-evolution**, **below-bar**.

---

## Category 5 — Standard-internal contradictions

### F-01 · `layout-§1` and `toc-file-§5` mandate incompatible orderings — **live**

Two MUSTs, and no TOC can satisfy both. `toc-file-§5` even asserts its order is *"matching the load
order (layout-§1)"*, so the cross-reference is itself false.

- `standards/standards/layout.md:51` — `core/*` → `defaults/*` → `locales/*` → `settings/*` → `modules/*`
- `standards/standards/toc-file.md:106` — Libraries → Locales → Core → Defaults → **Modules → Settings**, "settings **last**"

Disagreement on two axes: **Locales** (after defaults, vs before core) and **Settings vs Modules**
(settings before modules, vs settings last).

Filed **twice, independently**, from two different addons' audits:
<https://github.com/tusharsaxena/WowAddonStandards/issues/1> (from LootHistory's 2026-07-18 audit,
`state:triaged`, `severity:medium`) and
<https://github.com/tusharsaxena/WowAddonStandards/issues/2> (from PrettyChat, closed
`state:will-not-do`, `severity:medium`).

**The collection has already voted, 9 to 0.** Every rostered addon's TOC uses
`Libraries → Locales → Core → Defaults → Modules → Settings` — `toc-file-§5`'s order, not
`layout-§1`'s. Eight of the nine label the last block with the same reason in almost the same words
("Settings (last — depend on everything else being initialized)"). See `03_EVIDENCE.md` §A.

Live at v2.33.0: both lines are unchanged in the working tree.

### F-02 · `layout-§1`'s `core/` prefix is failed by 9 of 9 addons — **live**

`layout-§1` (`layout.md:51`) opens its load order with `core/Compat.lua` → `core/Constants.lua` →
`core/Namespace.lua`. **Not one addon in the collection loads its `core/` block that way**, and the
five that do start with `Compat.lua` all put a LibKa0s seam second, never `Constants.lua`:

| Addon | First three `core/` files |
|---|---|
| AbsorbTracker | `EnvSetup` → `MediaSetup` → `Constants` |
| BankLedger | `Compat` → `EnvSetup` → `ItemSetup` |
| ConsumableMaster | `Namespace` → `PerfSetup` → `MediaSetup` |
| KickCD | `Compat` → `EnvSetup` → `PoolSetup` |
| LootHistory | `Compat` → `EnvSetup` → `ItemSetup` |
| MultiMeters | `Compat` → `EnvSetup` → `PoolSetup` |
| PanelMaster | `Compat` → `EnvSetup` → `LSMPatch` |
| PrettyChat | `EnvSetup` → `MediaSetup` → `Constants` |
| WhatGroup | `CoreSetup` → `MediaSetup` → `Util` |

This is both a category-7 signal (a MUST nobody satisfies) **and** a category-4 one: it recurs as
**CM-49 in two consecutive audit dates** —
`ConsumableMaster/docs/audits/2026-08-04/02_DEVIATIONS.md:38` and
`ConsumableMaster/docs/audits/2026-08-05/02_DEVIATIONS.md:36` — the fix never sticks, and that
addon's own plan escalated it rather than fixing it:
`ConsumableMaster/docs/audits/2026-08-04/05_EXECUTION_PLAN.md:23` — *"Raise the `layout-§1` conflict
upstream: `Compat → Constants → Namespace` may be unsatisfiable for any addon whose `Namespace.lua`
bootstraps `NS`."*

**The standard's own scaffolding pack fails both F-01 and F-02.** `NEW_ADDON_CONTEXT.md:106-108`
states the `Compat → Constants → Namespace` prefix, and `NEW_ADDON_CONTEXT.md:186-196` — the pack's
own TOC template — ships `# Locales` before `# Core` and `Compat → MediaSetup → Constants →
Namespace`, annotating the reason on the line. `NEW_ADDON.md:73-78` repeats it normatively. An addon
scaffolded exactly as instructed is **born non-compliant with `layout-§1`**. See `03_EVIDENCE.md` §H.

**Both readings are stated in `04_PROPOSALS.md`; this run does not pick one.**

---

## Category 8 — LibKa0s ↔ standard drift

### F-03 · The standard describes six majors; the library ships ten — **live**

`library-stack.md:70` states `LibKa0s` ships **"six LibStub majors across nine files"** and tables
six: Core, Media, DebugLog, Slash, Options, Perf. The library actually ships **ten majors across
thirteen files** (`LibKa0s/LibKa0s/LibKa0s.xml`, thirteen `Script file=` entries):

| Major | File | In the standard's table? | Consumers (of 9) |
|---|---|---|---|
| `LibKa0s-Core-1.0` | `Core.lua` (minor 6) | yes | 9 |
| `LibKa0s-Media-1.0` | `Media.lua` (3) | yes | 9 |
| `LibKa0s-DebugLog-1.0` | `DebugLog.lua` (12) | yes | 9 |
| `LibKa0s-Slash-1.0` | `Slash.lua` (7) | yes | 9 |
| `LibKa0s-Options-1.0` | `Options.lua`, `OptionsWidgets.lua`, `OptionsScroll.lua` (8) | yes | 9 |
| `LibKa0s-Perf-1.0` | `Perf.lua`, `PerfPanel.lua` (7) | yes | 4 |
| **`LibKa0s-Env-1.0`** | `Env.lua` (1) | **no** | **9** |
| **`LibKa0s-Item-1.0`** | `Item.lua` (1) | **no** | 3 |
| **`LibKa0s-Pool-1.0`** | `Pool.lua` (3) | **no** | 4 |
| **`LibKa0s-Widgets-1.0`** | `Widgets.lua` (7) | **no** | 3 |

`LibKa0s-Env-1.0` is consumed by **every addon in the collection** and appears nowhere in the
standard. This is the exact failure shape `CLAUDE.md` names: a count stated with its members that
has gone stale — and a stale count with an open slot is the one an agent fills from memory.

Two dependent claims are stale with it: `library-stack.md:95` ("**Five of the six** majors need
`LibKa0s-Core-1.0`") and `open-evolutions.md`'s *Further LibKa0s modules* entry, which lists **six
majors across nine files** and still names *the object pool* as a candidate the collection
"duplicates" — `LibKa0s-Pool-1.0` shipped, and four addons consume it.

### F-04 · Four shipped majors that most of the collection has argued its way out of — **live, informational**

`LibKa0s-Widgets-1.0` was declined in **6** repos, `LibKa0s-Item-1.0` in **7**, `LibKa0s-Pool-1.0`
in **5** — all at `severity:low`, all with the same shape of rationale ("no control in this addon
wants it", "no item domain"). See `03_EVIDENCE.md` §D. This is not a rule the collection refuses;
it is the library correctly carrying modules only some hosts need, which is what per-module majors
are for (`library-stack-§7`). Recorded so the next run does not read the decline count as a defect.

---

## Category 1 — Convergent patterns

### F-05 · The TOC load-position annotation: **load-bearing** vs **conventional** — **live**

Every one of the nine addons annotates seam positions in its TOC with a comment saying whether the
position is **load-bearing** (something resolves at file scope, so moving the line breaks it
silently) or merely **conventional**. The two words are used as terms of art, in nine independently
written TOCs:

| Addon | "load-bearing" | "conventional" |
|---|---|---|
| AbsorbTracker | 1 | 1 |
| BankLedger | 3 | 3 |
| ConsumableMaster | 1 | 2 |
| KickCD | 1 | 0 |
| LootHistory | 3 | 1 |
| MultiMeters | 1 | 0 |
| PanelMaster | 2 | 2 |
| PrettyChat | 2 | 0 |
| WhatGroup | 2 | 2 |

All nine annotate the *same* case as load-bearing: `core/MediaSetup.lua` must precede
`core/Constants.lua`, because `Constants` resolves `FONT_MONO` from `NS.MediaFont` **at file load**
(`LootHistory/LootHistory.toc:41-42`, `PanelMaster/PanelMaster.toc:43-46`, and seven more —
`03_EVIDENCE.md` §B). Neither `toc-file` nor `layout` uses either word: `grep -n
"load-bearing\|conventional"` over both returns nothing.

The convention is already the collection's; the standard is late.

---

## Category 7 / 2 — A MUST with a chicken-and-egg blocker

### F-06 · An unpublished addon cannot carry `X-Curse-Project-ID`, and the standard does not say so — **live**

`toc-file.md:30` — "**MUST** have `X-Curse-Project-ID` once the addon is published on CurseForge".
The trigger clause is there, but nothing says what an addon does **before** that, and the corpus
shows both halves of the resulting mess:

- **PanelMaster** carries two deviations, D-001 and D-002, *permanently blocked* on the id
  (`PanelMaster/docs/audits/2026-07-30/02_DEVIATIONS.md` ▸ D-001/D-002;
  <https://github.com/tusharsaxena/PanelMaster/issues/22>, `#23`, both `state:triaged`) — deviation
  rows that cannot be closed by any act of the addon.
- **MultiMeters** solved it in the TOC and stated the cost —
  `MultiMeters/MultiMeters.toc:13-14`: *"X-Curse-Project-ID / X-Wago-ID are deliberately absent: the
  addon is not published yet, and a placeholder ID here would make the packager upload to somebody
  else's project."*

Two repos plus a stated, concrete consequence (a placeholder uploads your addon into a stranger's
project). Clears the evidence bar.

---

## Category 10 — Tooling gaps

### F-07 · Agent-tooling directories are shipped to players; nothing checks it — **live**

`packaging`'s ignore-list MUST names `docs/`, `_dev/`, `tests/`, `.luacheckrc`, `.gitignore`,
`.gitattributes`. It does not name the agent-tooling directories, and the collection is failing on
exactly those:

| Addon | has `.superpowers/` | ignores it | ignores `.claude` |
|---|---|---|---|
| AbsorbTracker | yes | **no** | no |
| BankLedger | yes | **no** | no |
| ConsumableMaster | yes | yes | yes |
| KickCD | yes | **no** | no |
| LootHistory | yes | **no** | no |
| MultiMeters | yes | **no** | no |
| PanelMaster | no | — | no |
| PrettyChat | no | — | no |
| WhatGroup | no | — | yes |

**Five addons would package a dev-only directory into the player's AddOns folder.** KickCD's audit
found it and filed it as `A-3` — then filed it *again* on the next date, unchanged:
`KickCD/docs/audits/2026-08-04/02_DEVIATIONS.md:49` and
`KickCD/docs/audits/2026-08-05/02_DEVIATIONS.md:51` — *"`.superpowers/` (54 files) and
`.claude/settings.local.json` are dev-only and are **not** in `.pkgmeta`'s ignore list. The
section's MUST names `docs/`, `_dev/`…"*. A deviation that recurs verbatim across two dates is the
category-4 no-teeth pattern, and its fix is a named list plus a mechanical check, not more prose.

---

## Category 3 — Midnight quirks written up more than once

### F-08 · `Settings.OpenToCategory` takes the integer ID — three independent write-ups — **live**

Written up separately, at different depths, in three addons' quirk files:
`AbsorbTracker/docs/midnight-quirks.md:73`, `ConsumableMaster/docs/midnight-quirks.md:74`,
`WhatGroup/docs/midnight-quirks.md:34`. **WhatGroup's is the deepest** — it is the only one that
enumerates all three wrong forms and names the silent failure (overwriting `category.ID` with a
string makes `OpenToCategory` a **no-op**, not an error). Quoted in full in `03_EVIDENCE.md` §C.

Paired with it, in the same three files: **forcing the parent category to render expanded** through
the private `SettingsPanel:GetCategoryList():GetCategoryEntry(cat):SetExpanded(true)` walk, wrapped
in `pcall`. **ConsumableMaster's is the deepest** — it is the only one that says *why* the walk is
necessary (`SettingsCategoryMixin` has no `SetExpanded`; that method lives on the visual list
entry) and the only one that pins the ordering constraint (call it **after** `OpenToCategory`, so
`SettingsPanel` is realized).

**The standard has no quirks catalogue section.** `options-ui` covers the landing page
(`options-ui.md:72`) and the combat refusal (`:56`) but never the ID form or the expand walk.
Promoting this needs a new section, which is itself a proposal (P-07).

### F-09 · Secret values — **settled-by-date**

Four repos write up 12.0 secret-value protection (AbsorbTracker, BankLedger, ConsumableMaster,
KickCD), and it looks like the strongest quirk cluster in the corpus. It is already upstream:
`events-frames-taint-§8` (`events-frames-taint.md:73-84`) carries the survives-`tostring`,
survives-`..`, raises-in-`table.concat` triple **and** the repeating-ticker consequence, in more
depth than three of the four write-ups. Only KickCD's `DurationObject` probe
(`KickCD/docs/midnight-quirks.md:53-93`) goes further, and it is one repo — **below-bar**, to the
watch list.

---

## Category 6 — Refusals that turn out to be settled

### F-10 · The `X-Wago-ID` refusal cluster — **settled-by-date**

Three repos declined the same rule with an argued rationale — ConsumableMaster
<https://github.com/tusharsaxena/ConsumableMaster/issues/17>, PrettyChat
<https://github.com/tusharsaxena/PrettyChat/issues/7>, WhatGroup
<https://github.com/tusharsaxena/WhatGroup/issues/5> — all `severity:low`, all provenance
`docs/pending/LEDGER.md` row `PLAN-01`/`PLAN-03`, decided 2026-07-31. On its face this is the
canonical category-6 finding: a rule three repos collectively refuse.

**It is not, because the rule already changed.** All three were filed against the old `toc-file-§1`,
which the issues quote as requiring *"both distribution ids"*. Today `toc-file.md:30` reads:
"`X-Wago-ID` and `X-WoWI-ID` are **optional** (**MAY**) — include each only when the addon is
actually listed on that platform … an addon that doesn't publish there simply omits the line."
The refusals describe a rule that no longer exists. Nothing to propose.

The **residue** is real but belongs downstream, not here: each of those three issues asserts *"a
future standards audit will still flag the missing field"*, and it will not. Named as rollout debt
in `06_OUTCOME.md`; this command does not write to addon repos.

### F-11 · The perf-harness declines — **duplicate-of-open-evolution / settled**

Five repos declined wiring `LibKa0s-Perf-1.0`: BankLedger `#9`, LootHistory `#22`, PanelMaster
`#31`, PrettyChat `#10`, WhatGroup `#7`. Only 4 of 9 addons consume the Perf major. Five of nine
declining a MUST would be a strong category-7 finding if the exemption did not exist — but
`performance-§12` is precisely that exemption, and the declines cite it (`PrettyChat#10`: "declined
on two independent structural grounds"; `WhatGroup#7`: "ratified in ARCHITECTURE Documented
deviations"). The rule is working as designed.

The one live edge — a **window-bounded ticker** that ends the exemption on the letter of criterion
(a) — is already recorded in `open-evolutions.md` ("What `performance-§12`'s re-check trigger should
do with a window-bounded ticker", from WhatGroup, 2026-08-06). **Recorded as a vote, not a new
item.** This run adds no second repo to it, so the case is unchanged.

---

## Below the bar — watch list for the next run

Each needs one more repo, or a stated cost, to be promotable.

- **`.pkgmeta` should ignore itself.** ConsumableMaster is the only repo listing `.pkgmeta` in its
  own ignore block (`ConsumableMaster/.pkgmeta`); the standard's template does not. One repo, no
  stated cost.
- **`media/screenshots` ignored.** Same file, same single repo.
- **KickCD's `DurationObject` probe** (`KickCD/docs/midnight-quirks.md:53-93`) — the finding that
  *every* `DurationObject` getter is secret in combat. Deepest client research in the corpus and
  currently paid for by one repo.
- **A parent Settings category with subcategories hides its own panel widgets**
  (`WhatGroup/docs/midnight-quirks.md:18-32`). One repo. `options-ui-§...` already mandates the thin
  landing page, so the *behavior* is enforced; only the *reason* is undocumented.
- **The collapsed-group key `mode .. "\001" .. rawValue`** — already in `open-evolutions.md` as its
  own entry, still at two addons. **Vote unchanged**, no third addon found this run.
- **A shared `.luacheckrc` base** — `open-evolutions.md`'s *Shared luacheckrc base* entry. This run
  adds evidence: all **ten** repos (nine addons + LibKa0s) carry a `.luacheckrc` and **all ten
  differ** (ten distinct md5s). **Recorded as a strengthened vote**, not a new item, and not
  proposed: the entry's own blocker (it wants a symlink, and the repos are not a monorepo) is
  untouched by this evidence.
