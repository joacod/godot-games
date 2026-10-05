# Survivors asset provenance

## Included presentation

All included visuals are original geometric placeholders created for Step 01
on 2026-10-05. No external art, texture, font, audio, archive, or account download
is included. UI uses Godot's built-in font.

| Local file | Presentation | Mapping and modifications |
| --- | --- | --- |
| `scenes/visuals/keeper.tscn` | Polygon keeper with facing cue | Static Node2D; no sheet or animation; tinted by theme |
| `scenes/visuals/crawler.tscn` | Polygon crawler silhouette | Static Node2D; no sheet or animation; tinted by theme |
| `scenes/visuals/floor.tscn` | 960×640 floor and clearing polygon | Static Node2D; tinted by theme |
| `scenes/visuals/attack.tscn` | Diamond icon/effect placeholder | Static Node2D; definition only, no attack behavior |
| `scenes/arena.tscn` | Four visible arena edges | Geometry outside replaceable art; colored by theme |
| `data/ui_theme.tres` | Button styling and palette | Local Godot Theme/StyleBox resources |

There are no sprite frame dimensions or animation mappings to verify for this
placeholder baseline. Actor collisions remain outside presentation scenes.

## Researched CraftPix candidates

The [design](../docs/DESIGN.md) records listing research from 2026-10-03:

- [Free Island Adventure Pixel Top-Down Minigame Kit](https://craftpix.net/freebies/free-island-adventure-pixel-top-down-minigame-kit/)
  is the primary candidate for floor, one hero, one creature, and UI.
- [Free Slime Mobs Pixel Art Top-Down Sprite Pack](https://craftpix.net/freebies/free-slime-mobs-pixel-art-top-down-sprite-pack/)
  is an alternative enemy candidate, subject to scale and palette fit.

These remain candidates. Step 01 did not refresh listings, access an account,
inspect or download archives, verify entitlements, or import files. Exact frame
layouts, fit, animation mapping, and source-template redistribution rights remain
unverified. Weapon effects and XP gems have no verified candidate coverage.

Before any later import, inspect the actual archive and record source URL,
archive name, included files, dimensions, animation mapping, modifications, and
applicable [license evidence](https://craftpix.net/file-licenses/). Keep the
complete placeholder baseline runnable. Listing descriptions alone do not prove
asset fit or permission to distribute retrievable art in a source template.

## Step 03 effects — 2026-10-05

CraftPix listing research found the
[Free Water and Fire Magic Sprite Vector Pack](https://craftpix.net/freebies/free-water-and-fire-magic-sprite-vector-pack/)
and [Top-Down Wind and Lightning Magic Effects Pack](https://craftpix.net/product/top-down-wind-and-lightning-magic-effects-pack/).
These are candidate projectile/effect collections; actual archive fit, frame
mapping, entitlements, and redistribution rights were not verified. No download,
purchase, account access, or external asset inclusion occurred.

The planned geometric baseline remains: `scenes/visuals/spark.tscn` is a yellow
diamond, `halo.tscn` a violet square, `pulse.tscn` a thin green ring, and
`shard.tscn` a cyan directional dart. These are original local shapes, created
for Step 03, with no external licensing requirement. The weapon Resources
reference them as replaceable art; physics stays in `scenes/attacks/`.

## Step 04 gems and menus — 2026-10-05

CraftPix listing research found
[Free Mining Pixel 32×32 Icons](https://craftpix.net/freebies/free-mining-pixel-32x32-icons/)
and [Gems Games – Free GUI](https://craftpix.net/freebies/gems-games-gui/).
These are possible pickup/icon or menu sources, pending archive inspection,
scale/palette fit and source redistribution review. No archive, entitlement,
frame mapping or license applicability was verified; no files were downloaded.

`scenes/visuals/xp_gem.tscn` uses an original cyan diamond with a dark border,
created for Step 04. Gem collision lives in `scenes/xp_gem.tscn`, outside the
replaceable visual child. `scenes/ui/upgrade_menu.tscn` uses existing Theme
styles, Godot Controls and the built-in font. Arc Spark reuses Spark art with
runtime tint after a chain hit. No external media or new dependencies were added.

## Step 05 HUD and elite — 2026-10-05

The earlier CraftPix UI and enemy candidates remain unimported. Step 05 reuses
`scenes/visuals/crawler.tscn` at 1.7× visual scale for the labeled elite, with
its collision shape defined separately by run mechanics. `scripts/hud.gd`
draws original geometric weapon symbols; `scripts/spawn_director.gd` draws
edge warning crosses/rings. Pause and result panels reuse the existing local
Theme and built-in font. No external asset, archive or account access was used.

## Step 06 isolated reskin — 2026-10-05

The proof copy uses the existing original `scenes/visuals/crawler.tscn` as the
Lantern character visual, tinted cyan through theme data. Copper Marsh changes
the menu title, background/floor/boundary/actor palette and Spark lifetime in
three copied Resources. All visual and physics scene files remain byte-identical
to the source. No new artwork, external media, CraftPix archive, download,
account access or license claim is introduced.

The native PNG/MP4 captures are local evidence of the running placeholder game,
not imported runtime assets. See [acceptance evidence](../docs/ACCEPTANCE.md) for
copy/hash locations, rendering checks and the remaining human acceptance gate.
