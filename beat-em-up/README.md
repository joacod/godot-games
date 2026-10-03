# Beat 'Em Up

A finished single-player street brawler, one level long, inspired by Final Fight.
Move across the street and through its depth, clear two encounters, break a
crate for a heal, and defeat the Toxic Enforcer.

F5 opens a title with Play, Controls, Audio, and Quit. Play starts a fresh route:
safe entrance, two grunts, a connecting stretch, two grunts followed by a
grunt and a bruiser, then a locked final arena. Defeat the boss to reach
Victory after its death sequence. Play Again starts a fresh run.

## Open and run

Use Godot 4.7; development checks use 4.7.2. Import
[project.godot](project.godot) and press **F5**. The project uses GDScript and
the Compatibility renderer. The logical viewport is 640 × 360, displayed in a
1280 × 720 window with nearest filtering and a preserved aspect ratio. Normal
play hides actor anchor crosses and the ground test outline. Striped amber
markers show locked encounter and boss-arena gates. Jumping cannot bypass
movement bounds. The HUD stays above the walkable area.

From the repository root on this Mac:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --editor --path beat-em-up
```

## Controls

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move across the ground plane | WASD or arrow keys | Left stick or D-pad |
| Attack / continue combo | J | West face button |
| Jump | Space | South face button |
| Pause / resume | Escape | Start |
| Navigate menus | Arrow keys | D-pad |
| Confirm / back | Enter / Escape | South / east face buttons |

Gamepad labels describe Xbox positions. The movement-stick deadzone is 0.25.
After boot, resume, or reset, release held controls before a fresh move or jump.
Menu confirmation does not also attack or jump.

Press Attack again near the end of a strike to queue the next one, up to three.
Holding Attack does not repeat. Jump, then attack, for one air kick; it hits
only near the ground. Change depth, or move behind a committed tell, to avoid
a strike. Bruisers have a longer tell and knock the hero down. Body contact
does no damage.

The boss alternates a short sweep and a straight charge. Yellow ground markings
and SWEEP/CHARGE labels show the committed lane. Change depth or jump above the
hit band to avoid it. OPEN marks recovery. Boss hits reduce health without
cancelling a committed attack or knocking it down.

Between the two ordinary fights, punch the labeled crate twice to break it.
The dropped food restores up to 30 HP. Walk close at the same street depth
while grounded. At full health the pickup stays; jumping or death prevents
collection. The crate and its debris never block movement. Retry and Play
Again restore the crate.

Zero health opens Game Over with Retry, Main Menu, and Quit. Pause offers
Resume, Retry, Audio, Main Menu, and Quit. Retry restarts the entire route.
There are no checkpoints. Close the window to quit.

R, Back, and the test strike bindings are inactive in the main game. The old
test scenes keep those controls when opened with **F6**:
[movement_street.tscn](scenes/level/movement_street.tscn),
[combat_street.tscn](scenes/combat/combat_street.tscn), and
[fight_street.tscn](scenes/enemies/fight_street.tscn). The combat dummy also
accepts K / north for a normal strike and L / right shoulder for a knockdown.

## Audio

Audio is on the title and pause menus. Up/Down or the D-pad chooses
Master, Music, or SFX. Left/Right or the D-pad changes the level in 5% steps.
0% mutes that bus. Defaults are 80% / 45% / 80%. Choices last for the app
session, including Retry and Main Menu, and return to defaults after quit.
One music loop continues across runs and is quieter in menus. Pause freezes
gameplay sounds and impact effects; menu sounds stay active. Retry and Main
Menu discard old gameplay sounds and effects. There is no hit pause, camera
shake, or global time effect.

## Validate

From the repository root, using Godot 4.7.2:

```sh
godot --headless --editor --path beat-em-up --quit
godot --headless --path beat-em-up --quit-after 120
for suite in movement combat enemies level boss props presentation art_swap; do
  godot --headless --path beat-em-up --fixed-fps 60 \
    --script "res://tests/${suite}_test.gd" || exit 1
done
git diff --check
```

On this Mac the binary is `/Applications/Godot.app/Contents/MacOS/Godot`.
The suites check movement, combat, crowd commitments, encounter waves and gates,
boss attack and death rules, result precedence, menu input, props, presentation,
and the alternate-art sample. Headless checks do not prove feel, listening
quality, or a physical controller. After a gameplay change, play the affected
stretch: movement and depth, one combo, a jump attack, both encounters, the
crate and food, pause and resume, death and retry, and a boss clear.

Headless accelerated audio tests can report Ogg playback resources retained at
shutdown. The native presentation suite at real frame timing exits cleanly.
Run it without headless mode or a fixed frame rate:

```sh
godot --path beat-em-up --script res://tests/presentation_test.gd
```

Listening quality still requires manual testing.

## Edit and replace art

[Play, tune, and replace art](docs/EDITING.md) maps scene ownership, Inspector
values, and animation requirements. [Design](docs/DESIGN.md) records the combat
and encounter rules. [Art reference](ASSETS.md) and
[provenance](assets/PROVENANCE.md) record sources, licenses, and frame mappings.

Open [art_swap_street.tscn](scenes/sample/art_swap_street.tscn) and press **F6**
to fight a Cyborg-drawn grunt with unchanged grunt rules. The main level keeps
its chosen cast. The original art preview remains at
[street_sample.tscn](scenes/sample/street_sample.tscn).

This project does not depend on `2d-platform`.
