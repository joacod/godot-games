# Play, tune and replace art

Open `beat-em-up/project.godot` in Godot 4.7.2 with the Compatibility renderer.
F5 runs the title and complete route. F6 runs the scene currently open in the
editor. The [README](../README.md) lists controls and regression commands;
[final acceptance](steps/09-acceptance.md#completion-record) separates automated
results from the remaining hands-on checks.

## Scene and tuning map

Paths below are relative to `beat-em-up/`. Select an actor root in the editor
for exported tuning fields. Script constants and default arrays live in their
owning script; changing the art alone does not require changing those rules.

| File / node | Edit here |
| --- | --- |
| `main.tscn`, `scenes/ui/run.gd` | Title, Controls, Audio, pause, results, HUD and fresh-run ownership |
| `scenes/level/street.tscn` | Scenery, player start, recovery prop, encounter nodes and spawn markers |
| `scenes/level/street.gd` | Route/boss bounds, gate/camera ownership and boss entry |
| `street.tscn` → `FirstFight` / `YardFight` | Arena bounds, ordered `waves`, `wave_sizes`, delay; wave sizes must sum to the number of scenes in `waves` |
| `scenes/player/player.tscn` / `.gd` | Hero movement, jump, combo timing/damage/reach and input release gate |
| `scenes/enemies/grunt.tscn`, `bruiser.tscn`, `enemy.gd` | Ordinary actor health/speed/tells/damage; shared decisions and attack frames |
| `scenes/enemies/boss.tscn` / `.gd` | Boss health, sweep/charge timing, reach, speed and defeat duration |
| `scripts/combat_actor.gd` | Shared hit eligibility, ground bounds, hurt/down/get-up and health/death rules |
| `scenes/props/breakable.tscn`, `breakable.gd`, `food.gd` | Prop health/drop amount; pickup recovery, reach and depth tolerance |
| `scenes/level/presentation.gd` | Accepted-hit sparks and gameplay sound events |
| `scenes/ui/audio.gd`, `default_bus_layout.tres` | Bounded players, music/menu gain, bus defaults, routing and limiter |
| `scenes/player/*_frames.tres`, `scenes/enemies/*_frames.tres` | Source frame rectangles and semantic animation names |

Street depth is ground Y=242–312. Root positions, shadows and sorting remain on
the ground; jump raises only `Visual`. Keep encounter spawn markers inside their
arena, away from the entry point. After gameplay tuning, run the relevant suite
and replay the affected fight; headless passing checks do not prove balance.

## Proven alternate-art sample

Open `scenes/sample/art_swap_street.tscn` and press F6. It inherits the mixed-fight
validation scene. The left actor is still a **60-HP grunt**, now drawn as Cyborg;
the right grunt and the 100-HP bruiser keep their original resources. This is
an editing sample, not a new enemy type or a runtime character selector.

The complete override is:

- `Actors/GruntLeft/Visual/Sprite.sprite_frames`:
  `grunt_frames.tres` → existing `bruiser_frames.tres`.
- That sprite's `offset`: `(-21, -48)` → `(-14, -48)` to match Cyborg's feet.
- The sample title identifies the swap; `Actors/GruntLeft` is editable so the
  inherited sprite override can be inspected.

No new pixels or sheets are required. Both sets use 48 × 48 source frames,
right-facing art and 2× visual scale. Cyborg's existing resource provides idle
0–3 at 6 FPS, move 0–5 at 10 FPS, attack 0–5, hurt 0–1, fall 0–3 and reverse
get-up 3–0. Only idle/move advance freely. The enemy script selects tell frames
0–3, contact frame 4, and recovery frame 5 from state timing. Grunt timing stays
0.4 / 0.1 / 0.4 seconds, damage 12 and speed 85. No health, reach, footprint,
reaction timing, AI, encounter or damage-rule changes were needed.

[The provenance record](../assets/PROVENANCE.md#step-09-alternate-art-proof)
identifies the existing CraftPix source and license record. The automated swap
suite checks the actual inherited scene, not a substitute mock.

## Replace another actor's art

1. Review suitable CraftPix sheets first. Verify the source/license and required
   motions; import only used files and record modifications in provenance.
2. Create an inherited validation scene before touching the main level. Make the
   actor instance editable and place visual overrides there. Keep its gameplay
   script and root/shadow structure.
3. Create a dedicated SpriteFrames resource if the new mapping differs. Use
   AtlasTexture rectangles for each source frame. Preserve semantic names:
   ordinary enemies need `idle`, `move`, `attack`, `hurt`, `fall`, `get_up`;
   the hero and boss have their own mappings in their existing frame resources.
   Avoid modifying a shared resource in place unless every user should change.
4. Set `centered = false`, adjust the sprite offset to put its feet at the root,
   and keep the source art facing +X. Adjust the separate `Visual` scale only
   when needed. Check both facings, near/far depth overlaps and shadows.
5. Check the actor's phase-driven frame selection. Ordinary enemies currently
   require six attack entries, with contact at entry 4 and recovery at entry 5;
   reorder/duplicate suitable source frames to satisfy that mapping. FPS alone
   does not change contact timing. If proportions or motion require changed reach
   or timing, make the smallest explicit tuning change and record why. Do not
   silently copy a different enemy's health or behavior along with its art.
6. Run import, startup, art-swap and affected mechanic suites. Inspect idle/move,
   tells/contact/recovery, hurt, knockdown/get-up and death; play a fight, check
   pause/retry and confirm main-level actors remain unchanged. Record automated,
   staged rendering and hands-on observations separately.

Missing air attacks/get-up in the current packs use the approved adaptations in
[the asset brief](../ASSETS.md). A new pack with different frame dimensions or
contact poses may require its own mapping and justified tuning; this proof does
not promise arbitrary filename replacement.

## Current limitations

Final listening, physical controller support, route balance, duration and a
complete title-to-victory/retry playthrough remain pending. Art review here is
staged rendering, not proof of animation feel or foot sliding during live play.
The backdrop repeats/mirrors the supplied street layers. Controller menu tests
inject events; no physical device is recorded. Volumes persist only until quit.
See the [acceptance checklist](ACCEPTANCE.md#manual-checks) for the remaining
observations before calling the game complete.
