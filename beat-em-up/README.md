# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 08 presentation implemented; listening/manual validation pending.**
F5 opens a title with Play, Controls, Audio, and Quit. Play starts a fresh street route:
safe entrance → two grunts → connecting stretch → two grunts followed by a
grunt/bruiser wave → locked final arena with Toxic Enforcer → victory.
Step 05 was accepted after user-reported manual testing.
Steps 02–04 were accepted after user-reported manual testing.
Step 06 was accepted by the user for progression; detailed hands-on results were
not supplied.

## Open and run

Import `project.godot` into Godot **4.7.2**, then press **F5**. The independent
project uses GDScript and the Compatibility renderer. The logical viewport is
640 × 360, displayed in a 1280 × 720 window with nearest filtering and preserved
aspect ratio. Normal play hides actor anchor crosses and the ground test outline.
Striped amber ground markers show locked encounter and boss-arena gates. Jumping
cannot bypass movement bounds. The HUD stays above the walkable area.

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

The boss alternates a short sweep and a straight charge. Yellow ground markings
and SWEEP/CHARGE labels show the committed lane; change depth or jump above the
hit band to avoid it. OPEN marks recovery. Boss hits reduce health without
cancelling committed attacks or knocking it down. Its health appears in the HUD.
Defeat it to reach Victory after its death sequence; Play Again starts a fresh run.

Between the two ordinary fights, punch the labeled crate twice to break it.
It drops one food pickup restoring up to 30 HP. Walk close at the same street
depth to collect it while grounded. At full health it stays available; jumping
or death prevents collection. The crate and its debris never block movement.
Retry/Play Again restore the crate and discard old drops.

Escape/Start opens pause with Resume, Retry, Audio, Main Menu, and Quit. Zero health
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

Audio is available from the title and pause menus. Use Up/Down or D-pad to
choose Master/Music/SFX, then Left/Right or D-pad to adjust in 5% steps; 0% mutes.
Defaults are 80% / 45% / 80%. Choices last for the app session, including Retry
and Main Menu, and return to defaults after closing the game. One music loop
continues across runs, 8 dB quieter in menus. Pause freezes gameplay sounds and
impact effects; menu sounds remain active. Retry/Main Menu discard old sounds
and effects. No hit pause, camera shake, or global time effect is used.

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
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/boss_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/props_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/presentation_test.gd
git diff --check
```

The regression commands check movement, combat, crowd commitments, encounter
waves/gates, boss attack/death rules, result precedence, menu input, and whole-run reset. Earlier suites retain their original
test scenes. Synthetic controller events do not establish hardware support.
See the [Step 05 record](docs/steps/05-level.md#completion-record) for route tuning,
automated results and rendered observations. The [Step 06 record](docs/steps/06-boss.md#completion-record)
covers boss tuning, completion/reset checks, and pending hands-on acceptance.
The [Step 07 record](docs/steps/07-props.md#completion-record) covers prop damage,
food eligibility, pause/reset checks and rendered observations. The [Step 08 record](docs/steps/08-presentation.md#completion-record) covers
menu/volume tests, native rendering at two window sizes and measured audio output.
Listening quality, full-route balance and completion time remain pending hands-on
play. Headless accelerated audio tests can report Ogg playback resources retained
at shutdown; the native presentation suite at real frame timing exits cleanly.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
