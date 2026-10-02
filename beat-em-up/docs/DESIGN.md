# Game design and implementation boundaries

These are proposed implementation defaults, not existing functionality. Steps
may refine tuning values with evidence while preserving the agreed scope.

## Game loop

Title offers Play, Controls, and Quit. Play creates a fresh run. The hero crosses
a short introduction stretch, clears two ordinary encounters, and enters a final
boss yard. Defeating the boss completes the level after its death sequence.

Zero player health produces Game Over. Retry always restarts the entire short
level with full health and fresh enemies, props, pickups, camera, and encounters.
No checkpoints or saved progress. Victory offers Play Again, Main Menu, and Quit.
Pause offers Resume, Retry, Main Menu, and Quit. If player and boss die in the
same physics tick, player death takes precedence; handle the result once.

## Controls

| Action | Keyboard | Controller position |
| --- | --- | --- |
| Move across ground plane | WASD or arrow keys | Left stick or D-pad |
| Attack / continue combo | J | West face button |
| Jump | Space | South face button |
| Pause / resume | Escape | Start |
| Menu navigation / confirm / back | Arrows / Enter / Escape | D-pad / south / east |

Use Input Map actions, normalized diagonal movement, and a stick deadzone.
No running modifier. Display bindings in Controls. Consuming menu confirmation
must not also attack or jump; require release before fresh gameplay input.

## Ground plane and jump

Use a 2D ground plane: X is street length and Y is street depth. A character's
root and collision footprint stay at its feet on that plane. A separate numeric
jump height moves the visual child upward and returns to zero at landing.
Jumping never changes street depth or bypasses encounter gates.

Sort actors and appropriate props by ground Y, not the raised sprite position.
Keep a shadow at the ground anchor. Facing changes only with horizontal movement;
vertical movement retains the last facing. Lock facing during a committed attack.
Ground movement remains possible in the air; attacks restrict ground movement.

Use a broad, unobstructed walkable strip with top/bottom and endpoint bounds.
Avoid pathfinding, stairs, platforming, pits, and obstacles requiring navigation.
The camera follows X within the level and locks to each active encounter.
Camera bounds alone do not constrain movement: actual gates/bounds prevent escapes.

## Combat rules

- One attack press starts one strike. A press inside the combo buffer queues only
  the next strike, up to three; holding Attack does not repeat indefinitely.
  A late press resets the chain. The finisher knocks ordinary enemies down.
- Every attack has windup, active, and recovery periods, one committed facing,
  and a per-strike set of already-hit targets. One strike may hit multiple enemies,
  but each target at most once. No damage during windup or recovery.
- Attack reach uses facing, ground X distance, ground Y tolerance, and jump-height
  eligibility. Visual sprite overlap alone is not a hit. Define a single damage
  receiver path used by actors and, later, breakables.
- A jump allows one air attack. It can hit grounded opponents only within a
  configured low-height band; landing cancels any remaining air attack. Ordinary
  ground strikes miss actors above their configured height band. Airborne hurt
  cancels the attack and resolves into a safe landing/recovery, never a stuck state.
- Body contact causes no damage. Enemies cannot hurt each other. Ordinary hurt
  interrupts attacks; player hurt grants a short invulnerability interval and
  visible feedback. Knockback stays inside the walkable area.
- Knocked-down ordinary enemies cannot attack or take repeated ground hits;
  recovery includes a brief protected get-up window. Zero health disables all
  attacks immediately and reports defeat once.
- Boss hits reduce health but do not interrupt its committed tells/attacks or
  knock it down. Its recovery windows provide reliable opportunities to retaliate.
- Pause freezes movement, state timers, damage, encounter spawning, and jump
  height. Restart cancels queued attacks, timers, temporary effects, and hit registries.

Keep timing/damage/reach editable in the owning scene or a small attack Resource
if the three combo entries warrant one. Record actual values when implemented.
Do not tie game rules to sprite-sheet filenames or assume equal animation lengths.

## Enemies and encounters

The grunt approaches, aligns to the hero's depth, visibly winds up, strikes,
and recovers. The bruiser moves more slowly, has more health, and commits to a
longer, stronger attack. Reuse the ordinary enemy scene/script with explicit
parameters if that stays readable; avoid a generic behavior-tree framework.

Use a small encounter-owned limit of at most two simultaneous enemy attack
commitments. Others reposition or wait. Release slots on cancellation, defeat,
or reset. Use simple separation so enemies do not collapse onto one point.
Do not start attacks from outside the visible fight area or spawn on the hero.

Initial level layout:

| Area | Purpose | Initial population |
| --- | --- | --- |
| Street entrance | Safe movement and button prompts | No enemies |
| First street fight | Teach spacing and combo | Two grunts |
| Connecting stretch | Breathing room; later food prop | No enemies |
| Yard approach | Teach mixed crowd combat | Two grunts, then one grunt and one bruiser |
| Final yard | Boss with room to evade | One boss, no additional enemies |

Counts are tuning defaults. Ordinary encounters close their boundaries after
safe player entry and unlock only when all scheduled spawns and live enemies
are cleared. Trigger once per run; never depend on corpse animation removal for
the live-enemy count. A visible Go prompt points forward after a clear.

The boss uses a short melee sweep and a telegraphed straight charge. Both commit
to a direction/line, can be avoided by changing depth, and have punishable recovery.
The charge stops safely at the arena boundary. No second phase is required.

## Scene ownership and modest reuse

Proposed paths are implementation destinations; do not create empty scaffolding
until a step needs it.

| Destination | Owns |
| --- | --- |
| `project.godot`, `main.tscn` | Configuration and entry into the title/game flow |
| `scenes/player/` | Player input, movement, combat, visuals |
| `scenes/enemies/` | Ordinary enemy and boss scenes/state |
| `scenes/level/` | Street, boundaries, camera, encounters and spawn markers |
| `scenes/props/` | Breakable and food pickup |
| `scenes/ui/` | HUD, title, controls and outcome/pause menus |
| `scripts/` | Only genuinely shared helpers such as damage resolution |
| `assets/` | Used sprites, scenery, audio, fonts and provenance/license files |
| `tests/` | Focused Godot regression scripts added with relevant mechanics |

Use a run owner for current run state and UI transitions; encounters own local
wave state. Use signals for health/death/clear events. Prefer explicit enum state
machines inside actors over a class per state. No global service container,
content database, dependency injection layer, or runtime skin system.

For future styles, keep visual children separate from ground logic, retain
semantic animation names, and expose a small set of useful tuning values.
Document concrete replacement steps after proving one swap in Step 09.
