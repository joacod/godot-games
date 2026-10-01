# 2D Platform

A small Godot platformer for learning and experimentation. Jump across one
level, fight or avoid a patrol, collect two optional gems, and reach the EXIT.

## Open and play

Use Godot 4.7; development checks use 4.7.2. Import [project.godot](project.godot)
in the Godot Project Manager, open it, wait for asset import, and press **F6**
with [main.tscn](main.tscn) open, or **F5** to run the configured main scene.
The level starts immediately. Scripts use GDScript; no .NET setup is needed.
Keep the Mobile renderer and the configured 1920 × 1080 viewport with expand
stretch unless a demonstrated display problem requires changing them.

## Controls and the game loop

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | Left / Right arrows | D-pad / left stick |
| Jump | Up arrow | A / south button |
| Run (hold) | Shift | LB / left shoulder |
| Attacks 1 / 2 / 3 | Z / X / C | X / west, Y / north, B / east |
| Pause / resume | Esc | Start |
| Navigate menus | Up / Down arrows | D-pad / left stick |
| Confirm menu selection | Enter / Space | A / south button |

Gamepad labels describe Xbox positions; other controllers may print different
letters. Controls are also displayed in the HUD. Mappings live in
[project.godot](project.godot), under Project Settings → Input Map.

You start with three health points. Enemy contact costs one point and gives
one second of invulnerability with visible feedback. Spikes and falling below
the level kill immediately, even during invulnerability. Each attack deals one
damage; the enemy takes two hits to defeat. Movement and jumping remain
available during a swing, its facing stays fixed, and another attack cannot
interrupt it. Neither defeating the enemy nor collecting gems is required to win.

Pause freezes gameplay and offers Resume, Retry, and Quit. Death and win show
Retry and Quit; win also shows the collected count. Menus have visible initial
focus and work without a mouse. Retry reloads the entire level from its start,
resetting health, velocity, enemies, gems, count, and combat state. Quit closes
the running game. There are no checkpoints or saved progress.

## Find and edit the game

| File or folder | Edit here |
| --- | --- |
| [main.tscn](main.tscn) | Level tiles, spawn, camera limits, signs, and instances of gameplay scenes and UI |
| [scenes/main_character.tscn](scenes/main_character.tscn) | Player SpriteFrames, atlas references, body collision, and attack area |
| [scenes/main_character.gd](scenes/main_character.gd) | Player movement, health, invulnerability, damage, and striking frames |
| [scenes/enemy.tscn](scenes/enemy.tscn) / [enemy.gd](scenes/enemy.gd) | Enemy art, collision/contact shapes, health, patrol, and ledge probe |
| [scenes/run_state.gd](scenes/run_state.gd) | Death, fall threshold, pause, win, count, and full-level retry |
| [scenes/level_camera.gd](scenes/level_camera.gd) | Camera fitting for an expanded viewport |
| [scenes/hazard.tscn](scenes/hazard.tscn), [collectible.tscn](scenes/collectible.tscn), [exit.tscn](scenes/exit.tscn) | Reusable spikes, gems, and goal, each with its matching `.gd` script |
| [scenes/hud.tscn](scenes/hud.tscn), [death_ui.tscn](scenes/death_ui.tscn), [pause_ui.tscn](scenes/pause_ui.tscn), [win_ui.tscn](scenes/win_ui.tscn) | HUD, control text, menus, and focus styling |
| `player_sprites/`, `enemy_sprites/`, [Tileset.png](Tileset.png) | Art referenced directly by scene resources |

Select the player or enemy instance in `main.tscn` to override exported values
in the Inspector. Edit the reusable scene or script default to change the base.

| Owner | Editable values and defaults |
| --- | --- |
| Player | `walk_speed` 400 px/s; `run_speed` 700 px/s; `jump_velocity` -900 px/s; `deceleration` 3000 px/s²; `max_health` 3; `invulnerability_duration` 1 s; `attack_damage` 1 |
| Enemy | `max_health` 2; `patrol_speed` 90 px/s; `patrol_left` -90 px; `patrol_right` +90 px; `contact_damage` 1 |
| Level enemy instance | Patrol offsets overridden to -160 / +160 px from its spawn; uniform scale 0.85 |
| Run owner (`main.tscn` root) | `fall_kill_y` 1120 px |
| Project Settings → Physics → 2D | `default_gravity` 2500 px/s² |
| Player's Camera2D in `main.tscn` | Bounds left 0, top 0, right 24768, bottom 1080 px |

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
for suite in damage_death_retry combat game_loop level_route; do
  godot --headless --path 2d-platform --fixed-fps 60 \
    --script "res://tests/$suite.gd" || exit 1
done
git diff --check
```

Then play in the editor. Check walking/running, landings and gaps, both optional
gem shelves and their return routes, every attack facing both ways, enemy
contact and defeat, spikes and falls, camera edges, and pause/resume during an
attack. Retry after death, pause, and win several times and confirm everything
resets. Navigate each menu without a mouse and test Quit. For art changes,
inspect frame alignment, both facings, attack reach, and body/contact shapes
with **Debug → Visible Collision Shapes** enabled. Use a physical gamepad when
available; injected input checks cannot establish device behavior.

## Validation status and limits

The user reported manual acceptance of Steps 1–5 on 2026-10-01. Runtime checks
and rendered frame inspection also passed. A reversible idle-sheet replacement
was checked with baseline, replacement, and restored native captures. Final
local verification on 2026-10-01 passed startup and all four gameplay suites, with native Metal/Mobile
frames inspected for the start, combat area, pause, death, and win. These checks
supplement the recorded manual acceptance; no fresh editor playthrough was
performed during final verification. No connected gamepad was detected.
Physical controller testing and the 1–2 minute human pacing target remain
unconfirmed. The user accepted the original completion plan as done; these
optional follow-ups do not block the new [demo polish plan](PLAN.md). That plan
covers a title screen, graphics, mechanics, menus, and a final boss; none of
those new steps are implemented yet.

The current level uses Godot's deprecated TileMap node; migration is outside
the demo polish plan's scope. Original-level verification and documentation are complete;
publication requires separate authorization.
Original source/license information for the existing player sheets and tileset
is unresolved; enemy
provenance is recorded in [ASSETS.md](ASSETS.md#gorgon-enemy). There is no export
or distribution setup in the current project.
