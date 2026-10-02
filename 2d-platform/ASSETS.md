# Art reference and sources

Texture references live directly in [scenes/main_character.tscn](scenes/main_character.tscn),
[scenes/enemy.tscn](scenes/enemy.tscn), and [main.tscn](main.tscn).
The following dimensions come from the PNGs and current scene resources.
Step 2 adds the fortress assets and native drawing described below.

## Player sprite sheets

Each PNG is one horizontal row of transparent 128 × 128 px frames with no
padding or spacing. Atlas frame `i` is `Rect2(i * 128, 0, 128, 128)`.
`AnimatedSprite2D` in `scenes/main_character.tscn` displays frames at 2× scale,
with local position (16, 17). Keep artwork aligned to the same origin in every
frame and facing right; the script flips it for left-facing movement/attacks.

| File in `player_sprites/` | Sheet dimensions | Frames | Animation name | FPS | Loop |
| --- | --- | --- | --- | --- | --- |
| `Idle.png` | 1024 × 128 px | 8 | `default` | 14 | Yes |
| `walk.png` | 1408 × 128 px | 11 | `walking` | 12 | Yes |
| `Run.png` | 1152 × 128 px | 9 | `running` | 24 | Yes |
| `Jump.png` | 1408 × 128 px | 11 | `jumping` | 16 | Yes |
| `Attack_1.png` | 768 × 128 px | 6 | `attacking1` (thrust) | 14 | No |
| `Attack_2.png` | 512 × 128 px | 4 | `attacking2` (quick) | 16 | No |
| `Attack_3.png` | 640 × 128 px | 5 | `attacking3` (heavy) | 8 | No |

Attack 1 and 3 hold their final recovery frame for duration multiplier 2;
all other multipliers are 1. Sheet pixels, frame order, and origins are unchanged.
Animation names are used by
`scenes/main_character.gd`; keep them when replacing art. Attacks must finish
once because `animation_finished` ends the swing. The sprite autoplays `default`.

## Tileset

`Tileset.png` is 496 × 304 px: 31 columns × 19 rows of 16 × 16 px cells with
zero margins and separation. `main.tscn` embeds a TileSet with a 16 × 16 px
tile size and a TileSetAtlasSource at source ID 0. The visual-identity pass
now references `fortress_art/masonry.svg` instead of this PNG; the original
PNG stays untouched. The SVG preserves the 496 × 304 px atlas extent and
paints the four used cells with alternating stone, moss caps, and cracks.
The current TileMap uses atlas coordinates (7, 10), (8, 10), (7, 11), and
(8, 11), counted from the top-left at (0, 0). These cells have full-cell
collision polygons with corners (-8, -8), (8, -8), (8, 8), and (-8, 8).
World collision uses physics layer 1. Preserve the tile positions and
collision data for a compatible visual replacement.

## Collision and attack data

Sizes and positions below are local scene pixels, independent of texture
transparency. Visible artwork does not automatically change collision.

| Scene / node | Shape and local placement |
| --- | --- |
| Player `CollisionShape2D` | Capsule radius 62 px, height 138 px, center (44, 77) |
| Player thrust hitbox | Rectangle 72 × 80 px; area y=40, x=sprite x ±86 (102 right, -70 left) |
| Player quick hitbox | Rectangle 64 × 80 px; area y=60, x=sprite x ±64 (80 right, -48 left) |
| Player heavy hitbox | Rectangle 76 × 112 px; area y=24, x=sprite x ±66 (82 right, -50 left) |
| Enemy body | Rectangle 60 × 150 px, center (0, -75); origin at its feet |
| Enemy `ContactDamage` (awareness only) | Rectangle 340 × 150 px, center (0, -75); never deals contact damage |
| Enemy `AttackHitbox` | Rectangle 110 × 110 px; center (±78, -75), facing committed during windup |
| Enemy `FloorAhead` | World ray from (±(32 + patrol_speed × delta), -28) with target offset (0, 40), updated by the patrol script |
| Hazard `CollisionShape2D` | Rectangle 128 × 32 px, center (0, -16) |
| Collectible `CollisionShape2D` | Circle radius 24 px at the origin |
| Exit `CollisionShape2D` | Rectangle 80 × 128 px at the origin |

The enemy sprite is centered at (0, -128) with a 2× sprite scale. The level's
enemy instance additionally scales the entire scene to 0.85, including body,
awareness/strike areas, ray, and art. Player movement collides with World;
attack detection detects Enemy. Enemy awareness/strike areas, hazards, pickups,
and exit detect Player. Named
layers and masks are in `project.godot` and the corresponding scenes.

The player's `STRIKING_FRAMES` constant uses zero-based, inclusive indices:

| Input / role | Striking frames | Windup | Active window | Recovery | Whole swing | Damage | Forward edge from sprite origin | Knockback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Z / thrust (`attacking1`) | 4 | 0.286 s | 0.286–0.357 s | 0.143 s | 0.500 s | 1 | 122 px | 140 px/s |
| X / quick (`attacking2`) | 2 | 0.125 s | 0.125–0.188 s | 0.063 s | 0.250 s | 1 | 96 px | 100 px/s |
| C / heavy (`attacking3`) | 3 | 0.375 s | 0.375–0.500 s | 0.250 s | 0.750 s | 2 | 104 px | 200 px/s |

The heavy uppercut uses the raised arc on frame 3; frame 2 is now harmless
windup. Windup and recovery do no damage. Each target can be hit once per
swing; facing stays fixed while swinging. Hitboxes are mirrored around sprite
x=16, not the asymmetrically placed body capsule. Each player duplicates its
attack shape before changing it. If art changes, verify visible poses, shapes,
`STRIKING_FRAMES`, FPS, and duration multipliers together.

A confirmed hit flashes the enemy and draws a small gold impact burst on the
incoming side. Surviving enemies enter harmless recovery and receive up to
0.16 s of horizontal knockback, bounded by patrol endpoints and the ledge ray.
Maximum unblocked displacement is 16 / 22.4 / 32 px for quick / thrust / heavy.
The player is not knocked toward hazards.

Recheck jump distances and optional routes after changing movement, gravity,
or body dimensions; a new silhouette can also make existing gaps harder to read.

## Replace art

### Matching files and layout

1. Back up the PNGs you will change, or use a disposable copy of the project.
   Keep the corresponding scene resources and `.import` files.
2. Replace a PNG at its existing path with a transparent sheet matching its
   dimensions, frame count, order, and alignment above. Preserve filename case,
   including lowercase `walk.png`. For tiles, keep occupied atlas cells in place.
3. Open the project in Godot and wait for reimport, or select the changed PNG
   and click Reimport in the Import dock. Keep the current import settings;
   `.godot/imported/` is generated cache, not the source art to edit.
4. Run the level. Inspect animation alignment, facing, feet/body placement, and
   attacks with Debug → Visible Collision Shapes. Follow the
   [playtest checks](README.md#validate-a-change), then restore the backup and
   reimport to undo a trial. Verify that the original visuals return.

### Different dimensions, paths, or frame layouts

For player or enemy art, open the corresponding `.tscn`, select
`AnimatedSprite2D`, and edit its SpriteFrames resource in the bottom panel.
Rebuild each animation's atlas frames from the replacement sheet using the new
grid or explicit regions, keep the script's animation names, and set frame
order, FPS, durations, and looping deliberately. Adjust sprite position/scale
for alignment, then inspect collision/contact shapes separately. Renamed files
need new resource references through the editor; preserve existing paths when
possible. Check both facings and update striking frames when their meaning changes.

For tiles, select `TileMap` in `main.tscn` and edit its TileSet resource and
atlas source. Change texture, texture region size, margins, separation, and
tile size as needed. Recreate/remap occupied atlas coordinates and collision
polygons rather than assuming a new sheet is compatible. Changing tile size
also changes world geometry: recheck the route, instance positions, camera
bounds, and fall threshold. A layout change requires gameplay validation.

Spikes, gems, and the exit use `Polygon2D` visuals in their reusable scenes;
they have no sprite sheets. Replace or edit those visual children while
preserving the Area2D scripts, signals, and collision shapes, then check that
their visible extent still communicates the detection area. UI and route
signs use Godot Controls/Labels, not texture atlases.

## Gorgon enemy

The enemy uses CraftPix's
[Free Gorgon Pixel Art Character Sprite Sheets](https://craftpix.net/freebies/free-gorgon-pixel-art-character-sprite-sheets/),
downloaded through the signed-in browser on 2026-10-01.

Only these unmodified `Gorgon_1` PNGs from the archive are included:

| Project file | Sprite sheet | Frames | Animation name |
| --- | --- | --- | --- |
| `enemy_sprites/Walk.png` | 1664 × 128 px | 13 | `walk` |
| `enemy_sprites/Hurt.png` | 384 × 128 px | 3 | `hurt` |
| `enemy_sprites/Dead.png` | 384 × 128 px | 3 | `dead` |

Each sheet is one row of 128 × 128 px frames, with no padding or spacing and
duration multipliers of 1. `scenes/enemy.tscn` references these sheets and
plays them at 10 fps with a 2× scale and nearest-neighbor filtering. Walk
loops; hurt and death play once. The body remains 60 × 150 px, centered 75 px above the feet. The former
contact area now only senses nearby players. No enemy sheet or SpriteFrames
changed in Step 4: the walk pose freezes during a 0.55 s gold windup cue,
followed by a 0.15 s native-drawn forward swipe and 0.75 s harmless recovery
marked by a teal dot. Swipe strokes span x=23–133 in the committed facing and
y=-115 to -40, inside the damage rectangle x=23–133, y=-130 to -20. Each strike
deals one damage at most once per player, respecting player invulnerability.
All timers, animation, and knockback freeze on pause. A hit interrupts the
attack; defeat clears damage and removes the enemy after its death animation.
No additional assets were downloaded; cues, swipe, and impact are Godot drawing.

The archive's `Licens.txt` points to the
[CraftPix file license](https://craftpix.net/file-licenses/). The Freebie
Products section permits use and modification in personal and commercial
projects and distribution of games using the assets. Attribution is optional;
this document records the source. The assets are third-party artwork under
that license, not original repository artwork. Keep their use within the game;
do not resell or provide them as a standalone asset pack. Other characters,
unused animations, PSD source files, and promotional files are not included.

## Fortress visual identity

Step 2 uses a night palette: blue charcoal backgrounds, moss-capped gray stone,
parchment text, gold focus and gems, warm spike tips, and a teal exit arrow.
The shared `scenes/menu_theme.tres` retains Godot's bundled default font across
menus, HUD, prompts, and exit labels; no external font or font dependency is added.
Button states share their content margins so focus and hover do not shift layout.

`scenes/fortress_background.tscn` / `fortress_background.gd` draw the sky, stepped
moon, clouds, masonry seams, windows, and two fortress silhouettes using native
Godot primitives. Gameplay uses a screen-filling CanvasLayer at layer -10;
only horizontal camera motion drives cloud/fortress offsets (0.025, 0.06, 0.14).
The title reuses the scene with camera following disabled. Background colors
stay dimmer than playable surfaces. Decoration has no collision or gameplay
state; pause freezes camera-driven updates. No animation timing was added.

`fortress_art/masonry.svg` is new geometric artwork written for this project.
It retains the original 16 px atlas grid and used coordinates (7, 10), (8, 10),
(7, 11), (8, 11). Tile positions and full-cell collision polygons are unchanged.
The cap is at the tile's actual top edge; transparent unused cells add no art
in gaps. `Tileset.png` remains available as the original visual reference.
No player/enemy SpriteFrames, attack frames, or detection shapes changed.

The four unmodified props in `fortress_art/` come from CraftPix's
[Free Medieval Tileset Pixel Art Pack](https://craftpix.net/freebies/free-medieval-tileset-pixel-art-pack/),
downloaded through the browser on 2026-10-01:

| Included file | Archive path | PNG size | Use |
| --- | --- | --- | --- |
| `torch.png` | `PNG/Objects/torch.png` | 32 × 32 px | 3× torches on visible decorative mounts |
| `barrel.png` | `PNG/Objects/barrel.png` | 32 × 32 px | 3× barrels at the start and exit approach |
| `shield.png` | `PNG/Objects/shield.png` | 64 × 64 px | 2× shield on a post near the first optional gem |
| `window.png` | `PNG/Objects/window.png` | 64 × 64 px | 2× window on the exit's ruined pier |

`main.tscn` places these behind the player, enemy, and TileMap with nearest
filtering. They are scenery, not interactive items or landing surfaces.
Only these used PNGs and the archive's `License.txt` were included. The archive,
Unity package, unused props/tiles, and promotional artwork are not included.
The archive license points to the [CraftPix file license](https://craftpix.net/file-licenses/),
whose Freebie Products section permits use and modification in game projects
and distribution of games using the assets. Credit is optional; this record
preserves provenance. These props remain third-party artwork under that license.

The spike faces/base, faceted gold gem, and framed teal exit are native scene
polygons. Their outer extents match the existing 128 × 32 px hazard rectangle,
24 px pickup radius, and 80 × 128 px exit rectangle. Inner decoration adds no
collision; the lethal spike area still covers the whole spike strip.

## Existing art

The existing `player_sprites/` and `Tileset.png` files are unchanged. Their
original source and license have not been established in this step.

## Refreshed route and courtyard

Step 5 reuses all existing textures and SpriteFrames; no assets were downloaded.
The masonry atlas and its full-cell collisions are unchanged, while occupied
cells now form a 11,280 px-wide route with nine main floor stretches, two
optional shelves at y=608, and a continuous final approach/courtyard floor at
y=864. The useful opening platforms remain. Main gaps are 96–160 px wide;
upward steps are at most 128 px. Repositioned patrol, spikes, gems, prompts,
and props follow the shorter route. Reusable detection shapes are unchanged.

The final courtyard spans x=9152–11264, with native Polygon2D stone piers,
dark arched recesses, masonry courses, and a teal banner using the existing
shield texture. These decorations have no collision. A visible 32 px-wide
entry boundary at x=9152 closes only after the player's capsule has cleared
it; the right edge uses the level's existing full-height wall treatment.
The entry Area2D detects only Player across the level height, so jumping
through entry cannot skip the retry point. The safe retry origin is (9360, 718).
The exit sits at (10992, 800); Step 6 seals it until guardian defeat.

## Courtyard guardian and boss gates

Step 6 adds no downloaded artwork. `scenes/boss.tscn` reuses the existing
128 × 128 Gorgon Walk/Hurt/Dead atlas frames and their existing frame order;
the player and ordinary enemy SpriteFrames remain unchanged. The guardian
uses the standing Walk frame at 2.5× scale, teal tint, a native gold crown,
hit flash/impact rays, and the three-frame Dead animation at 10 FPS. This
retains the existing creature silhouette; the crown and size distinguish it.
The original Gorgon source/license remains as documented above.

The guardian stands at (10112, 864). Its enemy-layer damage receiver is a
100 × 210 px rectangle centred 105 px above the floor. Player collision masks
allow walking through it; body contact deals no damage. A 220 × 120 px sweep
is centred 155 px towards the committed facing, 90 px above the floor. Its
gold tell rectangle matches that area; teal swipe lines cover its reach.
Two 64 × 40 px ground-wave areas, centred 20 px above the floor, use matching
native jagged stone polygons. They start 70 px either side of the boss, travel
at 650 px/s, and disappear at the courtyard boundaries or end of attack.
Each attack damages a player at most once. The waves share one hit registry,
so crossing both cannot cause a second hit in the same attack.

| Guardian value | Default |
| --- | --- |
| Health / damage per attack | 12 / 1 |
| Idle between tells | 0.7 s |
| Sweep tell / strike | 0.7 / 0.22 s |
| Ground-wave tell / attack lifetime | 1.0 / 2.2 s |
| Recovery above / at or below half health | 1.2 / 0.85 s |
| Vulnerability | All states after entry; hits do not interrupt the committed attack |

Native effects use fortress gold for tells and pale teal for attacks/recovery.
A compact bottom-centred health bar uses the shared menu theme and announces
phase two. Gates use the existing 32 px stone boundary shape. The entry gate
closes safely after entry as before; a second gate at x=10848 blocks the exit
and opens on defeat. The locked exit hides its arrow, darkens its opening,
and reads SEALED; defeat restores the teal arrow and EXIT label. Existing
terrain, hazard/pickup shapes, player/enemy sheets, and camera bounds are
unchanged. No new third-party assets or license claims are introduced.
