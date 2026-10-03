# 2D Platform

A small Godot platformer for learning and experimentation. Jump across one
concise level, fight or avoid a patrol, collect two optional gems, defeat the
courtyard guardian, and reach the unlocked EXIT to complete the demo.
The world and menus share a night fortress style with layered silhouettes,
moss-capped stone, gold focus, and a teal exit marker.

## Open and play

Use Godot 4.7; development checks use 4.7.2. Import [project.godot](project.godot)
in the Godot Project Manager, open it, wait for asset import, and press **F5**.
The title screen offers Play, How to Play, and Quit. Play starts a fresh level.
For level editing, press **F6** with [main.tscn](main.tscn) open to run it directly.
Scripts use GDScript; no .NET setup is needed.
Keep the Mobile renderer and the configured 1920 × 1080 viewport with expand
stretch unless a demonstrated display problem requires changing them.

## Controls

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

## Gameplay

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
the level kill immediately, even during invulnerability.

Z is a longer thrust (1 damage, 0.50 s), X a fast close strike
(1 damage, 0.25 s), and C a slow raised uppercut (2 damage, 0.75 s). The
two-health enemy takes two light hits or one heavy hit. Confirmed hits flash,
show a small burst, interrupt enemy attacks, and push surviving enemies a
short distance without crossing patrol bounds or ledges. Movement and jumping
remain available during a swing, its facing stays fixed, and another attack
cannot interrupt it. Patrol combat and gems are optional; the guardian is required.

## Pause and retry

Pause freezes gameplay and offers Resume, Retry, Main Menu, and Quit. Death
shows Retry, Main Menu, and Quit. Demo Complete shows Play Again, Main Menu,
Quit, and the collected count. Main Menu discards the current run and clears
pause. Play always starts fresh.
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
not cancel the attack or change its committed facing. At or below half health,
the bar announces phase two and recovery shortens from 1.2 to 0.85 seconds; tells,
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

From the repository root, use Godot 4.7.2 on your PATH. On a fresh checkout,
import assets before running terminal checks:

```sh
godot --headless --path 2d-platform --import
```

Then run a startup check:

```sh
godot --headless --path 2d-platform --quit-after 120
```

The implementation machine uses
`/Applications/Godot.app/Contents/MacOS/Godot` in place of `godot`.
For changes to gameplay, run the existing focused checks:

```sh
for suite in movement menu_navigation damage_death_retry combat game_loop level_route arena_retry boss; do
  godot --headless --path 2d-platform --fixed-fps 60 \
    --script "res://tests/$suite.gd" || exit 1
done
git diff --check
```

Then play in the editor. Check walking/running, landings and gaps, both optional
gem shelves and their return routes, every attack facing both ways, enemy
windup, strike avoidance, recovery punishment, and defeat. Check spikes, falls,
camera edges, and pause/resume during an attack. Retry before and after
courtyard entry with zero, one, and two gems; confirm
full health, clean combat, safe positioning, and the recorded entry count.
Play Again and Main Menu/Play must start fresh. Navigate each menu without a
mouse and test Quit. For art changes, inspect frame alignment, both facings,
attack reach, and body/attack shapes
with **Debug → Visible Collision Shapes** enabled. Use a physical gamepad when
available; injected input checks cannot establish device behavior.

## Maintenance notes

- `scenes/run_state.gd` owns run transitions and the session-only arena retry
  point. Keep health, gem count, gates, boss attacks, and pause resets together.
- Native scene replacement previously left the HUD invisible after title →
  Play and arena Retry. Keep the deferred `_redraw_hud()` refresh; the menu
  and boss suites include native pixel checks for these paths.
- Native screenshot helpers force a draw on static screens so capture does
  not stall waiting for `frame_post_draw`. To inspect menu and boss frames,
  create output folders and run from the repository root:

  ```sh
  mkdir -p /private/tmp/platform-menu /private/tmp/platform-boss
  MENU_CAPTURE_DIR=/private/tmp/platform-menu godot --path 2d-platform \
    --disable-vsync --fixed-fps 60 --script res://tests/menu_navigation.gd
  BOSS_CAPTURE_DIR=/private/tmp/platform-boss godot --path 2d-platform \
    --disable-vsync --fixed-fps 60 --script res://tests/boss.gd
  ```

Headless checks cannot establish gameplay feel or physical controller behavior.
Physical gamepad testing remains unconfirmed. The existing macOS headless
certificate diagnostic is recorded separately from script/scene failures.
The level still uses Godot's deprecated TileMap node. There is no export setup;
player and original tileset provenance remain unresolved in [ASSETS.md](ASSETS.md#existing-art).
