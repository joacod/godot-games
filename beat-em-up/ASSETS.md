# Art reference

The finished level uses free CraftPix character and street art, Kenney CC0
interface and impact sounds, and one CC0 music loop. Exact archives, crops,
licenses, and frame indices are in [provenance](assets/PROVENANCE.md).
[The editing guide](docs/EDITING.md) is the procedure for a further swap.

## What is in the game

| Role | Source | Local files |
| --- | --- | --- |
| Hero | [Free 3 Cyberpunk Characters](https://craftpix.net/freebies/free-3-cyberpunk-characters-pixel-art/), Biker | `assets/hero/` |
| Grunts | [Free Pixel Enemies for Seaport](https://craftpix.net/freebies/free-pixel-enemies-character-pack-for-seaport-location/), enemy 1 | `assets/enemy/` |
| Bruiser and the art-swap sample | Same cyberpunk pack, Cyborg | `assets/bruiser/` |
| Boss | [Free Factory Boss Enemies](https://craftpix.net/freebies/free-factory-boss-enemies-asset-pack-for-cyberpunk/), Toxic Enforcer | `assets/boss/` |
| Street, crate, dumpster | [Free Pixel Art Street Backgrounds](https://craftpix.net/freebies/free-pixel-art-street-2d-backgrounds/), City1 Bright | `assets/street/`, `assets/props/crate.png` |
| Food | [Free Pixel Art Icons for Mine Location](https://craftpix.net/freebies/free-pixel-art-icons-for-mine-location/), Ribs | `assets/props/food.png` |
| Hits, hurt, break, swing, menu | [Kenney](https://kenney.nl/) CC0 packs | `assets/audio/` |
| Music | [pmiller / Chiptune Battle Music](https://opengameart.org/content/chiptune-battle-music) CC0 | `assets/audio/street.ogg` |

UI text uses Godot's built-in font. Health bars and the impact spark are drawn
in code. Encounter locks and the boss SWEEP, CHARGE, and OPEN cues are drawn
in the street scene. Actor sheets are 48 × 48 except the boss, which is
96 × 96. Gameplay displays them at 2×. Source pixels are unchanged; unused
frames were omitted from the SpriteFrames resources.

## Adaptations

The packs do not include a dedicated air attack or get-up. The game uses
these mappings instead of new drawings:

- The hero's second punch sheet is trimmed to one strike. The kick sheet is
  the combo finisher and the air attack. Fall frames stop before the
  disintegrating tail, and get-up plays those frames in reverse.
- Grunt and bruiser attacks use six entries, with contact at index 4 and
  recovery at index 5. Fall uses intact frames, then reverse get-up.
- The boss punch sheet is the sweep, with contact at frame 3. Prepare is the
  stationary charge tell, Run is the moving charge, and intact Death frames
  are the defeat. Feet use offset `(-48, -96)`.

Attack and reaction frames are selected by state timers. Looping idle and
move animations are the ones that advance by FPS. Provenance lists the index
lists. Do not treat a sheet filename as the gameplay rule.

## Reviewed and not imported

These were checked and left out. A later art pass can start somewhere else.

- [Free Extra Animations for Cyberpunk Characters](https://craftpix.net/freebies/free-extra-animations-for-cyberpunk-characters/):
  walk and airborne fall poses, still no dedicated air attack or get-up.
- [Free Seaport Tileset](https://craftpix.net/freebies/free-seaport-tileset-32x32-pixel-art-for-platformer/):
  platformer tiles. The street pack already supplied the crate.
- [Free Futuristic Sounds and Music Pack](https://craftpix.net/freebies/free-futuristic-sounds-and-music-pack-for-pixel-games/):
  the signed-in download was unavailable when audio was chosen. Kenney and
  the CC0 loop were used instead.
- [Free Cartoon Smoke Effects](https://craftpix.net/freebies/free-cartoon-smoke-effects-asset-pack/)
  and [Free Pixel Art Enemy Spaceships](https://craftpix.net/freebies/free-pixel-art-enemy-spaceship-2d-sprites/):
  the smoke and explosions were the wrong scale and style for a small punch accent.

The hero's energy-weapon attack sheet, other seaport characters, other factory
bosses, and unused street foreground layers are also outside the project.

## Replacement rules

Look on CraftPix before generating replacement art. Prefer a free pack or one
already available on the user's account. Do not purchase without an explicit
yes. Import only used files and the license record. Do not copy assets from
`2d-platform` by assumption.

Keep feet at the actor root, visuals on a separate child, and a consistent
facing. Map sheets to the semantic animation names already in the frame
resources. Record dimensions, rectangles, frame rate, looping, scale, and foot
offset in provenance. Record hit windows separately from animation FPS.

Changing art must not require changing enemy decisions, encounter order, damage
rules, or menus. Different proportions can require an explicit offset,
footprint, reach, or timing change. The Cyborg grunt in
`scenes/sample/art_swap_street.tscn` is the worked example: art and foot offset
changed, grunt tuning did not.
