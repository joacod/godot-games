# Complete one playable platformer level

Status: Step 1 complete; runtime checks and rendered frame inspection passed,
and manual validation was reported by the user. Steps 2–7 have not started.

## Goal

Finish the existing Godot 4.7 project as one short, complete game:
start → platforming → combat or avoidance → goal → win → retry.
Death returns the player to the start through an explicit retry action.
Target roughly 1–2 minutes for a successful run, checked through playtesting.

The game comes first. Prepare a readable base for another small platformer,
with reusable scenes, editable gameplay values, and a documented art replacement
format. Do not build a skin-loading system or generic game framework.

## Existing foundation

- Project: `project.godot`; entry scene: `res://main.tscn`.
- Player: `scenes/main_character.tscn` and `scenes/main_character.gd`.
- Movement and animations exist; visual gameplay still needs verification.
- Attacks currently have no damage logic, loop, and lose priority to movement.
- Existing input actions are keyboard-only: left, right, jump, run, and attacks 1–3.
- Keep the current tileset, player sprites, Mobile renderer, viewport configuration,
  and Godot 4.7. Change display settings only for a demonstrated problem.

## Gameplay decisions

- One level, one patrol enemy type, optional collectibles, and one visible exit.
- Player starts with three health points. Enemy contact deals one damage, with
  brief invulnerability and visible feedback to prevent repeated immediate hits.
- Spikes and falling below the level kill immediately. Death stops gameplay and
  shows Retry and Quit. Retry reloads the whole level at its start.
- Every retry resets health, enemies, collectibles, score, and transient combat
  state. No checkpoints or persistent progress.
- Attacks 1–3 play once and deal damage only during documented striking frames.
  A swing hits each enemy at most once. Initially all attacks deal one damage;
  an enemy takes two hits to defeat. No combos or attack interruption by another attack.
- Movement remains available during attacks; facing is fixed for the swing so
  animation and hitbox agree. Death cancels the attack. Tune if playtesting finds issues.
- Collectibles show a count in the HUD. Collecting all of them or killing enemies
  is not required to win; provide a safe opportunity to learn combat.
- Reaching the exit shows Win, the collected count, Retry, and Quit.
- Pause offers Resume, Retry, and Quit. Gameplay and combat timers freeze while
  paused. Death and win cannot be overridden by pause.
- Quit closes the running game. No title screen or Back destination is required.

## Implementation sequence

Implement in this order. When a step is requested individually, stop after that
step. Record completed work and verification here without marking untested
acceptance criteria as passed.

### 1. Stabilize the player and camera

- Verify existing movement, jumping, facing, and animation playback in the editor.
- Expose movement values with clear names, units, and defaults. Keep existing
  values initially; adjust only when needed for the final level's feel.
- Make attacks finish once and retain animation priority until completion.
- Add a following camera with explicit level bounds. Check edges, landings,
  respawn positioning, and viewport behavior for readable framing.

Acceptance: movement remains usable; all three attacks complete; the camera
follows without revealing space outside the intended level bounds.

Implementation and verification (2026-10-01):

- `scenes/main_character.gd` exposes `walk_speed` (400 px/s), `run_speed`
  (700 px/s), `jump_velocity` (-900 px/s), and `deceleration` (3000 px/s²).
  Deceleration preserves the previous 50 px/s reduction per tick at 60 Hz and
  now scales with the physics timestep. Project gravity remains 2500 px/s².
- All three attack animations are non-looping and keep priority until
  `animation_finished`. They retain their existing frames and 10 fps playback:
  attack 1 lasts 0.6 s, attack 2 lasts 0.4 s, and attack 3 lasts 0.5 s.
  Other attacks pressed during a swing are ignored. Movement and jumping stay
  available; sprite facing stays fixed for the swing and resumes afterward.
  Attack damage is still Step 3 work.
- `main.tscn` adds a player-following `Camera2D`, centered on the existing
  collision shape, with pixel bounds left 0, top 0, right 2112, bottom 1080.
  Current tiles occupy x=0–2112 and y=640–944. At the default viewport, the
  camera can travel only 192 pixels horizontally and has no vertical travel.
  Revisit these bounds during Step 5 when the level geometry is finalized.
- `scenes/level_camera.gd` preserves zoom 1 for the default viewport and raises
  zoom only when the expanded viewport would exceed those bounds. Renderer,
  viewport configuration, artwork, collisions, and tile geometry are unchanged.
- Startup command from the repository root (Godot 4.7.2), exit 0, no script or
  scene errors:

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step1-check.log --quit-after 120
  git diff --check
  ```

- Temporary GDScript runtime checks in `/tmp` passed: spawn landing, idle,
  walking, running, deceleration, jumping and landing; attacks 1–3 in both
  directions; rejection of interrupting attacks; movement during swings;
  completion and facing recovery; fresh scene spawn and attack state. Camera
  rectangles stayed bounded at spawn, interior, and out-of-bounds positions
  with 1920×1080, 2560×1080, and 1080×1920 window sizes. Separate checks verified
  camera following and clamping, not just containment.
- Native Metal/Mobile rendering produced inspected frames at spawn, the right
  edge, and a left-facing attack. This verifies static rendering and framing;
  it does not establish movement feel or continuous animation quality.
- Sandboxed headless runs emit a macOS `get_system_ca_certificates` error;
  the same error occurred before these changes. Native rendering exited 0
  without that error. No network behavior was added.
- Manual acceptance: the user reported manual validation of Step 1 on
  2026-10-01. Step 1 is complete based on that report and the runtime checks
  above. Individual manual scenarios were not separately recorded. Controller
  checks and actual death/retry belong to later steps.

### 2. Complete damage, death, and retry

- Define named collision layers and masks for world, player, enemy, attack
  detection, pickups, and hazards. Use only the layers the implementation needs.
- Add health, invulnerability feedback, and a reusable hazard scene.
- Add a fall kill zone and a minimal death UI with a full-level retry.
- Keep one clear owner for run state and transitions; avoid duplicate death events.

Acceptance: hazards and falls consistently cause death; retry creates a clean
run without leftover velocity, attacks, or invulnerability.

### 3. Make combat playable

- Add a reusable enemy scene with bounded patrol, world collision, contact damage,
  health, and clear defeat feedback. Prevent enemies from walking into unintended pits.
- Add player attack hitboxes that follow facing and activate only on striking frames.
- Expose damage, enemy health, patrol speed, and invulnerability duration.
- Use a simple style-compatible placeholder if suitable enemy art is unavailable.

Acceptance: each attack works facing either direction, one swing cannot damage
the same enemy repeatedly, contact damage respects invulnerability, and defeated
enemies stop damaging the player. Confirm pause preserves attack timing.

### 4. Finish the game loop and controls

- Add reusable collectible and exit scenes and a HUD for health and count.
- Add win and pause UI; reuse the same retry behavior as death.
- Keep existing keyboard controls; add pause and explicit gamepad mappings for
  movement, jump, run, and all three attacks.
- Support keyboard and controller menu navigation with visible initial focus.
  Display the actual controls without requiring the player to read source code.

Acceptance: collect, pause/resume, die/retry, and win/retry all work. Menus are
usable without a mouse. Winning and dying cannot trigger competing screens.

### 5. Build and tune the cohesive level

- Keep `main.tscn` as the entry point; instance a dedicated level scene only if
  that makes editing clearer. Reuse existing geometry where it fits the design.
- Arrange a safe start, teaching jumps, optional collectible routes, one combat
  beat with room to avoid the enemy, a readable hazard, and a clearly marked goal.
- Use instances for enemies, hazards, collectibles, exit, and UI. Avoid mandatory
  folder moves or TileMap migration unrelated to completing the level.
- Tune jump spacing, camera, enemy placement, damage feedback, and pacing through
  play. Avoid blind jumps, unavoidable hits, and softlocks.

Acceptance: a new player can understand the route and finish; optional collection
adds interest; successful runs target 1–2 minutes without artificial padding.

### 6. Prepare the base and document it

- Keep art references easy to find in scene resources. Do not add runtime skin
  selection, multiple skins, or a configuration loader.
- Document current sprite sheet dimensions, frame counts, animation names, and
  tileset layout. Explain how to replace art with compatible files and where to
  edit scene resources when dimensions or frame layouts differ.
- Document collision shapes and attack frames as gameplay data: new art must be
  checked against them. Movement changes require rechecking jump distances.
- Use a few clear folders where useful, preserving existing player paths unless
  a move has a concrete benefit. No speculative structure for future genres.
- Add `README.md` within this folder with opening instructions, controls, retry
  behavior, editable values, art replacement, limitations, and playtest instructions.
- Update the root README game description only when completion is verified.

Acceptance: another developer can find the level, player, tunable values, and art
references without reading every script. The documented replacement procedure
is checked with a small reversible art change before claiming it works.

### 7. Verify and deliver

- Run a scene/script startup check from the repository root, using a Godot 4.7
  executable available on the implementation machine:

  ```sh
  godot --headless --path 2d-platform --quit-after 120
  ```

- Play in the editor: movement, jumps, all attacks in both directions, enemy
  damage/defeat, hazard death, falls, collectibles, camera edges, pause/resume,
  death/retry, win/retry, and quit. Repeat retries to check reset behavior.
- Test keyboard and an actual gamepad when available. Explicitly report missing
  controller or visual checks; headless success alone does not complete this plan.
- Use focused automated checks if state or damage logic needs them; do not add
  a testing framework just to complete this small game.
- Review the diff for unrelated changes and run `git diff --check`.
- After explicit publication authorization, create a scoped branch, commit, push,
  and PR to `joacod/godot-games`. Include scenes added, controls, art replacement
  instructions, verification results, and any remaining limitations.

## Completion checklist

- [ ] Godot 4.7 opens the project and Play starts the level without script/scene errors.
- [ ] Movement, camera, jumps, collectibles, hazards, and simple combat are playtested.
- [ ] All three attacks deal damage and complete their animations.
- [ ] Death, win, pause, and retry behave consistently and reset correctly.
- [ ] Keyboard gameplay and menus work; controller verification status is recorded.
- [ ] One cohesive short level is complete, with readable danger and a clear exit.
- [ ] Reusable scenes and exposed values remain simple and understandable.
- [ ] Art replacement instructions describe the actual supported format and are checked.
- [ ] Project README and root game description accurately reflect verified behavior.

## Out of scope

Multiple levels, checkpoints, saves, online features, Steam integration,
achievements, export packaging, settings menus, complex combos, extra movement
abilities, new monetization, Story Studio integration, unrelated projects,
engine downgrades, and a generalized template or skin framework.
