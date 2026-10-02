# Step 02 — Movement, depth and jump

Status: accepted by the user after manual testing. Prerequisite:
Step 01 foundation evidence and the user's free-asset decision are recorded.

## Outcome

The hero can traverse and jump within a bounded test street with correct depth
sorting and camera behavior, using keyboard or controller.

## Work

1. Implement [ground-plane rules](../DESIGN.md#ground-plane-and-jump) with a
   grounded character root, raised visual child, shadow, and separate jump height.
2. Add normalized movement, stick deadzone, horizontal facing and idle/walk/jump
   presentation. Expose only needed speed, jump and bounds tuning.
3. Add street boundaries and a horizontally following camera with level limits.
   Place an actor/prop sample to inspect overlap and Y sorting.
4. Add a minimal pause/resume path and reset action for testing. All movement and
   jump state must freeze/reset correctly; final menu styling comes later.

## Acceptance

- Walk in all directions; diagonals are not faster; no stick drift at rest.
- Jump in place and while moving; land at the ground anchor; never cross bounds
  or change sorting because the visual sprite rose.
- Pause in midair and resume; reset midair; no stuck velocity or stale input.
- Validate keyboard visually and controller on hardware, reporting gaps separately.

Exclude attacks, enemies, encounters and final art polish.
Use [shared validation](../ACCEPTANCE.md).

## Completion record

Date: 2026-10-02. Evidence applies to the current uncommitted Step 02 working tree.
The user authorized the bounded implementation with “go”, then chose existing free
assets and later adaptations rather than paid replacement packs.

### Files and behavior

- Added `scenes/player/player.gd`, its Godot-generated `.gd.uid`, `player.tscn`,
  and `movement_frames.tres`. The CharacterBody2D root/24 × 8 footprint stay at
  ground level. A separate numeric height raises only `Visual`; the shadow and
  cyan foot marker stay at the root. Ground Y controls actor sorting.
- Added `assets/hero/jump.png` from the existing original Biker archive and its
  Godot import descriptor. Uses existing idle/run art plus selected jump poses;
  see [provenance](../../assets/PROVENANCE.md#step-02-movement-subset).
- Added `scenes/level/movement_street.gd`, its `.gd.uid`, and `movement_street.tscn`.
  The 1280-pixel test street uses existing scenery with a mirrored second half,
  an idle seaport actor for overlap checks, bounds, camera, and plain test UI.
- `main.tscn` now instantiates the movement test. Preserved the original preview
  verbatim at `scenes/sample/street_sample.tscn`; its script, actors, and frames
  remain unchanged.
- `project.godot` adds only `test_reset` (R / controller Back). Existing movement,
  jump, pause, and menu bindings, deadzone, renderer, and viewport are retained.
- Added `tests/movement_test.gd` and its `.gd.uid`; updated README, PLAN,
  ACCEPTANCE, Step 01's follow-up decision, ASSETS, and provenance.

Initial tuning: movement 130 px/s; jump launch speed 260 px/s; jump gravity
780 px/s². Feet bounds are X=48–1232, Y=242–312, keeping the footprint/shadow
inside the illustrative floor band. All three motion values and the feet bounds
are Inspector exports on the player. The camera keeps Y=180, follows X between
320 and 960, and has world limits (0, 0)–(1280, 360).

Pause freezes actors, sprite animation, and the camera. Escape/Start toggles pause;
Enter/south resumes while paused. R/Back resets at any time; J/west also resets
while paused. Reset restores spawn (240, 278), right-facing idle, zero height and
velocity, and the initial camera. Input must return to neutral after boot,
resume, or reset; a resumed airborne jump continues its arc while held movement
or confirm input is blocked. Holding Jump does not repeat jumps on landing.

### Engine and automated results

Verified engine: `4.7.2.stable.official.ed1daf0bf`. Commands from repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 res://scenes/sample/street_sample.tscn --quit-after 780
git diff --check
```

Import, startup, the preserved preview cycle, and whitespace checks passed.
The regression script passed **48 checks, 0 failures**: equal cardinal/diagonal
distance, facing, idle release, mapped stick deadzone, all four bounds while
airborne, stationary/moving jumps, grounded shadow/footprint, landing, held-jump
suppression, mapped Escape/Enter input, key-repeat rejection, frozen pause state,
input guards, midair/paused reset, camera endpoints/depth independence, and
synthetic controller south/west interactions.

The first test run had one exact float equality failure comparing numeric jump
height with a Vector2 component. The comparison now uses `is_equal_approx` for
the engine's differing scalar/vector precision; the final run passes.
Initial sandboxed import/startup emitted macOS certificate/editor-settings access
errors. Reruns with normal Godot application-data access passed without changing
project configuration. Final logs contain no script/resource errors. All three
new scripts have generated UID files. Focused local Markdown targets were checked.

### Visual and input observations

Opened the native 1280 × 720 game window (OpenGL Compatibility on Apple M2) and
inspected it through computer use. The hero, idle overlap sample, ground markers,
bounds, controls, pause panel, and reset state are visible and readable. Basic
keyboard events through computer use exercised jump/pause and Enter/R resume/reset.
This is a keyboard smoke check, not a sustained physical-keyboard playtest.

A temporary session-only render script produced snapshots for ground positions
behind/in front of the sample, a paused jump in the nearer lane at height 39.87,
the mirrored scenery join, and the right camera endpoint. Inspection confirmed
the expected overlap order follows root Y while airborne; feet markers and shadow
stay on the street. The camera stays within the backdrop, the player is visible
at the right bound, and controls remain on screen while scrolling. Mirrored
graffiti is visible in the second half: acceptable test scenery, not final art.

Controller hardware/device: **not tested**. Controller events were synthetic.
Sustained keyboard playtest, physical stick drift, resized-window behavior, and
controller movement/jump/pause/reset acceptance: **pending**. There is no audio.

### Intentionally untouched and follow-ups

`2d-platform`, repository/skill instructions, DESIGN, existing sample scripts and
actor/frame resources, and Steps 03–09 are untouched. No attacks, damage, AI,
encounters, final menu styling, paid assets, dependencies, or framework were added.
No branch, commit, push, PR, purchase, or publication was performed.

Complete the hands-on keyboard/controller checks above. Approved missing-motion
adaptations and final bruiser/boss art fit remain for their owning mechanics;
Step 02 does not claim those animations are complete. Stop here before Step 03.

### User acceptance update

On 2026-10-02, before Step 03, the user reported: “Step 02 was manually tested
all good, go”. Step 02 is accepted on that user-reported manual evidence. The
original automated/native observations above remain the historical implementation
record. No controller model or additional device-specific results were supplied.
