# Asset provenance

## Shipped assets

All room, prop and item visuals are project-authored `Polygon2D` packed scenes
under `scenes/visuals/`: background, oil, press, clerk, noticeboard, gate and pass.
They contain no downloaded artwork. Fonts use Godot's built-in default.
Hotspot geometry lives separately in `data/room.json`; replacing a visual does
not change its interaction shape. The pass visual is validated item content; inventory uses text buttons.
It is not a sixth room hotspot.

## CraftPix candidate

Selected candidate: the **Castle Interior** scene from
[Free Castle Interior Pixel Game Backgrounds](https://craftpix.net/freebies/free-castle-interior-pixel-game-backgrounds/).
The listing was checked on 2026-10-03 and describes four backgrounds at 576×324,
in PNG/PSD format. The interior with stone walls and fountain is the proposed
fixed backdrop. Its exact archive filename, individual file names, layer layout,
cropping and in-engine appearance are unverified.

No archive was downloaded or imported; used files, modifications and animation
mapping are therefore not applicable. No account access or purchase occurred.
The listing links to [CraftPix license terms](https://craftpix.net/file-licenses/),
but redistribution suitability for a source template has not been verified.
Record archive/file names, dimensions, modifications and applicable license
evidence before any later import. The complete placeholder room remains usable.

The listing does not establish independent oil, stamp press, pass, clerk or gate
art. Any later companion assets should be transparent pixel PNGs with readable
silhouettes; a clerk portrait or silhouette is sufficient for this static stage.


## Coverage and verified reskin — 2026-10-04

The shipped game retains its original project-authored placeholders. The
standalone temporary Harbor Gate copy changes only backdrop polygon colors;
prop scenes, geometry and visual state attachment nodes are unchanged.
`tests/create_reskin_copy.py` records the exact edits, and
[the retained audit](../docs/evidence/step06-reskin-audit.json) records hashes.
No external art, generated raster media, account access or downloads were used.

| Coverage | Used source | Status |
| --- | --- | --- |
| Fixed background | `scenes/visuals/background.tscn` | Project-authored polygons; copy recolors four palette roles |
| Oil, press, clerk, noticeboard, gate | Corresponding `scenes/visuals/*.tscn` | Project-authored placeholder silhouettes; native interaction verified |
| Pass and oil item visuals | `pass.tscn`, `oil.tscn` | Validated packed scenes; inventory renders names/tooltips rather than icons |
| Text/UI | `data/theme.tres`, Godot default font | Native readability checks; no downloaded font |

The [CraftPix candidate listing](https://craftpix.net/freebies/free-castle-interior-pixel-game-backgrounds/)
was rechecked on 2026-10-04: four 576×324 PNG/PSD backgrounds remain listed.
Archive files, prop coverage and in-engine fit remain unverified.
The [license page checked on 2026-10-04](https://craftpix.net/file-licenses/) permits game use
and modification of freebies, while restricting retrievable art redistribution
and providing separate template/enterprise terms. No source-template
redistribution approval or account entitlement is claimed. These are candidate
and license observations, separate from gameplay acceptance; final CraftPix art
is not part of the verified placeholder reskin.
