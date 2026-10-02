# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 03 combat accepted after user-reported manual testing.**
Step 02 was manually tested and accepted by the user. The bounded test street now
has a three-hit combo, one attack per jump, damage/reactions, a stationary combat
dummy, health/phase readout, and pause/reset. Enemy AI and encounters are not yet
implemented.

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
air kick, which can hit only near the ground. Stand just left of the dummy in its
depth lane: K/north triggers its normal incoming strike; L/right shoulder triggers
a knockdown strike. Both have a visible windup and fixed left-facing reach.
R/Back restores both actors and their health, including after death. The dummy
stays dead until reset. The header shows health and the hero's combat phase.

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
git diff --check
```

The movement and combat regression commands check bounds/jump/camera/input and
hit eligibility/combo/reactions/pause/reset respectively. Synthetic controller
events do not establish hardware support. See the
[Step 03 record](docs/steps/03-combat.md#completion-record) for tuning, automated
results, rendered observations, and remaining hands-on checks.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
