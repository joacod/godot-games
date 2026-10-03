# Design

Rules for the finished one-level street brawler. Exported tuning lives on the
owning scenes; [the editing guide](EDITING.md) lists those files. Gameplay does
not depend on cyberpunk names, outfits, or story.

## Game loop

The title offers Play, Controls, Audio, and Quit. Play creates a fresh run.
The hero crosses a short introduction, clears two ordinary encounters, and
enters a final boss yard. Defeating the boss completes the level after its
death sequence.

Zero player health produces Game Over. Retry always restarts the entire level
with full health and fresh enemies, props, pickups, camera, and encounters.
There are no checkpoints or saved progress. Victory offers Play Again, Main
Menu, and Quit. Pause offers Resume, Retry, Audio, Main Menu, and Quit. If the
player and boss die in the same physics tick, player death takes precedence
and the result is handled once.

A successful first clear was planned at roughly 5–8 minutes. Duration comes
from play, not from adding more of the street.

## Controls

| Action | Keyboard | Controller position |
| --- | --- | --- |
| Move across the ground plane | WASD or arrow keys | Left stick or D-pad |
| Attack / continue combo | J | West face button |
| Jump | Space | South face button |
| Pause / resume | Escape | Start |
| Menu navigation / confirm / back | Arrows / Enter / Escape | D-pad / south / east |

Input Map actions drive movement. Diagonals are normalized. The stick deadzone
is 0.25. There is no run modifier. Controls are listed in the Controls screen.
Menu confirmation must not also attack or jump; release is required before
fresh gameplay input.

## Ground plane and jump

X is street length and Y is street depth. A character's root and collision
footprint stay at its feet on that plane. A separate numeric jump height moves
the visual child up and returns to zero on landing. Jumping never changes
street depth or bypasses encounter gates.

Actors and appropriate props sort by ground Y, not the raised sprite position.
A shadow stays at the ground anchor. Facing changes only with horizontal
movement; vertical movement keeps the last facing. A committed attack locks
facing. Ground movement remains possible in the air. Attacks restrict ground
movement.

The walkable strip is broad and unobstructed, with top, bottom, and endpoint
bounds. There is no pathfinding, stairs, platforming, pits, or navigation
obstacle. The camera follows X within the level and locks to each active
encounter. Camera bounds do not constrain movement. Gates and bounds do.

## Combat rules

- One attack press starts one strike. A press inside the combo buffer queues
  only the next strike, up to three. Holding Attack does not repeat. A late
  press resets the chain. The finisher knocks ordinary enemies down.
- Every attack has windup, active, and recovery, one committed facing, and a
  per-strike set of already-hit targets. One strike may hit multiple enemies,
  each target at most once. Windup and recovery deal no damage.
- Reach uses facing, ground X distance, ground Y tolerance, and jump-height
  eligibility. Sprite overlap alone is not a hit. Actors and breakables share
  one damage receiver path.
- A jump allows one air attack. It can hit grounded opponents only inside a
  low height band. Landing cancels any remaining air attack. Ordinary ground
  strikes miss actors above their height band. Airborne hurt cancels the
  attack and resolves into a landing recovery.
- Body contact causes no damage. Enemies cannot hurt each other. Ordinary hurt
  interrupts attacks. Player hurt grants a short invulnerability interval and
  visible feedback. Knockback stays inside the walkable area.
- Knocked-down ordinary enemies cannot attack or take repeated ground hits.
  Recovery includes a brief protected get-up. Zero health disables attacks
  immediately and reports defeat once.
- Boss hits reduce health. They do not interrupt its committed tells or
  attacks, and they do not knock it down. Recovery windows are the opening
  to retaliate.
- Pause freezes movement, state timers, damage, encounter spawning, and jump
  height. Restart cancels queued attacks, timers, temporary effects, and hit
  registries.

Timing, damage, and reach are exports on the owning actor. Rules are not tied
to sprite-sheet filenames or to equal animation lengths.

## Enemies and encounters

The grunt approaches, aligns to the hero's depth, winds up, strikes, and
recovers. The bruiser is slower, has more health, and commits to a longer,
stronger attack that knocks down. Both use the ordinary enemy scene and script
with explicit parameters.

An encounter allows at most two simultaneous enemy attack commitments. Others
reposition or wait. Slots release on cancellation, defeat, or reset. Simple
separation keeps enemies from stacking. Attacks do not start from outside the
visible fight area, and enemies do not spawn on the hero.

| Area | Bounds | Population |
| --- | --- | --- |
| Street entrance | Route from X=48 | No enemies; movement and button prompts |
| First street fight | X=480–1020, Y=242–312 | Two grunts |
| Connecting stretch | Between the fights | No enemies; one breakable crate and its food drop |
| Yard approach | X=1560–2100, Y=242–312 | Two grunts, then one grunt and one bruiser after 1.2 s |
| Final yard | X=2180–2720, Y=242–312 | One boss |

The whole route is X=48–2720 and Y=242–312. Ordinary encounters close their
boundaries after safe player entry and unlock only when every scheduled spawn
and live enemy is cleared. Each trigger runs once per run. Corpse animation
does not count as a live enemy. A visible Go prompt points forward after a clear.

The boss uses a short melee sweep and a telegraphed straight charge. Both
commit to a direction or lane, can be avoided by changing depth, and have a
punishable recovery. The charge stops at the arena boundary. There is no
second phase.

## Scene ownership

| Destination | Owns |
| --- | --- |
| `project.godot`, `main.tscn` | Configuration and entry into the title and game flow |
| `scenes/player/` | Player input, movement, combat, and visuals |
| `scenes/enemies/` | Ordinary enemy and boss scenes and state |
| `scenes/level/` | Street, boundaries, camera, encounters, and spawn markers |
| `scenes/props/` | Breakable crate and food pickup |
| `scenes/ui/` | HUD, title, controls, audio, and outcome and pause menus |
| `scripts/` | Shared helpers such as damage resolution |
| `assets/` | Used sprites, scenery, audio, and provenance and license files |
| `tests/` | Focused Godot regression scripts |

The run owner holds the current run and UI transitions. Encounters own local
wave state. Signals carry health, death, and clear events. Actors use explicit
enum state machines. There is no global service container, content database,
dependency injection layer, or runtime skin system.

Keep visual children separate from ground logic, keep semantic animation names,
and expose a small set of tuning values. [The editing guide](EDITING.md)
records the proven art swap.

## Left out on purpose

Co-op and networking, grabs and throws, weapons, special moves, blocking and
dodging, character selection, branching levels, progression, saves, score,
lives or continues, procedural content, mod support, runtime skins, a template
generator, editor plugins, publishing, and extra platforms. These are scope
cuts. The game does not claim every Final Fight mechanic.
