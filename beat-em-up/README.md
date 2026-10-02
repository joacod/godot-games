# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 04 enemies accepted after user-reported manual testing.**
Steps 02 and 03 were accepted after user-reported manual testing. The test street
now opens a live fight against two grunts and a slower, tougher Cyborg bruiser.
Attacks have visible tells and at most two enemies commit simultaneously.
Defeat the group or lose all health, then retry with R/controller Back.

## Open and run

Import `project.godot` into Godot **4.7.2**, then press **F5**. The independent
project uses GDScript and the Compatibility renderer. The logical viewport is
640 × 360, displayed in a 1280 × 720 window with nearest filtering and preserved
aspect ratio. Cyan crosses mark ground anchors; the outlined strip limits the
hero's feet. Walk around the dummy to inspect depth sorting, then jump
to check that the shadow and sorting stay at ground level.

From the repository root on this Mac:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --editor --path beat-em-up
```

Move with WASD/arrows or the controller's left stick/D-pad. Jump with Space or
the south face button. Escape/Start pauses and resumes; Enter/south also resumes
while paused. R/Back resets the test street; J/west also resets while paused.
J/west attacks. Press again near the end of each strike to queue the next,
up to three; holding does not repeat. Space/south followed by J/west performs one
air kick, which can hit only near the ground. Change depth or move behind an
enemy's committed tell to avoid its strike. Grunts strike faster; the armored
bruiser has a longer tell and knocks the hero down. Body contact does no damage.
R/Back restores the whole fight, including after victory, death, or pause.
The header shows health and the number of reserved enemy attack slots.

The Step 03 dummy remains available at `scenes/combat/combat_street.tscn` (F6).
In that scene K/north triggers a normal strike and L/right shoulder a knockdown.

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
git diff --check
```

The regression commands check movement, combat and crowd commitments/reset.
Movement and combat suites open their original test scenes. Synthetic controller
events do not establish hardware support. See the
[Step 04 record](docs/steps/04-enemies.md#completion-record) for tuning, automated
results, rendered observations, and remaining hands-on checks.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
