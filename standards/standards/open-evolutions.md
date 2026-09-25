> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- ~~**Ka0s-Core sibling addon.**~~ **Settled, and settled the other way.** The AceGUI panel scaffold, the slash dispatcher, the debug console and the test-harness scaffolding are all extracted — as `LibKa0s-Options-1.0`, `LibKa0s-Slash-1.0`, `LibKa0s-DebugLog-1.0` and the shared `testkit/`, on top of `LibKa0s-Core-1.0`. They are a **vendored library**, not a sibling addon, because library-stack-§6 forbids requiring another addon to be installed. What remained open was the Schema runtime and the Compat templates, and at `LibKa0s v1.55.0` both moved: `LibKa0s-Compat-1.0` shipped as a **narrow** major, with the wide extraction measured and rejected (library-stack-§7's module table carries the measurement), and `LibKa0s-Schema-1.0` shipped the schema runtime's **portable half**, with the host half — root resolution and the write's announcement — staying per addon. Migration-stamp ownership, which neither major touches, was ruled at v2.65.0 without a library (below).
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- ~~**Shared test scaffolding.**~~ **Shipped** as `testkit/` in the LibKa0s repo, vendored to each addon's `tests/_kit/` — the framework, the sandboxed loader and the universal WoW/Ace mock base (testing-§1).
- **Multi-zone profile model adoption** for group-context addons.
- ~~**Object pool standard** packaged as a copyable micro-lib.~~ **Shipped**, and not as a copyable micro-lib — as `LibKa0s-Pool-1.0`, in both the array and keyed shapes (library-stack-§7). A copyable micro-lib was the wrong answer for the same reason the pool needed doing at all: four copies shipped across two addons and one of them never returned anything to the free list, which a fifth copy would not have caught either.
- **Further `LibKa0s` modules.** `LibKa0s` is now the sanctioned path for shared Ka0s-owned code (library-stack-§7), and its per-module-major layout makes each addition independent and purely additive. Shipped so far: the secret-safe/printer seams (Core), the client-fact reader (Env), the widget pool (Pool), the item primitives (Item), the shared media catalog (Media), the flat dropdown, copy window, reorder list and drag handle (Widgets), the debug console and, from `LibKa0s v1.60.0`, the diagnostics-report helper (DebugLog), the slash dispatcher (Slash), the options toolkit (Options), the perf harness (Perf), the minimap/broker launcher (Launcher) and the stand-down latch (Lifecycle), and from `LibKa0s v1.55.0` the version-variant readers and secret guards (Compat), the bus stand-down record and strict message catalog (Bus) and the schema runtime's portable half (Schema) — **fifteen majors across twenty-two files** (recounted from `LibKa0s/tests/majors.lua` and `LibKa0s/LibKa0s.xml`, library-stack-§7), plus the non-code `media/` payload. The three candidates this entry used to name each moved, and each only in part. **`Compat`: a narrow major shipped; the wide extraction was measured and rejected** — the nine `core/Compat.lua` copies hold 2820 lines (`wc -l */core/Compat.lua` over the collection), of which the absorbed members occupy 248 (330 with the two `core/Secrets.lua` seams), summed from the per-member `file:line` spans in `Ka0sAddonsCommonTasks` `docs/2026-09-22-SUITE_STANDARDS_AND_LIBKA0S_SWEEP/3b-specs/compat.md`, §1 *Measurements* (commit `79ed441`), each span counted `end − start + 1`: the nine copies' rows sum to 248 and the two `Secrets.lua` rows to 82 (library-stack-§7), and the rest is single-consumer, content-free or disagreed-on. **The bus: the stand-down record and the catalog shipped**; the untracked host factory stays host code (architecture-§4). **`Schema`: the portable half shipped**; root resolution and announcement stay per addon, and **migration stamps were ruled at v2.65.0 in the standard's template, not in a library** (below). What the collection still duplicates beyond those is what each major's API document lists under what it leaves out. Each is its own decision, adopted on its own schedule — deliberately **not** a lockstep migration, and deliberately not a `Ka0s-Core` addon (library-stack-§6 forbids requiring another addon).
- **A per-addon adoption command.** Still open, and now broader than when it was written: adoption spans fifteen majors rather than one, and most of the newer ones **delete files the addon owns** rather than only adding a descriptor — which is harder to script safely and more valuable to keep identical across addons. `LibKa0s/docs/adoption-prompt.md` carries the per-addon survey and hazards in the meantime.
- ~~**Migration-stamp ownership.**~~ **Ruled at v2.65.0** (savedvariables-§1). The collection held
  **five incompatible schema-migration variants** across eight repos, disagreeing on who writes
  `schemaVersion` (the runner, or each step), whether it is stamped per step or once at the end, whether
  a failed step still stamps, and what a missing step does. The divergence is why a shared runner was
  rejected (library-stack-§7, anti-patterns #55), and the resolution is the ruling rather than a library.
  The hard case it had to decide was AceDB's defaults merge: a declared `schemaVersion` default is
  backfilled onto a legacy account that stored none, and `removeDefaults` strips a stored stamp equal to
  its default at logout. The ruling: defaults declare `schemaVersion = 0`, `NS.SCHEMA_VERSION` is the
  runner's target, the runner alone advances the stamp and only past a step that returned without
  raising, a profile-scoped step runs for every stored profile (or idempotently per profile on
  `OnProfileChanged` against a per-profile stamp) and is never gated by the account-wide stamp alone, and
  every step is idempotent against a fresh default profile. The worked cases were **PanelMaster**, whose
  declared default masked legacy accounts until it stopped seeding the stamp (`febf108`);
  **LootHistory**, which held the default at 1 while its runner stamps to 8, the reason living only in a
  comment; and **WhatGroup**, whose default of `NS.SCHEMA_VERSION` AceDB would strip at every logout, so
  its first real migration would have been skipped for every existing user. Each converges on the
  template in its own follow-up, with a red-first migration test.
- **What `performance-§12`'s re-check trigger should do with a window-bounded ticker.** §12 grants the
  no-combat-path exemption on criterion **(a)** — no `OnUpdate`, no repeating ticker, no event handler
  doing more than occasional work in combat — and its re-check trigger re-arms the **full** wiring MUST
  on *"the first `OnUpdate` handler, repeating ticker, or in-combat event handler doing real work"*.
  Note the asymmetry: *in-combat* qualifies only the event-handler arm. A repeating ticker re-arms the
  wiring unconditionally, however it is gated.

  WhatGroup hit this on 2026-08-06 and it is the first real test of the trigger. A teleport-cooldown
  countdown in its popup needs a 1-second timer; the timer is a single handle, armed only while the
  popup is **both** open and showing a live cooldown, replaced rather than stacked, and canceled from
  the frame's `OnHide`, from the top of the configure path, and by the tick that reaches zero. Per tick
  it costs one `C_Spell.GetSpellCooldown` and one `SetText`. On the letter of the trigger that ends the
  exemption, so the addon owes a `core/PerfSetup.lua`, a `perf` verb, a second SavedVariables global, a
  suspend/resume contract, a `tests/perf.lua` and a `docs/perf-analysis/` store — to account for a timer
  the player starts by opening a window and stops by closing it. Criteria **(b)** and **(c)** did not
  change: the buckets would still read `0.000`, which performance-§3 calls a lie in every report, and
  `suspend` would still make a capture addon miss the capture. Only (a) broke.

  It is recorded there as a **ratified deviation in its own right** rather than resolved locally, which
  is the correct handling under documentation-§3 but is also the tell that the rule needs a ruling: an
  addon meeting the *spirit* of (a) exactly — no hot path, no unbounded work — should not have to carry
  a register row for it. The decision this needs is what the boundary actually is, and it is not
  obvious. *"Gated on a visible frame"* is the intuitive line and is too loose (an addon can keep a
  window open through a raid boss). *"Never runs in combat"* is too strict and unenforceable, since a
  player can open a popup mid-pull. Candidate shape: a ticker at 1Hz or slower, bounded by a frame the
  **player** opened, doing O(1) work per tick, stays inside (a) and is recorded as a one-line note on
  the existing exemption row rather than a new deviation — with the wiring re-armed the moment any of
  those three properties stops holding. Whatever is decided, the trigger should say which of its three
  arms are qualified by combat and which are not, because the current asymmetry reads as an oversight
  and the next reader will not know whether it was one.

- **A collapsed-group key convention.** Two addons independently key a table's collapsed-group state as
  `mode .. "\001" .. rawValue`. It is load-bearing — changing the format silently resets every user's
  collapsed groups — and is currently written down nowhere. Too small to be a library (it is one
  concatenation); the right home is a naming/convention line, if a third addon grows grouped tables.

- **The options surface and the shared icon catalog.** library-stack-§8 deliberately stops at the
  addon's own user-facing windows and leaves the settings panel alone. The reason is ownership rather
  than taste: those widgets are `LibKa0s-Options-1.0`'s, so a mark on a Defaults button or a page
  header is a **library** change that lands in nine addons at once, and doing it per addon would mean
  nine hosts reaching into the panel a library builds — exactly what options-ui exists to prevent.
  What to settle before it moves: which controls genuinely benefit (a reset, a copy-from, a page
  header's category mark) versus which are labels that should stay labels; whether the descriptor
  gains a per-row `icon` field or the library picks marks by row type; and whether a host may override
  one, given that the panel is the surface a user compares across addons least often and the strip of
  a main window most. Do it as one library minor with a screenshot of every affected page, not as a
  rolling adoption.

- **Whether an unlock anchor has to be the library's handle.** `LibKa0s-Widgets-1.0` ships two drag
  surfaces and the standard mandates one of them. options-ui-§18 requires `ReorderList` wherever the
  **order** of a list is the setting, and four addons consume it. `DragHandle` — the labeled strip a
  player drags to move a positionable frame, with its geometry published as `DRAG_HANDLE` — is
  required nowhere, and three addons consume it while eight do not. The extraction bar was already
  met before the module existed: two addons had hand-built the same widget down to the same 18px
  strip, the same 2px gap and the same centered gold label, which is library-stack-§7's bar 1 — two
  consumers with the same semantics — stated in the library's own voice. So the open question is not
  whether the surface belongs in the library, which is settled, but whether it earns a **rule** of
  §18's kind and where that rule would live: §18 is scoped to list ordering and does not reach a
  frame-move handle, and standalone-windows governs the window chrome the library owns rather than
  the anchor a player drags.

  What would settle it is what the eight non-consumers actually draw. A handle that is genuinely
  absent — an addon with nothing positionable — is a different answer from a fifth hand-built strip,
  and only the second makes this the shape library-stack-§9 describes, where the count of callers is
  not what decides. Cross-check preview-mode before writing it: the unlock anchor is the affordance an
  addon's lock/unlock state is expressed through, so a handle rule and the preview rules must agree
  about when the strip is on screen.

- **The schema write seam's name and call style (recorded, not ruled).** The standard names the seam
  twice and two ways. architecture-§5 reads *"one helper: `NS.Schema:Set(path, value)`"* — a colon
  method on `NS.Schema`; slash-commands-§3's descriptor example reads `set = function(path, v)
  NS.SetByPath(path, v) end` and calls that *the single write seam* — a free function. The
  collection holds both, and three more. Measured as the function each of the eleven addons' Options
  and Slash descriptors bind as `set` (`git -C <repo> grep -nE -A3 '^\s*set\s*=' --
  settings/OptionsSetup.lua settings/Slash.lua`), the seam is spelled five ways, one of them
  colon-called: **`NS.Schema:Set`** in BankLedger, LootHistory and PanelMaster (`git -C <repo> grep
  -oE 'NS\.Schema:Set\b' -- '*.lua' ':!libs' | wc -l`: 63, 103 and 41); **`NS.SetByPath`** in
  AbsorbTracker, AuraMaster, MultiMeters and PartyFrameEnhanced; a dot-called **`NS.Schema.Set`** in
  PrettyChat (defined `settings/Schema.lua:636`); a dot-called **`Helpers.Set(path, value, opts)`**
  in WhatGroup (defined `settings/Schema.lua:451`, bound `settings/OptionsSetup.lua:195` and
  `settings/Slash.lua:233`; 55 call sites, `git -C WhatGroup grep -hoE 'Helpers\.Set\(' -- '*.lua'
  ':!libs' | wc -l`); and a dot-called **`Helpers.SetAndRefresh(path, value)`** in ConsumableMaster
  and KickCD (bound at ConsumableMaster `settings/OptionsSetup.lua:260` and `settings/Slash.lua:524`,
  KickCD `settings/OptionsSetup.lua:162` and `settings/Slash.lua:378`; defined KickCD
  `settings/Panel_Render.lua:273`). Two of those hosts carry a second name beside the bound one.
  ConsumableMaster also publishes a colon `KCM.Schema:Set` (`settings/Panel.lua:1069`) that
  forwards to `Helpers.SetAndRefresh`. KickCD's `Helpers.Set(path, section, value)`
  (`settings/Panel.lua:380`) is the store writer beneath its seam, called from
  `settings/Panel_Render.lua:263`, and is bound by neither descriptor. `LibKa0s-Schema-1.0`'s member is **`inst.Set(path, value,
  instanceId)`, dot-called**, and it can be nothing else: the Options and Slash descriptors take their
  seam **as a value** and call `d.set(row.path, value)`, and a colon member cannot be handed over as
  one. The library therefore picks neither name, and a host binds whichever it has — `NS.SetByPath =
  inst.Set`, or a one-line colon wrapper — so no call site moves when it adopts. What needs deciding
  is whether architecture-§5 and slash-commands-§3 converge on one spelling and which, and whether a
  colon-called `NS.Schema:Set` stays a sanctioned shape now that the shared member cannot be one.
  Until it is decided, each host keeps the name it has, and neither citation is a finding against it.
- **Whether the settings panel's live-refresh subscription is setup or feature (recorded, not
  ruled).** slash-commands-§7 lists *"the settings-category registration and the panel body"* among
  what survives a stand-down, and *"every event, message and bucket registration"* among what goes.
  A panel's subscription to its own refresh message sits between the two, and the collection reads
  it both ways. **Kept live, as part of the panel body:** BankLedger names *"the panel body with its
  own live-refresh target"* as setup (`core/BankLedger.lua:137`; the target at
  `settings/Panel.lua:165`), and LootHistory (`settings/Panel.lua:154`), AuraMaster
  (`settings/OptionsSetup.lua:395`) and PanelMaster (`settings/PanelEditor.lua:1441-1444`, pinned as
  the panel body at `tests/test_disabled.lua:49`) build theirs on an untracked factory the stand-down
  does not reach. **Taken down, as feature:** ConsumableMaster argues that every publisher of its three panel
  messages is itself a stood-down path, so a live subscription would listen for messages that can no
  longer be sent (`settings/OptionsShim.lua:252-261`), and MultiMeters builds its profile-refresh
  receiver on its tracked factory (`settings/Profiles.lua:121`), and KickCD unregisters its Spells
  page's messages in `Spells.StandDown` and re-arms them on stand-up (`settings/Spells.lua:1422-1437`). `LibKa0s-Bus-1.0` does not decide
  it: a host picks by building the receiver on the tracked `bus:NewTarget()` or on its own untracked
  factory (architecture-§4). The natural home for a ruling is slash-commands-§7's survivor list.
  Until it is ruled, each host keeps the reading it has, and neither reading is a finding against it:
  a panel's subscription to its own refresh message left live across a stand-down is not filed under
  slash-commands-§7's *What MUST stand down*, and one taken down is not filed either.
- **Whether a runtime-critical major that calls nothing in Core should floor on it (recorded, not
  ruled).** Ten of the fifteen `LibKa0s` majors floor on `LibKa0s-Core-1.0` without calling a member
  (library-stack-§7), so that a partial payload leaves every module absent rather than a mixed set.
  `LibKa0s-Schema-1.0` is one of the ten, and so is `LibKa0s-Compat-1.0`, and the feature runtime
  reaches both while neither calls a Core member (`grep -l 'local NEEDS_CORE' LibKa0s/*.lua` in
  the library; no Core read in `Compat.lua` or `Schema.lua` beyond the floor). Schema's seam is read
  on a repaint pass; Compat's readers and guards are built for hot paths, and KickCD already calls
  its own `NS.Compat.GetSpellCooldown` (`modules/IconGrid_Render.lua:381`) from a 0.1 s
  `C_Timer.NewTicker` (`:961`), the call an adopter routes through the major. Without the floor, a
  payload missing `Core.lua` would lose the panel and the CLI and keep settings and spell reads. The
  question is for every runtime-critical major, not for Schema alone.
  **Reading A, keep the floor:** the fall-together property (the whole payload loads or none of it
  does), which options-ui-§1's composed-content ruling rested on through v2.64.0, and whole-folder
  vendoring (anti-pattern #48) makes a Core-less payload a defect rather than a state to design for;
  library-stack-§7 might then state the floor as a rule for every major.
  **Reading B, no floor for such a major:** a runtime-critical major that calls nothing in Core
  declares none, so a payload missing `Core.lua` still keeps settings and spell reads. Schema minor 1
  and Compat minor 1 floor today, as the majority convention does; that is the current state, not a
  ruling between the two readings.
