# Asset sources

## Gorgon enemy

The enemy uses CraftPix's
[Free Gorgon Pixel Art Character Sprite Sheets](https://craftpix.net/freebies/free-gorgon-pixel-art-character-sprite-sheets/),
downloaded through the signed-in browser on 2026-10-01.

Only these unmodified `Gorgon_1` PNGs from the archive are included:

| Project file | Sprite sheet | Frames |
| --- | --- | --- |
| `enemy_sprites/Walk.png` | 1664 × 128 px | 13 |
| `enemy_sprites/Hurt.png` | 384 × 128 px | 3 |
| `enemy_sprites/Dead.png` | 384 × 128 px | 3 |

Each frame is 128 × 128 px. `scenes/enemy.tscn` references these sheets and
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

## Existing art

The existing `player_sprites/` and `Tileset.png` files are unchanged. Their
original source and license have not been established in this step.
