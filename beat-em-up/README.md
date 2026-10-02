# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 02 movement implemented; hands-on/controller validation pending.**
The project opens a bounded test street with a movable, jumping hero, a stationary
overlap sample, horizontal camera follow, and minimal pause/reset controls.
Combat, AI, encounters, and final menus are not implemented.

## Open and run

Import `project.godot` into Godot **4.7.2**, then press **F5**. The independent
project uses GDScript and the Compatibility renderer. The logical viewport is
640 × 360, displayed in a 1280 × 720 window with nearest filtering and preserved
aspect ratio. Cyan crosses mark ground anchors; the outlined strip limits the
hero's feet. Walk around the stationary actor to inspect depth sorting, then jump
to check that the shadow and sorting stay at ground level.

From the repository root on this Mac:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --editor --path beat-em-up
```

Move with WASD/arrows or the controller's left stick/D-pad. Jump with Space or
the south face button. Escape/Start pauses and resumes; Enter/south also resumes
while paused. R/Back resets the test street; J/west also resets while paused.
The movement-stick deadzone is 0.25. After boot, resume, or reset, release held
controls before fresh movement/jump input. Close the window to exit.

The original automatic art preview is preserved at
`scenes/sample/street_sample.tscn`. Open it and press **F6**, or run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up res://scenes/sample/street_sample.tscn
```

## Validate

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
git diff --check
```

The regression command checks movement, bounds, jump, camera, pause/reset, and
mapped synthetic input. Inspect logs for errors; synthetic controller events do
not establish hardware support. See the
[Step 02 record](docs/steps/02-movement.md#completion-record) for automated results,
rendered observations, and remaining hands-on checks.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
