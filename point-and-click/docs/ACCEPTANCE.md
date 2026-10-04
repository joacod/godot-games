# Acceptance evidence

## Step 01 — 2026-10-03

Foundation complete: standalone static stage, five labeled placeholder hotspots,
project-local JSON definitions and validation before room construction.
OpenSpec tasks 1.1–1.6 are complete; all later tasks remain pending.

Engine: `4.7.2.stable.official.ed1daf0bf`. Compatibility renderer, OpenGL 4.1
on Apple M2. Logical viewport 640×360; native window content 1280×720.
`canvas_items` stretching retains the logical layout and renders text at window
resolution. No shared runtime resources or new dependencies were added.

### Automated checks

Run from `point-and-click/`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd -- --capture-dir=/tmp/closed-gate-step01-evidence
```

- Import passed with no script/resource errors in the final run.
- Headless suite: **126 passed, 0 failed**. Native suite: **128 passed, 0 failed**;
  the extra two checks save actual native-rendered viewport images.
- Negative fixtures cover malformed JSON, non-object roots, missing files/fields,
  duplicate hotspot/item/speaker/node/rule IDs, invalid value types, unknown keys,
  invalid polygons, local scene constraints, unresolved speaker/node/flag/item/
  target references, unsupported verbs and unknown effects.
- Startup checks confirm invalid content produces no partial room or props and
  shows a file-specific error panel. Valid content builds five independent props
  and disabled, ID-bearing collision regions. Input actions and fixed camera
  framing are checked. No effects or run-state mechanics execute in this step.
- Generated `.gd.uid` files are retained for `scripts/main.gd`,
  `scripts/content_loader.gd` and `tests/run_tests.gd`; no script UID is missing.

The first restricted import encountered macOS application-data/editor-setting
permissions and a script naming collision with `RefCounted.reference()`.
The helper was renamed; subsequent checks ran with normal Godot application-data
access. A collinear polygon fixture exposed a geometry-validation gap, now
rejected with an explicit area check. Final commands above passed.

### Native visual and input evidence

The normal native launch command (`--path .`) displayed the fixed room. Agent
inspection through computer use confirmed readable title, subtitle, all five
labels and foundation status text, with no clipping or off-screen props at the
target size. Native left-click, right-click and Escape left the static room
unchanged, as expected before Step 02 dispatch. This confirms a foundation
input smoke check, not functional verbs, hover names, cancellation or pause UI.
Native launch and test runs reported no project/runtime errors.

The captured native test viewports were separately inspected for room readability
and a readable error panel with no partially displayed stage:

![Step 01 fixed room with five labeled placeholder props](evidence/step01-room.png)

![Startup error panel naming four missing content files](evidence/step01-content-error.png)

### Independent copy

The whole folder was copied without `.godot/` to the temporary directory
`/var/folders/l1/llh3yrws3q9gmq_bq9cp_klm0000gn/T/closed-gate-step01-tnso91kc/point-and-click`.
Fresh import and headless checks passed there (**126/126**), and the native
project process started with Compatibility rendering and no missing-resource
errors. The final native capture suite also passed in the copy (**128/128**);
its room and error-panel image hashes match the inspected source captures.
The source native window supplied computer-use visual/input evidence; no separate
physical input acceptance is claimed for the copy. All runtime scene paths
resolve within `res://`; repository planning links are not runtime dependencies.
The full isolated-copy completion/reskin route remains Step 06 work.

### Remaining gaps

- Human acceptance and timed playthrough are pending; there is no playable
  puzzle chain in Step 01. Look/Use/Talk, inventory, dialogue, pause, restart and
  completion remain Steps 02–05 work.
- No controller check was performed; controller support is outside this slice.
- CraftPix art remains a researched candidate; no imported-asset or license
  acceptance is claimed. See [provenance](../assets/PROVENANCE.md).
- Later-step acceptance items in DESIGN.md remain unchecked.

## Step 01 label bounds correction — 2026-10-03

Label placement and width now use the hotspot polygon's bounding rectangle,
so changing its starting vertex does not change the label layout. The authored
room geometry and later-step status are unchanged.

- Import passed with no script/resource errors using Godot 4.7.2.
- The current headless suite passed **128/128**; the native capture suite passed
  **130/130**. Two new checks validate reordered content and compare the label's
  position and size with the original layout.
- Native room and error-panel captures were inspected for readability. Captures
  are temporary outputs under `/private/tmp/closed-gate-label-bounds-evidence`;
  the original Step 01 evidence images above are retained.
- No new human playthrough, live mouse-input acceptance, or isolated-copy check
  was performed for this correction. Steps 02–06 remain pending.

## Files changed for Step 01

Only this game and its OpenSpec task checklist changed:

- `point-and-click/.gitignore`
- `point-and-click/README.md`
- `point-and-click/assets/PROVENANCE.md`
- `point-and-click/data/dialogue.json`
- `point-and-click/data/items.json`
- `point-and-click/data/puzzle.json`
- `point-and-click/data/room.json`
- `point-and-click/data/theme.tres`
- `point-and-click/docs/ACCEPTANCE.md`
- `point-and-click/docs/evidence/step01-content-error.png`
- `point-and-click/docs/evidence/step01-content-error.png.import`
- `point-and-click/docs/evidence/step01-room.png`
- `point-and-click/docs/evidence/step01-room.png.import`
- `point-and-click/project.godot`
- `point-and-click/scenes/main.tscn`
- `point-and-click/scenes/room.tscn`
- `point-and-click/scenes/visuals/background.tscn`
- `point-and-click/scenes/visuals/clerk.tscn`
- `point-and-click/scenes/visuals/gate.tscn`
- `point-and-click/scenes/visuals/noticeboard.tscn`
- `point-and-click/scenes/visuals/oil.tscn`
- `point-and-click/scenes/visuals/pass.tscn`
- `point-and-click/scenes/visuals/press.tscn`
- `point-and-click/scripts/content_loader.gd`
- `point-and-click/scripts/content_loader.gd.uid`
- `point-and-click/scripts/main.gd`
- `point-and-click/scripts/main.gd.uid`
- `point-and-click/tests/run_tests.gd`
- `point-and-click/tests/run_tests.gd.uid`
- `openspec/changes/add-point-and-click/tasks.md`
- `point-and-click/docs/DESIGN.md`
- `point-and-click/docs/STEPS.md`
- `point-and-click/docs/steps/01-foundation.md`

Sibling games, root guidance/configuration, OpenSpec requirements, and Step 02–06
guides were intentionally untouched. Git delivery is separate from foundation acceptance.

## Step 02 — 2026-10-03

Look/Use/Talk dispatch complete; OpenSpec tasks 2.1–2.5 are checked. Steps 03–06
remain pending. Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility rendering,
640×360 logical viewport and 1280×720 native window are retained.

### Behavior

All five authored polygons support hover names and Look descriptions. The first
matching hotspot in `room.json` order wins overlaps. GUI controls consume clicks;
decorative controls ignore them. `Interaction.modal_open` clears hover and blocks
room dispatch, including direct calls; later dialogue UI will own this lock.

Dispatch executes only unconditional, text-only rules with no selected item.
Use on the press/gate shows an authored clue; other Use/Talk requests show the
verb's authored fallback. Conditional, mixed-effect, item, flag, dialogue and
completion rules remain inactive, so oil is not picked up and progress never
changes. No puzzle or dialogue strings live in mechanics scripts.

### Automated verification

Run from `point-and-click/`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd -- --capture-dir=/private/tmp/closed-gate-step02-evidence
```

- Import passed with no script/resource errors using normal application-data
  access. The first restricted attempt could not save macOS editor settings.
- Final headless suite: **179 passed, 0 failed**. Final native suite:
  **181 passed, 0 failed**, including two viewport image saves.
- Retained foundation checks and added all-prop center/edge discovery, Look
  rendering, Use/Talk feedback, no content/progress mutation, invalid target/verb
  handling, deterministic overlap, exclusive verb selection, mixed-effect and
  conditional-rule deferral, and data-text replacement.
- Injected viewport events verify hover, one room dispatch per click, verb GUI
  selection, no verb-click dispatch, overlay click consumption, modal blocking
  and resumed room input. These are automated event-routing checks.
- New scripts retain generated UIDs: `scripts/hotspot.gd`,
  `scripts/interaction.gd`, `scripts/interaction_ui.gd`,
  `tests/interaction_test.gd`. No script UID is missing.

### Native visual and input evidence

Agent computer-use clicks in the native game confirmed hover/readable feedback
for all five hotspots (oil, press, clerk, noticeboard and gate), explicit Talk
selection with the gate's unsupported-action response, and Use selection with
the press clue. Props and camera stayed fixed. Native captures of the room and
startup error panel were separately inspected for readable text and no clipping.
Captures are temporary outputs at `/private/tmp/closed-gate-step02-evidence`.

The Godot MCP reported version 4.7.2, launched this exact project, and returned
no debug errors. This establishes a native launch/debug smoke check separately
from computer-use input and visual inspection. No controller or human playthrough
is claimed. Modal/overlap fixtures were checked by injected events, not a finished
dialogue UI. The independent-copy/reskin route remains Step 06 work.

### Changed files and follow-ups

- Runtime: `scripts/main.gd`, `scripts/hotspot.gd`, `scripts/interaction.gd`,
  `scripts/interaction_ui.gd`, `scenes/main.tscn`, `scenes/hotspot.tscn`,
  `scenes/ui/verbs.tscn`, `data/theme.tres`, and new script UIDs.
- Verification: `tests/run_tests.gd`, `tests/interaction_test.gd` and its UID.
- Documentation: `README.md`, `docs/DESIGN.md`, `docs/STEPS.md`,
  `docs/steps/02-hotspots-and-verbs.md`, this evidence record and the OpenSpec
  task checklist.
- Intentionally untouched: other games, engine/renderer configuration, JSON
  schemas/content, content loader, prop art/provenance, OpenSpec requirements,
  and later-step guides. No dependency, downloaded asset, branch, commit, push
  or PR was added.
- Next: Step 03, six-slot inventory and atomic item use. Human timed puzzle
  acceptance and independent-copy completion remain later work.


## Step 03 — 2026-10-03

Six-slot inventory and atomic item use complete; OpenSpec tasks 3.1–3.6 are
checked. Steps 04–06 remain pending. Godot `4.7.2.stable.official.ed1daf0bf`,
Compatibility renderer and the 640×360 logical / 1280×720 native view are retained.

### Behavior and files changed

- New runtime files: `scripts/inventory.gd`, `scripts/puzzle_state.gd`,
  `scripts/inventory_ui.gd`, `scenes/ui/inventory_bar.tscn`, and generated script UIDs.
- Integrated runtime: `scripts/main.gd`, `scripts/interaction.gd`,
  `scripts/interaction_ui.gd`, `scenes/main.tscn`, `scenes/ui/verbs.tscn`.
- Content: `data/puzzle.json` adds pickup feedback and state-specific press text;
  `data/theme.tres` adds selection/repaired labels and current instructions;
  `data/room.json` moves oil, press and clerk clear of the new UI row.
- Tests: new `tests/inventory_actions_test.gd` and its UID,
  `tests/interaction_test.gd` updates Step 02 expectations for supported conditions
  while retaining routing/discovery coverage; `tests/run_tests.gd` runs both suites.
- Documentation: `README.md`, `docs/DESIGN.md`, `docs/STEPS.md`, this record,
  `docs/steps/03-inventory-and-actions.md`, and the OpenSpec task checklist.

Pickup validates capacity before committing oil and its flag. A successful pickup
hides its visual, label and hotspot. Selecting oil shows Use Oil flask with the
hovered target; right-click clears selection. Oil on clerk/unsupported targets
preserves oil, while oil on press consumes it and repairs once. Repair raises the
press ram and updates its label; later bare Use/Look gives repaired feedback.
There is no discard action. Transactions stage the entire rule and publish
signals after both stores commit; deferred dialogue/completion effects reject
an entire rule rather than executing a partial change.

### Verification

Run from `point-and-click/`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd -- --capture-dir=/private/tmp/closed-gate-step03-evidence
```

- Final import passed without script/resource errors. Final headless suite:
  **211 passed, 0 failed**. Final native suite: **215 passed, 0 failed**, including
  four saved viewport captures (error, initial room, selected oil, repaired press).
- Fixtures prove full pickup preserves oil availability and flags, six-item cap,
  unique/known IDs, failed late effects roll back without signals, duplicate grants
  preserve reward flags, wrong targets retain oil, repeated repair is rejected,
  observers see a complete transaction, and loaded content stays unchanged.
- Injected viewport events verify pickup, inventory selection, cancellation,
  normal verb restoration, modal blocking and inventory click-through prevention.
  The capacity fixture uses six unique test IDs; shipped content has two item IDs.
- All four native captures were inspected: readable item slot/prompt, repaired
  label/ram, feedback and error panel, with no controls covering clickable props.
  Captures remain temporary at `/private/tmp/closed-gate-step03-evidence`.
- Agent computer-use mouse input independently confirmed pickup, selecting oil,
  oil-on-clerk response while retaining the item, right-click cancellation,
  oil-on-press repair, empty inventory after consumption and repeated bare Use
  feedback. This is native input evidence, not a human timed playthrough.
- Godot MCP confirmed 4.7.2, launched this project and returned no final debug
  errors. This launch/debug check is separate from visual and input evidence.
- All four new script UIDs are retained; no script UID is missing.

The first restricted import exposed one type-inference error and macOS
application-data permissions. The type was made explicit, and final checks ran
with normal Godot application-data access. Two fixture expectations initially
referenced the wrong JSON array indices; corrected expectations passed. A debug
warning about an externally emitted inventory signal was resolved by giving its
publication an explicit method. Capture inspection found a prop/UI overlap;
local room positions and the item prompt were adjusted before final validation.

### Boundaries and follow-ups

Other games, engine/renderer settings, content schemas/loader, item/dialogue
JSON, prop art, asset provenance, OpenSpec requirements and later-step guides
are intentionally untouched. No dependencies, downloads, branch, commit, push
or PR were added. Inventory uses text slots and description tooltips; icon scenes
remain validated but are not rendered in this step.

Next is Step 04: clerk dialogue, pass reward and complete puzzle chain. Human
timed acceptance, controller checks, pause/restart and independent-copy completion
or reskin checks were not performed; their applicable later-step gates remain
pending. No full puzzle completion is claimed.
