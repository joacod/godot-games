# Polish the platformer into a complete demo

Status: the original playable-level plan is complete and accepted by the user
on 2026-10-01. This is the new active plan. Steps 1–6 are implemented; Step 7 has not started.

## Goal

Turn the existing level into a cohesive demo with stronger graphics, responsive
movement, readable combat, polished menus, and a final boss that gives the run
a satisfying ending.

Target flow: title screen → Play → platforming and combat → boss arena →
boss defeat → demo complete → Play Again or Main Menu.

“Landing page” means the in-game title/main menu, not a separate website.
The previous plan's optional follow-ups do not block this new work.

## Starting point

- Godot 4.7, GDScript, Mobile renderer, 1920 × 1080 viewport with expand stretch.
- `main.tscn` currently starts the level directly. It contains the TileMap,
  player, following camera, one patrol enemy, spikes, two optional gems,
  exit, HUD, route signs, and pause/death/win UI.
- Movement, three attacks, striking-frame damage, health, invulnerability,
  hazards, pause, full-level retry, and keyboard/gamepad mappings already work.
- `scenes/run_state.gd` owns gameplay transitions. Keep that ownership clear
  while adding scene navigation and the boss encounter.
- [README.md](README.md) describes current behavior and editing locations;
  [ASSETS.md](ASSETS.md) records current art and collision data.
- Existing focused suites cover damage/death/retry, combat, the game loop,
  and route traversal. Adapt them when behavior intentionally changes.

## Scope and decisions

- Keep one level and one final boss. Refresh the existing route rather than
  building a campaign or procedural levels.
- Use a cohesive pixel-art direction built around the existing creature player
  and Gorgon enemy: a ruined fortress with a distinct final arena. Choose
  backgrounds, terrain, props, effects, and UI that fit together.
- Keep current art where it fits. Document any added/replaced assets and check
  their alignment, collision silhouettes, and attack frames.
- Improve existing movement with jump forgiveness and variable jump height.
  Improve the three existing attacks before adding new player abilities.
- Ordinary combat and gems remain optional. The final boss is required to
  complete the demo; reaching the old exit alone will no longer win.
- Add one session-only boss-entry retry point so learning the boss does not
  require replaying the entire level. No saves or general checkpoint system.
- Keep exported tuning values and reusable gameplay scenes straightforward.
  No generic menu router, skin loader, combat framework, or new dependencies.
- Keep engine, renderer, and display settings unless a demonstrated problem
  requires changing them. TileMap migration is not a goal of this plan.

## Working rules

Implement in order. For each requested step, read relevant scenes/scripts,
explain non-trivial implementation choices, and wait for confirmation before
coding. Complete only that step, record results here, and stop.

Use brief implementation records: files/behavior changed, checks run, and
remaining issues. Keep the README accurate about implemented behavior rather
than presenting future steps as already available. Report missing live checks
honestly; publication is separate from demo completion.

## Implementation sequence

### 1. Add the landing screen and menu navigation

- Add a dedicated title scene as the configured startup scene. Keep
  `main.tscn` as the playable level, runnable directly with F6.
- Provide Play, How to Play, and Quit. How to Play shows actual keyboard and
  gamepad bindings and returns to the title screen.
- Establish a simple shared UI theme with clear hierarchy, button states,
  initial focus, and consistent spacing. Step 2 supplies the final visual treatment.
- Add Main Menu to pause, death, and win screens. Keep Resume, Retry, and Quit
  where appropriate; returning to the title must leave no paused gameplay behind.
- Starting Play always creates a fresh run. Avoid persistent state or an
  autoload unless a concrete navigation need requires it.

Acceptance: startup lands on the title screen; Play, help/back, resume, retry,
Main Menu, and Quit work. Repeated menu → Play cycles reset the run. Mouse,
keyboard focus, and existing gamepad mappings remain usable.

### 2. Give the world and UI a cohesive visual identity

- Replace the flat gray presentation with background depth, restrained parallax,
  terrain variation, and fortress props that distinguish playable surfaces.
- Improve spikes, gems, and the exit marker so their meaning and visible extent
  agree with their detection areas. Keep danger readable against the background.
- Apply the visual direction to the title screen and all menus through the
  shared theme. Use a consistent font, palette, borders, and focus treatment.
- Replace the large permanent control block with a compact health/collection
  HUD; retain full controls in How to Play and brief contextual prompts in the level.
- Preserve geometry during this visual pass. Document asset sources and any
  SpriteFrames changes in ASSETS.md; do not change hitboxes to hide art misalignment.

Acceptance: inspected gameplay and menu frames look like one game. Player,
enemy, landing surfaces, hazards, pickups, HUD, and focus are clearly readable.
Art and parallax do not conceal gaps or expose space beyond camera bounds.

### 3. Improve movement and camera feel

- Add short, exported coyote-time and jump-buffer windows. Consume each request
  once; no extra midair jumps from a held button or buffered input.
- Add variable jump height: releasing Jump early gives a shorter jump, while
  holding it preserves a useful full jump.
- Tune acceleration/deceleration only where play reveals a need. Keep Walk and
  Run meaningful and preserve movement during attacks.
- Add restrained camera smoothing/look-ahead only if it improves landings and
  hazard visibility. Keep bounds and reset positioning correct.
- Clear buffered input and movement transients on death, retry, and menu return.
  Pause must freeze any new timing windows.

Acceptance: late and slightly early jump presses feel forgiving; short and full
jumps are deliberate. No double jumps or unwanted jumps after resume/retry.
The mandatory route and optional shelves remain reachable after tuning.

### 4. Make the three attacks distinct and combat readable

- Give the existing attacks useful roles: a fast close strike, a longer-reaching
  strike, and a slower heavy strike. Tune damage, reach, windup, and recovery
  against their visible animation frames; document final values.
- Keep fixed facing per swing, movement during attacks, and one hit per target
  per swing. Do not add combos, a skill tree, or new attack inputs.
- Improve impact feedback with brief flashes, small effects, and restrained
  knockback where it helps. Knockback must not create unavoidable repeated damage.
- Give the existing enemy one clearly telegraphed attack with a punishable
  recovery, retaining bounded patrol and safe ledge behavior. Teach the same
  observe → avoid → punish rhythm the boss will use.
- Keep pause, death cancellation, invulnerability, and defeat behavior consistent.

Acceptance: all three attacks work in both directions and have understandable
tradeoffs. Players can read enemy windup, avoid damage, and punish recovery.
Feedback matches actual hits; defeated enemies cannot damage the player.

### 5. Refresh the level and build the boss approach

- Reshape repetitive stretches into a concise sequence: safe introduction,
  forgiving jumps, optional gems, a teaching combat beat, readable hazards,
  and a recognizable boss approach. No fixed duration is a completion gate.
- Retune spacing using Step 3's movement. Keep useful existing geometry and
  instances; avoid blind jumps and mandatory damage.
- Add a distinct, bounded final arena with room to avoid the planned boss moves.
  Clearly communicate entry, encounter space, and the eventual demo exit.
- Establish the session-only boss retry point at entry. Start the encounter
  with full health; store the entry gem count and restore it on boss retries.
- Before arena entry, Retry restarts the level. After entry, Retry restarts the
  arena encounter with full health and clean combat state. Main Menu/Play Again
  clears the retry point and starts a fresh level.
- In this step, preserve a completable temporary exit until Step 6 installs
  the boss gate. Do not strand the demo between steps.

Acceptance: the refreshed route is readable and has no softlocks. Arena entry
and retry positioning are safe; repeated boss-area retries reset transient
state and preserve the entry count without duplicating gems.

### 6. Add the final boss and demo ending

- Add one dedicated boss scene, visually related to the fortress and existing
  creatures, with a readable silhouette and a compact health bar.
- Use a small explicit state sequence: idle → telegraph → attack → recovery,
  plus hurt/defeat where needed. Give it two attacks: a close sweep and a
  telegraphed ground shockwave that can be jumped.
- At half health, change the pattern or shorten recovery moderately while
  retaining visible tells and a fair damage opportunity. No extra enemy waves.
- Boss health and timings are tunable. Player attacks use the existing damage
  contract; each swing hits the boss once. Clearly show vulnerable and protected
  windows if protection is used.
- Close arena boundaries during the encounter without trapping the player in
  collision geometry. Freeze all boss/projectile timing on pause; clear it on
  defeat, death/retry, and menu return.
- Boss defeat removes attacks, opens the exit, and allows reaching it to show
  Demo Complete with collected count, Play Again, Main Menu, and Quit.
  Completion fires once and cannot be overridden by pause or death.

Acceptance: a full run ends only after defeating the boss and reaching the
exit. Both attacks can be avoided and punished, the second phase remains fair,
and repeated death/retry resets the boss, health bar, gates, and projectiles.

### 7. Polish and verify the complete demo

- Play title → level → boss → ending and correct concrete visual, timing,
  navigation, and readability issues found along the way.
- Check short/full jumps, all attacks in both directions, enemy and boss damage,
  invulnerability, hazards, pickups, camera edges, and optional routes.
- Pause during boss telegraph/attack/recovery; repeat level and boss retries;
  return to Main Menu from pause/death/completion and start again.
- Run startup, focused regression checks, native rendering inspection, and
  `git diff --check`. Add focused boss/navigation checks without a new framework.
- Update README.md, ASSETS.md, and the root game description to reflect the
  completed demo. Record live-check gaps without reopening the old plan.
- Stop after local delivery. Branches, commits, pushes, PRs, and distribution
  require explicit authorization.

Acceptance: the complete demo flow works, graphics and menus are consistent,
and the boss provides a clear ending. Document actual verification and any
remaining bugs; do not use a headless result as evidence of gameplay feel.

## Progress

- [x] 1. Landing screen and menu navigation
- [x] 2. World and UI visual identity
- [x] 3. Movement and camera feel
- [x] 4. Distinct attacks and readable combat
- [x] 5. Refreshed level, arena, and boss retry point
- [x] 6. Final boss and demo ending
- [ ] 7. Complete-demo polish and verification

### Step 1 implementation record — 2026-10-01

- Added `scenes/title.tscn` and `title.gd` as startup, with Play, actual controls
  help/Back, Quit, and initial/restored focus. `main.tscn` still runs with F6.
- Added `scenes/menu_theme.tres` for shared button states, palette, and spacing.
  Pause/death/win scenes now offer Main Menu. `run_state.gd` owns the deferred
  transition, guards duplicate requests, frees the old run, and clears pause.
  Play creates a new level without an autoload or persistent state.
- Updated `project.godot`, README, and this record. Gameplay scripts, level
  geometry, HUD, engine/renderer settings, input mappings, and artwork are untouched.
- Passed startup and `tests/menu_navigation.gd`, plus damage/death/retry,
  combat, game-loop, and level-route suites using Godot 4.7.2. The new suite
  checks help/back focus, injected keyboard/mouse/controller input, repeated
  Play cycles, all three Main Menu paths, state resets, and title Quit.
- Native Metal/Mobile title/help/pause/death/win frames were inspected; layout
  and focus are readable. `git diff --check` passed. Headless runs retain the
  known macOS certificate diagnostic without script/scene errors.
- Remaining live checks: human mouse/keyboard menu playthrough and physical
  gamepad. Final world/menu artwork belongs to Step 2. No assets downloaded,
  commits, branches, pushes, or publication performed.

### Step 2 implementation record — 2026-10-01

- Added a shared native-drawn night fortress background for the title and level,
  with two restrained horizontal parallax layers, clouds, stars, moon, and ruins.
  Added `fortress_art/masonry.svg` at the existing atlas coordinates and four
  used CraftPix free medieval PNGs, with visible decorative mounts and a pier.
- Updated `main.tscn`, title/help, the shared theme, pause/death/win menus,
  spikes, gems, and exit visuals. The HUD now shows health/count/pause in one
  compact strip; full controls stay in How to Play, with brief jump/combat signs.
  ASSETS.md records sources, license, dimensions, font, and visual alignment;
  README describes the implemented presentation. No SpriteFrames changed.
- Passed startup and menu-navigation, damage/death/retry, combat, game-loop,
  and level-route suites with Godot 4.7.2. Compared TileMap cells/collision
  polygons, camera limits, and hazard/pickup/exit shapes against HEAD: unchanged.
  Movement, attack/damage scripts, navigation/state owner, input mappings,
  player/enemy sheets, original Tileset.png, engine, and renderer are untouched.
- Inspected native Metal/Mobile frames for title/help, start/gem/combat/spikes/exit,
  pause/death/win, and wide/tall viewport camera edges. Background coverage and
  camera-bound assertions passed; native gap pixels confirm empty cells show
  background. `git diff --check` passed. Headless checks retain the existing
  macOS certificate diagnostic without script/scene errors.
- Remaining live checks: fresh human route/menu playthrough and physical gamepad.
  Step 3 has not started. No branch, commit, push, PR, or publication performed.

### Step 3 implementation record — 2026-10-01

- Added exported `coyote_time` and `jump_buffer_time` (both 0.12 s), plus
  `jump_cut_ratio` (0.45) in `scenes/main_character.gd`. Each request is consumed
  once; holding Jump cannot repeat on landing or create an extra midair jump.
  Early release also shortens a buffered jump released before touchdown.
- Windows freeze with pausable gameplay. Resume clears pending input and
  requires release before a fresh press, preventing controller confirm from
  jumping. Death, Retry, and Main Menu clear movement transients; a new player
  ignores a jump held across navigation until release.
- Added `tests/movement.gd`; adapted `tests/level_route.gd` to hold full jumps
  through ascent. Updated README and this record. Speeds, acceleration,
  deceleration, camera script/bounds, geometry, combat, art, scenes, input
  bindings, engine, and renderer are untouched. No evidence justified further
  speed or camera tuning without a human feel check.
- Godot 4.7.2 startup and all six suites passed: movement, menu navigation,
  damage/death/retry, combat, game loop, and level route. At fixed 60 Hz, full
  jumps reached 169.6 px and early-release jumps 79.2 px. Walking/running routes,
  patrol phases, optional shelves/returns, and camera-bound checks passed.
  Movement checks also passed in native Metal/Mobile rendering. Headless runs
  retain the known macOS certificate diagnostic without script/scene errors.
  `git diff --check` passed.
- Remaining live checks: human short/full-jump feel, fresh route playthrough,
  and physical gamepad. Native movement verification was automated, without
  visual inspection or a human playtest. Step 4 has not started. No assets,
  branches, commits, pushes, PRs, or publication performed.

### Step 4 implementation record — 2026-10-01

- Tuned Z as the longer thrust (1 damage, 0.50 s), X as the quick close strike
  (1 damage, 0.25 s), and C as the heavy uppercut (2 damage, 0.75 s). Existing
  sheets/frame order remain; FPS and final recovery holds changed. Hitboxes
  follow the visible reach/height; the uppercut strikes only on raised frame 3.
  Fixed facing, movement, and one hit per target per swing are preserved.
- The Gorgon uses explicit patrol/windup/strike/recovery states: a stationary
  0.55 s gold tell, 0.15 s committed forward strike, and 0.75 s harmless recovery.
  Body contact now senses the player without damaging them. Hits interrupt
  attacks, flash/show a native impact burst, and apply at most 0.16 s of
  knockback constrained by patrol bounds and ledge detection. Defeat clears
  attacks immediately; pause freezes combat, animation, and knockback.
- Changed player/enemy scripts and scenes, the combat suite, combat sign,
  controls-help role label, README, ASSETS, and this record. ASSETS documents
  final timings, damage, shapes, and effects. No new assets or dependencies.
  Geometry, movement/camera, navigation/state owner, input mappings, other
  menus/HUD, engine, and renderer are untouched. The existing untracked
  `tests/movement.gd.uid` was preserved.
- Godot 4.7.2 startup and all six suites passed: movement, menu navigation,
  damage/death/retry, combat, game loop, and level route. Native Metal/Mobile
  combat checks passed. Native frames were inspected for every attack in both
  directions, enemy windup/strike/recovery, impact, combat sign, and controls help.
  Headless checks retain the known macOS certificate diagnostic without script
  or scene errors. `git diff --check` passed.
- Remaining live checks: human attack tradeoffs/combat feel, fresh full route,
  and physical gamepad. Step 5 has not started. No branch, commit, push, PR,
  or publication performed.

### Step 5 implementation record — 2026-10-01

- Condensed `main.tscn` from 24,768 to 11,280 px wide, retaining useful opening
  geometry and arranging nine main stretches around forgiving gaps, both optional
  gem shelves, one teaching patrol, readable spikes, and a courtyard approach.
  Repositioned existing instances/props and prompts. Added a 2,112 px-wide
  courtyard with decorative piers, arches, banner, and an entry boundary.
- `run_state.gd` now records entry once, restores full health, bounds the arena,
  and reloads pause/death retries at a safe arena spawn with the entry count.
  Scene replacement clears combat/movement state; approach gems cannot be
  collected again. Before entry, Retry still starts the level. Completion's
  button reads Play Again and starts fresh; Main Menu/Play clears entry state.
  The temporary exit remains completable. No autoload or persistent saves.
- Added `tests/arena_retry.gd` and its generated UID. Strengthened the route
  suite to track damage before entry healing. Updated README, ASSETS, and this
  record. Movement, player/enemy combat, input mappings, title/help, shared theme,
  reusable hazard/pickup/exit scenes, texture atlases/SpriteFrames, engine, and
  renderer are untouched. No assets or dependencies were added.
- Godot 4.7.2 startup and all seven focused suites passed: movement, navigation,
  damage/death/retry, combat, game loop, route, and arena retry. Walking/running
  routes, patrol phases, optional shelf returns, and camera bounds passed.
  Arena checks also passed with native Metal/Mobile rendering and exercise
  real entry/collection physics, 0/1/2 gem snapshots, repeated death/pause
  retries, safe bounds/spawn, clean transients, held confirm,
  temporary exit, Play Again, and Main Menu/Play resets.
- Native Metal/Mobile start/gem/patrol/spikes/approach/courtyard and wide/tall
  arena-retry frames were inspected. Corrected a floating barrel and courtyard
  draw order found during inspection. Added a one-time HUD redraw after arena
  restoration to fix missing native HUD draw lists, with a native pixel check.
  `git diff --check` passed. Headless runs retain the known macOS certificate
  diagnostic; editor import generated the
  UID but could not save user editor settings under the sandbox. No scene/script
  errors occurred.
- Remaining live checks: human route pacing/combat playthrough and physical
  gamepad. The courtyard has no boss yet; Step 6 has not started. No branch,
  commit, push, PR, or publication performed.

### Step 6 implementation record — 2026-10-02

- Added dedicated `scenes/boss.tscn` / `boss.gd` and generated UID. The
  courtyard guardian reuses Gorgon art with a larger silhouette, teal tint,
  native gold crown, hit flash, and a compact teal/gold health bar. No assets
  were downloaded and no dependencies were added.
- Boss uses idle → telegraph → attack → recovery → idle, with terminal defeat.
  It alternates a committed close sweep and two jumpable ground shockwaves.
  All windows remain vulnerable through the existing player damage contract;
  hits flash without interrupting its tells. Default health is 12, damage 1,
  tells are 0.7/1.0 s, and recovery shortens from 1.2 to 0.85 s at half health.
  Pause freezes all state/animation/wave timing. Death and navigation clear it.
- `run_state.gd` starts the boss on entry and arena retry, owns the boss health
  UI and gate opening, and rejects completion until defeat. The exit has a
  sealed marker and a second physical gate. Defeat clears attacks, opens both
  gates, and unlocks the exit; reaching it shows Demo Complete with collected
  count, Play Again, Main Menu, and Quit. Retry replaces the boss, waves, bar,
  and gates with full health and the existing entry gem snapshot.
- Updated `main.tscn`, exit script, completion title, README, ASSETS, and this
  record. Added `tests/boss.gd` and generated UID. Adapted navigation/game-loop/
  arena-retry suites for the required boss defeat; route checks stop at entry
  and the boss suite covers the encounter/exit. Player movement/combat, ordinary
  enemy, route terrain, hazard/pickup scenes, sprite sheets, shared theme,
  startup/input settings, camera script/bounds, engine, renderer, and root
  README are intentionally untouched. Root description/final polish stay in Step 7.
- Passed startup and all eight focused headless suites with Godot 4.7.2.
  Boss checks cover physical entry, each player attack in both directions,
  once-per-swing damage, sweep commitment/retreat, both damaging and jumpable
  wave directions, pause in every combat state, phase-two timing, death cleanup,
  retry resets, physical exit blocking, one defeat, unlocked exit traversal,
  terminal completion, and fresh Play Again. An input-driven fight defeats both
  phases without taking damage. Walking/running route and existing regressions
  pass. Headless import generated both new UIDs; the sandbox still prevents
  saving user editor settings and emits the known macOS certificate diagnostic.
- Native Metal/Mobile boss checks also passed, including the input-driven
  fight. Inspected sweep tell, travelling waves/jump, settled arena retry,
  defeated/open-exit, and Demo Complete frames. Corrected the missing crown
  vertices and default gray health-bar styling found during inspection; native
  pixel checks verify the crown and restored player HUD. `git diff --check`
  passed and every script has its UID.
- Remaining live checks: human boss feel/readability, full manual run, and a
  physical gamepad. Step 7 has not started. No branch, commit, push, PR, or
  publication performed.

## Out of scope

A separate website, multiple levels or bosses, procedural generation, online
features, persistent saves, achievements, inventory/equipment, complex combos,
new movement abilities such as dash or double jump, generic frameworks,
engine migrations, export packaging, and store publishing.
