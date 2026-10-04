# The Closed Gate

A complete standalone Godot point-and-click adventure: one fixed gatehouse,
five named placeholder props, Look/Use/Talk interactions, a six-slot inventory,
and one recoverable puzzle chain. Human playtest accepted on 2026-10-04; see
[acceptance evidence](docs/ACCEPTANCE.md).

## Run

Use Godot **4.7**; development checks use **4.7.2** and Compatibility rendering.
Open this folder's `project.godot` in Godot, or run from this folder on macOS:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The 640×360 logical room opens at 1280×720. Click Start; the camera stays fixed. Hover a prop
to read its name; select Look, Use or Talk and left-click it for authored feedback.
Use on the oil flask collects it. Select its inventory slot, then click the clerk
for wrong-target feedback or the press to repair it. Right-click cancels item
selection without discarding it. Repair consumes oil once and changes the press
shape and label. Use on the gate gives a clue. Talk to the clerk before repair for an oil hint;
after repair, request a stamped pass. Select the pass and use it on the gate to
complete the puzzle once. Dialogue blocks room clicks until you choose a response
or cancel with the leave button, right-click or Escape. Repeated Talk gives the
current hint without granting another pass. Completion visibly opens the gate
and offers Restart. Use Pause to suspend play, including an open conversation;
Resume restores progress. Escape first cancels a selected item or conversation,
then pauses idle play; Escape in the pause menu resumes. Restart from pause or
completion immediately begins a fresh puzzle. There is no timer or loss state.
Long responses and dialogue scroll; shortened inventory names and item prompts
retain their full text in hover tooltips.

## Validate

Run from this folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
```

Expected behavioral result: `Foundation + interaction + inventory + puzzle + lifecycle checks: 352 passed, 0 failed`.
An import exit code alone is insufficient: inspect output for script/resource
errors. For native rendering checks and optional viewport captures:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd -- --capture-dir=/private/tmp/closed-gate-evidence
```

The native capture run adds fifteen image-save checks (367 total). It validates the
error panel, room, inventory selection, repair, dialogue states, capacity feedback,
completion, start/pause/restart, long text and injected GUI input, then exits. This does not substitute for a
human playthrough.
See [acceptance evidence](docs/ACCEPTANCE.md) for results and evidence boundaries.

## Verify a standalone reskin

From this folder, use Python 3 (standard library only):

```sh
python3 tests/create_reskin_copy.py
```

The script creates a fresh `harbor-gate` copy under `/private/tmp/`, omits
`.godot/`, changes the backdrop palette, clerk/item names and dialogue, and
writes `reskin-audit.json` beside the copy. It checks unchanged runtime script/UID
and scene hashes (except the backdrop), stable content IDs/geometry/rules, and
project-local runtime references. Run the import and behavioral commands above
with `--path` set to the printed copy path, then launch that copy and complete
its puzzle. Source game content and mechanics stay unchanged.
See [standalone reskin evidence](docs/ACCEPTANCE.md#standalone-reskin) for recorded results.

## Edit or copy

- Edit names, hotspot positions and polygons in `data/room.json`.
- Replace visual packed scenes under `scenes/visuals/`; keep their roots `Node2D`.
- Edit items, conversation text and rules in `data/*.json` according to the
  [content schema](docs/DESIGN.md#content-schema).
- Edit fonts, label colors, verb names, item prompts and instructions in
  `data/theme.tres`. Inventory slots use item names and description tooltips;
  item icon scenes are validated content, but the inventory displays text buttons.
- Overlapping hotspots resolve in `room.json` array order: the first match wins.
  Puzzle actions execute conditions and atomic item/flag/text/dialogue/completion
  effects. Failed actions leave progress and required items available.
- Content errors hide the room and name the file and offending ID in a scrollable
  error panel. All four JSON files must validate before any props are built.

Copy this entire folder, including script `.gd.uid` files. Omit `.godot/`.
No sibling game, repository-level resource, account or asset download is needed.
The [design and editing reference](docs/DESIGN.md) and
[asset provenance](assets/PROVENANCE.md) document the content and reskin boundaries.
