# Shooter — Relay Bunker

## Core loop

Enter a compact single-floor bunker, move with WASD, look with the mouse, and
fire one hitscan weapon. Read corners and enemy windups, fight a chasing guard
and a stationary sentry, collect health and one key, open the locked door, and
reach the exit. Death offers a clean retry. The maze is small enough to learn
and complete in three to four minutes.

## Renderer choice

Use native **Godot 3D on a hand-authored grid maze**, with Compatibility rendering.
`CharacterBody3D`, `Camera3D`, collision bodies, and ray queries already cover
movement and hitscan. A custom 2.5D raycaster would add projection, occlusion,
and collision maintenance without improving this slice's mechanics or reskin
boundary. Keep a flat floor, uniform wall height, no stairs or jumping, and
simple primitive enemies. Mouse pitch is clamped; player movement stays on XZ.
This decision has no unresolved blocker.

## Slice and exclusions

- One fixed maze, one hitscan blaster, two enemy types, one key, one locked door,
  two health pickups, one exit. Suggested roster: four guards and two sentries.
- WASD, mouse look, left-click fire, E interact, Escape pause/release mouse.
- Unlimited ammunition, fixed fire cooldown, crosshair, HP/key HUD, win/lose/retry.
- No ADS, reload system or minigame, weapon inventory, squad AI, vehicles,
  procedural maze, jumps, crouch, stairs, destructible walls, headshots, or multiplayer.

## Maze and combat proposal

Working theme: **Relay Bunker**. Build an 11×11 grid with 2 m cells. Symbols:
`#` wall, `.` floor, `P` player, `G` chasing guard, `S` stationary sentry,
`H` health, `K` key, `D` locked door, `E` exit. This is the initial authored layout:

```text
###########
#P..#....K#
#.#.#.###.#
#.#...#G..#
#.#####.#.#
#...G.H.#S#
###.#####.#
#H..#...G.#
#.###.###.#
#G....S.#DE
###########
```

The exit at the east edge is a recessed exit tile with an outer backing wall,
not a hole into the void. `D` is its only approach; validate graph reachability
with the door blocked and unblocked. The key must be reachable before the door,
and the exit must be unreachable until it opens. All entities occupy walkable
cells; actor radii and door clearance must fit a 2 m corridor.

Initial tuning: player 100 HP, 4 m/s; blaster 25 damage every 0.3 s, 20 m range.
Guards have 50 HP, pursue at 2 m/s, and deal 10 contact damage on a 0.8 s cooldown.
Sentries have 75 HP, stay in place, and fire a 15-damage hitscan shot after a
0.6 s visible windup, at most every 1.5 s. Both require unblocked sight within
10 m to detect; guards pursue the last seen cell briefly then idle. Sentries
cancel a shot if sight is obstructed at fire time. Death immediately disables
attacks and blocking collision. Values are proposed and need playtest tuning.

Health pickups restore 25 HP, clamp at 100, and remain when HP is full. The key
is collected once. E within 1.5 m and aimed at the door gives a locked message
without the key, or opens it permanently with the key. Door collision and
pathfinding occupancy change together after the opening completes. Walking
into the exit trigger after opening wins. Win/lose are terminal until retry;
retry restores key, door, enemies, pickups, HP, and player pose.

## Scene tree and script responsibilities

```text
Main (Node; menus/run transitions)
├── Run (Node3D; outcome)
│   ├── WorldEnvironment
│   ├── Light (DirectionalLight3D)
│   ├── Maze (Node3D; grid construction and path queries)
│   │   ├── Floor / Walls (StaticBody3D + MeshInstance3D + CollisionShape3D)
│   │   └── LockedDoor (Node3D; visual, body, interaction)
│   ├── Player (CharacterBody3D; movement)
│   │   ├── CollisionShape3D
│   │   ├── Head (Node3D; mouse yaw/pitch responsibility)
│   │   │   └── Camera3D
│   │   │       ├── ShotRay (RayCast3D)
│   │   │       └── UseRay (RayCast3D)
│   │   └── Weapon (Node; cooldown and shot resolution)
│   ├── Enemies (Node3D; CharacterBody3D scenes)
│   ├── Pickups (Node3D; Area3D scenes)
│   └── Exit (Area3D)
└── UI (CanvasLayer; HUD, pause, result)
```

Separate scripts own movement, mouse look, weapon, health, enemy state,
maze/path queries, door, pickup, run outcome, and UI. Enemy behavior is a small
IDLE/CHASE/ATTACK/DEAD enum; sentries never enter CHASE. Avoid a generic AI framework.

## External data

| Local content | Externalized fields |
| --- | --- |
| `data/maze.json` | Grid, cell size, symbol mapping, actor placements and key/door IDs |
| `data/player.tres` | HP, speed, look sensitivity, camera limits |
| `data/weapon.tres` | Damage, cooldown, range, feedback colors, optional viewmodel scene |
| `data/enemies/*.tres` | Guard/sentry kind, HP, speed, range, windup, damage, visual scene |
| `data/items/*.tres` | Key ID/name, heal amount, labels, pickup visuals |
| `data/theme.tres` | Wall/floor materials, lighting, UI labels, optional audio and prop scenes |

Reskin with materials and child visual scenes, preserving body dimensions,
ray origin, collision layers, and semantic IDs. Leave movement, hit detection,
AI transitions, grid pathing, door gating, and outcome scripts untouched.

## Godot APIs and pitfalls

Use `CharacterBody3D.move_and_slide()`, `InputEventMouseMotion`, captured mouse
mode, `Camera3D`, `RayCast3D`, `Area3D`, and primitive meshes/materials.
[RayCast3D](https://docs.godotengine.org/en/stable/classes/class_raycast3d.html)
returns the first collision: include walls and doors in shot/vision masks,
exclude the shooter body, and refresh the query when resolving a shot after
an aim change. Otherwise shots can hit through walls or use a stale direction.

Use [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html)
for the maze's XZ cells, mapping 2D cell coordinates back to 3D floor positions.
Disable diagonals to prevent corner cutting. Set region/cell size, call
`update()`, then mark solids. Reapply solids after any rebuilding update; toggle
the door cell with its collision state. Repath on target-cell changes or a
bounded cadence, not per enemy every rendered frame. Return an empty path
cleanly. On pause/result/focus loss, release mouse capture and stop damage;
recapture only after an explicit resume action, consuming that click.

## CraftPix candidates and gaps

[Free Sci-Fi Items Icons – Weapons](https://craftpix.net/freebies/free-sci-fi-items-icons-weapons/)
lists PNG/PSD/JPEG weapon images. One icon can identify the blaster in the HUD;
it does not establish a first-person viewmodel or animated enemy coverage.
[Free Pixel Prototype Character Sprites for Shooter](https://craftpix.net/freebies/free-pixel-prototype-character-sprites-for-shooter/)
was considered but does not establish the directional FPS presentation needed
here. Do not treat its side-view action list as a ready-made Wolfenstein enemy.

Use contrasting primitive guard/sentry silhouettes and built-in materials for
this slice. If later replacing them, seek front-facing or directional transparent
PNG sprites with idle, attack, hurt, and death, or local 3D packed scenes. A HUD
icon is optional and the complete game must remain runnable without any pack.

## Acceptance route — under five minutes

- [ ] Capture mouse, use WASD, turn, stop against walls, and aim/fire immediately.
- [ ] Encounter both types: guard sees/chases/attacks, sentry telegraphs/shoots, both die.
- [ ] Shoot at an enemy behind a wall/closed door; neither player nor enemy attacks cross it.
- [ ] Try locked door before key; remain blocked with visible feedback.
- [ ] Collect health when injured, collect key, open door, and reach exit in under five minutes.
- [ ] Escape releases mouse; resume does not fire from the resume click.
- [ ] In a separate short run, die and retry; key, door, pickups, HP, enemies, and pose reset.
- [ ] No clipped camera, inaccessible key, bypassed door, stuck chase route, or console error.

## Project boundary and status

Research handoff dated 2026-10-03. This document specifies future behavior;
no gameplay implementation or playable acceptance is claimed yet.
Use Godot 4.7, verified locally as 4.7.2, GDScript, and Compatibility rendering.
Each game owns its eventual `project.godot`, scenes, scripts, data, assets, and
checks. No shared launcher, autoload, source imports, symlinks, or sibling-game
resources. OpenSpec at the repository root is planning tooling only.

## Copy and reskin contract

Copy this entire game folder to a new location, including `project.godot`,
`scenes/`, `scripts/`, script `.gd.uid` files, `data/`, `assets/`, `docs/`, and
`tests/` once implemented. Omit generated `.godot/`, export builds, and local
logs. OpenSpec and all sibling folders are unnecessary to run the copy.
All runtime references must resolve within the copied project's `res://`.

Change the project display name, data values, text, and visual packed scenes.
Preserve stable content IDs, data schemas, signal contracts, collision layers,
and the documented visual attachment points. Replacing art must not change
hitboxes, interaction regions, or mechanics scripts. A new mechanic is a code
change; a new theme using existing mechanics is not.

Keep immutable content Resources separate from mutable run state. Reset runtime
state by rebuilding the run, not by mutating loaded content assets. Use focused
scripts for input, rules, content loading, actor behavior, and UI; do not create
an all-purpose controller or a reusable framework spanning these games.
Godot [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
and packed scenes provide the local data/presentation boundary.

## Asset research policy

Candidate product descriptions were checked on 2026-10-03. Archives, exact
frame layouts, account entitlements, and in-engine appearance are not verified.
Before import, record source URL, archive name, used files, frame dimensions,
animation mapping, modifications, and license evidence in `assets/PROVENANCE.md`.
Use only the files needed by this game, stored inside this game.

CraftPix's [license page](https://craftpix.net/file-licenses/) distinguishes
use in games from distribution of retrievable artwork and templates. Do not
assume a free download or account subscription grants unrestricted template
redistribution. Keep a complete placeholder presentation available; verify the
applicable terms before including art in a distributed source template.
No purchase, account access, download, or asset inclusion occurred in this handoff.

## Verification and evidence

These are future implementation commands, run from this game's folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The test runner is a planned deliverable, not an existing command target.
Test observable behavior and boundary cases, not merely node existence.
Record engine version, commands, results, and remaining gaps in
`docs/ACCEPTANCE.md`. Separately record native rendering/input and a timed human
playthrough. Capture console output through win, invalid actions or loss, and
restart; require no errors. Headless success does not prove visual clarity,
feel, physical input, or balance. Controller support is outside this slice.
Repeat launch and the completion route from a copy outside this repository,
with no sibling projects available. Keep all acceptance items unchecked until
that evidence exists.

## Implementation steps

See [the step index](STEPS.md) and [OpenSpec tasks](../../openspec/changes/add-shooter/tasks.md).
