# The Closed Gate

A standalone Godot point-and-click adventure: one fixed gatehouse, five named
placeholder props, and data-authored Look/Use/Talk feedback. Steps 01–02 are
complete. Inventory and the playable puzzle chain arrive in later steps.

## Run

Use Godot **4.7**; development checks use **4.7.2** and Compatibility rendering.
Open this folder's `project.godot` in Godot, or run from this folder on macOS:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The 640×360 logical room opens at 1280×720. The camera stays fixed. Hover a prop
to read its name; select Look, Use or Talk and left-click it for authored feedback.
Use on the press or gate gives a clue. Picking up oil and starting conversations
are deferred, with fallback feedback until their steps are implemented. Inventory,
dialogue, pause menus and completion remain pending; cancellation and pause input
actions are configured for later use.

## Validate

Run from this folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
```

Expected behavioral result: `Foundation + interaction checks: 179 passed, 0 failed`.
An import exit code alone is insufficient: inspect output for script/resource
errors. For native rendering checks and optional viewport captures:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd -- --capture-dir=/private/tmp/closed-gate-step02-evidence
```

The native capture run adds two image-save checks (181 total). It validates the
error panel, room and injected GUI input, then exits. This does not substitute
for a human playthrough.
See [acceptance evidence](docs/ACCEPTANCE.md) for checks and remaining gaps.

## Edit or copy

- Edit names, hotspot positions and polygons in `data/room.json`.
- Replace visual packed scenes under `scenes/visuals/`; keep their roots `Node2D`.
- Edit items, conversation text and rules in `data/*.json` according to the
  [content schema](docs/DESIGN.md#implemented-content-schema-step-01).
- Edit fonts, label colors, verb names and instructions in `data/theme.tres`.
- Overlapping hotspots resolve in `room.json` array order: the first match wins.
  Text-only rules with no conditions or selected item execute in Step 02; all
  other rules stay inactive.
- Content errors hide the room and name the file and offending ID in a scrollable
  error panel. All four JSON files must validate before any props are built.

Copy this entire folder, including script `.gd.uid` files. Omit `.godot/`.
No sibling game, repository-level resource, account or asset download is needed.
The [design](docs/DESIGN.md), [steps](docs/STEPS.md) and
[asset provenance](assets/PROVENANCE.md) explain the boundaries and next work.
