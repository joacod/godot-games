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

## Step 02 movement subset

On 2026-10-02, imported `1 Biker/Biker_jump.png` from the original hero ZIP in
Downloads as `hero/jump.png`, with unchanged pixels and the same hero license
record. It is 192 × 48: four 48 × 48 frames, indexed 0–3. The player's independent
`scenes/player/movement_frames.tres` reuses the recorded idle and locomotion
sheets and adds semantic `jump`. Jump frames do not advance by FPS: the movement
script selects frame 1 while rising faster than 60 px/s, frame 2 near the apex,
and frame 3 while descending faster than 60 px/s. Frame 0 is not used in the
current jump presentation. All use the existing (14, 48) anchor and 2× scale.
This does not establish air-attack or recovery animation coverage.

The original preview is now `scenes/sample/street_sample.tscn`, unchanged from
its former `main.tscn` contents. The new movement street places two copies of
the same backdrop/road composite across a 1280-pixel test area, mirroring the
right copy horizontally to join matching edge pixels. Source pixels are unchanged;
this is a test street with repeated/mirrored scenery, not final level art.

Two additional free archives were downloaded through signed-in Chrome for review:

- `craftpix-net-796772-free-extra-animations-for-cyberpunk-characters.zip` from
  [Free Extra Animations for Cyberpunk Characters](https://craftpix.net/freebies/free-extra-animations-for-cyberpunk-characters/).
- `craftpix-net-412866-free-factory-boss-enemies-asset-pack-for-cyberpunk.zip` from
  [Free Factory Boss Enemies Asset Pack for Cyberpunk](https://craftpix.net/freebies/free-factory-boss-enemies-asset-pack-for-cyberpunk/).

These remain in Downloads; no files from either archive were imported into this
project. They establish only the asset-review observations in the asset brief.
No purchase or new license grant is asserted by this review.

## Step 03 combat subset

On 2026-10-02, copied unchanged PNGs from the already-acquired original archives:
`1 Biker/Biker_hurt.png` → `hero/hurt.png` (96 × 48),
`1 Biker/Biker_death.png` → `hero/fall.png` (288 × 48),
seaport `1/Hurt.png` → `enemy/hurt.png` (96 × 48), and
`1/Death.png` → `enemy/fall.png` (288 × 48).
The source extraction in `/private/tmp/beat-assets` matches the original used
hero/enemy sheets byte-for-byte. Existing hero/enemy license records apply;
no new download, purchase, or license assertion was made.

Combat uses separate frame resources, preserving all original sample mappings.
Each source frame remains 48 × 48 with the existing feet offsets and 2× scale.
The hero's second punch uses indices 5, 6, 7, 5, removing the first punch.
Finisher uses kick indices 0–5; air attack uses 2, 3, 4, 5.
Hero fall uses 0, 1, 2 (before the fragmented tail); get-up reverses 2, 1, 0.
Dummy fall uses 2, 3, 4 (omitting initial muzzle flashes and final tail);
get-up reverses 4, 3, 2. Hurt uses indices 0, 1 for both.
These are selected frames, not edited source pixels. Actual contact windows and
phase-driven frame selection are in the
[Step 03 record](../docs/steps/03-combat.md#combat-tuning-and-animation-mapping).

## Step 04 ordinary enemies

On 2026-10-02 imported unchanged PNGs from the already-acquired hero pack's
`3 Cyborg/` directory in `/private/tmp/beat-assets/hero`: `Cyborg_idle.png`,
`Cyborg_run.png`, `Cyborg_attack1.png`, `Cyborg_hurt.png`, `Cyborg_death.png` →
`bruiser/idle.png`, `move.png`, `attack.png`, `hurt.png`, `fall.png` respectively.
The existing [hero license record](licenses/hero.txt) applies. No new download,
purchase, image editing, or license assertion. All frames are 48 × 48, displayed
at 2× with sprite offset (-14, -48). Idle/move loop at 6/10 FPS; attack/hurt/fall
and reverse get-up are driven by state timing. All idle/run/punch/hurt source
frames are mapped; fall uses 0–3, get-up 3–0. The 6-frame punch contacts at index 4.

Grunt resources reuse the existing seaport files, including the full walk sheet
at 10 FPS; feet offset (-21, -48) and 2× scale are unchanged. Their fall/get-up
mapping remains 2,3,4 / 4,3,2. Attack contact is index 4, recovery index 5 for both
types. Source pixels are unchanged; phase timing is independent of sheet FPS.
