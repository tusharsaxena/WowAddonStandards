> Part of the **[Ka0s WoW Addon Standard](../STANDARDS.md)** — the split standard. Cross-references use the `filename-§N` form (see the index's section map).

## Open evolutions

Items recorded for future versions of this standard:

- ~~**Ka0s-Core sibling addon.**~~ **Settled, and settled the other way.** The AceGUI panel scaffold, the slash dispatcher, the debug console and the test-harness scaffolding are all extracted — as `LibKa0s-Options-1.0`, `LibKa0s-Slash-1.0`, `LibKa0s-DebugLog-1.0` and the shared `testkit/`, on top of `LibKa0s-Core-1.0`. They are a **vendored library**, not a sibling addon, because library-stack-§6 forbids requiring another addon to be installed. What remained open was the Schema runtime and the Compat templates, and at `LibKa0s v1.55.0` both moved: `LibKa0s-Compat-1.0` shipped as a **narrow** major, with the wide extraction measured and rejected (library-stack-§7's module table carries the measurement), and `LibKa0s-Schema-1.0` shipped the schema runtime's **portable half**, with the host half — root resolution and the write's announcement — staying per addon. Migration-stamp ownership, which neither major touches, was ruled at v2.65.0 without a library (below).
- **Shared luacheckrc base.** A `Ka0s-luacheckrc.lua` symlinked into every addon.
- **Shared vendored libs.** Once monorepo'd, vendor each lib once at the repo root and share it across addons rather than duplicating `libs/` per addon.
- ~~**Shared test scaffolding.**~~ **Shipped** as `testkit/` in the LibKa0s repo, vendored to each addon's `tests/_kit/` — the framework, the sandboxed loader and the universal WoW/Ace mock base (testing-§1).
- **Multi-zone profile model adoption** for group-context addons.
- ~~**Object pool standard** packaged as a copyable micro-lib.~~ **Shipped**, and not as a copyable micro-lib — as `LibKa0s-Pool-1.0`, in both the array and keyed shapes (library-stack-§7). A copyable micro-lib was the wrong answer for the same reason the pool needed doing at all: four copies shipped across two addons and one of them never returned anything to the free list, which a fifth copy would not have caught either.
- **Further `LibKa0s` modules.** `LibKa0s` is now the sanctioned path for shared Ka0s-owned code (library-stack-§7), and its per-module-major layout makes each addition independent and purely additive. Shipped so far: the secret-safe/printer seams (Core), the client-fact reader (Env), the widget pool (Pool), the item primitives (Item), the shared media catalog (Media), the flat dropdown, copy window, reorder list and drag handle (Widgets), the debug console and, from `LibKa0s v1.60.0`, the diagnostics-report helper (DebugLog), the slash dispatcher (Slash), the options toolkit (Options), the perf harness (Perf), the minimap/broker launcher (Launcher) and the stand-down latch (Lifecycle), from `LibKa0s v1.55.0` the version-variant readers and secret guards (Compat), the bus stand-down record and strict message catalog (Bus) and the schema runtime's portable half (Schema), and from `LibKa0s v1.75.0` the flat search box and test-mode strip (Widgets), the bonus ids of a link (Item), the stateless LibCustomGlow driver (Glow) and the in-game simulator's core (Sim), from `LibKa0s v1.77.0` the settings-panel Keybindings tab and the one strata tooltip (Options), and from `LibKa0s v1.78.0` the skin engine (Skin) and the Skin tab (Options) — **eighteen majors across fifty-one files** (recounted for `LibKa0s v1.78.0` from `LibKa0s/tests/majors.lua` and `LibKa0s/LibKa0s.xml`, library-stack-§7), plus the non-code `media/` payload. The three candidates this entry used to name each moved, and each only in part. **`Compat`: a narrow major shipped; the wide extraction was measured and rejected** — the nine `core/Compat.lua` copies hold 2820 lines (`wc -l */core/Compat.lua` over the collection), of which the absorbed members occupy 248 (330 with the two `core/Secrets.lua` seams), summed from the per-member `file:line` spans in `Ka0sAddonsCommonTasks` `docs/2026-09-22-SUITE_STANDARDS_AND_LIBKA0S_SWEEP/3b-specs/compat.md`, §1 *Measurements* (commit `79ed441`), each span counted `end − start + 1`: the nine copies' rows sum to 248 and the two `Secrets.lua` rows to 82 (library-stack-§7), and the rest is single-consumer, content-free or disagreed-on. **The bus: the stand-down record and the catalog shipped**; the untracked host factory stays host code (architecture-§4). **`Schema`: the portable half shipped**; root resolution and announcement stay per addon, and **migration stamps were ruled at v2.65.0 in the standard's template, not in a library** (below). What the collection still duplicates beyond those is what each major's API document lists under what it leaves out. Each is its own decision, adopted on its own schedule — deliberately **not** a lockstep migration, and deliberately not a `Ka0s-Core` addon (library-stack-§6 forbids requiring another addon).
  - **Recorded rejections, LibKa0s#46–#58 (2026-10-22).** Each line names the bar it failed (library-stack-§7's bars 1–3, frequency alone, or a correctness disagreement) and the trigger that reopens it; none carries an API sketch, so no later nomination is anchored to one. The full record of each is the issue's closing comment or the API document of the major it would have joined.
    - **#49 chat sender.** No content: the fallback rung is unreachable on every admitted client. Re-check when the send API moves again and the second rung becomes reachable, or a third addon sends chat through the API with the same resolution.
    - **#49 tooltip line reader and duration decoder.** Bar 1, one consumer. Re-check when a second addon reads tooltip lines with the same first-answer semantics, or decodes a whole localized duration sentence.
    - **#49 restriction tracker.** Bar 3: a same-author copy under ten days old, its edges already diverged. Re-check when at least two of these hold: a third addon, not a copy, needs a restriction answer set; the two copies converge on one announce edge and one answer set; 12.2 ships with no change to `Enum.AddOnRestrictionType`, the event payload or the chat-blocking classification.
    - **#49 the four restriction readers.** Guards: promotion removes no host line. Re-check when a non-copy addon needs the absent and secret answers and the three readers reconcile.
    - **#49 GlobalString-to-pattern compiler.** Bar 1, the consumers disagree (positional mapping, anchoring). Re-check when a locale or a positional GlobalString breaks one of the non-positional copies.
    - **#49 / #51 loot-line parser.** Correctness disagreement (crafting and refund lines). Re-check when the consumers agree in writing on which line kinds are receipts.
    - **#50 mixed grid composer.** Bar 1, one consumer, and the issue's premise is gone. Re-check when a second addon ships a fixed row set crossed with setting columns of different maker types; re-run the census whenever an addon joins the roster.
    - **#51 the other item reads** (LinkDetail/BetterLink, IdentityKey/SameItem, EffectiveItemLevel, ItemLevelAt/QualityAt, QualityOf, the Wowhead URL). Bar 1, a single consumer, or disagreeing semantics, or a simulator bypass. Re-check per read when a second addon needs it with the same semantics.
    - **#52 flat checkbox.** Bar 1, no consumer. Re-check when a second standalone window hand-builds one beside a `Dropdown`.
    - **#52 exported flat skin.** High frequency, low content, and the themes disagree. Re-check when a third flat control outside the library copies the literals.
    - **#48 shared tone table.** False premise. Re-check only on a new nomination that shows two test markers needing the same tones with the same meaning.
    - **#53 exporting the step constants.** Superseded by the Sim-private step panel (the library's step-panel spike took outcome B). Re-check when a second consumer can take the renderer with no edit to its suites.
    - **#54 "safety rules enforced by the library".** Now a host contract in preview-mode. Re-check only when a library-level hook can see a host's sends, saved writes or world without the host routing them, which no addon framework offers.
    - **#56 IconStyle.** Bars 1 and 2: every consumer means something different. Re-check when two hosts converge on one icon look with the same semantics.
    - **#56 glow lifecycle and signature layer.** Bars 1–3: disagreeing no-op policies, and it writes LibCustomGlow's private state. Re-check when two hosts share one change-detection key, or LibCustomGlow publishes a supported burst suppression.
    - **#56 `GLOW_STYLES` / `GLOW_KNOBS` defaults and catalogs.** Profile-owned, and the hosts disagree. Re-check when a fourth host copies the knob table, or the ranges drift apart.
    - **#56 `O.GlowGroup`.** No canonical glow block in options-ui. Re-check when options-ui gains one, or two hosts converge on one glow row layout.
    - **#56 LibSharedMedia `"Solid"` registration.** Frequency alone: one line at four sites. Re-check when an addon registers `"Solid"` with a different texture.
    - **#58 key-binding helper.** See launcher-§6. Re-check when two addons' binding buttons diverge in a correctness way after the rollout.
    - **#47 the lizard shape detector and the sanitizer rewrite.** Zero instances, and the rewrite under-counts CCN. Re-check at the first authored file that crashes `lizard` on that shape.
    - **#55 picker-credit helper.** `all` is reserved to one addon. Re-check when a second addon ships a player-facing icon chooser, and so earns `all`.
- **A per-addon adoption command.** Still open, and now broader than when it was written: adoption spans eighteen majors rather than one, and most of the newer ones **delete files the addon owns** rather than only adding a descriptor — which is harder to script safely and more valuable to keep identical across addons. `LibKa0s/docs/adoption-prompt.md` carries the per-addon survey and hazards in the meantime.
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
  header is a **library** change that lands in every addon at once, and doing it per addon would mean
  every host reaching into the panel a library builds — exactly what options-ui exists to prevent.
  What to settle before it moves: which controls genuinely benefit (a reset, a copy-from, a page
  header's category mark) versus which are labels that should stay labels; whether the descriptor
  gains a per-row `icon` field or the library picks marks by row type; and whether a host may override
  one, given that the panel is the surface a user compares across addons least often and the strip of
  a main window most. Do it as one library minor with a screenshot of every affected page, not as a
  rolling adoption.

- **Whether an unlock anchor has to be the library's handle.** `LibKa0s-Widgets-1.0` ships two drag
  surfaces and the standard mandates one of them. options-ui-§18 requires `ReorderList` wherever the
  **order** of a list is the setting, and four addons consume it (as measured on 2026-10-10). `DragHandle` — the labeled strip a
  player drags to move a positionable frame, with its geometry published as `DRAG_HANDLE` — is
  required nowhere, and four addons consume it while eight do not. The extraction bar was already
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

  From `LibKa0s v1.82.0` the library's handle re-measures its title in its own font on every skin
  repaint, so it fits under every shipped skin (skinning-§4, *Text width is skin-invariant*), and a
  `LibKa0s` issue checks every addon's anchors once the faces and sizes are frozen (the run of
  2026-10-30, below). Re-check this question when that issue closes.

- **The schema write seam's name and call style (recorded, not ruled).** The standard names the seam
  twice and two ways. architecture-§5 reads *"one helper: `NS.Schema:Set(path, value)`"* — a colon
  method on `NS.Schema`; slash-commands-§3's descriptor example reads `set = function(path, v)
  NS.SetByPath(path, v) end` and calls that *the single write seam* — a free function. The
  collection held both, and three more, when this was recorded. Measured on 2026-09-23 (each citation
  below is pinned to the commit read that day) as the function each of the eleven addons' Options
  and Slash descriptors bind as `set` (`git -C <repo> grep -nE -A3 '^\s*set\s*=' --
  settings/OptionsSetup.lua settings/Slash.lua`), the seam is spelled five ways, one of them
  colon-called: **`NS.Schema:Set`** in BankLedger, LootHistory and PanelMaster (`git -C <repo> grep
  -oE 'NS\.Schema:Set\b' -- '*.lua' ':!libs' | wc -l`: 63, 103 and 41); **`NS.SetByPath`** in
  AbsorbTracker, AuraMaster, MultiMeters and PartyFrameEnhanced; a dot-called **`NS.Schema.Set`** in
  PrettyChat (defined `PrettyChat@bc9669c0b1:settings/Schema.lua:636`); a dot-called
  **`Helpers.Set(path, value, opts)`** in WhatGroup (defined `WhatGroup@d7f95edead:settings/Schema.lua:451`,
  bound `WhatGroup@d7f95edead:settings/OptionsSetup.lua:195` and
  `WhatGroup@d7f95edead:settings/Slash.lua:233`; 55 call sites, `git -C WhatGroup grep -hoE 'Helpers\.Set\(' -- '*.lua'
  ':!libs' | wc -l`); and a dot-called **`Helpers.SetAndRefresh(path, value)`** in ConsumableMaster
  and KickCD (bound at `ConsumableMaster@189e2e5f3f:settings/OptionsSetup.lua:260` and
  `ConsumableMaster@189e2e5f3f:settings/Slash.lua:524`, `KickCD@b7c9223280:settings/OptionsSetup.lua:162`
  and `KickCD@b7c9223280:settings/Slash.lua:378`; defined `KickCD@b7c9223280:settings/Panel_Render.lua:273`). Two of those
  hosts carried a second name beside the bound one. ConsumableMaster also published a colon
  `KCM.Schema:Set` (`ConsumableMaster@189e2e5f3f:settings/Panel.lua:1069`) that forwards to
  `Helpers.SetAndRefresh`. KickCD's `Helpers.Set(path, section, value)`
  (`KickCD@b7c9223280:settings/Panel.lua:380`) was the store writer beneath its seam, called from
  `KickCD@b7c9223280:settings/Panel_Render.lua:263`, and was bound by neither descriptor. `LibKa0s-Schema-1.0`'s member is **`inst.Set(path, value,
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
  A panel's subscription to its own refresh message sits between the two, and the collection read
  it both ways when this was recorded (each citation below is pinned to the commit read on
  2026-09-23). **Kept live, as part of the panel body:** BankLedger names *"the panel body with its
  own live-refresh target"* as setup (`BankLedger@0aae6b6221:core/BankLedger.lua:137`; the target at
  `BankLedger@0aae6b6221:settings/Panel.lua:165`), and LootHistory (`LootHistory@dbcde6180b:settings/Panel.lua:154`),
  AuraMaster (`AuraMaster@e93bf279b1:settings/OptionsSetup.lua:395`) and PanelMaster
  (`PanelMaster@eb4b4a8423:settings/PanelEditor.lua:1441-1444`, pinned as the panel body at
  `PanelMaster@eb4b4a8423:tests/test_disabled.lua:49`) built theirs on an untracked factory the stand-down
  does not reach. **Taken down, as feature:** ConsumableMaster argues that every publisher of its three panel
  messages is itself a stood-down path, so a live subscription would listen for messages that can no
  longer be sent (`ConsumableMaster@189e2e5f3f:settings/OptionsShim.lua:252-261`), and MultiMeters
  built its profile-refresh receiver on its tracked factory
  (`MultiMeters@d17a8f83ba:settings/Profiles.lua:121`), and KickCD unregistered its Spells page's
  messages in `Spells.StandDown` and re-armed them on stand-up
  (`KickCD@b7c9223280:settings/Spells.lua:1422-1437`). `LibKa0s-Bus-1.0` does not decide
  it: a host picks by building the receiver on the tracked `bus:NewTarget()` or on its own untracked
  factory (architecture-§4). The natural home for a ruling is slash-commands-§7's survivor list.
  Until it is ruled, each host keeps the reading it has, and neither reading is a finding against it:
  a panel's subscription to its own refresh message left live across a stand-down is not filed under
  slash-commands-§7's *What MUST stand down*, and one taken down is not filed either.
- **Whether a runtime-critical major that calls nothing in Core should floor on it (recorded, not
  ruled).** Ten of the eighteen `LibKa0s` majors floor on `LibKa0s-Core-1.0` without calling a member
  (library-stack-§7), so that a partial payload leaves every module absent rather than a mixed set.
  `LibKa0s-Schema-1.0` is one of the ten (eleven until `LibKa0s v1.77.0`, when `Options` began
  reading Core's `SafeRegisterEvent`), and so is `LibKa0s-Compat-1.0`, and the feature runtime
  reaches both while neither calls a Core member (`grep -l 'local NEEDS_CORE' LibKa0s/*.lua` in
  the library; no Core read in `Compat.lua` or `Schema.lua` beyond the floor). Schema's seam is read
  on a repaint pass; Compat's readers and guards are built for hot paths, and KickCD called
  its own `NS.Compat.GetSpellCooldown` (`KickCD@b7c9223280:modules/IconGrid_Render.lua:381`) from a
  0.1 s `C_Timer.NewTicker` (`KickCD@b7c9223280:modules/IconGrid_Render.lua:961`) when this was
  recorded (2026-09-23), the call an adopter routes through the major. Without the floor, a
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
- **Whether an adopted major needs a full library-absent stub (recorded, not ruled).** library-stack's
  *Ship payload vs adoption* has each setup file degrade to a stub when its major is absent;
  slash-commands-§1 requires the Slash stub to carry every member the addon calls, and testing-§8's
  stub-surface parity case pins each adopted module's stub against the live surface. Libraries are
  vendored and committed, and `.pkgmeta` declares no `externals:` block (library-stack-§3, packaging), so
  a no-lib package has no external to strip and packaging never produces a library-less install; some
  addons, PrettyChat among them, also set `enable-nolib-creation: no`. A major still goes absent
  through a **load or floor failure**: a module that misses its `LibKa0s-Core-1.0` floor, or raises at
  load against a drifted client API, does not register, and its stub is what answers. The cost is not
  small. PrettyChat's 2026-10-07 review (`PrettyChat docs/reviews/2026-10-07/01_FINDINGS.md`, F-008) counted about 758 lines of stubs across
  its setup files, `settings/Slash.lua` and `settings/Schema.lua`, the last re-implementing
  `Set`, `SetMany` and `BulkRun`, plus the parity suite that keeps them honest. The question: given that
  a major goes absent only through such a failure, should an adopted major still need a full
  member-answering stub plus a parity case, or would a one-line refusal at the addon's entry points
  (the slash command, the settings panel, the feature's enable) be enough? A refusal is cheaper and
  cannot drift from the live surface, but it gives up the partial function a stub keeps, such as host
  verbs that still answer. No rule changes until this is ruled: the stubs and parity cases stay
  required, and a host carrying a full stub is not a finding.
- **A library context menu, `W.ContextMenu` (recorded, not ruled).** Two addons, LootHistory and
  BankLedger, hand-build an identical right-click row menu over a full-screen click catcher, the
  shape frame-layering-§4 forbids. A `LibKa0s-Widgets-1.0` `ContextMenu` would be a new widget
  surface, and both addons can take the local fix in the 2026-10-24 run: drop the catcher and dismiss
  on `GLOBAL_MOUSE_DOWN`, ignoring presses inside the menu. Re-check when a third addon builds a row
  context menu, or the two local menus diverge in shape.
- **A StaticPopup lift-while-shown helper (recorded, not ruled).** QuickComms lifts a borrowed
  Blizzard confirmation above its own `DIALOG` band while it is shown and restores the recorded
  strata on hide (`ModalWindow.LiftConfirm`), the one strata switch frame-layering-§4 allows.
  PremadeGroupsFilterExtension may need the same, pending an in-client confirmation. Promote the
  helper into `LibKa0s` if a second addon confirms the case in the client.
- **A guarded `LevelOf(frame, fallback)` (recorded, not ruled).** A frame-level read made secret-safe
  and forbidden-frame-safe, answering the fallback when the level cannot be read (frame-layering-§1,
  host-matched surfaces; events-frames-taint-§8). One consumer, AuraMaster, so it stays local.
  Re-check when a second addon reads another addon's or Blizzard's frame levels under the same guard.
- **A `strata` option on the library's tool windows and copy window (recorded, not ruled).** A
  `strata` field on the `LibKa0s-DebugLog-1.0` and `LibKa0s-Perf-1.0` descriptors and on
  `LibKa0s-Widgets-1.0` `CopyWindow`, default unchanged, with the console's copy window opening one
  strata above whatever the console uses, for an addon whose own surface sits at `DIALOG` or above
  (QuickComms' dial, PremadeGroupsFilterExtension's surface at `FULLSCREEN`). Both cases are
  developer-facing, so it is not in `LibKa0s v1.77.0` (STRATA_MODEL LK-05, Ka0sAddonsCommonTasks
  `docs/2026-10-24-KEYBINDS_LAYOUT_STRATA/`); until then such an addon says in its layers table's
  comment that the surface can cover the console (debug-logging, frame-layering-§5). Re-check when a player-facing surface of an addon sits at `DIALOG` or
  above and its console is covered in the client.
- **A `PageBanner` that takes several acts (recorded, not ruled).** A band holding a picker plus
  enable, link and copy acts draws one `O.PageHeader` block today (U-08(d), Ka0sAddonsCommonTasks
  `docs/2026-10-24-KEYBINDS_LAYOUT_STRATA/`); a `PageBanner{ acts = { ... } }` arm would keep the
  picker library-drawn beside them. Not ruled at v2.88.0: one accepted change needed it and expressed
  it with `PageHeader`, and the library's tabbed-page file is at its size re-check trigger. Re-check
  when a second addon's band needs it.
- **Gating a swatch on its feature's own switch (deferred, owner call CALL-05).** options-ui-§17
  forbids `disabledIf` on a color row because the swatch's alpha survives class color; where the
  whole feature is off, though, the swatch is truly not read (U-13). The proposal: allow gating a
  swatch on its feature's on/off row, never on its class-color companion. Not ruled at v2.88.0: the
  owner deferred it to an issue,
  <https://github.com/tusharsaxena/WowAddonStandards/issues/13>. Re-check when that issue is triaged.
- **Flow-engine seams for host blocks (recorded, not ruled).** An after-subgroup hook, a
  before-group hook, a schema `note` row drawn dim and full width and skipped by `/list`, and a
  Position-block composer (U-14). Not ruled at v2.88.0: every change that wanted one landed on
  existing seams (two `RenderRows` slices, an after-group `TextRow`, a host-drawn position block),
  and the flow engine's file is at its re-check trigger, so a seam there is a peel. Re-check with the
  first layout that cannot be expressed on today's seams.
- **A library line naming what is account-wide (recorded, not ruled).** An optional library-drawn
  line above the AceDBOptions group listing what is account-wide, from a descriptor field (U-15).
  Not ruled at v2.88.0: it fell below the run's confidence threshold and one addon asked for it.
  Re-check when a second addon asks for it.
- ~~**The collection's skin rollout.**~~ **Shipped.** `skinning` (v2.89.0) binds an addon from its
  adoption. The first run converted LootHistory as the prototype, Ka0s Skin Tester adopted at its
  creation, and the rollout run (Ka0sAddonsCommonTasks `docs/2026-10-29-SKINNING_ROLLOUT/`, branch
  `feat/2026-10-29-skinning-rollout`) adopted the fourteen other roster addons on `LibKa0s v1.80.0`
  under the owner rulings of 2026-10-29: **O2**, skinning-§6's one-time HUD style reset kept; **O3**,
  the first-run skin picker shown to every player; **O4**, PremadeGroupsFilterExtension's own
  EllesmereUI bridge retired for the library's `eui` source, its saved choice migrated and its
  ratified register row (library-stack-§6) retired with it. The run merged on 2026-10-29 and
  `v1.80.0` is tagged. Each addon is bound from the commit that adopted, as skinning-§8 says.
- ~~**The skinning rollout's library follow-ups.**~~ **Shipped.** The rollout left nine
  `LibKa0s` follow-ups and one open call. The follow-up run (Ka0sAddonsCommonTasks
  `docs/2026-10-30-SKIN_LIBRARY_FOLLOWUPS/`, branch `feat/2026-10-30-skin-library-followups` in
  every repo it touches) fixes them in `LibKa0s v1.81.0` and re-vendors every adopted addon onto it,
  each deleting the workarounds the release makes unnecessary. The owner's rulings of 2026-10-30
  that change the standard are ruled at v2.92.0: the tab is labeled **Skin** (skinning-§3); the stock
  look under Ka0s Default is retired with `opts.stockDefault`, the stock look being the WoW Default
  skin, while the Scope's *Ignore settings panel* stays and defaults to on (skinning-§1,
  skinning-§3, skinning-§4); *Ignore fonts* covers the HUD (skinning-§6); every custom library widget
  is skinned and obeys the Scope, which covers the settings panel and nothing else for the panel
  half and every string for the fonts half (skinning-§1, skinning-§3); and every skin has a HUD face
  of its own (skinning-§4). The rest are library fixes with no rule to change: the close button
  restores the art's own tint, `Skin.ResetToSkin` leaves an absent bool companion a bool, the drag
  handle's tooltip and the library's other tooltip lines take the skin's tooltip colors, the `q.*`
  tokens match the client's quality colors exactly, `Skin:DrawsKey(owner)` is public, and the
  first-run picker's title reads "Choose a skin" with the addon's name on its own line above the
  dropdown. These rules bind an adopted addon from its re-vendor of `v1.81.0`. The run merged on
  2026-10-30, `v1.81.0` is tagged, and the owner's smoke pass is recorded in its bundle.
- **Skin fonts and the owner's feedback (in progress, recorded).** The owner's batch of 2026-10-30,
  given after the follow-ups' smoke pass (Ka0sAddonsCommonTasks `docs/2026-10-30-SKIN_FONTS_AND_FEEDBACK/`,
  branch `feat/2026-10-30-skin-fonts-feedback` in every repo it touches), ships in `LibKa0s v1.82.0`
  and re-vendors every adopted addon onto it. Its rulings that change the standard are ruled at
  v2.93.0: three faces ship and the unused ones leave the payload, under a license rule
  (library-stack-§8); each skin's faces are named (skinning-§4); text width and HUD sizes are
  skin-invariant, measured with the outline on (skinning-§4); an enabled button reads as enabled in
  every skin (skinning-§4); a skin change resets the overrides, and the *Font outline* choice joins
  the Skin tab (skinning-§3, skinning-§6); every font setting is the whole block, its flags following
  the skin by default (options-ui-§16); `/<slash> skin` is reserved (slash-commands-§2,
  skinning-§3); a HUD display may go unmarked in test mode and carries no simulation marker
  (preview-mode); sections a choice does not use are hidden (options-ui-§22); and displayed strings
  keep to the characters every shipped face draws (localization-§7). Its `LibKa0s` issues, filed
  after the release: the conditional-sections sweep across every addon (options-ui-§22), the
  anchor-width check across every addon (above) and the real Friz Quadrata measurement (next entry).
  These rules bind an adopted addon from its re-vendor of `v1.82.0`, not yet tagged. Re-check when the
  run merges: close this entry.
- **WoW Default's sizes against real Friz Quadrata (recorded, not ruled).** Width parity
  (skinning-§4) holds every skin's sizes to Ka0s Default's widths, but on the owner's client the file
  at `Fonts/FRIZQT__.TTF` is byte-identical to Ka0s Prototype, so the face the WoW Default skin
  actually draws has not been measured, and neither has its character coverage (localization-§7).
  WoW Default's sizes stay as they were. Re-check when the `LibKa0s` measurement issue filed by the
  run above closes.
- **Ka0s Default's split tokens (recorded, not ruled).** Where two call sites drew one role in two
  colors before skins, Ka0s Default keeps both values as two tokens, so that adopting changes no
  pixel; the list is in `LibKa0s` `docs/api/Skin`. Each pair is a candidate to merge into one token
  in the rollout, which is a visible change to Ka0s Default and so a standard change first
  (standalone-windows, *The Ka0s window edge*). Re-check pair by pair as the rollout reaches the
  addons that draw them.
- **The WoW Forever client (recorded, not ruled).** The *WoW Forever* skin is a look usable on
  retail (skinning-§4). Running Ka0s addons on the WoW Forever client itself is not supported:
  `SetDesaturation` is missing there, which breaks every AceGUI checkbox, and the work is tracked in
  LibKa0s#44. Re-check when that issue moves.
