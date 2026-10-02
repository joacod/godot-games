# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 05 level and encounters accepted after user-reported manual testing.**
F5 opens a title with Play, Controls, and Quit. Play starts a fresh street route:
safe entrance → two grunts → connecting stretch → two grunts followed by a
grunt/bruiser wave → sealed boss entrance. The boss arrives in Step 06.
Steps 02–04 were accepted after user-reported manual testing.

## Open and run

Import `project.godot` into Godot **4.7.2**, then press **F5**. The independent
project uses GDScript and the Compatibility renderer. The logical viewport is
640 × 360, displayed in a 1280 × 720 window with nearest filtering and preserved
aspect ratio. Cyan crosses still mark actor ground anchors; the outlined strip
marks walkable ground. Amber lines show locked encounter gates; the red line
marks the sealed boss entrance. Jumping cannot bypass movement bounds.

From the repository root on this Mac:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --editor --path beat-em-up
```

Move with WASD/arrows or the controller's left stick/D-pad. Jump with Space or
the south face button. J/west attacks; press again near the end of each strike
to queue the next, up to three. Holding Attack does not repeat. Jump then attack
performs one air kick, which can hit only near the ground. Change depth or move
behind an enemy's committed tell to avoid its strike. Bruisers have a longer tell
and knock the hero down. Body contact does no damage.

Escape/Start opens pause with Resume, Retry, Main Menu, and Quit. Zero health
opens Game Over with Retry, Main Menu, and Quit. Navigate menus with arrows/D-pad,
confirm with Enter/south, and use Escape/east to go back from Controls or resume.
Retry restarts the entire route; there are no checkpoints. R/Back and the test
strike bindings are inactive in the main game.

The old test scenes retain their original controls when opened with F6:
`scenes/level/movement_street.tscn`, `scenes/combat/combat_street.tscn`, and
`scenes/enemies/fight_street.tscn`. They still use R/Back to reset. The combat dummy
also accepts K/north for a normal strike and L/right shoulder for a knockdown.

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
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/enemies_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/level_test.gd
git diff --check
```

The regression commands check movement, combat, crowd commitments, encounter
waves/gates, menu input, and whole-run reset. Earlier suites retain their original
test scenes. Synthetic controller events do not establish hardware support.
See the [Step 05 record](docs/steps/05-level.md#completion-record) for route tuning,
automated results, rendered observations, and remaining hands-on checks.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
