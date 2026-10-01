# Complete one playable platformer level

Status: Steps 1–5 are implemented and manually validated, as reported by the
user on 2026-10-01. Runtime checks and rendered frame inspection also passed.
Step 6 is complete with a checked art replacement procedure. Step 7 has not started.

Manual validation report (2026-10-01): the user reported testing everything
implemented through Step 5, including that step. This records acceptance of
movement, camera, jumps, all attacks, combat, damage and death, collectibles,
pause/resume, menus, retry, and the complete route to the exit. Individual
scenarios, input devices, and timed run durations were not separately recorded;
physical controller testing and the 1–2 minute pacing target remain unconfirmed.
The pending manual checks in the implementation records below describe the
state before this report and are now superseded for gameplay acceptance.

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

Implementation and verification (2026-10-01):

- `project.godot` names physics layers World (1), Player (2), Enemy (3),
  Attack detection (4), Pickups (5), and Hazards (6). Only World, Player, and
  Hazards are used now: the player is on layer 2 and collides with World;
  hazards are on layer 6 and detect Player. Existing tiles remain on World.
- `scenes/main_character.gd` starts with three health points, exposes
  `max_health` and `invulnerability_duration` (1 s), and provides
  `take_damage(amount)` for Step 3 contact damage. Ordinary hits tint the
  sprite red and blink during invulnerability. Physics time drives the
  countdown, so it freezes when the tree is paused. Non-positive damage and
  hits during invulnerability are ignored.
- `kill()` bypasses invulnerability, emits death once, stops movement and
  animation, and clears attacks and invulnerability. No enemy or attack
  damage logic was added; those remain Step 3.
- `scenes/hazard.tscn` and `scenes/hazard.gd` provide a reusable lethal
  `Area2D`, with a 128×32 px collision rectangle and visible red spikes.
  `main.tscn` places one at (600, 864) on the existing starting platform.
  Final hazard placement and art tuning remain Step 5.
- `scenes/run_state.gd` is the single run transition owner. Falling below
  `fall_kill_y` (1120 px), at any horizontal position, kills the player.
  Death pauses the entire gameplay tree and shows `scenes/death_ui.tscn`.
  Its Retry and Quit buttons remain active while paused; Retry has initial
  focus. Retry guards duplicate requests and defers a whole-scene reload,
  restoring the initial scene state. Quit closes the game.
- Verification commands from the repository root (Godot 4.7.2):

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step2-check.log --quit-after 120
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step2-tests.log \
    --script res://tests/damage_death_retry.gd
  git diff --check
  ```

- Startup passed with no script/scene errors. Focused runtime checks passed
  for initial health, collision masks, ordinary damage, invulnerability and
  its expiration, paused countdown, feedback reset, health depletion,
  duplicate death rejection, frozen movement, initial menu focus, actual
  spike overlap and falls during invulnerability, three full scene retries,
  spawn/velocity/health/combat resets, and the connected Quit button.
  Sandboxed headless runs retain the previously observed macOS
  `get_system_ca_certificates` error.
- Native Metal/Mobile rendering exited 0 without errors. Captured frames
  were inspected for visible spike placement, damage tint, and centered
  death UI with visible Retry focus. Static frames and runtime checks do
  not establish continuous animation, keyboard/mouse usability, or game feel.
- Manual acceptance: the user reported manual testing of Step 2 on
  2026-10-01. Step 2 is complete based on that report and the runtime checks
  above. Individual manual scenarios and input devices were not separately
  recorded. Explicit gamepad mappings and actual controller checks remain
  Step 4. Step 3 has not started.

### 3. Make combat playable

- Add a reusable enemy scene with bounded patrol, world collision, contact damage,
  health, and clear defeat feedback. Prevent enemies from walking into unintended pits.
- Add player attack hitboxes that follow facing and activate only on striking frames.
- Expose damage, enemy health, patrol speed, and invulnerability duration.
- Use a simple style-compatible placeholder if suitable enemy art is unavailable.

Acceptance: each attack works facing either direction, one swing cannot damage
the same enemy repeatedly, contact damage respects invulnerability, and defeated
enemies stop damaging the player. Confirm pause preserves attack timing.

Implementation and verification (2026-10-01):

- `scenes/enemy.tscn` and `scenes/enemy.gd` add a reusable Gorgon enemy.
  Exposed defaults are `max_health` 2, `contact_damage` 1, `patrol_speed`
  90 px/s, and patrol offsets -90/+90 px from its starting position. It
  collides with World, reverses at walls and patrol bounds, and probes the
  floor beyond its body and the next tick's movement to turn before ledges.
  `main.tscn` instances it at (390, 864), patrolling x=300–480 on the existing
  starting platform before the spikes. Final placement remains Step 5.
- Enemy bodies use Enemy (layer 3) and collide with World. Their contact
  `Area2D` detects Player (layer 2) and applies damage throughout overlap;
  the player's existing 1 s `invulnerability_duration` prevents immediate
  repeated hits. Hurt plays once with a red tint. Defeat immediately clears
  motion and collision participation and stops contact damage, then plays
  the non-looping death animation before removing the enemy.
- `scenes/main_character.tscn` adds an 84×80 px attack detection area on
  layer 4, detecting only Enemy. Its center is 94 px to either side of the
  sprite's x origin and y=60 px. `scenes/main_character.gd` exposes
  `attack_damage` (1), mirrors the area with the swing's fixed facing, and
  records enemies hit during each swing. It checks existing overlaps when
  striking begins, so an enemy need not enter the area during the attack.
  Each swing can hit multiple enemies but only once each; new attacks cannot
  interrupt it. Death cancels attack damage and clears hit history.
- Striking frames use zero-based, inclusive indices at 10 fps: attack 1
  frame 4 (0.4–0.5 s), attack 2 frame 2 (0.2–0.3 s), and attack 3 frames 2–3
  (0.2–0.4 s). Windup and recovery deal no damage. Attack 1 was narrowed to
  its extended punch after inspecting the rendered frame. Animation playback,
  invulnerability, enemy movement, and hurt timing inherit gameplay pause.
  A player-operated pause menu is still Step 4 work.
- `enemy_sprites/` contains only the three used, unmodified `Gorgon_1`
  walk/hurt/death sheets from CraftPix's free Gorgon pack, downloaded using
  the signed-in browser. [Asset sources](ASSETS.md) records the product,
  license, frame layout, and collision dimensions. Existing player art and
  tiles, level geometry, camera, run-state/death UI, input mappings, engine,
  and renderer remain unchanged.
- Verification commands from the repository root (Godot 4.7.2):

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step3-startup.log --quit-after 120
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step3-tests.log --script res://tests/combat.gd
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step3-regression.log \
    --script res://tests/damage_death_retry.gd
  git diff --check
  ```

- Startup and both runtime suites passed with exit 0 and no script or scene
  errors. Combat checks cover all attacks in both directions through actual
  input actions and physics overlaps; harmless windup, ignored attack
  interruption, fixed facing while moving, hits only during striking frames,
  one hit per target with multiple targets, targets behind/out of reach,
  second-swing defeat and removal, sustained contact and invulnerability,
  pause during windup/strikes and contact cooldown, ledges at both ends of a
  platform, explicit patrol bounds, wall reversal, and two full scene retries
  restoring enemies and combat state. Step 2's existing regression checks
  passed unchanged. Sandboxed headless runs retain the previously observed
  macOS `get_system_ca_certificates` error; asset import also reported a
  sandbox-blocked editor-settings save outside the repository.
- Native Metal/Mobile rendering exited 0 without errors. Temporary scripted
  captures in `/tmp` were inspected at spawn, during hurt/death, and during
  all three striking animations facing both directions. Every captured
  strike reduced enemy health from two to one. These checks establish static
  rendering and scripted combat behavior, not continuous game feel or manual
  keyboard usability. Manual combat acceptance was pending at implementation:
  try each attack in both directions, defeat or jump past the patrol, take
  contact damage, and die/retry. Actual controller checks remain Step 4. Stop here;
  no Step 4 features have been implemented.

### 4. Finish the game loop and controls

- Add reusable collectible and exit scenes and a HUD for health and count.
- Add win and pause UI; reuse the same retry behavior as death.
- Keep existing keyboard controls; add pause and explicit gamepad mappings for
  movement, jump, run, and all three attacks.
- Support keyboard and controller menu navigation with visible initial focus.
  Display the actual controls without requiring the player to read source code.

Acceptance: collect, pause/resume, die/retry, and win/retry all work. Menus are
usable without a mouse. Winning and dying cannot trigger competing screens.

Implementation and verification (2026-10-01):

- `scenes/collectible.tscn` / `.gd` add a reusable gold gem on Pickups
  (layer 5), detecting only Player. Actual overlap collects once, removes the
  gem, and emits `collected`. `scenes/exit.tscn` / `.gd` add a reusable green
  doorway marked EXIT that detects Player and emits `reached`. Two provisional
  gems and an exit are instanced in `main.tscn`; final placement remains Step 5.
  Winning requires neither every gem nor enemy defeat.
- `scenes/hud.tscn` displays health, collected count, and actual keyboard,
  controller, and menu controls. The player's `health_changed` signal updates
  the HUD. Analog movement retains partial speed, with facing normalized to
  left/right so partial stick input does not shrink the attack's reach.
- `scenes/run_state.gd` remains the transition owner, adding PAUSED and WON.
  Gameplay children pause; the owner and menus can process while paused.
  Pause freezes movement, enemy animation, attacks, and invulnerability.
  `scenes/pause_ui.tscn` provides Resume, Retry, and Quit; `scenes/win_ui.tscn`
  provides collected count, Retry, and Quit. Both match the existing death UI.
  Resume initially has visible focus on pause, and Retry on win/death.
  The first terminal transition wins; paused/terminal runs reject competing
  screens and player damage. All three menus share guarded whole-scene Retry,
  resetting health, enemies, pickups, count, motion, and combat state.
- `project.godot` preserves keyboard movement (left/right arrows), jump (up),
  run (Shift), and attacks (Z/X/C); adds Esc pause; and explicitly maps D-pad
  or left stick movement, A/south jump, LB run, X/west attack 1, Y/north attack 2,
  B/east attack 3, and Start pause. Menus use arrows, D-pad, or left stick;
  Enter/Space/A confirm. Controller A is explicitly added to `ui_accept`;
  this project's engine defaults included only keyboard Confirm events.
- Verification commands from the repository root (Godot 4.7.2):

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step4-startup.log --quit-after 120
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step4-tests.log --script res://tests/game_loop.gd
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step4-damage.log \
    --script res://tests/damage_death_retry.gd
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step4-combat.log --script res://tests/combat.gd
  git diff --check
  ```

- Startup and all three suites passed, exit 0, with no script/scene errors.
  The new suite checks real pickup and exit overlaps, HUD updates, optional
  collection/combat, frozen strike timing and cooldown, keyboard and synthetic
  controller menu navigation/confirmation, displayed gamepad bindings, analog
  facing, competing pause/death/win rejection, and full retries from all three
  menus. Existing damage/death/retry and combat regression suites pass.
  Headless runs retain the previously observed macOS certificate error.
- Native Metal/Mobile rendering exited 0 without errors. Temporary scripted
  frames in `/tmp` were inspected for HUD/control readability, visible gem/exit,
  and centered pause/win menus with initial focus. Static frames and synthetic
  input events do not establish continuous gameplay feel or physical gamepad
  behavior. Manual acceptance was pending at implementation: collect, pause
  during a swing, resume, die/retry, reach the exit/win/retry, navigate menus
  without a mouse,
  and try all displayed bindings on an actual controller when available.
- Existing level geometry, camera, art, enemy/hazard scenes, death UI, renderer,
  viewport settings, and README files remain unchanged. Stop after Step 4;
  level tuning, documentation preparation, and final delivery remain Steps 5–7.

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

Implementation and verification (2026-10-01):

- `main.tscn` remains the entry and editable level scene. It reuses the current
  TileMap and colliding stone tiles across a 24,768 px route, with 24 main
  platforms, 96–160 px gaps, and platform tops at y=736, 800, or 864 px.
  Adjacent upward steps are at most 128 px. Broad landing areas, a grounded
  safe spawn at (160, 718), end walls, and signs introduce the goal, first
  jump, optional collection, combat, spikes, and final approach.
- Two elevated gem shelves at y=608 branch from higher preceding platforms
  through deliberate run jumps. Lower ground offers a route beneath them;
  neither gem is required. Shelf placement accounts for the player's 138 px
  collision height, keeping the lower route clear. Both shelves have a safe
  return to the main route.
- The enemy instance is at (10624, 864), with patrol offsets -160/+160 on a
  1600 px wide platform. This level's instance uses uniform 0.85 scale for
  forgiving jump clearance while preserving matching art and collision shapes.
  A sign offers fighting or running and jumping past it; defeat is optional.
  Spikes at (14912, 864) have visible approach and landing room. The green
  exit is at (24528, 800) on the final platform.
- Camera right bound is now 24768; left/top/bottom remain 0/0/1080. Existing
  camera fitting, movement values, damage feedback, reusable gameplay scenes,
  run-state logic, UI, input mappings, artwork, renderer, and engine version
  remain unchanged. No TileMap migration or folder moves were made.
- `tests/level_route.gd` traverses the actual tile geometry using movement and
  jump inputs, without teleporting along the full route. Walking with a short
  run jump past the patrol reaches the exit in 60.0 simulated seconds; running
  throughout takes 34.6 seconds. Both finish at full health without collecting
  gems and visit every main platform. These ideal scripted times do not establish
  the 1–2 minute human pacing target, especially when running throughout.
- The route checks also sample camera containment during both traversals, test
  damage-free run jumps past four patrol phases, and check collection and safe
  returns from both optional shelves. Optional-route and patrol-phase checks
  position the player on a starting platform before exercising real inputs.
  `tests/combat.gd` now captures the real enemy spawn for retry checks instead
  of asserting Step 3's provisional coordinates.
- Verification commands from the repository root (Godot 4.7.2):

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step5-startup.log --quit-after 120
  for suite in level_route game_loop combat damage_death_retry; do
    /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
      --fixed-fps 60 --script "res://tests/$suite.gd"
  done
  git diff --check
  ```

- Startup and all four runtime suites passed with exit 0 and no script/scene
  errors. Headless runs retain the previously observed macOS certificate error.
  Native Metal/Mobile rendering required execution outside the sandbox after
  the sandboxed attempt exited 134; the native check then exited 0 without
  errors. Temporary captures in `/tmp` were inspected at the start, optional
  shelf, combat platform, spikes, and exit.
- Manual acceptance was pending at implementation: play from spawn to exit,
  try collecting both gems and returning to the route, fight or avoid the
  patrol, check jump
  timing and camera readability while moving, and retry after death and win.
  Time successful runs with a new player to assess the 1–2 minute target and
  whether any stretches feel repetitive. Physical controller validation from
  Step 4 also remains pending. Static captures and scripted traversal do not
  establish human usability or continuous gameplay feel. Stop after Step 5;
  documentation preparation and final delivery remain Steps 6–7.

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

Implementation and verification (2026-10-01):

- `README.md` adds Godot opening instructions, actual keyboard/gamepad and menu
  controls, health/combat rules, full-level retry behavior, an editing map,
  exported defaults and level overrides, art guidance, validation commands,
  and manual playtest instructions. It distinguishes the user's reported
  Steps 1–5 acceptance from unconfirmed physical controller and timed human
  pacing checks.
- `ASSETS.md` now documents all player/enemy PNG dimensions, frame counts,
  animation names, FPS and looping, the tileset grid and occupied atlas cells,
  scene origins/scales, body/contact/detection shapes, and striking frames.
  It explains matching-file replacement/reimport/restoration and where to edit
  scene resources for different paths, dimensions, or layouts. Existing asset
  attribution and unresolved player/tileset provenance remain recorded.
- Art references already live directly in scene resources. Gameplay scripts,
  scenes, original PNGs and import settings, folder paths, engine, renderer,
  and root README are unchanged. The root game description remains pending
  final completion verification; no Step 7 delivery work was started.
- A disposable project copy at `/tmp/godot-step6-586zrj8p/project` was imported
  without copying the original `.godot` cache. A temporary GDScript recolored
  nontransparent pixels in `player_sprites/Idle.png` cyan while preserving
  its 1024 × 128 px layout and alpha. Godot reimported that same-path replacement.
  Native Metal/Mobile captures of baseline, replacement, and restored art were
  inspected: cyan art appeared and the original appearance returned. The backup
  was restored byte-for-byte and reimported. Original repository art was never
  changed.
- Temporary runtime checks passed in all three states: the imported texture
  matched an opaque source pixel, idle retained eight frames at 14 FPS with
  looping/playback, and grounded spawn, health, body capsule, and attack rectangle
  remained unchanged. This checks one compatible idle-sheet replacement; other
  sheets and differing layouts still require the documented visual/combat checks.
- Verification commands from the repository root (Godot 4.7.2):

  ```sh
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform \
    --log-file /tmp/godot-platform-step6-startup.log --quit-after 120
  /Applications/Godot.app/Contents/MacOS/Godot --headless --editor \
    --path /tmp/godot-step6-586zrj8p/project \
    --log-file /tmp/godot-step6-586zrj8p/import-restored.log --import
  /Applications/Godot.app/Contents/MacOS/Godot \
    --path /tmp/godot-step6-586zrj8p/project --fixed-fps 60 \
    --log-file /tmp/godot-step6-586zrj8p/restored.log \
    --script /tmp/godot-step6-586zrj8p/check.gd \
    -- restored /tmp/godot-step6-586zrj8p/restored.png
  git diff --check
  ```

- Startup, import, and runtime/render checks exited 0 with no script/scene
  errors. Sandboxed headless runs retain the macOS certificate error; temporary
  editor imports also report blocked editor-settings saves outside the repository.
  Native rendering required execution outside the sandbox after an exit 134,
  then passed. The temporary source-image inspection emits an export warning;
  game code still uses imported scene textures. Local Markdown targets/anchors,
  headings, fences, tables, and whitespace were checked statically; no Markdown
  tooling or dependencies were added. Full gameplay suites were not rerun for
  this documentation-only change. Step 6 is complete; stop here.

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

- [x] Godot 4.7 opens the project and Play starts the level without script/scene errors.
- [x] Movement, camera, jumps, collectibles, hazards, and simple combat are playtested.
- [x] All three attacks deal damage and complete their animations.
- [x] Death, win, pause, and retry behave consistently and reset correctly.
- [x] Keyboard gameplay and menus work; controller verification status is recorded.
- [x] One cohesive short level is complete, with readable danger and a clear exit.
- [x] Reusable scenes and exposed values remain simple and understandable.
- [x] Art replacement instructions describe the actual supported format and are checked.
- [ ] Project README and root game description accurately reflect verified behavior.

## Out of scope

Multiple levels, checkpoints, saves, online features, Steam integration,
achievements, export packaging, settings menus, complex combos, extra movement
abilities, new monetization, Story Studio integration, unrelated projects,
engine downgrades, and a generalized template or skin framework.
