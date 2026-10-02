# Sample asset provenance

Acquired 2026-10-02 through the user's signed-in Chrome session on CraftPix.
All three packs are free; no purchase was made. Publisher/credited source:
CraftPix.net. No individual artist is identified in the supplied license files.

## Downloads and imported subset

| Pack | Download archive | Imported subset |
| --- | --- | --- |
| [Free 3 Cyberpunk Characters Pixel Art](https://craftpix.net/freebies/free-3-cyberpunk-characters-pixel-art/) | `craftpix-net-856554-free-3-cyberpunk-characters-pixel-art.zip` | `1 Biker/Biker_idle.png`, `Biker_run.png`, `Biker_attack1.png`, `Biker_attack2.png`, `Biker_punch.png` → `hero/`, with `Biker_` removed |
| [Free Pixel Enemies Character Pack for Seaport Location](https://craftpix.net/freebies/free-pixel-enemies-character-pack-for-seaport-location/) | `craftpix-net-545114-free-pixel-enemies-character-pack-for-seaport-location.zip` | `1/Idle.png`, `1/Walk.png`, `1/Attack.png` → `enemy/`, lowercase filenames |
| [Free Pixel Art Street 2D Backgrounds](https://craftpix.net/freebies/free-pixel-art-street-2d-backgrounds/) | `craftpix-891123-free-pixel-art-street-2d-backgrounds.zip` | `PNG/City1/Bright/Sky.png`, `buildings.png`, `wall1.png`, `road&border.png` composited into `street/city.png` |

Paths in the destination column are relative to this folder. Source PNG actor
pixels are unchanged. Only files used by the sample are imported; PSDs, coupons,
fonts, alternate characters, and unused animations remain outside the project.
The original ZIPs are in the user's Downloads folder.

The street image is a transparent 1920 × 1080 RGBA canvas with the four named
layers alpha-composited in the listed order at (0, 0), without resizing or color
changes. This omits the front wall and oversized prop layers. The scene displays
it at one-third scale, at (0, -60). A second sprite uses the rectangle
(0, 900, 1920, 180), vertically mirrored at one-third scale at (0, 300), extending
the road to the viewport edge with matching boundary pixels. No replacement art
was generated. Horizontal level tiling remains unverified.

## License records

The archive-supplied license files are preserved as
[hero.txt](licenses/hero.txt), [enemy.txt](licenses/enemy.txt), and
[street.txt](licenses/street.txt). Each contains only the official
[CraftPix license URL](https://craftpix.net/file-licenses/), not a standalone grant.
That page was reviewed on acquisition: its freebie terms permit personal and
commercial game use and modification, with restrictions on resale and
redistribution of the artwork itself. This records the source terms, not a
separate license for the repository. No publication is part of Step 01.

## Sprite mapping

All frames are 48 × 48, in one horizontal row; zero-based frame `i` uses
`Rect2(i * 48, 0, 48, 48)`. Frame durations are equal. These are preview rates,
not approved combat timings. No active hit windows or damage exist yet.

| Actor / semantic name | Local sheet | Sheet size | Frames | FPS | Loop |
| --- | --- | --- | --- | --- | --- |
| Hero / `idle` | `hero/idle.png` | 192 × 48 | 0–3 | 6 | Yes |
| Hero / `move` | `hero/run.png` | 288 × 48 | 0–5 | 10 | Yes |
| Hero / `attack_1` | `hero/attack1.png` | 288 × 48 | 0–5 | 10 | No |
| Hero / `attack_2` | `hero/attack2.png` | 384 × 48 | 0–7 | 10 | No |
| Hero / `attack_3` | `hero/punch.png` | 288 × 48 | 0–5 | 10 | No |
| Enemy / `idle` | `enemy/idle.png` | 192 × 48 | 0–3 | 6 | Yes |
| Enemy / `move` | `enemy/walk.png` | 288 × 48 | 0–5 | 10 | Yes |
| Enemy / `attack` | `enemy/attack.png` | 288 × 48 | 0–5 | 10 | No |

The hero ground anchor corresponds to source (14, 48), the enemy to (21, 48).
Sprites are uncentered, with offsets (-14, -48) and (-21, -48). The separate
`Visual` child scales 2×; source art faces right (+X). The enemy's `Visual`
uses X=-2 to mirror around the feet, rather than around the sheet center.
Standing silhouettes are about 68–72 logical pixels high.

Both roots stay fixed, at (240, 258) and (398, 310). Their shadows and cyan
anchor marks stay at ground level. The parent sorts by root Y. Sorting under
movement/jump is not tested because those mechanics are intentionally absent.

Preview phases last 2.4 seconds: idle → move → first attack → second attack →
third attack → repeat. Enemy attack restarts in each attack phase. Non-looping
animations hold their final frame until the next phase. Movement is an in-place
animation preview, not foot-sliding acceptance for locomotion.

For unresolved coverage and proposed adaptations, see
[the asset brief](../ASSETS.md#step-01-decisions-and-gaps).
