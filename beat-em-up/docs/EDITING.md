# Play, tune, and replace art

Open `beat-em-up/project.godot` in Godot 4.7 with the Compatibility renderer.
Development checks use 4.7.2. F5 runs the title and the complete route. F6 runs
the scene currently open in the editor. The [README](../README.md) lists
controls and regression commands. [Design](DESIGN.md) records the rules these
scenes implement.

## Scene and tuning map

Paths are relative to `beat-em-up/`. Select an actor root for exported tuning.
Script constants and default arrays live in the owning script. Changing art
alone does not require changing those rules.

| File / node | Edit here |
| --- | --- |
| `main.tscn`, `scenes/ui/run.gd` | Title, Controls, Audio, pause, results, HUD, and fresh-run ownership |
| `scenes/level/street.tscn` | Scenery, player start, recovery prop, encounter nodes, and spawn markers |
| `scenes/level/street.gd` | Route and boss bounds, gate and camera ownership, and boss entry |
| `street.tscn` → `FirstFight` / `YardFight` | Arena bounds, ordered `waves`, `wave_sizes`, and delay. Wave sizes must sum to the number of scenes in `waves` |
| `scenes/player/player.tscn` / `.gd` | Hero movement, jump, combo timing, damage, reach, and the input release gate |
| `scenes/enemies/grunt.tscn`, `bruiser.tscn`, `enemy.gd` | Ordinary health, speed, tells, damage, shared decisions, and attack frames |
| `scenes/enemies/boss.tscn` / `.gd` | Boss health, sweep and charge timing, reach, speed, and defeat duration |
| `scripts/combat_actor.gd` | Shared hit eligibility, ground bounds, hurt, knockdown, get-up, health, and death |
| `scenes/props/breakable.tscn`, `breakable.gd`, `food.gd` | Prop health and drop amount; pickup recovery, reach, and depth tolerance |
| `scenes/level/presentation.gd` | Accepted-hit sparks and gameplay sound events |
| `scenes/ui/audio.gd`, `default_bus_layout.tres` | Bounded players, music and menu gain, bus defaults, routing, and the limiter |
| `scenes/player/*_frames.tres`, `scenes/enemies/*_frames.tres` | Source frame rectangles and semantic animation names |

Street depth is ground Y=242–312. Root positions, shadows, and sorting stay on
the ground. Jump raises only `Visual`. Keep encounter spawn markers inside
their arena and away from the entry point. After gameplay tuning, run the
relevant suite and replay the affected fight.

## Proven alternate-art sample

Open `scenes/sample/art_swap_street.tscn` and press F6. It inherits the mixed
fight validation scene. The left actor is still a 60 HP grunt, drawn as Cyborg.
The right grunt and the 100 HP bruiser keep their original resources. This is
an editing sample, not a new enemy type or a runtime character selector.

The override is:

- `Actors/GruntLeft/Visual/Sprite.sprite_frames`: `grunt_frames.tres` becomes
  the existing `bruiser_frames.tres`.
- That sprite's `offset`: `(-21, -48)` becomes `(-14, -48)` so Cyborg's feet
  match the root.
- The sample title identifies the swap. `Actors/GruntLeft` is editable so the
  inherited sprite override can be inspected.

No new pixels or sheets are required. Both sets use 48 × 48 source frames,
right-facing art, and 2× visual scale. Cyborg's resource provides idle 0–3 at
6 FPS, move 0–5 at 10 FPS, attack 0–5, hurt 0–1, fall 0–3, and reverse get-up
3–0. Only idle and move advance freely. The enemy script selects tell frames
0–3, contact frame 4, and recovery frame 5 from state timing. Grunt timing
stays 0.4 / 0.1 / 0.4 seconds, damage 12, and speed 85. Health, reach,
footprint, reaction timing, AI, encounters, and damage rules stay unchanged.

[Provenance](../assets/PROVENANCE.md#step-09-alternate-art-proof) identifies the
CraftPix source and license record. The art-swap suite checks this inherited
scene.

## Replace another actor's art

1. Review suitable CraftPix sheets first. Verify the source, license, and
   required motions. Import only used files and record changes in provenance.
2. Create an inherited validation scene before touching the main level. Make
   the actor instance editable and place visual overrides there. Keep its
   gameplay script and root and shadow structure.
3. Create a dedicated SpriteFrames resource when the mapping differs. Use
   AtlasTexture rectangles for each source frame. Preserve semantic names.
   Ordinary enemies need `idle`, `move`, `attack`, `hurt`, `fall`, and
   `get_up`. The hero and boss have their own mappings in their frame
   resources. Do not modify a shared resource in place unless every user of
   that resource should change.
4. Set `centered` to false. Adjust the sprite offset so the feet sit at the
   root, and keep the source art facing +X. Change the separate `Visual` scale
   only when needed. Check both facings, near and far depth overlaps, and shadows.
5. Check phase-driven frame selection. Ordinary enemies need six attack
   entries, with contact at entry 4 and recovery at entry 5. Reorder or
   duplicate source frames to match. FPS alone does not change contact timing.
   If proportions or motion need a different reach or timing, make the smallest
   explicit tuning change and record why. Do not copy another enemy's health
   or behavior along with its art.
6. Run import, startup, the art-swap suite, and the affected mechanic suites.
   Inspect idle, move, tell, contact, recovery, hurt, knockdown, get-up, and
   death. Play a fight, check pause and retry, and confirm the main-level
   actors are unchanged.

[The art reference](../ASSETS.md) records the approved adaptations for missing
air attacks and get-up frames. A new pack with different frame dimensions or
contact poses may need its own mapping and a justified tuning change. A swap
is not a filename replacement.

## Current limits

There is no checkpoint, save, or export preset. Volume choices last until quit.
The backdrop repeats and mirrors the supplied street layers. Regression tests
inject controller events; play on a physical device when you need to judge one.
Headless suites do not establish listening quality, loop-seam feel, or foot
contact during live movement. The main cast is fixed in the level scenes.
