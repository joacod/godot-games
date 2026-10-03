# Step 08 — Art, sound and presentation

Status: implemented, pending listening and hands-on validation. Prerequisite:
Step 07 accepted by the user for progression on 2026-10-02; detailed recovery/
balance observations were not supplied.

## Outcome

The finished route looks and sounds like one coherent game, with readable combat
and usable menus rather than debug presentation.

## Work

1. Finish selected CraftPix art integration, palette/scale consistency, ground
   anchors, animation timing and scenery. Update asset provenance and mapping.
2. Finalize HUD, health bars, button hints, Controls, focus, prompts and result
   screens. Show information without covering the walkable fight area.
3. Source and record the planned sounds/music; verify rights before import.
   Add Master/Music/SFX volume controls and document pause/music behavior.
4. Add restrained impact effects and optional brief hit pause/shake only if they
   improve readability. Ensure pause/reset clears any global time/camera effects.
5. Remove test-only overlays from normal play while retaining useful test scenes.
   Keep diagnostics available without exposing them in the normal game flow.

## Acceptance

- Visually inspect all combat states, depth overlaps, UI and two window sizes.
- Listen to music/effects during a full fight and menus; no duplicate loops,
  clipping, missing cues or unresponsive volume controls.
- All menus work without mouse input and use clear focus; resume leaks no input.
- No final gameplay animation is silently represented by a debug placeholder.

Exclude new mechanics, cinematic production, custom shaders and publishing.
See [assets](../../ASSETS.md) and [validation](../ACCEPTANCE.md).

## Completion record

Implemented on 2026-10-02 with Godot **4.7.2.stable.official.ed1daf0bf**,
Compatibility renderer. **Listening and hands-on acceptance remain pending.**

Behavior:

- Polished title, Controls, pause, Game Over and victory menus, using the existing
  street image, a restrained dark/teal/amber palette, clear button outlines and
  explicit keyboard/controller navigation. The title and pause offer Audio.
  The focused volume row has both an arrow and amber text. Controls describe
  combo buffering, air attacks and depth evasion. Confirm/resume retains the
  existing release-before-input gate.
- Biker and Toxic Enforcer health labels/bars sit in the top 84 logical pixels,
  above the walkable strip at Y=242–312. Bars are 204 × 10; route prompts stay
  below them. Escape/Start is shown outside the boss fight. Normal play hides
  cyan ground-anchor crosses and the ground test outline; striped amber LOCK
  markers and boss SWEEP/CHARGE/OPEN cues remain as gameplay information.
  `Street.debug_bounds` can expose the ground outline in the Inspector, while
  original test scenes retain their diagnostics.
- Added two cropped rear dumpsters and a final-yard sign using the existing
  CraftPix street pack. All actor sheets, palette, 2× scales, foot offsets,
  timings and semantic mappings remain as approved. The backdrop remains the
  repeated/mirrored street; no new level geometry or new stage art is implied.
- Added seven confirmed-event cues and one CC0 music loop. CraftPix was reviewed
  first; the available browser could not access its signed-in downloads. The
  imported public CC0 sources and supplied/authored license records are in
  [provenance](../../assets/PROVENANCE.md#step-08-presentation-and-audio).
- Master/Music/SFX defaults are 80%/45%/80%, adjustable in 5% increments by
  keyboard/D-pad; 0% mutes. Choices persist through run/menu transitions for
  the app session, without creating a settings/save system. One music player
  runs across Retry and Main Menu; menus lower its player gain from -10 to
  -18 dB. It loops after the source's 7.5-second intro. Six bounded gameplay
  voices and one separate menu voice feed SFX. Master has a -1 dB hard limiter.
- Accepted hits show a small 0.18-second spark; rejected/invulnerable hits show
  none. Boss hits retain feedback during protected attack commitments. The crate
  has one breaking cue and food one pickup cue. Pause freezes game sound tails
  and effects while menu cues/music remain active; Retry/Main Menu stop old game
  sounds and replace the effect owner. No hit pause, shake or global time/camera
  effect is used. A result cue replaces frozen lethal-hit tails on Game Over.

Files changed:

- `scenes/ui/run.gd`: HUD, menu presentation/focus, volume controls and transitions.
- New `scenes/ui/audio.gd` and `scenes/level/presentation.gd`, with generated UIDs:
  bounded audio ownership and street-local effect/cue wiring.
- `default_bus_layout.tres`: Music/SFX routing and Master hard limiter.
- `scripts/combat_actor.gd`, player/enemy/boss scripts and `props/breakable.gd`:
  presentation-only attack/accepted-damage signals, including the boss's custom
  receiver. Combat decisions, health amounts and attack timing are unchanged.
- `scenes/level/street.gd` / `.tscn`, `props/breakable.tscn`: normal-play diagnostics,
  striped locks, final-yard dressing and keyboard/controller crate hint.
- Eight files in `assets/audio/`, `assets/street/dumpster.png`, generated imports,
  three supplied Kenney license records and the authored music source record.
- New `tests/presentation_test.gd` and UID; README, plan, asset brief, provenance,
  acceptance checklist, Step 07 progression status and this completion record.

Verification from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit --log-file /private/tmp/presentation-import.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120 --log-file /private/tmp/presentation-startup.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/enemies_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/level_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/boss_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/props_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/presentation_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script res://tests/presentation_test.gd --log-file /private/tmp/presentation-test-native.log
git diff --check
```

Results: movement **48/48**, combat **58/58**, enemies **35/35**, level **33/33**,
boss **125/125**, props **36/36**, presentation **49/49**; **384 checks passed**.
The native presentation suite also passed **49/49** at actual frame timing and
exited without resource-retention warnings. Import/startup had no script, scene
or resource-loading failures. New UIDs were generated. Headless checks emit the
known macOS `get_system_ca_certificates` diagnostic, and editor import cannot
save global editor settings under the sandbox. Accelerated headless audio runs
also report Ogg playback/packet resources retained at shutdown. These are reported
separately from assertion results; timed native rendering/audio checks exit cleanly.

The presentation suite exercises actual controls and buses: keyboard and synthetic
controller navigation/confirmation/back, each slider's real gain/mute, single
accepted cues and rejected duplicate damage, dynamically spawned actors, protected
boss impacts, pause lifetimes/tails, resume release-gating, menu geometry, and
Retry/Main Menu cleanup without music duplication or lost session volume choices.
Synthetic events do not establish physical controller support.

Native staged rendering used temporary harnesses, outside the sandbox because
its native graphics startup exited 134:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --fixed-fps 60 --script /private/tmp/presentation-render.gd --log-file /private/tmp/presentation-render.log
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --fixed-fps 60 --script /private/tmp/presentation-states.gd --log-file /private/tmp/presentation-states.log
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script /private/tmp/presentation-audio-capture.gd --log-file /private/tmp/presentation-audio-capture.log
```

Inspected title, Controls, Audio, pause, Game Over, victory, HUD, crate/food,
ordinary fight, impacts, final-yard scenery and boss tells. Native window sizes
were **1280 × 720** and **960 × 540**, with the same 640 × 360 logical viewport.
Verified health-strip size and slider focus after correcting issues found in the
first review. Staged pose sheets cover all hero strike windup/contact/recovery
and reactions; both ordinary enemies' attack phases, hurt, down/get-up and death;
boss sweep/charge phases, hurt and death. Boss knockdown/get-up are excluded
because gameplay never uses them. Depth overlaps preserve ground-root sorting.
This is **staged rendering, not animation feel, physical input or a full playthrough**.
Temporary images/harnesses remain in `/private/tmp`, outside shipped game files.

Native audio capture measured nonzero output for all seven cues, SFX mute, music
signal across the loop boundary, and a six-hit/music stress mix. Peak was
**0.891256**, at the -1 dB ceiling (approximately 0.891251, within floating
point tolerance). Master mute was checked on its actual bus; the capture is
before that bus's output fader, so it does not measure final device silence.
All **11 measurement checks passed**. The source loop seam and mix quality have
**not been listened to**; signal/peak measurements are not listening acceptance.

Intentionally untouched: actor frame resources and sprite sheets, damage/reach/
combo/reaction timing, enemy/boss decisions, encounter waves/counts, recovery
amount, input map, engine/renderer configuration, original test scenes and suites,
`2d-platform`, and Step 09. No dependency, purchase, commit, branch, push, PR or
publication was added.

Remaining hands-on checks: listen during a full ordinary fight, boss fight and
menus; adjust/mute all three buses, hear the loop seam, and verify balance and
absence of distracting dropped cues. Play the route to validate final art and
feedback in motion, including depth overlaps, pause/resume, deaths and Retry.
Verify every menu and a fight with a physical controller, recording the device.
Record route completion time and recovery fairness. Step 09 remains not started.
