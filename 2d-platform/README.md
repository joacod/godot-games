# 2D Platform

A small Godot platformer for learning and experimentation. Jump across one
concise level, fight or avoid a patrol, collect two optional gems, defeat the
courtyard guardian, and reach the unlocked EXIT to complete the demo.
The world and menus share a night fortress style with layered silhouettes,
moss-capped stone, gold focus, and a teal exit marker.

## Open and play

Use Godot 4.7; development checks use 4.7.2. Import [project.godot](project.godot)
in the Godot Project Manager, open it, wait for asset import, and press **F6**
with [main.tscn](main.tscn) open, or **F5** to run the configured main scene.
F5 opens the title screen with Play, How to Play, and Quit. Play starts a fresh
level; F6 with `main.tscn` open still starts the level directly. Scripts use
GDScript; no .NET setup is needed.
Keep the Mobile renderer and the configured 1920 × 1080 viewport with expand
stretch unless a demonstrated display problem requires changing them.

## Controls and the game loop

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | Left / Right arrows | D-pad / left stick |
| Jump | Up arrow | A / south button |
| Run (hold) | Shift | LB / left shoulder |
| Thrust / Quick / Heavy | Z / X / C | X / west, Y / north, B / east |
| Pause / resume | Esc | Start |
| Navigate menus | Up / Down arrows | D-pad / left stick |
| Confirm menu selection | Enter / Space | A / south button |

Gamepad labels describe Xbox positions; other controllers may print different
letters. Full controls are displayed in How to Play. The compact HUD shows health,
collection count, and a pause reminder; short level prompts introduce jumping
and combat. Mappings live in
[project.godot](project.godot), under Project Settings → Input Map.

Jump has a 0.12-second grace window after walking off a ledge and a
0.12-second buffer for presses just before landing. Hold Jump for full height;
release early for a shorter hop. Each press jumps once. Pause freezes the
windows; Resume discards a pending jump and requires releasing a held button
before a fresh press, so controller confirm cannot also launch a jump.
Death, Retry, and Main Menu clear movement transients.

You start with three health points. The Gorgon stops for a gold windup cue,
strikes forward, then shows a teal recovery cue. Walk or jump clear of the
strike and punish its recovery. Its strike costs one point and gives one
second of invulnerability; body contact is harmless. Spikes and falling below
the level kill immediately, even during invulnerability. Z is a longer thrust (1 damage, 0.50 s), X a fast close strike
(1 damage, 0.25 s), and C a slow raised uppercut (2 damage, 0.75 s). The
two-health enemy takes two light hits or one heavy hit. Confirmed hits flash,
show a small burst, interrupt enemy attacks, and push surviving enemies a
short distance without crossing patrol bounds or ledges. Movement and jumping remain
available during a swing, its facing stays fixed, and another attack cannot
interrupt it. Neither defeating the patrol nor collecting gems is required to win; the final
guardian is required.

Pause freezes gameplay and offers Resume, Retry, Main Menu, and Quit. Death
shows Retry, Main Menu, and Quit; Demo Complete shows Play Again, Main Menu, Quit, and
the collected count.
Main Menu discards the current run and clears pause. Play always starts fresh.
Menus have visible initial focus and work without a mouse. Before courtyard
entry, Retry reloads the level from its start, resetting health, velocity,
enemies, gems, count, and combat state. Entering the courtyard restores full
health, records the gem count, and closes the boundary behind you. After entry,
death/pause Retry reloads the scene at the safe courtyard spawn with full
health, clean combat/movement state, and the recorded count. Approach gems
cannot be collected again. Play Again and Main Menu/Play discard this entry
point and start a fresh level. The entry point lasts only for the current
session; no progress is saved. Quit closes the running game.

## Courtyard guardian

Entry starts a 12-health guardian encounter and shows a compact health bar.
The guardian alternates a close sweep and a ground shockwave. A gold sweep
rectangle marks the committed side and reach: step away or cross behind it.
The ground-line tell signals two low waves travelling away from the guardian;
jump over them. Body contact is harmless. Gold tells last 0.7 seconds for the
sweep and 1 second for the wave. A teal dot marks recovery, giving time to
punish with the existing attacks. All states are vulnerable; hits flash but do
not cancel the attack or change its committed facing. Below half health, the
bar announces phase two and recovery shortens from 1.2 to 0.85 seconds; tells,
damage, and wave speed stay unchanged.

Both courtyard gates stay closed during the encounter. Pause freezes tells,
strikes, recovery, and travelling waves. Death clears active attacks; arena
Retry restores the guardian, health bar, gates, full player health, and entry
gem count. Defeat clears attacks and opens the gates and exit. Reach the exit
to show Demo Complete; defeating the guardian alone does not end the run.

## Find and edit the game

| File or folder | Edit here |
| --- | --- |
| [scenes/title.tscn](scenes/title.tscn) / [title.gd](scenes/title.gd) | Startup title, controls help, focus, and Play navigation |
| [scenes/menu_theme.tres](scenes/menu_theme.tres) | Shared menu/HUD/prompt font, palette, button states, and spacing |
| [scenes/fortress_background.tscn](scenes/fortress_background.tscn) / [fortress_background.gd](scenes/fortress_background.gd) | Shared title/gameplay scenery and restrained camera-driven parallax |
| [main.tscn](main.tscn) | Level tiles, spawn, camera limits, signs, and instances of gameplay scenes and UI |
| [scenes/main_character.tscn](scenes/main_character.tscn) | Player SpriteFrames, atlas references, body collision, and attack area |
| [scenes/main_character.gd](scenes/main_character.gd) | Player movement, health, invulnerability, damage, and striking frames |
| [scenes/enemy.tscn](scenes/enemy.tscn) / [enemy.gd](scenes/enemy.gd) | Enemy art, awareness/strike shapes, telegraph/recovery, health, patrol, and ledge probe |
| [scenes/boss.tscn](scenes/boss.tscn) / [boss.gd](scenes/boss.gd) | Guardian art, sweep/wave states, damage, and exported health/timings |
| [scenes/run_state.gd](scenes/run_state.gd) | Death, fall threshold, pause, win, count, level/arena retry, and Main Menu navigation |
| [scenes/level_camera.gd](scenes/level_camera.gd) | Camera fitting for an expanded viewport |
| [scenes/hazard.tscn](scenes/hazard.tscn), [collectible.tscn](scenes/collectible.tscn), [exit.tscn](scenes/exit.tscn) | Reusable spikes, gems, and goal, each with its matching `.gd` script |
| [scenes/hud.tscn](scenes/hud.tscn), [death_ui.tscn](scenes/death_ui.tscn), [pause_ui.tscn](scenes/pause_ui.tscn), [win_ui.tscn](scenes/win_ui.tscn) | Compact HUD, menus, and focus styling |
| `player_sprites/`, `enemy_sprites/`, `fortress_art/` | Character sheets, masonry atlas, and used CraftPix props; original `Tileset.png` stays untouched |

Select the player or enemy instance in `main.tscn` to override exported values
in the Inspector. Edit the reusable scene or script default to change the base.

| Owner | Editable values and defaults |
| --- | --- |
| Player | `walk_speed` 400 px/s; `run_speed` 700 px/s; `jump_velocity` -900 px/s; `coyote_time` 0.12 s; `jump_buffer_time` 0.12 s; `jump_cut_ratio` 0.45; `deceleration` 3000 px/s²; `max_health` 3; `invulnerability_duration` 1 s; `thrust_damage` 1; `quick_damage` 1; `heavy_damage` 2 |
| Enemy | `max_health` 2; `patrol_speed` 90 px/s; `patrol_left` -90 px; `patrol_right` +90 px; `attack_damage` 1; `windup_duration` 0.55 s; `strike_duration` 0.15 s; `recovery_duration` 0.75 s |
| Level enemy instance | Patrol offsets overridden to -160 / +160 px from its spawn; uniform scale 0.85 |
| Boss | `max_health` 12; `attack_damage` 1; `idle_duration` 0.7 s; `sweep_telegraph` 0.7 s; `sweep_duration` 0.22 s; `wave_telegraph` 1 s; `wave_duration` 2.2 s; `wave_speed` 650 px/s; `recovery_duration` 1.2 s; `phase_two_recovery` 0.85 s |
| Run owner (`main.tscn` root) | `fall_kill_y` 1120 px |
| Project Settings → Physics → 2D | `default_gravity` 2500 px/s² |
| Player's Camera2D in `main.tscn` | Bounds left 0, top 0, right 11280, bottom 1080 px |

Recheck the route and optional shelves after changing speed, jump velocity,
gravity, or body size. Edit `STRIKING_FRAMES` in the player script when attack
timing changes; [the art reference](ASSETS.md#collision-and-attack-data) describes
the current windows and shapes. Camera limits and the fall threshold need to
match any changed level geometry.

## Replace art

[ASSETS.md](ASSETS.md) records sprite sheet dimensions, frame counts, animation
names, playback speeds, tileset layout, collision data, and sources. Follow its
[replacement procedure](ASSETS.md#replace-art) for matching PNGs or a different
frame layout. Resources stay in the existing scenes; there is no runtime skin
selector or configuration loader. Keep the current paths unless a concrete
editing need justifies moving them.

## Validate a change

From the repository root, run a startup check with Godot 4.7 on your PATH:

```sh
godot --headless --path 2d-platform --quit-after 120
```

The implementation machine uses
`/Applications/Godot.app/Contents/MacOS/Godot` in place of `godot`.
For changes to gameplay, run the existing focused checks:

```sh
for suite in movement menu_navigation damage_death_retry combat game_loop level_route arena_retry; do
  godot --headless --path 2d-platform --fixed-fps 60 \
    --script "res://tests/$suite.gd" || exit 1
done
git diff --check
```

Then play in the editor. Check walking/running, landings and gaps, both optional
gem shelves and their return routes, every attack facing both ways, enemy
windup, strike avoidance, recovery punishment, and defeat, spikes and falls, camera edges, and pause/resume during an
attack. Retry before and after courtyard entry with zero, one, and two gems; confirm
full health, clean combat, safe positioning, and the recorded entry count.
Play Again and Main Menu/Play must start fresh. Navigate each menu without a mouse and test Quit. For art changes,
inspect frame alignment, both facings, attack reach, and body/attack shapes
with **Debug → Visible Collision Shapes** enabled. Use a physical gamepad when
available; injected input checks cannot establish device behavior.

## Validation status and limits

The user reported manual acceptance of the original playable-level plan
(Steps 1–5) on 2026-10-01. Runtime checks
and rendered frame inspection also passed. A reversible idle-sheet replacement
was checked with baseline, replacement, and restored native captures. Final
local verification on 2026-10-01 passed startup and all four gameplay suites, with native Metal/Mobile
frames inspected for the start, combat area, pause, death, and win. These checks
supplement the recorded manual acceptance; no fresh editor playthrough was
performed during final verification. No connected gamepad was detected.
Physical controller testing and the 1–2 minute human pacing target remain
unconfirmed. The user accepted the original completion plan as done; these
optional follow-ups do not block the new [demo polish plan](PLAN.md). That plan
covers a title screen, graphics, mechanics, menus, and a final boss. Steps 1–6
(title/navigation, world/UI visual identity, jump forgiveness/height,
distinct attacks/readable combat, refreshed route/arena retry point, and final
boss/demo ending) are implemented. Step 7 remains pending.

Step 1 checks on 2026-10-01 passed startup, the new menu-navigation suite, and
all four existing gameplay suites. Navigation checks cover keyboard help/back,
injected mouse help/back, injected controller confirm, Main Menu from pause,
death, and win, duplicate transition requests, fresh-run resets, and title Quit.
Native Metal/Mobile frames for title, help, pause, death, and win were inspected
for layout and readable focus. These checks do not establish physical controller
behavior or replace a human menu/playthrough check. Headless runs emitted the
existing macOS certificate diagnostic; there were no script or scene errors.

The current level uses Godot's deprecated TileMap node; migration is outside
the demo polish plan's scope. Original-level verification and documentation are complete;
publication requires separate authorization.
Original source/license information for the existing player sheets and tileset
is unresolved; enemy
provenance is recorded in [ASSETS.md](ASSETS.md#gorgon-enemy). There is no export
or distribution setup in the current project.

Step 2 checks on 2026-10-01 passed startup, menu navigation, damage/death/retry,
combat, game-loop, and route suites. Native Metal/Mobile title/help,
start/gem/combat/spikes/exit, pause/death/win, and wide/tall camera-edge frames
were inspected. Tile positions, collision polygons, camera limits, and all
hazard/pickup/exit detection shapes match the pre-step version. Headless checks
retain the macOS certificate diagnostic without script or scene errors.
A fresh human traversal and physical gamepad checks remain unverified.
Sources, atlas layout, and visual-only prop placement are recorded in ASSETS.md.

Step 3 checks on 2026-10-01 passed startup, the new movement suite, and all five
existing regression suites. Movement checks cover coyote/buffer consumption and
expiration, held/released jump height, jumping during attacks, paused windows,
Resume input suppression, death, Retry, and Main Menu/Play resets. At fixed
60 Hz, full jumps reached about 170 px and early-release jumps about 79 px.
Both mandatory route traversals, patrol avoidance, optional shelves, and camera
bounds passed with full jumps held through ascent. The movement suite also
passed with native Metal/Mobile rendering; this was an automated run, without
a human feel assessment or physical controller test. Speeds, acceleration,
deceleration, camera behavior, geometry, and artwork remain unchanged.

Step 4 checks on 2026-10-01 passed startup and all six focused suites. Combat
checks exercise each player attack in both directions, thrust-only reach,
heavy damage, harmless windup/recovery, movement with fixed facing, one hit
per target, pause in strike/windup/recovery, enemy strike avoidance and
punishment, defeat cancellation, bounded knockback, ledge/wall patrol, and
repeated death/retry. Native Metal/Mobile combat checks also passed; rendered
attack, enemy cue, impact, combat-sign, and controls-help frames were inspected.
These are automated checks and visual inspection; human combat feel and a
physical gamepad remain unverified. No new art was downloaded. Level geometry,
movement, navigation logic, input bindings, engine, and renderer are unchanged.

Step 5 checks on 2026-10-01 passed startup and all seven focused suites,
including physical arena-entry overlap, repeated pause/death arena retries for
0/1/2 entry gems, boundary safety, held-confirm suppression, camera positioning,
temporary-exit reachability, and fresh Play Again/Main Menu runs. The arena
retry suite also passed with native Metal/Mobile rendering. The route
suite checks damage throughout traversal so entry healing cannot hide a hit.
Walking and running traversals, patrol phases, both optional shelves, and camera
bounds passed. Native Metal/Mobile frames were inspected for the start, gem,
patrol, spikes, approach, courtyard, and wide/tall arena-retry views. Human
route pacing, combat feel, and physical gamepad checks remain unverified.

Step 6 checks on 2026-10-02 passed startup and all eight focused suites using
Godot 4.7.2. The new boss suite checks physical arena entry, sealed exit,
all player attacks in both directions with one hit per swing, committed sweep
facing and walking avoidance, both wave directions with actual jumping,
pause in telegraph/attack/recovery and projectile motion, phase-two timing,
death cleanup, retry health/bar/gates, single defeat, physical exit blocking,
unlocked exit traversal, Demo Complete, and fresh Play Again. An input-driven
fight defeats both phases without damage using approach/recovery attacks,
sweep retreat, and full jumps over waves.
The route suite now checks reaching the boss entry; encounter and completion
checks live in the boss suite. Native Metal/Mobile boss checks, including the
input-driven fight, also passed. Inspected tell, wave/jump, arena retry,
defeat/open-exit, and completion frames; native pixel checks verify the crown
and restored HUD. `git diff --check` passed. Human fight feel and physical
gamepad checks remain pending. Step 7 has not started.

Run the boss checks with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path 2d-platform --fixed-fps 60 --script res://tests/boss.gd
```
