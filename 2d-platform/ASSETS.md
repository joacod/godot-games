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
| `Attack_1.png` | 768 × 128 px | 6 | `attacking1` | 10 | No |
| `Attack_2.png` | 512 × 128 px | 4 | `attacking2` | 10 | No |
| `Attack_3.png` | 640 × 128 px | 5 | `attacking3` | 10 | No |

All frame duration multipliers are 1. Animation names are used by
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
| Player `AttackHitbox/CollisionShape2D` | Rectangle 84 × 80 px, centered in its Area2D; area y=60, x=sprite x ±94 (110 right, -78 left) |
| Enemy body and `ContactDamage/CollisionShape2D` | Rectangle 60 × 150 px, center (0, -75); enemy origin is at its feet |
| Enemy `FloorAhead` | World ray from (±(32 + patrol_speed × delta), -28) with target offset (0, 40), updated by the patrol script |
| Hazard `CollisionShape2D` | Rectangle 128 × 32 px, center (0, -16) |
| Collectible `CollisionShape2D` | Circle radius 24 px at the origin |
| Exit `CollisionShape2D` | Rectangle 80 × 128 px at the origin |

The enemy sprite is centered at (0, -128) with a 2× sprite scale. The level's
enemy instance additionally scales the entire scene to 0.85, including body,
contact area, ray, and art. Player movement collides with World; attack detection
detects Enemy. Enemy contact, hazards, pickups, and exit detect Player. Named
layers and masks are in `project.godot` and the corresponding scenes.

The player's `STRIKING_FRAMES` constant uses zero-based, inclusive indices:

| Animation | Striking frames | Damage window at 10 FPS | Whole swing |
| --- | --- | --- | --- |
| `attacking1` | 4 | 0.4–0.5 s | 0.6 s |
| `attacking2` | 2 | 0.2–0.3 s | 0.4 s |
| `attacking3` | 2–3 | 0.2–0.4 s | 0.5 s |

Windup and recovery do no damage. Each enemy can be hit once per swing; facing
stays fixed while swinging. If the new art strikes on different frames, change
`STRIKING_FRAMES` and verify animation, area placement, and damage together.
Changing FPS or frame duration changes the real-time windows in this table.
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
loops; hurt and death play once. Collision and contact shapes are 60 × 150 px,
centered 75 px above the enemy's origin at its feet. Recheck these shapes if
the art changes.

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
