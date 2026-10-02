# Step 03 — Player combat and damage

Status: accepted after user-reported manual testing. Prerequisite:
Step 02 accepted by the user after manual testing on 2026-10-02.

## Outcome

The hero can perform a three-hit combo and an air attack against a damageable
dummy, and react correctly to a controlled incoming strike.

## Work

1. Implement [combat rules](../DESIGN.md#combat-rules): windup/active/recovery,
   input buffering, committed facing, depth/height eligibility and per-strike hits.
2. Add health, hurt, interruption, bounded knockback, knockdown, get-up protection,
   invulnerability and death. Use one small damage interface, not an ability system.
3. Implement the jump attack and safe hurt/landing cancellation. Connect sprite
   timing to authored strike windows; record actual values and animation mapping.
4. Add a dummy and controlled incoming attack in a test scene, health readout and
   minimal hit feedback. Include meaningful deterministic combat regressions.

## Acceptance

- A strike hits multiple eligible targets once each and misses behind, outside
  depth tolerance, outside its active window, and at incompatible jump heights.
- Fast presses advance at most three strikes; holding does not auto-loop; expired
  input resets the combo. Hurt, death and reset clear queued attacks.
- Finisher knockdown and protected get-up work; no repeated ground-hit stun lock.
- Pause/resume in every attack phase and reset while hurt produce a clean state.
- Record focused regression command and visual timing checks separately.

Exclude enemy decisions, live encounter sequencing and special moves.
See [validation](../ACCEPTANCE.md).

## Completion record

Date: 2026-10-02. Evidence applies to this uncommitted Step 03 working tree.
The user confirmed Step 02 manual testing was good and authorized implementation.

### Files and behavior

- Added `scripts/combat_actor.gd` and its generated UID: the shared damage receiver,
  health/death signals, bounded knockback, hurt/down/get-up/dead reactions, and
  ground-distance/depth/height strike eligibility. Same-team actors cannot hit
  each other. Body contact has no damage behavior.
- Updated `scenes/player/player.gd` and `player.tscn`; added `combat_frames.tres`.
  Explicit strike index/time owns windup, active and recovery, committed facing,
  one hit registry per strike, one queued next strike, and one air attack per jump.
  Attack/hurt restrict movement; airborne hurt lands safely before recovery.
- Added `scenes/combat/dummy.gd`, `dummy.tscn`, `dummy_frames.tres`,
  `combat_street.gd`, `combat_street.tscn`, and generated script UIDs.
  The stationary dummy has a manually triggered 0.4 s windup, 0.1 s active window,
  and 0.2 s recovery, 64 px reach, 14 px depth tolerance, and 8 px height band.
  K/north triggers 15 damage; L/right shoulder triggers 15 damage plus knockdown.
  Dummy attacks commit left, so stand just left of it in the same depth lane.
  Health, hero attack phase and death/reset prompt are shown in the header;
  hurt flashes give minimal impact feedback. R/Back resets both actors completely.
- `main.tscn` opens the combat street. `project.godot` adds only test-hit and
  test-knockdown actions; retained engine, renderer, resolution and existing input.
- Imported four existing hurt/fall PNGs and their Godot import descriptors;
  provenance records frame selection and sources. Added `tests/combat_test.gd`
  with generated UID. Updated README, PLAN, ACCEPTANCE, ASSETS, provenance, and
  Step 02's user acceptance record.

### Combat tuning and animation mapping

All values are Inspector exports on their owning scripts. Health: hero 100,
dummy 120. Ordinary hurt lasts 0.24 s, damage protection 0.65 s; hero knockback is
100 px/s for the hurt interval; dummy knockback is 30 px/s to keep a close-range
combo in reach. Both clamp to street bounds. The dummy has no ordinary hurt
invulnerability, so all three combo strikes can connect; down/get-up protection
still prevents ground-hit stun lock. Knockdown lasts
at least 0.75 s and waits for landing; get-up lasts 0.3 s with no damage eligibility,
followed by 0.2 s protection. Death disables attacks immediately, emits once and
holds the final intact fall pose until reset. No outcome menu is added here.

| Strike | Windup / active / recovery (seconds) | Damage | Reach | Source frames / contact index |
| --- | --- | --- | --- | --- |
| First punch | 0.24 / 0.08 / 0.08 | 10 | 52 px | `attack1` 0–5 / source 4 |
| Second punch | 0.16 / 0.08 / 0.08 | 12 | 56 px | `attack2` 5,6,7,5 / source 7 |
| Finisher kick | 0.24 / 0.06 / 0.12 | 18 + knockdown | 64 px | `punch` 0–5 / source 4 |
| Air kick | 0.12 / 0.12 / 0.18 | 15 | 64 px | `punch` 2,3,4,5 / source 4 |

Depth tolerance is 14 px. Ground attacks require both actors at height ≤8 px;
air attack requires both at height ≤28 px. Eligibility uses ground roots rather
than sprite overlap. One strike may damage several targets, once each. Even a
protected target is registered for that strike, preventing delayed repeat hits.

The combo buffer accepts presses in the final 0.22 s of a strike. It queues only
one next strike and stops after the finisher. Earlier/expired presses do not
advance; after recovery a fresh press starts strike one. Holding does not repeat.
Hurt/death/reset clear strike, buffer and hit registry. Landing cancels the air
attack before further hit resolution. Pause freezes actors, strike/reaction and
protection timers, sprite poses and jump height; resume requires input release.

Idle/move retain 6/10 FPS looping; jump retains Step 02 phase-selected poses.
Attack/reaction animations never auto-advance: physics timers select frames.
Windup spreads the frames preceding contact across its authored duration, active
holds the contact frame, and recovery holds the next available pose. Frame-resource
nominal attack rates are 15/12.5/14.2857/9.5238 FPS respectively, but do not control
combat. Hurt advances two frames across 0.24 s; fall advances three across 0.3 s
and holds; reverse fall advances three across the 0.3 s get-up. All are non-looping.
See provenance for intact frame indices; feet offsets, 48 × 48 rectangles and
2× scale are unchanged. No source pixels or sample resources were modified.

### Verification commands and results

Verified engine: `4.7.2.stable.official.ed1daf0bf`. From repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd
git diff --check
```

Editor import/resource loading and startup passed. Movement: **48 checks passed,
0 failures**. Combat: **58 checks passed, 0 failures**. Covers multi-target and
per-strike damage, active-only windows and contact poses, facing/reach/depth/height
rejection, protected/allied target rejection, all three combo hits through hurt/knockback, queue limits/expiry and held
input, one air attack/landing cancellation, finisher knockdown/protected recovery,
hurt interruption/invulnerability/bounds, airborne recovery, health clamp and
single death, mapped J/west/K/L input, body contact, phase pause, input guards,
and paused/hurt reset. No external test runner or dependency was added.

Initial import exposed a malformed dummy scene resource declaration, then the
first combat test needed explicit types for dynamic properties and correct
incoming-strike positioning. Those were fixed before final passing runs. Initial
sandbox runs emitted log/editor-settings access errors; editor validation with
normal application-data access passed. Sandboxed headless runs still emit the
known macOS `get_system_ca_certificates` diagnostic, with no script/resource errors.
All new scripts have generated UID files. Whitespace and local document links pass.

### Visual and input observations

Native OpenGL Compatibility rendering on Apple M2 at 1280 × 720 was inspected.
A temporary script outside the project captured idle, each active contact pose,
air kick, knockdown, mid-get-up and death. Punches/kick read clearly, air visual is
raised while the shadow/feet anchor stay grounded, and intact fall/reverse poses
are visible. The header/footer and pause panel fit the viewport. Contact-frame
assertions verify phase selection separately from these rendered observations.

Computer-use keyboard taps exercised movement, Escape pause, Enter resume and R
reset in the native window. Sustained real-time combo timing, attack/reaction feel,
air-kick timing, resized display and physical keyboard/controller combat playtests
were **not run by the agent**. Controller regression input was synthetic; no hardware/device
claim is made. Rendered poses and smoke checks do not establish hands-on acceptance.
No audio is present in this step.

### Intentionally untouched and follow-ups

Preserved `2d-platform`, repository/skill guidance, DESIGN, original sample scenes,
scripts and frame resources, original movement street/resources and movement test,
existing license records, and Steps 04–09. No enemy AI, encounters, boss, props,
audio, final menus, additional assets/packs, dependencies or framework were added.
No purchase or publication was performed.

### User acceptance update

On 2026-10-02, after implementation, the user reported Step 03 was manually tested
and invoked ticket-to-pr for delivery. Step 03 is accepted on that user-reported
manual evidence. No controller model, display size or detailed case-by-case
results were supplied; the agent observations above remain separate evidence.
No further Step 03 implementation is requested. Stop before Step 04.
